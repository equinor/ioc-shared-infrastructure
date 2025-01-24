# Container Application

Typically, an app will be deployed as a container, either with webapp or containerapp resource as base.

ContainerApp offers more flexibility while WebApp is tailored for web-applications.

Creates an Azure Container Application, Container Environment and UserAssignedIdentity.

<span style="color:orange;font-size:large">NB!</span> The AcrPull role must be manually configured for the user-assigned identity by resourceGroup-owner, else container will fail to load.

Resources: BICEP


| Parameter                     | Type    | Required | Description                                                       |
|-------------------------------|---------|----------|-------------------------------------------------------------------|
| activeRevisionsMode           | String  | No       | The mode of the active revision, defaults to 'Single'             |
| location                      | String  | No       | The resource location                                             |
| tags                          | Object  | Yes      | The list of tags for the application                              |
| containerAppName              | String  | Yes      | The name of the containerApp                                      |
| containerAppEnvName           | Bool    | Yes      | The name of the containerApp environment                          |
| containerRegistryLoginServer  | String  | Yes      | The login server for the container registry                       |
| containerImage                | String  | Yes      | The docker container image to deploy                              |
| targetPort                    | Int     | No       | The target port for ingress (typically one exposed by container)  |
| ingressAllowInsecure          | Bool    | No       | Basically, if we allow self-signed CA certificates                |
| ingressExternal               | Bool    | No       | If container allow external traffic                               |
| minReplicas                   | Int     | No       | Minimum number of replicas to deploy                              |
| maxReplicas                   | Int     | No       | Maximum number of replicas to deploy                              |
| cpuCore                       | Decimal | No       | Number of CPU cores container can use                             |
| memorySize                    | Decimal | No       | Amount of memory allocated to container (GiB)                     |
| logAnalyticsWorkspaceName     | String  | Yes      | Name of existing log analytics workspace                          |
| containerRegistryUsername     | String  | Yes      | Username to pull image from container registry                    |
| containerRegistryPassword     | String  | Yes      | Secure string password phrase to login to registry                |
| envVars                       | Array   | No       | List of environment variables                                     |
