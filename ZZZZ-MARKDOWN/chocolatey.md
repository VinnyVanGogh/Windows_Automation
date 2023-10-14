# Chocolatey Cheatsheet

## Installation

Firstly, if you haven't installed Chocolatey yet, open PowerShell as an administrator and run:

```powershell
Set-ExecutionPolicy Bypass -Scope Process -Force; [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072; iex ((New-Object System.Net.WebClient).DownloadString('https://chocolatey.org/install.ps1'))
```

---

## Basic Commands

### Search for a Package

```powershell
choco search <package_name>
```

### Install a Package

```powershell
choco install <package_name>
```

#### Options:

- `-y`: Automatically confirm any prompts
- `-version <specific_version>`: Install a specific version

### Upgrade a Package

```powershell
choco upgrade <package_name>
```

#### Options:

- `-y`: Automatically confirm any prompts
- `-version <specific_version>`: Upgrade to a specific version

### Uninstall a Package

```powershell
choco uninstall <package_name>
```

#### Options:

- `-y`: Automatically confirm any prompts

---

## Advanced Commands

### List Installed Packages

```powershell
choco list --local-only
```

### Pin a Package

Prevent a package from being upgraded.

```powershell
choco pin add -n=<package_name>
```

### Unpin a Package

Allow a pinned package to be upgraded.

```powershell
choco pin remove -n=<package_name>
```

### Install Multiple Packages

```powershell
choco install <package1> <package2> ... <packageN>
```

### Configure Proxies

```powershell
choco config set proxy <address>
choco config set proxyUser <username>
choco config set proxyPassword <password>
```

---

## Automation and Scripts

Given your background, you might want to automate the package installation process, perhaps for setting up development environments. You can create a PowerShell script like:

```powershell
$packages = @("git", "nodejs", "vscode")
foreach ($package in $packages) {
    choco install $package -y
}
```

This will automatically install Git, Node.js, and VSCode without requiring manual confirmation.
