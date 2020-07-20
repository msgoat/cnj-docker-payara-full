# cnj-docker-payara-full

Builds a Payara Full Profile Server image primarily intended to be extended by the CloudTrain JavaEE showcases.
Comes with a preconfigured PostgreSQL datasource.

## Status
![Build status](https://drone.at41tools.k8s.aws.msgoat.eu/api/badges/cloudtrain/cnj-docker-payara-full/status.svg)

## Release information

Latest version is: `4.2.0`.

A changelog can be found in [changelog.md](changelog.md).

## Docker Pull Command
`docker pull docker.at41tools.k8s.aws.msgoat.eu/cloudtrain/cnj-docker-payara-full`

## Usage 

If you want to run your own application using this base docker image you will have to extend it 
using the following docker build file template:

``` 
FROM docker.at41tools.k8s.aws.msgoat.eu/cloudtrain/docker-payara-full:latest

# copy build artifact into payara deployment folder
COPY *.war ${DEPLOY_DIR}/
```

Provide your application as a WAR in the same folder like your Dockerfile. During a docker build it will be copied 
to the deployment folder of the Payara application server and automatically deployed when the docker container is started.
By default, your application will listen on port 8080 for incoming HTTP traffic.

*NOTE*: HTTPS endpoints are currently not supported due to complexity of TSL certificate integration. Please contact us, if you should need HTTPS support. 

## Configurable Environment

| Environment Variable Name | Type | Description |
| --- | --- | --- |
| POSTGRES_DB_USER | string | __(required)__ PostgreSQL user name | 
| POSTGRES_DB_PASSWORD | string | __(required)__ PostgreSQL user password | 
| POSTGRES_DB_NAME | string | __(required)__ PostgreSQL database name | 
| POSTGRES_DB_HOST | string | __(required)__ Hostname/IP-Adress of the PostgreSQL instance | 
| POSTGRES_DB_PORT | int | __(required)__ Port number of the PostgreSQL instance | 

## Exposed Ports

| Port | Protocol | Description |
| --- | --- | --- |
| 8080 | HTTP | HTTP endpoint of your application | 
| 4848 | HTTP | HTTP endpoint of the Payara admin console |
 
