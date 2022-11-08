from dataclasses import dataclass


@dataclass
class RequestHourlyData(object):
    instance: int
    id_project: int
    cups: str
    sensor: str
    hourly_data: list
