---
stage: Application Security Testing
group: Dynamic Analysis
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
title: 跨域资源共享（CORS）
---

<a id="description"></a>

## 描述

检查 CORS 配置错误，包括过于宽松的允许 Origin 头白名单或未验证 Origin 头。还检查是否允许在潜在无效或危险的 Origins 上使用凭据，以及缺少可能导致缓存投毒的标头。

<a id="remediation"></a>

## 修复

配置错误的 CORS 实现可能在哪些域应受信任以及信任级别方面过于宽松。这可能允许不受信任的域伪造 Origin 头并发起各种类型的攻击，例如跨站请求伪造或跨站脚本。攻击者可能窃取受害者的凭据或代表受害者发送恶意请求。受害者甚至可能不知道正在发起攻击。

<a id="links"></a>

## 链接

- [OWASP](https://owasp.org/Top10/A01_2021-Broken_Access_Control/)
- [CWE](https://cwe.mitre.org/data/definitions/942.html)