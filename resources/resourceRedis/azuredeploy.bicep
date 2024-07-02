// Version 1.0
param redisName string
param location string = resourceGroup().location
param tags object = {}
param redisConfiguration object = {
  maxclients: '1000'
  'maxmemory-reserved': '50'
  'maxfragmentationmemory-reserved': '50'
  'maxmemory-delta': '50'
}
param redisVersion string = '6'
param sku object = {
  name: 'Standard'
  family: 'C'
  capacity: 1
}

resource redis 'Microsoft.Cache/Redis@2023-08-01' = {
  name: redisName
  location: location
  tags: tags
  properties: {
    sku: sku
    enableNonSslPort: false
    minimumTlsVersion: '1.2'
    redisConfiguration: redisConfiguration
    redisVersion: redisVersion
  }
}
