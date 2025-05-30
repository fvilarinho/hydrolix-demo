#!/bin/bash

# Checks the dependencies of this script.
function checkDependencies() {
  if [ -z "$TERRAFORM_CMD" ]; then
    echo "terraform is not installed! Please install it first to continue!"

    exit 1
  fi

  if [ -z "$KUBECTL_CMD" ]; then
    echo "kubectl is not installed! Please install it first to continue!"

    exit 1
  fi

  if [ -z "$CURL_CMD" ]; then
    echo "curl is not installed! Please install it first to continue!"

    exit 1
  fi

  if [ -z "$JQ_CMD" ]; then
    echo "jq is not installed! Please install it first to continue!"

    exit 1
  fi

  if [ -z "$CERTBOT_CMD" ]; then
    echo "certbot is not installed! Please install it first to continue!"

    exit 1
  fi
}

# Clean-up.
function cleanUp() {
  rm -f "$TERRAFORM_PLAN_FILENAME"
}

# Prepares the environment to execute this script.
function prepareToExecute() {
  source functions.sh

  showBanner

  cd iac || exit 1
}

# Starts the provisioning of the environment based on the IaC files.
function deploy() {
  $TERRAFORM_CMD init \
                 -upgrade \
                 -migrate-state || exit 1

  $TERRAFORM_CMD plan \
                 -out "$TERRAFORM_PLAN_FILENAME" || exit 1

  $TERRAFORM_CMD apply \
                 -auto-approve \
                 "$TERRAFORM_PLAN_FILENAME"
}

# Main function.
function main() {
  prepareToExecute
  checkDependencies
  deploy
  cleanUp
}

main