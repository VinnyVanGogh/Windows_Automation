Import-Module ActiveDirectory

$date = Get-Date -Format "MM.dd.yyyy"
$path = "C:\VC3"
$save_path = Join-Path -Path $path -ChildPath ("ActiveUsersWithLastSignOn" + $date + ".csv")

If (!(Test-Path -PathType Container $path)) {
    New-Item -ItemType Directory -Path $path
}

Get-ADUser -Filter * -Properties * |
    Where-Object { $_.Enabled -eq $True -and $_.info -notlike "*excludeFromUserCount*"} |
    Select-Object created,Name,samaccountname,EmailAddress,lastLogonDate,CanonicalName,division |
    Export-Csv $save_path -NoTypeInformation