function get-server
{   param($ComputerName)
	#Write-Host "passed in $clientid,$ComputerName, $notes"
	
	trap [System.Exception] 
	{ 
	    $exception = $_.Exception.GetType().Name
	    $exception|write-host 
		#"Get-Machine,$computerName,$exception"|Add-Content $err
		#continue; 
	}
	
	#if (Test-Connect -ServerName "$ComputerName"){
	
    $os = Get-WmiObject -computername "$ComputerName" Win32_OperatingSystem |  Select OSArchitecture,Caption,Version,CSDVersion
    $prc = Get-WmiObject -computername "$ComputerName" Win32_Processor |  Select Name, NumberOfCores, NumberOfLogicalProcessors, MaxClockSpeed -first 1
	
    Get-WmiObject -computername "$ComputerName" Win32_ComputerSystem  | 
	foreach { $MachineName = $_.name #reset here in case this is a cluster
	
			add-member -in $_ -membertype noteproperty MachineName $($_.name)
			add-member -in $_ -membertype noteproperty Make $($_.Manufacturer -replace(',',';'))
			add-member -in $_ -membertype noteproperty ProcType $($prc.Name -replace(',',';'))
			add-member -in $_ -membertype noteproperty ClockSpeed $($prc.MaxClockSpeed)
			add-member -in $_ -membertype noteproperty Cores $($prc.NumberOfCores)
			add-member -in $_ -membertype noteproperty NumOfVisProcs $($_.NumberOfLogicalProcessors)
			add-member -in $_ -membertype noteproperty RamAmtGB $([Math]::Round($_.TotalPhysicalMemory/1GB,2))
			add-member -in $_ -membertype noteproperty IsPAEenabled $(IF ($_.PAEEnabled -like "True") {$true} ELSE {$false})
			add-member -in $_ -membertype noteproperty OS $($($OS.OSArchitecture  + " " + $OS.Caption) -replace(',',';') )
			add-member -in $_ -membertype noteproperty OSversionNum $($OS.Version)
			add-member -in $_ -membertype noteproperty OSsplevel $($OS.CSDVersion) -passThru
			} |select Make,Model, 
				ProcType, ClockSpeed, Cores, NumOfVisProcs, RamAmtGB, IsPAEenabled, OS, 
				OSversionNum, OSsplevel
#}
#else
#{
#Write-Host "Cannot connect to $ComputerName"
#}

}
