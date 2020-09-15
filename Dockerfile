### Cache ###
FROM centos:latest

# update OS + dependencies & run Caché silent instal
RUN yum -y update \
 && yum -y install which tar hostname net-tools wget \
 && yum -y clean all \ 
 && ln -sf /etc/locatime /usr/share/zoneinfo/Europe/Prague



ARG cache=ensemble-2018.1.4.505.1
ARG globals8k=512
ARG routines=32
ARG locksiz=117964800

ENV TMP_INSTALL_DIR=/tmp/distrib

COPY ensemble/Common.cls /home/cacheusr/ensemble/Common.cls
#COPY ensemble/InboundAdapter.cls /home/cacheusr/ensemble/InboundAdapter.cls
#COPY ensemble/Interface.cls /home/cacheusr/ensemble/Interface.cls
COPY ensemble/Production.cls /home/cacheusr/ensemble/Production.cls

# vars for Caché silent install
ENV ISC_PACKAGE_INSTANCENAME="ENSEMBLE" \
    ISC_PACKAGE_INSTALLDIR="/opt/ensemble/" \
    ISC_PACKAGE_UNICODE="Y" \
    ISC_PACKAGE_CLIENT_COMPONENTS="" \
    ISC_INSTALLER_MANIFEST=${TMP_INSTALL_DIR}/Installer.cls \
    ISC_INSTALLER_LOGFILE=installer_log \
    ISC_INSTALLER_LOGLEVEL=3 \
    ISC_INSTALLER_PARAMETERS="routines=$routines,locksiz=$locksiz,globals8k=$globals8k" \
    SRC_DIR=/home/cacheusr

COPY ensemble/Installer.cls /home/cacheusr/ensemble/Installer.cls
COPY ensemble/Common.cls /home/cacheusr/ensemble/Common.cls
COPY ensemble/TestCommon.cls /home/cacheusr/ensemble/TestCommon.cls
COPY ensemble/InboundAdapter.cls /home/cacheusr/ensemble/InboundAdapter.cls
COPY ensemble/ReadRequest.cls /home/cacheusr/ensemble/ReadRequest.cls
COPY ensemble/OPCUABS.cls /home/cacheusr/ensemble/OPCUABS.cls
COPY ensemble/BP.cls /home/cacheusr/ensemble/BP.cls
COPY ensemble/Production.cls /home/cacheusr/ensemble/Production.cls
COPY ensemble/TestProduction.cls /home/cacheusr/ensemble/TestProduction.cls
COPY ensemble/readResult.cls /home/cacheusr/ensemble/readResult.cls


# set-up and install Caché from distrib_tmp dir 
WORKDIR ${TMP_INSTALL_DIR}

ENV KEY_FILE="ISC Development_ENS_Enterprise_100_Platform Independent_11-30-2020.ISCkey"

# our application installer
#COPY Installer.cls .
# custom installation manifest 
#COPY custom_install-manifest.isc ./$cache-lnxrhx64/package/custom_install/manifest.isc 
# license file
COPY ["cache.key", "/opt/ensemble/mgr/cache.key"]

COPY ensemble-2018.1.4.505.1-lnxrhx64.tar.gz /tmp/ensemble-2018.1.4.505.1-lnxrhx64.tar.gz

# cache distributive
RUN tar xvfz /tmp/$cache-lnxrhx64.tar.gz \
 && ./$cache-lnxrhx64/cinstall_silent \
 && cat $ISC_PACKAGE_INSTALLDIR/mgr/cconsole.log \
 && cat $ISC_PACKAGE_INSTALLDIR/mgr/installer_log \
 && ccontrol stop ENSEMBLE quietly \
 && rm -rf $TMP_INSTALL_DIR \
 && rm /tmp/ensemble-2018.1.4.505.1-lnxrhx64.tar.gz

# TCP sockets that can be accessed if user wants to (see 'docker run -p' flag)
EXPOSE 57772 1972 22

RUN yum install -y \
   java-1.8.0-openjdk \
   java-1.8.0-openjdk-devel

# Setup JAVA_HOME -- useful for docker commandline
ENV JAVA_HOME /usr/lib/jvm/java-8-openjdk-amd64/
RUN export JAVA_HOME

COPY build/libs/opcua_ensemble.jar /tmp/opcua.jar

RUN yum -y install unzip && mkdir /home/cacheusr/opcua && cd /home/cacheusr/opcua && jar xf /tmp/opcua.jar && rm /tmp/opcua.jar

# Caché container main process PID 1 (https://github.com/zrml/ccontainermain)
RUN curl -L https://github.com/daimor/ccontainermain/releases/download/0.1/ccontainermain -o /ccontainermain && chmod +x /ccontainermain

RUN ccontrol start ENSEMBLE && \
    /bin/echo -e "zn \"ENSEMBLE\"\n"\
            " do \$system.OBJ.Load(\$system.Util.GetEnviron(\"SRC_DIR\") _ \"/ensemble/Installer.cls\",\"ck\")\n" \
            " set sc = ##class(OPCUA.Installer).Setup(, 3)\n" \
            " if 'sc  write !,\$System.Status.GetErrorText(sc),!  do \$system.Process.Terminate(, 1)" \ 
    | csession ENSEMBLE && \
 ccontrol stop ENSEMBLE quietly \
  && rm -f $ISC_PACKAGE_INSTALLDIR/mgr/journal.log \
  && rm -f $ISC_PACKAGE_INSTALLDIR/mgr/IRIS.WIJ \
  && rm -f $ISC_PACKAGE_INSTALLDIR/mgr/iris.ids \
  && rm -f $ISC_PACKAGE_INSTALLDIR/mgr/alerts.log \
  && rm -f $ISC_PACKAGE_INSTALLDIR/mgr/journal/* \
  && rm -f $ISC_PACKAGE_INSTALLDIR/mgr/messages.log \
  && rm -rf $SRC_DIR/isc $SRC_DIR/rtn \
  && touch $ISC_PACKAGE_INSTALLDIR/mgr/messages.log

ENTRYPOINT ["/ccontainermain", "-cconsole", "-i", "ensemble"]