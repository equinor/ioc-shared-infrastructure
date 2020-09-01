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

[sku]: https://docs.microsoft.com/en-us/azure/templates/microsoft.dbforpostgresql/2017-12-01/servers#sku-object "SKU"
