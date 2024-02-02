# Contributors:
# Chad Schultz
#
# PowerShell module to List and modify crash dump configurations.

#Set-StrictMode 1
#$DebugPreference = "SilentlyContinue"

function getctrlscrollusb {
    Set-Location $crtlscrollusb
    Return Get-Item -Path .\Parameters
}

function getctrlscrollps2 {
    Set-Location $ctrlscrollps2
    Return Get-Item -Path .\Parameters
}

function getcrashdumpconfig {
    Set-Location $CrashControlPath
    Return Get-Item -Path.\CrashControl
}

function getwerlocaldumpsconfig {
    Set-Location $WERPath
    Get-Item -Path .\LocalDumps

    Set-Location $WERPath"\LocalDumps"
    Get-ChildItem
}

function getaedebugconfig {
    Set-Location $AEDebugPath
    Get-Item -Path .\AEDebug

    Set-Location $AEDebugPath"\AEDebug"
    Get-ChildItem
}

function getaedebugwow6432config {
    Set-Location $AEDebugWOW6432Path
    Get-Item -Path .\AEDebug

    Set-Location $AEDebugWOW6432Path"\AEDebug"
    Get-ChildItem
}

function getmemorydmp {

    $dumpfile = $crash.GetValue("DumpFile")

    Write-Debug "Getting full memory dump path from registry path"
    try {
        if(Test-Path -Path $crash.GetValue("DumpFile"))
            {
                Write-Debug "DumpFile value found"
                $dumpfile = $crash.GetValue('DumpFile')
            }
        else
            {
                Write-Debug "Getting full dump path from default path"
                 if(Test-Path -Path "$env:SystemRoot\memory.dmp")
                    {
                        $dumpfile = "$env:SystemRoot\memory.dmp"
                    }
            }

        }
    catch
        {
            Write-Debug "Getting full dump path from default path"
            if(Test-Path -Path "$env:SystemRoot\memory.dmp")
                {
                    $dumpfile = "$env:SystemRoot\memory.dmp"
                }
        }
    Return $dumpfile
}

function getminidumps {
    $minidumps = $crash.GetValue("MinidumpDir")

    Write-Debug "Getting mini memory dump path from registry path"
    try {
        if(Test-Path -Path $crash.GetValue("MinidumpDir"))
            {
                Write-Debug "DumpFile value found"
                $minidumps = $crash.GetValue('MinidumpDir')
            }
        else
            {
                Write-Debug "Getting mini dump path from default path"
                if(Test-Path -Path "$env:SystemRoot\Minidump")
                    {
                        $minidumps = "$env:SystemRoot\Minidump"
                    }
            }
        }
    catch {
        Write-Debug "Getting mini dump path from default path"
        if(Test-Path -Path "$env:SystemRoot\Minidump")
            {
                $minidumps = "$env:SystemRoot\Minidump"
            }
    }
    Return $minidumps
}

function geteventlogcrashes {
    try {
        $bugchecks=Get-WinEvent -ErrorAction SilentlyContinue -LogName System -FilterXPath "*[System[Provider[@EventSourceName='BugCheck']]]"|Out-Null
    } catch {Write-Host -ForegroundColor DarkRed "Error getting events from Event Log"}
    if($bugchecks.length -lt 1){$bugchecks = "None"}
    Return $bugchecks
}

function Get-IFEO {
    try {
        Set-Location $IFEO
        Get-ChildItem

        Set-Location $IFEOWOW
        Get-ChildItem
    }
    catch {
        Write-Host -ForegroundColor DarkRed "Error getting Image File Execution Options registry keys"
    }
}

function Get-CrashDumpSettings {
    getwerlocaldumpsconfig
    getaedebugconfig
    getaedebugwow6432config
    getctrlscrollusb
    getctrlscrollps2
    Get-IFEO

    Write-Host -ForegroundColor Blue "`n`nCrash dump files:"
    $fulldumppath = getmemorydmp
    $minidumppath = getminidumps
    Write-Host "`nMemory crash dump found:"
    if(Test-Path $fulldumppath){Get-ChildItem $fulldumppath}else{Write-Host "None"}
    Write-Host "`nMini memory crash dumps found:"
    if(Test-Path $minidumppath){Get-ChildItem $minidumppath}else{Write-Host "None"}
}

# Start Script
$location = Get-Location

Write-Host -ForegroundColor Blue "Crash dump registry settings:"
$crtlscrollusb = "HKLM:\SYSTEM\CurrentControlSet\Services\kbdhid"
$ctrlscrollps2 = "HKLM:\SYSTEM\CurrentControlSet\Services\i8042prt"
$CrashControlPath = "HKLM:\SYSTEM\CurrentControlSet\Control"
$WERPath = "HKLM:\SOFTWARE\Microsoft\Windows\Windows Error Reporting"
$AEDebugPath = "HKLM:\Software\Microsoft\Windows NT\CurrentVersion"
$AEDebugWOW6432Path = "HKLM:\Software\Wow6432Node\Microsoft\Windows NT\CurrentVersion"
$IFEO = "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Image File Execution Options"
$IFEOWOW = "HKLM:\SOFTWARE\WOW6432Node\Microsoft\Windows NT\CurrentVersion\Image File Execution Options"
$crash = getcrashdumpconfig
$crash
Write-Host -ForegroundColor Green "* CrashDumpEnabled - (0) None, (1) Complete/Active, (2) Kernel, (3) Small, (7) Automatic"
Write-Host -ForegroundColor Green "* FilterPages 1 if active dump, does not exist if another dump type."
Get-CrashDumpSettings
Write-Host -ForegroundColor Blue "`n`nBugCheck log events:"
geteventlogcrashes

Set-Location $location