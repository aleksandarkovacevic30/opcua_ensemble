### Cache ###
FROM centos:latest

# update OS + dependencies & run Caché silent instal
RUN yum -y update \
 && yum -y install which tar hostname net-tools wget unzip \
 && yum -y clean all \ 
 && ln -sf /etc/locatime /usr/share/zoneinfo/Europe/Prague

RUN set -ex \
	\
	&& wget -O opcua.zip "https://github.com/digitalpetri/opc-ua-demo-server/releases/download/v0.1/milo-demo-server-0.1-linux.zip" \
	&& mkdir -p /tmp/opcua \
	&& unzip  opcua.zip -d /tmp/opcua \
    && rm opcua.zip

EXPOSE 62541

ENTRYPOINT ["/tmp/opcua/milo-demo-server/bin/milo-demo-server"]