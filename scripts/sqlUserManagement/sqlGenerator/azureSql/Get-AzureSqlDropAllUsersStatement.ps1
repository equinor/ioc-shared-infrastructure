function Get-AzureSqlDropAllUsersStatement {
    return "
    DECLARE @qry NVARCHAR(MAX) = '';

    SELECT @qry = @qry +
        'DROP USER [' + name + '];'
    FROM sys.sysusers
    WHERE name NOT IN ('public','guest','INFORMATION_SCHEMA', 'sys', 'dbo')
        AND LEFT(name,3) <> 'db_'

    exec sp_executesql @qry;
    "
}