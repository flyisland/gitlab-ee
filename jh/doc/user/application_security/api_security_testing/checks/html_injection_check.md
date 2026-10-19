---
stage: Application Security Testing
group: Dynamic Analysis
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
title: HTML 注入
---

<a id="description"></a>

## 描述

检查所有支持字符串的字段是否存在通过 HTML 注入实现的 XSS。这包括 HTTP 请求的各个部分，例如路径、查询、请求头，以及正文参数，例如 XML 字段、JSON 字段等。检测方式是在已知启用了 HTML 的字段中监控响应是否包含注入的值。

<a id="remediation"></a>

## 修复

跨站脚本（XSS）是一种攻击技术，它将攻击者提供的代码回显到用户的浏览器实例中。浏览器实例可以是标准 Web 浏览器客户端，也可以是嵌入在软件产品中的浏览器对象，例如 WinAmp 中的浏览器、RSS 阅读器或电子邮件客户端。代码本身通常以 HTML/JavaScript 编写，但也可能扩展到 VBScript、ActiveX、Java、Flash 或任何其他浏览器支持的技术。

当攻击者让用户的浏览器执行其代码时，代码将在承载网站的安全上下文（或区域）中运行。凭借这种级别的权限，代码能够读取、修改和传输浏览器可访问的任何敏感数据。被跨站脚本攻击的用户可能会遭遇账号被劫持（Cookie 窃取）、浏览器被重定向到其他位置，或者可能看到其访问的网站所传递的欺诈内容。跨站脚本攻击本质上破坏了用户与网站之间的信任关系。使用浏览器对象实例从文件系统加载内容的应用程序可能会在本地计算机区域下执行代码，从而导致系统被入侵。

跨站脚本攻击有三种类型：非持久型、持久型和基于 DOM 型。

非持久型攻击和基于 DOM 型攻击需要用户访问带有恶意代码的特制链接，或访问包含 Web 表单的恶意网页，该表单在提交到存在漏洞的网站时会发起攻击。当存在漏洞的资源仅接受 HTTP POST 请求时，通常会使用恶意表单。在这种情况下，表单可以在受害者不知情的情况下自动提交（例如通过 JavaScript）。点击恶意链接或提交恶意表单后，XSS 载荷会被回显，并由用户的浏览器解释和执行。另一种发送几乎任意请求（GET 和 POST）的技术是使用嵌入式客户端，例如 Adobe Flash。

持久型攻击发生在恶意代码被提交到网站并在其中存储一段时间的情况下。攻击者最喜欢的目标通常包括留言板帖子、Web 邮件消息和 Web 聊天软件。毫无戒心的用户无需与任何其他网站/链接交互（例如攻击者网站或通过电子邮件发送的恶意链接）。他们只需查看包含该代码的网页即可。

<a id="links"></a>

## 链接

- [OWASP](https://owasp.org/Top10/A03_2021-Injection/)
- [CWE](https://cwe.mitre.org/data/definitions/79.html)
