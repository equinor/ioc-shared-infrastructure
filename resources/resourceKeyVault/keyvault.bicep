param tenantId string
param vaultUri string
param accessPolicies array = []
param tags object = {}
param networkAcls object = {}
param publicNetworkAccess string = 'Enabled'
param sku object = {}
param softDeleteRetentionInDays int = 90

var rgScope = resourceGroup()

resource keyvaultResource 'Microsoft.KeyVault/vaults@2023-07-01' = {
  name: 'string'
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
    vaultUri: vaultUri
  }
}
