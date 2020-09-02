# Postgresql server

Provisions a managed postgresql database. Parameters:

| Parameter                 | Type         | Required | Meaning                                             |
|---------------------------|--------------|----------|-----------------------------------------------------|
| postgresServerName        | string       | yes      | The name of the postgres database                   |
| postgresVersion           | string       | no       | The postgres version [9.5, 9.6, 10, 10.0, 10.2, 11] |
| tags                      | object       | yes      | The tags associated with the resources              |
| sku                       | object       | no       | Postgresql [SKU][sku]                               |
| adminstratorLogin         | string       | yes      | The username of the postgresql administrator        |
| adminstratorLoginPassword | securestring | yes      | The administrator password                          |

This is an example parameter file

```json
{
    "$schema": "https://schema.management.azure.com/schemas/2019-04-01/deploymentParameters.json#",
    "contentVersion": "1.0.0.0",
    "parameters": {
        "administratorLogin": {
            "value": "<admin_user>"
        },
        "administratorLoginPassword": {
            "value": "<admin_password>"
        },
        "environment": {
            "value": "dev"
        },
        "sku": {
            "value": {
                "name": "GP_Gen5_2",
                "tier": "GeneralPurpose",
                "family": "Gen5",
                "capacity": 2
            }
        }
    }
}
```

## Creating databases

When using the template, use template described [here][../resourcePostgresqlDatabases/README.md]:

[sku]: https://docs.microsoft.com/en-us/azure/templates/microsoft.dbforpostgresql/2017-12-01/servers#sku-object "SKU"
