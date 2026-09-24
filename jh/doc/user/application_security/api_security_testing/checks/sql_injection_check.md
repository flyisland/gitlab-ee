---
stage: Application Security Testing
group: Dynamic Analysis
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
title: SQL 注入
---

<a id="sql-injection"></a>

## SQL 注入

<a id="description"></a>

## 描述

检测 SQL 和 NoSQL 注入漏洞。SQL 注入攻击是指通过客户端向应用程序输入的数据，插入或“注入”一段 SQL 查询。一次成功的 SQL 注入攻击可以读取数据库中的敏感数据，修改数据库数据（插入/更新/删除），执行对数据库的管理操作（如关闭 DBMS），恢复 DBMS 文件系统上某个特定文件的内容，在某些情况下还能向操作系统发出命令。SQL 注入攻击是一种注入攻击类型，在这种攻击中，SQL 命令被注入到数据平面输入中，以影响预定义 SQL 命令的执行。此检测会修改请求中的参数（路径、查询字符串、请求头、JSON、XML 等），尝试在 SQL 或 NoSQL 查询中制造语法错误。随后会分析日志和响应，尝试检测是否发生了错误。如果检测到错误，则极有可能存在漏洞。

<a id="remediation"></a>

## 修复方案

软件使用来自上游组件的外部可控输入构建了部分或全部 SQL 命令，但在发送给下游组件时，未能消除或未能正确消除可能修改预期 SQL 命令的特殊元素。

如果未对用户可控输入中的 SQL 语法进行充分的移除或转义处理，生成的 SQL 查询可能会将这些输入视为 SQL 而非普通用户数据。这可以被用来改变查询逻辑以绕过安全检查，或插入额外语句来修改后端数据库，甚至可能包括执行系统命令。

SQL 注入已成为数据库驱动网站的常见问题。该漏洞容易被发现且易于利用，因此，任何拥有哪怕极少量用户基数的网站或软件包都可能遭遇此类攻击尝试。该漏洞依赖于 SQL 在控制平面和数据平面之间没有实质区分这一事实。

<a id="links"></a>

## 链接

- [OWASP](https://owasp.org/Top10/A03_2021-Injection/)
- [CWE](https://cwe.mitre.org/data/definitions/930.html)