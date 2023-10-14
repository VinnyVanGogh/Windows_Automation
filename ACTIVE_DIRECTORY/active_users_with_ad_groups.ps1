$FOLDER_PATH = "C:\VC3"
If (!(Test-Path -PathType Container $FOLDER_PATH)) {
    New-Item -ItemType Directory -Path $FOLDER_PATH
}
$YEAR_AND_MONTH = Get-Date -f "yyyy-MM" 
$CSV_FILE = Join-Path -Path $FOLDER_PATH -ChildPath ("AD_Groups" + $YEAR_AND_MONTH + ".csv") 
$CSV_OUTPUT = @() 
$AD_GROUPS = Get-ADGroup -Filter * 
 
$INCREMENT=0 
$TOTAL_GROUP_COUNT = $AD_GROUPS.count 
 
foreach ($AD_GROUP in $AD_GROUPS) { 
    $INCREMENT++ 
    $status = "{0:N0}" -f ($INCREMENT / $TOTAL_GROUP_COUNT * 100) 
    
    Write-Progress -Activity "Exporting AD Groups" -status "Processing Group $INCREMENT of $TOTAL_GROUP_COUNT : $status% Completed" -PercentComplete ($INCREMENT / $TOTAL_GROUP_COUNT * 100) 
    
    $members = "" 

    $users_array = Get-ADGroup -filter {Name -eq $AD_GROUP.Name} | Get-ADGroupMember | Select-Object Name, objectClass, distinguishedName 
    if ($users_array) {  
        foreach ($user in $users_array) {  
            if ($user.objectClass -eq "user") { 
                $users_distinguished_name = $user.distinguishedName 
                $user_object = Get-ADUser -filter {DistinguishedName -eq $users_distinguished_name} 
                if ($user_object.Enabled -eq $False) { 
                    continue 
                } 
            } 
            $members = $members + "," + $user.Name  
        } 
        if ($members) { 
            $members = $members.Substring(1,($members.Length) -1) 
        } 
    } 
    $hash_table = $NULL 
    $hash_table = [ordered]@{ 
        "Name" = $AD_GROUP.Name 
        "Category" = $AD_GROUP.GroupCategory 
        "Scope" = $AD_GROUP.GroupScope 
        "members" = $members 
    } 
    $CSV_OUTPUT += New-Object PSObject -Property $hash_table 
} 

$CSV_OUTPUT | Sort-Object Name | Export-Csv $CSV_FILE -NoTypeInformation 