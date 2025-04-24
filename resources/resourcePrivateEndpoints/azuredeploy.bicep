// Version 1.0
param privateEndpointName string
param tags object = {}
@description('Resource ID of the App Service (or other service, e.g. postgres-server) to connect to the private endpoint.')
param serviceResourceId string
param subnetId string
param groupIds array = [
  'sites'
]
param privateLinkServiceConnections array = [
  {
    name: 'privateLinkServiceConnection'
    properties: {
      privateLinkServiceId: serviceResourceId
      groupIds: groupIds
      privateLinkServiceConnectionState: {
        status: 'Approved'
        description: 'Private endpoint connection approved.'
      }
      requestMessage: 'Deployed via bicep template.'
    }
  }
]

param location string = resourceGroup().location

var networkInterfaceName = '${privateEndpointName}-nic'

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
