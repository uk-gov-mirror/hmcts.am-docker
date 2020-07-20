#!/bin/sh

IMPORTER_USERNAME=${1:-am.docker.default@hmcts.net}
IMPORTER_PASSWORD=${2:-Pa55word11}
IDAM_OPEN_ID_URI=http://localhost:5000/o/token
REDIRECT_URI="http://localhost:4096/oauth2redirect"
CLIENT_ID="am_docker"
CLIENT_SECRET="am_docker_secret"
GRANT_TYPE="password"
SCOPE_VARIABLES=openid%20profile%20roles%20authorities

Authorization=$(curl -H "Content-Type: application/x-www-form-urlencoded" -XPOST "${IDAM_OPEN_ID_URI}?client_id=${CLIENT_ID}&client_secret=${CLIENT_SECRET}&grant_type=${GRANT_TYPE}&scope=${SCOPE_VARIABLES}&username=${IMPORTER_USERNAME}&password=${IMPORTER_PASSWORD}" -d "" | jq -r .access_token)
# Get the user Info using the OIDC token
curl -H "Authorization: Bearer ${Authorization}"  -XGET 'http://localhost:5000/o/userinfo' | jq -r .uid
