#!/bin/bash

function createNamespace() {
  $KUBECTL_CMD create namespace "$NAMESPACE" \
               -o yaml \
               --dry-run=client | $KUBECTL_CMD apply -f -
}

function createSettings() {
  $KUBECTL_CMD create secret tls traefik-tls \
               --key="$CERTIFICATE_KEY_FILENAME" \
               --cert="$CERTIFICATE_FILENAME" \
               -n "$NAMESPACE" \
               -o yaml \
               --dry-run=client | $KUBECTL_CMD apply -f -
}

function applyStack() {
  $KUBECTL_CMD apply -f "$OPERATOR_FILENAME"

  # Waits until operator gets ready.
  sleep 5

  $KUBECTL_CMD apply -f "$STACK_FILENAME"
}

function main() {
  createNamespace
  createSettings
  applyStack
}

main