#!/bin/bash

# Required binaries.
export KUBECTL_CMD=$(which kubectl)

# Environment variables.
export KUBECONFIG=$CONFIGURATION_FILENAME

# Fetches the LKE cluster loadbalancer hostname.
HOSTNAME=$($KUBECTL_CMD get service traefik -n hydrolix -o json | jq -r '.status.loadBalancer.ingress[0].hostname')

# Returns to terraform the hostname.
echo "{\"hostname\": \"$HOSTNAME\"}"