import os
from distutils.util import strtobool

from dotenv import load_dotenv

load_dotenv()

SENSOR_TYPE_TAXONOMY = {"EnergyConsumptionGas": "GAS", "EnergyConsumptionWaterHeating": "WATER",
                        "EnergyConsumptionGridElectricity": "ELECTRICITY"}  # TODO: Add EnergyConsumptionDistrictHeating

INVERTED_SENSOR_TYPE_TAXONOMY = {v: k for k, v in SENSOR_TYPE_TAXONOMY.items()}

PROJECTS = {
    # greece
    '852': "Chania", '882': 'Heraklion', '866': 'Chersonisos', '886': 'Viannos', '853': 'Rethymno',
    # zlin
    '856': 'Karolinka', '857': 'Dolní Bečva', '873': 'Bánov', '876': 'Hluk', '877': 'Pozlovice',
    '878': 'Bohuslavice u Zlína', '891': 'Petruvka', '906': 'Horní Becva', '907': 'Liptál', '908': 'Zubrí',
    '909': 'Policná', '910': 'Horní Lhota', '911': 'Podolí', '912': 'Topolná', '913': 'Šarovy',
    '914': 'Racková', '915': 'Slavkov', '916': 'Bohuslavice nad Vlárí', '917': 'Nedakonice',
    '918': 'Valašská Bystrice', '919': 'Drínov', '920': 'Hrobice', '921': 'Hrivínuv Újezd',
    '922': 'Nový Hrozenkov', '923': 'Rožnov pod Radhoštem', '924': 'Spytihnev', '925': 'Žlutava',
    '926': 'Uherské Hradište', '927': 'Holešov', '928': 'Horní Nemcí', '929': 'Luhacovice',
    '930': 'Korytná', '931': 'Kostelec u Holešova', '932': 'Nedašov', '933': 'Štítná nad Vlárí-Popov',
    '934': 'Velký Orechov', '935': 'Vlcnov', '936': 'Zlín', '937': 'Strání - Kvetná',
    '938': 'Pitín', '939': 'Brusné', '940': 'Huslenky', '941': 'Jarcová', '942': 'Hradcovice',
    '943': 'Veletiny', '944': 'Kašava', '945': 'Nivnice', '946': 'Lacnov', '947': 'Podhradní Lhota',
    '948': 'Suchá Loz', '949': 'Brestek', '950': 'Slavkov pod Hostýnem', '951': 'Hostetín',
    '952': 'Prostrední Becva', '953': 'Slopné', '954': 'Barice - Velké Tešany', '955': 'Vigantice',
    '956': 'Otrokovice', '957': 'Bystrice pod Hostýnem', '958': 'Bojkovice', '959': 'Brumov-Bylnice',
    '960': 'Valašské Klobouky', '961': 'Boršice', '962': 'Buchlovice', '963': 'Fryšták', '964': 'Chvalcov',
    '965': 'Uherské Hradište - Jarošov', '966': 'Kromeríž', '967': 'Kunovice', '968': 'Kvasice',
    '969': 'Loucka', '970': 'Lukov', '971': 'Medlovice', '972': 'Morkovice - Slížany', '973': 'Napajedla',
    '974': 'Návojná', '975': 'Pržno', '976': 'Slavicín', '977': 'Staré Mesto', '978': 'Uherský Brod',
    '979': 'Uherský Ostroh', '980': 'Valašské Mezirící', '981': 'Velehrad', '982': 'Vsetín', '983': 'Zašová',
    '984': 'Zborovice', '985': 'Nezdenice', '986': 'Kelc', '987': 'Vidce', '988': 'Vizovice', '989': 'Rymice',
    '990': 'Lešná',
    }

TZ_INFO = 'Europe/Madrid'

DEBUG = bool(strtobool(os.getenv("DEBUG", "False")))
