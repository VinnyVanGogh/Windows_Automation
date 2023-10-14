$VENDOR_NAME = "ScreenConnect Software"

function Uninstall-VendorApplications {
    $applications = Get-WmiObject -Class Win32_Product | Where-Object {$_.Vendor -eq $script:VENDOR_NAME}
    foreach ($application in $applications) {
        $app_name = $application.Name
        $uninstall_result = $application.Uninstall()
        
        if ($uninstall_result.ReturnValue -eq 0) {
            Write-Host "Uninstalled application: $app_name"
        } else {
            Write-Host "Failed to uninstall application: $app_name. Error code: $($uninstall_result.ReturnValue)"
        }
    }
}

Uninstall-VendorApplications
