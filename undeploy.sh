#!/bin/bash

# Checks the dependencies to run this script.
function checkDependencies() {
  if [ -z "$TERRAFORM_CMD" ]; then
    echo "terraform is not installed! Please install it first to continue!"

    exit 1
  fi

  if [ -z "$KUBECTL_CMD" ]; then
    echo "kubectl is not installed! Please install it first to continue!"

    exit 1
  fi

  if [ -z "$OPENSSL_CMD" ]; then
    echo "openssl is not installed! Please install it first to continue!"

    exit 1
  fi
}

# Prepares the environment to execute this script.
function prepareToExecute() {
  source functions.sh

  showBanner

  cd iac || exit 1
}

# Destroys the provisioned environment.
function undeploy() {
  $TERRAFORM_CMD init \
                 -upgrade \
                 -migrate-state

  $TERRAFORM_CMD destroy \
                 -auto-approve
}

# Main function.
function main() {
  prepareToExecute
  checkDependencies
  undeploy
}

main