// Version 2.0 Module vnet
param vnetName string
param addressSpacePrefix array = ['10.1.0.0/16']
param subnets array = []
param tags object = {}
param location string = resourceGroup().location

resource virtualNetwork 'Microsoft.Network/virtualNetworks@2023-11-01' = {
  name: vnetName
  location: location
  tags: tags
  properties: {
    addressSpace: {
      addressPrefixes: addressSpacePrefix
    }
    subnets: subnets
  }
}

output vnetId string = virtualNetwork.id
