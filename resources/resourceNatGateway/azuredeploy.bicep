// Version 1.0
param name string
param publicIpAddressName string
param tags object
param location string = resourceGroup().location
param sku string = 'Standard'
param zones array = []
param idleTimeoutInMinutes int = 4

resource publicIpAddress 'Microsoft.Network/publicIpAddresses@2023-11-01' existing = {
  name: publicIpAddressName
}

resource natGateway 'Microsoft.Network/natGateways@2023-11-01' = {
  name: name
  location: location
  tags: tags
  sku: {
    name: sku
  }
  zones: zones
  properties: {
    publicIpAddresses: [
      {
        id: publicIpAddress.id
      }
    ]
    publicIpPrefixes: []
    idleTimeoutInMinutes: idleTimeoutInMinutes
  }
  dependsOn: [
    publicIpAddress
  ]
}
