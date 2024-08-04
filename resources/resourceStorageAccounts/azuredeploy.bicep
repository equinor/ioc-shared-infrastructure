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
param networkAcls object = {
  defaultAction: 'Allow'
  bypass: 'AzureServices'
}
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
    publicNetworkAccess: 'string'
    supportsHttpsTrafficOnly: true
  }
}
