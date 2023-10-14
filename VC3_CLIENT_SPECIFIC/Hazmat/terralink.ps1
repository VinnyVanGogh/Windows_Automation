$USERNAME = (Get-WmiObject -Class Win32_ComputerSystem | Select-Object -ExpandProperty UserName).Split('\')[1]
$SOURCE_PATH = "\\application\TDX Enterprise\install\TDXEnterprise3-04-100"
$DESTINATION_PATH = "C:\Users\$USERNAME\Desktop\TDXEnterprise3-04-000"

function New-TerralinkSetup {
    param (
        [string]$source_path,
        [string]$destination_path
    )
  
    if (-not (Test-Path -Path $source_path)) {
        Write-Host "Source path does not exist or is inaccessible."
        return
    }

    if (-not (Test-Path -Path $destination_path)) {
        Write-Host "Destination path does not exist. Creating directory..."
        New-Item -Path $destination_path -ItemType Directory
    }
  
    Copy-Item -Path $source_path -Destination $destination_path -ErrorAction Stop
    $executable_path = Join-Path -Path $destination_path -ChildPath "TDXEnterprise3-04-000.exe"
  
    if (Test-Path -Path $executable_path) {
        Start-Process -FilePath $executable_path
    } else {
        Write-Host "Executable not found in destination path."
    }
}

New-TerralinkSetup -source_path $SOURCE_PATH -destination_path $DESTINATION_PATH
