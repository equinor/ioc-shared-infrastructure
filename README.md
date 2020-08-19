# IOC Shared Infrastructure

IOC Shared Infrastructure is a repository for sharing commonly used Azure infrastructure components within the Equinor IOC.

The intention is to provide a "menu" of ready-to-use ARM-templates, which can be directly included in apps and solutions.

## What is Equinor IOC

The Equinor integrated operations centre (IOC) will help increase safety, add value and reduce emissions from our installations on the Norwegian continental shelf (NCS). The agile development teams develops and runs services aimed at supporting these operations.

More info at [equinor.com](https://www.equinor.com/en/news/27nov2017-integrated-operations-centre.html).

## See available resources

Go to the [resources](resources) folder to see available resources

## Usage

The following snippet shows the `resources` section of a parent template, which
links to a resource template:

``` json
"resources": [
  {
    "name": "linkedTemplateContainerRegistry",
    "type": "Microsoft.Resources/deployments",
    "apiVersion": "2018-05-01",
    "properties": {
      "mode": "Incremental",
      "templateLink": {
        "uri": "[concat(parameters('resourceTemplateUriBase'), 'resourceContainerRegistry/azuredeploy.jsonc')]",
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

## Licence

See [LICENCE](LICENCE)
