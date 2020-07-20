# AM Docker :whale:

- [Prerequisites](#prerequisites)
- [Quick start](#quick-start)
- [Using AM](#using-am)
- [Idam Stub](#idam-stub)
- [Compose branches](#compose-branches)
- [Compose projects](#compose-projects)
- [Under the hood](#under-the-hood-speedboat)
- [Containers](#containers)
- [Local development](#local-development)
- [Troubleshooting](#troubleshooting)
- [Variables](#variables)
- [Remarks](#remarks)
- [License](#license)

## Prerequisites

- [Docker](https://www.docker.com)

*Memory and CPU allocations may need to be increased for successful execution of am applications altogether. (On Preferences / Advanced)*

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

There are 6 more steps required to correctly configure SIDAM and AM before it can be used:

### 1. Configure Oauth2 Client of AM docker on SIDAM

An oauth2 client should be configured for am-docker application, on SIDAM Web Admin.
You need to login to the SIDAM Web Admin with the URL and logic credentials here: 

http://localhost:8082/login
For more details refer : https://tools.hmcts.net/confluence/x/eQP3P

Navigate to Home > Manage Services > Add a new Service

On the **Add Service** screen the following fields are required:
```
label : am_docker
description : am_docker
client_id : am_docker
client_secret : am_docker_secret
scope : openid profile roles authorities email manage-user
new redirect_uri (click 'Add URI' before saving) : http://localhost:4096/oauth2redirect
```
### 2. Create Idam roles
After defining the above client/service, the following roles must be defined under this client/service (Home > Manage Roles > select your service > Role Label)
(some of these roles are used in the automated functional test):

    * am-import
    * caseworker

Don't worry about the *Assignable roles* section when adding roles

Once the roles are defined under the client/service, go to the service configuration for the service you created in Step 1 (Home > Manage Services > select your service) and select `am-import` role radio option under **Private Beta Role** section
 
**Any business-related roles like `caseworker`,`caseworker-<jurisdiction>` etc to be used in AM later must also be defined under the client configuration at this stage.**

### 3. Create users and roles

#### 3.1 Automated creation

A script is provided that sets up some initial users and roles for running functional tests. Execute the following:

```bash
./bin/create-initial-roles-and-users.sh
```

#### 3.2 Manual creation

##### 3.2.1 Create a Default User with "am-import" Role

A user with import role should be created using the following command:

```bash
./bin/idam-create-caseworker.sh am-import am.docker.default@hmcts.net Pa55word11 Default AM_Docker
```

This call will create a user in SIDAM with am-import role. This user will be used to acquire a user token with "am-import" role.


##### 3.2.3 Add Initial Case Worker Users

A caseworker user can be created in IDAM using the following command:

```bash
./bin/idam-create-caseworker.sh <roles> <email> [password] [surname] [forename]
```

Parameters:
- `roles`: a comma-separated list of roles. Roles must be existing IDAM roles for the am domain. Every caseworker requires at least it's coarse-grained jurisdiction role (`caseworker-<jurisdiction>`).
- `email`: Email address used for logging in.
- `password`: Optional. Password for logging in. Defaults to `Pa55word11`. Weak passwords that do not match the password criteria by SIDAM will cause use creation to fail, and such failure may not be expressly communicated to the user. 

For example:

```bash
./bin/idam-create-caseworker.sh caseworker-probate,caseworker-probate-solicitor probate@hmcts.net
```

## Compose projects

By default, `am-docker` runs the most commonly used backend project required:

* Back-end:
  * **sidam-api**: Strategic identity and access control
  * **service-auth-provider-api**: Service-to-service security layer
  * **am-role-assignment-service**: AM Role assignment service

Optional compose files will allow other projects to be enabled on demand using the `enable` and `disable` commands.

## Under the hood :speedboat:

### Set

#### Non-`master` branches

When switching to a branch with the `set` command, the following actions take place:

1. The given branch is cloned in the temporary `.workspace` folder
2. If required, the project is built
3. A docker image is built
4. The Docker image is tagged as `hmcts/<project>:<branch>-<git hash>`
5. An entry is added to file `.tags.env` exporting an environment variable `<PROJECT>_TAG` with a value `<branch>-<git hash>` matching the Docker image tag

The `.tags.env` file is sourced whenever the `am compose` command is used and allows to override the Docker images version used in the Docker compose files.

Hence, to make that change effective, the containers must be updated using `./am compose up`.

#### `master` branch

When switching a project to `master` branch, the branch override is removed using the `unset` command detailed below.

### Unset

Given a list of 1 or more projects, for each project:

1. If `.tags.env` contains an entry for the project, the entry is removed

Similarly to when branches are set, for a change to `.tags.env` to be applied, the containers must be updated using `./am compose up`.

### Status

Retrieve from `.tags.env` the branches and compose files currently enabled and display them.

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

## Containers

### Back-end

#### am-role-assignment-service

It stores all the local role and validations rules on the basis of which multiple role assignments are granted/revoked.


## Local development

The provided Docker compose files can be used to get up and running for local development.

However, while working, it is more convenient to run a project directly on the localhost rather than having to rebuild a docker image and a container.
This means mixing a locally-run project, the one being worked on, with projects running in Docker containers.

Given their unique configuration and dependencies, the way to achieve this varies slightly from one project to the other.

Here's the overall approach:

### 1. Update containers to point to local project

As is, the containers are configured to use one another.
Thus, the first step to replace a container by a locally running instance is to update all references to this container in the compose files.

For instances, to use a local data store, references in `am-api-gateway` service (file `compose/frontend.yml`) must be changed from:

```yml
PROXY_AGGREGATED: http://am-role-assignment-service:4096
PROXY_DATA: http://am-role-assignment-service:4096
```

to, for Mac OS:

```yml
PROXY_AGGREGATED: http://docker.for.mac.localhost:4096
PROXY_DATA: http://docker.for.mac.localhost:4096
```

or to, for Windows:

```yml
PROXY_AGGREGATED: http://docker.for.win.localhost:4096
PROXY_DATA: http://docker.for.win.localhost:4096
```

The `docker.for.mac.localhost` and `docker.for.win.localhost` hostnames point to the host computer (your localhost running Docker).

For other systems, the host IP address could be used.

Once the compose files have been updated, the new configuration can be applied by running:

```
./am compose up -d
```

### 2. Configure local project to use containers

The local project properties must be reviewed to use the containers and comply to their configuration.

Mainly, this means:
- **Database**: pointing to the locally exposed port for the associated DB. This port used to be 5000 but has been changed to 5050 after SIDAM integration, which came to use 5000 for sidam-api application.
- **SIDAM**: pointing to the locally exposed port for SIDAM
- **S2S**:
  - pointing to the locally exposed port for `service-auth-provider-api`
  - :warning: using the right key, as defined in `service-auth-provider-api` container
- **URLs**: all URLs should be updated to point to the corresponding locally exposed port

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

am UI not loading:

- it might take few minutes for all the services to startup
    > wait few minutes and then retry accessing am UI
- sometimes happens that some of the back-ends (data store, definition store, user profile) cannot startup because the database liquibase lock is stuck.
    > check on the back-end log if there's the following exception: 'liquibase.exception.LockException: Could not acquire change log lock'
    Execute the following command on the database:
    UPDATE DATABASECHANGELOGLOCK SET LOCKED=FALSE, LOCKGRANTED=null, LOCKEDBY=null where ID=1;
- it's possible that some of the services cannot start or crash because of lack of availabel memory. This especially when starting Idam and or ElasticSearch
    > give more memory to Docker. Configurable under Preferences -> Advanced

DM Store issues:

- "uk.gov.hmcts.dm.exception.AppConfigurationException: Cloub Blob Container does not exist"
    > ./bin/document-management-store-create-blob-store-container.sh

## Variables
Here are the important variables exposed in the compose files:

| Variable | Description |
| -------- | ----------- |
| AM_DB | Access Management database name |
| AM_DB_USERNAME | Access Management database username |
| AM_DB_PASSWORD | Access Management database password |

## Remarks

- A container can be configured to call a localhost host resource with the localhost shortcut added for docker containers recently. However the shortcut must be set according the docker host operating system.

```bash
# for Mac
docker.for.mac.localhost
# for Windows
docker.for.win.localhost
```

Remember that once you changed the above for a particular app you have to make sure the container configuration for that app does not try to automatically start the dependency that you have started locally. To do that either comment out the entry for the locally running app from the **depends_on** section of the config or start the app with **--no-deps** flag.

- If you happen to run `docker-compose up` before setting up the environment variables, you will probably get error while starting the DB. In that
case, clear the containers but also watch out for volumes created to be cleared to get a fresh start since some initialisation scripts don't run if
you have already existing volume for the container.

```bash
$ docker volume list
DRIVER              VOLUME NAME

# better be empty
```

## LICENSE

This project is licensed under the MIT License - see the [LICENSE](LICENSE.md) file for details.
