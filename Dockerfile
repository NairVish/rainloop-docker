FROM php:7.2.7-apache-stretch

ENV RAINLOOP_VERSION 1.12.0
ENV RAINLOOP_ZIP_URL="https://github.com/RainLoop/rainloop-webmail/releases/download/v${RAINLOOP_VERSION}/rainloop-${RAINLOOP_VERSION}.zip"
ENV RAINLOOP_ZIP_NAME="rainloop-${RAINLOOP_VERSION}.zip"
ENV APACHE_CONFDIR="/etc/apache2"
ENV APACHE_LOG_DIR="/var/log/apache2"
ENV RAINLOOP_HOME="/var/www/rainloop/"

# Setup and harden PHP
# See: https://www.cyberciti.biz/tips/php-security-best-practices-tutorial.html
RUN { \
        echo 'expose_php=Off'; \
        echo 'display_errors=Off'; \
        echo 'log_errors=On'; \
        echo "error_log=${APACHE_LOG_DIR}/php_scripts_error.log"; \
        echo 'file_uploads=On'; \
        echo 'upload_max_filesize=15M'; \
        echo 'allow_url_fopen=Off'; \
        echo 'allow_url_include=Off'; \
        echo 'post_max_size=20M'; \
        echo 'max_execution_time=30'; \
        echo 'max_input_time=30'; \
        echo 'memory_limit=40M'; \
        echo 'disable_functions =exec,passthru,shell_exec,system,proc_open,popen,curl_exec,curl_multi_exec,parse_ini_file,show_source'; \
        echo 'cgi.force_redirect=On'; \
        echo "open_basedir=${RAINLOOP_HOME}"; \
        echo 'session.save_path=/var/lib/php/session'; \
        echo 'upload_tmp_dir=/var/lib/php/session'; \
    } > /usr/local/etc/php/conf.d/custom.ini;

RUN set -ex; \
    \
    touch "${APACHE_LOG_DIR}/php_scripts_error.log"; \
    chown www-data:www-data "${APACHE_LOG_DIR}/php_scripts_error.log"; \
    mkdir -p /var/lib/php/session; \
    chown -R root:www-data /var/lib/php/session; \
    docker-php-ext-install pdo pdo_mysql pdo_pgsql;

# Download and unzip Rainloop
RUN set -ex; \
    apt-get update; \
    apt-get install -y --no-install-recommends wget unzip;

RUN set -ex; \
    \
    cd /var/www; \
    wget -v ${RAINLOOP_ZIP_URL}; \
    unzip ${RAINLOOP_ZIP_NAME} -d ${RAINLOOP_HOME}; \
    chown -R www-data:www-data /var/www;

# Set Apache config and hardened conf
RUN rm ${APACHE_CONFDIR}/sites-available/000-default.conf
COPY ./000-default.conf ${APACHE_CONFDIR}/sites-available

RUN a2enmod headers
RUN rm ${APACHE_CONFDIR}/apache2.conf
COPY ./apache2.conf ${APACHE_CONFDIR}

# Copy entrypoint script onto filesystem
COPY entrypoint.sh /
RUN chmod +x /entrypoint.sh

# Finalize
ENTRYPOINT ["/entrypoint.sh"]
CMD ["apache2-foreground"]
