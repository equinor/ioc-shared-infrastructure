function Get-AzureSqlInitializeVariables {
    
    return "DECLARE @currentPermission NVARCHAR(128)
            DECLARE @sql NVARCHAR(500)
            DECLARE @UserName nvarchar(128) 
            DECLARE @Permission nvarchar(128)
            DECLARE @ObjectName nvarchar(128)
            DECLARE	@ObjectType nvarchar(60)
            DECLARE @RoleName nvarchar(128)
            DECLARE @RevokeCommand varchar(500)
            DECLARE @AlterCommand varchar(500)"
}