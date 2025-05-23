// Version 1.0 Module appgateway

@description('Name of the application/solution. Will be used for generating resource names.')
param applicationName string
@allowed(['dev', 'test', 'prod'])
@description('Environment name (used as suffix for naming resources).')
param applicationEnvironment string
@description('VNet address prefix and subnet address.')
param vnetAddressPrefix array
@description('Vnet subnets. Defaults to a basic subnet for application gateway.')
param subnets array = [
  {
    name: '${applicationName}-snet-${applicationEnvironment}'
    addressPrefix: vnetAddressPrefix[0]
    serviceEndpoints: [
      'Microsoft.Storage'
      'Microsoft.Sql'
    ]
  }
]
@description('ID to the KeyVault certificate secret used for SSL.')
param sslCertificateKeyVaultId string
@description('List of geo regions to allow traffic from.')
param allowGeoRegionsList array = []
@description('List of IP`s that aren`t restricted by regions. Can be known developer static IP`s or other trusted IP`s.')
param allowIpList array = []
@description('List of URL`s that aren`t restricted by regions. Can be API endpoints')
param allowUrlList array = []
@description('List of path segments that are exempted from firewall policies.')
param firewallExclusionList array = []
@description('''
List of applications to configure in the application gateway. Array of objects.
Format: { name: testapp01, fqdn: testapp01.azurewebsites.net, rootpath: /, paths: [/testapp01], requesttimeout: 300, subnets: [] }
''')
param applications array = []
@description('Default application (name of app)')
param defaultApplication string
@description('Configure to run security scan on request body. Default is true')
param requestBodyCheck bool = true
@description('Auto scale configuration. Defaults to 0 - 10.')
param autoscaleConfiguration object = {
  minCapacity: 0
  maxCapacity: 10
}
@description('The location (Azure region) of the application gateway.')
param location string = resourceGroup().location
param tags object = {}
@description('Type of ssl policy.')
param sslPolicyType string = 'Custom'
@description('Minimum version requirement for ssl protocol.')
param sslMinProtocolVersion string = 'TLSv1_2'
@description('List of ciphers to use for the ssl policy.')
param sslCipherSuites array = [
  'TLS_RSA_WITH_AES_256_CBC_SHA256'
  'TLS_ECDHE_RSA_WITH_AES_256_CBC_SHA384'
  'TLS_ECDHE_RSA_WITH_AES_128_GCM_SHA256'
  'TLS_ECDHE_RSA_WITH_AES_128_CBC_SHA256'
  'TLS_DHE_RSA_WITH_AES_128_GCM_SHA256'
  'TLS_RSA_WITH_AES_128_GCM_SHA256'
  'TLS_RSA_WITH_AES_128_CBC_SHA256'
]
@description('The owasp ruleset version to apply.')
param owaspRuleSetVersion string = '3.2'
@description('The Microsoft_BotManagerRuleSet version to apply.')
param botManagerRuleSet string = '1.0'

@description('Public IP availability zones.')
param availabilityZones string[] = ['1', '2', '3']

var applicationGatewayName = '${applicationName}-agw-${applicationEnvironment}'
var applicationGatewayFirewallPolicyName = '${applicationName}-policy-${applicationEnvironment}'
var applicationGatewaySku = 'WAF_v2'

var publicIpv4AddressName = '${applicationName}-pip-${applicationEnvironment}'
var publicIpv4DnsLabel = toLower(applicationGatewayName)
var publicIpSku = 'Standard'

var logAnalyticsWorkspaceName = '${applicationName}-log-${applicationEnvironment}'
var logAnalyticsWorkspaceSku = 'PerGB2018'

var vnetName = '${applicationName}-vnet-${applicationEnvironment}'
var vnetSubnetName = '${applicationName}-snet-${applicationEnvironment}'
var networkSecurityGroupName = '${applicationName}-nsg-${applicationEnvironment}'

var identityName = '${applicationName}-agw-${applicationEnvironment}-identity'

var denyAllPathsMatchValue = ['/*']

resource identityResource 'Microsoft.ManagedIdentity/userAssignedIdentities@2024-11-30' = {
  location: location
  name: identityName
  tags: tags
}

module logAnalyticsWorkspaceResource 'br/CoreModulesDEV:laworkspace:1.0' = {
  name: 'law.deploy'
  params: {
    location: location
    workspaceName: logAnalyticsWorkspaceName
    sku: logAnalyticsWorkspaceSku
    tags: tags
  }
}

