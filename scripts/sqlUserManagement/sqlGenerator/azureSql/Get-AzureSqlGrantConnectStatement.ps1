function Get-AzureSqlGrantConnectStatement {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory=$true)]
        [string]$UserName
    )

    return "GRANT CONNECT TO [{0}];" -f $UserName
}