---
stage: Release Notes
group: Monthly Release
date: 2024-12-19
title: "极狐GitLab 17.7 发布说明"
description: "极狐GitLab 17.7 released with New Planner user role"
---

<!-- markdownlint-disable -->
<!-- vale off -->

2024 年 12 月 19 日，极狐GitLab 17.7 发布，包含以下功能。

<a id="primary-features"></a>

## 主要功能

<a id="new-planner-user-role"></a>

### 新增计划者用户角色

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: JihuLab.com
- Links: [文档](../../user/permissions.md)

{{< /details >}}

我们引入了新的计划者角色，为您提供对敏捷规划工具（如史诗、路线图和看板）的定制访问权限，而无需过度配置[权限](../../user/permissions.md)。此更改有助于您更有效地协作，同时保持工作流程安全并符合最小权限原则。

<a id="instance-administrators-can-control-which-integrations-can-be-enabled"></a>

### 实例管理员可以控制哪些集成可以被启用

{{< details >}}

- Tier: 旗舰版
- Links: [文档](../../administration/settings/project_integration_management.md#integration-allowlist)

{{< /details >}}

实例管理员现在可以配置允许列表，以控制在极狐GitLab 实例上可以启用哪些集成。如果配置了空的允许列表，则实例上不允许任何集成。配置允许列表后，新的极狐GitLab 集成默认不在允许列表中。

之前已启用但后来被允许列表设置阻止的集成将被禁用。如果这些集成再次被允许，它们将以其现有配置重新启用。

<a id="new-user-contribution-and-membership-mapping-available-in-direct-transfer"></a>

### 直接迁移中提供新的用户贡献和成员映射

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: JihuLab.com
- Links: [文档](../../user/group/import/direct_transfer_migrations.md)

{{< /details >}}

现在，当您通过[直接迁移](../../user/group/import/_index.md)在极狐GitLab 实例之间迁移时，可以使用新的用户贡献和成员映射方法。此功能为管理导入过程的用户和接收贡献重新分配的用户提供了灵活性和控制力。使用新方法，您可以：

- 在导入完成后，将成员和贡献重新分配给目标实例上的现有用户。您导入的任何成员和贡献首先映射到占位用户。所有贡献都会与占位用户关联，直到您在目标实例上重新分配它们。
- 为在源实例和目标实例上具有不同电子邮件地址的用户映射成员和贡献。

当您将贡献重新分配给目标实例上的用户时，该用户可以接受或拒绝重新分配。

有关更多信息，请参阅[简化迁移的用户贡献和成员映射](https://gitlab.cn/blog/streamline-migrations-with-user-contribution-and-membership-mapping/)。

<a id="auto-resolve-vulnerabilities-when-not-found-in-subsequent-scans"></a>

### 在后续扫描中未发现时自动解决漏洞

{{< details >}}

- Tier: 旗舰版
- Offering: JihuLab.com
- Links: [文档](../../user/application_security/policies/vulnerability_management_policy.md)

{{< /details >}}

极狐GitLab 的[安全扫描工具](../../user/application_security/_index.md)有助于识别应用程序代码中的已知漏洞和潜在弱点。扫描功能分支会在合并之前发现新的弱点或漏洞，以便进行修复。对于项目默认分支中已存在的漏洞，在功能分支中修复这些漏洞后，当下一次默认分支扫描运行时，该漏洞将被标记为不再检测到。虽然知道哪些漏洞不再被检测到是有用的，但每个漏洞仍必须手动标记为“已解决”才能关闭。即使使用新的[活动过滤器](../../user/application_security/vulnerability_report/_index.md#activity-filter)和[批量更改状态](../../user/application_security/vulnerability_report/_index.md#change-status-of-vulnerabilities)，如果要解决的漏洞很多，这也会很耗时。

我们为希望漏洞在自动化扫描不再检测到时自动设置为“已解决”的用户引入了一种新的策略类型 *漏洞管理策略*。只需配置一个带有新“自动解决”选项的新策略，并将其应用于适当的项目。您甚至可以配置策略仅自动解决特定严重性或来自特定安全扫描器的漏洞。一旦到位，下次扫描项目的默认分支时，任何不再发现的现有漏洞都将被标记为“已解决”。该操作会使用活动记录、操作发生的时间戳以及确定漏洞被移除的流水线来更新漏洞记录。

<a id="rotate-personal-project-and-group-access-tokens-in-the-ui"></a>

### 在 UI 中轮换个人、项目和群组访问令牌

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: JihuLab.com
- Links: [文档](../../user/profile/personal_access_tokens.md#rotate-a-personal-access-token)

{{< /details >}}

现在，您可以使用 UI 轮换个人、项目和群组访问令牌。以前，您必须使用 API 来执行此操作。

感谢 [shangsuru](https://jihulab.com/shangsuru) 的贡献！

<a id="track-cicd-component-usage-across-projects"></a>

### 跨项目跟踪 CI/CD 组件使用情况

{{< details >}}

- Tier: 专业版，旗舰版
- Links: [文档](../../api/graphql/reference/_index.md#cicatalogresourcecomponentusage)

{{< /details >}}

中央 DevOps 团队通常需要跟踪其 CI/CD 组件在流水线中的使用位置，以便更好地管理和优化它们。如果没有可见性，就很难识别过时的组件使用、了解采用率或支持组件生命周期。

为了解决这个问题，我们添加了一个新的 GraphQL 查询，使 DevOps 团队能够查看组件在其组织的流水线中使用的项目列表。
此功能使 DevOps 团队能够通过提供关键洞察来提高生产力并做出更好的决策。

<a id="small-hosted-runner-on-linux-arm-available-to-all-tiers"></a>

### Linux Arm 小型托管 Runner 对所有层级可用

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: JihuLab.com
- Links: [文档](../../ci/runners/hosted_runners/linux.md)

{{< /details >}}

我们很高兴在 JihuLab.com 上推出适用于所有层级的 Linux Arm 小型托管 Runner。
这个 2 vCPUs Arm Runner 与极狐GitLab CI/CD 完全集成，允许您
在 Arm 架构上原生构建和测试应用程序。

我们致力于提供业界最快的 CI/CD 构建速度，并期待看到团队实现更短的反馈周期，并最终更快地交付软件。

<a id="scale-and-deployments"></a>

## 扩展与部署

<a id="omnibus-improvements"></a>

### Omnibus 改进

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Links: [文档](https://gitlab.cn/docs/omnibus/)

{{< /details >}}

由于一个错误，极狐GitLab 17.6 及更早版本的 FIPS Linux 软件包未使用系统 Libgcrypt，而是使用了与常规 Linux 软件包捆绑的相同 Libgcrypt。

此问题已针对极狐GitLab 17.7 的所有 FIPS Linux 软件包修复，AmazonLinux 2 除外。AmazonLinux 2 的 Libgcrypt 版本与 FIPS Linux 软件包附带的 GPGME 和 GnuPG 版本不兼容。

AmazonLinux 2 的 FIPS Linux 软件包将继续使用与常规 Linux 软件包捆绑的相同 Libgcrypt，否则我们将不得不降级 GPGME 和 GnuPG。

<a id="unified-devops-and-security"></a>

## 统一 DevOps 与安全

<a id="improved-detection-accuracy-in-advanced-sast"></a>

### 高级 SAST 中改进的检测准确性

{{< details >}}

- Tier: 旗舰版
- Offering: JihuLab.com
- Links: [文档](../../user/application_security/sast/gitlab_advanced_sast.md)

{{< /details >}}

我们更新了高级 SAST，以更准确地检测以下漏洞类别：

- C#：操作系统命令注入和 SQL 注入。
- Go：路径遍历。
- Java：代码注入、标头或日志中的 CRLF 注入、跨站请求伪造 (CSRF)、不正确的证书验证、不安全的反序列化、不安全的反射以及 XML 外部实体 (XXE) 注入。
- JavaScript：代码注入。

我们还改进了对 C# (ASP.NET) 和 Java (JSF, HttpServlet) 用户输入源的检测，并更新了严重性级别以保持一致性。

要查看高级 SAST 在每种语言中检测到的漏洞类型，请参阅[高级 SAST 覆盖范围](../../user/application_security/sast/advanced_sast_coverage.md)。
要使用这种改进的跨文件、跨函数扫描，请[启用高级 SAST](../../user/application_security/sast/gitlab_advanced_sast.md#turn-on-gitlab-advanced-sast)。
如果您已经启用了高级 SAST，新规则将[自动激活](../../user/application_security/sast/rules.md#how-rule-updates-are-released)。

<a id="efficient-risk-prioritization-with-kev"></a>

### 利用 KEV 进行高效的风险优先级排序

{{< details >}}

- Tier: 旗舰版
- Offering: JihuLab.com
- Links: [文档](../../api/graphql/reference/_index.md#cveenrichmenttype)

{{< /details >}}

在极狐GitLab 17.7 中，我们添加了对已知被利用漏洞目录 (KEV) 的支持。[KEV 目录](https://www.cisa.gov/known-exploited-vulnerabilities-catalog) 由 CISA 维护，整理了已在野外被利用的 CVE 列表。您可以利用 KEV 更好地对扫描结果进行优先级排序，并帮助评估漏洞对您的环境可能产生的影响。

此数据可通过 GraphQL 供组件分析用户使用。

<a id="expanded-code-flow-view-for-advanced-sast"></a>

### 高级 SAST 的扩展代码流视图

{{< details >}}

- Tier: 旗舰版
- Offering: JihuLab.com
- Links: [文档](../../user/application_security/sast/gitlab_advanced_sast.md#code-flow)

{{< /details >}}

高级 SAST [代码流视图](../../user/application_security/sast/gitlab_advanced_sast.md#code-flow) 现在可在显示漏洞的任何位置使用，包括：

- [漏洞报告](../../user/application_security/vulnerability_report/_index.md)。
- [合并请求安全小部件](../../user/application_security/sast/_index.md#merge-request-widget)。
- [流水线安全报告](../../user/application_security/detect/security_scanning_results.md)。
- [合并请求更改视图](../../user/application_security/sast/_index.md#merge-request-changes-view)。

新视图已在 JihuLab.com 上启用。在极狐GitLab 私有化部署中，新视图从极狐GitLab 17.7（合并请求更改视图）和极狐GitLab 17.6（所有其他视图）开始默认开启。有关支持的版本和功能标志的详细信息，请参阅[代码流功能可用性](../../user/application_security/sast/gitlab_advanced_sast.md#code-flow)。

要了解有关高级 SAST 的更多信息，请参阅[公告博客](https://gitlab.cn/blog/gitlab-advanced-sast-is-now-generally-available/)。

<a id="new-help-command-in-gitlab-duo-chat"></a>

### 极狐GitLab Duo Chat 中的新 `/help` 命令

{{< details >}}

- Tier: 专业版，旗舰版
- Offering: JihuLab.com
- Add-ons: Duo Pro, Duo Enterprise
- Links: [文档](../../user/gitlab_duo_chat/examples.md#gitlab-duo-chat-slash-commands)

{{< /details >}}

探索极狐GitLab Duo Chat 的强大功能！只需在聊天消息字段中输入 `/help`，即可探索它能为您做的所有事情。

试试看，体验极狐GitLab Duo Chat 如何让您的工作更顺畅、更高效。

<a id="setting-environmentaction-access-and-prepare-resets-the-auto_stop_in-timer"></a>

### 设置 `environment.action: access` 和 `prepare` 会重置 `auto_stop_in` 计时器

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: JihuLab.com
- Links: [文档](../../ci/yaml/_index.md#environmentauto_stop_in)

{{< /details >}}

以前，当同时使用 `action: prepare`、`action: verify` 和 `action: access` 作业以及 `auto_stop_in` 设置时，计时器不会被重置。从 18.0 开始，`action: prepare` 和 `action: access` 将重置计时器，而 `action: verify` 保持不变。

目前，您可以通过启用 `prevent_blocking_non_deployment_jobs` 功能标志来切换到新的实现。

多个重大更改旨在区分 `environment.action: prepare | verify | access` 值的行为。`environment.action: access` 关键字将保持最接近其当前行为，但计时器重置除外。

为防止未来的兼容性问题，您应该检查对这些关键字的使用。

<a id="kubernetes-131-support"></a>

### Kubernetes 1.31 支持

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: JihuLab.com
- Links: [文档](../../user/clusters/agent/_index.md#supported-kubernetes-versions-for-gitlab-features)

{{< /details >}}

此版本添加了对 2024 年 8 月发布的 Kubernetes 版本 1.31 的全面支持。如果您将应用程序部署到 Kubernetes，现在可以将连接的集群升级到最新版本，并利用其所有功能。

有关更多信息，请参阅我们的 [Kubernetes 支持策略和其他支持的 Kubernetes 版本](../../user/clusters/agent/_index.md#supported-kubernetes-versions-for-gitlab-features)。

<a id="set-namespace-and-flux-resource-path-from-cicd-job"></a>

### 从 CI/CD 作业设置命名空间和 Flux 资源路径

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: JihuLab.com
- Links: [文档](../../ci/environments/kubernetes_dashboard.md)

{{< /details >}}

要使用 Kubernetes 仪表板，您需要从环境设置中选择一个用于 Kubernetes 连接的代理，并可选择配置命名空间和 Flux 资源以跟踪协调状态。在极狐GitLab 17.6 中，我们添加了通过 CI/CD 配置选择代理的支持。但是，配置命名空间和 Flux 资源仍然需要使用 UI 或进行 API 调用。在 17.7 中，您可以使用 CI/CD 语法通过 `environment.kubernetes.namespace` 和 `environment.kubernetes.flux_resource_path` 属性完全配置仪表板。

<a id="group-and-project-access-tokens-in-credentials-inventory"></a>

### 凭据清单中的群组和项目访问令牌

{{< details >}}

- Tier: 旗舰版
- Offering: JihuLab.com
- Links: [文档](../../administration/credentials_inventory.md)

{{< /details >}}

群组和项目访问令牌现在在 JihuLab.com 的凭据清单中可见。以前，只有个人访问令牌和 SSH 密钥可见。清单中额外的令牌类型可以更全面地了解群组中的凭据。

<a id="extended-token-expiration-notifications"></a>

### 扩展的令牌过期通知

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: JihuLab.com
- Links: [文档](../../security/tokens/_index.md)

{{< /details >}}

以前，令牌过期电子邮件通知仅在到期前七天发送。现在，这些通知也会在到期前 30 天和 60 天发送。通知频率和日期范围的增加使用户更加了解可能即将过期的令牌。

<a id="unicode-151-emoji-support"></a>

### Unicode 15.1 表情符号支持 🦖🍋‍🟩🐦‍🔥

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: JihuLab.com
- Links: [文档](https://gitlab-org.gitlab.io/ruby/gems/tanuki_emoji/)

{{< /details >}}

在极狐GitLab 的早期版本中，表情符号支持仅限于较旧的 Unicode 标准，这意味着一些较新的表情符号不可用。

极狐GitLab 17.7 引入了对 Unicode 15.1 的支持，带来了最新的表情符号添加。这包括令人兴奋的新选项，如霸王龙 🦖、青柠 🍋‍🟩 和凤凰 🐦‍🔥，让您能够使用最新的符号表达自己。

此外，此更新增强了表情符号的多样性，确保在不同文化、语言和身份之间具有更大的代表性，帮助每个人在平台上交流时感到被包容。

<a id="set-your-preferred-text-editor-as-default"></a>

### 将首选文本编辑器设为默认

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: JihuLab.com
- Links: [文档](../../user/profile/preferences.md#set-the-default-text-editor)

{{< /details >}}

在此版本中，我们引入了设置默认文本编辑器的功能，以获得更个性化的编辑体验。通过此更改，您现在可以在富文本编辑器、纯文本编辑器之间进行选择，或选择不设默认值，从而在创建和编辑内容时具有灵活性。

此更新通过使编辑器界面与个人偏好或团队标准保持一致，确保了更顺畅的工作流程。通过此增强功能，极狐GitLab 继续优先考虑所有用户的定制化和可用性。

<a id="new-description-field-for-access-tokens"></a>

### 访问令牌的新描述字段

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: JihuLab.com
- Links: [文档](../../user/profile/personal_access_tokens.md#create-a-personal-access-token)

{{< /details >}}

创建个人、项目、群组或模拟访问令牌时，您现在可以选择输入该令牌的描述。这有助于提供有关令牌的额外上下文，例如它的使用位置和方式。

<a id="enable-secret-push-protection-in-your-groups-with-apis"></a>

### 通过 API 在群组中启用密钥推送保护

{{< details >}}

- Tier: 旗舰版
- Offering: JihuLab.com
- Links: [文档](../../api/group_security_settings.md)

{{< /details >}}

在此版本中，您现在可以通过 [REST API](../../api/group_security_settings.md) 和 [GraphQL API](../../api/graphql/reference/_index.md#mutationsetgroupsecretpushprotection) 在群组中的所有项目上启用密钥推送保护。这使您可以按群组高效地启用密钥推送保护，而不是逐个项目进行。每次启用或禁用推送保护时都会记录审计事件。

<a id="new-api-endpoint-to-list-enterprise-users"></a>

### 列出企业用户的新 API 端点

{{< details >}}

- Tier: 专业版，旗舰版
- Offering: JihuLab.com
- Links: [文档](../../api/group_enterprise_users.md)

{{< /details >}}

群组所有者现在可以使用专用的 API 端点来列出企业用户及其任何关联属性。

<a id="remove-owner-base-role-from-custom-roles"></a>

### 从自定义角色中移除所有者基础角色

{{< details >}}

- Tier: 旗舰版
- Offering: JihuLab.com
- Links: [文档](../../user/custom_roles/_index.md#create-a-custom-member-role)

{{< /details >}}

创建自定义角色时，所有者基础角色不再可用，因为它没有提供额外的价值，因为权限是累加的。具有所有者基础角色的现有自定义角色不受此更改的影响。

<a id="navigation-and-usability-improvements-for-the-compliance-center"></a>

### 合规中心的导航和可用性改进

{{< details >}}

- Tier: 旗舰版，专业版
- Offering: JihuLab.com
- Links: [文档](../../user/compliance/compliance_center/compliance_frameworks_report.md)

{{< /details >}}

我们继续对群组和项目的合规中心用户体验进行迭代和重要的改进。

在极狐GitLab 17.7 中，我们交付了两项关键改进：

- 用户现在可以在合规中心的 **项目** 选项卡中按群组进行筛选，这为用户提供了另一种选项来应用、筛选和搜索适当的项目以及附加到该项目的合规框架。
- 项目的合规中心现在有一个 **框架** 选项卡，允许用户搜索附加到该特定项目的合规框架。

请注意，添加或编辑框架仍然在群组上完成，而不是在项目上。

