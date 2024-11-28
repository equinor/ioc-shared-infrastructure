// Version 1.0
param server string
param databases array

resource parentPgFlexibleServer 'Microsoft.DBforPostgreSQL/flexibleServers@2024-08-01' existing = {
  name: server
}

resource server_databases 'Microsoft.DBforPostgreSQL/flexibleServers/databases@2024-08-01' = [
  for item in databases: {
    name: item
    parent: parentPgFlexibleServer
    properties: {
      charset: 'UTF8'
      collation: 'en_US.utf8'
    }
  }
]
