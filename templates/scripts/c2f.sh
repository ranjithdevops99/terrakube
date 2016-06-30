#!/bin/bash

# full path + name of file to be pulled from k/v
FILE=$1

# url for all curl commands
BASE_URL="http://useless.mass.goathorde.org:8500/v1/kv"
# prefix for host specific config files
URL_PREFIX="/$(hostname)"
# dir appended to output file, mostly for testing
FS_PREFIX="/tmp"
# resulting directory the file will be placed in
OUT_DIR=$(dirname ${FS_PREFIX}${FILE})
# create output directory if non-existant
[[ ! -d "$OUT_DIR" ]] && mkdir -p "$OUT_DIR"
# host specific url for file
URL="${BASE_URL}${URL_PREFIX}${FILE}?raw"
# 200 - file exists, 404 - does not exist
HTTP_STATUS=$(curl -s -w "%{http_code}" -o /dev/null "$URL")
# echo "http status: $HTTP_STATUS"
# if host specific file verson does not exist, use global one
[ "$HTTP_STATUS" == "404" ] && URL="${BASE_URL}${FILE}?raw"
# output url to be used
# echo -e "url: $URL"
# download file
curl -s -o "${FS_PREFIX}${FILE}" "$URL"
# output result of download
[[ $? -eq 0 ]] && echo -e "success" || echo -e "error"
