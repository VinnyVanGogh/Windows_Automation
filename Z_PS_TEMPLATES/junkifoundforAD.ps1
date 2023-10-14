# Import the AD module to the session

Import-Module ActiveDirectory

#Search for the users and export report

Get-AdUser -filter * -properties Name, PasswordNeverExpires | Where-Object {
$_.passwordNeverExpires -eq "true" } |  Select-Object DistinguishedName,Name,Enabled |
Export-csv c:\teamaccent\UsersWithPasswordNeverExpires.csv -NoTypeInformation