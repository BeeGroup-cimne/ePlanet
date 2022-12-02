import argparse
import re

import utils
from utils.cache import Cache

from utils.nomenclature import RawMode


def harmonize_command_line(arguments, config=None, settings=None):
    ap = argparse.ArgumentParser(description='Mapping of ePlanet summary data to neo4j.')
    ap.add_argument("--user", "-u", help="The user importing the data", required=True)
    ap.add_argument("--namespace", "-n", help="The subjects namespace uri", required=True)
    args = ap.parse_args(arguments)

    hbase_conn = config['hbase_store_raw_data']
    hbase_table = utils.nomenclature.raw_nomenclature(args.source, RawMode.STATIC, data_type="BuildingInfo",
                                                      user=args.user)
    Cache.load_cache()
    for data in utils.hbase.get_hbase_data_batch(hbase_conn, hbase_table, batch_size=100):
        dic_list = []
        for key, value in data:
            item = dict()
            for k, v in value.items():
                k1 = re.sub("^info:", "", k.decode())
                item[k1] = v

            year, month, unique_id = key.decode().split("~")
            item.update({"Unique ID": unique_id})
            item.update({"Month": month})
            item.update({"Year": year})
            dic_list.append(item)
