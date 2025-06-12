// Version 1.1 Module storageaccount
param accountName string
param location string = resourceGroup().location
param sku object = {
  name: 'Standard_LRS'
}
param kind string = 'BlobStorage'
param accessTier string = 'Hot'
param allowBlobPublicAccess bool = true
param allowSharedKeyAccess bool = true
param defaultToOAuthAuthentication bool = false
param keyExpirationPeriodInDays int = 365
param largeFileSharesState string = 'Disabled'  // cannot be reverted once set to Enabled
param publicNetworkAccess string = 'Enabled'
param networkAcls object = {
  defaultAction: 'Allow'
  bypass: 'AzureServices'
}
param deployBlobService bool = false
param blobServiceName string = ''
param blobContainerNames array = []
param tags object = {}

@description('StorageAccount with Private Endpoint. This module creates a private endpoint for the storageAccount if privateEndpointName is defined.')
param privateEndpointName string = ''
@description('The name of the resource group where the virtual network is located.')
param privatelinkVnetResourceGroupName string = ''
@description('The name of the virtual network where the private endpoint will be created.')
param privatelinkVnetName string = ''
@description('The name of the subnet where the private endpoint will be created.')
param privatelinkSubnetName string = ''
@description('The private DNS zone ID')
param privateDnsZoneId string


resource storageAccount 'Microsoft.Storage/storageAccounts@2024-01-01' = {
  name: accountName
  location: location
  tags: tags
  sku: sku
  kind: kind
  identity: {
    type: 'SystemAssigned'
  }
  properties: {
    accessTier: accessTier
    allowBlobPublicAccess: allowBlobPublicAccess
    allowCrossTenantReplication: false
    allowedCopyScope: 'AAD'
    allowSharedKeyAccess: allowSharedKeyAccess
    defaultToOAuthAuthentication: defaultToOAuthAuthentication
    dnsEndpointType: 'Standard'
    isHnsEnabled: false
    isLocalUserEnabled: false
    isNfsV3Enabled: false
    isSftpEnabled: false
    keyPolicy: {
      keyExpirationPeriodInDays: keyExpirationPeriodInDays 
    }
    largeFileSharesState: largeFileSharesState
    minimumTlsVersion: 'TLS1_2'
    networkAcls: networkAcls
    publicNetworkAccess: publicNetworkAccess
    supportsHttpsTrafficOnly: true
  }
}

resource blobService 'Microsoft.Storage/storageAccounts/blobServices@2024-01-01' = if (deployBlobService) {
  name: blobServiceName
  parent: storageAccount
  properties: {
    changeFeed: {
      enabled: true
      retentionInDays: 7
    }
    containerDeleteRetentionPolicy: {
      allowPermanentDelete: true
      days: 30
      enabled: true
    }
    deleteRetentionPolicy: {
      allowPermanentDelete: true
      days: 30
      enabled: true
    }
    isVersioningEnabled: false
    restorePolicy: {
      days: 28
      enabled: true
    }
  }
}

resource blobContainer 'Microsoft.Storage/storageAccounts/blobServices/containers@2024-01-01' = [for i in range(0, length(blobContainerNames)): {
  name: blobContainerNames[i]
  parent: blobService
  properties: {
    immutableStorageWithVersioning: {
      enabled: false
    }
    publicAccess: 'Blob'
  }
}]

module privateEndpoint 'br/CoreModulesDEV:privateendpoints:1.0' = if (empty(privateEndpointName) == false) {  
  name: 'storage.pept'
  params: {
    privateEndpointName: privateEndpointName
    serviceResourceId: storageAccount.id
    privateDnsZoneId: privateDnsZoneId
    groupIds: [
      'blob'
      'file'
      'queue'
      'table'
      'dfs'
    ]
    subnetId: resourceId(privatelinkVnetResourceGroupName,'Microsoft.Network/virtualNetworks/subnets', privatelinkVnetName, privatelinkSubnetName)
    tags: tags
  }
}
