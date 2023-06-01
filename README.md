# cnj-docker-payara-full

Builds a Payara Full Profile Server image primarily intended to be extended by the CloudTrain JavaEE showcases.
Comes with a preconfigured PostgreSQL datasource.

## Status
![Build status](https://codebuild.eu-west-1.amazonaws.com/badges?uuid=eyJlbmNyeXB0ZWREYXRhIjoiMkt4OE1WV1Y2UlJkbmlCWUg3N0FNVG83a1p5aVZnOFJDYTB4em5KcHlxM2hzOExVNVFNU3N2V2FFbi9qenZmOHNiUnNwZFFjUTg1Z2lMZGlWZm01L1EwPSIsIml2UGFyYW1ldGVyU3BlYyI6IjhaMjk4dnZtT0pRd0NHcVciLCJtYXRlcmlhbFNldFNlcmlhbCI6MX0%3D&branch=main)

## Release information

Please check changelog for latest version and release notes.

A changelog can be found in [changelog.md](changelog.md).

## Docker Pull Command
`docker pull docker.cloudtrain.aws.msgoat.eu/cloudtrain/cnj-docker-payara-full`

## Usage 

If you want to run your own application using this base docker image you will have to extend it 
using the following docker build file template:

``` 
FROM docker.cloudtrain.aws.msgoat.eu/cloudtrain/docker-payara-full:latest

# copy build artifact into payara deployment folder
COPY *.war ${DEPLOY_DIR}/
```

Provide your application as a WAR in the same folder as your Dockerfile. During a docker build it will be copied 
to the deployment folder of the Payara application server and automatically deployed when the docker container is started.
By default, your application will listen on port 8080 for incoming HTTP traffic.

*NOTE*: HTTPS endpoints are currently not supported due to complexity of TSL certificate integration. Please contact us, if you should need HTTPS support. 

## Configurable Environment

| Environment Variable Name | Type | Description |
| --- | --- | --- |
| POSTGRES_DB_USER | string | __(required)__ PostgreSQL user name | 
| POSTGRES_DB_PASSWORD | string | __(required)__ PostgreSQL user password | 
| POSTGRES_DB_NAME | string | __(required)__ PostgreSQL database name | 
| POSTGRES_DB_HOST | string | __(required)__ Hostname/IP-Address of the PostgreSQL instance | 
| POSTGRES_DB_PORT | int | __(required)__ Port number of the PostgreSQL instance | 

## Exposed Ports

| Port | Protocol | Description |
| --- | --- | --- |
| 8080 | HTTP | HTTP endpoint of your application | 
| 4848 | HTTP | HTTP endpoint of the Payara admin console |

## TODOs

| TODO | Description | Status |
| --- | --- | --- |
| Optimize docker image size | Consider switching to a multi-mode Docker build to minimize Docker image size | OPEN | 

