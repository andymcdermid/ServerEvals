function get-alerts
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
		$alerts = $sqlAgent.Alerts|where-object {$_.IsEnabled -eq 1}
		
		$alerts|
		foreach{ add-member -in $_ -membertype noteproperty ServerName $($ServerName ) -Force
			 add-member -in $_ -membertype noteproperty InstanceName $($instname) -Force
				add-member -in $_ -membertype noteproperty Name  $($_.name) -force
				add-member -in $_ -membertype noteproperty Type $($_.AlertType) -force
				add-member -in $_ -membertype noteproperty IsEnabled $($_.IsEnabled) -force  -PassThru
				}|Select Name, Type, IsEnabled
				
				
}				
				
