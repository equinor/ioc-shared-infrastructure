// Version 1.0
param workspaceName string
param location string = resourceGroup().location
param sku string = 'Standard'
param enableDataExport bool = true
param disableLocalAuth bool = false
param retentionInDays int = 30
param dailyQuotaGb int = 1
param tags object

resource workspace 'Microsoft.OperationalInsights/workspaces@2023-09-01' = {
  name: workspaceName
  location: location
  tags: tags
  properties: {
    features: {
      disableLocalAuth: disableLocalAuth
      enableDataExport: enableDataExport
      enableLogAccessUsingOnlyResourcePermissions: true
      immediatePurgeDataOn30Days: false
    }
    retentionInDays: retentionInDays
    sku: {
      name: sku
    }
    workspaceCapping: {
      dailyQuotaGb: dailyQuotaGb
    }
  }
}

output logAnalyticsWorkspaceId string = workspace.id
