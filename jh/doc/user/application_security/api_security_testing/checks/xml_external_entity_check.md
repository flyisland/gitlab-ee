---
stage: Application Security Testing
group: Dynamic Analysis
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
title: XML 外部实体
---

<a id="description"></a>

## 描述

检查 XML DTD 处理漏洞。

<a id="remediation"></a>

## 修复

XML 外部实体攻击是一种针对解析 XML 输入的应用程序的攻击。当包含外部实体引用的 XML 输入被配置不当的 XML 解析器处理时，就会发生这种攻击。此类攻击可能导致机密数据泄露、拒绝服务、服务器端请求伪造、从解析器所在机器的角度进行端口扫描，以及其他系统影响。

<a id="links"></a>

## 链接

- [OWASP](https://owasp.org/Top10/A03_2021-Injection/)
- [CWE](https://cwe.mitre.org/data/definitions/611.html)
