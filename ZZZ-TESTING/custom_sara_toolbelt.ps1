# DON'T USE OFFICE SCRUB, DOESN'T WORK PROPERLY, FREEZES
# Created by Microsoft Added to by Vinny Vasile - 6.16.2023
# SaRACMD.exe Powertool

$SaraCmdSourcePath = "https://aka.ms/SaRA_EnterpriseVersionFiles"

$validValues = @("ExpertExperienceAdminTask", "OfficeScrubScenario", "ResetOfficeActivation", "TeamsAddinScenario", "OfficeActivationScenario")

do {
    Write-Host "ExpertExperienceAdminTask | (Outlook Diagnostics)" -ForegroundColor Black -BackgroundColor DarkCyan
#ThisShouldWorkButDoesn'tOnMyVMNeedsMoreTestingBeforeUncommenting-CanStillTechnicallyRunThisJustWon'tDisplay    Write-Host "OfficeScrubScenario | (Uninstalls Office)" -ForegroundColor Black -BackgroundColor DarkCyan
    Write-Host "ResetOfficeActivation | (Resets Office Subscription)" -ForegroundColor Black -BackgroundColor DarkCyan
    Write-Host "TeamsAddinScenario | (Teams meeting for Outlook troubleshooter)" -ForegroundColor Black -BackgroundColor DarkCyan
    Write-Host "OfficeActivationScenario | (Troubleshoots Activation issues)" -ForegroundColor Black -BackgroundColor DarkCyan

    $scenarioName = Read-Host "Enter the value, ex ExpertExperienceAdminTask, ResetOfficeActivation, etc"

    if ($validValues -notcontains $scenarioName) {
        Write-Host "Invalid value. Please try again." -ForegroundColor Red
    }
} while ($validValues -notcontains $scenarioName)

$SaraScenarioArgument = "-S $scenarioName"

if ($scenarioName -eq "TeamsAddinScenario") {
    $SaraScenarioArgument += " -CloseOutlook"
}

if ($scenarioName -eq "OfficeScrubScenario") {
    $SaraScenarioArgument += " -CloseOffice"
}

$SaraScenarioArgument += " -Script -AcceptEula"

$currentTimeStamp = Get-Date -Format "yyyy-MMM-dd_HH.mm.ss"

