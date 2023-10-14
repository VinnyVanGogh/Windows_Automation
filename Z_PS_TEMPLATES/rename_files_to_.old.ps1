$file_paths = @(
"C:\Windows\System32\XblAuthManager.dll"
"C:\Windows\System32\XblAuthManagerProxy.dll"
"C:\Windows\System32\XblAuthTokenBrokerExt.dll"
"C:\Windows\System32\XblGameSave.dll"
"C:\Windows\System32\XblGameSaveExt.dll"
"C:\Windows\System32\XblGameSaveProxy.dll"
"C:\Windows\System32\XblGameSaveTask.exe"
"C:\Windows\System32\XboxGipRadioManager.dll"
"C:\Windows\System32\xboxgipsvc.dll"
"C:\Windows\System32\xboxgipsynthetic.dll"
"C:\Windows\System32\XboxNetApiSvc.dll"
"C:\Program Files\WindowsApps\Microsoft.XboxApp_48.104.4001.0_x64__8wekyb3d8bbwe\XboxApp.dll"
"C:\Program Files\WindowsApps\Microsoft.XboxApp_48.104.4001.0_x64__8wekyb3d8bbwe\XboxApp.exe"
)

foreach ($path in $file_paths) {
    Rename-Item -Path $path -NewName "$($path | Split-Path -Leaf).old"
}