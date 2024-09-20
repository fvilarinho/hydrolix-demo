#!/bin/bash

function createNamespace() {
  $KUBECTL_CMD create namespace "$NAMESPACE" \
               -o yaml \
               --dry-run=client | $KUBECTL_CMD apply -f -
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

function applyStack() {
  applyStorages
  applyDeployments
  applyServices
}

function main() {
  createNamespace
  applyStack
}

main