resource networkSecurityGroupResource 'Microsoft.Network/networkSecurityGroups@2023-11-01' = {
  name: networkSecurityGroupName
  location: location
  tags: tags
  properties: {
    securityRules: [
      {
        name: 'HTTP'
        properties: {
          protocol: 'TCP'
          sourcePortRange: '*'
          destinationPortRange: '80'
          sourceAddressPrefix: '*'
          destinationAddressPrefix: '*'
          access: 'Allow'
          priority: 200
          direction: 'Inbound'
        }
      }
      {
        name: 'HTTPS'
        properties: {
          protocol: 'TCP'
          sourcePortRange: '*'
          destinationPortRange: '443'
          sourceAddressPrefix: '*'
          destinationAddressPrefix: '*'
          access: 'Allow'
          priority: 300
          direction: 'Inbound'
        }
      }
      {
        name: 'agw-management-traffic'
        properties: {
          protocol: 'TCP'
          sourcePortRange: '*'
          destinationPortRange: '65200-65535'
          sourceAddressPrefix: '*'
          destinationAddressPrefix: '*'
          access: 'Allow'
          priority: 400
          direction: 'Inbound'
        }
      }
      {
        name: 'AllowHTTPSOutbound'
        properties: {
          protocol: 'TCP'
          sourcePortRange: '*'
          destinationPortRange: '443'
          sourceAddressPrefix: '*'
          destinationAddressPrefix: '*'
          access: 'Allow'
          priority: 400
          direction: 'Outbound'
        }
      }
    ]
  }
}

module publicIpAddressResource 'br/CoreModulesDEV:publicip:1.1' = {
  name: 'pip.deploy'
  params: {
    location: location
    publicIpName: publicIpv4AddressName
    publicIpDnsLabel: publicIpv4DnsLabel
    zones: availabilityZones
    skuName: publicIpSku
    tags: tags
  }
}

module vnetResource 'br/CoreModulesDEV:vnet:2.0' = {
  name: 'vnet.deploy'
  params: {
    location: location
    vnetName: vnetName
    addressSpacePrefix: vnetAddressPrefix
    subnets: subnets
    tags: tags
  }
}

resource diagServiceResource 'Microsoft.Insights/diagnosticSettings@2021-05-01-preview' = {
  name: '${applicationGatewayName}-diagsettings'
  scope: applicationGatewayResource
  properties: {
    workspaceId:  logAnalyticsWorkspaceResource.outputs.logAnalyticsWorkspaceId
    logs: [
      {
        category: 'ApplicationGatewayAccessLog'
        enabled: true
        retentionPolicy: {
          enabled: true
          days: 30
        }
      }
      {
        category: 'ApplicationGatewayPerformanceLog'
        enabled: true
        retentionPolicy: {
          enabled: true
          days: 30
        }
      }
      {
        category: 'ApplicationGatewayFirewallLog'
        enabled: true
        retentionPolicy: {
          enabled: true
          days: 30
        }
      }
    ]
    metrics: [
      {
        category: 'AllMetrics'
        enabled: true
        retentionPolicy: {
          enabled: true
          days: 30
        }
      }
    ]
  }
}

