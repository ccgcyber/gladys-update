#!/bin/bash
set -e

GLADYS_VERSION=3.11.0
EXPECTED_CHECKSUM="8956af8b8b38054f16a2c426263bfa21  gladys-v3.11.0-Linux-armv6l.tar.gz"

TMP_HOOK_FOLDER="/tmp/gladys_hooks"
TMP_CACHE_FOLDER="/tmp/gladys_cache"
GLADYS_FOLDER="/home/pi/gladys"

# Cleaning Gladys hook folder
rm -rf $TMP_HOOK_FOLDER

# Cleaning Gladys cache folder
rm -rf $TMP_CACHE_FOLDER

# Creating temp folder
mkdir $TMP_HOOK_FOLDER
mkdir $TMP_CACHE_FOLDER

# We copy the hooks repository of the old folder
cp -ar $GLADYS_FOLDER/api/hooks/. $TMP_HOOK_FOLDER

# We copy the cache folder of the old gladys
cp -ar $GLADYS_FOLDER/cache/. $TMP_CACHE_FOLDER

# We clean the installation file if it already exists
rm gladys-v3.11.0-Linux-armv6l.tar.gz || true

# download update
wget https://mirror-fr-2.gladysproject.com/upgrades/gladys-v3.11.0-Linux-armv6l.tar.gz

CHECKSUM="$(md5sum gladys-v3.11.0-Linux-armv6l.tar.gz)"

# check checksum
if [ "$CHECKSUM" != "$EXPECTED_CHECKSUM" ]
then
 echo "Wrong file checksum. Exiting" 
 exit 1
fi

# stop gladys
pm2 stop --silent gladys || true

# Delete current gladys install
rm -rf $GLADYS_FOLDER || true

#  install gladys 
tar zxvf gladys-v$GLADYS_VERSION-Linux-armv6l.tar.gz

# move back hooks & cache
cp -ar $TMP_HOOK_FOLDER/. $GLADYS_FOLDER/api/hooks
cp -ar $TMP_CACHE_FOLDER/. $GLADYS_FOLDER/cache

# init 
#cd $GLADYS_FOLDER
#node init.js

# restart gladys
pm2 start /home/pi/gladys/app.js --name gladys