#!/bin/bash

# Installs the Hydrolix operator and manifest.
function install() {
  $KUBECTL_CMD create namespace "$NAMESPACE" \
               -o yaml \
               --dry-run=client | $KUBECTL_CMD apply -f -

  $KUBECTL_CMD create secret tls traefik-tls \
               --key="$CERTIFICATE_KEY_FILENAME" \
               --cert="$CERTIFICATE_PEM_FILENAME" \
               -n "$NAMESPACE" \
               -o yaml \
               --dry-run=client | $KUBECTL_CMD apply -f -

  $KUBECTL_CMD apply -f "$OPERATOR_FILENAME"

  # Waits until operator gets ready.
  sleep 5

  $KUBECTL_CMD apply -f "$MANIFEST_FILENAME"
}

install