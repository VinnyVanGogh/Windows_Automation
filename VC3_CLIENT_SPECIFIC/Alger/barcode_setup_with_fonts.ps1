# Barcode
Start-Process -FilePath "H:\Vet\BARCODE\Setup.exe" -Wait

# Step 2: Copy fonts from source to destination
$sourceFontsPath = "H:\Vet\Master & Inventory Labels Instructions"
$destinationFontsPath = "C:\BARCODE"
robocopy $sourceFontsPath $destinationFontsPath /E /R:1 /W:1

# Step 3: Copy WBCXC.OCX to multiple locations using robocopy
$wbcxcOcxPath = "H:\Vet\Barcode"
$destinationPaths = @("C:\VETUSER", "C:\Windows\System32", "C:\Windows\Syswow64")
foreach ($path in $destinationPaths) {
    robocopy $wbcxcOcxPath $path "WBCXC.OCX" /R:1 /W:1
}

# Step 4: Register WBCXC.OCX
$ocxFilePath = Join-Path -Path $destinationPaths[0] -ChildPath "WBCXC.OCX"
$ocxFilePath = [System.IO.Path]::Combine($ocxFilePath, "WBCXC.OCX")
foreach ($path in $destinationPaths) {
    Set-Location -Path $path
    Start-Process -FilePath "regsvr32.exe" -ArgumentList "/s $ocxFilePath" -Wait
}

Write-Host "Script execution completed."