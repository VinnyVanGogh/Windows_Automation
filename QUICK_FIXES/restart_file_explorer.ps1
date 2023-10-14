function Restart-FileExplorer {
    Stop-Process -Name explorer
    Start-Sleep -Seconds 1
    Start-Process explorer
}

Restart-FileExplorer