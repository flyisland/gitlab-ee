---
stage: Application Security Testing
group: Dynamic Analysis
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
title: 会话 Cookie
---

<a id="description"></a>

## 描述

验证会话 Cookie 是否具有正确的标志和过期时间。

<a id="remediation"></a>

## 修复

HTTP 是一种无状态协议，因此网站通常使用 Cookie 来存储会话 ID，以唯一标识每个请求对应的用户。因此，必须保持每个会话 ID 的机密性，以防止多个用户访问同一账户。被盗的会话 ID 可用于查看其他用户的账户或执行欺诈交易。

- 保护会话 ID 的一个方面是正确标记它们的过期时间，并要求使用正确的标志集，以确保它们不会以明文形式传输或通过脚本访问。
- HttpOnly 是 Set-Cookie HTTP 响应头中包含的一个附加标志。在生成 Cookie 时使用 HttpOnly 标志有助于降低客户端脚本访问受保护 Cookie 的风险（如果浏览器支持）。如果 HTTP 响应头中包含 HttpOnly 标志（可选），则无法通过客户端脚本访问该 Cookie（同样，如果浏览器支持此标志）。因此，即使存在跨站脚本 (XSS) 漏洞，并且用户意外访问了利用此漏洞的链接，浏览器也不会向第三方泄露该 Cookie。
- HTTPS 会话中敏感 Cookie 的 Secure 属性未设置，这可能导致用户代理在 HTTP 会话中以明文形式发送这些 Cookie。
- 发现一个与会话相关的 Cookie 在不安全的传输协议上使用。不安全的传输协议是指未使用 SSL/TLS 来保护连接的协议。此类协议的示例包括 'http'。
- 当 Web 应用程序允许攻击者重用旧的会话凭据或会话 ID 进行授权时，就会发生会话过期不足。会话过期不足会增加网站遭受窃取或重用用户会话标识符攻击的风险。

<a id="links"></a>

## 链接

- [OWASP](https://owasp.org/Top10/A07_2021-Identification_and_Authentication_Failures/)
- [CWE](https://cwe.mitre.org/data/definitions/930.html)