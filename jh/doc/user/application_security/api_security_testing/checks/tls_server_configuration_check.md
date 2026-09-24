---
stage: Application Security Testing
group: Dynamic Analysis
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
title: TLS 服务器配置
---

<a id="description"></a>

## 描述

检查各种 TLS 服务器配置问题。检查服务器支持的 TLS 版本、HMAC、密码和压缩算法。

<a id="remediation"></a>

## 修复

传输层保护不足会使通信暴露给不受信任的第三方，为破坏 Web 应用程序和/或窃取敏感信息提供攻击向量。网站通常使用安全套接字层/传输层安全 (SSL/TLS) 在传输层提供加密。但是，除非网站配置为使用 SSL/TLS 并正确配置 SSL/TLS，否则网站可能容易受到流量拦截和修改的攻击。

多年来，SSL/TLS 作为一种协议经历了多次修订。每个新版本都增加了功能并修复了协议中的弱点。随着时间的推移，某些版本的协议严重损坏，如果支持则会变成漏洞。建议仅支持最新的 TLS 版本，例如 TLS 1.3 (2018) 和 TLS 1.2 (2008)。

压缩已与针对 TLS 连接的侧信道攻击相关联。禁用压缩可以防止这些攻击。特别是一种名为 CRIME（"Compression Ratio Info-leak Made Easy"）的攻击可以被预防。CRIME 是一种针对客户端的攻击，但如果服务器不支持压缩，攻击将得到缓解。

过去，高等级的加密技术被限制从美国出口。因此，网站被配置为支持弱加密选项，以满足那些仅限于使用弱密码的客户端的需求。弱密码容易受到攻击，因为破解它们相对容易；在典型的家用计算机上不到两周，而使用专用硬件只需几秒钟。

如今，所有现代浏览器和网站都使用更强的加密，但某些网站仍然配置为支持过时的弱密码。因此，攻击者可能能够强制客户端在连接到网站时降级到较弱的密码，从而使攻击者能够破解弱加密。因此，服务器应配置为仅接受强密码，并且不为任何请求较弱密码的客户端提供服务。此外，某些网站配置错误，即使客户端支持更强的密码，也会选择较弱的密码。OWASP 提供了一份测试 SSL/TLS 问题的指南，包括弱密码支持和错误配置，并且还有其他资源和工具。

<a id="links"></a>

## 链接

- [OWASP](https://owasp.org/Top10/A02_2021-Cryptographic_Failures/)
- [CWE](https://cwe.mitre.org/data/definitions/934.html)