---
stage: Security Risk Management
group: Security Insights
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
title: 漏洞严重性级别
description: 分类、影响、优先级排序和风险评估。
---

{{< details >}}

- Tier: 旗舰版
- Offering: JihuLab.com，私有化部署

{{< /details >}}

极狐GitLab 漏洞分析器会尽可能返回漏洞严重性级别值。以下是可用的极狐GitLab 漏洞严重性级别列表，按严重程度从高到低排列：

- 严重
- 高
- 中
- 低
- 信息
- 未知

极狐GitLab 分析器会尽量符合下面的严重性描述，但可能并不总是准确。第三方供应商提供的分析器和扫描器可能不遵循相同的分类。

<a id="critical-severity"></a>

## 严重级别

被识别为严重级别的漏洞应立即调查。此级别的漏洞假定利用该缺陷可能导致系统或数据完全失陷。严重级别缺陷的示例包括命令/代码注入和 SQL 注入。通常，这些缺陷的 CVSS 4.0 评分介于 9.0 到 10.0 之间。

<a id="high-severity"></a>

## 高严重性

高严重性漏洞可以描述为可能导致攻击者访问应用程序资源或导致数据意外泄露的缺陷。高严重性缺陷的示例包括外部 XML 实体注入（XXE）、服务器端请求伪造（SSRF）、本地文件包含、路径遍历以及某些形式的跨站脚本（XSS）。通常，这些缺陷的 CVSS 4.0 评分介于 7.0 到 8.9 之间。

<a id="medium-severity"></a>

## 中严重性

中严重性漏洞通常源于系统配置错误或缺少安全控制措施。利用这些漏洞可能导致访问受限数量的数据，也可能与其他缺陷结合使用，从而获得对系统或资源的非预期访问权限。中严重性缺陷的示例包括反射型 XSS、不正确的 HTTP 会话处理以及缺少安全控制措施。通常，这些缺陷的 CVSS 4.0 评分介于 4.0 到 6.9 之间。

<a id="low-severity"></a>

## 低严重性

低严重性漏洞包含可能无法直接利用，但会给应用程序或系统带来不必要弱点的缺陷。这些缺陷通常源于缺少安全控制措施，或不必要地披露有关应用程序环境的信息。低严重性漏洞的示例包括缺少 Cookie 安全指令以及详细的错误或异常消息。通常，这些缺陷的 CVSS 4.0 评分介于 0.1 到 3.9 之间。

<a id="info-severity"></a>

## 信息严重性

信息级别严重性漏洞包含可能具有价值，但不一定与特定缺陷或弱点相关的信息。通常，这些问题没有 CVSS 评分。

<a id="unknown-severity"></a>

## 未知严重性

在此级别识别的问题没有足够的上下文来明确表明严重性。

极狐GitLab 漏洞分析器包含常用的开源扫描工具。每个开源扫描工具都提供自己的原生漏洞严重性级别值。这些值可以是以下之一：

