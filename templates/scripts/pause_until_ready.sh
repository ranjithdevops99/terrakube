#!/bin/bash

function master() {
  until ( $(sudo netstat -tnlp | grep 8080 &> /dev/null) ); do
    sleep 5
    #echo "waiting for apiserver to start"
  done
  echo "I'm a master!!!"
  curl -H "Content-Type: application/json" -X POST \
    -d '{"apiVersion":"v1","kind":"Namespace","metadata":{"name":"kube-system"}}' \
    "http://127.0.0.1:8080/api/v1/namespaces"
}

function minion() {
  echo "I'm a minion!!!"
}

case $(hostname) in
  coreos0):
    master
    ;;
  *):
    minion
    ;;
esac
