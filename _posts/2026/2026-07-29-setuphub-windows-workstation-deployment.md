---
layout: post
title: "SetupHub: A Practical Way to Prepare Windows Workstations"
date: 2026-07-29 11:24:00 +0200
categories: [Projects, System Administration]
tags: [windows, powershell, winget, workstation-deployment, automation, software-management, system-inventory, open-source]
---

## Abstract

Preparing a Windows workstation usually involves the same sequence of tasks: installing a familiar set of applications, removing unwanted preinstalled software, checking the machine configuration, and documenting what was changed.

The individual steps are not particularly difficult. The problem is making the process consistent, repeatable, and easy to review when more than one workstation is involved.

I developed **SetupHub** to bring these activities into a single graphical workflow. It is an open-source tool for Windows 10 and Windows 11 that combines software deployment through WinGet, reusable workstation profiles, optional bloatware cleanup, package validation, system inventory, and deployment reporting.

The project is available on GitHub:

[SetupHub — Windows Workstation Setup and Deployment](https://github.com/melillopietro/SetupHub)

---

## The Problem Behind the Project

A newly installed Windows machine is rarely ready for immediate use.

It may need a browser, office applications, collaboration tools, developer utilities, security software, remote support tools, or applications required for a specific role. At the same time, the default installation may contain software that is not needed in the intended environment.

These activities are often completed manually. An administrator downloads one installer after another, removes a few applications, checks the hardware, and moves on to the next device. The workstation may be usable at the end, but there is not always a clear record of what succeeded, what failed, what was skipped, or which package was unavailable.

SetupHub was created for this practical situation. Its purpose is to reduce repetitive work while keeping the deployment visible and under the operator's control.

---

## What SetupHub Does

SetupHub provides a graphical interface for preparing Windows workstations.

It can:

- install applications through WinGet and Microsoft Store package sources;
- apply predefined software profiles;
- create and save custom profiles;
- validate package availability before installation;
- remove selected Windows Appx and provisioned packages;
- collect hardware and software inventory;
- produce timestamped deployment reports;
- record applications that require manual installation.

The tool does not include third-party installers in the repository. Software is resolved through the package sources configured on the workstation.

This keeps the project easier to inspect and avoids maintaining a separate archive of vendor installation files.

---

## Project at a Glance

| Area | Description |
| :--- | :--- |
| **Purpose** | Windows workstation preparation and software deployment |
| **Supported systems** | Windows 10 and Windows 11 |
| **Interface** | PowerShell WPF graphical interface |
| **Package sources** | WinGet and Microsoft Store |
| **Languages** | English and Italian |
| **Profiles** | Predefined and user-created workstation profiles |
| **Cleanup** | Optional removal of selected preinstalled Windows apps |
| **Inventory** | Hardware, operating system, security, network, and installed software |
| **Reports** | HTML, CSV, JSON, and text |
| **License** | GNU GPL v3.0 only |

---

## Workstation Profiles

Different users need different machines.

A basic office workstation should not necessarily receive the same software as a development machine or a cybersecurity analysis workstation. Installing every available application would make the deployment slower and produce systems that are unnecessarily complex.

SetupHub uses profiles to solve this problem.

The predefined profiles cover common scenarios such as:

- essential workstation setup;
- business use;
- software development;
- cybersecurity analysis;
- multimedia work;
- gaming;
- home use;
- clean or complete installations.

A profile is simply a reusable software selection. The operator can apply one of the existing profiles, review the selected applications, make changes, and then start the deployment.

Custom profiles can also be created directly from the interface. They are stored locally in the `profiles` directory and can be reused when another workstation requires the same configuration.

This is useful when a team wants a practical level of standardization without introducing a larger endpoint management platform.

---

## Live Package Validation

Package identifiers do not remain stable forever.

An application may be renamed, removed from a source, replaced by another package, or temporarily unavailable. A deployment process that assumes every identifier is valid can produce misleading failures.

SetupHub validates the selected software catalog before installation. It checks whether each supported package can be resolved through the configured WinGet or Microsoft Store source.

A package that cannot be resolved is reported separately rather than being counted as an installation failure.

This distinction matters. There is a difference between an installation that genuinely failed and a package that was not available from the expected source at the time of deployment.

By recording those situations separately, the final report provides a more accurate account of the workstation preparation process.

---

## Software Installation Through WinGet

SetupHub uses WinGet as its main software deployment mechanism.

The catalog groups applications into practical categories, including:

- browsers and communication tools;
- office and productivity software;
- developer tools;
- cybersecurity utilities;
- remote support applications;
- multimedia software;
- virtualization tools;
- system utilities.

The operator remains responsible for reviewing the selected applications before starting the deployment.

Some products may require a Microsoft account, a commercial licence, a vendor account, specific hardware, or an interactive installation process controlled by the publisher. SetupHub does not attempt to bypass those requirements.

---

## Handling Software That Cannot Be Automated Reliably

Not every application is suitable for unattended installation.

Some tools are distributed through vendor portals, require account authentication, depend on particular hardware, use portable archives, or do not have a reliable WinGet package.

SetupHub keeps these applications in a **Manual / Unsupported** section.

They are documented in the report but are not treated as failed deployments. This prevents the automation from presenting an incomplete or vendor-restricted installation as a technical error.

The approach is deliberately conservative: software should only be automated when the package source and installation method are sufficiently predictable.

---

## Bloatware Cleanup

SetupHub can remove selected Windows preinstalled applications through Appx and provisioned package checks.

The cleanup process first determines whether the selected package is actually present. When it exists, SetupHub attempts to remove it. When it is already absent, the result is recorded as skipped or already removed.

This avoids false failures on machines that:

- use different Windows editions;
- were prepared from an OEM image;
- have already been cleaned;
- do not include a particular preinstalled application.

Bloatware removal remains optional. The operator can review the cleanup selection before making changes to the machine.

---

## Hardware and Software Inventory

Installing applications is only part of workstation preparation.

A useful deployment record should also describe the machine on which those changes were made. SetupHub therefore collects hardware and software inventory during each run.

The inventory can include:

- Windows version and build;
- processor information;
- installed memory;
- disks and volumes;
- graphics hardware;
- network adapters;
- TPM status;
- Secure Boot status;
- Microsoft Defender status;
- PowerShell and WinGet versions;
- installed desktop software.

This information helps confirm that the workstation meets the expected baseline and provides useful context when the deployment report is reviewed later.

---

## Deployment Reporting

Every SetupHub run creates a timestamped set of reports in the local `reports` directory.

The generated output can include:

```text
SetupHub_Report_<timestamp>.html
SetupHub_Report_<timestamp>.csv
SetupHub_Report_<timestamp>.json
SetupHub_Log_<timestamp>.txt
SetupHub_SystemInventory_<timestamp>.json
SetupHub_InstalledSoftware_<timestamp>.csv
SetupHub_CatalogAudit_<timestamp>.json
SetupHub_CatalogAudit_<timestamp>.csv
SetupHub_ManualUnsupported_<timestamp>.json
SetupHub_ManualUnsupported_<timestamp>.csv
```

The reports record:

- installation results;
- catalog validation status;
- cleanup results;
- executed commands;
- process exit codes;
- WinGet logs, where available;
- hardware and operating system information;
- installed software inventory;
- packages requiring manual handling.

The HTML report provides an immediate overview, while CSV and JSON outputs are more suitable for later analysis or integration into another workflow.

Generated reports remain local and are excluded from the repository because they may contain machine-specific information.

---

## Protecting Workstation Information

System inventory can contain sensitive data.

Hostnames, usernames, network addresses, MAC addresses, serial numbers, local file paths, and information about installed security controls should not be published without review.

SetupHub reports are intended to support deployment and internal documentation. Before sharing a report outside the intended environment, sensitive workstation details should be removed or anonymized.

This is especially important when screenshots or reports are used in public documentation, support requests, or project presentations.

---

## Requirements

SetupHub is designed for:

- Windows 10 build 18363 or later;
- Windows 11;
- PowerShell 5.1 or later;
- administrator privileges;
- WinGet;
- access to Microsoft Store sources when Store packages are selected;
- internet connectivity for validation and package download.

Because the tool installs applications and can remove Windows packages, it should first be tested on a non-critical machine.

---

## Getting Started

Clone or download the repository and open an elevated PowerShell session.

```powershell
powershell.exe -NoProfile -ExecutionPolicy Bypass -File .\SetupHub_Setup.ps1
```

The included launcher can also be used:

```cmd
Start_SetupHub.cmd
```

When SetupHub starts, the recommended workflow is:

1. choose the interface language;
2. select a predefined profile or create a custom one;
3. review the software selection;
4. review the optional cleanup selection;
5. start the deployment;
6. allow the catalog validation and installation phases to complete;
7. review the generated inventory and reports.

SetupHub requests elevation when it is not already running with administrator privileges.

---

## Design Choices

Several decisions shaped the first public release of SetupHub.

The project uses PowerShell and WPF because they are already available in the Windows administrative environment. WinGet and Microsoft Store remain responsible for obtaining software, rather than the repository acting as a software distribution point.

Package validation takes place before deployment because catalog availability changes over time. Manual and unsupported applications are documented rather than forced into unreliable automation. Cleanup results distinguish between actual failures and applications that were already absent.

These choices are intended to keep the workflow understandable. The operator can see what the tool plans to do, what it actually did, and what still requires manual attention.

---

## Intended Use

SetupHub can support:

- IT administrators preparing newly installed Windows machines;
- small teams that need reusable workstation configurations;
- technical laboratories and training environments;
- developers building consistent local workstations;
- cybersecurity professionals preparing analysis systems;
- users who want a documented alternative to installing applications one by one.

It is not a replacement for enterprise endpoint management, configuration management, or software distribution platforms. It is a lightweight option for situations where a local, transparent, and repeatable setup process is more appropriate.

---

## Open-Source Release

SetupHub v1.0 is released under the **GNU General Public License v3.0 only**.

The source code, documentation, screenshots, profiles, and contribution guidelines are available in the public repository:

[View SetupHub on GitHub](https://github.com/melillopietro/SetupHub)

The licence allows the project to be used, studied, shared, and modified. Distributed modifications must remain under the same GPL-3.0-only licence, with the corresponding source code available.

---

## Final Considerations

Workstation setup is often treated as a collection of small manual tasks. The real difficulty appears when the same work has to be repeated, explained, or verified.

SetupHub turns that sequence into a documented workflow. Software selection is based on reusable profiles, package availability is checked before installation, cleanup is handled carefully, and each run leaves behind an inventory and a set of reports.

The purpose is not to remove human control from workstation preparation. It is to make the work easier to repeat and easier to understand.
