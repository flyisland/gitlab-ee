---
stage: Release Notes
group: Monthly Release
date: 2024-07-18
title: "极狐GitLab 17.2 发布说明"
description: "极狐GitLab 17.2 发布，支持 Kubernetes pod 和容器的日志流式传输"
---

<!-- markdownlint-disable -->
<!-- vale off -->

2024 年 7 月 18 日，极狐GitLab 17.2 发布，包含以下功能。

<a id="primary-features"></a>

## 主要功能

<a id="log-streaming-for-kubernetes-pods-and-containers"></a>

### Kubernetes pod 和容器的日志流式传输

<!-- categories: Environment Management -->

{{< details >}}

- 适用版本: 基础版、专业版、旗舰版
- 交付方式: JihuLab.com、私有化部署
- 链接: [文档](../../ci/environments/kubernetes_dashboard.md) | [相关史诗](https://gitlab.com/groups/gitlab-org/-/epics/13793)

{{< /details >}}

在极狐GitLab 16.1 中，我们引入了 Kubernetes pod 列表和详情视图。但是，您仍然必须使用第三方工具才能深入分析您的工作负载。极狐GitLab 现在内置了 pod 和容器的日志流式传输视图，因此您无需离开应用交付工具，即可快速检查并排查各个环境中的问题。

<a id="gitlab-duo-disabling-input-and-output-logging-by-default"></a>

### 极狐GitLab Duo 默认禁用输入和输出日志记录

<!-- categories: Duo Chat -->

{{< details >}}

- 适用版本: 基础版、专业版、旗舰版
- 交付方式: JihuLab.com、私有化部署
- 附加组件: 极狐GitLab Duo Pro, 极狐GitLab Duo Enterprise
- 链接: [文档](../../user/gitlab_duo/data_usage.md#data-retention) | [相关史诗](https://gitlab.com/groups/gitlab-org/-/epics/13401)

{{< /details >}}

极狐GitLab 现在默认禁用极狐GitLab Duo 的 AI 输入和输出日志记录。

在极狐GitLab，我们致力于确保客户对其数据拥有自主权。现在，我们已默认禁用输入和输出日志记录，只有在客户通过极狐GitLab 支持工单明确同意的情况下，才会记录输入和输出。

<a id="block-a-merge-request-by-requesting-changes"></a>

### 通过请求更改来阻止合并请求

<!-- categories: Code Review Workflow -->

{{< details >}}

- 适用版本: 专业版、旗舰版
- 交付方式: JihuLab.com、私有化部署
- 链接: [文档](../../user/project/merge_requests/reviews/_index.md#prevent-merge-when-you-request-changes)

{{< /details >}}

当您执行评审时，可以通过选择 `approve`、`comment` 或 `request changes`（[在极狐GitLab 16.9 中发布](../16/gitlab-16-9-released.md#request-changes-on-merge-requests)）来完成评审。在评审过程中，您可能会发现某些更改应阻止合并请求合并，直到这些问题得到解决，因此您以 `request changes` 完成评审。

在请求更改时，极狐GitLab 现在会添加一项合并检查，在请求更改得到解决之前阻止合并。当最初请求更改的用户重新评审合并请求并随后批准该合并请求时，请求更改即可得到解决。如果最初请求更改的用户无法批准，任何拥有合并权限的人都可以**绕过**该请求更改，以便开发工作继续进行。

请在[议题 455339](https://gitlab.com/gitlab-org/gitlab/-/issues/455339)中向我们提供有关此新功能的反馈。

<a id="vulnerability-explanation"></a>

### 漏洞解释

<!-- categories: Vulnerability Management -->

{{< details >}}

- 适用版本: 旗舰版
- 交付方式: JihuLab.com、私有化部署
- 附加组件: Duo Enterprise
- 链接: [文档](../../user/application_security/analyze/duo.md) | [相关史诗](https://gitlab.com/groups/gitlab-org/-/epics/10642)

{{< /details >}}

漏洞解释现在是极狐GitLab Duo Chat 的一部分，并且已正式发布。借助漏洞解释，您可以从任何 SAST 漏洞打开聊天，以更好地了解该漏洞、查看它可能如何被利用，并查看潜在的修复方案。

<a id="oauth-20-device-authorization-grant-support"></a>

### 支持 OAuth 2.0 设备授权授予

<!-- categories: System Access -->

{{< details >}}

- 适用版本: 基础版、专业版、旗舰版
- 交付方式: JihuLab.com、私有化部署
- 链接: [文档](../../api/oauth2.md#device-authorization-grant-flow) | [相关议题](https://gitlab.com/gitlab-org/gitlab/-/issues/332682)

{{< /details >}}

极狐GitLab 现在支持 [OAuth 2.0 设备授权授予流程](https://datatracker.ietf.org/doc/html/rfc8628)。此流程使得在无法进行浏览器交互的输入受限设备上安全地验证您的极狐GitLab 身份成为可能。这使得设备授权授予流程非常适合尝试从无头服务器或其他没有 UI 或 UI 受限的设备使用极狐GitLab 服务的用户。
感谢 [John Parent](https://kitware.com/)的贡献！

<a id="pipeline-execution-policy-type"></a>

### 流水线执行策略类型

<!-- categories: Security Policy Management -->

{{< details >}}

- 适用版本: 旗舰版
- 交付方式: JihuLab.com、私有化部署
- 链接: [文档](../../user/application_security/policies/pipeline_execution_policies.md) | [相关史诗](https://gitlab.com/groups/gitlab-org/-/epics/13266)

{{< /details >}}

流水线执行策略类型是一种新型的[安全策略](../../user/application_security/policies/_index.md)，允许用户支持强制执行通用 CI 作业、脚本和指令。

流水线执行策略类型使安全和合规团队能够强制执行自定义的 [GitLab 安全扫描模板](https://gitlab.com/gitlab-org/gitlab/-/tree/master/lib/gitlab/ci/templates/Jobs)、[GitLab 或合作伙伴支持的 CI 模板](https://gitlab.com/gitlab-org/gitlab/-/tree/master/lib/gitlab/ci/templates)、第三方安全扫描模板、通过 CI 作业实现的自定义报告规则，或通过极狐GitLab CI 实现的自定义脚本/规则。

流水线执行策略有两种模式：注入和覆盖。*注入*模式将作业注入项目的 CI/CD 流水线。*覆盖*模式替换项目的 CI/CD 流水线配置。

与所有极狐GitLab 策略一样，强制执行可以由创建和管理策略的指定安全和合规团队成员集中管理。[了解如何通过创建您的第一个流水线执行策略来开始使用](../../user/application_security/policies/pipeline_execution_policies.md)！

<a id="expanded-support-of-custom-rulesets-in-pipeline-secret-detection"></a>

### 扩展流水线密钥检测中自定义规则集的支持

<!-- categories: Secret Detection -->

{{< details >}}

- 适用版本: 旗舰版
- 交付方式: JihuLab.com、私有化部署
- 链接: [文档](../../user/application_security/secret_detection/pipeline/configure.md#customize-analyzer-rulesets) | [相关议题](https://gitlab.com/gitlab-org/gitlab/-/issues/336395)

{{< /details >}}

我们扩展了流水线密钥检测中自定义规则集的支持。

您可以使用两种新型透传类型 `git` 和 `url` 来配置远程规则集。这使得管理诸如在多个项目之间共享规则集配置之类的工作流变得更加容易。

您还可以使用这些新型透传类型之一，通过远程规则集扩展默认配置。

分析器现在还支持：

- 将最多 20 个透传链接到单个配置中以替换预定义规则。
- 在透传中包含环境变量。
- 在加载透传时设置超时。
- 验证规则集配置中的 TOML 语法。

<a id="gitlab-duo-chat-and-code-suggestions-available-in-workspaces"></a>

### 工作区中可用的极狐GitLab Duo Chat 和代码建议

<!-- categories: Workspaces, Duo Chat, Code Suggestions -->

{{< details >}}

- 适用版本: 专业版、旗舰版
- 交付方式: JihuLab.com、私有化部署
- 附加组件: Duo Pro, Duo Enterprise
- 链接: [文档](../../user/gitlab_duo/_index.md)

{{< /details >}}

[极狐GitLab Duo Chat](../../user/gitlab_duo_chat/_index.md) 和[代码建议](../../user/project/repository/code_suggestions/_index.md)现已在工作区中可用！无论您是寻求快速答案还是高效的代码改进，Duo Chat 和代码建议都旨在提高生产力并简化您的工作流，使工作区中的远程开发比以往任何时候都更高效、更有效。

<a id="scale-and-deployments"></a>

## 规模和部署

<a id="improved-sorting-and-filtering-in-group-overview"></a>

### 改进群组概览中的排序和筛选

<!-- categories: Groups & Projects -->

{{< details >}}

- 适用版本: 基础版、专业版、旗舰版
- 交付方式: JihuLab.com、私有化部署
- 链接: [文档](../../user/group/_index.md#view-a-group) | [相关议题](https://gitlab.com/gitlab-org/gitlab/-/issues/437013)

{{< /details >}}

我们更新了群组概览页面的排序和筛选功能。搜索元素现在横跨整个页面，让您可以更好地查看搜索字符串。我们将排序选项标准化为 `Name`、`Created date`、`Updated date` 和 `Stars`。

我们欢迎在[议题 438322](https://gitlab.com/gitlab-org/gitlab/-/issues/438322)中提供有关这些更改的反馈。

<a id="list-groups-that-a-group-was-invited-to-using-the-groups-api"></a>

### 使用群组 API 列出群组被邀请加入的群组

<!-- categories: Source Code Management, Groups & Projects -->

{{< details >}}

- 适用版本: 基础版、专业版、旗舰版
- 交付方式: JihuLab.com、私有化部署
- 链接: [文档](../../api/groups.md#list-shared-groups) | [相关议题](https://gitlab.com/gitlab-org/gitlab/-/issues/424959)

{{< /details >}}

我们在群组 API 中添加了一个新端点，用于列出群组被邀请加入的群组。此功能补充了[列出群组被邀请加入的项目的端点](../../api/groups.md#list-shared-projects)，因此您现在可以全面了解您的群组已被添加到的所有群组和项目。该端点的速率限制为每用户每分钟 60 个请求。

感谢 [@imskr](https://gitlab.com/imskr)的社区贡献！

<a id="resolve-to-do-items-one-discussion-at-a-time"></a>

### 一次解决一个讨论串的待办事项

<!-- categories: Notifications -->

{{< details >}}

- 适用版本: 基础版、专业版、旗舰版
- 交付方式: JihuLab.com、私有化部署
- 链接: [文档](../../user/todos.md) | [相关议题](https://gitlab.com/gitlab-org/gitlab/-/issues/461111)

{{< /details >}}

极狐GitLab 议题上的讨论可能会很繁忙。极狐GitLab 通过为您相关的评论创建待办事项来帮助您管理这些对话，并在您对议题执行操作时自动解决该事项。

以前，当您对议题中的某个讨论串执行操作时，所有待办事项都会被解决，即使您在多个不同的讨论串中被提及。现在，极狐GitLab 只会解决您所交互的讨论串的待办事项。

<a id="indicate-imported-items-in-ui"></a>

### 在 UI 中指示导入的条目

<!-- categories: Importers -->

{{< details >}}

- 适用版本: 基础版、专业版、旗舰版
- 交付方式: JihuLab.com、私有化部署
- 链接: [文档](../../user/import/_index.md) | [相关史诗](https://gitlab.com/groups/gitlab-org/-/epics/13825)

{{< /details >}}

您可以从[其他 SCM 解决方案](../../user/import/_index.md)将项目导入到极狐GitLab。但是，很难知道项目条目是在极狐GitLab 实例上导入的还是创建的。

在此版本中，我们为从 GitHub、Gitea、Bitbucket Server 和 Bitbucket Cloud 导入的条目添加了视觉指示器，其中创建者被标识为特定
用户。例如，合并请求、议题和评论。

<a id="deleted-branches-are-removed-from-jira-development-panel"></a>

### 已删除的分支会从 Jira 开发面板中移除

<!-- categories: Settings -->

{{< details >}}

- 适用版本: 基础版、专业版、旗舰版
- 交付方式: JihuLab.com、私有化部署
- 链接: [文档](../../integration/jira/development_panel.md#feature-availability) | [相关议题](https://gitlab.com/gitlab-org/gitlab/-/issues/351625)

{{< /details >}}

以前，在使用 [GitLab for Jira Cloud 应用](../../integration/jira/connect-app.md)时，如果您在极狐GitLab 中删除了某个分支，该分支仍会出现在 Jira 开发面板中。选择该分支会导致极狐GitLab 上出现 `404` 错误。

从此版本开始，在极狐GitLab 中删除的分支会从 Jira 开发面板中移除。

<a id="find-project-settings-by-using-the-command-palette"></a>

### 使用命令面板查找项目设置

<!-- categories: Settings, Global Search -->

{{< details >}}

- 适用版本: 基础版、专业版、旗舰版
- 交付方式: JihuLab.com、私有化部署
- 链接: [文档](../../user/search/command_palette.md) | [相关议题](https://gitlab.com/gitlab-org/gitlab/-/issues/448637)

{{< /details >}}

极狐GitLab 在项目、群组、实例以及您个人方面提供了许多设置。要找到您要查找的设置，您通常需要花费时间点击 UI 中的许多不同区域。

在此版本中，您现在可以从命令面板搜索项目设置。通过访问一个项目、选择**搜索或跳转到…**、使用`>`进入命令模式，然后输入设置部分的名称（如**受保护标签**）来试用它。选择一个结果即可直接跳转到该设置本身。

<a id="unified-devops-and-security"></a>

## 统一 DevOps 和安全

<a id="merge-commit-message-generation-now-ga"></a>

### 合并提交消息生成现已正式发布

<!-- categories: Code Review Workflow -->

{{< details >}}

- 适用版本: 旗舰版
- 交付方式: 私有化部署
- 附加组件: Duo Enterprise
- 链接: [文档](../../user/project/merge_requests/duo_in_merge_requests.md#generate-a-merge-commit-message)

{{< /details >}}

精心编写提交消息是确保未来用户了解对代码库所做更改的内容和原因的重要一环。想出一条既能有效传达您的更改、又能考虑到您可能更改的所有内容的提交消息是一项挑战。

使用极狐GitLab Duo 生成合并提交现已正式发布，以帮助确保每个合并请求都有高质量的提交消息。在合并之前，在合并小组件中选择**编辑提交消息**，然后使用**生成提交消息**选项来起草提交消息。

这项新的极狐GitLab Duo 能力是确保您项目的提交历史成为未来开发者宝贵资源的好方法。

<a id="gitlab-duo-for-the-cli-now-ga"></a>

### 面向 CLI 的极狐GitLab Duo 现已正式发布

<!-- categories: GitLab CLI -->

{{< details >}}

- 适用版本: 旗舰版
- 交付方式: 私有化部署
- 附加组件: Duo Enterprise
- 链接: [文档](https://gitlab.cn/docs/cli/)

{{< /details >}}

面向 CLI 的极狐GitLab Duo 现已面向所有用户正式发布。您现在可以 `ask` 极狐GitLab Duo 来帮助您找到满足您需求的正确 `git` 命令。

使用 `glab duo ask <git question>`让极狐GitLab Duo 为您提供格式化的 `git` 命令以实现您的目标。然后，GitLab CLI 会提供有关这些命令及其作用的更多详细信息，包括所传递的任何标志的信息。然后，您可以在工作流中直接运行这些命令并获取其输出。

GitLab CLI 的 `ask` 命令是加快您工作流的好方法，可帮助您记住需要额外帮助的 `git` 命令。

<a id="pure-ssh-transfer-protocol-for-lfs"></a>

### 用于 LFS 的纯 SSH 传输协议

<!-- categories: Source Code Management -->

{{< details >}}

- 适用版本: 基础版、专业版、旗舰版
- 交付方式: JihuLab.com、私有化部署
- 链接: [文档](../../administration/lfs/_index.md#pure-ssh-transfer-protocol) | [相关史诗](https://gitlab.com/groups/gitlab-org/-/epics/11872)

{{< /details >}}

早在 2021 年 9 月，[`git-lfs` 3.0.0](https://github.com/git-lfs/git-lfs/blob/main/CHANGELOG.md#300-24-sep-2021) 就发布了对使用 SSH 作为传输协议（而非 HTTP）的支持。在 `git-lfs` 3.0.0 之前，HTTP 是唯一受支持的传输协议，这意味着某些用户无法在极狐GitLab 上使用 `git-lfs`。在此版本中，我们非常高兴地提供为 `git-lfs` 启用 SSH over HTTP 作为传输协议的支持。

感谢 [Kyle Edwards](https://gitlab.com/KyleFromKitware) 和
[Joe Snyder](https://gitlab.com/joe-snyder)的贡献！

<a id="deployments-and-approvals-to-protected-environments-trigger-an-audit-event"></a>

### 对受保护环境的部署和审批会触发审计事件

<!-- categories: Continuous Delivery -->

{{< details >}}

- 适用版本: 专业版、旗舰版
- 交付方式: JihuLab.com、私有化部署
- 链接: [文档](../../user/compliance/audit_event_types.md#continuous-delivery) | [相关议题](https://gitlab.com/gitlab-org/gitlab/-/issues/456687)

{{< /details >}}

可访问的部署事件记录（如部署审批）对于合规管理至关重要。在此之前，极狐GitLab 不提供与部署相关的审计事件，因此合规经理不得不使用自定义工具或直接在极狐GitLab 中搜索这些数据。极狐GitLab 现在提供三种审计事件：

- `deployment_started` 记录谁启动了部署作业，以及何时启动。
- `deployment_approved` 记录谁批准了部署作业，以及何时批准。
- `deployment_rejected` 记录谁拒绝了部署作业，以及何时拒绝。

<a id="assigning-frameworks-at-subgroup-compliance-center"></a>

### 在子群组合规中心分配框架

<!-- categories: Compliance Management -->

{{< details >}}

- 适用版本: 专业版、旗舰版
- 交付方式: JihuLab.com、私有化部署
- 链接: [文档](../../user/compliance/compliance_center/compliance_projects_report.md) | [相关史诗](https://gitlab.com/gitlab-org/gitlab/-/issues/469004)

{{< /details >}}

合规中心是合规团队管理其合规标准遵循情况报告、违规报告以及其群组合规框架的集中位置。

以前，合规中心的所有相关功能仅适用于顶级群组。这意味着对于子群组，所有者无法访问顶级群组上合规中心提供的任何功能。

为帮助解决这些关键痛点，我们添加了为子群组分配和取消分配合规框架的功能。现在，群组所有者可以在子群组级别可视化其合规状况，此外还可以使用已经提供的完整的顶级群组级别合规中心仪表板。

<a id="expand-scan-execution-policies-to-run-latest-templates-for-each-gitlab-analyzer"></a>

### 扩展“扫描执行策略”以为每个极狐GitLab 分析器运行 `latest` 模板

<!-- categories: Security Policy Management -->

{{< details >}}

- 适用版本: 旗舰版
- 交付方式: JihuLab.com、私有化部署
- 链接: [文档](../../user/application_security/policies/scan_execution_policies.md) | [相关议题](https://gitlab.com/gitlab-org/gitlab/-/issues/415427)

{{< /details >}}

[扫描执行策略](../../user/application_security/policies/scan_execution_policies.md)已扩展，允许您在定义策略规则时在 `default` 和 `latest` 极狐GitLab 模板之间进行选择。`default` 反映当前行为，而您可以将策略更新为 `latest`，以使用仅在给定安全分析器的最新模板中可用的功能。

通过使用 `latest` 模板，您现在可以确保在合并请求流水线上强制执行扫描，以及 `latest` 模板中启用的任何其他规则。以前，这仅限于分支流水线或指定的计划。

注意：在修改策略之前，请务必查看 `default` 和 `latest` 模板之间的所有更改，以确保这符合您的需求！

<a id="identify-dates-when-multiple-access-tokens-expire"></a>

### 识别多个访问令牌过期的日期

<!-- categories: System Access -->

{{< details >}}

- 适用版本: 基础版、专业版、旗舰版
- 交付方式: 私有化部署
- 链接: [文档](../../security/tokens/_index.md) | [相关议题](https://gitlab.com/gitlab-org/gitlab/-/issues/467313)

{{< /details >}}

管理员现在可以运行一个脚本，用于识别多个访问令牌过期的日期。如果尚未实施令牌轮换，您可以将此脚本与[令牌故障排除页面](../../security/tokens/token_troubleshooting.md)上的其他脚本结合使用，以识别并延长可能即将到期的大批令牌。

<a id="oauth-authorization-screen-improvements"></a>

### OAuth 授权屏幕改进

<!-- categories: System Access -->

{{< details >}}

- 适用版本: 基础版、专业版、旗舰版
- 交付方式: JihuLab.com、私有化部署
- 链接: [文档](../../integration/oauth_provider.md) | [相关议题](https://gitlab.com/gitlab-org/gitlab/-/issues/462655)

{{< /details >}}

OAuth 授权屏幕现在更清楚地描述了您正在授予的授权。它还为极狐GitLab 提供的应用程序包含了一个“由极狐GitLab 验证”部分。以前，无论应用程序是否由极狐GitLab 提供，用户体验都是相同的。这项新功能提供了额外的信任层。

<a id="streamlined-instance-administrator-setup"></a>

### 简化的实例管理员设置

<!-- categories: User Management -->

{{< details >}}

- 适用版本: 基础版、专业版、旗舰版
- 交付方式: 私有化部署
- 链接: [文档](../../administration/_index.md) | [相关议题](https://gitlab.com/gitlab-org/gitlab/-/issues/458985)

{{< /details >}}

全新安装极狐GitLab 的管理员设置体验已得到简化，并且更加安全。初始管理员 root 电子邮件地址现在是随机生成的，管理员必须将此电子邮件地址更改为他们可以访问的账号。以前，此步骤可能会被延迟，管理员可能会忘记更改电子邮件地址。

<a id="user-api-added-to-the-snowflake-data-connector"></a>

### 用户 API 已添加到 Snowflake 数据连接器

<!-- categories: Audit Events, Compliance Management -->

{{< details >}}

- 适用版本: 基础版、专业版、旗舰版
- 交付方式: 私有化部署
- 链接: [文档](../../integration/snowflake.md) | [相关史诗](https://gitlab.com/groups/gitlab-org/-/epics/13004)

{{< /details >}}

在极狐GitLab 17.2 中，我们为 [GitLab 数据连接器](https://app.snowflake.com/marketplace/listing/GZTYZXESENG/gitlab-gitlab-data-connector)添加了对[用户 API](../../api/users.md#list-all-users)的支持，该连接器可在 Snowflake Marketplace 应用中使用。您现在可以使用用户 API 将用户数据从私有化部署的极狐GitLab 实例流式传输到 Snowflake。

<a id="simplified-setup-for-google-cloud-integration"></a>

### 简化的 Google Cloud 集成设置

<!-- categories: System Access -->

{{< details >}}

- 适用版本: 基础版
- 交付方式: JihuLab.com
- 链接: [文档](../../tutorials/set_up_gitlab_google_integration/_index.md#secure-your-usage-with-google-cloud-identity-and-access-management-iam) | [相关议题](https://gitlab.com/gitlab-org/gitlab/-/issues/454343)

{{< /details >}}

在为 Google Cloud IAM 集成设置工作负载身份联合时，现在可以原生使用 Google Cloud CLI 命令。以前，引导式设置使用通过 cURL 命令下载的脚本。此外，还添加了帮助文本，以更好地描述设置过程。这些改进可帮助群组所有者更快地设置 Google Cloud IAM 集成。

<a id="separate-wiki-page-title-and-path-fields"></a>

### 分离 Wiki 页面标题和路径字段

<!-- categories: Wiki -->

{{< details >}}

- 适用版本: 基础版、专业版、旗舰版
- 交付方式: JihuLab.com、私有化部署
- 链接: [文档](../../user/project/wiki/_index.md) | [相关议题](https://gitlab.com/gitlab-org/gitlab/-/issues/30758)

{{< /details >}}

在极狐GitLab 17.2 中，Wiki 页面标题与其路径分离。在以前的版本中，如果页面标题发生更改，路径也会更改，这可能导致指向该页面的链接失效。现在，如果 Wiki 页面的标题发生更改，路径保持不变。即使 Wiki 页面路径发生更改，也会设置自动重定向以防止链接失效。

<a id="improvements-to-the-wiki-sidebar"></a>

### Wiki 侧边栏的改进

<!-- categories: Wiki -->

{{< details >}}

- 适用版本: 基础版、专业版、旗舰版
- 交付方式: JihuLab.com、私有化部署
- 链接: [文档](../../user/project/wiki/_index.md) | [相关议题](https://gitlab.com/gitlab-org/gitlab/-/issues/281570)

{{< /details >}}

极狐GitLab 17.2 为 Wiki 显示侧边栏的方式添加了多项增强功能。现在，Wiki 会在侧边栏中显示所有页面（最多 5000 个页面）、显示目录（TOC），并提供搜索栏以快速查找页面。

以前，侧边栏缺少目录，使得导航到页面的各个部分变得困难。新的目录功能有助于清晰地查看页面结构，以及快速导航到不同的部分，大大提高了可用性。

搜索栏的添加使发现内容变得更加容易。而且由于侧边栏现在显示所有页面，您可以无缝浏览整个 Wiki。

<a id="document-modules-in-the-terraform-module-registry"></a>

### Terraform 模块仓库中的文档模块

<!-- categories: Package Registry -->

{{< details >}}

- 适用版本: 基础版、专业版、旗舰版
- 交付方式: JihuLab.com、私有化部署
- 链接: [文档](../../user/packages/terraform_module_registry/_index.md#view-terraform-modules) | [相关议题](https://gitlab.com/gitlab-org/gitlab/-/issues/451054)

{{< /details >}}

Terraform 模块仓库现在会显示 Readme 文件！借助这项备受期待的功能，您可以透明地记录每个模块的用途、配置和要求。

以前，您必须在其他来源中搜索这些关键信息，这使得正确评估和使用模块变得困难。现在，由于模块文档随时可用，您可以在使用模块之前快速了解其能力。这种可访问性使您能够自信地在整个组织中共享和重用 Terraform 代码。

<a id="add-type-attribute-to-issues-events-webhook"></a>

### 为议题事件 Webhook 添加 type 属性

<!-- categories: Team Planning, Notifications, Incident Management, Service Desk -->

{{< details >}}

- 适用版本: 基础版、专业版、旗舰版
- 交付方式: JihuLab.com、私有化部署
- 链接: [文档](../../user/project/integrations/webhook_events.md#work-item-events) | [相关议题](https://gitlab.com/gitlab-org/gitlab/-/issues/467415)

{{< /details >}}

议题、任务、事件、需求、目标和关键结果
都会在 **议题事件** Webhook 类别下触发负载。到目前为止，还没有办法在事件负载中快速确定触发 Webhook 的对象类型。此版本引入了 `object_attributes.type` 属性，可用于 **议题事件**、**评论**、**机密议题事件** 和 **表情事件** 触发器中的负载。

<a id="gitlab-advanced-sast-available-in-beta-for-go-java-and-python"></a>

### 极狐GitLab Advanced SAST 面向 Go、Java 和 Python 推出测试版

<!-- categories: SAST -->

{{< details >}}

- 适用版本: 旗舰版
- 交付方式: JihuLab.com、私有化部署
- 链接: [文档](../../user/application_security/sast/gitlab_advanced_sast.md)

{{< /details >}}

极狐GitLab Advanced SAST 现已作为测试版功能面向旗舰版客户提供。Advanced SAST 使用跨文件、跨函数分析来提供更高质量的结果。
它现在支持 Go、Java 和 Python。

在测试版阶段，我们建议在测试项目中运行Advanced SAST，而不是替换现有的 SAST 分析器。要启用Advanced SAST，请参阅[说明](../../user/application_security/sast/gitlab_advanced_sast.md#turn-on-gitlab-advanced-sast)。从极狐GitLab 17.2 开始，Advanced SAST 已包含在 [`SAST.latest` CI/CD 模板](https://gitlab.com/gitlab-org/gitlab/-/blob/master/lib/gitlab/ci/templates/Jobs/SAST.latest.gitlab-ci.yml)中。

这是我们迭代式[集成 Oxeye 技术](https://about.gitlab.com/blog/oxeye-joins-gitlab-to-advance-application-security-capabilities/)的一部分。在即将发布的版本中，我们计划将Advanced SAST 移至正式发布、添加对[其他语言](https://gitlab.com/groups/gitlab-org/-/epics/14312)的支持，并引入新的 UI 元素来追踪漏洞的流动方式。我们欢迎在[议题 466322](https://gitlab.com/gitlab-org/gitlab/-/issues/466322)中提供任何测试反馈。

<a id="api-security-testing-now-supports-signed-authentication-requests"></a>

### API 安全测试现在支持签名认证请求

<!-- categories: API Security -->

{{< details >}}

- 适用版本: 旗舰版
- 交付方式: JihuLab.com、私有化部署
- 链接: [文档](../../user/application_security/api_security_testing/configuration/variables.md) | [相关议题](https://gitlab.com/gitlab-org/gitlab/-/issues/458825)

{{< /details >}}

API 安全已经支持“覆盖”，它可以修改扫描器发送的请求。但是，这些覆盖必须提前设置，并且不能根据请求本身进行更改。极狐GitLab 17.2 添加了“每请求脚本”（`APISEC_PER_REQUEST_SCRIPT`），允许用户提供一个 C# 脚本，该脚本在发送每个请求之前被调用。这为使用密钥对请求进行“签名”作为一种身份验证形式提供了支持。

<a id="container-scanning-continuous-vulnerability-scanning-os-support"></a>

### 容器扫描：持续漏洞扫描操作系统支持

<!-- categories: Software Composition Analysis -->

{{< details >}}

- 适用版本: 旗舰版
- 交付方式: JihuLab.com、私有化部署
- 链接: [文档](../../user/application_security/container_scanning/continuous_container_scanning/_index.md#supported-package-types) | [相关议题](https://gitlab.com/groups/gitlab-org/-/epics/10174)

{{< /details >}}

作为容器扫描持续漏洞扫描 MVC 的后续工作，在 17.2 期间，我们添加了对 APK 和 RPM 操作系统软件包版本的支持。

此增强功能使我们的分析器能够通过比较 [APK](https://gitlab.com/gitlab-org/gitlab/-/issues/428703) 和 [RPM](https://gitlab.com/gitlab-org/gitlab/-/issues/428941) 操作系统 purl 类型的软件包版本，完全支持容器扫描公告的持续漏洞扫描。

请注意，不支持包含脱字符（`^`）的 RPM 版本。支持这些版本的工作正在此[议题](https://gitlab.com/gitlab-org/gitlab/-/issues/459969)中跟踪。

<a id="dast-analyzer-updates"></a>

### DAST 分析器更新

<!-- categories: DAST -->

{{< details >}}

- 适用版本: 旗舰版
- 交付方式: JihuLab.com、私有化部署
- 链接: [文档](../../user/application_security/dast/browser/checks/_index.md) | [相关议题](https://gitlab.com/groups/gitlab-org/-/epics/13411)

{{< /details >}}

在 17.2 发布里程碑期间，我们发布了以下更新。

1. 我们添加了三项新检查：

- 检查 506.1 是一项被动检查，用于识别可能因 Polyfill.io CDN 接管而受损的请求 URL。
- 检查 384.1 是一项被动检查，用于识别会话固定弱点，这可能允许恶意行为者重用有效的会话标识符。
- 检查 16.11 是一项主动检查，用于识别生产服务器上何时启用了 TRACE HTTP 调试方法，这可能会无意中泄露敏感信息。

1. 我们修复了以下错误以减少误报：

- 当站点通过将过期日期设置为过去来清除 cookie 时，DAST 检查 614.1（没有 Secure 属性的敏感 cookie）和 1004.1（没有 HttpOnly 属性的敏感 cookie）不再创建发现项。
- DAST 检查 1336.1（服务器端模板注入）不再依赖 500 HTTP 响应状态码来确定攻击是否成功。

1. 我们添加了以下增强功能：

- 所有响应头现在都作为证据呈现在 DAST 漏洞发现项中。这些额外的上下文减少了用于分类发现项的时间。
- 现在会抓取 Sitemap.xml 文件以获取其他 URL，从而更好地覆盖目标网站。

<a id="api-fuzz-testing-now-supports-signed-authentication-requests"></a>

### API 模糊测试现在支持签名认证请求

<!-- categories: Fuzz Testing -->

{{< details >}}

- 适用版本: 旗舰版
- 交付方式: JihuLab.com、私有化部署
- 链接: [文档](../../user/application_security/api_fuzzing/configuration/variables.md) | [相关议题](https://gitlab.com/gitlab-org/gitlab/-/issues/458825)

{{< /details >}}

API 模糊测试已经支持“覆盖”，它可以修改扫描器发送的请求。但是，这些覆盖必须提前设置，并且不能根据请求本身进行更改。极狐GitLab 17.2 添加了“每请求脚本”（`FUZZAPI_PER_REQUEST_SCRIPT`），允许用户提供一个 C# 脚本，该脚本在发送每个请求之前被调用。这为使用密钥对请求进行“签名”作为一种身份验证形式提供了支持。

<a id="secret-push-protection-now-available-for-self-managed-and-improved-warnings-of-potential-leaks"></a>

### 密钥推送保护现已面向私有化部署提供，并改进了潜在泄露的警告

<!-- categories: Secret Detection -->

{{< details >}}

- 适用版本: 旗舰版
- 交付方式: JihuLab.com、私有化部署
- 链接: [文档](../../user/application_security/secret_detection/_index.md) | [相关史诗](https://gitlab.com/groups/gitlab-org/-/epics/13107)

{{< /details >}}

在 17.2 发布里程碑期间，我们发布了以下更新：

- 密钥推送保护测试版现已面向私有化部署客户提供。在管理员[在实例范围内启用该功能](../../user/application_security/secret_detection/secret_push_protection/_index.md#allow-the-use-of-secret-push-protection-in-your-gitlab-instance)后，请按照我们的文档在您的项目上[启用推送保护](../../user/application_security/secret_detection/secret_push_protection/_index.md#enable-secret-push-protection-in-a-project)。
- [文本内容中潜在泄露的警告](../../user/application_security/secret_detection/client/_index.md)已得到丰富，包含更多细节，使您更容易理解议题、史诗或合并请求中的描述或评论中即将泄露的是哪种类型的密钥。

<a id="sort-options-for-pipeline-schedules"></a>

### 流水线计划的排序选项

<!-- categories: Continuous Integration (CI) -->

{{< details >}}

- 适用版本: 基础版、专业版、旗舰版
- 交付方式: JihuLab.com、私有化部署
- 链接: [文档](../../ci/pipelines/schedules.md) | [相关议题](https://gitlab.com/gitlab-org/gitlab/-/issues/37246)

{{< /details >}}

您现在可以按描述、ref、下次运行、创建日期和更新日期对流水线计划列表进行排序。

<a id="ruleschangescompare_to-now-supports-cicd-variables"></a>

### `rules:changes:compare_to` 现在支持 CI/CD 变量

<!-- categories: Pipeline Composition, Pipeline Composition -->

{{< details >}}

- 适用版本: 基础版、专业版、旗舰版
- 交付方式: JihuLab.com、私有化部署
- 链接: [文档](../../ci/yaml/_index.md#ruleschangescompare_to) | [相关议题](https://gitlab.com/gitlab-org/gitlab/-/issues/369916)

{{< /details >}}

在极狐GitLab 15.3 中，我们为 `rules:change` 引入了 [`compare_to` 关键字](../../ci/yaml/_index.md#ruleschangescompare_to)。这使得可以定义要比较的确切 ref。从极狐GitLab 17.2 开始，您现在可以将 CI/CD 变量与此关键字一起使用，从而更容易在多个作业中定义和重用 `compare_to` 值。

<a id="gitlab-runner-172"></a>

### 极狐GitLab Runner 17.2

<!-- categories: GitLab Runner Core -->

{{< details >}}

- 适用版本: 基础版、专业版、旗舰版
- 交付方式: 私有化部署
- 链接: [文档](https://gitlab.cn/docs/runner/)

{{< /details >}}

我们今天发布极狐GitLab Runner 17.2！极狐GitLab Runner 是轻量级、高度可扩展的代理，用于运行您的 CI/CD 作业并将结果发送回极狐GitLab 实例。极狐GitLab Runner 与极狐GitLab CI/CD 协同工作，后者是极狐GitLab 中包含的开源持续集成服务。

<a id="whats-new"></a>

#### 新增功能

- [GitLab Runner 面向 AWS EC2 实例的 fleeting 插件（正式发布）](https://gitlab.com/gitlab-org/gitlab-runner/-/issues/29222)
- [允许配置 Runner `livenessProbe` 和 `readinessProbe`](https://gitlab.com/gitlab-org/charts/gitlab-runner/-/issues/545)
- [能够为 Kubernetes 执行器启用和禁用 `umask 0000` 命令](https://gitlab.com/gitlab-org/gitlab-runner/-/issues/28867)
- [GitLab Runner Operator 支持 Red Hat OpenShift 4.16](https://gitlab.com/gitlab-org/gl-openshift/gitlab-runner-operator/-/issues/203)

<a id="bug-fixes"></a>

#### 错误修复

- [GitLab Runner 升级会移除所有缓存卷](https://gitlab.com/gitlab-org/gitlab-runner/-/issues/30876)

有关所有更改的列表，请参阅极狐GitLab Runner [CHANGELOG](https://gitlab.com/gitlab-org/gitlab-runner/blob/17-2-stable/CHANGELOG.md)。

<a id="new-agent-authorization-strategy-for-workspaces"></a>

### 工作区的新代理授权策略

<!-- categories: Workspaces -->

{{< details >}}

- 适用版本: 专业版、旗舰版
- 交付方式: JihuLab.com、私有化部署
- 链接: [文档](../../user/workspace/gitlab_agent_configuration.md)

{{< /details >}}

在此版本中，我们为工作区实施了一种新的授权策略，以解决旧策略的局限性，同时为群组所有者和管理员提供更多控制和灵活性。借助新的授权策略，群组所有者和管理员可以控制使用哪些集群代理来托管工作区。

为确保平稳过渡，使用旧授权策略的用户会自动迁移到新策略。支持工作区的现有代理会在这些代理所在的根群组中自动获得允许。即使这些代理已在根群组中的不同群组中获得允许，此迁移也会发生。
