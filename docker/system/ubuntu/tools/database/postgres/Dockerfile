FROM ubuntu/postgres
LABEL version=${VERSION}

ENV DEBIAN_FRONTEND=noninteractive
#install utils
RUN apt-get update && apt-get upgrade -y && apt-get install -y \
wget nano mc vim htop procps git plocate iputils-ping lynx telnet

EXPOSE 5432
CMD ["postgres"]

