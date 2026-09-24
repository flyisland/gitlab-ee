---
stage: Application Security Testing
group: Dynamic Analysis
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
title: 认证令牌
---

<a id="description"></a>

## 描述

执行各种认证令牌检查，例如移除令牌或将其更改为无效值。

<a id="remediation"></a>

## 修复

API 令牌必须具有不可预测性（足够的随机性），以防止攻击者通过统计分析技术猜测或预测出有效的 API 令牌。为此，必须使用良好的 PRNG（伪随机数生成器）。

认证令牌可能存在以下问题：

- 被修改为无效值。
- 已从请求中移除。
- 长度不符合要求。
- 被配置为签名。

某项 API 操作未能通过认证令牌正确限制访问。这使得攻击者可以绕过认证，获取信息甚至修改数据。

<a id="links"></a>

## 链接

- [OWASP](https://owasp.org/Top10/A07_2021-Identification_and_Authentication_Failures/)
- [CWE](https://cwe.mitre.org/data/definitions/285.html)