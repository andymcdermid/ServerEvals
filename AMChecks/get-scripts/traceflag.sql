create table #DBCCTrace(
TraceFlag varchar(100), 
Status int, Global int,
Session int)

insert into #DBCCTrace
exec ('DBCC TRACESTATUS (-1) WITH NO_INFOMSGS')

select * from #DBCCTrace
union
select null,null,null,null

drop table #DBCCTrace