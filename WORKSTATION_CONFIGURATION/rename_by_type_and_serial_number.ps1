# Rename computers by their serial name and if they're a desktop or laptop
$serial_number = (Get-WmiObject -Class Win32_BIOS).SerialNumber
$system_type = (Get-WmiObject -Class Win32_ComputerSystem).PCSystemType

$sanitized_serial = $serial_number -replace '[^\w\d]', ''

$sanitized_serial = $sanitized_serial.Substring(0, [Math]::Min(9, $sanitized_serial.Length))

$prefix = if ($system_type -eq 2) { "LT" } else { "DT" }

$new_computer_name = "$prefix-$sanitized_serial"

Rename-Computer -NewName $new_computer_name -Force