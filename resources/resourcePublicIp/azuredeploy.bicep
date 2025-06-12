// Version 1.2 Module publicip

@description('Specifies the name of the public IP')
param publicIpName string
@description('The DNS label for the public IP address. This label is used to create a fully qualified domain name (FQDN) for the public IP address.')
param publicIpDnsLabel string
@description('Availability zones for the public IP')
param zones string[] = ['NoZone']
param idleTimeoutInMinutes int = 4
param location string = resourceGroup().location
param tags object
param skuName string = 'Standard'

@description('Enable delete lock')
param enableDeleteLock bool = false

var publicIpLockName = '${publicIp.name}-lck'


resource publicIp 'Microsoft.Network/publicIpAddresses@2023-11-01' = {
  name: publicIpName
  location: location
  tags: tags
  zones: zones
  sku: {
    name: skuName
  }
  properties: {
    publicIPAddressVersion: 'IPv4'
    publicIPAllocationMethod: 'Static'
    deleteOption: 'Detach'
    dnsSettings: {
      domainNameLabel: publicIpDnsLabel
    }
    idleTimeoutInMinutes: idleTimeoutInMinutes
  }
}

resource publicIpAddressLock 'Microsoft.Authorization/locks@2020-05-01' = if (enableDeleteLock) {
  scope: publicIp
  name: publicIpLockName
  properties: {
    level: 'CanNotDelete'
  }
}

output publicIpId string = publicIp.id
output publicIpAddress string = publicIp.properties.ipAddress
