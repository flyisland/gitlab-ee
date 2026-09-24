---
stage: Application Security Testing
group: Dynamic Analysis
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
title: JSON 注入
---

<a id="description"></a>

## 描述

检查 JSON 序列化/注入漏洞。

<a id="remediation"></a>

## 修复

JSON 注入是一种攻击技术，用于操纵或破坏 JSON 应用程序或服务的逻辑。在 JSON 消息中插入非预期的 JSON 内容和/或结构可以改变应用程序的预期逻辑。此外，JSON 注入可能导致恶意内容被插入到结果消息/文档中。

<a id="links"></a>

## 链接

- [OWASP](https://owasp.org/Top10/A03_2021-Injection/)
- [CWE](https://cwe.mitre.org/data/definitions/929.html)