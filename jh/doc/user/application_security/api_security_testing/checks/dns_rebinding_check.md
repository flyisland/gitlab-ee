---
stage: Application Security Testing
group: Dynamic Analysis
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
title: DNS 重绑定
---

<a id="description"></a>

## 描述

检查 DNS 重绑定。此检查验证主机是否检查请求的 HOST 请求头存在，并与预期的主机名匹配，以避免通过恶意 DNS 条目发起的攻击。

<a id="remediation"></a>

## 修复

DNS 重绑定允许恶意主机伪造请求或将请求重定向到其他 IP 地址，从而可能使攻击者绕过安全身份验证或授权。DNS 解析本身并不构成有效的身份验证机制。服务器应验证请求的 Host 请求头是否与服务器的预期主机名匹配。如果主机名缺失或与预期值不匹配，服务器应返回 400。在请求被转发的情况下，有时会使用 X-Forwarded-Host 请求头代替 Host 请求头。在这些情况下，如果使用 X-Forwarded-Host 请求头来确定原始请求的 Host，则也应验证该请求头。

<a id="links"></a>

## 链接

- [OWASP](https://owasp.org/Top10/A05_2021-Security_Misconfiguration/)
- [CWE](https://cwe.mitre.org/data/definitions/350.html)
