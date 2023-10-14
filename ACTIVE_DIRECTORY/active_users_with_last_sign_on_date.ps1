Import-Module ActiveDirectory

$current_date = Get-Date -Format "MM.dd.yyyy"
$vc3_folder_path = "C:\VC3"
$csv_file_prefix = "ActiveUsersWithLastSignOn"
$csv_filename = Join-Path -Path $vc3_folder_path -ChildPath ($csv_file_prefix + $current_date + ".csv")
$old_csv_files = Get-ChildItem -Path $vc3_folder_path -Filter ($csv_file_prefix + "*.csv") | Where-Object { $_.Name -ne ($csv_file_prefix + $current_date + ".csv") }
$ad_user_properties = "created", "Name", "samaccountname", "EmailAddress", "lastLogonDate", "CanonicalName", "division"

New-Item -ItemType Directory -Path $vc3_folder_path -Force

$old_csv_files | Remove-Item -Force -File

$ad_user_filter = @{
    Filter = "*"
    Properties = "*"
}

$ad_users = Get-ADUser @ad_user_filter |
    Where-Object { $_.Enabled -eq $True -and $_.info -notlike "*excludeFromUserCount*" } |
    Select-Object $ad_user_properties

$ad_users | Export-Csv $csv_filename -NoTypeInformation