// Version 1.0
param namespaceName string
param eventhubName string
param partitionCount int = 1
param messageRetentionInDays int = 1
param eventLogRetentionTimeInHours int = 24
param tombstoneRetentionInHours int = 72

@allowed([
  'Delete'
  'Compact'
])
param cleanupPolicy string = 'Delete'
param tags object = {}
param sku object = {
  capacity: 1
  name: 'Standard'
  tier: 'Standard'
}

var rgScope = resourceGroup()

func setRetentionDescription(policy string, retentionInHours int, tombstoneRetentionInHours int) object => (policy == 'Delete') ? {
    cleanupPolicy: 'Delete'
    retentionTimeInHours: retentionInHours
  } : {
    cleanupPolicy: 'Compact'
    retentionTimeInHours: retentionInHours
    tombstoneRetentionTimeInHours: tombstoneRetentionInHours
  }

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
    retentionDescription: setRetentionDescription(cleanupPolicy, eventLogRetentionTimeInHours, tombstoneRetentionInHours)
    status: 'Active'
  }
}
