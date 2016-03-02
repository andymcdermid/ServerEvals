#####Functions######

function build_table($values,$row,$report)
{
trap [System.Exception] 
{ 
    write-host ("Trapped in function build_table " + $_.Exception.GetType().Name + "");
	continue; 
}

$c = 1
$r = $row
foreach ($v in $values)
{
$csvstr += [string]$v + ","
#Start-Sleep -m 100
$c++
}
$csvstr = $csvstr.SubString(0,$csvstr.Length-1)
#Write-Host $csvstr
$csvstr|Add-Content $report

$r++
return $r
}


Function test-sqlconn ($Server)
{
$connectionString = "Data Source=$Server;Integrated Security=true;Initial Catalog=master;Connect Timeout=3;"
$sqlConn = new-object ("Data.SqlClient.SqlConnection") $connectionString
trap
{
"failed"
Write-host "Cannot connect to $Server.";
continue
}
$sqlConn.Open()
 
if ($sqlConn.State -eq 'Open')
{
$sqlConn.Close();
"success"
}
}