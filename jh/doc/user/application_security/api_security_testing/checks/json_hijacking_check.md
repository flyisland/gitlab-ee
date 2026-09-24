---
stage: Application Security Testing
group: Dynamic Analysis
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
title: JSON 劫持
---

<a id="description"></a>

## 描述

检查可能易受劫持的 JSON 数据。此检查会查找返回 JSON 数组的 GET 请求，该数组可能被恶意网站劫持并读取。

<a id="remediation"></a>

## 修复

JSON 劫持允许攻击者通过恶意网站或类似攻击向量发送 GET 请求，并利用用户存储的凭据检索该用户有权访问的敏感或受保护数据。JSON 数组本身就是有效的 JavaScript，因此对仅返回 JavaScript 数组的资源发起恶意 GET 请求，可能允许攻击者使用恶意脚本从请求中读取数组中的数据。GET 请求绝不应返回 JSON 数组，即使该资源需要身份验证才能访问。请考虑对此请求使用 POST 而非 GET，或将数组包装在 JSON 对象中。

<a id="links"></a>

## 链接

- [OWASP](https://owasp.org/Top10/A01_2021-Broken_Access_Control/)
- [CWE](https://cwe.mitre.org/data/definitions/352.html)

