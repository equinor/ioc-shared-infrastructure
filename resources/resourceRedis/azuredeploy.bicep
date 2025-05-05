// Version 1.2 Module redis
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

@description('Key Vault with Private Endpoint. This module creates a private endpoint for the keyvault if privateEndpointName is defined.')
param privateEndpointName string = ''
@description('The name of the resource group where the virtual network is located.')
param vnetResourceGroupName string = ''
@description('The name of the virtual network where the private endpoint will be created.')
param vnetName string = ''
@description('The name of the subnet where the private endpoint will be created.')
param subnetName string = ''

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

module privateEndpoint 'br/CoreModulesDEV:privateendpoints:1.0' = if (empty(privateEndpointName) == false) {
  name: 'redis.pept'
  params: {
    privateEndpointName: privateEndpointName
    serviceResourceId: redis.id
    subnetId: resourceId(vnetResourceGroupName,'Microsoft.Network/virtualNetworks/subnets', vnetName, subnetName)
    groupIds: [
      'redisCache'
    ]
    tags: tags
  }
}
