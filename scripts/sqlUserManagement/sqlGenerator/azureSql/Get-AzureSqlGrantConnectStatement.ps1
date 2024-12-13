function Get-AzureSqlGrantConnectStatement {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory=$true)]
        [string]$UserName
    )

    return "INSERT INTO #TempRequestedPermissions VALUES ('{0}','CONNECT',NULL,'DATABASE');
            GRANT CONNECT TO [{0}];
            SET @Feedback = CONCAT(@Feedback, N'Granted CONNECT to database for user {0}', NCHAR(10) + NCHAR(13))" -f $UserName
}