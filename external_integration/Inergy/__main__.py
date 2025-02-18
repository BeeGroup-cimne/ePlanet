import argparse
import os

import utils.utils
from dotenv import load_dotenv
from neo4j import GraphDatabase

import settings
from external_integration.Inergy.sources.InergySource import InergySource
from external_integration.constants import DEBUG
from external_integration.logger import logger
from external_integration.utils import gather_data, fn_insert_elements, fn_insert_supplies, fn_insert_hourly_data, \
    fn_insert_actions
from external_integration.utils.neo4j import get_buildings, get_sensors, get_sensors_measurements, get_actions

if __name__ == '__main__':
    # https://apiv20.inergy.online/docs/api.html#218--insertar-elementos
    # Load env. variables
    # Set Arguments in CLI
    ap = argparse.ArgumentParser(description='Insert data to Inergy')
    ap.add_argument("--id_project", "-id_project", type=str, help="Project Id", required=True)
    ap.add_argument("--data", "-d", type=str, help="The data that you want to process",
                    choices=['elements', 'supplies', 'consumption', 'actions', 'all'],
                    required=True)

    # ap.add_argument("--method", "-m", type=str, help="Method that you use to process the data.",
    #                 choices=['update', 'insert'], default='insert')
    ap.add_argument("--namespace", "-n", required=True)

    # ap.add_argument("--skip", "-s", type=int, default=0)
    # ap.add_argument("--limit", "-l", type=int, default=100)
    # ap.add_argument("--stop", "-st", type=int, default=0)

    # ap.add_argument("--token", '-to', default=True, type=bool, action=argparse.BooleanOptionalAction)

    ap.add_argument("--year", '-y', default=None, type=str)
    ap.add_argument("--mandatory_year", '-my', default=2021, type=str)
    ap.add_argument("--user", '-u', required=True, type=str)

    args = ap.parse_args()

    logger.info(f"DEBUG MODE: [{DEBUG}]")
    config = utils.utils.read_config(settings.conf_file)

    ###############################
    # config = utils.utils.read_config(settings.conf_file)
    # args = Namespace(id_project='856', data='actions', namespace='https://czech.cz#', year='2021', mandatory_year='2021', user='czech')

    # args.id_project = 856

    # InergySource.authenticate(**config['inergy_dev'])
    # Get credentials
    # if not DEBUG:
    #     InergySource.authenticate(**config['inergy_dev_auth'])
    #     logger.info(InergySource.base_uri)
    ###############################


    # # Get credentials
    # if not DEBUG:
    #     InergySource.authenticate(**config['inergy_dev'])
    #     logger.info(InergySource.base_uri)

    # # Get credentials
    if not DEBUG:
        InergySource.authenticate(**config['inergy'])
        logger.info(InergySource.base_uri)

    # # Get credentials
    # if not DEBUG:
    #     InergySource.authenticate(**config['inergy-auth-prod'])
    #     logger.info(InergySource.base_uri)

    # Neo4J
    try:
        driver = GraphDatabase.driver(**config['neo4j'])
        logger.info("[NEO4J]: OK")
    except Exception as ex:
        logger.error(ex)
        exit(-1)

    projects = args.id_project.split(',')
    logger.info(f"Projects to be integrate: {projects}")

    InergySource.base_uri = config['inergy_planning-prod']['base_uri']
    # insert actions
    if args.data == "actions" or args.data == "all":
        for i in projects:
            with driver.session() as session:
                actions = get_actions(session, namespace=args.namespace, id_project=i,
                                          mandatory_year=args.mandatory_year).data()
                print(actions)
            if actions:
               fn_insert_actions(args, i, actions)
               logger.info(f"The from {i} has been integrated.")

    # # insert buildings
    if args.data == "elements" or args.data == "all":
        for i in projects:
            with driver.session() as session:
                buildings = get_buildings(session, namespace=args.namespace, id_project=i,
                                          mandatory_year=args.mandatory_year).data()
                # print(buildings)
            if buildings:
               print(buildings)
               fn_insert_elements(args, i, buildings, user=args.user)
               logger.info(f"The from {i} has been integrated.")

    # insert devices
    if args.data == "supplies" or args.data == "all":
        for i in projects:
            with driver.session() as session:
                supplies = get_sensors(session, namespace=args.namespace, id_project=i,
                                       mandatory_year=args.mandatory_year).data()
            if supplies:
                fn_insert_supplies(args, i, supplies)
            logger.info(f"The from {i} has been integrated.")

    # insert consumptions
    if args.data == "consumption" or args.data == "all":
        # insert ts year
        for i in projects:
            with driver.session() as session:
                sensors = get_sensors_measurements(session=session, id_project=i, namespace=args.namespace,
                                                   mandatory_year=args.mandatory_year).data()
            if sensors:
                fn_insert_hourly_data(args, i, sensors, config, args.user)
                logger.info(f"The has been integrated.")
