#!/bin/bash

# Fetches Hydrolix origin hostname.
function fetchOrigin() {
  export KUBECONFIG="$1"
  export NAMESPACE="$2"

  HOSTNAME=

  # Waits until the LKE cluster load balancer is ready.
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