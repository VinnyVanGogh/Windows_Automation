# Script to install Microsoft 365 Enterprise with Teams, and watchguard and create shortcuts, plus a welcome doc
# Vinny Vasile - June 16th, 2023

Import-Module ActiveDirectory
$loggedInUser = ((Get-WmiObject -Class Win32_ComputerSystem).UserName).Split('\')[1]
$loggedInUserAD = Get-ADUser -Identity $loggedInUser -Properties GivenName
$firstName = $loggedInUserAD.GivenName
$lastName = $loggedInUserAD.Surname
$emailAddress = $loggedInUserAD.EmailAddress
$domainName = $env:UserDomain
$domainUser = (Get-WmiObject -Class Win32_ComputerSystem).UserName
$domainPrefix = $domainName.Substring(0, 8)
$usernamePrefix = $loggedInUser.Substring(0, 6)
$computerName = "$domainPrefix-$usernamePrefix"
$desktopPath = "C:\Users\{0}\Desktop" -f $loggedInUser
$tempFolderPath = Join-Path -Path $desktopPath -ChildPath "ScriptSetup"
$teamsShortcut = "C:\Users\{0}\AppData\Roaming\Microsoft\Windows\Start Menu\Programs\Microsoft Teams (work or school).lnk" -f $loggedInUser
$teamsurl = "https://go.microsoft.com/fwlink/?linkid=2187327&Lmsrc=groupChatMarketingPageWeb&Cmpid=directDownloadWin32&clcid=0x409&culture=en-us&country=us"
$teamsinstallerPath = Join-Path -Path $tempFolderPath -ChildPath "vinnysteamsinstaller.exe"
$ODTUrl = "https://download.microsoft.com/download/2/7/A/27AF1BE6-DD20-4CB4-B154-EBAB8A7D4A7E/officedeploymenttool_16501-20196.exe"
$ODTPath = Join-Path -Path $tempFolderPath -ChildPath "OfficeDeployToolbyVinny"
$ConfigXmlPath = Join-Path -Path $ODTPath -ChildPath "vinnyssetup.xml"
$watchguardDownloadUrl = 'https://cdn.watchguard.com/SoftwareCenter/Files/MUVPN_SSL/12_7_2/WG-MVPN-SSL_12_7_2.exe'
$watchguardDownloadPath = Join-Path -Path $tempFolderPath -ChildPath "WatchguardMobileVPNInstallerAutomatedbyVinny.exe"
$watchguardShortcut = 'C:\ProgramData\Microsoft\Windows\Start Menu\Programs\WatchGuard\Mobile VPN with SSL client\Mobile VPN with SSL client.lnk'
$publicIp = (Invoke-WebRequest -Uri 'https://api.ipify.org?format=text').Content.Trim()
$watchGuardRegistryPath = "HKCU:\Software\WatchGuard\SSLVPNClient\Settings"
$userRegistryPath = "HKCU:\Software\Microsoft\Office\16.0\Common\Identity"
$exchangeRegistryPath = "HKCU:\Software\Microsoft\Exchange"
$storeProcess = Get-Process -Name "ms-windows-store" -ErrorAction SilentlyContinue
$todaysDate = Get-Date
$formattedDateTime = $todaysDate.ToString("MMMM dd, yyyy hh:mm tt")


New-Item -ItemType Directory -Path $tempFolderPath -Force

$installOption = Read-Host -Prompt $(Write-Host -NoNewline -ForegroundColor Cyan "Do you want to install Microsoft 365 Enterprise? (Y/N)")
$officeSuiteInstalled = $false
if ($installOption -eq "Y"){
Write-Host "Installing and setting up Office Suite with ODT..." -ForegroundColor DarkYellow

New-Item -ItemType Directory -Force -Path $ODTPath | Out-Null

$ODTExePath = Join-Path -Path $ODTPath -ChildPath "ODT.exe"

Invoke-WebRequest -Uri $ODTUrl -OutFile $ODTExePath

Start-Process -Wait -FilePath $ODTExePath -ArgumentList "/quiet", "/extract:$ODTPath"

@"
<Configuration>
    <Add OfficeClientEdition="64" Channel="Broad">
    <Product ID="O365ProPlusRetail">
        <Language ID="en-us" />
    </Product>
    <Product ID="VisioProRetail">
        <Language ID="en-us" />
    </Product>
    <Product ID="ProjectProRetail">
        <Language ID="en-us" />
    </Product>
    <Product ID="AccessProRetail">
    <Language ID="en-us" />
    </Product>
    </Add>
    <Updates Enabled="TRUE" />
    <Display Level="None" AcceptEULA="TRUE" />
    <Property Name="AUTOACTIVATE" Value="1" />
</Configuration>
"@ | Set-Content -Path $ConfigXmlPath

$SetupExePath = Get-ChildItem -Path $ODTPath -Filter "setup.exe" -Recurse -Depth 1 | Select-Object -ExpandProperty FullName

Start-Process -Wait -FilePath $SetupExePath -ArgumentList "/configure", $ConfigXmlPath

Set-ItemProperty -Path $userRegistryPath -Name 'EnableADAL' -Value 1
Set-ItemProperty -Path $userRegistryPath -Name 'Version' -Value 1
Set-ItemProperty -Path $exchangeRegistryPath -Name 'AlwaysUseMSOAuthForAutoDiscover' -Value 1

$officeSuiteInstalled = $true
}
else {
  Write-Host "Office 365 Enterprise Installation Skipped..." -ForegroundColor DarkYellow
}

$installWatchGuardOption = Read-Host -Prompt $(Write-Host -NoNewline -ForegroundColor Cyan "Do you want to install WatchGuard Mobile VPN? (Y/N)")
$watchGuardVPNInstalled = $false
if ($installWatchGuardOption -in @("Y", "y", "Yes", "yes", "YES")) {
    $usepublicIPorEnterIP = Read-Host -Prompt $(Write-Host -NoNewline -ForegroundColor Cyan "Enter an IP address or server name for the VPN, (N) to use current Public IP (If you enter port here, enter no on [VPN Port])")
    $VPNPort = Read-Host -Prompt $(Write-Host -NoNewline -ForegroundColor Cyan "Enter VPN Port, or anything else to continue without a port")
    $username = Read-Host -Prompt $(Write-Host -NoNewline -ForegroundColor Cyan "Enter username for VPN or no to use logged in user as username.")

    Invoke-WebRequest -Uri $watchguardDownloadUrl -OutFile $watchguardDownloadPath
    Start-Process -FilePath "$watchguardDownloadPath" -ArgumentList "/verysilent" -Wait

    Remove-Item -Path $watchguardDownloadPath -Force

    Start-Sleep -Seconds 5

    if ($username -in @("N", "NO", "no", "No", "nO", "n")) {
        if (-not [string]::IsNullOrWhiteSpace($loggedInUser)) {
            $username = $loggedInUser
        }
    }

    if ($usepublicIPorEnterIP -in @("N", "NO", "No", "nO", "n", "no")) {
        if ([string]::IsNullOrWhiteSpace($VPNPort) -or $VPNPort -match '^\d+$') {
            $VPNIP = if ([string]::IsNullOrWhiteSpace($VPNPort)) { $publicIp } else { "$publicIp`:$VPNPort" }
        } else {
            Write-Host "Invalid VPN port. Using IP without port." -ForegroundColor DarkYellow
            $VPNIP = $publicIp
        }
    } elseif ($usepublicIPorEnterIP -match '^[a-zA-Z0-9.-]+$') {
        if ([string]::IsNullOrWhiteSpace($VPNPort) -or $VPNPort -match '^\d+$') {
            $VPNIP = if ([string]::IsNullOrWhiteSpace($VPNPort)) { $usepublicIPorEnterIP } else { "$usepublicIPorEnterIP`:$VPNPort" }
        } else {
            Write-Host "Invalid VPN port. Using IP without port." -ForegroundColor DarkYellow
            $VPNIP = $usepublicIPorEnterIP
        }
    } else {
        Write-Host "Invalid input. Using current public IP address and port." -ForegroundColor DarkYellow
        $VPNIP = if ([string]::IsNullOrWhiteSpace($VPNPort)) { $publicIp } else { "$publicIp`:$VPNPort" }
    }

    $watchguardRegistryValues = @{
        'Server' = $VPNIP
        'Username' = $username
    }

    foreach ($entry in $watchguardRegistryValues.GetEnumerator()) {
        Set-ItemProperty -Path $watchGuardRegistryPath -Name $entry.Key -Value $entry.Value -Type String
    }

    Write-Host "WatchGuard Mobile VPN installation and configuration completed." -ForegroundColor Green
    
    $watchGuardVPNInstalled = $true
}
else {
    Write-Host "WatchGuard Mobile VPN installation skipped." -ForegroundColor DarkYellow
}

$installTeamsOption = Read-Host -Prompt $(Write-Host -NoNewline -ForegroundColor Cyan "Do you want to install Microsoft Teams? (Y/N)")
$teamsInstalled = $false
if ($installTeamsOption -eq "Y") {
    Write-Host "Starting installation of Microsoft Teams..." -ForegroundColor Green
    Invoke-WebRequest -Uri $teamsurl -OutFile $teamsinstallerPath
    Start-Process -FilePath $teamsinstallerPath -ArgumentList "/s" -PassThru
    $teamsInstalled = $true
}
else {
    Write-Host "Teams Installation Skipped..." -ForegroundColor DarkYellow
}

$setupByTechnician = Read-Host -Prompt $(Write-Host -NoNewline -ForegroundColor Cyan "Enter your name, to sign the document for the user")

Write-Host "Changing Power settings..." -ForegroundColor Green

Add-Type -TypeDefinition @"
using System;
using System.Runtime.InteropServices;

public class Power {
    [DllImport("kernel32.dll", CharSet = CharSet.Auto, SetLastError = true)]
    public static extern uint SetThreadExecutionState(uint esFlags);
}
"@

$null = [Power]::SetThreadExecutionState([UInt32] "0x80000003")

powercfg /change monitor-timeout-ac 30
powercfg /change monitor-timeout-dc 60
powercfg /change standby-timeout-ac 60
powercfg /change standby-timeout-dc 120

Write-Host "Office Suite: $(if ($officeSuiteInstalled) { 'Installed, creating shortcuts on desktop...' } else { 'Skipped, attempting to create shortcuts still if Office is already installed...' })" -ForegroundColor DarkYellow
Write-Host "WatchGuard Mobile VPN: $(if ($watchGuardVPNInstalled) { 'Installed, creating shortcuts on desktop...' } else { 'Skipped, attempting to create shortcuts still if the app is already installed...' })" -ForegroundColor DarkYellow
Write-Host "Microsoft Teams: $(if ($teamsInstalled) { 'Installed, creating shortcuts on desktop...' } else { 'Skipped, attempting to create shortcuts still if the app is already installed...' })" -ForegroundColor DarkYellow



$vpnShortcutcreated = $false
if (!(Test-Path "$desktopPath\*Mobile VPN*.lnk")) {
    Copy-Item -Path $watchguardShortcut -Destination "$desktopPath\$domainName WatchGuard Mobile VPN.lnk"
    $vpnShortcutcreated = $true
}


$teamsShortcutcreated = $false
if (!(Test-Path "$desktopPath\Microsoft Teams (work or school).lnk")) {
  Copy-Item -Path $teamsShortcut -Destination "$desktopPath\$loggedInUser's Microsoft Teams for $domainName.lnk"
  Write-Host  -ForegroundColor Green
  $teamsShortcutcreated = $true
}


$appsToShortcut = @(
    "Outlook",
    "Word",
    "Excel",
    "Microsoft Edge",
    "OneNote",
    "OneDrive",
    "PowerPoint",
    "Visio",
    "Access",
    "Project"
)


foreach ($app in $appsToShortcut) {
    $shortcutPath = Join-Path -Path $desktopPath -ChildPath "$loggedInUser's $app.lnk"
    $targetPath = "C:\ProgramData\Microsoft\Windows\Start Menu\Programs\$app.lnk"

    if (-not (Test-Path $shortcutPath)) {
        $shell = New-Object -ComObject WScript.Shell
        $shortcut = $shell.CreateShortcut($shortcutPath)
        $shortcut.TargetPath = $targetPath
        $shortcut.Save()
        Write-Host "Shortcut created for $app." -ForegroundColor Green
    } else {
        Write-Host "Shortcut already exists for $app." -ForegroundColor DarkYellow
    }
    $shortcutCreated = Test-Path $shortcutPath
    Write-Host "$app $(if ($shortcutCreated) { 'is now on your desktop...' } else { "Failed to create shortcut for $app you can create one from $targetPath" })" -ForegroundColor Green
}


Write-Host "WatchGuard Mobile VPN: $(if ($vpnShortcutcreated) { "Shortcut for $domainName WatchGuard Mobile VPN has been created..." } else { "Unable to create shortcut $loggedInUser's Microsoft Teams for $domainName, you can find the application at, $watchguardShortcut" })" -ForegroundColor DarkYellow
Write-Host "Microsoft Teams: $(if ($teamsShortcutcreated) { "Shortcut created for $loggedInUser's Microsoft Teams for $domainName" } else { "Unable to create shortcut $loggedInUser's Microsoft Teams for $domainName, you can find the application at, $teamsShortcut" })" -ForegroundColor DarkYellow

$microsoftStoreResetOption = Read-Host -Prompt $(Write-Host -NoNewline -ForegroundColor Cyan "Are you having issues with the microsoft store(resets Microsoft store app)? (Y/N)")
if ($microsoftStoreResetOption -eq "Y") {
  start ms-windows-store:
  Start-Sleep -Milliseconds 250
  taskkill /f /im WinStore.App.exe

  if ($storeProcess) {
      $storeProcess | Stop-Process -Force
      Write-Host "Microsoft Store closed successfully, resetting store." -ForegroundColor DarkYellow
  } else {
      Write-Host "Microsoft Store is not running, resetting store." -ForegroundColor DarkYellow
  }

  try {
    Get-AppXPackage *WindowsStore* -AllUsers | ForEach-Object {Add-AppxPackage -DisableDevelopmentMode -Register "$($_.InstallLocation)\AppXManifest.xml"}
    Write-Host "Microsoft Store has been reset successfully." -ForegroundColor Green
  } catch {
    Write-Host "Failed to reset the Microsoft Store: $_" -ForegroundColor Red
  }
}
Write-Host "Applications installed, creating Welcome Document for user." -ForegroundColor Green

$renameComputerOption = Read-Host -Prompt ("Do you want to rename the computer to " + $computerName + "? (Y/N)")
if ($renameComputerOption -eq "Y") {
    Rename-Computer -NewName "$computerName" -Force
    $renamePerformed = $true
}
else {
    $secondRenameComputerOption = Read-Host -Prompt "Do you want to rename the computer yourself? (Y/N)"
    if ($secondRenameComputerOption -eq "Y") {
        $newComputerName = Read-Host -Prompt "Enter the new computer name (Max 15 Characters):"
        Rename-Computer -NewName $newComputerName -Force
        $renamePerformed = $true
        $computerName = $newComputerName
    }
}

$docPath = Join-Path -Path $desktopPath -ChildPath "Welcome Info | $setupByTechnician - $formattedDateTime.docx"

$wordApp = New-Object -ComObject "Word.Application"
$doc = $wordApp.Documents.Add()


$welcomeContent = @"
Welcome $firstName $lastName!
We're glad to have you onboard $firstName. We are Accent Computer Solutions, a VC3 Company, and we will be your IT support team.
Here you will find what you need to login to various apps:
    • Computer Name: $computerName
    • Username: $username
    • Domain Login: $domainUser
    • Email Address: $emailAddress
    • Password: The password you used to login syncs across all or most applications.
And here is your vpn info (if installed):
    • Server Name: $VPNIP
    • Username: $loggedInUser, or $domainUser
    • Password: The password you used to login syncs across all or most applications.

Client Support Center:
Having a problem? We're ready to help!
    Support Hours:
        • Live Support: Weekdays 6:00 am - 6:00 pm,
        • Saturday 7:30 am - 4:30 pm Pacific Time
        • via the Accent hero icon, email, or phone at:
                - Local Phone: 909.481.4368
                - Toll-Free: 800.481.4369

On-Call Support: Available 24/7/365 outside of normal business hours by calling (800) 481-4369
If you need any help, don't hesitate to ask. We're here to support you!
Enjoy your day!
$setupByTechnician - $formattedDateTime
"@

$boldSections = @(
    "Welcome $firstName $lastName!",
    "Accent Computer Solutions, a VC3 Company,",
    "Here you will find what you need to login to various apps:",
    "And here is your vpn info (if installed):",
    "Client Support Center:",
    "Support Hours:",
    "Live Support:",
    "$firstName",
    "$lastName",
    "$VPNIP",
    "$loggedInUser",
    "$domainUser",
    "$emailAddress",
    "$computerName",
    "On-Call Support:",
    "Accent hero icon",
    "If you need any help, don't hesitate to ask. We're here to support you!",
    "Enjoy your day!",
    "$setupByTechnician - $formattedDateTime"
)

$paragraph = $doc.Content.Paragraphs.Add()
$range = $paragraph.Range
$range.Text = $welcomeContent
$range.Start = 0
$range.End = $range.Text.Length

foreach ($section in $boldSections) {
    $start = $range.Text.IndexOf($section)
    $end = $start + $section.Length
    $boldRange = $doc.Range($range.Start + $start, $range.Start + $end)
    $boldRange.Bold = $true
}

$doc.Content.Font.Name = "Times New Roman"
$doc.Content.Font.Size = 12

$doc.SaveAs($docPath)
$doc.Close()
$wordApp.Quit()

[System.Runtime.Interopservices.Marshal]::ReleaseComObject($paragraph) | Out-Null
[System.Runtime.Interopservices.Marshal]::ReleaseComObject($doc) | Out-Null
[System.Runtime.Interopservices.Marshal]::ReleaseComObject($wordApp) | Out-Null
[System.GC]::Collect()
[System.GC]::WaitForPendingFinalizers()


Write-Host "Almost done, cleaning up after ourselves, then you will be asked if you'd like to rename the computer" -ForegroundColor DarkYellow 

$null = [Power]::SetThreadExecutionState([UInt32] "0x80000000")

Start-Sleep -Seconds 5

Remove-Item -Path $tempFolderPath -Recurse -Force

if ($renamePerformed -and (Read-Host -Prompt "Do you want to reboot the computer? (Y/N)") -eq "Y") {
  Write-Host "Script completed successfully, rebooting in 3 seconds. Enjoy :)" -ForegroundColor Green
  Start-Sleep -Seconds 3
  Restart-Computer -Force
}
else {
  Write-Host "Script completed successfully. Enjoy :)" -ForegroundColor Green
  Start-Sleep -Seconds 1
  Start-Process -FilePath $docPath
}

