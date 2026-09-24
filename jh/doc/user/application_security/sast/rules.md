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

极狐GitLab 静态应用程序安全测试 (SAST) 使用一组[分析器](analyzers.md)扫描代码以查找潜在漏洞。它会根据仓库中检测到的编程语言自动选择要运行哪些分析器。

每个分析器处理代码，然后使用规则来查找源代码中可能存在的弱点。分析器的规则决定了它报告哪些类型的弱点。

<a id="scope-of-rules"></a>

## 规则范围

SAST 专注于安全弱点和漏洞。它不旨在发现一般的 bug 或评估整体代码质量或可维护性。

极狐GitLab 管理检测规则集，专注于识别可操作的安全弱点和漏洞。该规则集旨在针对影响最大的漏洞提供广泛的覆盖，同时最大限度地减少误报（即在不存在漏洞的情况下报告的漏洞）。

SAST 设计为在默认配置下使用，但如果需要，你可以[配置检测规则](#configure-rules-in-your-projects)。

<a id="source-of-rules"></a>

## 规则来源

SAST 使用的漏洞检测规则取决于所使用的分析器，可以是极狐GitLab Advanced SAST 或基于 Semgrep 的分析器。

<a id="gitlab-advanced-sast"></a>

### 极狐GitLab Advanced SAST

{{< details >}}

- Tier: 旗舰版

{{< /details >}}

极狐GitLab 为[极狐GitLab Advanced SAST](gitlab_advanced_sast.md) 创建、维护和支持规则。其规则是定制构建的，以利用极狐GitLab Advanced SAST 扫描引擎的跨文件、跨函数分析能力。极狐GitLab Advanced SAST 规则集不是开源的，也不同于其他任何分析器的规则集。

有关极狐GitLab Advanced SAST 检测的漏洞类型，请参阅[漏洞检测标准](gitlab_advanced_sast.md#vulnerability-detection-criteria)。

有关极狐GitLab Advanced SAST 使用的所有规则列表，请参阅[极狐GitLab Advanced SAST 规则](glas_rules_docs/_index.md)。

<a id="semgrep-based-analyzer"></a>

### 基于 Semgrep 的分析器

极狐GitLab 创建、维护和支持用于基于 Semgrep 的极狐GitLab SAST 分析器的规则。该分析器可以在单个 CI/CD 流水线作业中扫描[多种语言](_index.md#supported-languages-and-frameworks)。它结合了：

- Semgrep 开源引擎。
- 极狐GitLab 管理的检测规则集，该规则集在[极狐GitLab 管理的开源 `sast-rules` 项目](https://jihulab.com/gitlab-cn/security-products/sast-rules)中管理。
- 极狐GitLab 专有技术用于[漏洞跟踪](_index.md#advanced-vulnerability-tracking)。

<a id="other-analyzers"></a>

### 其他分析器

极狐GitLab SAST 使用其他分析器来扫描剩余的[支持语言](_index.md#supported-languages-and-frameworks)。这些扫描的规则在每个扫描器的上游项目中定义。

<a id="how-rule-updates-are-released"></a>

## 规则更新发布的方式

极狐GitLab 根据客户反馈和内部研究定期更新规则。规则作为每个分析器的容器镜像的一部分发布。除非你[手动将分析器固定到特定版本](_index.md#pin-analyzer-image-version)，否则你会自动获取更新后的分析器和规则。

如果有相关更新，分析器及其规则将[至少每月更新一次](../detect/vulnerability_scanner_maintenance.md)。

<a id="rule-update-policies"></a>

### 规则更新政策

SAST 规则的更新不属于[破坏性变更](../../../update/terminology.md#breaking-change)。这意味着规则可能被添加、删除或更新，而无需事先通知。

但是，为了使规则更改更加方便和理解，极狐GitLab：

- 记录计划中或已完成的[规则更改](#important-rule-changes)。
- 对于基于 Semgrep 的分析器，在其规则被移除后，自动[解决](_index.md#automatic-vulnerability-resolution)这些规则产生的发现。
- 允许你[批量更改状态为“不再检测到”的漏洞的活动](../vulnerability_report/_index.md#change-status-of-vulnerabilities)。
- 评估拟议的规则更改对现有漏洞记录的影响。

<a id="configure-rules-in-your-projects"></a>

## 在项目中配置规则

除非你有特定的理由进行更改，否则你应该使用默认的 SAST 规则。默认规则集旨在与大多数项目相关。

但是，如果需要，你可以[自定义要使用的规则](#apply-local-rule-preferences)或[控制规则变更的推出方式](#coordinate-rule-rollouts)。

<a id="apply-local-rule-preferences"></a>

### 应用本地规则偏好

你可能希望自定义 SAST 扫描中使用的规则，因为：

- 你的组织已为特定漏洞类别分配了优先级，例如选择先处理跨站脚本攻击 (XSS) 或 SQL 注入，然后再处理其他类别的漏洞。
- 你认为某个特定规则是误报结果，或者在代码库的上下文中不相关。

要更改用于扫描项目的规则、调整其严重性或应用其他偏好设置，请参阅[自定义规则集](customize_rulesets.md)。如果你的自定义设置可能对其他用户有益，请考虑[向极狐GitLab 报告问题](#report-a-problem-with-a-gitlab-sast-rule)。

<a id="coordinate-rule-rollouts"></a>

### 协调规则发布

为了控制规则更改的推出，你可以[将 SAST 分析器固定到特定版本](_index.md#pin-analyzer-image-version)。

如果你想在多个项目中同时进行这些更改，请考虑在以下位置设置变量：

- [群组级别的 CI/CD 变量](../../../ci/variables/_index.md#for-a-group)。
- [扫描执行策略](../policies/scan_execution_policies.md)中的自定义 CI/CD 变量。

<a id="report-a-problem-with-a-gitlab-sast-rule"></a>

## 报告极狐GitLab SAST 规则的问题
<!-- This title is intended to match common search queries users might make. -->

极狐GitLab 欢迎对 SAST 中使用的规则集做出贡献。贡献可以解决以下问题：

- 误报结果，即潜在的漏洞是不正确的。
- 漏报结果，即 SAST 未报告确实存在的潜在漏洞。
- 规则的名称、严重性评级、描述、指南或其他解释性内容。

如果你认为某个检测规则可以改进以便所有用户受益，请考虑：

- 向 [`sast-rules` 仓库](https://jihulab.com/gitlab-cn/security-products/sast-rules)提交合并请求。详情请参阅[贡献指南](https://jihulab.com/gitlab-cn/security-products/sast-rules#contributing)。
- 在 [`gitlab-org/gitlab` 议题跟踪器](https://jihulab.com/gitlab-cn/-/issues/)中提交议题。
  - 发表一条评论，内容为 `@gitlab-bot label ~"group::static analysis" ~"Category:SAST"`，这样你的议题就会进入正确的分类工作流程。

<a id="important-rule-changes"></a>

## 重要规则更改

极狐GitLab [定期](#how-rule-updates-are-released)更新 SAST 规则。本节重点介绍最重要的更改。更多详细信息，请参阅发布公告和提供的变更日志（CHANGELOG）链接。

<a id="rule-changes-in-the-semgrep-based-analyzer"></a>

### 基于 Semgrep 的分析器中的规则更改

针对 Semgrep 扫描的极狐GitLab 管理规则集的主要更改包括：

- 从极狐GitLab 16.3 开始，极狐GitLab 静态分析和漏洞研究团队正致力于移除那些倾向于产生大量误报结果或可操作的真正漏洞结果不足的规则。这些被移除规则的现有发现将[自动解决](_index.md#automatic-vulnerability-resolution)；它们不再出现在[安全仪表盘](../security_dashboard/_index.md#project-security-dashboard)或[漏洞报告](../vulnerability_report/_index.md)的默认视图中。这项工作在[史诗 10907](https://jihulab.com/groups/gitlab-cn/-/epics/10907)中进行跟踪。
- 在极狐GitLab 16.0 至 16.2 中，极狐GitLab 漏洞研究团队更新了每个结果中包含的指南。
- 在极狐GitLab 15.10 中，`detect-object-injection` 规则[被默认移除](https://jihulab.com/gitlab-cn/-/issues/373920)，其发现也[自动解决](_index.md#automatic-vulnerability-resolution)。

有关更多详细信息，请参阅 [`sast-rules` 的变更日志](https://jihulab.com/gitlab-cn/security-products/sast-rules/-/blob/main/CHANGELOG.md)。

<a id="rule-changes-in-other-analyzers"></a>

### 其他分析器中的规则更改

有关每个[分析器](analyzers.md)的变更，包括每个版本中包含的新规则或更新规则，请参阅每个分析器的变更日志（CHANGELOG）文件。