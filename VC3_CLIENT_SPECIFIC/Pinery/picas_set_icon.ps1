$loggedInUser = ((Get-WmiObject -Class Win32_ComputerSystem).UserName).Split('\')[1]
$iconFolder = "\\piapp01\Progress_Client\icons"
$localiconFolder = "C:\Users\$loggedInUser\PicasIcons"
$desktopPath = "C:\users\$loggedInUser\Desktop"
New-Item -Path $localiconFolder -ItemType Directory -Force
Copy-Item -Path $iconFolder -Destination $localiconFolder -Recurse -Force


$shortcutPath = "$desktopPath\Picas.lnk"
if (Test-Path $shortcutPath) {
    $WshShell = New-Object -ComObject WScript.Shell
    $Shortcut = $WshShell.CreateShortcut($shortcutPath)
    $Shortcut.IconLocation = "$localiconFolder\icons\current.ico"
    $Shortcut.Save()
} else {
    Write-Host "The shortcut does not exist."
}

$shortcutPath = "$desktopPath\Picas QA.lnk"
if (Test-Path $shortcutPath) {
    $WshShell = New-Object -ComObject WScript.Shell
    $Shortcut = $WshShell.CreateShortcut($shortcutPath)
    $Shortcut.IconLocation = "$localiconFolder\icons\current-qa.ico"
    $Shortcut.Save()
} else {
    Write-Host "The shortcut does not exist."
}






$loggedInUser = ((Get-WmiObject -Class Win32_ComputerSystem).UserName).Split('\')[1]
$iconFolder = "\\piapp01\Progress_Client\icons"
$localiconFolder = "C:\Users\Public\PicasIcons"
$desktopPath = "C:\users\Public\Desktop"
New-Item -Path $localiconFolder -ItemType Directory -Force
Copy-Item -Path $iconFolder -Destination $localiconFolder -Recurse -Force


$shortcutPath = "$desktopPath\Picas.lnk"
if (Test-Path $shortcutPath) {
    $WshShell = New-Object -ComObject WScript.Shell
    $Shortcut = $WshShell.CreateShortcut($shortcutPath)
    $Shortcut.IconLocation = "$localiconFolder\icons\current.ico"
    $Shortcut.Save()
} else {
    Write-Host "The shortcut does not exist."
}

$shortcutPath = "$desktopPath\Picas QA.lnk"
if (Test-Path $shortcutPath) {
    $WshShell = New-Object -ComObject WScript.Shell
    $Shortcut = $WshShell.CreateShortcut($shortcutPath)
    $Shortcut.IconLocation = "$localiconFolder\icons\current-qa.ico"
    $Shortcut.Save()
} else {
    Write-Host "The shortcut does not exist."
}