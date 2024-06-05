#!/bin/bash

# Checks if the resources exist otherwise it will create them.
function checkOrCreateResources() {
  # Fetches the access token.
  echo "Authenticating in Hydrolix platform..."

  accessToken=$($CURL_CMD -s \
                          -H "Accept: application/json" \
                          -H "Content-Type: application/json" \
                          "$url/config/v1/login" \
                          -d "{\"username\": \"$username\", \"password\": \"$password\"}" \
                          --insecure | $JQ_CMD -r '.auth_token.access_token')

  if [ -z "$accessToken" ] || [ "$accessToken" == "null" ]; then
    echo "Please check the credentials in Hydrolix platform before continue!"

    exit 1
  fi

  # Fetches the organization.
  echo "Fetching organization..."

  org=$($CURL_CMD -s \
                  -H "Accept: application/json" \
                  -H "Content-Type: application/json" \
                  -H "Authorization: Bearer $accessToken" \
                  "$url/config/v1/orgs" \
                  --insecure | $JQ_CMD -r '.results[0].uuid')

  # Checks if the organization exists.
  if [ -z "$org" ]; then
    echo "Please check your Hydrolix installation! The organization wasn't found!"

    exit 1
  fi

  # Fetches the project.
  echo "Fetching project..."

  projectName=$($JQ_CMD -r ".name" "$projectStructureFilename")
  project=$($CURL_CMD -s \
                      -H "Accept: application/json" \
                      -H "Content-Type: application/json" \
                      -H "Authorization: Bearer $accessToken" \
                      "$url/config/v1/orgs/$org/projects" \
                      --insecure | $JQ_CMD -r ".[]|select(.name == \"$projectName\")|.uuid")

  # Checks if the project exists.
  if [ -z "$project" ]; then
    # Creates the project based on the project structure file.
    echo "Creating project..."

    project=$($CURL_CMD -s \
                        -X POST \
                        -H "Accept: application/json" \
                        -H "Content-Type: application/json" \
                        -H "Authorization: Bearer $accessToken" \
                        "$url/config/v1/orgs/$org/projects" \
                        -d @"$projectStructureFilename" \
                        --insecure | $JQ_CMD -r '.uuid')

  fi

  # Fetches the table.
  echo "Fetching table..."

  tableName=$($JQ_CMD -r ".name" "$tableStructureFilename")
  table=$($CURL_CMD -s \
                      -H "Accept: application/json" \
                      -H "Content-Type: application/json" \
                      -H "Authorization: Bearer $accessToken" \
                      "$url/config/v1/orgs/$org/projects/$project/tables" \
                      --insecure | $JQ_CMD -r ".[]|select(.name == \"$tableName\")|.uuid")

  # Checks if the table exists.
  if [ -z "$table" ]; then
    # Creates the table based on the table structure file.
    echo "Creating table..."

    table=$($CURL_CMD -s \
                        -X POST \
                        -H "Accept: application/json" \
                        -H "Content-Type: application/json" \
                        -H "Authorization: Bearer $accessToken" \
                        "$url/config/v1/orgs/$org/projects/$project/tables" \
                        -d @"$tableStructureFilename" \
                        --insecure | $JQ_CMD -r '.uuid')
  fi

  # Fetches the transform.
  echo "Fetching transform..."

  transformName=$($JQ_CMD -r ".name" "$transformStructureFilename")
  transform=$($CURL_CMD -s \
                        -H "Accept: application/json" \
                        -H "Content-Type: application/json" \
                        -H "Authorization: Bearer $accessToken" \
                        "$url/config/v1/orgs/$org/projects/$project/tables/$table/transforms" \
                        --insecure | $JQ_CMD -r ".[]|select(.name == \"$transformName\")|.uuid")

  # Checks if the transform exists.
  if [ -z "$transform" ]; then
    # Creates the transform based on the transform structure file.
    echo "Creating transform..."

    transform=$($CURL_CMD -s \
                          -X POST \
                          -H "Accept: application/json" \
                          -H "Content-Type: application/json" \
                          -H "Authorization: Bearer $accessToken" \
                          "$url/config/v1/orgs/$org/projects/$project/tables/$table/transforms" \
                          -d @"$transformStructureFilename" \
                          --insecure | $JQ_CMD -r '.uuid')
  fi

  echo "Hydrolix resources were validated successfully!"
}

checkOrCreateResources