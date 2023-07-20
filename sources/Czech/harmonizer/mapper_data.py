import datetime
from functools import partial
from hashlib import sha256

import numpy as np
import pandas as pd
from dateutil.relativedelta import relativedelta
from neo4j import GraphDatabase
from rdflib import Namespace
from utils.cache import Cache
from utils.data_transformations import *
from utils.hbase import save_to_hbase
from utils.neo4j import create_sensor

from utils.rdf.rdf_functions import generate_rdf
from utils.rdf.save_rdf import save_rdf_with_source, link_devices_with_source
from utils.utils import read_config

import settings
from ontology.namespaces_definition import bigg_enums, units
from sources.Czech.harmonizer.Mapper import Mapper
from slugify import slugify

consumptionType = {
    "plyn": "EnergyConsumptionGas",
    "Plyn": "EnergyConsumptionGas",
    "elektřina celkem": "EnergyConsumptionGridElectricity",
    "elektřina celkem (kWh)": "EnergyConsumptionGridElectricity",
    "Elektřina celkem": "EnergyConsumptionGridElectricity",
    "Teplo": "EnergyConsumptionDistrictHeating",
    "teplo": "EnergyConsumptionDistrictHeating",
    "Voda": "EnergyConsumptionWaterHeating",
    "voda (m3)": "EnergyConsumptionWaterHeating",
    "voda": "EnergyConsumptionWaterHeating"
}

region_condition = ['Hasičský záchranný sbor Zlínského kraje', 'Zlínský kraj']

def set_municipality(df):
    municipality_dic = Cache.municipality_dic_CZ
    municipality_fuzz = partial(fuzzy_dictionary_match,
                                map_dict=fuzz_params(
                                    municipality_dic,
                                    ['ns1:name']
                                ),
                                default=None
                                )
    unique_municipality = df['Municipality'].unique()
    municipality_map = {k: municipality_fuzz(k) for k in unique_municipality}
    df.loc[:, 'hasAddressCity'] = df['Municipality'].map(municipality_map)


def set_province(df):
    province_dic = Cache.province_dic_CZ
    province_fuzz = partial(fuzzy_dictionary_match,
                            map_dict=fuzz_params(
                                province_dic,
                                ['ns1:name']
                            ),
                            default=None
                            )
    unique_province = df['Region'].unique()
    province_map = {k: province_fuzz(k) for k in unique_province}
    df.loc[:, 'hasAddressProvince'] = df['Region'].map(province_map)


def get_source_df(df, user, conn):
    neo = GraphDatabase.driver(**conn)
    with neo.session() as session:
        source_id = session.run(f"""
        Match (n:FileSource)<-[:hasSource]-(org{{userID:"{user}"}})
        RETURN id(n) as id""").data()
    df['source_id'] = source_id[0]['id']
    return df[['device_subject', 'source_id']]


def set_organization(df):
    df["organization"] = df["Municipality"]
    df.loc[df.Owner.isin(region_condition), 'organization'] = 'Zlin region'
    return df

