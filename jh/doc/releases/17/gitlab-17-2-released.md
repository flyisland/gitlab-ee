---
stage: Release Notes
group: Monthly Release
date: 2024-07-18
title: "极狐GitLab 17.2 发布说明"
description: "极狐GitLab 17.2 released with Log streaming for Kubernetes pods and containers"
---

<!-- markdownlint-disable -->
<!-- vale off -->

2024 年 7 月 18 日，极狐GitLab 17.2 发布，包含以下功能。

<a id="primary-features"></a>

## 主要功能

<a id="log-streaming-for-kubernetes-pods-and-containers"></a>

### Kubernetes Pod 和容器的日志流

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: JihuLab.com
- Links: [文档](../../ci/environments/kubernetes_dashboard.md) | [关联史诗](https://jihulab.com/groups/gitlab-cn/-/epics/13793)

{{< /details >}}

在极狐GitLab 16.1 中，我们引入了 Kubernetes Pod 列表和详情视图。然而，你仍需使用第三方工具来深入分析你的工作负载。极狐GitLab 现在提供了 Pod 和容器的日志流视图，因此你可以快速检查和排查各环境中的问题，而无需离开你的应用交付工具。

<a id="gitlab-duo-disabling-input-and-output-logging-by-default"></a>

### 极狐GitLab Duo 默认禁用输入和输出日志记录

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: JihuLab.com
- Add-ons: GitLab Duo Pro, GitLab Duo Enterprise
- Links: [文档](../../user/gitlab_duo/data_usage.md#data-retention) | [关联史诗](https://jihulab.com/groups/gitlab-cn/-/epics/13401)

{{< /details >}}

极狐GitLab 现在默认禁用极狐GitLab Duo 的 AI 输入和输出日志记录。

在极狐GitLab，我们旨在确保客户对其数据拥有主权。我们现在已默认禁用输入和输出日志记录，并且仅在客户通过极狐GitLab 支持工单明确同意的情况下记录输入和输出。

<a id="block-a-merge-request-by-requesting-changes"></a>

### 通过请求更改来阻止合并请求

{{< details >}}

- Tier: 专业版，旗舰版
- Offering: JihuLab.com
- Links: [文档](../../user/project/merge_requests/reviews/_index.md#prevent-merge-when-you-request-changes)

{{< /details >}}

当你执行审查时，你可以通过选择 `批准`、`评论` 或 `请求更改`（[在极狐GitLab 16.9 中发布](https://gitlab.cn/releases/2024/02/15/gitlab-16-9-released/#request-changes-on-merge-requests)）来完成审查。在审查过程中，你可能会发现一些更改应阻止合并请求合并，直到它们被解决，因此你以 `请求更改` 完成审查。

当请求更改时，极狐GitLab 现在会添加一个合并检查，阻止合并，直到更改请求被解决。更改请求可以在最初请求更改的用户重新审查合并请求并随后批准合并请求时解决。如果最初请求更改的用户无法批准，任何具有合并权限的人都可以**绕过**更改请求，以便开发继续。

<a id="vulnerability-explanation"></a>

### 漏洞解释

{{< details >}}

- Tier: 旗舰版
- Offering: JihuLab.com
- Add-ons: Duo Enterprise
- Links: [文档](../../user/application_security/analyze/duo.md) | [关联史诗](https://jihulab.com/groups/gitlab-cn/-/epics/10642)

{{< /details >}}

漏洞解释现在是极狐GitLab Duo Chat 的一部分，并已正式可用。通过漏洞解释，你可以从任何 SAST 漏洞打开聊天，以更好地了解漏洞，查看如何利用它，并审查潜在的修复方案。

<a id="oauth-2-0-device-authorization-grant-support"></a>

### OAuth 2.0 设备授权授予支持

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: JihuLab.com
- Links: [文档](../../api/oauth2.md#device-authorization-grant-flow) | [关联议题](https://jihulab.com/gitlab-cn/gitlab/-/issues/332682)

{{< /details >}}

极狐GitLab 现在支持 [OAuth 2.0 设备授权授予流程](https://datatracker.ietf.org/doc/html/rfc8628)。该流程使得从输入受限的设备（无法进行浏览器交互）安全地认证你的极狐GitLab 身份成为可能。这使得设备授权授予流程非常适合试图从无头服务器或其他没有或仅有有限 UI 的设备使用极狐GitLab 服务的用户。感谢 [John Parent](https://kitware.com/) 的贡献！

<a id="pipeline-execution-policy-type"></a>

### 流水线执行策略类型

{{< details >}}

- Tier: 旗舰版
- Offering: JihuLab.com
- Links: [文档](../../user/application_security/policies/pipeline_execution_policies.md) | [关联史诗](https://jihulab.com/groups/gitlab-cn/-/epics/13266)

{{< /details >}}

流水线执行策略类型是一种新型[安全策略](../../user/application_security/policies/_index.md)，允许用户支持强制执行通用 CI 作业、脚本和指令。

流水线执行策略类型使安全和合规团队能够强制执行自定义的[极狐GitLab 安全扫描模板](https://jihulab.com/gitlab-cn/gitlab/-/tree/master/lib/gitlab/ci/templates/Jobs)、[极狐GitLab 或合作伙伴支持的 CI 模板](https://jihulab.com/gitlab-cn/gitlab/-/tree/master/lib/gitlab/ci/templates)、第三方安全扫描模板、通过 CI 作业自定义报告规则，或通过极狐GitLab CI 自定义脚本/规则。

流水线执行策略有两种模式：注入和覆盖。*注入* 模式将作业注入到项目的 CI/CD 流水线中。*覆盖* 模式替换项目的 CI/CD 流水线配置。

与所有极狐GitLab 策略一样，强制执行可以由指定的安全和合规团队成员集中管理，他们创建和管理策略。[立即了解如何通过创建你的首个流水线执行策略开始使用](../../user/application_security/policies/pipeline_execution_policies.md)！

<a id="expanded-support-of-custom-rulesets-in-pipeline-secret-detection"></a>

### 流水线密钥检测中自定义规则集的扩展支持

{{< details >}}

- Tier: 旗舰版
- Offering: JihuLab.com
- Links: [文档](../../user/application_security/secret_detection/pipeline/configure.md#customize-analyzer-rulesets) | [关联议题](https://jihulab.com/gitlab-cn/gitlab/-/issues/336395)

{{< /details >}}

我们已扩展了流水线密钥检测中自定义规则集的支持。

你可以使用两种新类型的直通，`git` 和 `url`，来配置远程规则集。这使得管理诸如跨多个项目共享规则集配置的工作流变得更加容易。

你还可以使用其中一种新型直通通过远程规则集来扩展默认配置。

分析器现在还支持：

- 将最多 20 个直通链接成一个配置以替换预定义规则。
- 在直通中包含环境变量。
- 在加载直通时设置超时。
- 验证规则集配置中的 TOML 语法。

<a id="gitlab-duo-chat-and-code-suggestions-available-in-workspaces"></a>

### 工作空间中的极狐GitLab Duo Chat 和代码建议

{{< details >}}

- Tier: 专业版，旗舰版
- Offering: JihuLab.com
- Add-ons: Duo Pro, Duo Enterprise
- Links: [文档](../../user/gitlab_duo/_index.md)

{{< /details >}}

[极狐GitLab Duo Chat](../../user/gitlab_duo_chat/_index.md) 和 [代码建议](../../user/project/repository/code_suggestions/_index.md) 现在在工作空间中可用！无论你是寻求快速答案还是高效代码改进，Duo Chat 和代码建议都旨在提高生产力并简化工作流，使工作空间中的远程开发比以往更高效和有效。

<a id="scale-and-deployments"></a>

## 规模化与部署

<a id="improved-sorting-and-filtering-in-group-overview"></a>

### 改进的群组概览排序和筛选

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: JihuLab.com
- Links: [文档](../../user/group/_index.md#view-a-group) | [关联议题](https://jihulab.com/gitlab-cn/gitlab/-/issues/437013)

{{< /details >}}

我们更新了群组概览页面的排序和筛选功能。搜索元素现在横跨整个页面，让你可以更好地查看你的搜索字符串。我们标准化了排序选项为 `名称`、`创建日期`、`更新日期` 和 `星数`。

<a id="list-groups-that-a-group-was-invited-to-using-the-groups-api"></a>

### 使用群组 API 列出群组被邀请加入的群组

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: JihuLab.com
- Links: [文档](../../api/groups.md#list-shared-groups) | [关联议题](https://jihulab.com/gitlab-cn/gitlab/-/issues/424959)

{{< /details >}}

我们向群组 API 添加了一个新端点，用于列出一个群组被邀请加入的群组。此功能补充了[列出群组被邀请加入的项目的端点](../../api/groups.md#list-shared-projects)，因此你现在可以全面了解你的群组被添加到的所有群组和项目。该端点限制为每个用户每分钟 60 个请求。

感谢 [@imskr](https://gitlab.com/imskr) 的社区贡献！

<a id="resolve-to-do-items-one-discussion-at-a-time"></a>

### 一次解决一个讨论的待办事项

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: JihuLab.com
- Links: [文档](../../user/todos.md) | [关联议题](https://jihulab.com/gitlab-cn/gitlab/-/issues/461111)

{{< /details >}}

极狐GitLab 议题上的讨论可能会很繁忙。极狐GitLab 通过为与你相关的评论生成待办事项，并在你对议题采取操作时自动解决该事项，帮助你管理这些对话。以前，当你对议题中的一个主题讨论采取操作时，所有待办事项都会被解决，即使你在多个不同的主题讨论中被提及。现在，极狐GitLab 只解决你与之互动的主题讨论的待办事项。

<a id="indicate-imported-items-in-ui"></a>

### 在 UI 中指示导入的项

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: JihuLab.com
- Links: [文档](../../user/import/_index.md) | [关联史诗](https://jihulab.com/groups/gitlab-cn/-/epics/13825)

{{< /details >}}

你可以从[其他 SCM 解决方案](../../user/import/_index.md) 将项目导入到极狐GitLab。然而，很难知道项目项是导入的还是在极狐GitLab 实例上创建的。在此版本中，我们为从 GitHub、Gitea、Bitbucket Server 和 Bitbucket Cloud 导入的项添加了可视化指示器，其中创建者被标识为特定用户。例如，合并请求、议题和评论。

<a id="deleted-branches-are-removed-from-jira-development-panel"></a>

### 删除的分支将从 Jira 开发面板中移除

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: JihuLab.com
- Links: [文档](../../integration/jira/development_panel.md#feature-availability) | [关联议题](https://jihulab.com/gitlab-cn/gitlab/-/issues/351625)

{{< /details >}}

以前，当你使用[适用于 Jira Cloud 的极狐GitLab 应用](../../integration/jira/connect-app.md) 时，如果你在极狐GitLab 中删除了一个分支，该分支仍然显示在 Jira 开发面板中。选择该分支会导致极狐GitLab 上出现 `404` 错误。从此版本开始，在极狐GitLab 中删除的分支会从 Jira 开发面板中移除。

<a id="find-project-settings-by-using-the-command-palette"></a>

### 使用命令面板查找项目设置

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: JihuLab.com
- Links: [文档](../../user/search/command_palette.md) | [关联议题](https://jihulab.com/gitlab-cn/gitlab/-/issues/448637)

{{< /details >}}

极狐GitLab 在项目、群组、实例以及个人层面提供了许多设置。为了找到你正在寻找的设置，你通常需要花费时间在 UI 的许多不同区域中点击。在此版本中，你现在可以从命令面板搜索项目设置。尝试通过访问项目，选择 **搜索或跳转到...**，输入 `>` 进入命令模式，然后键入设置部分的名称，如 **受保护的标签**。选择一个结果即可直接跳转到该设置本身。

<a id="unified-devops-and-security"></a>

## 统一 DevOps 与安全

<a id="merge-commit-message-generation-now-ga"></a>

### 合并提交消息生成现已正式可用

{{< details >}}

- Tier: 旗舰版
- Add-ons: Duo Enterprise
- Links: [文档](../../user/project/merge_requests/duo_in_merge_requests.md#generate-a-merge-commit-message)

{{< /details >}}

编写提交消息是确保未来用户了解代码库进行了哪些更改以及为何更改的重要部分。构建一条能有效传达你的更改并涵盖你可能更改的所有内容的消息颇具挑战性。使用极狐GitLab Duo 生成合并提交消息现在已正式可用，以帮助确保每个合并请求都有高质量的提交消息。在合并之前，在合并部件中选择 **编辑提交消息**，然后使用 **生成提交消息** 选项来起草提交消息。这个新的极狐GitLab Duo 功能是确保项目提交历史成为未来开发者宝贵资源的绝佳方式。

<a id="gitlab-duo-for-the-cli-now-ga"></a>

### 极狐GitLab Duo for CLI 现已正式可用

{{< details >}}

- Tier: 旗舰版
- Add-ons: Duo Enterprise
- Links: [文档](https://gitlab.cn/docs/cli/)

{{< /details >}}

极狐GitLab Duo for CLI 现已对所有用户正式可用。现在你可以使用 `glab duo ask <git question>` 向极狐GitLab Duo 询问，以帮助你找到适合需求的 `git` 命令。极狐GitLab CLI 随后会提供有关命令及其作用的附加详细信息，包括有关所传递标志的信息。然后你可以直接在 workflow 中运行命令并获取输出。`ask` 命令是一个绝佳方式，可加快你使用可能需要额外帮助才能记住的 `git` 命令的工作流程。

<a id="pure-ssh-transfer-protocol-for-lfs"></a>

### 用于 LFS 的纯 SSH 传输协议

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: JihuLab.com
- Links: [文档](../../administration/lfs/_index.md#pure-ssh-transfer-protocol) | [关联史诗](https://jihulab.com/groups/gitlab-cn/-/epics/11872)

{{< /details >}}

早在 2021 年 9 月，[`git-lfs` 3.0.0](https://github.com/git-lfs/git-lfs/blob/main/CHANGELOG.md#300-24-sep-2021) 发布了使用 SSH 作为传输协议（而不是 HTTP）的支持。在 `git-lfs` 3.0.0 之前，HTTP 是唯一受支持的传输协议，这意味着对于一些用户来说，在极狐GitLab 上使用 `git-lfs` 是不可能的。在此版本中，我们非常兴奋地提供启用 SSH over HTTP 作为 `git-lfs` 传输协议的能力。

感谢 [Kyle Edwards](https://gitlab.com/KyleFromKitware) 和 [Joe Snyder](https://gitlab.com/joe-snyder) 的贡献！

<a id="deployments-and-approvals-to-protected-environments-trigger-an-audit-event"></a>

### 部署和审批受保护环境触发审计事件

{{< details >}}

- Tier: 专业版，旗舰版
- Offering: JihuLab.com
- Links: [文档](../../user/compliance/audit_event_types.md#continuous-delivery) | [关联议题](https://jihulab.com/gitlab-cn/gitlab/-/issues/456687)

{{< /details >}}

可访问的部署事件记录（如部署审批）对于合规管理至关重要。在此之前，极狐GitLab 不提供与部署相关的审计事件，因此合规管理员必须使用自定义工具或直接在极狐GitLab 中搜索这些数据。极狐GitLab 现在提供三个审计事件：

- `deployment_started` 记录谁启动了部署作业，以及何时启动。
- `deployment_approved` 记录谁批准了部署作业，以及何时批准。
- `deployment_rejected` 记录谁拒绝了部署作业，以及何时拒绝。

<a id="assigning-frameworks-at-subgroup-compliance-center"></a>

### 在子群组合规中心分配框架

{{< details >}}

- Tier: 旗舰版，专业版
- Offering: JihuLab.com
- Links: [文档](../../user/compliance/compliance_center/compliance_projects_report.md) | [关联史诗](https://jihulab.com/gitlab-cn/gitlab/-/issues/469004)

{{< /details >}}

合规中心是合规团队管理其合规标准遵从性报告、违规报告以及其群组的合规框架的中心位置。以前，合规中心的所有关联功能仅适用于顶级群组。这意味着对于子群组，所有者无法访问顶级群组上合规中心提供的任何功能。为了帮助解决这些关键痛点，我们增加了为子群组分配和取消分配合规框架的功能。现在，群组所有者可以在子群组级别以及现有的完整顶级群组合规中心仪表板上，可视化其合规状况。

<a id="expand-scan-execution-policies-to-run-latest-templates-for-each-gitlab-analyzer"></a>

### 扩展 “扫描执行策略”以运行每个极狐GitLab 分析器的 `latest` 模板

{{< details >}}

- Tier: 旗舰版
- Offering: JihuLab.com
- Links: [文档](../../user/application_security/policies/scan_execution_policies.md) | [关联议题](https://jihulab.com/gitlab-cn/gitlab/-/issues/415427)

{{< /details >}}

[扫描执行策略](../../user/application_security/policies/scan_execution_policies.md) 已扩展，允许你在定义策略规则时在 `default` 和 `latest` 极狐GitLab 模板之间进行选择。`default` 反映了当前行为，而你可以将策略更新为 `latest`，以使用仅在给定安全分析器的最新模板中可用的功能。通过利用 `latest` 模板，你现在可以确保扫描在合并请求流水线上强制执行，以及 `latest` 模板中启用的任何其他规则。以前，这仅限于分支流水线或指定的计划。

注意：在修改策略之前，请务必查看 `default` 和 `latest` 模板之间的所有更改，以确保这符合你的需求！

<a id="identify-dates-when-multiple-access-tokens-expire"></a>

### 识别多个访问令牌过期日期

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Links: [文档](../../security/tokens/_index.md) | [关联议题](https://jihulab.com/gitlab-cn/gitlab/-/issues/467313)

{{< /details >}}

管理员现在可以运行一个脚本，识别多个访问令牌过期的日期。你可以将此脚本与[令牌问题排查页面](../../security/tokens/token_troubleshooting.md) 上的其他脚本结合使用，以识别并延长可能即将到期的大量令牌，如果尚未实施令牌轮换。

<a id="oauth-authorization-screen-improvements"></a>

### OAuth 授权屏幕改进

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: JihuLab.com
- Links: [文档](../../integration/oauth_provider.md) | [关联议题](https://jihulab.com/gitlab-cn/gitlab/-/issues/462655)

{{< /details >}}

OAuth 授权屏幕现在更清晰地描述了你正在授予的授权。对于由极狐GitLab 提供的应用程序，它还包含一个 “由极狐GitLab 验证” 的部分。以前，无论应用程序是否由极狐GitLab 提供，用户体验都是相同的。这项新功能提供了额外的信任层。

<a id="streamlined-instance-administrator-setup"></a>

### 简化的实例管理员设置

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Links: [文档](../../administration/_index.md) | [关联议题](https://jihulab.com/gitlab-cn/gitlab/-/issues/458985)

{{< /details >}}

极狐GitLab 新安装的管理员设置体验已得到简化并变得更加安全。初始管理员 root 电子邮件地址现在是随机的，管理员被强制将此电子邮件地址更改为他们可以访问的帐户。以前，此步骤可能被延迟，管理员可能忘记更改电子邮件地址。

<a id="user-api-added-to-the-snowflake-data-connector"></a>

### 用户 API 添加到 Snowflake 数据连接器

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Links: [文档](../../integration/snowflake.md) | [关联史诗](https://jihulab.com/groups/gitlab-cn/-/epics/13004)

{{< /details >}}

在极狐GitLab 17.2 中，我们向 [极狐GitLab 数据连接器](https://app.snowflake.com/marketplace/listing/GZTYZXESENG/gitlab-gitlab-data-connector)（在 Snowflake Marketplace 应用程序中提供）添加了对 [用户 API](../../api/users.md#list-all-users) 的支持。你现在可以使用用户 API 将用户数据从私有化部署的极狐GitLab 实例流式传输到 Snowflake。

<a id="simplified-setup-for-google-cloud-integration"></a>

### 简化的 Google Cloud 集成设置

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: JihuLab.com
- Links: [文档](../../tutorials/set_up_gitlab_google_integration/_index.md#secure-your-usage-with-google-cloud-identity-and-access-management-iam) | [关联议题](https://jihulab.com/gitlab-cn/gitlab/-/issues/454343)

{{< /details >}}

在为 Google Cloud IAM 集成设置工作负载身份联合时，Google Cloud CLI 命令现在是原生可用的。以前，引导设置使用通过 cURL 命令下载的脚本。此外，还添加了帮助文本以更好地描述设置过程。这些改进有助于群组所有者更快地设置 Google Cloud IAM 集成。

<a id="separate-wiki-page-title-and-path-fields"></a>

### 分离 wiki 页面标题和路径字段

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: JihuLab.com
- Links: [文档](../../user/project/wiki/_index.md) | [关联议题](https://jihulab.com/gitlab-cn/gitlab/-/issues/30758)

{{< /details >}}

在极狐GitLab 17.2 中，wiki 页面标题与其路径分离。在以前的版本中，如果页面标题更改，路径也会更改，这可能导致指向该页面的链接断开。现在，如果 wiki 页面的标题更改，路径保持不变。即使 wiki 页面路径更改，也会设置自动重定向以防止链接断开。

<a id="improvements-to-the-wiki-sidebar"></a>

### wiki 侧边栏改进

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: JihuLab.com
- Links: [文档](../../user/project/wiki/_index.md) | [关联议题](https://jihulab.com/gitlab-cn/gitlab/-/issues/281570)

{{< /details >}}

极狐GitLab 17.2 为 wiki 显示侧边栏的方式添加了多项增强功能。现在，wiki 在侧边栏中显示所有页面（最多 5000 页），显示目录（TOC），并提供一个搜索栏以快速查找页面。

以前，侧边栏缺少目录，使得导航到页面的各个部分颇具挑战性。新的目录功能有助于清晰地查看页面结构，并快速导航到不同的部分，极大地提高了可用性。搜索栏的添加使发现内容更加容易。而且由于侧边栏现在显示所有页面，你可以无缝浏览整个 wiki。

<a id="document-modules-in-the-terraform-module-registry"></a>

### 在 Terraform 模块仓库中记录模块文档

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: JihuLab.com
- Links: [文档](../../user/packages/terraform_module_registry/_index.md#view-terraform-modules) | [关联议题](https://jihulab.com/gitlab-cn/gitlab/-/issues/451054)

{{< /details >}}

Terraform 模块仓库现在显示 Readme 文件！有了这个备受期待的功能，你可以透明地记录每个模块的目的、配置和要求。
<a id="previously-you-had-to-search-other-sources"></a>

### 此前，你需要从其他来源搜索这些关键信息

此前，你需要从其他来源搜索这些关键信息，导致很难恰当地评估和使用模块。现在，随着模块文档的随时可用，你可以在使用模块之前快速了解其功能。这种便利性使你可以自信地在整个组织内共享和重用 Terraform 代码。

<a id="add-type-attribute-to-issues-events-webhook"></a>

### 为议题事件 webhook 添加类型属性

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: JihuLab.com
- Links: [文档](../../user/project/integrations/webhook_events.md#work-item-events)

{{< /details >}}

议题、任务、事件、需求、目标和关键结果都会在 **议题事件** webhook 类别下触发有效载荷。到目前为止，还没有办法在事件有效载荷中快速确定触发 webhook 的对象类型。本次发布在 **议题事件**、**评论**、**机密议题事件** 和 **表情事件** 触发器的有效载荷中引入了 `object_attributes.type` 属性。

<a id="gitlab-advanced-sast-available-in-beta-for-go-java-and-python"></a>

### 极狐GitLab Advanced SAST 面向 Go、Java 和 Python 的 Beta 版可用

{{< details >}}

- Tier: 旗舰版
- Offering: JihuLab.com
- Links: [文档](../../user/application_security/sast/gitlab_advanced_sast.md)

{{< /details >}}

极狐GitLab Advanced SAST 现已作为 Beta 功能面向旗舰版客户提供。
Advanced SAST 采用跨文件、跨函数分析，提供更高质量的结果。
现已支持 Go、Java 和 Python。

在 Beta 阶段，我们建议在测试项目中使用 Advanced SAST，而不是替换现有的 SAST 分析器。
要启用 Advanced SAST，请参阅[说明](../../user/application_security/sast/gitlab_advanced_sast.md#turn-on-gitlab-advanced-sast)。
从极狐GitLab 17.2 开始，Advanced SAST 包含在 [`SAST.latest` CI/CD 模板](https://jihulab.com/gitlab-cn/gitlab/-/blob/master/lib/gitlab/ci/templates/Jobs/SAST.latest.gitlab-ci.yml)中。

这是我们迭代[集成 Oxeye 技术](https://gitlab.cn/blog/oxeye-joins-gitlab-to-advance-application-security-capabilities/)的一部分。
在即将发布的版本中，我们计划将 Advanced SAST 推向正式版（GA），增加对[其他语言](https://jihulab.com/groups/gitlab-cn/-/epics/14312)的支持，并引入新的界面元素来追踪漏洞的传播路径。

<a id="api-security-testing-now-supports-signed-authentication-requests"></a>

### API 安全测试现已支持签名认证请求

{{< details >}}

- Tier: 旗舰版
- Offering: JihuLab.com
- Links: [文档](../../user/application_security/api_security_testing/configuration/variables.md)

{{< /details >}}

API 安全测试已经支持“覆盖”，可以修改扫描器发送的请求。但是这些覆盖必须提前设置，不能根据请求本身进行更改。极狐GitLab 17.2 新增了一个“逐请求脚本”（`APISEC_PER_REQUEST_SCRIPT`），允许用户提供一个 C# 脚本，该脚本在每次发送请求之前调用。这提供了对使用密钥对请求进行“签名”作为认证形式的支持。

<a id="container-scanning-continuous-vulnerability-scanning-os-support"></a>

### 容器扫描：持续漏洞扫描操作系统支持

{{< details >}}

- Tier: 旗舰版
- Offering: JihuLab.com
- Links: [文档](../../user/application_security/container_scanning/continuous_container_scanning/_index.md#supported-package-types)

{{< /details >}}

作为对容器扫描持续漏洞扫描 MVC 的跟进，在 17.2 中我们添加了对 APK 和 RPM 操作系统软件包版本的支持。

此增强功能使我们的分析器能够通过比较 APK 和 RPM 操作系统 purl 类型的软件包版本，完全支持容器扫描的持续漏洞扫描公告。

需要说明的是，包含 `^` 的 RPM 版本不受支持。

<a id="dast-analyzer-updates"></a>

### DAST 分析器更新

{{< details >}}

- Tier: 旗舰版
- Offering: JihuLab.com
- Links: [文档](../../user/application_security/dast/browser/checks/_index.md)

{{< /details >}}

在 17.2 发布里程碑期间，我们发布了以下更新。

1. 我们新增了三个检查项：
   - 检查 506.1 是一个被动检查，可识别可能已被 Polyfill.io CDN 接管的请求 URL。
   - 检查 384.1 是一个被动检查，可识别会话固定弱点，该弱点可能允许恶意行为者重用有效的会话标识符。
   - 检查 16.11 是一个主动检查，可识别生产服务器上启用了 TRACE HTTP 调试方法的情况，这可能会不经意地暴露敏感信息。

2. 我们解决了以下错误以减少误报：
   - DAST 检查 614.1（未设置 Secure 属性的敏感 Cookie）和 1004.1（未设置 HttpOnly 属性的敏感 Cookie）在站点通过设置过去的过期时间来清除 Cookie 时不再生成发现项。
   - DAST 检查 1336.1（服务器端模板注入）不再依赖 500 HTTP 响应状态码来确定攻击是否成功。

3. 我们添加了以下增强功能：
   - 所有响应标头现在都会作为证据呈现在 DAST 漏洞发现中。此额外上下文可减少对发现项进行分类所花费的时间。
   - 现在会抓取 Sitemap.xml 文件以获取更多 URL，从而更好地覆盖目标网站。

<a id="api-fuzz-testing-now-supports-signed-authentication-requests"></a>

### API 模糊测试现已支持签名认证请求

{{< details >}}

- Tier: 旗舰版
- Offering: JihuLab.com
- Links: [文档](../../user/application_security/api_fuzzing/configuration/variables.md)

{{< /details >}}

API 模糊测试已经支持“覆盖”，可以修改扫描器发送的请求。但是这些覆盖必须提前设置，不能根据请求本身进行更改。极狐GitLab 17.2 新增了一个“逐请求脚本”（`FUZZAPI_PER_REQUEST_SCRIPT`），允许用户提供一个 C# 脚本，该脚本在每次发送请求之前调用。这提供了对使用密钥对请求进行“签名”作为认证形式的支持。

<a id="secret-push-protection-now-available-for-self-managed-and-improved-warnings-of-potential-leaks"></a>

### 密钥推送保护现已可用于私有化部署，并改进了潜在泄露的警告

{{< details >}}

- Tier: 旗舰版
- Offering: JihuLab.com
- Links: [文档](../../user/application_security/secret_detection/_index.md)

{{< /details >}}

在 17.2 发布里程碑期间，我们发布了以下更新：

- 密钥推送保护 Beta 版现已可用于私有化部署客户。管理员在[实例范围内启用此功能](../../user/application_security/secret_detection/secret_push_protection/_index.md#allow-the-use-of-secret-push-protection-in-your-gitlab-instance)后，请按照我们的文档在项目上[启用推送保护](../../user/application_security/secret_detection/secret_push_protection/_index.md#enable-secret-push-protection-in-a-project)。
- [文本内容中潜在泄露的警告](../../user/application_security/secret_detection/client/_index.md)已包含更多详细信息，便于了解在议题、史诗或 MR 的描述或评论中即将泄露的密钥类型。

<a id="sort-options-for-pipeline-schedules"></a>

### 流水线计划排序选项

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: JihuLab.com
- Links: [文档](../../ci/pipelines/schedules.md)

{{< /details >}}

你现在可以按描述、引用、下次运行时间、创建日期和更新日期对流水线计划列表进行排序。

<a id="ruleschangescompare_to-now-supports-cicd-variables"></a>

### `rules:changes:compare_to` 现支持 CI/CD 变量

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: JihuLab.com
- Links: [文档](../../ci/yaml/_index.md#ruleschangescompare_to)

{{< /details >}}

在极狐GitLab 15.3 中，我们为 `rules:change` 引入了 [`compare_to` 关键词](../../ci/yaml/_index.md#ruleschangescompare_to)。这使得可以定义要比较的确切引用。从极狐GitLab 17.2 开始，你可以将 CI/CD 变量与此关键词配合使用，从而更轻松地在多个作业中定义和重用 `compare_to` 值。

<a id="gitlab-runner-172"></a>

### GitLab Runner 17.2

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Links: [文档](https://gitlab.cn/docs/runner)

{{< /details >}}

我们今天发布了 GitLab Runner 17.2！GitLab Runner 是一个轻量级、高扩展性的代理，用于运行你的 CI/CD 作业并将结果发送回极狐GitLab 实例。GitLab Runner 与极狐GitLab CI/CD 协同工作，后者是极狐GitLab 中包含的开源持续集成服务。

所有变更的完整列表，请参阅 GitLab Runner [CHANGELOG](https://jihulab.com/gitlab-cn/gitlab-runner/blob/17-2-stable/CHANGELOG.md)。

<a id="new-agent-authorization-strategy-for-workspaces"></a>

### 工作空间的新代理授权策略

{{< details >}}

- Tier: 专业版，旗舰版
- Offering: JihuLab.com
- Links: [文档](../../user/workspace/gitlab_agent_configuration.md)

{{< /details >}}

在此版本中，我们为工作空间实施了一种新的授权策略，以解决旧策略的局限性，同时为群组所有者和管理员提供更多控制和灵活性。通过新的授权策略，群组所有者和管理员可以控制使用哪些集群代理来托管工作空间。

为确保平稳过渡，采用旧授权策略的用户将自动迁移到新策略。支持工作空间的现有代理会自动在其所在的根群组中允许。即使这些代理已在根群组的不同群组中被允许，此迁移也会发生。