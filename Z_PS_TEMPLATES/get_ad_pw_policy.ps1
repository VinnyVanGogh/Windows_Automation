$command = 'Get-ADDefaultDomainPasswordPolicy -Identity agc.local'
$output = Invoke-Expression $command
"$command`r`n$output" | Set-Clipboard

