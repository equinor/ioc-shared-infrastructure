# Bicep resources
We are in a process of rewriting our ARM-templates to Bicep.

Here follows some guidelines of how to use the Bicep resources and how to contribute.

## Prerequisites
You'll need the following tools installed

* `az cli`

When you use Azure CLI with Bicep, you have everything you need to deploy and decompile Bicep files. Azure CLI automatically installs the Bicep CLI when a command is executed that needs it.

You must have Azure CLI version 2.20.0 or later installed. To install or update Azure CLI, see:

* https://learn.microsoft.com/en-us/cli/azure/install-azure-cli-windows
* https://learn.microsoft.com/en-us/cli/azure/install-azure-cli-linux
* https://learn.microsoft.com/en-us/cli/azure/install-azure-cli-macos

## Usage
Bicep files will  be stored together with their equivalent ARM-template resource, i.e. `containerregistry.bicep` should be found alongside `azuredeploy.jsonc` in the `./resources/resourceContainerRegsitry/` folder.

Whereas the ARM-template resources are downloaded via github at deploy-time, the Bicep resources are downloaded from a Bicep Container Registry residing in `ioc-shared-rg-prod`.
To start using it you need a configuration file which can be copied into your project infrastructure-folder from here `./bicepconfig.json`.
This configuration contains the required registry uri's and some select linter rules to get you started.

You'll need a main bicep file to deploy your project. Lets call this `main.bicep`

The following example shows a deployment of an ApplicationConfiguration resource
```
param env string
param tagComponent string
param tagEnvironment string
param appConfigSku string

var appConfigName = 's039-ioc-{myspace}-appconf-${env}'

var keyValuePairs = []
var keyVaultReferences = []
var featureFlags = []

module appConfigModule 'br/CoreModules:appconfiguration:v1.0' = {
  name: 'appConfigDeploy'
  scope: resourceGroup()
  params: {
    sku: appConfigSku
    appConfigName: appConfigName
    tagComponent: tagComponent
    tagEnvironment: tagEnvironment
    keyValuePairs: keyValuePairs
    featureFlags: featureFlags
    keyVaultReferences: keyVaultReferences
  }
}
```

To invoke this script, use the command (assuming your parameters are stored in `azuredeploy.parameters.dev.json`)
```
az deployment group create \
    --mode Incremental \
    --name $(shell echo shared.dev.RUNID) \
    --template-file ./main.bicep \
    --resource-group RESOURCE_GROUP_DEV \
    --parameters @./azuredeploy.parameters.dev.json
```
The appconfiguration resource v1.3 will then be downloaded from the container registry and used during deployment.

## Contributing
After adding or modifying a bicep resource you simply run the command

`az bicep publish --file /path/to/{mymodule}.bicep --target br/CoreModules:{mymodule}:{version}`

This will effectivly push the resource to the container registry with the specified version number. The `CoreModules` is specified in the `bicepconfig.json` and links to `s039iocsharedbrprod.azurecr.io/bicep/modules`. The acronym `br` simply stands for `Bicep Registry`.

ex. publishing the `appconfiguration` resource

`az bicep publish --file ./resources/resourceAppConfiguration/appConfiguration.bicep --target br/CoreModules:appconfiguration:1.0`

If `appconfiguration:v1.0` already exists you will get an error, in which case you will use `appconfiguration:v1.1` instead.
If you're simply testing and want to overwrite a version you've just added you can apply the `--force` flag, which requires `az cli @v2.49.0` or later.

