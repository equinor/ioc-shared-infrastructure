// Version 1.0

@description('Specifies the name of the public IP')
param publicIpName string
@description('The DNS label for the public IP address. This label is used to create a fully qualified domain name (FQDN) for the public IP address.')
param publicIpDnsLabel string
param idleTimeoutInMinutes int = 4
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
    publicIPAddressVersion: 'IPv4'
    publicIPAllocationMethod: 'Static'
    dnsSettings: {
      domainNameLabel: publicIpDnsLabel
    }
    idleTimeoutInMinutes: idleTimeoutInMinutes
  }
}
