function Get-AzureSqlGrantPermissionsStatement {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory=$true)]
        [string]$UserName,
        [Parameter(Mandatory=$true)]
        [string]$Grants,
        [string]$Target,
        [ValidateSet('Object', 'Schema')]
        [string]$Type
    )

    if($Type){
        return "GRANT {0} ON {1}::{2} TO [{3}]" -f $Grants, $Type, $Target, $UserName
    } else {
        return "GRANT {0} TO [{1}];" -f $Grants, $UserName
    }
}