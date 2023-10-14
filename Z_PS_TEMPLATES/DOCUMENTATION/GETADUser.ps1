# Commands for Get-ADUser
# https://docs.microsoft.com/en-us/powershell/module/addsadministration/get-aduser?view=windowsserver2022-ps
# https://docs.microsoft.com/en-us/powershell/module/addsadministration/get-aduser?view=win10-ps
# https://docs.microsoft.com/en-us/powershell/module/addsadministration/get-aduser?view=winserver2012-ps
# https://docs.microsoft.com/en-us/powershell/module/addsadministration/get-aduser?view=winserver2012r2-ps
# https://docs.microsoft.com/en-us/powershell/module/addsadministration/get-aduser?view=winserver2016-ps
Get-ADUser
# Gets one or more Active Directory users.

Get-ADUser -Filter {Name -like "A*"}
# Gets all users whose names start with the letter A.

Get-ADUser -Filter {Name -like "A*"} -Properties Name,EmailAddress
# Gets all users whose names start with the letter A and displays the Name and EmailAddress properties.

Get-ADUser -Filter {EmailAddress -like "*@fabrikam.com" -and Surname -eq "Smith"}
# Gets all users whose email address ends with @fabrikam.com and whose last name is Smith.

Get-ADUser -Filter {EmailAddress -like "*@fabrikam.com" -and Surname -eq "Smith"} -Properties EmailAddress,GivenName,Surname
# Gets all users whose email address ends with @fabrikam.com and whose last name is Smith and displays the EmailAddress, GivenName, and Surname properties.

Get-ADUser -Filter {EmailAddress -like "*@fabrikam.com" -and Surname -eq "Smith"} -Properties EmailAddress,GivenName,Surname | Format-Table -Property EmailAddress,GivenName,Surname
# Gets all users whose email address ends with @fabrikam.com and whose last name is Smith and displays the EmailAddress, GivenName, and Surname properties.

Get-ADUser -Filter {EmailAddress -like "*@fabrikam.com" -and Surname -eq "Smith"} -Properties EmailAddress,GivenName,Surname | Format-Table -Property EmailAddress,GivenName,Surname -Wrap
# Gets all users whose email address ends with @fabrikam.com and whose last name is Smith and displays the EmailAddress, GivenName, and Surname properties.