
#.dot source the functions
. .\get-scripts\get-disk.ps1
. .\get-scripts\get-server.ps1
. .\get-scripts\get-instance.ps1
. .\get-scripts\get-database.ps1
. .\get-scripts\get-databasedatafile.ps1
. .\get-scripts\get-databaselogfile.ps1
. .\get-scripts\get-job.ps1
. .\get-scripts\get-alert.ps1
. .\get-scripts\get-errorlog.ps1
. .\get-scripts\get-configuration.ps1
. .\get-scripts\functions.ps1
. .\get-scripts\test-sqlconn.ps1
. .\get-scripts\get-sqlresults.ps1
. .\get-scripts\clusterinfo.ps1



#####Start#####
$reportdate = get-date

$servers = get-content .\servers.txt

#load up the server names
foreach ($hostname in $servers){

Write-host "Begin server eval collection for $hostname" -ForegroundColor Green;

##lets check if its a cluster node, if so we just use the get-clusterSQLvirtual to get the virt instance names
write-host "checking is server is a cluster node"
$clustername = get-clustername $hostname
if($clustername){
write-host "it is a cluster node"
$sqlservers = get-clusterSQLvirtual $hostname|select -property @{N='Name';E={$_.ServerInstance}}
write-host "these are the virtual failover sql instances"
$sqlservers|select name
}

Else{
##get the instances available on each server
write-host "no clusters here, getting running instances on this server"
$sqlservers = Get-WmiObject -ComputerName $hostname win32_service | `
	where {$_.name -like "MSSQL$*" -or $_.name -eq "MSSQLSERVER" -and $_.name -notlike "*##SSEE*"  -and $_.State -eq "Running"}
write-host "these are the sql instances"
$sqlservers|select name
}

if ($sqlservers -eq $null)
{Write-host "We cannot connect to $hostname" -ForegroundColor Yellow;
Write-Host "$hostname,$hostname,Unable to Connect WMI,Unable to Connect WMI"
#"$s,$s,Unable to Connect WMI,Unable to Connect WMI"|out-file $outfile -append;
continue
}



#init this counter
$instancecounter = 1

#iterate each instance
foreach ($i in $sqlservers)
{


write-host "this is the instancename: $($i.name)"

#rework the instance name
	
	if ($i.name.Contains("MSSQL$"))
	{
		$n = $($i.name.Substring(6))
		$name = "$hostname\$n"
		$dname = "$hostname-$n"
	}
	elseif ($i.name.Contains("MSSQLSERVER"))
	{ 
		$name = $hostname
		$dname = $hostname
	}
	else #it is a cluster node
	{ 
		$name = $($i.name)
		$vname = $($i.name) -replace("\\","-")
		$dname = "$hostname-$vname"
	}



Write-Host "now getting info for this instance..."
Write-Host $name -ForegroundColor Yellow

Write-Host "on host..."
Write-Host $hostname  -ForegroundColor Yellow


#test the connection, if no connection, skip this instance
$test = test-sqlconn $name
Write-host "SQL connection Test $test "
if ( $test -ne "success")
{
Write-host "we cannot connect to the sql server $name" -ForegroundColor Yellow;
continue
}

#if it is an express lets just forget about it.
if ( $name -like "*SQLEXPRESS")
{
Write-host "if it is an express lets just forget about it. $name" -ForegroundColor Yellow;
continue
}

#initialize a var to keep track of the rows
$rownum = 1

##add a sub-dir to the current dir collect csv files
write-host "building a new directoy here: $PWD\$dname" -ForegroundColor Yellow
New-Item "$PWD\$dname" -ItemType directory -Force
Remove-Item "$PWD\$dname\*" -include *.csv
Remove-Item "$PWD\$dname\*" -include *.txt

#scroll down a row
$rownum++

###################################################################3

#server
write-host "#server"
$report = "$PWD\$dname\server.csv"
get-server $hostname | select @{Name='Server';Expression={"$hostname"}},@{Name='Instance';Expression={"$name"}}, * -ExcludeProperty RowError,RowState,Table,ItemArray,HasErrors|convertto-csv -NoTypeInformation|%{$_ -replace '"',""}|out-file "$report" -fo


#disk
write-host "#disk"
$report = "$PWD\$dname\disk.csv"
get-disk $hostname | select @{Name='Server';Expression={"$hostname"}},@{Name='Instance';Expression={"$name"}}, * -ExcludeProperty RowError,RowState,Table,ItemArray,HasErrors|convertto-csv -NoTypeInformation|%{$_ -replace '"',""}|out-file "$report" -fo


#instance
write-host "#instance"
$report = "$PWD\$dname\instance.csv"
get-instance $name | select @{Name='Server';Expression={"$hostname"}},@{Name='Instance';Expression={"$name"}}, * -ExcludeProperty RowError,RowState,Table,ItemArray,HasErrors|convertto-csv -NoTypeInformation|%{$_ -replace '"',""}|out-file "$report" -fo


#database
write-host "#database"
$report = "$PWD\$dname\database.csv"
get-database $name | select @{Name='Server';Expression={"$hostname"}},@{Name='Instance';Expression={"$name"}}, * -ExcludeProperty RowError,RowState,Table,ItemArray,HasErrors|convertto-csv -NoTypeInformation|%{$_ -replace '"',""}|out-file "$report" -fo


#databasedatafile
write-host "#databasedatafile"
$report = "$PWD\$dname\databasefile.csv"
get-databasedatafile $name | select @{Name='Server';Expression={"$hostname"}},@{Name='Instance';Expression={"$name"}}, * -ExcludeProperty RowError,RowState,Table,ItemArray,HasErrors|convertto-csv -NoTypeInformation|%{$_ -replace '"',""}|out-file "$report" -fo
		

#databaseslogfile
$report = "$PWD\$dname\databaselogfile.csv"
get-databaselogfile $name | select @{Name='Server';Expression={"$hostname"}},@{Name='Instance';Expression={"$name"}}, * -ExcludeProperty RowError,RowState,Table,ItemArray,HasErrors|convertto-csv -NoTypeInformation|%{$_ -replace '"',""}|out-file "$report" -fo
	

#errorlog
write-host "#errorlog"
$report = "$PWD\$dname\errorlog.csv"
get-errorlog  $name |select @{Name='Server';Expression={"$hostname"}},@{Name='Instance';Expression={"$name"}}, * -ExcludeProperty RowError,RowState,Table,ItemArray,HasErrors|convertto-csv -NoTypeInformation|%{$_ -replace '"',""}|out-file "$report" -fo
	

#configuration
#write-host "#configuration"
#$report = "$PWD\$dname\configuration.csv"
#get-configuration  $name |select @{Name='Server';Expression={"$hostname"}},@{Name='Instance';Expression={"$name"}}, * -ExcludeProperty RowError,RowState,Table,ItemArray,HasErrors|convertto-csv -NoTypeInformation|%{$_ -replace '"',""}|out-file "$report" -fo


#jobs
write-host "#jobs"
$report = "$PWD\$dname\job.csv"
get-jobs $name |select @{Name='Server';Expression={"$hostname"}},@{Name='Instance';Expression={"$name"}}, * -ExcludeProperty RowError,RowState,Table,ItemArray,HasErrors|convertto-csv -NoTypeInformation|%{$_ -replace '"',""}|out-file "$report" -fo

#alerts
write-host "#alerts"
$report = "$PWD\$dname\alert.csv"
get-alerts $name |select @{Name='Server';Expression={"$hostname"}},@{Name='Instance';Expression={"$name"}}, * -ExcludeProperty RowError,RowState,Table,ItemArray,HasErrors|convertto-csv -NoTypeInformation|%{$_ -replace '"',""}|out-file "$report" -fo


##this section cycles through any .sql files in the get-script dir
$sqlfiles  = gci "$PWD\get-scripts\*.sql"
foreach($file in $sqlfiles)
{
write-host "getting sql results for $($file.basename)"
get-sqlresults $name "$($file.basename)"
}


}
}
