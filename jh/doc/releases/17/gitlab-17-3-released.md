---
stage: Release Notes
group: Monthly Release
date: 2024-08-15
title: "极狐GitLab 17.3 发布说明"
description: "极狐GitLab 17.3 发布，包含通过根因分析排查失败作业的功能"
---

<!-- markdownlint-disable -->
<!-- vale off -->

2024 年 8 月 15 日，极狐GitLab 17.3 正式发布，带来了以下功能。

<a id="primary-features"></a>

## 主要功能

<a id="troubleshoot-failed-jobs-with-root-cause-analysis"></a>

### 通过根因分析排查失败作业

{{< details >}}

- Tier: 旗舰版
- Offering: JihuLab.com
- Add-ons: Duo Enterprise
- Links: [文档](../../user/gitlab_duo_chat/examples.md#troubleshoot-failed-cicd-jobs-with-root-cause-analysis) | [相关史诗](https://gitlab.com/groups/gitlab-org/-/epics/13080)

{{< /details >}}

根因分析现已正式可用。借助根因分析，您可以更快地排查 CI/CD 流水线中的失败作业。这项 AI 驱动的功能会分析失败的作业日志，迅速确定作业失败的根本原因，并为您建议修复方案。

<a id="health-check-for-gitlab-duo-in-beta"></a>

### 极狐GitLab Duo 健康检查（测试版）

{{< details >}}

- Tier: 专业版，旗舰版
- Add-ons: Duo Pro，Duo Enterprise
- Links: [文档](../../administration/gitlab_duo/configure/_index.md#run-a-health-check-for-gitlab-duo) | [相关议题](https://gitlab.com/groups/gitlab-org/-/epics/14518)

{{< /details >}}

现在，您可以对私有化部署实例上的极狐GitLab Duo 设置进行故障排除。在 **管理员** 区域，在 极狐GitLab Duo 页面上，选择 **运行健康检查**。
此健康检查会执行一系列验证，并建议适当的纠正措施，以确保极狐GitLab Duo 可正常运行。

极狐GitLab Duo 的健康检查以测试版功能可用于私有化部署。

<a id="delete-a-pod-from-the-gitlab-ui"></a>

### 从极狐GitLab UI 删除 Pod

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: JihuLab.com
- Links: [文档](../../ci/environments/kubernetes_dashboard.md#delete-a-pod) | [相关议题](https://jihulab.com/gitlab-cn/gitlab/-/issues/467653)

{{< /details >}}

您是否曾需要在 Kubernetes 中重启或删除发生故障的 Pod？在此之前，您必须离开极狐GitLab，使用其他工具连接到集群，停止 Pod，并等待新 Pod 启动。现在，极狐GitLab 内置了删除 Pod 的支持，因此您可以顺畅地排查 Kubernetes 集群问题。

您可以从 [Kubernetes 仪表盘](../../ci/environments/kubernetes_dashboard.md) 停止 Pod，该仪表盘列出了跨集群或命名空间的所有 Pod。

<a id="easily-connect-to-a-cluster-from-your-local-terminal"></a>

### 从本地终端轻松连接到集群

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: JihuLab.com
- Links: [文档](../../user/clusters/agent/user_access.md) | [相关议题](https://jihulab.com/gitlab-cn/gitlab/-/issues/463769)

{{< /details >}}

您是否想从本地终端或使用桌面 Kubernetes GUI 工具连接到 Kubernetes 集群？
极狐GitLab 允许您使用 [Kubernetes Agent 的用户访问功能](../../user/clusters/agent/user_access.md) 连接到终端。
以前，查找命令需要离开极狐GitLab 去浏览文档。现在，极狐GitLab 从 UI 提供了连接命令。极狐GitLab 甚至可以帮助您配置用户访问！

要获取连接命令，请转到 [Kubernetes 仪表盘](../../ci/environments/kubernetes_dashboard.md)，或访问 [Agent 列表](../../user/clusters/agent/work_with_agent.md#view-your-agents)。

<a id="resolve-a-vulnerability-with-ai"></a>

### 使用 AI 解决漏洞

{{< details >}}

- Tier: 旗舰版
- Offering: JihuLab.com
- Add-ons: Duo Enterprise
- Links: [文档](../../user/application_security/vulnerabilities/_index.md#vulnerability-resolution) | [相关史诗](https://gitlab.com/groups/gitlab-org/-/epics/10783)

{{< /details >}}

漏洞解决利用 AI 为用户提供特定的代码建议，以修复漏洞。只需点击一下按钮，您就可以打开合并请求，开始解决 [支持的 CWE 标识符列表](../../user/application_security/vulnerabilities/_index.md#supported-vulnerabilities-for-vulnerability-resolution) 中的任何 SAST 漏洞。

<a id="add-multiple-compliance-frameworks-to-a-single-project"></a>

### 为单个项目添加多个合规框架

{{< details >}}

- Tier: 专业版，旗舰版
- Offering: JihuLab.com
- Links: [文档](../../user/project/working_with_projects.md#add-a-compliance-framework-to-a-project) | [相关史诗](https://gitlab.com/groups/gitlab-org/-/epics/13294)

{{< /details >}}

您可以创建合规框架，以标识您的项目具有特定的合规要求或需要额外的监督。
合规框架可以选择性地对应用它的项目强制执行合规流水线配置。

以前，用户只能为一个项目应用一个合规框架，这限制了可在项目上设置的合规要求数量。
现在，我们提供了用户可以为每个项目应用多个合规框架的能力。
这将允许用户在给定时间将多个不同的合规框架应用到单个项目上。
通过此版本，您可以向项目应用多个合规框架。然后，项目将设置为每个框架的合规要求。

<a id="ai-impact-analytics-code-suggestions-acceptance-rate-and-gitlab-duo-seats-usage"></a>

### AI Impact 分析：代码建议接受率和 极狐GitLab Duo 许可座位使用率

{{< details >}}

- Tier: 旗舰版
- Offering: JihuLab.com
- Add-ons: Duo Enterprise
- Links: [文档](../../user/analytics/value_streams_dashboard.md#dashboard-metrics-and-drill-down-reports) | [相关议题](https://jihulab.com/gitlab-cn/gitlab/-/issues/471168)

{{< /details >}}

这两个新指标突出了极狐GitLab Duo 的有效性和利用率，现已包含在 [价值流仪表板中的 AI Impact 分析](https://gitlab.cn/blog/developing-gitlab-duo-ai-impact-analytics-dashboard-measures-the-roi-of-ai/) 中，帮助组织了解极狐GitLab Duo 对交付业务价值的影响。

**代码建议接受率** 指标表示开发人员接受极狐GitLab Duo 给出的代码建议的频率。此指标反映了这些建议的有效性以及贡献者对 AI 能力的信任程度。具体来说，该指标代表了过去 30 天内由极狐GitLab Duo 提供并被代码贡献者接受的代码建议的百分比。

**已分配和已使用的极狐GitLab Duo 许可座位** 指标显示了已消耗许可座位的百分比，帮助组织有效地规划许可使用、资源分配并理解使用模式。此指标跟踪了过去 30 天内至少使用过一项 AI 功能的已分配座位的比例。

随着这些新指标的添加，我们还引入了新的概览卡片——一种新的可视化方式，可提供指标的清晰摘要，帮助您快速评估 AI 功能的当前状态。

## 规模与部署

<a id="omnibus-improvements"></a>

### Omnibus 改进

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Links: [文档](https://gitlab.cn/docs/omnibus/)

{{< /details >}}

极狐GitLab 17.3 包含对 [Raspberry Pi OS 12](https://www.raspberrypi.com/news/bookworm-the-new-version-of-raspberry-pi-os/) 的支持软件包。

Debian 10 已于 [2024 年 6 月 30 日 EOL](https://www.debian.org/releases/buster/)。极狐GitLab 将在 极狐GitLab 17.6 中移除对 Debian 10 的支持。

<a id="improved-sorting-and-filtering-for-projects-and-groups-in-your-work"></a>

### 改进了您的工作中项目和群组的排序和筛选

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: JihuLab.com
- Links: [文档](../../user/project/working_with_projects.md#explore-all-projects-on-an-instance) | [相关议题](https://jihulab.com/gitlab-cn/gitlab/-/issues/25368)

{{< /details >}}

我们更新了 **您的工作** 中项目和群组概览的排序和筛选功能。
此前，在 **您的工作** 项目页面中，您可以按名称和语言进行筛选，并使用一组预定义的排序选项。现在，我们将排序选项标准化为包括 **名称**、**创建日期**、**更新日期** 和 **星标**。我们还添加了导航元素，以升序或降序排序，并将语言筛选器移至筛选菜单。现在，您可以在新的 **非活跃** 选项卡中找到已归档的项目。此外，我们添加了一个 **角色** 筛选器，允许您搜索您是所有者的项目。

在群组的您的工作页面中，我们将排序选项标准化为包括 **名称**、**创建日期** 和 **更新日期**，并添加了导航元素以升序或降序排序。

<a id="end-to-end-instance-indexing-for-advanced-search"></a>

### 为高级搜索进行端到端实例索引

{{< details >}}

- Tier: 专业版，旗舰版
- Offering: JihuLab.com
- Links: [文档](../../integration/advanced_search/elasticsearch.md#index-the-instance) | [相关议题](https://jihulab.com/gitlab-cn/gitlab/-/issues/271532)

{{< /details >}}

当您在极狐GitLab 中启用高级搜索时，现在可以选择 **索引实例** 来执行初始索引或从头重新创建索引。此设置通过对所有支持的数据类型索引到集成的 Elasticsearch 或 OpenSearch 集群，实现了与 `gitlab:elastic:index` rake 任务的功能对等。

**索引实例** 替代了仅限初始索引的索引所有项目的设置。

<a id="toggle-inheriting-settings-for-integrations-by-using-the-api"></a>

### 使用 API 切换集成的设置继承

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: JihuLab.com
- Links: [文档](../../user/project/integrations/_index.md) | [相关议题](https://jihulab.com/gitlab-cn/gitlab/-/issues/467089)

{{< /details >}}

到目前为止，您只能使用 UI 控制项目是否继承集成设置，还是使用自己的设置。

在这个里程碑中，我们为所有集成的 REST API 引入了一个新的 `use_inherited_settings` 参数。此参数允许您使用 API 来设置
项目是否继承集成设置。如果未设置，默认行为是 `false`（使用项目自己的设置）。

<a id="list-group-or-project-webhook-events-with-the-api"></a>

### 使用 API 列出群组或项目 webhook 事件

{{< details >}}

- Tier: 专业版，旗舰版
- Offering: JihuLab.com
- Links: [文档](../../api/project_webhooks.md#list-project-webhook-events) | [相关议题](https://jihulab.com/gitlab-cn/gitlab/-/issues/437188)

{{< /details >}}

自极狐GitLab 9.3 起，您可以在 UI 中查看项目 webhook 请求历史，自极狐GitLab 15.3 起，您也可以在 [UI 中查看群组 webhook 请求历史](../../user/project/integrations/webhooks.md#view-webhook-request-history)。

在此版本中，该数据现可通过 REST API 获取，这可以帮助您自动化发现和响应 webhook 错误的过程。您可以获取过去 7 天内特定 [项目钩子](../../api/project_webhooks.md#list-project-webhook-events) 和 [群组钩子](../../api/group_webhooks.md#list-all-group-hook-events) 的事件列表。

感谢 [Phawin](https://gitlab.com/lifez) 所做的 [社区贡献](https://jihulab.com/gitlab-cn/gitlab/-/merge_requests/151048)！

<a id="find-group-settings-by-using-the-command-palette"></a>

### 使用命令面板查找群组设置

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: JihuLab.com
- Links: [文档](../../user/search/command_palette.md) | [相关议题](https://jihulab.com/gitlab-cn/gitlab/-/issues/448646)

{{< /details >}}

在 17.2 中，我们添加了 [使用命令面板搜索项目设置](https://about.gitlab.com/releases/2024/07/18/gitlab-17-2-released/#find-project-settings-by-using-the-command-palette) 的功能。这一改变使快速找到所需设置变得更加容易。

在 17.3 中，您现在也可以从命令面板搜索群组设置。尝试一下：访问一个群组，选择 **搜索或跳转到**，通过输入 `>` 进入命令模式，然后键入设置部分的名称，例如 **合并请求审批**。选择一个结果即可直接跳转到该设置本身。

## 统一 DevOps 与安全

<a id="more-easily-remove-content-from-repositories"></a>

### 更轻松地从仓库中移除内容

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: JihuLab.com
- Links: [文档](../../user/project/repository/repository_size.md#remove-blobs)

{{< /details >}}

目前，从仓库中移除内容的过程很复杂，您可能需要将项目强制推送回极狐GitLab。
这容易出错，并且可能导致您临时关闭保护才能完成推送。
删除仓库中占用空间过大的文件甚至更困难。

您现在可以使用项目设置中新的仓库维护选项，根据对象 ID 列表移除 blob。
有了这种新方法，您可以有选择性地移除内容，而无需将项目强制推送回极狐GitLab。

如果机密或其他已推送的内容需要从项目中编辑清除，我们还引入了一个新选项来编辑文本。
提供一个字符串，极狐GitLab 将用 `***REMOVED***` 替换项目中所有文件中的该字符串。
文本编辑后，运行 housekeeping 以移除旧版本的字符串。

这个新的 UI 简化了在需要移除内容时管理仓库的方式。

<a id="audit-event-when-agent-for-kubernetes-is-created-and-deleted"></a>

### Kubernetes Agent 创建和删除时的审计事件

{{< details >}}

- Tier: 专业版，旗舰版
- Offering: JihuLab.com
- Links: [文档](../../user/compliance/audit_event_types.md#deployment-management) | [相关议题](https://jihulab.com/gitlab-cn/gitlab/-/issues/462749)

{{< /details >}}

由于 Kubernetes Agent 允许 Kubernetes 集群与极狐GitLab 之间的双向数据流动，了解何时添加或移除了可以访问您系统的组件非常重要。
在过去的版本中，合规团队必须使用自定义工具或在极狐GitLab 中直接查找这些数据。现在，极狐GitLab 提供了以下审计事件：

- `cluster_agent_created` 记录了谁注册了新的 Kubernetes Agent。
- `cluster_agent_create_failed` 记录了谁尝试注册新的 Kubernetes Agent 但失败了。
- `cluster_agent_deleted` 记录了谁移除了 Kubernetes Agent 注册。
- `cluster_agent_delete_failed` 记录了谁尝试移除 Kubernetes Agent 注册但失败了。

这些审计事件扩展了 `cluster_agent_token_created` 和 `cluster_agent_token_revoked` 审计事件，进一步提高了审计极狐GitLab 实例的能力。

<a id="kubernetes-130-support"></a>

### Kubernetes 1.30 支持

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: JihuLab.com
- Links: [文档](../../user/clusters/agent/_index.md#supported-kubernetes-versions-for-gitlab-features) | [相关议题](https://jihulab.com/gitlab-cn/gitlab/-/issues/456929)

{{< /details >}}

此版本为 2024 年 4 月发布的 Kubernetes 1.30 版本提供全面支持。如果您将应用部署到 Kubernetes，现在可以将已连接的集群升级到最新版本，并充分利用其所有功能。

您可以阅读有关 [我们的 Kubernetes 支持策略和其他受支持的 Kubernetes 版本](../../user/clusters/agent/_index.md#supported-kubernetes-versions-for-gitlab-features) 的更多信息。

<a id="add-authentication-to-merge-request-external-status-checks"></a>

### 为合并请求外部状态检查添加身份验证

{{< details >}}

- Tier: 旗舰版
- Offering: JihuLab.com
- Links: [文档](../../user/project/merge_requests/status_checks.md) | [相关议题](https://jihulab.com/gitlab-cn/gitlab/-/issues/433035)

{{< /details >}}

外部状态检查现在可以配置为使用 HMAC（基于哈希的消息认证码）身份验证。这将提供一种更安全的方式，来验证来自极狐GitLab 的请求是否合法。

当为您的状态检查启用后，一个共享密钥会用于为每个请求生成唯一的签名。该签名使用 SHA256 作为哈希算法，通过 `X-Gitlab-Signature` 头发送。

- 提高安全性：HMAC 身份验证防止请求被篡改，并确保它们来自合法来源。
- 合规性：此功能对于受监管的行业（如银行）特别有价值，因为在这些行业中安全性至关重要。
- 向后兼容性：该功能是可选的并且向后兼容。用户可以选择为新的或现有的检查启用 HMAC 身份验证，但现有的外部状态检查将继续不变地运行。

在 [未来的迭代中](https://jihulab.com/gitlab-cn/gitlab/-/issues/476163)，极狐GitLab 计划添加一个选项来验证并阻止 HTTP 请求。

<a id="filter-the-member-list-in-a-group-or-project-by-role"></a>

### 按角色筛选群组或项目中的成员列表

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: JihuLab.com
- Links: [文档](../../user/project/members/_index.md) | [相关议题](https://jihulab.com/gitlab-cn/gitlab/-/issues/431397)

{{< /details >}}

用户现在可以按角色筛选成员页面。使用筛选器可以按特定角色查找成员。

<a id="view-role-details-in-the-right-drawer"></a>

### 在右侧抽屉中查看角色详情

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: JihuLab.com
- Links: [文档](../../user/custom_roles/_index.md) | [相关史诗](https://gitlab.com/groups/gitlab-org/-/epics/13061)

{{< /details >}}

以前，如果您想查看用户自定义角色的权限，您必须拥有群组的 Owner 角色。这一要求使得在为用户分配自定义角色时排查和理解用户可以执行的操作变得困难。现在，任何用户都可以在成员页面中查看被分配了自定义角色的用户的权限。

<a id="ldap-group-link-support-for-custom-roles"></a>

### 自定义角色的 LDAP 群组链接支持

{{< details >}}

- Tier: 旗舰版
- Offering: JihuLab.com
- Links: [文档](../../user/group/access_and_permissions.md#manage-group-memberships-with-ldap) | [相关议题](https://jihulab.com/gitlab-cn/gitlab/-/issues/435229)

{{< /details >}}

使用 LDAP 群组链接管理群组用户权限的组织已经可以使用默认角色设置成员资格。

在此版本中，我们将该支持扩展到 [自定义角色](../../user/custom_roles/_index.md)。这种配置使得将访问权限映射到大量用户组变得更加容易。

<a id="new-permission-for-custom-roles"></a>

### 自定义角色的新权限

{{< details >}}

- Tier: 旗舰版
- Offering: JihuLab.com
- Links: [文档](../../user/custom_roles/_index.md) | [相关议题](https://jihulab.com/gitlab-cn/gitlab/-/issues/391760)

{{< /details >}}

您可以使用以下新权限创建自定义角色：

- [读取 Runner](../../user/custom_roles/abilities.md#runner)

通过自定义角色，您可以减少拥有 Owner 角色的用户数量，方法是创建具有等效权限的用户。这有助于您定义适合您的群组需求的角色，并防止用户被赋予超出所需的权限。

<a id="disable-personal-access-tokens-using-admin-ui"></a>

### 使用管理员 UI 禁用个人访问令牌

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Links: [文档](../../user/profile/personal_access_tokens.md#view-token-usage-information) | [相关议题](https://jihulab.com/gitlab-cn/gitlab/-/issues/436991)

{{< /details >}}

管理员现在可以通过管理员 UI 禁用或重新启用实例个人访问令牌。以前，管理员必须使用应用程序设置 API 或极狐GitLab Rails 控制台来执行此操作。

<a id="bluesky-identifier-in-user-profile"></a>

### 用户资料中的 Bluesky 标识符

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: JihuLab.com
- Links: [文档](../../user/profile/_index.md#add-external-accounts-to-your-user-profile-page) | [相关议题](https://jihulab.com/gitlab-cn/gitlab/-/issues/451690)

{{< /details >}}

您现在可以将您的 Bluesky did:plc 标识符添加到您的极狐GitLab 个人资料中。

感谢 [Dominique](https://domi.zip/) 的贡献！

<a id="subdomain-cookies-preserved-on-sign-out"></a>

### 注销时保留子域 Cookie

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: JihuLab.com
- Links: [文档](../../user/profile/active_sessions.md) | [相关议题](https://jihulab.com/gitlab-cn/gitlab/-/issues/471097)

{{< /details >}}

极狐GitLab 的注销流程已得到改进，以便在注销时不会删除同级子域的 Cookie。以前，这些 Cookie 会被删除，导致用户从与极狐GitLab 相同顶级域上的其他子域服务中注销。例如，如果用户在 `kibana.example.com` 上设置了 Kibana，在 `gitlab.example.com` 上设置了极狐GitLab，从极狐GitLab 注销将不再让用户从 Kibana 注销。

感谢 [Guilherme C. Souza](https://gitlab.com/GCSBOSS) 的贡献！

<a id="ai-impact-analytics-with-enhanced-sparklines-trend-visualization"></a>

### 带有增强迷你图趋势可视化的 AI Impact 分析

{{< details >}}

- Tier: 旗舰版
- Offering: JihuLab.com
- Add-ons: Duo Enterprise
- Links: [文档](../../user/analytics/duo_and_sdlc_trends.md) | [相关议题](https://jihulab.com/gitlab-cn/gitlab/-/issues/464692)

{{< /details >}}

我们很高兴宣布对 [AI Impact 分析](https://gitlab.cn/blog/developing-gitlab-duo-ai-impact-analytics-dashboard-measures-the-roi-of-ai/) 的重大改进，引入了迷你图。这些嵌入在数据表中的简单小型图表增强了 AI Impact 数据的可读性和可访问性。通过将数值转化为可视化表示，新的迷你图使得更容易识别随时间变化的趋势，从而让您能够发现上升或下降的运动。这种新的可视化方式还简化了跨多个指标比较趋势的过程，减少了仅依赖数字时所需的时间和精力。

<a id="add-merge-requests-to-tasks"></a>

### 将合并请求添加到任务

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: JihuLab.com
- Links: [文档](../../user/tasks.md#add-a-merge-request-and-automatically-close-tasks) | [相关议题](https://jihulab.com/gitlab-cn/gitlab/-/issues/440851)

{{< /details >}}
任务通常用于将议题分解为工程实施步骤。在此版本之前，无法将合并请求与其实现的任务关联起来。现在，您可以使用与在合并请求描述中引用议题时相同的[关闭模式](../../user/project/issues/managing_issues.md#closing-issues-automatically)，将合并请求连接到任务。在任务视图中，可以从侧边栏看到已连接的合并请求。如果您的项目启用了[自动关闭设置](../../user/project/issues/managing_issues.md#disable-automatic-issue-closing)，则当连接的合并请求合并到默认分支时，任务将自动关闭。

<a id="set-parent-items-for-okrs-and-tasks"></a>

### 为 OKR 和任务设置父项

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: JihuLab.com
- Links: [文档](../../user/okrs.md#set-an-objective-as-a-parent) | 相关史诗

{{< /details >}}

现在，您可以直接从子记录轻松更新 [OKR](../../user/okrs.md#set-an-objective-as-a-parent) 和 [任务](../../user/tasks.md#set-an-issue-as-a-parent) 的父项分配，无需来回导航。这是朝着我们提高工作流效率目标迈出的重要一步。

<a id="report-abuse-for-task-objective-and-key-result-items"></a>

### 报告任务、目标和关键结果的滥用行为

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: JihuLab.com
- Links: [文档](../../user/report_abuse.md) | 相关议题

{{< /details >}}

现在，您可以直接从 **操作** 菜单轻松报告工作项的滥用行为，就像处理旧版议题一样。这一新功能通过允许您快速标记不当内容，有助于保持工作区的清洁和安全，为您的团队确保更好的协作环境。

<a id="resolve-threads-in-tasks-objectives-and-key-results"></a>

### 解决任务、目标和关键结果中的讨论串

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: JihuLab.com
- Links: [文档](../../user/discussions/_index.md#resolve-a-thread) | 相关议题

{{< /details >}}

现在，您可以解决任务、目标和关键结果中的讨论串，从而更轻松地管理和跟踪重要对话。已解决的讨论串默认折叠，帮助您专注于活跃讨论并简化协作工作流。

<a id="new-value-stream-analytics-stage-events-for-cycle-time-reduction"></a>

### 用于缩短周期时间的全新价值流分析阶段事件

{{< details >}}

- Tier: 专业版，旗舰版
- Offering: JihuLab.com
- Links: [文档](../../user/group/value_stream_analytics/_index.md#value-stream-stage-events) | 相关议题

{{< /details >}}

为了改进极狐GitLab中合并请求（MR）审查时间的跟踪，我们向[价值流分析](https://gitlab.cn/solutions/value-stream-management/)添加了一个新的阶段事件：**MR 第一位审查者已分配**。
借助这个新事件，团队可以识别审查过程中发生延迟的位置，找到改善协作的机会，并鼓励团队成员形成响应性和问责制的文化。减少审查时间直接影响开发的整体周期时间，[从而实现更快的软件交付](https://gitlab.cn/blog/three-steps-to-optimize-software-value-streams/)。例如，您现在可以添加一个新的自定义 **审查到合并时间 (RTTM)** 阶段，该阶段以 **MR 第一位审查者已分配** 开始，以 **MR 已合并** 结束。

<a id="rust-support-for-dependency-and-license-scanning"></a>

### 依赖项和许可证扫描的 Rust 支持

{{< details >}}

- Tier: 旗舰版
- Offering: JihuLab.com
- Links: [文档](../../user/compliance/license_scanning_of_cyclonedx_files/_index.md#supported-languages-and-package-managers) | 相关史诗

{{< /details >}}

组合分析已为依赖项和许可证扫描提供了 Rust 支持。Rust 扫描支持 `Cargo.lock` 文件类型。

要为您的项目启用 Rust 扫描，请使用[依赖项扫描 CI/CD 组件](https://jihulab.com/explore/catalog/components/dependency-scanning)中的 `cargo` 模板。

<a id="display-sbom-ingestion-errors-in-gitlab-ui"></a>

### 在极狐GitLab UI 中显示 SBOM 摄取错误

{{< details >}}

- Tier: 旗舰版
- Offering: JihuLab.com
- Links: [文档](../../user/application_security/dependency_list/_index.md) | 相关史诗

{{< /details >}}

极狐GitLab 15.3 添加了对[摄取 CycloneDX SBOM](../../ci/yaml/artifacts_reports.md#artifactsreportscyclonedx) 的支持。虽然 SBOM 报告会根据 CycloneDX 模式进行验证，但验证过程中产生的任何警告和错误都不会向用户显示。

在极狐GitLab 17.3 中，这些验证消息会显示在极狐GitLab UI 的项目级漏洞报告和依赖项列表页面上。

用户将能够在极狐GitLab UI 的以下区域查看 SBOM 摄取错误：项目级漏洞报告和依赖项列表页面，流水线页面的许可证和安全选项卡。

<a id="enforce-the-ruleset-used-in-sast-iac-scanning-and-secret-detection"></a>

### 强制执行 SAST、IaC 扫描和密钥检测中使用的规则集

{{< details >}}

- Tier: 旗舰版
- Offering: JihuLab.com
- Links: [文档](../../user/application_security/sast/customize_rulesets.md#use-a-remote-ruleset-file)

{{< /details >}}

您可以通过创建提交到仓库中的本地配置文件，或通过设置 CI/CD 变量以在多个项目间应用共享配置，来自定义 [SAST](../../user/application_security/sast/customize_rulesets.md)、[IaC 扫描](../../user/application_security/iac_scanning/_index.md#optimize-iac-scanning) 和 [密钥检测](../../user/application_security/secret_detection/pipeline/configure.md#customize-analyzer-behavior) 中使用的规则。

以前，即使您还设置了共享规则集引用，扫描器也会优先使用本地配置文件。
这种优先级顺序使得难以确保扫描使用已知的、可信的规则集。

现在，我们添加了一个新的 CI/CD 变量 `SECURE_ENABLE_LOCAL_CONFIGURATION`，用于控制是否允许本地配置文件。
它默认为 `true`，保持现有行为：允许本地配置文件，并优先于共享配置。
如果您在[强制执行扫描执行](../../user/application_security/policies/scan_execution_policies.md)时将值设置为 `false`，则可以确保扫描使用您的共享规则集或默认规则集，即使项目开发者添加了本地配置文件。

<a id="filter-jobs-by-job-name"></a>

### 按作业名称筛选作业

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: JihuLab.com
- Links: [文档](../../ci/jobs/_index.md) | 相关议题

{{< /details >}}

现在，您可以通过搜索作业名称快速找到特定作业。

以前，您只能按状态筛选作业列表，需要手动滚动才能找到特定作业。在此版本中，您现在可以输入作业名称来筛选结果。结果将仅包含在极狐GitLab 17.3 发布后运行的流水线中的作业。

<a id="merge-train-visualization"></a>

### 合并队列可视化

{{< details >}}

- Tier: 专业版，旗舰版
- Offering: JihuLab.com
- Links: [文档](../../ci/pipelines/merge_trains.md) | 相关史诗

{{< /details >}}

现在，您可以可视化合并队列，以更好地了解流水线中合并请求的状态和顺序。借助合并队列可视化，您可以更早地识别冲突，直接在合并队列中对合并请求采取行动，并最大程度地降低破坏默认分支的风险。

<a id="gitlab-runner-173"></a>

### 极狐GitLab Runner 17.3

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Links: [文档](https://gitlab.cn/docs/runner)

{{< /details >}}

今天，我们发布了极狐GitLab Runner 17.3！极狐GitLab Runner 是轻量级、高度可扩展的代理，用于运行您的 CI/CD 作业并将结果发送回极狐GitLab 实例。极狐GitLab Runner 与极狐GitLab CI/CD 配合使用，极狐GitLab CI/CD 是极狐GitLab 中包含的开源持续集成服务。

<a id="bug-fixes"></a>

#### 错误修复

- 在 Kubernetes runner 中取消作业时，作业似乎挂起
- 未指定时日志级别未更新
- 使用 runner Kubernetes executor 时作业日志添加额外换行符

有关所有更改的列表，请参阅极狐GitLab Runner [变更日志](https://jihulab.com/gitlab-cn/gitlab-runner/blob/17-3-stable/CHANGELOG.md)。

<a id="improved-performance-for-hosted-runners-on-macos"></a>

### macOS 上托管 Runner 的性能改进

{{< details >}}

- Tier: Silver, Gold
- Offering: JihuLab.com
- Links: [文档](../../ci/runners/hosted_runners/macos.md) | 相关议题

{{< /details >}}

我们通过最近升级到 macOS 14.5 和 Xcode 15.4 提供了性能改进。通过此更改，Xcode 构建作业比以前执行作业时显著加快。

<a id="description-and-type-added-to-cicd-catalog-component-input-details"></a>

### CI/CD 目录组件输入详情中添加了描述和类型

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Links: [文档](../../ci/components/_index.md#cicd-catalog) | 相关议题

{{< /details >}}

目录中 CI/CD 组件的详情页面提供了有关该组件的有用信息。在此版本中，我们在显示可用输入信息的表格中添加了两列。新的 **描述** 和 **类型** 列使您更容易理解输入的用途以及期望的值类型。