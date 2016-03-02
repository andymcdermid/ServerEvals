function get-errorlog
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

		$version = $instance.VersionMajor
		
		if ($version -gt 8)
			{
			#Write-Host "for the last 3 day"
			$date2 = get-date
			$date1 = $date2.AddDays(-3) #(-$daystoget)
			$errorlog  = $instance.ReadErrorLog(0) | where-object {$_.LogDate -gt $date1 -and $_.ProcessInfo -ne "Backup" -and $_.ProcessInfo -ne "Logon"}
			}
			else
			{
			#Write-Host "for the last 30 records (pre-2K5)"
			$errorlog  = $instance.ReadErrorLog(0) | sort-object logdate -descending|where-object { $_.ProcessInfo -ne "Backup" -and $_.ProcessInfo -ne "Logon"}|Select LogDate, ProcessInfo, Text -first 30
			}

			
		$errorlog|
		foreach{ 	$errorlog = [string]::join("",($($_.Text).Split("`n")))
				add-member -in $_ -membertype noteproperty ServerName $($ServerName ) -Force
				add-member -in $_ -membertype noteproperty InstanceName $($instname)
				add-member -in $_ -membertype noteproperty LogDate $($_.LogDate) -Force
				add-member -in $_ -membertype noteproperty ProcessInfo $($_.ProcessInfo) -Force
				add-member -in $_ -membertype noteproperty Text $($errorlog -replace(',',';')) -Force -PassThru
		}|Select LogDate, ProcessInfo, Text
		
		
		
}		
		