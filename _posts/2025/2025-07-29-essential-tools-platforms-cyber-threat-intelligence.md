---
layout: post
title: "Essential Tools and Platforms for Cyber Threat Intelligence"
date: 2025-07-29 09:00:00 +0200
categories: [Guides, Tools]
tags: [threat-intelligence, osint, cti-platforms, dark-web, ioc, tools]
---

## Introduction

A Cyber Threat Intelligence workflow depends on the ability to collect, enrich, validate, and contextualize heterogeneous evidence. No single platform is sufficient on its own: effective CTI usually combines breach intelligence, malware analysis, infrastructure monitoring, dark web visibility, and structured intelligence sharing.

This guide provides a curated overview of tools and platforms that can support analysts across tactical, operational, and strategic intelligence activities.

---

## Breach and Credential Leak Intelligence

### [Have I Been Pwned](https://haveibeenpwned.com/)

Have I Been Pwned helps verify whether email addresses or domains have appeared in known data breaches. It is particularly useful for awareness, exposure validation, and domain-level monitoring.

### [Hudson Rock – Cavalier](https://cavalier.hudsonrock.com/)

Cavalier focuses on infostealer-related exposure, helping organizations identify compromised devices, stolen credentials, and third-party risks associated with infected endpoints.

### [DeHashed](https://www.dehashed.com/)

DeHashed provides breach data search capabilities across emails, usernames, IPs, hashes, domains, and other identifiers. It can support exposure analysis and incident investigation.

### [LeakPeek](https://leak-peak.com/)

LeakPeek provides visibility into infostealer logs, credentials, and leaked files. It can be useful for domain monitoring and enrichment of exposed identity artifacts.

---

## Dark Web Monitoring and Marketplace Intelligence

### [DarkOwl Vision](https://www.darkowl.com/products/vision/)

DarkOwl Vision provides access to indexed dark web and darknet data, supporting threat hunting, brand monitoring, fraud investigation, and underground source analysis.

### [Rapid7 Threat Command](https://www.rapid7.com/products/threat-command/)

Formerly known as IntSights, Threat Command provides external threat intelligence, brand protection, dark web monitoring, and alerting capabilities integrated into enterprise workflows.

### [CyberSixgill](https://www.cybersixgill.com/)

CyberSixgill offers deep and dark web monitoring, threat actor profiling, CVE exploitation tracking, and contextual intelligence for security teams.

---

## General CTI Platforms and Enrichment Services

### [MISP](https://www.misp-project.org/)

MISP is an open-source threat intelligence sharing platform used to store, correlate, and exchange indicators, TTPs, campaigns, and structured intelligence objects.

### [AlienVault OTX](https://otx.alienvault.com/)

OTX is a community-driven threat intelligence platform that allows users to consume and share indicator collections, known as pulses.

### [VirusTotal](https://www.virustotal.com/)

VirusTotal aggregates file, URL, domain, and IP reputation data. It is widely used for triage, enrichment, and malware investigation.

### [Recorded Future](https://www.recordedfuture.com/)

Recorded Future provides commercial threat intelligence capabilities, including real-time alerting, risk scoring, graph analysis, and strategic reporting.

### [Shodan](https://www.shodan.io/)

Shodan indexes Internet-connected devices and services. It is useful for exposure assessment, infrastructure fingerprinting, and attack surface monitoring.

---

## Malware, Infrastructure, and IOC Analysis

### [ANY.RUN](https://any.run/)

ANY.RUN is an interactive malware sandbox that supports dynamic analysis of files, scripts, documents, and network behavior.

### [MalwareBazaar](https://bazaar.abuse.ch/)

MalwareBazaar, maintained by abuse.ch, provides malware samples and related metadata useful for malware research and detection engineering.

### [ThreatFox](https://threatfox.abuse.ch/)

ThreatFox collects and shares indicators of compromise with a strong focus on timely, community-driven threat intelligence.

---

## Threat Actor and Campaign Intelligence

### [MITRE ATT&CK](https://attack.mitre.org/)

MITRE ATT&CK is a knowledge base of adversary tactics and techniques. It supports behavior-based analysis, detection engineering, and threat actor mapping.

### [Malpedia](https://malpedia.caad.fkie.fraunhofer.de/)

Malpedia provides structured information on malware families and threat groups, helping analysts connect tools, campaigns, and actors.

---

## Conclusion

These tools provide a strong foundation for building a CTI workflow. Their real value emerges when they are integrated into a repeatable process: collection, enrichment, validation, correlation, and reporting. Used correctly, they help transform isolated indicators into intelligence that can support detection, prioritization, and strategic decision-making.
