# Windows_Automation
## Table of Contents

- [Prerequisites](#prerequisites)
- [Description](#description)
- [Installation](#installation)
- [Usage](#usage)
  - [Option one: _(Recommended)_](#option-one-recommended)
  - [Option two: _(Single script)_](#option-two-single-script)
- [Folder Descriptions](#folder-descriptions)
- [Contributing](#contributing)
- [License](#license)

## Prerequisites

Before you begin, ensure you have met the following requirements:
* You have installed the latest version of `PowerShell`
* You have a `Windows` machine.
* Optional: You have installed the latest version of `Chocolatey`

## Description

A collection of scripts I've made to automate various tasks on Windows. These scripts vary from setting up a new machine or user to troubleshooting various issues. 

## Installation

1. Clone the repository

```shell
git clone https://github.com/VinnyVanGogh/Windows_Automation.git
```

2. Install Chocolatey (optional)

```powershell
Set-ExecutionPolicy Bypass -Scope Process -Force
[System.Net.ServicePointManager]::SecurityProtocol = [System.Net.SecurityProtocolType]::Tls12
Invoke-Expression ((New-Object System.Net.WebClient).DownloadString('https://community.chocolatey.org/install.ps1'))
```

## Usage

### **Option one:** _(Recommended)_
  - Follow the commands below to be able to run multiple scripts

**_Check the current execution policy_**

```powershell
Get-ExecutionPolicy
```

**_Set the execution policy to remote signed_**

```powershell
Set-ExecutionPolicy RemoteSigned
```

**_Run the script_**

```shell
cd "C:\path\to\script"
.\Script.ps1 # optionally add arguments as required by the script ex. .\Script.ps1 -Argument1 "Value1" -Argument2 "Value2"
```

### **Option two:** _(Single script)_
  - Run the script from the command line (this will not change the execution policy)

**_Run the script from the command line, bypassing the execution policy_**

```powershell
Start-Process PowerShell -ArgumentList "-NoProfile -ExecutionPolicy Bypass -File C:\Path\To\Your\Script.ps1"
```

## Folder Descriptions

[ACTIVE_DIRECTORY](ACTIVE_DIRECTORY/)

- Scripts for managing Active Directory
  - These scripts are meant to keep track of users and their attributes, or modify them in AD or Azure

[CHOCOLATEY](CHOCOLATEY/)

- Scripts for installing and uninstalling software using Chocolatey
  - I will also be working on building more of my own packages

[FILE_MANAGEMENT](FILE_MANAGEMENT/)

- Scripts for managing files and folders
  - These scripts are meant to keep track of files and folders, or modify them such as copying, moving, or deleting them

[NETWORKING](NETWORKING/)

- Scripts for managing network settings
  - These scripts are meant to keep track of network settings, or modify them such as changing the DNS server or IP address
  - There are also various other scripts for troubleshooting network issues

[INSTALLERS](INSTALLERS/)

- Scripts for installing software
  - These scripts are meant to install software that is not available through Chocolatey

[UNINSTALLERS](UNINSTALLERS/)

- Scripts for uninstalling software
  - These scripts are meant to uninstall software that is not available through Chocolatey
  - there are also various other scripts due to some clients not having things installed through Chocolatey

[ONBOARDING](ONBOARDING/)

- Various scripts for my job as an onboarding analyst
  - These scripts are meant to automate the process of onboarding a new company/client
  - there are also various other scripts for troubleshooting issues that may arise during the onboarding process

[QUICK_FIXES](QUICK_FIXES/)

- Various scripts for quick fixes
  - These scripts are meant to fix various issues that may arise on a machine
  - These scripts are meant to be run on a single machine, not multiple machines at once  

[REGISTRY](REGISTRY/)

- Scripts for managing the registry
  - These scripts are meant to keep track of registry keys, or modify them such as adding or removing them
  - These are meant to automate and simplify the process of regedits that consistently need to be done

[WORKSTATION_CONFIGURATION](WORKSTATION_CONFIGURATION/)
- Scripts for configuring workstations
  - These scripts are meant to automate the process of configuring a new workstation
  - These scripts are more so meant to have their functions used in other scripts, but can be run on their own if desired

## Contributing

To contribute to Windows_Automation, follow these steps:
1. Fork this repository.
2. Create a branch: \`git checkout -b <branch_name>\`.
3. Make your changes and commit them: \`git commit -m '<commit_message>'\`
4. Send a message detailing the branch you've created and the changes you've made.

## License

This collection of scripts is licensed under the [MIT License](LICENSE).

-[Back to top](#windows_automation)-

