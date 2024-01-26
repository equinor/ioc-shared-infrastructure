@minLength(5)
@maxLength(50)
@description('Provide a globally unique name of your Azure Container Registry')
param registryName string
@description('Provide a location for the registry.')
param location string = resourceGroup().location
@description('Provide a tier of your Azure Container Registry.')
param sku string = 'Basic'
@description('Enable admin user for the registry.')
param adminUserEnabled bool = true
@description('Dictionary of tag names and values.')
param tags object = {}

resource acrResource 'Microsoft.ContainerRegistry/registries@2023-07-01' = {
  name: registryName
  location: location
  sku: {
    name: sku
  }
  tags: tags
  properties: {
    adminUserEnabled: adminUserEnabled
    policies: {
      quarantinePolicy: {
        status: 'disabled'
      }
      trustPolicy: {
        type: 'Notary'
        status: 'disabled'
      }
      retentionPolicy: {
        days: 7
        status: 'disabled'
      }
    }
    encryption: {
      status: 'disabled'
    }
    dataEndpointEnabled: false
    publicNetworkAccess: 'Enabled'
  }
}

@description('Output the login server property for later use')
output loginServer string = acrResource.properties.loginServer
