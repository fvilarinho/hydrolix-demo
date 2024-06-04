#!/bin/bash

# Prepares the environment to execute this script.
function prepareToExecute() {
  cd ../../ || exit 1

  source functions.sh
}

# Fetches the SHA1 fingerprint using the PEM file.
function fetchSha1Fingerprint() {
  FINGERPRINT=$($OPENSSL_CMD x509 -noout -fingerprint -in "$CERTIFICATE_PEM_FILENAME" | sha1sum | awk -F' ' '{print $1}')

  # Returns to terraform the fingerprint.
  echo "{\"fingerprint\": \"$FINGERPRINT\"}"
}

# Main function.
function main() {
  prepareToExecute
  fetchSha1Fingerprint
}

main