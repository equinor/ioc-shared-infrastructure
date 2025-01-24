function Get-AzureSqlDropTempInitialPermissions {
    
    return "IF OBJECT_ID('tempDB..##TempInitialPermissions', 'U') IS NOT NULL	            
	            DROP TABLE ##TempInitialPermissions;"
}