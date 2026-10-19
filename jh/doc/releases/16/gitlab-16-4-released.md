---
stage: Release Notes
group: Monthly Release
date: 2023-09-22
title: "极狐GitLab 16.4 发布说明"
description: "极狐GitLab 16.4 发布，支持自定义角色"
---

<!-- markdownlint-disable -->
<!-- vale off -->

2023 年 9 月 22 日，极狐GitLab 16.4 正式发布，带来了以下功能。

<a id="primary-features"></a>

## 主要功能

<a id="customizable-roles"></a>

### 自定义角色

<!-- categories: User Management -->

{{< details >}}

- 适用版本: 旗舰版
- 交付方式: JihuLab.com、私有化部署
- 链接: [文档](../../user/permissions.md) | [相关议题](https://gitlab.com/gitlab-org/gitlab/-/issues/393235)

{{< /details >}}

群组所有者或管理员现在可以使用“角色和权限”菜单下的 UI 创建和删除自定义角色。要创建自定义角色，您可以在现有[基础角色](../../user/permissions.md#roles)的基础上添加[权限](../../user/permissions.md)。目前，可以添加到基础角色的权限数量有限，包括[精细安全权限](https://gitlab.cn/docs/#granular-security-permissions)、批准合并请求和查看代码的能力。每个里程碑都会发布新权限，这些权限随后可以添加到现有权限中，以创建自定义角色。

<a id="create-workspaces-for-private-projects"></a>

### 为私有项目创建工作区

<!-- categories: Workspaces -->

{{< details >}}

- 适用版本: 专业版、旗舰版
- 交付方式: JihuLab.com、私有化部署
- 链接: [文档](../../user/workspace/_index.md#personal-access-token)

{{< /details >}}

此前，无法为私有项目[创建工作区](../../user/workspace/configuration.md)。要克隆私有项目，您只能在创建工作区后进行身份验证。

在极狐GitLab 16.4 中，您可以为任何公开或私有项目创建工作区。创建工作区时，您会获得一个用于该工作区的个人访问令牌。使用此令牌，您无需任何额外配置或身份验证即可克隆私有项目并执行 Git 操作。

<a id="access-clusters-locally-using-your-gitlab-user-identity"></a>

### 使用极狐GitLab 用户身份在本地访问集群

<!-- categories: Environment Management, User Profile -->

{{< details >}}

- 适用版本: 基础版、专业版、旗舰版
- 交付方式: JihuLab.com、私有化部署
- 链接: [文档](../../user/clusters/agent/user_access.md#access-a-cluster-with-the-kubernetes-api) | [相关史诗](https://gitlab.com/groups/gitlab-org/-/epics/11235)

{{< /details >}}

允许开发者访问 Kubernetes 集群需要开发者云账号或第三方身份验证工具。这增加了云身份和访问管理的复杂性。现在，您可以仅使用开发者的极狐GitLab 身份和极狐GitLab Kubernetes Agent 授予开发者访问 Kubernetes 集群的权限。使用传统的 Kubernetes RBAC 管理集群内的授权。

结合极狐GitLab 流水线中提供的 [OIDC 云身份验证](../../ci/cloud_services/_index.md)，这些功能允许极狐GitLab 用户在不危及安全性和合规性的情况下，无需专用云账号即可访问云资源。

在集群访问的第一个迭代中，您必须[手动管理 Kubernetes 配置](../../user/clusters/agent/user_access.md)。[史诗 11455](https://gitlab.com/groups/gitlab-org/-/epics/11455) 提议通过扩展 GitLab CLI 的相关命令来简化设置。

<a id="groupsub-group-level-dependency-list"></a>

### 群组/子群组级依赖项列表

<!-- categories: Dependency Management -->

{{< details >}}

- 适用版本: 旗舰版
- 交付方式: JihuLab.com、私有化部署
- 链接: [文档](../../user/application_security/dependency_list/_index.md) | [相关史诗](https://gitlab.com/groups/gitlab-org/-/epics/8090)

{{< /details >}}

在查看依赖项列表时，拥有整体视图非常重要。对于希望跨所有项目审计其依赖项的大型组织来说，在项目级别管理依赖项存在问题。在此版本中，您可以查看项目或群组级别（包括子群组）的所有依赖项。此功能现已默认可用。

<a id="vulnerability-bulk-status-updates"></a>

### 漏洞批量状态更新

<!-- categories: Vulnerability Management -->

{{< details >}}

- 适用版本: 旗舰版
- 交付方式: JihuLab.com、私有化部署
- 链接: [文档](../../user/application_security/vulnerability_report/_index.md) | [相关史诗](https://gitlab.com/groups/gitlab-org/-/epics/4649)

{{< /details >}}

有些漏洞需要批量处理。无论它们是误报还是不再被检测到，最大限度地减少噪音并轻松排查漏洞都很重要。在此版本中，您可以从群组或项目漏洞报告批量更改状态并为多个漏洞添加评论。

<a id="granular-security-permissions"></a>

### 精细安全权限

<!-- categories: Vulnerability Management, Dependency Management -->

{{< details >}}

- 适用版本: 旗舰版
- 交付方式: JihuLab.com、私有化部署
- 链接: [文档](../../user/permissions.md) | [相关史诗](https://gitlab.com/groups/gitlab-org/-/epics/10684)

{{< /details >}}

一些组织希望为其安全团队授予所需的最低访问权限，以便遵循[最小权限原则](https://en.wikipedia.org/wiki/Principle_of_least_privilege)。安全团队不应有权编写代码更新，但他们必须能够批准合并请求、查看漏洞并更新漏洞状态。

极狐GitLab 现在允许用户基于[报告者](../../user/permissions.md)角色的访问权限[创建自定义角色](../../user/permissions.md)，但增加了以下权限：

- 查看依赖项列表（`read_dependency`）。
- 查看安全仪表板和漏洞报告（`read_vulnerability`）。
- 批准合并请求（`admin_merge_request`）。
- 更改漏洞状态（`admin_vulnerability`）。

如该[弃用条目](../../update/deprecations.md#deprecate-change-vulnerability-status-from-the-developer-role)所述，我们计划在 17.0 中从所有版本的开发者角色中移除更改漏洞状态的能力。有关此拟议变更的反馈可在[议题 424688](https://gitlab.com/gitlab-org/gitlab/-/issues/424668)中分享。

<a id="fast-forward-merge-support-for-merge-trains"></a>

### 合并列车支持快进合并

<!-- categories: Merge Trains -->

{{< details >}}

- 适用版本: 专业版、旗舰版
- 交付方式: JihuLab.com、私有化部署
- 链接: [文档](../../ci/pipelines/merge_trains.md) | [相关史诗](https://gitlab.com/groups/gitlab-org/-/epics/4911)

{{< /details >}}

[快进合并](../../user/project/merge_requests/methods/_index.md#fast-forward-merge)是一种常见且流行的合并方法，它避免了合并提交，但需要更多的变基。另外，合并列车是一个强大的工具，有助于应对与频繁合并到主分支相关的一些更大挑战。遗憾的是，在此版本之前，您无法同时使用合并列车和快进合并。

在此版本中，私有化部署管理员现在可以在同一项目中同时启用快进合并和合并列车。您可以获得合并列车的所有优势（确保所有提交在合并前协同工作），同时拥有快进合并更简洁的提交历史！

要启用快进合并列车，请找到功能标志 `fast_forward_merge_trains_support`（默认已禁用）并启用它。

<a id="set-id_token-globally-and-eliminate-configuration-for-individual-jobs"></a>

### 全局设置 `id_token`，无需为各个作业单独配置

<!-- categories: Secrets Management -->

{{< details >}}

- 适用版本: 基础版、专业版、旗舰版
- 交付方式: JihuLab.com、私有化部署
- 链接: [文档](../../ci/yaml/_index.md#id_tokens) | [相关议题](https://gitlab.com/gitlab-org/gitlab/-/issues/419750)

{{< /details >}}

在极狐GitLab 15.9 中，我们宣布[弃用旧版本的 JSON Web 令牌](../../update/deprecations.md#old-versions-of-json-web-tokens-are-deprecated)，转而使用 `id_token`。遗憾的是，为了适应此变更，必须逐个修改作业。为了顺利过渡到 `id_token`，从极狐GitLab 16.4 开始，您可以在 `.gitlab-ci.yml`中将 `id_tokens` 设置为全局默认值。此功能会为每个作业自动设置 `id_token` 配置。使用 OpenID Connect (OIDC) 身份验证的作业不再需要您单独设置 `id_token`。

[使用 `id_token` 和 OIDC 向第三方服务进行身份验证](../../ci/secrets/id_token_authentication.md)。必需的 `aud` 子关键字用于配置 JWT 的 `aud` 声明。

<a id="scale-and-deployments"></a>

## 规模和部署

<a id="elasticsearch-index-integrity-now-generally-available"></a>

### Elasticsearch 索引完整性现已正式发布

<!-- categories: Global Search -->

{{< details >}}

- 适用版本: 专业版、旗舰版
- 交付方式: JihuLab.com、私有化部署
- 链接: [文档](../../integration/advanced_search/elasticsearch.md#index-integrity) | [相关议题](https://gitlab.com/gitlab-org/gitlab/-/issues/214601)

{{< /details >}}

在极狐GitLab 16.4 中，Elasticsearch 索引完整性已面向所有极狐GitLab 用户正式发布。索引完整性有助于检测和修复缺失的代码仓库数据。当限定到群组或项目的代码搜索未返回结果时，会自动使用此功能。

<a id="omnibus-improvements"></a>

### Omnibus 改进

<!-- categories: Omnibus Package -->

{{< details >}}

- 适用版本: 基础版、专业版、旗舰版
- 交付方式: 私有化部署
- 链接: [文档](https://gitlab.cn/docs/omnibus/)

{{< /details >}}

- 极狐GitLab 16.4 包含适用于 [OpenSUSE 15.5](https://en.opensuse.org/Release_announcement_15.5)的软件包。

<a id="add-webhooks-for-added-or-revoked-emoji-reactions"></a>

### 为添加或撤销表情回应添加 webhook

<!-- categories: Notifications -->

{{< details >}}

- 适用版本: 基础版、专业版、旗舰版
- 交付方式: JihuLab.com、私有化部署
- 链接: [文档](../../user/project/integrations/webhook_events.md#emoji-events) | [相关议题](https://gitlab.com/gitlab-org/gitlab/-/issues/290773)

{{< /details >}}

为了尽可能提供更多与第三方系统自动化和集成的机会，我们添加了对创建 webhook 的支持，当用户添加或撤销表情回应时会触发该 webhook。

例如，您可以使用新的 webhook 在用户对议题或合并请求做出表情回应时发送电子邮件。

<a id="create-custom-role-name-and-description-using-api"></a>

### 使用 API 创建自定义角色名称和描述

<!-- categories: System Access -->

{{< details >}}

- 适用版本: 旗舰版
- 交付方式: JihuLab.com、私有化部署
- 链接: [文档](../../api/member_roles.md) | [相关议题](https://gitlab.com/gitlab-org/gitlab/-/issues/416751)

{{< /details >}}

创建自定义角色时，您现在可以使用成员角色 API 添加名称（必需）和描述（可选）。任何现有的自定义角色都被赋予了名称 `Custom`，您可以使用 API 将自定义角色的名称更改为您选择的名称。

<a id="trigger-slack-notifications-for-group-mentions"></a>

### 为群组提及触发 Slack 通知

<!-- categories: Settings -->

{{< details >}}

- 适用版本: 基础版、专业版、旗舰版
- 交付方式: JihuLab.com、私有化部署
- 链接: [文档](../../user/project/integrations/gitlab_slack_application.md#trigger-notifications-for-group-mentions) | [相关议题](https://gitlab.com/gitlab-org/gitlab/-/issues/417751)

{{< /details >}}

极狐GitLab 可以针对某些极狐GitLab 事件向 Slack 工作区频道发送消息。在此版本中，您现在可以为以下公开和私有上下文中的群组提及触发 [Slack 通知](../../user/project/integrations/gitlab_slack_application.md#notification-events)：

- 议题和合并请求描述
- 议题、合并请求和提交上的评论

<a id="expand-configurable-import-limits-available-in-application-settings"></a>

### 扩展应用程序设置中可配置的导入限制

<!-- categories: Importers -->

{{< details >}}

- 适用版本: 基础版、专业版、旗舰版
- 交付方式: 私有化部署
- 链接: [文档](../../administration/settings/import_and_export_settings.md#timeout-for-decompressing-archived-files) | [相关议题](https://gitlab.com/gitlab-org/gitlab/-/issues/421432)

{{< /details >}}

我们最近将一些硬编码的导入限制改为可配置的应用程序设置，以便私有化部署的极狐GitLab 管理员可以根据自己的需求调整这些限制。

在此版本中，我们添加了解压缩归档文件的超时时间作为可配置的应用程序设置。

此限制此前硬编码为 210 秒。在 JihuLab.com 上以及默认情况下对于私有化部署安装，我们将此限制设置为 210 秒。私有化部署的极狐GitLab 和 JihuLab.com 管理员都可以根据需要调整此限制。

<a id="custom-email-address-for-service-desk"></a>

### 服务台的自定义电子邮件地址

<!-- categories: Service Desk -->

{{< details >}}

- 适用版本: 基础版、专业版、旗舰版
- 交付方式: JihuLab.com、私有化部署
- 链接: [文档](../../user/project/service_desk/configure.md#custom-email-address) | [相关议题](https://gitlab.com/gitlab-org/gitlab/-/issues/329990)

{{< /details >}}

服务台是您的业务与客户之间最有意义的联系之一。现在，您可以使用自己的自定义电子邮件地址为服务台发送和接收电子邮件。通过此变更，维护品牌形象并让客户确信他们正在与正确的实体沟通变得更加容易。

此功能处于测试版。我们鼓励用户尝试测试版功能，并在[反馈议题](https://gitlab.com/gitlab-org/gitlab/-/issues/416637)中提供反馈。

<a id="geo-supports-unified-urls-on-cloud-native-hybrid-sites"></a>

### Geo 在 Cloud Native Hybrid 站点上支持统一 URL

<!-- categories: Disaster Recovery, Geo Replication -->

{{< details >}}

- 适用版本: 专业版、旗舰版
- 交付方式: 私有化部署
- 链接: [文档](../../administration/geo/secondary_proxy/_index.md#set-up-a-unified-url-for-geo-sites) | [相关史诗](https://gitlab.com/gitlab-org/charts/gitlab/-/issues/3522)

{{< /details >}}

Geo 现在在 [Cloud Native Hybrid](../../administration/reference_architectures/_index.md#cloud-native-hybrid) 站点上支持统一 URL，这意味着 Cloud Native Hybrid 站点可以与主站点共享单个外部 URL。这为您的远程团队提供了无缝的极狐GitLab UI 和 Git 开发者体验，他们可以使用单个通用 URL 根据其位置自动定向到最佳的 Geo 从站点。通过此更新，所有极狐GitLab 参考架构现在都支持统一 URL。

<a id="geo-verifies-object-storage"></a>

### Geo 验证对象存储

<!-- categories: Geo Replication, Disaster Recovery -->

{{< details >}}

- 适用版本: 专业版、旗舰版
- 交付方式: 私有化部署
- 链接: [文档](../../administration/geo/replication/object_storage.md) | [相关议题](https://gitlab.com/groups/gitlab-org/-/epics/8056)

{{< /details >}}

当[对象存储复制由极狐GitLab 管理](../../administration/geo/replication/object_storage.md#enabling-gitlab-managed-object-storage-replication)时，Geo 添加了验证对象存储的能力。为了保护您的对象存储数据免受损坏，Geo 会比较主站点和从站点之间的文件大小。如果 Geo 是您灾难恢复策略的一部分，并且您启用了极狐GitLab 管理的对象存储复制，这可以保护您免受数据丢失。此外，它还减少了复制从站点上可能已存在的数据的需求。例如，当将旧的主站点重新添加为从站点时。

<a id="unified-devops-and-security"></a>

## 统一 DevOps 和安全

<a id="support-for-environment-keyword-in-downstream-pipelines"></a>

### 在下游流水线中支持 `environment` 关键字

<!-- categories: Environment Management, Deployment Management -->

{{< details >}}

- 适用版本: 基础版、专业版、旗舰版
- 交付方式: JihuLab.com、私有化部署
- 链接: [文档](../../ci/pipelines/downstream_pipelines.md#downstream-pipelines-for-deployments) | [相关议题](https://gitlab.com/gitlab-org/gitlab/-/issues/369061)

{{< /details >}}

如果您需要从 CI/CD 流水线作业触发下游流水线，可以使用 `trigger` 关键字。为了增强您的部署管理，您现在可以在使用 `trigger` 时使用 `environment` 关键字指定环境。例如，您可以为 `/web-app` 项目上 `main` 分支触发下游流水线，并指定环境名称 `dev` 和环境 URL。

此前，当您为 CI 和 CD 运行单独的流水线并使用 `trigger` 关键字启动 CD 流水线时，无法指定环境详细信息。这使得从 CI 项目跟踪部署变得困难。添加对环境的支持简化了跨项目的部署跟踪。

<a id="allow-users-to-define-branch-exceptions-to-enforced-security-policies"></a>

### 允许用户为强制执行的安全策略定义分支例外

<!-- categories: Security Policy Management -->

{{< details >}}

- 适用版本: 旗舰版
- 交付方式: JihuLab.com、私有化部署
- 链接: [文档](../../user/application_security/policies/_index.md) | [相关史诗](https://gitlab.com/groups/gitlab-org/-/epics/9567)

{{< /details >}}

安全策略强制扫描器在极狐GitLab 项目中运行，并强制执行合并请求检查/审批以确保安全性和合规性。通过分支例外，您可以更精细地执行策略，并排除对任何超出范围的给定分支的执行。如果开发者创建了意外受到严格执行影响的开发或测试分支，他们可以与安全团队合作，在安全策略中豁免该分支。

对于扫描执行策略，您可以为[流水线](../../user/application_security/policies/scan_execution_policies.md#pipeline-rule-type)或[计划](../../user/application_security/policies/scan_execution_policies.md#schedule-rule-type)规则类型配置例外。对于扫描结果策略，您可以为 [scan_finding](../../user/application_security/policies/merge_request_approval_policies.md#scan_finding-rule-type) 或 [license_finding](../../user/application_security/policies/merge_request_approval_policies.md#license_finding-rule-type) 规则类型指定分支例外。

<a id="notifications-for-expiring-access-tokens"></a>

### 访问令牌即将过期的通知

<!-- categories: System Access -->

{{< details >}}

- 适用版本: 基础版、专业版、旗舰版
- 交付方式: 私有化部署
- 链接: [文档](../../security/tokens/_index.md) | [相关议题](https://gitlab.com/gitlab-org/gitlab/-/issues/367705)

{{< /details >}}

群组和项目访问令牌经常用于自动化。当其中一个令牌即将过期时，管理员和群组所有者收到通知非常重要，这样可以避免中断。管理员和群组所有者现在会在令牌距离过期还有七天或更短时间时收到通知电子邮件。

<a id="email-notification-when-access-expires"></a>

### 访问权限过期时的电子邮件通知

<!-- categories: System Access -->

{{< details >}}

- 适用版本: 基础版、专业版、旗舰版
- 交付方式: 私有化部署
- 链接: [文档](../../user/group/_index.md#add-users-to-a-group) | [相关议题](https://gitlab.com/gitlab-org/gitlab/-/issues/12704)

{{< /details >}}

用户将在其群组或项目访问权限过期前七天收到电子邮件通知。这仅在设置了访问过期日期时适用。此前，访问权限过期时没有任何通知。提前通知意味着您可以联系极狐GitLab 管理员以确保访问的连续性。

<a id="browser-based-dast-active-check-221-is-enabled-by-default"></a>

### 基于浏览器的 DAST 主动检查 22.1 默认启用

<!-- categories: DAST -->

{{< details >}}

- 适用版本: 旗舰版
- 交付方式: JihuLab.com、私有化部署
- 链接: [文档](../../user/application_security/dast/browser/checks/_index.md#active-checks) | [相关议题](https://gitlab.com/gitlab-org/gitlab/-/issues/392718)

{{< /details >}}

基于浏览器的 DAST 主动检查 22.1 已默认启用。它取代了已禁用的 ZAP 检查 6。检查 22.1 识别“路径名到受限目录的不当限制（路径遍历）”，该漏洞可通过将有效负载插入 URL 端点上的参数来利用，从而允许读取任意文件。

<a id="private-registry-support-for-operational-container-scanning"></a>

### 运维容器扫描支持私有镜像仓库

<!-- categories: Container Scanning -->

{{< details >}}

- 适用版本: 旗舰版
- 交付方式: JihuLab.com、私有化部署
- 链接: [文档](../../user/clusters/agent/vulnerabilities.md#scanning-private-images) | [相关议题](https://gitlab.com/gitlab-org/gitlab/-/issues/415451)

{{< /details >}}

[运维容器扫描](../../user/clusters/agent/vulnerabilities.md)现在可以访问和扫描来自私有容器镜像仓库的镜像。OCS 使用镜像拉取密钥来访问私有镜像仓库容器。

<a id="dependency-and-license-scanning-support-for-pnpm-lockfile-v61"></a>

### 依赖项和许可证扫描支持 pnpm lockfile v6.1

<!-- categories: Software Composition Analysis -->

{{< details >}}

- 适用版本: 旗舰版
- 交付方式: JihuLab.com、私有化部署
- 链接: [文档](../../user/application_security/dependency_scanning/legacy_dependency_scanning/_index.md#obtaining-dependency-information-by-parsing-lockfiles) | [相关议题](https://gitlab.com/gitlab-org/gitlab/-/issues/413903)

{{< /details >}}

得益于 [Weyert de Boer](https://gitlab.com/weyert-tapico)的社区贡献，极狐GitLab 依赖项和许可证扫描现在支持使用 v6.1 lockfile 格式分析 pnpm 项目。

<a id="sast-analyzer-updates"></a>

### SAST 分析器更新

<!-- categories: SAST -->

{{< details >}}

- 适用版本: 基础版、专业版、旗舰版
- 交付方式: 私有化部署
- 链接: [文档](../../user/application_security/sast/analyzers.md) | [相关议题](../../user/application_security/_index.md)

{{< /details >}}

极狐GitLab SAST 包含[许多安全分析器](../../user/application_security/sast/_index.md#supported-languages-and-frameworks)，由 GitLab 静态分析团队积极维护、更新和支持。我们在 16.4 发布里程碑期间发布了以下更新：

- 将基于 KICS 的分析器更新到 KICS 扫描器的 1.7.7 版本。有关更多详细信息，请参阅 [CHANGELOG](https://gitlab.com/gitlab-org/security-products/analyzers/kics/-/blob/main/CHANGELOG.md?ref_type=heads#v415)。
- 将基于 Sobelow 的分析器更新到 Sobelow 扫描器的 0.13.0 版本。我们还将分析器的基础镜像更新到 Elixir 1.13，以提高与较新 Elixir 版本的兼容性。请参阅 [CHANGELOG](https://gitlab.com/gitlab-org/security-products/analyzers/sobelow/-/blob/master/CHANGELOG.md?ref_type=heads#v421)
- 将基于 PMD Apex 的分析器更新到 PMD 扫描器的 6.55.0 版本。有关更多详细信息，请参阅 [CHANGELOG](https://gitlab.com/gitlab-org/security-products/analyzers/pmd-apex/-/blob/master/CHANGELOG.md?ref_type=heads#v413)。
- 更改了基于 PHPCS Security Audit 的分析器，移除了 `Security.Misc.IncludeMismatch` 规则。有关更多详细信息，请参阅 [CHANGELOG](https://gitlab.com/gitlab-org/security-products/analyzers/phpcs-security-audit/-/blob/master/CHANGELOG.md?ref_type=heads#v411)。
- 更新了基于 Semgrep 的分析器中使用的规则，以修复规则错误、修复规则描述中的失效链接，并解决具有相同规则 ID 的 Java 和 Scala 规则之间的冲突。我们还将自定义规则文件的最大大小增加到 10 MB。有关更多详细信息，请参阅 [CHANGELOG](https://gitlab.com/gitlab-org/security-products/analyzers/semgrep/-/blob/main/CHANGELOG.md?ref_type=heads#v4412)。

如果您[包含 GitLab 管理的 SAST 模板](../../user/application_security/sast/_index.md)（[`SAST.gitlab-ci.yml`](https://gitlab.com/gitlab-org/gitlab/blob/master/lib/gitlab/ci/templates/Security/SAST.gitlab-ci.yml)）并运行极狐GitLab 16.0 或更高版本，您将自动收到这些更新。要保留任何分析器的特定版本并防止自动更新，您可以[固定其版本](../../user/application_security/sast/_index.md)。

有关之前的更改，请参阅[上个月的更新](gitlab-16-3-released.md#sast-analyzer-updates)。

<a id="improved-sast-vulnerability-tracking"></a>

### 改进的 SAST 漏洞跟踪

<!-- categories: SAST -->

{{< details >}}

- 适用版本: 旗舰版
- 交付方式: 私有化部署
- 链接: [文档](../../user/application_security/sast/_index.md#advanced-vulnerability-tracking) | [相关议题](https://gitlab.com/gitlab-org/gitlab/-/issues/373921)

{{< /details >}}

极狐GitLab SAST [高级漏洞跟踪](../../user/application_security/sast/_index.md#advanced-vulnerability-tracking)通过跟踪代码移动时的发现结果，使分类更加高效。

在极狐GitLab 16.4 中，我们为新语言和分析器启用了高级漏洞跟踪。除了[现有覆盖范围](../../user/application_security/sast/_index.md#advanced-vulnerability-tracking)外，高级跟踪现在可用于：

- Java，在基于 SpotBugs 的 SAST 分析器中。
- PHP，在基于 PHPCS Security Audit 的 SAST 分析器中。

这建立在[极狐GitLab 16.3 中发布](gitlab-16-3-released.md#improved-sast-vulnerability-tracking)的先前扩展和改进的基础上。我们正在[史诗 5144](https://gitlab.com/groups/gitlab-org/-/epics/5144)中跟踪进一步的改进。

这些更改包含在极狐GitLab SAST [分析器](../../user/application_security/sast/analyzers.md)的[更新版本](https://gitlab.cn/docs/#sast-analyzer-updates)中。使用更新后的分析器扫描项目后，您项目的漏洞发现结果将使用新的跟踪签名进行更新。除非您[将 SAST 分析器固定到特定版本](../../user/application_security/sast/_index.md)，否则您无需采取任何操作即可收到此更新。

<a id="pipeline-specific-cyclonedx-sbom-exports"></a>

### 流水线特定的 CycloneDX SBOM 导出

<!-- categories: Software Composition Analysis -->

{{< details >}}

- 适用版本: 旗舰版
- 交付方式: JihuLab.com、私有化部署
- 链接: [文档](../../api/dependency_list_export.md) | [相关议题](https://gitlab.com/gitlab-org/gitlab/-/issues/333463)

{{< /details >}}

我们添加了一个 API，允许您下载 CycloneDX SBOM，其中列出了 CI 流水线中检测到的所有组件。这包括应用程序级依赖项和系统级依赖项。

<a id="users-with-the-maintainer-role-can-view-runner-details"></a>

### 具有维护者角色的用户可以查看 runner 详细信息

<!-- categories: Fleet Visibility -->

{{< details >}}

- 适用版本: 基础版、专业版、旗舰版
- 交付方式: 私有化部署
- 链接: [文档](../../user/permissions.md) | [相关议题](https://gitlab.com/gitlab-org/gitlab/-/issues/384179)

{{< /details >}}

具有群组维护者角色的用户现在可以查看群组 runner 的详细信息。具有此角色的用户可以查看群组 runner，以快速确定哪些 runner 可用，或验证自动创建的 runner 是否已成功注册到群组命名空间。

<a id="macos-13-ventura-image-for-saas-runners-on-macos"></a>

### 适用于 macOS 上 SaaS runner 的 macOS 13 (Ventura) 镜像

<!-- categories: GitLab Hosted Runners -->

{{< details >}}

- 交付方式: JihuLab.com
- 链接: [文档](../../ci/runners/hosted_runners/macos.md#supported-macos-images) | [相关议题](https://gitlab.com/gitlab-org/ci-cd/shared-runners/infrastructure/-/issues/101)

{{< /details >}}

团队现在可以在 macOS 13 上为 Apple 生态系统无缝创建、测试和部署应用程序。

macOS 上的 SaaS runner 允许您在安全、按需的极狐GitLab Runner 构建环境中提高开发团队构建和部署需要 macOS 的应用程序的速度，该环境与极狐GitLab CI/CD 集成。

<a id="gitlab-runner-164"></a>

### 极狐GitLab Runner 16.4

<!-- categories: GitLab Runner Core -->

{{< details >}}

- 适用版本: 基础版、专业版、旗舰版
- 交付方式: 私有化部署
- 链接: [文档](https://gitlab.cn/docs/runner/)

{{< /details >}}

我们今天还发布了极狐GitLab Runner 16.4！极狐GitLab Runner 是轻量级、高度可扩展的代理，它运行您的 CI/CD 作业并将结果发送回极狐GitLab 实例。极狐GitLab Runner 与极狐GitLab CI/CD 协同工作，后者是极狐GitLab 中包含的开源持续集成服务。

<a id="whats-new"></a>

#### 新增功能

- [将队列持续时间直方图指标添加到 runner Prometheus 指标端点](https://gitlab.com/gitlab-org/gitlab-runner/-/issues/36627)

<a id="bug-fixes"></a>

#### 缺陷修复

- [Kubernetes runner pod 在 GitLab Runner 16.3.0 中未被清理](https://gitlab.com/gitlab-org/gitlab-runner/-/issues/36803)
- [`gitlab-runner-helper` 在缓存下载期间终止](https://gitlab.com/gitlab-org/gitlab-runner/-/issues/27984)

所有更改的列表在极狐GitLab Runner [CHANGELOG](https://gitlab.com/gitlab-org/gitlab-runner/blob/16-4-stable/CHANGELOG.md)中。
