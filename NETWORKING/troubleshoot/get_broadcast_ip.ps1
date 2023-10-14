$IPCONFIG = Get-WmiObject -Class Win32_NetworkAdapterConfiguration -Filter "IPEnabled=TRUE" | Where-Object { $_.Description -like "*Ethernet*" } | Select-Object -First 1

function ConvertTo-BinaryString {
    param (
        [Parameter(Mandatory = $true)]
        [string]$ip
    )
    return ($ip -split '\.' | ForEach-Object { [Convert]::ToString($_, 2).PadLeft(8, '0') }) -join ''
}

function Get-InvertedSubnetBinary {
    param (
        [Parameter(Mandatory = $true)]
        [string]$subnet_binary
    )
    return $subnet_binary -replace '0', 'x' -replace '1', '0' -replace 'x', '1'
}

function Get-BroadcastBinary {
    param (
        [Parameter(Mandatory = $true)]
        [string]$ip_binary,
        [Parameter(Mandatory = $true)]
        [string]$inverted_subnet_binary
    )
    return [Convert]::ToString(([Convert]::ToInt32($ip_binary, 2) -bxor [Convert]::ToInt32($inverted_subnet_binary, 2)), 2).PadLeft(32, '0')
}

function ConvertTo-BroadcastAddress {
    param (
        [Parameter(Mandatory = $true)]
        [string]$broadcast_binary
    )
    return ((0..3) | ForEach-Object { [Convert]::ToByte($broadcast_binary.Substring($_ * 8, 8), 2) }) -join '.'
}

function Get-BroadcastAddress {
    param (
        [Parameter(Mandatory = $true)]
        $ipconfig
    )
    $ip_address = $ipconfig.IPAddress[0]
    $subnet_mask = $ipconfig.IPSubnet[0]

    $ip_binary = ConvertTo-BinaryString -ip $ip_address
    $subnet_binary = ConvertTo-BinaryString -ip $subnet_mask

    $inverted_subnet_binary = Calculate-InvertedSubnetBinary -subnet_binary $subnet_binary

    $broadcast_binary = Calculate-BroadcastBinary -ip_binary $ip_binary -inverted_subnet_binary $inverted_subnet_binary

    return ConvertTo-BroadcastAddress -broadcast_binary $broadcast_binary
}

Get-BroadcastAddress -ipconfig $IPCONFIG
