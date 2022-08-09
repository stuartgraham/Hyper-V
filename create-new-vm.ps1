# Error handling 
$PSNativeCommandUseErrorActionPreference = $true
$ErrorActionPreference = 'Stop'

# Multi choice prompt
Write-Host "Select template type"
Write-Host "[1] Ubuntu 20.04 LTS [2] Ubuntu 22.04 LTS"
$templateVM = Read-Host -Prompt "Choice"
Switch ($templateVM)
{
    default {"ubuntu-2004-template"}
    1 {"ubuntu-2004-template"}
    2 {"ubuntu-2204-template"}
}

# Build varables
$refVM = Get-VM $templateVM
$switch = (Get-VMNetworkAdapter -VMName $refVM.name).SwitchName
$firmware = Get-VMFirmware $refVM.name

# New machine name
$newVM = Read-Host "New VM name"

# Shutdown template for copying
Write-Host "Shutting down template machine"
Stop-VM $templateVM 

# copy VHDX
Write-Host "Copying VHDX"
$Source = "V:\VM\Virtual Hard Disks\ubuntu-template.vhdx"
$Destination = "V:\VM\Virtual Hard Disks\$newVM.vhdx"
cmd /c copy /z $Source $Destination

# Create new VM
Write-Host "Creating new VM"
$build = New-VM -Name $newVM `
-MemoryStartupBytes 1024MB `
-Generation 2 `
-VHDPath $Destination `
-SwitchName $switch

# Fix secureboot for gen 2 linux manchines
Set-VMFirmware $newVM -SecureBootTemplate $firmware.SecureBootTemplate

# Startups
Write-Host "Starting new VM"
Start-VM $newVM
Write-Host "Starting template VM"
Start-VM $templateVM