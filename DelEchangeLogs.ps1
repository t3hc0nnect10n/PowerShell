# Set execution policy if not set
$ExecutionPolicy = Get-ExecutionPolicy
if ($ExecutionPolicy -ne "RemoteSigned") {
    Set-ExecutionPolicy RemoteSigned -Force
}

# Cleanup logs older than the set of days in numbers
$days = 3

# Path of the logs that you like to cleanup
$IISLogPath = "C:\inetpub\logs\LogFiles\"
$ExchangeLoggingPath = "C:\Program Files\Microsoft\Exchange Server\V15\Logging\"
$ETLLoggingPath = "C:\Program Files\Microsoft\Exchange Server\V15\Bin\Search\Ceres\Diagnostics\ETLTraces\"
$ETLLoggingPath2 = "C:\Program Files\Microsoft\Exchange Server\V15\Bin\Search\Ceres\Diagnostics\Logs\"

# Clean the logs
Function CleanLogfiles($TargetFolder) {
    Write-Host -Debug -ForegroundColor Yellow -BackgroundColor Cyan $TargetFolder

    if (Test-Path $TargetFolder) {
        $Now = Get-Date
        $LastWrite = $Now.AddDays(-$days)
        $Files = Get-ChildItem $TargetFolder -Recurse | Where-Object { $_.Name -like "*.log" -or $_.Name -like "*.blg" -or $_.Name -like "*.etl" } | Where-Object { $_.lastWriteTime -le "$lastwrite" } | Select-Object FullName  
        foreach ($File in $Files) {
            $FullFileName = $File.FullName  
            Write-Host "Deleting file $FullFileName" -ForegroundColor "yellow"; 
            Remove-Item $FullFileName -ErrorAction SilentlyContinue | out-null
        }
    }
    Else {
        Write-Host "The folder $TargetFolder doesn't exist! Check the folder path!" -ForegroundColor "red"
    }
}
CleanLogfiles($IISLogPath)
CleanLogfiles($ExchangeLoggingPath)
CleanLogfiles($ETLLoggingPath)
CleanLogfiles($ETLLoggingPath2)