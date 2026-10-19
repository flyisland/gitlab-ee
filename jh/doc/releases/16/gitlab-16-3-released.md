---
stage: Release Notes
group: Monthly Release
date: 2023-08-22
title: "极狐GitLab 16.3 发布说明"
description: "极狐GitLab 16.3 发布，价值流仪表板新增速度指标"
---

<!-- markdownlint-disable -->
<!-- vale off -->

2023 年 8 月 22 日，极狐GitLab 16.3 发布了以下功能。

<a id="primary-features"></a>

## 主要功能

<a id="new-velocity-metrics-in-the-value-streams-dashboard"></a>

### 价值流仪表板新增速度指标

<!-- categories: Value Stream Management -->

{{< details >}}

- 适用版本: 旗舰版
- 交付方式: JihuLab.com、私有化部署
- 链接: [文档](../../user/analytics/value_streams_dashboard.md) | [相关议题](https://gitlab.com/gitlab-org/gitlab/-/issues/383665)

{{< /details >}}

[价值流仪表板](https://about.gitlab.com/blog/getting-started-with-value-streams-dashboard/)新增了以下指标：**合并请求吞吐量**和**已关闭议题总数**（速度）。在极狐GitLab 中，**合并请求吞吐量**是指每月合并的合并请求数量，**已关闭议题总数**是指在某一时间点已关闭的流项数量。

借助这些指标，您可以识别生产力低或高的月份，以及[合并请求和代码评审流程](../../user/analytics/merge_request_analytics.md)的效率。然后，您可以评估[价值流交付](../../user/group/value_stream_analytics/_index.md)是否在加速。

随着时间的推移，这些指标会累积合并请求和议题的历史数据。团队可以使用这些数据来确定交付速率是在加速还是需要改进，并更准确地估算或预测他们可以交付的工作量。

为了帮助我们改进价值流仪表板，请在此[调查](https://gitlab.fra1.qualtrics.com/jfe/form/SV_50guMGNU2HhLeT4)中分享您的使用体验。

<a id="connect-to-workspaces-with-ssh"></a>

### 使用 SSH 连接到工作区

<!-- categories: Workspaces -->

{{< details >}}

- 适用版本: 专业版、旗舰版
- 交付方式: JihuLab.com、私有化部署
- 链接: [文档](../../user/workspace/configuration.md#connect-to-a-workspace-with-ssh)

{{< /details >}}

借助工作区，您可以创建可重现、临时、基于云的运行时环境。自该功能在极狐GitLab 16.0 中引入以来，使用工作区的唯一方式是通过直接在该环境中运行的基于浏览器的 Web IDE。然而，Web IDE 可能并不总是适合您的工具。

在极狐GitLab 16.3 中，您现在可以通过 SSH 从桌面安全地连接到工作区，并使用本地工具和扩展。第一个迭代版本支持直接在 VS Code 中或通过命令行使用 Vim 或 Emacs 等编辑器进行 SSH 连接。未来迭代版本中计划支持 JetBrains IDE 和 JupyterLab 等其他编辑器。

<a id="flux-sync-status-visualization"></a>

### Flux 同步状态可视化

<!-- categories: Environment Management -->

{{< details >}}

- 适用版本: 基础版、专业版、旗舰版
- 交付方式: JihuLab.com、私有化部署
- 链接: [文档](../../ci/environments/kubernetes_dashboard.md#flux-sync-status) | [相关议题](https://gitlab.com/gitlab-org/gitlab/-/issues/391581)

{{< /details >}}

在之前的版本中，您可能使用 `kubectl` 或其他第三方工具来检查 Flux 部署的状态。从极狐GitLab 16.3 开始，您可以使用环境 UI 检查您的部署。

部署依赖 Flux `Kustomization` 和 `HelmRelease` 资源来收集给定环境的状态，这需要为环境配置命名空间。默认情况下，极狐GitLab 会在 `Kustomization` 和 `HelmRelease` 资源中搜索项目 slug 的名称。您可以在环境设置中自定义极狐GitLab 查找的名称。

<a id="additional-filtering-for-scan-result-policies"></a>

### 扫描结果策略的额外筛选

<!-- categories: Security Policy Management -->

{{< details >}}

- 适用版本: 旗舰版
- 交付方式: JihuLab.com、私有化部署
- 链接: [文档](../../user/application_security/policies/merge_request_approval_policies.md) | [相关史诗](https://gitlab.com/groups/gitlab-org/-/epics/6826)

{{< /details >}}

确定安全或合规扫描中哪些结果可操作，对安全和合规团队来说是一项重大挑战。扫描结果策略的精细筛选器将帮助您排除干扰，识别哪些漏洞或违规最需要您的关注。这些新的筛选器和筛选器更新将简化您的工作流：

- 状态：状态规则变更引入了对“新”漏洞与“先前存在”漏洞更直观的强制执行。新的状态字段 `new_needs_triage` 允许您仅筛选需要排查的新漏洞。
- 存在时长：创建策略，当漏洞超出 SLA（天、月或年）时，根据检测日期强制执行审批。
- 有可用修复：缩小策略的关注范围，以处理有可用修复的依赖项。
- 误报：过滤掉由我们的漏洞提取工具（针对 SAST 结果）以及通过 Rezilion（针对容器扫描和依赖项扫描结果）检测到的误报。

<a id="security-findings-in-vs-code"></a>

### VS Code 中的安全发现

<!-- categories: Editor Extensions, API Security, Container Scanning, DAST, Fuzz Testing, SAST, Secret Detection, Software Composition Analysis, Vulnerability Management -->

{{< details >}}

- 适用版本: 旗舰版
- 交付方式: 私有化部署
- 链接: [文档](../../editor_extensions/visual_studio_code/_index.md) | [相关史诗](https://gitlab.com/groups/gitlab-org/-/epics/10407)

{{< /details >}}

您现在可以直接在 Visual Studio Code (VS Code) 中查看安全发现，就像在合并请求中一样。

您已经可以在 GitLab Workflow 面板中监控 CI/CD 流水线的状态、查看 CI/CD 作业日志，并推进您的开发工作流。现在，在您为分支创建合并请求后，您还可以查看之前未在默认分支上发现的新安全发现列表。

此新功能是 VS Code 的 [GitLab Workflow](https://marketplace.visualstudio.com/items?itemName=GitLab.gitlab-workflow)的一部分。
安全扫描结果从 API 拉取，因此使用 JihuLab.com 或运行极狐GitLab 16.1 或更高版本的私有化部署实例的开发者均可使用此功能。

<a id="use-the-needs-keyword-with-parallel-jobs"></a>

### 将 `needs` 关键字与并行作业一起使用

<!-- categories: Pipeline Composition -->

{{< details >}}

- 适用版本: 基础版、专业版、旗舰版
- 交付方式: JihuLab.com、私有化部署
- 链接: [文档](../../ci/yaml/_index.md#needsparallelmatrix) | [相关议题](https://gitlab.com/gitlab-org/gitlab/-/issues/254821)

{{< /details >}}

`needs` 关键字用于定义作业之间的依赖关系。您可以使用该关键字将作业配置为依赖特定的更早作业，而不是遵循阶段顺序。当依赖的作业完成后，该作业可以立即开始，从而加速您的流水线。

以前，无法使用 `needs` 关键字将[并行矩阵](../../ci/yaml/_index.md#parallelmatrix)作业设置为依赖项，但在本次发布中，我们启用了将 `needs` 与并行矩阵作业一起使用的能力。您现在可以为并行矩阵作业定义灵活的依赖关系，这可以帮助您进一步加速流水线！您的作业越早开始，您的流水线就能越早完成！

<a id="more-powerful-gitlab-saas-runners-on-linux"></a>

### 更强大的 Linux 上的极狐GitLab SaaS Runner

<!-- categories: GitLab Hosted Runners -->

{{< details >}}

- 交付方式: JihuLab.com
- 链接: [文档](../../ci/runners/hosted_runners/linux.md) | [相关议题](https://gitlab.com/gitlab-org/gitlab/-/issues/388165)

{{< /details >}}

在最近升级了所有 Linux SaaS Runner 之后，我们现在推出了 `xlarge` 和 `2xlarge`[Linux 上的 SaaS Runner](../../ci/runners/hosted_runners/linux.md)。这些 Runner 分别配备 16 和 32 个 vCPU，并与极狐GitLab CI/CD 完全集成，让您能够以前所未有的速度构建和测试应用程序。

我们致力于提供业界最快的 CI/CD 构建速度，并期待看到团队实现更短的反馈周期，最终更快地交付软件。

<a id="azure-key-vault-secrets-manager-support"></a>

### Azure Key Vault 密钥管理器支持

<!-- categories: Secrets Management -->

{{< details >}}

- 适用版本: 专业版、旗舰版
- 交付方式: JihuLab.com、私有化部署
- 链接: [文档](../../ci/secrets/azure_key_vault.md) | [相关议题](https://gitlab.com/gitlab-org/gitlab/-/issues/271271)

{{< /details >}}

存储在 Azure Key Vault 中的密钥现在可以轻松检索并在 CI/CD 作业中使用。我们的新集成简化了通过极狐GitLab CI/CD 与 Azure Key Vault 交互的过程，帮助您简化构建和部署流程！

<a id="scale-and-deployments"></a>

## 规模和部署

<a id="include-or-exclude-archived-projects-from-project-search-results"></a>

### 在项目搜索结果中包含或排除已归档项目

<!-- categories: Global Search -->

{{< details >}}

- 适用版本: 基础版、专业版、旗舰版
- 交付方式: JihuLab.com、私有化部署
- 链接: [文档](../../user/search/_index.md#include-archived-projects-in-search-results) | [相关议题](https://gitlab.com/gitlab-org/gitlab/-/issues/413237)

{{< /details >}}

您现在可以选择在搜索结果中包含或排除已归档项目。默认情况下，已归档项目会被排除。此功能适用于极狐GitLab 中的项目搜索。未来版本中计划支持其他[全局搜索范围](../../user/search/_index.md)。

<a id="omnibus-improvements"></a>

### Omnibus 改进

<!-- categories: Omnibus Package -->

{{< details >}}

- 适用版本: 基础版、专业版、旗舰版
- 交付方式: 私有化部署
- 链接: [文档](https://gitlab.cn/docs/omnibus/)

{{< /details >}}

- 极狐GitLab 16.3 包含 [Mattermost 8.0](https://mattermost.com/blog/mattermost-v8-0-is-now-available/)。此版本包含
[安全更新](https://mattermost.com/security-updates/)，建议从更早版本升级。
- 我们的 Amazon Linux 构建现在使用 [Amazon Linux 2023](https://aws.amazon.com/linux/amazon-linux-2023/)。Amazon Linux 2022 从未
正式发布，已被 Amazon Linux 2023 取代，因此我们已将产品调整为更新后的版本。

<a id="audit-event-recorded-for-applications-settings-change"></a>

### 记录应用程序设置变更的审计事件

<!-- categories: Audit Events -->

{{< details >}}

- 适用版本: 专业版、旗舰版
- 交付方式: JihuLab.com、私有化部署
- 链接: [文档](../../administration/compliance/audit_event_reports.md) | [相关议题](https://gitlab.com/gitlab-org/gitlab/-/issues/282428)

{{< /details >}}

实例、项目和群组级别的应用程序设置变更现在会记录在审计日志中，同时记录进行变更的用户。这改进了私有化部署和 SaaS 的应用程序设置审计。

<a id="preserve-pull-request-reviewers-when-importing-from-bitbucket-server"></a>

### 从 BitBucket Server 导入时保留拉取请求审核人

<!-- categories: Importers -->

{{< details >}}

- 适用版本: 基础版、专业版、旗舰版
- 交付方式: JihuLab.com、私有化部署
- 链接: [文档](../../integration/bitbucket.md) | [相关议题](https://gitlab.com/gitlab-org/gitlab/-/issues/416611)

{{< /details >}}

到目前为止，BitBucket Server 导入器不会导入拉取请求 (PR) 审核人，而是将其归类为参与者。PR 审核人的信息从审计和合规角度来看非常重要。

在极狐GitLab 16.3 中，我们添加了对从 BitBucket 正确导入 PR 审核人的支持。在极狐GitLab 中，他们会成为合并请求审核人。

<a id="configurable-import-limits-available-in-application-settings"></a>

### 应用程序设置中提供可配置的导入限制

<!-- categories: Importers -->

{{< details >}}

- 适用版本: 基础版、专业版、旗舰版
- 交付方式: 私有化部署
- 链接: [文档](../../user/group/import/_index.md#limits)

{{< /details >}}

通过直接传输迁移和通过导入导出文件迁移都存在硬编码限制。

在本次发布中，我们将其中一些限制设为可在应用程序设置中配置，以便私有化部署的极狐GitLab 管理员根据需要进行调整：

- [直接传输中可从源实例下载的最大关系大小](../../administration/settings/account_and_limit_settings.md)。
以前硬编码为 5 GB。在 JihuLab.com 上，我们将此限制设为 5 GB。
- [可从远程对象存储（如 AWS S3）下载的远程导入文件的最大大小](../../administration/settings/account_and_limit_settings.md)。
以前硬编码为 10 GB。在 JihuLab.com 上，我们将此限制设为 10 GB。

我们还添加了一个新的[导入归档文件的最大解压文件大小](../../administration/settings/account_and_limit_settings.md)应用程序设置，它取代了 `validate_import_decompressed_archive_size` 功能标志。此限制硬编码为 10 GB。在 JihuLab.com 上，我们将此限制设为 25
GB。

借助这些新的应用程序设置，私有化部署的极狐GitLab 和 JihuLab.com 管理员都可以根据需要调整这些限制。

<a id="new-navigation-has-color-themes-available"></a>

### 新导航提供颜色主题

<!-- categories: Navigation -->

{{< details >}}

- 适用版本: 基础版、专业版、旗舰版
- 交付方式: 私有化部署
- 链接: [文档](../../user/profile/preferences.md)

{{< /details >}}

启用新导航后，您现在可以从五种不同的颜色主题中选择一种，并为每种主题选择浅色或深色变体。使用主题来区分不同的环境，或选择您喜欢的颜色。

<a id="no-entity-export-timeout-for-migrations-by-direct-transfer"></a>

### 通过直接传输迁移时没有实体导出超时

<!-- categories: Importers -->

{{< details >}}

- 适用版本: 基础版、专业版、旗舰版
- 交付方式: JihuLab.com、私有化部署
- 链接: [文档](../../user/group/import/_index.md#limits) | [相关议题](https://gitlab.com/gitlab-org/gitlab/-/issues/392725)

{{< /details >}}

到目前为止，通过直接传输迁移群组和项目有 90 分钟的导出超时。此限制实际上将大型项目排除在迁移之外，因为只允许在 90 分钟内完成迁移的项目。

整体迁移超时的上限为 4 小时，因此 90 分钟的导出超时没有必要。在此里程碑中，该限制已被移除，允许迁移更大的项目。

<a id="support-for-azure-ad-overage-claim"></a>

### 支持 Azure AD 超额声明

<!-- categories: User Management -->

{{< details >}}

- 适用版本: 专业版、旗舰版
- 交付方式: JihuLab.com、私有化部署
- 链接: [文档](../../user/group/saml_sso/group_sync.md#microsoft-azure-active-directory-integration) | [相关议题](https://gitlab.com/gitlab-org/gitlab/-/issues/414875)

{{< /details >}}

极狐GitLab SAML 群组同步现在支持 Azure AD（现称为 Entra ID）超额声明，允许用户关联超过 150 个群组。之前的最大值为 150 个群组。有关更多信息，请参阅 [Microsoft 群组超额](https://learn.microsoft.com/en-us/security/zero-trust/develop/configure-tokens-group-claims-app-roles#group-overages)。

<a id="geo-verifies-group-wikis"></a>

### Geo 验证群组 Wiki

<!-- categories: Geo Replication, Disaster Recovery -->

{{< details >}}

- 适用版本: 专业版、旗舰版
- 交付方式: 私有化部署
- 链接: [文档](../../administration/geo/_index.md) | [相关议题](https://gitlab.com/gitlab-org/gitlab/-/issues/323897)

{{< /details >}}

Geo 现在能够检测和纠正[群组 Wiki](../../user/project/wiki/group.md) 在静态和传输中的数据损坏。如果您将 Geo 作为灾难恢复策略的一部分，这有助于在发生故障转移时保护您免受数据丢失。

<a id="unified-devops-and-security"></a>

## 统一 DevOps 和安全

<a id="codeowners-file-syntax-and-format-validation"></a>

### CODEOWNERS 文件语法和格式验证

<!-- categories: Source Code Management -->

{{< details >}}

- 适用版本: 专业版、旗舰版
- 交付方式: 私有化部署
- 链接: [文档](../../user/project/codeowners/reference.md)

{{< /details >}}

您现在可以在 UI 中查看您的 `CODEOWNERS` 文件是否存在语法或格式错误。能够指定代码所有者提供了极大的灵活性，允许用户配置多个文件位置、部分和规则。借助此新的语法验证，您的 `CODEOWNERS` 文件中的错误将显示在极狐GitLab UI 中，使问题易于发现和修复。将显示以下错误：

- 包含空格的条目。
- 无法解析的部分。
- 格式错误的所有者。
- 无法访问的所有者。
- 零个所有者。
- 少于 1 个必需的审批。

以前，`CODEOWNERS` 文件不会验证输入到文件中的信息。这可能导致创建：

- 针对不存在的文件/路径的规则。
- 与其他现有规则产生冲突的规则。
- 由于语法不正确而不适用的规则。

<a id="kubernetes-127-support"></a>

### 支持 Kubernetes 1.27

<!-- categories: Deployment Management -->

{{< details >}}

- 适用版本: 基础版、专业版、旗舰版
- 交付方式: JihuLab.com、私有化部署
- 链接: [文档](../../user/clusters/agent/_index.md) | [相关议题](https://gitlab.com/gitlab-org/gitlab/-/issues/420859)

{{< /details >}}

本次发布增加了对 2023 年 4 月发布的 Kubernetes 1.27 版本的全面支持。如果您使用 Kubernetes，您现在可以将集群升级到最新版本并利用其所有功能。

您可以阅读有关[我们的 Kubernetes 支持策略](../../user/clusters/agent/_index.md)和其他受支持的 Kubernetes 版本的更多信息。

<a id="wrap-feature-flag-names-instead-of-truncating"></a>

### 换行显示功能标志名称而不是截断

<!-- categories: Feature Flags -->

{{< details >}}

- 适用版本: 基础版、专业版、旗舰版
- 交付方式: JihuLab.com、私有化部署
- 链接: [文档](../../operations/feature_flags.md) | [相关议题](https://gitlab.com/gitlab-org/gitlab/-/issues/418147)

{{< /details >}}

如果您在之前版本的极狐GitLab 中使用过功能标志，您可能注意到较长的功能标志名称被截断了。这使得快速区分相似的功能标志名称变得困难。

在极狐GitLab 16.3 中，会显示完整的功能标志名称。如有需要，较长的名称会换行显示。

<a id="names-for-audit-event-streams"></a>

### 审计事件流的名称

<!-- categories: Audit Events -->

{{< details >}}

- 适用版本: 旗舰版
- 交付方式: JihuLab.com、私有化部署
- 链接: [文档](../../administration/compliance/audit_event_reports.md)

{{< /details >}}

以前，审计事件流目标按目标 URL 分配。当您为一个群组或实例设置多个流时，这可能会导致混淆，因为您必须在 UI 中展开目标才能看到应用了哪些筛选器和自定义请求头。

在极狐GitLab 16.3 中，您现在可以为审计事件流目标命名，以便在定义了多个流目标时帮助识别和区分它们。

<a id="explain-this-vulnerability"></a>

### 解释此漏洞

<!-- categories: Vulnerability Management -->

{{< details >}}

- 交付方式: JihuLab.com
- 链接: [文档](../../user/application_security/vulnerabilities/_index.md) | [相关史诗](https://gitlab.com/groups/gitlab-org/-/epics/10368)

{{< /details >}}

极狐GitLab 会呈现包含相关信息的漏洞，但有时不清楚从哪里开始。研究和综合漏洞记录中呈现的信息需要时间。此外，弄清楚如何修复给定漏洞可能很困难。在此测试版发布中，您可以点击按钮获取由 AI 生成的关于如何缓解漏洞的解释和建议。

<a id="compliance-reports-renamed-to-compliance-center"></a>

### 合规报告更名为合规中心

<!-- categories: Compliance Management -->

{{< details >}}

- 适用版本: 旗舰版
- 交付方式: JihuLab.com、私有化部署
- 链接: [文档](../../user/compliance/compliance_center/_index.md)

{{< /details >}}

为了促进合规相关功能从报告扩展到管理，极狐GitLab 的合规报告部分已更名，以反映该领域不断扩大的范围。

从极狐GitLab 16.3 开始，合规报告称为合规中心。

<a id="improve-accuracy-of-scan-result-policies"></a>

### 提高扫描结果策略的准确性

<!-- categories: Security Policy Management -->

{{< details >}}

- 适用版本: 旗舰版
- 交付方式: JihuLab.com、私有化部署
- 链接: [文档](../../user/application_security/policies/merge_request_approval_policies.md) | [相关史诗](https://gitlab.com/gitlab-org/gitlab/-/issues/379108)

{{< /details >}}

扫描结果策略是一种安全策略，用于在违反特定规则时评估和阻止合并请求。审批人可以审核并批准变更，或与其开发团队合作解决任何问题（例如解决严重安全漏洞）。

以前，我们比较最新源分支和目标分支中的漏洞，以检测任何新的策略规则违规。但是，这可能无法捕获由各种流水线来源运行的扫描所检测到的漏洞。为了提高准确性，我们现在比较每个流水线来源的最新已完成流水线（父/子流水线除外）。这将确保更全面的评估，并减少在可能出乎意料的情况下需要审批的情况。

<a id="instance-level-streaming-audit-event-filters"></a>

### 实例级流式审计事件筛选器

<!-- categories: Audit Events -->

{{< details >}}

- 适用版本: 旗舰版
- 交付方式: 私有化部署
- 链接: [文档](../../administration/compliance/audit_event_reports.md)

{{< /details >}}

在极狐GitLab 16.2 中，我们引入了实例级审计事件流。但是，没有可应用于这些流的筛选器。

在极狐GitLab 16.3 中，您现在可以按审计事件类型为实例级审计事件流应用筛选器。通过在 UI 中添加这些筛选器，您可以捕获审计事件的子集发送到每个流位置，只关注与您相关的事件。

<a id="security-bot-to-trigger-scan-execution-policies-pipelines"></a>

### 安全机器人触发扫描执行策略流水线

<!-- categories: Security Policy Management -->

{{< details >}}

- 适用版本: 旗舰版
- 交付方式: JihuLab.com、私有化部署
- 链接: [文档](../../user/application_security/policies/scan_execution_policies.md) | [相关史诗](https://gitlab.com/groups/gitlab-org/-/epics/10756)

{{< /details >}}

将创建安全机器人用户以支持管理后台任务，并为所有新创建或更新的安全策略项目链接强制执行安全策略。这将简化安全和合规团队成员的策略配置和强制执行过程，特别是消除了安全策略项目维护者还需要在开发项目中维护 `Developer` 访问权限的需要。安全策略机器人用户还将使受强制执行项目中的用户更清楚地了解流水线何时代表安全策略执行，因为此机器人用户将是流水线作者。

当安全策略项目链接到群组或子群组时，将在该群组或子群组中的每个项目中创建一个安全策略机器人。当链接到群组、子群组或单个项目时，将为给定项目或群组或子群组中的任何项目创建一个安全机器人用户。任何已链接到安全策略项目的群组、子群组或项目目前不受影响，但用户可以重新建立任何现有链接以利用此功能。在极狐GitLab 16.4 中，我们计划在 JihuLab.com 上所有具有现有安全策略项目链接的项目上[启用安全机器人](https://gitlab.com/gitlab-org/gitlab/-/issues/414376)。

<a id="sast-analyzer-updates"></a>

### SAST 分析器更新

<!-- categories: SAST -->

{{< details >}}

- 适用版本: 基础版、专业版、旗舰版
- 交付方式: 私有化部署
- 链接: [文档](../../user/application_security/sast/analyzers.md) | [相关议题](../../user/application_security/_index.md)

{{< /details >}}

极狐GitLab SAST 包含[许多安全分析器](../../user/application_security/sast/_index.md#supported-languages-and-frameworks)，由 GitLab 静态分析团队积极维护、更新和支持。我们在 16.3 发布里程碑期间发布了以下更新：

- 基于 Kics 的分析器已更新为使用 Kics 引擎 1.7.5 版本。此更新包含各种错误修复，还改进了 JSON 和 YAML 中自引用的错误处理。有关更多详细信息，请参阅 [CHANGELOG](https://gitlab.com/gitlab-org/security-products/analyzers/kics/-/blob/main/CHANGELOG.md?ref_type=heads#v414)。
- 基于 Semgrep 的分析器已更新，添加了在直通自定义配置期间指定模糊引用的支持。我们还将 SARIF 解析器更新为使用 Name 而非 Title，并且不再在 SARIF `toolExecutionNotifications` 级别为 error 时使扫描失败。有关更多详细信息，请参阅 [CHANGELOG](https://gitlab.com/gitlab-org/security-products/analyzers/semgrep/-/blob/main/CHANGELOG.md?ref_type=heads#v446)。

如果您[包含极狐GitLab 管理的 SAST 模板](../../user/application_security/sast/_index.md)（[`SAST.gitlab-ci.yml`](https://gitlab.com/gitlab-org/gitlab/blob/master/lib/gitlab/ci/templates/Security/SAST.gitlab-ci.yml)）并运行极狐GitLab 16.0 或更高版本，您将自动收到这些更新。要保留任何分析器的特定版本并防止自动更新，您可以[固定其版本](../../user/application_security/sast/_index.md)。

有关之前的变更，请参阅[上个月的更新](gitlab-16-2-released.md#sast-analyzer-updates)。

<a id="dependency-and-license-scanning-support-for-java-v21"></a>

### 对 Java v21 的依赖项和许可证扫描支持

<!-- categories: Software Composition Analysis -->

{{< details >}}

- 适用版本: 旗舰版
- 交付方式: JihuLab.com、私有化部署
- 链接: [文档](../../user/application_security/dependency_scanning/legacy_dependency_scanning/_index.md#obtaining-dependency-information-by-parsing-lockfiles) | [相关议题](https://gitlab.com/gitlab-org/gitlab/-/issues/387307)

{{< /details >}}

极狐GitLab 依赖项和许可证扫描现在支持分析 Java v21 Maven 锁文件。

<a id="runner-tags-enable-ui-based-configuration-of-on-demand-dast-scans"></a>

### Runner 标签支持基于 UI 配置按需 DAST 扫描

<!-- categories: DAST -->

{{< details >}}

- 适用版本: 旗舰版
- 交付方式: JihuLab.com、私有化部署
- 链接: [文档](../../user/application_security/dast/on-demand_scan.md) | [相关议题](https://gitlab.com/gitlab-org/gitlab/-/issues/345430)

{{< /details >}}

您现在可以使用标签来指定希望用于按需 DAST 扫描的 Runner。在 16.3 之前，您可以通过 CI 配置文件使用私有 Runner 配置 DAST 扫描。此基于 UI 的配置可实现高效的 UI 配置来管理 DAST 扫描。

<a id="improved-sast-vulnerability-tracking"></a>

### 改进的 SAST 漏洞跟踪

<!-- categories: SAST -->

{{< details >}}

- 适用版本: 旗舰版
- 交付方式: 私有化部署
- 链接: [文档](../../user/application_security/sast/_index.md#advanced-vulnerability-tracking) | [相关议题](https://gitlab.com/groups/gitlab-org/-/epics/5144)

{{< /details >}}

极狐GitLab SAST [高级漏洞跟踪](../../user/application_security/sast/_index.md#advanced-vulnerability-tracking)通过跟踪代码移动时的发现，使漏洞排查更加高效。我们在极狐GitLab 16.3 中发布了两项改进：

1. 扩展语言支持：除了[现有覆盖范围](../../user/application_security/sast/_index.md#advanced-vulnerability-tracking)外，我们还为以下语言启用了高级漏洞跟踪：
  - C 和 C++，在基于 Flawfinder 的分析器中。
  - Java，在基于 MobSF 的分析器中。
  - JavaScript，在基于 NodeJS-Scan 的分析器中。
1. 更好的跟踪：我们改进了跟踪算法以处理 JavaScript 中的匿名函数。

这建立在[极狐GitLab 16.2 中发布](gitlab-16-2-released.md#improved-sast-vulnerability-tracking)的先前扩展和改进之上。我们正在[史诗 5144](https://gitlab.com/groups/gitlab-org/-/epics/5144)中跟踪进一步的改进，包括扩展到更多语言、更好地处理更多语言结构，以及改进 Python 和 Ruby 的跟踪。

这些变更包含在极狐GitLab SAST [分析器](../../user/application_security/sast/analyzers.md)的[更新版本](https://gitlab.cn/docs/#sast-analyzer-updates)中。使用更新后的分析器扫描项目后，您项目的漏洞发现将使用新的跟踪签名进行更新。除非您[将 SAST 分析器固定到特定版本](../../user/application_security/sast/_index.md)，否则您无需采取任何操作即可收到此更新。

<a id="automatic-response-to-leaked-postman-api-keys"></a>

### 对泄露的 Postman API 密钥的自动响应

<!-- categories: Secret Detection -->

{{< details >}}

- 链接: [文档](../../user/application_security/secret_detection/automatic_response.md) | [相关议题](https://gitlab.com/gitlab-org/gitlab/-/issues/403825)

{{< /details >}}

我们已将密钥检测与 Postman 集成，以更好地保护在其极狐GitLab 项目中使用 Postman 的客户。

密钥检测会搜索 [Postman API 密钥](https://learning.postman.com/docs/reference/postman-api/authentication)。
如果密钥在 JihuLab.com 上的公共项目中暴露，极狐GitLab 会将泄露的密钥发送给 Postman。
Postman 验证该密钥，然后[通知 Postman API 密钥的所有者](https://learning.postman.com/docs/administration/token-scanner/#protecting-postman-api-keys-in-gitlab)。

对于在 JihuLab.com 上[启用了密钥检测](../../user/application_security/secret_detection/_index.md)的项目，此集成默认开启。密钥检测扫描在所有极狐GitLab 版本中可用，但对泄露密钥的自动响应目前仅在旗舰版项目中可用。

有关更多详细信息，请参阅[关于此集成的 Postman 博客文章](https://blog.postman.com/protecting-your-postman-api-keys-in-gitlab/)。

<a id="expose-pipeline-name-as-a-predefined-cicd-variable"></a>

### 将流水线名称公开为预定义 CI/CD 变量

<!-- categories: Continuous Integration (CI) -->

{{< details >}}

- 适用版本: 基础版、专业版、旗舰版
- 交付方式: JihuLab.com、私有化部署
- 链接: [文档](../../ci/variables/predefined_variables.md) | [相关议题](https://gitlab.com/gitlab-org/gitlab/-/issues/420002)

{{< /details >}}

使用 [`workflow:name`](../../ci/yaml/_index.md#workflowname) 关键字定义的流水线名称现在可以通过预定义变量 `$CI_PIPELINE_NAME` 访问。

<a id="gitlab-runner-163"></a>

### 极狐GitLab Runner 16.3

<!-- categories: GitLab Runner Core -->

{{< details >}}

- 适用版本: 基础版、专业版、旗舰版
- 交付方式: 私有化部署
- 链接: [文档](https://gitlab.cn/docs/runner/)

{{< /details >}}

我们今天还发布了极狐GitLab Runner 16.3！极狐GitLab Runner 是轻量级、高度可扩展的代理，用于运行您的 CI/CD 作业并将结果发送回极狐GitLab 实例。极狐GitLab Runner 与极狐GitLab CI/CD 协同工作，后者是极狐GitLab 中包含的开源持续集成服务。

<a id="whats-new"></a>

#### 新增功能

- [默认将项目克隆目录配置为安全](https://gitlab.com/gitlab-org/gitlab-runner/-/issues/29022)

<a id="bug-fixes"></a>

#### 错误修复

- [Runner v16.2.0 在 Debian/RHEL 仓库中不可用](https://gitlab.com/gitlab-org/gitlab-runner/-/issues/36048)
- [使用 shell 执行器的 GitLab-runner 有时无法获取子模块](https://gitlab.com/gitlab-org/gitlab-runner/-/issues/26993)

所有变更的列表在极狐GitLab Runner [CHANGELOG](https://gitlab.com/gitlab-org/gitlab-runner/blob/16-3-stable/CHANGELOG.md)中。
