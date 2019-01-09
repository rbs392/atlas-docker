ARG ATLAS_FOLDER=apache-atlas-sources-1.1.0
ARG ATLAS_BINARY=apache-atlas-1.1.0
ARG ATLAS_TAR_NAME=apache-atlas-1.1.0-sources.tar.gz
ARG ATLAS_TAR_URL=http://mirrors.estointernet.in/apache/atlas/1.1.0/apache-atlas-1.1.0-sources.tar.gz


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

ENV ATLAS_BINARY=${ATLAS_BINARY}

COPY --from=0 /tmp/$ATLAS_FOLDER/distro/target/${ATLAS_BINARY}-bin.tar.gz /apps/${ATLAS_BINARY}-bin.tar.gz

RUN cd /apps \
    && tar xvfx ${ATLAS_BINARY}-bin.tar.gz

WORKDIR /apps/${ATLAS_BINARY}

EXPOSE 21000

CMD ["/usr/lib/jvm/java-8-openjdk-amd64/bin/java", \
    "-Datlas.log.dir=/apps/${ATLAS_BINARY}/logs", \
    "-Datlas.log.file=application.log", \
    "-Datlas.home=/apps/${ATLAS_BINARY}", \
    "-Datlas.conf=/apps/${ATLAS_BINARY}/conf", \
    "-Xmx1024m", \
    "-Dlog4j.configuration=atlas-log4j.xml", \
    "-Djava.net.preferIPv4Stack=true", \
    "-server", \
    "-classpath", \
    "/apps/${ATLAS_BINARY}/conf:/apps/${ATLAS_BINARY}/server/webapp/atlas/WEB-INF/classes:/apps/${ATLAS_BINARY}/server/webapp/atlas/WEB-INF/lib/*:/apps/${ATLAS_BINARY}/libext/*:/apps/${ATLAS_BINARY}/hbase/conf", \
    "org.apache.atlas.Atlas", \
    "-app", \
    "/apps/${ATLAS_BINARY}/server/webapp/atlas"]