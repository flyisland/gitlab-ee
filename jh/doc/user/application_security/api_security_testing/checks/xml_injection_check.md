---
stage: Application Security Testing
group: Dynamic Analysis
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
title: XML 注入检查
---

<a id="description"></a>

## 描述

检查 XML 序列化/注入漏洞。

<a id="remediation"></a>

## 修复建议

XML 注入是一种攻击技术，用于操纵或破坏 XML 应用程序或服务的逻辑。将非预期的 XML 内容和/或结构注入 XML 消息中，可能会改变应用程序的预期逻辑。此外，XML 注入可能导致在生成的消息/文档中插入恶意内容。

<a id="links"></a>

## 链接

- [OWASP](https://owasp.org/Top10/A03_2021-Injection/)
- [CWE](https://cwe.mitre.org/data/definitions/91.html)