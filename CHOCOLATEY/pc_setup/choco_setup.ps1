# Define SaRA installation variables
$URL = "https://aka.ms/SaRA-Internet-Setup"
$SARA_EXE_PATH = "$Env:TEMP\SaraSetup.exe"
$ARGLIST = "/quiet"

# Define the list of packages to install
$ESSENTIAL_PACKAGES = @(
    "firefox",
    "googleChrome-AllUsers",
    "microsoft-Edge",
    "microsoft-Teams",
    "zoom",
    "notepadPlusPlus",
    "vlc",
    "7zip",
    "microsoft-Windows-Terminal",
    "pwsh",
    "powershell",
    "python",
    "putty",
    "sysinternals",
    "windirstat",
    "wireshark",
    "nmap",
    "openvpn-Connect",
    "adobeReader"
    )

# Define packages to pin
# You can find installed package names by running "choco list --local-only --limit-output" in PowerShell
# $PACKAGES_TO_PIN = @("", "", "")

# Define Windows features to enable
$FEATURES_TO_ENABLE = @(
    "Microsoft-Windows-Subsystem-Linux",
    "NetFx3",
    "NetFx4",
    "VirtualMachinePlatform",
    "RSAT",
    "RSAT:ServerManager",
    "RSAT:ActiveDirectory",
    "RSAT:ADCS",
    "RSAT:ADDS",
    "RSAT:DNS-Server",
    "RSAT:Hyper-V-Tools",
    "RSAT:RemoteAccess",
    "RSAT:Role-Tools",
    "RSAT:Web-Server",
    "RSAT:Clustering",
    "RSAT:DHCP",
    "RSAT:FailoverCluster",
    "RSAT:File-Services",
    "RSAT:GroupPolicy",
    "RSAT:Licensing-Diagnosis-UI",
    "RSAT:Remote-Desktop-Services",
    "RSAT:RemoteAccess-PowerShell",
    "RSAT:ServerManager-PowerShell",
    "RSAT:Storage-Services",
    "RSAT:Storage-Replica",
    "RSAT:WDS",
    "RSAT:VolumeActivation",
    "RSAT:Windows-Internal-Database"
)

function Set-ExecutionPolicyForScripts {
  try {
      Set-ExecutionPolicy -Scope LocalMachine -ExecutionPolicy RemoteSigned -Force
  } catch {
      Write-Host "Error setting execution policy: $_" -ForegroundColor Red
  }
}

function Initialize-Chocolatey {
  if (-Not (Get-Command choco -ErrorAction SilentlyContinue)) {
      try {
          Set-ExecutionPolicy Bypass -Scope Process -Force
          [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.SecurityProtocolType]::Tls12
          Invoke-Expression ((New-Object System.Net.WebClient).DownloadString('https://community.chocolatey.org/install.ps1'))
      } catch {
          Write-Host "Error initializing Chocolatey: $_" -ForegroundColor Red
      }
  }
}

function Install-Packages {
  param (
      [string[]]$packageList
  )
  $installedPackages = choco list --local-only --limit-output | ForEach-Object { $_.Split('|')[0].Trim() }

  foreach ($package in $packageList) {
      if ($installedPackages -notcontains $package) {
          $attempts = 0
          $maxAttempts = 5
          $installed = $false
          while ($attempts -lt $maxAttempts -and !$installed) {
              $attempts++
              Write-Host "Attempt $attempts - Installing package $package" -ForegroundColor Gray
              try {
                  choco install $package -y -q
                  Write-Host "Package $package successfully installed." -ForegroundColor Green
                  $installed = $true
              } catch {
                  Write-Host "Failed to install package $package. Retrying..." -ForegroundColor Red
                  Start-Sleep -Seconds 5
              }
          }
      } else {
          Write-Host "Package $package is already installed. Skipping." -ForegroundColor Cyan
      }
  }
}


function Optimize-Packages {
  choco upgrade all -y
}

function Lock-Packages {
  param (
      [string[]]$packageList
  )
  
  foreach ($package in $packageList) {
      $pinStatus = choco pin list -n $package | Out-String
      
      if ($pinStatus -match "Pinned") {
          Write-Host "Package $package is already pinned. Skipping." -ForegroundColor Cyan
      } else {
          choco pin add -n $package > $null 
          Write-Host "Package $package has been pinned." -ForegroundColor DarkGreen
      }
  }
}

function Enable-WindowsFeatures {
  param (
      [string[]]$featureList
  )
  
  $existingFeatures = Get-WindowsOptionalFeature -Online | Select-Object -ExpandProperty FeatureName

  foreach ($feature in $featureList) {
    if ($existingFeatures -contains $feature) {
      $featureStatus = Get-WindowsOptionalFeature -Online -FeatureName $feature | Select-Object -ExpandProperty State
      if ($featureStatus -eq "Enabled") {
        Write-Host "Feature $feature is already enabled." -ForegroundColor Cyan
      } else {
        Enable-WindowsOptionalFeature -Online -FeatureName $feature -NoRestart
        Write-Host "Feature $feature has been enabled." -ForegroundColor Green
      }
    } else {
      Write-Host "Feature $feature is not available on this machine." -ForegroundColor DarkCyan
    }
  }
}


