# Log Analytics Workspace

Creates a Log Analytics Workspace instance. Parameters:

| Parameter       | Type   | Required | Description                                    |
|-----------------|--------|----------|------------------------------------------------|
| workspaceName   | String | Yes      | Name of workspace instance                  |
| location        | String | No       | Azure location to deploy in                    |
| sku             | String | No      | The payment tier used for this resource     |
| enableDataExport| Bool   | No       | Indicates whether to enable data export from workspace |
| disableLocalAuth| Bool   | No       | Indicates whether to allow local authentication to access workspace |
| retentionInDays | Int    | No       | Number of days to keep data |
| dailyQuotaGb    | Int    | No       | Allowed daily space |
| tags            | Object | Yes      | Tags associated with the app insights instance |

Outputs:

| Parameter       | Type   | Description |
|-----------------|--------|-------------|
| logAnalyticsWorkspaceId   | String | Id of workspace instance, used as input for app insights resource |


See the [documentation for applications insights](../resourceAppInsights/README.md) for an example

