ARG  platform arm64v8
FROM ${platform}/ubuntu

ENV PROJECT_NAME ""
ENV VERSION 0.0.1
LABEL version=${VERSION}
LABEL description=${PROJECT_NAME}

# avoid to ask what to do and brake the build process
ENV DEBIAN_FRONTEND=noninteractive
#install utils
RUN apt-get update && apt-get upgrade -y && apt-get install -y \
wget nano mc vim htop procps git plocate iputils-ping lynx telnet \
net-tools nmap lsof
# UTC Timezone
RUN ln -sf /usr/share/zoneinfo/UTC /etc/localtime


#install nginx
RUN apt-get update && apt-get upgrade -y && apt-get install -y \
nginx

COPY conf/default.conf /etc/nginx/sites-available
RUN ln -s /etc/nginx/sites-available/default.conf /etc/nginx/sites-enabled/
#remove default distro configuraton
RUN rm /etc/nginx/sites-enabled/default
#set error log to stderr
#RUN addgroup nobody tty


COPY setrights.sh /setrights.sh
COPY entrypoint.sh /entrypoint.sh
RUN chmod 700 /entrypoint.sh
RUN chmod 700 /setrights.sh
ENTRYPOINT [ "/entrypoint.sh" ]
CMD ["nginx", "-g", "daemon off;"]
EXPOSE 80
