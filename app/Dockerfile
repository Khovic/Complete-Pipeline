FROM openjdk:8-jdk-oracle
EXPOSE 8080

ARG VERSION=0.0.0
ENV	VERSION=${VERSION}
ARG DB_NAME=database
ENV DB_NAME=${DB_NAME}
ARG DB_SERVER=server
ENV DB_SERVER=${DB_SERVER}
ARG DB_PWD=password
ENV	DB_PWD=${DB_PWD}
ARG DB_USER=user
ENV	DB_USER=${DB_USER}

RUN mkdir /opt/app
COPY build/libs/bootcamp-java-mysql-project-$VERSION.jar /opt/app
WORKDIR /opt/app
CMD java -jar bootcamp-java-mysql-project-$VERSION.jar

