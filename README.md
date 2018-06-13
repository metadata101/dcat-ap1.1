# DCAT-AP Schema Plugin for GeoNetwork

The [schemas/dcat-ap](/schemas/dcat-ap) folder contains a [DCAT-AP v1.1](https://joinup.ec.europa.eu/asset/dcat_application_profile/asset_release/dcat-ap-v11) schema plugin for [GeoNetwork](http://geonetwork-opensource.org/). 

The work on this schema plugin was funded by the [OpenTransportNet](http://opentransportnet.eu/) innovation project funding by the European Union’s Competitiveness and Innovation Framework Programme under grant agreement no. 620533. The work was carried out at the request of and in close collaboration with the Flemish Information Agency ([AIV](http://www.vlaanderen.be/nl/contact/adressengids/diensten-van-de-vlaamse-overheid/administratieve-diensten-van-de-vlaamse-overheid/beleidsdomein-kanselarij-en-bestuur/agentschap-informatie-vlaanderen)). 

## Features

* **XML Schema for DCAT-AP**: This plugin makes use of the fact that GeoNetwork is capable of storing metadata in any XML format. The plugin therefore defines its own XML Schema (see the [schema](/schemas/dcat-ap/src/main/plugin/dcat-ap/schema)) folder for DCAT-AP that is used for the internal representation of DCAT-AP fields. To limit the data conversion needed, the XML Schema was designed to fully resemble an XML/RDF syntax of DCAT-AP.
* **Import script**: To import RDF metadata into GeoNetwork, something needs to be done to accomodate the many different formats (JSON-LD, Turtle, RDF/XML, etc.) and structure (nestings, ordering, etc.) that RDF data can take. Therefore, an import [script](/schemas/dcat-ap/src/main/plugin/dcat-ap/import) was written to "normalize" the RDF metadata, such that it fits in the XML Schema for DCAT-AP that was defined for the plugin. This script does the following: it downloads RDF metadata from a remote catalogue (curl), converts that into XML using a SPARQL SELECT query, converts that into DCAT-AP XML (XSL conversion), and imports this into GeoNetwork using the GeoNetwork API (curl).
* **DCAT-AP input form**: A custom form was created following the guidance in the GeoNetwork [form customization guide](http://geonetwork-opensource.org/manuals/trunk/eng/users/customizing-application/editor-ui/creating-custom-editor.html). The form pays a lot of attention to the use of controlled vocabularies - which can be imported as SKOS [classification systems](http://geonetwork-opensource.org/manuals/3.0.5/eng/users/administrator-guide/managing-classification-systems/index.html) using standard GeoNetwork functionality.
* **Export in DCAT-AP RDF format**: The plugin exports DCAT-AP RDF metadata using the GeoNetwork API (/geonetwork/srv/api/0.1/records), which can in turn be harvested by e.g. [CKAN](https://github.com/ckan/ckanext-dcat)


## Usage note 

To include this schema plugin in a build, copy the dcat-ap schema folder in the 
schemas folder, add it to the schemas/pom.xml 
and add it to the copy-schemas execution in web/pom.xml.

Samples and templates can be imported via the 'Admin Console' > 'Metadata and Templates' > 'DCAT-AP' menu.

For further guidance on setting up a development environment/building Geonetwork/compiling user documentation/making a release see:
[Software Development Documentation](https://github.com/geonetwork/core-geonetwork/tree/develop/software_development)


## Future work

This plugin would merit further improvements in the following areas:
* Integration of the import script in a GeoNetwork DCAT harvester.
* Forms: The layout of the DCAT-AP editor needs furhter improvement. A number of components still need to be implemented (spatial coverage) or made more generic.