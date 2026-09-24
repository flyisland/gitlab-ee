---
stage: Application Security Testing
group: Dynamic Analysis
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
title: DNS 重绑定
---

## 描述

检查 DNS 重绑定。此检查验证主机是否检查请求的 HOST 头是否存在，并与主机的预期名称匹配，以避免通过恶意 DNS 条目进行攻击。

## 修复

DNS 重绑定允许恶意主机将请求欺骗或重定向到备用 IP 地址，可能允许攻击者绕过安全认证或授权。DNS 解析本身并不能正确构成有效的认证机制。服务器应验证请求的 Host 头是否与服务器的预期主机名匹配。如果主机名缺失或与预期值不匹配，服务器应返回 400 状态码。在请求被转发的情况下，有时会使用 X-Forwarded-Host 头而不是 Host 头。在这些情况下，如果使用 X-Forwarded-Host 头来确定原始请求的主机，也应该对其进行验证。

## 链接

- [OWASP](https://owasp.org/Top10/A05_2021-Security_Misconfiguration/)
- [CWE](https://cwe.mitre.org/data/definitions/350.html)