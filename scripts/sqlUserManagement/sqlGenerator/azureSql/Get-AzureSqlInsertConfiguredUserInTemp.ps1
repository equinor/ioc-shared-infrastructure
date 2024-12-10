function Get-AzureSqlInsertConfiguredUserInTemp {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory=$true)]
        [string]$UserName
    )

    return "INSERT INTO #TempConfiguredUsers VALUES ('{0}');" -f $UserName
}