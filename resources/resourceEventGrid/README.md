# Event Grid

Creates a EventGrid domain, and one one or multiple domain topics,

![Resource view](overview.png)

## Template parameters

| Parameter name           | Type   | Required | Value                                                                                                                                                                   |
|--------------------------|--------|----------|-------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| eventGridDomainName      | string | Yes      | The name of the Event Grid domain.                                                                                                                                      |
| eventGridDomainTopicName | string | Yes      | The name of the Event Grid domain topics.                                                                                                                                |
| location                 | string | No       | The name of the resource group. "defaultValue": "[resourceGroup().location]"                                                                                              |
| tags                     | object | Yes      | Tags that are associated with the resource. (https://docs.microsoft.com/en-us/azure/templates/microsoft.resources/tags)                                                   |
                                     

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
                        "value":   ["Mytopic1","Mytopic2"] 
                    },                   
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
