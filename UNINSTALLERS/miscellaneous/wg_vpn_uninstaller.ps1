$USERNAME = (Get-WmiObject -Class Win32_ComputerSystem | Select-Object -ExpandProperty UserName).Split('\')[1]
$UNINSTALLER_PATH = "C:\Program Files (x86)\WatchGuard\WatchGuard Mobile VPN with SSL\unins000.exe"
$REMAINING_FILES = @(
    "C:\Program Files\WatchGuard\Mobile VPN",
    "C:\Users\$USERNAME\AppData\Roaming\WatchGuard\Mobile VPN"
)
$REMAINING_REGISTRY_KEYS = @(
    "HKCU:\Software\WatchGuard\SSLVPNClient\Settings",
    "HKCU:\Software\Microsoft\Windows\CurrentVersion\Run\WatchGuard Mobile VPN with SSL"
)

function Close-VPNProcesses {
    $processes = Get-Process | Where-Object { $_.Name -like "*wgsslvpn*" }
    if ($processes) {
        foreach ($process in $processes) {
            $process | Stop-Process -Force
            Write-Host "Closed process: $($process.Name)"
        }
    } else {
        Write-Host "No running processes found for Mobile VPN with SSL client"
    }
}

function Uninstall-VPNClient {
    if (Test-Path $script:UNINSTALLER_PATH) {
        $uninstall_args = "/S"
        $uninstall_result = Start-Process -FilePath $script:UNINSTALLER_PATH -ArgumentList $uninstall_args -Wait -NoNewWindow
        if ($uninstall_result.ExitCode -eq 0) {
            Write-Host "Uninstalled Mobile VPN with SSL client"
        } else {
            Write-Host "Failed to uninstall Mobile VPN with SSL client. Error code: $($uninstall_result.ExitCode)"
        }
    } else {
        Write-Host "Uninstaller not found at: $script:UNINSTALLER_PATH"
    }
}

function Remove-RemainingFiles {
    $script:REMAINING_FILES | ForEach-Object {
        if (Test-Path $_) {
            Remove-Item -Path $_ -Recurse -Force
            Write-Host "Deleted: $_"
        } else {
            Write-Host "File not found: $_"
        }
    }
}

function Remove-RemainingRegistryKeys {
    $script:REMAINING_REGISTRY_KEYS | ForEach-Object {
        if (Test-Path $_) {
            Remove-Item -Path $_ -Force
            Write-Host "Deleted registry key: $_"
        } else {
            Write-Host "Registry key not found: $_"
        }
    }
}

Close-VPNProcesses
Uninstall-VPNClient
Remove-RemainingFiles
Remove-RemainingRegistryKeys
