#!/usr/bin/env bash

set -eu

dir=$(dirname ${0})

#${dir}/utils/idam-create-service.sh "ccd_gateway" "ccd_gateway" "ccd_gateway_secret" "http://localhost:3451/oauth2redirect" "false" "openid profile roles authorities search-user"
${dir}/utils/idam-create-service.sh "am_docker" "am_docker" "am_docker_secret" "http://localhost:4096/oauth2redirect" "false" "openid profile roles authorities search-user"