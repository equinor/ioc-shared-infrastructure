function Get-AzureSqlRemoveOldPermissions {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory=$true)]
        [string]$UserName
    )

    return "DECLARE cur CURSOR FOR
            SELECT [DatabaseUserName], [PermissionType], [ObjectName], [Type]
            FROM
            ( 
            SELECT [DatabaseUserName] = princ.[name],
            [PermissionType] = perm.[permission_name], 
            [ObjectName] = CASE perm.[class] 
                        WHEN 1 THEN OBJECT_NAME(perm.major_id)  
                        WHEN 3 THEN schem.[name]                
                        WHEN 4 THEN imp.[name]                
                   END
	        ,[Type] = sec.class_desc 
            FROM  sys.database_principals princ  
            LEFT JOIN sys.database_permissions perm ON perm.[grantee_principal_id] = princ.[principal_id]
            LEFT JOIN sys.objects obj ON perm.[major_id] = obj.[object_id]
            LEFT JOIN sys.schemas schem ON schem.[schema_id] = perm.[major_id]
            LEFT JOIN sys.database_principals imp ON imp.[principal_id] = perm.[major_id]
            LEFT JOIN sys.securable_classes sec on perm.class = sec.class
            WHERE 
            princ.[type] IN ('S','E','X') AND
            princ.[name] NOT IN ('sys', 'INFORMATION_SCHEMA', 'guest') AND
	        princ.[name] = '{0}'
            EXCEPT
            SELECT [DatabaseUserName] COLLATE database_default,
            [PermissionType] COLLATE database_default,
            [ObjectName] COLLATE database_default,
            [Type] COLLATE database_default 
            FROM #TempRequestedPermissions
            ) permissionList
            OPEN cur
            FETCH NEXT FROM cur INTO @UserName, @Permission, @ObjectName, @ObjectType
            WHILE @@FETCH_STATUS = 0
            BEGIN            
            SET @RevokeCommand = 'REVOKE ' + @Permission + 
            CASE
                WHEN @ObjectName IS NULL AND @ObjectType = 'DATABASE' THEN ''
                WHEN @ObjectType = 'SCHEMA' THEN ' ON SCHEMA::' + @ObjectName 
                ELSE @ObjectName
            END 
            + ' FROM [' + @UserName + ']'
            EXEC(@RevokeCommand)
            FETCH NEXT FROM cur INTO @UserName, @Permission, @ObjectName, @ObjectType
            END
            CLOSE cur
            DEALLOCATE cur
            IF (SELECT COUNT(*) FROM #TempRequestedPermissions) > 0 
                    DELETE FROM #TempRequestedPermissions" -f $UserName
}