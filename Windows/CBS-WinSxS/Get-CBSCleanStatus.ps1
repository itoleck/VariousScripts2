#Script to test if a CBS store cleanup is neccessary

#Check Administrator access.
#Requires -RunAsAdministrator

Start-Process -Wait "Dism.exe" -ArgumentList "/Online /Cleanup-Image /AnalyzeComponentStore" -RedirectStandardOutput c:\temp\cbs_clean.txt
$a=Get-Content c:\temp\cbs_clean.txt -Raw
if (!$a.contains("Component Store Cleanup Recommended : No"))
{
    Write-EventLog -LogName System -Source "CBS" -EntryType Warning -EventId 1337 -Message $a
}
type c:\temp\cbs_clean.txt