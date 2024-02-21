@description('Specifies the name of the key vault.')
param keyVaultName string

@description(
  'Specifies the Azure Active Directory tenant ID that should be used for authenticating requests to the key vault. Get it by using Get-AzSubscription cmdlet.'
)
param tenantId string = subscription().tenantId

@description(
  'Specifies a list of object IDs of users, service principals or security groups in the Azure Active Directory tenant for the vault.'
)
param objectIds array

@description(
  'Specifies the permissions to secrets in the vault. https://docs.microsoft.com/en-us/azure/templates/microsoft.keyvault/2023-07-01/vaults'
)
param permissions object = {
  secrets: ['list']
}

resource keyVaultName_add 'Microsoft.KeyVault/vaults/accessPolicies@2023-07-01' = {
  name: '${keyVaultName}/add'
  properties: {
    accessPolicies: [
      for item in objectIds: {
        tenantId: tenantId
        objectId: item
        permissions: permissions
      }
    ]
  }
}
