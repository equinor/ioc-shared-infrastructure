<#
    .SYNOPSIS
    Deletes and re-creates all users on a target database
    based on a given YAML user configuration file.

    .DESCRIPTION
    The script generates a delete all users statement on
    the target database. Then re-creates the users based
    on one or more YAML files, with the permissions defined.

    The script currently supports following user types:
        - Active Directory Group
        - Active Directory App Registration
        - SQL Login.

    In the case it's a SQL login the script will check a
    given KeyVault for a secret. If the secret doesn't exists
    then it will be created in a given format.

    .PARAMETER Environment
    Environment to target. Typically dev, test and prod.
    Must match the environment mapping in the yaml file.

    .PARAMETER ConfigurationPath
    The path where the script should look for YAML files.

    .PARAMETER KeyVaultName
    The name of the KeyVault where the passwords for
    SQL logins will be stored.

    .PARAMETER TargetServer
    The SQL server the script should connect to.

    .PARAMETER TargetDatabase
    The target database where the delete and re-create
    users will be run.

    .PARAMETER EnablePasswordRotation
    Enable or disable password rotation. Default is
    to not perform password rotation.

    .PARAMETER RotationDays
    The number of days before rotating the password.

    .EXAMPLE
    Publish-DatabaseUsersAndPermissions 'dev' .\myYamlFolder\ myKeyVault myServer myDatabase -Verbose

