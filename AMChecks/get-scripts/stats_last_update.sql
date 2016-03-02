SET NOCOUNT ON
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
declare @SQL varchar(max)
set @SQL = ''
select  @SQL = @SQL +
'select  ' + quotename(name,'''') + ' COLLATE DATABASE_DEFAULT DBName, 
	ss.name   COLLATE DATABASE_DEFAULT AS SchemaName
	, st.name   COLLATE DATABASE_DEFAULT AS TableName
	, s.name   COLLATE DATABASE_DEFAULT AS IndexName
	, STATS_DATE(s.id,s.indid)   AS ''Statistics Last Updated''
	, s.rowcnt    AS ''Row Count''
	, s.rowmodctr    AS ''Number Of Changes''
	, CAST((CAST(s.rowmodctr AS DECIMAL(28,8))/CAST(s.rowcnt AS
			DECIMAL(28,2)) * 100.0)
				AS DECIMAL(28,2))    AS ''% Rows Changed''
FROM sys.sysindexes s
INNER JOIN ['+name+'].sys.tables st ON st.[object_id] = s.[id]
INNER JOIN ['+name+'].sys.schemas ss ON ss.[schema_id] = st.[schema_id]
WHERE s.id > 100
	AND s.indid > 0
	AND s.rowcnt >= 500'
	
 + CHAR(13)+
 'union'
 + CHAR(13) 

from  sys.databases
where  state_desc ='ONLINE'
and database_id not in (1,2,3)
and name not like 'ReportServer$%'

select @SQL = Left(@SQL, len (@SQL)-6)


exec(@SQL)

