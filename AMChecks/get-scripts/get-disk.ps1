function get-disk
{
	param($computerName)
	
	trap [System.Exception] 
	{ 
	    $exception = $_.Exception.GetType().Name
	    $exception|write-host 
	#	"Get-Disk,$computerName,$exception"|Add-Content $err
		continue; 
	}
		
	#if (Test-Connect -ServerName "$ComputerName"){
    Get-WmiObject -computername "$ComputerName" Win32_Volume -filter "DriveType != 5 and Capacity > 0"  | 
    foreach { 
			add-member -in $_ -membertype noteproperty CaptionName $($_.Caption)
			add-member -in $_ -membertype noteproperty LableName $(if($_.Label) {$_.Label} else {'Unlabeled'})
            		add-member -in $_ -membertype noteproperty SizeGB $([math]::round(($_.Capacity/1GB),2))
			add-member -in $_ -membertype noteproperty FreeSpaceGB $([math]::round(($_.FreeSpace/1GB),2))
add-member -in $_ -membertype noteproperty UsedSpaceGB $([math]::round(( ($_.Capacity/1GB)- ($_.FreeSpace/1GB) ),2))
			add-member -in $_ -membertype noteproperty PercentFree $([math]::round((([float]$_.FreeSpace/[float]$_.Capacity) * 100),2)) -passThru
			} |select CaptionName,LableName,SizeGB,FreeSpaceGB,UsedSpaceGB,PercentFree
			 
	#}
}

