SET NOCOUNT ON
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
declare @SQL varchar(8000)
set @SQL = ''
declare @version varchar(300)
SELECT @version = CAST(SERVERPROPERTY('ProductVersion') as nvarchar(128)) 
declare @majversion int
SELECT @majversion = left(@version,charindex('.',@version)-1) 
if (@majversion) >9
begin
set @SQL = '
SELECT 
bs. database_name AS [DBName] ,
CONVERT ( BIGINT, bs .compressed_backup_size / 1048576 ) AS [CompressedBackupSizeMB],
CONVERT ( BIGINT, bs .backup_size / 1048576 ) AS [UncompressedBackupSizeMB],
DATEDIFF ( SECOND, bs .backup_start_date, bs.backup_finish_date ) AS [BackupElapsedTimeSec],
bs.backup_finish_date AS [BackupFinishDate], 
mf.physical_device_name as [BackupPath]
FROM msdb..backupset AS bs WITH (NOLOCK)
join msdb..backupmediafamily mf on bs.media_set_id = mf.media_set_id
WHERE DATEDIFF (SECOND , bs. backup_start_date, bs .backup_finish_date) > 0
AND bs. backup_size > 0
AND bs. type = ''D''
and bs.backup_finish_date >= DATEADD(D,-10, GETDATE())
ORDER BY bs.backup_finish_date DESC;'
end
else 
begin
set @SQL = '
SELECT 
bs. database_name AS [DBName] ,
0 AS [CompressedBackupSizeMB],
CONVERT ( BIGINT, bs .backup_size / 1048576 ) AS [UncompressedBackupSizeMB],
DATEDIFF ( SECOND, bs .backup_start_date, bs.backup_finish_date ) AS [BackupElapsedTimeSec],
bs.backup_finish_date AS [BackupFinishDate], 
mf.physical_device_name as [BackupPath]
FROM msdb..backupset AS bs WITH (NOLOCK)
join msdb..backupmediafamily mf on bs.media_set_id = mf.media_set_id
WHERE DATEDIFF (SECOND , bs. backup_start_date, bs .backup_finish_date) > 0
AND bs. backup_size > 0
AND bs. type = ''D''
and bs.backup_finish_date >= DATEADD(D,-10, GETDATE())
ORDER BY bs.backup_finish_date DESC;'
end

exec(@SQL)
