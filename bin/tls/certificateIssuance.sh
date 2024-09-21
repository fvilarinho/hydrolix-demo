#!/bin/bash

$CERTBOT_CMD certonly \
             --dns-linode \
             --dns-linode-credentials "$CERTIFICATE_ISSUANCE_CREDENTIALS_FILENAME" \
             --dns-linode-propagation-seconds 300 \
             --domain "$DOMAIN" \
             --email "$EMAIL"