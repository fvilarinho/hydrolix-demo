#!/bin/bash

# Prepares the environment to execute this script.
function prepareToExecute() {
  cd ../../ || exit 1

  source functions.sh
}

# Fetches Hydrolix origin.
function fetchOrigin() {
  # Fetches the LKE cluster loadbalancer hostname.
  HOSTNAME=$($KUBECTL_CMD get service traefik -n "$NAMESPACE" -o json | jq -r '.status.loadBalancer.ingress[0].hostname')

  # Returns to terraform the hostname.
  echo "{\"hostname\": \"$HOSTNAME\"}"
}

# Main function.
function main() {
  prepareToExecute
  fetchOrigin
}

main