// Version 1.4 Module webapp
param webAppName string
param location string = resourceGroup().location
param tags object
param appserviceResourceId string
param containerRegistryName string
param containerImageName string = webAppName
param containerImageTag string
param environmentVariables array
param publicNetworkAccess string = 'Disabled'
param appGatewayIp string
param appCommandLine string = ''
param allowedCorsOrigins array = json(' [ ] ')
param supportCredentials bool = false
param acrResourceGroup string = resourceGroup().name
param azureStorageAccounts object = {}
param healthCheckPath string = ''
param http20Enabled bool = true
param numberOfWorkers int = 1
param webSitesPort int = 8080
param vnetConnectionName string = 'vnet-connection'
param vnetName string = ''
param subnetName string = 'default'
param virtualNetworkSubnetId string = ''

@description('''Server with Private Endpoint. This module creates a private endpoint for the server if privateEndpointName is defined.
NB! For existing servers a private endpoint might not be eligible for creation.''')
param privateEndpointName string = ''
@description('The name of the resource group where the virtual network is located.')
param privatelinkVnetResourceGroupName string = ''
@description('The name of the virtual network where the private endpoint will be created.')
param privatelinkVnetName string = ''
@description('The name of the subnet where the private endpoint will be created.')
param privatelinkSubnetName string = ''

func createSettingsObject (key string, value string) array => [
  {
    name: key
    value: value
  }
]

var globalAppSettings = [
  {
    name: 'WEBSITES_ENABLE_APP_SERVICE_STORAGE'
    value: 'false'
  }
  {
    name: 'DOCKER_ENABLE_CI'
    value: 'true'
  }
  {
    name: 'WEBSITES_PORT'
    value: webSitesPort
  }
]
var virtualNetworkProperties = (virtualNetworkSubnetId != '') ? {
  virtualNetworkSubnetId: virtualNetworkSubnetId
  vnetRouteAllEnabled: true
} : {}

var vnetNameProperty = (vnetName != '') ? {
  vnetName: vnetName
} : {}

resource webApp 'Microsoft.Web/sites@2023-12-01' = {
  name: webAppName
  location: location
  tags: tags
  identity: {
    type: 'SystemAssigned'
  }
  properties: {
    enabled: true
    serverFarmId: appserviceResourceId
    clientAffinityEnabled: false
    siteConfig: {
      linuxFxVersion: 'DOCKER|${containerRegistryName}.azurecr.io/${toLower(containerImageName)}:${containerImageTag}'
      appSettings: union(globalAppSettings, environmentVariables, createSettingsObject('DOCKER_REGISTRY_SERVER_URL', reference(resourceId(acrResourceGroup, 'Microsoft.ContainerRegistry/registries/', containerRegistryName), '2023-07-01').loginServer), createSettingsObject('DOCKER_REGISTRY_SERVER_USERNAME', listCredentials(resourceId(acrResourceGroup, 'Microsoft.ContainerRegistry/registries/', containerRegistryName), '2023-07-01').username), createSettingsObject('DOCKER_REGISTRY_SERVER_PASSWORD', listCredentials(resourceId(acrResourceGroup, 'Microsoft.ContainerRegistry/registries/', containerRegistryName), '2023-07-01').passwords[0].value))
      appCommandLine: appCommandLine
    }
    httpsOnly: true
    ...virtualNetworkProperties
  }
}

resource webAppName_web 'Microsoft.Web/sites/config@2023-12-01' = {
  parent: webApp
  name: 'web'
  properties: {
    numberOfWorkers: numberOfWorkers
    alwaysOn: true
    cors: {
      allowedOrigins: allowedCorsOrigins
      supportCredentials: supportCredentials
    }
    http20Enabled: http20Enabled
    minTlsVersion: '1.2'
    ftpsState: 'Disabled'
    healthCheckPath: healthCheckPath
    publicNetworkAccess: publicNetworkAccess
    ipSecurityRestrictions: [
      {
        ipAddress: appGatewayIp
        action: 'Allow'
        priority: 100
        name: 'Allow IOC Application Gateway'
      }
    ]
    azureStorageAccounts: azureStorageAccounts
    ...vnetNameProperty
  }
}

resource vnetConnection 'Microsoft.Web/sites/virtualNetworkConnections@2023-12-01' = if (!empty(vnetName)) {
  parent: webApp
  name: vnetConnectionName
  properties: {
    vnetResourceId: resourceId('Microsoft.Network/virtualNetworks/subnets', vnetName, subnetName)
    isSwift: true
  }
}

module privateEndpoint 'br/CoreModulesDEV:privateendpoints:1.0' = if (empty(privateEndpointName) == false) {  
  name: 'webapp.pept'
  params: {
    privateEndpointName: privateEndpointName
    serviceResourceId: webApp.id
    groupIds: [
      'sites'
    ]
    subnetId: resourceId(privatelinkVnetResourceGroupName,'Microsoft.Network/virtualNetworks/subnets', privatelinkVnetName, privatelinkSubnetName)
    tags: tags
  }
}

output objectId string = webApp.id
output identityObjectId string = webApp.identity.principalId
