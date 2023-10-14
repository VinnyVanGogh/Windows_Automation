$domain = $ENV:UserDomain

# Prompt for username
$username = Read-Host -Prompt "Enter the username (e.g., $domain\User)"

# Prompt for password
$password = Read-Host -Prompt "Enter the password" -AsSecureString

# Prompt for target computer name
$targetComputer = Read-Host -Prompt "Enter the target computer name (e.g., ACSIProbe, XYZ-PC01)"

$credential = New-Object System.Management.Automation.PSCredential($username, $password)

Invoke-Command -ComputerName $targetComputer -Credential $credential -ScriptBlock {
    # Your script code here
}
