function Get-AzureSqlInitializeVariables {
    
    return "DECLARE @currentPermission NVARCHAR(128)
            DECLARE @sql NVARCHAR(500)
            DECLARE @UserName NVARCHAR(128) 
            DECLARE @Permission NVARCHAR(128)
            DECLARE @ObjectName NVARCHAR(128)
            DECLARE	@ObjectType NVARCHAR(60)
            DECLARE @RoleName NVARCHAR(128)
            DECLARE @RevokeCommand VARCHAR(500)
            DECLARE @AlterCommand VARCHAR(500)
            DECLARE @Feedback NVARCHAR(3000)"
}