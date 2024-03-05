param webAppName string
param location string = resourceGroup().location
param tags object
param appserviceResourceId string
param containerRegistryName string
param containerImageName string = webAppName
param containerImageTag string
param environmentVariables array
param appGatewayIp string
param appCommandLine string = ''
param allowedCorsOrigins array = json(' [ ] ')
param supportCredentials bool = false
param acrResourceGroup string = resourceGroup().name
param azureStorageAccounts object = {}

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
]

resource webApp 'Microsoft.Web/sites@2022-03-01' = {
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
      appSettings: union(globalAppSettings, environmentVariables, createSettingsObject('DOCKER_REGISTRY_SERVER_URL', reference(resourceId(acrResourceGroup, 'Microsoft.ContainerRegistry/registries/', containerRegistryName), '2022-12-01').loginServer), createSettingsObject('DOCKER_REGISTRY_SERVER_USERNAME', listCredentials(resourceId(acrResourceGroup, 'Microsoft.ContainerRegistry/registries/', containerRegistryName), '2022-12-01').username), createSettingsObject('DOCKER_REGISTRY_SERVER_PASSWORD', listCredentials(resourceId(acrResourceGroup, 'Microsoft.ContainerRegistry/registries/', containerRegistryName), '2022-12-01').passwords[0].value))
      appCommandLine: appCommandLine
    }
    httpsOnly: true
  }
}

resource webAppName_web 'Microsoft.Web/sites/config@2022-03-01' = {
  parent: webApp
  name: 'web'
  properties: {
    numberOfWorkers: 1
    alwaysOn: true
    cors: {
      allowedOrigins: allowedCorsOrigins
      supportCredentials: supportCredentials
    }
    http20Enabled: false
    minTlsVersion: '1.2'
    ftpsState: 'Disabled'
    ipSecurityRestrictions: [
      {
        ipAddress: appGatewayIp
        action: 'Allow'
        priority: 100
        name: 'Allow IOC Application Gateway'
      }
    ]
    azureStorageAccounts: azureStorageAccounts
  }
}

output objectId string = webApp.id
output identityObjectId string = webApp.identity.principalId
