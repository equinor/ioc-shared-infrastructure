SELECT
    dbs.name AS database_name,
    objs.name AS object_name,
    idxs.name AS index_name,
    idx_stats.user_seeks,
    idx_stats.user_scans,
    idx_stats.user_lookups,
    idx_stats.user_updates,
    idx_stats.last_user_seek,
    idx_stats.last_user_scan,
    idx_stats.last_user_lookup,
    idx_stats.last_user_update
FROM 
    sys.dm_db_index_usage_stats idx_stats
INNER JOIN 
    sys.indexes idxs ON idx_stats.object_id = idxs.object_id AND idx_stats.index_id = idxs.index_id
INNER JOIN 
    sys.objects objs ON idxs.object_id = objs.object_id
INNER JOIN 
    sys.databases dbs ON idx_stats.database_id = dbs.database_id
WHERE 
    dbs.name = '' -- Insert database name (Required)
    AND idx_stats.database_id = DB_ID(''); -- Insert database name (Required)
    AND objs.name = '' -- Insert table name or comment out for all tables
    AND idxs.name = '' -- Insert index name or comment out for all indexes