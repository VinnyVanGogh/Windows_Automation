$BASE_DIR='\\bmcfps02\Applications\Barracuda Email and Web Filtering\_Barracuda Content Shield Agent\'
$SETUP_FILENAME='BarracudaContentShieldSetup-2.3.23.1.exe'
$KEY_FILENAME='bcs.key'
$bcsExePath = $(Join-Path $BASE_DIR $SETUP_FILENAME)
$bcsKeyPath = $(Join-Path $BASE_DIR $KEY_FILENAME)

if(!(Test-Path $bcsKeyPath)) {
    Write-Host "Barracuda Content Shield key file not found. Exiting."
    exit
}

if(!(Test-Path $bcsExePath)) {
    Write-Host "Barracuda Content Shield setup file not found. Exiting."
    exit
}

[string[]]$arguments = @()
If ($KEY_FILENAME -ne ''){
    $arguments += "KEYPATH=`"$($bcsKeyPath)`""
    $arguments += "/silent" 
}

Start-Process -FilePath $bcsExePath -ArgumentList $arguments -PassThru -Wait -NoNewWindow