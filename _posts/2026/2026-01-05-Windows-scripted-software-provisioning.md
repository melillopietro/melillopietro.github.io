---
layout: post
title: "Script-based software provisioning on Windows using PowerShell and WinGet"
date: 2026-01-05 09:00:00 +0100
categories: [Engineering, Windows]
tags: [PowerShell, WinGet, Automation, Windows, IT Governance]
---

## Abstract

In operational Windows environments, manual software installation remains a recurring source of inconsistency, operational overhead, and configuration drift.  
This article presents a lightweight, script-based approach for controlled software provisioning on Windows systems, leveraging native tooling such as **PowerShell** and **WinGet**.

---

## Overview

The solution is composed of two files:

- **`Default.cmd`** – execution wrapper  
- **`installer.ps1`** – PowerShell provisioning logic

The design prioritizes transparency, repeatability, and operational control.

---

## Downloads

The implementation can be downloaded directly from the links below:

- **Default.cmd**  
  https://melillopietro.github.io/assets/files/Default.cmd

- **installer.ps1**  
  https://melillopietro.github.io/assets/files/installer.ps1

---

## Usage notes

The scripts are provided as-is for educational and operational purposes.  
Review and adapt them according to your security, governance, and compliance requirements before use.

---

## Conclusion

This script-based approach demonstrates how native Windows tooling can be used to implement controlled and repeatable software provisioning workflows without relying on external frameworks or management platforms.
