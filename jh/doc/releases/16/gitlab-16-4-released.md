---
stage: 发布说明
group: 月度发布
date: 2023-09-22
title: "极狐GitLab 16.4 发布说明"
description: "极狐GitLab 16.4 发布，带来可自定义角色等功能"
---

<!-- markdownlint-disable -->
<!-- vale off -->

2023 年 9 月 22 日，极狐GitLab 16.4 正式发布，带来了以下功能。

## 主要功能

### 可自定义角色

{{< details >}}

- Tier: 旗舰版
- Offering: JihuLab.com
- 链接：[文档](../../user/permissions.md) | [相关议题](https://gitlab.com/gitlab-org/gitlab/-/issues/393235)

{{< /details >}}

群组所有者或管理员现在可以通过 UI 在“角色和权限”菜单下创建和删除自定义角色。要创建自定义角色，你需要在一个现有的[基础角色](../../user/permissions.md#roles)之上添加[权限](../../user/permissions.md)。目前，可以添加到基础角色的权限数量有限，包括[粒度安全权限](https://docs.gitlab.com/#granular-security-permissions)、批准合并请求以及查看代码的能力。每个里程碑都会发布新的权限，然后可以将其添加到现有的权限中以创建自定义角色。

### 为私有项目创建工作区

{{< details >}}

- Tier: 专业版，旗舰版
- Offering: JihuLab.com
- 链接：[文档](../../user/workspace/_index.md#personal-access-token)

{{< /details >}}

以前，不可能为私有项目[创建工作区](../../user/workspace/configuration.md)。要克隆私有项目，你只能在创建工作区后进行身份验证。

在极狐GitLab 16.4 中，你可以为任何公开或私有项目创建工作区。创建工作区时，你会获得一个与该工作区一起使用的个人访问令牌。有了这个令牌，你可以克隆私有项目并执行 Git 操作，而无需任何额外的配置或身份验证。

### 使用你的极狐GitLab 用户身份在本地访问集群

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: JihuLab.com
- 链接：[文档](../../user/clusters/agent/user_access.md#access-a-cluster-with-the-kubernetes-api) | [相关史诗](https://gitlab.com/groups/gitlab-org/-/epics/11235)

{{< /details >}}

允许开发者访问 Kubernetes 集群需要开发者云账户或第三方身份验证工具。这增加了云身份和访问管理的复杂性。现在，你可以仅使用开发者的极狐GitLab 身份和 Kubernetes 代理来授予他们对 Kubernetes 集群的访问权限。使用传统的 Kubernetes RBAC 来管理集群内的授权。

结合极狐GitLab 流水线中提供的 [OIDC 云身份验证](../../ci/cloud_services/_index.md)，这些功能允许极狐GitLab 用户在没有专用云账户的情况下访问云资源，且不会危及安全性和合规性。

在集群访问的这第一个迭代中，你必须[手动管理你的 Kubernetes 配置](../../user/clusters/agent/user_access.md)。[Epic 11455](https://gitlab.com/groups/gitlab-org/-/epics/11455) 提议通过使用相关命令扩展极狐GitLab CLI 来简化设置。

### 群组/子群组级别的依赖项列表

{{< details >}}

- Tier: 旗舰版
- Offering: JihuLab.com
- 链接：[文档](../../user/application_security/dependency_list/_index.md) | [相关史诗](https://gitlab.com/groups/gitlab-org/-/epics/8090)

{{< /details >}}

在审查依赖项列表时，拥有一个全局视图非常重要。对于希望审计其所有项目中依赖项的大型组织而言，在项目级别管理依赖项存在问题。在此版本中，你可以在项目或群组级别（包括子群组）查看所有依赖项。此功能现在默认可用。

### 漏洞批量状态更新

{{< details >}}

- Tier: 旗舰版
- Offering: JihuLab.com
- 链接：[文档](../../user/application_security/vulnerability_report/_index.md) | [相关史诗](https://gitlab.com/groups/gitlab-org/-/epics/4649)

{{< /details >}}

有些漏洞需要批量处理。无论它们是误报还是不再被检测到，最大限度地减少干扰并轻松分类漏洞至关重要。在此版本中，你可以从群组或项目的漏洞报告中批量更改多个漏洞的状态并发表评论。

### 粒度安全权限

{{< details >}}

- Tier: 旗舰版
- Offering: JihuLab.com
- 链接：[文档](../../user/permissions.md) | [相关史诗](https://gitlab.com/groups/gitlab-org/-/epics/10684)

{{< /details >}}

一些组织希望为其安全团队提供最少必要权限，以便他们能够遵守[最小权限原则](https://en.wikipedia.org/wiki/Principle_of_least_privilege)。安全团队不应有权编写代码更新，但他们必须能够批准合并请求、查看漏洞并更新漏洞状态。

极狐GitLab 现在允许用户基于[报告者](../../user/permissions.md)角色的访问权限来[创建自定义角色](../../user/permissions.md)，但增加了以下额外权限：

- 查看依赖项列表 (`read_dependency`)。
- 查看安全仪表板和漏洞报告 (`read_vulnerability`)。
- 批准合并请求 (`admin_merge_request`)。
- 更改漏洞状态 (`admin_vulnerability`)。

我们计划从 17.0 开始，在所有层级中移除开发者角色更改漏洞状态的能力，如[此弃用条目](../../update/deprecations.md#deprecate-change-vulnerability-status-from-the-developer-role)中所述。关于此提议变更的反馈可以在[议题 424688](https://gitlab.com/gitlab-org/gitlab/-/issues/424668) 中分享。

### 合并队列支持快进合并

{{< details >}}

- Tier: 专业版，旗舰版
- Offering: JihuLab.com
- 链接：[文档](../../ci/pipelines/merge_trains.md) | [相关史诗](https://gitlab.com/groups/gitlab-org/-/epics/4911)

{{< /details >}}

[快进合并](../../user/project/merge_requests/methods/_index.md#fast-forward-merge)是一种常见且流行的合并方法，可以避免合并提交，但需要更多变基。另一方面，合并队列是一个强大的工具，有助于解决与频繁合并到主分支相关的一些更大挑战。遗憾的是，在此版本之前，你不能同时使用合并队列和快进合并。

在此版本中，私有化部署管理员现在可以在同一项目中同时启用快进合并和合并队列。你可以获得合并队列的所有好处——确保所有提交在合并前能协同工作——同时还能拥有快进合并带来的更清晰的提交历史！

要启用快进合并队列，请找到默认禁用的功能标志 `fast_forward_merge_trains_support` 并启用它。

### 全局设置 `id_token` 并为单个作业消除配置

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: JihuLab.com
- 链接：[文档](../../ci/yaml/_index.md#id_tokens) | [相关议题](https://gitlab.com/gitlab-org/gitlab/-/issues/419750)

{{< /details >}}

在极狐GitLab 15.9 中，我们宣布[弃用旧版 JSON Web 令牌](../../update/deprecations.md#old-versions-of-json-web-tokens-are-deprecated)，转而使用 `id_token`。遗憾的是，必须逐一修改作业以适应此更改。为了能够平稳过渡到 `id_token`，从极狐GitLab 16.4 开始，你可以在 `.gitlab-ci.yml` 中将 `id_tokens` 设置为全局默认值。此功能会自动为每个作业设置 `id_token` 配置。使用 OpenID Connect（OIDC）身份验证的作业不再需要你设置单独的 `id_token`。

[使用 `id_token` 和 OIDC 对第三方服务进行身份验证](../../ci/secrets/id_token_authentication.md)。必需的 `aud` 子关键字用于配置 JWT 的 `aud` 声明。

## 扩展与部署

### Elasticsearch 索引完整性已正式可用

{{< details >}}

- Tier: 专业版，旗舰版
- Offering: JihuLab.com
- 链接：[文档](../../integration/advanced_search/elasticsearch.md#index-integrity) | [相关议题](https://gitlab.com/gitlab-org/gitlab/-/issues/214601)

{{< /details >}}

在极狐GitLab 16.4 中，Elasticsearch 索引完整性对所有极狐GitLab 用户普遍可用。索引完整性有助于检测和修复丢失的仓库数据。当限定在某个群组或项目的代码搜索没有返回结果时，系统会自动使用此功能。

### Omnibus 改进

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- 链接：[文档](https://gitlab.cn/docs/omnibus/)

{{< /details >}}

- 极狐GitLab 16.4 包含了适用于 [OpenSUSE 15.5](https://en.opensuse.org/Release_announcement_15.5) 的软件包。

### 为添加或撤销表情回应添加 Webhook

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: JihuLab.com
- 链接：[文档](../../user/project/integrations/webhook_events.md#emoji-events) | [相关议题](https://gitlab.com/gitlab-org/gitlab/-/issues/290773)

{{< /details >}}

为了提供尽可能多的自动化和与第三方系统集成的机会，我们添加了创建 Webhook 的支持，当用户添加或撤销表情回应时触发。

例如，你可以使用新的 Webhook 在用户通过表情符号回应议题或合并请求时发送电子邮件。

### 使用 API 创建自定义角色名称和描述

{{< details >}}

- Tier: 旗舰版
- Offering: JihuLab.com
- 链接：[文档](../../api/member_roles.md) | [相关议题](https://gitlab.com/gitlab-org/gitlab/-/issues/416751)

{{< /details >}}

创建自定义角色时，你现在可以使用成员角色 API 添加名称（必填）和描述（可选）。任何现有的自定义角色都已被赋予名称 `Custom`，你可以使用 API 将自定义角色的名称更改为你选择的名称。

### 为群组提及触发 Slack 通知

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: JihuLab.com
- 链接：[文档](../../user/project/integrations/gitlab_slack_application.md#trigger-notifications-for-group-mentions) | [相关议题](https://gitlab.com/gitlab-org/gitlab/-/issues/417751)

{{< /details >}}

极狐GitLab 可以针对某些极狐GitLab 事件向 Slack 工作区频道发送消息。在此版本中，你现在可以在以下公开和私有上下文中为群组提及触发 [Slack 通知](../../user/project/integrations/gitlab_slack_application.md#notification-events)：

- 议题和合并请求描述
- 议题、合并请求和提交的评论

### 在应用设置中扩展可配置的导入限制

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- 链接：[文档](../../administration/settings/import_and_export_settings.md#timeout-for-decompressing-archived-files) | [相关议题](https://gitlab.com/gitlab-org/gitlab/-/issues/421432)

{{< /details >}}

最近，我们将一些硬编码的导入限制转为可配置的应用设置，以便私有化部署极狐GitLab 管理员能够根据自身需求调整这些限制。

在此版本中，我们将解压存档文件的超时时间添加为一个可配置的应用设置。

此限制之前硬编码为 210 秒。在 JihuLab.com 上，对于私有化部署安装的默认情况，我们已将此限制设置为 210 秒。私有化部署极狐GitLab 和 JihuLab.com 的管理员都可以根据需要调整此限制。

### Service Desk 自定义电子邮件地址

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: JihuLab.com
- 链接：[文档](../../user/project/service_desk/configure.md#custom-email-address) | [相关议题](https://gitlab.com/gitlab-org/gitlab/-/issues/329990)

{{< /details >}}

Service Desk 是你的业务与客户之间最重要的连接之一。你现在可以使用自己的自定义电子邮件地址来发送和接收 Service Desk 的电子邮件。通过此更改，可以更轻松地维护品牌形象，并向客户灌输他们正在与正确实体沟通的信心。

此功能处于 Beta 阶段。我们鼓励用户尝试 Beta 功能，并在[反馈议题](https://gitlab.com/gitlab-org/gitlab/-/issues/416637)中提供反馈。

### Geo 支持云原生混合站点上的统一 URL

{{< details >}}

- Tier: 专业版，旗舰版
- 链接：[文档](../../administration/geo/secondary_proxy/_index.md#set-up-a-unified-url-for-geo-sites) | [相关史诗](https://gitlab.com/gitlab-org/charts/gitlab/-/issues/3522)

{{< /details >}}

Geo 现在支持[云原生混合](../../administration/reference_architectures/_index.md#cloud-native-hybrid)站点上的统一 URL，这意味着云原生混合站点可以与主站点共享一个外部 URL。这为你的远程团队提供了无缝的极狐GitLab UI 和 Git 开发者体验，他们可以使用一个通用 URL 根据其位置被自动定向到最佳的 Geo 辅助站点。随着此更新，统一 URL 现在在所有极狐GitLab 参考架构上得到支持。

### Geo 验证对象存储

{{< details >}}

- Tier: 专业版，旗舰版
- 链接：[文档](../../administration/geo/replication/object_storage.md) | [相关议题](https://gitlab.com/groups/gitlab-org/-/epics/8056)

{{< /details >}}

当[对象存储复制由极狐GitLab 管理](../../administration/geo/replication/object_storage.md#enabling-gitlab-managed-object-storage-replication)时，Geo 增加了验证对象存储的能力。为了保护你的对象存储数据免受损坏，Geo 会比较主站点和辅助站点之间的文件大小。如果 Geo 是你灾难恢复策略的一部分，并且你启用了极狐GitLab 管理的对象存储复制，这将保护你免受数据丢失。此外，它还减少了复制可能已存在于辅助站点上的数据的需求。例如，当将一个旧主站点作为辅助站点重新添加时。

## 统一 DevOps 和安全

### 在下游流水线中支持 `environment` 关键字

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: JihuLab.com
- 链接：[文档](../../ci/pipelines/downstream_pipelines.md#downstream-pipelines-for-deployments) | [相关议题](https://gitlab.com/gitlab-org/gitlab/-/issues/369061)

{{< /details >}}

如果你需要从 CI/CD 流水线作业触发下游流水线，你可以使用 `trigger` 关键字。为了增强你的部署管理，你现在可以在使用 `trigger` 时通过 `environment` 关键字指定一个环境。例如，你可以为 `/web-app` 项目上的 `main` 分支触发一个下游流水线，其环境名称为 `dev` 并具有指定的环境 URL。

以前，当你为 CI 和 CD 运行单独的流水线并使用 `trigger` 关键字启动 CD 流水线时，无法指定环境详细信息。这使得从你的 CI 项目跟踪部署变得困难。添加对环境支持的简化了跨项目的部署跟踪。

### 允许用户为强制安全策略定义分支例外

{{< details >}}

- Tier: 旗舰版
- Offering: JihuLab.com
- 链接：[文档](../../user/application_security/policies/_index.md) | [相关史诗](https://gitlab.com/groups/gitlab-org/-/epics/9567)

{{< /details >}}

安全策略强制扫描器在极狐GitLab 项目中运行，并强制进行 MR 检查/审批以确保安全性和合规性。通过分支例外，你可以更精细地强制执行策略，并排除对任何不在范围内的分支的强制执行。如果开发者创建了一个开发或测试分支，意外地受到了严格强制执行的影响，他们可以与安全团队合作，在安全策略中豁免该分支。

对于扫描执行策略，你可以为[流水线](../../user/application_security/policies/scan_execution_policies.md#pipeline-rule-type)或[计划](../../user/application_security/policies/scan_execution_policies.md#schedule-rule-type)规则类型配置例外。对于扫描结果策略，你可以为[`scan_finding`](../../user/application_security/policies/merge_request_approval_policies.md#scan_finding-rule-type)或[`license_finding`](../../user/application_security/policies/merge_request_approval_policies.md#license_finding-rule-type)规则类型指定分支例外。

### 访问令牌到期通知

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- 链接：[文档](../../security/tokens/_index.md) | [相关议题](https://gitlab.com/gitlab-org/gitlab/-/issues/367705)

{{< /details >}}

群组和项目访问令牌常用于自动化。当这些令牌之一即将到期时，通知管理员和群组所有者非常重要，这样可以避免中断。管理员和群组所有者现在会在令牌距离到期还有七天或更少时间时收到通知电子邮件。

### 访问权限到期时发送电子邮件通知

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- 链接：[文档](../../user/group/_index.md#add-users-to-a-group) | [相关议题](https://gitlab.com/gitlab-org/gitlab/-/issues/12704)

{{< /details >}}

用户将在其群组或项目访问权限到期前七天收到电子邮件通知。这仅在设置了访问到期日期时适用。以前，当访问权限到期时没有通知。提前通知意味着你可以联系你的极狐GitLab 管理员以确保连续访问。

### 基于浏览器的 DAST 主动检查 22.1 默认启用

{{< details >}}

- Tier: 旗舰版
- Offering: JihuLab.com
- 链接：[文档](../../user/application_security/dast/browser/checks/_index.md#active-checks) | [相关议题](https://gitlab.com/gitlab-org/gitlab/-/issues/392718)

{{< /details >}}

基于浏览器的 DAST 主动检查 22.1 已默认启用。它取代了已被禁用的 ZAP 检查 6。检查 22.1 识别“对受限目录的路径名限制不当（路径遍历）”，这种漏洞可以通过在 URL 端点的参数中插入有效负载来利用，从而允许读取任意文件。

### 运维容器扫描支持私有仓库

{{< details >}}

- Tier: 旗舰版
- Offering: JihuLab.com
- 链接：[文档](../../user/clusters/agent/vulnerabilities.md#scanning-private-images) | [相关议题](https://gitlab.com/gitlab-org/gitlab/-/issues/415451)

{{< /details >}}

[运维容器扫描](../../user/clusters/agent/vulnerabilities.md)现在可以访问并扫描来自私有容器镜像仓库的镜像。OCS 使用镜像拉取密钥来访问私有仓库容器。

### Dependency 和 License 扫描支持 pnpm lockfile v6.1

{{< details >}}

- Tier: 旗舰版
- Offering: JihuLab.com
- 链接：[文档](../../user/application_security/dependency_scanning/legacy_dependency_scanning/_index.md#obtaining-dependency-information-by-parsing-lockfiles) | [相关议题](https://gitlab.com/gitlab-org/gitlab/-/issues/413903)

{{< /details >}}

感谢来自 [Weyert de Boer](https://gitlab.com/weyert-tapico) 的社区贡献，极狐GitLab Dependency 和 License 扫描现在支持分析使用 v6.1 lockfile 格式的 pnpm 项目。

### SAST 分析器更新

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- 链接：[文档](../../user/application_security/sast/analyzers.md) | [相关议题](../../user/application_security/_index.md)

{{< /details >}}

极狐GitLab SAST 包含[许多安全分析器](../../user/application_security/sast/_index.md#supported-languages-and-frameworks)，极狐GitLab 静态分析团队积极维护、更新和支持这些分析器。我们在 16.4 发布里程碑期间发布了以下更新：

- 将基于 KICS 的分析器更新至 KICS 扫描器的 1.7.7 版本。更多详情，请参阅 [CHANGELOG](https://gitlab.com/gitlab-org/security-products/analyzers/kics/-/blob/main/CHANGELOG.md?ref_type=heads#v415)。
- 将基于 Sobelow 的分析器更新至 Sobelow 扫描器的 0.13.0 版本。我们还将分析器的基础镜像更新为 Elixir 1.13，以提高与较新 Elixir 版本的兼容性。请参阅 [CHANGELOG](https://gitlab.com/gitlab-org/security-products/analyzers/sobelow/-/blob/master/CHANGELOG.md?ref_type=heads#v421)
- 将基于 PMD Apex 的分析器更新至 PMD 扫描器的 6.55.0 版本。更多详情，请参阅 [CHANGELOG](https://gitlab.com/gitlab-org/security-products/analyzers/pmd-apex/-/blob/master/CHANGELOG.md?ref_type=heads#v413)。
- 更改了基于 PHPCS Security Audit 的分析器，移除了 `Security.Misc.IncludeMismatch` 规则。更多详情，请参阅 [CHANGELOG](https://gitlab.com/gitlab-org/security-products/analyzers/phpcs-security-audit/-/blob/master/CHANGELOG.md?ref_type=heads#v411)。
- 更新了基于 Semgrep 的分析器中使用的规则，以修复规则错误、修复规则描述中的损坏链接，并解决了具有相同规则 ID 的 Java 和 Scala 规则之间的冲突。我们还将自定义规则文件的最大大小增加到 10 MB。更多详情，请参阅 [CHANGELOG](https://gitlab.com/gitlab-org/security-products/analyzers/semgrep/-/blob/main/CHANGELOG.md?ref_type=heads#v4412)。

如果你[包含了极狐GitLab 管理的 SAST 模板](../../user/application_security/sast/_index.md)（[`SAST.gitlab-ci.yml`](https://gitlab.com/gitlab-org/gitlab/blob/master/lib/gitlab/ci/templates/Security/SAST.gitlab-ci.yml)）并运行极狐GitLab 16.0 或更高版本，你将自动收到这些更新。
要保留特定版本的任何分析器并阻止自动更新，你可以[固定其版本](../../user/application_security/sast/_index.md)。

有关以前的更改，请参阅[上个月的更新](https://about.gitlab.com/releases/2023/08/22/gitlab-16-3-released/#sast-analyzer-updates)。

### 改进的 SAST 漏洞追踪

{{< details >}}

- Tier: 旗舰版
- 链接：[文档](../../user/application_security/sast/_index.md#advanced-vulnerability-tracking) | [相关议题](https://gitlab.com/gitlab-org/gitlab/-/issues/373921)

{{< /details >}}

极狐GitLab SAST [高级漏洞追踪](../../user/application_security/sast/_index.md#advanced-vulnerability-tracking)通过跟踪代码移动时的发现结果，使分类更高效。

在极狐GitLab 16.4 中，我们为新的语言和分析器启用了高级漏洞追踪。除了其[现有覆盖范围](../../user/application_security/sast/_index.md#advanced-vulnerability-tracking)之外，高级追踪现在可用于：

- 基于 SpotBugs 的 SAST 分析器中的 Java。
- 基于 PHPCS Security Audit 的 SAST 分析器中的 PHP。

这建立在[极狐GitLab 16.3 中发布](https://about.gitlab.com/releases/2023/08/22/gitlab-16-3-released/#improved-sast-vulnerability-tracking)的先前扩展和改进之上。我们正在 [epic 5144](https://gitlab.com/groups/gitlab-org/-/epics/5144) 中追踪进一步的改进。
这些更改包含在极狐GitLab SAST [更新版本](https://gitlab.cn/docs/#sast-analyzer-updates)的[分析器](../../user/application_security/sast/analyzers.md)中。
在使用更新后的分析器扫描项目后，项目的漏洞发现问题将用新的跟踪签名进行更新。
除非你已经[将 SAST 分析器固定到特定版本](../../user/application_security/sast/_index.md)，否则无需采取任何操作即可接收此更新。

<a id="pipeline-specific-cyclonedx-sbom-exports"></a>

### 流水线特定的 CycloneDX SBOM 导出

{{< details >}}

- Tier: 旗舰版
- Offering: JihuLab.com
- Links: [文档](../../api/dependency_list_export.md)

{{< /details >}}

我们添加了一个 API，允许您下载 CycloneDX SBOM，其中列出了在 CI 流水线中检测到的所有组件。这包括应用级依赖和系统级依赖。

<a id="users-with-the-maintainer-role-can-view-runner-details"></a>

### 具有维护者角色的用户可以查看 runner 详细信息

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Links: [文档](../../user/permissions.md)

{{< /details >}}

现在，对一个群组具有维护者角色的用户可以查看群组 runner 的详细信息。具有此角色的用户可以查看群组 runner，以快速确定哪些 runner 可用，或验证自动创建的 runner 是否已成功注册到群组命名空间。

<a id="macos-13-ventura-image-for-saas-runners-on-macos"></a>

### 适用于 macOS SaaS runner 的 macOS 13 (Ventura) 镜像

{{< details >}}

- Tier: 白银版，黄金版
- Offering: JihuLab.com
- Links: [文档](../../ci/runners/hosted_runners/macos.md#supported-macos-images)

{{< /details >}}

团队现在可以在 macOS 13 上无缝地为 Apple 生态系统创建、测试和部署应用程序。

macOS 上的 SaaS runner 使您能够提高开发团队构建和部署需要 macOS 的应用程序的速度，在一个安全、按需的极狐GitLab Runner 构建环境中集成极狐GitLab CI/CD。

<a id="gitlab-runner-16-4"></a>

### 极狐GitLab Runner 16.4

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Links: [文档](https://gitlab.cn/docs/runner)

{{< /details >}}

我们今天还发布了极狐GitLab Runner 16.4！极狐GitLab Runner 是一个轻量级、高度可扩展的代理，运行你的 CI/CD 作业并将结果发送回极狐GitLab 实例。极狐GitLab Runner 与极狐GitLab CI/CD 配合使用，这是极狐GitLab 中包含的开源持续集成服务。

#### 新功能

- 添加队列持续时间直方图指标到 runner Prometheus 指标端点

#### 问题修复

- Kubernetes runner pod 在极狐GitLab Runner 16.3.0 中未清理
- 在缓存下载期间 `gitlab-runner-helper` 终止

所有更改的列表在极狐GitLab Runner [CHANGELOG](https://jihulab.com/gitlab-cn/gitlab-runner/blob/16-4-stable/CHANGELOG.md) 中。

