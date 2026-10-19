---
stage: Application Security Testing
group: Static Analysis
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
title: 分析
description: 漏洞分析与评估。
---

分析是漏洞管理生命周期的第三个阶段：检测、分类、分析、修复。

分析是评估漏洞详细信息，以确定是否能够且应当修复该漏洞的过程。漏洞可以批量分类，但分析必须逐个进行。作为风险管理框架的一部分，分析有助于确保资源用在最有效的地方。使用安全仪表板和漏洞报告中包含的数据，根据漏洞的严重性和相关风险来确定分析的优先级。

<a id="scope"></a>

## 范围

分析阶段的范围是那些已经过分类阶段并确认需要进一步处理的所有漏洞。

筛选漏洞报告以识别需要分析的漏洞：

- **状态**：已确认

<a id="risk-analysis"></a>

## 风险分析

您应根据风险评估框架进行漏洞分析。如果您尚未使用风险评估框架，可考虑以下框架：

- [SANS Institute 漏洞管理框架](https://www.sans.org/blog/the-vulnerability-assessment-framework/)
- [OWASP 威胁与防护矩阵（TaSM）](https://owasp.org/www-project-threat-and-safeguard-matrix/)

如果可用，请使用[安全分析师 Agent](../../duo_agent_platform/agents/foundational_agents/security_analyst_agent.md) 来加速您的漏洞分析。该 Agent 通过提供洞察、风险评估和修复指导，高效地分类、评估和修复安全发现。

计算漏洞的风险评分取决于您组织特有的标准。一个基本的风险评分公式是：

风险 = 可能性 x 影响

可能性数值和影响数值都因漏洞和您的环境而异。确定这些数值并计算风险评分可能需要一些极狐GitLab 中不具备的信息。因此，您必须根据您的风险管理框架来计算这些数值。计算完成后，将其记录在您为该漏洞创建的议题中。

一般来说，花在某个漏洞上的时间和精力应与其风险成正比。例如，您可以选择只分析严重和高风险的漏洞，而忽略其余漏洞。您应根据自己对漏洞的风险阈值做出这一决定。

<a id="analysis-strategies"></a>

## 分析策略

请尝试以下策略，优先处理最重要的漏洞。

<a id="prioritize-vulnerabilities-of-highest-severity"></a>

### 优先处理严重性最高的漏洞

为帮助识别严重性最高的漏洞：

- 如果您在分类阶段尚未这样做，请使用
  [漏洞优先级排序器 CI/CD 组件](../vulnerabilities/risk_assessment_data.md#vulnerability-prioritizer)
  来帮助确定漏洞分析的优先级。
- 对于每个群组，筛选漏洞报告以确定需要分析的漏洞的优先级：

  - **状态**：已确认
  - **活动**：仍检测到
  - **分组依据**：严重性
- 优先分析您风险最高的项目中的漏洞，例如部署给客户的应用程序。

<a id="prioritize-vulnerabilities-that-have-a-solution-available"></a>

### 优先处理已有可用解决方案的漏洞

有些漏洞已有可用的解决方案，例如“从 13.2 版本升级到 13.8”。这可以减少分析和修复这些漏洞所需的时间。有些解决方案仅在启用极狐GitLab Duo 时才可用。

筛选漏洞报告以识别已有可用解决方案的漏洞。

- 对于由 SBOM 扫描检测到的漏洞，使用以下条件：
  - **状态**：已确认
  - **活动**：有解决方案
- 对于由 SAST 检测到的漏洞，使用以下条件：
  - **状态**：已确认
  - **活动**：可用的漏洞解决方法

<a id="vulnerability-details-and-action"></a>

## 漏洞详情与操作

每个漏洞都有一个[漏洞页面](../vulnerabilities/_index.md)，其中包含详细信息，包括检测时间、检测方式、严重性评级以及完整日志。使用这些信息来帮助分析漏洞。

以下提示也可能有助于您分析漏洞：

- 使用[极狐GitLab Duo 漏洞解释](duo.md)
  来帮助解释漏洞并建议修复方案。仅适用于由 SAST 检测到的漏洞。
- 使用第三方培训供应商提供的[安全培训](../vulnerabilities/_index.md#view-security-training-for-a-vulnerability)
  来帮助理解特定漏洞的性质。

分析每个已确认的漏洞后，您应当：

- 如果您决定应修复该漏洞，则将其状态保留为**已确认**。
- 如果您决定不应修复该漏洞，则将其状态更改为**已忽略**。

如果您确认某个漏洞：

1. [创建议题](../vulnerabilities/_index.md#create-a-gitlab-issue-for-a-vulnerability)以
   跟踪、记录和管理修复工作。
1. 继续进入漏洞管理生命周期的修复阶段。

如果您忽略某个漏洞，必须提供一条简短评论，说明您忽略它的原因。已忽略的漏洞如果再次被检测到，将被忽略。漏洞记录会出于审计目的予以保留（直到被归档）。您可以根据需要更新其状态来管理其生命周期。