| 原生漏洞严重性级别类型                                                                                          | 示例                                       |
|-----------------------------------------------------------------------------------------------------------------------------------|------------------------------------------------|
| 字符串                                                                                                                            | `WARNING`, `ERROR`, `Critical`, `Negligible`   |
| 整数                                                                                                                           | `1`, `2`, `5`                                  |
| [CVSS v2.0 评级](https://nvd.nist.gov/vuln-metrics/cvss)                                                                        | `(AV:N/AC:L/Au:S/C:P/I:P/A:N)`                 |
| [CVSS v3.1 定性严重性评级](https://www.first.org/cvss/v3.1/specification-document#Qualitative-Severity-Rating-Scale) | `CVSS:3.1/AV:N/AC:L/PR:L/UI:N/S:C/C:H/I:H/A:H` |
| [CVSS v4.0 定性严重性评级](https://www.first.org/cvss/v4.0/specification-document#Qualitative-Severity-Rating-Scale) | `CVSS:4.0/AV:N/AC:L/AT:N/PR:N/UI:N/VC:H/VI:H/VA:H/SC:N/SI:N/SA:N` |

为提供一致的漏洞严重性级别值，极狐GitLab 漏洞分析器会将先前的值转换为标准化的极狐GitLab 漏洞严重性级别，如下表所示：

<a id="container-scanning"></a>

## 容器扫描

| 极狐GitLab 分析器                                                        | 输出严重性级别？ | 原生严重性级别类型 | 原生严重性级别示例                                |
|------------------------------------------------------------------------|--------------------------|----------------------------|--------------------------------------------------------------|
| [`container-scanning`](https://gitlab.com/gitlab-org/security-products/analyzers/container-scanning)| {{< yes >}} | 字符串 | `Unknown`, `Low`, `Medium`, `High`, `Critical` |

如果可用，供应商严重性级别优先，并由分析器使用。如果不可用，则回退到 CVSS v4.0 评级。如果也不可用，则使用 CVSS v3.1 评级。如果也不可用，则改用 CVSS v2.0 评级。

<a id="dynamic-application-security-testing-dast"></a>

## 动态应用程序安全测试（DAST）

| 极狐GitLab 分析器                                                                          | 输出严重性级别？     | 原生严重性级别类型 | 原生严重性级别示例       |
|------------------------------------------------------------------------------------------|------------------------------|----------------------------|-------------------------------------|
| [`Browser-based DAST`](../dast/browser/_index.md)         | {{< yes >}}       | 字符串 | `HIGH`, `MEDIUM`, `LOW`, `INFO` |

<a id="api-security-testing"></a>

## API 安全测试

| 极狐GitLab 分析器                                                                          | 输出严重性级别？     | 原生严重性级别类型 | 原生严重性级别示例       |
|------------------------------------------------------------------------------------------|------------------------------|----------------------------|-------------------------------------|
| [`API security testing`](../api_security_testing/_index.md)         | {{< yes >}}       | 字符串 | `HIGH`, `MEDIUM`, `LOW` |

<a id="dependency-scanning"></a>

## 依赖扫描

| 极狐GitLab 分析器                                                                          | 输出严重性级别？     | 原生严重性级别类型 | 原生严重性级别示例       |
|------------------------------------------------------------------------------------------|------------------------------|----------------------------|-------------------------------------|
| [`gemnasium`](https://gitlab.com/gitlab-org/security-products/analyzers/gemnasium)         | {{< yes >}}       | CVSS v2.0 评级、CVSS v3.1 定性严重性评级 <sup>1</sup> 和 CVSS v4.0 定性严重性评级 <sup>1</sup> | `(AV:N/AC:L/Au:S/C:P/I:P/A:N)`, `CVSS:3.1/AV:N/AC:L/PR:L/UI:N/S:C/C:H/I:H/A:H`, `CVSS:4.0/AV:N/AC:L/AT:N/PR:N/UI:N/VC:H/VI:H/VA:H/SC:N/SI:N/SA:N` |

使用 CVSS v4.0 评级来计算严重性级别。如果不可用，则使用 CVSS v3.1 评级。如果也不可用，则改用 CVSS v2.0 评级。

<a id="fuzz-testing"></a>

## 模糊测试

所有模糊测试结果都报告为未知严重性。应手动审查和分类这些结果，以找出可利用的故障并确定修复优先级。

<a id="static-application-security-testing-sast"></a>

## 静态应用程序安全测试（SAST）

|  极狐GitLab 分析器                                                                 | 输出严重性级别？ | 原生严重性级别类型 | 原生严重性级别示例 |
|----------------------------------------------------------------------------------|--------------------------|----------------------------|-------------------------|
| [`kubesec`](https://gitlab.com/gitlab-org/security-products/analyzers/kubesec)   | {{< yes >}}   | 字符串                     | `CriticalSeverity`, `InfoSeverity` |
| [`pmd-apex`](https://gitlab.com/gitlab-org/security-products/analyzers/pmd-apex) | {{< yes >}}   | 整数                    | `1`, `2`, `3`, `4`, `5`            |
| [`semgrep`](https://gitlab.com/gitlab-org/security-products/analyzers/semgrep)   | {{< yes >}}   | 字符串                     | `error`, `warning`, `note`, `none` |
| [`sobelow`](https://gitlab.com/gitlab-org/security-products/analyzers/sobelow)   | {{< yes >}}   | 不适用             | 将所有严重性级别硬编码为 `Unknown` |
| [`SpotBugs`](https://gitlab.com/gitlab-org/security-products/analyzers/spotbugs) | {{< yes >}}   | 整数                    | `1`, `2`, `3`, `11`, `12`, `18`    |

<a id="infrastructure-as-code-iac-scanning"></a>

## 基础设施即代码（IaC）扫描

|  极狐GitLab 分析器                                                                                         | 输出严重性级别？ | 原生严重性级别类型 | 原生严重性级别示例      |
|----------------------------------------------------------------------------------------------------------|--------------------------|----------------------------|------------------------------------|
| [`kics`](https://gitlab.com/gitlab-org/security-products/analyzers/kics)                                 | {{< yes >}}   | 字符串                     | `error`, `warning`, `note`, `none`（在[分析器 3.7.0 及更高版本](https://gitlab.com/gitlab-org/security-products/analyzers/kics/-/releases/v3.7.0)中映射为 `info`） |

<a id="keeping-infrastructure-as-code-secure-kics-severity-mapping"></a>

### 保持基础设施即代码安全（KICS）严重性映射

KICS 分析器将其输出映射为静态分析结果交换格式（SARIF）严重性，后者又映射为极狐GitLab 严重性。使用下表查看极狐GitLab 漏洞报告中对应的严重性。

| KICS 严重性 | KICS SARIF 严重性 | 极狐GitLab 严重性 |
|---------------|---------------------|-----------------|
| CRITICAL      | error               | 严重        |
| HIGH          | error               | 严重        |
| MEDIUM        | warning             | 中        |
| LOW           | note                | 信息        |
| INFO          | none                | 信息        |
| invalid       | none                | 信息        |

尽管 KICS 和极狐GitLab 都定义了高严重性，但 SARIF 没有定义，因此 KICS 中的高严重性漏洞在极狐GitLab 中映射为严重级别。

[GitLab 映射的源代码](https://gitlab.com/gitlab-org/security-products/analyzers/report/-/blob/902c7dcb5f3a0e551223167931ebf39588a0193a/sarif/sarif.go#L279-315)。

<a id="secret-detection"></a>

## 密钥检测

极狐GitLab [`secrets`](https://gitlab.com/gitlab-org/security-products/analyzers/secrets) 分析器将所有严重性级别硬编码为严重。更细粒度的严重性评级已在[史诗 10320](https://gitlab.com/groups/gitlab-org/-/epics/10320)中提出。
