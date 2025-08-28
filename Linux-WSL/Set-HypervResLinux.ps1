# Set Hyper-V Enhanced Session Mode for Linux VM
# This script configures a Hyper-V virtual machine to use Enhanced Session Mode with specified resolution settings
##requires -RunAsAdministrator


param (
    [string]$vmname
)

if (-not $vmname) {
    $vmname = Read-Host "Enter the name of the Hyper-V VM. VM must be off."
}

set-vmvideo -vmname $vmname -horizontalresolution:1440  -verticalresolution:900 -resolutiontype single
set-vm $vmname -EnhancedSessionTransportType HVSocket
