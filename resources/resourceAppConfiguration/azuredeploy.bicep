// Version 1.0
param appConfigName string
param tagComponent string
param tagEnvironment string
param location string = resourceGroup().location
param keyValuePairs array = []
param featureFlags array = []
param keyVaultReferences array = []
param disableLocalAuth bool = false
param publicNetworkAccess string = 'Enabled'
param sku string = 'standard'

resource appConfig 'Microsoft.AppConfiguration/configurationStores@2023-03-01' = {
  name: appConfigName
  location: location
  sku: {
    name: sku
  }
  identity: {
    type: 'SystemAssigned'
  }
  tags: {
    Component: tagComponent
    Environment: tagEnvironment
  }
  properties: {
    disableLocalAuth: disableLocalAuth
    publicNetworkAccess: publicNetworkAccess
  }

  resource keyValues 'keyValues@2023-03-01' = [for kvp in keyValuePairs: {
    name: '${kvp.name}'
    properties: {
      contentType: 'string'
      value: kvp.value
    }
  }]

  resource featureValues 'keyValues@2023-03-01' = [for feature in featureFlags: {
    name: feature.name
    properties: {
      contentType: 'application/vnd.microsoft.appconfig.ff+json;charset=utf-8'
      value: string(feature.value)
    }
  }]

  resource keyVaultRefs 'keyValues@2023-03-01' = [for ref in keyVaultReferences: {
    name: '${ref.name}'
    properties: {
      contentType: 'application/vnd.microsoft.appconfig.keyvaultref+json;charset=utf-8'
      value: string(ref.value)
    }
  }]
}
