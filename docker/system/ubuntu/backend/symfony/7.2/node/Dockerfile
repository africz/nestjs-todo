FROM ubuntu
LABEL version=${VERSION}
ENV NODE_ENV $NODE_ENV

ENV DEBIAN_FRONTEND=noninteractive
#install utils
RUN apt-get update && apt-get upgrade -y && apt-get install -y \
wget nano mc vim htop procps git plocate iputils-ping lynx telnet \
net-tools nmap lsof

RUN apt-get update && apt-get upgrade -y && apt-get install -y \
npm
RUN npm install -g n
RUN n lts
#RUN npx -y playwright@1.41.1 install --with-deps
#ENTRYPOINT ["/usr/local/bin/npm", "run","dev"]
WORKDIR /var/www/html
EXPOSE 9323
EXPOSE 80