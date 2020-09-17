# Postgresql server

Provisions a managed postgresql database. Parameters:

| Parameter                 | Type         | Required | Meaning                                             |
|---------------------------|--------------|----------|-----------------------------------------------------|
| postgresServerName        | string       | yes      | The name of the postgres database server            |
| tags                      | object       | yes      | The tags associated with the resources              |
| location                  | string       | no       | Location(use the default)                           |
| postgresVersion           | string       | no       | The postgres version [9.5, 9.6, 10, 10.0, 10.2, 11] |
| sku                       | object       | no       | Postgresql [SKU][sku]                               |
| adminstratorLogin         | string       | yes      | The username of the postgresql administrator        |
| adminstratorLoginPassword | securestring | yes      | The administrator password                          |

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

When creating a database server with this template, use its [sibling template][../resourcePostgresqlDatabases/README.md] to create databases:

[sku]: https://docs.microsoft.com/en-us/azure/templates/microsoft.dbforpostgresql/2017-12-01/servers#sku-object "SKU"
