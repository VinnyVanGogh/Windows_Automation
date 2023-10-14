$network_drives = Get-ChildItem 'HKU:\' -ErrorAction SilentlyContinue | Where-Object { Test-Path ("\{0}\Network" -f $_.PSPath) } | ForEach-Object { Get-ChildItem ("\{0}\Network" -f $_.PSPath) }

$network_drives | ForEach-Object {
    $username = (Get-WmiObject -Query "SELECT * FROM win32_useraccount WHERE SID = '{0}'" -f $_.PSPath.Split('\')[2]).Name
    $drive_letter = $_.PSChildName
    $remote_path = (Get-ItemProperty -Path $_.PSPath).RemotePath

    [PSCustomObject]@{
        UserName = $username
        DriveLetter = $drive_letter
        RemotePath = $remote_path
    }
} | Format-Table -AutoSize
