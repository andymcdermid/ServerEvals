SET NOCOUNT ON
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
declare @brps as bigint,@cps as bigint, @rcps as int 
select  @brps = cntr_value  from sys.dm_os_performance_counters
where counter_name = 'Batch Requests/sec'

select  @cps = cntr_value  from sys.dm_os_performance_counters
where counter_name = 'SQL Compilations/sec'                                                                                                           

select  @rcps = cntr_value  from sys.dm_os_performance_counters
where counter_name = 'SQL Re-Compilations/sec'   

WaitFor Delay '0:01:00'; 

select  ltrim(rtrim(object_name)) object_name, ltrim(rtrim(counter_name)) counter_name,ltrim(rtrim(instance_name)) instance_name, (cntr_value-@brps)/60 cntr_value,cntr_type   from sys.dm_os_performance_counters
where counter_name = 'Batch Requests/sec'
union 
select ltrim(rtrim(object_name)) object_name, ltrim(rtrim(counter_name)) counter_name,ltrim(rtrim(instance_name)) instance_name, (cntr_value-@cps)/60 cntr_value ,cntr_type   from sys.dm_os_performance_counters
where counter_name = 'SQL Compilations/sec'                                                                                                           
union 
select ltrim(rtrim(object_name)) object_name, ltrim(rtrim(counter_name)) counter_name,ltrim(rtrim(instance_name)) instance_name, (cntr_value-@rcps)/60  cntr_value ,cntr_type from sys.dm_os_performance_counters
where counter_name = 'SQL Re-Compilations/sec' 
union 
Select  ltrim(rtrim(object_name)) object_name, ltrim(rtrim(counter_name)) counter_name,ltrim(rtrim(max(instance_name))) instance_name, avg(cntr_value), cntr_type  from sys.dm_os_performance_counters
where counter_name = 'Page life expectancy' and object_name = 'SQLServer:Buffer Node' group by object_name,counter_name,cntr_type
union 
select  ltrim(rtrim(object_name)) object_name, ltrim(rtrim(counter_name) )counter_name,ltrim(rtrim(instance_name)) instance_name, cntr_value, cntr_type   from sys.dm_os_performance_counters
where counter_name = 'Total Server Memory (KB)'
union 
select  ltrim(rtrim(object_name)) object_name, ltrim(rtrim(counter_name) )counter_name,ltrim(rtrim(instance_name)) instance_name, cntr_value, cntr_type   from sys.dm_os_performance_counters
where counter_name = 'Target Server Memory (KB)'
union 
select  ltrim(rtrim(object_name)) object_name, ltrim(rtrim(counter_name) )counter_name,ltrim(rtrim(instance_name)) instance_name, cntr_value, cntr_type   from sys.dm_os_performance_counters
where counter_name = 'Memory Grants Pending'
union 
select  ltrim(rtrim(object_name)) object_name, ltrim(rtrim(counter_name) )counter_name,ltrim(rtrim(instance_name)) instance_name, cntr_value, cntr_type   from sys.dm_os_performance_counters
where counter_name = 'User Connections'                                                                                                     



select * from  sys.dm_os_performance_counters
where object_name like '%node%'
