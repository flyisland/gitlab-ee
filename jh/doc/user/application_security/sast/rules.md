---
stage: Application Security Testing
group: Static Analysis
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
title: SAST 规则
---

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: JihuLab.com，私有化部署

{{< /details >}}

极狐GitLab 静态应用程序安全测试（SAST）使用一组[分析器](analyzers.md)来扫描代码中的潜在漏洞。它会根据代码仓库中发现的编程语言自动选择要运行的分析器。

每个分析器都会处理代码，然后使用规则查找源代码中可能存在的弱点。分析器的规则决定了它会报告哪些类型的弱点。

<a id="scope-of-rules"></a>

## 规则范围

SAST 专注于安全弱点和漏洞。它并不旨在查找一般性缺陷，也不评估整体代码质量或可维护性。

极狐GitLab 管理检测规则集，重点识别可采取措施解决的安全弱点和漏洞。该规则集旨在针对影响最大的漏洞提供广泛覆盖，同时尽量减少误报（即报告了实际并不存在的漏洞）。

SAST 设计为在默认配置下使用，但您可以根据需要[配置检测规则](#configure-rules-in-your-projects)。

<a id="source-of-rules"></a>

## 规则来源

SAST 使用的漏洞检测规则取决于所使用的分析器，即极狐GitLab Advanced SAST 或基于 Semgrep 的分析器。

<a id="gitlab-advanced-sast"></a>

### 极狐GitLab Advanced SAST

{{< details >}}

- Tier: 旗舰版

{{< /details >}}

极狐GitLab 为[极狐GitLab Advanced SAST](gitlab_advanced_sast.md)创建、维护并支持规则。
其规则是专门构建的，以充分利用极狐GitLab Advanced SAST 扫描引擎的跨文件、跨函数分析能力。极狐GitLab Advanced SAST 规则集不是开源的，也与其他任何分析器的规则集不同。

有关极狐GitLab Advanced SAST 检测哪些类型漏洞的详细信息，请参阅[漏洞检测标准](gitlab_advanced_sast.md#vulnerability-detection-criteria)。

有关极狐GitLab Advanced SAST 使用的所有规则列表，请参阅[极狐GitLab Advanced SAST 规则](glas_rules_docs/_index.md)。

<a id="semgrep-based-analyzer"></a>

### 基于 Semgrep 的分析器

极狐GitLab 创建、维护并支持基于 Semgrep 的极狐GitLab SAST 分析器所使用的规则。此分析器在单个 CI/CD 流水线作业中扫描[多种语言](_index.md#supported-languages-and-frameworks)。它结合了：

- Semgrep 开源引擎。
- 极狐GitLab 管理的检测规则集，在[由 GitLab 管理的开源 `sast-rules` 项目](https://gitlab.com/gitlab-org/security-products/sast-rules)中维护。
- 极狐GitLab 专有技术，用于[漏洞跟踪](_index.md#advanced-vulnerability-tracking)。

<a id="other-analyzers"></a>

### 其他分析器

极狐GitLab SAST 使用其他分析器来扫描其余[受支持的语言](_index.md#supported-languages-and-frameworks)。这些扫描的规则在每个扫描器的上游项目中定义。

<a id="how-rule-updates-are-released"></a>

## 规则更新如何发布

极狐GitLab 根据客户反馈和内部研究定期更新规则。规则作为每个分析器的容器镜像的一部分发布。除非您[手动将分析器固定到特定版本](_index.md#pin-analyzer-image-version)，否则会自动收到更新后的分析器和规则。

如果有相关更新，分析器及其规则会[至少每月](../detect/vulnerability_scanner_maintenance.md)更新一次。

<a id="rule-update-policies"></a>

### 规则更新策略

SAST 规则的更新不属于[破坏性变更](../../../update/terminology.md#breaking-change)。这意味着规则可能会在未事先通知的情况下添加、移除或更新。

不过，为了让规则变更更方便、更易于理解，极狐GitLab：

- 记录计划中或已完成的[规则变更](#important-rule-changes)。
- 对于基于 Semgrep 的分析器，在规则被移除后[自动解决](_index.md#automatic-vulnerability-resolution)由这些规则产生的发现结果。
- 使您能够[批量更改活动状态为“不再检测到”的漏洞的状态](../vulnerability_report/_index.md#change-status-of-vulnerabilities)。
- 评估提议的规则变更对现有漏洞记录的影响。

<a id="configure-rules-in-your-projects"></a>

## 在项目中配置规则

除非有特定理由需要更改，否则您应使用默认的 SAST 规则。默认规则集旨在适用于大多数项目。

不过，您可以根据需要[自定义使用哪些规则](#apply-local-rule-preferences)或[控制规则变更的推出方式](#coordinate-rule-rollouts)。

<a id="apply-local-rule-preferences"></a>

### 应用本地规则偏好

您可能希望自定义 SAST 扫描中使用的规则，原因包括：

- 您的组织已为特定漏洞类别分配了优先级，例如选择优先处理跨站脚本（XSS）或 SQL 注入，而不是其他类别的漏洞。
- 您认为某条特定规则是误报，或者在您的代码库上下文中不相关。

要更改用于扫描项目的规则、调整其严重性级别或应用其他偏好，请参阅[自定义规则集](customize_rulesets.md)。如果您的自定义设置会让其他用户受益，请考虑[向 GitLab 报告问题](#report-a-problem-with-a-gitlab-sast-rule)。

<a id="coordinate-rule-rollouts"></a>

### 协调规则推出

要控制规则变更的推出，您可以将 [SAST 分析器固定到特定版本](_index.md#pin-analyzer-image-version)。

如果您想在多个项目中同时进行这些更改，请考虑在以下位置设置变量：

- [群组级 CI/CD 变量](../../../ci/variables/_index.md#for-a-group)。
- [扫描执行策略](../policies/scan_execution_policies.md)中的自定义 CI/CD 变量。

<a id="report-a-problem-with-a-gitlab-sast-rule"></a>

## 报告极狐GitLab SAST 规则的问题
<!-- This title is intended to match common search queries users might make. -->

极狐GitLab 欢迎为 SAST 使用的规则集做出贡献。贡献可能涉及：

- 误报结果，即潜在漏洞不正确。
- 漏报结果，即 SAST 未报告确实存在的潜在漏洞。
- 规则的名称、严重性评级、描述、指导或其他说明性内容。

如果您认为某条检测规则可以为所有用户改进，请考虑：

- 向 [`sast-rules` 代码仓库](https://gitlab.com/gitlab-org/security-products/sast-rules)提交合并请求。有关详细信息，请参阅[贡献说明](https://gitlab.com/gitlab-org/security-products/sast-rules#contributing)。
- 在 [`gitlab-org/gitlab` 议题跟踪器](https://gitlab.com/gitlab-org/gitlab/-/issues/)中提交议题。
  - 发表评论 `@gitlab-bot label ~"group::static analysis" ~"Category:SAST"`，以便您的议题进入正确的分类工作流。

<a id="important-rule-changes"></a>

## 重要规则变更

极狐GitLab [定期](#how-rule-updates-are-released)更新 SAST 规则。
本节重点介绍最重要的变更。更多详细信息请参阅发布公告以及所提供的 CHANGELOG 链接。

<a id="rule-changes-in-the-semgrep-based-analyzer"></a>

### 基于 Semgrep 的分析器中的规则变更

用于 Semgrep 扫描的极狐GitLab 管理规则集的主要变更包括：

- 从极狐GitLab 16.3 开始，GitLab 静态分析和漏洞研究团队正在移除那些往往会产生过多误报结果或可操作真阳性结果不足的规则。这些已移除规则的现有发现结果会被[自动解决](_index.md#automatic-vulnerability-resolution)；它们不再出现在[安全仪表板](../security_dashboard/_index.md#project-security-dashboard)或[漏洞报告](../vulnerability_report/_index.md)的默认视图中。此工作记录在[史诗 10907](https://gitlab.com/groups/gitlab-org/-/epics/10907)中。
- 在极狐GitLab 16.0 到 16.2 中，GitLab 漏洞研究团队更新了每个结果中包含的指导。
- 在极狐GitLab 15.10 中，`detect-object-injection` 规则[默认被移除](https://gitlab.com/gitlab-org/gitlab/-/issues/373920)，其发现结果被[自动解决](_index.md#automatic-vulnerability-resolution)。

有关更多详细信息，请参阅 [`sast-rules`的 CHANGELOG](https://gitlab.com/gitlab-org/security-products/sast-rules/-/blob/main/CHANGELOG.md)。

<a id="rule-changes-in-other-analyzers"></a>

### 其他分析器中的规则变更

有关每个[分析器](analyzers.md)各版本中包含的变更（包括新增或更新的规则）的详细信息，请参阅其 CHANGELOG 文件。
