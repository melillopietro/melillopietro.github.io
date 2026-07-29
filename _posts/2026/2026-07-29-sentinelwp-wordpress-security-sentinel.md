---
layout: post
title: "SentinelWP: A Practical WordPress Security Assessment Platform"
date: 2026-07-29 11:00:00 +0200
categories: [Projects, Cybersecurity]
tags: [wordpress, security-assessment, web-security, vulnerability-management, python, flask, open-source, security-auditing]
---

## Abstract

WordPress security is rarely determined by a single issue. The real picture emerges from several signals: exposed files, outdated components, weak HTTP configuration, unnecessary public endpoints, insecure cookies, visible technical information, and operational choices that gradually increase the attack surface.

I developed **SentinelWP** to bring these checks together in one platform. It is an open-source WordPress security assessment and posture management tool designed to support structured, repeatable, and non-destructive analysis.

The project is available on GitHub:

[SentinelWP — WordPress Security Sentinel](https://github.com/melillopietro/SentinelWP)

---

## Why I Built SentinelWP

A WordPress assessment often starts with a simple question: *How exposed is this website?*

Answering it properly can require several tools, manual browser checks, command-line utilities, vulnerability database searches, and separate reporting activities. This works for individual tests, but it becomes difficult to repeat consistently across multiple websites or over time.

SentinelWP was created to make that process more manageable. The goal is not to replace professional penetration testing, but to provide a clear view of the security posture of a WordPress installation and highlight the areas that deserve closer attention.

The platform collects technical evidence, organizes findings by severity, calculates a risk score, and produces reports that can be used by both technical teams and decision-makers.

---

## Project at a Glance

| Area | Description |
| :--- | :--- |
| **Purpose** | WordPress security assessment and posture management |
| **Approach** | Non-destructive reconnaissance and configuration auditing |
| **Interface** | Web-based dashboard with live scan progress |
| **Scan profiles** | Passive, Safe-Active, and Full |
| **Vulnerability intelligence** | Plugin and theme matching through the OSV.dev API |
| **Reporting** | PDF, HTML, Excel, JSON, and SARIF |
| **Access control** | Administrator, Analyst, and Viewer roles |
| **Technology** | Python, Flask, Jinja2, SQLite, and background workers |
| **License** | MIT |

---

## Three Levels of Assessment

SentinelWP provides three scan profiles so that the level of interaction can be selected according to the assessment context.

### Passive

The passive profile analyses the homepage and publicly referenced assets without actively probing additional WordPress paths. It is intended for an initial, low-impact review.

### Safe-Active

The safe-active profile checks known WordPress endpoints and public files while avoiding destructive actions. It provides a broader view of the installation and its externally visible configuration.

### Full

The full profile includes the previous checks and adds a limited audit of common default credentials. The number of attempts is restricted to reduce unnecessary load and prevent uncontrolled authentication testing.

The selected profile should always reflect the authorization and scope of the assessment.

---

## What SentinelWP Looks For

The platform combines several forms of analysis rather than relying on a single WordPress fingerprint.

### WordPress Detection

SentinelWP evaluates multiple independent signals, including generator metadata, asset paths, REST API behaviour, cookies, and RSS references. These signals are combined into a confidence score, which helps distinguish a confirmed WordPress installation from a weak or ambiguous indication.

### Plugins, Themes, and Vulnerabilities

Plugins and themes can be identified from public page content without generating additional discovery requests. Detected components are then compared with vulnerability information obtained through the OSV.dev API.

This helps connect reconnaissance results with known security issues while keeping the collected evidence understandable and traceable.

### Exposed Files and Misconfigurations

The assessment includes checks for conditions such as:

- accessible backup copies of `wp-config.php`;
- public WordPress debug logs;
- directory listing;
- visible PHP errors;
- missing HTTPS redirection;
- unnecessary technical information exposed by the server.

These findings are often overlooked because they do not always appear as a single critical vulnerability. Together, however, they can reveal sensitive information or make later attacks easier.

### REST API and Cookie Security

SentinelWP inspects the public WordPress REST API, available namespaces, and exposed routes. User-related endpoints are handled with a privacy-first approach, without retaining personal data.

It also reviews cookie security attributes, including `Secure`, `HttpOnly`, and `SameSite`, which are important for protecting authenticated sessions.

### HTTP Security Headers

The platform checks the response headers that contribute to browser-side security and hardening. Missing or weak headers are presented as part of the wider posture rather than as isolated configuration details.

---

## From a Single Scan to Continuous Posture Management

A security review is useful, but a WordPress installation changes over time. Plugins are updated, themes are replaced, configurations are modified, and new vulnerabilities are disclosed.

For this reason, SentinelWP also supports scheduled assessments. Scans can be repeated every 12 hours, every 24 hours, or every seven days.

When a Critical or High severity finding is detected, the platform can send an alert through SMTP email or a webhook. Webhooks can be connected to collaboration platforms such as Slack or Microsoft Teams, as well as to custom endpoints.

This makes SentinelWP suitable not only for one-time assessments, but also for monitoring changes in the external security posture of authorized WordPress environments.

---

## Reporting and Integration

Assessment results can be exported in several formats:

- **PDF**, for formal and executive reporting;
- **HTML**, for portable browser-based review;
- **Excel**, for analysis and remediation tracking;
- **JSON**, for data processing and custom integrations;
- **SARIF 2.1.0**, for compatibility with development and CI/CD security workflows.

The objective is to make the same technical evidence useful in different contexts. An analyst may need the complete finding details, while a manager may need a concise view of risk, severity, and remediation priorities.

---

## Security by Design

Because SentinelWP performs security checks, its own operating model must avoid introducing unnecessary risk.

The current implementation includes:

- a first-run setup wizard with no default administrator credentials;
- role-based access control;
- rate limiting for login and scan requests;
- SSRF protection that blocks private networks, loopback addresses, and local hostnames;
- automatic redaction of credentials and secrets found in exposed configuration files;
- asynchronous scan execution with live progress tracking;
- a local SQLite database with WAL mode enabled.

These controls are part of the platform's design rather than optional additions.

---

## Architecture

SentinelWP uses a lightweight Python stack:

- **Flask** and **Jinja2** for the application and web interface;
- **SQLite** for scan, finding, user, and scheduling data;
- **ThreadPoolExecutor** for asynchronous scans;
- a background scheduler for recurring assessments;
- **ReportLab** for PDF generation;
- **OpenPyXL** for Excel reports;
- a dedicated SARIF generator for CI/CD integration.

The application can be installed locally with Python 3.10 or later.

```bash
git clone https://github.com/melillopietro/SentinelWP.git
cd SentinelWP

python3 -m venv .venv
source .venv/bin/activate
pip install -r requirements.txt

python3 app.py
```

After startup, the setup wizard is available at:

```text
http://localhost:8080/setup
```

---

## Intended Use

SentinelWP can support:

- security teams reviewing company-owned WordPress websites;
- consultants carrying out authorized assessments;
- administrators looking for configuration weaknesses and exposed resources;
- developers checking security posture before or after deployment;
- researchers studying WordPress attack surfaces and defensive controls.

It should only be used on systems that you own or for which you have explicit authorization to perform security testing.

---

## Open-Source Development

SentinelWP is released under the MIT License. The source code, installation instructions, and project documentation are available in the public repository:

[View SentinelWP on GitHub](https://github.com/melillopietro/SentinelWP)

The project will continue to evolve around practical WordPress assessment, repeatable evidence collection, safer testing methods, and reporting that connects technical findings with remediation decisions.

---

## Final Considerations

WordPress remains widely used because it is flexible and accessible, but that same flexibility creates a security posture that can change quickly. A secure installation depends on more than updating the core platform. Plugins, themes, public endpoints, server configuration, authentication controls, exposed files, and HTTP behaviour all contribute to the final level of risk.

SentinelWP brings these elements into a single assessment workflow. The purpose is straightforward: make WordPress exposure easier to understand, easier to review, and easier to address before a minor weakness becomes part of a larger incident.
