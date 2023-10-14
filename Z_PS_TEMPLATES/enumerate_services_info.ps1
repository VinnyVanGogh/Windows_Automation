$current_date = Get-Date -Format "MM.dd.yyyy"
$vc3_folder_path = "C:\VC3"
$csv_filename = Join-Path -Path $vc3_folder_path -ChildPath ("ServicesInfo" + $current_date + ".csv")
$non_system_filter = { $_.State -eq "Running" -and ($_.StartName -notlike "NT AUTHORITY\*" -and $_.StartName -notlike "LocalSystem") }
$admin_filter = { $_.State -eq "Running" -and $_.StartName -match "admin" }
$running_filter = { $_.State -eq "Running" }
$stopped_filter = { $_.State -eq "Stopped" }

$directory_params = @{
    Path = $vc3_folder_path
    ItemType = "Directory"
    Force = $true
}

$script_params = @{
    Class = 'Win32_Service'
}

if (!(Test-Path -Path $vc3_folder_path)) {
    New-Item @directory_params
}

function Get-ServicesWithFilters {
    param (
        [string]$state = "",
        [string]$account_filter = ""
    )

    $service_accounts = Get-WmiObject -Class Win32_Service | Where-Object { $_.State -eq $state -and $_.StartName -like $account_filter }

    $results = New-Object System.Collections.ArrayList

    if ($service_accounts) {
        foreach ($service in $service_accounts) {
            $results.Add((Format-ServiceObject($service))) | Out-Null
        }
    } else {
        $results.Add("No service_accounts found") | Out-Null
    }

    return $results
}

function Format-ServiceObject($service) {
    $account = $service.StartName
    if ($null -eq $account) {
        $account = if ($service.Name -match '_\d+$') {
            'User-specific grouped service account'
        } else {
            'Virtual service account'
        }
    }

    return [PSCustomObject]@{
        "Service Name" = $service.Name
        "Service Account" = $account
        "Current Status" = $service.State
        "Startup Type" = $service.StartMode
    }
}


function Search-ServicesWithFilters{
    param (
        [string]$state = "",
        [string]$account_filter = ""
    )
    $non_system_services = Get-WmiObject @script_params | Where-Object $non_system_filter
    $services_running_as_admin = Get-WmiObject @script_params | Where-Object $admin_filter
    $running_services = Get-WmiObject @script_params | Where-Object $running_filter
    $stopped_services = Get-WmiObject @script_params | Where-Object $stopped_filter
    $all_services = Get-WmiObject @script_params

    $service_sections = @{
        "Non-System Services" = $non_system_services
        "Services Running as Admin" = $services_running_as_admin
        "Running Services" = $running_services
        "Stopped Services" = $stopped_services
        "All Services" = $all_services
    }
    return $service_sections, $all_services
}

function Format-InMarkdown {
    param (
        [hashtable]$service_sections
    )
        $service_counts = @{}
        foreach ($service_section in $service_sections.GetEnumerator()) {
            $counter = 0
            $services_output = $service_section.Value | ForEach-Object {
                Format-ServiceObject $_
                $counter += 1
            }
            $markdown_output += "### $($service_section.Key) - $counter`r`n"
            $markdown_output += "| Service Name | Service Account | Current Status | Startup Type |`r`n"
            $markdown_output += "|--------------|-----------------|----------------|--------------|`r`n"
            
            $services_output | ForEach-Object {
                $markdown_output += "| $($_.'Service Name') | $($_.'Service Account') | $($_.'Current Status') | $($_.'Startup Type') |`r`n"
            }

            
            $markdown_output += "`r`n`r`n"
            $markdown_output += "Total services found for $($service_section.Key): $counter`r`n`r`n"
            $markdown_output += "- [Follow me back up top](#quick-links)`r`n`r`n"

            $service_counts[$service_section.Key] = $counter
        }
    $final_markdown_output += "---`r`n Info on Various Services`r`n---`r`n`r`n"
    $final_markdown_output = "Total services found: $($service_counts['All Services'])`r`n"
    $final_markdown_output += "Total non-system services found: $($service_counts['Non-System Services'])`r`nTotal services running as admin found: $($service_counts['Services Running as Admin'])`r`nTotal running services found: $($service_counts['Running Services'])`r`nTotal stopped services found: $($service_counts['Stopped Services'])`r`n`r`n"
    $final_markdown_output += $markdown_output
    $final_markdown_output | Write-Output | Set-Clipboard
}


function Publish-CsvToVc3Directory{
    param (
        [string]$csv_filename,
        [array]$all_services
    )
    $final_csv_data = $($all_services) | Where-Object { $_ -ne $null }
    $final_csv_data | Export-Csv -Path $csv_filename -NoTypeInformation
}

$service_sections, $all_services = Search-ServicesWithFilters
Publish-CsvToVc3Directory -csv_filename $csv_filename -all_services $all_services
Format-InMarkdown -service_sections $service_sections