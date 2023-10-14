Import-Module AzureAD

$computer_name = $env:ComputerName
$domain_name = $env:UserDomain
$date = Get-Date
$folder_name = "$computer_name-" + $date.ToString("yyyy.MM.dd")
$csv_output_path = "C:\VC3\Refresh\$domain_name\$folder_name"
$csv_file_path = Join-Path $csv_output_path "AzureADUsers.csv"

$credentials = Get-Credential
Connect-AzureAD -Credential $credentials

if (!(Test-Path -Path $csv_output_path)) {
    New-Item -ItemType Directory -Force -Path $csv_output_path
}

function Get-AzureADUsersAndGroups {
    [CmdletBinding()]
    param (
        [Parameter()]
        [ValidateScript({Test-Path $_ -PathType 'Container'})]
        [string]$output_folder_path = 'C:\VC3\Refresh',
        
        [Parameter()]
        [string]$domain_name = $env:UserDomain
    )

    $users = Get-AzureADUser -All $true

    $audit_data = @()

    foreach ($user in $users) {
        $licenses = $user.AssignedPlans | Where-Object { $_.CapabilityStatus -eq 'Enabled' } | Select-Object -ExpandProperty CapabilityStatus

        $audit_info = [PSCustomObject]@{
            'Username' = $user.UserPrincipalName
            'DisplayName' = $user.DisplayName
            'License' = ($licenses -join ', ')
            'Created Date' = $user.CreatedDateTime
            'Account Status' = if ($user.AccountEnabled) { 'Enabled' } else { 'Disabled' }
        }

        $audit_data += $audit_info
    }

    $audit_data | Export-Csv -Path $csv_file_path -NoTypeInformation

    Write-Output "User audit information has been exported to $csv_file_path"
}

Get-AzureADUsersAndGroups -OutputFolderPath $csv_output_path -DomainName $domain_name
