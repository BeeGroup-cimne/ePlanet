import os
import time
import settings
import happybase
import pandas as pd
from datetime import datetime
from external_integration.Inergy.domain.Element import Element
from external_integration.Inergy.domain.Action import Action
from external_integration.Inergy.domain.HourlyData import HourlyData
from external_integration.Inergy.domain.RequestHourlyData import RequestHourlyData
from external_integration.Inergy.domain.SensorEnum import SensorEnum
from external_integration.Inergy.domain.Supply import Supply, get_sensor_id
from external_integration.Inergy.sources.InergySource import InergySource
from external_integration.constants import DEBUG, INVERTED_SENSOR_TYPE_TAXONOMY, TZ_INFO
from external_integration.logger import logger
from external_integration.constants import PROJECTS
import requests

def get_responsible(id_project, headers, base_uri):

    res = requests.get(url=f"{base_uri}/responsibles/{id_project}", headers=headers, timeout=30)
    if res.ok:
        project_responsibles = dict(zip([d['name'] for d in res.json()], [d['idResponsible'] for d in res.json()]))
        if project_responsibles.keys() and PROJECTS[id_project].split('ORGANIZATION-')[1].capitalize() + ' responsible' in project_responsibles.keys():
            return project_responsibles[PROJECTS[id_project].split('ORGANIZATION-')[1].capitalize() + ' responsible']
        else:
            data = {
                "idProject": id_project,
                "name": PROJECTS[id_project].split('ORGANIZATION-')[1].capitalize() + ' responsible'
            }
            response = requests.post(url=f"{base_uri}/responsible", headers=headers, json=data, timeout=30)
            if response.ok:
                return response.json()
            else:
                res.raise_for_status()
    else:
        res.raise_for_status()

def fn_insert_actions(args=None, id_project=None, data=None):
    tok = ""
    headers = {'Authorization': f'Bearer {tok}', 'accept': 'application/json', 'Content-Type': 'application/json'}
    base_uri = 'https://sie-api-planning.inergy.online'

    to_insert = []

    project_responsible = get_responsible(id_project=id_project, headers=headers, base_uri=base_uri)

    for action in data:
        ac = Action.create(id_project=id_project, action=action, project_responsible=project_responsible)
        if ac:
            to_insert.append(ac.__dict__)
    try:
        res = InergySource.insert_actions(data=to_insert, headers=headers, base_uri=base_uri)
        logger.info(res)
    except Exception as ex:
        logger.error(ex)
        exit(-1)
    failed_actions = [x for x in res if x['is_error']]
    to_update = [y for y in to_insert if y['code'] in [y['code'] for y in failed_actions]]
    res = InergySource.update_actions(data=to_update)
    logger.info(res)

def fn_insert_elements(args, id_project, data, user):
    to_insert = []
    for building in data:
        el = Element.create(id_project, building, user)
        if el:
            to_insert.append(el.__dict__)
    logger.info(f"DATA: {to_insert}")
    try:
        res = InergySource.insert_elements(data=to_insert)
        logger.info(res)
    except Exception as ex:
        logger.error(ex)
        exit(-1)
    failed_buildings = [x for x in res if x['is_error']]
    print([y['code'] for y in failed_buildings])
    to_update = [y for y in to_insert if y['code'] in [y['code'] for y in failed_buildings]]
    res = InergySource.update_elements(data=to_update)
    logger.info(res)
    if not DEBUG:
        if args.method == 'insert':
            InergySource.insert_elements(data=to_update)
        elif args.method == 'update':
            InergySource.update_elements(data=to_insert)

def fn_insert_supplies(args, id_project, data):
    to_insert = []
    for sensor in data:
        supply = Supply.create(id_project, sensor)
        if supply:
            to_insert.append(supply.__dict__)
    logger.info(f"DATA: {to_insert}")
    try:
        res = InergySource.insert_supplies(data=to_insert)
        logger.info(res)
    except Exception as ex:
        logger.error(ex)
        exit(-1)
    failed_supplies = [x for x in res if x['is_error']]

    to_update = [y for y in to_insert if y['code'] in [y['code'] for y in failed_supplies]]
    res = InergySource.update_supplies(data=to_update)
    logger.info(res)

    if not DEBUG:
        if args.method == 'insert':
            InergySource.insert_supplies(data=to_insert)
        elif args.method == 'update':
            InergySource.update_supplies(data=to_insert)


