from dataclasses import dataclass
from datetime import datetime, date
from typing import Optional

from dateutil.relativedelta import relativedelta

from external_integration.Inergy.domain.Location import Location


@dataclass
class Element(object):
    instance: int
    id_project: int
    code: str
    use: str
    typology: int
    name: str
    begin_date: str  # 2020-01-16
    end_date: str  # 2020-01-16
    location: Optional[dict] = None

    @classmethod
    def create(cls, id_project, i):
        print(i)
        building = i['b']
        location = i['lo']
        city = i['c']

        if all(item in list(building.keys()) for item in
               ['bigg__buildingIDFromOrganization', 'bigg__buildingName']) \
                and all(item in list(location.keys()) for item in
               ['bigg__addressStreetName']):
            building_name = f"{building.get('bigg__buildingName')}-{location.get('bigg__addressStreetName')}"
            building_name = f"{building_name}-{location.get('bigg__addressStreetNumber')}" if location.get('bigg__addressStreetNumber') else building_name
            return Element(id_project=id_project,
                           instance=1,
                           code=str(building.get('bigg__buildingIDFromOrganization')),
                           use='Equipment', typology=9, name=building_name,
                           begin_date=str(date(2019, 1, 1)),
                           end_date=str(date.today() + relativedelta(years=10)),
                           location=Location.create(location, city).__dict__)
