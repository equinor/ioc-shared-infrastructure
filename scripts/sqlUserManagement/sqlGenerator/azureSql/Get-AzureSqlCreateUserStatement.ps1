function Get-AzureSqlCreateUserStatement {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory=$true)]
        [string]$UserName,
        [Parameter(Mandatory=$true)]
        [ValidateSet($true, $false)]
        $IsExternalProvider,
        [SecureString]$Password
    )

    if($IsExternalProvider){
        return "CREATE USER [{0}] FOR EXTERNAL PROVIDER;" -f $UserName
    }else {
        return "CREATE USER [{0}] WITH PASSWORD = '{1}';" -f $UserName, (ConvertFrom-SecureString -SecureString $Password -AsPlainText)
    }
}