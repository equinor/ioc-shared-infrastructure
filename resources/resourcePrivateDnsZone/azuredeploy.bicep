// Version 1.0 Module privatednszone
param privateEndpointName string
param privateIpAddress string
param vnetId string
param privateDnsZoneName string = ''
param ttl int = 36000
param tags object = {}

resource privateDnsZoneResource 'Microsoft.Network/privateDnsZones@2024-06-01' = {
  location: 'global'
  name: privateDnsZoneName
  properties: {}
  tags: tags
}

resource privateDnsZone 'Microsoft.Network/privateDnsZones@2024-06-01' existing = {
  name: privateDnsZoneName
}

resource vnetLink 'Microsoft.Network/privateDnsZones/virtualNetworkLinks@2024-06-01' = {
  parent: privateDnsZone
  name: '${privateDnsZoneName}-vnet-link'
  location: 'global'
  properties: {
    registrationEnabled: false
    virtualNetwork: {
      id: vnetId
    }
  }
}

resource dnsZoneA 'Microsoft.Network/privateDnsZones/A@2024-06-01' = {
  parent: privateDnsZone
  name: privateEndpointName
  properties: {
    ttl: ttl
    aRecords: [
      {
        ipv4Address: privateIpAddress
      }
    ]
  }
}

output zoneId string = privateDnsZone.id
