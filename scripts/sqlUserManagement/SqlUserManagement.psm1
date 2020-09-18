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
        [string]$TargetDatbase,
        [switch]$EnablePasswordRotation,
        [int]$RotationDays=-90
    )

    # Supress breaking changes warnings
    # for this script.
    Set-Item Env:\SuppressAzurePowerShellBreakingChangeWarnings "true"

    # Import PSYaml module so that the script
    # is able to parse the user yaml configuration.
    Add-Type -AssemblyName System.Web
    Import-Module .\.psyaml\source\PSYaml

    # Import sqlGenerator module
    Get-ChildItem -Path "$PSScriptRoot\sqlGenerator\azureSql" | ForEach-Object { . $($_.FullName) }

    # Define the output folder.
    $outputFolder = ".\output"
    Write-Verbose "Ouput folder is set to $outputFolder"

    if ((Test-Path $outputFolder)) {
        # Remove previously generated items
        Remove-Item $outputFolder -Recurse | Out-Null
    }

    # Define the file name of script.
    $sqlFileName = "create_database_users.sql"

    # Parse yaml user configuration.
    Get-ChildItem -Path $ConfigurationPath |
    ForEach-Object {
        Write-Verbose "Parsing user configuration file $_"
        $userConfig = ConvertFrom-YAML (Get-Content $_ -Raw)

        # Skip a user creation if it's not part of targeted
        # environment.
        $usersFromEnvironmentToCreate = $userConfig.environments | ForEach-Object {
            $environmentMapping = $_.Split(":")
            if ($environmentMapping[1] -eq $environment ) {
                $environmentMapping[0]
            }
        }

        if ($usersFromEnvironmentToCreate -notcontains $environment) {
            return
        }

        $currentFilePath = "$outputFolder\$TargetServer\$TargetDatbase\$sqlFileName"

        # If the file already exists there is no
        # need to re-create it or append the initial
        # sql commands.
        if (!(Test-Path $currentFilePath)) {
            New-Item -Path $currentFilePath -Force | Out-Null

            # Append the drop users statement so that
            # we remove all users not defined as part
            # of version control.
            Add-Content -Path $currentFilePath -Value (Get-AzureSqlDropAllUsersStatement)
            Invoke
        }

        $usersToCreate = $userConfig.type -eq "active_directory_group" ? $usersFromEnvironmentToCreate[0] : $usersFromEnvironmentToCreate

        $usersToCreate | ForEach-Object {
            $currentUserName = $userConfig.format -f $userConfig.name, $_

            # Generate create user statement.
            switch ($userConfig.type) {
                active_directory_group {
                    Add-Content -Path $currentFilePath (Get-AzureSqlCreateUserStatement $currentUserName $true)
                }
                active_directory_app_registration {
                    Add-Content -Path $currentFilePath (Get-AzureSqlCreateUserStatement $currentUserName $true)
                }
                sql_login {
                    $currentSecret = Get-AzKeyVaultSecret -VaultName "$KeyVaultName" -Name ('sql-login-password-{0}' -f $currentUserName)

                    # If password rotation is enabled and the secret
                    # is older than number of allowed rotation days,
                    # then update the secret.
                    if ($currentSecret.Updated -lt (get-date).AddDays($RotationDays) -And $EnablePasswordRotation) {
                        Write-Verbose ('Password roation is enabled. The secret for [{0}] is older than 90 days and therefore updated.' -f $currentUserName)
                        $currentSecret = $null
                    }

                    if (!$currentSecret) {
                        $password = ConvertTo-SecureString ( -join ((0x30..0x39) + ( 0x41..0x5A) + ( 0x61..0x7A) | Get-Random -Count 30  | % { [char]$_ }) ) -AsPlainText -Force
                        $currentSecret = Set-AzKeyVaultSecret -VaultName "$KeyVaultName" -Name ('sql-login-password-{0}' -f $currentUserName) -SecretValue $password -ContentType "password"
                    }

                    Add-Content -Path $currentFilePath (Get-AzureSqlCreateUserStatement $currentUserName $false $currentSecret.SecretValue)

                    ## Try add application to Access policies so that it can retrieve the the created secrets.
                    try {
                        $servicePrincipal = (Get-AzADServicePrincipal -SearchString "$currentUserName").Id

                        if($servicePrincipal) {
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
            Add-Content $currentFilePath -Value (Get-AzureSqlGrantConnectStatement $currentUserName)

            # Grant the users permission on schema, objects or
            # or on a database level.
            $userConfig.permissions | ForEach-Object {
                $grants = $_.grants -ne 'CONNECT' -join ','
                $type = $_.type

                $_.targets | ForEach-Object {
                    if ($type -eq "database") {
                        Add-Content $currentFilePath -Value (Get-AzureSqlGrantPermissionsStatement $currentUserName $Grants)
                    }
                    else {
                        Add-Content $currentFilePath -Value (Get-AzureSqlGrantPermissionsStatement $currentUserName $Grants $_ $type)
                    }
                }
            }
        }
    }
}

Export-ModuleMember -Function 'Publish-DatabaseUsersAndPermissions'