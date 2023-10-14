# Windows_Automation
## Table of Contents

- [Prerequisites](#prerequisites)
- [Description](#description)
- [Installation](#installation)
- [Usage](#usage)
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

**Option one:** _(Recommended)_
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

**Option two:** _(Single script)_
  - Run the script from the command line (this will not change the execution policy)

**_Run the script from the command line, bypassing the execution policy_**

```powershell
Start-Process PowerShell -ArgumentList "-NoProfile -ExecutionPolicy Bypass -File C:\Path\To\Your\Script.ps1"
```

## Contributing

To contribute to Windows_Automation, follow these steps:
1. Fork this repository.
2. Create a branch: \`git checkout -b <branch_name>\`.
3. Make your changes and commit them: \`git commit -m '<commit_message>'\`
4. Send a message detailing the branch you've created and the changes you've made.

## License

This collection of scripts is licensed under the [MIT License](LICENSE).



