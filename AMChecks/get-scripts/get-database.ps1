function get-database
{	 param($instanceName)

		
		[reflection.assembly]::LoadWithPartialName( "Microsoft.SqlServer.Smo" )|Out-Null
		$instance = new-object ("Microsoft.SqlServer.Management.Smo.Server") $instanceName	
		
		trap [System.Exception] 
		{ 
		    $exception = $_.Exception.GetType().Name
		    $exception|write-host 
			#"Get-Databases,$instanceName,$exception"|Add-Content $err
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

		$instance.Databases|
			foreach{   add-member -in $_ -membertype noteproperty ServerName $($ServerName ) -Force
				add-member -in $_ -membertype noteproperty InstanceName $($instname) -Force
				add-member -in $_ -membertype noteproperty DBName  $($_.name)  -Force
				add-member -in $_ -membertype noteproperty DBid  $($_.ID)  -Force
				add-member -in $_ -membertype noteproperty Status $($_.Status -replace(",",":") )   -Force
				add-member -in $_ -membertype noteproperty Owner $($_.Owner)  -Force
				add-member -in $_ -membertype noteproperty RecoveryModel $($_.RecoveryModel)  -Force
				add-member -in $_ -membertype noteproperty UserAccess $($_.UserAccess) -Force
				add-member -in $_ -membertype noteproperty PageVerify $($_.PageVerify) -Force
				add-member -in $_ -membertype noteproperty AutoShrink $($_.AutoShrink) -Force 
				add-member -in $_ -membertype noteproperty AutoClose $($_.AutoClose) -Force
				add-member -in $_ -membertype noteproperty LastBackupDate $($_.LastBackupDate) -Force
				add-member -in $_ -membertype noteproperty LastDifferentialBackupDate $($_.LastDifferentialBackupDate) -Force 
				add-member -in $_ -membertype noteproperty LastLogBackupDate $($_.LastLogBackupDate) -Force
				add-member -in $_ -membertype noteproperty SizeMB $($_.SizeMB) -Force
				add-member -in $_ -membertype noteproperty SpaceAvailableMB $($_.SpaceAvailable) -Force
				add-member -in $_ -membertype noteproperty DataspaceUsageMB $($_.DataspaceUsage) -Force
				add-member -in $_ -membertype noteproperty IndexSpaceUsageMB $($_.IndexSpaceUsage) -Force
				add-member -in $_ -membertype noteproperty AutoCreateStatisticsEnabled $($_.AutoCreateStatisticsEnabled) -Force
				add-member -in $_ -membertype noteproperty AutoUpdateStatisticsAsync $($_.AutoUpdateStatisticsAsync) -Force
				add-member -in $_ -membertype noteproperty AutoUpdateStatisticsEnabled $($_.AutoUpdateStatisticsEnabled) -Force
				add-member -in $_ -membertype noteproperty ChangeTrackingEnabled $($_.ChangeTrackingEnabled) -Force
				add-member -in $_ -membertype noteproperty Collation $($_.Collation) -Force
				add-member -in $_ -membertype noteproperty CompatibilityLevel $($_.CompatibilityLevel) -Force
				add-member -in $_ -membertype noteproperty IsDatabaseSnapshot $($_.IsDatabaseSnapshot) -Force
				add-member -in $_ -membertype noteproperty IsManagementDataWarehouse $($_.IsManagementDataWarehouse) -Force
				add-member -in $_ -membertype noteproperty IsParameterizationForced $($_.IsParameterizationForced) -Force
				add-member -in $_ -membertype noteproperty IsReadCommittedSnapshotOn $($_.IsReadCommittedSnapshotOn) -Force
				add-member -in $_ -membertype noteproperty LogReuseWaitStatus $($_.LogReuseWaitStatus) -Force
				add-member -in $_ -membertype noteproperty MirroringPartner $($_.MirroringPartner) -Force
				add-member -in $_ -membertype noteproperty MirroringPartnerInstance $($_.MirroringPartnerInstance) -Force
				add-member -in $_ -membertype noteproperty MirroringRedoQueueMaxSize $($_.MirroringRedoQueueMaxSize) -Force
				add-member -in $_ -membertype noteproperty MirroringRoleSequence $($_.MirroringRoleSequence) -Force
				add-member -in $_ -membertype noteproperty MirroringSafetyLevel $($_.MirroringSafetyLevel) -Force
				add-member -in $_ -membertype noteproperty MirroringSafetySequence $($_.MirroringSafetySequence) -Force
				add-member -in $_ -membertype noteproperty MirroringStatus $($_.MirroringStatus) -Force
				add-member -in $_ -membertype noteproperty MirroringTimeout $($_.MirroringTimeout) -Force
				add-member -in $_ -membertype noteproperty MirroringWitness $($_.MirroringWitness) -Force
				add-member -in $_ -membertype noteproperty MirroringWitnessStatus $($_.MirroringWitnessStatus) -Force
				add-member -in $_ -membertype noteproperty ReplicationOptions $($_.ReplicationOptions) -Force
				add-member -in $_ -membertype noteproperty ReadOnly $($_.ReadOnly) -Force
				add-member -in $_ -membertype noteproperty SnapshotIsolationState $($_.SnapshotIsolationState) -Force -PassThru
			}|select DBName, DBID, Status, Owner, RecoveryModel, UserAccess, PageVerify, AutoShrink, AutoClose,LastBackupDate, `
					LastDifferentialBackupDate, LastLogBackupDate,SizeMB,SpaceAvailableMB,DataspaceUsageMB,IndexSpaceUsageMB, `
					AutoCreateStatisticsEnabled,AutoUpdateStatisticsAsync,AutoUpdateStatisticsEnabled,ChangeTrackingEnabled,Collation, `
					CompatibilityLevel,IsDatabaseSnapshot,IsManagementDataWarehouse,IsParameterizationForced,IsReadCommittedSnapshotOn, `
					LogReuseWaitStatus,MirroringPartner,MirroringPartnerInstance,MirroringRedoQueueMaxSize,MirroringRoleSequence, `
					MirroringSafetyLevel,MirroringSafetySequence,MirroringStatus,MirroringTimeout,MirroringWitness,MirroringWitnessStatus, `
					ReplicationOptions,ReadOnly,SnapshotIsolationState
			
			

}
