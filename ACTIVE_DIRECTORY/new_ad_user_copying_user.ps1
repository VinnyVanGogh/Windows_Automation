$FIRST_NAME = Read-Host "Enter the new user's first name"
$LAST_NAME = Read-Host "Enter the new user's last name"
$NEW_USER_USERNAME = Read-Host "Enter the new Username (Follow formatting guide from **Default New User Setup in ITGlue)"
$SECURE_PASSWORD = Read-Host "Enter the new password (Paste password from **Default New User Setup in ITGlue)" -AsSecureString
$USER_TO_COPY_USERNAME = Read-Host "Enter the account to copy's username (Notes section of **Default New User Setup in ITGlue) ex. templateuser"

function New-ADUser {
    $user_to_copy = Get-ADUser -Identity $script:USER_TO_COPY_USERNAME -Properties MemberOf
    $email_domain = $user_to_copy.UserPrincipalName.Split('@')[1]
    $user_principal_name = "$script:NEW_USER_USERNAME@$email_domain"
    $smtp_proxy_address = "SMTP:$user_principal_name"

    $new_user_params = @{
        GivenName = $script:FIRST_NAME
        Surname = $script:LAST_NAME
        SamAccountName = $script:NEW_USER_USERNAME
        UserPrincipalName = $user_principal_name
        Name = "$script:FIRST_NAME $script:LAST_NAME"
        EmailAddress = $user_principal_name
        Enabled = $true
        PasswordNeverExpires = $true
        CannotChangePassword = $false
        AccountPassword = $script:SECURE_PASSWORD
        Path = $user_to_copy.DistinguishedName.Substring($user_to_copy.DistinguishedName.IndexOf(',') + 1)
    }

    $new_user = New-ADUser @new_user_params -PassThru

    Set-ADUser -Identity $new_user.SamAccountName -Add @{ProxyAddresses = $smtp_proxy_address}

    $group_memberships = $user_to_copy.MemberOf | Get-ADGroup
    foreach ($group in $group_memberships) {
        Add-ADGroupMember -Identity $group -Members $new_user
    }

    Start-Sleep -Seconds 3
    Start-ADSyncSyncCycle -PolicyType Delta
}

New-ADUser
