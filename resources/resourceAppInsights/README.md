# Application Insights

Creates an application insights instance. Parameters:

| Parameter       | Type   | Required | Description                                    |
|-----------------|--------|----------|------------------------------------------------|
| appInsightsName | String | Yes      | Name of app insights instance                  |
| location        | String | No       | Azure location to deploy in                    |
| tags            | Object | Yes      | Tags associated with the app insights instance |
| workspaceResourceId | String | Yes  | id associated with a loganalytics workspace    |
| ingestionMode   | String | No       | Indicates the flow of the ingestion ('ApplicationInsights', 'ApplicationInsightsWithDiagnosticSettings' or 'LogAnalytics') |


See the [documentation for web applications](../resourceApp/README.md) for an example

