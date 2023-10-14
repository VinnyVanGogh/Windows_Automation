$target_ip = "8.8.8.8"
$log_file = "C:\teamaccent\packet_loss_log.txt"

while ($true) {
    $ping_result = Test-Connection -ComputerName $target_ip -Count 1 -Quiet
    if (-Not $ping_result) {
        $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
        Add-Content -Path $log_file -Value "$timestamp: 100% packet loss to $target_ip"
    }
    Start-Sleep -Seconds 1
}

