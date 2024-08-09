// Version 1.0
param namespaceName string
param eventhubName string
param partitionCount int = 1
param messageRetentionInDays int = 1
param eventLogRetentionTimeInHours int = 24
param tags object = {}
param sku object = {
  capacity: 1
  name: 'Standard'
  tier: 'Standard'
}

var rgScope = resourceGroup()

resource eventHubNamespaceResource 'Microsoft.EventHub/namespaces@2024-01-01' = {
  name: namespaceName
  location: rgScope.location
  tags: tags
  sku: sku
  identity: {
    type: 'SystemAssigned'
  }
  properties: {
    disableLocalAuth: false
    isAutoInflateEnabled: false
    kafkaEnabled: true
    maximumThroughputUnits: 0
    minimumTlsVersion: '1.2'
    publicNetworkAccess: 'Enabled'
    zoneRedundant: true
  }
}

resource eventHubResource 'Microsoft.EventHub/namespaces/eventhubs@2024-01-01' = {
  name: eventhubName
  parent: eventHubNamespaceResource
  properties: {
    messageRetentionInDays: messageRetentionInDays
    partitionCount: partitionCount
    retentionDescription: {
      cleanupPolicy: 'Delete'
      retentionTimeInHours: eventLogRetentionTimeInHours
    }
    status: 'Active'
  }
}
