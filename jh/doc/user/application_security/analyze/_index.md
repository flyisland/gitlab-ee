---
stage: Application Security Testing
group: Static Analysis
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
title: 分析
description: 漏洞分析与评估。
---

分析是漏洞管理生命周期的第三个阶段：检测、分类、分析、修复。

分析是评估漏洞详情以确定是否可以并且应该进行修复的过程。漏洞可以批量分类，但分析必须逐个进行。作为风险管理框架的一部分，分析有助于确保资源被应用到最有效的地方。使用安全仪表板和漏洞报告中包含的数据，根据漏洞的严重性和相关风险来优先分析漏洞。

<a id="scope"></a>

## 范围

分析阶段的范围是所有通过分类阶段并确认为需要进一步行动的漏洞。

过滤漏洞报告以识别需要分析的漏洞：

- **状态**：已确认

<a id="risk-analysis"></a>

## 风险分析

您应根据风险评估框架进行漏洞分析。如果您尚未使用风险评估框架，请考虑以下内容：

- [SANS Institute 漏洞管理框架](https://www.sans.org/blog/the-vulnerability-assessment-framework/)
- [OWASP 威胁与保障矩阵 (TaSM)](https://owasp.org/www-project-threat-and-safeguard-matrix/)

如果可用，使用[安全分析师 Agent](../../duo_agent_platform/agents/foundational_agents/security_analyst_agent.md)来加速漏洞分析。该 Agent 通过提供洞察、风险评估和修复指导，高效地分类、评估和修复安全发现。

计算漏洞的风险评分取决于特定于您组织的标准。一个基本的风险评分公式是：

风险 = 可能性 x 影响

可能性和影响的数值因漏洞和您的环境而异。确定这些数值并计算风险评分可能需要极狐GitLab 中不可用的某些信息。相反，您必须根据风险管理框架来计算它们。计算完成后，将它们记录在为该漏洞创建的议题中。

通常，花在漏洞上的时间和精力应与其风险成比例。例如，您可能选择仅分析关键和高风险漏洞，并忽略其余漏洞。您应根据对漏洞的风险阈值做出这一决定。

<a id="analysis-strategies"></a>

## 分析策略

尝试以下策略，首先关注最重要的漏洞。

<a id="prioritize-vulnerabilities-of-highest-severity"></a>

### 优先处理最高严重性的漏洞

为帮助识别最高严重性的漏洞：

- 如果您在分类阶段尚未执行此操作，请使用[漏洞优先级排序器 CI/CD 组件](../vulnerabilities/risk_assessment_data.md#vulnerability-prioritizer)来帮助对漏洞进行分析优先级排序。
- 对于每个群组，过滤漏洞报告以优先处理需要分析的漏洞：
  - **状态**：已确认
  - **活动**：仍被检测到
  - **分组依据**：严重性
- 优先分析最高风险项目的漏洞 - 例如，部署给客户的应用程序。

<a id="prioritize-vulnerabilities-that-have-a-solution-available"></a>

### 优先处理有可用解决方案的漏洞

一些漏洞有可用的解决方案，例如 "从版本 13.2 升级到 13.8"。这减少了分析和修复这些漏洞所需的时间。某些解决方案仅在启用极狐GitLab Duo 时可用。

过滤漏洞报告以识别有可用解决方案的漏洞。

- 对于由 SBOM 扫描检测到的漏洞，使用以下条件：
  - **状态**：已确认
  - **活动**：有解决方案
- 对于由 SAST 检测到的漏洞，使用以下条件：
  - **状态**：已确认
  - **活动**：漏洞修复可用

<a id="vulnerability-details-and-action"></a>

## 漏洞详情与行动

每个漏洞都有一个[漏洞页面](../vulnerabilities/_index.md)，其中包含详细信息，包括检测时间、检测方式、严重性评级和完整日志。使用这些信息来帮助分析漏洞。

以下提示也可能帮助您分析漏洞：

- 使用[极狐GitLab Duo 漏洞解释](duo.md)来帮助解释漏洞并提出修复建议。仅适用于由 SAST 检测到的漏洞。
- 使用由第三方培训供应商提供的[安全培训](../vulnerabilities/_index.md#view-security-training-for-a-vulnerability)来帮助理解特定漏洞的性质。

在分析每个已确认的漏洞后，您应该：

- 如果决定应修复，则将其状态保留为 **已确认**。
- 如果决定不应修复，则将其状态更改为 **已忽略**。

如果您确认一个漏洞：

1. [创建议题](../vulnerabilities/_index.md#create-a-gitlab-issue-for-a-vulnerability)以跟踪、记录和管理修复工作。
1. 继续漏洞管理生命周期的修复阶段。

如果您忽略一个漏洞，则必须提供简短的评论，说明忽略的原因。被忽略的漏洞如果再次被检测到，则会被忽略。漏洞记录将被保留以供审计之用（直到它们被归档）。您可以根据需要通过更新其状态来管理其生命周期。