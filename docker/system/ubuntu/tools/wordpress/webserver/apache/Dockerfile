FROM ubuntu
LABEL version=${VERSION}

# avoid to ask what to do and brake the build process
ENV DEBIAN_FRONTEND=noninteractive
#install utils
RUN apt-get update && apt-get upgrade -y && apt-get install -y \
wget nano mc vim htop procps git plocate iputils-ping lynx telnet \
net-tools nmap lsof

# install Apache
RUN apt-get update && apt-get upgrade -y && apt-get install -y \
apache2 apache2-dev cmake

# Set up base directories
RUN mkdir -p /var/log/httpd


# UTC Timezone
RUN ln -sf /usr/share/zoneinfo/UTC /etc/localtime

#setup Apache
RUN mkdir /var/run/apache2
COPY entrypoint.sh /entrypoint.sh
COPY setrights.sh /setrights.sh
RUN mkdir ssl-certs
COPY ssl/cert.pem /ssl-certs
COPY ssl/key.pem /ssl-certs
COPY conf.d/httpd.conf /etc/apache2/conf-available
RUN ln -sf /etc/apache2/conf-available/httpd.conf /etc/apache2/conf-enabled/httpd.conf 
RUN chmod 700 /entrypoint.sh
RUN chmod 700 /setrights.sh
RUN     { \
            echo 'LogLevel warn rewrite:trace8'; \
        } | tee /etc/apache2/mods-available/rewrite-log.load; 

RUN ln -sf /etc/apache2/mods-available/expires.load /etc/apache2/mods-enabled/expires.load
RUN ln -sf /etc/apache2/mods-available/cache.load /etc/apache2/mods-enabled/cache.load
RUN ln -sf /etc/apache2/mods-available/cache_disk.load /etc/apache2/mods-enabled/cache_disk.load
RUN ln -sf /etc/apache2/mods-available/cache_socache.load /etc/apache2/mods-enabled/cache_socache.load
RUN ln -sf /etc/apache2/mods-available/ssl.load /etc/apache2/mods-enabled/ssl.load
RUN ln -sf /etc/apache2/mods-available/ssl.conf /etc/apache2/mods-enabled/ssl.conf
RUN ln -sf /etc/apache2/mods-available/socache_shmcb.load /etc/apache2/mods-enabled/socache_shmcb.load
RUN ln -sf /etc/apache2/mods-available/headers.load /etc/apache2/mods-enabled/headers.load
RUN ln -sf /etc/apache2/mods-available/rewrite.load /etc/apache2/mods-enabled/rewrite.load
RUN ln -sf /etc/apache2/mods-available/http2.load /etc/apache2/mods-enabled/http2.load
RUN ln -sf /etc/apache2/mods-available/socache_shmcb.load /etc/apache2/mods-enabled/socache_shmcb.load
RUN ln -sf /etc/apache2/mods-available/rewrite-log.load /etc/apache2/mods-enabled/rewrite-log.load
RUN ln -sf /etc/apache2/mods-available/proxy.load /etc/apache2/mods-enabled/proxy.load
RUN ln -sf /etc/apache2/mods-available/proxy.conf /etc/apache2/mods-enabled/proxy.conf
RUN ln -sf /etc/apache2/mods-available/proxy_fcgi.load /etc/apache2/mods-enabled/proxy_fcgi.load

RUN chmod -R 777 /var/log
WORKDIR /var/www/html
EXPOSE 80
