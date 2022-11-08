from dataclasses import dataclass
from enum import Enum
from typing import Optional

from external_integration.constants import SENSOR_TYPE_TAXONOMY


def get_sensor_id(sensor_uri):
    split_uri = sensor_uri.split('-')
    if len(split_uri) == 8:
        sensor_id = '-'.join(split_uri[2:5])
        sensor_type = SENSOR_TYPE_TAXONOMY.get(split_uri[5])
        _from = 'CZ'

    else:
        sensor_id = split_uri[2]
        sensor_type = SENSOR_TYPE_TAXONOMY.get(split_uri[3])
        _from = 'GR'

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
        _from, sensor_id, sensor_type = get_sensor_id(sensor['s']['uri'])

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
