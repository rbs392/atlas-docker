ARG ATLAS_FOLDER=apache-atlas-sources-1.1.0
ARG ATLAS_BINARY=apache-atlas-1.1.0
ARG ATLAS_TAR_NAME=apache-atlas-1.1.0-sources.tar.gz
ARG ATLAS_TAR_URL=http://mirrors.fibergrid.in/apache/atlas/1.1.0/apache-atlas-1.1.0-sources.tar.gz


FROM maven:3.6.0-jdk-8

ARG ATLAS_FOLDER
ARG ATLAS_BINARY
ARG ATLAS_TAR_NAME
ARG ATLAS_TAR_URL

ENV MAVEN_OPTS="-Xms2g -Xmx2g"

# download atlas
RUN cd /tmp \
    && wget $ATLAS_TAR_URL \
    &&  tar xvfz $ATLAS_TAR_NAME


#install atlas
RUN cd /tmp/$ATLAS_FOLDER \
    && mvn clean package -DskipTests -Pdist,embedded-hbase-solr


FROM openjdk:8u181-jdk-stretch

ARG ATLAS_FOLDER
ARG ATLAS_BINARY

COPY --from=0 /tmp/$ATLAS_FOLDER/distro/target/${ATLAS_BINARY}-bin.tar.gz /apps/${ATLAS_BINARY}-bin.tar.gz

RUN cd /apps \
    && tar xvfx ${ATLAS_BINARY}-bin.tar.gz

WORKDIR /apps/${ATLAS_BINARY}

EXPOSE 21000

CMD "/bin/bash", "-c", "/apps/apache-atlas-1.1.0/bin/atlas_start.py; tail -fF /apps/apache-atlas-1.1.0/logs/application.log"
