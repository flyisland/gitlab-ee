---
stage: Application Security Testing
group: Static Analysis
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
title: 分类
description: 按状态进行漏洞分离。
---

<a id="triage"></a>

# 分类

分类是漏洞管理生命周期的第二阶段：检测、分类、分析、修复。

分类是一个持续的过程，评估每个漏洞以决定哪些需要立即关注，哪些不那么关键。高风险漏洞与中低风险威胁区分开。分析并修复每一个漏洞可能实际上不可行。作为风险管理框架的一部分，分类有助于确保资源被用在最有效的地方。建议经常对漏洞进行分类，这样每次分类周期内的漏洞数量较少且易于管理。

分类阶段的目标是确认或忽略每个漏洞。已确认的漏洞继续进入分析阶段，而被忽略的漏洞则不继续。

使用安全仪表板、安全资产清单和漏洞报告中的数据，有助于高效且有效地进行漏洞分类。

<a id="scope"></a>

## 范围

分类阶段的范围包括所有尚未评估的漏洞。

筛选漏洞报告以识别需要分类的漏洞：

- **状态**：需要分类

<a id="risk-analysis"></a>

## 风险分析

您应根据风险评估框架进行漏洞分类。根据您所在的行业或地理位置，法律可能要求遵守某个框架。如果没有，您应使用一个公认的风险评估框架，例如：

- [SANS 研究所漏洞管理框架](https://www.sans.org/blog/the-vulnerability-assessment-framework/)
- [OWASP 威胁与防护矩阵 (TaSM)](https://owasp.org/www-project-threat-and-safeguard-matrix/)

如果可用，使用 [安全分析师 Agent](../../duo_agent_platform/agents/foundational_agents/security_analyst_agent.md) 加速您的漏洞分析。该 Agent 通过提供洞察、风险评估和修复指导，高效地对安全发现进行分类、评估和修复。

通常，在漏洞上花费的时间和精力应与其风险成正比。例如，您的分类策略可能是仅关键的和高风险的漏洞继续进入分析阶段，其余的被忽略。您应根据漏洞风险阈值做出这一决定。

对漏洞进行分类后，应将其状态更改为以下之一：

- **已确认**：您已对此漏洞进行分类，并认为需要进行进一步分析。
- **已忽略**：您已对此漏洞进行分类，并决定不进行分析。

忽略漏洞时，必须提供简短的评论，说明忽略的原因。被忽略的漏洞在后续扫描中再次检测到时将被忽略。漏洞记录是永久的，但您可以随时更改漏洞的状态。

<a id="triage-strategies"></a>

## 分类策略

尝试以下策略，首先聚焦最重要的漏洞。

<a id="prioritize-vulnerabilities-of-significant-risk"></a>

### 优先处理重大风险漏洞

根据风险对漏洞进行优先级排序。

- 使用 [漏洞优先级排序 CI/CD 组件](../vulnerabilities/risk_assessment_data.md#vulnerability-prioritizer) 帮助对漏洞进行优先级排序。例如，CISA 已知利用漏洞 (KEV) 目录中的漏洞应作为最高优先级进行分析和修复，因为这些漏洞已知已被利用。
- 对于每个群组，访问 **安全资产清单**，可视化需要保护的资产，并了解需要采取哪些措施来改善安全态势。
- 对于每个群组，访问 **安全仪表板** 并查看 **项目安全状态** 面板。该面板按最高严重性漏洞对项目进行分组。使用此分组来优先对每个项目中的漏洞进行分类。
- 优先对您最高优先级的项目（例如部署给客户的应用程序）进行漏洞分类。
- 对于每个项目，查看漏洞报告。按严重性对漏洞进行分组，并将所有关键和高严重性漏洞的状态更改为“已确认”。

<a id="dismiss-vulnerabilities-of-low-risk"></a>

### 忽略低风险漏洞

批量处理低风险漏洞，以便集中精力处理最重要的漏洞。

- 有时漏洞会被检测到，但在后续的 CI/CD 流水线中不再检测到。在这种情况下，该漏洞的活动状态被标记为 **不再检测到**。如果这些漏洞的严重性是 **低** 或 **信息**，您可能选择忽略它们。在漏洞报告中使用筛选条件 **活动：不再检测到** 选择它们，并将其状态更改为 **已忽略**。您还可以通过使用 [漏洞管理策略](../policies/vulnerability_management_policy.md) 来自动化此操作。
- 按标识符忽略漏洞。如果漏洞被应用层之外的控制措施缓解，您可能选择忽略它们。在漏洞报告中使用 **标识符** 筛选条件选择它们，并将其状态更改为 **已忽略**。