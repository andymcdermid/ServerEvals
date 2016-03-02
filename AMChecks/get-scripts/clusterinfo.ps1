 
# ------------------------------------------------------------------------
### <Script>
### <Author>
### Chad Miller
### </Author>
### <Description>
### Defines functions for working with Microsoft Cluster Service (MSCS)
### Updated 8/3/2011
### Added Authentication PacketPrivacy to fix Access Denied errorson
### Windows 2008/2008 R2 clusters
### </Description>
### <Usage>
### . ./LibraryMSCS.ps1
### </Usage>
### </Script>
# ------------------------------------------------------------------------
 
#######################
function Get-Cluster
{
    param($cluster)
   
    gwmi -class "MSCluster_Cluster" -namespace "root\mscluster" -computername $cluster -Authentication PacketPrivacy
 
} #Get-Cluster
 
#######################
function Get-ClusterName
{
    param($cluster)
   
    Get-Cluster $cluster | select -ExpandProperty name
 
} #Get-ClusterName
 
#######################
function Get-ClusterNode
{
    param($cluster)
   
    gwmi -class MSCluster_Node -namespace "root\mscluster" -computername $cluster -Authentication PacketPrivacy | add-member -pass NoteProperty Cluster $cluster
 
} #Get-ClusterNode
 
#######################
function Get-ClusterSQLVirtual
{
    param($cluster)
   
    gwmi -class "MSCluster_Resource" -namespace "root\mscluster" -computername $cluster  -Authentication PacketPrivacy | where {$_.type -eq "SQL Server"} | Select @{n='Cluster';e={$cluster}}, Name, State, @{n='VirtualServerName';e={$_.PrivateProperties.VirtualServerName}}, @{n='InstanceName';e={$_.PrivateProperties.InstanceName}}, `
    @{n='ServerInstance';e={("{0}\{1}" -f $_.PrivateProperties.VirtualServerName,$_.PrivateProperties.InstanceName).TrimEnd('\')}}, `
    @{n='Node';e={$(gwmi -namespace "root\mscluster" -computerName $cluster -Authentication PacketPrivacy -query "ASSOCIATORS OF {MSCluster_Resource.Name='$($_.Name)'} WHERE AssocClass = MSCluster_NodeToActiveResource" | Select -ExpandProperty Name)}}
   
} #Get-ClusterSQLVirtual
 
#######################
function Get-ClusterNetworkName
{
    param($cluster)
   
    gwmi -class "MSCluster_Resource" -namespace "root\mscluster" -computername $cluster -Authentication PacketPrivacy | where {$_.type -eq "Network Name"} | Select @{n='Cluster';e={$cluster}}, Name, State, @{n='NetworkName';e={$_.PrivateProperties.Name}}, `
    @{n='Node';e={$(gwmi -namespace "root\mscluster" -computerName $cluster -Authentication PacketPrivacy -query "ASSOCIATORS OF {MSCluster_Resource.Name='$($_.Name)'} WHERE AssocClass = MSCluster_NodeToActiveResource" | Select -ExpandProperty Name)}}
       
} #Get-ClusterNetworkName
 
#######################
function Get-ClusterResource
{
    param($cluster)
    gwmi -ComputerName $cluster -Authentication PacketPrivacy -Namespace "root\mscluster" -Class MSCluster_Resource | add-member -pass NoteProperty Cluster $cluster |
    add-member -pass ScriptProperty Node `
    { gwmi -namespace "root\mscluster" -computerName $this.Cluster -Authentication PacketPrivacy -query "ASSOCIATORS OF {MSCluster_Resource.Name='$($this.Name)'} WHERE AssocClass = MSCluster_NodeToActiveResource" | Select -ExpandProperty Name } |
    add-member -pass ScriptProperty Group `
    { gwmi -ComputerName $this.Cluster -Authentication PacketPrivacy -Namespace "root\mscluster" -query "ASSOCIATORS OF {MSCluster_Resource.Name='$($this.Name)'} WHERE AssocClass = MSCluster_ResourceGroupToResource" | Select -ExpandProperty Name }
       
} #Get-ClusterResource
 
#######################
function Get-ClusterGroup
{
    param($cluster)
   
    gwmi -class MSCluster_ResourceGroup -namespace "root\mscluster" -computername $cluster -Authentication PacketPrivacy | add-member -pass NoteProperty Cluster $cluster  |
    add-member -pass ScriptProperty Node `
    { gwmi -namespace "root\mscluster" -computerName $this.Cluster -Authentication PacketPrivacy -query "ASSOCIATORS OF {MSCluster_ResourceGroup.Name='$($this.Name)'} WHERE AssocClass = MSCluster_NodeToActiveGroup" | Select -ExpandProperty Name } |
    add-member -pass ScriptProperty PreferredNodes `
    { @(,(gwmi -namespace "root\mscluster" -computerName $this.Cluster -Authentication PacketPrivacy -query "ASSOCIATORS OF {MSCluster_ResourceGroup.Name='$($this.Name)'} WHERE AssocClass = MSCluster_ResourceGroupToPreferredNode" | Select -ExpandProperty Name)) }
 
} #Get-ClusterGroup