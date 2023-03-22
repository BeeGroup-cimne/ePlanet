import pandas as pd

from external_integration.constants import PROJECTS


def convert(tz):
    if not tz.tz:
        tz = tz.tz_localize("UTC")
    if "UTC" != tz.tz.tzname(tz):
        tz = tz.tz_convert("UTC")
    return tz


def get_buildings(session, id_project, namespace, mandatory_year):
    mandatory_year = pd.to_datetime(f"{mandatory_year}-01-01")
    query = f"""MATCH (c)<-[:bigg__hasAddressCity]-(l:bigg__LocationInfo)<-[:bigg__hasLocationInfo]-(b:bigg__Building)
    -[:bigg__hasSpace]->(bs:bigg__BuildingSpace)-[:bigg__isObservedByDevice]->(d)-[:bigg__hasSensor]->(s:bigg__Sensor)
                WHERE s.uri contains '{namespace}' and c.geo__name='{PROJECTS[id_project]}' 
                and s.bigg__timeSeriesEnd > datetime("{convert(mandatory_year).to_pydatetime().isoformat()}")
                and s.bigg__timeSeriesStart < datetime("{convert(mandatory_year).to_pydatetime().isoformat()}")
                    RETURN b, l, c
                """
    return session.run(query)


def get_point_of_delivery(session, namespace, skip, limit):
    query = f"""MATCH (n:bigg__UtilityPointOfDelivery)-[r:bigg__hasUtilityType]-(u)
                WHERE n.uri contains "{namespace}"
                RETURN n.uri ,u.rdfs__label
                SKIP {skip}
                LIMIT {limit}
                """
    return session.run(query)


def get_sensors(session, id_project, namespace, mandatory_year):
    mandatory_year = pd.to_datetime(f"{mandatory_year}-01-01")
    query = f"""MATCH (c)<-[:bigg__hasAddressCity]-(l:bigg__LocationInfo)<-[:bigg__hasLocationInfo]-(b:bigg__Building)
        -[:bigg__hasSpace]->(bs:bigg__BuildingSpace)-[:bigg__isObservedByDevice]->(d)-[:bigg__hasSensor]->(s:bigg__Sensor)-
        [:bigg__hasMeasuredProperty]->(m)
        WHERE s.uri contains '{namespace}' and c.geo__name='{PROJECTS[id_project]}' 
        and s.bigg__timeSeriesEnd > datetime("{convert(mandatory_year).to_pydatetime().isoformat()}")
        and s.bigg__timeSeriesStart < datetime("{convert(mandatory_year).to_pydatetime().isoformat()}")
        RETURN s,m.uri
    """
    return session.run(query)


def get_sensors_measurements(session, id_project, namespace, mandatory_year):
    mandatory_year = pd.to_datetime(f"{mandatory_year}-01-01")
    query = f"""MATCH (c)<-[:bigg__hasAddressCity]-(l:bigg__LocationInfo)<-[:bigg__hasLocationInfo]-(b:bigg__Building)
         -[:bigg__hasSpace]->(bs:bigg__BuildingSpace)-[:bigg__isObservedByDevice]->(d)-[:bigg__hasSensor]->(s:bigg__Sensor)-
         [:bigg__hasMeasurement]->(mes)
         MATCH (s)-[:bigg__hasMeasuredProperty]->(m)
         WHERE s.uri contains '{namespace}' and c.geo__name='{PROJECTS[id_project]}' 
         and s.bigg__timeSeriesEnd > datetime("{convert(mandatory_year).to_pydatetime().isoformat()}")
         and s.bigg__timeSeriesStart < datetime("{convert(mandatory_year).to_pydatetime().isoformat()}")
         RETURN s, mes.uri, m.uri
     """

    return session.run(query)

# def get_sensors_measurements(session, id_project, namespace, skip, limit):
#     query = f"""MATCH (lc)-[:bigg__hasAddressCity]-(l:bigg__LocationInfo)-[]-(b:bigg__Building)-[]-(bs:bigg__BuildingSpace)-[:bigg__isObservedByDevice]-(d)-[:bigg__hasSensor]-(s:bigg__Sensor)-[:bigg__hasMeasurement]-(m:bigg__Measurement)
#                 WHERE s.uri contains '{namespace}' and lc.geo__name='{PROJECTS[id_project]}'
#                 RETURN s,m
#                 SKIP {skip}
#                 LIMIT {limit}
#             """
#
#     return session.run(query)
