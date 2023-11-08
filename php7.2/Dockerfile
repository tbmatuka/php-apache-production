FROM ubuntu:22.04

MAINTAINER Tin Benjamin Matuka <mail@tbmatuka.com>

# set up timezone
ENV TIMEZONE="UTC"
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

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
        libapache2-mod-php7.2 php7.2 php7.2-amqp php7.2-apcu php7.2-apcu-bc php7.2-bcmath php7.2-bz2 php7.2-cgi php7.2-cli php7.2-common php7.2-curl php7.2-dev php7.2-gd php7.2-gmp php7.2-imagick php7.2-imap php7.2-intl php7.2-json php7.2-ldap php7.2-mailparse php7.2-mbstring php7.2-memcache php7.2-memcached php7.2-mongodb php7.2-mysql php7.2-odbc php7.2-opcache php7.2-pgsql php7.2-pspell php7.2-readline php7.2-recode php7.2-redis php7.2-snmp php7.2-soap php7.2-sqlite3 php7.2-tideways php7.2-tidy php7.2-uuid php7.2-xml php7.2-xmlrpc php7.2-xsl php7.2-yaml php7.2-zip php7.2-zmq \
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
RUN update-alternatives --set php "/usr/bin/php7.2"

# set up php.ini
RUN cp "/etc/php/7.2/apache2/php.ini" "/etc/php/php.ini" ; \
    mkdir /etc/php/conf.d; ln -s /etc/php/7.2/mods-available/* /etc/php/conf.d/ ; \
    for phpenv in apache2 cli cgi; do \
        mv "/etc/php/7.2/$phpenv/php.ini" "/etc/php/7.2/$phpenv/php.ini.dist" ; \
        mv "/etc/php/7.2/$phpenv/conf.d" "/etc/php/7.2/$phpenv/conf.d.dist" ; \
        ln -s /etc/php/php.ini "/etc/php/7.2/$phpenv/php.ini"; \
        ln -s /etc/php/conf.d/ "/etc/php/7.2/$phpenv/conf.d"; \
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
    mv /etc/php/conf.d/mbstring.ini /etc/php/conf.d/001-mbstring.ini ; \
    mv /etc/php/conf.d/xml.ini /etc/php/conf.d/001-xml.ini


WORKDIR /app/

USER www-data

EXPOSE 80

HEALTHCHECK CMD curl --head http://localhost/ || exit 1

ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]

CMD []
