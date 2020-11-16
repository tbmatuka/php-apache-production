FROM ubuntu:20.04

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
        imagemagick \
        libapache2-mod-php7.3 php7.3 php7.3-amqp php7.3-apcu php7.3-apcu-bc php7.3-bcmath php7.3-bz2 php7.3-cgi php7.3-cli php7.3-common php7.3-curl php7.3-dev php7.3-gd php7.3-gmp php7.3-imagick php7.3-imap php7.3-intl php7.3-json php7.3-ldap php7.3-mailparse php7.3-mbstring php7.3-memcache php7.3-memcached php7.3-mongodb php7.3-mysql php7.3-odbc php7.3-opcache php7.3-pgsql php7.3-pspell php7.3-readline php7.3-recode php7.3-redis php7.3-snmp php7.3-soap php7.3-sqlite3 php7.3-tideways php7.3-tidy php7.3-uuid php7.3-xml php7.3-xmlrpc php7.3-xsl php7.3-yaml php7.3-zip php7.3-zmq \
        php-phalcon \
        php-mail && \
    apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

# copy remoteip.conf so that it can be enabled
COPY ./remoteip.conf /etc/apache2/conf-available/remoteip.conf

# enable missing modules
RUN phpenmod apcu && \
    phpenmod apcu_bc && \
    a2enmod rewrite headers ssl remoteip && \
    a2enconf remoteip

# set php version as active
RUN update-alternatives --set php "/usr/bin/php7.3"

RUN for phpenv in apache2 cli; do \
        mv "/etc/php/7.3/$phpenv/php.ini" "/etc/php/7.3/$phpenv/php.ini.dist" ; \
        ln -s /etc/php/php.ini "/etc/php/7.3/$phpenv/php.ini"; \
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

WORKDIR /app/

USER www-data

EXPOSE 80

ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]

CMD []
