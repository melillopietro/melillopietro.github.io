---
layout: post
title: "WordPress Enumeration and Common Attack Vectors"
date: 2025-07-29
categories: [Offensive Security / Penetration Testing, Guides]
tags: [wordpress, enumeration, pentest, rest api, wp-admin]
---

## Introduction

WordPress, by default, exposes several attack surfaces that may allow unauthenticated users to enumerate usernames, access metadata, and identify authentication-related entry points. These exposures are often underestimated and remain common across public-facing WordPress instances.

This article outlines several **enumeration vectors**, **administrative exposure patterns**, and **security validation considerations** frequently observed during assessment and hardening activities.

---

## Author Enumeration via REST API

Since version 4.7, WordPress has included a REST API endpoint that may expose user-related metadata through the following path:

```text
https://target-site.com/wp-json/wp/v2/users
