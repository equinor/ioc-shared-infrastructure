@description('The name of the hosting plan.')
param appServicePlanName string

@description('The names sku used for the appserivce plan.')
@allowed([
  'B1' // Basic
  'B2' // Basic
  'B3' // Basic
  'S1' // Standard
  'S2' // Standard
  'S3' // Standard
  'P1V2' // Premium V2
  'P2V2' // Premium V2
  'P3V2' // Premium V2
  'P1V3' // Premium V3
  'P2V3' // Premium V3
  'P3V3' // Premium V3
  'Y1' // Dynamic consumption plan
])
param appServicePlanSku string = 'Y1'

@description('The name of the function app.')
param functionAppName string

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

@description('The workspace resource id')
param workspaceResourceId string

@description('The ingestion mode used for the app insights')
param ingestionMode string = 'LogAnalytics'
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

@description('The name of the app insights.')
var appinsightsName = replace(functionAppName, '-func-', '-appi-')

var appSettingKeys = [
  {
    name: 'AzureWebJobsStorage'
    value: 'DefaultEndpointsProtocol=https;AccountName=${storageAccountName};AccountKey=${listKeys(storageAccountId,'2019-06-01').keys[0].value}'
  }
  {
    name: 'APPINSIGHTS_INSTRUMENTATIONKEY'
    value: appinsights.properties.InstrumentationKey
  }
]

// The Application Insights Resource
resource appinsights 'Microsoft.Insights/components@2020-02-02' = {
  name: appinsightsName
  location: location
  tags: tags
  kind: 'web'
  properties: {
    Application_Type: 'web'
    Request_Source: 'rest'
    RetentionInDays: 90
    IngestionMode: ingestionMode
    publicNetworkAccessForIngestion: 'Enabled'
    publicNetworkAccessForQuery: 'Enabled'
    WorkspaceResourceId: workspaceResourceId
  }
}

// The Storage Account Resource
resource storageAccount 'Microsoft.Storage/storageAccounts@2023-05-01' = {
  name: storageAccountName
  location: location
  tags: tags
  kind: 'StorageV2'
  sku: {
    name: 'Standard_LRS'
  }
  properties: {
    networkAcls: {
      bypass: 'AzureServices'
      defaultAction: 'Allow'
    }
    supportsHttpsTrafficOnly: true
    minimumTlsVersion: 'TLS1_2'
    encryption: {
      services: {
        file: {
          keyType: 'Account'
          enabled: true
        }
        blob: {
          keyType: 'Account'
          enabled: true
        }
      }
      keySource: 'Microsoft.Storage'
    }
  }
}

// The App Service Plan Resource
resource appServicePlan 'Microsoft.Web/serverfarms@2024-04-01' = {
  name: appServicePlanName
  location: location
  kind: 'linux'
  properties: {
    reserved: true
  }
  sku: {
    name: appServicePlanSku
  }
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
output appInsightsName string = appinsightsName
