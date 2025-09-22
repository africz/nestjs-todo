FROM ubuntu
LABEL version=${VERSION}
ENV PHP_VERSION 8.4

# avoid to ask what to do and brake the build process
ENV DEBIAN_FRONTEND=noninteractive
# UTC Timezone
RUN ln -sf /usr/share/zoneinfo/UTC /etc/localtime

RUN apt-get update && apt-get upgrade -y && apt-get install -y \ 
mc vim plocate iputils-ping lynx telnet net-tools nmap lsof \
wget curl git procps htop software-properties-common

#install php
RUN LC_ALL=C.UTF-8 add-apt-repository ppa:ondrej/php
RUN apt-get update && apt-get upgrade -y && apt-get install -y \ 
php${PHP_VERSION} php${PHP_VERSION}-fpm php php${PHP_VERSION}-mysql  php${PHP_VERSION}-gd php${PHP_VERSION}-intl php${PHP_VERSION}-pdo php${PHP_VERSION}-cli \
php${PHP_VERSION}-xml php${PHP_VERSION}-mbstring php${PHP_VERSION}-bcmath php${PHP_VERSION}-zip php${PHP_VERSION}-apcu php${PHP_VERSION}-opcache  php${PHP_VERSION}-soap \
php${PHP_VERSION}-tidy php${PHP_VERSION}-pcov php${PHP_VERSION}-redis php${PHP_VERSION}-yaml php${PHP_VERSION}-memcache php${PHP_VERSION}-memcached \
php${PHP_VERSION}-curl composer php${PHP_VERSION}-xdebug php${PHP_VERSION}-sqlite3

RUN apt-get update && apt-get upgrade -y && apt-get install -y \ 
php-json php-symfony-process

RUN ln -s /usr/sbin/php${PHP_VERSION}-fpm${PHP_VERSION} /usr/sbin/php-fpm

#install php tools
RUN apt-get update && apt-get upgrade -y && apt-get install -y \ 
php${PHP_VERSION}-dev php-pear libmcrypt-dev gcc make autoconf libc-dev \
pkg-config
# RUN pecl install mcrypt
# mcrypt is not supported for PHP 8.4 and above
# Install mcrypt only if PHP_VERSION is less than 8.4
RUN if dpkg --compare-versions "$PHP_VERSION" lt "8.4"; then \
	pecl install mcrypt && \
	echo "extension=mcrypt.so" > /etc/php/${PHP_VERSION}/mods-available/mcrypt.ini && \
	phpenmod -v ${PHP_VERSION} mcrypt; \
fi
# setup php
RUN sed -i \
    -e 's~^;date.timezone =$~date.timezone = Europe/Madrid~g' \
    -e 's~^display_startup_errors = Off$~display_startup_errors = On~g' \
    -e 's~^display_errors = Off$~display_errors = On~g' \
    -e 's~^;user_ini.filename =$~user_ini.filename =~g' \
	-e 's~^short_open_tag = Off$~short_open_tag = On~g' \
    -e 's~^sendmail_path = /usr/sbin/sendmail -t -i$~sendmail_path = /usr/bin/msmtp -C /etc/msmtprc -t -i~g' \
    -e 's~^upload_max_filesize = 2M$~upload_max_filesize = 128M~g' \
	-e 's~^post_max_size = 8M$~post_max_size = 20M~g' \
	-e 's~^;realpath_cache_size = 4096k$~realpath_cache_size = 4096k~g' \
	-e 's~^memory_limit = 128M$~memory_limit = 1024M~g' \
	-e 's~^;error_log = php_errors.log$~error_log = /var/log/fpm-php.www.log~g' \
	-e 's~^session.save_handler = files$~session.save_handler = redis~g' \
	-e 's~^;session.save_path = "/var/lib/php/sessions"$~session.save_path = tcp://redis:6379~g' \
    /etc/php/${PHP_VERSION}/fpm/php.ini

