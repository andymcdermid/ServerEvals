SELECT cp.cacheobjtype, 
cp.objtype,
sum(cp.usecounts) [Use Counts], 
sum(cast(cp.size_in_bytes as bigint))/1024 AS [Plan Size in KB]
FROM sys.dm_exec_cached_plans AS cp WITH (NOLOCK)
WHERE cp.cacheobjtype like N'Compiled Plan%' 
group by cp.cacheobjtype, cp.objtype
union
select null,null,null,null
