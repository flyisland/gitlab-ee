---
stage: Release Notes
group: Monthly Release
date: 2023-07-22
title: "极狐GitLab 16.2 发布说明"
description: "极狐GitLab 16.2 发布，带来全新的富文本编辑器体验"
---

<!-- markdownlint-disable -->
<!-- vale off -->

2023 年 7 月 22 日，极狐GitLab 16.2 发布，包含以下功能。

此外，我们要感谢所有贡献者，包括本月的杰出贡献者。

<a id="this-month's-notable-contributor"></a>

## 本月的杰出贡献者

Xing Xin 因最近的一个合并请求而受到表彰，该请求旨在[使用隔离仓库进行冲突检测](https://gitlab.com/gitlab-org/gitaly/-/merge_requests/6008)。极狐GitLab 的高级后端工程师 Karthik Nayak 指出：“使用隔离仓库可以避免在操作中途失败时在 git 仓库中留下过时对象。Xing 能够识别出我们可以引入隔离仓库的 RPC，并且对反馈做出了很好的回应，凭借对代码库的良好了解，在一些问题上说服了我们。”

Xing 自 2020 年以来一直为极狐GitLab 和 Gitaly 项目做贡献。作为字节跳动的一名“bytedancer”，Xing 也曾在阿里云和蚂蚁集团工作，专注于代码托管和工程师效率。Xing 补充说：“极狐GitLab 社区在代码管理的最佳实践以及所有友好审阅者的评论方面都给了我很多启发。希望能与社区共同成长。”

Missy Davies 是[极狐GitLab 英雄](https://contributors.gitlab.com/docs/previous-heroes)项目的最新成员之一。她因在极狐GitLab 项目中[近期的众多贡献](https://gitlab.com/gitlab-org/gitlab/-/merge_requests?scope=all&state=merged&assignee_username=missy-davies)而受到表彰，其中包括针对[流水线执行](https://handbook.gitlab.com/handbook/engineering/development/ops/verify/pipeline-execution/)和[环境](https://handbook.gitlab.com/handbook/engineering/development/ops/deploy/environments/)群组的多个合并请求。

Missy 还是极狐GitLab 贡献者社区的活跃成员，定期参与社区活动、办公时间以及 Discord 服务器。极狐GitLab 社区核心团队的 Lee Tickett 和 Marco Zille 都强调了 Missy 与更广泛社区的互动。Lee 补充说，Missy 一直在“践行我们的价值观”。

Missy 分享说，她在极狐GitLab 的开源世界中不断深入的参与让她感到非常愉快。她珍视强烈的社区意识、持续的学习机会以及对开源原则的共同热情。作为一名具有 Ruby on Rails 和 Python 经验的后端开发者，Missy 自 2022 年以来一直是一位有影响力的极狐GitLab 贡献者。

非常感谢本次发布中的所有社区贡献者 🙌

<a id="primary-features"></a>

## 主要功能

<a id="all-new-rich-text-editor-experience"></a>

### 全新的富文本编辑器体验

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: JihuLab.com
- Links: [文档](../../user/rich_text_editor.md) | [相关史诗](https://gitlab.com/groups/gitlab-org/-/epics/10378)

{{< /details >}}

极狐GitLab 16.2 带来了全新的富文本编辑体验！这一新功能面向所有人开放，作为现有 Markdown 编辑体验的替代方案。

对许多人来说，使用纯文本编辑器撰写评论或描述是协作的障碍。记住图片引用的语法或处理长表格即使对于相对熟悉语法的人来说也可能很繁琐。富文本编辑器旨在通过提供“所见即所得”的编辑体验以及一个可扩展的基础来打破这些障碍，在此基础上我们可以为图表、内容嵌入、媒体管理等构建自定义编辑界面。

富文本编辑器现已在所有议题、史诗和合并请求中可用。我们计划很快在极狐GitLab 的更多地方提供它。你可以[在此](https://gitlab.com/groups/gitlab-org/-/epics/10378)关注我们的进展。

我们为新的编辑体验感到自豪，并迫不及待地想听听你的想法。请试用新的富文本编辑器，并在[此议题](https://gitlab.com/gitlab-org/gitlab/-/issues/416293)中告诉我们你的体验。

<a id="gitlab-triggers-a-flux-synchronization-without-any-configuration"></a>

### 极狐GitLab 无需任何配置即可触发 Flux 同步

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: JihuLab.com
- Links: [文档](../../user/clusters/agent/gitops.md#immediate-git-repository-reconciliation) | [相关议题](https://gitlab.com/gitlab-org/gitlab/-/issues/392852)

{{< /details >}}

默认情况下，Flux 会定期同步 Kubernetes 清单。要在清单更改时立即触发协调，默认需要额外的配置。通过极狐GitLab 的 Kubernetes agent，你可以推送对清单的更改，并自动触发 Flux 同步。

<a id="support-for-keyless-signing-with-cosign"></a>

### 支持使用 Cosign 进行无密钥签名

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Links: [文档](../../ci/yaml/signing_examples.md) | [相关议题](https://gitlab.com/groups/gitlab-org/-/epics/10254)

{{< /details >}}

妥善存储、轮换和管理签名密钥可能很困难，通常需要管理单独的密钥管理系统 (KMS) 的开销。极狐GitLab 现在通过与 Sigstore Cosign 工具的原生集成支持无密钥签名，从而可以在极狐GitLab CI/CD 流水线中轻松、方便且安全地进行签名。签名使用非常短效的签名密钥完成。该密钥通过从极狐GitLab 服务器获取的令牌生成，该令牌使用运行流水线的用户的 OIDC 身份。此令牌包含唯一的声明，证明该令牌是由 CI/CD 流水线生成的。

要开始对你的构建产物、容器镜像和软件包使用无密钥签名，用户只需在其 CI/CD 文件中添加几行代码，如[我们的文档](../../ci/yaml/signing_examples.md)所示。

<a id="command-palette"></a>

### 命令面板

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: JihuLab.com
- Links: [文档](../../user/search/command_palette.md)

{{< /details >}}

如果你是一名高级用户，使用键盘进行导航和操作可能会令人沮丧。现在，一个新的命令面板可帮助你使用键盘完成更多工作。

要启用命令面板，请打开左侧边栏并点击 **搜索极狐GitLab** (🔍) 或使用 / 键。

输入以下特殊字符之一：

- > - 创建新对象或查找菜单项
- @ - 搜索用户
- : - 搜索项目
- / - 在默认仓库分支中搜索项目文件

<a id="gitlab-duo-code-suggestions-improvements-powered-by-google-ai"></a>

### 由 Google AI 提供支持的极狐GitLab Duo 代码建议改进

{{< details >}}

- Tier: 旗舰版，专业版，基础版
- Links: [文档](../../user/project/repository/code_suggestions/_index.md) | [相关议题](https://gitlab.com/groups/gitlab-org/-/epics/9814)

{{< /details >}}

代码建议现在使用 Google Cloud 的可定制基础模型和开放的生成式 AI 基础设施，并在 Vertex AI 中提供生成式 AI 支持。

极狐GitLab 代码建议通过 Google Vertex AI Codey API 的[数据治理](https://cloud.google.com/vertex-ai/docs/generative-ai/data-governance)和[负责任 AI](https://cloud.google.com/vertex-ai/docs/generative-ai/learn/responsible-ai) 进行路由。自 7 月 22 日起，代码建议针对当前打开的文件进行推理，上下文窗口为 2,048 个令牌和 8,192 个字符的限制。此限制包括光标前后的内容、文件名和扩展名类型。了解更多关于 Google Vertex AI [`code-gecko`](https://cloud.google.com/vertex-ai/docs/generative-ai/learn/models) 的信息。

[Google Vertex AI Codey API](https://cloud.google.com/vertex-ai/docs/generative-ai/code/code-models-overview#supported_coding_languages) 直接支持：C++、C#、Go、Google SQL、Java、JavaScript、Kotlin、PHP、Python、Ruby、Rust、Scala、Swift、TypeScript。对于基础设施文件，支持：Google Cloud CLI、Kubernetes Resource Model (KRM) 和 Terraform。

我们正在持续迭代以改进代码建议。请尝试使用并[与我们分享你的反馈](https://gitlab.com/gitlab-org/gitlab/-/issues/405152)。

<a id="track-your-machine-learning-model-experiments"></a>

### 跟踪你的机器学习模型实验

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Links: [文档](../../user/project/ml/experiment_tracking/_index.md) | [相关议题](https://gitlab.com/gitlab-org/gitlab/-/merge_requests/125758)

{{< /details >}}

当数据科学家创建机器学习 (ML) 模型时，他们通常会尝试不同的参数、配置和特征工程，以提高模型的性能。数据科学家需要跟踪所有这些元数据和相关产物，以便日后能够复现实验。这项工作并不简单，现有的解决方案需要复杂的设置。

通过机器学习模型实验，数据科学家可以将参数、指标和产物直接记录到极狐GitLab 中，从而轻松访问其性能最佳的模型。此功能是一个实验。

<a id="new-customization-layer-for-the-value-streams-dashboard"></a>

### 价值流仪表板的新自定义层

{{< details >}}

- Tier: 旗舰版
- Offering: JihuLab.com
- Links: [文档](../../user/analytics/value_streams_dashboard.md) | [相关议题](https://gitlab.com/gitlab-org/gitlab/-/issues/388890)

{{< /details >}}

我们为[价值流仪表板](https://youtu.be/EA9Sbks27g4)添加了一个新的配置文件，以便更轻松地自定义仪表板的数据和外观。在此文件中，你可以定义各种设置和参数，例如标题、描述以及面板和过滤器的数量。该文件由模式驱动，并使用 Git 等版本控制系统进行管理。这使得可以跟踪和维护配置更改的历史记录，在必要时恢复到以前的版本，并与团队成员有效协作。

新的配置还包括按标签过滤指标的选项。你可以根据你感兴趣的领域调整[指标比较面板](https://about.gitlab.com/blog/getting-started-with-value-streams-dashboard/)，过滤掉不相关的信息，并专注于对你的分析或决策过程最重要的数据。

<a id="scale-and-deployments"></a>

## 扩展与部署

<a id="group-level-wiki-now-available-in-advanced-search"></a>

### 群组级 Wiki 现已在高级搜索中可用

{{< details >}}

- Tier: 专业版，旗舰版
- Offering: JihuLab.com
- Links: [文档](../../user/search/advanced_search.md) | [相关议题](https://gitlab.com/gitlab-org/gitlab/-/issues/336100)

{{< /details >}}

在此版本中，我们将高级搜索扩展到包括[群组级 Wiki](../../user/project/wiki/group.md)。用户现在可以比以前更轻松、更快速地找到这些 Wiki 中的内容。

<a id="omnibus-improvements"></a>

### Omnibus 改进

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Links: [文档](https://gitlab.cn/docs/omnibus/)

{{< /details >}}

- 我们的 Redis 版本已更新至最新的稳定版本 [`7.0.12`](https://raw.githubusercontent.com/redis/redis/7.0/00-RELEASENOTES)。
- 对于极狐GitLab 的全新安装，你现在可以选择使用 [PostgreSQL 14](https://www.postgresql.org/docs/14/release-14.html#id-1.11.6.12.4)。

<a id="view-deployments-from-jira-issues-mentioned-in-gitlab-commits"></a>

### 查看极狐GitLab 提交中提到的 Jira 议题的部署

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: JihuLab.com
- Links: [文档](../../integration/jira/development_panel.md#information-displayed-in-the-development-panel) | [相关议题](https://gitlab.com/gitlab-org/gitlab/-/issues/300031)

{{< /details >}}

以前，仅当 Jira 议题在与部署关联的分支或合并请求中被提及时，极狐GitLab 部署才会从 Jira 开发面板链接。这通常给用户带来不便，因为它要求他们从合并请求进行部署，而这并非典型的工作流程。

在此版本中，极狐GitLab 部署还会扫描上次成功部署后对分支所做的最新 5,000 次提交的消息中提到的 Jira 议题。极狐GitLab 部署会与所有提到的 Jira 议题关联。

<a id="automatic-deletion-of-unconfirmed-users"></a>

### 自动删除未确认用户

{{< details >}}

- Tier: 专业版，旗舰版
- Links: [文档](../../administration/moderate_users.md#automatically-delete-unconfirmed-users) | [相关议题](https://gitlab.com/gitlab-org/gitlab/-/issues/352514)

{{< /details >}}

当邀请发送到错误的电子邮件地址时，这些邀请永远无法确认。以前，管理员必须手动删除这些账户。现在，管理员可以开启在指定天数后自动删除未确认用户的功能。同样，在 JihuLab.com 上，未确认的账户将在[指定天数](../../user/jihulab_com/_index.md)后自动删除。

<a id="improved-security-for-feed-tokens"></a>

### 改进了 Feed 令牌的安全性

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: JihuLab.com
- Links: [文档](../../security/tokens/_index.md#feed-token) | [相关议题](https://gitlab.com/gitlab-org/gitlab/-/issues/414257)

{{< /details >}}

Feed 令牌变得更加安全，因为它们仅适用于为其生成的 URL。这缩小了在令牌泄露时可读取的 Feed 范围。

<a id="gitlab-for-slack-app-available-on-self-managed-gitlab"></a>

### 极狐GitLab for Slack 应用现已在私有化部署的极狐GitLab 上可用

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Links: [文档](../../administration/settings/slack_app.md) | [相关议题](https://gitlab.com/gitlab-org/gitlab/-/issues/358872)

{{< /details >}}

在此版本中，极狐GitLab for Slack 应用可在私有化部署实例上使用。在私有化部署的极狐GitLab 上，你可以从[清单文件](https://api.slack.com/reference/manifests#creating_apps)创建极狐GitLab for Slack 应用的副本，并将该副本安装到你的 Slack 工作区中。每个副本都是私有的，不可公开分发。

要创建和配置该应用，请参阅[极狐GitLab for Slack 应用管理](../../administration/settings/slack_app.md)。

<a id="speed-up-imports-from-github-using-multiple-access-tokens"></a>

### 使用多个访问令牌加速从 GitHub 导入

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: JihuLab.com
- Links: [文档](../../api/import.md#import-repository-from-github) | [相关议题](https://gitlab.com/gitlab-org/gitlab/-/issues/337232)

{{< /details >}}

默认情况下，GitHub 导入器在将项目从 GitHub 导入到极狐GitLab 时使用单个访问令牌。用户账户的访问令牌通常限制为每小时 5000 个请求。在以下情况下，这会显著降低导入器的速度：

- 导入多个中小型项目。
- 导入包含大量数据的单个大型项目。

在此版本中，你可以将访问令牌列表传递给 GitHub 导入器 API，以便 API 在受到速率限制时轮换使用它们。
使用多个访问令牌时：

- 令牌不能来自同一个账户，因为它们会共享一个速率限制。
- 令牌必须具有相同的权限，并且对要导入的仓库具有足够的特权。

<a id="sync-auditor-role-with-oidc-provider"></a>

### 与 OIDC 提供程序同步审计员角色

{{< details >}}

- Tier: 专业版，旗舰版
- Links: [文档](../../administration/auth/oidc.md#auditor-groups) | [相关议题](https://gitlab.com/gitlab-org/gitlab/-/issues/389321)

{{< /details >}}

你现在可以将 OIDC 群组同步到极狐GitLab 中的 `auditor` 角色。这使得由 OIDC 促进的自动化用户生命周期管理能够使用 `auditor` 角色，该角色以前在角色映射中不受支持。

感谢 [Marin Hannache](https://gitlab.com/mareo) 的贡献！

<a id="improved-sign-in-and-sign-up-pages"></a>

### 改进了登录和注册页面

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: JihuLab.com
- Links: [文档](../../administration/settings/sign_up_restrictions.md) | [相关议题](https://gitlab.com/gitlab-org/gitlab/-/issues/385651)

{{< /details >}}

极狐GitLab 的登录和注册页面已得到改进：

- 当存在自定义文本时，采用两栏布局。
- 修复了多个 LDAP 的“记住我”复选框的问题。
- 改进了深色模式体验。
- 更大的单点登录按钮。
- 将页脚移至页面底部，以避免隐藏页面元素。
- 在 SAML 登录页面添加了语言切换器。
- 在注册试用页面启用了密码检查。

<a id="backup-adds-the-ability-to-skip-projects"></a>

### 备份增加了跳过项目的功能

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Links: [相关议题](https://gitlab.com/gitlab-org/gitlab/-/issues/18287)

{{< /details >}}

内置的备份和恢复工具增加了跳过特定仓库的功能。Rake 任务现在接受一个逗号分隔的群组或项目路径列表，通过使用新的 `SKIP_REPOSITORIES_PATHS` 环境变量，在备份或恢复期间跳过这些路径。这将允许你跳过例如不随时间变化的陈旧或归档项目，从而节省 a) 通过加快备份运行速度来节省时间，以及 b) 通过不将这些数据包含在备份文件中来节省空间。
感谢 [Yuri Konotopov](https://gitlab.com/nE0sIghT) 的[社区贡献](https://gitlab.com/gitlab-org/security-products/analyzers/semgrep/-/merge_requests/196)！

<a id="geo-add-individual-resync-and-reverification-for-all-components"></a>

### Geo 为所有组件添加单独重新同步和重新验证功能

{{< details >}}

- Tier: 专业版，旗舰版
- Links: [文档](../../administration/geo/_index.md) | [相关议题](https://gitlab.com/gitlab-org/gitlab/-/issues/364727)

{{< /details >}}

Geo 增加了为[自助服务框架](../../development/geo/framework.md)管理的所有组件类型单独重新同步和重新验证各个项目的能力。现在，你可以通过 UI 强制对 Geo 管理的任何单个项目执行重新同步或重新验证操作。这有助于加快失败项目的重新同步或重新验证操作，或者在应用了修复同步或验证错误的更改之后。

<a id="unified-devops-and-security"></a>

## 统一 DevOps 与安全

<a id="improve-git-lfs-download-performance"></a>

### 改进 Git LFS 下载性能

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Links: [文档](../../topics/git/lfs/_index.md)

{{< /details >}}

对于将 LFS 对象存储在对象存储中且未启用[代理下载](../../administration/object_storage.md#proxy-download)的实例，极狐GitLab 现在批量处理 LFS 请求。这极大地提高了下载大量 LFS 对象的性能。

以前，由于 LFS 对象的获取方式，极狐GitLab 会创建许多非常小的请求来检查用户权限并重定向到外部存储的对象。这可能导致显著负载和性能下降。通过此次修复，我们减少了主极狐GitLab 实例的负载，并为用户提供了更快的下载体验。

<a id="install-the-agent-for-kubernetes-using-extra-volumes-in-the-helm-chart"></a>

### 在 Helm Chart 中使用额外卷安装 Kubernetes agent

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: JihuLab.com
- Links: [文档](../../user/clusters/agent/install/_index.md#customize-the-helm-installation) | [相关议题](https://gitlab.com/gitlab-org/charts/gitlab-agent/-/issues/33)

{{< /details >}}

Kubernetes agent 的 `agentk` 组件需要一个令牌来向极狐GitLab 进行身份验证。以前，你可以直接提供令牌，或者作为包含令牌的 Kubernetes 密钥的引用。但是，你可能在密钥已存在于卷中的环境中操作，并且更愿意挂载该卷而不是创建单独的密钥。从极狐GitLab 16.2 开始，极狐GitLab agent Helm chart 包含了这一新增功能，这要感谢 [Thomas Spear](https://gitlab.com/tspearconquest) 的社区贡献。

<a id="support-for-custom-ci-variables-in-the-scan-execution-policies-editor"></a>

### 在扫描执行策略编辑器中支持自定义 CI 变量

{{< details >}}

- Tier: 旗舰版
- Offering: JihuLab.com
- Links: [文档](../../user/application_security/policies/scan_execution_policies.md) | [相关史诗](https://gitlab.com/groups/gitlab-org/-/epics/9566)

{{< /details >}}

你现在可以在扫描执行策略编辑器中定义自定义 CI 变量，包括它们的值。在策略中定义的 CI 变量会覆盖由该策略强制执行的项目中定义的匹配变量。例如，一个策略可以将 CI 变量 `SAST_EXCLUDED_ANALYZERS` 定义为 `brakeman`。当在项目中强制执行扫描程序时，无论项目的 CI 配置中定义了任何变量，扫描程序都将使用设置为 `brakeman` 的变量运行。对于每种扫描类型，你可以为默认变量定义值，也可以为自定义 CI 变量创建自定义键值对。这使得自定义扫描执行策略更快、更容易。

<a id="allow-scan-execution-policies-to-enable-ci-cd-pipelines-in-development-projects"></a>

### 允许扫描执行策略在开发项目中启用 CI/CD 流水线

{{< details >}}

- Tier: 旗舰版
- Offering: JihuLab.com
- Links: [文档](../../user/application_security/policies/scan_execution_policies.md) | [相关史诗](https://gitlab.com/groups/gitlab-org/-/epics/6880)

{{< /details >}}

在以前的极狐GitLab 版本中，安全策略不会在没有 `.gitlab-ci.yml` 文件或 AutoDevOps 被禁用的项目上强制执行。在极狐GitLab 16.2 中，安全策略隐式地在不包含 `.gitlab-ci.yml` 文件的项目上启用 CI/CD 流水线。这是确保安全策略合规性的又一步，允许你强制执行密钥检测、静态分析或任何不需要构建的其他作业。

<a id="target-default-or-protected-branches-in-security-policies"></a>

### 在安全策略中定位“默认”或“受保护”分支

{{< details >}}

- Tier: 旗舰版
- Offering: JihuLab.com
- Links: [文档](../../user/application_security/policies/merge_request_approval_policies.md#scan_finding-rule-type) | [相关史诗](https://gitlab.com/groups/gitlab-org/-/epics/9468)

{{< /details >}}

扫描执行和扫描结果策略将允许你将强制执行范围限定为策略所强制执行的多个项目中的“默认”分支或“受保护分支”。策略无需明确指定分支名称，可以更广泛地强制执行，并确保名称非典型的分支不会被排除在合规之外。

可以使用 `branch_type` 字段在我们的各种安全策略规则类型中配置分支规则：

- [扫描结果策略的 scan_finding 规则类型](../../user/application_security/policies/merge_request_approval_policies.md#scan_finding-rule-type)
- [扫描结果策略的 license_finding 规则类型](../../user/application_security/policies/merge_request_approval_policies.md#license_finding-rule-type)
- [扫描执行策略的流水线规则类型](../../user/application_security/policies/scan_execution_policies.md#pipeline-rule-type)
- [扫描执行策略的计划规则类型](../../user/application_security/policies/scan_execution_policies.md#schedule-rule-type)

<a id="audit-event-streaming-to-google-cloud-logging"></a>

### 审计事件流式传输到 Google Cloud Logging

{{< details >}}

- Tier: 旗舰版
- Offering: JihuLab.com
- Links: [文档](../../administration/compliance/audit_event_reports.md)

{{< /details >}}

你现在可以选择 Google Cloud Logging 作为审计事件流的目标。

以前，你必须使用标头来尝试构建 Google Cloud Logging 会接受的请求。这种方法容易出错，并且可能难以排查。

现在，你可以选择 Google Cloud Logging 作为流的目标，并提供你的项目 ID、客户端电子邮件、日志 ID 和私钥，以实现更无缝的集成。

<a id="compliance-frameworks-report-export"></a>

### 合规框架报告导出

{{< details >}}

- Tier: 旗舰版
- Offering: JihuLab.com
- Links: [文档](../../user/compliance/compliance_center/compliance_projects_report.md#export-a-report-of-compliance-frameworks-on-projects-in-a-group)

{{< /details >}}

你现在可以将合规框架及其关联项目的报告导出为 CSV 文件。

随着群组级别合规框架报告的添加，你能够查看和管理你的合规框架应用于哪些项目。

通过新的导出功能，你可以保留该文件的副本以供参考。你可以将该文件作为项目和合规框架关系理想状态的单一事实来源。或者，你可以将该文件发送给你组织中可能不在极狐GitLab 中工作，但有兴趣查看哪些项目被标记了哪些框架的人员。

<a id="group-sub-group-level-dependency-list"></a>

### 群组/子群组级别依赖项列表

{{< details >}}

- Tier: 旗舰版
- Links: [文档](../../user/application_security/dependency_list/_index.md) | [相关史诗](https://gitlab.com/groups/gitlab-org/-/epics/8090)

{{< /details >}}

在查看依赖项列表时，拥有整体视图非常重要。对于希望审计其所有项目中依赖项的大型组织来说，在项目级别管理依赖项是有问题的。
在此版本中，你可以在项目或群组级别（包括子群组）查看所有依赖项。此功能默认关闭，位于功能标志 `group_level_dependencies` 之后。

<a id="allow-initial-push-to-protected-branches"></a>

### 允许初始推送到受保护分支

{{< details >}}
{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: JihuLab.com
- Links: [文档](../../user/project/repository/branches/default.md#protect-initial-default-branches)

{{< /details >}}

在以前的极狐GitLab 版本中，当默认分支被完全保护时，只有项目维护者和所有者才能将初始提交推送到默认分支。

这给创建了新项目但无法推送初始提交的开发者带来了问题，因为只有默认分支存在。

通过 **初次推送后完全保护** 设置，开发者可以将初始提交推送到仓库的默认分支，但之后不能推送任何提交到默认分支。与分支完全保护类似，项目维护者始终可以推送到默认分支，但任何人都无法强制推送。

<a id="instance-level-streaming-audit-events"></a>

### 实例级流式审计事件

{{< details >}}

- Tier: 旗舰版
- Links: [文档](../../administration/compliance/audit_event_reports.md)

{{< /details >}}

在极狐GitLab 16.1 之前，只有顶级群组的审计事件可以流式传输到外部目的地。

现在，实例管理员可以为在实例级别生成的审计事件添加流式目的地。

<a id="streaming-audit-event-filtering-ui"></a>

### 流式审计事件过滤 UI

{{< details >}}

- Tier: 旗舰版
- Offering: JihuLab.com
- Links: [文档](../../administration/compliance/audit_event_reports.md)

{{< /details >}}

在以前的极狐GitLab 版本中，你必须使用 GraphQL API 将审计事件类型过滤器添加到你的审计事件流中。

现在，你可以使用极狐GitLab UI 中的过滤器下拉菜单查看所有可用的审计事件类型，这些类型按照它们相关的极狐GitLab 领域分组，并且可以搜索你希望在流中发送的具体类型。

这大大减少了向审计事件流添加过滤所需的时间，因为你不再需要使用 API 拉取整个列表并手动搜索列表。

<a id="interactive-diff-suggestions-in-merge-requests"></a>

### 合并请求中的交互式差异建议

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Links: [文档](../../user/project/merge_requests/reviews/suggestions.md#using-the-rich-text-editor) | [相关议题](https://gitlab.com/gitlab-org/gitlab/-/issues/406726)

{{< /details >}}

当你在合并请求中建议更改时，现在可以更快速地编辑你的建议。在评论中，切换到富文本编辑器并使用 UI 上下移动文本行。通过此更改，你可以查看你的建议在评论发布后的确切外观。

富文本编辑器是极狐GitLab 中的全新编辑方式。它可用于合并请求，但也可在议题和史诗中与纯文本编辑器一起使用。

我们计划很快在极狐GitLab 的更多领域提供富文本编辑器，我们正在积极努力。你可以在[此处](https://gitlab.com/groups/gitlab-org/-/epics/10378)关注我们的进展。

<a id="import-pypi-packages-with-ci-cd-pipelines"></a>

### 使用 CI/CD 流水线导入 PyPI 软件包

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Links: [文档](../../user/packages/package_registry/_index.md#to-import-packages) | [相关议题](https://gitlab.com/gitlab-org/gitlab/-/issues/389339)

{{< /details >}}

你一直在考虑将 PyPI 仓库迁移到极狐GitLab，但一直没时间迁移吗？在此版本中，极狐GitLab 推出了 PyPI 软件包导入器的第一版。

你现在可以使用软件包导入器工具从任何兼容 PyPI 的仓库（如 Artifactory）导入软件包。

<a id="add-emoji-reactions-to-comments-on-uploaded-designs"></a>

### 为上传设计中的评论添加表情符号回应

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: JihuLab.com
- Links: [文档](../../user/emoji_reactions.md) | [相关议题](https://gitlab.com/gitlab-org/gitlab/-/issues/29756)

{{< /details >}}

你现在可以通过向[设计管理](../../user/project/issues/design_management.md)中的评论添加表情符号回应，更创造性地表达你的想法。此功能为协作增添了一点趣味和轻松，促进更好的沟通，并使团队能够以更具表现力的方式提供快速反馈。

<a id="sast-analyzer-updates"></a>

### SAST 分析器更新

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Links: [文档](../../user/application_security/sast/analyzers.md) | [相关议题](../../user/application_security/_index.md)

{{< /details >}}

极狐GitLab SAST 包含[许多安全分析器](../../user/application_security/sast/_index.md#supported-languages-and-frameworks)，由极狐GitLab 静态分析团队积极维护、更新和支持。

在 16.2 版本里程碑中，我们的更改集中于基于 Semgrep 的分析器以及它用于扫描的极狐GitLab 维护的规则。我们发布了以下更改：

- 澄清了 JavaScript 规则的解释和指导，基于[极狐GitLab 16.1 中为其他语言发布的其他改进](https://gitlab.cn/releases/2023/06/22/gitlab-16-1-released/#clearer-guidance-and-better-coverage-for-sast-rules)。
- 更新了规则以发现 Java 和 JavaScript 中的其他漏洞。
- 更改了扫描中忽略哪些文件的默认配置，通过：
  - 移除了 `.gitignore` 排除。感谢 [`@SimonGurney`](https://gitlab.com/SimonGurney) 的社区贡献。
  - 尊重本地定义的 `.semgrepignore` 文件。感谢 [`@hmrc.colinameigh`](https://gitlab.com/hmrc.colinameigh) 的社区贡献。
- 改进了与 Go 内存别名相关的规则。感谢 [`@tyage`](https://gitlab.com/tyage) 的社区贡献。
- 移除了添加到 JavaScript 规则 Semgrep 规则 ID 的 `-1` 后缀。这是在极狐GitLab 16.0 中作为不相关更改的副作用添加的，但干扰了客户现有的 `semgrepignore` 注释。

有关更多详细信息，请参见 [`semgrep` CHANGELOG](https://jihulab.com/gitlab-cn/security-products/analyzers/semgrep/-/blob/main/CHANGELOG.md#v440) 和 [`sast-rules` CHANGELOG](https://jihulab.com/gitlab-cn/security-products/sast-rules/-/blame/main/CHANGELOG.md)。我们正在[史诗 10907](https://jihulab.com/groups/gitlab-cn/-/epics/10907) 中跟踪极狐GitLab 管理的规则集的进一步改进。

如果你[包含极狐GitLab 管理的 SAST 模板](../../user/application_security/sast/_index.md) ([`SAST.gitlab-ci.yml`](https://jihulab.com/gitlab-cn/gitlab/blob/master/lib/gitlab/ci/templates/Security/SAST.gitlab-ci.yml)) 并运行极狐GitLab 16.0 或更高版本，你将自动收到这些更新。要保留任何分析器的特定版本并防止自动更新，你可以[固定其版本](../../user/application_security/sast/_index.md)。

有关以前的更改，请参见[上个月的更新](https://gitlab.cn/releases/2023/06/22/gitlab-16-1-released/#sast-analyzer-updates)。

<a id="secret-detection-updates"></a>

### 密钥检测更新

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Links: [文档](../../user/application_security/secret_detection/_index.md) | [相关议题](../../user/application_security/_index.md)

{{< /details >}}

我们定期发布极狐GitLab 密钥检测分析器的更新。在极狐GitLab 16.2 里程碑中，我们：

- 为以下内容添加了[极狐GitLab 管理的检测规则](../../user/application_security/secret_detection/_index.md)：
  - OpenAI API 密钥。
  - CircleCI 个人和项目访问令牌。感谢 [`@nathanwfish`](https://gitlab.com/nathanwfish) 的社区贡献。
- 改进了使用 `keywords` 优化的规则性能。
- 修复了[一个问题](https://jihulab.com/gitlab-cn/gitlab/-/issues/358073)，其中密钥检测结果创建了指向仓库中错误位置的永久链接。

有关更多详细信息，请参见 [CHANGELOG](https://jihulab.com/gitlab-cn/security-products/analyzers/secrets/-/blob/master/CHANGELOG.md#v514)。

如果你[使用极狐GitLab 管理的密钥检测模板](../../user/application_security/secret_detection/_index.md) ([`Secret-Detection.gitlab-ci.yml`](https://jihulab.com/gitlab-cn/gitlab/blob/master/lib/gitlab/ci/templates/Jobs/Secret-Detection.gitlab-ci.yml)) 并运行极狐GitLab 16.0 或更高版本，你将自动收到这些更新。要保留任何分析器的特定版本并防止自动更新，你可以[固定其版本](../../user/application_security/secret_detection/_index.md)。

有关以前的更改，请参见[最新的密钥检测更新](https://gitlab.cn/releases/2023/05/22/gitlab-16-0-released/#secret-detection-updates)。

<a id="support-for-nuget-v2-in-dependency-and-license-scanning"></a>

### 依赖和许可证扫描中支持 NuGet v2

{{< details >}}

- Tier: 旗舰版
- Offering: JihuLab.com
- Links: [文档](../../user/application_security/dependency_scanning/legacy_dependency_scanning/_index.md#obtaining-dependency-information-by-parsing-lockfiles) | [相关议题](https://jihulab.com/gitlab-cn/gitlab/-/issues/398680)

{{< /details >}}

除了 NuGet `v1` 锁文件之外，极狐GitLab 的依赖扫描和许可证扫描现在还支持分析 NuGet `v2` 锁文件中定义的依赖项。

<a id="improved-sast-vulnerability-tracking"></a>

### 改进的 SAST 漏洞跟踪

{{< details >}}

- Tier: 旗舰版
- Links: [文档](../../user/application_security/sast/_index.md#advanced-vulnerability-tracking) | [相关议题](https://jihulab.com/groups/gitlab-cn/-/epics/5144)

{{< /details >}}

极狐GitLab SAST [高级漏洞跟踪](../../user/application_security/sast/_index.md#advanced-vulnerability-tracking)通过跟踪代码移动时发现的漏洞，使分类更高效。

我们在极狐GitLab 16.2 中发布了两项改进：

1. 扩展了语言支持：现在为 C# 启用了高级漏洞跟踪。
2. 更好的跟踪：我们改进了跟踪算法，以更好地处理 C、C#、Go、Java、JavaScript 和 Python 中的空格和注释。我们还修复了跟踪某些 Go 函数的问题。

我们正在[史诗 5144](https://jihulab.com/groups/gitlab-cn/-/epics/5144) 中跟踪进一步的改进，包括扩展到更多语言、更好地处理更多语言结构以及改进对 Python 和 Ruby 的跟踪。

这些更改包含在极狐GitLab SAST [分析器](../../user/application_security/sast/analyzers.md)的[更新版本](https://gitlab.cn/docs/#sast-analyzer-updates)中。在使用更新后的分析器扫描项目后，你的项目漏洞发现将使用新的跟踪签名进行更新。

你无需执行任何操作即可接收此更新，除非你已将 [SAST 分析器固定到特定版本](../../user/application_security/sast/_index.md)。

<a id="ci-cd-support-for-when-never-on-conditional-includes"></a>

### CI/CD：支持条件包含中的 `when: never`

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: JihuLab.com
- Links: [文档](../../ci/yaml/includes.md#include-with-rulesif) | [相关议题](https://jihulab.com/gitlab-cn/gitlab/-/issues/348146)

{{< /details >}}

[`include`](../../ci/yaml/_index.md#include) 是编写完整 CI/CD 流水线时最常用的关键字之一。如果你正在构建更大的流水线，你可能正在使用 `include` 关键字将外部 YAML 配置引入你的流水线。

在此版本中，我们扩展了该关键字的功能，以便你可以在[将 `rules` 与 `include` 一起使用](../../ci/yaml/includes.md#use-rules-with-include)时使用 `when: never`。现在，你可以决定在满足特定规则时何时排除外部 CI/CD 配置。这将帮助你编写标准化的流水线，能够根据你选择的条件更好地动态修改自身。

<a id="medium-saas-runners-on-linux-available-to-all-tiers"></a>

### Linux 上的中型 SaaS Runner 现可供所有层级使用

{{< details >}}

- Tier: 基础版、Silver、Gold
- Offering: JihuLab.com
- Links: [文档](../../ci/runners/hosted_runners/linux.md) | [相关议题](https://jihulab.com/gitlab-cn/gitlab/-/issues/418124)

{{< /details >}}

我们现在已向所有层级提供具有 4 个 vCPU 和 16 GB RAM 的中型 [极狐GitLab SaaS Runner（Linux 版）](../../ci/runners/hosted_runners/linux.md)。

以前，基础版的用户只能使用我们的小型 Linux Runner，这有时会导致更长的 CI/CD 执行时间。

我们很高兴看到基础版用户加快他们的流水线速度。

<a id="gitlab-runner-162"></a>

### 极狐GitLab Runner 16.2

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Links: [文档](https://gitlab.cn/docs/runner)

{{< /details >}}

我们今天还发布了 极狐GitLab Runner 16.2！极狐GitLab Runner 是一个轻量级、高度可扩展的代理，用于运行你的 CI/CD 作业并将结果发送回 极狐GitLab 实例。极狐GitLab Runner 与 极狐GitLab CI/CD 配合使用，后者是 极狐GitLab 附带的开源持续集成服务。

<a id="whats-new"></a>

#### 新功能

- [在 Runner Kubernetes 执行器中重试所有 k8s API 调用](https://jihulab.com/gitlab-cn/gitlab-runner/-/merge_requests/4143)

<a id="bug-fixes"></a>

#### 错误修复

- [当 dockerd 或任何进程在后台运行时，CI 作业脚本不会完成](https://jihulab.com/gitlab-cn/gitlab-runner/-/issues/2880)
- [GitLab-runner-helper servercore 镜像在 v16.1.0 中丢失](https://jihulab.com/gitlab-cn/gitlab-runner/-/issues/33918)
- [错误：无法创建缓存适配器](https://jihulab.com/gitlab-cn/gitlab-runner/-/issues/3802)

所有更改的列表在极狐GitLab Runner [CHANGELOG](https://jihulab.com/gitlab-cn/gitlab-runner/blob/16-2-stable/CHANGELOG.md) 中。