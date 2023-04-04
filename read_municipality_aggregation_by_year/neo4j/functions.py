import pandas as pd
from external_integration.constants import PROJECTS

def convert(tz):
    if not tz.tz:
        tz = tz.tz_localize("UTC")
    if "UTC" != tz.tz.tzname(tz):
        tz = tz.tz_convert("UTC")
    return tz
def get_sensors_measurements(session, id_project, namespace, mandatory_year):
    mandatory_year_end = pd.to_datetime(f"{mandatory_year}-01-01")
    mandatory_year_start = pd.to_datetime(f"{mandatory_year}-12-31")
    query = f"""MATCH (o:bigg__Organization)-[:bigg__hasSubOrganization]->(bo:bigg__Organization)-[
    :bigg__managesBuilding]->(b:bigg__Building)-[:bigg__hasSpace]->(bs:bigg__BuildingSpace)-[
    :bigg__isObservedByDevice]->(d)-[:bigg__hasSensor]->(s:bigg__Sensor)-
         [:bigg__hasMeasurement]->(mes)
         MATCH (s)-[:bigg__hasMeasuredProperty]->(m)
         WHERE s.uri contains '{namespace}' and o.uri ='{PROJECTS[id_project]}'
         and s.bigg__timeSeriesEnd > datetime("{convert(mandatory_year_end).to_pydatetime().isoformat()}")
         and s.bigg__timeSeriesStart < datetime("{convert(mandatory_year_start).to_pydatetime().isoformat()}")
         RETURN s, mes.uri, m.uri
     """

    return session.run(query)