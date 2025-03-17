// Version 1.1
param appServicePlanName string

@allowed([
  'S1'
  'B1'
  'B2'
  'B3'
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
@description('The number of instances assigned to this resource')
param skuCapacity int = 1

param location string = resourceGroup().location
param tags object

resource appServicePlan 'Microsoft.Web/serverfarms@2024-04-01' = {
  name: appServicePlanName
  location: location
  tags: tags
  sku: {
    name: appServicePlanSku
    size: appServicePlanSku
    capacity: skuCapacity
  }
  kind: 'linux'
  properties: {
    perSiteScaling: false
    reserved: true
  }
}

output resourceId string = appServicePlan.id
