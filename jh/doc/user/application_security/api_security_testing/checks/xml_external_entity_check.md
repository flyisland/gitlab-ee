---
stage: Application Security Testing
group: Dynamic Analysis
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
title: XML 外部实体
---

## 描述

检查 XML DTD 处理漏洞。

## 修复

XML 外部实体攻击是针对解析 XML 输入的应用程序的一种攻击类型。这种攻击发生在配置薄弱的 XML 解析器处理包含对外部实体引用的 XML 输入时。这种攻击可能导致机密数据泄露、拒绝服务、服务器端请求伪造、从解析器所在机器的视角进行端口扫描，以及其他系统影响。

## 链接

- [OWASP](https://owasp.org/Top10/A03_2021-Injection/)
- [CWE](https://cwe.mitre.org/data/definitions/611.html)