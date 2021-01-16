# AM Docker :whale:

- [Prerequisites](#prerequisites)
- [Quick start](#quick-start)
- [Setting up env variable](#setting-up-environment-variables)
- [Using AM](#using-am)
- [Troubleshooting](#troubleshooting)
- [Variables](#variables)
- [Remarks](#remarks)
- [License](#license)

## Prerequisites

- [Docker](https://www.docker.com) - Memory and CPU allocations may need to be increased for successful execution of am applications altogether.
 Minimum RAM required 6GB and if ccd-data-store.yml enabled then minimum 8GB *

- [Azure CLI](https://docs.microsoft.com/en-us/cli/azure/install-azure-cli?view=azure-cli-latest) - minimum version 2.0.57 
- [jq Json Processor] (https://stedolan.github.io/jq)

*The following documentation assumes that the current directory is `am-docker`.*

## Quick start

Checkout `am-docker` project:

```bash
git clone git@github.com:hmcts/am-docker.git
```

Login to the Azure Container registry:

```bash
./am login
```
Note:
if you experience any error with the above command, try `az login` first

For [Azure Authentication for pulling latest docker images](#azure-authentication-for-pulling-latest-docker-images)

Pulling latest Docker images:

```bash
./am compose pull
```

Running initialisation steps:

Note:
required only on the first run. Once executed, it doesn't need to be executed again

```bash
./am init
```

Creating and starting the containers:

```bash
./am compose up -d
```

Usage and commands available:

```bash
./am
```

## Setting up environment variables
Environment variables for AM applications can be setup by executing the following script.

Windows : `./bin/set-environment-variables.sh`

Mac : `source ./bin/set-environment-variables.sh`

Note: some users of zsh 'Oh My Zsh' experienced issues. Try switching to bash for this step

To persist the environment variables in Mac, copy the contents of `env_variables_all.txt` file into ~/.bash_profile.
A prefix 'export' will be required for each of environment variable.

## Using AM

There are following steps required to correctly configure SIDAM and AM apps before it can be used:

---
**NOTE**

The `idam-api` container can be slow to start - both the `role-assignment-service` and `ccd-data-store-api` containers will
try to connect to the `idam-api` container when they start.

If `idam-api` is not up and running and accepting connections
you may see errors in the `role-assignment-service` and `ccd-data-store-api` containers, such as

```bash
Caused by: org.springframework.web.client.ResourceAccessException: 
    I/O error on GET request for "http://idam-api:5000/o/.well-known/openid-configuration": Connection refused (Connection refused);
        nested exception is java.net.ConnectException: Connection refused (Connection refused)
```

If you the containers fail to start with these error, ensure `idam-api` is running using

 ```bash
curl http://localhost:5000/health
 ```

ensuring the response is 

```bash
{"status":"UP"}
```

Then restart the `definition-store-api` & `data-store-api` containers

```bash
./ccd compose restart ccd-definition-store-api ccd-data-store-api
```
---

However, some more steps are required to correctly configure SIDAM and AM before it can be used:

---
**NOTE**

All scripts require the following environment variables to be set

```bash
IDAM_ADMIN_USER
IDAM_ADMIN_PASSWORD
```

with the corresponding values from the confluence page at https://tools.hmcts.net/confluence/x/eQP3P

*********
At this point most users can run the single script 

```bash
./bin/setup.sh
```

to get their IDAM environment ready and then move on to the [Ready for take-off](###Ready-for-take-off) section.


### 4 Ready for take-off 🛫

you can now check the role-assignment-service health is up: [http://localhost:4096](http://localhost:4096)

To invoke any role-assignment-service API using postman, it requires service and user token which can be retrieved as follows:

#### 4.1 Create Service Token
A service token can be created using the following command:

```bash
./bin/idam-service-token.sh <microservice>
```

Parameters:
- `microservice`: Name of the microservice which is registered at `service-auth-provider-api`. 
Default to `ccd_gw`.

For example:

```bash
./bin/idam-service-token.sh am_role_assignment_service
```

#### 4.2 Create User Token
A user token can be created using the following command:

```bash
./bin/openid-connect-idam-user-token.sh.sh <user-email> <password>
```

Parameters:
- `email`: Email address used for logging in. Default to `am.docker.default@hmcts.net`.
- `password`: Optional. Password for logging in. Defaults to `Pa55word11`. Weak passwords that do not match the password criteria by SIDAM will cause user creation to fail, and such failure may not be expressly communicated to the user. 

For example:

```bash
./bin/idam-service-token.sh am_role_assignment_service
```

#### 4.3 Get IDAM User Id
For some API it is important to know the user-id of the invoking IDAM user. 
This can be retrieved using the following command:

```bash
./bin/idam-get-user-info.sh.sh <user-email> <password>
```

Parameters:
- `email`: Email address used for logging in. Default to `am.docker.default@hmcts.net`.
- `password`: Optional. Password for logging in. Defaults to `Pa55word11`. Weak passwords that do not match the password criteria by SIDAM will cause user creation to fail, and such failure may not be expressly communicated to the user. 

For example:

```bash
./bin/idam-get-user-info.sh TEST_AM_USER1_BEFTA@test.local Pa55word11
```

## Compose projects

By default, `am-docker` runs the most commonly used backend project required:

* Back-end:
  * **sidam-api**: Strategic identity and access control
  * **service-auth-provider-api**: Service-to-service security layer
  * **am-role-assignment-service**: AM Role assignment service

Optional compose files will allow other projects to be enabled on demand using the `enable` and `disable` commands.


### Compose

```bash
./am compose [<docker-compose command> [options]]
```

The compose command acts as a wrapper around `docker-compose` and accept all commands and options supported by it.

:information_source: *For the complete documentation of Docker Compose CLI, see [Compose command-line reference](https://docs.docker.com/compose/reference/).*

Here are some useful commands:

#### Up

```bash
./am compose up [-d]
```

This command:
1. Create missing containers
2. Recreate outdated containers (= apply configuration changes)
3. Start all enabled containers

The `-d` (detached) option start the containers in the background.

#### Down

```bash
./am compose down [-v] [project]
```

This stops and destroys all composed containers.

If provided, the `-v` option will also clean the volumes.

Destroyed containers cannot be restarted. New containers will need to be built using the `up` command.

#### Ps

```bash
./am compose ps [<project>]
```

Gives the current state of all or specified composed projects.

#### Logs

```bash
./am compose logs [-f] [<project>]
```

Displays the logs for all or specified composed projects.

The `-f` (follow) option allows to follow the tail of the logs.

#### Start/stop

```bash
./am compose start [<project>]
./am compose stop [<project>]
```

Start or stop all or specified composed containers. Stopped containers can be restarted with the `start` command.

:warning: Please note: Re-starting a project with stop/start does **not** apply configuration changes. Instead, the `up` command should be used to that end.

#### Pull

```bash
./am compose pull [project]
```

Fetch the latest version of an image from its source. For the new version to be used, the associated container must be re-created using the `up` command.

### Configuration

#### OAuth 2

OAuth 2 clients must be explicitly declared in service `sidam-api` with their ID and secret.

A client is defined as an environment variable complying to the pattern:

```yml
environment:
  IDAM_API_OAUTH2_CLIENT_CLIENT_SECRETS_<CLIENT_ID>: <CLIENT_SECRET>
```

The `CLIENT_SECRET` must then also be provided to the container used by the client service.

:information_source: *To prevent duplication, the client secret should be defined in the `.env` file and then used in the compose files using string interpolation `"${<VARIABLE_NAME>}"`.*

#### Service-to-Service

Micro-services names and secret keys must be registered as part of `service-auth-provider-api` configuration by adding environment variables like:

```yml
environment:
  MICROSERVICE_KEYS_<SERVICE_NAME>: <SERVICE_SECRET>
```

The `SERVICE_SECRET` must then also be provided to the container running the micro-service.

:information_source: *To prevent duplication, the client secret should be defined in the `.env` file and then used in the compose files using string interpolation `"${<VARIABLE_NAME>}"`.*

## App Containers

#### am-role-assignment-service

It stores all the local role and validations rules on the basis of which multiple role assignments are granted/revoked.

#### am-org-role-mapping-service
Development-in-progress:
It fetches all the updated user profiles from reference data and map them to appropriate role assignments.

### Azure Authentication for pulling latest docker images

```bash
ERROR: Get <docker_image_url>: unauthorized: authentication required
```

If you see this above authentication issue while pulling images, please follow below commands,

Install Azure-CLI locally,

```bash
brew update && brew install azure-cli
```

and to update a Azure-CLI locally,

```bash
brew update azure-cli
```

then,
login to MS Azure,

```bash
az login
```
and finally, Login to the Azure Container registry:

```bash
./am login
```

On windows platform, we are installing the [Azure CLI](https://docs.microsoft.com/en-us/cli/azure/install-azure-cli?view=azure-cli-latest) using executable .msi file.
If "az login" command throws an error like "Access Denied", please follow these steps.
We will need to install the az cli using Python PIP.
1. If Microsoft Azure CLI is already installed, uninstall it from control panel.
2. Setup the Python(version 2.x/3.x) on windows machine. PIP is bundled with Python.
3. Execute the command "pip install azure-cli" using command line. It takes about 20 minutes to install the azure cli.
4. Verify the installation using the command az --version.

## Troubleshooting

am-network could not be found error:

- if you get "am: ERROR: Network am-network declared as external, but could not be found. Please create the network manually using docker network create am-network"
    > ./am init

## Variables
Here are the important variables exposed in the compose files:

| Variable | Description |
| -------- | ----------- |
| AM_DB | Access Management database name |
| AM_DB_USERNAME | Access Management database username |
| AM_DB_PASSWORD | Access Management database password |


## LICENSE

This project is licensed under the MIT License - see the [LICENSE](LICENSE.md) file for details.
# Learning-AI-ANN
