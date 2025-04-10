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
    # Creates a new user if none exist with this $UserName. 
    # If $Password is provided and user exists, new password is set (This requires ALTER ANY USER permission).
    # Checks that provided $UserName is not a match with db system users or roles
    if($IsExternalProvider){
        return "IF (SELECT COUNT(name) FROM sys.sysusers WHERE name = '{0}') < 1 AND '{0}' NOT IN ('public','guest','INFORMATION_SCHEMA', 'sys', 'dbo') AND LEFT('{0}',3) <> 'db_'
                BEGIN
                CREATE USER [{0}] FOR EXTERNAL PROVIDER;
                SET @Feedback = CONCAT(@Feedback, N'Created new user {0} for external provider', NCHAR(10) + NCHAR(13))
                END" -f $UserName
    }else {
        return "IF (SELECT COUNT(name) FROM sys.sysusers WHERE name = '{0}') < 1 AND '{0}' NOT IN ('public','guest','INFORMATION_SCHEMA', 'sys', 'dbo') AND LEFT('{0}',3) <> 'db_'
                BEGIN
                CREATE USER [{0}] WITH PASSWORD = '{1}'
                SET @Feedback = CONCAT(@Feedback, N'Created new user {0} with password', NCHAR(10) + NCHAR(13))
                END
                ELSE
                ALTER USER [{0}] WITH PASSWORD = '{1}';
                SET @Feedback = CONCAT(@Feedback, N'Altered user {0} with password', NCHAR(10) + NCHAR(13))" -f $UserName, (ConvertFrom-SecureString -SecureString $Password -AsPlainText)
    }
}