// Version 1.0
param appServicePlanName string

@allowed([
  'S1'
  'P1V2'
  'P2V2'
  'P3V2'
  'P1V3'
  'P2V3'
  'P3V3'
  'PC2'
  'PC3'
])
param appServicePlanSku string = 'P1V2'
param location string = resourceGroup().location
param tags object

resource appServicePlan 'Microsoft.Web/serverfarms@2023-12-01' = {
  name: appServicePlanName
  location: location
  tags: tags
  sku: {
    name: appServicePlanSku
  }
  kind: 'linux'
  properties: {
    perSiteScaling: false
    maximumElasticWorkerCount: 1
    reserved: true
  }
}

output resourceId string = appServicePlan.id
