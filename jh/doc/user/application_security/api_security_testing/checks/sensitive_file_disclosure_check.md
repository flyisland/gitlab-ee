---
stage: Application Security Testing
group: Dynamic Analysis
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
title: 敏感文件泄露
---

<a id="description"></a>

## 描述

检查是否存在敏感文件泄露。此检查会查找可能包含敏感信息的文件。示例包括 .htaccess、.htpasswd、.bash_history 等。

<a id="remediation"></a>

## 修复

信息泄露是一种应用弱点，即应用暴露了敏感数据，例如 Web 应用的技术细节、环境信息或用户特定数据。攻击者可能利用敏感数据来攻击目标 Web 应用、其托管网络或其用户。因此，应尽可能限制或防止敏感数据泄露。信息泄露最常见的成因是以下一种或多种情况：未能清除包含敏感信息的 HTML/脚本注释、应用或服务器配置不当，或有效数据与无效数据的页面响应存在差异。

在此类失败情形中，一个或多个本不应可访问的文件和/或文件夹可被访问。这可能包括主目录中常见的文件（如命令历史记录），或包含密码等密钥的文件。

<a id="links"></a>

## 链接

- [OWASP](https://owasp.org/Top10/A01_2021-Broken_Access_Control/)
- [CWE](https://cwe.mitre.org/data/definitions/200.html)
