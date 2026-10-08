$vcenter = "vcenter servername"

$username = "userid"

$psskey = Get-Content 'C:\Users\mmitta36\OneDrive - c:\Desktop\DJ.txt' | ConvertTo-SecureString

$cred = New-Object System.Management.Automation.PSCredential ($username,$psskey)

Function Table_format{

param(
[parameter(mandatory=$true)]$column1,
[parameter(mandatory=$true)]$column2,
[parameter(mandatory=$true)]$column3,
[parameter(mandatory=$true)]$column4)

Add-Content $report "</tr>" 
Add-content $report  "</table>" 
Add-Content $report "</body>" 
Add-Content $report "</html>" 
Add-content $report "<br >"
Add-content $report "<br >"

Add-Content $report "<html>" 
Add-Content $report "<head>" 
Add-Content $report "<meta http-equiv='Content-Type' content='text/html; charset=iso-8859-1'>" 

add-content $report '<STYLE TYPE="text/css">' 
add-content $report  "<!--" 
add-content $report  "td {" 
add-content $report  "font-family: Tahoma;" 
add-content $report  "font-size: 11px;" 
add-content $report  "border-top: 1px solid #999999;" 
add-content $report  "border-right: 1px solid #999999;" 
add-content $report  "border-bottom: 1px solid #999999;" 
add-content $report  "border-left: 1px solid #999999;" 
add-content $report  "padding-top: 0px;" 
add-content $report  "padding-right: 0px;" 
add-content $report  "padding-bottom: 0px;" 
add-content $report  "padding-left: 0px;" 
add-content $report  "}"


add-content $report  "body {" 
add-content $report  "margin-left: 5px;" 
add-content $report  "margin-top: 5px;" 
add-content $report  "margin-right: 0px;" 
add-content $report  "margin-bottom: 10px;" 
add-content $report  "" 
add-content $report  "table {" 
add-content $report  "border: thin solid #000000;" 
add-content $report  "}" 
add-content $report  "-->" 
add-content $report  "</style>" 
Add-Content $report "</head>" 
Add-Content $report "<body>" 
add-content $report  "<table width='30%' align='center'>" 
add-content $report  "<tr bgcolor='DarkSlateGray'>" 
add-content $report  "<td colspan='7' height='25' align='center'>" 
add-content $report  "<font face='tahoma' color='white' size='4'> $column1 </strong></font>" 
add-content $report  "</td>" 
add-content $report  "</tr>" 
add-content $report  "</table>" 
add-content $report  "<table width='100%'>" 
Add-Content $report  "<tr bgcolor='Teal'>" 
Add-Content $report  "<td width='10%' align='center'> <font color='white'> <B>$column2</B></td>" 
Add-Content $report  "<td width='10%' align='center'> <font color='white'> <B>$column3</B></td>" 
Add-Content $report  "<td width='10%' align='center'> <font color='white'> <B>$column4</B></td>"

Add-Content $report "</tr>" 

}

Function check_alerts{

Table_format "Active Alarms on $vcenter" "Alarm Name" "Affected Entity" "Created On"

$alarm_list = (Get-Datacenter).ExtensionData.TriggeredAlarmState

if ($alarm_list.Key -eq $null){

Add-Content $report "<tr>"
Add-Content $report "<td bgcolor= 'white' align=center>  <B> No Active Alarm </B></td>" 
Add-Content $report "<td bgcolor= 'white' align=center>  <B> No Active Alarm </B></td>" 
Add-Content $report "<td bgcolor= 'white' align=center>  <B> No Active Alarm </B></td>"

}

else{
foreach ($alert in $alarm_list){
$Alarm_Name = (Get-AlarmDefinition -Id $alert.Alarm).Name
$Object_Name = (Get-View $alert.Entity).Name
$Created_On = $alert.Time
$severity = $alert.OverallStatus

if ($severity -ieq "red"){
Add-Content $report "<tr>"
Add-Content $report "<td bgcolor= 'red' align=center>  <B> $Alarm_Name </B></td>" 
Add-Content $report "<td bgcolor= 'red' align=center>  <B> $Object_Name </B></td>" 
Add-Content $report "<td bgcolor= 'red' align=center>  <B> $Created_On </B></td>"

}
elseif ($severity -ieq "yellow"){

Add-Content $report "<tr>"

Add-Content $report "<td bgcolor= 'DarkOrange' align=center>  <B> $Alarm_Name </B></td>" 
Add-Content $report "<td bgcolor= 'DarkOrange' align=center>  <B> $Object_Name </B></td>" 
Add-Content $report "<td bgcolor= 'DarkOrange' align=center>  <B> $Created_On </B></td>" 

}

elseif ($severity -ieq "green") {

Add-Content $report "<tr>"

Add-Content $report "<td bgcolor= 'white' align=center>  <B> $Alarm_Name </B></td>" 
Add-Content $report "<td bgcolor= 'white' align=center>  <B> $Object_Name </B></td>" 
Add-Content $report "<td bgcolor= 'white' align=center>  <B> $Created_On </B></td>"

}

else {continue}
}
}

}

