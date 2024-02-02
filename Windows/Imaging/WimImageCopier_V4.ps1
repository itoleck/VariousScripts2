# Wim Image Copy Script
# Chad Schultz - chad.a@microsoft.com Microsoft PFE - 2017
# Will prepare and active partition and extract and copy .wim image to 1 or more attached USB drives. Any current data on attached USB drives will be lost.

$global:WimFilePath = $env:HOMEDRIVE
[System.Reflection.Assembly]::LoadWithPartialName("System.windows.forms")|Out-Null

#Logging
Function LogMsg([string]$msg,[string]$logtype="info") {
    $fcolor="green";$bcolor="black"
    if($logtype -eq "important"){$fcolor="blue";$bcolor="black"}
    if($logtype -eq "warning"){$fcolor="yellow";$bcolor="black"}
    if($logtype -eq "error"){$fcolor="red";$bcolor="white"}
    Write-Host $msg -ForegroundColor $fcolor -BackgroundColor $bcolor
}

Function Quit() {
    Exit
}

#Prompt for the WIM Image File
#From http://blogs.technet.com/b/heyscriptingguy/archive/2009/09/01/hey-scripting-guy-september-1.aspx
Function Get-FileName($initialDirectory)
{   
    $OpenFileDialog = New-Object System.Windows.Forms.OpenFileDialog
    $OpenFileDialog.initialDirectory = $initialDirectory
    $OpenFileDialog.filter = "Windows Image files (*.wim)| *.wim"
    $OpenFileDialog.ShowDialog()|Out-Null
    $OpenFileDialog.filename
} #end function Get-FileName

Function SetWIMImagePath()
{
    #Select the .wim image file
    LogMsg "Select an image file(ie. c:\temp\install.wim)."
    $global:WimFilePath = Get-FileName -initialDirectory $global:WimFilePath
    If($global:WimFilePath.Length -lt 7){LogMsg "No Windows Image selected, exiting script." "error";Quit}
    LogMsg "Setting WIM file to $global:WimFilePath" "important"
}

Function CreatePartitions($Disk)
{
    #Modified from http://social.technet.microsoft.com/wiki/contents/articles/6991.windows-to-go-step-by-step.aspx

    Clear-Disk –InputObject $Disk -RemoveData -confirm:$false
    Start-sleep -Seconds 2
    Initialize-Disk –InputObject $Disk -PartitionStyle MBR -confirm:$false
    Start-sleep -Seconds 2
    $SystemPartition = New-Partition –InputObject $Disk -Size (350MB) -IsActive
    Start-sleep -Seconds 2
    Format-Volume -NewFileSystemLabel "System" -FileSystem FAT32 -Partition $SystemPartition -confirm:$false
    Start-sleep -Seconds 2
    $OSPartition = New-Partition –InputObject $Disk -UseMaximumSize
    Start-sleep -Seconds 2
    Format-Volume -NewFileSystemLabel "Windows" -FileSystem NTFS -Partition $OSPartition -confirm:$false
    Start-sleep -Seconds 2
    Set-Partition -InputObject $SystemPartition -NewDriveLetter "S"
    Set-Partition -InputObject $OSPartition -NewDriveLetter "W"
    Set-Partition -InputObject $SystemPartition -NoDefaultDriveLetter $TRUE
}

Function ImageDisks($usbdisk)
{
    foreach ($usbdisk in $usbdisks) {
        $part = Get-Partition -DiskNumber $usbdisk.Number|?{$_.IsActive -eq $false}
        $dismargs = "/Apply-Image `"/ImageFile:" + $global:WimFilePath + "`" /Index:1 /ApplyDir:" + $part.DriveLetter + ":\"
        Start-Process -FilePath "DISM.exe" -ArgumentList $dismargs -wait
        $logimg = "Copying image using command : dism.exe " + $dismargs
        LogMsg $logimg
    }
}

Function CopyBootFiles($usbdisk)
{
    foreach ($usbdisk in $usbdisks) {
        $bootpart = Get-Partition -DiskNumber $usbdisk.Number|?{$_.IsActive -eq $true}
        $winpart = Get-Partition -DiskNumber $usbdisk.Number|?{$_.IsActive -eq $false}
        $bcdbootargs = $winpart.DriveLetter + ":\windows /f All /s " + $bootpart.DriveLetter + ":"
        Start-Process -FilePath "bcdboot" -ArgumentList $bcdbootargs -wait
        $logimg = "Copying boot files using command : bcdboot.exe " + $bcdbootargs
        LogMsg $logimg
    }
}

#Main
LogMsg "This script will prepare(FDISK and format) and copy a Windows Image(install.wim) to all USB drives attached to this computer."
LogMsg "Remove any USB drives that should not be formatted and loaded with an image as they will be overwritten."

SetWIMImagePath

#Enumerate all USB disks attached
$usbdisks=get-disk|?{$_.Path -match "USBSTOR" -and $_.BusType -eq "USB" -and $_.Size -gt 28Gb -and -not $_.IsBoot}

If($usbdisks)
{
    LogMsg "Are you sure you want to format and install Windows To Go on the following USB drives?" "warning"

    foreach ($usbdisk in $usbdisks) {
        Write-Host $usbdisk.FriendlyName
    }

    $a = new-object -comobject wscript.shell 
    $intAnswer = $a.popup("Install Windows ToGo?",0,"Install",4) 
    If ($intAnswer -eq 6) {
        foreach ($usbdisk in $usbdisks) {
            
            #Clean, partition and format disk
            CreatePartitions $usbdisk
            
            #Copy image using DISM.exe
            ImageDisks $usbdisk

            #Copy the boot files for BIOS and UEFI
            CopyBootFiles $usbdisk

            #Clean up the S: and W: drive letters
            $drive = Get-WmiObject -Class Win32_volume -Filter "DriveLetter='W:'"
            Set-WmiInstance -input $drive -Arguments @{DriveLetter=$null}|Out-Null

            $drive = Get-WmiObject -Class Win32_volume -Filter "DriveLetter='S:'"
            Set-WmiInstance -input $drive -Arguments @{DriveLetter=$null}|Out-Null
        }

    } else {
        Quit
    }
}
else
{
   LogMsg "No USB drives detected, exiting." "error"
   Quit
}