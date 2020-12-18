#!/usr/bin/env bash

# Setup Services
echo "Setting up Services..."
#./add-idam-clients.sh

# Setup Roles
#echo ""
#echo "Setting up Roles..."
#./utils/idam-add-role.sh "ccd-import"
#./utils/idam-add-role.sh "caseworker"
#./utils/idam-add-role.sh "caseworker-iac"
#./utils/idam-add-role.sh "cwd-admin"
#./utils/idam-add-role.sh "cwd-user"
#./utils/idam-add-role.sh "caseworker-iac-bulkscan"

### Setup Users
echo ""
echo "Setting up Users..."
./create-user.sh "ccd.docker.default@hmcts.net" "Default" "CCD_Docker" "Pa55word11" "ccd-import" "[{ \"code\": \"ccd-import\"}]"
./create-user.sh "am.docker.default@hmcts.net" "Default" "AM_Docker" "Pa55word11" "ccd-import" "[{ \"code\": \"ccd-import\"}]"
./create-user.sh "ras.admin@hmcts.net" "testfirstname" "testsurname" "Pa55word11" "test" "[{ \"code\": \"caseworker\"}]"
./create-user.sh "orm.admin@hmcts.net" "testfirstname" "testsurname" "Pa55word11" "test" "[{ \"code\": \"caseworker\"}]"
./create-user.sh "TEST_AM_USER1_BEFTA@test.local" "testfirstname" "testsurname" "Pa55word11" "test" "[{ \"code\": \"caseworker\"}]"
./create-user.sh "TEST_AM_USER2_BEFTA@test.local" "testfirstname" "testsurname" "Pa55word11" "test" "[{ \"code\": \"caseworker\"}, { \"code\": \"caseworker-iac\"}]"
./create-user.sh "TEST_AM_USER3_BEFTA@test.local" "testfirstname" "testsurname" "Pa55word11" "test" "[{ \"code\": \"caseworker\"}, { \"code\": \"caseworker-iac\"}]"
./create-user.sh "TEST_AM_USER6_BEFTA@test.local" "testfirstname" "testsurname" "Pa55word11" "test" "[{ \"code\": \"caseworker\"}, { \"code\": \"caseworker-iac\"}]"
./create-user.sh "TEST_AM_USER4_BEFTA@test.local" "testfirstname" "testsurname" "Pa55word11" "test" "[{ \"code\": \"caseworker\"}, { \"code\": \"cwd-admin\"}]"
./create-user.sh "TEST_AM_USER5_BEFTA@test.local" "testfirstname" "testsurname" "Pa55word11" "test" "[{ \"code\": \"caseworker\"}, { \"code\": \"cwd-user\"}, { \"code\": \"caseworker-iac-bulkscan\"}]"