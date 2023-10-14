$driveLetter = Read-Host "Enter Letter for Shared Drive on Local PC"
$networkPath = Read-Host "Enter network path ex \\Server123\Path\To\Folder"

$credential = Get-Credential -Message "Enter your username and password."

New-PSDrive -Name ($driveLetter -replace ":", "") -PSProvider FileSystem -Root $networkPath -Persist -Credential $credential

$confirmation = Read-Host "Do you want to remove the shared drive? (Y/N)"

if ($confirmation -eq 'Y' -or $confirmation -eq 'y') {
    Remove-PSDrive -Name ($driveLetter -replace ":", "")
    Write-Host "The shared drive has been removed." -ForegroundColor Green
}
else {
   Write-Host "The shared drive doesn't seem to be added..." -ForegroundColor DarkYellow
}

$confirmation = Read-Host "Do you want to reconnect the shared drive? (Y/N)"

if ($confirmation -eq 'Y' -or $confirmation -eq 'y') {
    New-PSDrive -Name ($driveLetter -replace ":", "") -PSProvider FileSystem -Root $networkPath -Persist -Credential $credential
    Write-Host "The shared drive has been reconnected." -ForegroundColor Green
}
else {
    Write-Host "Failed to reconnect the shared drive, please reach out to support." -ForegroundColor Red
}
