# Key Vault Secrets

This template can be used to create one or more secrets on a given Key Vault resource.

![Resource view](overview.png)

## Template parameters

| Parameter name  | Type   | Required | Value                                   |
|-----------------|--------|----------|-----------------------------------------|
| keyVaultName    | string | Yes      | Specifies the name of the key vault.    |
| keyVaultSecrets | object | No       | The secrets to create in the key vault. |

## Example usage

``` ps
az deployment group create --mode Incremental --name myKeyVaultSecretsDeployment --resource-group myResourceGroup --template-uri "https://raw.githubusercontent.com/equinor/ioc-shared-infrastructure/master/resources/resourceKeyVaultSecrets/azuredeploy.jsonc"
```

## Example parameter file

``` json
{
    "$schema": "https://schema.management.azure.com/schemas/2019-04-01/deploymentParameters.json#",
    "contentVersion": "1.0.0.0",
    "parameters": {
        "keyVaultName": {
            "value": "myKeyVaultName"
        },
        "keyVaultSecrets": {
            "value": {
                "secrets" : [
                    { "name" : "mySecretName1", "value" : "super secret", "contentType" : "myContentType" },
                    { "name" : "mySecretName2", "value" : "super duper secret", "contentType" : "myContentType"}
                ]
            }
        }
    }
}
```