def fn_insert_hourly_data(args, id_project, data, config, user):
    tok = ""
    headers = {'Authorization': f'Bearer {tok}', 'accept': 'application/json', 'Content-Type': 'application/json'}
    base_uri = 'https://apiv20.inergy.online'
    for i in data:
        _from, sensor_id, sensor_type = get_sensor_id(i['s'].get('uri'), i['m.uri'])
        if sensor_type and _from and sensor_id:
            cups = f"{sensor_id}-{sensor_type}" if _from == 'CZ' else sensor_id
            measure_id = i['mes.uri'].split('#')[-1]

            logger.info(f"Sensor: {sensor_id} || Type: {sensor_type} || Measure: {measure_id}")

            table = {"type": i['m.uri'].split('#')[1],
                     "RCO": ('1' if i['s'].get('bigg__timeSeriesIsRegular') else '0') +
                            ('1' if i['s'].get('bigg__timeSeriesIsCumulative') else '0') +
                            ('1' if i['s'].get('bigg__timeSeriesIsOnChange') else '0'),
                     "AGG": i['s'].get('bigg__timeSeriesTimeAggregationFunction'),
                     "FRE": i['s'].get('bigg__timeSeriesFrequency'),
                     "USER": user
                     }
            req_hour_data = RequestHourlyData(instance=1, id_project=id_project, cups=cups,
                                              sensor=str(SensorEnum[sensor_type].value),
                                              hourly_data=[])

            req_hour_data.hourly_data = get_data_hbase(_from, measure_id, sensor_type, args.year, table, config)
            logger.info(f"DATA: {req_hour_data.__dict__}")
            if req_hour_data.hourly_data:
                try:

                    res = InergySource.update_hourly_data(data=[req_hour_data.__dict__], headers=headers, base_uri=base_uri)
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

        logger.info(f"Data had been cleaned successfully.")
        return [HourlyData(value=row['value'], timestamp=index.replace(hour=12, day=1).isoformat()).__dict__ for
                index, row in
                df.iterrows()]
    except Exception as ex:
        logger.error(ex)
        return []


def get_data_hbase(_from, measure_id, sensor_type, year, table_p, config):
    # calculate buckets with a list of [(ts_ini of bucket, ts_end of bucket, bucket, index),...]
    start_date = int(datetime(int(year), 1, 1).timestamp())
    end_date = int(datetime(int(year), 12, 31).timestamp())
    bucket_ts_ini = (int(start_date) // settings.ts_buckets)
    bucket_ts_end = (int(end_date) // settings.ts_buckets)
    if end_date < ((bucket_ts_ini + 1) * settings.ts_buckets):
        bucket_map = [(start_date, end_date, bucket_ts_ini % settings.buckets, 1)]
    else:
        bucket_map = [(start_date, (bucket_ts_ini + 1) * settings.ts_buckets, bucket_ts_ini % settings.buckets, 1)]

    for x in range(bucket_ts_ini + 1, bucket_ts_end):
        bucket_map.append((x * settings.ts_buckets, (x + 1) * settings.ts_buckets, x % settings.buckets, len(bucket_map) + 1))
    if not end_date < ((bucket_ts_ini + 1) * settings.ts_buckets):
        bucket_map.append((bucket_ts_end * settings.ts_buckets, end_date, bucket_ts_end % settings.buckets, len(bucket_map) + 1))
    bucket_iter = iter(bucket_map)

    # get data from hbase
    ts_data = []
    for ts_ini, ts_end, bucket, index in bucket_iter:
        row_start = '~'.join([str(int(bucket)), measure_id, str(int(ts_ini))])
        row_end = '~'.join([str(int(bucket)), measure_id, str(int(ts_end))])

        hbase_conn = happybase.Connection(**config['hbase_store_harmonized_data'])
        table = hbase_conn.table('harmonized_online_{type}_{RCO}_{AGG}_{FRE}_{USER}'.format(**table_p))

        for key, value in table.scan(row_start=row_start.encode(), row_stop=row_end.encode()):
            _, _, timestamp = key.decode().split('~')
            value = decode_hbase_values(value=value)
            ts_data.append({'start': timestamp, 'end': value['info:end'], 'value': value['v:value']})
    print(ts_data)
    logger.info(f"We found {len(ts_data)} records from {measure_id}")

    return clean_ts_data(_from, ts_data) if ts_data else []


def decode_hbase_values(value):
    item = dict()
    for k, v in value.items():
        item.update({k.decode(): v.decode()})
    return item
