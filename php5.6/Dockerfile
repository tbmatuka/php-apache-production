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
        imagemagick \
        libapache2-mod-php5.6 php5.6 php5.6-amqp php5.6-apcu php5.6-bcmath php5.6-bz2 php5.6-cgi php5.6-cli php5.6-common php5.6-curl php5.6-dev php5.6-gd php5.6-gmp php5.6-imagick php5.6-imap php5.6-intl php5.6-json php5.6-ldap php5.6-mailparse php5.6-mbstring php5.6-mcrypt php5.6-memcache php5.6-memcached php5.6-mysql php5.6-odbc php5.6-opcache php5.6-pgsql php5.6-pspell php5.6-readline php5.6-recode php5.6-redis php5.6-snmp php5.6-soap php5.6-sqlite3 php5.6-tidy php5.6-xml php5.6-xmlrpc php5.6-xsl php5.6-yaml php5.6-zip php5.6-zmq \
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
RUN update-alternatives --set php "/usr/bin/php5.6"

# set up php.ini
RUN cp "/etc/php/5.6/apache2/php.ini" "/etc/php/php.ini" ; \
    mkdir /etc/php/conf.d; ln -s /etc/php/5.6/mods-available/* /etc/php/conf.d/ ; \
    for phpenv in apache2 cli cgi; do \
        mv "/etc/php/5.6/$phpenv/php.ini" "/etc/php/5.6/$phpenv/php.ini.dist" ; \
        mv "/etc/php/5.6/$phpenv/conf.d" "/etc/php/5.6/$phpenv/conf.d.dist" ; \
        ln -s /etc/php/php.ini "/etc/php/5.6/$phpenv/php.ini"; \
        ln -s /etc/php/conf.d/ "/etc/php/5.6/$phpenv/conf.d"; \
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

ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]

CMD []
