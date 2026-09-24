---
stage: Application Security Testing
group: Dynamic Analysis
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
title: 敏感文件泄露
---

<a id="description"></a>

## 描述

检查敏感文件泄露。此检查查找可能包含敏感信息的文件。示例包括 .htaccess、.htpasswd、.bash_history 等。

<a id="remediation"></a>

## 修复方案

信息泄露是一种应用程序弱点，即应用程序泄露敏感数据，例如 Web 应用程序、环境或用户特定数据的技术细节。敏感数据可能被攻击者用来攻击目标 Web 应用程序、其托管网络或其用户。因此，应尽可能限制或防止敏感数据泄露。信息泄露最常见的形式是以下一种或多种情况的结果：未能清除包含敏感信息的 HTML/Script 注释、不当的应用程序或服务器配置，或针对有效数据与无效数据的页面响应差异。

在此失败的情况下，一个或多个本不应访问的文件和/或文件夹可被访问。这可能包括主文件夹中的常见文件，例如命令历史记录或包含密码等机密的文件。

<a id="links"></a>

## 链接

- [OWASP](https://owasp.org/Top10/A01_2021-Broken_Access_Control/)
- [CWE](https://cwe.mitre.org/data/definitions/200.html)