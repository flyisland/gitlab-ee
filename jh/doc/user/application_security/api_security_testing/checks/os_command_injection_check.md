---
stage: Application Security Testing
group: Dynamic Analysis
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
title: OS 命令注入
---

## 描述

检查 OS 命令注入漏洞。OS 命令注入攻击是指通过客户端输入数据向应用程序插入或“注入”OS 命令。
成功的 OS 命令注入漏洞利用可以运行任意命令。这使攻击者能够读取、写入和删除数据。根据命令运行时所使用的用户身份，还可能包括管理功能。

此检查修改请求中的参数（路径、查询字符串、标头、JSON、XML 等），以尝试执行 OS 命令。会执行标准注入和盲注。盲注成功时会导致响应延迟。

## 修复

可以在目标应用程序服务器上执行任意 OS 命令。OS 命令注入是一个严重漏洞，可能导致整个系统被攻陷。绝不应使用用户输入来构造命令或命令参数，传递给执行 OS 命令的函数。这包括由用户上传或下载提供的文件名。

确保您的应用程序不会：

- 在要执行的进程名称中使用用户提供的信息。
- 在不会转义 shell 元字符的 OS 命令执行函数中使用用户提供的信息。
- 在 OS 命令的参数中使用用户提供的信息。

应用程序应具有一组硬编码的参数，用于传递给 OS 命令。如果要将文件名传递给这些函数，建议改用文件名的哈希值或其他唯一标识符。强烈建议使用实现相同功能的本机库，而不是使用 OS 系统命令，因为存在针对第三方命令的未知攻击风险。

## 链接

- [OWASP](https://owasp.org/Top10/A03_2021-Injection/)
- [CWE](https://cwe.mitre.org/data/definitions/78.html)