# Script to uninstall Microsoft Teams and Office - Vinny Vasile - June 16th, 2023

# Prompt the user if they want to uninstall Microsoft Office 2019 to ensure they chose the right script
# Prompt the user if they want to uninstall Microsoft Teams
# If the user chooses to uninstall, the script proceeds with the uninstallation process
# It executes the uninstallation command for Microsoft Teams silently
# The script waits for the uninstallation process to complete
# If Microsoft Teams uninstallation is skipped, it displays a message indicating the skip
# A configuration file is created to specify the removal of Office applications (Access, Excel, OneNote, Outlook, PowerPoint, Project, Visio, Word)
# The Office Deployment Tool (ODT) is used with the configuration file to uninstall the specified Office applications
# The script resets the Microsoft Store to ensure proper functionality
# The temporary folder containing the downloaded files and installers is deleted for cleanup

$loggedInUser = (Get-WmiObject -Class Win32_ComputerSystem | Select-Object -ExpandProperty UserName).Split("\")[1]
$desktopPath = "C:\Users\$loggedInUser\Desktop"
$tempFolderPath = "$desktopPath\ScriptbyVV"
$ODTUrl = "https://download.microsoft.com/download/2/7/A/27AF1BE6-DD20-4CB4-B154-EBAB8A7D4A7E/officedeploymenttool_16501-20196.exe"
$ODTPath = "$tempFolderPath\OfficeDeployToolbyVinny"
$ConfigXmlPath = Join-Path -Path $ODTPath -ChildPath "vinnyssetup.xml"
$teamsUpdatePath = "C:\Users\$loggedInUser\AppData\Local\Microsoft\Teams\Update.exe"
$teamsShortcut = "C:\Users\$loggedInUser\AppData\Roaming\Microsoft\Windows\Start Menu\Programs\Microsoft Teams (work or school).lnk"
$teamsDesktopShortcutPath = Join-Path -Path $desktopPath -ChildPath "Microsoft Teams (work or school).lnk"

New-Item -ItemType Directory -Path $tempFolderPath -Force

$uninstallOption = Read-Host -Prompt "Do you want to uninstall Microsoft Office 2019? (Y/N)"
if ($uninstallOption -ne "Y") {
    exit
}

$uninstallTeamsOption = Read-Host -Prompt "Do you want to uninstall Microsoft Teams? (Y/N)"
if ($uninstallTeamsOption -eq "Y") {
    Write-Host "Additionally uninstalling Teams..." -ForegroundColor DarkYellow
    $uninstallerProcess = Start-Process -FilePath $teamsUpdatePath -ArgumentList "--uninstall" -NoNewWindow -Wait
    $uninstallerProcess.WaitForExit()
}
else {
    Write-Host "Teams uninstallation Skipped..." -ForegroundColor Red
}

Write-Host "Starting uninstallation of Microsoft Office 365..." -ForegroundColor DarkYellow

New-Item -ItemType Directory -Force -Path $ODTPath | Out-Null

$ODTExePath = Join-Path -Path $ODTPath -ChildPath "ODT.exe"

Invoke-WebRequest -Uri $ODTUrl -OutFile $ODTExePath

Start-Process -Wait -FilePath $ODTExePath -ArgumentList "/quiet", "/extract:$ODTPath"

@"
<Configuration>
  <Remove>
    <Product ID="ProPlus2019Volume">
    <Product ID="Access2019Volume">
    <Product ID="OneNote2019Volume">
    <Product ID="ProjectPro2019Volume">
    <Product ID="Publisher2019Volume">
    <Product ID="VisioPro2019Volume">
  <Remove>
  <Display Level="None" AcceptEULA="TRUE" />
</Configuration>
"@ | Set-Content -Path $ConfigXmlPath

$SetupExePath = Get-ChildItem -Path $ODTPath -Filter "setup.exe" -Recurse -Depth 1 | Select-Object -ExpandProperty FullName

Start-Process -Wait -FilePath $SetupExePath -ArgumentList "/configure", $ConfigXmlPath

Write-Host "Uninstallation completed successfully, resetting Microsoft App Store." -ForegroundColor DarkYellow

try {
  Get-AppXPackage *WindowsStore* -AllUsers | ForEach-Object {Add-AppxPackage -DisableDevelopmentMode -Register "$($_.InstallLocation)\AppXManifest.xml"}
  Write-Host "Microsoft Store has been reset successfully." -ForegroundColor Green
} catch {
  Write-Host "Failed to reset the Microsoft Store: $_" -ForegroundColor Red
}

Write-Host "Cleaning up Shortcuts and Temp Directory." -ForegroundColor DarkYellow

$appsToShortcut = @(
    "Access",
    "Excel",
    "OneNote",
    "Outlook",
    "PowerPoint",
    "Project",
    "Visio",
    "Word"
)

foreach ($app in $appsToShortcut) {
    $shortcutPath = Join-Path -Path $desktopPath -ChildPath "$app.lnk"
    
    if (Test-Path $shortcutPath) {
        Remove-Item -Path $shortcutPath -Force
        Write-Host "Shortcut deleted for $app." -ForegroundColor DarkGreen
    } else {
        Write-Host "Shortcut does not exist for $app." -ForegroundColor DarkYellow
    }
}


if (Test-Path $teamsDesktopShortcutPath) {
    Remove-Item -Path $teamsDesktopShortcutPath -Force
    Write-Host "Teams shortcut deleted." -ForegroundColor DarkGreen
} else {
    Write-Host "Teams shortcut does not exist." -ForegroundColor DarkYellow
}

Remove-Item -Path $tempFolderPath -Recurse -Force

Write-Host "Enjoy :)" -ForegroundColor DarkGreen
