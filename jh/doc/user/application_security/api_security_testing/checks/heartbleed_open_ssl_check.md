---
stage: Application Security Testing
group: Dynamic Analysis
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
title: Heartbleed OpenSSL 漏洞
---

<a id="description"></a>

## 描述

检查 Heartbleed OpenSSL 漏洞。

<a id="remediation"></a>

## 修复

Heartbleed 漏洞是广泛使用的 OpenSSL 加密库中的一个严重漏洞。OpenSSL 用于加密和解密通信，保护互联网流量安全。该漏洞允许攻击者窃取本应在其它情况下不可访问的受保护信息，例如用于加密敏感信息的密钥。

任何能访问目标 API 的人都可以利用易受攻击的 OpenSSL 库版本，通过 Heartbleed 漏洞从受保护的系统中读取内存。

<a id="links"></a>

## 链接

- [OWASP](https://owasp.org/Top10/A06_2021-Vulnerable_and_Outdated_Components/)
- [CWE](https://cwe.mitre.org/data/definitions/119.html)