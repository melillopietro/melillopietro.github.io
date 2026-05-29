# SetupHub v3.1

SetupHub is a Windows post-installation tool based on Microsoft WinGet / Windows Package Manager.
It provides software profiles, custom profiles, optional Windows app removal and final reporting.

## Main changes in v3.1

- Improved diagnostic reporting for failed installations.
- Captures WinGet stdout and stderr, because WinGet can write useful error details to stdout.
- Adds package verification before installation using `winget show`.
- Forces package resolution through an explicit source, default `winget`.
- Adds per-package WinGet log files in `reports/winget-logs`.
- Adds JSON report in addition to HTML, CSV and TXT log.
- Adds executed command, source, exit code and meaningful error summary to the report.

## How to run

Recommended:

```powershell
Set-ExecutionPolicy -Scope Process Bypass
.\SetupHub_Setup_v3.1.ps1
```

Optional launcher:

```cmd
Start_SetupHub_v3.1.cmd
```

The CMD file is not technically required. It is only a convenience launcher for users who prefer double-click startup.

## Report output

After execution, SetupHub creates files under `reports`:

- HTML report
- CSV report
- JSON diagnostic report
- TXT operation log
- per-package WinGet logs under `reports/winget-logs`

## Security note

SetupHub does not host installers directly. It invokes Microsoft WinGet and, by default, uses the explicit `winget` source. Package availability, package metadata, vendor URLs and license requirements are controlled by WinGet and the respective software publishers.

Some packages may fail when:

- the WinGet manifest is unavailable or renamed;
- the package requires interactive installation;
- the package requires a license or account, for example Microsoft 365 Apps / Office;
- the installer does not support silent mode;
- the app is Microsoft Store based and requires Store-specific handling;
- network, proxy, firewall, SmartScreen, TLS or permission issues block the download;
- the application is already installed in an incompatible version or scope.

## Author / Credits

Created by Pietro Melillo.
Powered by Microsoft WinGet / Windows Package Manager.
