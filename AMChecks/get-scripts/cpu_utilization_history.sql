declare @SQL varchar(8000)
set @SQL = ''
declare @version varchar(300)
SELECT @version = CAST(SERVERPROPERTY('ProductVersion') as nvarchar(128)) 
declare @majversion int
SELECT @majversion = left(@version,charindex('.',@version)-1) 


if (@majversion) >9
begin
set @SQL = '
DECLARE @ts_now bigint = (SELECT cpu_ticks/(cpu_ticks/ms_ticks) FROM sys.dm_os_sys_info WITH (NOLOCK)); 
SELECT TOP(256) SQLProcessUtilization AS [SQL Server Process CPU Utilization], 
               SystemIdle AS [System Idle Process], 
               100 - SystemIdle - SQLProcessUtilization AS [Other Process CPU Utilization], 
               DATEADD(ms, -1 * (@ts_now - [timestamp]), GETDATE()) AS [Event Time] 
FROM ( 
	  SELECT record.value(''(./Record/@id)[1]'', ''int'') AS record_id, 
			record.value(''(./Record/SchedulerMonitorEvent/SystemHealth/SystemIdle)[1]'', ''int'') 
			AS [SystemIdle], 
			record.value(''(./Record/SchedulerMonitorEvent/SystemHealth/ProcessUtilization)[1]'', 
			''int'') 
			AS [SQLProcessUtilization], [timestamp] 
	  FROM ( 
			SELECT [timestamp], CONVERT(xml, record) AS [record] 
			FROM sys.dm_os_ring_buffers WITH (NOLOCK)
			WHERE ring_buffer_type = N''RING_BUFFER_SCHEDULER_MONITOR'' 
			AND record LIKE N''%<SystemHealth>%'') AS x 
	  ) AS y 
ORDER BY record_id DESC OPTION (RECOMPILE);'
end
else 
begin
set @SQL = '
SELECT 0 ''SQL Server Process CPU Utilization'', 0 ''System Idle Process'', 0 ''Other Process CPU Utilization'', ''1900-01-01'' ''Event Time'';'
end

exec(@SQL)

