$COMMON_IDENTITY_PATH_365 = 'HKCU:\SOFTWARE\Microsoft\Office\16.0\Common\Identity'
$EXCHANGE_PATH_365 = 'HKCU:\Software\Microsoft\Exchange'
$COMMON_IDENTITY_PATH_2016 = 'HKCU:\SOFTWARE\Microsoft\Office\15.0\Common\Identity'
$EXCHANGE_PATH_2016 = 'HKCU:\Software\Microsoft\Exchange'

function Test-RegistryPathExists {
    param (
        [string]$path
    )
    return Test-Path $path
}

function Set-Office365Registry {
    $common_identity_path = $script:COMMON_IDENTITY_PATH_365
    $exchange_path = $script:EXCHANGE_PATH_365

    if (Test-RegistryPathExists -path $common_identity_path) {
        Set-ItemProperty -Path $common_identity_path -Name 'EnableADAL' -Value 1
        Set-ItemProperty -Path $common_identity_path -Name 'Version' -Value 1
    }

    if (Test-RegistryPathExists -path $exchange_path) {
        Set-ItemProperty -Path $exchange_path -Name 'AlwaysUseMSOAuthForAutoDiscover' -Value 1
    }
}

function Set-Office2016Registry {
    $common_identity_path = $script:COMMON_IDENTITY_PATH_2016
    $exchange_path = $script:EXCHANGE_PATH_2016

    if (Test-RegistryPathExists -path $common_identity_path) {
        Set-ItemProperty -Path $common_identity_path -Name 'EnableADAL' -Value 1
        Set-ItemProperty -Path $common_identity_path -Name 'Version' -Value 1
    }

    if (Test-RegistryPathExists -path $exchange_path) {
        Set-ItemProperty -Path $exchange_path -Name 'AlwaysUseMSOAuthForAutoDiscover' -Value 1
    }
}

function Set-AppropriateRegistry {
  if (Test-RegistryPathExists -path $script:GLOBAL_COMMON_IDENTITY_PATH_365 -or Test-RegistryPathExists -path $script:GLOBAL_EXCHANGE_PATH_365) {
      Set-Office365Registry
  }

  if (Test-RegistryPathExists -path $script:GLOBAL_COMMON_IDENTITY_PATH_2016 -or Test-RegistryPathExists -path $script:GLOBAL_EXCHANGE_PATH_2016) {
      Set-Office2016Registry
  }
}

Set-AppropriateRegistry
