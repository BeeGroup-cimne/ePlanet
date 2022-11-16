import os
import time

import happybase
import pandas as pd

from external_integration.Inergy.domain.Element import Element
from external_integration.Inergy.domain.HourlyData import HourlyData
from external_integration.Inergy.domain.RequestHourlyData import RequestHourlyData
from external_integration.Inergy.domain.SensorEnum import SensorEnum
from external_integration.Inergy.domain.Supply import Supply, get_sensor_id
from external_integration.Inergy.sources.InergySource import InergySource
from external_integration.constants import DEBUG, INVERTED_SENSOR_TYPE_TAXONOMY, TZ_INFO
from external_integration.logger import logger


def fn_insert_elements(args, id_project, data):
    to_insert = []
    for building in data:
        el = Element.create(id_project, building)
        if el:
            to_insert.append(el.__dict__)

    logger.info(f"DATA: {to_insert}")

    if not DEBUG:
        if args.method == 'insert':
            InergySource.insert_elements(data=to_insert)
        elif args.method == 'update':
            InergySource.update_elements(data=to_insert)


def fn_insert_supplies(args, id_project, data):
    to_insert = []
    for sensor in data:
        supply = Supply.create(id_project, sensor)
        if supply:
            to_insert.append(supply.__dict__)

    logger.info(f"DATA: {to_insert}")

    if not DEBUG:
        if args.method == 'insert':
            InergySource.insert_supplies(data=to_insert)
        elif args.method == 'update':
            InergySource.update_supplies(data=to_insert)


def fn_insert_hourly_data(args, id_project, data):
    for i in data:
        _from, sensor_id, sensor_type = get_sensor_id(i['s'].get('uri'))
        if sensor_type and _from and sensor_id:
            cups = f"{sensor_id}-{sensor_type}" if _from == 'CZ' else sensor_id
            cups = cups[:20]
            measure_id = i['m'].get('uri').split('#')[-1]

            logger.info(f"Sensor: {sensor_id} || Type: {sensor_type} || Measure: {measure_id}")
            print(f"Sensor: {sensor_id} || Type: {sensor_type} || Measure: {measure_id}")

            req_hour_data = RequestHourlyData(instance=1, id_project=id_project, cups=cups,
                                              sensor=str(SensorEnum[sensor_type].value),
                                              hourly_data=[])

            req_hour_data.hourly_data = get_data_hbase(_from, measure_id, sensor_type, args)

            logger.info(f"DATA: {req_hour_data.__dict__}")
            if not DEBUG and req_hour_data.hourly_data:
                try:
                    res = InergySource.update_hourly_data(data=[req_hour_data.__dict__])
                    logger.info(res)
                except Exception as ex:
                    logger.error(ex)


def gather_data(driver, fn_data, fn_insert, args, id_project):
    ttl = int(os.getenv('TTL'))
    t0 = time.time()

    index = 0
    count = 0  # number of items processed

    while time.time() - t0 < ttl:
        with driver.session() as session:
            data = fn_data(session, namespace=args.namespace, limit=args.limit, id_project=id_project,
                           skip=args.skip + (args.limit * index)).data()

        if data:
            fn_insert(args, id_project, data)
            index += 1

            if args.stop > 0:
                if args.stop < count:
                    break
                count += len(data)
        else:
            break


def clean_ts_data(_from, data):
    try:
        df = pd.DataFrame(data)
        # Cast Data
        df['start'] = df['start'].astype(int)
        df['end'] = df['end'].astype(int)
        df['value'] = df['value'].astype(float)

        df['start'] = pd.to_datetime(df['start'], unit='s').dt.tz_localize('UTC').dt.tz_convert(TZ_INFO)
        df['start'] = df['start'].dt.normalize()

        df['end'] = pd.to_datetime(df['end'], unit='s').dt.tz_localize('UTC').dt.tz_convert(TZ_INFO)
        df['end'] = df['end'].dt.normalize()

        df.set_index('end', inplace=True)
        df.sort_index(inplace=True)
        df.dropna(inplace=True)
        df = df[df['value'] > 0]

        if not df.empty and _from == 'GR':
            df['shifted'] = df['value'].shift(-1)
            df['isReal'] = df['shifted'] - df['value']
            df = df[df['isReal'] >= 0]
            df = df[['isReal']].resample('D').interpolate()
            df = df[['isReal']].resample('M').mean()
            df['isReal'] = df['isReal'].round(3)
            df.rename(columns={'isReal': 'value'}, inplace=True)

        logger.info(f"Data had been cleaned successfully.")
        return [HourlyData(value=row['value'], timestamp=index.replace(hour=12, day=1).isoformat()).__dict__ for
                index, row in
                df.iterrows()]
    except Exception as ex:
        logger.error(ex)
        return []


def get_data_hbase(_from, measure_id, sensor_type, args):
    # start_date = parse(args.start_date, dayfirst=True)
    # start_date.timestamp()
    hbase_conn = happybase.Connection(host=os.getenv('HBASE_HOST'), port=int(os.getenv('HBASE_PORT')),
                                      table_prefix=os.getenv('HBASE_TABLE_PREFIX'),
                                      table_prefix_separator=os.getenv('HBASE_TABLE_PREFIX_SEPARATOR'))
    table = hbase_conn.table(
        os.getenv(f'HBASE_TABLE_{_from}').format('online', INVERTED_SENSOR_TYPE_TAXONOMY.get(sensor_type)))
    ts_data = []

    # Gather TS data from measure_id
    for bucket in range(20):  # Bucket
        row_prefix = '~'.join([str(float(bucket)), measure_id])
        for key, value in table.scan(row_prefix=row_prefix.encode()):
            _, _, timestamp = key.decode().split('~')
            # timestamp = datetime.fromtimestamp(int(timestamp))
            value = decode_hbase_values(value=value)
            ts_data.append({'start': timestamp, 'end': value['info:end'], 'value': value['v:value']})
    logger.info(f"We found {len(ts_data)} records from {measure_id}")

    return clean_ts_data(_from, ts_data) if ts_data else []


def decode_hbase_values(value):
    item = dict()

    for k, v in value.items():
        item.update({k.decode(): v.decode()})
    return item
