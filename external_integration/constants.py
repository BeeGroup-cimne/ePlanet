import os
from distutils.util import strtobool

from dotenv import load_dotenv

load_dotenv()

SENSOR_TYPE_TAXONOMY = {"EnergyConsumptionGas": "GAS", "EnergyConsumptionWaterHeating": "WATER",
                        "EnergyConsumptionGridElectricity": "ELECTRICITY"}  # TODO: Add EnergyConsumptionDistrictHeating

INVERTED_SENSOR_TYPE_TAXONOMY = {v: k for k, v in SENSOR_TYPE_TAXONOMY.items()}

PROJECTS = {852: 'Chania', 853: 'Rethymno', 856: 'Karolinka', 857: 'Dolní Bečva'}

TZ_INFO = 'Europe/Madrid'

DEBUG = bool(strtobool(os.getenv("DEBUG", "True")))
