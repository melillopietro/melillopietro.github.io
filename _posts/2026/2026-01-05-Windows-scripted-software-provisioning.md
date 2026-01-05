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

---

## Design overview

The solution is composed of two files:

- **`Default.cmd`** – execution wrapper
- **`installer.ps1`** – PowerShell provisioning logic

---

## Execution wrapper (`Default.cmd`)

```bat
@echo off
setlocal enabledelayedexpansion

pushd "%~dp0" || exit /b 1
powershell.exe -NoProfile -ExecutionPolicy Bypass -File "%~dp0installer.ps1" %*
set "rc=%errorlevel%"
popd
exit /b %rc%
