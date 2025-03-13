# Azure Brokerpak

A brokerpak for the [Cloud Service Broker](https://github.com/pivotal/cloud-service-broker) that provides support for Azure services.

## Development Requirements

* [Install Azure ClI](https://learn.microsoft.com/en-us/cli/azure/install-azure-cli)
* Either an up-to-date version of Go or [Docker](https://docs.docker.com/get-docker/)
* make - covers development lifecycle steps

## Azure account information

To provision services, the brokerpak currently requires Azure account values. The brokerpak expects them in environment variables:

* ARM_SUBSCRIPTION_ID
* ARM_TENANT_ID
* ARM_CLIENT_ID
* ARM_CLIENT_SECRET

#### Setup Principal

A principal will be used by the broker to authenticate with Azure. The principal providees the values for `ARM_CLIENT_ID` and `ARM_CLIENT_SECRET`. [Create a Principal](https://learn.microsoft.com/en-us/azure/developer/terraform/authenticate-to-azure-with-service-principle?tabs=bash) in Azure with contributor role.
```
az ad sp create-for-rbac --name <service_principal_name> --role Contributor --scopes /subscriptions/<subscription_id>
```

Set environment variables.
```
export ARM_SUBSCRIPTION_ID="<azure_subscription_id>"
export ARM_TENANT_ID="<azure_subscription_tenant_id>"
export ARM_CLIENT_ID="<service_principal_appid>"
export ARM_CLIENT_SECRET="<service_principal_password>"
```
## Development Tools

A Makefile supports the full local development lifecycle for the brokerpak.

The make targets can be run either with Docker or installing the required libraries in the local OS.

Available make targets can be listed by running `make`.

### Running with docker

1. Install [Docker](https://docs.docker.com/get-docker/)
2. Launch an interactive shell into some supported image containing all necessary tools. For example:
   ```
   # From the root of this repo run:
   docker run -it --rm -v "${PWD}:/repo" --workdir "/repo" --entrypoint "/bin/bash" golang:latest
   make
   ```

### Running with Go

1. Make sure you have the right Go version installed (see `go.mod` file).

The make targets will build the source using the local go installation.

### Other targets

There is a make target to push the broker and brokerpak into a CloudFoundry foundation. It will be necessary to manually configure a few items for the broker to work.

- `make push-broker` will `cf push` the broker into CloudFoundry. Requires the `cf` cli to be installed.

The broker gets pushed into CloudFoundry as *cloud-service-broker-azure*  It will be necessary to bind a MySQL database to the broker to provide broker state storage. See [cloud.gov Installation](./docs/cloudgov-installation.md) docs for more info.

## Broker
The version of Cloud Service Broker to use with this brokerpak is encoded in the `go.mod` file.
The make targets will use this version by default.

## Tests

### Example tests

Services definitions declare examples for each plan they provide. Those examples are then run through the whole cycle of `provision`, `bind`, `unbind`, and `delete` when running

```
terminal 1
>> make run

terminal 2
>> make run-examples
```

## Acceptance tests

See [acceptance tests](acceptance-tests/README.md)

## Integration tests

Integration tests can be run with the following command:

```bash
make run-integration-tests
```

