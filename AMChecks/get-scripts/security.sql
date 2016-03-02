
SET NOCOUNT ON
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
declare @SQL varchar(max)
set @SQL = ''
select  top 5 @SQL = @SQL +
'Select  ' + quotename(name,'''') + ' COLLATE DATABASE_DEFAULT DBName, 
isnull(y.name,''orphaned'') COLLATE DATABASE_DEFAULT  [login], 
x.name COLLATE DATABASE_DEFAULT [user] , 
x.type COLLATE DATABASE_DEFAULT [type],
IS_SRVROLEMEMBER(''sysadmin'',y.name )  is_sa
from ['+name+'].sys.database_principals x
left join sys.server_principals y
on x.sid = y.sid
where x.type in (''S'',''U'') AND x.name NOT IN (''dbo'', ''guest'', ''INFORMATION_SCHEMA'',''sys'')'
 + CHAR(13)+
 'union'
 + CHAR(13) 

from  sys.databases
where  state_desc ='ONLINE'
and database_id not in (1,2,3)

select @SQL = Left(@SQL, len (@SQL)-6)

execute(@SQL)

     
     