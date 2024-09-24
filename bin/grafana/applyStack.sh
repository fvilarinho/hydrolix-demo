#!/bin/bash

# Checks the dependencies of this script.
function checkDependencies() {
  if [ -z "$KUBECONFIG" ]; then
    echo "The kubeconfig filename is not defined! Please define it first to continue!"

    exit 1
  fi

  if [ -z "$NAMESPACE" ]; then
    echo "The namespace is not defined! Please define it first to continue!"

    exit 1
  fi

  if [ -z "$INGRESS_SETTINGS_FILENAME" ]; then
    echo "The ingress settings filename is not defined! Please define it first to continue!"

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

  if [ -z "$STACK_FILENAME" ]; then
    echo "The stack filename is not defined! Please define it first to continue!"

    exit 1
  fi
}

# Prepares the environment to execute this script.
function prepareToExecute() {
  export SOURCE_CERTIFICATE_FILENAME=/etc/letsencrypt/live/"$DOMAIN"/fullchain.pem
  export SOURCE_CERTIFICATE_KEY_FILENAME=/etc/letsencrypt/live/"$DOMAIN"/privkey.pem

  export DESTINATION_CERTIFICATE_FILENAME=$CERTIFICATE_FILENAME
  export DESTINATION_CERTIFICATE_KEY_FILENAME=$CERTIFICATE_KEY_FILENAME
}

# Creates the namespace of the stack.
function createNamespace() {
  echo "Creating the namespace..."

  $KUBECTL_CMD create namespace "$NAMESPACE" \
               -o yaml \
               --dry-run=client | $KUBECTL_CMD apply -f -
}

# Creates the settings of the stack.
function createSettings() {
  echo "Creating the settings..."

  # Ingress definitions.
  $KUBECTL_CMD create configmap ingress-settings \
               --from-file="$INGRESS_SETTINGS_FILENAME" \
               -n "$NAMESPACE" \
               -o yaml \
               --dry-run=client | $KUBECTL_CMD apply -f -

  # Certificate definitions.
  if [ -f "$SOURCE_CERTIFICATE_FILENAME" ]; then
    cp -f "$SOURCE_CERTIFICATE_FILENAME" "$DESTINATION_CERTIFICATE_FILENAME"
  fi

  if [ -f "$SOURCE_CERTIFICATE_KEY_FILENAME" ]; then
    cp -f "$SOURCE_CERTIFICATE_KEY_FILENAME" "$DESTINATION_CERTIFICATE_KEY_FILENAME"
  fi

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
  echo "Applying the stack..."

  $KUBECTL_CMD apply -f "$STACK_FILENAME" -n "$NAMESPACE"

  echo "The stack was applied successfully!"
}

# Main function.
function main() {
  checkDependencies
  prepareToExecute
  createNamespace
  createSettings
  applyStack
}

main