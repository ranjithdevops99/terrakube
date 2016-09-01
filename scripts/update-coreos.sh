#!/bin/bash

source ~/admin-openrc.sh

BRANCHES="stable beta alpha"
IMG_URI="amd64-usr/current/coreos_production_openstack_image.img.bz2"
VER_URI="amd64-usr/current/version.txt"

for BRANCH in $BRANCHES; do
  # check local & remote versions
  CURRENT_VERSION=$(openstack image show -f value -c tags coreos-$BRANCH)
  eval $(curl -s http://$BRANCH.release.core-os.net/$VER_URI | grep "COREOS_VERSION=")
  echo "Local $BRANCH version: $CURRENT_VERSION"
  echo "Remote $BRANCH version: $COREOS_VERSION"

  read -p "Update? (y/n) " X
  [[ $X != y ]] && continue

  URL="http://$BRANCH.release.core-os.net/$IMG_URI"
  echo "Downloading $URL to coreos-$BRANCH.img"
  curl -s $URL | bzcat - > coreos-$BRANCH.img

  ID=$(openstack image show -f value -c id coreos-$BRANCH) && \
    openstack image delete $ID

  echo "Uploading coreos-$BRANCH.img"
  openstack image create --file coreos-$BRANCH.img \
    --container-format bare --disk-format qcow2 \
    --public --tag $COREOS_VERSION coreos-$BRANCH
  rm coreos-$BRANCH.img
done
