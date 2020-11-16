#!/bin/bash

apacheEnvFilePath='/etc/apache2/conf-enabled/docker_env.conf'

# empty the env file
: | sudo tee  ${apacheEnvFilePath} > /dev/null

if [ ! -z "${APACHE_VARS}" ]
then
    echo "Adding environment variables to apache:"

    for APACHE_VAR_NAME in ${APACHE_VARS}
    do
        echo "Adding ${APACHE_VAR_NAME}"
        echo "SetEnv" "${APACHE_VAR_NAME}" "$(printenv ${APACHE_VAR_NAME})" | sudo tee -a ${apacheEnvFilePath} > /dev/null
    done
fi

if [ ! -z "${SMTP}" ]
then
    sed -ri "s/^mailhub=.+\$/mailhub=${SMTP}/" /etc/ssmtp/ssmtp.conf
fi

args="$@"

if [ -z "${args}" ]
then
    # run user defined initialization script (for example DB migrations)
    if [ -x "/usr/local/bin/apache_init.sh" ]
    then
        /usr/local/bin/apache_init.sh
    fi

    # start apache
    sudo /usr/local/sbin/apache2-foreground.sh

    exit $?
fi

# run specified command
if [[ "$-" =~ i ]]
then
    # interactive
    /bin/bash --login -i -c "${args}"
else
    # non-interactive
    /bin/bash --login -c "${args}"
fi
