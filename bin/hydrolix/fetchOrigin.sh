#!/bin/bash

# Check the dependencies of this script.
function checkDependencies() {
  KUBECONFIG="$1"

  if [ -z "$KUBECONFIG" ]; then
    echo "The kubeconfig filename is not defined! Please define it first to continue!"

    exit 1
  fi

  NAMESPACE="$2"

  if [ -z "$NAMESPACE" ]; then
    echo "The namespace is not defined! Please define it first to continue!"

    exit 1
  fi
}

# Fetches the origin hostname.
function fetchOrigin() {
  checkDependencies "$1" "$2"

  HOSTNAME=

  # Waits until LKE cluster load balancer is ready.
  while true; do
    # Fetches the LKE cluster load balancer hostname.
    HOSTNAME=$($KUBECTL_CMD get service traefik \
                            -n "$NAMESPACE" \
                            -o json | $JQ_CMD -r '.status.loadBalancer.ingress[].hostname')

    if [ -n "$HOSTNAME" ]; then
      break
    fi

    sleep 5
  done

  # Returns the fetched hostname.
  echo "{\"hostname\": \"$HOSTNAME\"}"
}

fetchOrigin "$1" "$2"