resource applicationGatewayResource 'Microsoft.Network/applicationGateways@2023-11-01' = {
  name: applicationGatewayName
  location: location
  identity: {
    type: 'UserAssigned'
    userAssignedIdentities: {
      '${identityResource.id}': {}
    }
  }
  tags: tags
  properties: {
    sku: {
      name: applicationGatewaySku
      tier: applicationGatewaySku
    }
    enableHttp2: true
    autoscaleConfiguration: autoscaleConfiguration
    gatewayIPConfigurations: [
      {
        name: 'application-gateway-ipconfig'
        properties: {
          subnet: {
            id: resourceId('Microsoft.Network/virtualNetworks/subnets', vnetName, vnetSubnetName)
          }
        }
      }
    ]
    frontendIPConfigurations: [
      {
        name: 'application-gateway-public-ipv4'
        properties: {
          publicIPAddress: {
            id: publicIpAddressResource.outputs.publicIpId
          }
        }
      }
    ]
    frontendPorts: [
      {
        name: 'port_80'
        properties: {
          port: 80
        }
      }
      {
        name: 'port_443'
        properties: {
          port: 443
        }
      }
    ]
    requestRoutingRules: [
      {
        name: 'ioc-applications-routing-rule'
        properties: {
          ruleType: 'PathBasedRouting'
          priority: 10010
          httpListener: {
            id: resourceId('Microsoft.Network/applicationGateways/httpListeners', applicationGatewayName, 'https-listener')
          }
          urlPathMap: {
            id: resourceId('Microsoft.Network/applicationGateways/urlPathMaps', applicationGatewayName, 'default-urlpathmaps')
          }
        }
      }
      {
        name: 'http-to-https-routing-rule'
        properties: {
          ruleType: 'Basic'
          priority: 10020
          httpListener: {
            id: resourceId('Microsoft.Network/applicationGateways/httpListeners', applicationGatewayName, 'http-listener')
          }
          redirectConfiguration: {
            id: resourceId('Microsoft.Network/applicationGateways/redirectConfigurations', applicationGatewayName, 'http-to-https-redirect-config')
          }
        }
      }
    ]
    rewriteRuleSets: [
      {
        name: 'forward-host-header'
        properties: {
          rewriteRules: [
            {
              name: 'forward-host-header-rule'
              ruleSequence: 100
              conditions: []
              actionSet: {
                requestHeaderConfigurations: [
                  {
                    headerName: 'X-Forwarded-Host'
                    headerValue: '{var_host}'
                  }
                  {
                    headerName: 'X-Forwarded-Proto'
                    headerValue: '{var_request_scheme}'
                  }
                ]
                responseHeaderConfigurations: []
              }
            }
          ]
        }
      }
    ]
    redirectConfigurations: [
      {
        name: 'http-to-https-redirect-config'
        properties: {
          redirectType: 'Permanent'
          targetListener: {
            id: resourceId('Microsoft.Network/applicationGateways/httpListeners', applicationGatewayName, 'https-listener')
          }
          includePath: true
          includeQueryString: true
        }
      }
    ]
    httpListeners: [
      {
        name: 'http-listener'
        properties: {
          firewallPolicy: {
            id: resourceId('Microsoft.Network/applicationGatewayWebApplicationFirewallPolicies', applicationGatewayFirewallPolicyName)
          }
          frontendIPConfiguration: {
            id: resourceId('Microsoft.Network/applicationGateways/frontendIPConfigurations', applicationGatewayName, 'application-gateway-public-ipv4')
          }
          frontendPort: {
            id: resourceId('Microsoft.Network/applicationGateways/frontendPorts', applicationGatewayName, 'port_80')
          }
          protocol: 'Http'
          sslCertificate: null
          requireServerNameIndication: false          
        }
      }
      {
        name: 'https-listener'
        properties: {
          firewallPolicy: {
            id: resourceId('Microsoft.Network/applicationGatewayWebApplicationFirewallPolicies', applicationGatewayFirewallPolicyName)
          }
          frontendIPConfiguration: {
            id: resourceId('Microsoft.Network/applicationGateways/frontendIPConfigurations', applicationGatewayName, 'application-gateway-public-ipv4')
          }
          frontendPort: {
            id: resourceId('Microsoft.Network/applicationGateways/frontendPorts', applicationGatewayName, 'port_443')
          }
          sslCertificate: {
            id: resourceId('Microsoft.Network/applicationGateways/sslCertificates', applicationGatewayName, 'default-appgw-ssl-cert')
          }
          protocol: 'Https'
          requireServerNameIndication: false
        }
      }
    ]
    sslCertificates: [
      {
        name: 'default-appgw-ssl-cert'
        properties: {
          keyVaultSecretId: sslCertificateKeyVaultId
          password: null
        }
      }
    ]
    sslPolicy: {
      policyType: sslPolicyType
      minProtocolVersion: sslMinProtocolVersion
      cipherSuites: sslCipherSuites
    }
    firewallPolicy: {
      id: resourceId('Microsoft.Network/applicationGatewayWebApplicationFirewallPolicies', applicationGatewayFirewallPolicyName)
    }
    forceFirewallPolicyAssociation: true
    urlPathMaps: [
      {
        name: 'default-urlpathmaps'
        properties: {
          defaultBackendAddressPool: {
            id: resourceId('Microsoft.Network/applicationGateways/backendAddressPools', applicationGatewayName, '${defaultApplication}-pool')
          }
          defaultBackendHttpSettings: {
            id: resourceId('Microsoft.Network/applicationGateways/backendHttpSettingsCollection', applicationGatewayName, '${defaultApplication}-http-settings')
          }
          pathRules: [
            for app in applications: {
              name: '${app.name}-routing-rule'
              properties: {
                paths: app.paths
                backendAddressPool: {
                  id: resourceId('Microsoft.Network/applicationGateways/backendAddressPools', applicationGatewayName, '${app.name}-pool')
                }
                backendHttpSettings: {
                  id: resourceId('Microsoft.Network/applicationGateways/backendHttpSettingsCollection', applicationGatewayName, '${app.name}-http-settings')
                }
                rewriteRuleSet: {
                  id: resourceId('Microsoft.Network/applicationGateways/rewriteRuleSets', applicationGatewayName, 'forward-host-header')
                }
              }
            }
          ]
        }
      }
    ]
    backendAddressPools: [
      for app in applications: {
        name: '${app.name}-pool'
        properties: {
          backendAddresses: [
            {
              fqdn: app.fqdn
            }
          ]
        }
      }
    ]
    probes: [
      for app in applications: {
        name: '${app.name}-probe'
        properties: {
          protocol: 'Https'
          host: app.fqdn
          path: '/ping'
          interval: 60
          timeout: 30
          unhealthyThreshold: 6
        }
      }
    ]
    backendHttpSettingsCollection: [
      for app in applications: {
        name: '${app.name}-http-settings'
        properties: {
          port: 443
          protocol: 'Https'
          cookieBasedAffinity: 'Disabled'
          requestTimeout: app.requesttimeout
          pickHostNameFromBackendAddress: true
          probe: {
            id: resourceId('Microsoft.Network/applicationGateways/probes', applicationGatewayName, '${app.name}-probe')
          }
        }
      }
    ]
  }
}

