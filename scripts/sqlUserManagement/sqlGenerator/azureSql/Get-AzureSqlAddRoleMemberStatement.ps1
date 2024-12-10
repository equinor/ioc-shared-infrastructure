function Get-AzureSqlAddRoleMemberStatement {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory=$true)]
        [string]$UserName,
        [Parameter(Mandatory=$true)]
        [string]$RoleName
    )

    return "INSERT INTO #TempRequestedRoles VALUES ('{1}','{0}');
            EXEC sp_addrolemember '{0}' , '{1}';" -f $RoleName, $UserName
}
