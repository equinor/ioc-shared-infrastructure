// Version 1.0
@description('Specifies the name of the key vault.')
param keyVaultName string

@description('The secrets to create in the key vault.')
@secure()
param keyVaultSecrets object
param activationTime int = 0
param expiryTime int = 0

resource keyVaultName_keyVaultSecrets_secrets_name 'Microsoft.KeyVault/vaults/secrets@2023-07-01' = [
  for i in range(0, length(keyVaultSecrets.secrets)): {
    name: '${keyVaultName}/${keyVaultSecrets.secrets[i].name}'
    properties: {
      value: keyVaultSecrets.secrets[i].value
      contentType: keyVaultSecrets.secrets[i].contentType
      attributes: {
        enabled: true
        exp: ((expiryTime == 0) ? null : expiryTime)
        nbf: ((activationTime == 0) ? null : activationTime)
      }
    }
  }
]
