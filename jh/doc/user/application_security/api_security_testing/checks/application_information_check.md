---
stage: Application Security Testing
group: Dynamic Analysis
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
title: 应用程序信息泄露
---

<a id="description"></a>

## 描述

应用程序信息泄露检查。这包括版本号、数据库错误消息和堆栈跟踪等信息。

<a id="remediation"></a>

## 修复

应用程序信息泄露是一种应用程序弱点，即应用程序泄露敏感数据，例如 Web 应用程序或环境的技术细节。攻击者可能利用应用程序数据来攻击目标 Web 应用程序、其托管网络或其用户。因此，应尽可能限制或防止敏感数据泄露。信息泄露最常见的表现形式是由以下一种或多种情况导致的：未能清除包含敏感信息的 HTML 或脚本注释，或者应用程序或服务器配置不当。

在推送到生产环境之前未能清除 HTML 或脚本注释，可能导致敏感的情境信息泄露，例如服务器目录结构、SQL 查询结构和内部网络信息。开发者通常会在 HTML 和脚本代码中留下注释，以便在预生产阶段协助调试或集成过程。虽然允许开发者在所开发的内容中包含内联注释并无害处，但在内容公开发布之前应移除所有这些注释。

软件版本号和详细的错误消息（例如 ASP.NET 版本号）是服务器配置不当的示例。这些信息对攻击者很有用，因为它能详细揭示 Web 应用程序所使用的框架、语言或预构建函数。大多数默认服务器配置都会提供软件版本号和详细的错误消息，用于调试和故障排除。可以通过更改配置来禁用这些功能，从而阻止显示此类信息。

<a id="links"></a>

## 链接

- [OWASP](https://owasp.org/Top10/A05_2021-Security_Misconfiguration/)
- [CWE](https://cwe.mitre.org/data/definitions/200.html)
