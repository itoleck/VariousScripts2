cls

##############################################
#This must be run once on the machine and saved to a file
#Enter the domain\user and password in the security window
#The password is hashed with the current machine key and cannot be read by another machine withour the machine key
$MyCredential = Get-Credential
$MyCredential | Export-Clixml .\MyCredential.xml
##############################################


Add-Type -AssemblyName System.DirectoryServices.AccountManagement
#Loop 100 connections to the DC

$MyCredential = Import-Clixml .\MyCredential.xml
$Count = 100
$TotalTicks = 0

$stopwatch = [system.diagnostics.stopwatch]::StartNew()
for($i=1; $i -le $Count; $i++) {
Try
{
    $PC = New-Object -TypeName System.DirectoryServices.AccountManagement.PrincipalContext(1, ($MyCredential.GetNetworkCredential()).Domain)
    if ($PC.ValidateCredentials((($MyCredential.GetNetworkCredential()).UserName),($MyCredential.GetNetworkCredential().Password))) {
        Write-Output "Validation success"
    } else {
        Write-Output "Validation failed"
    }
    $PC.Dispose()
}
Catch
{
    $ErrorMsg = $_.Exception.Message
    Write-Warning "Failed to validate credentials: $ErrorMsg "
    Pause
    Break
}
$stopwatch
$TotalTicks = $TotalTicks + $stopwatch.ElapsedTicks
$stopwatch.Restart()
}
$Avgticks = $TotalTicks / $Count
$AvgMs = $Avgticks / 10000
Write-Output ("Average Domain connection time in Milliseconds: {0}" -f $AvgMs)


#Loop 100 connections to the QSL server DB
$SQLSvr = "SQLServer"
$DB = "database"
$Count = 100
$TotalTicks = 0
$stopwatch = [system.diagnostics.stopwatch]::StartNew()
for($i=1; $i -le $Count; $i++) {
$connectionString = 'Data Source={0};database={1};Integrated Security=True;' -f $SQLSvr,$DB
$sqlConnection = New-Object System.Data.SqlClient.SqlConnection $connectionString
$sqlConnection.Open()
$stopwatch
$TotalTicks = $TotalTicks + $stopwatch.ElapsedTicks
$stopwatch.Restart()
}
$Avgticks = $TotalTicks / $Count
$AvgMs = $Avgticks / 10000
Write-Output ("Average SQL connection time in Milliseconds: {0}" -f $AvgMs)