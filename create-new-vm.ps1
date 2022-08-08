$PSNativeCommandUseErrorActionPreference = $true
$ErrorActionPreference = 'Stop'

$templateVM = "ubuntu-2004-template"
$refVM = Get-VM $templateVM
$switch = (Get-VMNetworkAdapter -VMName $refVM.name).SwitchName
Write-Host $switch
$firmware = Get-VMFirmware $refVM.name
$newVM = Read-Host "Enter new hostname"

Write-Host "Shutting down template machine"
Stop-VM $templateVM 

Write-Host "Copying VHDX"
$Source = "V:\VM\Virtual Hard Disks\ubuntu-template.vhdx"
$Destination = "V:\VM\Virtual Hard Disks\$newVM.vhdx"
cmd /c copy /z $Source $Destination

Write-Host "Creating new VM"
$build = New-VM -Name $newVM `
-MemoryStartupBytes 512MB `
-Generation 2 `
-VHDPath $Destination `
-SwitchName $switch

Set-VMFirmware $newVM -SecureBootTemplate $firmware.SecureBootTemplate
Write-Host "Starting new VM"
Start-VM $newVM
Write-Host "Starting template VM"
Start-VM $templateVM
