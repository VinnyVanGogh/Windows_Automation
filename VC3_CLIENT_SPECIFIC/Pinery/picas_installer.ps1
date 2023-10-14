#expand-archive
net use z: \\PIAPP01\Progress_Client

if(-not(Test-Path -Path "C:\\picasInstaller")) {
    New-Item -ItemType Directory -Path "C:\\picasInstaller"
}

Robocopy Z:\OEMedia C:\picasInstaller PROGRESS_OE_11.7.3_WIN_32.zip

Expand-Archive -Path "C:\picasInstaller\PROGRESS_OE_11.7.3_WIN_32.zip" -DestinationPath "C:\picasInstaller"

Start-Process -FilePath "C:\picasInstaller\setup.exe" -Verb RunAs

# created by - vinny vasile
#7zip
net use z: \\PIAPP01\Progress_Client

if(-not(Test-Path -Path "C:\\picasInstaller")) {
    New-Item -ItemType Directory -Path "C:\\picasInstaller"
}

Robocopy Z:\OEMedia C:\picasInstaller PROGRESS_OE_11.7.3_WIN_32.zip

Start-Process -FilePath "7z" -ArgumentList "x -y `"-oC:\picasInstaller`" `"-i!C:\picasInstaller\PROGRESS_OE_11.7.3_WIN_32.zip`"" -Wait -NoNewWindow

Start-Process -FilePath "C:\picasInstaller\setup.exe" -Verb RunAs
# created by - vinny vasile



net use z: \\PIAPP01\Progress_Client

if(-not(Test-Path -Path "C:\\picasInstaller")) {
    New-Item -ItemType Directory -Path "C:\\picasInstaller"
}

Robocopy Z:\OEMedia C:\picasInstaller PROGRESS_OE_11.7.3_WIN_32.zip

Expand-Archive -Path "C:\\picasInstaller\\PROGRESS_OE_11.7.3_WIN_32.zip" -DestinationPath "C:\\picasInstaller"

Start-Process -FilePath "C:\\picasInstaller\\setup.exe" -Verb RunAs

