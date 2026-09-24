```yaml
---
stage: Release Notes
group: Monthly Release
date: 2024-03-21
title: "极狐GitLab 16.10 发行说明"
description: "极狐GitLab 16.10 发布，CI/CD 目录中支持语义化版本"
---

<!-- markdownlint-disable -->
<!-- vale off -->

2024 年 3 月 21 日，极狐GitLab 16.10 发布，包含以下功能。

此外，我们向所有贡献者表示感谢，特别要感谢本月了不起的贡献者。

## 本月了不起的贡献者

[Marco Zille](https://gitlab.com/zillemarco) 又一次获得了极狐GitLab MVP 奖项，他之前在 15.3 中获奖。Marco 不仅因为本次发布中的代码贡献而受到认可，还因为他持续支持极狐GitLab 更广泛的贡献者社区、组织社区结对编程、与极狐GitLab 团队成员协作以及审核合并请求。

Marco 增加了 [在一个作业失败后立即取消流水线的功能](https://gitlab.com/gitlab-org/gitlab/-/issues/23605)。该功能已在 JihuLab.com 上启用并可用，但对于私有化部署实例仍然受功能标志控制。它将在 16.11 中对所有用户可用。

[Allison Browne](https://gitlab.com/allison.browne)，极狐GitLab 高级后端工程师，提名 Marco 处理了这个长期存在且呼声很高的流水线执行功能请求。
[Fabio Pitino](https://gitlab.com/fabiopitino)，极狐GitLab 高级工程师，补充说：“Marco 不仅实现了修复，还为功能设计发挥了重要作用，带来了用例并与对该功能感兴趣的客户进行了讨论。”

[Peter Leitzen](https://gitlab.com/splattael) 还支持了对 Marco 的提名，他强调了 Marco 如何帮助[审查并最终完成了一个修复](https://gitlab.com/gitlab-org/gitlab/-/merge_requests/112813#note_1737719869)，该修复用于从 Sentry 加载堆栈跟踪。

我们非常感谢 Lennard 和 Marco 持续为改进极狐GitLab 以及支持我们的开源社区所做的贡献！🙌

## 主要功能

<a id="semantic-versioning-in-the-cicd-catalog"></a>

### CI/CD 目录中的语义化版本

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: JihuLab.com
- Links: [文档](../../ci/components/_index.md#component-versions) | [相关议题](https://gitlab.com/gitlab-org/gitlab/-/issues/442238)

{{< /details >}}

为了确保已发布组件的一致行为，在极狐GitLab 16.10 中，我们将对发布到 CI/CD 目录的组件强制执行语义化版本。发布组件时，标签必须遵循 3 位语义化版本标准（例如 `1.0.0`）。

在使用带有 `include: component` 语法的组件时，应该使用已发布的语义化版本。`~latest` 仍受支持，但它将始终返回最新发布的版本，因此使用时需谨慎，因为可能包含破坏性变更。简写语法暂不支持，但将在即将到来的里程碑中支持。

<a id="gitlab-duo-access-governance-control"></a>

### 极狐GitLab Duo 访问治理控制

{{< details >}}

- Tier: 专业版，旗舰版
- Links: [文档](../../user/gitlab_duo/turn_on_off.md)

{{< /details >}}

生成式 AI 正在彻底改变工作流程，您现在可以在不影响隐私、合规或知识产权（IP）保护的情况下促进这些技术的采用。

您现在可以使用 API 为项目、群组或实例禁用极狐GitLab Duo AI 功能。当您准备好时，可以为特定的项目或群组启用极狐GitLab Duo。这些变更是使 AI 功能更精细化控制的一系列预期工作的一部分。

<a id="wiki-templates"></a>

### Wiki 模板

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: JihuLab.com
- Links: [文档](../../user/project/wiki/_index.md#wiki-page-templates) | [相关议题](https://gitlab.com/gitlab-org/gitlab/-/issues/16608)

{{< /details >}}

本次极狐GitLab 版本为 Wiki 引入了全新的模板。现在，您可以创建模板来简化新页面的创建或现有页面的修改。模板是存储在 Wiki 仓库中 templates 目录下的 Wiki 页面。

通过此增强功能，您可以使 Wiki 页面布局更加一致，更快地创建或重构页面，并确保信息在您的知识库中清晰、连贯地呈现。

<a id="new-clickhouse-integration-for-high-performance-devops-analytics"></a>

### 全新的 ClickHouse 集成，提供高性能 DevOps 分析

{{< details >}}

- Tier：旗舰版
- Offering：JihuLab.com
- Links: [文档](../../user/group/contribution_analytics/_index.md) | [相关议题](https://gitlab.com/gitlab-org/gitlab/-/issues/428260)

{{< /details >}}

[贡献分析报告](../../user/group/contribution_analytics/_index.md) 现在性能更高，并且由 JihuLab.com 上使用 ClickHouse 构建的高级分析数据库提供支持。此次升级为全新的、丰富的分析和报告功能奠定了基础，使我们能够跨多个维度提供高性能的分析聚合、筛选和切片。私有化部署客户添加此功能的支持已在 [议题 441626](https://gitlab.com/gitlab-org/gitlab/-/issues/441626) 中提出。

尽管 ClickHouse 增强了极狐GitLab 的分析能力，但它并不是为了取代 PostgreSQL 或 Redis，现有功能保持不变。

<a id="offload-ci-traffic-to-geo-secondaries"></a>

### 将 CI 流量卸载到 Geo 从站点

{{< details >}}

- Tier：专业版，旗舰版
- Links: [文档](../../administration/geo/secondary_proxy/runners.md) | [相关史诗](https://gitlab.com/groups/gitlab-org/-/epics/9779)

{{< /details >}}

您现在可以将 CI Runner 流量卸载到 Geo 从站点。将 Runner 集群部署在更方便、更经济的位置进行运营和管理，同时减少跨区域流量。将负载分布到多个 Geo 从站点上。减少主站点的负载，为开发者流量保留资源。完成此设置后，开发者体验是透明和无缝的。开发者关于作业设置和配置的工作流保持不变。

## 规模化与部署

<a id="gitlab-chart-improvements"></a>

### 极狐GitLab Chart 改进

{{< details >}}

- Tier：基础版，专业版，旗舰版
- Links: [文档](https://gitlab.cn/docs/charts/)

{{< /details >}}

在极狐GitLab 16.10 中，我们已移除对 Kubernetes 1.24 及更早版本上安装极狐GitLab 的支持。Kubernetes 1.24 的维护支持已于 2023 年 7 月结束。

极狐GitLab 16.10 包含对在 Kubernetes 1.27 上安装极狐GitLab 的支持。有关更多信息，请参阅我们新的 [Kubernetes 版本支持策略](https://handbook.gitlab.com/handbook/engineering/careers/matrix/infrastructure/core-platform/distribution/)。我们的目标是在 Kubernetes 的新版本正式发布后更接近地支持它们。

<a id="omnibus-improvements"></a>

### Omnibus 改进

{{< details >}}

- Tier：基础版，专业版，旗舰版
- Links: [文档](https://gitlab.cn/docs/omnibus/)

{{< /details >}}

极狐GitLab 16.10 引入了 Patroni 的一个新主版本，版本 3.0.1。此次版本升级需要停机。更多信息和说明，请参阅[极狐GitLab 16 变更页面的 16.10 部分](../../update/versions/gitlab_16_changes.md#16100)。

极狐GitLab 16.10 还包含一个新版本的 Alertmanager，即版本 0.27。最值得注意的是，此版本移除了 API v1。有关此版本的更多信息，请参阅 [Alertmanager 更新日志](https://github.com/prometheus/alertmanager/blob/v0.27.0/CHANGELOG.md#0270--2024-02-28)。

极狐GitLab 16.10 还包含 [Mattermost 9.5](https://docs.mattermost.com/deploy/mattermost-changelog.html#release-v9-5-extended-support-release)。Mattermost 9.5 包括各种安全更新以及弃用对 MySQL 5.7 的支持。使用此 MySQL 版本的用户必须升级。

<a id="filter-members-by-enterprise-users-with-graphql-api"></a>

### 通过 GraphQL API 按企业用户筛选成员

{{< details >}}

- Tier：基础版，白银版，旗舰版
- Offering：JihuLab.com
- Links: [文档](../../api/graphql/reference/_index.md#groupgroupmembers) | [相关议题](https://gitlab.com/gitlab-org/gitlab/-/issues/356062)

{{< /details >}}

现在，您可以使用 GraphQL API 按企业用户筛选群组成员。

<a id="blocked-users-are-excluded-from-the-followers-list"></a>

### 被阻止的用户将从关注者列表中排除

{{< details >}}

- Tier：基础版，专业版，旗舰版
- Offering：JihuLab.com
- Links: [文档](../../user/profile/_index.md#follow-users) | [相关议题](https://gitlab.com/gitlab-org/gitlab/-/issues/441774)

{{< /details >}}

以前，当关注您的用户被阻止时，他们仍然会出现在您的用户资料页面中的关注者列表中。从极狐GitLab 16.10 开始，被阻止的用户将在关注者列表中隐藏。如果该用户被解除阻止，他们将重新出现在关注者列表中。

感谢 @SethFalco 的社区贡献！

<a id="filter-groups-by-visibility-in-the-rest-api"></a>

### 通过 REST API 按可见性筛选群组

{{< details >}}

- Tier：基础版，专业版，旗舰版
- Offering：JihuLab.com
- Links: [文档](../../api/groups.md#list-groups) | [相关议题](https://gitlab.com/gitlab-org/gitlab/-/issues/429314)

{{< /details >}}

现在，您可以在 [群组 API](../../api/groups.md) 中按可见性筛选群组。您可以使用筛选来关注具有特定可见性级别的群组，从而更轻松地审计极狐GitLab 部署。

感谢 @imskr 的社区贡献！

<a id="updated-project-deletion-functionality"></a>

### 更新的项目删除功能

{{< details >}}

- Tier：专业版，旗舰版
- Offering：JihuLab.com
- Links: [文档](../../user/project/working_with_projects.md) | [相关议题](https://gitlab.com/gitlab-org/gitlab/-/issues/443682)

{{< /details >}}

现在，在项目列表中识别已删除的项目变得更加容易。从极狐GitLab 16.10 开始，已删除的项目会在项目概览页面上的项目标题旁边显示一个 `等待删除` 徽章。警告消息说明已删除的项目是只读的。此消息显示在所有项目页面上，以确保即使在已删除项目的子页面上工作，也不会丢失此上下文。

<a id="threaded-notifications-supported-in-google-chat"></a>

### Google Chat 支持线索式通知

{{< details >}}

- Tier：基础版，专业版，旗舰版
- Offering：JihuLab.com
- Links: [文档](../../user/project/integrations/hangouts_chat.md) | [相关议题](https://gitlab.com/gitlab-org/gitlab/-/issues/438452)

{{< /details >}}

以前，从极狐GitLab 发送到 Google Chat 空间的通告无法作为对指定线索的回复创建。在此版本中，对于相同的极狐GitLab 对象（例如议题或合并请求），Google Chat 中默认启用了线索式通知。

感谢 [Robbie Demuth](https://gitlab.com/robbie-demuth) 的 [社区贡献](https://gitlab.com/gitlab-org/gitlab/-/merge_requests/145187)！

<a id="custom-payload-template-for-webhooks"></a>

### Webhook 的自定义载荷模板

{{< details >}}

- Tier：基础版，专业版，旗舰版
- Offering：JihuLab.com
- Links: [文档](../../user/project/integrations/webhooks.md#custom-webhook-template) | [相关议题](https://gitlab.com/gitlab-org/gitlab/-/issues/362504)

{{< /details >}}

以前，极狐GitLab Webhook 只能发送特定的 JSON 载荷，这意味着接收端点必须理解 Webhook 格式。要使用这些 Webhook，您要么必须使用专门支持极狐GitLab 的应用程序，要么编写自己的端点。

在此版本中，您可以在 Webhook 配置中设置自定义载荷模板。请求正文将使用当前事件的数据通过模板进行渲染。

感谢 [Niklas](https://gitlab.com/Taucher2003) 的 [社区贡献](https://gitlab.com/gitlab-org/gitlab/-/merge_requests/142738)！

<a id="create-service-desk-tickets-from-the-ui-and-api"></a>

### 从 UI 和 API 创建服务台工单

{{< details >}}

- Tier：基础版，专业版，旗舰版
- Offering：JihuLab.com
- Links: [文档](../../user/project/service_desk/using_service_desk.md#create-a-service-desk-ticket-in-gitlab-ui) | [相关议题](https://gitlab.com/gitlab-org/gitlab/-/issues/433376)

{{< /details >}}

现在，您可以通过 UI 和 API，在普通议题上使用 `/convert_to_ticket user@example.com` 快速操作来创建服务台工单。

创建一个普通议题，并添加带有 `/convert_to_ticket user@example.com` 快速操作的评论。提供的电子邮件地址将成为工单的外部作者。极狐GitLab 不会发送 [默认感谢邮件](../../user/project/service_desk/configure.md)。您可以在工单上添加公开评论，告知外部参与者工单已创建。

使用 API 添加服务台工单遵循相同概念：使用 [议题 API](../../api/issues.md) 创建议题，然后使用 `issue_iid` 通过 [笔记 API](../../api/notes.md) 添加带有快速操作的笔记。

## 统一 DevOps 与安全

<a id="automatically-collapse-generated-files-in-merge-requests"></a>

### 在合并请求中自动折叠生成的文件

{{< details >}}

- Tier：基础版，专业版，旗舰版
- Links: [文档](../../user/project/merge_requests/changes.md#collapse-generated-files)

{{< /details >}}

合并请求可以包含来自用户和自动化流程或编译器的变更。诸如 `package-lock.json`、`Gopkg.lock` 以及压缩的 `js` 和 `css` 文件之类的文件会增加合并请求审阅中显示的文件数量，并分散审阅者对人为生成更改的注意力。现在，合并请求默认以折叠方式显示这些文件，以帮助：

- 将审阅者的注意力集中在重要的变更上，但如果需要，仍可进行完整审阅。
- 减少加载合并请求所需的数据量，这可能有助于较大合并请求的性能提升。

有关默认折叠的文件类型示例，请参阅 [文档](../../user/project/merge_requests/changes.md#collapse-generated-files)。要在合并请求中折叠更多文件和文件类型，请在项目的 `.gitattributes` 文件中将它们指定为 `gitlab-generated`。

您可以在 [议题 438727](https://gitlab.com/gitlab-org/gitlab/-/issues/438727) 中对此变更提供反馈。

<a id="expanded-checks-in-merge-widget"></a>

### 合并控件中的扩展检查

{{< details >}}

- Tier：基础版，专业版，旗舰版
- Links: [文档](../../user/project/merge_requests/auto_merge.md)

{{< /details >}}

合并控件清楚地说明您的合并请求是否无法合并及其原因。以前，一次只显示一个合并阻止因素。这增加了审阅周期，并迫使您单独解决问题，而不知道是否还有更多阻止因素存在。

当您查看合并请求时，合并控件现在会为您提供问题的全面视图，包括剩余的和已解决的问题。现在，您可以一目了然地了解是否存在多个阻止因素，在单次迭代中修复所有问题，并增强信心，确保没有遗漏隐藏的阻止因素。

<a id="manually-refresh-the-dashboard-for-kubernetes"></a>

### 手动刷新 Kubernetes 仪表盘

{{< details >}}

- Tier：基础版，专业版，旗舰版
- Offering：JihuLab.com
- Links: [文档](../../ci/environments/kubernetes_dashboard.md) | [相关议题](https://gitlab.com/gitlab-org/gitlab/-/issues/429531)

{{< /details >}}

极狐GitLab 16.10 为 Kubernetes 仪表盘添加了专用的刷新功能。现在，您可以手动获取 Kubernetes 资源数据，并确保您可以访问有关集群的最新信息。

<a id="improved-environment-details-page"></a>

### 改进的环境详情页面

{{< details >}}

- Tier：基础版，专业版，旗舰版
- Offering：JihuLab.com
- Links: [文档](../../ci/environments/_index.md) | [相关议题](https://gitlab.com/gitlab-org/gitlab/-/issues/431746)

{{< /details >}}

极狐GitLab 16.10 改进了环境详情页面。当您从环境列表中选择一个环境时，您可以在一个便捷的布局中查看有关部署和已连接 Kubernetes 集群的最新信息。

<a id="improved-error-message-for-authentication-rate-limit"></a>

### 改进的认证速率限制错误消息

{{< details >}}

- Tier：基础版，专业版，旗舰版
- Offering：JihuLab.com
- Links: [文档](../../security/rate_limits.md#failed-authentication-ban-for-git-and-container-registry) | [相关议题](https://gitlab.com/gitlab-org/gitlab/-/issues/22787)

{{< /details >}}

在与极狐GitLab 进行认证时，可能会达到认证尝试速率限制，例如在使用脚本时。以前，如果达到认证速率限制，会返回 `403 Forbidden` 消息，该消息没有解释您为何遇到此错误。现在，我们返回更具描述性的错误消息，告知您已达到认证速率限制。

<a id="audit-event-scope-attribute"></a>

### 审计事件 `scope` 属性

{{< details >}}

- Tier：专业版，旗舰版
- Offering：JihuLab.com
- Links: [文档](../../administration/compliance/audit_event_reports.md)

{{< /details >}}

审计事件现在包含一个 `scope` 属性，该属性指示事件是关联整个实例、群组、项目还是用户。

此新属性可帮助用户确定审计事件负载中事件的来源。它还允许我们的 [审计事件类型文档](../../administration/compliance/audit_event_reports.md) 列出审计事件类型的所有可用范围。

您可以使用此新属性解析外部流目标，或更好地理解事件的上下文。

<a id="custom-names-for-service-accounts"></a>

### 服务账号的自定义名称

{{< details >}}

- Tier：专业版，旗舰版
- Offering：JihuLab.com
- Links: [文档](../../user/profile/service_accounts.md#create-a-service-account) | [相关议题](https://gitlab.com/gitlab-org/gitlab/-/issues/415973)

{{< /details >}}

现在，您可以自定义服务账号的用户名和显示名称。以前，这些是由极狐GitLab 自动生成的。使用自定义名称，可以更容易地理解服务账号的用途，并将其与用户列表中的其他账号区分开来。

<a id="audit-event-for-assigning-a-custom-role"></a>

### 分配自定义角色的审计事件

{{< details >}}

- Tier：专业版，旗舰版
- Offering：JihuLab.com
- Links: [文档](../../administration/compliance/audit_event_reports.md) | [相关议题](https://gitlab.com/gitlab-org/gitlab/-/issues/427954)

{{< /details >}}

现在，当用户被分配了不同的角色时，无论该角色是默认角色还是自定义角色，极狐GitLab 都会记录审计事件。在权限提升的情况下，此事件对于识别用户权限是否已被添加或更改非常重要。

<a id="new-permissions-for-custom-roles"></a>

### 自定义角色的新权限

{{< details >}}

- Tier：旗舰版
- Offering：JihuLab.com
- Links: [文档](../../user/custom_roles/_index.md) | [相关议题](https://gitlab.com/gitlab-org/gitlab/-/issues/391760)

{{< /details >}}

要创建自定义角色，您现在可以选择两个新权限：

- 管理 CI/CD 变量
- 删除群组的能力

随着这些自定义权限的发布，您可以通过创建一个具有这些等同于所有者权限的自定义角色，来减少群组中所需的所有者数量。自定义角色让您可以定义细粒度的角色，只授予用户完成其工作所需的权限，并减少不必要的权限提升。

<a id="scan-result-policies-are-now-merge-request-approval-policies"></a>

### 扫描结果策略现更名为“合并请求批准策略”

{{< details >}}

- Tier：旗舰版
- Offering：JihuLab.com
- Links: [文档](../../user/application_security/policies/merge_request_approval_policies.md) | [相关史诗](https://gitlab.com/groups/gitlab-org/-/epics/9850)

{{< /details >}}

随着我们扩展此策略类型的功能，以支持覆盖项目设置并强制执行批准要求，我们已将其名称更新为更贴切的“合并请求批准策略”。

合并请求批准策略不会替代现有的合并请求批准规则或与之冲突。相反，它们为旗舰版客户提供了通过由中央安全和合规团队管理的策略，跨项目创建全局强制措施的能力——对于大规模组织而言，这是一项日益艰巨的任务。

<a id="webhooks-support-mutual-tls"></a>

### Webhook 支持双向 TLS

{{< details >}}

- Tier：基础版，专业版，旗舰版
- Links: [文档](../../user/project/integrations/webhooks.md#configure-webhooks-to-support-mutual-tls) | [相关议题](https://gitlab.com/gitlab-org/gitlab/-/issues/27450)

{{< /details >}}

您现在可以配置 Webhook 以支持双向 TLS。此配置可建立 Webhook 来源的真实性并增强安全性。您以 PEM 格式配置客户端证书，该证书将在 TLS 握手期间出示给服务器。您还可以使用 PEM 密码保护证书。

<a id="sign-in-page-improvements"></a>

### 登录页面改进

{{< details >}}

- Tier：基础版，专业版，旗舰版
- Offering：JihuLab.com
- Links: [文档](https://gitlab.com/gitlab-org/gitlab/-/issues/412845) | [相关议题](https://gitlab.com/gitlab-org/gitlab/-/issues/412845)

{{< /details >}}

极狐GitLab 的登录页面已进行刷新，改进之处解决了间距问题、损坏元素和对齐问题。还添加了对暗色模式的额外支持，以及一个管理 Cookie 偏好的按钮。这些改进的结合使登录页面焕然一新，并提升了功能性。

<a id="smart-card-support-for-active-directory-ldap"></a>

### 对 Active Directory LDAP 的智能卡支持

{{< details >}}

- Tier：专业版，旗舰版
- Links: [文档](../../administration/auth/smartcard.md#authentication-against-an-active-directory-ldap-server) | [相关议题](https://gitlab.com/gitlab-org/gitlab/-/issues/328074)

{{< /details >}}

针对 LDAP 服务器的智能卡认证现支持 Entra ID（旧称 Azure Active Directory）。这使得可以轻松地从 Entra ID 同步用户身份数据，并使用智能卡针对 LDAP 进行认证。

<a id="use-merge-base-pipeline-for-merge-request-approval-policy-comparison"></a>

### 使用合并基线流水线进行合并请求批准策略比较

{{< details >}}

- Tier：旗舰版
- Offering：JihuLab.com
- Links: [文档](../../user/application_security/policies/merge_request_approval_policies.md#understanding-merge-request-approval-policy-approvals) | [相关议题](https://gitlab.com/gitlab-org/gitlab/-/issues/428518)

{{< /details >}}

此增强功能使合并请求批准策略评估的逻辑与安全 MR 控件保持一致，确保违反合并请求批准策略的发现与控件中显示的结果一致。通过统一逻辑，安全、合规和开发团队可以更一致地识别哪些发现违反了策略并需要批准。
与目标分支的最新已完成 `HEAD` 流水线相比，扫描结果策略现在与公共祖先的最新已完成流水线进行比较，即“合并基线”。

<a id="support-domain-level-redirects-for-gitlab-pages"></a>

### 支持极狐GitLab Pages 的域级重定向

{{< details >}}
{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: JihuLab.com
- Links: [文档](../../user/project/pages/redirects.md#domain-level-redirects)

{{< /details >}}

此前，极狐GitLab 专注于支持简单的重定向规则。在极狐GitLab 14.3 中，我们引入了对 splat 和占位符重定向的支持。

从极狐GitLab 16.10 开始，极狐GitLab Pages 支持域名级重定向。你可以将域名级重定向与 splat 规则结合使用，以动态重写 URL 路径。这项改进有助于防止混淆，并确保你在域名变更后仍能找到所需信息，即使你使用的是旧域名。

<a id="list-repository-tags-with-the-new-container-registry-api"></a>

### 使用新的容器镜像仓库 API 列出仓库标签

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Links: [文档](../../api/container_registry.md)

{{< /details >}}

此前，容器镜像仓库依赖 Docker/OCI [列出镜像标签的 registry API](https://jihulab.com/gitlab-cn/container-registry/-/blob/5208a0ce1600b535e529cd857c842fda6d19ad59/docs/spec/docker/v2/api.md#listing-image-tags) 在极狐GitLab 中显示标签。该 API 存在显著的性能和可发现性限制。

该 API 执行缓慢，因为针对 registry 的网络请求数量随标签列表中的标签数量而扩展。此外，由于该 API 不跟踪发布时间，因此发布的 timestamp 经常不正确。在基于 Docker manifest lists 或 OCI indexes 显示镜像时也存在限制，例如多架构镜像。

为了解决这些限制，我们引入了一个新的 registry [列出仓库标签 API](https://jihulab.com/gitlab-cn/container-registry/-/blob/5208a0ce1600b535e529cd857c842fda6d19ad59/docs/spec/gitlab/api.md#list-repository-tags)。在极狐GitLab 16.10 中，我们已完成向新 API 的迁移。现在，无论你使用 UI 还是 REST API，你都可以期待改进的性能、准确的发布时间戳以及对多架构镜像的稳健支持。

此改进仅在 JihuLab.com 上可用。私有化部署支持被阻止，直到下一代容器镜像仓库正式发布。

<a id="new-contributor-count-metric-in-the-value-streams-dashboard"></a>

### 价值流仪表板中的新贡献者数量指标

{{< details >}}

- Tier: 旗舰版
- Offering: JihuLab.com
- Links: [文档](../../user/analytics/value_streams_dashboard.md)

{{< /details >}}

为了使软件领导者能够深入了解团队速度、软件稳定性、安全风险以及团队生产力之间的关系，我们在价值流仪表板中引入了新的[**贡献者数量**指标](../../user/analytics/value_streams_dashboard.md#dashboard-metrics-and-drill-down-reports)。贡献者数量表示群组中每月有贡献的唯一用户数。该指标旨在跟踪随时间推移的采用趋势，并基于[贡献日历事件](../../user/profile/contributions_calendar.md#user-contribution-events)。

**贡献者数量**指标仅在 JihuLab.com 上可用，并且需要[配置贡献分析报告以通过 ClickHouse 运行](../../user/group/contribution_analytics/_index.md#contribution-analytics-with-clickhouse)。

<a id="inherited-filters-in-value-stream-analytics-for-seamless-and-accurate-workflow-analysis"></a>

### 价值流分析中的继承过滤器，实现无缝且准确的工作流分析

{{< details >}}

- Tier: 专业版，旗舰版
- Offering: JihuLab.com
- Links: [文档](../../user/group/issues_analytics/_index.md)

{{< /details >}}

[价值流分析](../../user/group/value_stream_analytics/_index.md) 现在在从**前置时间**磁贴下钻到[**议题分析**报告](../../user/group/issues_analytics/_index.md)时应用相同的过滤器。过滤器继承可帮助你在切换分析视图时更深入、无缝地探索数据。

<a id="add-an-issue-to-the-current-or-next-iteration-with-a-quick-action"></a>

### 使用快速操作将议题添加到当前或下一次迭代

{{< details >}}

- Tier: 专业版，旗舰版
- Offering: JihuLab.com
- Links: [文档](../../user/project/quick_actions.md)

{{< /details >}}

`/iteration` 快速操作现在接受带有 `--current` 或 `--next` 参数的节奏引用。如果你的群组只有一个迭代节奏，你可以通过使用 `/iteration --current|next` 快速将议题分配给当前或下一次迭代。如果你的群组包含多个迭代节奏，你可以在快速操作中通过引用节奏名称或 ID 来指定所需的节奏。例如，`/iteration [cadence:"<节奏名称>"|<节奏 ID>] --next|current`。

<a id="continuous-vulnerability-scanning-available-by-default-for-container-scanning"></a>

### 容器扫描的持续漏洞扫描默认可用

{{< details >}}

- Tier: 旗舰版
- Offering: JihuLab.com
- Links: [文档](../../user/application_security/continuous_vulnerability_scanning/_index.md)

{{< /details >}}

容器扫描的持续漏洞扫描现在默认可用。默认可用性消除了通过功能标志选择加入此功能的需要。要了解有关持续漏洞扫描优势的更多信息，请参阅文档链接。

<a id="improved-dependency-scanning-support-for-sbt"></a>

### 改进了对 sbt 的依赖项扫描支持

{{< details >}}

- Tier: 旗舰版
- Offering: JihuLab.com
- Links: [文档](../../user/application_security/dependency_scanning/legacy_dependency_scanning/_index.md#supported-languages-and-package-managers)

{{< /details >}}

我们更新了用于生成使用 sbt 的项目依赖项列表的机制。此更改仅适用于使用 sbt 1.7.2 及更高版本的项目。要充分利用 sbt 项目的依赖项扫描，你应该升级到 sbt 1.7.2 及更高版本。

<a id="dast-analyzer-performance-updates"></a>

### DAST 分析器性能更新

{{< details >}}

- Tier: 旗舰版
- Links: [文档](../../user/application_security/dast/browser/_index.md)

{{< /details >}}

在 16.10 发布里程碑期间，基于代理的 DAST 进行了以下更新：

- 将 ZAP 升级到版本 2.14.0。

我们还完成了以下基于浏览器的 DAST 爬虫性能改进：

- 限制爬取时创建的 goroutines 数量。
- 优化查找要交互的元素。这将扫描时间减少了 6%。
- 优化 DevTools 消息的 JSON 反序列化。这将扫描时间减少了 7%。

<a id="gitlab-runner-16-10"></a>

### 极狐GitLab Runner 16.10

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Links: [文档](https://gitlab.cn/docs/runner)

{{< /details >}}

我们也在今天发布了极狐GitLab Runner 16.10！极狐GitLab Runner 是轻量级、高度可扩展的代理，用于运行你的 CI/CD 作业并将结果发送回极狐GitLab 实例。极狐GitLab Runner 与极狐GitLab CI/CD 协同工作，极狐GitLab CI/CD 是极狐GitLab 附带的开源持续集成服务。

所有更改的列表见极狐GitLab Runner [CHANGELOG](https://jihulab.com/gitlab-cn/gitlab-runner/blob/16-10-stable/CHANGELOG.md)。

