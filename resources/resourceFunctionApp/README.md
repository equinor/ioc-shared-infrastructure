# Function App

Combines a function app, the storage account required for it, and a connected
ApplicationInsights instance.

![Resource view](overview.png)

## Template parameters

| Parameter name         | Type   | Required | Value                                                                                                                                                                   |
|------------------------|--------|----------|-------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| appServicePlanName     | string | Yes      | The name of the hosting plan.                                                                                                                                           |
| functionAppName        | string | Yes      | The name of the function app.                                                                                                                                           |
| storageAccountName     | string | Yes      | The name of the storage account used by the function(s).                                                                                                                |
| location               | string | No       | The name of the resource group. "defaultValue": "[resourceGroup().location]"                                                                                            |
| tags                   | object | Yes      | Tags that are associated with the resource. (https://docs.microsoft.com/en-us/azure/templates/microsoft.resources/tags)                                                 |
| appSettings            | array  | No       | The SiteConfig's appSettings of the functionApp   "defaultValue": [
                                                                                                                    {
                                                                                                                    "name": "FUNCTIONS_WORKER_RUNTIME",
                                                                                                                    "value": "python"
                                                                                                                    },
                                                                                                                    {
                                                                                                                    "name": "FUNCTIONS_EXTENSION_VERSION",
                                                                                                                    "value": "~2"
                                                                                                                    }]
                                              Note:  appSettings must at least contains value for FUNCTIONS_WORKER_RUNTIME and  FUNCTIONS_EXTENSION_VERSION                                           
|

## Example usage

``` ps
az deployment group create --mode Incremental --name myFunctionAppDeployment --resource-group myResourceGroup --template-file ./azuredeploy.json --template-uri "https://raw.githubusercontent.com/equinor/ioc-shared-infrastructure/master/resources/resourceFunctionApp/azuredeploy.jsonc"
```

## Example parameter file

``` json
{
    "$schema": "https://schema.management.azure.com/schemas/2019-04-01/deploymentParameters.json#",
    "contentVersion": "1.0.0.0",
    "parameters": {
                    "appServicePlanName": {
                        "value": "MyAppServicePlanName"
                    },
                    "functionAppName": {
                        "value":  "MyFunctionAppName" 
                    },
                     "storageAccountName": {
                        "value": "MyStorageAccountName"
                    },                    
                    "location" : {
                        "value" : "myFunctionAppLocation"
                    },
                    "tags": {
                        "value": {
                                "Environment": "MyEnvironment",
                                "ServiceName": "MyServiceName",
                                "Team": "MyTeam",
                                "GeneratedBy": "[concat('myApp-', deployment().properties.template.contentVersion)]"            
                            },
                    
                    "appSettings": {
                        "value": [
                             {
                                "name": "FUNCTIONS_WORKER_RUNTIME",
                                "value": "python"
                             },
                             {
                               "name": "FUNCTIONS_EXTENSION_VERSION",
                               "value": "~2"
                            },
                            {
                                "name": "MyCustomAppsetting",
                                "value": "120d"
                            },            
                            ]
                                                                                                                   
                    }                
                }
    }
}
```
