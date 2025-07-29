---
title: WordPress Enumeration & Attack Vectors
date: 2025-07-29
categories: [Offensive Security / Penetration Testing, WordPress, Enumeration,Offensive Security]
tags: [REST API, wp-admin, bruteforce, credentials, pentest]
---

## 1. Introduction

WordPress, by default, exposes several attack surfaces that allow unauthenticated users to enumerate usernames, access sensitive metadata, and potentially initiate password brute-force attacks. These misconfigurations, often underestimated, are widespread across public-facing WordPress instances.

This document outlines known enumeration vectors, password reset exploits, and wp-admin exposure techniques observed in real-world engagements.

---

## 2. Author Enumeration via REST API

Since version 4.7, WordPress has included a REST API endpoint that exposes user-related metadata. The endpoint can be accessed via:

```
https://target-site.com/wp-json/wp/v2/users
```

If the site is misconfigured, or still adheres to the default REST API behavior, the above call will return a list of users who have authored at least one public post. The response includes:

- `id`
- `name` (display name)
- `slug` (login/username)
- `link` (profile)

### ⚠️ Risk

The `slug` field usually reflects the actual login username. This data can be easily harvested and fed into automated brute-force scripts targeting `/wp-login.php`.

---

## 3. Detecting Exposed wp-admin Panel

The WordPress admin panel typically resides at:

```
https://target-site.com/wp-admin/
```

If not properly restricted via `.htaccess`, firewall, or WAF rules, unauthenticated users can reach the login interface (`/wp-login.php`). Enumeration of the login form can also be automated by checking:

- `HTTP 200 OK` on `/wp-admin/`
- Presence of HTML form with `id="loginform"`
- Cookies such as `wordpress_test_cookie`

### Detection via CLI tools:

```bash
curl -I https://target-site.com/wp-admin/
```

Look for `Location:` headers redirecting to `/wp-login.php`, which confirms login enforcement via redirection.

---

## 4. Unauthorized Password Reset (Local Access)

A known technique to manually change WordPress passwords via a PHP script is through `chg_wp_pwd.php`. This requires write access to the webroot (e.g., via FTP or reverse shell):

### Manual Procedure:

1. Upload the file `chg_wp_pwd.php` to the WordPress root directory.
2. Rename it if necessary to avoid detection.
3. Access it via browser:
   ```
   http://target-site.com/chg_wp_pwd.php
   ```
4. Enter:
   - the **username** whose password should be reset
   - the **new password**

> ⚠️ Use this script only in controlled environments. Its presence is highly detectable and may be flagged by security tools.

---

## 5. Hardening Recommendations

To prevent or mitigate the aforementioned vectors:

- Disable REST API endpoints for unauthenticated users:
  ```php
  add_filter( 'rest_endpoints', function( $endpoints ) {
      if ( isset( $endpoints['/wp/v2/users'] ) ) {
          unset( $endpoints['/wp/v2/users'] );
      }
      return $endpoints;
  });
  ```
- Restrict access to `/wp-admin/` and `/wp-login.php` via IP whitelisting or WAF
- Monitor access logs for enumeration patterns and failed logins
- Enforce 2FA and strong password policies
- Install a plugin to hide author archives (`/author=username`)

---

## 6. Conclusion

Enumeration and low-level privilege exploitation in WordPress remain among the most common initial access techniques in real-world intrusions. Organizations must not rely solely on plugin-based security but should harden the core platform behavior and monitor for reconnaissance activity proactively.
