# cnj-docker-payara-full

Builds a naked Payara Full Profile Server image primarily intended to be extended for 
application specific configuration.

## Docker Pull Command
`docker pull hmfwpncj/cnj-docker-payara-full`

## Usage 

If you want to run your own application using this base docker image you will have to extend it 
using the following docker build file template:

``` 
FROM docker.at.automotive.msg.team/cloudtrain/docker-payara-full:latest

ENV \
  PAYARA_AS_ADMIN_CMD="${PAYARA_PATH}/bin/asadmin --user ${ADMIN_USER} --passwordfile=${PAYARA_PASSWORD_FILE} --echo"

# Configure the naked payara according to your applications requirements using asadmin commands
RUN \
  && echo "Starting Payara domain ${PAYARA_DOMAIN} to configure application resources" \
  && ${PAYARA_AS_ADMIN_CMD} start-domain ${PAYARA_DOMAIN} \
  && echo "Starting application server configuration..." \
# TODO: add your asadmin commands here using the following pattern
# && ${PAYARA_AS_ADMIN_CMD} <asadmin command> \
  && echo "... finished  application server configuration" \
  && echo "Stopping Payara domain ${PAYARA_DOMAIN} after configuring application resources" \
  && ${PAYARA_AS_ADMIN_CMD} stop-domain ${PAYARA_DOMAIN}

# copy build artifact into payara deployment folder
COPY *.war ${DEPLOY_DIR}/
```

Provide your application as a WAR in the same folder like your Dockerfile. During a docker build it will be copied 
to the deployment folder of the Payara application server and automatically deployed when the docker container is started.
By default, your application will listen on port 8080 for incoming HTTP traffic.

*NOTE*: HTTPS endpoints are currently not supported due to complexity of TSL certificate integration. Please contact us, if you should need HTTPS support. 

## Exposed Ports

| Port | Protocol | Description |
| --- | --- | --- |
| 8080 | HTTP | HTTP endpoint of your application | 
| 4848 | HTTP | HTTP endpoint of the Payara admin console |
 
## Version / Tags

| Tag(s) | Payara version | Remarks |
| --- | --- | --- |
| latest, 2.0.0 | 5.192 | comes with JRE8 on Alpine |
| 1.0.1 | 5.184 | comes with JRE8 on Alpine |
