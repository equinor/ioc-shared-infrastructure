param appConfigName string
param tagComponent string
param tagEnvironment string
param keyValuePairs array = []
param featureFlags array = []
param keyVaultReferences array = []

var rgScope = resourceGroup()

resource appConfig 'Microsoft.AppConfiguration/configurationStores@2021-03-01-preview' = {
  name: appConfigName
  location: rgScope.location
  sku: {
    name: 'standard'
  }
  identity: {
    type: 'SystemAssigned'
  }
  tags: {
    Component: tagComponent
    Environment: tagEnvironment
  }
  properties: {
    disableLocalAuth: false
    publicNetworkAccess: 'Enabled'
  }

  resource keyValues 'keyValues@2021-03-01-preview' = [for kvp in keyValuePairs: {
    name: '${kvp.name}'
    properties: {
      contentType: 'string'
      value: kvp.value
    }
  }]

  resource featureValues 'keyValues@2021-03-01-preview' = [for feature in featureFlags: {
    name: feature.name
    properties: {
      contentType: 'application/vnd.microsoft.appconfig.ff+json;charset=utf-8'
      value: string(feature.value)
    }
  }]

  resource keyVaultRefs 'keyValues@2021-03-01-preview' = [for ref in keyVaultReferences: {
    name: '${ref.name}'
    properties: {
      contentType: 'application/vnd.microsoft.appconfig.keyvaultref+json;charset=utf-8'
      value: string(ref.value)
    }
  }]
}
