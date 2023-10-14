# Download the Office Deployment Tool
$ODTPath = "C:\ODT"
$ODTUrl = "https://download.microsoft.com/download/2/7/A/27AF1BE6-DD20-4CB4-B154-EBAB8A7D4A7E/officedeploymenttool_16501-20196.exe" # Replace ***** with the latest ODT download link
$ODTZip = "$ODTPath\ODT.zip"

# Create the ODT folder
New-Item -ItemType Directory -Force -Path $ODTPath | Out-Null

# Download ODT
Invoke-WebRequest -Uri $ODTUrl -OutFile $ODTZip

# Extract ODT
Expand-Archive -Path $ODTZip -DestinationPath $ODTPath

# Specify the installation configuration XML
$ConfigXmlPath = "$ODTPath\configuration.xml"

# Create the installation configuration XML
@"
<Configuration>
  <Add OfficeClientEdition="64" Channel="Broad">
    <Product ID="O365ProPlusRetail">
      <Language ID="en-us" />
      <ExcludeApp ID="OneNote" />
    </Product>
    <Product ID="VisioProRetail">
      <Language ID="en-us" />
    </Product>
  </Add>
  <Updates Enabled="TRUE" />
  <Display Level="None" AcceptEULA="TRUE" />
  <Property Name="AUTOACTIVATE" Value="1" />
</Configuration>
"@ | Set-Content -Path $ConfigXmlPath

# Install Microsoft 365 Business Pro with Visio
Start-Process -Wait -FilePath "$ODTPath\setup.exe" -ArgumentList "/configure", "$ConfigXmlPath"
