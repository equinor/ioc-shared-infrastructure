function Get-AzureSqlCreateTempTableRoles {
    
    return "IF OBJECT_ID('tempDB..#TempRequestedRoles', 'U') IS NOT NULL	
	            DROP TABLE #TempRequestedRoles;
            CREATE TABLE #TempRequestedRoles(
                RoleName NVARCHAR(128) NOT NULL,
                UserName NVARCHAR(128) NOT NULL)"
}