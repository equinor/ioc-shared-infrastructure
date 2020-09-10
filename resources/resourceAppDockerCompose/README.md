# App

Creates a web app for use with docker compose. It includes a connected ApplicationInsights instance.

![Resource view](overview.png)


## Example usage

``` ps
az deployment group create --mode Incremental --name myAppDockerComposeDeployment --resource-group myResourceGroup --template-uri "https://raw.githubusercontent.com/equinor/ioc-shared-infrastructure/master/resources/resourceAppDockerCompose/azuredeploy.jsonc"
```

## Example parameter file

``` json
{
    "$schema": "https://schema.management.azure.com/schemas/2019-04-01/deploymentParameters.json#",
    "contentVersion": "1.0.0.0",
    "parameters": {
        "webAppName": {
            "value": "myWebApp"
        },
        "appserviceResourceId": {
            "value": "00000-000-000-0000"
        },
        "containerRegistryName": {
            "value": "myContainerRegistry"
        },
        "dockerComposeYaml": {
            "value": "BASE64_ENCODED_DOCKER_COMPOSE"
        },
        "environmentVariables": {
            "value": [
                {
                    "key": "SomeEnvVar1",
                    "value": "SomeValue"
                },
                {
                    "key": "SomeEnvVar2",
                    "value": "SomeValue2"
                }
            ]
        },
    }
}
```
