#!/bin/bash

version=$(grep 'version ' build.gradle | awk '{print $2}' | awk 'NR==3' | tr -d "''")
echo $version
major=$(echo $version | cut -d. -f1)
minor=$(echo $version | cut -d. -f2)
patch=$(echo $version | cut -d. -f3)

filename="build.gradle"
valid=true

if [ $1 == 'major' ]
then
   patch = 0
   minor = 0
   version_new=$(($major+1)).0.0
elif [ $1 == 'minor' ]
then
   patch = 0
   version_new=$major.$(($minor+1)).0
elif [ $1 == 'patch' ]
then 
   version_new=$major.$minor.$(($patch+1))
else 
   echo "versioning error"
   valid=false
fi
echo $version_new
version_old="version '$version'"
version_replace="version '$version_new'"

if [ $valid = true ]
then
  echo "valid is true"
  echo $version_old
  
  echo $version_new > version.txt
  sed -i "s/$version_old/$version_replace/" $filename

fi
