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

敏感信息泄露是一种应用弱点，指应用泄露了用户特有的敏感数据。攻击者可能利用这些敏感数据攻击用户。因此，应尽可能限制或防止敏感数据的泄露。信息泄露的最常见形式是页面在有效与无效数据的响应上存在差异。

根据数据有效性提供不同响应的页面也可能导致信息泄露；特别是当机密数据因 Web 应用的设计而被泄露时。敏感数据的示例包括（但不限于）：账号、用户标识（驾照号码、护照号码、社会安全号码等）以及用户特有信息（密码、会话、地址等）。上下文中的信息泄露是指关键的、机密的用户数据泄露，这些数据不应以明文形式暴露，甚至对用户本人也是。信用卡号和其他受严格监管的信息是需要进一步保护，防止暴露或泄露，即使已实施适当的加密和访问控制措施，这也是典型示例。

<a id="links"></a>

## 链接

- [OWASP](https://owasp.org/Top10/A01_2021-Broken_Access_Control/)
- [CWE](https://cwe.mitre.org/data/definitions/200.html)