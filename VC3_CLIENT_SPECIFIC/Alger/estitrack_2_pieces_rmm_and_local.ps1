#From N-Able
$loggedInUser = (Get-WmiObject -Class Win32_ComputerSystem | Select-Object -ExpandProperty UserName).Split(‘\’)[1]
net localgroup Administrators $loggedInUser /add

 

#From Powershell as admin (as the user)
Net Use H: \\APMAPP\Estitrack /Persistent:Yes

Start-Process -Filepath "\\APMAPP\Estitrack\Vet\Vetsetup\setup.exe" -Wait #run through setup process

Invoke-Item -Path "H:\Vet\APP\3OF9.ttf" -Wait #(Install after it pops up)
Invoke-Item -Path "H:\Vet\APP\CODE128S.ttf" -Wait #(Install after it pops up)

Set-Location \

Set-SmbClientConfiguration -DirectoryCacheLifetime 0
Set-SmbClientConfiguration -FileInfoCacheLifetime 0

Start-Process "C:\VETUSER\vet.exe"
#Map to H:\VET\
#Log into the application using Carl's account (UN: Carl PW: Jung) *not case sensitive*