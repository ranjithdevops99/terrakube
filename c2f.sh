#!/bin/bash

FILE=$1

CURL_ARGS="-S -X GET"
BASE_URL="http://useless.mass.goathorde.org:8500/v1/kv"
URL_PREFIX="/storage/fs1"
FS_PREFIX="/tmp"

OUT_DIR=$(dirname $FS_PREFIX$FILE)
echo "out dir: $OUT_DIR"

[[ ! -d $OUT_DIR ]] && mkdir -p $OUT_DIR
SHA256=$(curl $CURL_ARGS $BASE_URL$URL_PREFIX$FILE.sha256?raw)
curl $CURL_ARGS $BASE_URL$URL_PREFIX$FILE?raw -o $FS_PREFIX$FILE
echo "$SHA256 $FILE" | sha256sum
[[ $? -eq 0 ]] && echo -e "\nsuccess" || echo -e "\nerror"
