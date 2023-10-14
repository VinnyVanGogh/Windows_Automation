# Script to uninstall Microsoft Teams and Office - Vinny Vasile - June 16th, 2023

# Prompt the user if they want to uninstall Microsoft Office 365 to ensure they chose the right script
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
$desktopPath = "C:\Users\{0}\Desktop" -f $loggedInUser
$tempFolderPath = Join-Path -Path $desktopPath -ChildPath "UninstallSetup"
$ODTDownloadURL = "https://download.microsoft.com/download/2/7/A/27AF1BE6-DD20-4CB4-B154-EBAB8A7D4A7E/officedeploymenttool_16501-20196.exe"
$ODTTempFolderPath = Join-Path -Path $tempFolderPath -ChildPath "OfficeDeployToolbyVinny"
$MS365ConfigXmlPath = Join-Path -Path $ODTTempFolderPath -ChildPath "vinnysoffice365setup.xml"
$teamsUpdatePath = "C:\Users\{0}\AppData\Local\Microsoft\Teams\Update.exe" -f $loggedInUser
$teamsDesktopShortcutPath = Get-ChildItem -Path $desktopPath | Where-Object { $_.Name -like "*Teams*" }
$mobileVPNShortcutPath = Get-ChildItem -Path $desktopPath | Where-Object { $_.Name -like "*VPN*" }
$SaRAapprefLauncher = Join-Path -Path $desktopPath -ChildPath "Microsoft Support and Recovery Assistant.appref-ms"
$SaRADownloadURL = "https://aka.ms/SaRA-Internet-Setup"
$SaRASetupPath = Join-Path -Path $Env:TEMP -ChildPath "SaraSetup.exe"
$watchguardUninstallerPath = "C:\Program Files (x86)\WatchGuard\WatchGuard Mobile VPN with SSL\unins000.exe"
$watchguarduninstallArgs = "/verysilent"
$teamsuninstallArgs = "--uninstall"
$ODTuninstallArgs = "/quiet", "/extract:$ODTTempFolderPath"
$SaRAinstallArgs = "/quiet"

New-Item -ItemType Directory -Path $tempFolderPath -Force | Out-Null

$uninstallOption = Read-Host -Prompt "Do you want to uninstall Microsoft Office 365? (Y/N)"
if ($uninstallOption -ne "Y") {
    exit
}

$confirmation = Read-Host "Do you want to close Mobile VPN with SSL client and uninstall it? (Y/N)"
if ($confirmation -eq "Y" -or $confirmation -eq "Yes") {
    # Close Mobile VPN with SSL client processes
    $processes = Get-Process | Where-Object { $_.Name -like "*wgsslvpn*" }

    if ($processes) {
        foreach ($process in $processes) {
            $process | Stop-Process -Force
            Write-Host "Closed process: $($process.Name)"
        }
    } else {
        Write-Host "No running processes found for Mobile VPN with SSL client"
    }

    if (Test-Path $watchguardUninstallerPath) {
        $uninstallResult = Start-Process -FilePath $watchguardUninstallerPath -ArgumentList $watchguarduninstallArgs -Wait -NoNewWindow

        if ($uninstallResult.ExitCode -eq 0) {
            Write-Host "Uninstalled Mobile VPN with SSL client"
        } else {
            Write-Host "Failed to uninstall Mobile VPN with SSL client. Error code: $($uninstallResult.ExitCode)"
        }
    } else {
        Write-Host "Uninstaller not found at: $watchguardUninstallerPath"
    }

    $remainingFiles = @(
        "C:\Program Files\WatchGuard\Mobile VPN"
        "C:\Users\$loggedInUser\AppData\Roaming\WatchGuard\Mobile VPN"
    )

    $remainingRegistryKeys = @(
        "HKCU:\Software\WatchGuard\SSLVPNClient\Settings"
        "HKCU:\Software\Microsoft\Windows\CurrentVersion\Run\WatchGuard Mobile VPN with SSL"
    )

    $remainingFiles | ForEach-Object {
        if (Test-Path $_) {
            Remove-Item -Path $_ -Recurse -Force
            Write-Host "Deleted: $_"
        } else {
            Write-Host "File not found: $_"
        }
    }

    $remainingRegistryKeys | ForEach-Object {
        if (Test-Path $_) {
            Remove-Item -Path $_ -Force
            Write-Host "Deleted registry key: $_"
        } else {
            Write-Host "Registry key not found: $_"
        }

      if ($mobileVPNShortcutPath) {
          Remove-Item -Path $mobileVPNShortcutPath -Force
          Write-Host "Mobile VPN shortcut deleted." -ForegroundColor DarkGreen
      } else {
          Write-Host "Mobile VPN shortcut does not exist." -ForegroundColor DarkYellow
      }
    }
} else {
    Write-Host "Mobile VPN with SSL client closure and uninstallation skipped."
}

