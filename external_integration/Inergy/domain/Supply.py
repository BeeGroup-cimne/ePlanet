from dataclasses import dataclass
from enum import Enum
from typing import Optional

from external_integration.constants import SENSOR_TYPE_TAXONOMY

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


class SupplyEnum(Enum):
    ELECTRICITY = 0
    GAS = 1
    FUEL = 2
    WATER = 3


@dataclass
class Supply(object):
    instance: int
    id_project: int
    code: str
    cups: str
    id_source: int
    element_code: str
    use: str
    id_zone: int
    begin_date: str  # 2020-01-16
    end_date: str  # 2020-01-16
    description: Optional[str] = None

    @classmethod
    def create(cls, id_project, sensor):
        print(sensor)
        _from, sensor_id, sensor_type = get_sensor_id(sensor['s']['uri'], sensor['m.uri'])

        if not sensor_type:
            return None

        code = f"{_from}-{sensor_type}-{sensor_id}"
        cups = f"{sensor_id}-{sensor_type}" if _from == 'CZ' else sensor_id
        cups = cups[:20]

        return Supply(instance=1, id_project=id_project, code=code, cups=cups,
                      id_source=SupplyEnum[sensor_type].value, element_code=sensor_id,
                      use='Equipment',
                      id_zone=1,
                      begin_date=str(sensor['s']['bigg__timeSeriesStart'].date()),
                      end_date=str(sensor['s']['bigg__timeSeriesEnd'].date()))
