# IE 10/11 scrollbar color change script
# Chad Schultz - chad.a@microsoft.com Microsoft PFE
# This script will read the current theme color and apply the IE scrollbar to the same color for a user.
# To revert the settings back to default go to IE->Internet Options->General->Accessibility->Format documents using my style sheet and uncheck the setting.

$dwm=Get-ItemProperty "hkcu:\software\microsoft\windows\dwm\"
$scol="#" + [convert]::ToString($dwm.ColorizationColor, 16).Substring(2)
$tcss="html{scrollbar-base-color:" + $scol + ";}"
$p=$env:APPDATA.ToString() + "\scrollbar.css"
out-file -InputObject $tcss -FilePath $p -Force
Set-ItemProperty -path "hkcu:\Software\Microsoft\Internet Explorer\Styles" -name "User Stylesheet" -Value $p
Set-ItemProperty -path "hkcu:\Software\Microsoft\Internet Explorer\Styles" -name "Use My Stylesheet" -Value 1
