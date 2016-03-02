function get-instance 
{    
	
	param($instanceName)
	
	[reflection.assembly]::LoadWithPartialName("Microsoft.SqlServer.Smo")|out-null

if ($instanceName -eq "JSISTBL2FSQL\PEOPLESOFT" ) {$instanceName = "JSISTBL2FSQL\PEOPLESOFT,1435"}
if ($instanceName -eq "JSISTBL2FSQL\ADBASE" ) {$instanceName = "JSISTBL2FSQL\ADBASE,1436"}	

	$instance = new-object ("Microsoft.SqlServer.Management.Smo.Server") $instanceName
	
	
	
	#trap [System.Exception] 
	#{ 
	#    $exception = $_.Exception.GetType().Name
	#    $exception|write-host 
	#	#"Get-Instance,$instanceName,$exception"|Add-Content $err
	#	continue; 
	#}

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


#write-host "instance name: $instname" 	

	$instance|
	foreach{  add-member -in $_ -membertype noteproperty ServerName $($ServerName ) -Force
			add-member -in $_ -membertype noteproperty InstanceName $($instname) -Force
			add-member -in $_ -membertype noteproperty Collation $($_.Collation) -Force
			add-member -in $_ -membertype noteproperty Edition $($_.Information.Edition) -Force
			add-member -in $_ -membertype noteproperty ServicePack $($_.Information.ProductLevel) -Force
			add-member -in $_ -membertype noteproperty MaxDOP $($_.Configuration.MaxDegreeOfParallelism.RunValue)
			add-member -in $_ -membertype noteproperty CTFP $($_.Configuration.CostThresholdForParallelism.RunValue)
			add-member -in $_ -membertype noteproperty PhysicalMemory $($_.PhysicalMemory)  -Force
			add-member -in $_ -membertype noteproperty MinServerMemory $($_.Configuration.MinServerMemory.RunValue)
			add-member -in $_ -membertype noteproperty MaxServerMemory $($_.Configuration.MaxServerMemory.RunValue)
			add-member -in $_ -membertype noteproperty IsAWEenabled $(if ($_.Configuration.AweEnabled.RunValue -eq 0){$false} else {$true})
			add-member -in $_ -membertype noteproperty IsSqlCLRenabled $(if ($_.Configuration.IsSqlClrEnabled.RunValue -eq 0){$false} else {$true})
			add-member -in $_ -membertype noteproperty IsXPCmdShellenabled $(if ($_.Configuration.XPCmdShellEnabled.RunValue -eq 0){$false} else {$true})
			add-member -in $_ -membertype noteproperty IsSqlMailXPsenabled $(if ($_.Configuration.SqlMailXPsEnabled.RunValue -eq 0){$false} else {$true})
			add-member -in $_ -membertype noteproperty IsInSingleUserMode $($_.IsSingleUser)
			add-member -in $_ -membertype noteproperty IsClustered $($_.information.IsClustered) -Force
			add-member -in $_ -membertype noteproperty OSVersion $($_.information.OSVersion) -Force
			add-member -in $_ -membertype noteproperty Platform $($_.information.Platform) -Force
			add-member -in $_ -membertype noteproperty Processors $($_.information.Processors) -Force
			add-member -in $_ -membertype noteproperty SQLBuildClrVersion $([string]$_.BuildClrVersion.Major + "." + [string]$_.BuildClrVersion.Minor + "." + [string]$_.BuildClrVersion.Build  + "." + [string]$_.BuildClrVersion.Revision)
			add-member -in $_ -membertype noteproperty SQLVersion $([string]$_.Version.Major + "." + [string]$_.Version.Minor + "." + [string]$_.Version.Build  + "." + [string]$_.Version.Revision)
			add-member -in $_ -membertype noteproperty IsADenabled $($_.ActiveDirectory.IsEnabled)
			add-member -in $_ -membertype noteproperty IsADregistered $($_.ActiveDirectory.IsRegistered)
			add-member -in $_ -membertype noteproperty IsFullTxtInstalled $($_.IsFullTextInstalled)
			add-member -in $_ -membertype noteproperty IsFullTxtenabled $($false)#$($_.FullTextService.LoadOSResourcesEnabled)
			add-member -in $_ -membertype noteproperty SecurityMode $($_.LoginMode)
			add-member -in $_ -membertype noteproperty IsDBMailenabled $(if($_.Configuration.DatabaseMailEnabled.RunValue  -eq 0){$false} else {$true}) -passthru
			}|	
	select Collation, Edition, SQLVersion, ServicePack, MaxDOP, CTFP, PhysicalMemory, MinServerMemory, MaxServerMemory, `
	IsAWEenabled,IsSqlCLRenabled, IsXPCmdShellenabled, IsSqlMailXPsenabled,`
	IsDBMailenabled, IsFullTextInstalled, IsFullTxtenabled, SecurityMode,IsInSingleUserMode, ServiceAccount,Processors, `
	IsClustered, OSVersion, Platform

}

 