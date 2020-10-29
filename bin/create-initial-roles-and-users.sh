#!/bin/bash

##This script will create the user roles.

parent_path=$( cd "$(dirname "${BASH_SOURCE[0]}")" ; pwd -P )
cd "$parent_path"

#Case workers are being created in SIDAM
#The following users are needed for the Functional Test Automation
./idam-create-caseworker.sh am-import am.docker.default@hmcts.net Pa55word11 Default AM_Docker
./idam-create-caseworker.sh caseworker,am-import ras.admin@hmcts.net Pa55word11 testsurname testfirstname
./idam-create-caseworker.sh caseworker,am-import TEST_AM_USER1_BEFTA@test.local Pa55word11 testsurname testfirstname
./idam-create-caseworker.sh caseworker,am-import TEST_AM_USER2_BEFTA@test.local Pa55word11 testsurname testfirstname
./idam-create-caseworker.sh caseworker,am-import TEST_AM_USER3_BEFTA@test.local Pa55word11 testsurname testfirstname
