create table #linked(
ServerName varchar(max), 
Provider varchar(max),
Product varchar(max),
Datasource varchar(max),
ProviderString varchar(max),
Location varchar(max),
Cat varchar(max),
)

insert into #linked
exec sp_linkedservers


select * from #linked
union
select null,null,null,null,null,null,null

drop table #linked



