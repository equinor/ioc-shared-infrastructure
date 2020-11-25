# Service bus namespace and queue

A servicebus namespace and queue

![Resource view](overview.png)


## Example usage

``` ps
az deployment group create --mode Incremental --name myRedisCacheDeployment --resource-group myResourceGroup --template-file ./azuredeploy.json --template-uri "https://raw.githubusercontent.com/equinor/ioc-shared-infrastructure/master/resources/resourceServiceBus/azuredeploy.jsonc"
```

## Example parameter file

``` json
{
    "$schema": "https://schema.management.azure.com/schemas/2019-04-01/deploymentParameters.json#",
    "contentVersion": "1.0.0.0",
    "parameters": {
        "serviceBusNamespaceName": {
            "value": "myServiceBus"
        },
        "serviceBusQueueNames": {
            "value": [
                "queue1",
                "queue2"
            ]
        },
        "tags": {
            "value": {
                "Environment" : "Dev"
            }
        },
        "sku": {
            "value": "Premium"
        }
    }
}
```