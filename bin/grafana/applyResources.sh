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

  if [ -z "$DATASOURCE_FILENAME" ] || [ ! -f "$DATASOURCE_FILENAME" ]; then
    echo "The datasource filename is not defined! Please define it first to continue!"

    exit 1
  fi

  if [ -z "$DASHBOARD_FILENAME" ] || [ ! -f "$DASHBOARD_FILENAME" ]; then
    echo "The dashboard filename is not defined! Please define it first to continue!"

    exit 1
  fi
}

# Prepares the environment to execute this script.
function prepareToExecute() {
  export DATASOURCE_NAME=$($JQ_CMD -r '.name' "$DATASOURCE_FILENAME")
  export DASHBOARD_NAME=$($JQ_CMD -r '.dashboard.title' "$DASHBOARD_FILENAME")
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

# Checks if the dashboard exists.
function checkIfDashboardExists() {
  echo "Check of the dashboard '$DASHBOARD_NAME' exists..."

  RESULT=$($CURL_CMD "$URL"/api/search \
                     -s \
                     -u "$USERNAME:$PASSWORD" \
                     -H "Content-Type: application/json" | $JQ_CMD -r ".[] | select(.title == \"$DASHBOARD_NAME\") | .id")

  # Returns the ID of the datasource if it exists.
  if [ "$RESULT" != "null" ]; then
    export DASHBOARD_ID=$RESULT
  else
    export DASHBOARD_ID=
  fi
}

# Checks if the datasource exists.
function checkIfDatasourceExists() {
  echo "Check of the datasource '$DATASOURCE_NAME' exists..."

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

# Applies the datasource.
function applyDatasource() {
  checkIfDatasourceExists

  if [ -z "$DATASOURCE_ID" ]; then
    echo "Creating the datasource '$DATASOURCE_NAME'..."

    $CURL_CMD -X POST "$URL"/api/datasources \
              -s \
              -u "$USERNAME:$PASSWORD" \
              -H "Content-Type: application/json" \
              -d @"$DATASOURCE_FILENAME" > /dev/null
  else
    echo "Updating the datasource '$DATASOURCE_NAME'..."

    $CURL_CMD -X PUT "$URL"/api/datasources/"$DATASOURCE_ID" \
              -s \
              -u "$USERNAME:$PASSWORD" \
              -H "Content-Type: application/json" \
              -d @"$DATASOURCE_FILENAME" > /dev/null
  fi
}

# Applies the dashboard.
function applyDashboard() {
  checkIfDashboardExists

  if [ -z "$DASHBOARD_ID" ]; then
    echo "Creating the dashboard '$DASHBOARD_NAME'..."

    $CURL_CMD -X POST "$URL"/api/dashboards/db \
              -s \
              -u "$USERNAME:$PASSWORD" \
              -H "Content-Type: application/json" \
              -d @"$DASHBOARD_FILENAME" > /dev/null
  else
    echo "Updating the dashboard '$DASHBOARD_NAME'..."

    $CURL_CMD -X PUT "$URL"/api/dashboards/db \
              -s \
              -u "$USERNAME:$PASSWORD" \
              -H "Content-Type: application/json" \
              -d @"$DASHBOARD_FILENAME" > /dev/null
  fi
}

# Applies the resources
function applyResources() {
  checkAvailability
  applyDatasource
  applyDashboard

  echo "The resources were validated successfully!"
}

# Main function.
function main() {
  checkDependencies
  prepareToExecute
  applyResources
}

main