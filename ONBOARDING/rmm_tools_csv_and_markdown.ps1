<#
RMM Tools:
- NinjaRMM, Atera, Datto RMM, Datto Windows Agent, Continuum, Kaseya, Syxsense, LabTech, ConnectWise, Pulseway, Syncro, Panorama9, Maxfocus, ManageEngine:
  - Searchable by: Installation directories, Registry keys (under HKLM\Software or HKLM\Software\WOW6432Node), WMI queries for specific services or processes.

Remote Desktop Apps:
- TeamViewer, AnyDesk, Splashtop, Zoho, VNC, BeyondTrust, RemotePC Host, LogMeIn, GoToMyPC:
  - Searchable by: Installation directories, Registry keys (under HKLM\Software or HKLM\Software\WOW6432Node), WMI queries for specific services or processes.

Note: These methods may vary between different versions and installations of the software, and some vendors may use techniques to make detection more complex.
#>

$current_date = Get-Date -Format "MM.dd.yyyy"
$vc3_folder_path = "C:\VC3"
$csv_file_prefix = "RMM_Tools"
$csv_filename = Join-Path -Path $vc3_folder_path -ChildPath ($csv_file_prefix + $current_date + ".csv")

if (!(Test-Path -Path $vc3_folder_path)) {
    New-Item -ItemType Directory -Force -Path $vc3_folder_path
}

$rmm_tool_vendors = @(
    "TeamViewer GmbH",
    "LogMeIn, Inc.",
    "TeamViewer",
    "RealVNC Ltd",
    "SolarWinds Worldwide, LLC.",
    "Kaseya",
    "ConnectWise",
    "ScreenConnect",
    "SolarWinds",
    "SolarWinds MSP",
    "MspPlatform",
    "N-Able",
    "N-Able Technologies",
    "ScreenConnect Software",
    "Mikogo",
    "Zoho Corporation",
    "Remote Utilities LLC",
    "BeyondTrust",
    "AnyDesk Software GmbH",
    "NinjaRMM",
    "Pulseway",
    "Atera Networks Ltd.",
    "Naverisk",
    "Zoho Corporation",
    "SysAid Technologies Ltd.",
    "SolarWinds N-able",
    "ConnectWise, Inc."
)

function Get-InstalledSoftware {
    param (
        [array]$rmm_tool_vendors
    )

    $wmi_software = Get-WmiObject -Class Win32_Product | ForEach-Object {
        New-Object PSObject -Property @{
            'Software Name' = $_.Name
            'Software Vendor' = $_.Vendor
            'GUID (Globally Unique Identifier)' = $_.IdentifyingNumber
            'Date of Installation' = if ($_.InstallDate -match '^\d{8}$') {[DateTime]::ParseExact($_.InstallDate, 'yyyyMMdd', $null).ToString('yyyy.MM.dd')} else {''}        }
    }

    $registry_64_bit_entries = Get-ItemProperty HKLM:\Software\Microsoft\Windows\CurrentVersion\Uninstall\* | 
    Where-Object { $_.UninstallString } | ForEach-Object {
        New-Object PSObject -Property @{
            'Software Name' = $_.DisplayName
            'Software Vendor' = $_.Publisher
            'Uninstallation ID' = $_.UninstallString
            'Date of Installation' = if ($_.InstallDate -match '^\d{8}$') {[DateTime]::ParseExact($_.InstallDate, 'yyyyMMdd', $null).ToString('yyyy.MM.dd')} else {''}        }
    }

    $registry_32_bit_entries = Get-ItemProperty HKLM:\Software\Wow6432Node\Microsoft\Windows\CurrentVersion\Uninstall\* |
    Where-Object { $_.UninstallString } | ForEach-Object {
        New-Object PSObject -Property @{
            'Software Name' = $_.DisplayName
            'Software Vendor' = $_.Publisher
            'Uninstallation ID' = $_.UninstallString
            'Date of Installation' = if ($_.InstallDate -match '^\d{8}$') {[DateTime]::ParseExact($_.InstallDate, 'yyyyMMdd', $null).ToString('yyyy.MM.dd')} else {''}        }
    }


    $detected_rmm_tools = @()

    foreach ($vendor in $rmm_tool_vendors) {
        $filtered_wmi_software = $wmi_software | Where-Object { $_.'Software Vendor' -like "*$vendor*" }
        $filtered_reg_64_bit_software = $registry_64_bit_entries | Where-Object { $_.'Software Vendor' -like "*$vendor*" }
        $filtered_reg_32_bit_software = $registry_32_bit_entries | Where-Object { $_.'Software Vendor' -like "*$vendor*" }
    
        $filtered_wmi_software | ForEach-Object { $detected_rmm_tools += $_ }
        $filtered_reg_64_bit_software | ForEach-Object { $detected_rmm_tools += $_ }
        $filtered_reg_32_bit_software | ForEach-Object { $detected_rmm_tools += $_ }
    }
    $markdown_output = @()
    $markdown_output += "## RMM Tools`r`n"
    $markdown_output += "- WMI Reg 64, and 32 Bit RMM Software`r`n" + ($detected_rmm_tools | ForEach-Object {"    - Application: " + $_.'Software Name' + "`r`n" + "        - Uninstall String: " + $_.'Uninstallation ID' + "`r`n"}) -join "`r`n- "

    $markdown_output | Write-Output | Set-Clipboard
    return $detected_rmm_tools
}

$csv_output = Get-InstalledSoftware -rmm_tool_vendors $rmm_tool_vendors
$csv_output | ForEach-Object {
    $line = $_.'Software Name' + ',' + $_.'Software Vendor' + ',' + $_.'Uninstallation ID' + ',' + $_.'Date of Installation'
    Add-Content -Path $csv_filename -Value $line
}