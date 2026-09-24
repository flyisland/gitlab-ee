---
stage: Security Risk Management
group: Security Insights
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
title: 漏洞严重程度级别
description: 分类、影响、优先级排序和风险评估。
---

{{< details >}}

- Tier: 旗舰版
- Offering: JihuLab.com，私有化部署

{{< /details >}}

极狐GitLab 漏洞分析器尽可能返回漏洞严重程度级别值。以下是可用的极狐GitLab 漏洞严重程度级别列表，按严重程度从高到低排列：

- 严重
- 高
- 中
- 低
- 信息
- 未知

极狐GitLab 分析器努力契合以下严重程度描述，但它们可能并不总是完全准确。由第三方供应商提供的分析器和扫描器可能不会遵循相同的分类。

<a id="critical-severity"></a>

## 严重

被识别为严重严重程度的漏洞应立即进行调查。此级别的漏洞假设利用该缺陷可能导致整个系统或数据被完全攻破。严重缺陷的示例包括命令/代码注入和 SQL 注入。通常，这些缺陷的 CVSS 4.0 评分在 9.0 到 10.0 之间。

<a id="high-severity"></a>

## 高

高严重程度漏洞的特征是可能导致攻击者访问应用资源或意外暴露数据的缺陷。高严重程度缺陷的示例包括外部 XML 实体注入（XXE）、服务器端请求伪造（SSRF）、本地文件包含/路径遍历以及某些形式的跨站脚本（XSS）。通常，这些缺陷的 CVSS 4.0 评分在 7.0 到 8.9 之间。

<a id="medium-severity"></a>

## 中

中危漏洞通常源于系统配置不当或缺乏安全控制。利用这些漏洞可能导致访问有限数量的数据，或者可能与其他缺陷结合使用，以获得对系统或资源的非预期访问权限。中危缺陷的示例包括反射型 XSS、不正确的 HTTP 会话处理以及缺少安全控制。通常，这些缺陷的 CVSS 4.0 评分在 4.0 到 6.9 之间。

<a id="low-severity"></a>

## 低

低危漏洞包含可能无法被直接利用，但会给应用或系统引入不必要弱点的缺陷。这些缺陷通常是由于缺少安全控制或不必要地泄露了关于应用环境的信息所致。低危漏洞的示例包括缺少 Cookie 安全指令、冗长的错误或异常消息。通常，这些缺陷的 CVSS 4.0 评分在 0.1 到 3.9 之间。

<a id="info-severity"></a>

## 信息

信息级严重程度的漏洞包含可能有价值但未必与特定缺陷或弱点相关联的信息。通常，这类问题没有 CVSS 评级。

<a id="unknown-severity"></a>

## 未知

在此级别识别的问题没有足够的上下文来清楚地展示其严重程度。

极狐GitLab 漏洞分析器包含了流行的开源扫描工具。每个开源扫描工具都提供其自身的原生漏洞严重程度级别值。这些值可能是以下之一：

