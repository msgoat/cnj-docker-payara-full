FROM openjdk:8-jre-alpine

LABEL maintainer="michael.theis@hm.edu" \
        ${project.groupId}.${project.artifactId}.project="HMFWPCNJ" \
        ${project.groupId}.${project.artifactId}.version="${project.version}" \
        ${project.groupId}.${project.artifactId}.description="${project.description}" \
        ${project.groupId}.${project.artifactId}.payara-version="5.184"

# Environment variables in two blocks to allow proper placeholder resolution
# - block 1 only contains all envvars without placeholders
# - block 2 contains all envvars with placeholders defined in block 1
ENV \
  ADMIN_USER=admin \
  ADMIN_PASSWORD=admin \
  PAYARA_PATH=/opt/payara5 \
  PAYARA_VERSION=5.184 \
  PAYARA_DOMAIN=domain1
ENV \
  PAYARA_PKG_URL=https://s3-eu-west-1.amazonaws.com/payara.fish/Payara+Downloads/${PAYARA_VERSION}/payara-${PAYARA_VERSION}.tar.gz \
  PKG_FILE_NAME=payara-full-${PAYARA_VERSION}.zip \
  DEPLOY_DIR=${PAYARA_PATH}/deployments \
  AUTODEPLOY_DIR=${PAYARA_PATH}/glassfish/domains/${PAYARA_DOMAIN}/autodeploy \
  POSTBOOT_COMMANDS=${PAYARA_PATH}/post-boot-commands.asadmin \
  PAYARA_PASSWORD_FILE=${PAYARA_PATH}/pwdfile

RUN \
  apk update && apk add curl bash \
  && mkdir -p ${PAYARA_PATH}/deployments \
  && echo "adding run user payara to system" \
  && addgroup -S payara && adduser -S payara -G payara \
  && echo "downloading payara tarball from ${PAYARA_PKG_URL}" \
  && curl -k --location --silent --output /opt/${PKG_FILE_NAME} ${PAYARA_PKG_URL} \
  && tar -xzf /opt/${PKG_FILE_NAME} -C /opt \
  && rm /opt/${PKG_FILE_NAME} \
  && ln -s ${PAYARA_PATH} /opt/payara \
  && echo -e "AS_ADMIN_PASSWORD=\nAS_ADMIN_NEWPASSWORD=${ADMIN_PASSWORD}\n\n" > /opt/tmpfile \
  && echo -e "AS_ADMIN_PASSWORD=${ADMIN_PASSWORD}\n\n" > ${PAYARA_PASSWORD_FILE} \
  && echo "securing payara domain ${PAYARA_DOMAIN}" \
  && ${PAYARA_PATH}/bin/asadmin --user ${ADMIN_USER} --passwordfile=/opt/tmpfile change-admin-password \
  && ${PAYARA_PATH}/bin/asadmin start-domain domain1 \
  && ${PAYARA_PATH}/bin/asadmin --user ${ADMIN_USER} --passwordfile=${PAYARA_PASSWORD_FILE} enable-secure-admin \
  && ${PAYARA_PATH}/bin/asadmin stop-domain domain1 \
  && echo "cleanup after initial payara setup" \
  && rm -rf ${PAYARA_PATH}/glassfish/domains/${PAYARA_DOMAIN}/osgi-cache \
  && rm -rf ${PAYARA_PATH}/glassfish/domains/${PAYARA_DOMAIN}/logs \
  && rm /opt/tmpfile \
  && echo "make sure everything in ${PAYARA_PATH} is owned by run user payara" \
  && chown -R payara:payara /opt

COPY generate_deploy_commands.sh ${PAYARA_PATH}/generate_deploy_commands.sh
COPY startInForeground.sh ${PAYARA_PATH}/bin/startInForeground.sh
COPY docker-entrypoint.sh /

RUN \
  chown -R payara:payara ${PAYARA_PATH}/generate_deploy_commands.sh \
  && chmod a+x ${PAYARA_PATH}/generate_deploy_commands.sh \
  && chmod a+x ${PAYARA_PATH}/bin/startInForeground.sh \
  && chmod a+x /docker-entrypoint.sh

USER payara
WORKDIR ${PAYARA_PATH}

# Default payara ports to expose
EXPOSE 4848 8009 8080 8181

ENTRYPOINT ["/docker-entrypoint.sh"]
CMD ["start-appserver"]