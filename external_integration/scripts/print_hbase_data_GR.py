import argparse
import datetime
import os
from datetime import datetime, date

import happybase
from dotenv import load_dotenv
from neo4j import GraphDatabase

from external_integration.Inergy.domain.Supply import get_sensor_id
from external_integration.constants import INVERTED_SENSOR_TYPE_TAXONOMY
from external_integration.utils import decode_hbase_values
from external_integration.utils.neo4j import get_sensors_measurements_by_sensor_id


def get_hbase_raw_data(cups: str):
    hbase_conn = happybase.Connection(host=os.getenv('HBASE_HOST'), port=int(os.getenv('HBASE_PORT')),
                                      table_prefix='eplanet_raw_data',
                                      table_prefix_separator=os.getenv('HBASE_TABLE_PREFIX_SEPARATOR'))

    table = hbase_conn.table('raw_Greece_static_BuildingInfo__eplanet')
    ts_data = []
    for year in range(2015, date.today().year + 1):
        for month in range(1, 13):
            row_prefix = '~'.join([str(year), str(month), cups])
            for key, value in table.scan(row_prefix=row_prefix.encode()):
                _year, _month, _sensor_id = key.decode().split('~')
                value = decode_hbase_values(value=value)
                ts_data.append({'date': date(year=int(_year), month=int(_month), day=1),
                                'value': float(value['info:Current record'])})
    print(ts_data)


def get_hbase_harmonized(cups: str):
    with driver.session() as session:
        res = get_sensors_measurements_by_sensor_id(session, cups).data()

    ts_data = []
    for i in res:
        _from, sensor_id, sensor_type = get_sensor_id(res[0]['s'].get('uri'))
        measure_id = i['m'].get('uri').split('#')[-1]

        hbase_conn = happybase.Connection(host=os.getenv('HBASE_HOST'), port=int(os.getenv('HBASE_PORT')),
                                          table_prefix=os.getenv('HBASE_TABLE_PREFIX'),
                                          table_prefix_separator=os.getenv('HBASE_TABLE_PREFIX_SEPARATOR'))
        table = hbase_conn.table(
            os.getenv(f'HBASE_TABLE_{_from}').format('online',
                                                     INVERTED_SENSOR_TYPE_TAXONOMY.get(sensor_type)))

        # Gather TS data from measure_id

        for bucket in range(20):  # Bucket
            row_prefix = '~'.join([str(float(bucket)), measure_id])
            for key, value in table.scan(row_prefix=row_prefix.encode()):
                _, _, timestamp = key.decode().split('~')
                value = decode_hbase_values(value=value)
                ts_data.append({'date': datetime.fromtimestamp(int(timestamp)), 'value': float(value['v:value'])})
    print(ts_data)


if __name__ == '__main__':
    load_dotenv()

    # Arguments
    ap = argparse.ArgumentParser(description='Plot HBASE Data')
    ap.add_argument("--sensors", "-s", type=str, required=True)

    args = ap.parse_args()

    # NEO4J
    driver = GraphDatabase.driver(os.getenv('NEO4J_URI'),
                                  auth=(os.getenv('NEO4J_USERNAME'), os.getenv('NEO4J_PASSWORD')))

    for i in args.sensors.split(','):
        raw_df = get_hbase_raw_data(i)

        harmonized_df = get_hbase_harmonized(i)
