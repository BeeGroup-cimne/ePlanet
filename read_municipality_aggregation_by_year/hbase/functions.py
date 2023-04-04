import settings
import happybase
import pandas as pd
from datetime import datetime
from external_integration.Inergy.domain.HourlyData import HourlyData
from external_integration.constants import DEBUG, INVERTED_SENSOR_TYPE_TAXONOMY, TZ_INFO
from external_integration.logger import logger

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

    logger.info(f"We found {len(ts_data)} records from {measure_id}")

    return clean_ts_data(_from, ts_data) if ts_data else []


def decode_hbase_values(value):
    item = dict()
    for k, v in value.items():
        item.update({k.decode(): v.decode()})
    return item