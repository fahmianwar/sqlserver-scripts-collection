SELECT 
    d.name AS database_name,
    p.command,
    p.status,
    p.session_id,
    p.blocking_session_id,
    CASE 
        WHEN p2.session_id IS NOT NULL 
            AND (p.blocking_session_id = 0 OR p.session_id IS NULL) 
        THEN '1' 
        ELSE '0' 
    END AS head_blocker,
    [statement_text] = SUBSTRING(
        t.TEXT, 
        (p.statement_start_offset / 2) + 1,  
        ((CASE 
            WHEN p.statement_end_offset = -1 THEN DATALENGTH(t.TEXT) 
            ELSE p.statement_end_offset  
        END - p.statement_start_offset) / 2) + 1
    ),
    [command_text] = COALESCE(
        QUOTENAME(DB_NAME(t.dbid)) + N'.' 
        + QUOTENAME(OBJECT_SCHEMA_NAME(t.objectid, t.dbid)) + N'.' 
        + QUOTENAME(OBJECT_NAME(t.objectid, t.dbid)), 
        ''
    ),
    p.start_time,
    p.total_elapsed_time / 1000 AS elapsed_time_secs,
    p.wait_time / 1000 AS wait_time_secs,
    p.last_wait_type,
    dr.host_name,
    dr.program_name,
    dr.login_name,
    m.granted_memory_kb,
    m.grant_time,
    p.plan_handle,
    ph.query_plan,
    p.sql_handle
FROM sys.dm_exec_requests p
    INNER JOIN sys.databases d ON d.database_id = p.database_id
    OUTER APPLY sys.dm_exec_sql_text(p.sql_handle) t
    OUTER APPLY sys.dm_exec_query_plan(p.plan_handle) AS ph
    INNER JOIN sys.dm_exec_sessions dr ON dr.session_id = p.session_id
    LEFT JOIN sys.dm_exec_query_memory_grants m ON m.session_id = p.session_id
    LEFT JOIN sys.dm_exec_requests p2 ON (p.session_id = p2.blocking_session_id)
WHERE 1 = 1
    AND t.text IS NOT NULL
ORDER BY p.start_time;
