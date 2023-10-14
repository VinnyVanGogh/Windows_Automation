# This script helps explore and gather information about the IPv4 and IPv6 DNS servers configured on a machine #
    ## created by vinny vasile - 6.14.23 ##
        ### Get DNS Server Addresses of Local Machine ###
    ## Display IPv4 DNS Information & Perform IPv4 DNS Traceroute ##
        ### Display IPv6 DNS Information & Perform IPv6 DNS Traceroute ###
$dnsClient = Get-DnsClientServerAddress

if ($dnsClient) {
    $ipAddresses = $dnsClient.ServerAddresses

    $ipv4Addresses = $ipAddresses | Where-Object { ($_ -as [IPAddress]) -and ($_ -as [IPAddress]).AddressFamily -eq 'InterNetwork' }
    $ipv6Addresses = $ipAddresses | Where-Object { ($_ -as [IPAddress]) -and ($_ -as [IPAddress]).AddressFamily -eq 'InterNetworkV6' }

    if ($ipv4Addresses) {
        Write-Host "IPv4 DNS Info:"
        Write-Host "IPv4 protocol is enabled on the machine."
        foreach ($ipv4 in $ipv4Addresses) {
            Write-Host $ipv4
            Test-Connection -IPAddress $ipv4 -Count 4
        }

        Write-Host "IPv4 DNS Traceroute:"
        foreach ($ipv4 in $ipv4Addresses) {
            Test-NetConnection -ComputerName $ipv4 -Traceroute
        }
    } else {
        Write-Host "IPv4 protocol is not enabled or no IPv4 DNS servers configured on the machine."
    }

    if ($ipv6Addresses) {
        Write-Host "IPv6 DNS Info:"
        Write-Host "IPv6 protocol is enabled on the machine."
        foreach ($ipv6 in $ipv6Addresses) {
            Write-Host $ipv6
        }

        Write-Host "IPv6 DNS Traceroute:"
        foreach ($ipv6 in $ipv6Addresses) {
            Test-NetConnection -ComputerName $ipv6 -Traceroute
        }
    } else {
        Write-Host "IPv6 protocol is not enabled or no IPv6 DNS servers configured on the machine."
    }
} else {
    Write-Host "No DNS servers configured on the machine."
}