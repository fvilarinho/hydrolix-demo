#!/bin/bash

# Checks the dependencies of this script.
function checkDependencies() {
  if [ -z "$URL" ]; then
    echo "The url is not defined! Please define it first to continue!"

    exit 1
  fi

  if [ -z "$USERNAME" ]; then
    echo "The credentials is not defined! Please define it first to continue!"

    exit 1
  fi

  if [ -z "$PASSWORD" ]; then
    echo "The credentials is not defined! Please define it first to continue!"

    exit 1
  fi

  if [ -z "$DATASOURCE_FILENAME" ]; then
    echo "The datasource filename is not defined! Please define it first to continue!"

    exit 1
  fi
}

# Prepares the environment to execute this script.
function prepareToExecute() {
  export DATASOURCE_NAME=$($JQ_CMD -r '.name' "$DATASOURCE_FILENAME")
}

# Checks if the platform is ready.
function checkAvailability() {
  RESULT=$($CURL_CMD -o /dev/null -s -w "%{http_code}\n" "$URL"/login)

  # Only accepts 200 code as healthy status.
  if [ "$RESULT" != 200 ]; then
    echo "The platform is not ready yet! Please try again later!"

    exit 1
  fi
}

# Checks if the datasource exists.
function checkIfDatasourceExists() {
  echo "Check of the datasource $DATASOURCE_NAME exists..."

  RESULT=$($CURL_CMD "$URL"/api/datasources/name/"$DATASOURCE_NAME" \
                     -s \
                     -u "$USERNAME:$PASSWORD" \
                     -H "Content-Type: application/json" | $JQ_CMD -r '.id')

  # Returns the ID of the datasource if it exists.
  if [ "$RESULT" != "null" ]; then
    export DATASOURCE_ID=$RESULT
  else
    export DATASOURCE_ID=
  fi
}

# Applies the datasources.
function applyDatasources() {
  checkAvailability
  checkIfDatasourceExists

  if [ -z "$DATASOURCE_ID" ]; then
    echo "Creating the datasource $DATASOURCE_NAME..."

    $CURL_CMD -X POST "$URL"/api/datasources \
              -s \
              -u "$USERNAME:$PASSWORD" \
              -H "Content-Type: application/json" \
              -d @"$DATASOURCE_FILENAME" > /dev/null
  else
    echo "Updating the datasource $DATASOURCE_NAME..."

    $CURL_CMD -X PUT "$URL"/api/datasources/"$DATASOURCE_ID" \
              -s \
              -u "$USERNAME:$PASSWORD" \
              -H "Content-Type: application/json" \
              -d @"$DATASOURCE_FILENAME" > /dev/null
  fi

  echo "The resources were validated successfully!"
}

# Applies the resources
function applyResources() {
  applyDatasources
}

# Main function.
function main() {
  checkDependencies
  prepareToExecute
  applyResources
}

main