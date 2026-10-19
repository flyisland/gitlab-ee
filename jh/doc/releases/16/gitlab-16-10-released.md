---
stage: Release Notes
group: Monthly Release
date: 2024-03-21
title: "极狐GitLab 16.10 发布说明"
description: "极狐GitLab 16.10 发布，在 CI/CD catalog 中支持语义化版本"
---

<!-- markdownlint-disable -->
<!-- vale off -->

2024 年 3 月 21 日，极狐GitLab 16.10 发布，包含以下功能。

<a id="primary-features"></a>

## 主要功能

<a id="semantic-versioning-in-the-cicd-catalog"></a>

### 在 CI/CD catalog 中支持语义化版本

<!-- categories: Pipeline Composition -->

{{< details >}}

- 适用版本: 基础版、专业版、旗舰版
- 交付方式: JihuLab.com、私有化部署
- 链接: [文档](../../ci/components/_index.md#component-versions) | [相关议题](https://gitlab.com/gitlab-org/gitlab/-/issues/442238)

{{< /details >}}

为确保已发布组件的行为保持一致，在极狐GitLab 16.10 中，我们将对发布到 CI/CD catalog 的组件强制实施语义化版本。发布组件时，标签必须遵循 3 位语义化版本标准（例如 `1.0.0`）。

使用 `include: component` 语法引用组件时，您应使用已发布的语义化版本。仍然支持使用 `~latest`，但它始终返回最新发布的版本，因此必须谨慎使用，因为它可能包含破坏性变更。暂不支持简写语法，但将在即将到来的里程碑中提供。

<a id="gitlab-duo-access-governance-control"></a>

### 极狐GitLab Duo 访问治理控制

<!-- categories: Duo Chat -->

{{< details >}}

- 适用版本: 专业版、旗舰版
- 交付方式: 私有化部署
- 链接: [文档](../../user/gitlab_duo/turn_on_off.md)

{{< /details >}}

生成式 AI 正在彻底改变工作流程，现在您可以在不损害隐私、合规性或知识产权（IP）保护的前提下，推动这些技术的采用。

现在，您可以通过 API 为项目、群组或实例禁用极狐GitLab Duo AI 功能。之后，您可以在准备好时为特定项目或群组启用极狐GitLab Duo。这些变更是使 AI 功能控制更加精细化的一系列预期工作的一部分。

<a id="wiki-templates"></a>

### Wiki 模板

<!-- categories: Wiki -->

{{< details >}}

- 适用版本: 基础版、专业版、旗舰版
- 交付方式: JihuLab.com、私有化部署
- 链接: [文档](../../user/project/wiki/_index.md#wiki-page-templates) | [相关议题](https://gitlab.com/gitlab-org/gitlab/-/issues/16608)

{{< /details >}}

此版本的极狐GitLab 为 Wiki 引入了全新的模板。现在，您可以创建模板，以简化创建新页面或修改现有页面的流程。模板是存储在 Wiki 代码仓库中 templates 目录下的 Wiki 页面。

通过此增强功能，您可以让 Wiki 页面布局更加一致，更快地创建或重构页面，并确保知识库中的信息清晰、连贯地呈现。

<a id="new-clickhouse-integration-for-high-performance-devops-analytics"></a>

### 用于高性能 DevOps 分析的全新 ClickHouse 集成

<!-- categories: Value Stream Management -->

{{< details >}}

- 交付方式: JihuLab.com
- 链接: [文档](../../user/group/contribution_analytics/_index.md) | [相关议题](https://gitlab.com/gitlab-org/gitlab/-/issues/428260)

{{< /details >}}

[贡献分析报告](../../user/group/contribution_analytics/_index.md)现在性能更高，在 JihuLab.com 上由使用 ClickHouse 的高级分析数据库提供支持。此次升级为新的广泛分析和报告功能奠定了基础，使我们能够跨多个维度提供高性能的分析聚合、筛选和切片。在[议题 441626](https://gitlab.com/gitlab-org/gitlab/-/issues/441626)中提议支持私有化部署客户使用此能力。

尽管 ClickHouse 增强了极狐GitLab 的分析能力，但它并非用于替代 PostgreSQL 或 Redis，现有能力保持不变。

<a id="offload-ci-traffic-to-geo-secondaries"></a>

### 将 CI 流量卸载到 Geo 从站点

<!-- categories: Geo Replication -->

{{< details >}}

- 适用版本: 专业版、旗舰版
- 交付方式: 私有化部署
- 链接: [文档](../../administration/geo/secondary_proxy/runners.md) | [相关史诗](https://gitlab.com/groups/gitlab-org/-/epics/9779)

{{< /details >}}

现在，您可以将 CI Runner 流量卸载到 Geo 从站点。将 Runner 集群部署在运维和管理更方便、更经济的位置，同时减少跨区域流量。将负载分布到多个 Geo 从站点。减轻主站点的负载，为服务开发者流量保留资源。完成此设置后，开发者体验是透明且无缝的。开发者设置和配置作业的工作流程保持不变。

<a id="scale-and-deployments"></a>

## 规模与部署

<a id="gitlab-chart-improvements"></a>

### GitLab chart 改进

<!-- categories: Cloud Native Installation -->

{{< details >}}

- 适用版本: 基础版、专业版、旗舰版
- 交付方式: 私有化部署
- 链接: [文档](https://gitlab.cn/docs/charts/)

{{< /details >}}

在极狐GitLab 16.10 中，我们移除了在 Kubernetes 1.24 及更早版本上安装极狐GitLab 的支持。Kubernetes 1.24 的维护支持已于 2023 年 7 月结束。

极狐GitLab 16.10 包含在 Kubernetes 1.27 上安装极狐GitLab 的支持。有关更多信息，请参阅我们新的 [Kubernetes 版本支持政策](https://handbook.gitlab.com/handbook/engineering/careers/matrix/infrastructure/core-platform/distribution/)。我们的目标是在更接近 Kubernetes 官方发布的时间点支持较新版本。

<a id="omnibus-improvements"></a>

### Omnibus 改进

<!-- categories: Omnibus Package -->

{{< details >}}

- 适用版本: 基础版、专业版、旗舰版
- 交付方式: 私有化部署
- 链接: [文档](https://gitlab.cn/docs/omnibus/)

{{< /details >}}

极狐GitLab 16.10 引入了 Patroni 的新主版本 3.0.1。此版本升级将需要停机。有关更多信息和说明，请参阅[极狐GitLab 16 变更页面的 16.10 部分](../../update/versions/gitlab_16_changes.md#16100)。

极狐GitLab 16.10 还包含新版本的 Alertmanager，即 0.27 版本。最值得注意的是，此版本移除了 API v1。有关此版本的更多信息，请参阅 [Alertmanager 变更日志](https://github.com/prometheus/alertmanager/blob/v0.27.0/CHANGELOG.md#0270--2024-02-28)。

极狐GitLab 16.10 还包含 [Mattermost 9.5](https://docs.mattermost.com/deploy/mattermost-changelog.html#release-v9-5-extended-support-release)。
Mattermost 9.5 包含各种安全更新，并弃用对 MySQL 5.7 的支持。使用此版本 MySQL 的用户必须更新。

<a id="filter-members-by-enterprise-users-with-graphql-api"></a>

### 使用 GraphQL API 按企业用户筛选成员

<!-- categories: Groups & Projects -->

{{< details >}}

- 适用版本: 基础版
- 交付方式: JihuLab.com
- 链接: [文档](../../api/graphql/reference/_index.md#groupgroupmembers) | [相关议题](https://gitlab.com/gitlab-org/gitlab/-/issues/356062)

{{< /details >}}

使用 GraphQL API，您现在可以按企业用户筛选群组成员。

<a id="blocked-users-are-excluded-from-the-followers-list"></a>

### 被阻止的用户从关注者列表中排除

<!-- categories: User Profile -->

{{< details >}}

- 适用版本: 基础版、专业版、旗舰版
- 交付方式: JihuLab.com、私有化部署
- 链接: [文档](../../user/profile/_index.md#follow-users) | [相关议题](https://gitlab.com/gitlab-org/gitlab/-/issues/441774)

{{< /details >}}

此前，当关注您的用户被阻止时，他们仍会出现在您用户个人资料的关注者列表中。从极狐GitLab 16.10 起，被阻止的用户会从关注者列表中隐藏。如果该用户被解除阻止，他们将重新出现在关注者列表中。

感谢 @SethFalco 的这一社区贡献！

<a id="filter-groups-by-visibility-in-the-rest-api"></a>

### 在 REST API 中按可见性筛选群组

<!-- categories: Groups & Projects -->

{{< details >}}

- 适用版本: 基础版、专业版、旗舰版
- 交付方式: JihuLab.com、私有化部署
- 链接: [文档](../../api/groups.md#list-groups) | [相关议题](https://gitlab.com/gitlab-org/gitlab/-/issues/429314)

{{< /details >}}

现在，您可以在 [群组 API](../../api/groups.md)中按可见性筛选群组。您可以使用筛选功能专注于具有特定可见性级别的群组，从而更轻松地审计极狐GitLab 部署。

感谢 @imskr 的这一社区贡献！

<a id="updated-project-deletion-functionality"></a>

### 更新后的项目删除功能

<!-- categories: Groups & Projects -->

{{< details >}}

- 适用版本: 专业版、旗舰版
- 交付方式: JihuLab.com、私有化部署
- 链接: [文档](../../user/project/working_with_projects.md) | [相关议题](https://gitlab.com/gitlab-org/gitlab/-/issues/443682)

{{< /details >}}

现在，在项目列表中识别已删除的项目更加容易。从极狐GitLab 16.10 起，已删除的项目会在项目概览页面的项目标题旁显示 `Pending deletion`（等待删除）徽章。一条提醒消息会说明已删除的项目为只读。此消息在所有项目页面上可见，以确保即使在已删除项目的子页面上工作时也不会丢失此上下文。

<a id="threaded-notifications-supported-in-google-chat"></a>

### Google Chat 中支持讨论串通知

<!-- categories: Settings -->

{{< details >}}

- 适用版本: 基础版、专业版、旗舰版
- 交付方式: JihuLab.com、私有化部署
- 链接: [文档](../../user/project/integrations/hangouts_chat.md) | [相关议题](https://gitlab.com/gitlab-org/gitlab/-/issues/438452)

{{< /details >}}

此前，从极狐GitLab 发送到 Google Chat 中某个空间的通知无法创建为指定讨论串的回复。在此版本中，对于同一极狐GitLab 对象（例如议题或合并请求），Google Chat 中默认启用讨论串通知。

感谢 [Robbie Demuth](https://gitlab.com/robbie-demuth)的[这一社区贡献](https://gitlab.com/gitlab-org/gitlab/-/merge_requests/145187)！

<a id="custom-payload-template-for-webhooks"></a>

### Webhook 的自定义负载模板

<!-- categories: Notifications -->

{{< details >}}

- 适用版本: 基础版、专业版、旗舰版
- 交付方式: JihuLab.com、私有化部署
- 链接: [文档](../../user/project/integrations/webhooks.md#custom-webhook-template) | [相关议题](https://gitlab.com/gitlab-org/gitlab/-/issues/362504)

{{< /details >}}

此前，极狐GitLab Webhook 只能发送特定的 JSON 负载，这意味着接收端点必须理解 Webhook 格式。要使用这些 Webhook，您必须使用专门支持极狐GitLab 的应用，或编写自己的端点。

在此版本中，您可以在 Webhook 配置中设置自定义负载模板。请求正文将根据模板和当前事件的数据渲染。

感谢 [Niklas](https://gitlab.com/Taucher2003)的[这一社区贡献](https://gitlab.com/gitlab-org/gitlab/-/merge_requests/142738)！

<a id="create-service-desk-tickets-from-the-ui-and-api"></a>

### 从 UI 和 API 创建服务台工单

<!-- categories: Service Desk -->

{{< details >}}

- 适用版本: 基础版、专业版、旗舰版
- 交付方式: JihuLab.com、私有化部署
- 链接: [文档](../../user/project/service_desk/using_service_desk.md#create-a-service-desk-ticket-in-gitlab-ui) | [相关议题](https://gitlab.com/gitlab-org/gitlab/-/issues/433376)

{{< /details >}}

现在，您可以在普通议题上使用 `/convert_to_ticket user@example.com` 快捷操作，从 UI 和 API 创建服务台工单。

创建一个普通议题，并添加一条包含 `/convert_to_ticket user@example.com` 快捷操作的评论。所提供的电子邮件地址将成为该工单的外部作者。极狐GitLab 不会发送[默认的感谢邮件](../../user/project/service_desk/configure.md)。您可以在工单上添加公开评论，让外部参与者知道工单已创建。

使用 API 添加服务台工单遵循相同的概念：使用 [议题 API](../../api/issues.md) 创建议题，并使用 `issue_iid` 通过 [评论 API](../../api/notes.md) 添加包含快捷操作的评论。

<a id="unified-devops-and-security"></a>

## 统一 DevOps 与安全

<a id="automatically-collapse-generated-files-in-merge-requests"></a>

### 在合并请求中自动折叠生成的文件

<!-- categories: Code Review Workflow -->

{{< details >}}

- 适用版本: 基础版、专业版、旗舰版
- 交付方式: 私有化部署
- 链接: [文档](../../user/project/merge_requests/changes.md#collapse-generated-files)

{{< /details >}}

合并请求可能包含来自用户以及自动化流程或编译器的变更。诸如 `package-lock.json`、`Gopkg.lock` 以及压缩后的 `js` 和 `css` 文件会增加合并请求评审中显示的文件数量，并分散审核人对人工生成变更的注意力。合并请求现在默认折叠显示这些文件，以帮助：

- 将审核人的注意力集中在重要变更上，但如有需要也可启用完整评审。
- 减少加载合并请求所需的数据量，这可能有助于较大的合并请求获得更好的性能。

有关默认折叠的文件类型示例，请参阅[文档](../../user/project/merge_requests/changes.md#collapse-generated-files)。要在合并请求中折叠更多文件和文件类型，请在项目的 `.gitattributes` 文件中将它们指定为 `gitlab-generated`。

您可以在[议题 438727](https://gitlab.com/gitlab-org/gitlab/-/issues/438727)中对此变更留下反馈。

<a id="expanded-checks-in-merge-widget"></a>

### 合并请求小部件中扩展的检查

<!-- categories: Code Review Workflow -->

{{< details >}}

- 适用版本: 基础版、专业版、旗舰版
- 交付方式: 私有化部署
- 链接: [文档](../../user/project/merge_requests/auto_merge.md)

{{< /details >}}

合并请求小部件会清楚地说明您的合并请求是否不可合并，以及原因。此前，一次只显示一个合并阻碍因素。这增加了评审周期，并迫使您逐个解决问题，而不知道是否还有更多阻碍因素。

当您查看合并请求时，合并请求小部件现在会为您提供问题的全面视图，包括仍存在的和已解决的。现在，您可以一目了然地了解是否存在多个阻碍因素，在一次迭代中全部修复，并更有信心地确保没有遗漏隐藏的阻碍因素。

<a id="manually-refresh-the-dashboard-for-kubernetes"></a>

### 手动刷新 Kubernetes 仪表板

<!-- categories: Environment Management -->

{{< details >}}

- 适用版本: 基础版、专业版、旗舰版
- 交付方式: JihuLab.com、私有化部署
- 链接: [文档](../../ci/environments/kubernetes_dashboard.md) | [相关议题](https://gitlab.com/gitlab-org/gitlab/-/issues/429531)

{{< /details >}}

极狐GitLab 16.10 为 Kubernetes 仪表板添加了专用的刷新功能。现在，您可以手动获取 Kubernetes 资源数据，并确保能够访问有关集群的最新信息。

<a id="improved-environment-details-page"></a>

### 改进的环境详情页面

<!-- categories: Environment Management -->

{{< details >}}

- 适用版本: 基础版、专业版、旗舰版
- 交付方式: JihuLab.com、私有化部署
- 链接: [文档](../../ci/environments/_index.md) | [相关议题](https://gitlab.com/gitlab-org/gitlab/-/issues/431746)

{{< /details >}}

环境详情页面在极狐GitLab 16.10 中得到改进。当您从环境列表中选择一个环境时，您可以在一个便捷的布局中查看有关部署和已连接 Kubernetes 集群的最新信息。

<a id="improved-error-message-for-authentication-rate-limit"></a>

### 改进的认证速率限制错误消息

<!-- categories: System Access -->

{{< details >}}

- 适用版本: 基础版、专业版、旗舰版
- 交付方式: JihuLab.com、私有化部署
- 链接: [文档](../../rate_limits/abuse_bans.md#failed-authentication-ban-for-git-and-container-registry) | [相关议题](https://gitlab.com/gitlab-org/gitlab/-/issues/22787)

{{< /details >}}

在使用极狐GitLab 进行认证时，可能会触及认证尝试速率限制，例如在使用脚本时。此前，如果您触及认证速率限制，会返回 `403 Forbidden` 消息，但并未说明您为何收到此错误。现在，我们会返回更具描述性的错误消息，告知您已触及认证速率限制。

<a id="audit-event-scope-attribute"></a>

### 审计事件 `scope` 属性

<!-- categories: Compliance Management -->

{{< details >}}

- 适用版本: 专业版、旗舰版
- 交付方式: JihuLab.com、私有化部署
- 链接: [文档](../../administration/compliance/audit_event_reports.md)

{{< /details >}}

审计事件现在包含 `scope` 属性，用于指示该事件是与整个实例、群组、项目还是用户相关联。

此新属性可帮助用户在审计事件负载中确定事件的来源。它还使我们的[审计事件类型文档](../../administration/compliance/audit_event_reports.md)能够列出审计事件类型的所有可用范围。

您可以使用此新属性来解析外部流式传输目标，或更好地理解事件周围的上下文。

<a id="custom-names-for-service-accounts"></a>

### 服务账号的自定义名称

<!-- categories: User Management -->

{{< details >}}

- 适用版本: 专业版、旗舰版
- 交付方式: JihuLab.com、私有化部署
- 链接: [文档](../../user/profile/service_accounts.md#create-a-service-account) | [相关议题](https://gitlab.com/gitlab-org/gitlab/-/issues/415973)

{{< /details >}}

现在，您可以自定义服务账号的用户名和显示名称。此前，这些由极狐GitLab 自动生成。使用自定义名称，可以更轻松地理解服务账号的用途，并将其与用户列表中的其他账号区分开来。

<a id="audit-event-for-assigning-a-custom-role"></a>

### 分配自定义角色的审计事件

<!-- categories: Permissions -->

{{< details >}}

- 适用版本: 专业版、旗舰版
- 交付方式: JihuLab.com、私有化部署
- 链接: [文档](../../administration/compliance/audit_event_reports.md) | [相关议题](https://gitlab.com/gitlab-org/gitlab/-/issues/427954)

{{< /details >}}

现在，当为用户分配不同角色时，极狐GitLab 会记录审计事件，无论该角色是默认角色还是自定义角色。在发生权限提升的情况下，此事件对于识别用户权限是否被添加或更改非常重要。

<a id="new-permissions-for-custom-roles"></a>

### 自定义角色的新权限

<!-- categories: Permissions -->

{{< details >}}

- 适用版本: 旗舰版
- 交付方式: JihuLab.com、私有化部署
- 链接: [文档](../../user/custom_roles/_index.md) | [相关议题](https://gitlab.com/gitlab-org/gitlab/-/issues/391760)

{{< /details >}}

要创建自定义角色，您现在可以选择两个新权限：

- 管理 CI/CD 变量
- 删除群组的能力

随着这些自定义权限的发布，您可以通过创建具有这些等同于所有者权限的自定义角色，减少群组中所需的所有者数量。自定义角色让您可以定义精细的角色，仅授予用户完成工作所需的权限，并减少不必要的权限提升。

<a id="scan-result-policies-are-now-merge-request-approval-policies"></a>

### 扫描结果策略现更名为“合并请求审批策略”

<!-- categories: Security Policy Management -->

{{< details >}}

- 适用版本: 旗舰版
- 交付方式: JihuLab.com、私有化部署
- 链接: [文档](../../user/application_security/policies/merge_request_approval_policies.md) | [相关史诗](https://gitlab.com/groups/gitlab-org/-/epics/9850)

{{< /details >}}

随着我们扩展该策略类型的能力，以支持覆盖项目设置和强制执行审批要求，我们将策略名称更新为更贴切的“合并请求审批策略”。

合并请求审批策略不会取代或与现有的合并请求审批规则冲突。相反，它们为旗舰版客户提供了通过由中央安全和合规团队管理的策略，跨项目创建全局强制执行的能力——这对大规模组织而言是一项日益艰巨的任务。

<a id="webhooks-support-mutual-tls"></a>

### Webhook 支持双向 TLS

<!-- categories: System Access -->

{{< details >}}

- 适用版本: 基础版、专业版、旗舰版
- 交付方式: 私有化部署
- 链接: [文档](../../user/project/integrations/webhooks.md#configure-webhooks-to-support-mutual-tls) | [相关议题](https://gitlab.com/gitlab-org/gitlab/-/issues/27450)

{{< /details >}}

现在，您可以配置 Webhook 以支持双向 TLS。此配置可确立 Webhook 来源的真实性并增强安全性。您需要配置 PEM 格式的客户端证书，该证书会在 TLS 握手期间呈现给服务器。您还可以使用 PEM 密码短语保护该证书。

<a id="sign-in-page-improvements"></a>

### 登录页面改进

<!-- categories: System Access -->

{{< details >}}

- 适用版本: 基础版、专业版、旗舰版
- 交付方式: JihuLab.com、私有化部署
- 链接: [文档](https://gitlab.com/gitlab-org/gitlab/-/issues/412845) | [相关议题](https://gitlab.com/gitlab-org/gitlab/-/issues/412845)

{{< /details >}}

极狐GitLab 登录页面已焕然一新，修复了间距问题、损坏的元素和对齐问题。此外还增加了对深色模式的额外支持，以及一个管理 Cookie 首选项的按钮。这些改进的结合为登录页面带来了全新的外观和增强的功能。

<a id="smart-card-support-for-active-directory-ldap"></a>

### Active Directory LDAP 的智能卡支持

<!-- categories: User Management -->

{{< details >}}

- 适用版本: 专业版、旗舰版
- 交付方式: 私有化部署
- 链接: [文档](../../administration/auth/smartcard.md#authentication-against-an-active-directory-ldap-server) | [相关议题](https://gitlab.com/gitlab-org/gitlab/-/issues/328074)

{{< /details >}}

针对 LDAP 服务器的智能卡认证现在支持 Entra ID（以前称为 Azure Active Directory）。这使得从 Entra ID 同步用户身份数据，并使用智能卡针对 LDAP 进行认证变得容易。

<a id="use-merge-base-pipeline-for-merge-request-approval-policy-comparison"></a>

### 使用合并基础流水线进行合并请求审批策略比较

<!-- categories: Security Policy Management -->

{{< details >}}

- 适用版本: 旗舰版
- 交付方式: JihuLab.com、私有化部署
- 链接: [文档](../../user/application_security/policies/merge_request_approval_policies.md#understanding-merge-request-approval-policy-approvals) | [相关议题](https://gitlab.com/gitlab-org/gitlab/-/issues/428518)

{{< /details >}}

此增强功能使合并请求审批策略评估的逻辑与安全合并请求小部件保持一致，确保违反合并请求审批策略的发现项与小部件中显示的结果一致。通过统一逻辑，安全、合规和开发团队可以更一致地识别哪些发现项违反了策略并需要审批。现在，扫描结果策略不再与目标分支最新完成的 `HEAD` 流水线进行比较，而是与共同祖先最新完成的流水线（即“合并基础”）进行比较。

<a id="support-domain-level-redirects-for-gitlab-pages"></a>

### 支持 GitLab Pages 的域级重定向

<!-- categories: Pages -->

{{< details >}}

- 适用版本: 基础版、专业版、旗舰版
- 交付方式: JihuLab.com、私有化部署
- 链接: [文档](../../user/project/pages/redirects.md#domain-level-redirects) | [相关议题](https://gitlab.com/gitlab-org/gitlab-pages/-/issues/601)

{{< /details >}}

此前，极狐GitLab 专注于支持简单的重定向规则。在极狐GitLab 14.3 中，我们[引入](https://gitlab.com/gitlab-org/gitlab-pages/-/merge_requests/458)了对 splat 和占位符重定向的支持。

从极狐GitLab 16.10 起，GitLab Pages 支持域级重定向。您可以将域级重定向与 [splat 规则](https://gitlab.com/gitlab-org/gitlab-pages/-/issues/601)结合使用，以动态重写 URL 路径。此改进有助于防止混淆，并确保您在域名变更后仍能找到您的信息，即使您使用的是旧域名。

<a id="list-repository-tags-with-the-new-container-registry-api"></a>

### 使用新的容器镜像仓库 API 列出容器仓库标签

<!-- categories: Container Registry -->

{{< details >}}

- 适用版本: 基础版
- 链接: [文档](../../api/container_registry.md) | [相关史诗](https://gitlab.com/groups/gitlab-org/-/epics/10208)

{{< /details >}}

此前，容器镜像仓库依赖 Docker/OCI [列出镜像标签的仓库 API](https://gitlab.com/gitlab-org/container-registry/-/blob/5208a0ce1600b535e529cd857c842fda6d19ad59/docs/spec/docker/v2/api.md#listing-image-tags) 在极狐GitLab 中显示标签。此 API 存在显著的性能和可发现性限制。

此 API 执行缓慢，因为针对镜像仓库的网络请求数量会随标签列表中的标签数量而增加。此外，由于该 API 不跟踪发布时间，发布时间戳常常不正确。在基于 Docker manifest 列表或 OCI 索引显示镜像（例如多架构镜像）时也存在限制。

为解决这些限制，我们引入了新的镜像仓库[列出容器仓库标签 API](https://gitlab.com/gitlab-org/container-registry/-/blob/5208a0ce1600b535e529cd857c842fda6d19ad59/docs/spec/gitlab/api.md#list-repository-tags)。在极狐GitLab 16.10 中，我们完成了向新 API 的迁移。现在，无论您使用 UI 还是 REST API，都可以期待改进的性能、准确的发布时间戳以及对多架构镜像的稳健支持。

此改进仅在 JihuLab.com 上可用。在下一代容器镜像仓库正式发布之前，私有化部署支持被阻止。要了解更多信息，请参阅[议题 423459](https://gitlab.com/gitlab-org/gitlab/-/issues/423459)。

<a id="new-contributor-count-metric-in-the-value-streams-dashboard"></a>

### 价值流仪表板中新增贡献者数量指标

<!-- categories: Value Stream Management -->

{{< details >}}

- 交付方式: JihuLab.com
- 链接: [文档](../../user/analytics/value_streams_dashboard.md) | [相关议题](https://gitlab.com/gitlab-org/gitlab/-/issues/433353)

{{< /details >}}

为了让软件领导者能够深入了解团队速度、软件稳定性、安全暴露和团队生产力之间的关系，我们在[价值流仪表板中引入了新的**贡献者数量**指标](../../user/analytics/value_streams_dashboard.md#dashboard-metrics-and-drill-down-reports)。贡献者数量表示群组中每月有贡献的唯一用户数。此指标旨在跟踪随时间推移的采用趋势，并基于[贡献日历事件](../../user/profile/contributions_calendar.md#user-contribution-events)。

**贡献者数量**指标仅在 JihuLab.com 上可用，并且需要[将贡献分析报告配置为通过 ClickHouse 运行](../../user/group/contribution_analytics/_index.md#contribution-analytics-with-clickhouse)。[议题 441626](https://gitlab.com/gitlab-org/gitlab/-/issues/441626) 跟踪了使此功能也可供私有化部署客户使用的努力。

<a id="inherited-filters-in-value-stream-analytics-for-seamless-and-accurate-workflow-analysis"></a>

### 价值流分析中的继承筛选器，实现无缝且准确的工作流分析

<!-- categories: Value Stream Management -->

{{< details >}}

- 适用版本: 专业版、旗舰版
- 交付方式: JihuLab.com、私有化部署
- 链接: [文档](../../user/group/issues_analytics/_index.md) | [相关议题](https://gitlab.com/gitlab-org/gitlab/-/issues/439615)

{{< /details >}}

[价值流分析](../../user/group/value_stream_analytics/_index.md)现在在从**前置时间**磁贴下钻到[**议题分析**报告](../../user/group/issues_analytics/_index.md)时应用相同的筛选器。筛选器继承可帮助您在切换分析视图时更深入、无缝地探索数据。

<a id="add-an-issue-to-the-current-or-next-iteration-with-a-quick-action"></a>

### 使用快捷操作将议题添加到当前或下一个迭代

<!-- categories: Team Planning -->

{{< details >}}

- 适用版本: 专业版、旗舰版
- 交付方式: JihuLab.com、私有化部署
- 链接: [文档](../../user/project/quick_actions.md) | [相关议题](https://gitlab.com/gitlab-org/gitlab/-/issues/384885)

{{< /details >}}

`/iteration` 快捷操作现在接受带有 `--current` 或 `--next` 参数的节奏引用。如果您的群组只有一个迭代节奏，您可以使用 `/iteration --current|next` 快速将议题分配到当前或下一个迭代。如果您的群组包含多个迭代节奏，您可以通过引用节奏名称或 ID 在快捷操作中指定所需的节奏。例如，`/iteration [cadence:"<cadence name>"|<cadence ID>] --next|current`。

<a id="continuous-vulnerability-scanning-available-by-default-for-container-scanning"></a>

### 持续漏洞扫描默认可用于容器扫描

<!-- categories: Software Composition Analysis -->

{{< details >}}

- 适用版本: 旗舰版
- 交付方式: JihuLab.com、私有化部署
- 链接: [文档](../../user/application_security/continuous_vulnerability_scanning/_index.md) | [相关史诗](https://gitlab.com/groups/gitlab-org/-/epics/10174)

{{< /details >}}

容器扫描的持续漏洞扫描现已默认可用。默认可用后，无需再通过功能标志选择启用此功能。要了解有关持续漏洞扫描优势的更多信息，请参阅文档链接。

<a id="improved-dependency-scanning-support-for-sbt"></a>

### 改进的 sbt 依赖扫描支持

<!-- categories: Software Composition Analysis -->

{{< details >}}

- 适用版本: 旗舰版
- 交付方式: JihuLab.com、私有化部署
- 链接: [文档](../../user/application_security/dependency_scanning/legacy_dependency_scanning/_index.md#supported-languages-and-package-managers) | [相关议题](https://gitlab.com/gitlab-org/gitlab/-/issues/390287)

{{< /details >}}

我们更新了用于为使用 sbt 的项目生成依赖列表的机制。此变更仅适用于使用 sbt 1.7.2 及更高版本的项目。要充分利用 sbt 项目的依赖扫描，您应升级到 sbt 1.7.2 及更高版本。

<a id="dast-analyzer-performance-updates"></a>

### DAST 分析器性能更新

<!-- categories: DAST -->

{{< details >}}

- 适用版本: 旗舰版
- 交付方式: 私有化部署
- 链接: [文档](../../user/application_security/dast/browser/_index.md) | [相关议题](https://gitlab.com/groups/gitlab-org/-/epics/12194)

{{< /details >}}

在 16.10 发布里程碑期间，基于代理的 DAST：

- 将 ZAP 升级到 2.14.0 版本。有关更多信息，请参阅[议题 442056](https://gitlab.com/gitlab-org/gitlab/-/issues/442056)。

我们还完成了以下基于浏览器的 DAST 爬虫性能改进：

- 限制爬取时创建的 goroutine 数量。有关更多信息，请参阅[议题 440151](https://gitlab.com/gitlab-org/gitlab/-/issues/440151)。
- 优化查找要交互的元素。这将扫描时间减少了 6%。有关更多信息，请参阅[议题 440295](https://gitlab.com/gitlab-org/gitlab/-/issues/440295)。
- 优化 DevTools 消息的 JSON 反序列化。这将扫描时间减少了 7%。有关更多信息，请参阅[议题 439726](https://gitlab.com/gitlab-org/gitlab/-/issues/439726)。

<a id="gitlab-runner-1610"></a>

### 极狐GitLab Runner 16.10

<!-- categories: GitLab Runner Core -->

{{< details >}}

- 适用版本: 基础版、专业版、旗舰版
- 交付方式: 私有化部署
- 链接: [文档](https://gitlab.cn/docs/runner/)

{{< /details >}}

我们今天还发布了极狐GitLab Runner 16.10！极狐GitLab Runner 是轻量级、高度可扩展的代理，用于运行您的 CI/CD 作业并将结果发送回极狐GitLab 实例。极狐GitLab Runner 与极狐GitLab CI/CD 协同工作，后者是极狐GitLab 中包含的开源持续集成服务。

缺陷修复：

- [在 Runner Kubernetes 执行器中取消作业时的内存泄漏](https://gitlab.com/gitlab-org/gitlab-runner/-/issues/27857)

所有变更的列表位于极狐GitLab Runner [CHANGELOG](https://gitlab.com/gitlab-org/gitlab-runner/blob/16-10-stable/CHANGELOG.md)中。
