# Script to install Microsoft Office 2019 with Teams and create shortcuts - Vinny Vasile - June 16th, 2023

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
$tempFolderPath = Join-Path -Path $desktopPath -ChildPath "ScriptbyVV"
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

New-Item -ItemType Directory -Path $tempFolderPath -Force

$installOption = Read-Host -Prompt "Do you want to install Microsoft Office 2019? (Y/N)"
if ($installOption -ne "Y") {
    exit
}

Add-Type -TypeDefinition @"
using System;
using System.Runtime.InteropServices;

public class Power {
    [DllImport("kernel32.dll", CharSet = CharSet.Auto, SetLastError = true)]
    public static extern uint SetThreadExecutionState(uint esFlags);
}
"@

$null = [Power]::SetThreadExecutionState([UInt32] "0x80000003")

$installWatchGuardOption = Read-Host -Prompt "Do you want to install WatchGuard Mobile VPN? (Y/N)"

if ($installWatchGuardOption -in @("Y", "y", "Yes", "yes", "YES")) {
    $usepublicIPorEnterIP = Read-Host "Enter an IP address or server name for the VPN, N to use current Public"
    $VPNPort = Read-Host "Enter VPN Port, or anything else to continue without a port"
    $username = Read-Host "Enter username or no to use logged in user as username."

    Invoke-WebRequest -Uri $watchguardDownloadUrl -OutFile $watchguardDownloadPath
    Start-Process -FilePath "$watchguardDownloadPath" -ArgumentList "/verysilent" -Wait

    if (!(Test-Path "$desktopPath\*Mobile VPN*.lnk")) {
        Copy-Item -Path $watchguardShortcut -Destination "$desktopPath\$domainName WatchGuard Mobile VPN.lnk"
    }

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
            Write-Host "Invalid VPN port. Using IP without port."
            $VPNIP = $publicIp
        }
    } elseif ($usepublicIPorEnterIP -match '^[a-zA-Z0-9.-]+$') {
        if ([string]::IsNullOrWhiteSpace($VPNPort) -or $VPNPort -match '^\d+$') {
            $VPNIP = if ([string]::IsNullOrWhiteSpace($VPNPort)) { $usepublicIPorEnterIP } else { "$usepublicIPorEnterIP`:$VPNPort" }
        } else {
            Write-Host "Invalid VPN port. Using IP without port."
            $VPNIP = $usepublicIPorEnterIP
        }
    } else {
        Write-Host "Invalid input. Using current public IP address and port."
        $VPNIP = if ([string]::IsNullOrWhiteSpace($VPNPort)) { $publicIp } else { "$publicIp`:$VPNPort" }
    }

    $watchguardRegistryValues = @{
        'Server' = $VPNIP
        'Username' = $username
    }

    foreach ($entry in $watchguardRegistryValues.GetEnumerator()) {
        Set-ItemProperty -Path $watchGuardRegistryPath -Name $entry.Key -Value $entry.Value -Type String
    }

    Write-Host "WatchGuard Mobile VPN installation and configuration completed." -ForegroundColor Black -BackgroundColor Green
}
else {
    Write-Host "WatchGuard Mobile VPN installation skipped."
}

$installTeamsOption = Read-Host -Prompt "Do you want to install Microsoft Teams? (Y/N)"
if ($installTeamsOption -eq "Y") {
    Write-Host "Starting installation of Microsoft Teams..." -ForegroundColor DarkYellow
    Invoke-WebRequest -Uri $teamsurl -OutFile $teamsinstallerPath
    Start-Process -FilePath $teamsinstallerPath -PassThru
}
else {
    Write-Host "Teams Installation Skipped..." -ForegroundColor Red
}

powercfg /change monitor-timeout-ac 30
powercfg /change monitor-timeout-dc 60
powercfg /change standby-timeout-ac 60
powercfg /change standby-timeout-dc 120

New-Item -ItemType Directory -Force -Path $ODTPath | Out-Null

$ODTExePath = Join-Path -Path $ODTPath -ChildPath "ODT.exe"

Invoke-WebRequest -Uri $ODTUrl -OutFile $ODTExePath

Start-Process -Wait -FilePath $ODTExePath -ArgumentList "/quiet", "/extract:$ODTPath"

