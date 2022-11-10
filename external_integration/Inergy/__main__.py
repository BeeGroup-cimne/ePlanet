import argparse
import os

from dotenv import load_dotenv
from neo4j import GraphDatabase

from external_integration.Inergy.sources.InergySource import InergySource
from external_integration.constants import DEBUG
from external_integration.logger import logger
from external_integration.utils import gather_data, fn_insert_elements, fn_insert_supplies, fn_insert_hourly_data
from external_integration.utils.neo4j import get_buildings, get_sensors, get_sensors_measurements

if __name__ == '__main__':
    # https://apiv20.inergy.online/docs/api.html#218--insertar-elementos
    # Load env. variables
    load_dotenv()

    # Set Arguments in CLI
    ap = argparse.ArgumentParser(description='Insert data to Inergy')
    ap.add_argument("--id_project", "-id_project", type=str, help="Project Id", required=True)
    ap.add_argument("--type", "-t", type=str, help="The data that you want to insert",
                    choices=['elements', 'supplies', 'hourly_data', 'all'],
                    required=True)

    ap.add_argument("--method", "-m", type=str, help="", choices=['update', 'insert'], default='insert')

    ap.add_argument("--namespace", "-n", required=True)

    ap.add_argument("--skip", "-s", type=int, default=0)
    ap.add_argument("--limit", "-l", type=int, default=100)

    ap.add_argument("--token", '-token', default=True, type=bool, action=argparse.BooleanOptionalAction)

    args = ap.parse_args()

    logger.info(f"DEBUG MODE: [{DEBUG}]")

    # Get credentials
    if not DEBUG:
        InergySource.token = os.getenv('TOKEN') if args.token else InergySource.authenticate()

    # Neo4J
    try:
        driver = GraphDatabase.driver(os.getenv('NEO4J_URI'),
                                      auth=(os.getenv('NEO4J_USERNAME'), os.getenv('NEO4J_PASSWORD')))
        logger.info("[NEO4J]: OK")
    except Exception as ex:
        logger.error(ex)
        exit(-1)

    projects = args.id_project.split(',')
    logger.info(f"Projects to be integrate: {projects}")

    if args.type == 'elements' or args.type == 'all':
        for i in projects:
            logger.info(f"Integrate: {args.type.upper()} - {i}")
            gather_data(driver=driver, fn_data=get_buildings, fn_insert=fn_insert_elements, args=args,
                        id_project=int(i))
            logger.info(f"The {args.type.upper()} from {i} has been integrated.")

    if args.type == 'supplies' or args.type == 'all':
        for i in projects:
            logger.info(f"Integrate: {args.type.upper()} - {i}")
            gather_data(driver=driver, fn_data=get_sensors, fn_insert=fn_insert_supplies, args=args,
                        id_project=int(i))
            logger.info(f"The {args.type.upper()} from {i} has been integrated.")

    if args.type == 'hourly_data' or args.type == 'all':
        for i in projects:
            logger.info(f"Integrate: {args.type.upper()} - {i}")
            gather_data(driver=driver, fn_data=get_sensors_measurements, fn_insert=fn_insert_hourly_data, args=args,
                        id_project=int(i))
            logger.info(f"The {args.type.upper()} from {i} has been integrated.")
