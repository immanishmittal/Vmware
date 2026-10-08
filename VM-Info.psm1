function VM-info {
Param ([parameter()]$VM_Name)
Get-VM -Name $VM_Name | select name,numcpu,memorygb}
