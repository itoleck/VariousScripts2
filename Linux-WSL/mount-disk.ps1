#Mount disk in wsl
# This script lists all physical disks and prompts the user to select one to mount in WSL.
# It requires administrative privileges to run.
#From https://learn.microsoft.com/en-us/windows/wsl/wsl2-mount-disk

#Requires -RunAsAdministrator

Class PhysicalDisk
{
    [String]$DiskNumber
    [String]$DeviceID
    [String]$Model
    [String]$Size
}

$disks=Get-CimInstance -Query "SELECT * from Win32_DiskDrive"

$myDisks = New-Object System.Collections.ArrayList
$index=0
foreach ($disk in $disks)
    {
        $myDisk=New-Object PhysicalDisk
        $myDisk.DiskNumber=$index
        $myDisk.DeviceID=$disk.DeviceID
        $myDisk.Model=$disk.Model
        $myDisk.Size=[math]::round($disk.Size/1GB,2)
        $myDisks.Add($myDisk)
        $index++
    }

$myDisks|Format-Table -AutoSize

# Prompt the user for a number
$dnum = Read-Host "Please enter DiskNumber to mount (e.g. 0, 1, 2)"

# Validate if the input is a number
if ([int]::TryParse($dnum, [ref]$null)) {
    Write-Host "You entered a valid number: $dnum"
} else {
    Write-Host "Invalid input. Please enter a numeric value."
}

wsl --mount $myDisks[($dnum)].DeviceID --bare

Write-Host "Disk $dnum mounted in WSL. You can now access it from your WSL distribution." -ForegroundColor Cyan
Write-Host "To unmount the disk, use the command: wsl --unmount <DiskPath>" -ForegroundColor Cyan
Write-Host "In Linux, you can find the disk under /dev/sdX (replace X with the appropriate letter)." -ForegroundColor Cyan
Write-Host "Find the disk using: lsblk or fdisk -l" -ForegroundColor Cyan
Write-Host "Mount it using: sudo mount /dev/sdX1 /mnt (replace X with the appropriate letter and 1 with the partition number)" -ForegroundColor Cyan
