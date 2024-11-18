// Version 1.0
param redisName string
param location string = resourceGroup().location
param tags object = {}
param aadEnabled string = 'false'
param redisConfiguration object = {
  maxclients: '1000'
  'maxmemory-reserved': '50'
  'maxfragmentationmemory-reserved': '50'
  'maxmemory-delta': '50'
  'aad-enabled': aadEnabled
}
param redisVersion string = '6'

@description('Specify the family for the sku. C = Basic/Standard, P = Premium.')
@allowed([
  'C'
  'P'
])
param redisCacheFamily string = 'C'
@description('Specify the size of the new Azure Redis Cache instance. Valid values: for C (Basic/Standard) family (0, 1, 2, 3, 4, 5, 6), for P (Premium) family (1, 2, 3, 4, 5)')
@allowed([
  0
  1
  2
  3
  4
  5
  6
])
param redisCacheCapacity int = 1
@description('Specify the pricing tier of the new Azure Redis Cache.')
@allowed([
  'Basic'
  'Standard'
  'Premium'
])
param redisCacheSKU string = 'Standard'

var sku = {
  name: redisCacheSKU
  family: redisCacheFamily
  capacity: redisCacheCapacity
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
