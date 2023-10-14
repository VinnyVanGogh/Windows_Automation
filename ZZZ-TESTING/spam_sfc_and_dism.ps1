$retryCount = 3
$retryDelay = 3  # in seconds
$errorLogFile = "C:\RepairErrors.txt"

$retryAttempts = 0
$retrySuccess = $false

while (-not $retrySuccess -and $retryAttempts -lt $retryCount) {
    Write-Host "Running System File Checker (SFC)..."
    Write-Progress -Activity "System File Checker (SFC)" -Status "Scanning..." -PercentComplete 0 -CurrentOperation "Progress:"

    $sfcOutput = sfc /scannow | Out-String
    $sfcCompleted = $sfcOutput -match 'Verification (\w+): (\d+)%'
    if ($sfcCompleted) {
        $sfcProgress = $Matches[1]
        $sfcPercent = [int]$Matches[2]
        Write-Progress -Activity "System File Checker (SFC)" -Status "$sfcProgress" -PercentComplete $sfcPercent -Completed -ForegroundColor Green
    }

    Write-Host "Running DISM (Deployment Image Servicing and Management) CheckHealth..."
    Write-Progress -Activity "DISM CheckHealth" -Status "Scanning..." -PercentComplete 0 -CurrentOperation "Progress:"

    $dismOutput = DISM.exe /Online /Cleanup-Image /CheckHealth | Out-String
    $dismCompleted = $dismOutput -match 'The component store is repairable.'
    if ($dismCompleted) {
        Write-Progress -Activity "DISM CheckHealth" -Status "Completed" -PercentComplete 100 -Completed -ForegroundColor Green
    }

    Write-Host "Running DISM ScanHealth..."
    Write-Progress -Activity "DISM ScanHealth" -Status "Scanning..." -PercentComplete 0 -CurrentOperation "Progress:"

    $dismOutput = DISM.exe /Online /Cleanup-Image /ScanHealth | Out-String
    $dismCompleted = $dismOutput -match 'The component store is repairable.'
    if ($dismCompleted) {
        Write-Progress -Activity "DISM ScanHealth" -Status "Completed" -PercentComplete 100 -Completed -ForegroundColor Green
    }

    if ($sfcOutput -notmatch 'found no integrity violations' -or $dismOutput -notmatch 'The component store is repairable') {
        Write-Host "Running DISM RestoreHealth..."
        Write-Progress -Activity "DISM RestoreHealth" -Status "Scanning..." -PercentComplete 0 -CurrentOperation "Progress:"
        DISM.exe /Online /Cleanup-Image /RestoreHealth | Out-File -Append -FilePath $errorLogFile
    }
    else {
        $sfcOutput2 = sfc /verifyonly
        $dismOutput2 = DISM.exe /Online /Cleanup-Image /ScanHealth

        if ($sfcOutput2 -notmatch 'found no integrity violations' -or $dismOutput2 -notmatch 'The component store is repairable') {
            $retryAttempts++
            Write-Host "Some issues were detected. Retrying in $retryDelay seconds..." -ForegroundColor Yellow
            Start-Sleep -Seconds $retryDelay
        }
        else {
            $retrySuccess = $true
            Write-Host "All checks passed successfully." -ForegroundColor Green
        }
    }
}

if (-not $retrySuccess) {
    Write-Host "Some issues were detected after multiple attempts. Further investigation may be required. Try C:\RepairErrors.txt"
    Write-Host "You can try dism /Online /Cleanup-Image /StartComponentCleanup"
    Write-Host "You can also do an in-place reset by running dism /Online /Cleanup-Image /RestoreHealth /Source:WIM:X:\Sources\Install.wim:1 /LimitAccess"
    Write-Host "Remember to replace X:\Sources\Install.wim in the Component Store reset command with the appropriate path to your Windows installation media." -ForegroundColor Red
    Write-Host "You can find that here: https://www.microsoft.com/software-download/windows11" -ForegroundColor Green
}
