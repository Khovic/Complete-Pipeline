#!/bin/bash

echo ${DB_NAME}
echo ${DB_SERVER}
echo ${DB_PWD}
echo ${DB_USER}
echo ${2}
docker build -t $1 . --build-arg VERSION=$2 --build-arg DB_NAME=${DB_NAME} --build-arg DB_SERVER=${DB_SERVER} --build-arg DB_PWD=${DB_PWD} --build-arg DB_USER=${DB_USER}