// Version 2.0 Module vnet
param vnetName string
param addressSpacePrefix array = ['10.1.0.0/16']
param subnets array = []
param tags object = {}
param location string = resourceGroup().location
param privateDnsZoneName string = ''
param virtualNetworkLinkName string = ''
param linkAutoRegistration bool = false

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

resource privateDnsZone 'Microsoft.Network/privateDnsZones@2024-06-01' = if (!empty(privateDnsZoneName)) {
  location: 'global'
  name: privateDnsZoneName
  properties: {}
  tags: tags
}

resource virtualNetworkLink 'Microsoft.Network/privateDnsZones/virtualNetworkLinks@2024-06-01' = if (!empty(virtualNetworkLinkName)) {
  parent: privateDnsZone
  location: 'global'
  name: virtualNetworkLinkName
  properties: {
    registrationEnabled: linkAutoRegistration
    virtualNetwork: {
      id: virtualNetwork.id
    }
  }
  tags: tags
}
