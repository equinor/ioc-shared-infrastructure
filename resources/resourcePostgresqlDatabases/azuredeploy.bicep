// Version 1.0
param server string
param databases array

resource postgres_databases 'Microsoft.DBforPostgreSQL/servers/databases@2017-12-01' = [
  for item in databases: {
    name: '${server}/${item}'
    properties: {
      charset: 'UTF8'
      collation: 'English_United States.1252'
    }
  }
]
