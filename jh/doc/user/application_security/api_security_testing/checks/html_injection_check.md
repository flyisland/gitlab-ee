---
stage: Application Security Testing
group: Dynamic Analysis
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
title: HTML 注入
---

## 描述

检查所有支持字符串的字段是否存在通过 HTML 注入进行的 XSS 攻击。这包括 HTTP 请求的各个部分，例如路径、查询、标头，以及正文参数，如 XML 字段、JSON 字段等。通过监控响应中已知的 HTML 启用字段是否包含注入值来进行检测。

## 修复

跨站脚本攻击 (XSS) 是一种将攻击者提供的代码回显到用户浏览器实例中的攻击技术。浏览器实例可以是标准的 Web 浏览器客户端，也可以是嵌入在软件产品中的浏览器对象，例如 WinAmp 中的浏览器、RSS 阅读器或电子邮件客户端。代码本身通常用 HTML/JavaScript 编写，但也可能扩展到 VBScript、ActiveX、Java、Flash 或任何其他浏览器支持的技术。

当攻击者让用户的浏览器执行他/她的代码时，该代码将在宿主网站的安全上下文（或区域）中运行。拥有此级别的权限后，代码能够读取、修改和传输浏览器可访问的任何敏感数据。遭受跨站脚本攻击的用户可能会被劫持账户（Cookie 窃取），他们的浏览器被重定向到其他位置，或者可能看到他们正在访问的网站提供的欺诈性内容。跨站脚本攻击本质上破坏了用户与网站之间的信任关系。利用从文件系统加载内容的浏览器对象实例的应用程序可能会在本地计算机区域下执行代码，从而导致系统受损。

跨站脚本攻击有三种类型：非持久型、持久型和基于 DOM 的攻击。

非持久型攻击和基于 DOM 的攻击要求用户要么访问一个包含恶意代码的特制链接，要么访问一个包含 Web 表单的恶意网页，当该表单被提交到有漏洞的站点时，就会发起攻击。当有漏洞的资源仅接受 HTTP POST 请求时，通常会使用恶意表单。在这种情况下，表单可以在受害者不知情的情况下自动提交（例如，通过使用 JavaScript）。点击恶意链接或提交恶意表单后，XSS 负载将被回显，并被用户的浏览器解释和执行。另一种发送几乎任意请求（GET 和 POST）的技术是使用嵌入式客户端，例如 Adobe Flash。

当恶意代码被提交到网站并存储一段时间时，就会发生持久型攻击。攻击者最常攻击的目标示例通常包括留言板帖子、Web 邮件消息和 Web 聊天软件。毫无戒心的用户无需与任何其他站点/链接交互（例如，攻击者站点或通过电子邮件发送的恶意链接），只需查看包含该代码的网页即可。

## 链接

- [OWASP](https://owasp.org/Top10/A03_2021-Injection/)
- [CWE](https://cwe.mitre.org/data/definitions/79.html)