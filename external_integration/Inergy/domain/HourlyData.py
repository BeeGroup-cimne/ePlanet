from dataclasses import dataclass


@dataclass
class HourlyData(object):
    value: float
    timestamp: str  # 2020-01-16T10:00:00Z
