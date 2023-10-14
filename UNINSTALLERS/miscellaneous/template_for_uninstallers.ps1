$PROGRAM_NAME = "Your Program Name"

$REG_PATHS = @(
    "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall",
    "HKLM:\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Uninstall"
)

function Uninstall-Program {
    $uninstall_data = $script:REG_PATHS |
        ForEach-Object{Get-ChildItem $_ -ErrorAction SilentlyContinue} |
        ForEach-Object{Get-ItemProperty $_.PsPath} |
        Where-Object {$_.DisplayName -like "*$script:PROGRAM_NAME*"} |
        Select-Object -Property DisplayName, UninstallString

    if ($uninstall_data) {
        $uninstall_string = $uninstall_data.UninstallString
        $silent_args = ""

        if ($uninstall_string -like "*msiexec.exe*") {
            $silent_args = "/quiet /norestart"
        } elseif ($uninstall_string -like "*unins*.exe*") {
            $silent_args = "/silent"
        } elseif ($uninstall_string -like "*nsis*.exe*") {
            $silent_args = "/S"
        }

        $uninstall_command = "`"$uninstall_string`" $silent_args"
        Invoke-Expression "& $uninstall_command"
    } else {
        Write-Host "Program not found: $script:PROGRAM_NAME"
    }
}

Uninstall-Program
