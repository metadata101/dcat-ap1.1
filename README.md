# DCAT-AP Schema Plugin for GeoNetwork

This repository contains a [DCAT-AP v1.2](https://joinup.ec.europa.eu/release/dcat-ap/12) schema plugin for [GeoNetwork](http://geonetwork-opensource.org/) 3.6+ or greater version.

## Reference documents
* [W3C Data Catalog Vocabulary (DCAT)](https://www.w3.org/TR/vocab-dcat/), Fadi Maali, John Erickson, 2014.
* [DCAT Application profile for data portals in Europe (DCAT-AP) v1.2](https://joinup.ec.europa.eu/release/dcat-ap/12)
* Interoperability between metadata standards: a reference implementation for metadata catalogues, Geraldine Nolf, W3C SDSVoc 2016. [[paper](https://www.w3.org/2016/11/sdsvoc/SDSVoc16_paper_11)] [[slides](https://www.w3.org/2016/11/sdsvoc/SDSVoc16_PPT_v02)]

## Description

This plugin has the following features:

* **XML Schema for DCAT-AP**: GeoNetwork is capable of storing metadata in XML format. The plugin therefore defines its own XML Schema (see the [schema](/src/main/plugin/dcat-ap/schema) folder) for DCAT-AP that is used for the internal representation of DCAT-AP fields. To limit the data conversion needed, the XML Schema was designed to fully resemble an XML/RDF syntax of DCAT-AP.
* **Harvester**: To import RDF metadata into GeoNetwork, something needs to be done to accomodate the many different formats (JSON-LD, Turtle, RDF/XML, etc.) and structure (nestings, ordering, etc.) that RDF data can take. Therefore, an DCAT-AP [harvester](src/main/java/org/fao/geonet/kernel/harvest/harvester/dcatap/Harvester.java) was written to "normalize" the RDF metadata, such that it fits in the XML Schema for DCAT-AP that was defined for the plugin. The harvester works as follows: it downloads RDF metadata from a remote catalogue (curl), converts that into XML using a SPARQL SELECT query, converts that into DCAT-AP XML (XSL conversion), and imports this into GeoNetwork using the GeoNetwork API (curl).
* **indexing**: The plugin maximally populates GeoNetwork's existing index fields for a consistent search experience.
* **editing**:  A custom form was created following the guidance in the GeoNetwork [form customization guide](http://geonetwork-opensource.org/manuals/trunk/eng/users/customizing-application/editor-ui/creating-custom-editor.html). The form uses the controlled vocabularies required by DCAT-AP. These are located in the folder[thesauri](/src/main/plugin/dcat-ap/thesauri) and can be imported in to GeoNetwork as SKOS [classification systems](https://geonetwork-opensource.org/manuals/3.6.x/is/administrator-guide/managing-classification-systems/index.html) using standard GeoNetwork functionality.
* **directory support for licences**: Licences are directory entries. The [subtemplates](/src/main/plugin/dcat-ap/subtemplates/) folder contains sample licence templates. These licences can be imported via the 'Contribute' > 'Import new records' dialog. Select 'Directory entry' as type of record. Alternatively, templates can be edited via the 'Contribute' > 'Manage directory' form.
* **viewing**: A custom 'full view' to visualise DCAT-AP records. 
* **multilingual metadata support**: The editor, view, and search benefit from the already existing multilingual capabilities of GeoNetwork.
* **validation (XSD and Schematron)**: Validation steps are first XSD validation made on the schema, then the schematron validation defined in folder  [dcat-ap/schematron](/src/main/plugin/dcat-ap/schematron). Two rule sets are available: schematron-rules-dcat-ap, and schematron-rules-dcat-ap-recommendations.
* **Export in DCAT-AP RDF format**: The plugin exports DCAT-AP RDF metadata using the GeoNetwork API (/geonetwork/srv/api/0.1/records), which can in turn be harvested by e.g. [CKAN](https://github.com/ckan/ckanext-dcat). To get the records in DCAT-AP RDF format, use the standard /geonetwork/srv/api/0.1/record endpoint (the DCAT/RDF output to GeoNetwork). Consider cherry picking from this [pull request](https://github.com/geonetwork/core-geonetwork/pull/3553) to enable paging, or apply the patch as explained in the next section.

## Installing the plugin

### GeoNetwork version to use with this plugin

Use GeoNetwork version 3.6+.

### Adding the plugin to the source code

To include this schema plugin in a build, copy the dcat-ap schema folder in the schemas folder, add it to the schemas/pom.xml and add it to the copy-schemas execution in web/pom.xml.

The best approach is to add the plugin as a submodule into GeoNetwork schema module.

```
cd schemas
git submodule add https://github.com/metadata101/dcat-ap1.1.git dcat-ap
git submodule init
git submodule update
```

Add the new module to the schema/pom.xml:

```
  <module>iso19139</module>
  <module>dcat-ap</module>
</modules>
```

Add the dependency in the web module in web/pom.xml:

```
<dependency>
  <groupId>${project.groupId}</groupId>
  <artifactId>schema-dcat-ap</artifactId>
  <version>${gn.schemas.version}</version>
</dependency>
```

Add the module to the webapp in web/pom.xml:

```
<execution>
  <id>copy-schemas</id>
  <phase>process-resources</phase>
  ...
  <resource>
    <directory>${project.basedir}/../schemas/dcat-ap/src/main/plugin</directory>
    <targetPath>${basedir}/src/main/webapp/WEB-INF/data/config/schema_plugins</targetPath>
  </resource>
```

Apply the [patches](/core-geonetwork-patches) to the geonetwork core.
```
git am schemas/dcat-ap/core-geonetwork-patches/*.patch
```

Build and run the application following the
[Software Development Documentation](https://github.com/geonetwork/core-geonetwork/tree/master/software_development).

Samples and templates can be imported via the 'Admin Console' > 'Metadata and Templates' > 'DCAT-AP' menu.


## Metadata rules: metadata identifier

The plugin uses dct:identifier to store a uuid that is used as (internal) metadata identifier. The metadata identifier is stored in the element dcat:Dataset/dct:identifier. When saving a record, this uuid is appended to the dataet URI, provided that the metadata (template) contains a dataset URI that ends with a uuid and the record is not harvested. Admittedly, it would be more correct to use a dcat:CatalogRecord/dct:identifier as metadata identifier, leaving dcat:Dataset/dct:identifier as a pure dataset identifier.


```
 <dcat:Dataset rdf:about="https://opendata.vlaanderen.be/dataset/9fde14b3-4654-44f5-970e-be0a986cf4eb">
	<dct:identifier>9fde14b3-4654-44f5-970e-be0a986cf4eb</dct:identifier>
```


## Community

Comments and questions to the issue tracker.

## More work required

This plugin would merit further improvements in at least the following areas:
* **Harvester to support LDP/Hydra paging**: Now that the GeoNetwork endpoint supports paging, it would bee better to also support it on the harvester.
* **Default view**: the default view currently does not display distribution information, this is only included in the full view.

## Contributors

* Dirk Debaere (Informatie Vlaanderen)
* Mathias De Schrijver (Informatie Vlaanderen)
* Geraldine Nolf (Informatie Vlaanderen) 
* Bart Cosyn (Informatie Vlaanderen)
* Stijn Van Speybroeck (Informatie Vlaanderen)
* Gustaaf Vandeboel (GIM)
* Mathieu Chaussier (GIM)
* Stijn Goedertier (GIM)
* Mathieu Van Wambeke (GIM)
* An Heirman (GIM)

## Acknowledgement

The work on this schema plugin was funded by and carried out in close collaboration with Informatie Vlaanderen ([AIV](https://overheid.vlaanderen.be/informatie-vlaanderen/flanders-information-agency-en)). 
