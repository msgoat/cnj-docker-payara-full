FROM docker.cloudtrain.aws.msgoat.eu/cloudtrain/at41-docker-payara-full:10.0.0

ARG POSTGRES_JDBC_DRIVER_VERSION=42.3.0
ARG POSTGRES_JDBC_POOL_NAME=cnj-postgres-pool
ARG POSTGRES_JDBC_DATASOURCE_NAME=cnj-postgres-datasource
ARG PAYARA_AS_ADMIN_CMD="${PAYARA_DIR}/bin/asadmin --user ${ADMIN_USER} --passwordfile=${PASSWORD_FILE} --echo"

LABEL maintainer="michael.theis@msg.group" \
        ${project.groupId}.${project.artifactId}.project="CloudTrain" \
        ${project.groupId}.${project.artifactId}.version="${project.version}" \
        ${project.groupId}.${project.artifactId}.description="${project.description}"

RUN echo "Downloading PostgreSQL JDBC driver version ${POSTGRES_JDBC_DRIVER_VERSION}" && \
    mkdir -p ${PAYARA_DIR}/glassfish/domains/${DOMAIN_NAME}/lib && \
    wget --no-verbose -O ${PAYARA_DIR}/glassfish/domains/${DOMAIN_NAME}/lib/postgresql-${POSTGRES_JDBC_DRIVER_VERSION}.jar \
       https://repo1.maven.org/maven2/org/postgresql/postgresql/${POSTGRES_JDBC_DRIVER_VERSION}/postgresql-${POSTGRES_JDBC_DRIVER_VERSION}.jar && \
    echo "Starting Payara domain ${DOMAIN_NAME} to configure application resources" && \
    ${PAYARA_AS_ADMIN_CMD} start-domain ${DOMAIN_NAME} && \
    echo "Creating connection pool ${POSTGRES_JDBC_POOL_NAME}" && \
    ${PAYARA_AS_ADMIN_CMD} create-jdbc-connection-pool \
    	--datasourceclassname org.postgresql.ds.PGSimpleDataSource \
        --restype javax.sql.DataSource \
        --property user=\${ENV=POSTGRES_DB_USER}:password=\${ENV=POSTGRES_DB_PASSWORD}:databaseName=\${ENV=POSTGRES_DB_NAME}:serverName=\${ENV=POSTGRES_DB_HOST}:portNumber=\${ENV=POSTGRES_DB_PORT} \
        ${POSTGRES_JDBC_POOL_NAME} && \
    ${PAYARA_AS_ADMIN_CMD} set resources.jdbc-connection-pool.${POSTGRES_JDBC_POOL_NAME}.connection-creation-retry-attempts=2 && \
    ${PAYARA_AS_ADMIN_CMD} set resources.jdbc-connection-pool.${POSTGRES_JDBC_POOL_NAME}.connection-creation-retry-interval-in-seconds=10 && \
    ${PAYARA_AS_ADMIN_CMD} set resources.jdbc-connection-pool.${POSTGRES_JDBC_POOL_NAME}.connection-leak-reclaim=true && \
    ${PAYARA_AS_ADMIN_CMD} set resources.jdbc-connection-pool.${POSTGRES_JDBC_POOL_NAME}.connection-leak-timeout-in-seconds=120 && \
    ${PAYARA_AS_ADMIN_CMD} set resources.jdbc-connection-pool.${POSTGRES_JDBC_POOL_NAME}.validation-classname=org.glassfish.api.jdbc.validation.PostgresConnectionValidation && \
    ${PAYARA_AS_ADMIN_CMD} set resources.jdbc-connection-pool.${POSTGRES_JDBC_POOL_NAME}.connection-validation-method=custom-validation && \
    ${PAYARA_AS_ADMIN_CMD} set resources.jdbc-connection-pool.${POSTGRES_JDBC_POOL_NAME}.is-connection-validation-required=true && \
    ${PAYARA_AS_ADMIN_CMD} set resources.jdbc-connection-pool.${POSTGRES_JDBC_POOL_NAME}.is-isolation-level-guaranteed=true && \
    ${PAYARA_AS_ADMIN_CMD} set resources.jdbc-connection-pool.${POSTGRES_JDBC_POOL_NAME}.max-pool-size=32 && \
    ${PAYARA_AS_ADMIN_CMD} set resources.jdbc-connection-pool.${POSTGRES_JDBC_POOL_NAME}.max-wait-time-in-millis=30000 && \
    ${PAYARA_AS_ADMIN_CMD} set resources.jdbc-connection-pool.${POSTGRES_JDBC_POOL_NAME}.pool-resize-quantity=4 && \
    ${PAYARA_AS_ADMIN_CMD} set resources.jdbc-connection-pool.${POSTGRES_JDBC_POOL_NAME}.pooling=true && \
    ${PAYARA_AS_ADMIN_CMD} set resources.jdbc-connection-pool.${POSTGRES_JDBC_POOL_NAME}.slow-query-threshold-in-seconds=15 && \
    ${PAYARA_AS_ADMIN_CMD} set resources.jdbc-connection-pool.${POSTGRES_JDBC_POOL_NAME}.statement-cache-size=50 && \
    ${PAYARA_AS_ADMIN_CMD} set resources.jdbc-connection-pool.${POSTGRES_JDBC_POOL_NAME}.statement-leak-reclaim=true && \
    ${PAYARA_AS_ADMIN_CMD} set resources.jdbc-connection-pool.${POSTGRES_JDBC_POOL_NAME}.statement-leak-timeout-in-seconds=120 && \
    ${PAYARA_AS_ADMIN_CMD} set resources.jdbc-connection-pool.${POSTGRES_JDBC_POOL_NAME}.statement-timeout-in-seconds=30 && \
