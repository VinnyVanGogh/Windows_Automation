function Add-LocalVC3AdminUser {
    try {
        $Username = "VC3_Admin"
        $Password = '#BP@$$w0rd#B'
        $SecurePassword = ConvertTo-SecureString $Password -AsPlainText -Force

        New-LocalUser -Name $Username -Password $SecurePassword
        Add-LocalGroupMember -Group "Administrators" -Member $Username
    }
    catch {
        Write-Error "An error occurred: $_"
    }
}

try {
    Add-LocalVC3AdminUser
}
catch {
    Write-Error "Failed to add local VC3 admin user: $_"
}