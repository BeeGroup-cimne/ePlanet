import argparse
import settings

import utils.utils
from dotenv import load_dotenv
from neo4j import GraphDatabase

from external_integration.constants import SENSOR_TYPE_TAXONOMY
from external_integration.Inergy.domain.RequestHourlyData import RequestHourlyData
from external_integration.Inergy.domain.SensorEnum import SensorEnum
from external_integration.constants import DEBUG, INVERTED_SENSOR_TYPE_TAXONOMY, TZ_INFO
from external_integration.logger import logger
from read_municipality_aggregation_by_year.hbase.functions import get_data_hbase

from read_municipality_aggregation_by_year.neo4j.functions import get_sensors_measurements


ns_map = {'https://czech.cz': "CZ", 'https://greece.gr': "GR"}

def get_sensor_id(sensor_uri, measurement_uri):
    split_uri = sensor_uri.split('#')
    if split_uri[0] in ns_map.keys():
        _from = ns_map[split_uri[0]]
        if _from == "CZ":
            sensor_id = "-".join(split_uri[1].split("-")[4:7])
        elif _from == "GR":
            sensor_id = split_uri[1].split("-")[4]

        sensor_type = SENSOR_TYPE_TAXONOMY.get(measurement_uri.split("#")[1])
    else:
        raise Exception("ADD namespace in map list in Supply")
    return _from, sensor_id, sensor_type
def aggregate_supply_consumptions(yearly_list):
    yearly_consumption = 0
    for item in yearly_list:
        yearly_consumption += item['value']
    return yearly_consumption


def fn_insert_hourly_data(args, id_project, data, config, user):
    aggregated_consumtion = 0
    for i in data:
        _from, sensor_id, sensor_type = get_sensor_id(i['s'].get('uri'), i['m.uri'])
        if sensor_type and _from and sensor_id:
            cups = f"{sensor_id}-{sensor_type}" if _from == 'CZ' else sensor_id
            measure_id = i['mes.uri'].split('#')[-1]

            # logger.info(f"Sensor: {sensor_id} || Type: {sensor_type} || Measure: {measure_id}")
            # print(f"Sensor: {sensor_id} || Type: {sensor_type} || Measure: {measure_id}")

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


            # print(req_hour_data.hourly_data)
            if req_hour_data.hourly_data:
                aggregated_consumtion += aggregate_supply_consumptions(req_hour_data.hourly_data)
    logger.info(f"Municipality {id_project} {args.year}: {aggregated_consumtion}")


if __name__ == '__main__':
    # https://apiv20.inergy.online/docs/api.html#218--insertar-elementos
    # Load env. variables
    # Set Arguments in CLI
    ap = argparse.ArgumentParser(description='Insert data to Inergy')
    ap.add_argument("--id_project", "-id_project", type=str, help="Project Id", required=True)
    '''ap.add_argument("--data", "-d", type=str, help="The data that you want to process",
                    choices=['elements', 'supplies', 'consumption', 'all'],
                    required=True)'''

    ap.add_argument("--namespace", "-n", required=True)

    ap.add_argument("--year", '-y', default=None, type=str)
    ap.add_argument("--mandatory_year", '-my', default=2021, type=str)
    ap.add_argument("--user", '-u', required=True, type=str)

    args = ap.parse_args()

    logger.info(f"DEBUG MODE: [{DEBUG}]")
    config = utils.utils.read_config(settings.conf_file)

    # Neo4J
    try:
        driver = GraphDatabase.driver(**config['neo4j'])
        logger.info("[NEO4J]: OK")
    except Exception as ex:
        logger.error(ex)
        exit(-1)

    projects = args.id_project.split(',')
    logger.info(f"Projects to be integrate: {projects}")

    for i in projects:

        with driver.session() as session:
            sensors = get_sensors_measurements(session=session, id_project=i, namespace=args.namespace,
                                               mandatory_year=args.mandatory_year).data()
        if sensors:
            fn_insert_hourly_data(args, i, sensors, config, args.user)
            # logger.info(f"The has been integrated.")
