// Version 1.1 Module eventhub
param namespaceName string
param eventhubName string
param autoInflateEnabled bool = false
param maximumThroughputUnits int = 1
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
    kafkaEnabled: true
    isAutoInflateEnabled: autoInflateEnabled
    maximumThroughputUnits: maximumThroughputUnits
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
