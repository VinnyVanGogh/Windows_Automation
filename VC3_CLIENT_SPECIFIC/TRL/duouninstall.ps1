$vendorName = "Duo Security, Inc."
$applications = Get-WmiObject -Class Win32_Product | Where-Object { $_.Vendor -eq $vendorName }

if ($applications) {
    foreach ($application in $applications) {
        $application.Uninstall()
    }
}

$vendorName = "Duo Security, Inc."; Get-WmiObject -Class Win32_Product | Where-Object { $_.Vendor -eq $vendorName } | ForEach-Object { $_.Uninstall() }
