---
stage: Application Security Testing
group: Dynamic Analysis
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
title: 应用程序信息泄露
---

<a id="description"></a>

描述

应用程序信息泄露检查。这包括版本号、数据库错误消息、堆栈跟踪等信息。

<a id="remediation"></a>

修复措施

应用程序信息泄露是一种应用程序弱点，即应用程序泄露敏感数据，例如 Web 应用程序或环境的技术细节。攻击者可能会利用应用程序数据来攻击目标 Web 应用程序、其托管网络或用户。因此，应尽可能限制或防止敏感数据的泄露。信息泄露最常见的形式是以下一种或多种情况的结果：未能清除包含敏感信息的 HTML 或脚本注释，或者应用程序或服务器配置不当。

在推送到生产环境之前未能清除 HTML 或脚本注释，可能导致敏感上下文信息（如服务器目录结构、SQL 查询结构和内部网络信息）的泄露。开发人员通常会出于调试或集成目的，在预生产阶段保留 HTML 和脚本代码中的注释。尽管允许开发人员在其开发内容中包含内联注释无害，但这些注释都应在内容公开发布前删除。

软件版本号和详细的错误消息（如 ASP.NET 版本号）是服务器配置不当的示例。这些信息对攻击者非常有用，可让他们详细了解 Web 应用程序所使用的框架、语言或预构建功能。大多数默认服务器配置会出于调试和故障排除目的提供软件版本号和详细的错误消息。可以通过更改配置来禁用这些功能，从而阻止显示这些信息。

<a id="links"></a>

链接

- [OWASP](https://owasp.org/Top10/A05_2021-Security_Misconfiguration/)
- [CWE](https://cwe.mitre.org/data/definitions/200.html)