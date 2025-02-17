-- Permissions
WITH db_permissions (Grantee, Securable, Permission, Schemas, Objects, Columns) 
AS (
SELECT
      USER_NAME(dbPer.grantee_principal_id)   AS Grantee
    , dbPer.class_desc                        AS Securable
    , dbPer.permission_name                   AS Permission
    , sch.name                                AS Schemas
    , obj.name                                AS Objects
    , col.name                                AS Columns
FROM sys.database_permissions AS dbPer
JOIN sys.database_principals AS dbPri
	ON dbPer.grantee_principal_id = dbPri.principal_id
LEFT JOIN sys.schemas AS sch
	ON dbPer.major_id = sch.schema_id
LEFT JOIN sys.objects AS obj 
    ON dbPer.major_id = obj.object_id AND dbPer.class_desc <> 'SCHEMA'
LEFT JOIN sys.columns AS col 
    ON dbPer.major_id = col.object_id AND dbPer.minor_id = col.column_id AND dbPer.class_desc = 'OBJECT_OR_COLUMN'
WHERE 
    1=1
    AND USER_NAME(dbPer.grantee_principal_id) <> 'Public'
)
SELECT
      Grantee
    , Securable
    , Permission
    , Schemas
    , Objects
    , Columns
FROM
    db_permissions
WHERE
  1=1
  -- AND Grantee LIKE '' -- Database user's name, e.g. Admin
  -- AND Securable LIKE '' -- DATABASE | SCHEMA | OBJECT_OR_COLUMN etc., see https://learn.microsoft.com/en-us/sql/relational-databases/system-catalog-views/sys-database-permissions-transact-sql?view=sql-server-ver15
  -- AND Permission LIKE '' -- SELECT | ALTER | UPDATE | CONNECT | DELETE etc., see https://learn.microsoft.com/en-us/sql/relational-databases/system-catalog-views/sys-database-permissions-transact-sql?view=sql-server-ver15#database-permissions
  -- AND Schemas LIKE '' -- 'dbo' or other custom schema name
  -- AND Objects LIKE '' -- Table name
  -- AND Columns LIKE '' -- Column name
  -- Comment in any of the above lines to filter the results
ORDER BY
    Grantee
    , Securable
    , Permission
    , Schemas
    , Objects
    , Columns;

-- Roles
SELECT 
	  DP1.name AS DatabaseRoleName
	, isnull (DP2.name, 'No members') AS DatabaseUserName
 FROM sys.database_role_members AS DRM
 RIGHT OUTER JOIN sys.database_principals AS DP1
   ON DRM.role_principal_id = DP1.principal_id
 LEFT OUTER JOIN sys.database_principals AS DP2
   ON DRM.member_principal_id = DP2.principal_id
WHERE DP1.type = 'R'
ORDER BY DP1.name;