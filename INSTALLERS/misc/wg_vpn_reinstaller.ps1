$LOGGED_IN_USER = (Get-WmiObject -Class Win32_ComputerSystem | Select-Object -ExpandProperty UserName).Split('\')[1]
$PUBLIC_IP = (Invoke-WebRequest -Uri 'https://api.ipify.org?format=text').Content.Trim()
$WATCHGUARD_REGISTRY_PATH = "HKCU:\Software\WatchGuard\SSLVPNClient\Settings"
$DOMAIN_NAME = $ENV:UserDomain
$TEMP_PATH = "C:\Users\$LOGGED_IN_USER\Temp"
$DESKTOP_PATH = "C:\Users\$LOGGED_IN_USER\Desktop"
$WATCHGUARD_DOWNLOAD_URL = 'https://cdn.watchguard.com/SoftwareCenter/Files/MUVPN_SSL/12_7_2/WG-MVPN-SSL_12_7_2.exe'
$WATCHGUARD_DOWNLOAD_PATH = "$TEMP_PATH\WatchguardMobileVPNInstallerAutomatedbyVinny.exe"
$WATCHGUARD_SHORTCUT = 'C:\ProgramData\Microsoft\Windows\Start Menu\Programs\WatchGuard\Mobile VPN with SSL client\Mobile VPN with SSL client.lnk'

function Stop-VPNProcesses {
    $processes = Get-Process | Where-Object { $_.Name -like "*wgsslvpn*" }
    if ($processes) {
        foreach ($process in $processes) {
            $process | Stop-Process -Force
        }
    }
}

function Uninstall-VPNClient {
    $uninstaller_path = "C:\Program Files (x86)\WatchGuard\WatchGuard Mobile VPN with SSL\unins000.exe"
    if (Test-Path $uninstaller_path) {
        Start-Process -FilePath $uninstaller_path -ArgumentList "/S" -Wait -NoNewWindow
    }
}

function Remove-ResidualFiles {
    $remaining_files = @(
        "C:\Program Files\WatchGuard\Mobile VPN",
        "C:\Users\$script:LOGGED_IN_USER\AppData\Roaming\WatchGuard\Mobile VPN"
    )
    foreach ($file in $remaining_files) {
        if (Test-Path $file) {
            Remove-Item -Path $file -Recurse -Force
        }
    }
}

function Remove-ResidualRegistryKeys {
    $remaining_registry_keys = @(
        "HKCU:\Software\WatchGuard\SSLVPNClient\Settings",
        "HKCU:\Software\Microsoft\Windows\CurrentVersion\Run\WatchGuard Mobile VPN with SSL"
    )
    foreach ($key in $remaining_registry_keys) {
        if (Test-Path $key) {
            Remove-Item -Path $key -Force
        }
    }
}

function Install-VPNClient {
    New-Item -ItemType Directory -Path $script:TEMP_PATH -Force
    Invoke-WebRequest -Uri $script:WATCHGUARD_DOWNLOAD_URL -OutFile $script:WATCHGUARD_DOWNLOAD_PATH
    Start-Process -FilePath $script:WATCHGUARD_DOWNLOAD_PATH -ArgumentList "/verysilent" -Wait
    Remove-Item -Path $script:WATCHGUARD_DOWNLOAD_PATH -Force
}

function New-VPNClient {
    $use_public_ip_or_enter_ip = Read-Host "Enter an IP address or server name for the VPN, N to use current Public"
    $vpn_port = Read-Host "Enter VPN Port, or anything else to continue without a port"
    $username = Read-Host "Enter username or no to use logged in user as username."

    $vpn_ip = if ($use_public_ip_or_enter_ip -in @("N", "NO", "No", "nO", "n", "no")) { $script:PUBLIC_IP } else { $use_public_ip_or_enter_ip }
    if (-not [string]::IsNullOrWhiteSpace($vpn_port)) { $vpn_ip = "$vpn_ip`:$vpn_port" }

    $registry_values = @{
        'Server' = $vpn_ip
        'Username' = if ($username -in @("N", "NO", "no,", "No", "nO", "n")) { $script:LOGGED_IN_USER } else { $username }
    }
    
    foreach ($entry in $registry_values.GetEnumerator()) {
        Set-ItemProperty -Path $script:WATCHGUARD_REGISTRY_PATH -Name $entry.Key -Value $entry.Value -Type String
    }
}

function Set-DesktopShortcut {
    if (!(Test-Path "$script:DESKTOP_PATH\Mobile VPN with SSL client\Mobile VPN with SSL client.lnk")) {
        Copy-Item -Path $script:WATCHGUARD_SHORTCUT -Destination "$script:DESKTOP_PATH\$script:DOMAIN_NAME WatchGuard Mobile VPN.lnk"
    }
}

Stop-VPNProcesses
Uninstall-VPNClient
Remove-ResidualFiles
Remove-ResidualRegistryKeys
Install-VPNClient
New-VPNClient
Set-DesktopShortcut