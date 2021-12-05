#!/bin/bash

PHP_VERSIONS="5.6 7.0 7.1 7.2 7.3 7.4 8.0 8.1"

for PHP_VERSION in $PHP_VERSIONS;
do
    echo "Building php$PHP_VERSION config"

    DIR_NAME="php$PHP_VERSION"
    mkdir -p "$DIR_NAME"

    cp entrypoint.sh "$DIR_NAME/entrypoint.sh"
    chmod +x "$DIR_NAME/entrypoint.sh"

    cp apache2-foreground.sh "$DIR_NAME/apache2-foreground.sh"
    chmod +x "$DIR_NAME/apache2-foreground.sh"

    cp sudoers "$DIR_NAME/sudoers"
    cp vhost.conf "$DIR_NAME/vhost.conf"
    cp remoteip.conf "$DIR_NAME/remoteip.conf"
    cp trusted-proxies.lst "$DIR_NAME/trusted-proxies.lst"

    PHP_PACKAGES=$(cat "packages-php$PHP_VERSION.txt" | xargs)

    sed "s/\#\#php-packages\#\#/$PHP_PACKAGES/" Dockerfile.template | sed "s/\#\#php-version\#\#/$PHP_VERSION/g" > "$DIR_NAME/Dockerfile"
done
