declare @SQL varchar(8000)
set @SQL = ''
declare @version varchar(300)
SELECT @version = CAST(SERVERPROPERTY('ProductVersion') as nvarchar(128)) 
declare @majversion int
SELECT @majversion = left(@version,charindex('.',@version)-1) 


if (@majversion) <=9
begin
set @SQL = 'Select ''none'' as ''EventName'', 0 as ''Occurrences'', ''1900-01-01'' as ''LastReportedEventTime'', ''1900-01-01'' as ''OldestRecordedEventTime'''
end
else 
begin
set @SQL = '
SELECT CAST(xet.target_data as xml) as XMLDATA
INTO #SystemHealthSessionData
FROM sys.dm_xe_session_targets xet
JOIN sys.dm_xe_sessions xe
ON (xe.address = xet.event_session_address)
WHERE xe.name = ''system_health''

;WITH CTE_HealthSession AS
(
SELECT C.query(''.'').value(''(/event/@name)[1]'', ''varchar(255)'') as EventName,
C.query(''.'').value(''(/event/@timestamp)[1]'', ''datetime'') as EventTime
FROM #SystemHealthSessionData a
CROSS APPLY a.XMLDATA.nodes(''/RingBufferTarget/event'') as T(C))
SELECT EventName,
COUNT(*) as Occurrences,
MAX(EventTime) as LastReportedEventTime,
MIN(EventTime) as OldestRecordedEventTime
FROM CTE_HealthSession
GROUP BY EventName
ORDER BY 2 DESC
DROP TABLE #SystemHealthSessionData
'
end

exec(@SQL)