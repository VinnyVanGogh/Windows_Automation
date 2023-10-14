w32tm /config /syncfromflags:manual /manualpeerlist:"time.google.com"

w32tm /resync

tzutil /s "Pacific Standard Time"

Import-Module ActiveDirectory
Get-ADGroup -Filter * | ForEach-Object { Get-GPInheritance -Target $_.DistinguishedName }
