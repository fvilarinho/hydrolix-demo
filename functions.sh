#!/bin/bash

# Shows the label.
function showLabel() {
  if [[ "$0" == *"undeploy.sh"* ]]; then
    echo "** Undeploy **"
  elif [[ "$0" == *"deploy.sh"* ]]; then
    echo "** Deploy **"
  fi

  echo
}

# Shows the banner.
function showBanner() {
  if [ -f "banner.txt" ]; then
    cat banner.txt
  fi

  showLabel
}

# Prepares the environment to execute the commands of this script.
function prepareToExecute() {
  # Required binaries.
  export TERRAFORM_CMD=$(which terraform)
  export KUBECTL_CMD=$(which kubectl)
  export HELM_CMD=$(which helm)
  export JQ_CMD=$(which jq)
  export CURL_CMD=$(which curl)
  export OPENSSL_CMD=$(which openssl)

  # Environment variables.
  export TERRAFORM_PLAN_FILENAME=/tmp/hydrolix-demo.plan
}

prepareToExecute