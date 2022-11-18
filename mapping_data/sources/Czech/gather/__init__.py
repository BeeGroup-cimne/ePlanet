import argparse
import os

import pandas as pd
from utils.hbase import save_to_hbase
from utils.kafka import save_to_kafka
from utils.nomenclature import raw_nomenclature, RawMode
from utils.utils import log_string


def gather(arguments, settings, config):
    ap = argparse.ArgumentParser(description='Gathering data from Czech')
    ap.add_argument("-st", "--store", required=True, help="Where to store the data", choices=["kafka", "hbase"])
    ap.add_argument("--user", "-u", help="The user importing the data", required=True)
    ap.add_argument("--namespace", "-n", help="The subjects namespace uri", required=True)
    ap.add_argument("-f", "--file", required=True, help="Excel file path to parse")
    ap.add_argument("-kf", "--kind_of_file", required=True,
                    help="Choice the kind of file that you would like to harmonize.",
                    choices=['ts', 'building_data', 'building_eem'])

    args = ap.parse_args(arguments)

    if args.kind_of_file == 'building_data':
        gather_building_info(args, config, settings)

    if args.kind_of_file == 'building_eem':
        gather_building_eem(args, config, settings)

    if args.kind_of_file == 'ts':
        freq = 'PT1M'

        for file in os.listdir(args.file):
            log_string(f"File: {file}")

            xl = pd.ExcelFile(f"{args.file}/{file}")

            for i in xl.sheet_names:
                if 'plyn' in i:  # GAS
                    gather_ts_simple_gas(args, config, file, freq, i, settings)

                elif 'elektřin' in i:
                    gather_ts_simple_electricity(args, config, file, freq, i, settings)

                elif 'souhrn' in i:
                    gather_ts_complex(args, config, file, i, settings)


def gather_ts_complex(args, config, file, i, settings):
    try:
        df = pd.read_excel(f"{args.file}/{file}", sheet_name=i, skiprows=99)
        df.dropna(how='all', axis='columns', inplace=True)

        df['Unique ID'] = file.split('_')[0]
        save_data(data=df.to_dict(orient="records"), data_type="complex_ts",
                  row_keys=["Unique ID"],
                  column_map=[("info", "all")], config=config, settings=settings, args=args,
                  table_name=raw_nomenclature(mode=RawMode.TIMESERIES, data_type="Consumptions",
                                              frequency="",
                                              user=args.user, source=config['source']))
    except Exception as ex:
        log_string(ex)


def gather_ts_simple_electricity(args, config, file, freq, i, settings):
    try:
        unique_id = f"{file}".split('_')[0]
        df = pd.read_excel(f"{args.file}/{file}", sheet_name=i,
                           skiprows=6)

        available_years = [i for i in list(df.columns) if type(i) == int]

        df = pd.read_excel(f"{args.file}/{file}", sheet_name=i,
                           skiprows=7)

        df.dropna(how='all', axis='columns', inplace=True)

        headers = ['Months']

        for year in available_years:
            headers.append(f'VT_{year}')
            headers.append(f'NT_{year}')
            headers.append(year)

        df.columns = headers

        df['Unique ID'] = unique_id
        df['data_type'] = 'EnergyConsumptionGridElectricity'
        df = df.iloc[:12]
        df['month'] = [i for i in range(1, 13)]

        save_data(data=df.to_dict(orient="records"), data_type="simple_ts",
                  row_keys=["Unique ID"],
                  column_map=[("info", "all")], config=config, settings=settings, args=args,
                  table_name=raw_nomenclature(mode=RawMode.TIMESERIES,
                                              data_type="EnergyConsumptionGridElectricity",
                                              frequency=freq,
                                              user=args.user, source=config['source']))
    except Exception as ex:
        log_string(ex)


def gather_ts_simple_gas(args, config, file, freq, i, settings):
    try:
        unique_id = f"{file}".split('_')[0]
        df = pd.read_excel(f"{args.file}/{file}", skiprows=5, sheet_name=i)
        df.dropna(how='all', axis='columns', inplace=True)
        df['Unique ID'] = unique_id
        df['data_type'] = 'EnergyConsumptionGas'
        df = df.iloc[:12]
        df['month'] = [i for i in range(1, 13)]

        save_data(data=df.to_dict(orient="records"), data_type="simple_ts",
                  row_keys=["Unique ID"],
                  column_map=[("info", "all")], config=config, settings=settings, args=args,
                  table_name=raw_nomenclature(mode=RawMode.TIMESERIES, data_type="EnergyConsumptionGas",
                                              frequency=freq,
                                              user=args.user, source=config['source']))
    except Exception as ex:
        log_string(ex)


def gather_building_eem(args, config, settings):
    for file in os.listdir(args.file):
        try:
            df = pd.read_excel(f"{args.file}/{file}", skiprows=1, sheet_name=1)
            df.rename(columns={"Unikátní kód": 'Unique ID'}, inplace=True)

            save_data(data=df.to_dict(orient="records"), data_type="EnergyEfficiencyMeasure",
                      row_keys=["Unique ID"],
                      column_map=[("info", "all")], config=config, settings=settings, args=args,
                      table_name=raw_nomenclature(mode=RawMode.STATIC, data_type="EnergyEfficiencyMeasure",
                                                  user=args.user, source=config['source']))
        except Exception as ex:
            log_string(ex)


def gather_building_info(args, config, settings):
    for file in os.listdir(args.file):
        try:
            df = pd.read_excel(f"{args.file}/{file}", skiprows=1, sheet_name=0)
            df.rename(columns={"Unikátní kód": 'Unique ID'}, inplace=True)
            save_data(data=df.to_dict(orient="records"), data_type="BuildingInfo",
                      row_keys=["Unique ID"],
                      column_map=[("info", "all")], config=config, settings=settings, args=args,
                      table_name=raw_nomenclature(mode=RawMode.STATIC, data_type="BuildingInfo",
                                                  user=args.user, source=config['source']))
        except Exception as ex:
            log_string(ex)


def save_data(data, data_type, row_keys, column_map, config, settings, args, table_name):
    if args.store == "kafka":
        try:
            k_topic = config["kafka"]["topic"]
            kafka_message = {
                "namespace": args.namespace,
                "user": args.user,
                "collection_type": data_type,
                "source": config['source'],
                "row_keys": row_keys,
                "data": data,
                "table_name": table_name
            }
            save_to_kafka(topic=k_topic, info_document=kafka_message,
                          config=config['kafka']['connection'], batch=settings.kafka_message_size)

        except Exception as e:
            log_string(f"error when sending message: {e}")

    elif args.store == "hbase":

        try:
            save_to_hbase(data, table_name, config['hbase_store_raw_data'], column_map,
                          row_fields=row_keys)
        except Exception as e:
            log_string(f"Error saving datadis supplies to HBASE: {e}")
    else:
        log_string(f"store {config['store']} is not supported")
