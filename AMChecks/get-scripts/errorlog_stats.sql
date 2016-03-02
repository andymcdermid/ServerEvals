
create table #enumerr(
ArchiveNo int, 
ArchiveDate datetime,
LogFileSizeByte int)

insert into #enumerr
exec xp_enumerrorlogs


select * from #enumerr
union
select null,null,null

drop table #enumerr