Function ESXi_State_Check{

Table_format "ESXi Not Connected to $vcenter" "ESXi Name" "Connection State" "Cluster Name"

$vmhost_list = Get-VMHost | where {$_.ConnectionState -ine "connected"}

if ($vmhost_list.Name -eq $null){

Add-Content $report "<tr>"
Add-Content $report "<td bgcolor= 'white' align=center>  <B> No Disconnected ESXi </B></td>" 
Add-Content $report "<td bgcolor= 'white' align=center>  <B> No Disconnected ESXi </B></td>" 
Add-Content $report "<td bgcolor= 'white' align=center>  <B> No Disconnected ESXi </B></td>"

}

else{

foreach ($ESX in $vmhost_list){

$host_name = $ESX.Name
$status = $ESX.ConnectionState
$Cluster_Name = $ESX.Parent

Add-Content $report "<tr>"

Add-Content $report "<td bgcolor= 'DarkOrange' align='center'>  <B> $host_name </B></td>" 
Add-Content $report "<td bgcolor= 'DarkOrange' align='center'>  <B> $status </B></td>" 
Add-Content $report "<td bgcolor= 'DarkOrange' align='center'>  <B> $Cluster_Name </B></td>" 


}

}

}

Function check_snapshot_aging{

Table_format "Snapshots older than 3 days" "VM Name" "Created By" "Created On"

$Snapshot_list = Get-VM | Get-Snapshot | where {$_.Created -le (Get-Date).AddDays(-3)}

if ($Snapshot_list.Name -eq $null){

Add-Content $report "<tr>"
Add-Content $report "<td bgcolor= 'white' align=center>  <B> No aging snapshots </B></td>" 
Add-Content $report "<td bgcolor= 'white' align=center>  <B> No aging snapshots </B></td>" 
Add-Content $report "<td bgcolor= 'white' align=center>  <B> No aging snapshots </B></td>"

}

else {

foreach ($snap in $Snapshot_list){

$snapevent = Get-VIEvent -Entity $snap.VM -Start $snap.Created.AddMinutes(-1) -Finish $snap.Created.AddMinutes(1) | where {$_.FullFormattedMessage -imatch "Create virtual machine snapshot"}

$Creator = $snapevent.UserName
$VM_Name = $snap.VM
$Created_ON = $snap.Created

Add-Content $report "<tr>"
Add-Content $report "<td bgcolor= 'DarkOrange' align=center>  <B> $VM_Name </B></td>" 
Add-Content $report "<td bgcolor= 'DarkOrange' align=center>  <B> $Creator </B></td>" 
Add-Content $report "<td bgcolor= 'DarkOrange' align=center>  <B> $Created_ON </B></td>" 
}


}

}

Function DS_Check{

$Datastores = Get-Datastore | Where {(($_.Name -notlike "*NTNX*") -and ($_.Name -notlike "*GX_*")) -and ((($_.CapacityGB-$_.FreeSpaceGB)/$_.CapacityGB)*100) -ge "90"} | sort Name

Table_format "Datastores with <10% free space" "Datastore Name" "Free Space Available(GB)" "Free Space (%)"


if ($Datastores.Name -eq $null){

Add-Content $report "<tr>"
Add-Content $report "<td bgcolor= 'white' align=center>  <B> No Datastore with less than 10% free space</B></td>" 
Add-Content $report "<td bgcolor= 'white' align=center>  <B> No Datastore with less than 10% free space</B></td>" 
Add-Content $report "<td bgcolor= 'white' align=center>  <B> No Datastore with less than 10% free space</B></td>"

}

else{

foreach ($DS in $Datastores){

$Datastore_Name = $DS.Name
$FreeSpace = [math]::Round($DS.FreeSpaceGB,2)
$PercentFree = [math]::Round(($DS.FreeSpaceGB/$DS.CapacityGB)*100,2)

Add-Content $report "<tr>"
Add-Content $report "<td bgcolor= 'red' align=center>  <B> $Datastore_Name </B></td>" 
Add-Content $report "<td bgcolor= 'red' align=center>  <B> $FreeSpace </B></td>" 
Add-Content $report "<td bgcolor= 'red' align=center>  <B> $PercentFree </B></td>" 
}

}
}

