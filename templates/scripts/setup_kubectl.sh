#!/bin/bash

IP=$1

kubectl config set-cluster tf-cluster \
  --embed-certs=true \
  --server="https://$IP" \
  --certificate-authority="/tmp/ca.pem"

kubectl config set-credentials tf-admin \
  --embed-certs=true \
  --certificate-authority="/tmp/ca.pem" \
  --client-key="/tmp/admin-key.pem" \
  --client-certificate="/tmp/admin.pem"

kubectl config set-context tf-system \
  --cluster="tf-cluster" \
  --user="tf-admin"

kubectl config use-context tf-system

exit 0

echo -n "Waiting for kubernetes master to come up"
while (true); do
  if (: < /dev/tcp/$1/443) 2>/dev/null; then break; fi
  echo -n "."
  sleep 5
done

for x in `seq 1 30`; do
  [[ $(kubectl get nodes | wc -l) -eq $2 ]] && continue
  echo -n "."
  sleep 2
done
echo
