function Get-AzureSqlRemoveOldRoles {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory=$true)]
        [string]$UserName
    )

    return "DECLARE cur CURSOR FOR
            SELECT [RoleName], [UserName]
            FROM
            ( 
            SELECT RoleName = imp.[name], UserName = pr.[name] FROM sys.database_role_members mem
            INNER JOIN
                sys.database_principals imp ON imp.[principal_id] = mem.[role_principal_id]
            INNER JOIN
                sys.database_principals pr on pr.principal_id = mem.member_principal_id
                WHERE 
                pr.[type] IN ('R','S','E','X') AND
                pr.[name] NOT IN ('sys', 'INFORMATION_SCHEMA', 'guest') AND
                pr.[name] = '{0}'
            EXCEPT
            SELECT [RoleName] COLLATE database_default, [UserName] COLLATE database_default
            FROM #TempRequestedRoles
            ) roleList
            OPEN cur
            FETCH NEXT FROM cur INTO @RoleName, @UserName
            WHILE @@FETCH_STATUS = 0
            BEGIN            
            SET @AlterCommand = 'ALTER ROLE ' + @RoleName + ' DROP MEMBER [' + @UserName + ']'
            EXEC(@AlterCommand)
            FETCH NEXT FROM cur INTO @RoleName, @UserName
            END
            CLOSE cur
            DEALLOCATE cur
            IF (SELECT COUNT(*) FROM #TempRequestedRoles) > 0 
                DELETE FROM #TempRequestedRoles" -f $UserName
}