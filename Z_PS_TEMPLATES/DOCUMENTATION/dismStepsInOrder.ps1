# Basic
# first
sfc /scannow

    # If corruption
    DISM /Online /Cleanup-Image /CheckHealth && DISM /Online /Cleanup-Image /ScanHealth

        # If corruption 
        DISM /Online /Cleanup-Image /RestoreHealth

            # Check Integrity without attempting to fix
            sfc /verifyonly

# If First steps are still failing            
# If restore fails, followed by restore again
DISM.exe /Online /Cleanup-Image /StartComponentCleanup

    # Check Integrity without attempting to fix
    sfc /verifyonly

# If this still fails
# Get info on the ISO you will need
wmic os get Caption, Version, ServicePackMajorVersion, OSArchitecture, BootDevice

    # Get info from the .wim file on which source to use
    DISM /Get-WimInfo /WimFile:G:\sources\install.wim

        # If wim is in sources on the iso Server 2016 standard (desktop experience)
        DISM /Online /Cleanup-Image /RestoreHealth /Source:WIM:G:\sources\install.wim:2 /LimitAccess

# Check Integrity without attempting to fix
sfc /verifyonly

    # if ISO has .esd not .wim in Sources;
    # If Restore fails and ISO has .esd not .wim
    DISM /Export-Image /SourceImageFile:G:\install.esd /SourceIndex:2 /DestinationImageFile:C:\TeamAccent\install.wim /Compress:max /CheckIntegrity

                # Once you have .wim in the ISO
                DISM /Online /Cleanup-Image /RestoreHealth /Source:C:\TeamAccent\install.wim:2 /LimitAccess

                # Check Integrity without attempting to fix
                sfc /verifyonly
                # End if ISO has .esd not .wim in Sources;