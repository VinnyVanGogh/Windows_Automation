$ad_user = "userPrincipalName ex. johnD"
$new_password = ConvertTo-SecureString -AsPlainText "TempPassword123!" -Force

Set-ADAccountPassword -Identity $ad_user -NewPassword $new_password -Reset

