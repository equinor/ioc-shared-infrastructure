SELECT 
	  OBJECT_SCHEMA_NAME(ips.object_id) AS schema_name
    , OBJECT_NAME(ips.object_id) AS object_name
    , i.name AS index_name
    , i.type_desc AS index_type
    , ips.avg_fragmentation_in_percent
    , ips.avg_page_space_used_in_percent
    , ips.page_count
    , ips.alloc_unit_type_desc
FROM sys.dm_db_index_physical_stats(DB_ID(), default, default, default, 'SAMPLED') AS ips
INNER JOIN sys.indexes AS i
ON ips.object_id = i.object_id
   AND ips.index_id = i.index_id
WHERE
	1=1
	AND OBJECT_SCHEMA_NAME(ips.object_id)	= '<schema_name>' -- Insert schema name
	AND OBJECT_NAME(ips.object_id)			= '<table_name>'  -- Insert table name
	AND i.name								= '<index_name>'  -- Insert index name
	-- Note: Comment out any of the above filters to not filter on the given property
ORDER BY 
	  OBJECT_SCHEMA_NAME(ips.object_id)
	, OBJECT_NAME(ips.object_id)
	, i.name
	, ips.avg_fragmentation_in_percent;