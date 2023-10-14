$target_ips = @("8.8.8.8", "192.168.4.21") # saves as seperate logs for each IP
$end_time = (Get-Date).AddMinutes(60) # change 60 to the time you want it to run in minutes

while ($true) {
    if ((Get-Date) -ge $end_time) {
        break
    }

    foreach ($target_ip in $target_ips) {
        $log_file = "C:\teamaccent\packet_loss_log_$target_ip.txt"
        $ping_result = Test-Connection -ComputerName $target_ip -Count 1 -Quiet
        if (-Not $ping_result) {
            $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
            Add-Content -Path $log_file -Value "At $timestamp - 100% packet loss to $target_ip"
        }
    }

    Start-Sleep -Seconds 1
}
