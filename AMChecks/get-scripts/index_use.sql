select DB_NAME(database_id) DBName, object_id, index_id, user_seeks, user_scans, user_lookups, user_updates
from sys.dm_db_index_usage_stats
where (user_seeks + user_scans + user_lookups)=0
union 
select DB_NAME(database_id) DBName, object_id, index_id, user_seeks, user_scans, user_lookups, user_updates
from sys.dm_db_index_usage_stats ius
where user_updates > (user_seeks + user_scans + user_lookups)
and  (user_seeks + user_scans + user_lookups)<> 0
union 
select null, null, null, null, null, null, null

