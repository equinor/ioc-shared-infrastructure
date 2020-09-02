# Postgresql databases

Create databases in a postgres database server

| Parameter | Type   | Required | Description                       |
|-----------|--------|----------|-----------------------------------|
| server    | string | yes      | The name of the postgres server   |
| databases | array  | yes      | A list of databases to be created |

This is an example parameter file

```json
{
    "server": {
        "value": "<Postgres server name>"
    },
    "databases": {
        "value": [
            "azure_sys",
            "azure_maintenance",
            "ioc-frontend"
        ]
    }
}
```

