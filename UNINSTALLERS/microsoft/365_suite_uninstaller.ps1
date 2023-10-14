$odtUrl = "https://download.microsoft.com/download/2/7/A/27AF1BE6-DD20-4CB4-B154-EBAB8A7D4A7E/officedeploymenttool_16501-20196.exe"
$odtExe = "$env:TEMP\officedeploymenttool_16501-20196.exe"
$extractPath = "$env:TEMP\ODTSetupFiles"
$installXml = "$env:TEMP\ODTSetupFiles\configuration.xml"

$sevenZipPath = "C:\Program Files\7-Zip\7z.exe"

# Check if 7-Zip is installed
if (-not (Test-Path $sevenZipPath)) {
    Write-Host "7-Zip is not installed. Installing 7-Zip..."

    # Download the 7-Zip installer
    $sevenZipInstallerUrl = "https://www.7-zip.org/a/7z1900-x64.exe"
    $sevenZipInstallerPath = "$env:TEMP\7zinstaller.exe"
    Invoke-WebRequest -Uri $sevenZipInstallerUrl -OutFile $sevenZipInstallerPath

    # Run the 7-Zip installer silently
    Start-Process -FilePath $sevenZipInstallerPath -ArgumentList "/S" -Wait

    # Check if 7-Zip installation was successful
    if (-not (Test-Path $sevenZipPath)) {
        Write-Host "7-Zip installation failed. Aborting."
        return
    }
}

# Download the Office Deployment Tool
Invoke-WebRequest -Uri $odtUrl -OutFile $odtExe

# Extract the ODT setup files to the specified location
& $sevenZipPath x -y -o"$extractPath" $odtExe

Write-Host "Office Deployment Tool setup files have been extracted to: $extractPath" -ForegroundColor Black -BackgroundColor Green

# Create an XML configuration file for installation
@"
<Configuration>
  <Remove>
    <Product ID="AccessProRetail" />
    <Product ID="ExcelRetail" />
    <Product ID="OneNoteRetail" />
    <Product ID="OutlookRetail" />
    <Product ID="PowerPointRetail" />
    <Product ID="ProjectProRetail" />
    <Product ID="VisioProRetail" />
    <Product ID="WordRetail" />
  </Remove>
</Configuration>
"@ | Out-File -FilePath $installXml -Encoding UTF8 -Force

# Run the Office Deployment Tool for installation
Start-Process -FilePath "$extractPath\setup.exe" -ArgumentList "/configure", $installXml -Wait -NoNewWindow

# Re-register the Microsoft Store
try {
    Get-AppXPackage *WindowsStore* -AllUsers | Foreach {Add-AppxPackage -DisableDevelopmentMode -Register "$($_.InstallLocation)\AppXManifest.xml"}
    Write-Host "Microsoft Store has been reset successfully." -ForegroundColor Black -BackgroundColor Green
} catch {
    Write-Host "Failed to reset the Microsoft Store: $_" -ForegroundColor Black -BackgroundColor Red
}
