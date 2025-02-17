SELECT
    qt.text AS [SQL Query],
    s.login_name AS [User],
    r.start_time AS [Start Time],
	CURRENT_TIMESTAMP AS [Time now],
    r.status,
	r.wait_type,
	r.wait_resource,
    r.percent_complete AS [Progress],
    r.blocking_session_id AS [Blocking Session],
    r.wait_time AS [Wait Time (ms)],
	r.dop AS [Degree of Parallelism]
FROM 
    sys.dm_exec_requests r
JOIN
    sys.dm_exec_sessions s ON r.session_id = s.session_id
CROSS APPLY 
    sys.dm_exec_sql_text(r.sql_handle) AS qt
WHERE 
    r.sql_handle IS NOT NULL
    AND r.session_id <> @@SPID -- Exclude this current query
ORDER BY 
    r.start_time;