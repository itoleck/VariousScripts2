Param (
    [string]$sAMAccount = "account",
    [string]$SQLSvr = "SQL Server",
    [string]$SQLDB = "Database",
    [int]$Count = 100
)

#Loop connections to the DC netlogon share
$TotalTicks = 0
$stopwatch = [system.diagnostics.stopwatch]::StartNew()

for($i=1; $i -le $Count; $i++) {
    Try
    {
        $adsiSearcher = New-Object DirectoryServices.DirectorySearcher
        #$adsiSearcher.Filter = “(&(ObjectCategory=User)(Name=First Last))”
        $adsiSearcher.Filter = “(sAMAccountName=$sAMAccount)”
        $adsiSearcher.FindAll() | Select path
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
    $adsiSearcher.Dispose()
    $stopwatch.Restart()
}
$Avgticks = $TotalTicks / $Count
$AvgMs = $Avgticks / 10000
Write-Output ("Average Domain share connection time in Milliseconds: {0}" -f $AvgMs)


#Loop connections to the SQL server DB
$TotalTicks = 0
$stopwatch = [system.diagnostics.stopwatch]::StartNew()
for($i=1; $i -le $Count; $i++) {
    $connectionString = 'Data Source={0};database={1};Integrated Security=True;' -f $SQLSvr,$SQLDB
    $sqlConnection = New-Object System.Data.SqlClient.SqlConnection $connectionString
    $sqlConnection.Open()
    $stopwatch
    $TotalTicks = $TotalTicks + $stopwatch.ElapsedTicks
    $stopwatch.Restart()
    $sqlConnection.Close()
}
$Avgticks = $TotalTicks / $Count
$AvgMs = $Avgticks / 10000
Write-Output ("Average SQL connection time in Milliseconds: {0}" -f $AvgMs)