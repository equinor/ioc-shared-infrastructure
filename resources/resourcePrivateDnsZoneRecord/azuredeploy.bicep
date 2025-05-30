// Version 1.0 Module dnszonerecord
param privateDnsZoneName string
param privateEndpointName string
param privateIpAddress string
param ttl int

resource privateDnsZone 'Microsoft.Network/privateDnsZones@2024-06-01' existing = {
  name: privateDnsZoneName
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