resource applicationGatewayFirewallPolicyResource 'Microsoft.Network/applicationGatewayWebApplicationFirewallPolicies@2023-11-01' = {
  name: applicationGatewayFirewallPolicyName
  location: location
  tags: tags
  properties: {
    policySettings: {
      mode: 'Prevention'
      state: 'Enabled'
      requestBodyCheck: requestBodyCheck
      maxRequestBodySizeInKb: 128
      fileUploadLimitInMb: 128
    }
    managedRules: {
      managedRuleSets: [
        {
          ruleSetType: 'Microsoft_BotManagerRuleSet'
          ruleSetVersion: botManagerRuleSet
        }
        {
          ruleSetType: 'OWASP'
          ruleSetVersion: owaspRuleSetVersion
        }
      ]
      exclusions: firewallExclusionList
    }
    customRules: [
          {
            name: 'AllowIpAddresses'
            priority: 10
            ruleType: 'MatchRule'
            action: 'Allow'
            matchConditions: [
              {
                matchVariables: [
                  {
                    variableName: 'RemoteAddr'
                  }
                ]
                operator: 'IPMatch'
                negationConditon: false
                matchValues: allowIpList
                transforms: []
              }
            ]
          }
          {
            name: 'AllowUrls'
            priority: 20
            ruleType: 'MatchRule'
            action: 'Allow'
            matchConditions: [
              {
                matchVariables: [
                  {
                    variableName: 'RequestUri'
                  }
                ]
                operator: 'Contains'
                negationConditon: false
                matchValues: allowUrlList
                transforms: [
                  'Lowercase'
                ]
              }
            ]
          }
          {
            name: 'AllowApprovedGeoTraffic'
            priority: 80
            ruleType: 'MatchRule'
            action: 'Allow'
            matchConditions: [
              {
                matchVariables: [
                  {
                    variableName: 'RemoteAddr'
                  }
                ]
                operator: 'GeoMatch'
                negationConditon: false
                matchValues: allowGeoRegionsList
                transforms: []
              }
            ]
          }
          {
            name: 'DenyOthers'
            priority: 100
            ruleType: 'MatchRule'
            action: 'Block'
            matchConditions: [
              {
                matchVariables: [
                  {
                    variableName: 'RequestUri'
                  }
                ]
                operator: 'BeginsWith'
                negationConditon: false
                matchValues: denyAllPathsMatchValue
                transforms: []
              }
            ]
          }
        ]
  }
}

output publicIpAddress string = publicIpAddressResource.outputs.publicIpAddress
output logAnalyticsWorkspaceId string = logAnalyticsWorkspaceResource.outputs.logAnalyticsWorkspaceId
