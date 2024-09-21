#!/bin/bash

# Creates the namespace of the stack.
function createNamespace() {
  $KUBECTL_CMD create namespace "$NAMESPACE" \
               -o yaml \
               --dry-run=client | $KUBECTL_CMD apply -f -
}

# Creates the settings of the stack.
function createSettings() {
  $KUBECTL_CMD create secret tls traefik-tls \
               --key="$CERTIFICATE_KEY_FILENAME" \
               --cert="$CERTIFICATE_FILENAME" \
               -n "$NAMESPACE" \
               -o yaml \
               --dry-run=client | $KUBECTL_CMD apply -f -
}

# Apply the stack.
function applyStack() {
  $KUBECTL_CMD apply -f "$OPERATOR_FILENAME"

  # Waits until operator is ready.
  sleep 5

  $KUBECTL_CMD apply -f "$STACK_FILENAME"
}

# Main function.
function main() {
  createNamespace
  createSettings
  applyStack
}

main