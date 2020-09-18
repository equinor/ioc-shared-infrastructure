# SQL User Management module

The SQL User Management module is created to ease the work of managing users on the different databases in the project.

Currently the module supports creating users that are active directory group, managed identities and sql logins. However if the user is of type sql login then the password is added to a given KeyVault. If the app registration is found it is given get permission on secrets to the access policies.

## TODO

  -Add support for users + role definitions
  -Add support for Invoke-SqlCmd so that this module can be run automated without exposing secrets.

## Requirements

Make sure that you have Powershell 7 installed and Azure Powershell.

- The installer for Powershell 7 can be found at [GitHub](https://github.com/PowerShell/PowerShell/releases).
- Once Powershell 7 are installed run the script **install-azurepowershell.ps1** to install Azure Powershell.

## Instructions

### Importing the module

To use the SqlUserManagement module it must be imported.

The easies way to start using the module and to experiment is to clone this  GitHub repository, then import the module pointing at the current folder.

```ps
Import-Module drive:\your-folderpath\sqlUserManagement\SqlUserManagement -Force
```

### User configuration file

The module reads one or more YAML files. The syntax is the following.

Definition:

```yaml
name: {login name}
format: {"{0}" | "{0}-{1}" | "{0}{1}"}
type: {active_directory_group | active_directory_app_registration | sql_login}
environments:
  - "<environment>:<environment_to_map_to>"
permissions:
  - type: {database | schema | object}
    targets:
      - {<table_name> | <schema_name> | all}
    grants:
      - <sql server grants>
```

Example:

```yaml
name: mySqlLogin
format: "{0}{1}"
type: sql_login
environments:
  - "dev:dev"
  - "dev:test"
  - "test:test"
  - "prod:prod"
permissions:
  - type: schema
    targets:
      - dbo
      - myOtherSchema
    grants:
      - SELECT
  - type: object
    targets:
      - myTableName
    grants:
      - SELECT
      - INSERT
```

### Module Parameters

```sh
 -Environment <String>
    Environment to target. Typically dev, test and prod.
    Must match the environment mapping in the yaml file.

    Required?                    true
    Position?                    1
    Default value
    Accept pipeline input?       false
    Accept wildcard characters?  false

-ConfigurationPath <String>
    The path where the script should look for YAML files.

    Required?                    true
    Position?                    2
    Default value
    Accept pipeline input?       false
    Accept wildcard characters?  false

-KeyVaultName <String>
    The name of the KeyVault where the passwords for
    SQL logins will be stored.

    Required?                    true
    Position?                    3
    Default value
    Accept pipeline input?       false
    Accept wildcard characters?  false

-TargetServer <String>
    The SQL server the script should connect to.

    Required?                    true
    Position?                    4
    Default value
    Accept pipeline input?       false
    Accept wildcard characters?  false

-TargetDatbase <String>

    Required?                    true
    Position?                    5
    Default value
    Accept pipeline input?       false
    Accept wildcard characters?  false

-EnablePasswordRotation [<SwitchParameter>]
    Enable or disable password rotation. Default is
    to not perform password rotation.

    Required?                    false
    Position?                    named
    Default value                False
    Accept pipeline input?       false
    Accept wildcard characters?  false

-RotationDays <Int32>
    The number of days before rotating the password.

    Required?                    false
    Position?                    6
    Default value                -90
    Accept pipeline input?       false
    Accept wildcard characters?  false
```

### Running the module

```ps
Publish-DatabaseUsersAndPermissions 'dev' .\my-folder-for-user-permission\ myKeyVaultName myTargetSqlServer myTargetDatabase
```
