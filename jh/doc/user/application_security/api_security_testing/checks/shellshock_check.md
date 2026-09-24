---
stage: Application Security Testing
group: Dynamic Analysis
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
title: Shellshock 漏洞
---

## 描述

检查 Shellshock 漏洞。

## 修复

Shellshock 漏洞利用了 BASH 中的一个缺陷，即当 BASH 导入存储在环境变量中的函数定义时，会错误地执行尾随命令。任何允许定义 BASH 环境变量的环境都可能受到此缺陷的影响，例如使用 mod_cgi 和 mod_cgid 模块的 Apache Web 服务器。一个已知的良好请求被修改为包含恶意内容。此恶意内容包括 Shellshock 攻击，其中服务器端应用程序在响应头中返回特定文本（证据）。

## 链接

- [OWASP](https://owasp.org/Top10/A03_2021-Injection/)
- [CWE](https://cwe.mitre.org/data/definitions/78.html)