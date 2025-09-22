FROM clickhouse
LABEL version=${VERSION}

# avoid to ask what to do and brake the build process
ENV DEBIAN_FRONTEND=noninteractive
# UTC Timezone
RUN ln -sf /usr/share/zoneinfo/UTC /etc/localtime

RUN apt-get update && apt-get upgrade -y && apt-get install -y \ 
mc vim plocate iputils-ping lynx telnet net-tools nmap lsof \
wget curl git procps htop 

