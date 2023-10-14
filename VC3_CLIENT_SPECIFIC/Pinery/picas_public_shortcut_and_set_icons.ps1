$clientFolder = "\\piapp01\progress_client"
$iconFolder = "\\piapp01\Progress_Client\icons"
$localiconFolder = "C:\Users\Public\PicasIcons"
$desktopPath = "C:\users\Public\Desktop"

New-Item -Path $localiconFolder -ItemType Directory -Force

robocopy $iconFolder $localiconFolder /MIR

robocopy $clientFolder $desktopPath "Picas QA.lnk"
robocopy $clientFolder $desktopPath "Picas.lnk"

$shortcutPath = "$desktopPath\Picas.lnk"
if (Test-Path $shortcutPath) {
    $WshShell = New-Object -ComObject WScript.Shell
    $Shortcut = $WshShell.CreateShortcut($shortcutPath)
    $Shortcut.IconLocation = "$localiconFolder\current.ico"
    $Shortcut.Save()
} else {
    Write-Host "The shortcut does not exist."
}

$shortcutPath = "$desktopPath\Picas QA.lnk"
if (Test-Path $shortcutPath) {
    $WshShell = New-Object -ComObject WScript.Shell
    $Shortcut = $WshShell.CreateShortcut($shortcutPath)
    $Shortcut.IconLocation = "$localiconFolder\current-qa.ico"
    $Shortcut.Save()
} else {
    Write-Host "The shortcut does not exist."
}
