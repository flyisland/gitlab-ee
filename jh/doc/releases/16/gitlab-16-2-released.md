---
stage: Release Notes
group: Monthly Release
date: 2023-07-22
title: "极狐GitLab 16.2 发布说明"
description: "极狐GitLab 16.2 发布，带来全新的富文本编辑器体验"
---

<!-- markdownlint-disable -->
<!-- vale off -->

2023 年 7 月 24 日，极狐GitLab 16.2 正式发布，包含以下功能。

<a id="primary-features"></a>

## 主要功能

<a id="all-new-rich-text-editor-experience"></a>

### 全新的富文本编辑器体验

<!-- categories: Team Planning, Portfolio Management, Code Review Workflow -->

{{< details >}}

- 适用版本: 基础版、专业版、旗舰版
- 交付方式: JihuLab.com、私有化部署
- 链接: [文档](../../user/rich_text_editor.md) | [相关史诗](https://gitlab.com/groups/gitlab-org/-/epics/10378)

{{< /details >}}

极狐GitLab 16.2 带来了全新的富文本编辑体验！这项新功能面向所有用户开放，可作为现有 Markdown 编辑体验的替代方案。

对许多人来说，使用纯文本编辑器撰写评论或描述是协作的一大障碍。即使对语法相对熟悉的人来说，记住图片引用的语法或处理冗长的表格也可能十分繁琐。富文本编辑器旨在打破这些障碍，提供“所见即所得”的编辑体验，并构建一个可扩展的基础，让我们能够为图表、内容嵌入、媒体管理等场景构建自定义编辑界面。

富文本编辑器现已在所有议题、史诗和合并请求中可用。我们计划很快在极狐GitLab 的更多位置提供此功能。您可以在[此处](https://gitlab.com/groups/gitlab-org/-/epics/10378)关注我们的进展。

我们对新的编辑体验感到自豪，并迫不及待地想了解您的想法。请试用新的富文本编辑器，并在[此议题](https://gitlab.com/gitlab-org/gitlab/-/issues/416293)中告诉我们您的使用体验。

<a id="gitlab-triggers-a-flux-synchronization-without-any-configuration"></a>

### 极狐GitLab 无需任何配置即可触发 Flux 同步

<!-- categories: Deployment Management -->

{{< details >}}

- 适用版本: 基础版、专业版、旗舰版
- 交付方式: JihuLab.com、私有化部署
- 链接: [文档](../../user/clusters/agent/gitops.md#immediate-git-repository-reconciliation) | [相关议题](https://gitlab.com/gitlab-org/gitlab/-/issues/392852)

{{< /details >}}

默认情况下，Flux 会按固定时间间隔同步 Kubernetes 清单。若要在清单变更时默认立即触发协调，则需要额外配置。借助极狐GitLab Kubernetes Agent，您可以推送清单变更并自动触发 Flux 同步。

<a id="support-for-keyless-signing-with-cosign"></a>

### 支持使用 Cosign 进行无密钥签名

<!-- categories: Pipeline Composition -->

{{< details >}}

- 适用版本: 基础版
- 链接: [文档](../../ci/yaml/signing_examples.md) | [相关议题](https://gitlab.com/groups/gitlab-org/-/epics/10254)

{{< /details >}}

妥善存储、轮换和管理签名密钥可能十分困难，通常还需要管理单独的密钥管理系统（KMS）的额外开销。极狐GitLab 现在通过与 Sigstore Cosign 工具的原生集成支持无密钥签名，让您可以在极狐GitLab CI/CD 流水线中轻松、便捷且安全地完成签名。签名使用一个非常短期的签名密钥完成。该密钥通过从极狐GitLab 服务器获取的令牌生成，该令牌使用运行流水线的用户的 OIDC 身份。此令牌包含唯一声明，可证明该令牌由 CI/CD 流水线生成。

要开始为您的构建产物、容器镜像和软件包使用无密钥签名，用户只需按照[我们文档中的说明](../../ci/yaml/signing_examples.md)在其 CI/CD 文件中添加几行配置即可。

<a id="command-palette"></a>

### 命令面板

<!-- categories: Navigation -->

{{< details >}}

- 适用版本: 基础版、专业版、旗舰版
- 交付方式: JihuLab.com、私有化部署
- 链接: [文档](../../user/search/command_palette.md)

{{< /details >}}

如果您是高级用户，使用键盘进行导航和操作可能会令人沮丧。现在，新的命令面板可帮助您使用键盘完成更多工作。

要启用命令面板，请打开左侧边栏并点击**搜索极狐GitLab**（🔍），或使用 `/` 键。

输入以下特殊字符之一：

- `>` - 创建新对象或查找菜单项
- `@` - 搜索用户
- `:` - 搜索项目
- `/` - 在默认代码仓库分支中搜索项目文件

<a id="gitlab-duo-code-suggestions-improvements-powered-by-google-ai"></a>

### 由 Google AI 驱动的极狐GitLab Duo 代码建议改进

<!-- categories: Code Suggestions -->

{{< details >}}

- 适用版本: 基础版
- 链接: [文档](../../user/project/repository/code_suggestions/_index.md) | [相关议题](https://gitlab.com/groups/gitlab-org/-/epics/9814)

{{< /details >}}

代码建议现在使用 Google Cloud 可定制的基础模型和开放的生成式 AI 基础设施，并在 Vertex AI 中提供生成式 AI 支持。

极狐GitLab 代码建议通过 Google Vertex AI Codey API 的[数据治理](https://docs.cloud.google.com/gemini-enterprise-agent-platform/resources/zero-data-retention)和[负责任 AI](https://docs.cloud.google.com/gemini-enterprise-agent-platform/models/responsible-ai) 进行路由。截至 7 月 22 日，代码建议会针对当前打开的文件进行推理，上下文窗口为 2,048 个 token，字符上限为 8,192。此限制包括光标前后的内容、文件名和扩展名类型。

Google Vertex AI Codey API 直接支持：C++、C#、Go、Google SQL、Java、JavaScript、Kotlin、PHP、Python、Ruby、Rust、Scala、Swift、TypeScript。对于基础设施文件，支持：Google Cloud CLI、Kubernetes Resource Model（KRM）和 Terraform。

我们正在持续迭代以改进代码建议。欢迎试用并[与我们分享您的反馈](https://gitlab.com/gitlab-org/gitlab/-/issues/405152)。

<a id="track-your-machine-learning-model-experiments"></a>

### 跟踪您的机器学习模型实验

<!-- categories: MLOps -->

{{< details >}}

- 适用版本: 基础版、专业版、旗舰版
- 交付方式: 私有化部署
- 链接: [文档](../../user/project/ml/experiment_tracking/_index.md) | [相关议题](https://gitlab.com/gitlab-org/gitlab/-/merge_requests/125758)

{{< /details >}}

数据科学家在创建机器学习（ML）模型时，通常会尝试不同的参数、配置和特征工程，以提高模型性能。数据科学家需要跟踪所有这些元数据及关联的产物，以便日后复现实验。这项工作并不简单，现有解决方案需要复杂的设置。

借助机器学习模型实验，数据科学家可以将参数、指标和产物直接记录到极狐GitLab 中，从而轻松访问性能最佳的模型。此功能目前为实验性功能。

<a id="new-customization-layer-for-the-value-streams-dashboard"></a>

### 价值流仪表板新增自定义层

<!-- categories: Value Stream Management, DORA Metrics -->

{{< details >}}

- 适用版本: 旗舰版
- 交付方式: JihuLab.com、私有化部署
- 链接: [文档](../../user/analytics/value_streams_dashboard.md) | [相关议题](https://gitlab.com/gitlab-org/gitlab/-/issues/388890)

{{< /details >}}

在价值流仪表板新增的配置文件中，您可以定义各种设置和参数，例如标题、描述以及面板和过滤器的数量。该文件由模式驱动，并使用 Git 等版本控制系统进行管理。这样可以跟踪和维护配置变更历史，必要时回滚到之前的版本，并与团队成员高效协作。

新配置还包含按标记筛选指标的选项。您可以根据自己关注的领域调整[指标对比面板](https://about.gitlab.com/blog/getting-started-with-value-streams-dashboard/)，过滤掉无关信息，并专注于与您的分析或决策过程最相关的数据。

<a id="scale-and-deployments"></a>

## 扩展与部署

<a id="group-level-wiki-now-available-in-advanced-search"></a>

### 群组级 Wiki 现已在高级搜索中可用

<!-- categories: Global Search -->

{{< details >}}

- 适用版本: 专业版、旗舰版
- 交付方式: JihuLab.com、私有化部署
- 链接: [文档](../../user/search/advanced_search.md) | [相关议题](https://gitlab.com/gitlab-org/gitlab/-/issues/336100)

{{< /details >}}

在此版本中，我们将高级搜索扩展到了[群组级 Wiki](../../user/project/wiki/group.md)。用户现在可以比以前更轻松、更快速地找到这些 Wiki 中的内容。

<a id="omnibus-improvements"></a>

### Omnibus 改进

<!-- categories: Omnibus Package -->

{{< details >}}

- 适用版本: 基础版、专业版、旗舰版
- 交付方式: 私有化部署
- 链接: [文档](https://gitlab.cn/docs/omnibus/)

{{< /details >}}

- 我们的 Redis 版本已更新至最新稳定版 [`7.0.12`](https://raw.githubusercontent.com/redis/redis/7.0/00-RELEASENOTES)。
- 对于极狐GitLab 的全新安装，您现在可以选择使用 [PostgreSQL 14](https://www.postgresql.org/docs/14/release-14.html#id-1.11.6.12.4)。

<a id="view-deployments-from-jira-issues-mentioned-in-gitlab-commits"></a>

### 从极狐GitLab 提交中提及的 Jira 议题查看部署

<!-- categories: Settings -->

{{< details >}}

- 适用版本: 基础版、专业版、旗舰版
- 交付方式: JihuLab.com、私有化部署
- 链接: [文档](../../integration/jira/development_panel.md#information-displayed-in-the-development-panel) | [相关议题](https://gitlab.com/gitlab-org/gitlab/-/issues/300031)

{{< /details >}}

此前，只有在与部署关联的分支或合并请求中提及了 Jira 议题时，极狐GitLab 部署才会从 Jira 开发面板中关联。这通常给用户带来不便，因为这要求他们从合并请求进行部署，而这并非典型的工作流程。

在此版本中，极狐GitLab 部署还会扫描上次成功部署后对该分支所做的最新 5,000 次提交的消息中的 Jira 议题提及。极狐GitLab 部署会与所有被提及的 Jira 议题关联。

<a id="automatic-deletion-of-unconfirmed-users"></a>

### 自动删除未确认用户

<!-- categories: System Access -->

{{< details >}}

- 适用版本: 专业版、旗舰版
- 交付方式: 私有化部署
- 链接: [文档](../../administration/moderate_users.md#automatically-delete-unconfirmed-users) | [相关议题](https://gitlab.com/gitlab-org/gitlab/-/issues/352514)

{{< /details >}}

当邀请发送到错误的电子邮件地址时，这些邀请将永远无法被确认。此前，管理员必须手动删除这些账号。现在，管理员可以开启在指定天数后自动删除未确认用户的功能。同样，在 JihuLab.com 上，未确认账号将在[指定天数](../../user/jihulab_com/_index.md)后自动删除。

<a id="improved-security-for-feed-tokens"></a>

### 提高 Feed 令牌的安全性

<!-- categories: System Access -->

{{< details >}}

- 适用版本: 基础版、专业版、旗舰版
- 交付方式: JihuLab.com、私有化部署
- 链接: [文档](../../security/tokens/_index.md#feed-token) | [相关议题](https://gitlab.com/gitlab-org/gitlab/-/issues/414257)

{{< /details >}}

Feed 令牌现在更加安全，因为它们仅对生成时对应的 URL 有效。这缩小了令牌泄露时可被读取的 Feed 范围。

<a id="gitlab-for-slack-app-available-on-self-managed-gitlab"></a>

### GitLab for Slack 应用现已在私有化部署的极狐GitLab 上可用

<!-- categories: Settings -->

{{< details >}}

- 适用版本: 基础版、专业版、旗舰版
- 交付方式: 私有化部署
- 链接: [文档](../../administration/settings/slack_app.md) | [相关议题](https://gitlab.com/gitlab-org/gitlab/-/issues/358872)

{{< /details >}}

在此版本中，GitLab for Slack 应用现已在私有化部署实例上可用。在私有化部署的极狐GitLab 上，您可以根据[清单文件](https://api.slack.com/reference/manifests#creating_apps)创建 GitLab for Slack 应用的副本，并将该副本安装到您的 Slack 工作区中。每个副本都是私有的，不可公开分发。

要创建和配置该应用，请参阅 [GitLab for Slack 应用管理](../../administration/settings/slack_app.md)。

<a id="speed-up-imports-from-github-using-multiple-access-tokens"></a>

### 使用多个访问令牌加速从 GitHub 导入

<!-- categories: Importers -->

{{< details >}}

- 适用版本: 基础版、专业版、旗舰版
- 交付方式: JihuLab.com、私有化部署
- 链接: [文档](../../api/import.md#import-repository-from-github) | [相关议题](https://gitlab.com/gitlab-org/gitlab/-/issues/337232)

{{< /details >}}

默认情况下，GitHub 导入器在将项目从 GitHub 导入到极狐GitLab 时使用单个访问令牌。用户账号的访问令牌通常限制为每小时 5,000 个请求。在以下情况下，这会显著降低导入器的速度：

- 导入多个中小型项目。
- 导入一个包含大量数据的超大型项目。

在此版本中，您可以向 GitHub 导入器 API 传递访问令牌列表，以便 API 在遇到速率限制时轮换使用这些令牌。使用多个访问令牌时：

- 令牌不能来自同一个账号，因为它们会共享同一个速率限制。
- 令牌必须对要导入的代码仓库具有相同的权限和足够的特权。

<a id="sync-auditor-role-with-oidc-provider"></a>

### 与 OIDC 提供商同步审计员角色

<!-- categories: User Management -->

{{< details >}}

- 适用版本: 专业版、旗舰版
- 交付方式: 私有化部署
- 链接: [文档](../../administration/auth/oidc.md#auditor-groups) | [相关议题](https://gitlab.com/gitlab-org/gitlab/-/issues/389321)

{{< /details >}}

您现在可以将 OIDC 群组同步到极狐GitLab 中的 `auditor` 角色。这使得由 OIDC 促进的自动化用户生命周期管理能够使用 `auditor` 角色，此前该角色在角色映射中不受支持。

感谢 [Marin Hannache](https://gitlab.com/mareo)的贡献！

<a id="improved-sign-in-and-sign-up-pages"></a>

### 改进登录和注册页面

<!-- categories: System Access -->

{{< details >}}

- 适用版本: 基础版、专业版、旗舰版
- 交付方式: JihuLab.com、私有化部署
- 链接: [文档](../../administration/settings/sign_up_restrictions.md) | [相关议题](https://gitlab.com/gitlab-org/gitlab/-/issues/385651)

{{< /details >}}

极狐GitLab 登录和注册页面已得到改进：

- 存在自定义文本时采用两栏布局。
- 修复了多个 LDAP 下 `Remember me` 复选框的问题。
- 改进了深色模式体验。
- 更大的单点登录按钮。
- 将页脚移至页面底部，避免遮挡页面元素。
- 在 SAML 登录页面添加了语言切换器。
- 在注册试用页面启用了密码检查。

<a id="backup-adds-the-ability-to-skip-projects"></a>

### 备份新增跳过项目的功能

<!-- categories: Backup/Restore of GitLab instances -->

{{< details >}}

- 适用版本: 基础版、专业版、旗舰版
- 交付方式: 私有化部署
- 链接: [相关议题](https://gitlab.com/gitlab-org/gitlab/-/issues/18287)

{{< /details >}}

内置的备份和恢复工具新增了跳过特定代码仓库的功能。Rake 任务现在通过新的 `SKIP_REPOSITORIES_PATHS` 环境变量，接受一个以逗号分隔的群组或项目路径列表，以便在备份或恢复期间跳过这些路径。例如，这使您可以跳过长期不变、已过时或已归档的项目，从而 a) 通过加快备份运行速度来节省时间，b) 通过不将这些数据包含在备份文件中来节省空间。
感谢 [Yuri Konotopov](https://gitlab.com/nE0sIghT)的[社区贡献](https://gitlab.com/gitlab-org/security-products/analyzers/semgrep/-/merge_requests/196)！

<a id="geo-add-individual-resync-and-reverification-for-all-components"></a>

### Geo 为所有组件新增单独重新同步和重新验证功能

<!-- categories: Geo Replication, Disaster Recovery -->

{{< details >}}

- 适用版本: 专业版、旗舰版
- 交付方式: 私有化部署
- 链接: [文档](../../administration/geo/_index.md) | [相关议题](https://gitlab.com/gitlab-org/gitlab/-/issues/364727)

{{< /details >}}

Geo 新增了对[自助服务框架](../../development/geo/framework.md)管理的所有组件类型中的单个条目进行重新同步和重新验证的功能。现在，您可以使用 UI 对 Geo 管理的任何单个条目强制执行重新同步或重新验证操作。这有助于加快失败条目的重新同步或重新验证操作，或在应用更改以修复同步或验证错误后执行这些操作。

<a id="unified-devops-and-security"></a>

## 统一 DevOps 与安全

<a id="improve-git-lfs-download-performance"></a>

### 提升 Git LFS 下载性能

<!-- categories: Source Code Management -->

{{< details >}}

- 适用版本: 基础版、专业版、旗舰版
- 交付方式: 私有化部署
- 链接: [文档](../../topics/git/lfs/_index.md)

{{< /details >}}

对于在未启用[代理下载](../../administration/object_storage.md#proxy-download)的情况下将 LFS 对象存储在对象存储中的实例，极狐GitLab 现在会批量处理 LFS 请求。这极大地提升了下载大量 LFS 对象的性能。

此前，由于 LFS 对象的获取方式，极狐GitLab 会创建大量非常小的请求来检查用户权限并重定向到外部存储的对象。这可能导致显著负载和性能下降。通过此修复，我们降低了主极狐GitLab 实例的负载，并为用户提供了更快的下载体验。

<a id="install-the-agent-for-kubernetes-using-extra-volumes-in-the-helm-chart"></a>

### 在 Helm chart 中使用额外卷安装极狐GitLab Kubernetes Agent

<!-- categories: Deployment Management -->

{{< details >}}

- 适用版本: 基础版、专业版、旗舰版
- 交付方式: JihuLab.com、私有化部署
- 链接: [文档](../../user/clusters/agent/install/_index.md#customize-the-helm-installation) | [相关议题](https://gitlab.com/gitlab-org/charts/gitlab-agent/-/issues/33)

{{< /details >}}

极狐GitLab Kubernetes Agent 的 `agentk` 组件需要一个令牌来向极狐GitLab 进行身份验证。此前，您可以原样提供令牌，或提供对包含该令牌的 Kubernetes 密钥的引用。但是，您可能在一个密钥已在卷中可用的环境中运行，并且更希望挂载该卷，而不是创建单独的密钥。从极狐GitLab 16.2 开始，极狐GitLab Agent Helm chart 附带了这一新增功能，这要感谢 [Thomas Spear](https://gitlab.com/tspearconquest)的社区贡献。

<a id="support-for-custom-ci-variables-in-the-scan-execution-policies-editor"></a>

### 在扫描执行策略编辑器中支持自定义 CI 变量

<!-- categories: Security Policy Management -->

{{< details >}}

- 适用版本: 旗舰版
- 交付方式: JihuLab.com、私有化部署
- 链接: [文档](../../user/application_security/policies/scan_execution_policies.md) | [相关史诗](https://gitlab.com/groups/gitlab-org/-/epics/9566)

{{< /details >}}

您现在可以在扫描执行策略编辑器中定义自定义 CI 变量及其值。策略中定义的 CI 变量会覆盖该策略强制执行的项目中定义的匹配变量。例如，策略可以将 CI 变量 `SAST_EXCLUDED_ANALYZERS` 定义为 `brakeman`。当扫描器在项目中强制执行时，无论项目的 CI 配置中定义了任何变量，扫描器都将使用设置为 `brakeman`的变量运行。对于每种扫描类型，您可以为默认变量定义值，也可以为自定义 CI 变量创建自定义键值对。这使得自定义扫描执行策略更加快捷和容易。

<a id="allow-scan-execution-policies-to-enable-cicd-pipelines-in-development-projects"></a>

### 允许扫描执行策略在开发项目中启用 CI/CD 流水线

<!-- categories: Security Policy Management -->

{{< details >}}

- 适用版本: 旗舰版
- 交付方式: 私有化部署
- 链接: [文档](../../user/application_security/policies/scan_execution_policies.md) | [相关史诗](https://gitlab.com/groups/gitlab-org/-/epics/6880)

{{< /details >}}

在之前的极狐GitLab 版本中，安全策略不会在没有 `.gitlab-ci.yml` 文件或已禁用 AutoDevOps 的项目上强制执行。在极狐GitLab 16.2 中，安全策略会在不包含 `.gitlab-ci.yml` 文件的项目上隐式启用 CI/CD 流水线。这是确保安全策略合规性的又一步，使您能够强制执行密钥检测、静态分析或任何其他不需要构建的作业。

<a id="target-default-or-protected-branches-in-security-policies"></a>

### 在安全策略中定位“默认”或“受保护”分支

<!-- categories: Security Policy Management -->

{{< details >}}

- 适用版本: 旗舰版
- 交付方式: JihuLab.com、私有化部署
- 链接: [文档](../../user/application_security/policies/merge_request_approval_policies.md#scan_finding-rule-type) | [相关史诗](https://gitlab.com/groups/gitlab-org/-/epics/9468)

{{< /details >}}

扫描执行和扫描结果策略将允许您将强制执行范围限定为策略所强制执行的多个项目中的“默认”分支或“受保护分支”。策略无需明确指定分支名称，即可更广泛地强制执行，并确保名称不寻常的分支不会被排除在合规范围之外。

可以使用 `branch_type` 字段在我们的各种安全策略规则类型中配置分支规则：

- [扫描结果策略的 Scan_finding 规则类型](../../user/application_security/policies/merge_request_approval_policies.md#scan_finding-rule-type)
- [扫描结果策略的 License_finding 规则类型](../../user/application_security/policies/merge_request_approval_policies.md#license_finding-rule-type)
- [扫描执行策略的流水线规则类型](../../user/application_security/policies/scan_execution_policies.md#pipeline-rule-type)
- [扫描执行策略的 Schedule 规则类型](../../user/application_security/policies/scan_execution_policies.md#schedule-rule-type)

<a id="audit-event-streaming-to-google-cloud-logging"></a>

### 将审计事件流式传输到 Google Cloud Logging

<!-- categories: Audit Events -->

{{< details >}}

- 适用版本: 旗舰版
- 交付方式: JihuLab.com、私有化部署
- 链接: [文档](../../administration/compliance/audit_event_reports.md)

{{< /details >}}

您现在可以选择 Google Cloud Logging 作为审计事件流的目标。

此前，您必须使用请求头来尝试构建 Google Cloud Logging 会接受的请求。这种方法容易出错，并且可能难以排查。

现在，您可以选择 Google Cloud Logging 作为流的目标，并提供您的项目 ID、客户端电子邮件、日志 ID 和私钥，以实现更无缝的集成。

<a id="compliance-frameworks-report-export"></a>

### 合规框架报告导出

<!-- categories: Compliance Management -->

{{< details >}}

- 适用版本: 旗舰版
- 交付方式: JihuLab.com、私有化部署
- 链接: [文档](../../user/compliance/compliance_center/compliance_projects_report.md#export-a-report-of-compliance-frameworks-on-projects-in-a-group)

{{< /details >}}

您现在可以将合规框架及其关联项目的报告导出为 CSV 文件。

随着群组级合规框架报告的新增，您可以查看和管理合规框架应用于哪些项目。

通过新的导出功能，您可以保留该文件的副本以供参考。您可以将该文件作为项目和合规框架关系理想状态的单一事实来源。或者，您也可以将该文件发送给组织中可能不在极狐GitLab 中工作、但有兴趣了解哪些项目被标记了哪些框架的人员。

<a id="groupsub-group-level-dependency-list"></a>

### 群组/子群组级依赖项列表

<!-- categories: Dependency Management -->

{{< details >}}

- 适用版本: 旗舰版
- 交付方式: 私有化部署
- 链接: [文档](../../user/application_security/dependency_list/_index.md) | [相关史诗](https://gitlab.com/groups/gitlab-org/-/epics/8090)

{{< /details >}}

在查看依赖项列表时，拥有整体视图非常重要。在项目级管理依赖项对于希望审计其所有项目依赖项的大型组织来说是个问题。在此版本中，您可以在项目或群组级（包括子群组）查看所有依赖项。此功能默认关闭，受功能标志 `group_level_dependencies` 控制。

<a id="allow-initial-push-to-protected-branches"></a>

### 允许向受保护分支进行初始推送

<!-- categories: Compliance Management, Source Code Management -->

{{< details >}}

- 适用版本: 基础版、专业版、旗舰版
- 交付方式: JihuLab.com、私有化部署
- 链接: [文档](../../user/project/repository/branches/default.md#protect-initial-default-branches)

{{< /details >}}

在之前的极狐GitLab 版本中，当默认分支被完全保护时，只有项目维护者和所有者才能向默认分支推送初始提交。

这给创建了新项目但无法向其推送初始提交的开发者带来了问题，因为此时只存在默认分支。

通过**初始推送后完全保护**设置，开发者可以将初始提交推送到代码仓库的默认分支，但之后无法向默认分支推送任何提交。与分支被完全保护时类似，项目维护者始终可以向默认分支推送，但任何人都不能强制推送。

<a id="instance-level-streaming-audit-events"></a>

### 实例级流式审计事件

<!-- categories: Audit Events -->

{{< details >}}

- 适用版本: 旗舰版
- 交付方式: 私有化部署
- 链接: [文档](../../administration/compliance/audit_event_reports.md)

{{< /details >}}

在极狐GitLab 16.1 之前，只有来自顶级群组的审计事件才能流式传输到外部目标。

现在，实例管理员可以为实例级产生的审计事件添加流式传输目标。

<a id="streaming-audit-event-filtering-ui"></a>

### 流式审计事件过滤 UI

<!-- categories: Audit Events -->

{{< details >}}

- 适用版本: 旗舰版
- 交付方式: JihuLab.com、私有化部署
- 链接: [文档](../../administration/compliance/audit_event_reports.md)

{{< /details >}}

在之前的极狐GitLab 版本中，您必须使用 GraphQL API 向审计事件流添加审计事件类型过滤器。

现在，您可以使用极狐GitLab UI 中的过滤器下拉菜单查看所有可用的审计事件类型（按它们相关的极狐GitLab 区域分组），并搜索您想要在流中发送的确切类型。

这显著减少了向审计事件流添加过滤所需的时间，因为您不再需要使用 API 拉取整个列表并手动搜索。

<a id="interactive-diff-suggestions-in-merge-requests"></a>

### 合并请求中的交互式差异建议

<!-- categories: Team Planning, Portfolio Management, Code Review Workflow -->

{{< details >}}

- 适用版本: 基础版、专业版、旗舰版
- 交付方式: 私有化部署
- 链接: [文档](../../user/project/merge_requests/reviews/suggestions.md#using-the-rich-text-editor) | [相关议题](https://gitlab.com/gitlab-org/gitlab/-/issues/406726)

{{< /details >}}

当您在合并请求中建议更改时，现在可以更快地编辑您的建议。在评论中，切换到富文本编辑器并使用 UI 上下移动文本行。通过此更改，您可以准确查看建议在评论发布后的显示效果。

富文本编辑器是极狐GitLab 中的一种新编辑方式。它不仅在合并请求中可用，在议题和史诗中也可与纯文本编辑器一起使用。

我们计划很快在极狐GitLab 的更多区域提供富文本编辑器，并且我们正在积极推进这项工作。您可以在[此处](https://gitlab.com/groups/gitlab-org/-/epics/10378)关注我们的进展。

<a id="import-pypi-packages-with-cicd-pipelines"></a>

### 使用 CI/CD 流水线导入 PyPI 软件包

<!-- categories: Package Registry -->

{{< details >}}

- 适用版本: 基础版、专业版、旗舰版
- 交付方式: 私有化部署
- 链接: [文档](../../user/packages/package_registry/_index.md#to-import-packages) | [相关议题](https://gitlab.com/gitlab-org/gitlab/-/issues/389339)

{{< /details >}}

您是否一直在考虑将 PyPI 代码仓库迁移到极狐GitLab，但一直没时间进行迁移？在此版本中，极狐GitLab 推出了 PyPI 软件包导入器的第一个版本。

您现在可以使用软件包导入器工具从任何符合 PyPI 规范的仓库（如 Artifactory）导入软件包。

<a id="add-emoji-reactions-to-comments-on-uploaded-designs"></a>

### 为上传设计上的评论添加表情回应

<!-- categories: Design Management -->

{{< details >}}

- 适用版本: 基础版、专业版、旗舰版
- 交付方式: JihuLab.com、私有化部署
- 链接: [文档](../../user/emoji_reactions.md) | [相关议题](https://gitlab.com/gitlab-org/gitlab/-/issues/29756)

{{< /details >}}

您现在可以通过在[设计管理](../../user/project/issues/design_management.md)中为评论添加表情回应，更有创意地表达您的想法。此功能为协作增添了一丝乐趣和便利，促进更好的沟通，并使团队能够以更具表现力的方式提供快速反馈。

<a id="sast-analyzer-updates"></a>

### SAST 分析器更新

<!-- categories: SAST -->

{{< details >}}

- 适用版本: 基础版、专业版、旗舰版
- 交付方式: 私有化部署
- 链接: [文档](../../user/application_security/sast/analyzers.md) | [相关议题](../../user/application_security/_index.md)

{{< /details >}}

极狐GitLab SAST 包含[许多安全分析器](../../user/application_security/sast/_index.md#supported-languages-and-frameworks)，这些分析器由 GitLab 静态分析团队积极维护、更新和支持。

在 16.2 版本里程碑期间，我们的更改集中在基于 Semgrep 的分析器及其用于扫描的 GitLab 维护规则上。我们发布了以下更改：

- 澄清了 JavaScript 规则的说明和指导，基于[极狐GitLab 16.1 中为其他语言发布的改进](gitlab-16-1-released.md#clearer-guidance-and-better-coverage-for-sast-rules)
- 更新了规则以发现 Java 和 JavaScript 中的其他漏洞。
- 更改了扫描中忽略文件的默认配置，具体包括：
  - 移除了 `.gitignore` 排除项。感谢 [`@SimonGurney`](https://gitlab.com/SimonGurney)的社区贡献。
  - 尊重本地定义的 `.semgrepignore` 文件。感谢 [`@hmrc.colinameigh`](https://gitlab.com/hmrc.colinameigh)的社区贡献。
- 改进了与 Go 内存别名相关的规则。感谢 [`@tyage`](https://gitlab.com/tyage)的社区贡献。
- 移除了为 JavaScript 规则的 Semgrep 规则 ID 添加的 `-1` 后缀。这是在极狐GitLab 16.0 中作为一项无关更改的副作用添加的，但干扰了客户现有的 `semgrepignore` 注释。

有关更多详细信息，请参阅 [`semgrep` CHANGELOG](https://gitlab.com/gitlab-org/security-products/analyzers/semgrep/-/blob/main/CHANGELOG.md#v440) 和 [`sast-rules` CHANGELOG](https://gitlab.com/gitlab-org/security-products/sast-rules/-/blame/main/CHANGELOG.md)。
我们正在[史诗 10907](https://gitlab.com/groups/gitlab-org/-/epics/10907)中跟踪对 GitLab 管理规则集的进一步改进。

如果您[包含 GitLab 管理的 SAST 模板](../../user/application_security/sast/_index.md)（[`SAST.gitlab-ci.yml`](https://gitlab.com/gitlab-org/gitlab/blob/master/lib/gitlab/ci/templates/Security/SAST.gitlab-ci.yml)）并运行极狐GitLab 16.0 或更高版本，您将自动收到这些更新。要保持在任何分析器的特定版本上并防止自动更新，您可以[固定其版本](../../user/application_security/sast/_index.md)。

有关之前的更改，请参阅[上个月的更新](gitlab-16-1-released.md#sast-analyzer-updates)。

<a id="secret-detection-updates"></a>

### 密钥检测更新

<!-- categories: Secret Detection -->

{{< details >}}

- 适用版本: 基础版、专业版、旗舰版
- 交付方式: 私有化部署
- 链接: [文档](../../user/application_security/secret_detection/_index.md) | [相关议题](../../user/application_security/_index.md)

{{< /details >}}

我们会定期发布极狐GitLab 密钥检测分析器的更新。在极狐GitLab 16.2 里程碑期间，我们：

- 为以下内容添加了 [GitLab 管理的检测规则](../../user/application_security/secret_detection/_index.md)：
  - OpenAI API 密钥。
  - CircleCI 个人和项目访问令牌。感谢 [`@nathanwfish`](https://gitlab.com/nathanwfish)的社区贡献。
- 改进了使用 `keywords` 优化的规则的性能。
- 修复了[一个问题](https://gitlab.com/gitlab-org/gitlab/-/issues/358073)，该问题导致密钥检测结果在代码仓库中创建了指向错误位置的永久链接。

有关更多详细信息，请参阅 [CHANGELOG](https://gitlab.com/gitlab-org/security-products/analyzers/secrets/-/blob/master/CHANGELOG.md#v514)。

如果您[使用 GitLab 管理的密钥检测模板](../../user/application_security/secret_detection/_index.md)（[`Secret-Detection.gitlab-ci.yml`](https://gitlab.com/gitlab-org/gitlab/blob/master/lib/gitlab/ci/templates/Jobs/Secret-Detection.gitlab-ci.yml)）并运行极狐GitLab 16.0 或更高版本，您将自动收到这些更新。要保持在任何分析器的特定版本上并防止自动更新，您可以[固定其版本](../../user/application_security/secret_detection/_index.md)。

有关之前的更改，请参阅[最新的密钥检测更新](gitlab-16-0-released.md#secret-detection-updates)。

<a id="support-for-nuget-v2-in-dependency-and-license-scanning"></a>

### 依赖项和许可证扫描支持 NuGet v2

<!-- categories: Software Composition Analysis -->

{{< details >}}

- 适用版本: 旗舰版
- 交付方式: JihuLab.com、私有化部署
- 链接: [文档](../../user/application_security/dependency_scanning/legacy_dependency_scanning/_index.md#obtaining-dependency-information-by-parsing-lockfiles) | [相关议题](https://gitlab.com/gitlab-org/gitlab/-/issues/398680)

{{< /details >}}

除了 NuGet `v1` 锁定文件外，极狐GitLab 依赖项扫描和许可证扫描现在都支持分析 NuGet `v2` 锁定文件中定义的依赖项。

<a id="improved-sast-vulnerability-tracking"></a>

### 改进 SAST 漏洞跟踪

<!-- categories: SAST -->

{{< details >}}

- 适用版本: 旗舰版
- 交付方式: 私有化部署
- 链接: [文档](../../user/application_security/sast/_index.md#advanced-vulnerability-tracking) | [相关议题](https://gitlab.com/groups/gitlab-org/-/epics/5144)

{{< /details >}}

极狐GitLab SAST [高级漏洞跟踪](../../user/application_security/sast/_index.md#advanced-vulnerability-tracking)通过跟踪代码移动时的发现，使漏洞排查更加高效。我们在极狐GitLab 16.2 中发布了两项改进：

1. 扩展语言支持：高级漏洞跟踪现已支持 C#。
1. 更好的跟踪：我们改进了跟踪算法，以更好地处理 C、C#、Go、Java、JavaScript 和 Python 中的空白和注释。我们还修复了跟踪某些 Go 函数的问题。

我们正在[史诗 5144](https://gitlab.com/groups/gitlab-org/-/epics/5144)中跟踪进一步的改进，包括扩展到更多语言、更好地处理更多语言结构，以及改进对 Python 和 Ruby 的跟踪。

这些更改包含在极狐GitLab SAST [分析器](../../user/application_security/sast/analyzers.md)的[更新版本](https://gitlab.cn/docs/#sast-analyzer-updates)中。使用更新后的分析器扫描项目后，您项目的漏洞发现将使用新的跟踪签名进行更新。除非您已[将 SAST 分析器固定到特定版本](../../user/application_security/sast/_index.md)，否则无需执行任何操作即可收到此更新。

<a id="cicd-support-for-when-never-on-conditional-includes"></a>

### CI/CD：条件包含支持 `when: never`

<!-- categories: Pipeline Composition -->

{{< details >}}

- 适用版本: 基础版、专业版、旗舰版
- 交付方式: JihuLab.com、私有化部署
- 链接: [文档](../../ci/yaml/includes.md#include-with-rulesif) | [相关议题](https://gitlab.com/gitlab-org/gitlab/-/issues/348146)

{{< /details >}}

[`include`](../../ci/yaml/_index.md#include) 是编写完整 CI/CD 流水线时最常用的关键字之一。如果您正在构建更大的流水线，您可能正在使用 `include` 关键字将外部 YAML 配置引入您的流水线。

在此版本中，我们扩展了该关键字的功能，使您可以在[将 `rules` 与 `include` 一起使用](../../ci/yaml/includes.md#use-rules-with-include)时使用 `when: never`。现在，您可以决定在满足特定规则时何时排除外部 CI/CD 配置。这将帮助您编写标准化的流水线，并能够根据您选择的条件更好地动态修改自身。

<a id="medium-saas-runners-on-linux-available-to-all-tiers"></a>

### Linux 上的中型 SaaS Runner 现面向所有版本开放

<!-- categories: GitLab Hosted Runners -->

{{< details >}}

- 适用版本: 基础版
- 交付方式: JihuLab.com
- 链接: [文档](../../ci/runners/hosted_runners/linux.md) | [相关议题](https://gitlab.com/gitlab-org/gitlab/-/issues/418124)

{{< /details >}}

我们现在已将具有 4 个 vCPU 和 16 GB RAM 的中型 [Linux 上的极狐GitLab SaaS Runner](../../ci/runners/hosted_runners/linux.md) 提供给所有版本。

此前，基础版用户只能使用我们的小型 Linux Runner，有时会导致 CI/CD 执行时间更长。我们很高兴看到基础版用户能够加快其流水线速度。

<a id="gitlab-runner-162"></a>

### 极狐GitLab Runner 16.2

<!-- categories: GitLab Runner Core -->

{{< details >}}

- 适用版本: 基础版、专业版、旗舰版
- 交付方式: 私有化部署
- 链接: [文档](https://gitlab.cn/docs/runner/)

{{< /details >}}

我们今天还发布了极狐GitLab Runner 16.2！极狐GitLab Runner 是轻量级、高度可扩展的代理，用于运行您的 CI/CD 作业并将结果发送回极狐GitLab 实例。极狐GitLab Runner 与极狐GitLab CI/CD 协同工作，后者是极狐GitLab 中包含的开源持续集成服务。

<a id="whats-new"></a>

#### 新功能

- [在 Runner Kubernetes 执行器中重试所有 k8s API 调用](https://gitlab.com/gitlab-org/gitlab-runner/-/merge_requests/4143)

<a id="bug-fixes"></a>

#### 缺陷修复

- [当 dockerd 或任何进程在后台运行时，CI 作业脚本无法完成](https://gitlab.com/gitlab-org/gitlab-runner/-/issues/2880)
- [v16.1.0 缺少 GitLab-runner-helper servercore 镜像](https://gitlab.com/gitlab-org/gitlab-runner/-/issues/33918)
- [错误：无法创建缓存适配器](https://gitlab.com/gitlab-org/gitlab-runner/-/issues/3802)

所有更改的列表见极狐GitLab Runner [CHANGELOG](https://gitlab.com/gitlab-org/gitlab-runner/blob/16-2-stable/CHANGELOG.md)。
