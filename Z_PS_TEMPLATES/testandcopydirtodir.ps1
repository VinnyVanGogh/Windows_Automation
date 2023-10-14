$loggedInUser = (Get-WmiObject -Class Win32_ComputerSystem | Select-Object -ExpandProperty UserName).Split('\')[1]
$targetPath = "C:\Users\$loggedInUser\AccentIT\Sysinternals"
$destinationPath = "C:\Users\$loggedInUser\Desktop\Swag"

if (-not (Test-Path $targetPath)) {
    Write-Host "The target directory does not exist: $targetPath"
} else {
    if (-not (Test-Path $destinationPath)) {
        New-Item -ItemType Directory -Path $destinationPath | Out-Null
        Write-Host "Created the destination directory: $destinationPath"
    }
    Copy-Item -Path $targetPath\* -Destination $destinationPath -Force -Recurse
    Write-Host "Copied contents from target to destination."
}