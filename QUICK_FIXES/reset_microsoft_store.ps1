# Re-register the Microsoft Store
function Reset-MicrosoftStore {
    try {
        Get-AppXPackage *WindowsStore* -AllUsers | ForEach-Object {Add-AppxPackage -DisableDevelopmentMode -Register "$($_.InstallLocation)\AppXManifest.xml"}
        Write-Host "Microsoft Store has been reset successfully." -ForegroundColor Green
    } catch {
        Write-Host "Failed to reset the Microsoft Store: $_" -ForegroundColor Red
    }
}

Reset-MicrosoftStore