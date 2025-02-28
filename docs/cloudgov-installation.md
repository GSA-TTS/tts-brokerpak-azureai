# Installing the broker on cloud.gov

The broker service and the Azure brokerpak can be pushed and registered on cloud.gov.

Documentation for broker configuration can be found [here](./configuration.md).

## Requirements

### Azure Service Credentials
To do this, the broker needs the following service principal credentials to manage resources within the Azure account:
- tenant id
- subscription id
- client id
- client secret

#### Service Principal Roles and Required Providers
The subscription will require registered providers for each of the services that will be deployed.

> If the service principal being used has the `Contributor` role, provider registration should be automatic and the following can just be used for reference. 

> If the service principal being used does not have rights for automatic provider registration, the broker should be configured to disable this feature.
> Make sure the following is part of the `provision.defaults` part of the config file:
> ```yaml
> provision: 
>   defaults: '{
>     "skip_provider_registration": true
>   }' 

You can list the providers in the subscription, and make sure that the namespace is registered. For example, if you want to enable Service Bus service, `Microsoft.ServiceBus` should be registered. If the specific provider is not registered, you need to run `azure provider register <PROVIDER-NAME>` to register it.

```
$ azure provider list
info:    Executing command provider list
+ Getting ARM registered providers
data:    Namespace                  Registered
data:    -------------------------  -------------
data:    Microsoft.Batch            Registered
data:    Microsoft.Cache            Registered
data:    Microsoft.Compute          Registered
data:    Microsoft.DocumentDB       Registered
data:    microsoft.insights         Registered
data:    Microsoft.KeyVault         Registered
data:    Microsoft.MySql            Registered
data:    Microsoft.Network          Registering
data:    Microsoft.ServiceBus       Registered
data:    Microsoft.Sql              Registered
data:    Microsoft.ApiManagement    NotRegistered
data:    Microsoft.Authorization    Registered
data:    Microsoft.ClassicCompute   NotRegistered
data:    Microsoft.ClassicNetwork   NotRegistered
data:    Microsoft.ClassicStorage   NotRegistered
data:    Microsoft.Devices          NotRegistered
data:    Microsoft.Features         Registered
data:    Microsoft.HDInsight        NotRegistered
data:    Microsoft.Resources        Registered
data:    Microsoft.Scheduler        Registered
data:    Microsoft.ServiceFabric    NotRegistered
data:    Microsoft.StreamAnalytics  NotRegistered
data:    Microsoft.Web              NotRegistered
info:    provider list command OK
```

##### Services and their required providers
| Service | Namespace              |
|---------|------------------------|
| redis   | `Microsoft.Cache`      |
| mssql   | `Microsoft.Sql`        |
| mongodb | `Microsoft.DocumentDB` |
| storage | `Microsoft.Storage`    |

## Step By Step Deployment onto cloud.gov

These instructions include fetching a pre-built broker and binding it to a cloud.gov-managed MySQL.

### Requirements

The following tools are needed on your workstation:
- [cf cli](https://docs.cloudfoundry.org/cf-cli/install-go-cli.html)

### Assumptions

The `cf` CLI has been used to authenticate with cloud.gov (`cf api` and `cf login`) and an org and space have been targeted (`cf target`)

### Build The Brokerpak

```bash
make build
```

You should see a file called [TODO]... This is the broker "plug-in" that knows how to handle our services.


### Fetch A Broker Binary

Download a broker release from https://github.com/cloudfoundry/cloud-service-broker/releases. Download the `cloud-service-broker.linux` binary into the repository directory on your workstation. Rename it `cloud-service-broker`.

### Create a MySQL instance on cloud.gov
The following command will create a basic MySQL database instance named `csb-sql`
```bash
cf create-service aws-rds small-mysql csb-sql
```

### Build Config File
To avoid putting any sensitive information in environment variables, a config file can be used.

Create a file named `config.yml` in the same directory the broker and brokerpak. Its contents should be:

```yaml
azure:
  subscription_id: your subscription id
  tenant_id: your tenant id
  client_id: your client id
  client_secret: your client secret

api:
  user: someusername
  password: somepassword
```

### Push the Broker

Push the broker as a binary application:

```bash
SECURITY_USER_NAME=someusername
SECURITY_USER_PASSWORD=somepassword
APP_NAME=cloud-service-broker

chmod +x cloud-service-broker
cf push "${APP_NAME}" -c './cloud-service-broker serve --config config.yml' -b binary_buildpack --random-route --no-start
```

Bind the MySQL database and start the service broker:
```bash
cf bind-service cloud-service-broker csb-sql
cf start "${APP_NAME}"
```

### Register the Broker

Register the service broker:
```bash
BROKER_NAME=csb-$USER

cf create-service-broker "${BROKER_NAME}" "${SECURITY_USER_NAME}" "${SECURITY_USER_PASSWORD}" https://$(cf app "${APP_NAME}" | grep 'routes:' | cut -d ':' -f 2 | xargs) --space-scoped || cf update-service-broker "${BROKER_NAME}" "${SECURITY_USER_NAME}" "${SECURITY_USER_PASSWORD}" https://$(cf app "${APP_NAME}" | grep 'routes:' | cut -d ':' -f 2 | xargs)
```
Once this completes, the output from `cf marketplace` should include:
```
tts-azure-ai-model  basic          Manage Azure AI Models
```

## Uninstalling the Broker
First, make sure there are all service instances created with `cf create-service` have been destroyed with `cf delete-service`. Otherwise removing the broker will fail.

### Unregister the Broker
```bash
cf delete-service-broker csb-$USER
```

### Uninstall the Broker
```bash
cf delete cloud-service-broker
```

### Delete the Database
```bash
cf delete-service csb-sql
```

