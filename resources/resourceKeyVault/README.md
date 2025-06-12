# Key Vault

A single keyvault; typically deployed along with an application to contain its own
secrets.

## Bicep parameters

| Parameter name                | Type   | Required | Value                                                                                         |
|-----------------------        |--------|----------|-----------------------------------------------------------------------------------------------|
| tenantId                      | string | Yes      | The tenant id                                                                                 |
| keyvaultName                  | string | Yes      | The name of the keyvault                                                                      |
| accessPolicies                | array  | No       | A list of access policies                                                                     |
| tags                          | object | No       | Resource tags                                                                                 |
| networkAcls                   | string | No       | The network firewall default and bypass configuration                                         |
| publicNetworkAccess           | string | No       | Firewall config parameter. Defaults to 'Enabled'                                              |
| sku                           | object | No       | The keyvault sku object                                                                       |
| softDeleteRetentionInDays     | int    | No       | Keep deleted secrets for x days. Default is 90 days. NB! cannot be changed after first deploy |
| privateEndpointName           | string | No       | The name of the private endpoint. Optional                                                    |
| vnetResourceGroupName         | string | No       | The name of the resource group where the virtual network is located                           |
| vnetName                      | string | No       | The vnet name for the private endpoint                                                        |
| subnetName                    | string | No       | The subnet name for the private endpoint                                                      |
| privateDnsZoneName            | string | No       | The private dns-zone to register the private endpoint                                         |
| dnsZoneGroupName              | string | No       | The name of a dns-zone group                                                                  |
| privateDnsZoneGroupConfigName | object | No       | The name of a dns-zone group config                                                           |

![Resource view](overview.png)
