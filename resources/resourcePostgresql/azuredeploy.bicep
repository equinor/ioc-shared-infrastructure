// Version 1.0
@description('Resulting name of the resource.')
param postgresServerName string
param tags object

@description('Location for the resources.')
param location string = resourceGroup().location
param postgresVersion string = '11'
param sku object = {
  name: 'GP_Gen5_2'
  tier: 'GeneralPurpose'
  family: 'Gen5'
  capacity: 2
}
param administratorLogin string

@secure()
param administratorLoginPassword string

resource postgresServer 'Microsoft.DBforPostgreSQL/servers@2017-12-01' = {
  name: postgresServerName
  location: location
  tags: tags
  sku: sku
  properties: {
    storageProfile: {
      storageMB: 102400
      backupRetentionDays: 7
      geoRedundantBackup: 'Disabled'
      storageAutogrow: 'Disabled'
    }
    version: postgresVersion
    administratorLogin: administratorLogin
    administratorLoginPassword: administratorLoginPassword
    sslEnforcement: 'Enabled'
    minimalTlsVersion: 'TLS1_2'
    infrastructureEncryption: 'Disabled'
    publicNetworkAccess: 'Enabled'
  }
}

resource postgresServerName_AllowAllWindowsAzureIps 'Microsoft.DBforPostgreSQL/servers/firewallRules@2017-12-01' = {
  parent: postgresServer
  name: 'AllowAllWindowsAzureIps'
  properties: {
    startIpAddress: '0.0.0.0'
    endIpAddress: '0.0.0.0'
  }
}

resource postgresServerName_Equinor_Bergen 'Microsoft.DBforPostgreSQL/servers/firewallRules@2017-12-01' = {
  parent: postgresServer
  name: 'Equinor-Bergen'
  properties: {
    startIpAddress: '143.97.2.35'
    endIpAddress: '143.97.2.35'
  }
}

resource postgresServerName_Equinor_Statoil_Approved 'Microsoft.DBforPostgreSQL/servers/firewallRules@2017-12-01' = {
  parent: postgresServer
  name: 'Equinor-Statoil-Approved'
  properties: {
    startIpAddress: '143.97.2.129'
    endIpAddress: '143.97.2.129'
  }
}

output postgresServer string = postgresServerName
