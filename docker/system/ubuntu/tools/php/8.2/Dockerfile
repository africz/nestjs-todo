ARG  platform arm64v8
FROM ${platform}/ubuntu:noble

ENV PROJECT_NAME ""
ENV VERSION 0.0.1
LABEL version=${VERSION}
LABEL description=${PROJECT_NAME}

ENV XDEBUG_OUTPUT_DIR /tmp/xdebug
ENV XDEBUG_MODE debug
ENV XDEBUG_START yes
ENV PHP_VERSION 8.2
# avoid to ask what to do and brake the build process
ENV DEBIAN_FRONTEND=noninteractive
# UTC Timezone
RUN ln -sf /usr/share/zoneinfo/UTC /etc/localtime

#install php
RUN apt-get update && apt-get upgrade -y && apt-get install -y \ 
php php-fpm php php-mysql php-json php-gd php-intl php-pdo php-cli \
php-xml php-mbstring php-bcmath php-zip php-apcu php-opcache  php-soap \
php-tidy php-pcov php-redis php-yaml php-memcache php-memcached \
php-symfony-process php-curl composer php-xdebug

RUN ln -s /usr/sbin/php-fpm${PHP_VERSION} /usr/sbin/php-fpm

#install php tools
RUN apt-get update && apt-get upgrade -y && apt-get install -y \ 
php-dev php-pear libmcrypt-dev gcc make autoconf libc-dev \
pkg-config
RUN pecl install mcrypt

# setup php
RUN sed -i \
    -e 's~^;date.timezone =$~date.timezone = Europe/Madrid~g' \
    -e 's~^display_startup_errors = Off$~display_startup_errors = On~g' \
    -e 's~^display_errors = Off$~display_errors = On~g' \
    -e 's~^;user_ini.filename =$~user_ini.filename =~g' \
	-e 's~^short_open_tag = Off$~short_open_tag = On~g' \
    -e 's~^sendmail_path = /usr/sbin/sendmail -t -i$~sendmail_path = /usr/bin/msmtp -C /etc/msmtprc -t -i~g' \
    -e 's~^upload_max_filesize = 2M$~upload_max_filesize = 20M~g' \
    -e 's~^post_max_size = 8M$~post_max_size = 20M~g' \
    /etc/php/${PHP_VERSION}/fpm/php.ini

RUN sed -i \
    -e 's~^;date.timezone =$~date.timezone = Europe/Madrid~g' \
    -e 's~^display_startup_errors = Off$~display_startup_errors = On~g' \
    -e 's~^display_errors = Off$~display_errors = On~g' \
	-e 's~^short_open_tag = Off$~short_open_tag = On~g' \
    /etc/php/${PHP_VERSION}/cli/php.ini


#netstat -nr | grep '^0\.0\.0\.0' | awk '{print $2}'
#172.23.0.1

# setup php xdebug
RUN     { \
            echo "zend_extension=/usr/lib/php/20230831/xdebug.so"; \
            echo "[xdebug]"; \
            echo "xdebug.mode=${XDEBUG_MODE}"; \
            echo "xdebug.start_with_request=${XDEBUG_START}"; \
            echo "xdebug.discover_client_host=1"; \
            echo "xdebug.client_host=host.docker.internal"; \
            echo "xdebug.client_port=9003"; \
            echo "xdebug.idekey=VSCODE" ; \
            echo "xdebug.log=/var/www/html/var/log/xdebug_remote.log"; \
			echo "xdebug.output_dir=${XDEBUG_OUTPUT_DIR}"; \
        } | tee /etc/php/${PHP_VERSION}/mods-available/xdebug.ini; 



RUN ln -sf /etc/php/${PHP_VERSION}/mods-available/xdebug.ini /etc/php/${PHP_VERSION}/cli/conf.d/10-xdebug.ini   

#RUN ln -sf /etc/php/${PHP_VERSION}/mods-available/apcu.ini /etc/php/${PHP_VERSION}/cli/conf.d/40-acpu.ini

COPY www.conf /etc/php/${PHP_VERSION}/fpm/pool.d

# Set up base directories
RUN mkdir /tmp/xdebug

#install utils
RUN apt-get update && apt-get upgrade -y && apt-get install -y \
wget git plocate iputils-ping lynx telnet net-tools iputils-ping htop
#vim plocate
#nmap lsof
#plocate don't need locate works built in

CMD ["php-fpm", "-F", "-R"]
EXPOSE 9000