// Version 1.0
param tenantId string
param keyvaultName string
param accessPolicies array = []
param tags object = {}
param networkAcls object = {
  defaultAction: 'Allow'
  bypass: 'AzureServices'
}
param publicNetworkAccess string = 'Enabled'
param sku object
param softDeleteRetentionInDays int = 90

var rgScope = resourceGroup()

resource keyvaultResource 'Microsoft.KeyVault/vaults@2023-07-01' = {
  name: keyvaultName
  location: rgScope.location
  tags: tags
  properties: {
    accessPolicies: accessPolicies
    createMode: 'default'
    enabledForDeployment: true
    enabledForDiskEncryption: true
    enabledForTemplateDeployment: true
    enablePurgeProtection: true
    enableRbacAuthorization: false
    enableSoftDelete: true
    networkAcls: networkAcls
    provisioningState: 'Succeeded'
    publicNetworkAccess: publicNetworkAccess
    sku: sku
    softDeleteRetentionInDays: softDeleteRetentionInDays
    tenantId: tenantId
  }
}
