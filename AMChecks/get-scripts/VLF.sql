declare @version int
declare @sql varchar(max)

set @version = (select left(cast(SERVERPROPERTY('productversion') as varchar(20)),cast(CHARINDEX('.',cast(SERVERPROPERTY('productversion') as varchar(20))) as int)-1))
print @version

CREATE TABLE #VLFCountResults(DatabaseName sysname, VLFCount int);

if @version < 11
Begin
print '2008-'
set @sql = 
'CREATE TABLE ##VLFInfo (FileID  int,
					   FileSize bigint, StartOffset bigint,
					   FSeqNo      bigint, [Status]    bigint,
					   Parity      bigint, CreateLSN   numeric(38));'
print(@sql)						   
EXEC (@sql)					   
EXEC sp_MSforeachdb N'Use [?]; 

				INSERT INTO ##VLFInfo 
				EXEC sp_executesql N''DBCC LOGINFO([?])''; 
	 
				INSERT INTO #VLFCountResults 
				SELECT DB_NAME(), COUNT(*) 
				FROM ##VLFInfo; 

				TRUNCATE TABLE ##VLFInfo;'
	 
				   
end
else
begin	
print '2012+' 
set @sql = 
'CREATE TABLE ##VLFInfo (RecoveryUnitId int,
						FileID  int,
					   FileSize bigint, StartOffset bigint,
					   FSeqNo      bigint, [Status]    bigint,
					   Parity      bigint, CreateLSN   numeric(38));'
print(@sql)	
EXEC (@sql)							   
EXEC sp_MSforeachdb N'Use [?]; 

				INSERT INTO ##VLFInfo 
				EXEC sp_executesql N''DBCC LOGINFO([?])''; 
	 
				INSERT INTO #VLFCountResults 
				SELECT DB_NAME(), COUNT(*) 
				FROM ##VLFInfo; 

				TRUNCATE TABLE ##VLFInfo;'
					   
end




	 
SELECT DatabaseName, VLFCount  
FROM #VLFCountResults
ORDER BY VLFCount DESC;
	 
DROP TABLE ##VLFInfo;
DROP TABLE #VLFCountResults;
