#!/bin/bash
set -e
# ============================================================================
# docker-entrypoint.sh
# ----------------------------------------------------------------------------
# Starts the Payara Application Server if command "start-appserver" is passed
# as first parameter; otherwise executes given command.
# ============================================================================
if [ "$1" = "start-appserver" ]
then
    ${PAYARA_PATH}/generate_deploy_commands.sh
    ${PAYARA_PATH}/bin/startInForeground.sh --passwordfile=${PAYARA_PASSWORD_FILE} --postbootcommandfile ${POSTBOOT_COMMANDS} ${PAYARA_DOMAIN}
else
    exec "$@"
fi
