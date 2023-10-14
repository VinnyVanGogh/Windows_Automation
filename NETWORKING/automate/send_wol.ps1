$IPCONFIG = Get-WmiObject -Class Win32_NetworkAdapterConfiguration -Filter "IPEnabled=TRUE" | Where-Object { $_.Description -like "*Ethernet*" } | Select-Object -First 1
$PROMPT = Read-Host "Enter MAC address or IP address"
$TARGET_PORT = 9

function Get-Parameters {
  param (
      [Parameter(Mandatory = $true)]
      [string]$PROMPT
  )
  
  $ip_pattern = '^\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3}$'
  $mac_pattern = '^([0-9A-Fa-f]{2}[:-]){5}([0-9A-Fa-f]{2})$'

  if ($PROMPT -match $ip_pattern) {
      $mac_address = Get-MACAddress -host_or_ip $PROMPT
  } elseif ($PROMPT -match $mac_pattern) {
      $mac_address = $PROMPT
  } else {
      Write-Host "Invalid input. Please enter a valid IP or MAC address."
      return $null
  }

  $mac_address = $mac_address -replace "[:-]", ""

  return $mac_address
}

function Get-MACAddress {
  param (
      [Parameter(Mandatory = $true)]
      [string]$host_or_ip
  )

  $resolved_ip = [System.Net.Dns]::GetHostAddresses($host_or_ip) | Where-Object { $_.AddressFamily -eq 'InterNetwork' } | Select-Object -ExpandProperty IPAddressToString -First 1

  $arp_output = arp -a $resolved_ip
  $arp_line = ($arp_output -split "`n") | Where-Object { $_ -match $resolved_ip }
  $mac_address = ($arp_line -split '\s+')[3]

  return $mac_address
}

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

$BROADCAST_IP = Get-BroadcastAddress -ipconfig $IPCONFIG

function ConvertTo-ByteArray {
    param (
        [Parameter(Mandatory = $true)]
        [string]$mac_address
    )
    return $mac_address -split "[:-]" | ForEach-Object { [Byte] "0x$_"}
}

function New-WOLPacket {
    param (
        [Parameter(Mandatory = $true)]
        [Byte[]]$mac_byte_array
    )
    return (,[Byte]0xFF * 6) + ($mac_byte_array * 16)
}

function Set-WOLPacket {
    param (
        [Parameter(Mandatory = $true)]
        [Byte[]]$packet,
        [Parameter(Mandatory = $true)]
        [string]$target_ip,
        [Parameter(Mandatory = $true)]
        [int]$target_port
    )
    $udp_client = New-Object System.Net.Sockets.UdpClient
    $udp_client.EnableBroadcast = $true
    $udp_client.Send($packet, $packet.Length, $target_ip, $target_port)
}

function Send-WOLPacket {
  $mac_byte_array = ConvertTo-ByteArray -mac_address $MAC_ADDRESS
  $wol_packet = New-WOLPacket -mac_byte_array $mac_byte_array
  Set-WOLPacket -packet $wol_packet -target_ip $BROADCAST_IP -target_port $TARGET_PORT
}

Send-WOLPacket