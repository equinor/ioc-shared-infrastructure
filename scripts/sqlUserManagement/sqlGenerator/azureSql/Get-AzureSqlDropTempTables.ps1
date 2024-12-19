function Get-AzureSqlDropTempTables {
    
    return "IF OBJECT_ID('tempDB..#TempRequestedPermissions', 'U') IS NOT NULL	            
	            DROP TABLE #TempRequestedPermissions; 
            IF OBJECT_ID('tempDB..#TempPermissionlist', 'U') IS NOT NULL
                DROP TABLE #TempPermissionlist;
            IF OBJECT_ID('tempDB..#TempRequestedRoles', 'U') IS NOT NULL	
	            DROP TABLE #TempRequestedRoles;
            SELECT @Feedback;"
}