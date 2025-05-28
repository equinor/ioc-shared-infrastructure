// Version 1.0 Module privatednszone
param existing bool = false
param privateEndpointName string
param privateIpAddress string
param privateDnsZoneName string = ''
param ttl int = 36000
param tags object = {}

resource privateDnsZoneResource 'Microsoft.Network/privateDnsZones@2024-06-01' = if (!existing) {
  location: 'global'
  name: privateDnsZoneName
  properties: {}
  tags: tags
}

resource privateDnsZone 'Microsoft.Network/privateDnsZones@2024-06-01' existing = {
  name: privateDnsZoneName
}

resource dnsZoneA 'Microsoft.Network/privateDnsZones/A@2024-06-01' = if (privateEndpointName != '') {
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
