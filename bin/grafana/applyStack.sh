#!/bin/bash

# Creates the namespace of the stack.
function createNamespace() {
  $KUBECTL_CMD create namespace "$NAMESPACE" \
               -o yaml \
               --dry-run=client | $KUBECTL_CMD apply -f -
}

# Creates the settings of the stack.
function createSettings() {
  # Ingress definitions.
  $KUBECTL_CMD create configmap ingress-settings \
               --from-file="$INGRESS_SETTINGS_FILENAME" \
               -n "$NAMESPACE" \
               -o yaml \
               --dry-run=client | $KUBECTL_CMD apply -f -

  # Certificate definitions.
  $KUBECTL_CMD create configmap ingress-tls-certificate \
               --from-file="$CERTIFICATE_FILENAME" \
               -n "$NAMESPACE" \
               -o yaml --dry-run=client | $KUBECTL_CMD apply -f -

  $KUBECTL_CMD create configmap ingress-tls-certificate-key \
               --from-file="$CERTIFICATE_KEY_FILENAME" \
               -n "$NAMESPACE" \
               -o yaml \
               --dry-run=client | $KUBECTL_CMD apply -f -
}

# Apply the stack.
function applyStack() {
  $KUBECTL_CMD apply -f "$STACK_FILENAME" -n "$NAMESPACE"
}

# Main function.
function main() {
  createNamespace
  createSettings
  applyStack
}

main