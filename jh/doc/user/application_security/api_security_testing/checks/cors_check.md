---
stage: Application Security Testing
group: Dynamic Analysis
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
title: 跨域资源共享（CORS）
---

<a id="description"></a>

## 描述

检查 CORS 配置错误，包括对接受的 Origin 请求头允许名单过于宽松，或未能验证 Origin 请求头。同时检查是否在可能无效或危险的 Origin 上允许凭据，以及缺失可能导致缓存中毒的请求头。

<a id="remediation"></a>

## 修复

配置错误的 CORS 实现可能在信任哪些域以及信任级别上过于宽松。这可能允许不受信任的域伪造 Origin 请求头并发动各类攻击，例如跨站请求伪造或跨站脚本攻击。攻击者可能窃取受害者的凭据，或以受害者名义发送恶意请求。受害者甚至可能不知道攻击正在发生。

<a id="links"></a>

## 链接

- [OWASP](https://owasp.org/Top10/A01_2021-Broken_Access_Control/)
- [CWE](https://cwe.mitre.org/data/definitions/942.html)
