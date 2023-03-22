from calendar import monthrange
from functools import partial
from hashlib import sha256

import pandas as pd
from neo4j import GraphDatabase
from rdflib import Namespace
from utils.cache import Cache
from utils.data_transformations import *
from utils.hbase import save_to_hbase
from utils.neo4j import create_sensor
from utils.nomenclature import harmonized_nomenclature, HarmonizedMode
from utils.rdf.rdf_functions import generate_rdf
from utils.rdf.save_rdf import save_rdf_with_source, link_devices_with_source
from slugify import slugify
import settings
from ontology.namespaces_definition import units, bigg_enums
from sources.Greece.harmonizer.Mapper import Mapper

max_meter = 99999
translations = {'Municipality unit': 'Municipal unit'}

TS_COLUMNS = ['StartDate', 'EndDate', 'Year', 'Month', 'Unique ID', 'Current record', 'Previous record', 'Variable',
              'Recording date', 'Previous recording date']


def get_source_df(df, user, conn):
    neo = GraphDatabase.driver(**conn)
    with neo.session() as session:
        source_id = session.run(f"""
        Match (n:FileSource)<-[:hasSource]-(org{{userID:"{user}"}})
        RETURN id(n) as id""").data()
    df['source_id'] = source_id[0]['id']
    return df[['device_subject', 'source_id']]


def set_municipality(df):
    municipality_dic = Cache.municipality_dic_GR
    # crete filter
    query_f = """SELECT ?s ?p ?o WHERE{ ?s ns1:parentADM1 <https://sws.geonames.org/6697802/> . ?s ?p ?o}"""
    municipality_fuzz = partial(fuzzy_dictionary_match,
                                map_dict=fuzz_params(
                                    municipality_dic,
                                    ['ns1:alternateName', 'ns1:shortName'],
                                    query_f
                                ),
                                default=None,
                                fix_score=75
                                )

    unique_municipality = df['Municipality'].unique()
    municipality_map = {k: municipality_fuzz(k) for k in unique_municipality}
    df.loc[:, 'hasAddressCity'] = df['Municipality'].map(municipality_map)


def clean_static_data(df, config):
    df.rename(columns=translations, inplace=True)
    # Location Organization Subject
    df['location_organization_subject'] = df['Municipality'].apply(slugify).apply(building_department_subject)
    # Building
    df['building_organization_subject'] = df['Unique ID'].apply(building_department_subject)
    df['building_subject'] = df['Unique ID'].apply(building_subject)

    # Building Space
    df['building_space_subject'] = df['Unique ID'].apply(building_space_subject)

    # Location
    df['location_subject'] = df['Unique ID'].apply(location_info_subject)
    # crete
    df['hasAddressProvince'] = rdflib.URIRef("https://sws.geonames.org/6697802/")
    set_municipality(df)

    # Device
    df['device_subject'] = df['Unique ID'].apply(partial(device_subject, source=config['source']))

    return df


def distribute_consumption(x):
    range = pd.date_range(x.StartDate, x.EndDate, freq="D")
    d_df = pd.DataFrame(index=range)
    d_df['value'] = x['value'] / len(d_df)
    return d_df


def calculate_value(x):
    if x['Current record'] >= x['Previous record']:
        return (x['Current record'] - x['Previous record']) * x['Variable']
    else:
        return (max_meter - x['Previous record'] + x['Current record']) * x['Variable']