function Enable-WoL {
  $adapters = Get-NetAdapter | Where-Object Name -like "*Ethernet*"

  foreach ($adapter in $adapters) {
    $hasWoL = Get-NetAdapterAdvancedProperty -Name $adapter.Name | Where-Object DisplayName -eq "Wake on Magic Packet"
    
    if ($null -ne $hasWoL) {
      Set-NetAdapterAdvancedProperty -Name $adapter.Name -DisplayName "Wake on Magic Packet" -DisplayValue "Enabled"
      Write-Host "Wake on Magic Packet enabled for adapter: $($adapter.Name)" -ForegroundColor Green
    } else {
      Write-Host "Wake on Magic Packet not available for adapter: $($adapter.Name)" -ForegroundColor DarkBlue
    }
  }
}

function IsLaptop {
  $batteryStatus = Get-WmiObject -Query "Select * From Win32_Battery" 
  return ($null -ne $batteryStatus)
}

function SetPowerSettings {
  param (
      [bool] $isLaptop
  )
  powercfg -change -monitor-timeout-ac 30
  powercfg -change -standby-timeout-ac 0

  Write-Host "Power settings updated for Plugged-in:" -ForegroundColor Gray
  Write-Host "Monitor timeout: 30 minutes" -ForegroundColor Green
  Write-Host "Sleep timeout: Never" -ForegroundColor Green

  if ($isLaptop) {
      powercfg -change -monitor-timeout-dc 15
      powercfg -change -standby-timeout-dc 30

      Write-Host "Power settings updated for Battery power:" -ForegroundColor Gray 
      Write-Host "Monitor timeout: 15 minutes" -ForegroundColor Green
      Write-Host "Sleep timeout: 30 minutes" -ForegroundColor Green
  }
}

function Set-ComputerNameBySerial {
  $serial_number = (Get-WmiObject -Class Win32_BIOS).SerialNumber

  $sanitized_serial = $serial_number -replace '[^\w\d]', ''
  $sanitized_serial = $sanitized_serial.Substring(0, [Math]::Min(9, $sanitized_serial.Length))

  $prefix = if (IsLaptop) { "LT" } else { "DT" }

  $new_computer_name = "$prefix-$sanitized_serial"

  Rename-Computer -NewName $new_computer_name -Force
}

function Install-SaRA {
  $saraInstalled = Get-ItemProperty -Path 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Uninstall\*' |
                   Where-Object { $_.DisplayName -match "Microsoft Support and Recovery Assistant" }

  if ($null -ne $saraInstalled) {
    Write-Host "Support and Recovery Assistant is already installed." -ForegroundColor Green
    return
  }

  Invoke-WebRequest -Uri $URL -OutFile $SARA_EXE_PATH
  Start-Process -FilePath $SARA_EXE_PATH -ArgumentList $ARGLIST -Wait

  $saraInstalled = Get-ItemProperty -Path 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Uninstall\*' |
                   Where-Object { $_.DisplayName -match "Microsoft Support and Recovery Assistant" }

  if ($null -ne $saraInstalled) {
    $SARA_VERSION = $saraInstalled.DisplayVersion
    Write-Host "Support and Recovery Assistant version $SARA_VERSION is installed." -ForegroundColor DarkGreen
  } else {
    Write-Host "Support and Recovery Assistant installation failed." -ForegroundColor Red
  }

  $SETUP_EXE_PATH = "$Env:TEMP\SaraSetup.exe"
  Start-Process -FilePath $SETUP_EXE_PATH -Wait
}


function Install-WindowsUpdatesAutomatically {
  $modulesToInstall = @("PSWindowsUpdate", "PackageManagement", "PowerShellGet")

  foreach ($moduleName in $modulesToInstall) {
      $module = Get-Module -ListAvailable -Name $moduleName
      if ($null -eq $module) {
          Install-Module -Name $moduleName -Force -SkipPublisherCheck -Scope AllUsers
      }
  }
  
  $module = Get-Module -Name 'PSWindowsUpdate'
  if ($null -eq $module) {
      Import-Module PSWindowsUpdate
  }

  Install-WindowsUpdate -AcceptAll -IgnoreReboot -Confirm:$false
}

function Install-DellCommandUpdateIfApplicable {
  $manufacturer = (Get-WmiObject -Class Win32_ComputerSystem).Manufacturer
  
  if ($manufacturer -match 'Dell') {
      $installedPackages = choco list --local-only --limit-output
      if ($installedPackages -notcontains "DellCommandUpdate") {
          Write-Host "Installing DellCommandUpdate" -ForegroundColor Green
          choco install DellCommandUpdate -y
      } else {
          Write-Host "DellCommandUpdate is already installed. Skipping." -ForegroundColor Cyan
      }
  } else {
      Write-Host "This is not a Dell machine. Skipping DellCommandUpdate installation." -ForegroundColor DarkYellow
  }
}

try {
  Set-ExecutionPolicyForScripts
  Initialize-Chocolatey
  SetPowerSettings -isLaptop (IsLaptop)
  Enable-WindowsFeatures -featureList $FEATURES_TO_ENABLE
  Enable-WoL
  Install-Packages -packageList $ESSENTIAL_PACKAGES
#  Lock-Packages -packageList $PACKAGES_TO_PIN # Uncomment to pin packages
  Optimize-Packages
  Install-SaRA
  Install-DellCommandUpdateIfApplicable
  Install-WindowsUpdatesAutomatically
  Set-ComputerNameBySerial
  Write-Host "Restarting the computer in 10 seconds. You can cancel by pressing Ctrl+C." -ForegroundColor Magenta
  Start-Sleep -Seconds 10
  Restart-Computer -Force
} catch {
  $errorMessage = $_.Exception.Message
  Write-Host "Error occurred: $errorMessage" -ForegroundColor DarkRed
}
