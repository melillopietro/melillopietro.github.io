# SetupHub v3.2

SetupHub is a bilingual Windows post-installation tool for software deployment, software profiles, bloatware removal and final reporting.

## Main changes in v3.2

- Added/verified NordVPN from winget.run: `NordVPN.NordVPN`.
- Added alternate NordVPN manifest fallback: `NordSecurity.NordVPN`.
- Added/verified VMware Workstation Pro from winget.run: `VMware.WorkstationPro`.
- Added VMware Workstation Player: `VMware.WorkstationPlayer`.
- Added `ResolvedId` in the installation report to show the final WinGet ID actually used.
- Added `SetupHub_CatalogValidator_v3.2.ps1`, a dedicated validator that checks all SetupHub WinGet package IDs before deployment.
- Improved reporting for renamed or unavailable manifests.

## How to start SetupHub

Run:

```cmd
Start_SetupHub_v3.2.cmd
```

or directly:

```powershell
powershell.exe -NoProfile -ExecutionPolicy Bypass -File .\SetupHub_Setup_v3.2.ps1
```

## How to validate the catalog before installation

From the SetupHub folder, run:

```powershell
powershell.exe -NoProfile -ExecutionPolicy Bypass -File .\SetupHub_CatalogValidator_v3.2.ps1
```

The validator runs:

```powershell
winget show --id "PACKAGE.ID" --exact --source winget
```

for each software entry and creates reports under the `reports` folder:

- CSV
- JSON
- HTML

This allows you to identify which package IDs are currently available on the local WinGet source before starting installations.

## Important notes

WinGet package availability changes over time. A package can exist on winget.run but fail during installation because of vendor-side changes, installer hash mismatch, licensing requirements, proxy/firewall restrictions, pending reboot, antivirus/SmartScreen, or silent-install incompatibility.

VMware Workstation Pro may be more fragile than typical packages because VMware/Broadcom download flows and installer behavior have changed over time. SetupHub includes VMware Workstation Player as an alternative entry.

Microsoft Office / Microsoft 365 may require a valid Microsoft account, license, tenant policy, or Office Deployment Tool configuration.

## CMD file

The `.cmd` file is not required. It is only a convenient launcher for double-click execution. The main logic is inside `SetupHub_Setup_v3.2.ps1`.
