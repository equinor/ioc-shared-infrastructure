# Service bus namespace and queue

A servicebus namespace. Optionally add queues or topics+subscriptions
This template fails if linked using API version older than 2019-05-10.

![Resource view](overview.png)

![Topics example](sb-topics-01.png)

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
        "serviceBusTopics": {
            "value": [
                "topic1"
            ]
        },
        "serviceBusSubscriptions": {
            "value": [
                {
                    "topic": "topic1",
                    "subscriber": "subscriber1"
                },
                {
                    "topic": "topic1",
                    "subscriber": "subscriber2"
                }
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