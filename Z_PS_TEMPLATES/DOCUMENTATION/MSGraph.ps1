$exampleUserPrincipalName = 'aTestUserIdk@vinny-van-gogh.com'
$exampleUserPrincipalNameTwo = 'VinceVasile@vinny-van-gogh.com'

# Try to import or install the module
try {
    Import-Module Microsoft.Graph -ErrorAction Stop
} catch {
    Install-Module -Name Microsoft.Graph -Scope AllUsers -Force -ErrorAction Stop
} 
try {
    Connect-MgGraph -Scopes User.ReadWrite.All, Organization.Read.All -ErrorAction Stop
} catch {
    Write-Host "Unable to connect to Microsoft Graph." -ForegroundColor Red
    exit
}
Write-Host "Successfully connected to Microsoft Graph." -ForegroundColor Green

# Find Unlicensed accounts
Get-MgUser -Filter 'assignedLicenses/$count eq 0' -ConsistencyLevel eventual -CountVariable unlicensedUserCount -All

# To find the unlicensed synchronized users in your organization
Get-MgUser -Filter 'assignedLicenses/$count eq 0 and OnPremisesSyncEnabled eq true' -ConsistencyLevel eventual -CountVariable unlicensedUserCount -All -Select UserPrincipalName

# To find accounts that don't have a UsageLocation value
Get-MgUser -Select Id,DisplayName,Mail,UserPrincipalName,UsageLocation,UserType | where { $_.UsageLocation -eq $null -and $_.UserType -eq 'Member' }

# To set the UsageLocation value on an account
# Example #
# Update-MgUser -UserId "$exampleUserPrincipalName@vinny-van-gogh.com" -UsageLocation US #
$userUPN="<user sign-in name (UPN)>"
$userLoc="<ISO 3166-1 alpha-2 country code>"

Update-MgUser -UserId $userUPN -UsageLocation $userLoc

# To assign a license to a user,
Set-MgUserLicense -UserId $userUPN -AddLicenses @{SkuId = "<SkuId>"} -RemoveLicenses @()

# This example assigns a license from the SPE_E5 (Microsoft 365 E5) licensing plan to the unlicensed user $exampleUserPrincipalName@vinny-van-gogh.com
$e5Sku = Get-MgSubscribedSku -All | Where SkuPartNumber -eq 'SPE_E5'
Set-MgUserLicense -UserId "$exampleUserPrincipalName@vinny-van-gogh.com" -AddLicenses @{SkuId = $e5Sku.SkuId} -RemoveLicenses @()

# This example assigns SPE_E5 (Microsoft 365 E5) and EMSPREMIUM (ENTERPRISE MOBILITY + SECURITY E5) to the user $exampleUserPrincipalName@vinny-van-gogh.com:
$e5Sku = Get-MgSubscribedSku -All | Where SkuPartNumber -eq 'SPE_E5'
$e5EmsSku = Get-MgSubscribedSku -All | Where SkuPartNumber -eq 'EMSPREMIUM'
$addLicenses = @(
    @{SkuId = $e5Sku.SkuId},
    @{SkuId = $e5EmsSku.SkuId}
)

Set-MgUserLicense -UserId "$exampleUserPrincipalName@vinny-van-gogh.com" -AddLicenses $addLicenses -RemoveLicenses @()

# This example assigns SPE_E5 (Microsoft 365 E5) with the MICROSOFTBOOKINGS (Microsoft Bookings) and LOCKBOX_ENTERPRISE (Customer Lockbox) services turned off:

$e5Sku = Get-MgSubscribedSku -All | Where SkuPartNumber -eq 'SPE_E5'
$disabledPlans = $e5Sku.ServicePlans | `
    Where ServicePlanName -in ("LOCKBOX_ENTERPRISE", "MICROSOFTBOOKINGS") | `
    Select -ExpandProperty ServicePlanId

$addLicenses = @(
    @{
        SkuId = $e5Sku.SkuId
        DisabledPlans = $disabledPlans
    }
)

Set-MgUserLicense -UserId "$exampleUserPrincipalName@vinny-van-gogh.com" -AddLicenses $addLicenses -RemoveLicenses @()


# This example updates a user with SPE_E5 (Microsoft 365 E5) and turns off the Sway and Forms service plans while leaving the user's existing disabled plans in their current state:
$userLicense = Get-MgUserLicenseDetail -UserId "$exampleUserPrincipalName@vinny-van-gogh.com"
$userDisabledPlans = $userLicense.ServicePlans | `
    Where ProvisioningStatus -eq "Disabled" | `
    Select -ExpandProperty ServicePlanId

