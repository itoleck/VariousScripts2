#Enable 3 full memory dumps on Outlook.exe process crash

$path="HKLM:\SOFTWARE\Microsoft\Windows\Windows Error Reporting\LocalDumps"
md $path
md "$path\OUTLOOK.EXE"
New-ItemProperty -Path "$path" -Name "Disabled" -Value "0" -PropertyType DWORD -Force | Out-Null
New-ItemProperty -Path "$path\OUTLOOK.EXE" -Name "DumpCount" -Value "3" -PropertyType DWORD -Force | Out-Null
New-ItemProperty -Path "$path\OUTLOOK.EXE" -Name "DumpType" -Value "2" -PropertyType DWORD -Force | Out-Null