#opcache settings
RUN { \
	echo ";configuration for php opcache module";\
	echo ";priority=10";\
	echo "zend_extension=opcache.so";\
	echo "opcache.jit=on";\
	echo "opcache.enable=1"; \
	echo "opcache.enable_cli=1"; \
	echo "opcache.memory_consumption=512"; \
	echo "opcache.interned_strings_buffer=16"; \
	echo "opcache.max_accelerated_files=40000"; \
	echo "opcache.validate_timestamps=1"; \
} | tee /etc/php/${PHP_VERSION}/mods-available/opcache.ini;



#apcu settings
RUN { \
	echo ";configuration for php apcu module";\
	echo ";priority=20";\
	echo "extension=apcu.so";\
	echo "apc.enabled=1"; \
	echo "apc.enable_cli=1"; \
} | tee /etc/php/${PHP_VERSION}/mods-available/apcu.ini;



RUN sed -i \
	-e 's~^;date.timezone =$~date.timezone = Europe/Madrid~g' \
	-e 's~^;opcache.enable=0$~opcache.enable=1~g' \
	-e 's~^;opcache.enable_cli=0$~opcache.enable_cli=1~g' \
	-e 's~^;opcache.memory_consumption=128$~opcache.memory_consumption=512~g' \
	-e 's~^;realpath_cache_size = 4096k$~realpath_cache_size = 4096k~g' \
	-e 's~^display_startup_errors = Off$~display_startup_errors = On~g' \
    -e 's~^display_errors = Off$~display_errors = On~g' \
	-e 's~^short_open_tag = Off$~short_open_tag = On~g' \
    /etc/php/${PHP_VERSION}/cli/php.ini


# setup php xdebug
RUN rm -f /etc/php/${PHP_VERSION}/fpm/conf.d/20-xdebug.ini
RUN     { \
			echo "zend_extension=xdebug.so"; \
			echo "[xdebug]"; \
			echo "xdebug.mode=debug"; \
			echo "xdebug.start_with_request=yes"; \
			echo "xdebug.discover_client_host=1"; \
			echo "xdebug.profiler_enable=off"; \
			echo "xdebug.client_host=host.docker.internal"; \
			echo "xdebug.client_port=9003"; \
			echo "xdebug.idekey=VSCODESERVER" ; \
			echo "xdebug.output_dir=/tmp/xdebug"; \
		} | tee /etc/php/${PHP_VERSION}/fpm/conf.d/20-xdebug.ini

	RUN rm -f /etc/php/${PHP_VERSION}/cli/conf.d/20-xdebug.ini
	RUN     { \
		echo "zend_extension=xdebug.so"; \
		echo "[xdebug]"; \
		echo "xdebug.mode=debug"; \
		echo "xdebug.start_with_request=yes"; \
		echo "xdebug.discover_client_host=1"; \
		echo "xdebug.profiler_enable=off"; \
		echo "xdebug.client_host=host.docker.internal"; \
		echo "xdebug.client_port=9003"; \
		echo "xdebug.idekey=VSCODECLI" ; \
		echo "xdebug.output_dir=/tmp/xdebug"; \
	} | tee /etc/php/${PHP_VERSION}/cli/conf.d/20-xdebug.ini; 



COPY www.conf /etc/php/${PHP_VERSION}/fpm/pool.d

# Set up base directories
RUN mkdir /tmp/xdebug
#install phpDocumentor
RUN wget https://github.com/phpDocumentor/phpDocumentor/releases/latest/download/phpDocumentor.phar -O phpdoc.phar
## Generate documentation
#php phpdoc.phar -d app -t doc
WORKDIR /var/www/html
#install composer
RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer
#install symfony
RUN curl -1sLf 'https://dl.cloudsmith.io/public/symfony/stable/setup.deb.sh' | bash
RUN composer global require laravel/installer

CMD sh -c "php-fpm${PHP_VERSION} -F -R"
EXPOSE 9000