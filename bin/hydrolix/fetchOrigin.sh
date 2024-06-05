#!/bin/bash

# Fetches Hydrolix origin hostname.
function fetchOrigin() {
  export KUBECONFIG="$1"
  export NAMESPACE="$2"

  # Fetches the LKE cluster loadbalancer hostname.
  HOSTNAME=$($KUBECTL_CMD get service traefik \
                          -n "$NAMESPACE" \
                          -o json | $JQ_CMD -r '.status.loadBalancer.ingress[0].hostname')

  # Returns to terraform the hostname.
  echo "{\"hostname\": \"$HOSTNAME\"}"
}

fetchOrigin "$1" "$2"