#    ${PAYARA_AS_ADMIN_CMD} set resources.jdbc-connection-pool.${POSTGRES_JDBC_POOL_NAME}.steady-pool-size=0 && \
    ${PAYARA_AS_ADMIN_CMD} set resources.jdbc-connection-pool.${POSTGRES_JDBC_POOL_NAME}.transaction-isolation-level=read-committed && \
    ${PAYARA_AS_ADMIN_CMD} set resources.jdbc-connection-pool.${POSTGRES_JDBC_POOL_NAME}.validate-atmost-once-period-in-seconds=90 && \
    ${PAYARA_AS_ADMIN_CMD} set resources.jdbc-connection-pool.${POSTGRES_JDBC_POOL_NAME}.wrap-jdbc-objects=true && \
    echo "Creating JDBC datasource ${POSTGRES_JDBC_DATASOURCE_NAME}" && \
    ${PAYARA_AS_ADMIN_CMD} create-jdbc-resource --connectionpoolid ${POSTGRES_JDBC_POOL_NAME} jdbc/${POSTGRES_JDBC_DATASOURCE_NAME} && \
    echo "Setting up JSON logging" && \
    ${PAYARA_AS_ADMIN_CMD} set-log-attributes java.util.logging.ConsoleHandler.formatter='fish.payara.enterprise.server.logging.JSONLogFormatter' && \
    echo "Tell all other logging handlers to shut up" && \
    ${PAYARA_AS_ADMIN_CMD} set-log-attributes com.sun.enterprise.server.logging.GFFileHandler.logStandardStreams='false' && \
    ${PAYARA_AS_ADMIN_CMD} set-log-attributes com.sun.enterprise.server.logging.GFFileHandler.logtoConsole='false' && \
    ${PAYARA_AS_ADMIN_CMD} set-log-attributes com.sun.enterprise.server.logging.GFFileHandler.logtoFile='false' && \
#    ${PAYARA_AS_ADMIN_CMD} set-log-attributes com.sun.enterprise.server.logging.GFFileHandler.maxHistoryFiles='0' && \
#    ${PAYARA_AS_ADMIN_CMD} set-log-attributes com.sun.enterprise.server.logging.GFFileHandler.multiLineMode='false' && \
#    ${PAYARA_AS_ADMIN_CMD} set-log-attributes com.sun.enterprise.server.logging.GFFileHandler.rotationLimitInBytes='500000' && \
    ${PAYARA_AS_ADMIN_CMD} set-log-attributes fish.payara.enterprise.server.logging.PayaraNotificationFileHandler.logtoFile='false' && \
#    ${PAYARA_AS_ADMIN_CMD} set-log-attributes handlerServices='com.sun.enterprise.server.logging.GFFileHandler' && \
    echo "Stopping Payara domain ${DOMAIN_NAME} after configuring application resources" && \
    ${PAYARA_AS_ADMIN_CMD} stop-domain --kill true ${DOMAIN_NAME} && \
    rm -rf \
        ${PAYARA_DIR}/glassfish/domains/${DOMAIN_NAME}/osgi-cache \
        ${PAYARA_DIR}/glassfish/domains/${DOMAIN_NAME}/logs

# Required environment variables for PostgreSQL datasource configuration
ENV POSTGRES_DB_USER=""\
    POSTGRES_DB_PASSWORD=""\
    POSTGRES_DB_NAME=""\
    POSTGRES_DB_HOST=""\
    POSTGRES_DB_PORT=""

