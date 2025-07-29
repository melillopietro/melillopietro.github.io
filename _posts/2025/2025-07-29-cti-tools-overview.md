---
title: Essential Tools and Platforms for Cyber Threat Intelligence (CTI)
date: 2025-07-29
categories: [CTI, Tools, Resources]
tags: [Threat Intelligence, OSINT, CTI Platforms, Dark Web, IOC]
---

## 🧠 Introduction

This guide provides a curated list of the most relevant tools, platforms, and services for **Cyber Threat Intelligence (CTI)** analysts. The tools are categorized by functionality and provide references and descriptions to help you integrate them into your threat intelligence workflows.

---

## 🔍 Breach and Credential Leak Intelligence

### 🔐 [Have I Been Pwned (HIBP)](https://haveibeenpwned.com/)
- Checks if email addresses or domains have appeared in known data breaches.
- API available for automated checks and alerting.

### 🕵️ [LeakLooker](https://leaklooker.com/) *(when available)*
- Search engine for exposed data across paste sites and misconfigured services.
- Useful for identifying leaked credentials and documents.

### 🔦 [Hudson Rock – Cavalier](https://cavalier.hudsonrock.com/)
- Tracks infected devices and stolen credentials via infostealers.
- Offers organizational visibility into compromised employees, assets, and third-party risks.

### 🌐 [Dehashed](https://www.dehashed.com/)
- Breach database search engine.
- Supports IPs, emails, usernames, hashes, domains, and more.

### 🔍 [LeakPeak](https://leak-peak.com/)
- Provides visibility into infostealer logs, credentials, and files.
- Enables domain monitoring and IOC enrichment.

---

## 🕸️ Dark Web Monitoring & Marketplace Intelligence

### 🌑 [DarkOwl Vision](https://www.darkowl.com/products/vision/)
- Real-time and historical darknet data access for threat hunting.
- API and dashboard access to indexed darknet marketplaces and forums.

### 🕷️ [IntSights (now Rapid7 Threat Command)](https://www.rapid7.com/products/threat-command/)
- Dark web intelligence platform with alerting, brand protection, and fraud detection.
- Integrated with external monitoring and remediation workflows.

### 🧭 [CyberSixgill](https://www.cybersixgill.com/)
- Deep and dark web monitoring with automated alerting and contextual analysis.
- Threat actor profiling, CVE exploitation tracking, and TTP mapping.

---

## 🧰 General CTI Platforms & Enrichment Services

### 📚 [MISP – Malware Information Sharing Platform](https://www.misp-project.org/)
- Open-source threat intelligence sharing platform.
- Supports structured data (IOCs, TTPs) and collaborative sharing between orgs.

### 🧱 [AlienVault OTX](https://otx.alienvault.com/)
- Free threat intelligence community platform.
- Allows users to submit and consume pulse-based indicators (IPs, domains, hashes).

### 🔧 [VirusTotal](https://www.virustotal.com/)
- Aggregates antivirus scan results, network behavior, and metadata for files and URLs.
- Widely used for quick triage and IOC analysis.

### 🧠 [Recorded Future](https://www.recordedfuture.com/)
- Commercial threat intelligence platform with real-time alerting, graph analysis, and risk scoring.
- Covers technical, operational, and strategic CTI.

### 💡 [Shodan](https://www.shodan.io/)
- Search engine for Internet-connected devices.
- Used for infrastructure fingerprinting and exposure assessment.

---

## 🧪 Malware, Infrastructure & IOC Analysis

### 🧬 [Any.run](https://any.run/)
- Interactive malware sandbox for dynamic analysis.
- Supports PE, Office files, scripts, and more.

### 🕸️ [MalwareBazaar](https://bazaar.abuse.ch/)
- IOC repository focused on malware samples and YARA rules.
- Maintained by abuse.ch.

### 🌍 [ThreatFox](https://threatfox.abuse.ch/)
- Aggregated repository of threat intelligence IOCs.
- Strong focus on real-time feeds and community submissions.

---

## 🧠 Threat Actor & Campaign Intelligence

### 🧑‍💻 [MITRE ATT&CK](https://attack.mitre.org/)
- Knowledge base of adversary tactics and techniques.
- Used for mapping threat actor behaviors and detection engineering.

### 🔬 [APT & Threat Group Index – Malpedia](https://malpedia.caad.fkie.fraunhofer.de/)
- Profiles of APT groups and malware families.
- Focus on linking tools, actors, and campaigns.

---

## ✅ Conclusion

This collection represents a solid foundation for building or enriching a CTI workflow across strategic, operational, and tactical levels. Integration and automation with platforms such as MISP, TheHive, or custom dashboards can elevate these tools into a powerful intelligence ecosystem.

