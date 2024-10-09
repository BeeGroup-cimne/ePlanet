import pandas as pd

from external_integration.constants import PROJECTS

def convert(tz):
    if not tz.tz:
        tz = tz.tz_localize("UTC")
    if "UTC" != tz.tz.tzname(tz):
        tz = tz.tz_convert("UTC")
    return tz

def get_actions(session, id_project, namespace, mandatory_year):
    mandatory_year_end = pd.to_datetime(f"{mandatory_year}-01-01")
    mandatory_year_start = pd.to_datetime(f"{mandatory_year}-12-31")
    query = f"""MATCH (o:bigg__Organization)-[:bigg__hasSubOrganization]->(bo:bigg__Organization)-[:bigg__managesBuilding]->(b:bigg__Building)
    -[:bigg__hasProject]->(p)-[:bigg__includesMeasure]->(eem)-[:bigg__hasEnergyEfficiencyMeasureType]->(eemt) Match(p:bigg__RetrofitProject)
    -[:bigg__hasProjectInvestmentCurrency]->(cu:bigg__EnergyEfficiencyMeasureInvestmentCurrency) WHERE eem.uri contains '{namespace}' and 
    o.uri ='{PROJECTS[id_project]}' with b, p.bigg__projectInvestment AS investment, p.bigg__projectCurrencyExchangeRate AS ratio, 
    p.bigg__projectOperationalDate AS operationalDate, COLLECT(eemt.rdfs__comment[0]) AS eemNames""" + """ RETURN 
    {code:b.bigg__buildingIDFromOrganization, investment:investment, operationalDate:operationalDate, eemNames: eemNames, ratio: ratio} AS result"""

    return session.run(query)


def get_buildings(session, id_project, namespace, mandatory_year):
    query = ""
    if namespace == "https://czech.cz#":
        mandatory_year_end = pd.to_datetime(f"2019-01-01")

        query = f"""MATCH (o:bigg__Organization)-[:bigg__hasSubOrganization]->(bo:bigg__Organization)-[
                :bigg__managesBuilding]->(b:bigg__Building) 
                MATCH (c)<-[:bigg__hasAddressCity]-(lo:bigg__LocationInfo)<-[:bigg__hasLocationInfo]-(b)
                MATCH(b)-[:bigg__hasSpace]->(bs:bigg__BuildingSpace)-[
                :bigg__isObservedByDevice]->(d)-[:bigg__hasSensor]->(s:bigg__Sensor) 
                WHERE s.uri contains '{namespace}' and 
                o.uri ='{PROJECTS[id_project]}'
                            and s.bigg__timeSeriesEnd > datetime("{convert(mandatory_year_end).to_pydatetime().isoformat()}")
                                RETURN DISTINCT b, lo, c
                            """
    else:
        mandatory_year_end = pd.to_datetime(f"{mandatory_year}-01-01")
        mandatory_year_start = pd.to_datetime(f"{mandatory_year}-12-31")
        query = f"""MATCH (o:bigg__Organization)-[:bigg__hasSubOrganization]->(bo:bigg__Organization)-[
        :bigg__managesBuilding]->(b:bigg__Building) 
        MATCH (c)<-[:bigg__hasAddressCity]-(lo:bigg__LocationInfo)<-[:bigg__hasLocationInfo]-(b)
        MATCH(b)-[:bigg__hasSpace]->(bs:bigg__BuildingSpace)-[
        :bigg__isObservedByDevice]->(d)-[:bigg__hasSensor]->(s:bigg__Sensor) 
        WHERE s.uri contains '{namespace}' and 
        o.uri ='{PROJECTS[id_project]}'
                    and s.bigg__timeSeriesEnd > datetime("{convert(mandatory_year_end).to_pydatetime().isoformat()}")
                    and s.bigg__timeSeriesStart < datetime("{convert(mandatory_year_start).to_pydatetime().isoformat()}")
                        RETURN DISTINCT b, lo, c
                    """
    # mandatory_year +1 - 1 day
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
    query = ""
    if namespace == "https://czech.cz#":
        mandatory_year_end = pd.to_datetime(f"2019-01-01")

        query = f"""MATCH (o:bigg__Organization)-[:bigg__hasSubOrganization]->(bo:bigg__Organization)-[
                    :bigg__managesBuilding]->(b:bigg__Building)-[:bigg__hasSpace]->(bs:bigg__BuildingSpace)-[
                    :bigg__isObservedByDevice]->(d)-[:bigg__hasSensor]->(s:bigg__Sensor)-
                    [:bigg__hasMeasuredProperty]->(m)
                    WHERE s.uri contains '{namespace}' and o.uri ='{PROJECTS[id_project]}' 
                    
                    RETURN s,m.uri
                                """
        #and s.bigg__timeSeriesEnd > datetime("{convert(mandatory_year_end).to_pydatetime().isoformat()}")
    else:
        mandatory_year_end = pd.to_datetime(f"{mandatory_year}-01-01")
        mandatory_year_start = pd.to_datetime(f"{mandatory_year}-12-31")
        query = f"""MATCH (o:bigg__Organization)-[:bigg__hasSubOrganization]->(bo:bigg__Organization)-[
                    :bigg__managesBuilding]->(b:bigg__Building)-[:bigg__hasSpace]->(bs:bigg__BuildingSpace)-[
                    :bigg__isObservedByDevice]->(d)-[:bigg__hasSensor]->(s:bigg__Sensor)-
                    [:bigg__hasMeasuredProperty]->(m)
                    WHERE s.uri contains '{namespace}' and o.uri ='{PROJECTS[id_project]}' 
                    and s.bigg__timeSeriesEnd > datetime("{convert(mandatory_year_end).to_pydatetime().isoformat()}")
                    and s.bigg__timeSeriesStart < datetime("{convert(mandatory_year_start).to_pydatetime().isoformat()}")
                    RETURN s,m.uri
                        """
    return session.run(query)


def get_sensors_measurements(session, id_project, namespace, mandatory_year):
    query = ""

    if namespace == "https://czech.cz#":
        query = f"""MATCH (o:bigg__Organization)-[:bigg__hasSubOrganization]->(bo:bigg__Organization)-[
                :bigg__managesBuilding]->(b:bigg__Building)-[:bigg__hasSpace]->(bs:bigg__BuildingSpace)-[
                :bigg__isObservedByDevice]->(d)-[:bigg__hasSensor]->(s:bigg__Sensor)-
                [:bigg__hasMeasurement]->(mes)
                MATCH (s)-[:bigg__hasMeasuredProperty]->(m)
                WHERE s.uri contains '{namespace}' and o.uri ='{PROJECTS[id_project]}'
                RETURN s, mes.uri, m.uri
                                    """

    else:
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
