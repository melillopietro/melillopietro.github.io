---
layout: post
title: "Active Directory Enumeration Techniques"
date: 2025-07-29 09:00:00 +0200
categories: [Offensive Security, Penetration Testing]
tags: [active-directory, enumeration, recon, ldap, bloodhound, impacket]
---

## Introduction

Active Directory enumeration is a central activity in internal penetration testing, adversary simulation, and defensive validation. Understanding users, groups, trusts, permissions, and exposed services allows security teams to identify privilege escalation paths before they are abused by real attackers.

The techniques below are intended for **authorized assessments, lab environments, and defensive security activities**. They should not be used against systems without explicit permission.

---

## Initial Reconnaissance

The first step is to identify the domain namespace and reachable domain controllers.

```bash
nslookup
nslookup domain.local
nslookup -type=SRV _ldap._tcp.dc._msdcs.domain.local
```

```bash
net view /domain
```

These commands can help determine whether the host is joined to a domain and which directory services are visible from the current network segment.

---

## Basic Enumeration with Domain Credentials

When valid domain credentials are available, basic Windows commands can provide an initial view of users, groups, and local administrative configuration.

```bash
net user /domain
net group "Domain Users" /domain
net group "Domain Admins" /domain
```

```bash
net localgroup
net localgroup administrators
```

This information is useful for building a first privilege map and identifying potentially sensitive groups.

---

## PowerShell-Based Enumeration

The Active Directory module for PowerShell can be used to query domain objects in a structured way.

```powershell
Get-ADUser -Filter * -Properties SamAccountName, Name, Enabled |
  Format-Table Name, SamAccountName, Enabled
```

```powershell
Get-ADGroup -Filter * | ForEach-Object {
  $_.Name
  Get-ADGroupMember -Identity $_.DistinguishedName | Select-Object Name, ObjectClass
}
```

```powershell
Get-ADComputer -Filter * | Select-Object Name, IPv4Address
```

These commands are useful during authorized reviews because they provide a clearer understanding of domain structure and account exposure.

---

## Advanced Enumeration Tools

### BloodHound and SharpHound

BloodHound is widely used to collect and analyze Active Directory relationships, especially where privilege escalation paths are not immediately visible.

```bash
SharpHound.exe -c All
```

PowerShell collection can also be used in controlled lab or assessment contexts:

```powershell
Invoke-BloodHound -CollectionMethod All -ZipFileName data.zip
```

### LDAP Search from Linux

```bash
ldapsearch -x -H ldap://dc.domain.local -D "user@domain.local" -w 'Password123' -b "dc=domain,dc=local"
```

LDAP queries can expose useful details about users, groups, computers, organizational units, and policy-related objects.

---

## Common Tools for AD Reconnaissance

| Tool | Purpose |
| :--- | :--- |
| `enum4linux` | SMB and NetBIOS user/group enumeration |
| `crackmapexec smb` | Broad SMB and AD validation workflows |
| `rpcclient` | Domain information and RID enumeration |
| `impacket-GetADUsers` | AD user retrieval through Impacket |
| `impacket-GetNPUsers` | Identification of accounts without Kerberos pre-authentication |
| `ldapdomaindump` | Structured LDAP domain export |

---

## SID and RID Enumeration

RID cycling may reveal domain users in poorly hardened environments.

```bash
rpcclient -U "" <DC-IP>
> enumdomusers
```

This type of enumeration should be carefully monitored and restricted through proper access controls and network segmentation.

---

## SMB Share Enumeration

```bash
net view \<target>
net share
```

From Linux:

```bash
smbclient -L //<target> -U "user"
```

Exposed shares can reveal misconfigurations, excessive permissions, or sensitive files.

---

## Group Policy and Domain Settings

```powershell
Get-GPO -All
```

```powershell
Get-GPResultantSetOfPolicy -ReportType Html -Path report.html
```

```powershell
net accounts
```

These commands help assess policy configuration, password rules, and security posture across domain-joined systems.

---

## PowerView Examples

```powershell
Get-DomainUser -Identity "targetuser"
Get-DomainGroupMember -Identity "Domain Admins"
Get-DomainTrust
Get-ObjectAcl -SamAccountName "Domain Admins" -ResolveGUIDs | fl
```

PowerView can be useful for identifying delegation settings, ACLs, trust relationships, and other paths that may contribute to privilege escalation.

---

## Defensive Considerations

Organizations should regularly review Active Directory exposure by combining enumeration, configuration assessment, and detection engineering. Key controls include least privilege, tiered administration, privileged access monitoring, SMB hardening, credential hygiene, and continuous review of group memberships.

## Conclusion

Active Directory enumeration is valuable because it exposes how identity, permissions, and infrastructure relationships are actually configured. For defenders, this visibility is essential to reduce attack paths, validate hardening measures, and improve resilience against internal compromise.
