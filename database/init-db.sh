#!/usr/bin/env bash

set -e

if [ -z "$ROLE_ASSIGNMENT_DB_USERNAME" ] || [ -z "$ROLE_ASSIGNMENT_DB_PASSWORD" ]; then
  echo "ERROR: Missing environment variable. Set value for both 'ROLE_ASSIGNMENT_DB_USERNAME' and 'ROLE_ASSIGNMENT_DB_PASSWORD'."
  exit 1
fi

# Create user
psql -v ON_ERROR_STOP=1 --username postgres --set USERNAME=$ROLE_ASSIGNMENT_DB_USERNAME --set PASSWORD=$ROLE_ASSIGNMENT_DB_PASSWORD <<-EOSQL
  CREATE USER :USERNAME WITH PASSWORD ':PASSWORD';
EOSQL

# Create database for each service
for service in role_assignment ccd_user_profile ccd_definition ccd_data; do
  echo "Database $service: Creating..."
psql -v ON_ERROR_STOP=1 --username postgres --set USERNAME=$ROLE_ASSIGNMENT_DB_USERNAME --set PASSWORD=$ROLE_ASSIGNMENT_DB_PASSWORD --set DATABASE=$service <<-EOSQL
  CREATE DATABASE :DATABASE
    WITH OWNER = :USERNAME
    ENCODING = 'UTF-8'
    CONNECTION LIMIT = -1;
EOSQL
  echo "Database $service: Created"
done