def harmonize_building_info(data, **kwargs):
    namespace = kwargs['namespace']
    user = kwargs['user']
    n = Namespace(namespace)
    config = kwargs['config']



    df = pd.DataFrame(data)
    # columns translate
    translations = {"Země": 'Country', 'Kraj': 'Region', 'Město / obec': 'Municipality',
                    'Ulice': 'Road', 'č.p.': 'Road Number', 'PSČ': 'PostalCode',
                    'Zeměpisná délka': 'Longitude', 'Zeměpisná šířka': 'Latitude', 'Název': 'Name',
                    'Způsob využití': 'Use Type', 'Vlastník':'Owner', 'Rok výstavby': 'YearOfConstruction',
                    "Celková podlahová plocha": 'GrossFloorArea', 'Datum zpracování': 'EnergyCertificateDate',
                    'Klasifikační třída budovy dle PENB	': 'EnergyCertificateQualification',
                    'OZE \n(Ano / Ne)': 'Renewable', "Energetický audit \n(Ano / Ne)": 'EnergyAudit',
                    'Energetický management (Ano / Ne)': 'Monitoring', 'Fotovoltaika (Ano / Ne)': 'SolarPV',
                    'Solární ohřev vody (Ano/Ne)': 'SolarThermal'

                    }
    df = df.rename(translations, axis=1)

    df = df.applymap(decode_hbase)
    # Location Organization Subject
    df = set_organization(df)
    df['location_organization_subject'] = df['organization'].apply(slugify).apply(building_department_subject)
    # Building
    df['building_organization_subject'] = df['Unique ID'].apply(building_department_subject)
    df['building_subject'] = df['Unique ID'].apply(building_subject)

    # BuildingSpace
    df['Use Type'] = df['Use Type'].str.strip()
    building_type_taxonomy = get_taxonomy_mapping(
        taxonomy_file="sources/Czech/harmonizer/BuildingUseTypeTaxonomy.xls",
        default="Other")
    df['buildingSpaceUseType'] = df['Use Type'].map(building_type_taxonomy).apply(partial(to_object_property,
                                                                                          namespace=bigg_enums))
    df['building_space_subject'] = df['Unique ID'].apply(building_space_subject)

    # Location
    df['location_subject'] = df['Unique ID'].apply(location_info_subject)
    set_municipality(df)
    set_province(df)

    # Area
    df['gross_floor_area_subject'] = df['Unique ID'].apply(partial(gross_area_subject, a_source=config['source']))

    # EnergyPerformanceCertificate
    df['EnergyCertificateDate_timestamp'] = pd.to_datetime(df['EnergyCertificateDate']).view(int) // 10 ** 9
    df['energy_performance_certificate_subject'] = df.apply(
        lambda x: f"EPC-{x['Unique ID']}-{x['EnergyCertificateDate_timestamp']}",
        axis=1)

    # AdditionalInfoEPC
    df['energy_performance_certificate_additional_subject'] = df.apply(
        lambda x: f"ADDITIONAL-EPC-{x['Unique ID']}-{x['EnergyCertificateDate_timestamp']}",
        axis=1)
    translate_dict = {'Ano': True, 'Ne': False}
    # df['Renewable'] = df['Renewable'].map(translate_dict)
    # df['EnergyAudit'] = df['EnergyAudit'].map(translate_dict)
    # df['Monitoring'] = df['Monitoring'].map(translate_dict)
    df['SolarPV'] = df['SolarPV'].map(translate_dict)
    df['SolarThermal'] = df['SolarThermal'].map(translate_dict)

    # # Project
    # df['project_subject'] = df['Unique ID'].apply(project_subject)
    # df['hasProject'] = df['project_subject'].apply(lambda x: n[x])

    # Element
    df['element_subject'] = df['Unique ID'].apply(construction_element_subject)

    # Devices
    df['device_subject'] = df['Unique ID'].apply(partial(device_subject, source=config['source']))
    mapper = Mapper(config['source'], n)
    g = generate_rdf(mapper.get_mappings("building_info"), df)
    save_rdf_with_source(g, config['source'], config['neo4j'])
    link_devices_with_source(get_source_df(df, user, config['neo4j']), n, config['neo4j'])


