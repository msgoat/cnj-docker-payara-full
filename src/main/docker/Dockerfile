FROM ubuntu as tool

ARG ARG_PAYARA_VERSION=6.2023.5
ARG ARG_PAYARA_PKG_URL=https://search.maven.org/remotecontent?filepath=fish/payara/distributions/payara/${ARG_PAYARA_VERSION}/payara-${ARG_PAYARA_VERSION}.zip
ARG ARG_PAYARA_HOME=/opt/payara
ARG POSTGRES_JDBC_DRIVER_VERSION=42.6.0

RUN echo "install missing packages" && \
    apt-get update && \
    apt-get install --yes --no-install-recommends curl unzip && \
    apt-get clean && \
    echo "download payara appserver binaries" && \
    curl -fskL -o /tmp/payara.zip ${ARG_PAYARA_PKG_URL} && \
    echo "unpack payara appserver binaries" && \
    unzip -qq /tmp/payara.zip -d /tmp && \
    echo "download PostgreSQL JDBC driver version ${POSTGRES_JDBC_DRIVER_VERSION}" && \
    curl -fskL -o /tmp/postgresql-${POSTGRES_JDBC_DRIVER_VERSION}.jar https://repo1.maven.org/maven2/org/postgresql/postgresql/${POSTGRES_JDBC_DRIVER_VERSION}/postgresql-${POSTGRES_JDBC_DRIVER_VERSION}.jar && \
    ls -al /tmp

FROM eclipse-temurin:17-jre

ARG ARG_PAYARA_HOME=/opt/payara
ARG ARG_PAYARA_ADMIN_USER=admin
ARG ARG_PAYARA_ADMIN_PASSWORD=admin
ARG ARG_PAYARA_DOMAIN_NAME=domain1
ARG ARG_PAYARA_VERSION=6.2023.2
ARG ARG_PAYARA_PKG_URL=https://search.maven.org/remotecontent?filepath=fish/payara/distributions/payara/${ARG_PAYARA_VERSION}/payara-${ARG_PAYARA_VERSION}.zip
ARG ARG_PAYARA_USER=payara
ARG ARG_PAYARA_UID=1234
ARG ARG_PAYARA_GROUP=payara
ARG ARG_PAYARA_GID=1234
ARG POSTGRES_JDBC_POOL_NAME=cnj-postgres-pool
ARG POSTGRES_JDBC_DATASOURCE_NAME=cnj-postgres-datasource

# Initialize the configurable environment variables
ENV HOME_DIR=$ARG_PAYARA_HOME \
    PAYARA_DIR=$ARG_PAYARA_HOME \
    SCRIPT_DIR=$ARG_PAYARA_HOME/scripts \
    CONFIG_DIR=$ARG_PAYARA_HOME/config \
    DEPLOY_DIR=$ARG_PAYARA_HOME/deployments \
    PASSWORD_FILE=$ARG_PAYARA_HOME/passwordFile \
    PAYARA_VERSION=$ARG_PAYARA_VERSION \
    # Payara Server Domain options
    DOMAIN_NAME=$ARG_PAYARA_DOMAIN_NAME \
    ADMIN_USER=$ARG_PAYARA_ADMIN_USER \
    ADMIN_PASSWORD=$ARG_PAYARA_ADMIN_PASSWORD \
    PAYARA_AS_ADMIN_CMD="${ARG_PAYARA_HOME}/bin/asadmin --user ${ARG_PAYARA_ADMIN_USER} --passwordfile=${PASSWORD_FILE} --echo" \
    # Utility environment variables
    JVM_ARGS= \
    PAYARA_ARGS= \
    DEPLOY_PROPS= \
    POSTBOOT_COMMANDS=$ARG_PAYARA_HOME/config/post-boot-commands.asadmin \
    PREBOOT_COMMANDS=$ARG_PAYARA_HOME/config/pre-boot-commands.asadmin

RUN echo "adding run user payara to system" && \
    addgroup --gid $ARG_PAYARA_GID --system $ARG_PAYARA_GROUP && \
    adduser --system --home $ARG_PAYARA_HOME --shell /bin/bash --disabled-login --disabled-password --ingroup $ARG_PAYARA_GROUP --uid $ARG_PAYARA_UID $ARG_PAYARA_USER

