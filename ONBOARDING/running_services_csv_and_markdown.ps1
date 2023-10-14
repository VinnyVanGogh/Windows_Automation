$current_date = Get-Date -Format "MM.dd.yyyy"
$vc3_folder_path = "C:\VC3"
$csv_filename = Join-Path -Path $vc3_folder_path -ChildPath ("ServicesInfo" + $current_date + ".csv")

if (!(Test-Path -Path $vc3_folder_path)) {
    New-Item -ItemType Directory -Force -Path $vc3_folder_path
}

function CreateServiceObject($service) {
    $status = $service.State
    $name = $service.Name
    $account = $service.StartName
    $start_mode = $service.StartMode
    if ($null -eq $account) {
        if ($name -match '_\d+$') {
            $account = 'User-specific grouped service account'
        } else {
            $account = 'Virtual service account'
        }
    }

    if ($account -eq 'Virtual service account') {
        return $null
    }

    return New-Object PSObject -Property @{
        "Service Name" = $name
        "Service Account" = $account
        "Current Status" = $status
        "Startup Type" = $start_mode
    }
}

function Get-NonSystemServices {
    $exclude_accounts = @('LocalSystem', 'LocalService', 'NetworkService', 'NT AUTHORITY\LocalSystem', 'NT AUTHORITY\LocalService', 'NT AUTHORITY\NetworkService')
    $service_accounts = Get-WmiObject -Class Win32_Service | Where-Object { $_.StartName -notin $exclude_accounts }

    $results = @()
    if($service_accounts){
        foreach ($service in $service_accounts) {
            $temporary_results = @()
            $temporary_results += CreateServiceObject($service)
            if ($null -ne $temporary_results) {
                $results += $temporary_results
            }
        }
    } else {
        $results += "No service_accounts found"
    }

    return $results
}

function Get-ServicesRunningAsAdmin {
    $service_accounts = Get-WmiObject -Class Win32_Service | Where-Object { $_.StartName -like "*admin*" }

    $results = @()
    if($service_accounts){
        foreach ($service in $service_accounts) {
            $temporary_results = @()
            $temporary_results += CreateServiceObject($service)
            if ($null -ne $temporary_results) {
                $results += $temporary_results
            }
        }
    } else {
        $results += "No service_accounts found"
    }

    return $results
}

function Get-ServicesWithState($state) {
    $service_accounts = Get-WmiObject -Class Win32_Service | Where-Object { $_.State -eq $state }

    $results = @()
    if($service_accounts){
        foreach ($service in $service_accounts) {
            $temporary_results = @()
            $temporary_results += CreateServiceObject($service)
            if ($null -ne $temporary_results) {
                $results += $temporary_results
            }
        }
    } else {
        $results += "No service_accounts found"
    }

    return $results
}

function Get-AllServices {
    $service_accounts = Get-WmiObject -Class Win32_Service

    $results = @()
    if($service_accounts){
        foreach ($service in $service_accounts) {
            $temporary_results = @()
            $temporary_results += CreateServiceObject($service)
            if ($null -ne $temporary_results) {
                $results += $temporary_results
            }
        }
    } else {
        $results += "No service_accounts found"
    }

    return $results
}

$non_system_services = Get-NonSystemServices
$services_running_as_admin = Get-ServicesRunningAsAdmin
$running_services = Get-ServicesWithState('Running')
$stopped_services = Get-ServicesWithState('Stopped')
$all_services = Get-AllServices

$markdown_output = "## Services Information`r`n"

$markdown_output += "### Non-System Services`r`n"
$non_system_services | Where-Object { $_ -ne $null } | ForEach-Object {
    $markdown_output += "- " + $_."Service Name" + "`r`n"
    $markdown_output += "    - Account: " + $_."Service Account" + "`r`n"
    $markdown_output += "    - Status: " + $_."Current Status" + "`r`n"
    $markdown_output += "    - Startup Type: " + $_."Startup Type" + "`r`n"    
}

$markdown_output += "### Services Running as Admin`r`n"
$services_running_as_admin | Where-Object { $_ -ne $null } | ForEach-Object {
    $markdown_output += "- " + $_."Service Name" + "`r`n"
    $markdown_output += "    - Account: " + $_."Service Account" + "`r`n"
    $markdown_output += "    - Status: " + $_."Current Status" + "`r`n"
    $markdown_output += "    - Startup Type: " + $_."Startup Type" + "`r`n"    
}

$markdown_output += "### Running Services`r`n"
$running_services | Where-Object { $_ -ne $null } | ForEach-Object {
    $markdown_output += "- " + $_."Service Name" + "`r`n"
    $markdown_output += "    - Account: " + $_."Service Account" + "`r`n"
    $markdown_output += "    - Status: " + $_."Current Status" + "`r`n"
    $markdown_output += "    - Startup Type: " + $_."Startup Type" + "`r`n"    
}

$markdown_output += "### Stopped Services`r`n"
$stopped_services | Where-Object { $_ -ne $null } | ForEach-Object {
    $markdown_output += "- " + $_."Service Name" + "`r`n"
    $markdown_output += "    - Account: " + $_."Service Account" + "`r`n"
    $markdown_output += "    - Status: " + $_."Current Status" + "`r`n"
    $markdown_output += "    - Startup Type: " + $_."Startup Type" + "`r`n"    
}

$markdown_output += "### All Services`r`n"
$all_services | Where-Object { $_ -ne $null } | ForEach-Object {
    $markdown_output += "- " + $_."Service Name" + "`r`n"
    $markdown_output += "    - Account: " + $_."Service Account" + "`r`n"
    $markdown_output += "    - Status: " + $_."Current Status" + "`r`n"
    $markdown_output += "    - Startup Type: " + $_."Startup Type" + "`r`n"    
}

$markdown_output | Write-Output | Set-Clipboard

$all_data = ($non_system_services + $services_running_as_admin + $running_services + $stopped_services + $all_services) | Where-Object { $_ -ne $null }
$all_data | Export-Csv -Path $csv_filename -NoTypeInformation