$ETHERNET_ALIAS = 'Ethernet'

function Test-IPVersionEnabled {
    param (
        [Parameter(Mandatory = $true)]
        [string]$interface_alias,
        [Parameter(Mandatory = $true)]
        [string]$address_family
    )
    return Get-NetIPInterface | Where-Object { $_.InterfaceAlias -eq $interface_alias -and $_.AddressFamily -eq $address_family -and $_.Dhcp -eq 'Enabled' }
}

function Set-IPv4 {
    param (
        [Parameter(Mandatory = $true)]
        [object]$adapter
    )
    $ipv4_interface_index = $adapter | Get-NetIPInterface -AddressFamily IPv4 | Select-Object -ExpandProperty InterfaceIndex
    $ipv4_interface_index | ForEach-Object { Invoke-Expression "netsh interface ip set address $_ dhcp" }
    $adapter | Restart-NetAdapter
    Clear-DnsClientCache
}

function Show-IPInfo {
    param (
        [Parameter(Mandatory = $true)]
        [object]$ip_info,
        [Parameter(Mandatory = $true)]
        [string]$address_family
    )
    $dns_servers = (Get-DnsClientServerAddress -AddressFamily $address_family).ServerAddresses
    Write-Host "$address_family Enabled with DHCP"
    Write-Host "$address_family Address: $($ip_info.IPAddress)"
    Write-Host "Subnet Mask: $($ip_info.PrefixLength)"
    Write-Host "Default Gateway: $($ip_info.DefaultGateway)"
    Write-Host "DNS Servers: $($dns_servers -join ', ')"
}

$ipv4_enabled = Test-IPVersionEnabled -interface_alias $ETHERNET_ALIAS -address_family 'IPv4'
$ipv6_enabled = Test-IPVersionEnabled -interface_alias $ETHERNET_ALIAS -address_family 'IPv6'

if ($ipv4_enabled) {
    Disable-NetAdapterBinding -InterfaceAlias $ETHERNET_ALIAS -ComponentID 'ms_tcpip6' -PassThru | Out-Null
    $adapter = Get-NetAdapter -InterfaceAlias $ETHERNET_ALIAS
    Set-IPv4 -adapter $adapter
    $ipv4_info = Get-NetIPAddress -AddressFamily IPv4 | Where-Object { $_.InterfaceAlias -eq $ETHERNET_ALIAS }
    Show-IPInfo -ip_info $ipv4_info -address_family 'IPv4'
} else {
    Write-Host "IPv4 is not enabled with DHCP"
}

if ($ipv6_enabled) {
    $ipv6_info = Get-NetIPAddress -AddressFamily IPv6 | Where-Object { $_.InterfaceAlias -eq $ETHERNET_ALIAS }
    Show-IPInfo -ip_info $ipv6_info -address_family 'IPv6'
} else {
    Write-Host "IPv6 is not enabled with DHCP"
}
