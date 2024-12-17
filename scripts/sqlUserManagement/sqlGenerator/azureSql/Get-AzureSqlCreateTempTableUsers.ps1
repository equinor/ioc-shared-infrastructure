function Get-AzureSqlCreateTempTableUsers {
    
    return "IF OBJECT_ID('tempDB..#TempConfiguredUsers', 'U') IS NOT NULL	
	            DROP TABLE #TempConfiguredUsers;
            CREATE TABLE #TempConfiguredUsers(
                UserName nvarchar(128) NOT NULL)
            DECLARE @DropUserCommand varchar(500)
            DECLARE @FeedbackDel NVARCHAR(1000)"
}