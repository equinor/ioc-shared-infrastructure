function Get-AzureSqlProduceNewPermissionStatement {
    
    return "SELECT [DatabaseUserName] = princ.[name],
            [PermissionType] = perm.[permission_name], 
            [ObjectName] = CASE perm.[class] 
                        WHEN 1 THEN SCHEMA_NAME(obj.schema_id) + '.' + OBJECT_NAME(perm.major_id)  
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
            princ.[name] NOT IN ('sys', 'INFORMATION_SCHEMA', 'guest', 'dbo')
            EXCEPT
            SELECT [DatabaseUserName] COLLATE database_default,
            [PermissionType] COLLATE database_default,
            [ObjectName] COLLATE database_default,
            [Type] COLLATE database_default 
            FROM ##TempInitialPermissions"
}