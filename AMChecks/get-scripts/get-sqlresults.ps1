function get-sqlresults ($instanceName,$sqlfile)
{


		[reflection.assembly]::LoadWithPartialName( "Microsoft.SqlServer.Smo" )|Out-Null
		$instance = new-object ("Microsoft.SqlServer.Management.Smo.Server") $instanceName
		
$query = get-content ".\get-scripts\$sqlfile.sql"
		
 
		
if ($instance.VersionMajor -eq 8) 
	{
	$ServerName = $instance.NetName
	$instname = if ($instance.ServiceName -eq "MSSQLSERVER") 
						{$instance.NetName} 
				else {"$($instance.NetName)\$($instance.Name)" }
	$dirname  = $instname -replace("\\","-") 
	}
elseif ($instance.isclustered) 
	{
	#write-host "is clustered $($instance.isclustered)"
	#$instance|select NetName,InstanceName,ComputerNamePhysicalNetBIOS
	$ServerName = $instance.ComputerNamePhysicalNetBIOS
	$instname = if ($instance.InstanceName) 
		{"$($instance.NetName)\$($instance.InstanceName)" } 
				else {$instance.NetName}
	$dirname  = "$ServerName-$instname" -replace("\\","-")
	}
else
	{
	$ServerName = $instance.NetName
	$instname = if ($instance.InstanceName) 
			{"$($instance.ComputerNamePhysicalNetBIOS)\$($instance.InstanceName)" } 
		else {$instance.ComputerNamePhysicalNetBIOS}
	$dirname  = $instname -replace("\\","-") 
	}
	

 
 
$version = $instance.VersionMajor

		if($version -gt 8)
		{
		
		$x = $instance.databases['master']
		$results = $x.ExecuteWithResults($query)
			

		$results.tables[0]|select @{Name='Server';Expression={"$ServerName"}},@{Name='Instance';Expression={"$instname"}}, * -ExcludeProperty RowError,RowState,Table,ItemArray,HasErrors|convertto-csv -NoTypeInformation|%{$_ -replace '"',""}|out-file ".\$dirname\$sqlfile.csv" -fo

		
		}
		Else
		{Write-Host "$instname version $version -  has no $sqlfile stat this version"}
}
