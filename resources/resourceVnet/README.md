# VNET

This template can be used to deploy a Virtual Network

![Resource view](overview.png)

## Template parameters

| Parameter name     | Type   | Required | Value                                                   |
|--------------------|--------|----------|---------------------------------------------------------|
| vnetName           | string | Yes      | Specifies the name of the vnet.                         |
| subnets            | array  | No       | A list of subnets. Default empty                        |
| addressSpacePrefix | string | No       | An address space used by the vnet. Default '10.1.0.0/16 |
| tags               | object | No       | Tags to identify the resource. Default empty            |
| location           | string | No       | The azure location of the vnet. Default rg-location     |

Examples:

```
subnets: [
      {
        name: subnetName
        properties: {
          addressPrefix: '10.1.0.0/24'
          addressPrefixes: [
            'string'
          ]
          defaultOutboundAccess: bool
          delegations: [
            {
              name: 'string'
              properties: {
                serviceName: 'Microsoft.Web/serverFarms'
              }
            }
          ]
          ipAllocations: [
            {
              id: 'string'
            }
          ]
          natGateway: empty(natGatewayName) ? null : {
            id: natGateway.id
          }
          networkSecurityGroup: {
            id: 'security-group-id'
          }
          routeTable: {
            id: 'string'
          }
          serviceEndpoints: [
            {
              locations: [
                'string'
              ]
              networkIdentifier: {
                id: 'string
              }
              service: 'string'
            }
          ]
          privateEndpointNetworkPolicies: 'string'
        }
      }
    ]
```