# App Configuration Store

Creates an application configuration.

Parameters:

| Parameter             | Type   | Required | Description                                                    |
|-----------------------|--------|----------|----------------------------------------------------------------|
| appConfigName         | String | Yes      | The name of the application config                             |
| tagComponent          | String | Yes      | The Component tag, i.e. "Model Editor Api"                     |
| tagEnvironment        | String | Yes      | The Environment tag, i.e. "Dev"                                |
| location              | String | No       | The resource location                                          |
| sku                   | String | No       | The cost-tier of the registry, default is 'Standard'           |
| keyValuePairs         | Array  | No       | An array of key-value pairs to populate the config store       |
| keyVaultReferences    | Array  | No       | An array of keyvault references to populate the config store   |
| featureFlags          | Array  | No       | An array of feature-flags to populate the config store         |
| disableLocalAuth      | Bool   | No       | Indicates if local auth is disabled, defaults is false         |
| publicNetworkAccess   | String | No       | Access restriction setting, defaults is 'Enabled'              |
