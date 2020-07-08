#!/bin/sh

IMPORTER_USERNAME=${1:-am.docker.default@hmcts.net}
IMPORTER_PASSWORD=${2:-Pa55word11}
IDAM_URI=${IDAM_STUB_LOCALHOST:-http://localhost:5000}
IDAM_OPEN_ID_URI=http://localhost:5000/o/token
REDIRECT_URI="http://localhost:4096/oauth2redirect"
CLIENT_ID="am_docker"
CLIENT_SECRET="am_docker_secret"

#code=$(curl ${CURL_OPTS} -u "${IMPORTER_USERNAME}:${IMPORTER_PASSWORD}" -XPOST "${IDAM_URI}/oauth2/authorize?redirect_uri=${REDIRECT_URI}&response_type=code&client_id=${CLIENT_ID}" -d "" | jq -r .code)
#echo "Code is : ""$code"
#The code expires upon usage
#curl ${CURL_OPTS} -H "Content-Type: application/x-www-form-urlencoded" -u "${CLIENT_ID}:${CLIENT_SECRET}" -XPOST "${IDAM_URI}/oauth2/token?code="${code}"&redirect_uri=${REDIRECT_URI}&grant_type=authorization_code" -d "" | jq -r .access_token
curl ${CURL_OPTS} -H "Content-Type: application/x-www-form-urlencoded" -XPOST "http://localhost:5000/o/token?client_id=am_docker&client_secret=am_docker_secret&grant_type=password&scope=openid%20profile%20roles%20authorities%20email&username=am.docker.default@hmcts.net&password=Pa55word11" -d "" | jq -r .access_token
