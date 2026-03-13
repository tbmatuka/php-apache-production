FROM ubuntu:22.04

MAINTAINER Tin Benjamin Matuka <mail@tbmatuka.com>

# set up timezone
ARG TIMEZONE="UTC"
RUN ln -snf /usr/share/zoneinfo/${TIMEZONE} /etc/localtime && echo ${TIMEZONE} > /etc/timezone

# install deps, apache, php and php modules all in one run and clean up afterwards to reduce the snapshot size
RUN apt-get clean && \
    apt-get -y update && \
    apt-get install -y --force-yes \
        locales \
        curl \
        software-properties-common \
        git \
        apt-transport-https \
        sudo \
        nvi \
        nano \
        iproute2 \
        telnet \
        dnsutils \
        unzip \
        rsync \
        inetutils-ping && \
    locale-gen en_US.UTF-8 && \
    LC_ALL=en_US.UTF-8 add-apt-repository ppa:ondrej/php && apt-get update && \
    DEBIAN_FRONTEND=noninteractive apt-get install -y --force-yes \
        apache2 \
        ssmtp \
        mysql-client \
        imagemagick \
        libapache2-mod-php8.5 php8.5 php8.5-amqp php8.5-apcu php8.5-bcmath php8.5-bz2 php8.5-cgi php8.5-cli php8.5-common php8.5-curl php8.5-dev php8.5-gd php8.5-gmp php8.5-imagick php8.5-imap php8.5-intl php8.5-ldap php8.5-mailparse php8.5-mbstring php8.5-memcached php8.5-mysql php8.5-odbc php8.5-pgsql php8.5-pspell php8.5-readline php8.5-redis php8.5-snmp php8.5-soap php8.5-sqlite3 php8.5-tidy php8.5-uuid php8.5-xml php8.5-xsl php8.5-yaml php8.5-zip php8.5-zmq \
        php-mail && \
    apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

# copy remoteip.conf so that it can be enabled
COPY ./remoteip.conf /etc/apache2/conf-available/remoteip.conf

# enable missing modules
RUN phpenmod apcu && \
    phpenmod apcu_bc && \
    a2enmod rewrite headers ssl remoteip expires && \
    a2enconf remoteip

# set php version as active
RUN update-alternatives --set php "/usr/bin/php8.5"

# set up php.ini
RUN cp "/etc/php/8.5/apache2/php.ini" "/etc/php/php.ini" ; \
    mkdir /etc/php/conf.d; ln -s /etc/php/8.5/mods-available/* /etc/php/conf.d/ ; \
    for phpenv in apache2 cli cgi; do \
        mv "/etc/php/8.5/$phpenv/php.ini" "/etc/php/8.5/$phpenv/php.ini.dist" ; \
        mv "/etc/php/8.5/$phpenv/conf.d" "/etc/php/8.5/$phpenv/conf.d.dist" ; \
        ln -s /etc/php/php.ini "/etc/php/8.5/$phpenv/php.ini"; \
        ln -s /etc/php/conf.d/ "/etc/php/8.5/$phpenv/conf.d"; \
    done

# output apache logs to stdout
RUN ln -sf /proc/self/fd/1 /var/log/apache2/access.log && \
    ln -sf /proc/self/fd/1 /var/log/apache2/error.log

# set up sendmail so that mail() can be used
RUN echo 'FromLineOverride=YES' >> /etc/ssmtp/ssmtp.conf

# add www-data to sudoers
COPY ./sudoers /etc/sudoers.d/www-data

# prepare www-data to be used as main user
RUN usermod -s /bin/bash -G staff www-data && \
    mkdir -p /var/www /app && \
    touch /var/www/.bash_profile && \
    chown -R www-data. /var/www /app

# configure Apache
COPY ./vhost.conf /etc/apache2/sites-available/000-default.conf
COPY ./trusted-proxies.lst /etc/apache2/trusted-proxies.lst

# set up apache command
COPY ./apache2-foreground.sh /usr/local/sbin/apache2-foreground.sh

# prepare entrypoint and default command
COPY ./entrypoint.sh /usr/local/bin/

RUN mv /etc/php/conf.d/mysqlnd.ini /etc/php/conf.d/001-mysqlnd.ini ; \
    mv /etc/php/conf.d/msgpack.ini /etc/php/conf.d/001-msgpack.ini ; \
    mv /etc/php/conf.d/mbstring.ini /etc/php/conf.d/001-mbstring.ini


WORKDIR /app/

USER www-data

EXPOSE 80

HEALTHCHECK CMD curl --head http://localhost/ || exit 1

ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]

CMD []
