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

API 令牌必须不可预测（足够随机），以防止猜测攻击，即攻击者能够通过统计分析技术猜测或预测有效的 API 令牌。为此，必须使用良好的 PRNG（伪随机数生成器）。

认证令牌可能发生以下情况：

- 修改为无效值。
- 从请求中移除。
- 不符合长度要求。
- 配置为签名。

某个 API 操作未能使用认证令牌正确限制访问。这使攻击者能够绕过身份验证，获取信息访问权限，甚至获得修改数据的能力。

<a id="links"></a>

## 链接

- [OWASP](https://owasp.org/Top10/A07_2021-Identification_and_Authentication_Failures/)
- [CWE](https://cwe.mitre.org/data/definitions/285.html)
