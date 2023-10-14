$NTP_SERVER = Read-Host "Enter the NTP server address{Space between if using multiple} ('n' for default: time.google.com)"
function Write-ColoredText {
    param(
        [Parameter(Mandatory=$true)]
        [String]$Text,
        [Parameter(Mandatory=$true)]
        [String]$Color
    )
    Write-Host -ForegroundColor $Color $Text
}

function Set-NTPServer{
    if ($NTP_SERVER -eq "n") {
        $NTP_SERVER = "time.google.com"
    }

    Write-ColoredText "Configuring NTP server to $NTP_SERVER..." -Color Yellow
    $set_config_output = w32tm /config /syncfromflags:manual /manualpeerlist:"$NTP_SERVER" /reliable:yes /update
    if ($set_config_output -match "The command completed successfully.") {
        Write-ColoredText "The command completed successfully." -Color Green
    }

    Write-ColoredText "Restarting Windows Time service..." -Color Yellow
    Write-ColoredText "The Windows Time service is stopping." -Color Cyan
    $stop_output = net stop w32time
    if ($stop_output -match "The Windows Time service was stopped successfully.") {
        Write-ColoredText "The Windows Time service was stopped successfully." -Color Green
    }

    Write-ColoredText "The Windows Time service is starting." -Color Cyan
    $start_output = net start w32time
    if ($start_output -match "The Windows Time service was started successfully.") {
        Write-ColoredText "The Windows Time service was started successfully." -Color Green
    }

    Write-ColoredText "Synchronizing time..." -Color Yellow
    Write-ColoredText "Sending resync command to local computer" -Color Cyan
    $resync_output = w32tm /resync
    if ($resync_output -match "The command completed successfully.") {
        Write-ColoredText "The command completed successfully." -Color Green
    }

    Write-ColoredText "Querying NTP peers..." -Color Yellow
    $peers = w32tm /query /peers

    Write-ColoredText "NTP Server(Peer):" -Color Yellow
    $peers | ForEach-Object {
        $peer = $_
        if ($peer -match "Peer:\s+(.+)$") {
            $NTP_SERVER = $Matches[1]
            Write-ColoredText "$NTP_SERVER" -Color Green
        }
    }
}

Set-NTPServer