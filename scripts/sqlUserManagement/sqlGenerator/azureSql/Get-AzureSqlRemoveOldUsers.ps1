function Get-AzureSqlRemoveOldUsers {    

    return "IF OBJECT_ID('tempDB..#TempConfiguredUsers', 'U') IS NOT NULL
                DECLARE cur CURSOR FOR
                SELECT [UserName]
                FROM
                ( 
                SELECT UserName = pr.[name] FROM sys.database_principals pr
                WHERE 
                pr.[type] IN ('S','E','X') AND
                pr.[name] NOT IN ('sys', 'INFORMATION_SCHEMA', 'guest', 'dbo') 
                EXCEPT
                SELECT [UserName] COLLATE database_default
                FROM #TempConfiguredUsers
                ) userList
                OPEN cur
                FETCH NEXT FROM cur INTO @UserName
                WHILE @@FETCH_STATUS = 0
                BEGIN                
                SET @DropUserCommand = 'DROP USER [' + @UserName + ']'
                SET @Feedback = CONCAT(@Feedback, N'Deleting user {0} with command: ', @DropUserCommand, NCHAR(10) + NCHAR(13))
                EXEC(@DropUserCommand)                
                FETCH NEXT FROM cur INTO @UserName
                END
                CLOSE cur
                DEALLOCATE cur
            IF OBJECT_ID('tempDB..#TempConfiguredUsers', 'U') IS NOT NULL	
	            DROP TABLE #TempConfiguredUsers;" -f $UserName
}