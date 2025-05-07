# VNET

This template can be used to deploy a Virtual Network

![Resource view](overview.png)

## Template parameters

| Parameter name     | Type   | Required | Value                                                   |
|--------------------|--------|----------|---------------------------------------------------------|
| vnetName           | string | Yes      | Specifies the name of the vnet.                         |
| natGatewayName     | string | No       | A NAT Gateway to connect the subnet(s). Default empty   |
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
          delegations: [
            {
              name: 'delegation'
              properties: {
                serviceName: 'Microsoft.Web/serverFarms'
              }
            }
          ]
          natGateway: empty(natGatewayName) ? null : {
            id: natGateway.id
          }
        }
      }
    ]
```