

SELECT isnull([name], 'none') 'name'
FROM sysobjects
WHERE type = 'P'
  AND OBJECTPROPERTY(id, 'ExecIsStartUp') = 1
  union 
  select 'none'