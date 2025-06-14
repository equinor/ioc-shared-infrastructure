// Version 1.1 Module keyvault
param tenantId string
param keyvaultName string
param accessPolicies array = []
param tags object = {}
param networkAcls object = {
  defaultAction: 'Allow'
  bypass: 'AzureServices'
}
@allowed(['Enabled', 'Disabled'])
param publicNetworkAccess string = 'Enabled'
param sku object
param softDeleteRetentionInDays int = 90

@description('Key Vault with Private Endpoint. This module creates a private endpoint for the keyvault if privateEndpointName is defined.')
param privateEndpointName string = ''
@description('The name of the resource group where the virtual network is located.')
param vnetResourceGroupName string = ''
@description('The name of the virtual network where the private endpoint will be created.')
param vnetName string = ''
@description('The name of the subnet where the private endpoint will be created.')
param subnetName string = ''
@description('The private DNS zone ID for the Key Vault private endpoint. This is optional and can be used to link the private endpoint to a private DNS zone.')
param privateDnsZoneId string = ''

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

module privateEndpointKeyvault 'br/CoreModulesDEV:privateendpoints:1.0' = if (empty(privateEndpointName) == false) {  
  name: 'keyvault.pept'
  params: {
    privateEndpointName: privateEndpointName
    serviceResourceId: keyvaultResource.id
    privateDnsZoneId: privateDnsZoneId
    groupIds: [
      'vault'
    ]
    subnetId: resourceId(vnetResourceGroupName,'Microsoft.Network/virtualNetworks/subnets', vnetName, subnetName)
    tags: tags
  }
}

output privateIpAddress string = empty(privateEndpointName) ? '' : privateEndpointKeyvault.outputs.privateIpAddress
