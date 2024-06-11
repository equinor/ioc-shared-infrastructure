// Version 1.0
param vnetName string
param subnetName string = 'default'
param natGatewayName string
param addressPrefix string = '10.1.0.0/24'
param addressSpacePrefix string = '10.1.0.0/16'
param tags object = {}
param location string = resourceGroup().location

resource natGateway 'Microsoft.Network/natGateways@2023-11-01' existing = {
  name: natGatewayName
}

resource virtualNetwork 'Microsoft.Network/virtualNetworks@2023-11-01' = {
  name: vnetName
  location: location
  tags: tags
  properties: {
    addressSpace: {
      addressPrefixes: [
        addressSpacePrefix
      ]
    }
    subnets: [
      {
        name: subnetName
        properties: {
          addressPrefix: addressPrefix
          delegations: [
            {
              name: 'delegation'
              properties: {
                serviceName: 'Microsoft.Web/serverFarms'
              }
            }
          ]
          natGateway: {
            id: natGateway.id
          }
        }
      }
    ]
  }
}
