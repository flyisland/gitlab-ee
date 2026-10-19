---
stage: Application Security Testing
group: Dynamic Analysis
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
title: OS 命令注入
---

<a id="description"></a>

## 描述

检查 OS 命令注入漏洞。OS 命令注入攻击是指通过来自客户端的输入数据，向应用程序插入或“注入”OS 命令。成功利用 OS 命令注入漏洞可以运行任意命令。这使攻击者能够读取、写入和删除数据。根据命令运行所使用的用户身份，这可能还包括管理功能。

此检查会修改请求中的参数（路径、查询字符串、请求头、JSON、XML 等），以尝试执行 OS 命令。既执行标准注入，也执行盲注。盲注成功时会导致响应延迟。

<a id="remediation"></a>

## 修复

攻击者有可能在目标应用服务器上执行任意 OS 命令。OS 命令注入是一种严重漏洞，可能导致整个系统被攻陷。绝不应将用户输入用于构造命令，或用于构造传递给执行 OS 命令的函数的命令参数。这包括用户上传或下载所提供的文件名。

请确保您的应用程序不会：

- 在执行所用的进程名称中使用用户提供的信息。
- 在未转义 shell 元字符的 OS 命令执行函数中使用用户提供的信息。
- 在传递给 OS 命令的参数中使用用户提供的信息。

应用程序应具有一组硬编码的参数，用于传递给 OS 命令。如果要将文件名传递给这些函数，建议改用文件名的哈希值或其他唯一标识符。由于针对第三方命令的攻击方式未知，存在风险，强烈建议改用实现相同功能的本机库，而不是使用 OS 系统命令。

<a id="links"></a>

## 链接

- [OWASP](https://owasp.org/Top10/A03_2021-Injection/)
- [CWE](https://cwe.mitre.org/data/definitions/78.html)
