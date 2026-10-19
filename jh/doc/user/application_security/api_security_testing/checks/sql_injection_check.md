---
stage: Application Security Testing
group: Dynamic Analysis
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
title: SQL 注入
---

<a id="description"></a>

## 描述

检查 SQL 和 NoSQL 注入漏洞。SQL 注入攻击是指通过客户端向应用程序的输入数据中插入或“注入”SQL 查询。成功的 SQL 注入利用可以读取数据库中的敏感数据、修改数据库数据（插入/更新/删除）、对数据库执行管理操作（例如关闭 DBMS）、恢复 DBMS 文件系统中某个文件的内容，在某些情况下还可以向操作系统发出命令。SQL 注入攻击是一种注入攻击，其中 SQL 命令被注入到数据平面输入中，以影响预定义 SQL 命令的执行。此检查会修改请求中的参数（路径、查询字符串、请求头、JSON、XML 等），尝试在 SQL 或 NoSQL 查询中制造语法错误。随后分析日志和响应，尝试检测是否发生了错误。如果检测到错误，则很可能存在漏洞。

<a id="remediation"></a>

## 修复

软件使用来自上游组件的受外部影响的输入来构造全部或部分 SQL 命令，但未中和或未正确中和可能在被发送到下游组件时修改预期 SQL 命令的特殊元素。

如果未充分移除或转义用户可控输入中的 SQL 语法，生成的 SQL 查询可能会使这些输入被解释为 SQL，而不是普通用户数据。这可用于更改查询逻辑以绕过安全检查，或插入修改后端数据库的附加语句，其中可能包括执行系统命令。

SQL 注入已成为数据库驱动网站的常见问题。该缺陷易于检测，也易于利用，因此，任何拥有哪怕极少用户群的网站或软件包都可能遭受此类攻击尝试。该缺陷取决于一个事实：SQL 对控制平面和数据平面没有真正的区分。

<a id="links"></a>

## 链接

- [OWASP](https://owasp.org/Top10/A03_2021-Injection/)
- [CWE](https://cwe.mitre.org/data/definitions/930.html)
