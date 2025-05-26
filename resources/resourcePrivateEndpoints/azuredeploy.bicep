// Version 1.0 Module privateendpoints
param privateEndpointName string
param tags object = {}
@description('Resource ID of the App Service (or other service, e.g. postgres-server) to connect to the private endpoint.')
param serviceResourceId string
param subnetId string
param groupIds array = [
  'sites'
]
param location string = resourceGroup().location

@description('Id of private DNS zone to which this private endpoint shall belong. Optional.')
param privateDnsZoneId string = ''
param dnsZoneGroupName string = 'default'
param privateDnsZoneGroupConfigName string = 'config1'

var networkInterfaceName = '${privateEndpointName}-nic'

param privateLinkServiceConnections array = [
  {
    name: privateEndpointName
    properties: {
      privateLinkServiceId: serviceResourceId
      groupIds: groupIds
      privateLinkServiceConnectionState: {
        status: 'Approved'
        description: 'Private endpoint connection approved.'
        actionsRequired: 'None'
      }
    }
    type: 'Microsoft.Network/privateEndpoints/privateLinkServiceConnections'
  }
]

resource customNetworkInterface 'Microsoft.Network/networkInterfaces@2024-05-01' = {
  location: location
  name: networkInterfaceName
  properties: {
    auxiliaryMode: 'None'
    auxiliarySku: 'None'
    disableTcpStateTracking: false
    enableAcceleratedNetworking: false
    enableIPForwarding: false
    ipConfigurations: [
      {
        name: '${privateEndpointName}-ipconfig'
        properties: {
          applicationSecurityGroups: []
          primary: true
          privateIPAddressVersion: 'IPv4'
          privateIPAllocationMethod: 'Dynamic'
          subnet: {
            id: subnetId
          }
        }
        type: 'Microsoft.Network/networkInterfaces/ipConfigurations'
      }
    ]
    nicType: 'Standard'
  }
  tags: tags
}

resource privateEndpointsResource 'Microsoft.Network/privateEndpoints@2024-05-01' = {
  name: privateEndpointName
  location: location
  tags: tags
  properties: {
    subnet: {
      id: subnetId
    }
    privateLinkServiceConnections: privateLinkServiceConnections
    customNetworkInterfaceName: networkInterfaceName
  }
}

resource dnsZoneGroup 'Microsoft.Network/privateEndpoints/privateDnsZoneGroups@2024-05-01' = if (!empty(privateDnsZoneId)) {
  parent: privateEndpointsResource
  name: dnsZoneGroupName
  properties: {
    privateDnsZoneConfigs: [
      {
        name: privateDnsZoneGroupConfigName
        properties: {
          privateDnsZoneId: privateDnsZoneId
        }
      }
    ]
  }
}
