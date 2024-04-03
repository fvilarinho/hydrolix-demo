#!/bin/bash

# Prepares the environment to execute this script.
function prepareToExecute() {
  cd .. || exit 1

  source functions.sh

  cd iac || exit 1

  export KUBECONFIG="$CONFIGURATION_FILENAME"
}

# Deploys the LKE operator and manifest.
function deploy() {
  $KUBECTL_CMD create namespace "$NAMESPACE" -o yaml --dry-run=client | $KUBECTL_CMD apply -f -
  $KUBECTL_CMD create secret tls traefik-tls --key="$CERTIFICATE_KEY_FILENAME" --cert="$CERTIFICATE_FILENAME" -n "$NAMESPACE" -o yaml --dry-run=client | $KUBECTL_CMD apply -f -
  $KUBECTL_CMD apply -f "$OPERATOR_FILENAME"

  # Waits until operator gets ready.
  sleep 5

  $KUBECTL_CMD apply -f "$MANIFEST_FILENAME"
}

# Main function.
function main() {
  prepareToExecute
  deploy
}

main