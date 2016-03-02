function get-databasedatafile
{
	    param($instanceName)

if ($instanceName -eq "JSISTBL2FSQL\PEOPLESOFT" ) {$instanceName = "JSISTBL2FSQL\PEOPLESOFT,1435"}
if ($instanceName -eq "JSISTBL2FSQL\ADBASE" ) {$instanceName = "JSISTBL2FSQL\ADBASE,1436"}

		[reflection.assembly]::LoadWithPartialName( "Microsoft.SqlServer.Smo" )|Out-Null
		$instance = new-object ("Microsoft.SqlServer.Management.Smo.Server") $instanceName
		
		trap [System.Exception] 
		{ 
		    $exception = $_.Exception.GetType().Name
		    $exception|write-host 
		#	"Get-DatabaseDataFiles,$instanceName,$exception"|Add-Content $err
			continue; 
		}
		
if ($instance.VersionMajor -eq 8) 
	{
	$ServerName = $instance.NetName
	$instname = if ($instance.ServiceName -eq "MSSQLSERVER") 
						{$instance.NetName} 
				else {"$($instance.NetName)\$($instance.Name)" } 
	}
elseif ($instance.isclustered) 
	{
	#write-host "is clustered $instance.isclustered"
	#$instance|select NetName,InstanceName,ComputerNamePhysicalNetBIOS
	$ServerName = $instance.NetName
	$instname = if ($instance.InstanceName) 
		{"$($instance.NetName)\$($instance.InstanceName)" } 
				else {$instance.NetName}
	}
else
	{
	$ServerName = $instance.NetName
	$instname = if ($instance.InstanceName) 
		{"$($instance.ComputerNamePhysicalNetBIOS)\$($instance.InstanceName)" } 
				else {$instance.ComputerNamePhysicalNetBIOS}
	}


		$databases = $instance.databases
		foreach ($db in $databases)
		{
		if ($db.Status -ne "Offline")
		{
		$dbid = $db.ID
		$dbname = $db.name
		foreach ($filegroup in $db.FileGroups)
		{
		foreach ($file in $filegroup.files)
		{
		$file|foreach{    add-member -in $_ -membertype noteproperty ServerName $($ServerName ) -Force
			add-member -in $_ -membertype noteproperty InstanceName $($instname) -Force
			add-member -in $_ -membertype noteproperty DBId $($dbid)
			add-member -in $_ -membertype noteproperty DBName $($dbname)
			add-member -in $_ -membertype noteproperty FileGroup $($_.Parent)
			add-member -in $_ -membertype noteproperty DBFileName $($_.Name)
			add-member -in $_ -membertype noteproperty FileId $($_.ID)
			add-member -in $_ -membertype noteproperty FilePath $($_.FileName)
			add-member -in $_ -membertype noteproperty IsReadOnly $($_.IsReadOnly) -force
			add-member -in $_ -membertype noteproperty IsOffline $($_.IsOffline) -force			
			add-member -in $_ -membertype noteproperty GrowthType $($_.GrowthType) -force
			add-member -in $_ -membertype noteproperty GrowthSizeMB $($_.Growth)
			add-member -in $_ -membertype noteproperty MaxSizeMB $(if ($_.MaxSize -eq -1){0} else {$_.MaxSize}) -Force
			add-member -in $_ -membertype noteproperty NumberOfDiskReads $(if($_.NumberOfDiskReads){} else {0}) -Force
			add-member -in $_ -membertype noteproperty NumberOfDiskWrites $(if($_.NumberOfDiskWrites){} else {0}) -Force
			add-member -in $_ -membertype noteproperty SizeMB $($_.Size) -Force
			add-member -in $_ -membertype noteproperty UsedSpaceMB $($_.UsedSpace) -Force -PassThru
			}|select DBId, DBName, FileGroup, DBFileName, FileId, FilePath, GrowthType, GrowthSize, IsOffline, IsReadOnly, MaxSize, NumberOfDiskReads,NumberOfDiskWrites, Size, UsedSpace
	}}}} 
}	# Get-Databasedatafiles










