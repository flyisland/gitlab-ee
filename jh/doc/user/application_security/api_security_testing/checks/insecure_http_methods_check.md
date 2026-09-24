---
stage: Application Security Testing
group: Dynamic Analysis
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
title: 不安全的 HTTP 方法
---

<a id="description"></a>

## 描述

检查目标端点是否启用了 OPTIONS 和 TRACE 等 HTTP 方法。

<a id="remediation"></a>

## 修复措施

测试的资源支持 OPTIONS HTTP 方法。通常，这被视为安全配置错误，因为它会泄露支持的 HTTP 方法，导致有关特定服务器或资源的信息收集。然而，有一部分 API 社区希望使用 OPTIONS 作为自我发现资源操作的方法。如果启用 OPTIONS 是预期用途，则可以将此问题视为误报。

测试的资源支持 TRACE HTTP 方法。结合 Web 浏览器中的其他跨域漏洞，敏感信息可能会从标头泄露。建议在您的服务器/框架中禁用 TRACE 方法。

<a id="links"></a>

## 链接

- [OWASP](https://owasp.org/Top10/A05_2021-Security_Misconfiguration/)
- [CWE](https://cwe.mitre.org/data/definitions/200.html)