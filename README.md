# Docker production image containing Apache and PHP

## Image versions
The main difference between tagged version of the image is the installed PHP version.

## Installed applications

### PHP
The interpreter is run as usual with `php`. Pretty much all common modules are installed and a bunch of less common ones as well.

### Apache
Latest Apache available in the Ubuntu repository is installed and set up to run by default if no command is given when running the container.

### SSMTP
SSMTP is a simple sendmail implementation that sends your messages to the configured SMTP server. You can use an environment variable to configure this dynamically, or hardcode it in your image when you're building it.

## Environment variables

### sendmail
You can set the environment variable SMTP in Docker. Entrypoint script will set that as the SMTP host for SSMTP.

PHP command `mail()` uses sendmail to send mail, so you if you're using it you will need to set this.

### Apache environment variables
Any number of environment variables that you set in Docker can be passed to Apache and PHP. All you have to do is list the variable names in the `APACHE_VARS` environment variable. Use space as a delimiter.

## Configuration

### Apache

#### vhost
The only enabled vhost file is `/etc/apache2/sites-available/000-default.conf` and you can easily override it when building your image if you need to. The default vhost points to the `/app` dir.

#### mod_remoteip
mod_remoteip is configured in `/etc/apache2/conf-available/remoteip.conf`. It is configured to trust the internal Docker network and to load the `trusted-proxies.lst` file.

Config file `/etc/apache2/trusted-proxies.lst` contains a list of IP ranges that are trusted for mod_remoteip. You should have your load balancers listed here if you want the Apache IPs to be correct. The `trusted-proxies.lst` file can be overwritten by setting the `APACHE_TRUSTED_PROXIES` environment variable.

### Init script
If you create and make executable `/usr/local/bin/apache_init.sh` it will be run by the entrypoint script right before Apache is started. You can use this to run migrations or anything else your app needs to work.
