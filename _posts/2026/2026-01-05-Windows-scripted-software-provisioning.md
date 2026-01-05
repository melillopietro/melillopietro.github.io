---
layout: post
title: "Script-based software provisioning on Windows using PowerShell and WinGet"
date: 2026-01-05 09:00:00 +0100
categories: [Engineering, Windows]
tags: [PowerShell, WinGet, Automation, Windows, IT Governance]
---

## Abstract

In operational Windows environments, manual software installation remains a recurring source of inconsistency, operational overhead, and configuration drift.  
This article presents a lightweight, script-based approach for controlled software provisioning on Windows systems, leveraging native tooling such as **PowerShell** and **WinGet**, without introducing external frameworks or management platforms.

The proposed solution emphasizes repeatability, transparency, and auditability, making it suitable for laboratory environments, controlled workstations, and small-scale managed deployments.

---

## Design overview

The solution is intentionally composed of two files, each with a clearly defined responsibility:

- **`Default.cmd`**  
  A minimal execution wrapper responsible for orchestrating script execution and ensuring compatibility across Windows environments where direct PowerShell execution may be restricted.

- **`installer.ps1`**  
  The core PowerShell script implementing system checks, privilege handling, WinGet bootstrap, software installation, and optional debloating logic.

This separation keeps the execution flow explicit and predictable, avoiding hidden dependencies or implicit behaviors.

---

## Execution wrapper (`Default.cmd`)

The CMD wrapper acts as the entry point and ensures that the PowerShell script is executed from a consistent working directory while preserving command-line arguments.

```bat
@echo off
setlocal enabledelayedexpansion

pushd "%~dp0" || exit /b 1

powershell.exe -NoProfile -ExecutionPolicy Bypass -File "%~dp0installer.ps1" %*

set "rc=%errorlevel%"
popd
exit /b %rc%

The complete implementation is available for direct download below.

<div class="d-flex flex-wrap gap-2 my-4"> <a href="/assets/files/Default.cmd" class="btn btn-outline-primary btn-sm" download> ⬇ Download Default.cmd </a> <a href="/assets/files/installer.ps1" class="btn btn-outline-primary btn-sm" download> ⬇ Download installer.ps1 </a> </div>
