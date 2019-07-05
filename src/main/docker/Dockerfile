FROM openjdk:8-jre-alpine

LABEL maintainer="michael.theis@msg.group" \
        ${project.groupId}.${project.artifactId}.project="AT.41" \
        ${project.groupId}.${project.artifactId}.version="${project.version}" \
        ${project.groupId}.${project.artifactId}.description="${project.description}" \
        ${project.groupId}.${project.artifactId}.payara-version="5.192"

# Payara version (5.183+)
ARG PAYARA_VERSION=5.192
ARG PAYARA_PKG=https://search.maven.org/remotecontent?filepath=fish/payara/distributions/payara/${PAYARA_VERSION}/payara-${PAYARA_VERSION}.zip
ARG PAYARA_SHA1=710707f9a93b7313fb72ab4b409d5655287480c6
ARG TINI_VERSION=v0.18.0
ARG PAYARA_HOME=/opt/payara

# Initialize the configurable environment variables
ENV HOME_DIR=$PAYARA_HOME\
    PAYARA_DIR=$PAYARA_HOME/appserver\
    # Add for backwards compatibility
    PAYARA_PATH=$PAYARA_HOME/appserver\
    SCRIPT_DIR=$PAYARA_HOME/scripts\
    CONFIG_DIR=$PAYARA_HOME/config\
    DEPLOY_DIR=$PAYARA_HOME/deployments\
    PASSWORD_FILE=$PAYARA_HOME/passwordFile\
    # Added for backwards compatibility
    PAYARA_PASSWORD_FILE=$PAYARA_HOME/passwordFile\
    # Payara Server Domain options
    DOMAIN_NAME=production\
    ADMIN_USER=admin\
    ADMIN_PASSWORD=admin \
    # Utility environment variables
    JVM_ARGS=\
    PAYARA_ARGS=\
    DEPLOY_PROPS=\
    POSTBOOT_COMMANDS=/opt/payara/config/post-boot-commands.asadmin\
    PREBOOT_COMMANDS=/opt/payara/config/pre-boot-commands.asadmin
#ENV PATH="${PATH}:${PAYARA_DIR}/bin"

COPY *.crt /usr/local/share/ca-certificates/

RUN echo "Update packages, install required packages and update trust store" && \
    apk update && \
    apk add curl wget bash gnupg ca-certificates && \
    rm -rf /var/cache/apk/* && \
    update-ca-certificates && \
    echo "Create and set the Payara user and working directory owned by the new user" && \
    addgroup -S payara && \
    adduser -S -G payara -h ${HOME_DIR} payara && \
    echo payara:payara | chpasswd && \
    mkdir -p ${DEPLOY_DIR} && \
    mkdir -p ${CONFIG_DIR} && \
    mkdir -p ${SCRIPT_DIR} && \
    mkdir -p ${HOME_DIR}/.gfclient && \
    chown -R payara:payara ${HOME_DIR}

USER payara
WORKDIR ${HOME_DIR}

RUN echo "Download and unzip the Payara distribution" && \
    wget --no-verbose -O payara.zip ${PAYARA_PKG} && \
    echo "${PAYARA_SHA1} *payara.zip" | sha1sum -c - && \
    unzip -qq payara.zip -d ./ && \
    mv payara*/ appserver && \
    echo "Configure the password file for configuring Payara" && \
    echo -e "AS_ADMIN_PASSWORD=\nAS_ADMIN_NEWPASSWORD=${ADMIN_PASSWORD}\n\n" > /tmp/tmpfile && \
    echo -e "AS_ADMIN_PASSWORD=${ADMIN_PASSWORD}\n\n" >> ${PASSWORD_FILE} && \
    echo "Configure the payara domain" && \
    ${PAYARA_DIR}/bin/asadmin --user=${ADMIN_USER} --passwordfile=/tmp/tmpfile change-admin-password --domain_name=${DOMAIN_NAME} && \
    ${PAYARA_DIR}/bin/asadmin --user=${ADMIN_USER} --passwordfile=${PASSWORD_FILE} start-domain ${DOMAIN_NAME} && \
    ${PAYARA_DIR}/bin/asadmin --user=${ADMIN_USER} --passwordfile=${PASSWORD_FILE} enable-secure-admin && \
    for MEMORY_JVM_OPTION in $(${PAYARA_DIR}/bin/asadmin --user=${ADMIN_USER} --passwordfile=${PASSWORD_FILE} list-jvm-options | grep "Xm[sx]"); do\
        ${PAYARA_DIR}/bin/asadmin --user=${ADMIN_USER} --passwordfile=${PASSWORD_FILE} delete-jvm-options $MEMORY_JVM_OPTION;\
    done && \
    # FIXME: when upgrading this container to Java 10+, this needs to be changed to '-XX:+UseContainerSupport' and '-XX:MaxRAMPercentage'
    ${PAYARA_DIR}/bin/asadmin --user=${ADMIN_USER} --passwordfile=${PASSWORD_FILE} create-jvm-options '-XX\:+UnlockExperimentalVMOptions:-XX\:+UseCGroupMemoryLimitForHeap:-XX\:MaxRAMFraction=1' && \
    # FIXME: waiting on fix to https://github.com/payara/Payara/issues/3506
    #${PAYARA_DIR}/bin/asadmin --user=${ADMIN_USER} --passwordfile=${PASSWORD_FILE} set-log-attributes com.sun.enterprise.server.logging.GFFileHandler.logtoFile=false && \
    ${PAYARA_DIR}/bin/asadmin --user=${ADMIN_USER} --passwordfile=${PASSWORD_FILE} stop-domain ${DOMAIN_NAME} && \
    # Cleanup unused files
    rm -rf \
        /tmp/tmpFile \
        payara.zip \
        ${PAYARA_DIR}/glassfish/domains/${DOMAIN_NAME}/osgi-cache \
        ${PAYARA_DIR}/glassfish/domains/${DOMAIN_NAME}/logs \
        ${PAYARA_DIR}/glassfish/domains/domain1

# Copy across docker scripts
COPY --chown=payara:payara *.sh ${SCRIPT_DIR}/
RUN mkdir -p ${SCRIPT_DIR}/init.d && \
    chmod +x ${SCRIPT_DIR}/*

# Default payara ports to expose
# 4848: admin console
# 9009: debug port (JPDA)
# 8080: http
# 8181: https
EXPOSE 4848 9009 8080 8181

ENTRYPOINT ["scripts/docker-entrypoint.sh"]
CMD ["start-domain"]