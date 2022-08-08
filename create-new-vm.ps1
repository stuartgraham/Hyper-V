$PSNativeCommandUseErrorActionPreference = $true
$ErrorActionPreference = 'Stop'

$refVM = "docker1" 
$oldVM = Get-VM $refVM
$switch = (Get-VMNetworkAdapter -VMName $refVM).SwitchName
$firmware = Get-VMFirmware $refVM
$newVM = Read-Host "Enter new hostname"

Write-Host "Shutting down template machine"
Stop-VM ubuntu-2004-template 

Write-Host "Copying VHDX"
$Source = "V:\VM\Virtual Hard Disks\ubuntu-template.vhdx"
$Destination = "V:\VM\Virtual Hard Disks\$newVM.vhdx"
cmd /c copy /z $Source $Destination

Write-Host "Creating new VM"
New-VM -Name $newVM `
-MemoryStartupBytes 512MB `
-Generation 2 `
-VHDPath $Destination `
-SwitchName $switch

Set-VMFireware $newVM -SecureBootTemplate $firmware.SecureBootTemplate
Write-Host "Starting new VM"
Start-VM $newVM
Write-Host "Starting template VM"
Start-VM ubuntu-2004-template
