FROM mysql
LABEL version=${VERSION}

#ENV DEBIAN_FRONTEND=noninteractive
#install utils
#RUN apt-get update && apt-get upgrade -y && apt-get install -y \
#wget nano mc vim htop procps git plocate iputils-ping lynx telnet
COPY dbi.sh /dbi.sh
COPY my.cnf /etc/my.cnf

RUN chmod 700 dbi.sh

EXPOSE 3306