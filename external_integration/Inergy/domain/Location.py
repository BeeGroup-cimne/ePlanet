from dataclasses import dataclass
from typing import Optional


@dataclass
class Location(object):
    address: Optional[str] = None
    latitude: Optional[float] = None
    longitude: Optional[float] = None

    @classmethod
    def create(cls, location, city):
        address = None
        address_street = location.get('bigg__addressStreetName')
        address_number = location.get('bigg__addressStreetNumber')

        if address_street:
            address = address_street
            if address_street:
                address += f' {address_number}'

        if location.get('bigg__addressLatitude') and location.get('bigg__addressLongitude'):
            latitude = float(location.get('bigg__addressLatitude')[:-1])
            longitude = float(location.get('bigg__addressLongitude')[:-1])
        else:
            latitude = float(city.get('wgs__lat'))
            longitude = float(city.get('wgs__long'))

        return Location(address=address, latitude=latitude, longitude=longitude)