Function Incorrect_Sockets {

Table_format "VMs with incorrect socket counts" "VM Name" "VM Socket Count" "Host Socket Count"

$vmlist = @()

$HostSockets = Get-VMHost | where {$_.ConnectionState -eq "Connected" } | sort name
foreach ($esxihost in $HostSockets.Name){

$VMsWithIncorrectSocket = Get-VM -Location $esxihost | Where {$_.NumCpu/$_.CoresPerSocket -gt (Get-VMHostHardware -VMHost $esxihost).CpuCount }
if ($VMsWithIncorrectSocket -ne $null){$vmlist += $VMsWithIncorrectSocket}

}


if ($vmlist.Count -eq 0){

Add-Content $report "<tr>"

Add-Content $report "<td bgcolor='white' align='center'> <B> No-Socket-Misconfigurations </B></td>" 
Add-Content $report "<td bgcolor='white' align='center'> <B> No-Socket-Misconfigurations </B></td>" 
Add-Content $report "<td bgcolor='white' align='center'> <B> No-Socket-Misconfigurations </B></td>"

}

else{

foreach ($myvm in $vmlist){

$my_vm_name = $myvm.Name
$CPU_Coskets = $myvm.NumCpu/$myvm.CoresPerSocket
$host_Sockets = (Get-VMHost -VM $myvm | Get-VMHostHardware).CpuCount

Add-Content $report "<tr>"
Add-Content $report "<td bgcolor= 'DarkOrange' align=center>  <B> $my_vm_name </B></td>" 
Add-Content $report "<td bgcolor= 'DarkOrange' align=center>  <B> $CPU_Coskets </B></td>" 
Add-Content $report "<td bgcolor= 'DarkOrange' align=center>  <B> $host_Sockets </B></td>" 

}
}
}

Function HA_DRS_Check{
Table_format "Cluster HA/DRS State Check" "Cluster Name" "HA Status" "DRS Status"

$cluster_list = Get-Cluster | sort name
foreach ($clstr in $cluster_list){
$clstr_name = $clstr.Name
$HA_Status = $clstr.HAEnabled
$DRS_Status = $clstr.DrsEnabled

Add-Content $report "<tr>"
Add-Content $report "<td bgcolor= 'white' align=center>  <B> $clstr_name </B></td>"

if ($HA_Status -eq $false){Add-Content $report "<td bgcolor= 'DarkOrange' align=center>  <B> Disabled </B></td>"}
else {Add-Content $report "<td bgcolor= 'LimeGreen' align=center>  <B> Enabled </B></td>"}

if ($DRS_Status -eq $false){Add-Content $report "<td bgcolor= 'DarkOrange' align=center>  <B> Disabled </B></td>"}
else {Add-Content $report "<td bgcolor= 'LimeGreen' align=center>  <B> Enabled </B></td>"}

}

}

Function Deleted_VMs{

Table_format "VMs Deleted in last 1 day" "Deleted By" "Deleted On" "Description"

$eventnumber = 100
$events = @()
$eventMgr = Get-View EventManager
$eventFilter = New-Object VMware.Vim.EventFilterSpec
$eventFilter.eventTypeId = "VmRemovedEvent"
$eventFilter.time = New-Object VMware.Vim.EventFilterSpecByTime
$eventFilter.Time.BeginTime = (Get-Date).AddDays(-1)
$eventFilter.Time.EndTime = (Get-Date)
$eventCollector = Get-View ($eventMgr.CreateCollectorForEvents($eventFilter))
$eventsBuffer = $eventCollector.ReadNextEvents($eventnumber)
$Entity = @(Get-Folder -NoRecursion)
$Entity | foreach {


while($eventsBuffer){
$events += $eventsBuffer
$eventsBuffer = $eventCollector.ReadNextEvents($eventnumber)
}

}

$filter1 = @()
$filter1 += $events | where {$_.FullFormattedMessage -inotmatch "gx_backup"}

if ($filter1.Length -le 0){

Add-Content $report "<tr>"
Add-Content $report "<td bgcolor= 'white' align=center>  <B> No VM was deleted in last 1 day </B></td>"
Add-Content $report "<td bgcolor= 'white' align=center>  <B> No VM was deleted in last 1 day </B></td>"
Add-Content $report "<td bgcolor= 'white' align=center>  <B> No VM was deleted in last 1 day </B></td>"

}
Else{

foreach ($evnts in $filter1){

$user = $evnts.UserName
$Timeslot = $evnts.CreatedTime
$Description = $evnts.FullFormattedMessage

Add-Content $report "<tr>"
Add-Content $report "<td bgcolor= 'yellow' align=center>  <B> $user </B></td>"
Add-Content $report "<td bgcolor= 'yellow' align=center>  <B> $Timeslot </B></td>"
Add-Content $report "<td bgcolor= 'yellow' align=center>  <B> $Description </B></td>"

}

}

}

