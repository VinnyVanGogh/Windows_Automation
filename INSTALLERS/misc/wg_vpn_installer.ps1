$USE_PUBLIC_IP_OR_ENTER_IP = Read-Host "Enter an IP address or server name for the VPN, N to use current Public"
$VPN_PORT = Read-Host "Enter VPN Port, or anything else to continue without a port"
$USER_INPUT = Read-Host "Enter username or no/leave blank to use logged in user as username."
$LOGGED_IN_USER = (Get-WmiObject -Class Win32_ComputerSystem | Select-Object -ExpandProperty UserName).Split('\')[1]
$PUBLIC_IP = (Invoke-WebRequest -Uri 'https://api.ipify.org?format=text').Content.Trim()
$WATCHGUARD_REGISTRY_PATH = "HKCU:\Software\WatchGuard\SSLVPNClient\Settings"
$DOMAIN_NAME = $ENV:UserDomain
$TEMP_PATH = "C:\Users\$LOGGED_IN_USER\Temp"
$DESKTOP_PATH = "C:\Users\$LOGGED_IN_USER\Desktop"
$WATCHGUARD_DOWNLOAD_URL = 'https://cdn.watchguard.com/SoftwareCenter/Files/MUVPN_SSL/12_7_2/WG-MVPN-SSL_12_7_2.exe'
$WATCHGUARD_DOWNLOAD_PATH = "$TEMP_PATH\WatchguardMobileVPNInstallerAutomatedbyVinny.exe"
$WATCHGUARD_SHORTCUT = 'C:\ProgramData\Microsoft\Windows\Start Menu\Programs\WatchGuard\Mobile VPN with SSL client\Mobile VPN with SSL client.lnk'

function Initialize-TempDirectory {
    New-Item -ItemType Directory -Path $script:TEMP_PATH -Force
}

function New-VPNClient {
    Invoke-WebRequest -Uri $script:WATCHGUARD_DOWNLOAD_URL -OutFile $script:WATCHGUARD_DOWNLOAD_PATH
    Start-Process -FilePath "$script:WATCHGUARD_DOWNLOAD_PATH" -ArgumentList "/verysilent" -Wait
}

function Set-DesktopShortcut {
    if (!(Test-Path "$script:DESKTOP_PATH\Mobile VPN with SSL client\Mobile VPN with SSL client.lnk")) {
        Copy-Item -Path $script:WATCHGUARD_SHORTCUT -Destination "$script:DESKTOP_PATH\$script:DOMAIN_NAME WatchGuard Mobile VPN.lnk"
    }
}

function Remove-InstallationFiles {
    Remove-Item -Path $script:WATCHGUARD_DOWNLOAD_PATH -Force
}

function Set-VPNRegistryValues {
    $username = if ($script:USER_INPUT -in @("N", "NO", "no,", "No", "nO", "n", $null)) {
                    $script:LOGGED_IN_USER
                } else {
                    $script:USER_INPUT
                }
                
    $vpn_ip = if ($script:USE_PUBLIC_IP_OR_ENTER_IP -in @("N", "NO", "No", "nO", "n", "no", $null)) {
                    $script:PUBLIC_IP
                } elseif ($script:USE_PUBLIC_IP_OR_ENTER_IP -match '^[a-zA-Z0-9.-]+$') {
                    $script:USE_PUBLIC_IP_OR_ENTER_IP
                } else {
                    $script:PUBLIC_IP
                }
    if (-not [string]::IsNullOrWhiteSpace($script:VPN_PORT)) {
        $vpn_ip = "$vpn_ip`:$script:VPN_PORT"
    }

    $registry_values = @{
        'Server' = $vpn_ip
        'Username' = $username
    }
    
    foreach ($entry in $registry_values.GetEnumerator()) {
        Set-ItemProperty -Path $script:WATCHGUARD_REGISTRY_PATH -Name $entry.Key -Value $entry.Value -Type String
    }
}

Initialize-TempDirectory
New-VPNClient
Set-DesktopShortcut
Remove-InstallationFiles
Set-VPNRegistryValues
