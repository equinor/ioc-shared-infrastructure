# ioc-shared-infrastructure

This repository contains ARM templates for common components used in IOC
solutions.

## Resource templates

The `resources` directory contains the template files described in the following
subsections.

### resourceApp.json

Combines the actual web app, its configuration and a connected ApplicationInsights
instance.

### resourceAppServicePlan

Just an app service plan; useful to be able to put several apps into the same plan.

### resourceContainerRegistry.json

Typically, an app will be deployed as a container, thus the solution will come with
its own container registry.

### resourceFunctionApp.json

Combines a function app, the storage account required for it, and a connected
ApplicationInsights instance.

### resourceKeyVault.json

A single keyvault; typically deployed along with an application to contain its own
secrets.

### resourceKeyVaultAccess.json

This template can be used to grant access to keyvault secrets. For example the app of a
solution will require read access to obtain secrets from the vault.


## Usage

The following snippet shows the `resources` section of a parent template, which
links to a resource template:
```
"resources": [
  {
    "name": "linkedTemplateContainerRegistry",
    "type": "Microsoft.Resources/deployments",
    "apiVersion": "2018-05-01",
    "properties": {
      "mode": "Incremental",
      "templateLink": {
        "uri": "[concat(parameters('resourceTemplateUriBase'), 'resourceContainerRegistry.json')]",
        "contentVersion": "1.0.0.0"
      },
      "parameters": {
        "registryName": {
          "value": "[variables('registryName')]"
        },
        "location": {
          "value": "[parameters('location')]"
        },
        "tags": {
          "value": "[variables('tags')]"
        }
      }
    }
  }
],
"outputs": {
  "loginServer": {
    "type": "string",
    "value": "[reference('linkedTemplateContainerRegistry').outputs.acrServerUrl.value]"
  }
}
```
