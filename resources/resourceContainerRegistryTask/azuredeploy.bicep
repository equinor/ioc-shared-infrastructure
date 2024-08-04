// Version 1.0
@minLength(5)
@maxLength(50)
@description('Provide a globally unique name of your Azure Container Registry')
param registryName string
@description('Provide a location for the registry.')
param location string = resourceGroup().location
@description('Dictionary of tag names and values.')
param tags object = {}
@description('Provide the base64 encoded content of the task.')
param base64EncodedTaskContent string

resource acrResource 'Microsoft.ContainerRegistry/registries@2021-11-01' existing = {
  name: registryName
}

resource acrTaskResource 'Microsoft.ContainerRegistry/registries/tasks@2019-06-01-preview' = {
  name: 'weeklyPurgeTask'
  location: location
  tags: tags
  parent: acrResource
  properties: {
    agentConfiguration: {
      cpu: 2
    }
    isSystemTask: false
    platform: {
      architecture: 'amd64'
      os: 'linux'
    }
    step: {
      type: 'EncodedTask'
      encodedTaskContent: base64EncodedTaskContent
      // For remaining properties, see TaskStepProperties objects
    }
    timeout: 3600
    trigger: {
      baseImageTrigger: {
        baseImageTriggerType: 'Runtime'
        updateTriggerPayloadType: 'Default'
        status: 'Enabled'
        name: 'defaultBaseimageTriggerName'
      }
      timerTriggers: [
        {
          schedule: '0 1 * * Sun'
          status: 'Enabled'
          name: 't1'
        }
      ]
    }
  }
}