@"
<Configuration>
  <Add OfficeClientEdition="64" Channel="PerpetualVL2019">
    <Product ID="ProPlus2019Volume">
      <Language ID="en-us" />
    </Product>
    <Product ID="Access2019Volume">
      <Language ID="en-us" />
    </Product>
    <Product ID="OneNote2019Volume">
      <Language ID="en-us" />
    </Product>
    <Product ID="ProjectPro2019Volume">
      <Language ID="en-us" />
    </Product>
    <Product ID="Publisher2019Volume">
      <Language ID="en-us" />
    </Product>
    <Product ID="VisioPro2019Volume">
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

Write-Host "Installation completed successfully, creating Shortcuts for installed apps." -ForegroundColor DarkYellow

    Set-ItemProperty -Path $userRegistryPath -Name 'EnableADAL' -Value 1
    Set-ItemProperty -Path $userRegistryPath -Name 'Version' -Value 1
    Set-ItemProperty -Path $exchangeRegistryPath -Name 'AlwaysUseMSOAuthForAutoDiscover' -Value 1

if (!(Test-Path "$desktopPath\Microsoft Teams (work or school).lnk")) {
  Copy-Item -Path $teamsShortcut -Destination "$desktopPath\$loggedInUser's Microsoft Teams for $domainName.lnk"
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
      Write-Host "Shortcut created for $app."
  } else {
      Write-Host "Shortcut already exists for $app."
  }
}

if ($storeProcess) {
    $storeProcess | Stop-Process -Force
    Write-Host "Microsoft Store closed successfully." -ForegroundColor Green
} else {
    Write-Host "Microsoft Store is not running." -ForegroundColor Yellow
}

Write-Host "Shortcuts created successfully." -ForegroundColor Green


try {
  Get-AppXPackage *WindowsStore* -AllUsers | ForEach-Object {Add-AppxPackage -DisableDevelopmentMode -Register "$($_.InstallLocation)\AppXManifest.xml"}
  Write-Host "Microsoft Store has been reset successfully." -ForegroundColor Green
} catch {
  Write-Host "Failed to reset the Microsoft Store: $_" -ForegroundColor Red
}

Write-Host "Applications installed, creating Welcome Document." -ForegroundColor DarkGreen

Add-Type -Path "C:\Program Files\Microsoft Office\root\Office16\MSWORD.OLB"

$wordApp = New-Object -ComObject Word.Application

$doc = $wordApp.Documents.Add()

$welcomeContent = @"
Welcome $firstName $lastName!
We're glad to have you onboard $firstName. We are Accent Computer Solutions, a VC3 Company, and we will be your IT support team.

    Here are your login, and email credentials, as well as a few other useful pieces of information:
        - Computer Name: $computerName
        - Username: $username
        - Domain Login: $domainUser
        - Email Address: $emailAddress
        - Password: The password you used to login syncs across all or most applications.

    And your VPN Info if installed:
        - Server Name: $VPNIP
        - Username: $loggedInUser, or $domainUser
        - Password: The password you used to login syncs across all or most applications.

                Client Support Center
                Having a problem? We're ready to help!

                Support Hours:
                Live Support: Weekdays 6:00 am - 6:00 pm,
                Saturday 7:30 am - 4:30 pm Pacific Time
                via the Accent hero icon, email, or phone at:
                Local Phone: 909.481.4368
                Toll-Free: 800.481.4369

On-Call Support: Available 24/7/365 outside of normal business hours by calling (800) 481-4369
If you need any help, don't hesitate to ask. We're here to support you!

Enjoy your day!
    Best,
    Accent Computer Solutions, a VC3 Company
"@

$paragraph = $doc.Content.Paragraphs.Add()
$paragraph.Range.Text = $welcomeContent

$doc.SaveAs("$desktopPath\Welcome Info - From Accent.docx")

$doc.Close()
$wordApp.Quit()

[System.Runtime.Interopservices.Marshal]::ReleaseComObject($paragraph) | Out-Null
[System.Runtime.Interopservices.Marshal]::ReleaseComObject($doc) | Out-Null
[System.Runtime.Interopservices.Marshal]::ReleaseComObject($wordApp) | Out-Null
[System.GC]::Collect()
[System.GC]::WaitForPendingFinalizers()


Write-Host "Almost done, cleaning things up..." -ForegroundColor DarkYellow 

$null = [Power]::SetThreadExecutionState([UInt32] "0x80000000")

Start-Sleep -Seconds 5

Remove-Item -Path $tempFolderPath -Recurse -Force

Rename-Computer -NewName "$computerName"

Write-Host "Script Completed successfully. Enjoy :)" -ForegroundColor DarkGreen 
