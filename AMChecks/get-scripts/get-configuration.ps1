function get-configuration
{
   param($instanceName)

if ($instanceName -eq "JSISTBL2FSQL\PEOPLESOFT" ) {$instanceName = "JSISTBL2FSQL\PEOPLESOFT,1435"}
if ($instanceName -eq "JSISTBL2FSQL\ADBASE" ) {$instanceName = "JSISTBL2FSQL\ADBASE,1436"}
	
	[reflection.assembly]::LoadWithPartialName("Microsoft.SqlServer.Smo")|out-null
	
	$instance = new-object ("Microsoft.SqlServer.Management.Smo.Server") $instanceName
	
	
	
	trap [System.Exception] 
	{ 
	    $exception = $_.Exception.GetType().Name
	    $exception|write-host 
		#"Get-Instance,$instanceName,$exception"|Add-Content $err
		continue; 
	}



	#show advanced options
	$sao = $instance.Configuration.ShowAdvancedOptions.RunValue
	if ($sao -eq 0)
	{$instance.Configuration.ShowAdvancedOptions.ConfigValue = 1;
	$instance.Configuration.Alter()}

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

	$configs = $instance.configuration.properties

	$configs|
		foreach{ 		add-member -in $_ -membertype noteproperty ServerName $($ServerName ) -Force
					add-member -in $_ -membertype noteproperty InstanceName $($instname)
					add-member -in $_ -membertype noteproperty DisplayName $($_.DisplayName) -Force
					add-member -in $_ -membertype noteproperty RunValue $($_.RunValue) -Force
					add-member -in $_ -membertype noteproperty ConfigValue $($_.ConfigValue) -Force
					add-member -in $_ -membertype noteproperty Minimum $($_.Minimum) -Force
					add-member -in $_ -membertype noteproperty Maximum $($_.Maximum) -Force
					add-member -in $_ -membertype noteproperty Description $($_.Description) -Force -PassThru
		}|Select ServerName, InstanceName, DisplayName, RunValue, ConfigValue, Minimum, Maximum, Description

}