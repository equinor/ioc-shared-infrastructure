# Event Grid

Creates a EventGrid domain, one or multiple domain topics containing one or multiple subscriptions,

![Resource view](overview.png)

## Template parameters

| Parameter name                    | Type   | Required | Value                                                                                                                                                                   |
|-----------------------------------|--------|----------|-------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| eventGridDomainName               | string | Yes      | The name of the Event Grid domain.                                                                                                                                      |
| eventGridDomainTopicNames         | array  | Yes      | The name of the Event Grid domain topics.                                                                                                                               |
| eventGridDomainTopicSubscriptions | array  | Yes      | The configuration of the Event Grid domain topics' subscriptions.
                                                            Array of configuration object
                                                            {
                                                                "name": "name of subscription ",
                                                                "topic": "name of a topic from eventGridDomainTopicName",
                                                                "properties": {subscription property}
                                                            }
| location                          | string | No       | The name of the resource group. "defaultValue": "[resourceGroup().location]"                                                                                              |
| tags                              | object | Yes      | Tags that are associated with the resource. (https://docs.microsoft.com/en-us/azure/templates/microsoft.resources/tags)                                                   |
                                     

## Example usage

``` ps
az deployment group create --mode Incremental --name myEventGridDeployment --resource-group myResourceGroup --template-file ./azuredeploy.json --template-uri "https://raw.githubusercontent.com/equinor/ioc-shared-infrastructure/master/resources/resourceFunctionApp/azuredeploy.jsonc"
```

## Example parameter file

``` json
{
    "$schema": "https://schema.management.azure.com/schemas/2019-04-01/deploymentParameters.json#",
    "contentVersion": "1.0.0.0",
    "parameters": {
                    "eventGridDomainName": {
                        "value": "MyeventGridDomainName"
                    },
                    "eventGridDomainTopicNames": {
                        "value":   ["MyTopic1","MyTopic2"] 
                    }, 
                    "eventGridDomainTopicSubscriptions": {
                        "value": [{
                            "name": "MySubscription1",
                            "topic": "MyTopic1",
                            "properties":  {
                                "destination": {
                                    "endpointType": "WebHook",
                                    "properties": {
                                        "azureActiveDirectoryApplicationIdOrUri": "id or uri",
                                        "azureActiveDirectoryTenantId": "tenentId",
                                        "endpointUrl": "https://MyApp.azurewebsites.net/api/events"
                                    }
                                }
                            }
                        },      
                        {
                            "name": "MySubscription2",
                            "topic": "MyTopic2",
                            "properties":  {
                                "destination": {
                                    "endpointType": "WebHook",
                                    "properties": {                           
                                        "azureActiveDirectoryApplicationIdOrUri": "id or uri",
                                        "azureActiveDirectoryTenantId": "tenentId",
                                        "endpointUrl": "https://MyOtherApp.azurewebsites.net/api/events"
                                    }
                                }
                            }
                        }
                        ],               
                    "location" : {
                        "value" : "myEventGridLocation"
                    },
                    "tags": {
                        "value": {
                                "Environment": "MyEnvironment",
                                "ServiceName": "MyServiceName",
                                "Team": "MyTeam",
                                "GeneratedBy": "[concat('myApp-', deployment().properties.template.contentVersion)]"            
                            }
                }
    }
}
```
