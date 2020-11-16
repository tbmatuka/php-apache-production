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
        libapache2-mod-php8.0 php8.0 php8.0-amqp php8.0-apcu php8.0-bcmath php8.0-bz2 php8.0-cgi php8.0-cli php8.0-common php8.0-curl php8.0-dev php8.0-gd php8.0-gmp php8.0-imagick php8.0-imap php8.0-intl php8.0-ldap php8.0-mailparse php8.0-mbstring php8.0-memcached php8.0-mysql php8.0-odbc php8.0-opcache php8.0-pgsql php8.0-pspell php8.0-readline php8.0-redis php8.0-snmp php8.0-soap php8.0-sqlite3 php8.0-tidy php8.0-uuid php8.0-xml php8.0-xsl php8.0-yaml php8.0-zip php8.0-zmq \
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
RUN update-alternatives --set php "/usr/bin/php8.0"

RUN for phpenv in apache2 cli; do \
        mv "/etc/php/8.0/$phpenv/php.ini" "/etc/php/8.0/$phpenv/php.ini.dist" ; \
        ln -s /etc/php/php.ini "/etc/php/8.0/$phpenv/php.ini"; \
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
