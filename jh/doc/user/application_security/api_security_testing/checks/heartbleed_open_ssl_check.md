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

Heartbleed 漏洞是广泛使用的 OpenSSL 加密库中的一个严重缺陷。OpenSSL 用于加密和解密通信并保护互联网流量。该漏洞使攻击者能够窃取受保护的信息，这些信息在其他情况下本不应被访问，例如用于加密敏感信息的密钥。

任何能够访问目标 API 的人都可以利用 Heartbleed 漏洞读取受保护系统的内存，从而利用存在漏洞的 OpenSSL 库版本。

<a id="links"></a>

## 链接

- [OWASP](https://owasp.org/Top10/A06_2021-Vulnerable_and_Outdated_Components/)
- [CWE](https://cwe.mitre.org/data/definitions/119.html)
