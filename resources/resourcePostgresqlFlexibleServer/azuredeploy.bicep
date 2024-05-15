// Version 1.0
param administratorLogin string

@secure()
param administratorLoginPassword string
param tenantId string = '3aa4a235-b6e2-48d5-9195-7fcf05b459b0'
param authPasswdConfig string = 'Enabled'
param activeDirectoryAuthConfig string = 'Enabled'

@description('Location for the resources.')
param location string = resourceGroup().location
param tags object

@description('Resulting name of the resource.')
param postgresServerName string
param sku object = {
  name: 'Standard_D4ds_v4'
  tier: 'GeneralPurpose'
}
param backupRetention int = 90
param geoRedundantBackup string = 'Disabled'
param haMode string = 'Disabled'
param availabilityZone string = '1'
@allowed([
  '11'
  '12'
  '13'
  '14'
  '15'
])
param postgresVersion string = '15'
param virtualNetworkExternalId string = ''
param subnetName string = ''
param privateDnsZoneArmResourceId string = ''
@description('Flag to enable / disable Storage Auto grow for flexible server.')
param autoGrow string = 'Disabled'
@allowed([
  'P1'
  'P10'
  'P15'
  'P2'
  'P20'
  'P3'
  'P30'
  'P4'
  'P40'
  'P50'
  'P6'
  'P60'
  'P70'
  'P80'
])
@description('Name of storage tier for IOPS.')
param storageTier string = 'P10'
param storageSizeGB int = 128
param customMaintenanceWindow string = 'Disabled'
param customMaintenanceWindowDayOfWeek int = 6
param customMaintenanceWindowStartHour int = 0
param customMaintenanceWindowStartMinute int = 30

resource postgresServer 'Microsoft.DBforPostgreSQL/flexibleServers@2023-03-01-preview' = {
  name: postgresServerName
  location: location
  tags: tags
  sku: sku
  properties: {
    version: postgresVersion
    administratorLogin: administratorLogin
    administratorLoginPassword: administratorLoginPassword
    authConfig: {
      activeDirectoryAuth: activeDirectoryAuthConfig
      passwordAuth: authPasswdConfig
      tenantId: tenantId
    }
    network: {
      delegatedSubnetResourceId: (empty(virtualNetworkExternalId)
        ? null
        : json('${virtualNetworkExternalId}/subnets/${subnetName}'))
      privateDnsZoneArmResourceId: (empty(virtualNetworkExternalId) ? null : privateDnsZoneArmResourceId)
    }
    maintenanceWindow: {
      customWindow: customMaintenanceWindow
      dayOfWeek: customMaintenanceWindowDayOfWeek
      startHour: customMaintenanceWindowStartHour
      startMinute: customMaintenanceWindowStartMinute
    }
    highAvailability: {
      mode: haMode
    }
    storage: {
      autoGrow: autoGrow
      storageSizeGB: storageSizeGB
      tier: storageTier
    }
    backup: {
      backupRetentionDays: backupRetention
      geoRedundantBackup: geoRedundantBackup
    }
    availabilityZone: availabilityZone
  }
}

resource postgresServerName_AllowAllWindowsAzureIps 'Microsoft.DBforPostgreSQL/flexibleServers/firewallRules@2022-12-01' = {
  parent: postgresServer
  name: 'AllowAllWindowsAzureIps'
  properties: {
    startIpAddress: '0.0.0.0'
    endIpAddress: '0.0.0.0'
  }
}

resource postgresServerName_Equinor_Bergen 'Microsoft.DBforPostgreSQL/flexibleServers/firewallRules@2022-12-01' = {
  parent: postgresServer
  name: 'Equinor-Bergen'
  properties: {
    startIpAddress: '143.97.2.35'
    endIpAddress: '143.97.2.35'
  }
}

resource postgresServerName_Equinor_Statoil_Approved 'Microsoft.DBforPostgreSQL/flexibleServers/firewallRules@2022-12-01' = {
  parent: postgresServer
  name: 'Equinor-Statoil-Approved'
  properties: {
    startIpAddress: '143.97.2.129'
    endIpAddress: '143.97.2.129'
  }
}

output postgresServer string = postgresServerName
output fullyQualifiedDomainName string = postgresServer.properties.fullyQualifiedDomainName
