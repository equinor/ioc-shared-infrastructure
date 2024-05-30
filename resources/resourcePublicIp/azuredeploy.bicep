// Version 1.0

@description('Specifies the name of the public IP')
param publicIpName string
param location string = resourceGroup().location
param tags object
param skuName string = 'Standard'

resource publicIp 'Microsoft.Network/publicIpAddresses@2023-11-01' = {
  name: publicIpName
  location: location
  tags: tags
  sku: {
    name: skuName
  }
  properties: {
    publicIPAllocationMethod: 'Static'
  }
}
