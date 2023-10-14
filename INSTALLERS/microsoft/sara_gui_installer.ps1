# Script to download and start SaRA
# Created by Vinny Vasile - 6.16.2023
$loggedinUser = (Get-WmiObject -Class Win32_ComputerSystem | Select-Object -ExpandProperty UserName).Split('\')[1]
$desktopPath = "C:\Users\$loggedinUser\Desktop"
$SaRAAppRefPath = "$desktopPath\Microsoft Support and Recovery Assistant.appref-ms"
$url = "https://aka.ms/SaRA-Internet-Setup"  
$SaraExePath = "$Env:TEMP\SaraSetup.exe"  
$arglist = "/quiet" 

Invoke-WebRequest -Uri $url -OutFile $SaraExePath

Start-Process -FilePath $SaraExePath -ArgumentList $arglist -Wait

$InstallCheck = Get-ChildItem "HKCU:\Software\Microsoft\Windows\CurrentVersion\Uninstall"
$foundMatch = $false

foreach ($subkey in $InstallCheck) {
    if ($subkey.GetValue('DisplayName') -match "Microsoft Support and Recovery Assistant") {
        $foundMatch = $true
        $SaraVersion = $subkey.GetValue('DisplayVersion')
        Write-Host "Support and Recovery Assistant version $SaraVersion is installed."
        break
    }
}

if (-not $foundMatch) {
    Write-Host "Support and Recovery Assistant is not installed."
}

$setupExePath = "$Env:TEMP\SaraSetup.exe"
Start-Process -FilePath $setupExePath -Wait

Start-Process -FilePath $SaRAAppRefPath

Write-Host "Microsoft Support and Recovery Assistant (SARA) setup and application have been executed." -ForegroundColor Black -BackgroundColor Green