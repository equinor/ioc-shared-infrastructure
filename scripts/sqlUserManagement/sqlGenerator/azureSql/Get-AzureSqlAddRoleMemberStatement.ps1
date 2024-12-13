function Get-AzureSqlAddRoleMemberStatement {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory=$true)]
        [string]$UserName,
        [Parameter(Mandatory=$true)]
        [string]$RoleName
    )

    return "INSERT INTO #TempRequestedRoles VALUES ('{1}','{0}');
            SET @Feedback = CONCAT(@Feedback, N'Adding role {0} for user {1}', NCHAR(10) + NCHAR(13))
            EXEC sp_addrolemember '{0}' , '{1}';" -f $RoleName, $UserName
}
    