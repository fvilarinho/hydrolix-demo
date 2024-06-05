#!/bin/bash

# Fetches the SHA1 fingerprint using the PEM file.
function fetchSha1Fingerprint() {
  export CERTIFICATE_PEM_FILENAME="$1"

  FINGERPRINT=$($OPENSSL_CMD x509 \
                             -noout \
                             -fingerprint \
                             -in "$CERTIFICATE_PEM_FILENAME" | sha1sum | awk -F' ' '{print $1}')

  # Returns to terraform the fingerprint.
  echo "{\"fingerprint\": \"$FINGERPRINT\"}"
}

fetchSha1Fingerprint "$1"