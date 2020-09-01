# Postgresql database

Provisions a managed postgresql database. Parameters:

| Parameter                 | Type         | Required | Meaning                                             |
|---------------------------|--------------|----------|-----------------------------------------------------|
| postgresServerName        | string       | yes      | The name of the postgres database                   |
| postgresVersion           | string       | no       | The postgres version [9.5, 9.6, 10, 10.0, 10.2, 11] |
| tags                      | object       | yes      | The tags associated with the resources              |
| sku                       | object       | no       | Postgresql [SKU][sku]                               |
| adminstratorLogin         | string       | yes      | The username of the postgresql administrator        |
| adminstratorLoginPassword | securestring | yes      | The administrator password                          |


## Creating databases

When using the template, you can provision databases like this:
```json
{
    "type": "Microsoft.DBforPostgreSQL/servers/databases",
    "apiVersion": "2017-12-01",
    "name": "[concat(variables('postgresServerName'), '/<database_name>')]",
    "dependsOn": [
        "[variables('postgresServerName')]"
    ],
    "properties": {
        "charset": "UTF8",
        "collation": "English_United States.1252"
    }
},
```

[sku]: https://docs.microsoft.com/en-us/azure/templates/microsoft.dbforpostgresql/2017-12-01/servers#sku-object "SKU"
