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
    ap.add_argument("--process", "-p", type=str, help="The data that you want to process",
                    choices=['elements', 'supplies', 'hourly_data'],
                    required=True)

    ap.add_argument("--method", "-m", type=str, help="Method that you use to process the data.",
                    choices=['update', 'insert'], default='insert')

    ap.add_argument("--namespace", "-n", required=True)

    ap.add_argument("--skip", "-s", type=int, default=0)
    ap.add_argument("--limit", "-l", type=int, default=100)
    ap.add_argument("--stop", "-st", type=int, default=0)

    ap.add_argument("--token", '-to', default=True, type=bool, action=argparse.BooleanOptionalAction)

    ap.add_argument("--start_date", '-sd', default=None, type=str)

    args = ap.parse_args()

    # if args.process == 'hourly_data' and not args.start_date and not args.end_date:
    #     ap.error('--error')
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

    if args.process == 'elements':
        for i in projects:
            logger.info(f"Integrate: {args.process.upper()} - {i}")
            gather_data(driver=driver, fn_data=get_buildings, fn_insert=fn_insert_elements, args=args,
                        id_project=int(i))
            logger.info(f"The {args.process.upper()} from {i} has been integrated.")

    if args.process == 'supplies':
        for i in projects:
            logger.info(f"Integrate: {args.process.upper()} - {i}")
            gather_data(driver=driver, fn_data=get_sensors, fn_insert=fn_insert_supplies, args=args,
                        id_project=int(i))
            logger.info(f"The {args.process.upper()} from {i} has been integrated.")

    if args.process == 'hourly_data':
        for i in projects:
            logger.info(f"Integrate: {args.process.upper()} - {i}")
            gather_data(driver=driver, fn_data=get_sensors_measurements, fn_insert=fn_insert_hourly_data, args=args,
                        id_project=int(i))
            logger.info(f"The {args.process.upper()} from {i} has been integrated.")
