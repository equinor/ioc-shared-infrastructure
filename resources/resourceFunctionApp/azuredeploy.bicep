// Version 1.0

@description('The name of the hosting plan.')
param appServicePlanName string

@description('The names sku used for the appservice plan.')
param appServicePlanSku string = 'Y1'

@description('The name of the function app.')
param functionAppName string

@description('The name of the app insights.')
param appInsightsName string = replace(functionAppName, '-func-', '-appi-')

@description('The azure active directory client id')
param aadClientId string = ''

@description('The name of the storage account used by the function(s).')
param storageAccountName string

@description('The runtime language, defaults to python.')
@allowed([
  'PYTHON'
  'RUBY'
  'NODE'
  'PHP'
  'WILDFLY'
  'DOTNETCORE'
  'TOMCAT'
  'JAVA'
])
param stackName string = 'PYTHON'

@description('The version of the runtime language.')
param stackVersion string = '3.10'

@description('Resource location')
param location string = resourceGroup().location

param tags object

@description('The SiteConfig settings for the function app')
param appSettings array = [
  {
    name: 'FUNCTIONS_WORKER_RUNTIME'
    value: 'python'
  }
  {
    name: 'FUNCTIONS_EXTENSION_VERSION'
    value: '~4'
  }
]

@description('The id of the storage account used by the functions app.')
var storageAccountId = storageAccount.id

var appSettingKeys = [
  {
    name: 'AzureWebJobsStorage'
    value: 'DefaultEndpointsProtocol=https;AccountName=${storageAccountName};AccountKey=${listKeys(storageAccountId,'2019-06-01').keys[0].value}'
  }
  {
    name: 'APPINSIGHTS_INSTRUMENTATIONKEY'
    value: appInsights.properties.InstrumentationKey
  }
]

// Reference to existing app service plan
resource appServicePlan 'Microsoft.Web/serverfarms@2024-04-01' existing= {
  name: appServicePlanName
}

// Reference to existing app insights
resource appInsights 'Microsoft.Insights/components@2020-02-02' existing= {
  name: appInsightsName
}

// Reference to existing storage account
resource storageAccount 'Microsoft.Storage/storageAccounts@2023-05-01' existing= {
  name: storageAccountName
}

// The Function App Resource
resource functionApp 'Microsoft.Web/sites@2024-04-01' = {
  name: functionAppName
  kind: 'functionapp,linux'
  location: location
  tags: tags
  identity: {
    type: 'SystemAssigned'
  }
  properties: {
    enabled: true
    siteConfig: {
      linuxFxVersion: '${toUpper(stackName)}|${stackVersion}'
      alwaysOn: (appServicePlanSku != 'Y1')
      appSettings: union(
        appSettings,
        appSettingKeys
      )
      cors: {
        allowedOrigins: json(' [ ] ')
        supportCredentials: false
      }
      http20Enabled: false
      minTlsVersion: '1.2'
      ftpsState: 'Disabled'
    }
    serverFarmId: appServicePlan.id
    clientAffinityEnabled: false
    reserved: true
    dailyMemoryTimeQuota: 0
    httpsOnly: true
    redundancyMode: 'None'
  }
}

// The Function Apps Authorization Configuration
resource functionAppAuthConfig 'Microsoft.Web/sites/config@2024-04-01' = {
  name: 'authsettings'
  parent: functionApp
  properties: {
    enabled: (length(aadClientId) > 0)
    unauthenticatedClientAction: 'RedirectToLoginPage'
    defaultProvider: 'AzureActiveDirectory'
    tokenRefreshExtensionHours: 6
    clientId: aadClientId
    issuer: 'https://sts.windows.net/${subscription().tenantId}/'
  }
}

output objectId string = functionApp.id
output identityObjectId string = reference(functionApp.id, '2024-04-01', 'full').identity.principalId
output appInsightsName string = appInsightsName