COPY --from=tool /tmp/payara6 $ARG_PAYARA_HOME/

RUN echo "create payara appserver folders" && \
    mkdir -p ${DEPLOY_DIR} && \
    mkdir -p ${CONFIG_DIR} && \
    mkdir -p ${SCRIPT_DIR} && \
    echo "configure the password file for configuring Payara" && \
    echo "AS_ADMIN_PASSWORD=\nAS_ADMIN_NEWPASSWORD=${ADMIN_PASSWORD}\n\n" | tee /tmp/tmpfile && \
    echo "AS_ADMIN_PASSWORD=${ADMIN_PASSWORD}\n\n" | tee ${PASSWORD_FILE} && \
    cat /tmp/tmpfile && \
    echo "configure the payara domain" && \
    cd ${HOME_DIR} && \
    ${PAYARA_DIR}/bin/asadmin --user=${ADMIN_USER} --passwordfile=/tmp/tmpfile change-admin-password --domain_name ${DOMAIN_NAME} && \
    ${PAYARA_DIR}/bin/asadmin --user=${ADMIN_USER} --passwordfile=${PASSWORD_FILE} start-domain ${DOMAIN_NAME} && \
    ${PAYARA_DIR}/bin/asadmin --user=${ADMIN_USER} --passwordfile=${PASSWORD_FILE} enable-secure-admin && \
    for MEMORY_JVM_OPTION in $(${PAYARA_DIR}/bin/asadmin --user=${ADMIN_USER} --passwordfile=${PASSWORD_FILE} list-jvm-options | grep "Xm[sx]"); do\
        ${PAYARA_DIR}/bin/asadmin --user=${ADMIN_USER} --passwordfile=${PASSWORD_FILE} delete-jvm-options $MEMORY_JVM_OPTION;\
    done && \
    echo "Creating connection pool ${POSTGRES_JDBC_POOL_NAME}" && \
    ${PAYARA_DIR}/bin/asadmin --user=${ADMIN_USER} --passwordfile=${PASSWORD_FILE} create-jdbc-connection-pool \
    	--datasourceclassname org.postgresql.ds.PGSimpleDataSource \
        --restype javax.sql.DataSource \
        --property user=\${ENV=POSTGRES_DB_USER}:password=\${ENV=POSTGRES_DB_PASSWORD}:databaseName=\${ENV=POSTGRES_DB_NAME}:serverName=\${ENV=POSTGRES_DB_HOST}:portNumber=\${ENV=POSTGRES_DB_PORT} \
        ${POSTGRES_JDBC_POOL_NAME} && \
    ${PAYARA_DIR}/bin/asadmin --user=${ADMIN_USER} --passwordfile=${PASSWORD_FILE} set resources.jdbc-connection-pool.${POSTGRES_JDBC_POOL_NAME}.connection-creation-retry-attempts=2 && \
    ${PAYARA_DIR}/bin/asadmin --user=${ADMIN_USER} --passwordfile=${PASSWORD_FILE} set resources.jdbc-connection-pool.${POSTGRES_JDBC_POOL_NAME}.connection-creation-retry-interval-in-seconds=10 && \
    ${PAYARA_DIR}/bin/asadmin --user=${ADMIN_USER} --passwordfile=${PASSWORD_FILE} set resources.jdbc-connection-pool.${POSTGRES_JDBC_POOL_NAME}.connection-leak-reclaim=true && \
    ${PAYARA_DIR}/bin/asadmin --user=${ADMIN_USER} --passwordfile=${PASSWORD_FILE} set resources.jdbc-connection-pool.${POSTGRES_JDBC_POOL_NAME}.connection-leak-timeout-in-seconds=120 && \
    ${PAYARA_DIR}/bin/asadmin --user=${ADMIN_USER} --passwordfile=${PASSWORD_FILE} set resources.jdbc-connection-pool.${POSTGRES_JDBC_POOL_NAME}.validation-classname=org.glassfish.api.jdbc.validation.PostgresConnectionValidation && \
    ${PAYARA_DIR}/bin/asadmin --user=${ADMIN_USER} --passwordfile=${PASSWORD_FILE} set resources.jdbc-connection-pool.${POSTGRES_JDBC_POOL_NAME}.connection-validation-method=custom-validation && \
    ${PAYARA_DIR}/bin/asadmin --user=${ADMIN_USER} --passwordfile=${PASSWORD_FILE} set resources.jdbc-connection-pool.${POSTGRES_JDBC_POOL_NAME}.is-connection-validation-required=true && \
    ${PAYARA_DIR}/bin/asadmin --user=${ADMIN_USER} --passwordfile=${PASSWORD_FILE} set resources.jdbc-connection-pool.${POSTGRES_JDBC_POOL_NAME}.is-isolation-level-guaranteed=true && \
    ${PAYARA_DIR}/bin/asadmin --user=${ADMIN_USER} --passwordfile=${PASSWORD_FILE} set resources.jdbc-connection-pool.${POSTGRES_JDBC_POOL_NAME}.max-pool-size=32 && \
    ${PAYARA_DIR}/bin/asadmin --user=${ADMIN_USER} --passwordfile=${PASSWORD_FILE} set resources.jdbc-connection-pool.${POSTGRES_JDBC_POOL_NAME}.max-wait-time-in-millis=30000 && \
    ${PAYARA_DIR}/bin/asadmin --user=${ADMIN_USER} --passwordfile=${PASSWORD_FILE} set resources.jdbc-connection-pool.${POSTGRES_JDBC_POOL_NAME}.pool-resize-quantity=4 && \
    ${PAYARA_DIR}/bin/asadmin --user=${ADMIN_USER} --passwordfile=${PASSWORD_FILE} set resources.jdbc-connection-pool.${POSTGRES_JDBC_POOL_NAME}.pooling=true && \
    ${PAYARA_DIR}/bin/asadmin --user=${ADMIN_USER} --passwordfile=${PASSWORD_FILE} set resources.jdbc-connection-pool.${POSTGRES_JDBC_POOL_NAME}.slow-query-threshold-in-seconds=15 && \
    ${PAYARA_DIR}/bin/asadmin --user=${ADMIN_USER} --passwordfile=${PASSWORD_FILE} set resources.jdbc-connection-pool.${POSTGRES_JDBC_POOL_NAME}.statement-cache-size=50 && \
    ${PAYARA_DIR}/bin/asadmin --user=${ADMIN_USER} --passwordfile=${PASSWORD_FILE} set resources.jdbc-connection-pool.${POSTGRES_JDBC_POOL_NAME}.statement-leak-reclaim=true && \
    ${PAYARA_DIR}/bin/asadmin --user=${ADMIN_USER} --passwordfile=${PASSWORD_FILE} set resources.jdbc-connection-pool.${POSTGRES_JDBC_POOL_NAME}.statement-leak-timeout-in-seconds=120 && \
    ${PAYARA_DIR}/bin/asadmin --user=${ADMIN_USER} --passwordfile=${PASSWORD_FILE} set resources.jdbc-connection-pool.${POSTGRES_JDBC_POOL_NAME}.statement-timeout-in-seconds=30 && \
