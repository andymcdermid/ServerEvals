function get-jobs
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
			#"Get-DatabaseDataFiles,$instanceName,$exception"|Add-Content $err
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

		$sqlAgent = $instance.JobServer
		$jobs = $sqlAgent.Jobs|where-object {$_.IsEnabled -eq 1}
		
		$jobs|
		foreach{ add-member -in $_ -membertype noteproperty ServerName $($ServerName ) -Force
			add-member -in $_ -membertype noteproperty InstanceName $($instname) -Force
				add-member -in $_ -membertype noteproperty Name  $($_.name) -force
				add-member -in $_ -membertype noteproperty Owner  $($_.OwnerLoginName) -force
				add-member -in $_ -membertype noteproperty LastRunDate  $($_.LastRunDate) -force
				add-member -in $_ -membertype noteproperty LastRunOutCome  $([string]$_.LastRunOutCome) -force
				add-member -in $_ -membertype noteproperty NextRunDate  $($_.NextRunDate) -force -PassThru
				}|Select Name, Owner, LastRunDate, LastRunOutCome, NextRunDate
				
				
}				
				