$uninstallTeamsOption = Read-Host -Prompt "Do you want to uninstall Microsoft Teams? (Y/N)"
if ($uninstallTeamsOption -eq "Y") {
    Write-Host "Additionally uninstalling Teams..." -ForegroundColor DarkYellow
    Start-Process -FilePath $teamsUpdatePath -ArgumentList $teamsuninstallArgs -NoNewWindow -Wait
}
else {
    Write-Host "Teams uninstallation Skipped..." -ForegroundColor Red
}

Write-Host "Starting uninstallation of Microsoft Office 365..." -ForegroundColor DarkYellow

New-Item -ItemType Directory -Force -Path $ODTTempFolderPath | Out-Null

$ODTExePath = Join-Path -Path $ODTTempFolderPath -ChildPath "ODT.exe"

Invoke-WebRequest -Uri $ODTDownloadURL -OutFile $ODTExePath

Start-Process -Wait -FilePath $ODTExePath -ArgumentList $ODTuninstallArgs 

@"
<Configuration>
  <Remove>
    <Product ID="O365ProPlusRetail" />
    <Product ID="VisioProRetail" />
    <Product ID="ProjectProRetail" />
  </Remove>
  <Display Level="None" AcceptEULA="TRUE" />
</Configuration>
"@ | Set-Content -Path $MS365ConfigXmlPath

$SetupExePath = Get-ChildItem -Path $ODTTempFolderPath -Filter "setup.exe" -Recurse -Depth 1 | Select-Object -ExpandProperty FullName

Start-Process -Wait -FilePath $SetupExePath -ArgumentList "/configure", $MS365ConfigXmlPath

Write-Host "Uninstallation completed successfully, resetting Microsoft App Store." -ForegroundColor DarkYellow

try {
  Get-AppXPackage *WindowsStore* -AllUsers | ForEach-Object {Add-AppxPackage -DisableDevelopmentMode -Register "$($_.InstallLocation)\AppXManifest.xml"}
  Write-Host "Microsoft Store has been reset successfully." -ForegroundColor Green
} catch {
  Write-Host "Failed to reset the Microsoft Store: $_" -ForegroundColor Red
}

Write-Host "Cleaning up Shortcuts and Temp Directory." -ForegroundColor DarkYellow

$appsToShortcut = @(
    "*Access*",
    "*Excel*",
    "*OneNote*",
    "*Outlook*",
    "*PowerPoint*",
    "*Project*",
    "*Visio*",
    "*Word*"
)

foreach ($app in $appsToShortcut) {
    $shortcutPaths = Get-ChildItem -Path $desktopPath -Filter "$app.lnk" -File

    foreach ($shortcutPath in $shortcutPaths) {
        Remove-Item -Path $shortcutPath.FullName -Force
        Write-Host "Shortcut deleted: $($shortcutPath.Name)" -ForegroundColor DarkGreen
    }
}

if (Test-Path $teamsDesktopShortcutPath) {
    Remove-Item -Path $teamsDesktopShortcutPath -Force
    Write-Host "Teams shortcut deleted." -ForegroundColor DarkGreen
} else {
    Write-Host "Teams shortcut does not exist." -ForegroundColor DarkYellow
}

$installSaRAOption = Read-Host -Prompt "Did you have issues uninstalling Microsoft? Install Microsoft Support and Recovery Assistant (SaRA)? (Y/N)"
if ($installSaRAoption -eq "Y") {

Invoke-WebRequest -Uri $SaRADownloadURL -OutFile $SaRASetupPath

Start-Process -FilePath $SaRASetupPath -ArgumentList $SaRAinstallArgs -Wait

$InstallCheck = Get-ChildItem "HKCU:\Software\Microsoft\Windows\CurrentVersion\Uninstall"
$foundMatch = $false

foreach ($subkey in $InstallCheck) {
    if ($subkey.GetValue('DisplayName') -match "Microsoft Support and Recovery Assistant") {
        $foundMatch = $true
        $SaraVersion = $subkey.GetValue('DisplayVersion')
        Write-Host "Support and Recovery Assistant version $SaraVersion is installed."
        break
    }
}

if (-not $foundMatch) {
    Write-Host "Support and Recovery Assistant is not installed, you can look in $SaRASetupPath if it is not on your desktop." -ForegroundColor DarkYellow 
}

$setupExePath = "$Env:TEMP\SaraSetup.exe"
Start-Process -FilePath $setupExePath -Wait

Start-Process -FilePath $SaRAapprefLauncher

Write-Host "Microsoft Support and Recovery Assistant (SaRA) setup and application have been executed." -ForegroundColor DarkGreen
}
else {
    Write-Host "Microsoft Support and Recovery Assistant (SaRA) installation and launch have been skipped..." -ForegroundColor Red
}

Remove-Item -Path $tempFolderPath -Recurse -Force

Write-Host "Enjoy :)" -ForegroundColor DarkGreen