def harmonize_building_emm(data, **kwargs):
    namespace = kwargs['namespace']
    n = Namespace(namespace)
    user = kwargs['user']

    config = kwargs['config']

    config = {'neo4j': {'uri': 'neo4j://master1.internal:7687', 'auth': ('neo4j', 'neo4j1')}, 'hbase_store_raw_data': {'host': 'master2.internal', 'port': 9090, 'table_prefix': 'eplanet_raw_data', 'table_prefix_separator': ':'}, 'hbase_store_harmonized_data': {'host': 'master2.internal', 'port': 9090, 'table_prefix': 'eplanet_harmonized_data', 'table_prefix_separator': ':'}, 'kafka': {'connection': {'hosts': ['kafka1.internal'], 'ports': [29092]}, 'topic': 'eplanet', 'group_harmonize': 'group_harmonize', 'group_store': 'group_store'}, 'inergy': {'username': 'beegroup@cimne.upc.edu', 'password': '5lq1r4ZpVrK_V47h23Z16', 'base_uri': 'https://apiv20.inergy.online'}, 'inergy_dev': {'username': 'beegrouptest@cimne.upc.edu', 'password': '5H7YxUKMUB7d_Sn8nPFQZ', 'base_uri': 'https://api-dev.inergy.online'}, 'inergy_dev_auth': {'username': 'glaguna@cimne.upc.edu', 'password': 'sdfgh$$TT', 'base_uri': 'https://auth-dev.inergy.online'}, 'inergy_planning-dev': {'base_uri': ' https://api-planning-dev.inergy.online'}, 'source': 'Czech'}

    namespace = "https://czech.cz#"
    n = Namespace(namespace)
    user = "czech"

    # df = pd.DataFrame().from_records(data)
    translations = {"Název projektu / opatření": 'ETM Name', 'Realizovaná opatření': 'Measure Implemented',
                    "Datum": 'Date', 'Životnost opatření': 'EEM Life', 'Investice (Kč)': 'Investment',
                    'Dotace (Kč)': 'Subsidy', 'Směnný kurz (Kč/EUR)': 'Currency Rate',
                    'Roční energetické úspory (GJ)': 'Annual Energy Savings',
                    'Roční úspora CO2 (tuny)': 'Annual CO2 reduction', 'Komentáře': 'Comments'}

    df = pd.read_excel(f"data/Czech/building/Building_identification_data_EAZK_v5_CZE.xlsm", skiprows=1, sheet_name=1)
    df.rename(columns={"Unikátní kód": 'Unique ID'}, inplace=True)

    df = df.rename(translations, axis=1)
    df = df.applymap(decode_hbase)

    # explode and convert measure
    df = df.replace({'Measure Implemented': {'nan': np.nan}}).dropna(subset=['Measure Implemented'])
    df['Measure Implemented'] = df['Measure Implemented'].apply(lambda x: [re.sub(';|_x000D_', '', s).strip() for s in x.split(";")]).values
    df = df.explode('Measure Implemented').reset_index(drop=True)

    # Element
    df['element_subject'] = df['Unique ID'].apply(construction_element_subject)

    # EnergyEfficiencyMeasure
    df['energy_efficiency_measure_subject'] = df.apply(
            lambda x: eem_subject(f"{x['Unique ID']}-{slugify(x['Measure Implemented'])}"), axis=1)

    eem_type_taxonomy = get_taxonomy_mapping(
        taxonomy_file="sources/Czech/harmonizer/EEMTypeTaxonomy.xls",
        default="Other")
    df['hasEnergyEfficiencyMeasureType'] = df['Measure Implemented'].map(eem_type_taxonomy).apply(partial(to_object_property,
                                                                                                  namespace=bigg_enums))

    df['Currency Rate'] = float(1)/df['Currency Rate'].astype(float)
    # EnergySaving
    df['energy_saving_subject'] = df['Unique ID'].apply(energy_saving_subject)

    df['epc_date'] = df['Date'].apply(lambda x: datetime.datetime(year=int(x.split('-')[0]), month=1, day=1, hour=0).strftime("%Y-%m-%dT%H:%M:%SZ"))
    df['eem_date'] = df['Date'].apply(lambda x: datetime.datetime(year=int(x.split('-')[1]) if '-' in x else int(x), month=12, day=31, hour=23).strftime("%Y-%m-%dT%H:%M:%SZ"))

    df['hasEnergySavingType'] = to_object_property('TotalEnergySaving', namespace=bigg_enums)

    # Project
    df['project_subject'] = df.apply(
        lambda x: f"PROJECT-{x['Unique ID']}", axis=1)
    # Buildings
    df['building_subject'] = df.apply(
        lambda x: f"BUILDING-{x['Unique ID']}", axis=1)


    mapper = Mapper(config['source'], n)
    g = generate_rdf(mapper.get_mappings("eem_project"), df)
    save_rdf_with_source(g, config['source'], config['neo4j'])