Function Created_VMs{

Table_format "VMs Created or Cloned in last 1 day" "Created By" "Created On" "Description"

$eventnumber = 100
$events = @()
$eventMgr = Get-View EventManager
$eventFilter = New-Object VMware.Vim.EventFilterSpec
$eventFilter.eventTypeId = @("VmCreatedEvent", "VmBeingClonedEvent", "VmBeingDeployedEvent")
$eventFilter.time = New-Object VMware.Vim.EventFilterSpecByTime
$eventFilter.Time.BeginTime = (Get-Date).AddDays(-1)
$eventFilter.Time.EndTime = (Get-Date)
$eventCollector = Get-View ($eventMgr.CreateCollectorForEvents($eventFilter))
$eventsBuffer = $eventCollector.ReadNextEvents($eventnumber)
$Entity = @(Get-Folder -NoRecursion)
$Entity | foreach {


while($eventsBuffer){
$events += $eventsBuffer
$eventsBuffer = $eventCollector.ReadNextEvents($eventnumber)
}

}

$filter1 = @()
$filter1 += $events | where {$_.FullFormattedMessage -inotmatch "gx_backup"}

if ($filter1.Length -le 0){

Add-Content $report "<tr>"
Add-Content $report "<td bgcolor= 'white' align=center>  <B> No VM was Created in last 1 day </B></td>"
Add-Content $report "<td bgcolor= 'white' align=center>  <B> No VM was Created in last 1 day </B></td>"
Add-Content $report "<td bgcolor= 'white' align=center>  <B> No VM was Created in last 1 day </B></td>"

}
Else{

foreach ($evnts in $filter1){

$user = $evnts.UserName
$Timeslot = $evnts.CreatedTime
$Description = $evnts.FullFormattedMessage

Add-Content $report "<tr>"
Add-Content $report "<td bgcolor= 'yellow' align=center>  <B> $user </B></td>"
Add-Content $report "<td bgcolor= 'yellow' align=center>  <B> $Timeslot </B></td>"
Add-Content $report "<td bgcolor= 'yellow' align=center>  <B> $Description </B></td>"

}

}

}

Function ESXi_Details{

Table_format "ESXi Host Details" "ESXi Name" "Model,SerialNumber & CPU" "ESXi Version & Build"

$host_detail_list = Get-VMHost | sort name

foreach ($ESX in $host_detail_list){

$VMhost_name = $ESX.Name
$Make = ($ESX | Get-VMHostHardware).Manufacturer
$Model = ($ESX | Get-VMHostHardware).Model
$Serial = ($ESX | Get-VMHostHardware).SerialNumber
$CPU = ($ESX | Get-VMHostHardware).CpuModel

$esx_version = $ESX.Version
$esx_build = $ESX.Build

Add-Content $report "<tr>"
Add-Content $report "<td bgcolor= 'white' align=center>  <B> $VMhost_name </B></td>" 
Add-Content $report "<td bgcolor= 'white' align=center>  <B> Vendor=$Make, Model=$Model,S.No=$Serial, CPU=$CPU </B></td>" 
Add-Content $report "<td bgcolor= 'white' align=center>  <B> $esx_version $esx_build </B></td>" 

}

}

Function connect_vcenter{

Connect-VIServer $vcenter -Credential $Cred

}

function Mail_Send{
Param([Parameter (mandatory = $True)]$Exported_Body)
$smtp = "smtp.damen.com"
$from = "$vcenter@damen.com"
$emailTo = "TCS.DAMEN.Virtualization.Platform.Team@damen.com"
$smtpserver = New-Object System.Net.Mail.SmtpClient $smtp
$message = New-Object  System.Net.Mail.MailMessage 
$message.To.Add($emailTo)
$message.CC.Add("deepak.kumar@damen.com,Marc.Tulleners@damen.com")
$message.From = $from
$message.Subject = "vCenter $vcenter Daily Health Check"
$message.Body = $Exported_Body
$message.IsBodyHtml = $True
$smtpserver.Send($message)
}


Remove-Item "$PSScriptRoot\clusterReport.htm" -Force -ErrorAction SilentlyContinue

$report = New-Item "$PSScriptRoot\clusterReport.htm" -ItemType File

Add-Content $report " Hi Team,  "

Add-content $report "<br >"
Add-content $report "<br >"

Add-content $report " Please find below the vCenter $vcenter health check report and take action on reported items:"
Add-content $report "<br >"
Add-content $report "<br >"

Add-Content $report "<html>" 
Add-Content $report "<head>" 
Add-Content $report "<meta http-equiv='Content-Type' content='text/html; charset=iso-8859-1'>" 
Add-Content $report "</tr>" 

connect_vcenter

check_alerts
ESXi_State_Check
check_snapshot_aging
DS_Check
Incorrect_Sockets
Deleted_VMs
Created_VMs
HA_DRS_Check
ESXi_Details

$body = Get-Content "$PSScriptRoot\clusterReport.htm"

Mail_Send $body
