// Version 1.0

@allowed([
  'Single'
  'Labels'
  'Multiple'
])
param activeRevisionsMode string = 'Single'

@description('Specifies the name of the container app.')
param containerAppName string

@description('Specifies the name of the container app environment.')
param containerAppEnvName string

@description('Specifies the login server for the container registry.')
param containerRegistryLoginServer string

@description('Specifies the location for all resources.')
param location string = resourceGroup().location

@description('Specifies the docker container image to deploy.')
param containerImage string

@description('Specifies the container port.')
param targetPort int = 80

@description('Specifies if the container app should allow insecure traffic.')
param ingressAllowInsecure bool = false

@description('Specifies if the container app should allow external traffic.')
param ingressExternal bool = true

@description('Minimum number of replicas that will be deployed')
@minValue(0)
@maxValue(25)
param minReplicas int = 1

@description('Maximum number of replicas that will be deployed')
@minValue(0)
@maxValue(25)
param maxReplicas int = 3

@description('Number of CPU cores the container can use. Can be with a maximum of two decimals.')
@allowed([
  '0.25'
  '0.5'
  '0.75'
  '1'
  '1.25'
  '1.5'
  '1.75'
  '2'
])
param cpuCore string = '0.5'

@description('Amount of memory (in gibibytes, GiB) allocated to the container up to 4GiB. Can be with a maximum of two decimals. Ratio with CPU cores must be equal to 2.')
@allowed([
  '0.5'
  '1'
  '1.5'
  '2'
  '3'
  '3.5'
  '4'
])
param memorySize string = '1'

@description('Specifies the name of the Log Analytics workspace.')
param logAnalyticsWorkspaceName string

@description('Specifies the tags for the resources.')
param tags object

param containerRegistryUsername string
@secure()
param containerRegistryPassword string

var acrPullRole = resourceId('Microsoft.Authorization/roleDefinitions', '7f951dda-4ed3-4680-a7ca-43fe172d538d')

param envVars array = []

resource logAnalytics 'Microsoft.OperationalInsights/workspaces@2023-09-01' existing = {
  name: logAnalyticsWorkspaceName
  scope: resourceGroup()
}

resource uai 'Microsoft.ManagedIdentity/userAssignedIdentities@2023-07-31-preview' = {
  name: 'id-${containerAppName}'
  location: location
}

resource containerAppEnv 'Microsoft.App/managedEnvironments@2024-10-02-preview' = {
  name: containerAppEnvName
  location: location
  properties: {
    appLogsConfiguration: {
      destination: 'log-analytics'
      logAnalyticsConfiguration: {
        customerId: logAnalytics.properties.customerId
        sharedKey: logAnalytics.listKeys().primarySharedKey
      }
    }
  }
}

// This step is required to allow the container app to access the registry and pull images, but it requires ownership in the ResourceGroup to assign the role.
// Due to this, the we leave this step commented out and the user will need to manually assign the role or request a ResourceGroup owner to assign the role.
// @description('This allows the managed identity of the container app to access the registry, note scope is applied to the wider ResourceGroup not the ACR')
// resource uaiRbac 'Microsoft.Authorization/roleAssignments@2022-04-01' = {
//   name: guid(resourceGroup().id, uai.id, acrPullRole)
//   properties: {
//     roleDefinitionId: acrPullRole
//     principalId: uai.properties.principalId
//     principalType: 'ServicePrincipal'
//   }
// }

resource containerApp 'Microsoft.App/containerApps@2024-10-02-preview' = {
  location: location
  name: containerAppName
  identity: {
    type: 'UserAssigned'
    userAssignedIdentities: {
      '${uai.id}': {}
    }
  }
  tags: tags
  properties: {
    managedEnvironmentId: containerAppEnv.id
    configuration: {
      activeRevisionsMode: activeRevisionsMode
      secrets: [
        {
          name: 'container-registry-password'
          value: containerRegistryPassword
        }
      ]
      registries: [
        {
          server: containerRegistryLoginServer
          identity: uai.id
          username: containerRegistryUsername
          passwordSecretRef: 'container-registry-password'
        }
      ]
      ingress: {
        external: ingressExternal
        targetPort: targetPort
        allowInsecure: ingressAllowInsecure
        traffic: [
          {
            latestRevision: true
            weight: 100
          }
        ]
      }
    }
    template: {
        containers: [
          {
            name: containerAppName
            image: containerImage
            env: envVars
            resources: {
              cpu: json(cpuCore)
              memory: '${memorySize}Gi'
            }
          }
        ]
        scale: {
          minReplicas: minReplicas
          maxReplicas: maxReplicas
        }
    }
  }
}

output containerAppFQDN string = containerApp.properties.configuration.ingress.fqdn
