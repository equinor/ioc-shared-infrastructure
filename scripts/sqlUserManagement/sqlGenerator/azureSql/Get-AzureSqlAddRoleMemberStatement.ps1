function Get-AzureSqlAddRoleMemberStatement {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory=$true)]
        [string]$UserName,
        [Parameter(Mandatory=$true)]
        [string]$RoleName
    )

    return "EXEC sp_addrolemember '{0}' , '{1}';" -f $RoleName, $UserName
}
