# OPC UA Adapter in InterSystems Ensemble

This repository is an example of how can you use OPC UA Java Library to enable OPC UA in InterSystems Ensemble.

## Requirements

- InterSystems Ensemble Installation (named as *ensemble-2018.1.4.505.1-lnxrhx64.tar.gz*)
- InterSystems Ensemble License Key (named as *cache.key*)
- Docker

## Installation

Place installation file (*ensemble-2018.1.4.505.1-lnxrhx64.tar.gz*) and InterSystems Ensemble License Key (*cache.key*) into root folder of this repository.
Once these two files are in their position, run the following code (take care docker is on):

    ./gradlew build
    docker-compose up -d

- `gradlew build` will create an appropriate jar file.
- `docker-compose up -d` will create a docker image as an example.

## Code Structure

- ensemble/ - *all ObjectScript codes*
- ensemble/Common.cls - *Abstract Class that takes care of connecting to OPC UA Server via OPC UA library*
- ensemble/InboundAdapter.cls - *InboundAdapter for OPC UA*
- ensemble/Installer.cls - *Installer file which installs and configures everything required for this OPC UA example to run*
- ensemble/OPCUABS.cls - *Example Business Service which uses above mentioned InboundAdapter*

- src/ - *all java files*
- src/main - *all code files*
- src/test - *all test files*
- src/main/OPCUA.java - *main java file with optimized interface for InterSystems Ensemble*
