#!/bin/bash

function createNamespace() {
  $KUBECTL_CMD create namespace "$NAMESPACE" \
               -o yaml \
               --dry-run=client | $KUBECTL_CMD apply -f -
}

function createSettings() {
  $KUBECTL_CMD create configmap ingress-settings --from-file=../etc/grafana/ingress.conf -n "$NAMESPACE" -o yaml --dry-run=client | $KUBECTL_CMD apply -f -
  $KUBECTL_CMD create configmap ingress-tls-certificate --from-file=../etc/tls/fullchain.pem -n "$NAMESPACE" -o yaml --dry-run=client | $KUBECTL_CMD apply -f -
  $KUBECTL_CMD create configmap ingress-tls-certificate-key --from-file=../etc/tls/privkey.pem -n "$NAMESPACE" -o yaml --dry-run=client | $KUBECTL_CMD apply -f -
}

function applyStorages() {
  $KUBECTL_CMD apply -f "../etc/grafana/storages.yaml" -n "$NAMESPACE"
}

function applyDeployments() {
  $KUBECTL_CMD apply -f "../etc/grafana/deployments.yaml" -n "$NAMESPACE"
}

function applyServices() {
  $KUBECTL_CMD apply -f "../etc/grafana/services.yaml" -n "$NAMESPACE"
}

function apply() {
  applyStorages
  applyDeployments
  applyServices
}

function main() {
  createNamespace
  createSettings
  apply
}

main