#!/bin/bash

echo ${DB_NAME}
echo ${DB_SERVER}
echo ${DB_PWD}
echo ${DB_USER}

docker build -t $1 . --build-arg VERSION=${VERSION} --build-arg DB_NAME=${DB_NAME} --build-arg DB_SERVER=${DB_SERVER} --build-arg DB_PWD=${DB_PWD} --build-arg DB_USER=${DB_USER}