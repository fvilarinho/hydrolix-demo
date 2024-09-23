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

  if [ -z "$PROJECT_STRUCTURE_FILENAME" ] || [ ! -f "$PROJECT_STRUCTURE_FILENAME" ]; then
    echo "The project structure filename is not defined! Please define it first to continue!"

    exit 1
  fi

  if [ -z "$TABLE_STRUCTURE_FILENAME" ] || [ ! -f "$TABLE_STRUCTURE_FILENAME" ]; then
    echo "The table structure filename is not defined! Please define it first to continue!"

    exit 1
  fi

  if [ -z "$TRANSFORM_STRUCTURE_FILENAME" ] || [ ! -f "$TRANSFORM_STRUCTURE_FILENAME" ]; then
    echo "The transform structure filename is not defined! Please define it first to continue!"

    exit 1
  fi
}

# Checks if the required resources (project, table & transform) exist otherwise it will create them.
function applyResources() {
  # Fetches the access token.
  echo "Authenticating in the platform..."

  ACCESS_TOKEN=$($CURL_CMD -s \
                          -H "Accept: application/json" \
                          -H "Content-Type: application/json" \
                          "$URL/config/v1/login" \
                          -d "{\"username\": \"$USERNAME\", \"password\": \"$PASSWORD\"}" | $JQ_CMD -r '.auth_token.access_token')

  if [ -z "$ACCESS_TOKEN" ] || [ "$ACCESS_TOKEN" == "null" ]; then
    echo "Please check the credentials in the platform before continue!"

    exit 1
  fi

  # Fetches the organization.
  echo "Fetching the organization..."

  ORG=$($CURL_CMD -s \
                  -H "Accept: application/json" \
                  -H "Content-Type: application/json" \
                  -H "Authorization: Bearer $ACCESS_TOKEN" \
                  "$URL/config/v1/orgs" | $JQ_CMD -r '.results[0].uuid')

  # Checks if the organization exists.
  if [ -z "$ORG" ]; then
    echo "Please check your installation! The organization wasn't found!"

    exit 1
  fi

  # Fetches the project.
  echo "Fetching the project..."

  PROJECT_NAME=$($JQ_CMD -r ".name" "$PROJECT_STRUCTURE_FILENAME")
  PROJECT=$($CURL_CMD -s \
                      -H "Accept: application/json" \
                      -H "Content-Type: application/json" \
                      -H "Authorization: Bearer $ACCESS_TOKEN" \
                      "$URL/config/v1/orgs/$ORG/projects" | $JQ_CMD -r ".[]|select(.name == \"$PROJECT_NAME\")|.uuid")

  # Checks if the project exists.
  if [ -z "$PROJECT" ]; then
    # Creates the project based on the project structure file.
    echo "Creating the project..."

    PROJECT=$($CURL_CMD -s \
                        -X POST \
                        -H "Accept: application/json" \
                        -H "Content-Type: application/json" \
                        -H "Authorization: Bearer $ACCESS_TOKEN" \
                        "$URL/config/v1/orgs/$ORG/projects" \
                        -d @"$PROJECT_STRUCTURE_FILENAME" | $JQ_CMD -r '.uuid')

  fi

  # Fetches the table.
  echo "Fetching the table..."

  TABLE_NAME=$($JQ_CMD -r ".name" "$TABLE_STRUCTURE_FILENAME")
  TABLE=$($CURL_CMD -s \
                      -H "Accept: application/json" \
                      -H "Content-Type: application/json" \
                      -H "Authorization: Bearer $ACCESS_TOKEN" \
                      "$URL/config/v1/orgs/$ORG/projects/$PROJECT/tables" | $JQ_CMD -r ".[]|select(.name == \"$TABLE_NAME\")|.uuid")

  # Checks if the table exists.
  if [ -z "$TABLE" ]; then
    # Creates the table based on the table structure file.
    echo "Creating the table..."

    TABLE=$($CURL_CMD -s \
                        -X POST \
                        -H "Accept: application/json" \
                        -H "Content-Type: application/json" \
                        -H "Authorization: Bearer $ACCESS_TOKEN" \
                        "$URL/config/v1/orgs/$ORG/projects/$PROJECT/tables" \
                        -d @"$TABLE_STRUCTURE_FILENAME" | $JQ_CMD -r '.uuid')
  fi

  # Fetches the transform.
  echo "Fetching the transformation..."

  TRANSFORM_NAME=$($JQ_CMD -r ".name" "$TRANSFORM_STRUCTURE_FILENAME")
  TRANSFORM=$($CURL_CMD -s \
                        -H "Accept: application/json" \
                        -H "Content-Type: application/json" \
                        -H "Authorization: Bearer $ACCESS_TOKEN" \
                        "$URL/config/v1/orgs/$ORG/projects/$PROJECT/tables/$TABLE/transforms" | $JQ_CMD -r ".[]|select(.name == \"$TRANSFORM_NAME\")|.uuid")

  # Checks if the transform exists.
  if [ -z "$TRANSFORM" ]; then
    # Creates the transform based on the transform structure file.
    echo "Creating the transformation..."

    TRANSFORM=$($CURL_CMD -s \
                          -X POST \
                          -H "Accept: application/json" \
                          -H "Content-Type: application/json" \
                          -H "Authorization: Bearer $ACCESS_TOKEN" \
                          "$URL/config/v1/orgs/$ORG/projects/$PROJECT/tables/$TABLE/transforms" \
                          -d @"$TRANSFORM_STRUCTURE_FILENAME" | $JQ_CMD -r '.uuid')
  fi

  echo "The resources were validated successfully!"
}

# Main function.
function main() {
  checkDependencies
  applyResources
}

main