$username = (Get-WmiObject -Class Win32_ComputerSystem | Select-Object -ExpandProperty UserName).Split('\')[1]
$resultsFileName = $username + "_<scenario>_$currentTimeStamp.zip"


# ==================
# Begin Main Section ** Nothing below this line <requires> any edits **
# ==================

$currentLocation = $PSScriptRoot
$resultsFilePath = "$currentLocation\$resultsFileName"
$SaraCmdExecutableFolder = "$currentLocation\SaraCMDExecutable"
$SaraCmdExecutablePath = "$SaraCmdExecutableFolder\SaraCMD.exe"
$LocalLogFolder = "$currentLocation\LogFiles"
$scriptLogFile = "$LocalLogFolder\SaraCmd-$currentTimeStamp.txt"
$scriptStartTime = Get-Date

# ------------------------
# Starting Local Functions
# ------------------------


Function Create-LocalFolders
{
New-Item -Path $SaraCmdExecutableFolder -ItemType "directory" -Force | Out-Null
New-Item -Path $LocalLogFolder -ItemType "directory" -Force | Out-Null
}


Function Clean-LocalFiles
{
Remove-Item -Path $SaraCmdExecutableFolder -Force -Recurse
Remove-Item -Path $LocalLogFolder -Force -Recurse
}


Function Clean-InitialFiles
{
$targetZipFileLocation = "$currentLocation\SaraCmd.zip"

if (Test-Path -Path $targetZipFileLocation -PathType Leaf)
{
Remove-Item -Path $targetZipFileLocation -Force | Out-File -FilePath $scriptLogFile -Append
}

if (Test-Path -Path $SaraCmdExecutableFolder)
{
Remove-Item -Path $SaraCmdExecutableFolder -Force -Recurse | Out-File -FilePath $scriptLogFile -Append
}
}


Function Copy-SaraLocally($SaraCmdSourcePath)
{
$targetZipFileLocation = "$currentLocation\SaraCmd.zip"

Write-Output "Copying Files from $SaraCmdSourcePath" | Out-File -FilePath $scriptLogFile -Append


if ($SaraCmdSourcePath.StartsWith("http", 'CurrentCultureIgnoreCase'))
{
Write-Output "Getting zip file from web location $SaraCmdSourcePath" | Out-File -FilePath $scriptLogFile -Append

Invoke-WebRequest -URI $SaraCmdSourcePath -OutFile $targetZipFileLocation
$SaraCmdSourcePath = $targetZipFileLocation
}
else
{
if ($SaraCmdSourcePath.EndsWith(".zip", 'CurrentCultureIgnoreCase'))
{
Copy-Item -Path $SaraCmdSourcePath -Destination $targetZipFileLocation -Force | Out-File -FilePath $scriptLogFile -Append
$SaraCmdSourcePath = $targetZipFileLocation
}
}


if ($SaraCmdSourcePath.EndsWith(".zip", 'CurrentCultureIgnoreCase'))
{
Write-Output "Expanding zip file from $SaraCmdSourcePath" | Out-File -FilePath $scriptLogFile -Append
Expand-Archive -Path $targetZipFileLocation -DestinationPath $SaraCmdExecutableFolder -Force
$SaraCmdSourcePath = $SaraCmdExecutableFolder
}

if($SaraCmdSourcePath -ne $SaraCmdExecutableFolder)
{

Write-Output "Copying files from $SaraCmdSourcePath" | Out-File -FilePath $scriptLogFile -Append
Copy-Item -Path $SaraCmdSourcePath\* -Destination $SaraCmdExecutableFolder -Recurse -Force
Write-Output "Copied Files To $SaraCmdExecutableFolder" | Out-File -FilePath $scriptLogFile -Append
}


if (Test-Path -Path $targetZipFileLocation -PathType Leaf)
{
Remove-Item -Path $targetZipFileLocation -Force
}


if (Test-Path -Path "$SaraCmdExecutableFolder\SaraCmd.exe" -PathType Leaf)
{
return $true
}
else
{
return $false
}

}


Function Copy-LogFiles()
{
$SaraLogsRootFolder = $env:LOCALAPPDATA
$saraLogsFolder = "$SaraLogsRootFolder\SaraLogs\Log\"
$SaraUploadLogsFolder = "$SaraLogsRootFolder\SaraLogs\UploadLogs\"
$SaraResultsFolder = "$SaraLogsRootFolder\SaraResults\"


Get-ChildItem -Path $saraLogsFolder |
Where-Object {
$_.LastWriteTime `
-gt $scriptStartTime } |
ForEach-Object { $_ | Copy-Item -Destination $LocalLogFolder -Recurse }


Get-ChildItem -Path $SaraUploadLogsFolder |
Where-Object {
$_.LastWriteTime `
-gt $scriptStartTime } |
ForEach-Object { $_ | Copy-Item -Destination $LocalLogFolder -Recurse }


Get-ChildItem -Path $SaraResultsFolder |
Where-Object {
$_.LastWriteTime `
-gt $scriptStartTime } |
ForEach-Object { $_ | Copy-Item -Destination $LocalLogFolder -Recurse }
}


Function Create-LogArchive()
{
Compress-Archive -Path "$localLogFolder\*" -DestinationPath $resultsFilePath
}


Function Check-AdminAccess($scenario)
{
$elevationRequired = $false

if ($scenario -in "OfficeActivationScenario", "OfficeScrubScenario", "OfficeSharedComputerScenario", "ResetOfficeActivation")
{
$elevationRequired = $true
}

return $elevationRequired
}


Function Test-IsAdmin # Function credit to: https://devblogs.microsoft.com/scripting/use-function-to-determine-elevation-of-powershell-console/
{
$identity = [Security.Principal.WindowsIdentity]::GetCurrent()
$principal = New-Object Security.Principal.WindowsPrincipal $identity
return $principal.IsInRole([Security.Principal.WindowsBuiltinRole]::Administrator)
}


Function Execute-SaraCMD($saraCmdSourcePath, $arguments)
{
$success = $false
$filesCopied = Copy-SaraLocally($saraCmdSourcePath)
if ([bool]::Parse($filesCopied) -ne $true)
{
Write-Host "Could not get Sara CMD File locally, exiting..."
exit
}

Write-Output "Executing sara cmd from $SaraCmdExecutablePath" | Out-File -FilePath $scriptLogFile -Append
Write-Output "With arguments : $arguments" | Out-File -FilePath $scriptLogFile -Append

$scenario = Get-Scenario($arguments)

Write-Host ""
Write-Host ">>> Starting the scenario with the following arguments:"
Write-Host ""
Write-Host " $SaraScenarioArgument"
Write-Host ""
Write-Host ">>> Please wait ..."
Write-Host ""

$processInfo = new-Object System.Diagnostics.ProcessStartInfo($SaraCmdExecutablePath);
$processInfo.Arguments = $arguments # Do NOT modify - These are required parameters for this scenario

if(Check-AdminAccess($scenario) -eq $true)
{
$processInfo.Verb = "RunAs"
}

$processInfo.CreateNoWindow = $true;
$processInfo.UseShellExecute = $false;
$processInfo.RedirectStandardOutput = $true;
$process = [System.Diagnostics.Process]::Start($processInfo);
$process.StandardOutput.ReadToEnd();
$process.WaitForExit();

# https://learn.microsoft.com/microsoft-365/troubleshoot/administration/sara-command-line-version
# See the above article for possible ExitCode values

if($process.HasExited -and ($process.ExitCode -eq 0 -or ($process.ExitCode -eq 80) -or ($scenario="TeamsAddinScenario" -and $process.ExitCode -eq 23) -or ($scenario="OfficeSharedActivationScenario" -and $process.ExitCode -eq 63) -or ($scenario="OfficeActvationScenario" -and $process.ExitCode -eq 36) -or ($scenario="OutlookCalendarCheckTask" -and $process.ExitCode -eq 43) -or ($scenario="ExpertExperienceAdminTask" -and ($process.ExitCode -eq 01 -or $process.ExitCode -eq 02 -or $process.ExitCode -eq 3 -or $process.ExitCode -eq 66 -or $process.ExitCode -eq 67))))
{
$success = $true
}

$process.Dispose();

return $success;
}

Function Get-Scenario($arguments)
{
$scenario = ""

$args = $arguments.Split("-")

foreach ($arg in $args)
{
if ($arg.StartsWith("S ") -or $arg.StartsWith("s "))
{
$scenario = $arg.Split(" ")[1]
break;
}
}
return $scenario
}
#
# -------------------
# End Local Functions
# -------------------
#
# ------------
# Begin Script
# ------------
#

if(($SaraCmdSourcePath -eq "") -or ($SaraCmdSourcePath -eq $null))
{

Write-Host ">>>"
Write-Host ">>> A value for `$SaraCmdSourcPath has not be specified in the script."
exit
}

if (-not ($saracmdsourcepath -like "https*") -and -not (Test-Path $SaraCmdSourcePath))
{
Write-Host ">>>"
Write-Host ">>> The path specified for `$SaraCmdSourcePath: '$SaraCmdSourcePath' does not exist."
Write-Host ">>>"
Write-Host ">>> Please check the specified path and update `$SaraCmdSourcePath to point to a valid path."
Write-Host ">>>"
exit
}

if ($saracmdsourcepath -like "https*" -and -not($saracmdsourcepath -eq "https://aka.ms/SaRA_EnterpriseVersionFiles"))
{
Write-Host ">>>"
Write-Host ">>> https URL used, but the path ($SaraCmdSourcePath) specified for `$SaraCmdSourcePath is not correct."
Write-Host ">>>"
Write-Host ">>> Please update `$SaraCmdSourcePath to 'https://aka.ms/SaRA_EnterpriseVersionFiles'."
Write-Host ">>>"
exit
}

if (($SaraScenarioArgument -eq "") -or ($SaraScenarioArgument -eq $null))
{
Write-Host ">>>"
Write-Host ">>> `$SaraScenarioArgument is blank"
Write-Host ">>>"
Write-Host ">>> `$SaraScenarioArgument = $SaraScenarioArgument"
Write-Host ">>>"
Write-Host ">>> Please refer to the Configurable Variables section of the script for the `$SaraScenarioArgument variable"
exit
}


if (($currentTimeStamp -eq "") -or ($currentTimeStamp -eq $null))
{
Write-Host ">>>"
Write-Host ">>> `$currentTimeStamp is blank"
Write-Host ">>>"
Write-Host ">>> `$currentTimeStamp = $currentTimeStamp"
Write-Host ">>>"
Write-Host ">>> Please refer to the Configurable Variables section of the script for the `$currentTimeStamp variable"
exit
}

if (($resultsFileName -eq "") -or ($resultsFileName -eq $null))
{
Write-Host ">>>"
Write-Host ">>> `$resultsFileName is blank"
Write-Host ">>>"
Write-Host ">>> `$resultsFileName = $resultsFileName"
Write-Host ">>>"
Write-Host ">>> Please refer to the Configurable Variables section of the script for the `$resultsFileName variable"
exit
}

if ($SaraScenarioArgument -notlike "*-accepteula*")
{
Write-Host ">>>"
Write-Host ">>> Required switch -AcceptEula missing or misspelled in `$SaraScenarioArgument"
Write-Host ">>>"
Write-Host ">>> `$SaraScenarioArgument = $SaraScenarioArgument"
exit
}

if ($SaraScenarioArgument -notlike "*-script*")
{
Write-Host ">>>"
Write-Host ">>> Required switch -Script missing or misspelled in `$SaraScenarioArgument"
Write-Host ">>>"
Write-Host ">>> `$SaraScenarioArgument = $SaraScenarioArgument"
exit
}

if ($SaraScenarioArgument -notlike "*-s *")
{
Write-Host ">>>"
Write-Host ">>> Required switch -S missing in `$SaraScenarioArgument"
Write-Host ">>>"
Write-Host ">>> `$SaraScenarioArgument = $SaraScenarioArgument"
exit
}

$scenario = Get-Scenario($SaraScenarioArgument)


if ($scenario -notin "ExpertExperienceAdminTask", "OfficeActivationScenario", "OfficeScrubScenario", "TeamsAddinScenario", "OutlookCalendarCheckTask", "OfficeSharedComputerScenario", "ResetOfficeActivation")
{
Write-Host ">>>"
Write-Host ">>> The scenario name used for the -S switch in `$SaraScenarioArgument is not valid."
Write-Host ">>>"
Write-Host ">>> $SaraScenarioArgument = $SaraScenarioArgument"
Write-Host ">>>"
Write-Host ">>> Valid scenario names are: "
Write-Host ">>>"
Write-Host ">>> ExpertExperienceAdminTask, OfficeActivationScenario, OfficeScrubScenario, TeamsAddinScenario, "
Write-Host ">>> OutlookCalendarCheckTask, OfficeSharedComputerScenario, ResetOfficeActivation"
Write-Host ">>>"
write-Host ">>> See https://learn.microsoft.com/microsoft-365/troubleshoot/administration/sara-command-line-version for details."
exit
}

#
# Ensure the minimum required switches and parameters were used for the specified scenario
#
switch ($scenario)
{
ExpertExperienceAdminTask
{
# The required switches for this scenario are -S, -Script and -AcceptEula and there's a check for them elsewhere
}
OfficeActivationScenario
{
# Check for required -CloseOffice switch
if ($SaraScenarioArgument -notlike "*closeoffice*")
{
Write-Host ">>>"
Write-Host ">>> You specified the following switches and parameters:"
Write-Host ">>>"
Write-Host ">>> $SaraScenarioArgument"
Write-Host ">>>"
Write-Host ">>> The $scenario scenario requires the -CloseOffice switch"
Write-Host ">>>"
Write-Host ">>> Please see https://learn.microsoft.com/microsoft-365/troubleshoot/administration/assistant-office-activation for complete details"
exit
}
}
OfficeScrubScenario
{
# The required switches for this scenario are -S, -Script and -AcceptEula and there's a check for them elsewhere
}
TeamsAddinScenario
{
# Check for required -CloseOutlook switch
if ($SaraScenarioArgument -notlike "*closeoutlook*")
{
Write-Host ">>>"
Write-Host ">>> You specified the following switches and parameters:"
Write-Host ">>>"
Write-Host ">>> $SaraScenarioArgument"
Write-Host ">>>"
Write-Host ">>> The $scenario scenario requires the -CloseOutlook switch"
Write-Host ">>>"
Write-Host ">>> Please see https://learn.microsoft.com/microsoft-365/troubleshoot/administration/assistant-teams-meeting-add-in-outlook for complete details"
exit
}
}
OutlookCalendarCheckTask
{
# The required switches for this scenario are -S, -Script and -AcceptEula and there's a check for them elsewhere
}
OfficeSharedComputerScenario
{
# Check for required -CloseOffice switch
if ($SaraScenarioArgument -notlike "*closeoffice*")
{
Write-Host ">>>"
Write-Host ">>> You specified the following switches and parameters:"
Write-Host ">>>"
Write-Host ">>> $SaraScenarioArgument"
Write-Host ">>>"
Write-Host ">>> The $scenario scenario requires the -CloseOffice switch"
Write-Host ">>>"
Write-Host ">>> Please see https://learn.microsoft.com/microsoft-365/troubleshoot/administration/assistant-office-shared-computer-activation for complete details"
exit
}
}
ResetOfficeActivation
{
# Check for required -CloseOffice switch
if ($SaraScenarioArgument -notlike "*closeoffice*")
{
Write-Host ">>>"
Write-Host ">>> You specified the following switches and parameters:"
Write-Host ">>>"
Write-Host ">>> $SaraScenarioArgument"
Write-Host ">>>"
Write-Host ">>> The $scenario scenario requires the -CloseOffice switch"
Write-Host ">>>"
Write-Host ">>> Please see https://learn.microsoft.com/microsoft-365/troubleshoot/administration/assistant-reset-office-activation for complete details"
exit
}
}

}

try
{
Clean-InitialFiles
Create-LocalFolders
Write-Output "--------------------------------------------" | Out-File -FilePath $scriptLogFile # First log statement to create the file
}
catch
{
Write-Host ">>> Unable to create the local log file folders. You may not have permissions to write into this folder."
Write-Host ">>>"
Write-Host ">>> Execute this script in a different folder."
exit
}

$elevationNeeded = Check-AdminAccess($scenario)

if (($elevationNeeded -ne $true) -or (($elevationNeeded -eq $true) -and (Test-IsAdmin -eq $true)))
{
$resultsFileName = $resultsFileName.Replace("<scenario>", $scenario)
$resultsFilePath = $resultsFilePath.Replace("<scenario>", $scenario)

$executionSuccess = Execute-SaraCMD $SaraCmdSourcePath $SaraScenarioArgument

Write-Host ">>> SaraCmd.exe output"
Write-Host ""
Write-Host "SaRA Command Line script execution status: $executionSuccess"
Write-Host ""

Write-Output "SaRA Command Line script execution status: $executionSuccess" | Out-File -FilePath $scriptLogFile -Append
Write-Output "" | Out-File -FilePath $scriptLogFile -Append

if($executionSuccess -eq $true)
{
Write-Output ">>> Scenario execution completed successfully" | Out-File -FilePath $scriptLogFile -Append
Write-Host ">>> Scenario execution completed successfully"
}
else
{
Write-Output ">>> SaRA Commandline ran into a problem or had an error. Please check the SaraLog-<date>.log file for details." | Out-File -FilePath $scriptLogFile -Append
Write-Host ">>> SaRA Commandline ran into a problem or had an error. Please check the SaraLog-<date>.log files for details."
Write-Host ""
}

Copy-LogFiles
Create-LogArchive
Write-Output ">>> All Generated Logs are found at: $resultsFilePath"
}
else
{
Write-Host ""
Write-Host ">>> $scenario needs to be run with elevated privileges (Run As Administrator)"
Write-Host ">>> Execute this script from a new PowerShell window using 'Run As Administrator'"
Write-Host ""
}
Start-Process -FilePath "C:\Program Files\7-Zip\7z.exe" -ArgumentList "x -o$destinationFolder $archivePath" -Wait

Clean-LocalFiles
#
# ----------
# End script
# ----------
#
# ================
# End Main section
# ================
#