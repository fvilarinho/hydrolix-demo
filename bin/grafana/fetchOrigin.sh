#!/bin/bash

# Fetches Grafana origin hostname.
function fetchOrigin() {
  export KUBECONFIG="$1"
  export NAMESPACE="$2"

  HOSTNAME=

  while true; do
    # Fetches the LKE cluster loadbalancer hostname.
    HOSTNAME=$($KUBECTL_CMD get service ingress \
                            -n "$NAMESPACE" \
                            -o json | $JQ_CMD -r '.status.loadBalancer.ingress[].hostname')

    if [ -n "$HOSTNAME" ]; then
      break
    fi

    sleep 5
  done

  # Returns to terraform the hostname.
  echo "{\"hostname\": \"$HOSTNAME\"}"
}

fetchOrigin "$1" "$2"