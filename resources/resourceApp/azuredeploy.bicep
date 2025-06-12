// Version 1.5 Module webapp
param webAppName string
param location string = resourceGroup().location
param tags object
param appserviceResourceId string
param containerRegistryName string
param containerImageName string = webAppName
param containerImageTag string
param appGatewayIp string
param appCommandLine string = ''
param allowedCorsOrigins array = json(' [ ] ')
param acrResourceGroup string = resourceGroup().name

param environmentVariables array
@description('''Public network access for the web app. Possible values are 'Enabled' and 'Disabled'. Default is 'Disabled'.''')
param publicNetworkAccess string = 'Disabled'
@description('''Gets or sets whether CORS requests with credentials are allowed. Default is false.''')
param supportCredentials bool = false
@description('''Azure Storage Accounts. Default is an empty object.''')
param azureStorageAccounts object = {}

param healthCheckPath string = ''
param http20Enabled bool = true
param numberOfWorkers int = 1
param webSitesPort int = 8080
param ouboundVnetName string = ''
param outboundSubnetName string = 'default'
param outboundVnetConnectionName string = 'vnet-connection'
param outboundVnetSubnetId string = ''

@description('''Server with Private Endpoint. This module creates a private endpoint for the server if privateEndpointName is defined.
NB! For existing servers a private endpoint might not be eligible for creation.''')
param privateEndpointName string = ''
@description('The name of the resource group where the virtual network is located.')
param privatelinkVnetResourceGroupName string = ''
@description('The name of the virtual network where the private endpoint will be created.')
param privatelinkVnetName string = ''
@description('The name of the subnet where the private endpoint will be created.')
param privatelinkSubnetName string = ''
@description('The private DNS zone ID')
param privateDnsZoneId string

var webapp_dns_name = '.azurewebsites.net'

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
var virtualNetworkProperties = (outboundVnetSubnetId != '') ? {
  virtualNetworkSubnetId: outboundVnetSubnetId
  vnetRouteAllEnabled: true
} : {}

var vnetNameProperty = (ouboundVnetName != '') ? {
  vnetName: ouboundVnetName
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
    ipSecurityRestrictionsDefaultAction: 'Deny'
    ipSecurityRestrictions: [
      !empty(appGatewayIp) ? {
        ipAddress: appGatewayIp
        action: 'Allow'
        priority: 100
        name: 'Allow IOC Application Gateway'
      } : {}
    ]
    azureStorageAccounts: azureStorageAccounts
    ...vnetNameProperty
  }
}

resource webAppBinding 'Microsoft.Web/sites/hostNameBindings@2024-04-01' = {
  parent: webApp
  name: '${webApp.name}${webapp_dns_name}'
  properties: {
    siteName: webApp.name
    hostNameType: 'Verified'
  }
}

resource vnetConnection 'Microsoft.Web/sites/virtualNetworkConnections@2023-12-01' = if (!empty(ouboundVnetName)) {
  parent: webApp
  name: outboundVnetConnectionName
  properties: {
    vnetResourceId: resourceId('Microsoft.Network/virtualNetworks/subnets', ouboundVnetName, outboundSubnetName)
    isSwift: true
  }
}

module privateEndpoint 'br/CoreModulesDEV:privateendpoints:1.0' = if (empty(privateEndpointName) == false) {  
  name: 'webapp.pept'
  params: {
    privateEndpointName: privateEndpointName
    serviceResourceId: webApp.id
    privateDnsZoneId: privateDnsZoneId
    groupIds: [
      'sites'
    ]
    subnetId: resourceId(privatelinkVnetResourceGroupName,'Microsoft.Network/virtualNetworks/subnets', privatelinkVnetName, privatelinkSubnetName)
    tags: tags
  }
}

output objectId string = webApp.id
output identityObjectId string = webApp.identity.principalId
output privateIpAddress string = empty(privateEndpointName) ? '' : privateEndpoint.outputs.privateIpAddress