$e5Sku = Get-MgSubscribedSku -All | Where SkuPartNumber -eq 'SPE_E5'
$newDisabledPlans = $e5Sku.ServicePlans | `
    Where ServicePlanName -in ("SWAY", "FORMS_PLAN_E5") | `
    Select -ExpandProperty ServicePlanId

$disabledPlans = ($userDisabledPlans + $newDisabledPlans) | Select -Unique

$addLicenses = @(
    @{
        SkuId = $e5Sku.SkuId
        DisabledPlans = $disabledPlans
    }
)

Set-MgUserLicense -UserId "$exampleUserPrincipalName@vinny-van-gogh.com" -AddLicenses $addLicenses -RemoveLicenses @()

# This example updates a user with SPE_E5 (Microsoft 365 E5) and turns off the Sway and Forms service plans while leaving the user's existing disabled plans in all other subscriptions in their current state:
$userLicense = Get-MgUserLicenseDetail -UserId $exampleUserPrincipalName@vinny-van-gogh.com

$userDisabledPlans = $userLicense.ServicePlans | Where-Object ProvisioningStatus -eq "Disabled" | Select -ExpandProperty ServicePlanId

$e5Sku = Get-MgSubscribedSku -All | Where SkuPartNumber -eq 'SPE_E5'

$newDisabledPlans = $e5Sku.ServicePlans | Where ServicePlanName -in ("SWAY", "FORMS_PLAN_E5") | Select -ExpandProperty ServicePlanId

$disabledPlans = ($userDisabledPlans + $newDisabledPlans) | Select -Unique

$result=@()
$allPlans = $e5Sku.ServicePlans | Select -ExpandProperty ServicePlanId

foreach($disabledPlan in $disabledPlans)
{
    foreach($allPlan in $allPlans)
    {
        if($disabledPlan -eq $allPlan)
        {
            $property = @{
                Disabled = $disabledPlan
            }
        }
     }
     $result += New-Object psobject -Property $property
}


$finalDisabled = $result | Select-Object -ExpandProperty Disabled


$addLicenses = @(
    @{
        SkuId = $e5Sku.SkuId
        DisabledPlans = $finalDisabled
    }
)


Set-MgUserLicense -UserId $exampleUserPrincipalName@vinny-van-gogh.com -AddLicenses $addLicenses -RemoveLicenses @()

# This example assigns $exampleUserPrincipalNameTwo@vinny-van-gogh.com with the same licensing plan that has been applied to $exampleUserPrincipalName@vinny-van-gogh.com:
$mgUser = Get-MgUser -UserId "$exampleUserPrincipalName@vinny-van-gogh.com" -Property AssignedLicenses
Set-MgUserLicense -UserId "$exampleUserPrincipalNameTwo@vinny-van-gogh.com" -AddLicenses $mgUser.AssignedLicenses -RemoveLicenses @()

# Move a user to a different subscription (license plan)
# This example upgrades a user from the SPE_E3 (Microsoft 365 E3) licensing plan to the SPE_E5 (Microsoft 365 E5) licensing plan: 

$e3Sku = Get-MgSubscribedSku -All | Where SkuPartNumber -eq 'SPE_E3'
$e5Sku = Get-MgSubscribedSku -All | Where SkuPartNumber -eq 'SPE_E5'

# Unassign E3
Set-MgUserLicense -UserId "$exampleUserPrincipalName@vinny-van-gogh.com" -AddLicenses @{} -RemoveLicenses @($e3Sku.SkuId)
# Assign E5
Set-MgUserLicense -UserId "$exampleUserPrincipalName@vinny-van-gogh.com" -AddLicenses @{SkuId = $e5Sku.SkuId} -RemoveLicenses @()

# You can verify the change in subscription for the user account with this command.
Get-MgUserLicenseDetail -UserId "$exampleUserPrincipalName@vinny-van-gogh.com"




New-AzureADUser -UserPrincipalName "powerShellTestUser2@vinny-van-gogh.com" -DisplayName "PowerShell Test User2" -GivenName "powerShell" -surname "Test User 2" -PasswordProfile (New-Object -TypeName Microsoft.Open.AzureAD.Model.PasswordProfile -Property @{ForceChangePasswordNextLogin=$false; Password="YourSecurePassword123"}) -MailNickname "powerShellTestUser" -AccountEnabled $true
