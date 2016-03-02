SET NOCOUNT ON
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
declare @SQL varchar(max)
declare @fragthresh varchar(3)
declare @pagecntthresh varchar(6)
set @fragthresh = '50' 
set @pagecntthresh = '1000'
set @SQL = ''
select   @SQL = @SQL +
'select  ' + quotename(name,'''') + ' COLLATE DATABASE_DEFAULT DBName, 
object_name(ios.object_id,' + convert(varchar(10),database_id) + ')  COLLATE DATABASE_DEFAULT object_name, 
i.name  COLLATE DATABASE_DEFAULT index_name, 
ios.index_type_desc  COLLATE DATABASE_DEFAULT index_type_desc, 
ios.alloc_unit_type_desc, ios.avg_fragmentation_in_percent, 
ios.page_count
from sys.dm_db_index_physical_stats(' + convert(varchar(10),database_id) + ',null,null,null,null) ios
left outer join sys.dm_db_index_usage_stats ius
on ios.database_id = ius.database_id and ios.object_id = ius.object_id and ios.index_id = ius.index_id
join ['+name+'].sys.indexes i 
on ios.object_id = i.object_id
and ios.index_id = i.index_id
where ios.page_count > '+@pagecntthresh+'
and ios.avg_fragmentation_in_percent > '+@fragthresh+'
and (isnull(ius.user_seeks,0) + isnull(ius.user_seeks,0) + isnull(ius.user_lookups,0)) > 1'
 + CHAR(13)+
 'union'
 + CHAR(13) 

from  sys.databases
where  state_desc ='ONLINE'
and database_id not in (1,2,3)
and name not like 'ReportServer$%'

select @SQL = Left(@SQL, len (@SQL)-6)


exec(@SQL)