#    ${PAYARA_AS_ADMIN_CMD} set resources.jdbc-connection-pool.${POSTGRES_JDBC_POOL_NAME}.steady-pool-size=0 && \
    ${PAYARA_DIR}/bin/asadmin --user=${ADMIN_USER} --passwordfile=${PASSWORD_FILE} set resources.jdbc-connection-pool.${POSTGRES_JDBC_POOL_NAME}.transaction-isolation-level=read-committed && \
    ${PAYARA_DIR}/bin/asadmin --user=${ADMIN_USER} --passwordfile=${PASSWORD_FILE} set resources.jdbc-connection-pool.${POSTGRES_JDBC_POOL_NAME}.validate-atmost-once-period-in-seconds=90 && \
    ${PAYARA_DIR}/bin/asadmin --user=${ADMIN_USER} --passwordfile=${PASSWORD_FILE} set resources.jdbc-connection-pool.${POSTGRES_JDBC_POOL_NAME}.wrap-jdbc-objects=true && \
    echo "Creating JDBC datasource ${POSTGRES_JDBC_DATASOURCE_NAME}" && \
    ${PAYARA_DIR}/bin/asadmin --user=${ADMIN_USER} --passwordfile=${PASSWORD_FILE} create-jdbc-resource --connectionpoolid ${POSTGRES_JDBC_POOL_NAME} jdbc/${POSTGRES_JDBC_DATASOURCE_NAME} && \
    echo "Setting up JSON logging" && \
    ${PAYARA_DIR}/bin/asadmin --user=${ADMIN_USER} --passwordfile=${PASSWORD_FILE} set-log-attributes java.util.logging.ConsoleHandler.formatter='fish.payara.enterprise.server.logging.JSONLogFormatter' && \
    echo "Tell all other logging handlers to shut up" && \
    ${PAYARA_DIR}/bin/asadmin --user=${ADMIN_USER} --passwordfile=${PASSWORD_FILE} set-log-attributes com.sun.enterprise.server.logging.GFFileHandler.logStandardStreams='false' && \
    ${PAYARA_DIR}/bin/asadmin --user=${ADMIN_USER} --passwordfile=${PASSWORD_FILE} set-log-attributes com.sun.enterprise.server.logging.GFFileHandler.logtoConsole='false' && \
    ${PAYARA_DIR}/bin/asadmin --user=${ADMIN_USER} --passwordfile=${PASSWORD_FILE} set-log-attributes com.sun.enterprise.server.logging.GFFileHandler.logtoFile='false' && \
