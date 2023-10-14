Import-Module ActiveDirectory
Import-Module AzureAD

$computerName = $env:ComputerName
$domainName = $env:UserDomain
$date = Get-Date
$folderName = $computerName + "-" + $date.ToString("yyyy.MM.dd")
$csvOutputPath = "C:\VC3\Refresh\$domainName\$folderName"
$csvFilePath = Join-Path $csvOutputPath "ADUsers.csv"
$credentials = Get-Credential
Connect-AzureAD -Credential $credentials

if (!(Test-Path -Path $csvOutputPath)) {
    New-Item -ItemType Directory -Force -Path $csvOutputPath
}

function Get-ADUsersAndGroups {
    [CmdletBinding()]
    param (
        [Parameter()]
        [ValidateScript({Test-Path $_ -PathType 'Container'})]
        [string]$OutputFolderPath = 'C:\VC3\Refresh',
        
        [Parameter()]
        [string]$DomainName = $env:UserDomain
    )

    $users = Get-ADUser -Filter * -Properties Enabled, PasswordNeverExpires, PasswordLastSet, PasswordExpired, LockedOut, BadPwdCount, Created, Modified, MemberOf, Manager, DirectReports, Department, Title, Office, EmailAddress, EmployeeID, GivenName, Surname, DisplayName, Description, ProxyAddresses

    $auditData = foreach ($user in $users) {
        $accountStatus = if ($user.Enabled -eq $true) { "Enabled" } else { "Disabled" }
        $passwordNeverExpires = if ($user.PasswordNeverExpires -eq $true) { "Yes" } else { "No" }
        $passwordExpired = if ($user.PasswordExpired -eq $true) { "Yes" } else { "No" }
        $accountLockoutStatus = if ($user.LockedOut -eq $true) { "Locked" } else { "Not Locked" }



        $userPrincipalName = $user.UserPrincipalName

        try {
            $licenses = (Get-AzureADUser -Filter "UserPrincipalName eq '$userPrincipalName'").AssignedLicenses
        }
        catch {
            Write-Host "Error retrieving licenses for user: $userPrincipalName"
            $licenses = @()
        }

        $assignedLicenses = $licenses | ForEach-Object {
            $disabledPlans = $_.DisabledPlans
            $skuId = $_.SkuId

            $licenseName = (Get-AzureADSubscribedSku | Where-Object { $_.SkuId -eq $skuId }).SkuPartNumber

            [PSCustomObject]@{
                'SkuId' = $skuId
                'LicenseName' = $licenseName
                'DisabledPlans' = $disabledPlans -join ', '
            }
        }

        $auditInfo = [PSCustomObject]@{
            'Username' = $user.SamAccountName
            'Given Name' = $user.GivenName
            'Surname' = $user.Surname
            'License' = ($assignedLicenses | Select-Object -ExpandProperty LicenseName -Unique) -join ', '
            'Proxy Addresses' = $user.ProxyAddresses -join ', '
            'Roles and Groups' = ($user.MemberOf | Get-ADGroup | Select-Object -ExpandProperty Name) -join ', '
            'Description' = $user.Description
            'Created Date' = $user.Created
            'Modified Date' = $user.Modified
            'Password Last Set' = $user.PasswordLastSet
            'Password Never Expires' = $passwordNeverExpires
            'Account Status' = $accountStatus
            'Password Expired' = $passwordExpired
            'Account Lockout Status' = $accountLockoutStatus
            'Failed Login Attempts' = $user.BadPwdCount
        }

        $auditInfo
    }

    $auditData | Export-Csv -Path $csvFilePath -NoTypeInformation

    Write-Output "User audit information has been exported to $csvFilePath"
}

Get-ADUsersAndGroups -OutputFolderPath $csvOutputPath -DomainName $domainName
