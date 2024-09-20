#!/bin/bash

export EMAAIL="$1"
export DOMAIN="$2"

certbot certonly \
        --manual \
        --manual-auth-hook 'echo "{\"domain\": \"$CERTBOT_DOMAIN\", \"token\": \"$CERTBOT_VALIDATION\"}"' \
        --preferred-challenges dns \
        --email "$EMAIL" \
        --domain "$DOMAIN"

