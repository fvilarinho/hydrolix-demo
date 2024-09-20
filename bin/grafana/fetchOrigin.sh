#!/bin/bash

export KUBECONFIG="$1"
export NAMESPACE="$2"

$KUBECTL_CMD get service -n "$NAMESPACE" -o json | $JQ_CMD -r '.items[].status.loadBalancer.ingress[]'