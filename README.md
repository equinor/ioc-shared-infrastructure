# IOC Shared Infrastructure

IOC Shared Infrastructure is a repository for sharing commonly used Azure infrastructure components within the Equinor IOC.

The intention is to provide a "menu" of ready-to-use ARM-templates, which can be directly included in apps and solutions.

## What is Equinor IOC

The Equinor integrated operations centre (IOC) will help increase safety, add value and reduce emissions from our installations on the Norwegian continental shelf (NCS). The agile development teams develops and runs services aimed at supporting these operations.

More info at [equinor.com](https://www.equinor.com/en/news/27nov2017-integrated-operations-centre.html).

## See available resources

Go to the [resources](resources) folder to see available resources

## Versioning
The repository employs versioning to enable deterministic builds. Versioning is based on semantic versioning. If a client requires a change, it will
usually constitute a patch version change, but if there are any breaking changes then the minor version should be bumped.

At every version change, a git tag and a github release will be made. The github release has an autogenerated list of changes which makes it easier to
see for others which changes have been made between their current version and the latest. This makes it important to write useful commit messages and
pull request titles.

The github release will have a zipped (`.zip|.tar.gz`) file containing all files in the repository, so it can be downloaded in a local workspace or in a
build pipeline for easy integration with `bicep` files

## Usage

The following snippet shows the `resources` section of a parent template, which
links to a resource template:

``` json
"resources": [
  {
    "name": "linkedTemplateContainerRegistry",
    "type": "Microsoft.Resources/deployments",
    "apiVersion": "2021-04-01",
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
