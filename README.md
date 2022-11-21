# Install Neo4j

Follow the instruction in the [link](https://neo4j.com/docs/operations-manual/current/installation/linux/debian/#debian-installation)

Add in the `plugins` directory located at `/var/lib/neo4j/plugins`:
 - the neosemantics
 - the apoc

if you face the error `NoSuchMethodError` with `apoc.convert.fromJsonList`, follow the instruction in the [link](https://github.com/neo4j-contrib/neo4j-apoc-procedures/issues/2861)

# Set up the database (first time)
- login and change the password.
- run in neo4j:
```cypher 
CREATE CONSTRAINT n10s_unique_uri ON (r:Resource) ASSERT r.uri IS UNIQUE
```
# Set up the database (all the time after reset)
- run in neo4j:
```cypher
CALL n10s.graphconfig.init({ keepLangTag: true, handleMultival:"ARRAY", multivalPropList:["http://www.w3.org/2000/01/rdf-schema#label", "http://www.w3.org/2000/01/rdf-schema#comment", "http://www.geonames.org/ontology#officialName"]});
CALL n10s.nsprefixes.add("bigg","http://bigg-project.eu/ontology#");
CALL n10s.nsprefixes.add("geo","http://www.geonames.org/ontology#");
CALL n10s.nsprefixes.add("unit","http://qudt.org/vocab/unit/");
CALL n10s.nsprefixes.add("wgs","http://www.w3.org/2003/01/geo/wgs84_pos#");
CALL n10s.nsprefixes.add("rdfs","http://www.w3.org/2000/01/rdf-schema#");
```
* add other namespaces if required.

# LOAD DATA FOR BIGG

## 1. Load the taxonomies
Create the dictionaries, when they are already translated
```bash
echo "add translation to previously created dictionaries"
python3 -m set_up.Dictionaries -a load_translate
```

<details>
  <summary>set up the translation files</summary>

```bash
echo "create dictionaries without translation"
python3 -m set_up.Dictionaries -a load
echo "create translation files for the taxonomies"
python3 -m set_up.Dictionaries -a create
echo "add translation to previously created dictionaries"
python3 -m set_up.Dictionaries -a translate
```
</details>