| 原生漏洞严重程度级别类型 | 示例 |
|---|---|
| 字符串 | `WARNING`， `ERROR`， `Critical`， `Negligible` |
| 整数 | `1`， `2`， `5` |
| [CVSS v2.0 Rating](https://nvd.nist.gov/vuln-metrics/cvss) | `(AV:N/AC:L/Au:S/C:P/I:P/A:N)` |
| [CVSS v3.1 Qualitative Severity Rating](https://www.first.org/cvss/v3.1/specification-document#Qualitative-Severity-Rating-Scale) | `CVSS:3.1/AV:N/AC:L/PR:L/UI:N/S:C/C:H/I:H/A:H` |
| [CVSS v4.0 Qualitative Severity Rating](https://www.first.org/cvss/v4.0/specification-document#Qualitative-Severity-Rating-Scale) | `CVSS:4.0/AV:N/AC:L/AT:N/PR:N/UI:N/VC:H/VI:H/VA:H/SC:N/SI:N/SA:N` |

为了提供一致的漏洞严重程度级别值，极狐GitLab 漏洞分析器会将这些值转换为标准化的极狐GitLab 漏洞严重程度级别，如下表所示：

<a id="container-scanning"></a>

## 容器扫描

| 极狐GitLab 分析器 | 是否输出严重程度级别？ | 原生严重程度级别类型 | 原生严重程度级别示例 |
|---|---|---|---|
| [`container-scanning`](https://gitlab.com/gitlab-org/security-products/analyzers/container-scanning) | 是 | 字符串 | `Unknown`， `Low`， `Medium`， `High`， `Critical` |

当供应商严重程度级别可用时，分析器将优先使用该级别。如果不可用，则会回退到 CVSS v4.0 评级。如果依然不可用，则会使用 CVSS v3.1 评级。如果还是不可用，则会改用 CVSS v2.0 评级。

<a id="dynamic-application-security-testing-dast"></a>

## 动态应用安全测试（DAST）

| 极狐GitLab 分析器 | 是否输出严重程度级别？ | 原生严重程度级别类型 | 原生严重程度级别示例 |
|---|---|---|---|
| [`基于浏览器的 DAST`](../dast/browser/_index.md) | 是 | 字符串 | `HIGH`， `MEDIUM`， `LOW`， `INFO` |

<a id="api-security-testing"></a>

## API 安全测试

| 极狐GitLab 分析器 | 是否输出严重程度级别？ | 原生严重程度级别类型 | 原生严重程度级别示例 |
|---|---|---|---|
| [`API 安全测试`](../api_security_testing/_index.md) | 是 | 字符串 | `HIGH`， `MEDIUM`， `LOW` |

<a id="dependency-scanning"></a>

## 依赖项扫描

| 极狐GitLab 分析器 | 是否输出严重程度级别？ | 原生严重程度级别类型 | 原生严重程度级别示例 |
|---|---|---|---|
| [`gemnasium`](https://gitlab.com/gitlab-org/security-products/analyzers/gemnasium) | 是 | CVSS v2.0 评级， CVSS v3.1 定性严重程度评级 <sup>1</sup> 和 CVSS v4.0 定性严重程度评级 <sup>1</sup> | `(AV:N/AC:L/Au:S/C:P/I:P/A:N)`， `CVSS:3.1/AV:N/AC:L/PR:L/UI:N/S:C/C:H/I:H/A:H`， `CVSS:4.0/AV:N/AC:L/AT:N/PR:N/UI:N/VC:H/VI:H/VA:H/SC:N/SI:N/SA:N` |

CVSS v4.0 评级被用来计算严重程度级别。如果不可用，则使用 CVSS v3.1 评级。如果依然不可用，则改用 CVSS v2.0 评级。

<a id="fuzz-testing"></a>

## 模糊测试

所有模糊测试结果均报告为“未知”严重程度。应对其进行人工审查和分类，以发现可利用的故障，并优先进行修复。

<a id="static-application-security-testing-sast"></a>

## 静态应用安全测试（SAST）

| 极狐GitLab 分析器 | 是否输出严重程度级别？ | 原生严重程度级别类型 | 原生严重程度级别示例 |
|---|---|---|---|
| [`kubesec`](https://gitlab.com/gitlab-org/security-products/analyzers/kubesec) | 是 | 字符串 | `CriticalSeverity`， `InfoSeverity` |
| [`pmd-apex`](https://gitlab.com/gitlab-org/security-products/analyzers/pmd-apex) | 是 | 整数 | `1`， `2`， `3`， `4`， `5` |
| [`semgrep`](https://gitlab.com/gitlab-org/security-products/analyzers/semgrep) | 是 | 字符串 | `error`， `warning`， `note`， `none` |
| [`sobelow`](https://gitlab.com/gitlab-org/security-products/analyzers/sobelow) | 是 | 不适用 | 将所有严重程度级别硬编码为 `Unknown` |
| [`SpotBugs`](https://gitlab.com/gitlab-org/security-products/analyzers/spotbugs) | 是 | 整数 | `1`， `2`， `3`， `11`， `12`， `18` |

<a id="infrastructure-as-code-iac-scanning"></a>

## 基础设施即代码（IaC）扫描

| 极狐GitLab 分析器 | 是否输出严重程度级别？ | 原生严重程度级别类型 | 原生严重程度级别示例 |
|---|---|---|---|
| [`kics`](https://gitlab.com/gitlab-org/security-products/analyzers/kics) | 是 | 字符串 | `error`， `warning`， `note`， `none`（在[分析器版本 3.7.0 及更高版本](https://gitlab.com/gitlab-org/security-products/analyzers/kics/-/releases/v3.7.0)中被映射到 `info`） |

### Keeping Infrastructure as Code Secure (KICS) 严重程度映射

KICS 分析器将其输出映射到静态分析结果交换格式（SARIF）严重程度，这些严重程度再映射到极狐GitLab 严重程度。使用下表查看极狐GitLab 漏洞报告中对应的严重程度。

| KICS 严重程度 | KICS SARIF 严重程度 | 极狐GitLab 严重程度 |
|---|---|---|
| CRITICAL | error | 严重 |
| HIGH | error | 严重 |
| MEDIUM | warning | 中 |
| LOW | note | 信息 |
| INFO | none | 信息 |
| invalid | none | 信息 |

尽管 KICS 和极狐GitLab 都定义了高严重程度，但 SARIF 没有定义，因此 KICS 中的高严重程度漏洞在极狐GitLab 中被映射为严重程度。

[极狐GitLab 映射的源代码](https://gitlab.com/gitlab-org/security-products/analyzers/report/-/blob/902c7dcb5f3a0e551223167931ebf39588a0193a/sarif/sarif.go#L279-315)。

<a id="secret-detection"></a>

## 密钥检测

极狐GitLab 的 [`secrets`](https://gitlab.com/gitlab-org/security-products/analyzers/secrets) 分析器将所有严重程度级别硬编码为“严重”。更细粒度的严重程度评级已在[史诗 10320](https://gitlab.com/groups/gitlab-org/-/epics/10320) 中提出。