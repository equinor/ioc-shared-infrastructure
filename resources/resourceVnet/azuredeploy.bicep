// Version 2.1 Module vnet
param vnetName string
param addressSpacePrefix array = ['10.1.0.0/16']
param subnets array = []
param tags object = {}
param location string = resourceGroup().location
param dnsServerIps array = []

resource virtualNetwork 'Microsoft.Network/virtualNetworks@2023-11-01' = {
  name: vnetName
  location: location
  tags: tags
  properties: {
    addressSpace: {
      addressPrefixes: addressSpacePrefix
    }
    dhcpOptions: {
      dnsServers: dnsServerIps
    }
    subnets: subnets
  }
}

output vnetId string = virtualNetwork.id
