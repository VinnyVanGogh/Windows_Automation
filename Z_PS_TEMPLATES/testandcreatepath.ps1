$targetPath = Write-Host "Enter the path to create: "

if (-not (Test-Path $targetPath)) {
    New-Item -ItemType Directory -Path $targetPath | Out-Null
    Write-Host "Created the directory: $targetPath"
} else {
    Write-Host "The directory already exists: $targetPath"
}
