---
stage: Application Security Testing
group: Dynamic Analysis
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
title: API 安全
description: 防护、分析、测试、扫描和发现。
---

{{< details >}}

- Tier: 旗舰版
- Offering: JihuLab.com，私有化部署

{{< /details >}}

API 安全是指为保护 Web 应用程序编程接口（API）免遭未授权访问、滥用和攻击而采取的措施。API 是现代应用程序开发的关键组成部分，因为它们允许应用程序相互交互并交换数据。然而，这也使它们对攻击者具有吸引力，如果未妥善保护，就容易受到安全威胁。本节讨论可用于确保应用程序中 Web API 安全的极狐GitLab 功能。所讨论的部分功能特定于 Web API，其他则是更通用的解决方案，也用于 Web API 应用程序。

- [SAST](../sast/_index.md) 通过分析应用程序的代码库来识别漏洞。
- [依赖扫描](../dependency_scanning/_index.md)审查项目的第三方依赖项是否存在已知漏洞（例如 CVE）。
- [容器扫描](../container_scanning/_index.md)分析容器镜像，以识别已知的操作系统软件包漏洞和已安装的语言依赖项。
- [API 发现](api_discovery/_index.md)检查包含 REST API 的应用程序，并推断出该 API 的 OpenAPI 规范。OpenAPI 规范文档由其他极狐GitLab 安全工具使用。
- [API 安全测试分析器](../api_security_testing/_index.md)对 Web API 执行动态分析安全测试。它可以识别应用程序中的各种安全漏洞，包括 OWASP Top 10。
- [API 模糊测试](../api_fuzzing/_index.md)对 Web API 执行模糊测试。模糊测试会查找应用程序中此前未知、且不映射到 SQL 注入等经典漏洞类型的问题。
