# Run After Harmonization

In order to avoid errors after harmonization process, run the following commands:

## Neo4J Queries

    match(o:bigg__Organization)-[:bigg__pertainsToOrganization]-(b:bigg__Building),(b)-[]-(l:bigg__LocationInfo),(l)-[r:bigg__hasAddressCity]-(c) where o.bigg__organizationName='Greece' and c.geo__name='Molos-Agios Konstantinos' return l