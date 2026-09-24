---
stage: Release Notes
group: Monthly Release
date: 2023-08-22
title: "极狐GitLab 16.3 发布说明"
description: "极狐GitLab 16.3 released with New velocity metrics in the Value Streams Dashboard"
---

<!-- markdownlint-disable -->
<!-- vale off -->

2023 年 8 月 22 日，极狐GitLab 16.3 发布了以下功能。

<a id="primary-features"></a>

## 主要功能

<a id="new-velocity-metrics-in-the-value-streams-dashboard"></a>

### 价值流仪表盘中的新速度指标

{{< details >}}

- Tier: 旗舰版
- Offering: JihuLab.com
- Links: [文档](../../user/analytics/value_streams_dashboard.md) | [相关议题](https://jihulab.com/gitlab-cn/gitlab/-/issues/383665)

{{< /details >}}

[价值流仪表盘](https://gitlab.cn/blog/getting-started-with-value-streams-dashboard/) 增强了新指标：**合并请求 (MR) 吞吐量** 和 **已关闭议题总数**（速度）。在极狐GitLab 中，**MR 吞吐量** 是每月合并的合并请求数量，**已关闭议题总数** 是某个时间点已关闭的工作项数量。

借助这些指标，你可以识别生产效率低或高的月份以及[合并请求和代码审查流程](../../user/analytics/merge_request_analytics.md)的效率。然后你可以判断[价值流交付](../../user/group/value_stream_analytics/_index.md)是否在加速。

随着时间推移，这些指标会从 MR 和议题积累历史数据。团队可以使用这些数据来确定交付速率是在加速还是需要改进，并为可交付的工作量提供更准确的估算或预测。

为了帮助我们改进价值流仪表盘，请通过此[调查](https://gitlab.fra1.qualtrics.com/jfe/form/SV_50guMGNU2HhLeT4)分享你的体验反馈。

<a id="connect-to-workspaces-with-ssh"></a>

### 通过 SSH 连接到工作区

{{< details >}}

- Tier: 专业版, 旗舰版
- Offering: JihuLab.com
- Links: [文档](../../user/workspace/configuration.md#connect-to-a-workspace-with-ssh)

{{< /details >}}

通过工作区，你可以创建可重现、临时的云端运行时环境。自从极狐GitLab 16.0 引入这一功能以来，使用工作区的唯一方式是通过直接在环境中运行的基于浏览器的 Web IDE。然而，Web IDE 可能并不总是适合你的工具。

在极狐GitLab 16.3 中，你现在可以通过 SSH 从桌面安全地连接到工作区，并使用本地工具和扩展。第一个迭代支持直接在 VS Code 中或通过 Vim 或 Emacs 等编辑器从命令行连接。对其他编辑器（如 JetBrains IDE 和 JupyterLab）的支持计划在未来的迭代中实现。

<a id="flux-sync-status-visualization"></a>

### Flux 同步状态可视化

{{< details >}}

- Tier: 基础版, 专业版, 旗舰版
- Offering: JihuLab.com
- Links: [文档](../../ci/environments/kubernetes_dashboard.md#flux-sync-status) | [相关议题](https://jihulab.com/gitlab-cn/gitlab/-/issues/391581)

{{< /details >}}

在之前的版本中，你可能使用 `kubectl` 或其他第三方工具来检查 Flux 部署的状态。从极狐GitLab 16.3 开始，你可以通过环境 UI 来检查你的部署。

部署依赖于 Flux `Kustomization` 和 `HelmRelease` 资源来收集给定环境的状态，这要求为环境配置命名空间。默认情况下，极狐GitLab 会搜索项目 slug 名称的 `Kustomization` 和 `HelmRelease` 资源。你可以在环境设置中自定义极狐GitLab 要查找的名称。

<a id="additional-filtering-for-scan-result-policies"></a>

### 扫描结果策略的额外过滤

{{< details >}}

- Tier: 旗舰版
- Offering: JihuLab.com
- Links: [文档](../../user/application_security/policies/merge_request_approval_policies.md) | [相关史诗](https://jihulab.com/groups/gitlab-cn/-/epics/6826)

{{< /details >}}

确定安全或合规扫描的哪些结果需要处理，是安全和合规团队面临的一项重大挑战。扫描结果策略的精细过滤器将帮助你从噪音中筛选出最需要关注的漏洞或违规。这些新过滤器和过滤器更新将简化你的工作流程：

- 状态：状态规则变更引入了更直观的“新”与“已有”漏洞的强制执行。新的状态字段 `new_needs_triage` 允许你只筛选需要分类的新漏洞。
- 年龄：创建策略以在漏洞超出 SLA（基于检测日期计算的天数、月数或年数）时强制审批。
- 修复可用：缩小策略焦点，以处理有修复可用的依赖项。
- 误报：过滤掉由我们的漏洞提取工具针对 SAST 结果检测到的误报，以及通过 Rezilion 针对容器扫描和依赖项扫描结果检测到的误报。

<a id="security-findings-in-vs-code"></a>

### VS Code 中的安全发现

{{< details >}}

- Tier: 旗舰版
- Links: [文档](../../editor_extensions/visual_studio_code/_index.md) | [相关史诗](https://jihulab.com/groups/gitlab-cn/-/epics/10407)

{{< /details >}}

你现在可以直接在 Visual Studio Code (VS Code) 中看到安全发现，就像在合并请求中一样。

你此前已经可以在极狐GitLab Workflow 面板中监控 CI/CD 流水线的状态、查看 CI/CD 作业日志，并在开发工作流中导航。
现在，当你为分支创建合并请求后，你还可以看到之前在默认分支上未发现的新安全发现列表。

这一新功能是 VS Code 的 [GitLab Workflow](https://marketplace.visualstudio.com/items?itemName=GitLab.gitlab-workflow) 扩展的一部分。
安全扫描结果从 API 获取，因此这一功能适用于使用 JihuLab.com 或运行极狐GitLab 16.1 或更高版本的私有化部署实例的开发者。

<a id="use-the-needs-keyword-with-parallel-jobs"></a>

### 在并行作业中使用 `needs` 关键字

{{< details >}}

- Tier: 基础版, 专业版, 旗舰版
- Offering: JihuLab.com
- Links: [文档](../../ci/yaml/_index.md#needsparallelmatrix) | [相关议题](https://jihulab.com/gitlab-cn/gitlab/-/issues/254821)

{{< /details >}}

`needs` 关键字用于定义作业之间的依赖关系。你可以使用该关键字将作业配置为依赖于特定的早期作业，而不是遵循阶段顺序。当依赖作业完成后，该作业可以立即启动，从而加快流水线速度。

此前，无法使用 `needs` 关键字将[并行矩阵](../../ci/yaml/_index.md#parallelmatrix)作业设置为依赖项，但在此版本中，我们也启用了对并行矩阵作业使用 `needs` 的能力。现在，你可以为并行矩阵作业定义灵活的依赖关系，这有助于进一步加快你的流水线速度！作业启动得越早，流水线完成得越早！

<a id="more-powerful-gitlab-saas-runners-on-linux"></a>

### 更强大的 Linux 极狐GitLab SaaS Runner

{{< details >}}

- Tier: Silver, Gold
- Offering: JihuLab.com
- Links: [文档](../../ci/runners/hosted_runners/linux.md) | [相关议题](https://jihulab.com/gitlab-cn/gitlab/-/issues/388165)

{{< /details >}}

最近升级了所有 Linux SaaS Runner 后，我们现在推出了 `xlarge` 和 `2xlarge` [Linux SaaS Runner](../../ci/runners/hosted_runners/linux.md)。这些 Runner 分别配备 16 和 32 个 vCPU，并与极狐GitLab CI/CD 完全集成，让你能够比以往更快地构建和测试应用程序。

我们决心提供业界最快的 CI/CD 构建速度，并期待看到团队实现更短的反馈周期，最终更快地交付软件。

<a id="azure-key-vault-secrets-manager-support"></a>

### Azure Key Vault 密钥管理器支持

{{< details >}}

- Tier: 专业版, 旗舰版
- Offering: JihuLab.com
- Links: [文档](../../ci/secrets/azure_key_vault.md) | [相关议题](https://jihulab.com/gitlab-cn/gitlab/-/issues/271271)

{{< /details >}}

存储在 Azure Key Vault 中的密钥现在可以轻松检索并用于 CI/CD 作业。我们的新集成简化了通过极狐GitLab CI/CD 与 Azure Key Vault 交互的过程，帮助你简化构建和部署流程！

<a id="scale-and-deployments"></a>

## 扩展和部署

<a id="include-or-exclude-archived-projects-from-project-search-results"></a>

### 在项目搜索结果中包含或排除归档项目

{{< details >}}

- Tier: 基础版, 专业版, 旗舰版
- Offering: JihuLab.com
- Links: [文档](../../user/search/_index.md#include-archived-projects-in-search-results) | [相关议题](https://jihulab.com/gitlab-cn/gitlab/-/issues/413237)

{{< /details >}}

你现在可以选择在搜索结果中包含或排除归档项目。默认情况下，归档项目被排除。此功能适用于极狐GitLab 中的项目搜索。对[其他全局搜索范围](../../user/search/_index.md)的支持计划在未来版本中推出。

<a id="omnibus-improvements"></a>

### Omnibus 改进

{{< details >}}

- Tier: 基础版, 专业版, 旗舰版
- Links: [文档](https://gitlab.cn/docs/omnibus/)

{{< /details >}}

- 极狐GitLab 16.3 包含 [Mattermost 8.0](https://mattermost.com/blog/mattermost-v8-0-is-now-available/)。此版本包含[安全更新](https://mattermost.com/security-updates/)，建议从早期版本升级。
- 我们的 Amazon Linux 构建现已是 [Amazon Linux 2023](https://aws.amazon.com/linux/amazon-linux-2023/)。Amazon Linux 2022 从未正式 GA，且已被 Amazon Linux 2023 取代，因此我们将产品线调整为更新后的版本。

<a id="audit-event-recorded-for-applications-settings-change"></a>

### 应用设置变更的审计事件记录

{{< details >}}

- Tier: 专业版, 旗舰版
- Offering: JihuLab.com
- Links: [文档](../../administration/compliance/audit_event_reports.md) | [相关议题](https://jihulab.com/gitlab-cn/gitlab/-/issues/282428)

{{< /details >}}

实例、项目和群组级别的应用设置变更现在会记录在审计日志中，并记录进行更改的用户。这改进了私有化部署和 SaaS 的应用设置审计。

<a id="preserve-pull-request-reviewers-when-importing-from-bitbucket-server"></a>

### 从 BitBucket Server 导入时保留拉取请求审查者

{{< details >}}

- Tier: 基础版, 专业版, 旗舰版
- Offering: JihuLab.com
- Links: [文档](../../integration/bitbucket.md) | [相关议题](https://jihulab.com/gitlab-cn/gitlab/-/issues/416611)

{{< /details >}}

到目前为止，BitBucket Server 导入器未导入拉取请求 (PR) 审查者，而是将其分类为参与者。PR 审查者的信息对于审计和合规非常重要。

在极狐GitLab 16.3 中，我们添加了对从 BitBucket 正确导入 PR 审查者的支持。在极狐GitLab 中，他们将成为合并请求审查者。

<a id="configurable-import-limits-available-in-application-settings"></a>

### 应用设置中的可配置导入限制

{{< details >}}

- Tier: 基础版, 专业版, 旗舰版
- Links: [文档](../../user/group/import/_index.md#limits)

{{< /details >}}

直接迁移和导入导出文件存在硬编码限制。

在此版本中，我们使其中一些限制可在应用设置中配置，允许私有化部署极狐GitLab 管理员根据需要进行调整：

- [直接迁移中可从源实例下载的最大关系大小](../../administration/settings/account_and_limit_settings.md)。此前硬编码为 5 GB。在 JihuLab.com 上，我们将此限制设置为 5 GB。
- [可从远程对象存储（如 AWS S3）下载的远程导入文件最大大小](../../administration/settings/account_and_limit_settings.md)。此前硬编码为 10 GB。在 JihuLab.com 上，我们将此限制设置为 10 GB。

我们还添加了一个新的[导入归档文件最大解压大小](../../administration/settings/account_and_limit_settings.md)应用设置，取代了 `validate_import_decompressed_archive_size` 功能标志。此限制硬编码为 10 GB。在 JihuLab.com 上，我们将此限制设置为 25 GB。

借助这些新的应用设置，私有化部署极狐GitLab 和 JihuLab.com 的管理员都可以根据需要调整这些限制。

<a id="new-navigation-has-color-themes-available"></a>

### 新导航提供颜色主题

{{< details >}}

- Tier: 基础版, 专业版, 旗舰版
- Links: [文档](../../user/profile/preferences.md)

{{< /details >}}

启用新导航后，你现在可以选择五种不同的颜色主题，并为每种主题选择浅色或深色变体。使用主题来识别不同的环境或选择你喜欢的颜色。

<a id="no-entity-export-timeout-for-migrations-by-direct-transfer"></a>

### 直接迁移无实体导出超时

{{< details >}}

- Tier: 基础版, 专业版, 旗舰版
- Offering: JihuLab.com
- Links: [文档](../../user/group/import/_index.md#limits) | [相关议题](https://jihulab.com/gitlab-cn/gitlab/-/issues/392725)

{{< /details >}}

到目前为止，通过直接迁移迁移群组和项目有 90 分钟的导出超时。这一限制实际上将大型项目排除在迁移之外，因为只有能在 90 分钟内完成的项目才被允许迁移。

整体迁移超时的上限是 4 小时，因此 90 分钟的导出超时是不必要的。在此里程碑中，该限制被移除，允许迁移更大的项目。

<a id="support-for-azure-ad-overage-claim"></a>

### 支持 Azure AD 超量声明

{{< details >}}

- Tier: 专业版, 旗舰版
- Offering: JihuLab.com
- Links: [文档](../../user/group/saml_sso/group_sync.md#microsoft-azure-active-directory-integration) | [相关议题](https://jihulab.com/gitlab-cn/gitlab/-/issues/414875)

{{< /details >}}

极狐GitLab SAML 群组同步现在支持 Azure AD（现在称为 Entra ID）超量声明，允许用户关联超过 150 个群组。之前的最大值为 150 个群组。有关更多信息，请参阅 [Microsoft group overages](https://learn.microsoft.com/en-us/security/zero-trust/develop/configure-tokens-group-claims-app-roles#group-overages)。

<a id="geo-verifies-group-wikis"></a>

### Geo 验证群组 Wiki

{{< details >}}

- Tier: 专业版, 旗舰版
- Links: [文档](../../administration/geo/_index.md) | [相关议题](https://jihulab.com/gitlab-cn/gitlab/-/issues/323897)

{{< /details >}}

Geo 现在能够检测并纠正[群组 wiki](../../user/project/wiki/group.md) 在静态和传输中的数据损坏。如果你将 Geo 用作灾难恢复策略的一部分，这有助于在发生故障转移时防止数据丢失。

<a id="unified-devops-and-security"></a>

## 统一 DevOps 和安全

<a id="codeowners-file-syntax-and-format-validation"></a>

### CODEOWNERS 文件语法和格式验证

{{< details >}}

- Tier: 专业版, 旗舰版
- Links: [文档](../../user/project/codeowners/reference.md)

{{< /details >}}

你现在可以在 UI 中看到 `CODEOWNERS` 文件是否存在语法或格式错误。能够指定代码所有者提供了极大的灵活性，允许用户配置多个文件位置、章节和规则。通过这种新的语法验证，`CODEOWNERS` 文件中的错误将在极狐GitLab UI 中显示，从而更容易发现和修复问题。以下错误将被显示：

- 包含空格的条目。
- 无法解析的章节。
- 格式错误的所有者。
- 不可访问的所有者。
- 零所有者。
- 未达到要求的审批数。

此前，`CODEOWNERS` 文件不会验证输入的信息。这可能导致创建：

- 针对不存在文件/路径的规则。
- 与其他现有规则冲突的规则。
- 因语法错误而不适用的规则。

<a id="kubernetes-1-27-support"></a>

### 支持 Kubernetes 1.27

{{< details >}}

- Tier: 基础版, 专业版, 旗舰版
- Offering: JihuLab.com
- Links: [文档](../../user/clusters/agent/_index.md) | [相关议题](https://jihulab.com/gitlab-cn/gitlab/-/issues/420859)

{{< /details >}}

此版本添加了对 2023 年 4 月发布的 Kubernetes 版本 1.27 的全面支持。如果你使用 Kubernetes，现在可以将集群升级到最新版本，并利用其所有功能。

你可以阅读更多关于[我们的 Kubernetes 支持策略](../../user/clusters/agent/_index.md)以及其他受支持的 Kubernetes 版本。

<a id="wrap-feature-flag-names-instead-of-truncating"></a>

### 换行而非截断功能标志名称

{{< details >}}

- Tier: 基础版, 专业版, 旗舰版
- Offering: JihuLab.com
- Links: [文档](../../operations/feature_flags.md) | [相关议题](https://jihulab.com/gitlab-cn/gitlab/-/issues/418147)

{{< /details >}}

如果你在以前版本的极狐GitLab 中使用功能标志，可能注意到较长的功能标志名称会被截断。这导致难以快速区分相似的功能标志名称。

在极狐GitLab 16.3 中，将显示完整的功能标志名称。如有需要，长名称将换行显示。

<a id="names-for-audit-event-streams"></a>

### 审计事件流的名称

{{< details >}}

- Tier: 旗舰版
- Offering: JihuLab.com
- Links: [文档](../../administration/compliance/audit_event_reports.md)

{{< /details >}}

此前，审计事件流目标由目标 URL 分配。当你为一个群组或实例设置多个流时，这可能会导致混淆，因为你必须在 UI 中展开目标才能查看已应用哪些过滤器和自定义标头。

在极狐GitLab 16.3 中，你现在可以为审计事件流目标命名，帮助在定义了多个流目标时识别和区分它们。

<a id="explain-this-vulnerability"></a>

### 解释此漏洞

{{< details >}}

- Tier: Gold
- Offering: JihuLab.com
- Links: [文档](../../user/application_security/vulnerabilities/_index.md) | [相关史诗](https://jihulab.com/groups/gitlab-cn/-/epics/10368)

{{< /details >}}

极狐GitLab 会显示包含相关信息的漏洞，然而有时不清楚从哪里着手。研究和综合漏洞记录中显示的信息需要时间。此外，弄清楚如何修复特定漏洞可能很困难。通过此 Beta 版本，你可以点击按钮获取 AI 生成的解释和缓解漏洞的建议。

<a id="compliance-reports-renamed-to-compliance-center"></a>

### 合规报告更名为合规中心

{{< details >}}

- Tier: 旗舰版
- Offering: JihuLab.com
- Links: [文档](../../user/compliance/compliance_center/_index.md)

{{< /details >}}

为了促进合规相关功能从报告向管理的扩展，极狐GitLab 的合规报告部分已更名，以反映该领域不断扩大的范围。

从极狐GitLab 16.3 开始，合规报告称为合规中心。

<a id="improve-accuracy-of-scan-result-policies"></a>

### 提高扫描结果策略的准确性

{{< details >}}

- Tier: 旗舰版
- Offering: JihuLab.com
- Links: [文档](../../user/application_security/policies/merge_request_approval_policies.md) | [相关史诗](https://jihulab.com/gitlab-cn/gitlab/-/issues/379108)

{{< /details >}}

扫描结果策略是一种安全策略，用于评估并在特定规则违规时阻止合并请求。审批者可以审查和批准变更，或者与他们的开发团队合作解决任何问题（例如处理严重的安全漏洞）。

此前，我们比较最新源分支和目标分支中的漏洞，以检测任何新的策略规则违反。但这可能无法捕获各种流水线来源运行的扫描检测到的漏洞。为了提高准确性，我们现在比较每个流水线来源（不包括父子流水线）的最新完成流水线。这将确保更全面的评估，并减少在意外情况下需要审批的情况。

<a id="instance-level-streaming-audit-event-filters"></a>

### 实例级流审计事件过滤

{{< details >}}

- Tier: 旗舰版
- Links: [文档](../../administration/compliance/audit_event_reports.md)

{{< /details >}}

在极狐GitLab 16.2 中，我们引入了实例级审计事件流。但是，当时没有可应用于这些流的过滤器。

在极狐GitLab 16.3 中，你现在可以按审计事件类型为实例级审计事件流应用过滤器。通过在 UI 中添加这些过滤器，你可以仅捕获审计事件的子集发送到每个流位置，只关注与你相关的事件。

<a id="security-bot-to-trigger-scan-execution-policies-pipelines"></a>

### 安全 Bot 触发扫描执行策略流水线

{{< details >}}

- Tier: 旗舰版
- Offering: JihuLab.com
- Links: [文档](../../user/application_security/policies/scan_execution_policies.md) | [相关史诗](https://jihulab.com/groups/gitlab-cn/-/epics/10756)

{{< /details >}}

将创建安全 bot 用户来支持管理后台任务，并为所有新建或更新的安全策略项目链接强制执行安全策略。这将简化安全和合规团队成员配置和执行策略的过程，特别是消除了安全策略项目维护者同时需要在开发项目中保持 `Developer` 访问权限的需要。安全策略 bot 用户还将使受强制项目内的用户更清楚地知道何时流水线是代表安全策略执行的，因为此 bot 用户将是流水线作者。

当安全策略项目链接到群组或子群组时，将在该群组或子群组中的每个项目中创建一个安全策略 bot。当链接到群组、子群组或单个项目时，会为给定项目或群组/子群组内的任何项目创建一个安全 bot 用户。当前，任何已有安全策略项目链接的群组、子群组或项目此时不会受到影响，但用户可以重新建立现有链接以利用此功能。在极狐GitLab 16.4 中，我们计划为 JihuLab.com 上所有已有安全策略项目链接的项目[启用安全 bot](https://jihulab.com/gitlab-cn/gitlab/-/issues/414376)。

<a id="sast-analyzer-updates"></a>

### SAST 分析器更新

{{< details >}}

- Tier: 基础版, 专业版, 旗舰版
- Links: [文档](../../user/application_security/sast/analyzers.md) | [相关议题](../../user/application_security/_index.md)

{{< /details >}}

极狐GitLab SAST 包含[多个安全分析器](../../user/application_security/sast/_index.md#supported-languages-and-frameworks)，由极狐GitLab 静态分析团队积极维护、更新和支持。我们在 16.3 发布里程碑中发布了以下更新：

- 基于 Kics 的分析器已更新为使用 Kics 引擎的 1.7.5 版本。此更新包括各种错误修复，还改进了 JSON 和 YAML 中自引用的错误处理。详情见 [CHANGELOG](https://gitlab.com/gitlab-org/security-products/analyzers/kics/-/blob/main/CHANGELOG.md?ref_type=heads#v414)。
- 基于 Semgrep 的分析器已更新，增加了在直通自定义配置期间指定模糊引用的支持。我们还更新了 SARIF 解析器，使用 Name 而不是 Title，并且不再因为 SARIF `toolExecutionNotifications` 级别的错误而失败扫描。详情见 [CHANGELOG](https://gitlab.com/gitlab-org/security-products/analyzers/semgrep/-/blob/main/CHANGELOG.md?ref_type=heads#v446)。

如果你[包含极狐GitLab 管理的 SAST 模板](../../user/application_security/sast/_index.md)（[`SAST.gitlab-ci.yml`](https://gitlab.com/gitlab-org/gitlab/blob/master/lib/gitlab/ci/templates/Security/SAST.gitlab-ci.yml)）并运行极狐GitLab 16.0 或更高版本，你将自动获得这些更新。
要停留在特定版本的分析器并防止自动更新，你可以[固定其版本](../../user/application_security/sast/_index.md)。

有关之前的变更，请参阅[上个月的更新](https://gitlab.cn/releases/2023/07/22/gitlab-16-2-released/#sast-analyzer-updates)。

<a id="dependency-and-license-scanning-support-for-java-v21"></a>

### 对 Java v21 的依赖项和许可证扫描支持

{{< details >}}

- Tier: 旗舰版
- Offering: JihuLab.com
- Links: [文档](../../user/application_security/dependency_scanning/legacy_dependency_scanning/_index.md#obtaining-dependency-information-by-parsing-lockfiles) | [相关议题](https://jihulab.com/gitlab-cn/gitlab/-/issues/387307)

{{< /details >}}
<a id="gitlab-dependency-and-license-scanning-now-support-analyzing-java-v21-maven-lock-files"></a>

极狐GitLab 依赖项和许可证扫描现在支持分析 Java v21 Maven 锁定文件。

<a id="runner-tags-enable-ui-based-configuration-of-on-demand-dast-scans"></a>

### Runner 标签支持按需 DAST 扫描的基于 UI 的配置

{{< details >}}

- Tier: 旗舰版
- Offering: JihuLab.com
- Links: [文档](../../user/application_security/dast/on-demand_scan.md) | [相关议题](https://gitlab.com/gitlab-org/gitlab/-/issues/345430)

{{< /details >}}

现在您可以使用标签来指定希望用于按需 DAST 扫描的 runner。在 16.3 之前，您可以通过 CI 配置文件使用私有 runner 来配置 DAST 扫描。这种基于 UI 的配置使得通过 UI 管理 DAST 扫描更加高效。

<a id="improved-sast-vulnerability-tracking"></a>

### 改进的 SAST 漏洞追踪

{{< details >}}

- Tier: 旗舰版
- Links: [文档](../../user/application_security/sast/_index.md#advanced-vulnerability-tracking) | [相关史诗](https://gitlab.com/groups/gitlab-org/-/epics/5144)

{{< /details >}}

极狐GitLab SAST [高级漏洞追踪](../../user/application_security/sast/_index.md#advanced-vulnerability-tracking) 通过跟踪代码迁移时的发现，使分类更高效。我们在 16.3 版本中推出了两项改进：

1. 扩展语言支持：除了其[现有覆盖范围](../../user/application_security/sast/_index.md#advanced-vulnerability-tracking) 外，我们还为以下语言启用了高级漏洞追踪：
   - C 和 C++，在基于 Flawfinder 的分析器中。
   - Java，在基于 MobSF 的分析器中。
   - JavaScript，在基于 NodeJS-Scan 的分析器中。
2. 更好的追踪：我们改进了追踪算法，以处理 JavaScript 中的匿名函数。

这是基于之前在[极狐GitLab 16.2 版本](https://gitlab.cn/releases/2023/07/22/gitlab-16-2-released/#improved-sast-vulnerability-tracking) 中发布的扩展和改进。我们正在追踪进一步的改进，包括扩展到更多语言、更好地处理更多语言结构，以及改进 Python 和 Ruby 的追踪，请参见[史诗 5144](https://gitlab.com/groups/gitlab-org/-/epics/5144)。

这些变更已包含在极狐GitLab SAST [分析器](../../user/application_security/sast/analyzers.md) 的[更新版本](https://gitlab.cn/docs/#sast-analyzer-updates) 中。在项目使用更新后的分析器扫描后，项目的漏洞发现会更新新的追踪签名。除非您已[将 SAST 分析器固定到特定版本](../../user/application_security/sast/_index.md)，否则无需采取任何操作即可获得此更新。

<a id="automatic-response-to-leaked-postman-api-keys"></a>

### 对泄露的 Postman API 密钥的自动响应

{{< details >}}

- Tier: Gold
- Links: [文档](../../user/application_security/secret_detection/automatic_response.md) | [相关议题](https://gitlab.com/gitlab-org/gitlab/-/issues/403825)

{{< /details >}}

我们将密钥检测与 Postman 集成，以更好地保护在极狐GitLab 项目中使用 Postman 的客户。

密钥检测会搜索 [Postman API 密钥](https://learning.postman.com/docs/developer/postman-api/authentication/)。如果密钥在 JihuLab.com 上的公开项目中暴露，极狐GitLab 会将泄露的密钥发送给 Postman。Postman 验证密钥，然后[通知 Postman API 密钥的所有者](https://learning.postman.com/docs/administration/token-scanner/#protecting-postman-api-keys-in-gitlab)。

对于已在 JihuLab.com 上[启用密钥检测](../../user/application_security/secret_detection/_index.md) 的项目，此集成默认开启。密钥检测扫描在所有极狐GitLab 版本中均可用，但对泄露密钥的自动响应目前仅适用于旗舰版项目。

有关更多详细信息，请参阅 [Postman 关于此集成的博客文章](https://blog.postman.com/protecting-your-postman-api-keys-in-gitlab/)。

<a id="expose-pipeline-name-as-a-predefined-cicd-variable"></a>

### 将流水线名称暴露为预定义的 CI/CD 变量

{{< details >}}

- Tier: 免费版，专业版，旗舰版
- Offering: JihuLab.com
- Links: [文档](../../ci/variables/predefined_variables.md) | [相关议题](https://gitlab.com/gitlab-org/gitlab/-/issues/420002)

{{< /details >}}

通过 [`workflow:name`](../../ci/yaml/_index.md#workflowname) 关键字定义的流水线名称现在可以通过预定义变量 `$CI_PIPELINE_NAME` 访问。

<a id="gitlab-runner-163"></a>

### 极狐GitLab Runner 16.3

{{< details >}}

- Tier: 免费版，专业版，旗舰版
- Links: [文档](https://gitlab.cn/docs/runner)

{{< /details >}}

我们还在今天发布了极狐GitLab Runner 16.3！极狐GitLab Runner 是轻量级、高可扩展的代理，用于运行您的 CI/CD 作业并将结果发送回极狐GitLab 实例。极狐GitLab Runner 与极狐GitLab CI/CD 协同工作，而极狐GitLab CI/CD 是极狐GitLab 自带的开源持续集成服务。

<a id="whats-new"></a>

#### 新功能

- [默认将项目克隆目录配置为安全](https://jihulab.com/gitlab-cn/gitlab-runner/-/issues/29022)

<a id="bug-fixes"></a>

#### 错误修复

- [Runner v16.2.0 在 Debian/RHEL 仓库中不可用](https://jihulab.com/gitlab-cn/gitlab-runner/-/issues/36048)
- [使用 shell executor 的极狐GitLab Runner 有时无法获取子模块](https://jihulab.com/gitlab-cn/gitlab-runner/-/issues/26993)

所有变更的列表位于极狐GitLab Runner [CHANGELOG](https://jihulab.com/gitlab-cn/gitlab-runner/blob/16-3-stable/CHANGELOG.md)。