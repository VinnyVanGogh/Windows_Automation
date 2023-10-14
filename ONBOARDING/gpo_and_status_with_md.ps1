$gpoDetails = @()
$counter = 0
$gpoDetails += "# OU's and GPO's`r`n"
$gpoDetails += "## Organizational Units `r`n"
$gpoDetails += "- OU Names`r`n"

Get-ADOrganizationalUnit -Filter * | ForEach-Object {
    $ou = $_.DistinguishedName
    $inheritance = Get-GPInheritance -Target $ou
    $gpoLinks = $inheritance.GpoLinks -join ', '
    $inheritedGpoLinks = $inheritance.InheritedGpoLinks -join ', '
    $gpoDetails += "    - $ou`r`n"
    $toRemoveSquigglies =  $gpoLinks + $inheritedGpoLinks
    $toRemoveSquigglies = $toRemoveSquigglies -replace '99problemsbutsquiqqlylinesaintone', ''
}

$gpoDetails += "## GPO Details`r`n"

Get-GPO -All | ForEach-Object {
    $counter++
    $gpo = $_
    $gpoDetails += "### GPO - $counter`r`n- [ ]  **$($gpo.DisplayName)**`r`n"
    $gpoDetails += "    - Created at`r`n        - **$($gpo.CreationTime)**`r`n"
    $gpoDetails += "    - Modified last`r`n        - **$($gpo.ModificationTime)**`r`n"
    $gpoDetails += "    - Enforced **$($_.GpoStatus -eq 'AllSettingsEnabled')**`r`n"
    $wmiFilter = if ($gpo.WmiFilter.Name) { $gpo.WmiFilter.Name } else { "None" }
    $gpoDetails += "    - WMIFilter: **$wmiFilter**`r`n"
    $gpoDetails += "    - Block Inheritance: **$($inheritance.GpoInheritanceBlocked)**`r`n"
    $gpoDetails += "    - Link Enabled: **$($_.inheritedGpoLinks -ne $false)**`r`n        - **$inheritedGpoLinks**`r`n`r`n"

    $gpoStatus = $gpo.GpoStatus
    if ($gpoStatus -eq 'AllSettingsEnabled') {
        $gpoStatus = 'All Settings Enabled'
    }
    elseif ($gpoStatus -eq 'AllSettingsDisabled') {
        $gpoStatus = 'All Settings Disabled'
    }
    elseif ($gpoStatus -eq 'ComputerSettingsDisabled') {
        $gpoStatus = 'Computer Settings Disabled'
    }
    elseif ($gpoStatus -eq 'UserSettingsDisabled') {
        $gpoStatus = 'User Settings Disabled'
    }

    $gpoDetails += "    - GPO Status: **$gpoStatus**`r`n"
    $description = $gpo.Description
    if (!$description) {
        $description = "No description in Group Policy Management Console for this GPO."
    }
    $gpoDetails += "    - Purpose`r`n        - **$($description)**`r`n`r`n- [Return to Top $counter](#quick-links)`r`n`r`n"
}

$gpoDetails -join "" | Write-Output | Set-Clipboard