#    ${PAYARA_AS_ADMIN_CMD} set-log-attributes com.sun.enterprise.server.logging.GFFileHandler.maxHistoryFiles='0' && \
#    ${PAYARA_AS_ADMIN_CMD} set-log-attributes com.sun.enterprise.server.logging.GFFileHandler.multiLineMode='false' && \
#    ${PAYARA_AS_ADMIN_CMD} set-log-attributes com.sun.enterprise.server.logging.GFFileHandler.rotationLimitInBytes='500000' && \
    ${PAYARA_DIR}/bin/asadmin --user=${ADMIN_USER} --passwordfile=${PASSWORD_FILE} set-log-attributes fish.payara.enterprise.server.logging.PayaraNotificationFileHandler.logtoFile='false' && \
#    ${PAYARA_AS_ADMIN_CMD} set-log-attributes handlerServices='com.sun.enterprise.server.logging.GFFileHandler' && \
    echo "Stopping Payara domain ${DOMAIN_NAME} after configuring application resources" && \
    ${PAYARA_DIR}/bin/asadmin --user=${ADMIN_USER} --passwordfile=${PASSWORD_FILE} stop-domain --kill true ${DOMAIN_NAME} && \
    rm -rf \
        ${PAYARA_DIR}/glassfish/domains/${DOMAIN_NAME}/osgi-cache \
        ${PAYARA_DIR}/glassfish/domains/${DOMAIN_NAME}/logs && \
    chown -R ${ARG_PAYARA_USER}:${ARG_PAYARA_GROUP} ${HOME_DIR}

# Copy PostgreSQL JDBC driver lib
COPY --from=tool --chown=${ARG_PAYARA_USER}:${ARG_PAYARA_GROUP} /tmp/postgresql*.jar ${PAYARA_DIR}/glassfish/domains/${DOMAIN_NAME}/lib/

# Copy docker scripts
COPY --chown=payara:payara *.sh ${SCRIPT_DIR}/
RUN chmod +x ${SCRIPT_DIR}/*.sh

# Required environment variables for PostgreSQL datasource configuration
ENV POSTGRES_DB_USER=""\
    POSTGRES_DB_PASSWORD=""\
    POSTGRES_DB_NAME=""\
    POSTGRES_DB_HOST=""\
    POSTGRES_DB_PORT=""

# Switch current directory to Payara script directory
WORKDIR $SCRIPT_DIR

# Default payara ports to expose
EXPOSE 4848 8009 8080 8181

ENTRYPOINT ["/opt/payara/scripts/docker-entrypoint.sh"]
CMD ["start-domain"]