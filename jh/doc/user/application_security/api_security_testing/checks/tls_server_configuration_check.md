---
stage: Application Security Testing
group: Dynamic Analysis
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
title: TLS 服务器配置
---

<a id="description"></a>

## 描述

检查各种 TLS 服务器配置问题。检查服务器支持的 TLS 版本、HMAC、密码算法和压缩算法。

<a id="remediation"></a>

## 修复

传输层保护不足会使通信暴露给不受信任的第三方，从而为攻击者提供入侵 Web 应用程序和/或窃取敏感信息的攻击途径。网站通常使用安全套接字层/传输层安全（SSL/TLS）在传输层提供加密。但是，除非网站配置为使用 SSL/TLS 并正确配置为使用 SSL/TLS，否则网站可能容易受到流量拦截和篡改的攻击。

多年来，SSL/TLS 作为一种协议经历了多次修订。每个新版本都会增加功能并修复协议中的弱点。随着时间的推移，某些版本的协议已被严重破坏，如果继续支持就会成为漏洞。建议仅支持最新的 TLS 版本，例如 TLS 1.3（2018）和 TLS 1.2（2008）。

压缩已被认为与 TLS 连接上的侧信道攻击有关。禁用压缩可以防止这些攻击。尤其可以防止一种名为 CRIME（“Compression Ratio Info-leak Made Easy”）的攻击。CRIME 是一种针对客户端的攻击，但如果服务器不支持压缩，该攻击就会得到缓解。

网站曾被配置为支持弱加密选项，以兼容那些只能使用弱密码算法的客户端。弱密码算法容易受到攻击，因为破解它们相对容易；在典型的家用计算机上不到两周，而使用专用硬件只需几秒钟。

如今，所有现代浏览器和网站都使用强得多的加密，但一些网站仍被配置为支持过时的弱密码算法。因此，攻击者可能能够强制客户端在连接到网站时降级到较弱的密码算法，从而使攻击者能够破解弱加密。因此，服务器应配置为仅接受强密码算法，并且不为任何请求使用较弱密码算法的客户端提供服务。此外，一些网站配置错误，即使客户端支持强得多的密码算法，也会选择较弱的密码算法。OWASP 提供了一份测试 SSL/TLS 问题的指南，包括弱密码算法支持和配置错误，此外还有其他资源和工具。

<a id="links"></a>

## 链接

- [OWASP](https://owasp.org/Top10/A02_2021-Cryptographic_Failures/)
- [CWE](https://cwe.mitre.org/data/definitions/934.html)
