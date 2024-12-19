function Get-AzureSqlCreateTempTablePermissions {
    
    return "IF OBJECT_ID('tempDB..#TempRequestedPermissions', 'U') IS NOT NULL	            
	            DROP TABLE #TempRequestedPermissions;
            CREATE TABLE #TempRequestedPermissions(
	            DatabaseUserName NVARCHAR(128) NOT NULL,
	            PermissionType NVARCHAR(128) NOT NULL,	
                ObjectName NVARCHAR(128),
                [Type] NVARCHAR(60) NOT NULL)
            IF OBJECT_ID('tempDB..#TempPermissionlist', 'U') IS NOT NULL
                DROP TABLE #TempPermissionlist;
            CREATE TABLE #TempPermissionlist(permission NVARCHAR(128))"
}