$LOGGED_IN_USER = (Get-WmiObject -Class Win32_ComputerSystem | Select-Object -ExpandProperty UserName).Split('\')[1]

function Get-LoggedInUserName {
    [CmdletBinding()]
    param ()

    if (-not $LOGGED_IN_USER) {
        Write-Host "No user currently logged in."
        return $null
    }
    return $LOGGED_IN_USER
}

function Get-UserSid {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true)]
        [string]$UserName
    )

    $user_sid = (Get-WmiObject -Class Win32_UserAccount | Where-Object { $_.Name -eq $UserName }).SID
    if (-not $user_sid) {
        Write-Host "Could not retrieve SID for user $UserName."
        return $null
    }
    return $user_sid
}

function Write-RegistryPathForSid {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true)]
        [string]$UserSid
    )

    $registry_path = "Computer\HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows NT\CurrentVersion\ProfileList\$UserSid"
    Write-Host "Paste into Regedit.exe:" -ForegroundColor Green
    Write-Host "$registry_path" -ForegroundColor Green
}

$user_name = Get-LoggedInUserName
if ($user_name) {
    $user_sid = Get-UserSid -UserName $user_name
    if ($user_sid) {
        Write-RegistryPathForSid -UserSid $user_sid
    }
}
