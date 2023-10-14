$USE_PUBLIC_IP_OR_ENTER_IP = Read-Host "Enter an IP address or server name for the VPN, N to use current Public"
$VPN_PORT = Read-Host "Enter VPN Port, or anything else to continue without a port"
$USER_INPUT = Read-Host "Enter the username, or N/No/leave blank to use the current user"
$USERNAME = (Get-WmiObject -Class Win32_ComputerSystem | Select-Object -ExpandProperty UserName).Split('\')[1]
$PUBLIC_IP = (Invoke-WebRequest -Uri 'https://api.ipify.org?format=text').Content.Trim()
$WATCHGUARD_REGISTRY_PATH = "HKCU:\Software\WatchGuard\SSLVPNClient\Settings"

function Get-Username {
    if ($script:USER_INPUT -in @("N", "NO", "No", "nO", "n", "no", "", $null)) {
        return $script:USERNAME
    } elseif ($script:USER_INPUT -match '^[a-zA-Z0-9.-]+$') {
        return $script:USER_INPUT
    } else {
        Write-Host "Invalid input. Using current user."
        return $script:USERNAME
    }
}

function Set-VPNRegistryValues {
    $vpn_ip = Get-VPNIPAddress -ipOrName $script:USE_PUBLIC_IP_OR_ENTER_IP -vpnPort $script:VPN_PORT

    $registry_values = @{
        'Server' = $vpn_ip
        'Username' = $script:USERNAME
    }

    foreach ($entry in $registry_values.GetEnumerator()) {
        Set-ItemProperty -Path $script:WATCHGUARD_REGISTRY_PATH -Name $entry.Key -Value $entry.Value -Type String
    }
}

function Get-VPNIPAddress {
    param (
        [string]$ip_or_name,
        [string]$vpn_port
    )
    if ($ip_or_name -in @("N", "NO", "No", "nO", "n", "no", "", $null)) {
        return Confirm-ValidPort -ip $script:PUBLIC_IP -vpnPort $vpn_port
    } elseif ($ip_or_name -match '^[a-zA-Z0-9.-]+$') {
        return Confirm-ValidPort -ip $ip_or_name -vpnPort $vpn_port
    } else {
        Write-Host "Invalid input. Using current public IP address and port."
        return Confirm-ValidPort -ip $script:PUBLIC_IP -vpnPort $vpn_port
    }
}

function Confirm-ValidPort {
    param (
        [string]$ip,
        [string]$vpn_port
    )
    if ([string]::IsNullOrWhiteSpace($vpn_port) -or $vpn_port -match '^\d+$') {
        if ([string]::IsNullOrWhiteSpace($vpn_port)) {
            return $ip
        } else {
            return "$ip`:$vpn_port"
        }
    } else {
        Write-Host "Invalid VPN port. Using IP without port."
        return $ip
    }
}

Set-VPNRegistryValues
