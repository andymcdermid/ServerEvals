declare @SQL varchar(8000)
set @SQL = ''
declare @version varchar(300)
SELECT @version = CAST(SERVERPROPERTY('ProductVersion') as nvarchar(128)) 
declare @majversion int
SELECT @majversion = left(@version,charindex('.',@version)-1) 


if (@majversion) >=9
begin
set @SQL = 'Select ''none'' as ''Job'''
end
else 
begin
set @SQL = 'SELECT j.name AS ''Job'' 
FROM msdb..sysschedules sched
  JOIN msdb..sysjobschedules jsched 
    ON sched.schedule_id = jsched.schedule_id
  JOIN msdb.dbo.sysjobs j 
    ON jsched.job_id = j.job_id
WHERE sched.freq_type = 64;'
end

exec(@SQL)

