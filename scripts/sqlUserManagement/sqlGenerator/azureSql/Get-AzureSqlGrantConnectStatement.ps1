function Get-AzureSqlGrantConnectStatement {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory=$true)]
        [string]$UserName
    )

    return "INSERT INTO #TempRequestedPermissions VALUES ('{0}','CONNECT',NULL,'DATABASE');
            GRANT CONNECT TO [{0}];" -f $UserName
}