---
stage: Application Security Testing
group: Dynamic Analysis
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
title: 不安全的 HTTP 方法
---

<a id="description"></a>

## 描述

检查任何目标端点上是否启用了 OPTIONS 和 TRACE 等 HTTP 方法。

<a id="remediation"></a>

## 修复

所测试的资源支持 OPTIONS HTTP 方法。通常，这被视为一种安全配置错误，因为它会泄露受支持的 HTTP 方法，从而导致对特定服务器或资源的信息收集。不过，API 社区中有一部分人希望将 OPTIONS 用作自我发现资源操作的方法。如果启用 OPTIONS 是出于这一目的，那么此问题可被视为误报。

所测试的资源支持 TRACE HTTP 方法。结合 Web 浏览器中的其他跨域漏洞，敏感信息可能会从请求头中泄露。建议在您的服务器/框架中禁用 TRACE 方法。

<a id="links"></a>

## 链接

- [OWASP](https://owasp.org/Top10/A05_2021-Security_Misconfiguration/)
- [CWE](https://cwe.mitre.org/data/definitions/200.html)
