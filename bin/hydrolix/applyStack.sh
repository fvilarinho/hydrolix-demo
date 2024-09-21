#!/bin/bash

# Check the dependencies of this script.
function checkDependencies() {
  if [ -z "$KUBECONFIG" ]; then
    echo "The kubeconfig filename is not defined! Please define it first to continue!"

    exit 1
  fi

  if [ -z "$NAMESPACE" ]; then
    echo "The namespace is not defined! Please define it first to continue!"

    exit 1
  fi

  if [ -z "$CERTIFICATE_FILENAME" ]; then
    echo "The certificate filename is not defined! Please define it first to continue!"

    exit 1
  fi

  if [ -z "$CERTIFICATE_KEY_FILENAME" ]; then
    echo "The certificate key filename is not defined! Please define it first to continue!"

    exit 1
  fi

  if [ -z "$OPERATOR_FILENAME" ]; then
    echo "The operator filename is not defined! Please define it first to continue!"

    exit 1
  fi

  if [ -z "$STACK_FILENAME" ]; then
    echo "The stack filename is not defined! Please define it first to continue!"

    exit 1
  fi
}

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
  checkDependencies
  createNamespace
  createSettings
  applyStack
}

main