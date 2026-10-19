---
stage: Application Security Testing
group: Dynamic Analysis
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
title: 敏感信息泄露
---

<a id="description"></a>

## 描述

敏感信息泄露检查。包括信用卡号、健康记录、个人信息等。

<a id="remediation"></a>

## 修复

敏感信息泄露是一种应用弱点，即应用泄露了用户特定的敏感数据。攻击者可能利用敏感数据来侵害其用户。因此，应尽可能限制或防止敏感数据泄露。信息泄露最常见的成因，是应用对有效数据与无效数据的页面响应存在差异。

根据数据有效性提供不同响应的页面也可能导致信息泄露，尤其是当被视为机密的数据因 Web 应用的设计而被泄露时。敏感数据的示例包括（但不限于）：账号、用户标识符（驾驶证号、护照号、社会保障号等）以及用户特定信息（密码、会话、地址）。此语境中的信息泄露涉及被视为机密或秘密的关键用户数据被暴露，这些数据不应以明文形式暴露，即使对用户本人也是如此。信用卡号和其他受严格监管的信息就是典型示例，即使已采取适当的加密和访问控制，这些用户数据仍需进一步保护，以防暴露或泄露。

<a id="links"></a>

## 链接

- [OWASP](https://owasp.org/Top10/A01_2021-Broken_Access_Control/)
- [CWE](https://cwe.mitre.org/data/definitions/200.html)
