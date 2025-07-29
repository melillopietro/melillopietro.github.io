---
title: Active Directory Enumeration Techniques
date: 2025-07-29
categories: [Offensive Security / Penetration Testing, ActiveDirectory, Enumeration,Offensive Security]
tags: [recon, AD, PowerView, LDAP, BloodHound, Impacket]
---

## 1. Introduction

Active Directory (AD) enumeration is a fundamental step in internal penetration testing and red team operations. Understanding the domain structure, users, groups, and permissions is essential for identifying potential attack paths and privilege escalation opportunities.

This document outlines both credentialed and non-credentialed enumeration techniques, leveraging built-in Windows commands, PowerShell, and third-party tools commonly used by adversaries.

---

## 2. Initial Recon (Unauthenticated)

### 🔸 Discover Domain and Domain Controllers

```bash
nslookup
nslookup domain.local
nslookup -type=SRV _ldap._tcp.dc._msdcs.domain.local
```

```bash
net view /domain
```

These commands help identify the domain namespace and the IP addresses of reachable domain controllers (DCs).

---

## 3. Basic Enumeration with Domain Credentials

### 🔸 Enumerate Users and Groups

```bash
net user /domain
net group "Domain Users" /domain
net group "Domain Admins" /domain
```

### 🔸 List Local Groups

```bash
net localgroup
net localgroup administrators
```

---

## 4. PowerShell-Based Enumeration (Native Modules)

### 🔹 List All Domain Users

```powershell
Get-ADUser -Filter * -Properties SamAccountName, Name, Enabled | Format-Table Name, SamAccountName, Enabled
```

### 🔹 Enumerate Groups and Their Members

```powershell
Get-ADGroup -Filter * | ForEach-Object {
  $_.Name
  Get-ADGroupMember -Identity $_.DistinguishedName | Select-Object Name, ObjectClass
}
```

### 🔹 List Domain Computers

```powershell
Get-ADComputer -Filter * | Select-Object Name, IPv4Address
```

---

## 5. Advanced Enumeration Tools

### 🔸 BloodHound (via SharpHound)

BloodHound is widely used for collecting AD relationships and analyzing privilege escalation paths.

```bash
SharpHound.exe -c All
```

or via PowerShell:

```powershell
Invoke-BloodHound -CollectionMethod All -ZipFileName data.zip
```

### 🔸 LDAP Search from Linux

```bash
ldapsearch -x -H ldap://dc.domain.local -D "user@domain.local" -w Password123 -b "dc=domain,dc=local"
```

---

## 6. Popular Tools for AD Recon

| Tool                  | Description                                      |
|-----------------------|--------------------------------------------------|
| enum4linux            | SMB/NetBIOS user and group enumeration           |
| crackmapexec smb      | Broad SMB/AD enumeration and credential testing  |
| rpcclient             | Query domain info and SID bruteforce             |
| impacket-GetADUsers   | Retrieve AD users via Kerberos                   |
| impacket-GetNPUsers   | Kerberoasting of pre-auth disabled accounts      |
| ldapdomaindump        | Full dump of LDAP domain structure               |

---

## 7. SID Bruteforce and RID Cycling

```bash
rpcclient -U "" <DC-IP>
> enumdomusers
```

This allows RID enumeration in unauthenticated mode, revealing domain users.

---

## 8. Enumerate SMB Shares

```bash
net view \<target>
net share
```

With `smbclient` (Linux):

```bash
smbclient -L //<target> -U "user"
```

---

## 9. Group Policy and Domain Settings

### 🔹 List All GPOs

```powershell
Get-GPO -All
```

### 🔹 Export GPO Report

```powershell
Get-GPResultantSetOfPolicy -ReportType Html -Path report.html
```

### 🔹 View Password Policy

```powershell
net accounts
```

---

## 10. Sample PowerView Command

```powershell
Get-DomainUser -Identity "targetuser"
Get-DomainGroupMember -Identity "Domain Admins"
Get-DomainTrust
Get-ObjectAcl -SamAccountName "Domain Admins" -ResolveGUIDs | fl
```

PowerView can reveal delegation rights, ACLs, and trust relationships.

---

## 11. Conclusion

Effective Active Directory enumeration provides insight into the internal structure of a Windows domain, enabling attackers to identify privileged accounts, exposed services, and vulnerable paths. Regular auditing, segmentation, and least privilege principles are key to mitigating these risks.

