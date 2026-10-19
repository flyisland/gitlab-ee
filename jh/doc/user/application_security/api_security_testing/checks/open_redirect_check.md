---
stage: Application Security Testing
group: Dynamic Analysis
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
title: 开放重定向
---

<a id="description"></a>

## 描述

识别开放重定向，并判断攻击者是否可能滥用它们。

<a id="remediation"></a>

## 修复

当 Web 应用程序接受不可信输入，且该输入可能导致 Web 应用程序将请求重定向到不可信输入中包含的 URL 时，就可能出现未经验证的重定向和转发。通过将不可信的 URL 输入修改为恶意站点，攻击者可能成功发起钓鱼诈骗并窃取用户凭据。由于修改后链接中的服务器名称与原始站点相同，钓鱼尝试可能显得更加可信。未经验证的重定向和转发攻击还可用于恶意构造一个 URL，该 URL 会通过应用程序的访问控制检查，然后将攻击者转发到他们通常无法访问的特权功能。

<a id="links"></a>

## 链接

- [OWASP](https://owasp.org/Top10/A01_2021-Broken_Access_Control/)
- [CWE](https://cwe.mitre.org/data/definitions/601.html)
