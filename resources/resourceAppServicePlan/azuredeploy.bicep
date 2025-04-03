// Version 1.1
param appServicePlanName string

@allowed([
  'B1' // Basic Small
  'B2' // Basic Medium
  'B3' // Basic Large
  'S1' // Standard Small
  'S2' // Standard Medium
  'S3' // Standard Large
  'P1V2' // Premium V2 Small
  'P2V2' // Premium V2 Medium
  'P3V2' // Premium V2 Large
  'P1V3' // Premium V3 Small
  'P2V3' // Premium V3 Medium
  'P3V3' // Premium V3 Large
  'Y1' // Dynamic consumption plan
  'PC2' // Premium Container Small
  'PC3' // Premium Container Medium
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
