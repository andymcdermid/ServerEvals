declare @SQL varchar(8000)
set @SQL = ''
declare @version varchar(300)
SELECT @version = CAST(SERVERPROPERTY('ProductVersion') as nvarchar(128)) 
declare @majversion int
SELECT @majversion = left(@version,charindex('.',@version)-1) 


if (@majversion) >9
begin
set @SQL = '
SELECT node_id, node_state_desc, memory_node_id, online_scheduler_count, 
       active_worker_count, avg_load_balance, resource_monitor_state
FROM sys.dm_os_nodes WITH (NOLOCK) 
WHERE node_state_desc <> N''ONLINE DAC'' 
union 
select null,null,null,null,null,null,null
OPTION (RECOMPILE);'
end
else 
begin
set @SQL = 'SELECT 0 ''node_id'', ''none'' ''node_state_desc'', 0 ''memory_node_id'', 0 ''online_scheduler_count'', 0 ''active_worker_count'', 0 ''avg_load_balance'', ''none'' ''resource_monitor_state''' 
end

exec(@SQL)
