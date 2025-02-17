WITH partition_boundaries AS (
    SELECT
        pf.function_id,
        pf.boundary_value_ON_right,
        pf.name as [partition_function],
        ps.name as partition_schema,
        prv.boundary_id as [partition_number],
        prv.[value] as [partition_value] ,
        ds.data_space_id
    FROM sys.partition_functions pf
    LEFT JOIN sys.partition_range_values prv
        ON prv.function_id = pf.function_id
    INNER JOIN sys.partition_schemes ps
        ON  ps.function_id = pf.function_id
    INNER JOIN sys.data_spaces ds
        ON ds.data_space_id = ps.data_space_id
)
SELECT
    CONCAT(s.name, '.', o.name) as object_name,
    i.name as index_name,
    p.partition_number,
    pb.partition_schema,
    pb.partition_function,
    pb.partition_value,
    p.[rows] as row_in_partition,
    p_stat.row_count as p_stat_row_in_partition
FROM sys.partitions p
INNER JOIN sys.dm_db_partition_stats p_stat
    ON p_stat.partition_id = p.partition_id
    AND p_stat.partition_number = p.partition_number
INNER JOIN sys.objects o
    ON o.object_id = p_stat.object_id
INNER JOIN sys.schemas s
    ON s.schema_id = o.schema_id
INNER JOIN sys.indexes i
    ON i.object_id = p_stat.object_id
    AND i.index_id = p_stat.index_id
LEFT JOIN partition_boundaries pb
    ON pb.data_space_id = i.data_space_id
    AND pb.partition_number + IIF(pb.boundary_value_ON_right = 1, 1,0 ) = p.partition_number
WHERE
    s.name = 'dbo'
AND o.name NOT IN(
    '__RefactorLog'
)
ORDER BY
    s.name,
    o.name,
    i.name,
    p.partition_number