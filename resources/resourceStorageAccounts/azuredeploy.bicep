// Version 1.0
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

resource storageAccount 'Microsoft.Storage/storageAccounts@2023-01-01' = {
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

resource blobService 'Microsoft.Storage/storageAccounts/blobServices@2023-01-01' = if (deployBlobService) {
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

resource blobContainer 'Microsoft.Storage/storageAccounts/blobServices/containers@2023-01-01' = [for i in range(0, length(blobContainerNames)): {
  name: blobContainerNames[i]
  parent: blobService
  properties: {
    immutableStorageWithVersioning: {
      enabled: false
    }
    publicAccess: 'Blob'
  }
}]
