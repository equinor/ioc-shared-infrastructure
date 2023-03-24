# Postgresql server

Provisions a managed postgresql database. Parameters:

| Parameter                  | Type         | Required | Meaning                                             |
|----------------------------|--------------|----------|-----------------------------------------------------|
| postgresServerName         | string       | yes      | The name of the postgres database server            |
| tags                       | object       | yes      | The tags associated with the resources              |
| adminstratorLogin          | string       | yes      | The username of the postgresql administrator        |
| adminstratorLoginPassword  | securestring | yes      | The administrator password                          |
| tenantId                   | string       | no       | Defaults to Equinor tenant                          |
| pwdAuthConfig              | string       | no       | Disabled/Enabled. Defaults to Enabled               |
| activeDirectoryAuthConfig  | string       | no       | Disabled/Enabled. Defaults to Enabled               |
| location                   | string       | no       | Location(use the default)                           |
| postgresVersion            | string       | no       | The postgres version [11, 12, 13, 14]               |
| sku                        | object       | no       | Postgresql [SKU][sku]                               |
| skuSizeGB                  | int          | no       | The db storage size                                 |
| backupRetention            | int          | no       | Backup retention in days. Defaults to 30            |
| geoRedundantBackup         | string       | no       | Whether to use georedundancy on backups.            |
| haMode                     | string       | no       | high availability mode [Disabled, ZoneRedundant]    |
| availabilityZone           | string       | no       | how many zones in which resource is available       |
| virtualNetworkExternalId   | string       | no       | If virtual network (defaults to publicNetworkAccess)|
| subnetName                 | string       | no       | If located in a subnet                              |
| privateDnsZoneArmResourceID| string       | no       | Sets the private dns zone arm resource id           |


This is an example parameter file

```json
{
    "$schema": "https://schema.management.azure.com/schemas/2019-04-01/deploymentParameters.json#",
    "contentVersion": "1.0.0.0",
    "parameters": {
        "postgresServerName": {
            "value": "<Server name>"
        },
        "tags": {
            "value": {
                "Environment": "<Environment>]"
            }
        },
        "administratorLogin": {
            "value": "<Admin username>"
        },
        "administratorLoginPassword": {
            "value": "<Admin password>"
        },
        "sku": {
            "value": {
                "name": "Standard_D4ds_v4",
                "tier": "GeneralPurpose"
            }
        },
        "haMode": {
            "value": "ZoneRedundant"
        },
    }
}
```

## Creating databases

When creating a database server with this template, use its [sibling template][../resourcePostgresqlDatabases/README.md] to create databases:

[sku]: https://docs.microsoft.com/en-us/azure/templates/microsoft.dbforpostgresql/2017-12-01/servers#sku-object "SKU"