def harmonize_ts_data(raw_df, kwargs):
    namespace = kwargs['namespace']
    config = kwargs['config']
    user = kwargs['user']

    n = Namespace(namespace)

    neo4j_connection = config['neo4j']
    neo = GraphDatabase.driver(**neo4j_connection)

    hbase_conn = config['hbase_store_harmonized_data']

    for device, df in raw_df.groupby('device_subject'):
        # ESTIMATED VALUES
        # if Current record =! na or 0 the data is REAL
        df['value'] = df.apply(calculate_value, axis=1)
        # also, when startDate is replicated, we keep only the last value
        df = df.sort_values("EndDate").drop_duplicates(["StartDate"])
        # generate daily data
        daily = pd.concat(df.apply(distribute_consumption, axis=1).to_list())
        daily = daily[~daily.index.duplicated()]
        monthly = daily.resample('M').mean()
        monthly['value'] = monthly.apply(lambda x: x.value * monthrange(x.name.year, x.name.month)[1], axis=1)

        monthly['end_date'] = monthly.index
        monthly['start_date'] = monthly['end_date'] - pd.offsets.MonthBegin(1)

        dt_ini = monthly.iloc[0]['start_date']
        dt_end = monthly.iloc[-1]['end_date']
        monthly['start'] = monthly['start_date'].astype(int) // 10 ** 9
        monthly["bucket"] = (monthly['start'].apply(int) // settings.ts_buckets) % settings.buckets
        monthly['end'] = monthly['end_date'].astype(int) // 10 ** 9
        monthly['isReal'] = True

        with neo.session() as session:
            device_uri = str(n[device])
            sensor_id = sensor_subject(config['source'], device,
                                       'EnergyConsumptionGridElectricity', "RAW", "P1M")
            sensor_uri = str(n[sensor_id])
            measurement_id = sha256(sensor_uri.encode("utf-8"))
            measurement_id = measurement_id.hexdigest()
            measurement_uri = str(n[measurement_id])
            create_sensor(session, device_uri, sensor_uri, units["KiloW-HR"],
                          bigg_enums.EnergyConsumptionGridElectricity, bigg_enums.TrustedModel,
                          measurement_uri, True,
                          False, False, "P1M", "SUM", dt_ini, dt_end, settings.namespace_mappings)

            monthly['listKey'] = measurement_id

            reduced_df = monthly[['start', 'end', 'value', 'listKey', 'bucket', 'isReal']]

            device_table = harmonized_nomenclature(mode=HarmonizedMode.ONLINE,
                                                   data_type='EnergyConsumptionGridElectricity',
                                                   R=True, C=False, O=False,
                                                   aggregation_function='SUM',
                                                   freq="P1M", user=user)

            save_to_hbase(reduced_df.to_dict(orient="records"), device_table, hbase_conn,
                          [("info", ['end', 'isReal']), ("v", ['value'])],
                          row_fields=['bucket', 'listKey', 'start'])


def building_filters(df):
    if len(df.Municipality.unique()) > 1:
        raise Exception("Error l'excel te més d'un municipi")
    municipality = df.Municipality.unique()[0]
    if municipality == "ΡΕΘΥΜΝΗΣ":
        return df[df['Name of the building or public lighting'] == "ΔΗΜΟΣ ΡΕΘΥΜΝΗΣ"]
    if municipality == "ΑΓΙΟΥ ΝΙΚΟΛΑΟΥ":
        return df[df['Name of the building or public lighting'] == "ΔΗΜΟΣ ΑΓ.ΝΙΚΟΛΑΟΥ"]
    if municipality == "ΧΑΝΙΩΝ":
        return df[df['Name of the building or public lighting'] == "ΔΗΜΟΣ ΧΑΝΙΩΝ"]
    if municipality == "ΧΕΡΣΟΝΗΣΟΥ":
        return df[df['Name of the building or public lighting'] == "ΔΗΜΟΣ ΧΕΡΣΟΝΗΣΟΥ"]
    if municipality == "ΗΡΑΚΛΕΙΟΥ":
        return df[df['Name of the building or public lighting'] == "ΔΗΜΟΣ ΗΡΑΚΛΕΙΟΥ"]
    if municipality == "ΜΙΝΩΑ ΠΕΔΙΑΔΑΣ":
        return df[df['Name of the building or public lighting'] == "ΔΗΜΟΣ ΜΙΝΩΑ ΠΕΔΙΑΔΟΣ"]
    if municipality == "ΑΓ.ΒΑΣΙΛΕΙΟΥ":
        df1 = df[df['Name of the building or public lighting'] == "ΔΗΜΟΣ"]
        df2 = df[df['Name of the building or public lighting'].str.contains(".*ΔΗΜΟΣ.*ΒΑΣΙΛΕΙΟΥ.*", regex=True)]
        df2 = df2[df2['Name of the building or public lighting'].str.contains("(?!.*ΦΟΠ)(?!.*ΦΩΤΙΣΜΟΣ)(?!.*ΦΩΤΙΣΜ)(?!.*ΦΩΤΕΙΝΟΙ)(?!.*ΑΝΤΛΙΟΣΤΑΘΜΟΣ)(?!.*ΑΦΟΔΕΥΤΗΡΙΑ)(?!.*ΠΑΡΚΙΝΓΚ)(?!.*Φ/B)(?!.*ΣΗΜΑΤΟΔΟΤΕΣ)")]
        return pd.append([df1, df2])
    if municipality == "ΑΜΑΡΙΟΥ":
        return df[df['Name of the building or public lighting'] == "ΔΗΜΟΣ ΑΜΑΡΙΟΥ"]
    if municipality == "ΔΗΜΟΣ ΑΝΩΓΕΙΩΝ":
        return df[df['Name of the building or public lighting'] == "ΔΗΜΟΣ ΑΝΩΓΕΙΩΝ"]
    if municipality == "ΑΠΟΚΟΡΩΝΟΥ":
        return df[df['Name of the building or public lighting'] == "ΔΗΜΟΣ ΑΠΟΚΟΡΩΝΟΥ"]
    if municipality == "ΑΡΧΑΝΩΝ-ΑΣΤΕΡΟΥΣΙΩΝ":
        return df[df['Name of the building or public lighting'] == "ΔΗΜΟΣ ΑΡΧΑΝΩΝ"]
    if municipality == "ΓΑΥΔΟΥ":
        return df[df['Name of the building or public lighting'] == "ΔΗΜΟΣ ΓΑΥΔΟΥ"]
    if municipality == "ΓΟΡΤΥΝΑΣ":
        return df[df['Name of the building or public lighting'] == "ΔΗΜΟΣ ΓΟΡΤΥΝΑΣ"]
    if municipality == "ΒΙΑΝΝΟΥ":
        return df[df['Name of the building or public lighting'] == "ΔΗΜΟΣ ΒΙΑΝΝΟΥ"]


def clean_general_data(df: pd.DataFrame):
    # Only buildings
    df = building_filters(df)
    if df.empty:
        return df
    df['StartDate'] = df['Previous recording date'].astype(str).str.zfill(8)
    df['EndDate'] = df['Recording date'].astype(str).str.zfill(8)

    df['StartDate'] = pd.to_datetime(df['StartDate'], format="%d%m%Y", errors='coerce')
    df['EndDate'] = pd.to_datetime(df['EndDate'], format="%d%m%Y", errors='coerce')
    df = df[~pd.isna(df["StartDate"])]
    if df.empty:
        return df
    df = df[~pd.isna(df["EndDate"])]
    if df.empty:
        return df

    df['Current record'] = df['Current record'].astype(float)
    df['Previous record'] = df['Previous record'].astype(float)
    df['Variable'] = df['Variable'].astype(float)
    df = df[(~pd.isna(df['Current record'])) & (df['Current record'] > 0)]
    df = df[(~pd.isna(df['Previous record']))]
    if df.empty:
        return df

    df['Unique ID'] = df['Unique ID'].astype(str)
    df.sort_values(by=['Unique ID', 'StartDate'], inplace=True)
    df.drop_duplicates(inplace=True)

    return df


def harmonize_data(data, **kwargs):
    namespace = kwargs['namespace']
    config = kwargs['config']
    user = kwargs['user']
    n = Namespace(namespace)

    df = pd.DataFrame(data)
    df = df.applymap(decode_hbase)

    df = clean_general_data(df)
    if df.empty:
        return
    df_static = df.copy(deep=True)
    df_static = clean_static_data(df_static, config)
    harmonize_static_data(df_static, config, kwargs, n)

    harmonize_ts_data(df_static, kwargs)


def harmonize_static_data(df, config, kwargs, n):
    user = kwargs['user']
    mapper = Mapper(config['source'], n)

    g = generate_rdf(mapper.get_mappings("static"), df)
    save_rdf_with_source(g, config['source'], config['neo4j'])
    link_devices_with_source(get_source_df(df, user, config['neo4j']), n, config['neo4j'])