#>
function Publish-DatabaseUsersAndPermissions {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [string]$Environment,
        [Parameter(Mandatory = $true)]
        [string]$ConfigurationPath,
        [Parameter(Mandatory = $true)]
        [string]$KeyVaultName,
        [Parameter(Mandatory = $true)]
        [string]$TargetServer,
        [Parameter(Mandatory = $true)]
        [string]$TargetDatabase,
        [switch]$EnablePasswordRotation,
        [int]$RotationDays = -90
    )
    # If any errors has occured. Execution must be stopped.
    $ErrorActionPreference = "Stop"

    # Supress breaking changes warnings
    # for this script.
    Set-Item Env:\SuppressAzurePowerShellBreakingChangeWarnings "true"

    # Import PSYaml module so that the script
    # is able to parse the user yaml configuration.
    Add-Type -AssemblyName System.Web
    Import-Module .\.psyaml\source\PSYaml

    # Import sqlGenerator module
    Get-ChildItem -Path "$PSScriptRoot\sqlGenerator\azureSql" | ForEach-Object { . $($_.FullName) }


    # Define a string format that must be appended on each
    # sql statment added to the sqlStatement variable.
    # This is to enforce that a newline is added when appending
    # a new statement to the variable.
    $sqlStatementFormat = "{0} `r`n"
    $sqlStatement = $sqlStatementFormat -f (Get-AzureSqlDropAllUsersStatement)

    # Parse yaml user configuration.
    Get-ChildItem -Path $ConfigurationPath |
    ForEach-Object {
        Write-Verbose "Parsing user configuration file $_"
        $userConfig = ConvertFrom-YAML (Get-Content $_ -Raw)

        # Parse the environment mapping
        $usersFromEnvironmentToCreate = $userConfig.environments | ForEach-Object {
            $environmentMapping = $_.Split(":")

            $hash = @{
                sourceEnvironment = $environmentMapping[0]
                targetEnvironment = $environmentMapping[1]
            }

            if ($hash.targetEnvironment -eq $environment ) {
                $hash
            }
        }

        # If the user to create is of type active directory group
        # then we should only process it once.
        $usersToCreate = $userConfig.type -eq "active_directory_group" -and $usersFromEnvironmentToCreate -is [array] ? $usersFromEnvironmentToCreate[0] : $usersFromEnvironmentToCreate

        # Skip a user creation if it's not part of targeted
        # environment.
        if ($usersToCreate.targetEnvironment -ne $environment) {
            return
        }

        $usersToCreate | ForEach-Object {
            $currentUserName = $userConfig.format -f $userConfig.name, $_.sourceEnvironment

            # Generate create user statement.
            switch ($userConfig.type) {
                active_directory_group {
                    $sqlStatement += $sqlStatementFormat -f (Get-AzureSqlCreateUserStatement $currentUserName $true)
                }
                active_directory_app_registration {
                    $sqlStatement += $sqlStatementFormat -f (Get-AzureSqlCreateUserStatement $currentUserName $true)
                }
                sql_login {
                    # Get the current secret from the KeyVault.
                    $currentSecret = Get-AzKeyVaultSecret -VaultName "$KeyVaultName" -Name ('sql-login-password-{0}' -f $currentUserName)

                    # If password rotation is enabled and the secret
                    # is older than number of allowed rotation days,
                    # then we must discard current secret version.
                    if ($currentSecret.Updated -lt (get-date).AddDays($RotationDays) -And $EnablePasswordRotation) {
                        Write-Verbose ('Password roation is enabled. The secret for [{0}] is older than 90 days and therefore updated.' -f $currentUserName)
                        $currentSecret = $null
                    }

                    # If the current secret is not retrieved from the KeyVault
                    # or that it has been nulled out by the password rotation
                    # logic, we need to create or update the secret.
                    if (!$currentSecret) {
                        Write-Verbose "Generating password for $currentUserName"
                        $password = ConvertTo-SecureString ( -join ((0x30..0x39) + ( 0x41..0x5A) + ( 0x61..0x7A) | Get-Random -Count 30  | % { [char]$_ }) ) -AsPlainText -Force
                        $currentSecret = Set-AzKeyVaultSecret -VaultName "$KeyVaultName" -Name ('sql-login-password-{0}' -f $currentUserName) -SecretValue $password -ContentType "password"
                    }

                    $sqlStatement += $sqlStatementFormat -f (Get-AzureSqlCreateUserStatement $currentUserName $false $currentSecret.SecretValue)

                    # Try add the application using sql-login to the KeyVault access
                    # policies. This requires that the user name is the same as one
                    # registered in app registration.
                    try {
                        $servicePrincipal = (Get-AzADServicePrincipal -SearchString "$currentUserName").Id

                        if($servicePrincipal) {
                            Write-Verbose ("Assiging access policy to {0} on KeyVault {1}" -f $currentUserName, $KeyVaultName)
                            Set-AzKeyVaultAccessPolicy -VaultName "$KeyVaultName" -ObjectId $servicePrincipal -PermissionsToSecrets Get
                        }
                    }
                    catch {
                        Write-Error ('An issue occured assigning access polciy to {0}, {1}' -f $currentUserName, $_)
                    }
                }
                Default { Write-Error ("User type [{0}] is not supported" -f $userConfig.type) }
            }

            # Grant the user ability to connect
            # to the database.
            $sqlStatement += $sqlStatementFormat -f (Get-AzureSqlGrantConnectStatement $currentUserName)

            # Grant the users permission on schema, objects or
            # or on a database level.
            $userConfig.permissions | ForEach-Object {
                $grants = $_.grants -ne 'CONNECT' -join ','
                $type = $_.type

                $_.targets | ForEach-Object {
                    if ($type -eq "database") {
                        $sqlStatement += $sqlStatementFormat -f (Get-AzureSqlGrantPermissionsStatement $currentUserName $Grants)
                    }
                    else {
                        $sqlStatement += $sqlStatementFormat -f (Get-AzureSqlGrantPermissionsStatement $currentUserName $Grants $_ $type)
                    }
                }
            }

            $userConfig.roles | ForEach-Object {
                if ($_){
                    $sqlStatement += $sqlStatementFormat -f (Get-AzureSqlAddRoleMemberStatement $currentUserName $_)
                }
            }
        }
    }

    # When the sql statements are generated. It must be run
    # towards the target sql server.
    Write-Verbose 'Executing query on target database'
    $token = az account get-access-token --resource https://database.windows.net --output tsv --query accessToken
    $accessToken = $token

    $sqlConnection = New-Object System.Data.SqlClient.SqlConnection
    $sqlConnection.ConnectionString = ("Data Source=tcp:{0},1433;Initial Catalog={1};Persist Security Info=True;Connect Timeout=30;Encrypt=True;TrustServerCertificate=True" -f "$TargetServer.database.windows.net", $TargetDatabase)
    $sqlConnection.AccessToken = $accessToken

    $command = $sqlConnection.CreateCommand()
    $command.CommandText = $sqlStatement
    $command.CommandType.Text
    $command.Connection.Open()
    $command.ExecuteReader()
    $sqlConnection.Close()
}

Export-ModuleMember -Function 'Publish-DatabaseUsersAndPermissions'