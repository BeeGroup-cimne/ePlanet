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

## 1. Czech Organization
 - namespace: `https://czech.cz#`
 - username: `czech`
<details>
    <summary>Load czech data</summary>

### 1.1. Set up organization and data sources

```bash
echo "main org"
python3 -m set_up.Organizations -f data/Organizations/czech-organizations.xls -name "Czech" -u "czech" -n "https://czech.cz#"
echo "summary source"
python3 -m set_up.DataSources -u "czech" -n "https://czech.cz#" -f data/DataSources/czech.xls -d FileSource
```

### 5.2. Harmonize the static data
Load from HBASE (recomended when re-harmonizing)
```bash
python3 -m harmonizer -so Czech -u "czech" -n "https://czech.cz#" -c
```
<details>
    <summary>Load from KAFKA (online harmonization)</summary>

1. start the harmonizer and store daemons:
```bash
python3 -m harmonizer
python3 -m store
```
2. Launch the gather utilities

```bash
python3 -m gather -so Czech -f "data/czech/building" -u "czech" -n "https://czech.cz#" -st kafka -kf building_data 
python3 -m gather -so Czech -f "data/czech/building" -u "czech" -n "https://czech.cz#" -st kafka -kf building_eem 
python3 -m gather -so Czech -f "data/czech/ts" -u "czech" -n "https://czech.cz#" -st kafka -kf ts 
```
</details>


### 5.3. Upload to inergy

```bash
python3 -m external_integration.Inergy -id_project=907 -n "https://czech.cz#" -u czech -my 2021 -y 2021
```
</details>

## 1. Greece Organization
 - namespace: `https://greece.gr#`
 - username: `greece`
<details>
    <summary>Load greece data</summary>

### 1.1. Set up organization and data sources

```bash
echo "main org"
python3 -m set_up.Organizations -f data/Organizations/greece-organizations.xls -name "Greece" -u "greece" -n "https://greece.gr#"
echo "summary source"
python3 -m set_up.DataSources -u "greece" -n "https://greece.gr#" -f data/DataSources/greece.xls -d FileSource
```

### 5.2. Harmonize the static data
Load from HBASE (recomended when re-harmonizing)
```bash
python3 -m harmonizer -so Greece -u "greece" -n "https://greece.gr#" -c
```
<details>
    <summary>Load from KAFKA (online harmonization)</summary>

1. start the harmonizer and store daemons:
```bash
python3 -m harmonizer
python3 -m store
```
2. Launch the gather utilities

```bash
python3 -m gather -so Greece -f "data/greece" -u "greece" -n "https://greece.gr#" -st kafka
```
</details>

### 5.3. Upload to inergy

```bash
python3 -m external_integration.Inergy --data supplies -id_project=886 -n "https://greece.gr#" -u greece -my 2021 -y 2021
```

</details>
