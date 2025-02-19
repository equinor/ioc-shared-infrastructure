SELECT
	  s.name AS schema_name
	, t.name AS table_name
	, c.name AS column_name
FROM sys.schemas s
INNER JOIN sys.tables t ON s.schema_id = t.schema_id
INNER JOIN sys.columns c ON t.object_id = c.object_id
WHERE
	1=1
	AND s.name LIKE '%schema_name%'  -- Replace "schema_name" with the schema you're looking for
	AND t.name LIKE '%table_name%'  -- Replace "table_name" with the table you're looking for
	AND c.name LIKE '%column_name%' -- Replace "column_name" with the name of the column you're looking for
	-- Note: Comment out any of the above to not filter on that property
ORDER BY 
	  schema_name
	, table_name
	, column_name