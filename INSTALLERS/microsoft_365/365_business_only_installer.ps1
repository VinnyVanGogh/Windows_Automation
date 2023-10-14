$loggedInUser = $env:userName
$desktopPath = "C:\Users\{0}\Desktop" -f $loggedInUser
$tempFolderPath = Join-Path -Path $desktopPath -ChildPath "ScriptbyVV"
$ODTUrl = "https://download.microsoft.com/download/2/7/A/27AF1BE6-DD20-4CB4-B154-EBAB8A7D4A7E/officedeploymenttool_16501-20196.exe"
$ODTPath = Join-Path -Path $tempFolderPath -ChildPath "OfficeDeployToolbyVinny"
$ConfigXmlPath = Join-Path -Path $ODTPath -ChildPath "vinnyssetup.xml"
$userRegistryPath = "HKCU:\Software\Microsoft\Office\16.0\Common\Identity"
$exchangeRegistryPath = "HKCU:\Software\Microsoft\Exchange"

New-Item -ItemType Directory -Path $tempFolderPath -Force | Out-Null

$installOption = Read-Host -Prompt $(Write-Host -NoNewline -ForegroundColor Cyan "Do you want to install Microsoft 365 Enterprise? (Y/N)")
if ($installOption -eq "Y"){
Write-Host "Installing and setting up Office Suite with ODT..." -ForegroundColor DarkYellow

New-Item -ItemType Directory -Force -Path $ODTPath | Out-Null

$ODTExePath = Join-Path -Path $ODTPath -ChildPath "ODT.exe"

Invoke-WebRequest -Uri $ODTUrl -OutFile $ODTExePath

Start-Process -Wait -FilePath $ODTExePath -ArgumentList "/quiet", "/extract:$ODTPath"

@"
<Configuration>
  <Add OfficeClientEdition="64" Channel="Broad">
    <Product ID="O365BusinessRetail">
      <Language ID="en-us" />
    </Product>
    <Product ID="VisioProRetail">
      <Language ID="en-us" />
    </Product>
    <Product ID="ProjectProRetail">
      <Language ID="en-us" />
    </Product>
    <Product ID="OneNoteRetail">
      <Language ID="en-us" />
    </Product>
  </Add>
  <Updates Enabled="TRUE" />
  <Display Level="None" AcceptEULA="TRUE" />
  <Property Name="AUTOACTIVATE" Value="1" />
</Configuration>
"@ | Set-Content -Path $ConfigXmlPath

$SetupExePath = Get-ChildItem -Path $ODTPath -Filter "setup.exe" -Recurse -Depth 1 | Select-Object -ExpandProperty FullName

Start-Process -Wait -FilePath $SetupExePath -ArgumentList "/configure", $ConfigXmlPath

Set-ItemProperty -Path $userRegistryPath -Name 'EnableADAL' -Value 1
Set-ItemProperty -Path $userRegistryPath -Name 'Version' -Value 1
Set-ItemProperty -Path $exchangeRegistryPath -Name 'AlwaysUseMSOAuthForAutoDiscover' -Value 1
} 

Remove-Item -Path $tempFolderPath -Recurse -Force

