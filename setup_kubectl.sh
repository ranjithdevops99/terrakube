#!/bin/bash

kubectl config set-cluster tf-cluster \
  --server="https://${1}" \
  --certificate-authority="/tmp/ca.pem"
kubectl config set-credentials tf-admin \
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

kubectl get nodes

kubectl cluster-info


kubectl config set-cluster default-cluster --server=https://${MASTER_HOST} --certificate-authority=${CA_CERT}
kubectl config set-credentials tf-admin --certificate-authority=${CA_CERT} --client-key=${ADMIN_KEY} --client-certificate=${ADMIN_CERT}
kubectl config set-context default-system --cluster=default-cluster --user=default-admin
kubectl config use-context default-system
