$csdrive = ""
$attacheddrive = ""
$vols=Get-Volume
foreach($vol in $vols) {
    write-host $vol.DriveLetter
    if ($vol.DriveLetter -eq 'c') {} else {
        $attacheddrive = $vol.DriveLetter
    }
    $path = "$attacheddrive" + ":\Video\"
    $ispath = Test-Path -Path $path
    if ($ispath) {
        $csdrive = $vol.DriveLetter
    }
}
$csdrive