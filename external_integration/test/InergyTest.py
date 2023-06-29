import unittest
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

from dotenv import load_dotenv

from external_integration.Inergy.sources.InergySource import InergySource


class SourceTesting(unittest.TestCase):
    token = ""
    base_uri = ""

    def setUp(self):
        load_dotenv()

    def test_1_get_credentials(self):
        InergySource.authenticate()
        self.assertIsNotNone(InergySource.token)
        self.__class__.token = InergySource.token


    def test_2_generate_element(self):
        InergySource.insert_elements(self.token)
    def test_3_get_dev_credentials(self):

        config = utils.utils.read_config(settings.conf_file)
        InergySource.authenticate(**config['inergy_dev'])
        self.assertIsNotNone(InergySource.token)
        self.__class__.token = InergySource.token
        self.__class__.base_uri = config['inergy_dev']['base_uri']

    def test_4_get_element(self):
        self.__class__.token = InergySource.token
        self.__class__.base_uri = config['inergy_dev']['base_uri']
        InergySource.get_elements(self)

    def test_5_generate_action(self):
        config = utils.utils.read_config(settings.conf_file)
        # Neo4J
        try:
            driver = GraphDatabase.driver(**config['neo4j'])
            logger.info("[NEO4J]: OK")
        except Exception as ex:
            exit(-1)
        with driver.session() as session:
            actions = get_actions(session, namespace='https://czech.cz#', id_project=856, mandatory_year=2021).data()
        if actions:
            # print(actions)
            fn_insert_actions(id_project=856, data=actions)


if __name__ == '__main__':
    unittest.main()
    config = utils.utils.read_config(settings.conf_file)