---
stage: Application Security Testing
group: Dynamic Analysis
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
title: 框架调试模式
---

<a id="description"></a>

## 描述

检查 Flask 和 ASP.NET 等各种框架中是否启用了调试模式。此检查的误报率较低。

<a id="remediation"></a>

## 修复

检测到 Flask 或 ASP.NET 框架启用了调试模式。这使攻击者能够下载文件系统上的任何文件，并具备其他能力。这是一个高危问题，攻击者很容易利用。

<a id="links"></a>

## 链接

- [OWASP](https://owasp.org/Top10/A05_2021-Security_Misconfiguration/)
- [CWE-23：相对路径遍历](https://cwe.mitre.org/data/definitions/23.html)
- [CWE-285：不当授权](https://cwe.mitre.org/data/definitions/285.html)
