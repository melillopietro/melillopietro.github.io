---
layout: post
title: "WordPress Enumeration and Common Attack Vectors"
date: 2025-07-29 09:00:00 +0200
categories: [Offensive Security, Penetration Testing]
tags: [wordpress, enumeration, pentest, rest-api, wp-admin]
---

## Introduction

WordPress is one of the most widely deployed content management systems on the Internet. Its popularity makes it a frequent target during reconnaissance, vulnerability assessment, and opportunistic attacks.

This article summarizes common WordPress enumeration vectors and exposure patterns that are often reviewed during authorized security assessments and hardening activities.

The techniques described here are intended for **defensive validation and authorized testing only**.

---

## Author Enumeration via REST API

Since WordPress 4.7, the REST API can expose user-related metadata through endpoints such as:

```text
https://target-site.com/wp-json/wp/v2/users
```

Depending on configuration, this endpoint may reveal usernames, display names, and author metadata. Such information can support password spraying or targeted phishing if not properly controlled.

### Defensive Actions

- Restrict unauthenticated access to user endpoints where possible.
- Avoid exposing login usernames as public display names.
- Use security plugins or custom rules to limit unnecessary REST API exposure.

---

## Author Enumeration via Query Parameter

Another common pattern is enumeration through the `author` parameter:

```text
https://target-site.com/?author=1
```

Some WordPress installations redirect this request to an author archive URL that reveals the username or slug associated with that account.

### Defensive Actions

- Disable author archives if not needed.
- Use generic display names.
- Monitor repeated author enumeration attempts.

---

## Login Page Exposure

The default WordPress login page is usually available at:

```text
https://target-site.com/wp-login.php
https://target-site.com/wp-admin/
```

The mere presence of these endpoints is not a vulnerability, but it increases exposure when combined with weak passwords, missing MFA, outdated plugins, or unrestricted brute-force attempts.

### Defensive Actions

- Enforce multi-factor authentication.
- Apply rate limiting and login protection.
- Monitor failed login attempts.
- Use strong password policies and disable unused accounts.

---

## Plugin and Theme Enumeration

Plugins and themes can often be identified through publicly accessible paths, static assets, or HTML references.

Examples include:

```text
/wp-content/plugins/plugin-name/
/wp-content/themes/theme-name/
```

Version information, when exposed, can help attackers map the site against known vulnerabilities.

### Defensive Actions

- Keep plugins, themes, and WordPress core updated.
- Remove unused plugins and themes.
- Avoid exposing unnecessary version information.
- Monitor for requests targeting known vulnerable plugin paths.

---

## XML-RPC Exposure

The `xmlrpc.php` endpoint can be abused in brute-force amplification, pingback abuse, or automated attacks when not required.

```text
https://target-site.com/xmlrpc.php
```

### Defensive Actions

- Disable XML-RPC if not needed.
- Restrict access through web server rules or security plugins.
- Monitor abnormal POST requests to the endpoint.

---

## Common Security Controls

A hardened WordPress deployment should include:

- timely core, plugin, and theme updates;
- MFA for administrative users;
- least-privilege roles;
- Web Application Firewall rules;
- automated backups;
- file integrity monitoring;
- restricted administrative access where possible;
- logging and alerting on suspicious activity.

---

## Conclusion

WordPress enumeration is often simple, but its impact depends on the surrounding security posture. Exposed usernames, outdated plugins, accessible administrative endpoints, and weak authentication controls can create realistic attack paths.

Regular assessment and hardening are essential to reduce the attack surface of public WordPress installations.
