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

resource privateEndpointsResource 'Microsoft.Network/privateEndpoints@2024-05-01' = {
  name: privateEndpointName
  location: location
  tags: tags
  properties: {
    subnet: {
      id: subnetId
    }
    customNetworkInterfaceName: networkInterfaceName
    privateLinkServiceConnections: privateLinkServiceConnections
  }
}

resource networkInterface 'Microsoft.Network/networkInterfaces@2024-05-01' existing = {
  name: networkInterfaceName
}

output privateIpAddress string = networkInterface.properties.ipConfigurations[0].properties.privateIPAddress
