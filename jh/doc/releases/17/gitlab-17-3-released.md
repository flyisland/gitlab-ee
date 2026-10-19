---
stage: Release Notes
group: Monthly Release
date: 2024-08-15
title: "极狐GitLab 17.3 发布说明"
description: "极狐GitLab 17.3 发布，支持通过根因分析排查失败作业"
---

<!-- markdownlint-disable -->
<!-- vale off -->

2024 年 8 月 15 日，极狐GitLab 17.3 正式发布，带来了以下功能。

<a id="primary-features"></a>

## 主要功能

<a id="troubleshoot-failed-jobs-with-root-cause-analysis"></a>

### 通过根因分析排查失败作业

<!-- categories: Continuous Integration (CI) -->

{{< details >}}

- 适用版本: 旗舰版
- 交付方式: JihuLab.com、私有化部署
- 附加组件: Duo Enterprise
- 链接: [文档](../../user/gitlab_duo_chat/examples.md#troubleshoot-failed-cicd-jobs-with-root-cause-analysis) | [相关史诗](https://gitlab.com/groups/gitlab-org/-/epics/13080)

{{< /details >}}

根因分析现已正式发布。借助根因分析，您可以更快地排查 CI/CD 流水线中失败的作业。这项 AI 驱动的功能会分析失败的作业日志，快速确定作业失败的根本原因，并为您建议修复方案。

<a id="health-check-for-gitlab-duo-in-beta"></a>

### 极狐GitLab Duo 健康检查（测试版）

<!-- categories: Duo Chat -->

{{< details >}}

- 适用版本: 专业版、旗舰版
- 交付方式: 私有化部署
- 附加组件: Duo Pro, Duo Enterprise
- 链接: [文档](../../administration/gitlab_duo/configure/_index.md#run-a-health-check-for-gitlab-duo) | [相关议题](https://gitlab.com/groups/gitlab-org/-/epics/14518)

{{< /details >}}

现在，您可以在私有化部署实例上排查极狐GitLab Duo 的设置问题。在**管理**区域的极狐GitLab Duo 页面上，选择 **运行健康检查**。此健康检查会执行一系列验证，并建议适当的纠正措施，以确保极狐GitLab Duo 正常运行。

极狐GitLab Duo 健康检查在私有化部署上作为测试版功能提供。

<a id="delete-a-pod-from-the-gitlab-ui"></a>

### 从极狐GitLab UI 中删除 pod

<!-- categories: Deployment Management -->

{{< details >}}

- 适用版本: 基础版、专业版、旗舰版
- 交付方式: JihuLab.com、私有化部署
- 链接: [文档](../../ci/environments/kubernetes_dashboard.md#delete-a-pod) | [相关议题](https://gitlab.com/gitlab-org/gitlab/-/issues/467653)

{{< /details >}}

您是否曾经需要重启或删除 Kubernetes 中失败的 pod？在此之前，您必须离开极狐GitLab，使用其他工具连接到集群，停止 pod，然后等待新 pod 启动。极狐GitLab 现在内置了删除 pod 的支持，因此您可以顺畅地排查 Kubernetes 集群问题。

您可以从 [Kubernetes 仪表板](../../ci/environments/kubernetes_dashboard.md)中停止 pod，该仪表板会列出集群或命名空间中的所有 pod。

<a id="easily-connect-to-a-cluster-from-your-local-terminal"></a>

### 从本地终端轻松连接到集群

<!-- categories: Deployment Management -->

{{< details >}}

- 适用版本: 基础版、专业版、旗舰版
- 交付方式: JihuLab.com、私有化部署
- 链接: [文档](../../user/clusters/agent/user_access.md) | [相关议题](https://gitlab.com/gitlab-org/gitlab/-/issues/463769)

{{< /details >}}

您想从本地终端或使用某个桌面 Kubernetes GUI 工具连接到 Kubernetes 集群吗？
极狐GitLab 允许您使用[极狐GitLab Kubernetes Agent 的用户访问功能](../../user/clusters/agent/user_access.md)连接到终端。
此前，要找到相关命令，需要离开极狐GitLab 去浏览文档。现在，极狐GitLab 在 UI 中提供了连接命令。极狐GitLab 甚至可以帮助您配置用户访问权限！

要获取连接命令，请前往 [Kubernetes 仪表板](../../ci/environments/kubernetes_dashboard.md)，或前往 [Agent 列表](../../user/clusters/agent/work_with_agent.md#view-your-agents)。

<a id="resolve-a-vulnerability-with-ai"></a>

### 使用 AI 解决漏洞

<!-- categories: Vulnerability Management -->

{{< details >}}

- 适用版本: 旗舰版
- 交付方式: JihuLab.com、私有化部署
- 附加组件: Duo Enterprise
- 链接: [文档](../../user/application_security/vulnerabilities/_index.md#vulnerability-resolution) | [相关史诗](https://gitlab.com/groups/gitlab-org/-/epics/10783)

{{< /details >}}

漏洞解决功能使用 AI 提供具体的代码建议，帮助用户修复漏洞。只需点击按钮，您就可以打开一个合并请求，开始解决[受支持的 CWE 标识符列表](../../user/application_security/vulnerabilities/_index.md#supported-vulnerabilities-for-vulnerability-resolution)中的任何 SAST 漏洞。

<a id="add-multiple-compliance-frameworks-to-a-single-project"></a>

### 为单个项目添加多个合规框架

<!-- categories: Compliance Management -->

{{< details >}}

- 适用版本: 专业版、旗舰版
- 交付方式: JihuLab.com、私有化部署
- 链接: [文档](../../user/project/working_with_projects.md#add-a-compliance-framework-to-a-project) | [相关史诗](https://gitlab.com/groups/gitlab-org/-/epics/13294)

{{< /details >}}

您可以创建合规框架，以表明您的项目具有特定的合规要求或需要额外的监督。合规框架可以选择性地对应用它的项目强制执行合规流水线配置。

此前，用户只能为一个项目应用一个合规框架，这限制了可以在项目上设置的合规要求数量。现在，我们提供了让用户为每个项目应用多个合规框架的能力。这将允许用户在同一时间为单个项目应用多个不同的合规框架。在此版本中，您可以为项目应用多个合规框架。随后，项目会被设置每个框架的合规要求。

<a id="ai-impact-analytics-code-suggestions-acceptance-rate-and-gitlab-duo-seats-usage"></a>

### AI 影响分析：代码建议接受率和极狐GitLab Duo 席位使用情况

<!-- categories: Value Stream Management, Code Suggestions -->

{{< details >}}

- 适用版本: 旗舰版
- 交付方式: JihuLab.com、私有化部署
- 附加组件: Duo Enterprise
- 链接: [文档](../../user/analytics/value_streams_dashboard.md#dashboard-metrics-and-drill-down-reports) | [相关议题](https://gitlab.com/gitlab-org/gitlab/-/issues/471168)

{{< /details >}}

这两项新指标突显了极狐GitLab Duo 的有效性和使用情况，现已纳入[价值流仪表板中的 AI 影响分析](https://about.gitlab.com/blog/developing-gitlab-duo-ai-impact-analytics-dashboard-measures-the-roi-of-ai/)，可帮助组织了解极狐GitLab Duo 对交付业务价值的影响。

**代码建议接受率**指标表示开发者接受极狐GitLab Duo 提供的代码建议的频率。该指标既反映了这些建议的有效性，也反映了贡献者对 AI 能力的信任程度。具体而言，该指标表示过去 30 天内代码贡献者接受的极狐GitLab Duo 提供的代码建议的百分比。

**极狐GitLab Duo 席位分配和使用情况**指标显示已消耗的许可席位的百分比，帮助组织有效地规划许可使用、资源分配并了解使用模式。该指标跟踪过去 30 天内至少使用过一项 AI 功能的已分配席位的比例。

在新增这些指标的同时，我们还引入了新的概览磁贴——一种新的可视化方式，可清晰汇总各项指标，帮助您快速评估 AI 功能的当前状态。

<a id="scale-and-deployments"></a>

## 规模与部署

<a id="omnibus-improvements"></a>

### Omnibus 改进

<!-- categories: Omnibus Package -->

{{< details >}}

- 适用版本: 基础版、专业版、旗舰版
- 交付方式: 私有化部署
- 链接: [文档](https://gitlab.cn/docs/omnibus/)

{{< /details >}}

极狐GitLab 17.3 包含支持 [Raspberry Pi OS 12](https://www.raspberrypi.com/news/bookworm-the-new-version-of-raspberry-pi-os/)的软件包。

Debian 10 已于 [2024 年 6 月 30 日停止支持（EOL）](https://www.debian.org/releases/buster/)。极狐GitLab 将在极狐GitLab 17.6 中移除对 Debian 10 的支持。

<a id="improved-sorting-and-filtering-for-projects-and-groups-in-your-work"></a>

### 改进“您的工作”中项目和群组的排序与筛选

<!-- categories: Groups & Projects -->

{{< details >}}

- 适用版本: 基础版、专业版、旗舰版
- 交付方式: JihuLab.com、私有化部署
- 链接: [文档](../../user/project/working_with_projects.md#explore-all-projects-on-an-instance) | [相关议题](https://gitlab.com/gitlab-org/gitlab/-/issues/25368)

{{< /details >}}

我们更新了**您的工作**中项目和群组概览的排序和筛选功能。此前，在项目的**您的工作**页面中，您可以按名称和语言筛选，并使用一组预定义的排序选项。我们统一了排序选项，包括**名称**、**创建日期**、**更新日期**和**星标**。我们还添加了一个导航元素，用于按升序或降序排序，并将语言筛选移到了筛选菜单中。现在，您可以在新的**非活跃**选项卡中找到已归档的项目。此外，我们添加了**角色**筛选器，允许您搜索您作为所有者的项目。

在群组的“您的工作”页面中，我们统一了排序选项，包括**名称**、**创建日期**和**更新日期**，并添加了一个导航元素，用于按升序或降序排序。

欢迎在 [#438322](https://gitlab.com/gitlab-org/gitlab/-/issues/438322)中反馈有关这些更改的意见。

<a id="end-to-end-instance-indexing-for-advanced-search"></a>

### 高级搜索的端到端实例索引

<!-- categories: Global Search -->

{{< details >}}

- 适用版本: 专业版、旗舰版
- 交付方式: JihuLab.com、私有化部署
- 链接: [文档](../../integration/advanced_search/elasticsearch.md#index-the-instance) | [相关议题](https://gitlab.com/gitlab-org/gitlab/-/issues/271532)

{{< /details >}}

在极狐GitLab 中启用高级搜索时，您现在可以选择 **索引实例** 来执行初始索引或从头重新创建索引。此设置通过将所有受支持类型的数据索引到集成的 Elasticsearch 或 OpenSearch 集群中，实现了与 `gitlab:elastic:index` rake 任务相同的功能。

**索引实例** 取代了索引所有项目的设置，后者仅限于初始索引。

<a id="toggle-inheriting-settings-for-integrations-by-using-the-api"></a>

### 使用 API 切换集成的继承设置

<!-- categories: Settings -->

{{< details >}}

- 适用版本: 基础版、专业版、旗舰版
- 交付方式: JihuLab.com、私有化部署
- 链接: [文档](../../user/project/integrations/_index.md) | [相关议题](https://gitlab.com/gitlab-org/gitlab/-/issues/467089)

{{< /details >}}

在此之前，您只能通过 UI 控制项目是继承集成设置，还是使用自己的设置。

在此里程碑中，我们为所有集成的 REST API 引入了一个新的 `use_inherited_settings` 参数。此参数允许您使用 API 设置项目是否继承集成设置。如果未设置，默认行为为 `false`（使用项目自己的设置）。

<a id="list-group-or-project-webhook-events-with-the-api"></a>

### 使用 API 列出群组或项目 webhook 事件

<!-- categories: Notifications -->

{{< details >}}

- 适用版本: 专业版、旗舰版
- 交付方式: JihuLab.com、私有化部署
- 链接: [文档](../../api/project_webhooks.md#list-project-webhook-events) | [相关议题](https://gitlab.com/gitlab-org/gitlab/-/issues/437188)

{{< /details >}}

自极狐GitLab 9.3 起，您可以在 UI 中查看项目 webhook 请求历史记录，自极狐GitLab 15.3 起，您还可以[在 UI 中查看群组 webhook 请求历史记录](../../user/project/integrations/webhooks.md#view-webhook-request-history)。

在此版本中，该数据现在通过 REST API 公开，这可以帮助您自动化流程，以发现和响应 webhook 错误。您可以获取过去 7 天内特定[项目钩子](../../api/project_webhooks.md#list-project-webhook-events)和[群组钩子](../../api/group_webhooks.md#list-all-group-hook-events)的事件列表。

感谢 [Phawin](https://gitlab.com/lifez)的[这项社区贡献](https://gitlab.com/gitlab-org/gitlab/-/merge_requests/151048)！

<a id="find-group-settings-by-using-the-command-palette"></a>

### 使用命令面板查找群组设置

<!-- categories: Settings, Global Search -->

{{< details >}}

- 适用版本: 基础版、专业版、旗舰版
- 交付方式: JihuLab.com、私有化部署
- 链接: [文档](../../user/search/command_palette.md) | [相关议题](https://gitlab.com/gitlab-org/gitlab/-/issues/448646)

{{< /details >}}

在 17.2 中，我们添加了[使用命令面板搜索项目设置](gitlab-17-2-released.md#find-project-settings-by-using-the-command-palette)的功能。这一更改使您更容易快速找到所需的设置。

在 17.3 中，您现在也可以从命令面板搜索群组设置。前往某个群组，选择**搜索或跳转到**，使用 `>` 进入命令模式，然后输入设置部分的名称，例如**合并请求审批**，即可试用。选择一个结果即可直接跳转到该设置。

<a id="unified-devops-and-security"></a>

## 统一 DevOps 与安全

<a id="granular-control-of-code-suggestions-by-language-in-vs-code"></a>

### 在 VS Code 中按语言精细控制代码建议

<!-- categories: Editor Extensions -->

{{< details >}}

- 适用版本: 专业版、旗舰版
- 交付方式: JihuLab.com、私有化部署
- 附加组件: Duo Pro, Duo Enterprise
- 链接: [文档](../../user/project/repository/code_suggestions/supported_extensions.md#manage-languages-for-code-suggestions) | [相关议题](https://gitlab.com/gitlab-org/gitlab-vscode-extension/-/issues/1388)

{{< /details >}}

通过为特定编程语言启用或禁用代码建议，在 VS Code 中获得对编码体验的更多控制。这种精细控制允许您自定义工作流，减少无关或干扰性的建议，同时保留您首选语言的代码建议带来的好处。

<a id="improved-tls-support-in-jetbrains-ides"></a>

### 改进 JetBrains IDE 中的 TLS 支持

<!-- categories: Editor Extensions -->

{{< details >}}

- 适用版本: 基础版、专业版、旗舰版
- 交付方式: JihuLab.com、私有化部署
- 链接: [文档](../../editor_extensions/jetbrains_ide/jetbrains_troubleshooting.md#certificate-errors) | [相关议题](https://gitlab.com/gitlab-org/editor-extensions/gitlab-jetbrains-plugin/-/issues/371)

{{< /details >}}

为了在敏感环境中实现更严格的安全性，您现在可以直接在 JetBrains IDE 设置中配置自定义 HTTP agent 选项，包括客户端证书和证书颁发机构。

<a id="more-easily-remove-content-from-repositories"></a>

### 更轻松地从代码仓库中移除内容

<!-- categories: Source Code Management -->

{{< details >}}

- 适用版本: 基础版、专业版、旗舰版
- 交付方式: JihuLab.com、私有化部署
- 链接: [文档](../../user/project/repository/repository_size.md#remove-blobs)

{{< /details >}}

目前，从代码仓库中移除内容的过程很复杂，您可能不得不将项目强制推送到极狐GitLab。这容易出错，并且可能导致您临时关闭保护才能进行推送。删除代码仓库中占用过多空间的文件可能更加困难。

您现在可以使用项目设置中新的代码仓库维护选项，根据对象 ID 列表移除 blob。使用这种新方法，您可以选择性地移除内容，而无需将项目强制推送回极狐GitLab。

如果推送了密钥或其他需要从项目中删除的内容，我们还引入了一个新的文本删除选项。提供一个字符串，极狐GitLab 会在整个项目的文件中将其替换为 `***REMOVED***`。删除文本后，运行例行维护以移除该字符串的旧版本。

当需要移除内容时，这个新的 UI 简化了您管理代码仓库的方式。

<a id="audit-event-when-agent-for-kubernetes-is-created-and-deleted"></a>

### 创建和删除极狐GitLab Kubernetes Agent 时的审计事件

<!-- categories: Audit Events -->

{{< details >}}

- 适用版本: 专业版、旗舰版
- 交付方式: JihuLab.com、私有化部署
- 链接: [文档](../../user/compliance/audit_event_types.md#deployment-management) | [相关议题](https://gitlab.com/gitlab-org/gitlab/-/issues/462749)

{{< /details >}}

由于极狐GitLab Kubernetes Agent 允许 Kubernetes 集群与极狐GitLab 之间进行双向数据流，因此了解何时添加或移除可以访问您系统的组件非常重要。在过去的版本中，合规团队不得不使用自定义工具或直接在极狐GitLab 中搜索这些数据。极狐GitLab 现在提供以下审计事件：

- `cluster_agent_created` 记录谁注册了新的极狐GitLab Kubernetes Agent。
- `cluster_agent_create_failed` 记录谁尝试注册新的极狐GitLab Kubernetes Agent 但失败了。
- `cluster_agent_deleted` 记录谁移除了极狐GitLab Kubernetes Agent 注册。
- `cluster_agent_delete_failed` 记录谁尝试移除极狐GitLab Kubernetes Agent 注册但失败了。

这些审计事件扩展了 `cluster_agent_token_created` 和 `cluster_agent_token_revoked` 审计事件，进一步提升了审计极狐GitLab 实例的能力。

<a id="kubernetes-130-support"></a>

### 支持 Kubernetes 1.30

<!-- categories: Deployment Management -->

{{< details >}}

- 适用版本: 基础版、专业版、旗舰版
- 交付方式: JihuLab.com、私有化部署
- 链接: [文档](../../user/clusters/agent/_index.md#supported-kubernetes-versions-for-gitlab-features) | [相关议题](https://gitlab.com/gitlab-org/gitlab/-/issues/456929)

{{< /details >}}

此版本增加了对 2024 年 4 月发布的 Kubernetes 1.30 版本的全面支持。如果您将应用部署到 Kubernetes，现在可以将已连接的集群升级到最新版本，并利用其所有功能。

您可以阅读更多关于[我们的 Kubernetes 支持策略和其他受支持的 Kubernetes 版本](../../user/clusters/agent/_index.md#supported-kubernetes-versions-for-gitlab-features)的信息。

<a id="add-authentication-to-merge-request-external-status-checks"></a>

### 为合并请求外部状态检查添加身份验证

<!-- categories: Security Policy Management -->

{{< details >}}

- 适用版本: 旗舰版
- 交付方式: JihuLab.com、私有化部署
- 链接: [文档](../../user/project/merge_requests/status_checks.md) | [相关议题](https://gitlab.com/gitlab-org/gitlab/-/issues/433035)

{{< /details >}}

外部状态检查现在可以配置 HMAC（基于哈希的消息认证码）身份验证。这将提供一种更安全的方式来验证从极狐GitLab 到外部服务的请求的真实性。

为您的状态检查启用后，将使用共享密钥为每个请求生成唯一签名。签名通过 `X-Gitlab-Signature` 请求头发送，使用 SHA256 作为哈希算法。

- 改进的安全性：HMAC 身份验证可防止请求被篡改，并确保请求来自合法来源。
- 合规性：此功能对于银行等安全至关重要的受监管行业尤其有价值。
- 向后兼容性：此功能将是可选的且向后兼容。用户可以选择为新的或现有的检查启用 HMAC 身份验证，但现有的外部状态检查将继续正常运行，无需更改。

在[未来的迭代](https://gitlab.com/gitlab-org/gitlab/-/issues/476163)中，极狐GitLab 计划添加一个选项，用于验证并阻止 HTTP 请求。

<a id="filter-the-member-list-in-a-group-or-project-by-role"></a>

### 按角色筛选群组或项目中的成员列表

<!-- categories: Permissions -->

{{< details >}}

- 适用版本: 基础版、专业版、旗舰版
- 交付方式: JihuLab.com、私有化部署
- 链接: [文档](../../user/project/members/_index.md) | [相关议题](https://gitlab.com/gitlab-org/gitlab/-/issues/431397)

{{< /details >}}

用户现在可以按角色筛选成员页面。使用筛选器查找具有特定角色的成员。

<a id="view-role-details-in-the-right-drawer"></a>

### 在右侧抽屉中查看角色详情

<!-- categories: Permissions -->

{{< details >}}

- 适用版本: 基础版、专业版、旗舰版
- 交付方式: JihuLab.com、私有化部署
- 链接: [文档](../../user/custom_roles/_index.md) | [相关议题](https://gitlab.com/groups/gitlab-org/-/epics/13061)

{{< /details >}}

此前，如果您想查看用户自定义角色的权限，您必须在群组中拥有所有者角色。这一要求使得排查和了解用户在分配自定义角色后可以执行哪些操作变得困难。现在，任何用户都可以在成员页面中查看分配了自定义角色的用户的权限。

<a id="ldap-group-link-support-for-custom-roles"></a>

### 自定义角色的 LDAP 群组链接支持

<!-- categories: Permissions -->

{{< details >}}

- 适用版本: 旗舰版
- 交付方式: JihuLab.com、私有化部署
- 链接: [文档](../../user/group/access_and_permissions.md#manage-group-memberships-with-ldap) | [相关议题](https://gitlab.com/gitlab-org/gitlab/-/issues/435229)

{{< /details >}}

使用 LDAP 群组链接管理群组用户权限的组织已经可以使用默认角色进行成员管理。

在此版本中，我们将该支持扩展到[自定义角色](../../user/custom_roles/_index.md)。此配置使映射大量用户的访问权限变得更加容易。

<a id="new-permission-for-custom-roles"></a>

### 自定义角色的新权限

<!-- categories: Permissions -->

{{< details >}}

- 适用版本: 旗舰版
- 交付方式: JihuLab.com、私有化部署
- 链接: [文档](../../user/custom_roles/_index.md) | [相关议题](https://gitlab.com/gitlab-org/gitlab/-/issues/391760)

{{< /details >}}

您可以使用以下新权限创建自定义角色：

- [读取 Runner](../../user/custom_roles/abilities.md#runner)

借助自定义角色，您可以通过创建具有同等权限的用户来减少拥有所有者角色的用户数量。这有助于您定义适合群组需求的角色，并防止用户被授予超出其需要的权限。

<a id="disable-personal-access-tokens-using-admin-ui"></a>

### 使用管理 UI 禁用个人访问令牌

<!-- categories: System Access -->

{{< details >}}

- 适用版本: 基础版、专业版、旗舰版
- 交付方式: 私有化部署
- 链接: [文档](../../user/profile/personal_access_tokens.md#view-token-usage-information) | [相关议题](https://gitlab.com/gitlab-org/gitlab/-/issues/436991)

{{< /details >}}

管理员现在可以通过管理 UI 禁用或重新启用实例个人访问令牌。此前，管理员必须使用应用程序设置 API 或 GitLab Rails 控制台才能执行此操作。

<a id="bluesky-identifier-in-user-profile"></a>

### 用户个人资料中的 Bluesky 标识符

<!-- categories: User Profile -->

{{< details >}}

- 适用版本: 基础版、专业版、旗舰版
- 交付方式: JihuLab.com、私有化部署
- 链接: [文档](../../user/profile/_index.md#add-external-accounts-to-your-user-profile-page) | [相关议题](https://gitlab.com/gitlab-org/gitlab/-/issues/451690)

{{< /details >}}

您现在可以将您的 Bluesky did:plc 标识符添加到极狐GitLab 个人资料中。

感谢 [Dominique](https://domi.zip/)的贡献！

<a id="subdomain-cookies-preserved-on-sign-out"></a>

### 退出登录时保留子域 cookie

<!-- categories: System Access -->

{{< details >}}

- 适用版本: 基础版、专业版、旗舰版
- 交付方式: JihuLab.com、私有化部署
- 链接: [文档](../../user/profile/active_sessions.md) | [相关议题](https://gitlab.com/gitlab-org/gitlab/-/issues/471097)

{{< /details >}}

极狐GitLab 的退出登录流程已得到改进，退出登录时不再删除来自同级子域的 cookie。此前，这些 cookie 会被删除，导致用户从与极狐GitLab 位于同一顶级域的其他子域服务中退出登录。例如，如果用户在 `kibana.example.com` 上设置了 Kibana，在 `gitlab.example.com` 上设置了极狐GitLab，那么从极狐GitLab 退出登录将不再使用户从 Kibana 退出登录。

感谢 [Guilherme C. Souza](https://gitlab.com/GCSBOSS)的贡献！

<a id="ai-impact-analytics-with-enhanced-sparklines-trend-visualization"></a>

### 具有增强迷你图趋势可视化的 AI 影响分析

<!-- categories: Value Stream Management, Code Suggestions -->

{{< details >}}

- 适用版本: 旗舰版
- 交付方式: JihuLab.com、私有化部署
- 附加组件: Duo Enterprise
- 链接: [文档](../../user/analytics/duo_and_sdlc_trends.md) | [相关议题](https://gitlab.com/gitlab-org/gitlab/-/issues/464692)

{{< /details >}}

我们很高兴地宣布，通过引入迷你图，我们的 [AI 影响分析](https://about.gitlab.com/blog/developing-gitlab-duo-ai-impact-analytics-dashboard-measures-the-roi-of-ai/)得到了重大改进。这些嵌入数据表中的小型简单图表增强了 AI 影响数据的可读性和可访问性。通过将数值转换为可视化表示，新的迷你图使识别随时间变化的趋势变得更加容易，因此您可以发现上升或下降的走势。这种新的可视化方法还简化了跨多个指标比较趋势的过程，减少了仅依赖数字时所需的时间和精力。

<a id="add-merge-requests-to-tasks"></a>

### 将合并请求添加到任务

<!-- categories: Team Planning -->

{{< details >}}

- 适用版本: 基础版、专业版、旗舰版
- 交付方式: JihuLab.com、私有化部署
- 链接: [文档](../../user/tasks.md#add-a-merge-request-and-automatically-close-tasks) | [相关议题](https://gitlab.com/gitlab-org/gitlab/-/issues/440851)

{{< /details >}}

任务经常用于将议题分解为工程实施步骤。在此版本之前，无法将合并请求连接到它所实现的任务。您现在可以使用与在合并请求描述中引用议题时相同的[关闭模式](../../user/project/issues/managing_issues.md#closing-issues-automatically)，将合并请求连接到任务。在任务视图中，连接的合并请求会显示在侧边栏中。如果您的项目[启用了自动关闭设置](../../user/project/issues/managing_issues.md#disable-automatic-issue-closing)，当连接的合并请求合并到您的默认分支时，任务将自动关闭。

<a id="set-parent-items-for-okrs-and-tasks"></a>

### 为 OKR 和任务设置父项

<!-- categories: Portfolio Management -->

{{< details >}}

- 适用版本: 基础版、专业版、旗舰版
- 交付方式: JihuLab.com、私有化部署
- 链接: [文档](../../user/okrs.md#set-an-objective-as-a-parent) | [相关史诗](https://gitlab.com/groups/gitlab-org/-/epics/11198)

{{< /details >}}

您现在可以直接从子记录轻松更新 [OKR](../../user/okrs.md#set-an-objective-as-a-parent) 和[任务](../../user/tasks.md#set-an-issue-as-a-parent)的父项分配，无需来回导航。这是朝着我们[提高工作流效率](https://gitlab.com/groups/gitlab-org/-/epics/10501)的目标迈出的一大步。

<a id="report-abuse-for-task-objective-and-key-result-items"></a>

### 举报任务、目标和关键结果项的滥用行为

<!-- categories: Team Planning -->

{{< details >}}

- 适用版本: 基础版、专业版、旗舰版
- 交付方式: JihuLab.com、私有化部署
- 链接: [文档](../../user/report_abuse.md) | [相关议题](https://gitlab.com/gitlab-org/gitlab/-/issues/461848)

{{< /details >}}

您现在可以直接从**操作**菜单举报工作项的滥用行为，就像对旧版议题一样。这项新功能允许您快速标记不当内容，帮助保持工作区整洁安全，为您的团队确保更好的协作环境。

<a id="resolve-threads-in-tasks-objectives-and-key-results"></a>

### 解决任务、目标和关键结果中的讨论串

<!-- categories: Team Planning -->

{{< details >}}

- 适用版本: 基础版、专业版、旗舰版
- 交付方式: JihuLab.com、私有化部署
- 链接: [文档](../../user/discussions/_index.md#resolve-a-thread) | [相关议题](https://gitlab.com/gitlab-org/gitlab/-/issues/458818)

{{< /details >}}

您现在可以解决任务、目标和关键结果中的讨论串，从而更轻松地管理和跟踪重要对话。已解决的讨论串默认折叠，帮助您专注于活跃的讨论并简化协作工作流。

<a id="new-value-stream-analytics-stage-events-for-cycle-time-reduction"></a>

### 用于缩短周期时间的新价值流分析阶段事件

<!-- categories: Value Stream Management -->

{{< details >}}

- 适用版本: 专业版、旗舰版
- 交付方式: JihuLab.com、私有化部署
- 链接: [文档](../../user/group/value_stream_analytics/_index.md#value-stream-stage-events) | [相关议题](https://gitlab.com/gitlab-org/gitlab/-/issues/466383)

{{< /details >}}

为了改进极狐GitLab 中合并请求评审时间的跟踪，我们为[价值流分析](https://about.gitlab.com/solutions/value-stream-management/)添加了一个新的阶段事件：**合并请求首次分配审核人**。借助这个新事件，团队可以识别评审过程中出现延迟的环节，找到改进协作的机会，并在团队成员中培养响应迅速和负责的文化。缩短评审时间会直接影响开发的整体周期时间，[从而加快软件交付](https://about.gitlab.com/blog/three-steps-to-optimize-software-value-streams/)。例如，您现在可以添加一个新的自定义**评审到合并时间（RTTM）**阶段，该阶段以**合并请求首次分配审核人**开始，以**合并请求已合并**结束。

<a id="rust-support-for-dependency-and-license-scanning"></a>

### 依赖扫描和许可证扫描支持 Rust

<!-- categories: Software Composition Analysis -->

{{< details >}}

- 适用版本: 旗舰版
- 交付方式: JihuLab.com、私有化部署
- 链接: [文档](../../user/compliance/license_scanning_of_cyclonedx_files/_index.md#supported-languages-and-package-managers) | [相关议题](https://gitlab.com/groups/gitlab-org/-/epics/13093)

{{< /details >}}

成分分析已为依赖扫描和许可证扫描提供 Rust 支持。Rust 扫描支持 `Cargo.lock` 文件类型。

要为您的项目启用 Rust 扫描，请使用[依赖扫描 CI/CD 组件](https://gitlab.com/explore/catalog/components/dependency-scanning)中的 `cargo` 模板。

<a id="display-sbom-ingestion-errors-in-gitlab-ui"></a>

### 在极狐GitLab UI 中显示 SBOM 摄取错误

<!-- categories: Software Composition Analysis -->

{{< details >}}

- 适用版本: 旗舰版
- 交付方式: JihuLab.com、私有化部署
- 链接: [文档](../../user/application_security/dependency_list/_index.md) | [相关议题](https://gitlab.com/groups/gitlab-org/-/epics/14408)

{{< /details >}}

极狐GitLab 15.3 添加了对[摄取 CycloneDX SBOM](../../ci/yaml/artifacts_reports.md#artifactsreportscyclonedx)的支持。虽然 SBOM 报告会根据 CycloneDX 架构进行验证，但验证过程中产生的任何警告和错误都不会显示给用户。

在极狐GitLab 17.3 中，这些验证消息会显示在极狐GitLab UI 的项目级漏洞报告和依赖列表页面上。

用户将能够在极狐GitLab UI 的以下区域查看 SBOM 摄取错误：项目级漏洞报告和依赖列表页面、流水线页面的许可证和安全选项卡。

<a id="enforce-the-ruleset-used-in-sast-iac-scanning-and-secret-detection"></a>

### 强制执行 SAST、IaC 扫描和密钥检测中使用的规则集

<!-- categories: SAST, Secret Detection, Security Policy Management -->

{{< details >}}

- 适用版本: 旗舰版
- 交付方式: JihuLab.com、私有化部署
- 链接: [文档](../../user/application_security/sast/customize_rulesets.md#use-a-remote-ruleset-file)

{{< /details >}}

您可以通过创建提交到代码仓库中的本地配置文件，或通过设置 CI/CD 变量以在多个项目间应用共享配置，来自定义 [SAST](../../user/application_security/sast/customize_rulesets.md)、[IaC 扫描](../../user/application_security/iac_scanning/_index.md#optimize-iac-scanning)和[密钥检测](../../user/application_security/secret_detection/pipeline/configure.md#customize-analyzer-behavior)中使用的规则。

此前，即使您同时设置了共享规则集引用，扫描器也会优先使用本地配置文件。这种优先级顺序使得确保扫描使用已知、可信的规则集变得困难。

现在，我们添加了一个新的 CI/CD 变量 `SECURE_ENABLE_LOCAL_CONFIGURATION`，用于控制是否允许本地配置文件。它默认为 `true`，保持现有行为：允许本地配置文件，并且优先于共享配置。如果您在[强制执行扫描](../../user/application_security/policies/scan_execution_policies.md)时将值设置为 `false`，那么即使项目开发者添加了本地配置文件，您也可以确保扫描使用您的共享规则集或默认规则集。

<a id="filter-jobs-by-job-name"></a>

### 按作业名称筛选作业

<!-- categories: Continuous Integration (CI) -->

{{< details >}}

- 适用版本: 基础版、专业版、旗舰版
- 交付方式: JihuLab.com、私有化部署
- 链接: [文档](../../ci/jobs/_index.md) | [相关议题](https://gitlab.com/gitlab-org/gitlab/-/issues/387547)

{{< /details >}}

您现在可以通过搜索作业名称来快速找到特定作业。

此前，您只能按状态筛选作业列表，需要手动滚动才能找到特定作业。在此版本中，您现在可以输入作业名称来筛选结果。结果将仅包含在极狐GitLab 17.3 发布之后运行的流水线中的作业。

<a id="merge-train-visualization"></a>

### 合并列车可视化

<!-- categories: Merge Trains -->

{{< details >}}

- 适用版本: 专业版、旗舰版
- 交付方式: JihuLab.com、私有化部署
- 链接: [文档](../../ci/pipelines/merge_trains.md) | [相关史诗](https://gitlab.com/groups/gitlab-org/-/epics/13705)

{{< /details >}}

您现在可以可视化合并列车，以更好地了解流水线中合并请求的状态和顺序。借助合并列车可视化，您可以更早地识别冲突，直接在合并列车中对合并请求执行操作，并最大限度地降低破坏默认分支的风险。

<a id="gitlab-runner-173"></a>

### 极狐GitLab Runner 17.3

<!-- categories: GitLab Runner Core -->

{{< details >}}

- 适用版本: 基础版、专业版、旗舰版
- 交付方式: 私有化部署
- 链接: [文档](https://gitlab.cn/docs/runner/)

{{< /details >}}

我们今天发布极狐GitLab Runner 17.3！极狐GitLab Runner 是轻量级、高度可扩展的代理，用于运行您的 CI/CD 作业并将结果发送回极狐GitLab 实例。极狐GitLab Runner 与极狐GitLab CI/CD 协同工作，后者是极狐GitLab 中包含的开源持续集成服务。

<a id="bug-fixes"></a>

#### 缺陷修复

- [在 Kubernetes runner 中取消作业时作业似乎挂起](https://gitlab.com/gitlab-org/gitlab-runner/-/issues/37780)
- [未指定时日志级别未更新](https://gitlab.com/gitlab-org/gitlab-runner/-/issues/37490)
- [使用 runner Kubernetes 执行器时作业日志添加了额外的换行符](https://gitlab.com/gitlab-org/gitlab-runner/-/issues/27099)

有关所有更改的列表，请参阅极狐GitLab Runner [变更日志](https://gitlab.com/gitlab-org/gitlab-runner/blob/17-3-stable/CHANGELOG.md)。

<a id="improved-performance-for-hosted-runners-on-macos"></a>

### 改进 macOS 上托管 runner 的性能

<!-- categories: GitLab Hosted Runners -->

{{< details >}}

- 交付方式: JihuLab.com
- 链接: [文档](../../ci/runners/hosted_runners/macos.md) | [相关议题](https://gitlab.com/gitlab-org/ci-cd/shared-runners/images/job-images/-/issues/6)

{{< /details >}}

我们通过最近升级到 macOS 14.5 和 Xcode 15.4 带来了性能改进。通过这一更改，Xcode 构建作业比之前的作业执行速度显著加快。

<a id="description-and-type-added-to-cicd-catalog-component-input-details"></a>

### 为 CI/CD catalog 组件输入详情添加描述和类型

<!-- categories: Pipeline Composition -->

{{< details >}}

- 适用版本: 基础版、专业版、旗舰版
- 交付方式: 私有化部署
- 链接: [文档](../../ci/components/_index.md#cicd-catalog) | [相关议题](https://gitlab.com/gitlab-org/gitlab/-/issues/426870)

{{< /details >}}

目录中 CI/CD 组件的详情页面提供了有关该组件的有用信息。在此版本中，我们为显示可用输入信息的表格添加了两列。新的**描述**和**类型**列使您更容易理解输入的用途以及期望的值类型。
