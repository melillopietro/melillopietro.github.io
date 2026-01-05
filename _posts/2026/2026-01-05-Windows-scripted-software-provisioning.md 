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

The proposed solution focuses on repeatability, transparency, and auditability, making it suitable for laboratory environments, controlled workstations, and small-scale managed deployments.

---

## Design overview

The solution is intentionally composed of two files, each with a clearly defined responsibility:

- **`Default.cmd`**  
  A minimal wrapper responsible for orchestrating execution and ensuring compatibility across Windows environments where direct PowerShell execution may be restricted.

- **`installer.ps1`**  
  The core PowerShell script implementing system checks, privilege handling, WinGet bootstrap, software installation, and optional debloating logic.

This separation allows the execution flow to remain explicit and predictable, avoiding hidden dependencies or implicit behaviors.

---

## Execution wrapper (`Default.cmd`)

The CMD wrapper acts as an entry point and ensures that the PowerShell script is executed from a consistent working directory while preserving command-line arguments.

```bat
@echo off
setlocal enabledelayedexpansion

pushd "%~dp0" || exit /b 1

powershell.exe -NoProfile -ExecutionPolicy Bypass -File "%~dp0installer.ps1" %*

set "rc=%errorlevel%"
popd
exit /b %rc%
