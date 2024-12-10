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
        return "GRANT {0} ON {1}::{2} TO [{3}];
                IF (SELECT COUNT(*) FROM #TempPermissionlist) > 0 
                    DELETE FROM #TempPermissionlist;                
                INSERT INTO #TempPermissionlist
                SELECT value FROM STRING_SPLIT('{0}', ',')
                DECLARE cur CURSOR FOR SELECT permission FROM #TempPermissionlist
                OPEN cur
                FETCH NEXT FROM cur INTO @currentPermission
                WHILE @@FETCH_STATUS = 0
                BEGIN
                    SET @sql = 'INSERT INTO #TempRequestedPermissions VALUES ('
                            + QUOTENAME('{3}','''') + ', '
                            + QUOTENAME(@currentPermission,'''') + ', '
                            + QUOTENAME('{2}','''') + ', '
                            + QUOTENAME('{1}','''') + ');'
                    EXEC (@sql)
                    FETCH NEXT FROM cur INTO @currentPermission
                END
                CLOSE cur
                DEALLOCATE cur
                " -f $Grants, $Type, $Target, $UserName
    } else {
        return "GRANT {0} TO [{1}];
                IF (SELECT COUNT(*) FROM #TempPermissionlist) > 0 
                    DELETE FROM #TempPermissionlist;    
                INSERT INTO #TempPermissionlist
                SELECT value FROM STRING_SPLIT('{0}', ',')
                DECLARE cur CURSOR FOR SELECT permission FROM #TempPermissionlist
                OPEN cur
                FETCH NEXT FROM cur INTO @currentPermission
                WHILE @@FETCH_STATUS = 0
                BEGIN
                    SET @sql = 'INSERT INTO #TempRequestedPermissions (DatabaseUserName, PermissionType, [Type])  VALUES ('
                            + QUOTENAME('{1}', '''') + ', '
                            + QUOTENAME(@currentPermission,'''') + ', '
                            + QUOTENAME('DATABASE', '''') + ');'
                    EXEC (@sql)
                    FETCH NEXT FROM cur INTO @currentPermission
                END
                CLOSE cur
                DEALLOCATE cur" -f $Grants, $UserName
    }
}