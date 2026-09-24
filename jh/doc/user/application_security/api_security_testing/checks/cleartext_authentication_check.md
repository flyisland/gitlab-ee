---
stage: Application Security Testing
group: Dynamic Analysis
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
title: 明文认证
---

<a id="description"></a>

## 描述

此检查会查找明文认证，例如未使用 TLS 的 HTTP 基本认证。

<a id="remediation"></a>

## 修复

认证凭据通过未加密的通道 (HTTP) 传输。这会将传输的凭据暴露给任何能够在传输过程中监控（嗅探）网络流量的攻击者。诸如凭据之类的敏感信息应始终通过加密通道（如 HTTPS）传输。

<a id="links"></a>

## 链接

- [OWASP](https://owasp.org/Top10/A02_2021-Cryptographic_Failures/)
- [CWE](https://cwe.mitre.org/data/definitions/319.html)