def harmonize_ts(df, data_type, n, freq, config, user):
    hbase_conn = config['hbase_store_harmonized_data']
    neo4j_connection = config['neo4j']
    neo = GraphDatabase.driver(**neo4j_connection)

    df['Year'] = df['Year'].astype(int)
    df['date'] = df.apply(lambda x: f"{x.Year}/{int(x.Month)}/1", axis=1)
    df['date'] = pd.to_datetime(df['date'])
    df['start'] = df['date'].astype(int) // 10 ** 9
    df["bucket"] = (df['start'] // settings.ts_buckets) % settings.buckets
    df['end'] = df['date'] + pd.DateOffset(months=1) - pd.DateOffset(days=1)
    df['end'] = df['end'].astype(int) // 10 ** 9
    if data_type == "EnergyConsumptionGas":
        df['value'] = df['value'] * 10.69
    elif data_type == "EnergyConsumptionDistrictHeating":
        df['value'] = df['value'] * 277.77
    df['isReal'] = True
    df = df[df['value'] != 0]
    if df.empty:
        return
    # get min and max
    df.set_index("date", inplace=True)
    df.sort_index(inplace=True)
    dt_ini = df.iloc[0].name
    dt_end = df.iloc[-1].name

    device_uri = n[df['device_subject'].unique()[0]]
    sensor_id = sensor_subject(config['source'], df['device_subject'].unique()[0], data_type, "RAW", freq)

    sensor_uri = str(n[sensor_id])
    measurement_id = sha256(sensor_uri.encode("utf-8"))
    measurement_id = measurement_id.hexdigest()
    measurement_uri = str(n[measurement_id])

    with neo.session() as session:
        create_sensor(session, device_uri, sensor_uri, units["KiloW-HR"],
                      bigg_enums[data_type], bigg_enums.TrustedModel,
                      measurement_uri, True,
                      False, False, freq, "SUM", dt_ini, dt_end, settings.namespace_mappings)
        df['listKey'] = measurement_id
        device_table = f"harmonized_online_{data_type}_100_SUM_{freq}_{user}"

        save_to_hbase(df.to_dict(orient="records"),
                      device_table,
                      hbase_conn,
                      [("info", ['end', 'isReal']), ("v", ['value'])],
                      row_fields=['bucket', 'listKey', 'start'])
        # print(df)

def harmonize_simple_ts(data, **kwargs):
    # Variables
    namespace = kwargs['namespace']
    n = Namespace(namespace)
    config = kwargs['config']
    user = kwargs['user']
    freq = 'P1M'

    # Data processing

    df = pd.DataFrame(data)

    # harmonize data
    df['device_subject'] = df['Unique ID'].apply(partial(device_subject, source=config['source']))
    df = df.rename({"month": "Month"}, axis=1)
    df = df[df['Month'] < 13]
    available_years = [i for i in list(df.columns) if type(i) == int]
    data_type = df['data_type'].unique()[0]
    df = df.rename(columns={df.columns[0]: 'Data'})

    df = df.melt(id_vars=['Data', 'Month', 'device_subject'],
                 value_vars=available_years, var_name='Year',
                 value_name='value')
    df = df.dropna(subset=["value"])
    harmonize_ts(df, data_type, n, freq, config, user)


def harmonize_complex_ts(data, **kwargs):
    namespace = kwargs['namespace']
    n = Namespace(namespace)
    config = kwargs['config']
    user = kwargs['user']
    freq = 'P1M'

    df = pd.DataFrame(data)
    try:
        df.drop('celkem', axis=1, inplace=True)
    except:
        pass
    df.columns = ['DataType', 'Year', 1, 2, 3, 4, 5, 6, 7, 8,
                  9, 10, 11, 12, 'Unit', 'Unique ID']
    df['device_subject'] = df['Unique ID'].apply(partial(device_subject, source=config['source']))

    df = df.melt(id_vars=["DataType", "Year", "Unit", "Unique ID", 'device_subject'], value_vars=range(1, 13),
                 value_name="value", var_name="Month")

    df['DataType'] = df['DataType'].map(consumptionType)
    df = df[df['DataType'].notna()]
    df = df.dropna(subset=['value'])
    print(df.dtypes)
    df = df[df['value'] != 0]
    if df.empty:
        return
    for data_type, sub_df in df.groupby("DataType"):
        harmonize_ts(sub_df, data_type, n, freq, config, user)

