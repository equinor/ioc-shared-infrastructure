param server string
param databases array

resource parentPgFlexibleServer 'Microsoft.DBforPostgreSQL/flexibleServers@2023-03-01-preview' existing = {
  name: server
}

resource server_databases 'Microsoft.DBforPostgreSQL/flexibleServers/databases@2023-06-01-preview' = [
  for item in databases: {
    name: item
    parent: parentPgFlexibleServer
    properties: {
      charset: 'UTF8'
      collation: 'en_US.utf8'
    }
  }
]
