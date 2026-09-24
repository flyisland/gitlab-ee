---
stage: Release Notes
group: Monthly Release
date: 2025-04-17
title: "极狐GitLab 17.11 发行说明"
description: "GitLab 17.11 released with Customize compliance frameworks with requirements and compliance controls"
---

<!-- markdownlint-disable -->
<!-- vale off -->

2025 年 4 月 17 日，极狐GitLab 17.11 已发布，包含以下功能。

<a id="primary-features"></a>

## 主要特性

<a id="customize-compliance-frameworks-with-requirements-and-compliance-controls"></a>

### 通过要求与合规控制自定义合规框架

{{< details >}}

- Tier: 旗舰版
- Offering: JihuLab.com
- Links: [文档](../../user/compliance/compliance_center/compliance_status_report.md)

{{< /details >}}

之前，极狐GitLab 中的合规框架可以作为标签创建，用于标识你的项目具有特定的合规要求或需要额外的监督。这个标签随后可以作为范围机制，确保安全策略能在群组中的所有项目上强制执行。

在此版本中，我们为合规经理引入了一种通过“要求”在极狐GitLab 中实现更深层次合规监控的新方式。

通过要求，作为自定义合规框架的一部分，你可以根据一系列不同的合规标准、法律和规章，定义组织必须遵循的特定要求。

我们还将提供的合规控制数量从 5 个扩展到超过 50 个！这 50 个开箱即用（OOTB）的控制可以与合规框架要求进行映射。

这些控制会检查你极狐GitLab 实例中特定的项目、安全和合并请求设置，帮助你满足一系列合规标准、法律和规章的要求，例如 SOC2、NIST、ISO 27001 和极狐GitLab CIS 基准。

这些控制的遵循情况会反映在标准的遵循报告中，该报告经过重新设计，充分考虑了要求以及控制与要求的映射关系。

除了扩展 OOTB 控制之外，我们现在还允许用户将要求映射到外部控制，这些外部控制可以针对极狐GitLab 平台外部存在的项目、程序或系统。这些映射使你能够将极狐GitLab 合规中心作为合规监控和审计证据需求的唯一真实来源。

<a id="more-gitlab-duo-features-now-available-on-gitlab-duo-self-hosted"></a>

### 更多极狐GitLab Duo 功能现已在极狐GitLab Duo 自托管中可用

{{< details >}}

- Tier: 旗舰版
- Add-ons: Duo Enterprise
- Links: [文档](../../administration/gitlab_duo_self_hosted/_index.md#feature-versions-and-status) | [关联史诗](https://gitlab.com/groups/gitlab-org/-/epics/17072)

{{< /details >}}

你现在可以在极狐GitLab 私有化部署实例的极狐GitLab Duo 自托管中使用更多[极狐GitLab Duo](https://gitlab.cn/gitlab-duo/) 功能。以下功能以测试版提供：

- [根因分析](../../user/gitlab_duo_chat/examples.md#troubleshoot-failed-cicd-jobs-with-root-cause-analysis)
- [漏洞解释](../../user/application_security/analyze/duo.md)
- [漏洞修复](../../user/application_security/vulnerabilities/_index.md#vulnerability-resolution)
- [AI 影响仪表板](../../user/analytics/duo_and_sdlc_trends.md)
- [讨论摘要](../../user/discussions/_index.md#summarize-issue-discussions-with-gitlab-duo-chat)
- [合并请求提交信息](../../user/project/merge_requests/duo_in_merge_requests.md#generate-a-merge-commit-message)
- [合并请求摘要](../../user/project/merge_requests/duo_in_merge_requests.md#generate-a-description-by-summarizing-code-changes)
- [用于 CLI 的极狐GitLab Duo](https://gitlab.cn/docs/editor_extensions/gitlab_cli/#gitlab-duo-for-the-cli)

[代码审查摘要](../../user/project/merge_requests/duo_in_merge_requests.md#summarize-a-code-review)也作为实验性功能在极狐GitLab Duo 自托管中可用。

<a id="enhance-security-with-protected-container-tags"></a>

### 通过受保护的容器标签增强安全性

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Links: [文档](../../user/packages/container_registry/protected_container_tags.md) | [关联议题](https://gitlab.com/gitlab-org/gitlab/-/issues/523893)

{{< /details >}}

容器镜像仓库是现代 DevSecOps 团队的关键基础设施。在此之前，拥有开发者角色或更高权限的极狐GitLab 用户可以在其项目中推送和删除任何容器标签，这带来了对生产关键容器镜像的意外或未经授权更改的风险。

有了受保护的容器标签，你现在可以精细控制谁可以推送或删除特定的容器标签。你可以：

- 每个项目最多创建五条保护规则。
- 使用 RE2 正则表达式模式来保护像 `latest`、语义化版本（例如 `v1.0.0`）或稳定发布标签（例如 `main-stable`）这样的标签。
- 将推送和删除操作限制为维护者、所有者或管理员角色。
- 阻止受保护的标签被清理策略删除。

此功能需要下一代容器镜像仓库，该仓库已在 JihuLab.com 上默认启用。对于极狐GitLab 私有化部署实例，你需要启用[元数据库](../../administration/packages/container_registry_metadata_database.md)才能使用受保护的容器标签。

<a id="safeguard-your-registry-with-protected-maven-packages"></a>

### 通过受保护的 Maven 软件包保护你的仓库

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: JihuLab.com
- Links: [文档](../../user/packages/package_registry/package_protection_rules.md) | [关联议题](https://gitlab.com/gitlab-org/gitlab/-/issues/323969)

{{< /details >}}

我们激动地推出对受保护 Maven 软件包的支持，以增强极狐GitLab 软件包仓库的安全性和稳定性。软件包的意外修改可能会打乱整个开发流程。借助受保护的软件包，你可以保护最重要的依赖项免受意外变更。

在极狐GitLab 17.11 中，你现在可以通过创建保护规则来保护 Maven 软件包。如果某个软件包匹配保护规则，则只有指定的用户才能推送该软件包的新版本。软件包保护规则可以防止意外覆盖，提高对法规要求的合规性，并减少人工监督的需求。

[受保护的软件包](https://gitlab.com/groups/gitlab-org/-/epics/5574)对 Maven 和其他软件包格式的支持全部来自社区贡献者 `gerardo-navarro` 和 Siemens 团队。感谢 Gerardo 以及 Siemens 团队为极狐GitLab 做出的诸多贡献！

<a id="epic-issue-and-task-custom-fields"></a>

### 史诗、议题和任务自定义字段

{{< details >}}

- Tier: 专业版，旗舰版
- Offering: JihuLab.com
- Links: [文档](../../user/work_items/custom_fields.md) | [关联史诗](https://gitlab.com/groups/gitlab-org/-/epics/14904)

{{< /details >}}

在此版本中，你可以为议题、史诗、任务、目标和关键结果配置文本、数字、单选和多选自定义字段。虽然到目前为止，标签一直是分类工作项的主要方式，但自定义字段提供了一种对用户更友好的方法来为你的计划工件添加结构化元数据。

自定义字段在顶级群组中配置，并向下级联到所有子群组和项目。你可以将字段映射到一个或多个工作项类型，并在议题和史诗列表中按自定义字段值进行筛选。

<a id="new-issue-look-now-generally-available"></a>

### 新议题界面现已 GA

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: JihuLab.com
- Links: [文档](../../user/project/issues/_index.md) | [关联议题](https://gitlab.com/gitlab-org/gitlab/-/issues/525547)

{{< /details >}}

从本版本开始，新议题界面已 GA 并取代了旧版议题体验。议题现在与史诗和任务共享一个通用框架，具有实时更新和工作流改进：

- **抽屉视图：** 你可以从列表或看板中将项目在抽屉中打开，以便快速查看而无需离开当前上下文。顶部的按钮可让你展开至全页面视图。
- **更改类型：** 使用“更改类型”操作在史诗、议题和任务之间转换类型（取代了“提升为史诗”）
- **开始日期：** 议题现支持开始日期，使它们的功能与史诗和任务保持一致。
- **层级关系：** 完整的层级结构显示在标题上方和侧边栏的父级字段中。要管理关系，请使用新的快速操作命令 `/set_parent`、`/remove_parent`、`/add_child` 和 `/remove_child`。
- **控件：** 所有操作现在都可以从顶部菜单（垂直省略号）中访问，该菜单在滚动时保持在粘性标题中可见。
- **开发：** 与议题或任务相关的所有开发项（合并请求、分支和功能标志）现在都整合在一个便捷的列表中。
- **布局：** UI 的改进使议题、史诗、任务和合并请求之间的体验更加无缝，帮助你更高效地导航工作流。
- **链接项：** 通过改进的链接选项在任务、议题和史诗之间创建关系。拖放以更改链接类型，并切换标签和已关闭项目的可见性。

<a id="service-accounts-ui"></a>

### 服务账户 UI

{{< details >}}

- Tier: 专业版，旗舰版
- Offering: JihuLab.com
- Links: [文档](../../user/profile/service_accounts.md) | [关联史诗](https://gitlab.com/groups/gitlab-org/-/epics/9965)

{{< /details >}}

你现在可以在极狐GitLab UI 中使用一个专门的空间来创建和管理服务账户。此界面允许你创建、监控和控制对极狐GitLab 资源的自动化访问。此前，该功能仅可通过 API 使用。

<a id="automated-duo-pro-and-duo-enterprise-seat-assignment"></a>

### 自动化 Duo Pro 和 Duo Enterprise 席位分配

{{< details >}}

- Tier: 专业版，旗舰版
- Offering: JihuLab.com
- Add-ons: Duo Pro, Duo Enterprise
- Links: [文档](../../user/group/saml_sso/group_sync.md#manage-gitlab-duo-seat-assignment) | [关联议题](https://gitlab.com/gitlab-org/gitlab/-/issues/502496)

{{< /details >}}

你现在可以通过 SAML 群组同步自动为用户分配 Duo Pro 或 Duo Enterprise 席位。只要极狐GitLab 群组有可用的 Duo Pro 或 Duo Enterprise 席位，任何从身份提供商映射过来的用户都会自动分配到一个席位。这减少了管理席位分配的工作量。

<a id="cicd-pipeline-inputs"></a>

### CI/CD 流水线输入

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Links: [文档](../../ci/inputs/_index.md#for-a-pipeline)

{{< /details >}}

CI/CD 变量对于动态 CI/CD 工作流至关重要，它们被用于多种用途，包括环境变量、上下文变量、工具配置和矩阵变量。但开发人员有时会依赖 CI/CD 变量来注入[流水线变量](../../ci/variables/_index.md#use-pipeline-variables)以手动修改流水线行为，由于流水线变量具有更高的优先级，这存在一些风险。

在极狐GitLab 17.11 及更高版本中，你现在可以使用 `inputs` 安全地修改流水线行为，而不是使用流水线变量，包括在定时流水线、下游流水线、触发流水线以及其他场景中。输入为开发人员提供了一种更结构化、更灵活的解决方案，用于在 CI/CD 作业运行时注入动态内容。在你切换到输入之后，你可以完全[禁用对流水线变量的访问](../../ci/variables/_index.md#restrict-pipeline-variables)。

我们非常希望你试用该功能并通过此专用[议题](https://gitlab.com/gitlab-org/gitlab/-/issues/533802)分享你的反馈。

<a id="agentic-core"></a>

## Agentic Core

<a id="gitlab-duo-chat-now-uses-anthropic-claude-sonnet-3-7"></a>

### 极狐GitLab Duo Chat 现在使用国内 SOTA 大模型

{{< details >}}

- Tier: 专业版，旗舰版
- Offering: JihuLab.com
- Add-ons: Duo Pro, Duo Enterprise
- Links: [文档](../../user/gitlab_duo_chat/examples.md) | [关联议题](https://gitlab.com/gitlab-org/gitlab/-/issues/521034)

{{< /details >}}

极狐GitLab Duo Chat 现在使用国内 SOTA 大模型作为基础模型，取代了之前用于回答大多数问题的国内 SOTA 大模型。

该模型在编码和推理能力方面有显著提升，使其在解释代码、生成代码、处理文本数据和回答复杂的 DevSecOps 问题方面更加出色。你会在这些领域注意到更详细和准确的 Chat 回答。

此升级适用于所有 Chat 功能，确保整个 Chat 界面具有一致且改进的体验。

<a id="open-files-as-context-now-available-on-gitlab-duo-self-hosted-code-suggestions"></a>

### 已打开文件作为上下文现已在极狐GitLab Duo 自托管代码建议中可用

{{< details >}}

- Tier: 旗舰版
- Add-ons: Duo Enterprise
- Links: [文档](../../user/project/repository/code_suggestions/context.md#using-open-files-as-context) | [关联史诗](https://gitlab.com/groups/gitlab-org/-/epics/16611)

{{< /details >}}

在极狐GitLab Duo 自托管上，你现在可以在使用代码建议时，将[IDE 中标签页打开的文件](../../user/project/repository/code_suggestions/context.md#using-open-files-as-context)作为上下文。

<a id="select-individual-models-for-ai-powered-features-on-gitlab-duo-self-hosted"></a>

### 在极狐GitLab Duo 自托管上为 AI 功能选择单独的模型

{{< details >}}

- Tier: 旗舰版
- Add-ons: Duo Enterprise
- Links: [文档](../../administration/gitlab_duo_self_hosted/configure_duo_features.md#select-a-self-hosted-model-for-a-feature) | [关联史诗](https://gitlab.com/groups/gitlab-org/-/epics/17099)

{{< /details >}}

在极狐GitLab Duo 自托管上，你现在可以为极狐GitLab 私有化部署实例上的每个极狐GitLab Duo 功能和子功能选择并配置单独的受支持模型。

要提供反馈，请访问[议题 524175](https://gitlab.com/gitlab-org/gitlab/-/issues/524175)。

<a id="llama-3-models-generally-available-for-gitlab-duo-chat-and-code-suggestions"></a>

### Llama 3 模型对极狐GitLab Duo Chat 和代码建议 GA

{{< details >}}

- Tier: 旗舰版
- Add-ons: Duo Enterprise
- Links: [文档](../../administration/gitlab_duo_self_hosted/supported_models_and_hardware_requirements.md#supported-models) | [关联史诗](https://gitlab.com/groups/gitlab-org/-/epics/15678)

{{< /details >}}

Llama 3 模型现已与极狐GitLab Duo 自托管一起 GA，支持极狐GitLab Duo Chat 和代码建议。

有关在极狐GitLab Duo 自托管上使用这些模型的反馈，请参见[议题 523918](https://gitlab.com/gitlab-org/gitlab/-/issues/523918)。

<a id="manage-multiple-conversations-in-gitlab-duo-chat"></a>

### 在极狐GitLab Duo Chat 中管理多个对话

{{< details >}}

- Tier: 专业版，旗舰版
- Offering: JihuLab.com
- Add-ons: Duo Pro, Duo Enterprise
- Links: [文档](../../user/gitlab_duo_chat/_index.md#have-multiple-conversations) | [关联史诗](https://gitlab.com/groups/gitlab-org/-/epics/16108)

{{< /details >}}

极狐GitLab Duo Chat 的多对话功能现已在 Web UI 中的极狐GitLab 私有化部署实例上可用。你可以创建新对话、浏览对话历史并在对话之间切换而不会丢失上下文。

为了保护你的隐私，30 天无活动的对话将被自动删除，你也可以随时手动删除任何对话。在极狐GitLab 私有化部署上，管理员可以缩短对话的保留时间。

在[议题 526013](https://gitlab.com/gitlab-org/gitlab/-/issues/526013) 中与我们分享你的体验。

<a id="scale-and-deployments"></a>

## Scale and Deployments

<a id="all-auto-disabled-webhooks-now-automatically-re-enable"></a>

### 所有自动禁用的 Webhooks 现在会自动重新启用

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: JihuLab.com
- Links: [文档](../../user/project/integrations/webhooks.md#auto-disabled-webhooks) | [关联议题](https://gitlab.com/gitlab-org/gitlab/-/issues/396577)

{{< /details >}}

在此版本中，返回 `4xx` 错误码的 Webhooks 现在会自动重新启用。所有错误（`4xx`、`5xx` 或服务器错误）都按相同方式处理，从而实现更可预测的行为和更轻松的故障排除。此变更已在[此博客文章](https://gitlab.cn/blog/gitlab-webhooks-get-smarter-with-self-healing-capabilities/)中公布。

失败的 Webhooks 会被暂时禁用一分钟，最长延长至 24 小时。当 Webhook 连续失败 40 次后，它现在会被永久禁用。

在极狐GitLab 17.10 及更早版本中永久禁用的 Webhooks 经历了一次数据迁移。

- 对于 JihuLab.com，这些更改自动适用。
- 对于极狐GitLab 私有化部署，这些更改仅影响启用了 `auto_disabling_webhooks` 功能标志的实例。

感谢 [Phawin](https://gitlab.com/lifez) 的[此社区贡献](https://gitlab.com/gitlab-org/gitlab/-/merge_requests/166329)！

<a id="ghost-user-contributions-auto-mapped-during-imports"></a>

### Ghost 用户贡献在导入期间自动映射

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: JihuLab.com
- Links: [文档](../../user/import/mapping/post_migration_mapping.md) | [关联议题](https://gitlab.com/gitlab-org/gitlab/-/issues/514014)

{{< /details >}}

此前，Ghost 用户贡献会创建需要手动重新分配的占位引用，从而在迁移过程中产生额外工作。现在，使用新的[贡献和成员映射功能](../../user/import/mapping/post_migration_mapping.md)的导入器、通过直接转移迁移、GitHub、Bitbucket Server 和 Gitea 导入器，可以更智能地处理 Ghost 用户贡献。在将内容导入到极狐GitLab 时，源实例上之前由 Ghost 用户做出的贡献现在会自动映射到目标实例上的 Ghost 用户。

此增强功能消除了为 Ghost 用户贡献创建不必要的占位用户，减少了用户映射界面的混乱，并简化了迁移过程。

<a id="saml-verification-for-contribution-reassignment-when-importing-to-gitlab-com"></a>

### 导入到 JihuLab.com 时用于贡献重新分配的 SAML 验证

{{< details >}}
- Tier: 专业版，旗舰版
- Offering: JihuLab.com
- Links: [文档](../../user/import/mapping/reassignment.md)

{{< /details >}}

在此里程碑中，我们为导入到 JihuLab.com 时的贡献重新分配添加了 SAML 验证检查。这些检查可防止在启用了 SAML SSO 的群组中出现重新分配错误。

如果您导入到 JihuLab.com 并对 JihuLab.com 群组使用 SAML SSO，则所有用户必须先将其 SAML 身份关联到其 JihuLab.com 账户，然后您才能重新分配贡献和成员资格。当您将贡献重新分配给尚未验证其 SAML 身份的用户时，您将收到错误消息。这些消息说明了为确保正确归属群组成员资格而需要采取的步骤。

<a id="filter-placeholder-users-in-admin-area"></a>

### 在管理区域筛选占位用户

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: JihuLab.com
- Links: [文档](../../administration/admin_area.md#administering-users)

{{< /details >}}

以前，在导入过程中创建的占位用户与普通用户混杂在一起，在 **管理** 区域的 **用户** 页面上没有明确区分。

在此版本中，管理员现在可以在 **管理** 区域的 **用户** 页面的搜索框中筛选占位账户。为此，请在下拉列表中选择 `类型`，然后选择 `占位`。

<a id="placeholder-user-limits-appear-in-group-usage-quotas"></a>

### 占位用户限制显示在群组使用配额中

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: JihuLab.com
- Links: [文档](../../user/import/mapping/post_migration_mapping.md#placeholder-user-limits)

{{< /details >}}

对于导入到 JihuLab.com 的情况，占位用户在每个顶级群组中受到限制。这些限制取决于您的极狐GitLab 许可证和席位数量。在此版本中，可以在 UI 中检查顶级群组的占位用户使用情况和限制。

要查看当前使用情况和限制：

1. 在左侧边栏中，选择 **搜索或跳转到** 并找到您的群组。此群组必须位于顶级。
1. 选择 **设置 > 使用配额**。
1. 选择 **导入** 选项卡。

<a id="geo---new-replicables-view"></a>

### Geo - 新复制品视图

{{< details >}}

- Tier: 专业版，旗舰版
- Links: [文档](../../administration/geo/_index.md)

{{< /details >}}

我们正在为 Geo 中的复制品视图引入新的外观和感觉。新体验更好地与极狐GitLab 的其余部分保持一致，并提供了一个更精简、更少杂乱的界面来查看 Geo 辅助站点的同步和验证状态。此外，现在每个可复制项目都有一个可点击的详细视图，提供诸如主要和辅助校验和、错误详情等信息。这些信息将使排查 Geo 同步问题变得更加容易。

<a id="linux-package-improvements"></a>

### Linux 包改进

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Links: [文档](https://gitlab.cn/docs/omnibus)

{{< /details >}}

在极狐GitLab 18.0 中，PostgreSQL 的最低支持版本将是 16。为了为此变更做准备，在不使用 [PostgreSQL 集群](../../administration/postgresql/replication_and_failover.md) 的实例上，升级到极狐GitLab 17.11 时将尝试自动将 PostgreSQL 升级到版本 16。

如果您使用 [PostgreSQL 集群](../../administration/postgresql/replication_and_failover.md) 或 [选择退出此自动升级](https://gitlab.cn/docs/omnibus/settings/database/#opt-out-of-automatic-postgresql-upgrades)，则必须 [手动升级到 PostgreSQL 16](https://gitlab.cn/docs/omnibus/settings/database/#upgrade-packaged-postgresql-server) 才能升级到极狐GitLab 18.0。

<a id="pre-deployment-opt-out-toggle-to-disable-event-data-sharing"></a>

### 部署前选择退出开关以禁用事件数据共享

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: JihuLab.com
- Links: [文档](../../administration/settings/event_data.md)

{{< /details >}}

在极狐GitLab 18.0 中，我们计划从私有化部署实例启用事件级产品使用数据收集。与聚合数据不同，事件级数据为极狐GitLab 提供更深入的使用洞察，使我们能够改善平台上的用户体验并提高功能采用率。

从极狐GitLab 17.11 开始，您将能够在事件数据收集开始之前选择退出，从而有效地允许您提前选择参与。有关更多信息以及如何选择退出的详细信息，请参阅我们的文档。

## 统一 DevOps 与安全

<a id="increased-rule-coverage-for-secret-push-protection-and-pipeline-secret-detection"></a>

### 增强了密钥推送保护和流水线密钥检测的规则覆盖

{{< details >}}

- Tier: 旗舰版
- Offering: JihuLab.com
- Links: [文档](../../user/application_security/secret_detection/detected_secrets.md)

{{< /details >}}

极狐GitLab 密钥检测已收到重大更新，包括 17 条新的密钥推送保护规则和 12 条新的流水线密钥检测规则。一些现有规则也已更新，以提高质量并减少误报。有关详细信息，请参阅 [变更日志](https://jihulab.com/gitlab-cn/security-products/secret-detection/secret-detection-rules/-/blob/main/CHANGELOG.md#v090) 中的 v0.9.0。

<a id="static-reachability-beta-with-python-support"></a>

### 静态可达性测试版支持 Python

{{< details >}}

- Tier: 旗舰版
- Offering: JihuLab.com
- Links: [文档](../../user/application_security/dependency_scanning/static_reachability.md) | [相关史诗](https://jihulab.com/groups/gitlab-cn/-/epics/15781)

{{< /details >}}

组合分析团队已发布了对 Python 的静态可达性测试版支持。此测试版侧重于增强稳定性和可观测性，并通过更简单的配置提供更好的用户体验。

静态可达性丰富了软件组合分析（SCA）结果。由极狐GitLab 高级 SAST 提供支持，静态可达性扫描项目源代码以识别哪些开源依赖项正在被使用。

您可以将静态可达性产生的数据作为分类和修复决策的一部分。静态可达性数据还可以与 CVSS 和 EPSS 评分以及 KEV 指标一起使用，以提供更集中的漏洞视图。

我们欢迎对此功能的反馈。如果您有疑问、意见或希望与我们的团队交流，请联系我们。

<a id="dynamic-analysis-support-for-reflected-xss-checks"></a>

### 动态分析支持反射型 XSS 检查

{{< details >}}

- Tier: 旗舰版
- Offering: JihuLab.com
- Links: [文档](../../user/application_security/dast/browser/checks/_index.md)

{{< /details >}}

动态分析团队引入了对 [CWE-79](https://cwe.mitre.org/data/definitions/79.html) 的检查。这项工作使我们的 DAST 扫描器能够检查反射型 XSS 攻击。

检查反射型 XSS 默认开启。要关闭此检查，请在您的配置中设置 `DAST_FF_XSS_ATTACK: false`。

<a id="assign-projects-when-creating-compliance-frameworks"></a>

### 创建合规框架时分配项目

{{< details >}}

- Tier: 旗舰版，专业版
- Offering: JihuLab.com
- Links: [文档](../../user/compliance/compliance_frameworks/_index.md#apply-a-compliance-framework-to-a-project)

{{< /details >}}

过去，在创建合规框架后，您必须导航到合规中心的 **项目** 选项卡才能将新的合规框架分配给项目。这种情况为在群组中创建新的合规框架带来了不必要的摩擦。

在极狐GitLab 17.11 中，创建合规框架时，我们引入了一个新步骤，该步骤提供了在创建合规框架之前将多个项目分配给该框架的选项。

这项新功能：

- 帮助您保持在合规框架创建工作流中。
- 为您提供指导，让您了解合规框架与群组中的项目协同工作，以监控和强制执行整个群组的合规性。

<a id="kubernetes-1-32-support"></a>

### Kubernetes 1.32 支持

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: JihuLab.com
- Links: [文档](../../user/clusters/agent/_index.md#supported-kubernetes-versions-for-gitlab-features)

{{< /details >}}

此版本添加了对 2024 年 12 月发布的 Kubernetes 版本 1.32 的全面支持。如果您将应用部署到 Kubernetes，现在可以将连接的集群升级到最新版本，并利用其所有功能。

您可以阅读有关 [我们的 Kubernetes 支持策略和其他受支持的 Kubernetes 版本](../../user/clusters/agent/_index.md#supported-kubernetes-versions-for-gitlab-features) 的更多信息。

<a id="docker-hub-authentication-ui-for-the-dependency-proxy"></a>

### 依赖代理的 Docker Hub 认证 UI

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Links: [文档](../../user/packages/dependency_proxy/_index.md#authenticate-with-docker-hub)

{{< /details >}}

我们很高兴地宣布在极狐GitLab 依赖代理中为 Docker Hub 认证提供 UI 支持。此功能最初在极狐GitLab 17.10 中引入，仅支持 GraphQL API，现在包括一个用户界面，以便于配置。

通过此增强功能，您现在可以直接从群组设置页面配置 Docker Hub 认证，帮助您：

- 避免由于速率限制导致的流水线失败。
- 访问私有 Docker Hub 镜像。
- 安全地存储您的 Docker Hub 凭据、[个人访问令牌](https://docs.docker.com/security/for-developers/access-tokens/) 或 [组织访问令牌](https://docs.docker.com/security/for-admins/access-tokens/)。

这种简化的方法使得无需使用 GraphQL API 即可更轻松地维持在 CI/CD 流水线中对 Docker Hub 镜像的不间断访问。

<a id="set-work-in-progress-limits-by-weight"></a>

### 按权重设置在制品限制

{{< details >}}

- Tier: 专业版，旗舰版
- Offering: JihuLab.com
- Links: [文档](../../user/project/issue_board.md#work-in-progress-limits)

{{< /details >}}

您现在除了按议题数量外，还可以按权重设置在制品限制，从而在管理工作负载方面为您提供更大的灵活性。

根据每个任务的复杂性或工作量来控制工作流，而不仅仅是议题的数量。使用议题权重来表示工作量的团队现在可以通过限制给定看板列表中议题的总权重来确保他们不会过度承诺。

使用此功能来优化团队的生产力，并创建一个更平衡的工作流，以适应不同的任务复杂性。

<a id="improved-wiki-sidebar-styling"></a>

### 改进的 Wiki 侧边栏样式

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: JihuLab.com
- Links: [文档](../../user/project/wiki/_index.md#customize-sidebar)

{{< /details >}}

自定义 Wiki 侧边栏现在具有改进的样式，包括更小的标题尺寸和更好的列表左内边距。这些人体工程学增强提高了通过 `_sidebar` Wiki 页面创建的自定义导航的可读性。

自定义侧边栏帮助团队以适合其独特知识库结构的方式组织 Wiki 内容。通过此样式更新，侧边栏现在更易于浏览，创建了更清晰的视觉层次，帮助团队成员更快地找到相关信息。

<a id="display-last-comment-as-a-column-in-glql-views"></a>

### 在 GLQL 视图中将最后评论显示为列

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: JihuLab.com
- Links: [文档](../../user/glql/fields.md)

{{< /details >}}

GLQL 视图现在支持将议题或合并请求的最后评论显示为列。通过在 GLQL 查询中包含 `lastComment` 作为字段，您可以在不离开当前上下文的情况下查看最新更新。

以前，您必须单独打开每个议题或合并请求才能查看最后评论，这很耗时，并且难以快速了解进展。此改进通过提供对正在进行的对话和状态更新的概览可见性，帮助团队保持动力。

我们欢迎您对此增强功能和 GLQL 视图的反馈。

<a id="nuxt-project-template-for-gitlab-pages"></a>

### 极狐GitLab Pages 的 Nuxt 项目模板

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: JihuLab.com
- Links: [文档](../../user/project/pages/getting_started/pages_new_project_template.md)

{{< /details >}}

极狐GitLab 为最流行的静态站点生成器（SSG）提供模板，您现在可以使用 Nuxt 创建极狐GitLab Pages 站点，Nuxt 是一个基于 Vue.js 构建的强大框架。Nuxt 对于希望构建现代、高性能 Web 应用程序且配置开销更少的团队特别有价值。

此添加扩展了您快速启动 Pages 站点的选项，具有内置的 CI/CD 流水线和现代开发体验，而无需花费时间在初始设置和配置上。

<a id="cyclonedx-export-for-the-project-dependency-list"></a>

### 项目依赖列表的 CycloneDX 导出

{{< details >}}

- Tier: 旗舰版
- Offering: JihuLab.com
- Links: [文档](../../user/application_security/dependency_list/_index.md#export)

{{< /details >}}

许多组织现在要求提供软件物料清单（SBOM）以满足监管要求，并帮助进一步提高软件供应链的安全性。以前，您只能从极狐GitLab 将依赖列表导出为 JSON 或 CSV 文件。现在，极狐GitLab 可以通过以广泛采用的 CycloneDX 格式导出您的依赖列表来生成 SBOM。

要直接以 CycloneDX 文件形式下载 SBOM，请在依赖列表中，选择 **导出** > **导出为 CycloneDX (JSON)**。

<a id="email-delivery-for-dependency-list-and-vulnerability-report-export"></a>

### 依赖列表和漏洞报告导出的电子邮件发送

{{< details >}}

- Tier: 旗舰版
- Offering: JihuLab.com
- Links: [文档](../../user/application_security/dependency_list/_index.md#export)

{{< /details >}}

以前，在导出依赖列表或漏洞报告时，您必须停留在页面上直到导出完成才能下载报告。

现在，当依赖列表或漏洞报告导出完成时，您会通过电子邮件收到通知，其中包含下载链接。

<a id="export-dependency-list-in-csv-format"></a>

### 以 CSV 格式导出依赖列表

{{< details >}}

- Tier: 旗舰版
- Offering: JihuLab.com
- Links: [文档](../../user/application_security/dependency_list/_index.md#export)

{{< /details >}}

以前，您无法从极狐GitLab 将依赖列表导出为 CSV 文件。现在，当您下载依赖列表时，可以选择新的 CSV 选项以该格式导出列表。

<a id="tool-filter-replaced-with-scanner-and-report-type-filters"></a>

### 工具过滤器替换为扫描器和报告类型过滤器

{{< details >}}

- Tier: 旗舰版
- Offering: JihuLab.com
- Links: [文档](../../user/application_security/vulnerability_report/_index.md#report-type-filter)

{{< /details >}}

以前，漏洞报告中的 **工具** 搜索过滤器允许您根据包含扫描器类型（如 ESLint 或 Gemnasium）和报告类型（如 SAST 或容器扫描）的单一工具组来筛选结果。

为了帮助您更轻松地找到合适的工具，我们将 **工具** 过滤器替换为 **扫描器** 过滤器和 **报告类型** 过滤器。您现在可以分别基于这些工具类型来筛选搜索。

<a id="store-and-filter-a-source-value-for-ci-cd-jobs"></a>

### 存储和筛选 CI/CD 作业的 `source` 值

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: JihuLab.com
- Links: [文档](../../api/jobs.md#retrieve-a-job-by-job-id) | [相关史诗](https://jihulab.com/groups/gitlab-cn/-/epics/11796)

{{< /details >}}

极狐GitLab 17.11 引入了一项新功能，允许用户通过跟踪 CI/CD 作业的 source 属性来验证构建产物的来源。此增强功能对于安全与合规工作流特别有价值。例如，组织可以实施软件供应链安全措施，或要求提供可验证的安全扫描证据以满足合规性要求。

极狐GitLab 中的作业现在存储并显示一个 `source` 值，该值标识它们是否源自：

- 扫描执行策略
- 流水线执行策略
- 常规流水线

您可以通过 **构建** > **作业** 页面上的新筛选选项、使用 Jobs API 或通过用于产物验证的 ID 令牌 `claims` 来访问 `source` 属性。

借助这项新功能，您现在可以：

- 验证安全扫描结果的真实性。
- 按源类型筛选作业，以快速识别策略强制执行的扫描。
- 使用新的 ID 令牌声明对产物实施加密验证。
- 确保满足合规性要求并提供适当的审计跟踪。

安全与合规团队可以利用此功能：

- 使用作业页面上的新过滤器仅查看策略强制执行的作业。
- 通过访问 Jobs API 中的 `source` 字段来自动化任务。
- 使用新的 ID 令牌声明实施产物验证：
  - `job_source`：标识作业的来源。
  - `job_policy_ref_uri`：指向策略文件（对于策略定义的作业）。
  - `job_policy_ref_sha`：包含策略的 git 提交 SHA。

<a id="enhanced-sorting-options-for-access-tokens"></a>

### 访问令牌的增强排序选项

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: JihuLab.com
- Links: [文档](../../user/profile/personal_access_tokens.md)

{{< /details >}}

现在，UI 和 API 中为访问令牌提供了额外的排序选项。这些排序选项补充了极狐GitLab 现有的令牌管理功能，使您能够更好地控制访问令牌库存，并帮助您更好地维护访问令牌安全。新的排序选项包括：

- 按到期日期排序（升序）：查看最快到期的令牌。
- 按到期日期排序（降序）：查看剩余生存期最长的令牌。
- 按上次使用日期排序（升序）：查看最近未使用的令牌。
- 按上次使用日期排序（降序）：查看最近使用的令牌。

<a id="token-statistics-for-service-account-management"></a>

### 服务账户管理的令牌统计

{{< details >}}

- Tier: 专业版，旗舰版
- Offering: JihuLab.com
- Links: [文档](../../user/profile/service_accounts.md)

{{< /details >}}

服务账户的令牌管理界面现在包含一个有用的统计仪表板，可提供有关令牌库存的概览信息。这些信息可以帮助您评估令牌的状态并识别需要关注的令牌。

统计仪表板包括四个关键指标：

- 活跃令牌：查看活跃令牌的总数
- 即将过期的令牌：识别在未来两周内到期的令牌
- 已撤销的令牌：跟踪被手动撤销的令牌
- 已过期的令牌：监控之前已过期的令牌

感谢 [Chaitanya Sonwane](https://jihulab.com/chaitanyason9) 的贡献！

<a id="improved-pipeline-graph-visualization-for-failed-jobs"></a>

### 改进的流水线图可视化失败作业

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: JihuLab.com
- Links: [文档](../../ci/pipelines/_index.md#view-pipelines)

{{< /details >}}

您现在可以通过新的视觉指示器在流水线图中快速识别失败的作业。失败的作业组在流水线图中高亮显示，并且失败的作业分组在每个阶段的顶部。这种改进的可视化帮助您排查流水线故障，而无需在复杂的流水线结构中搜索。

<a id="force-cancel-ci-cd-jobs-stuck-in-canceling-state"></a>

### 强制取消卡在取消状态的 CI/CD 作业

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: JihuLab.com
- Links: [文档](../../ci/jobs/_index.md#force-cancel-a-job)

{{< /details >}}

CI/CD 作业偶尔会卡在“取消中”状态，从而阻塞部署或对共享资源的访问。

具有维护者 [角色](../../user/permissions.md) 的用户现在可以直接从作业日志页面强制取消这些卡住的作业，确保有问题的作业可以被正确终止。

<a id="improved-runner-management-in-projects"></a>

### 改进的项目中 runner 管理

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: JihuLab.com
- Links: [文档](../../ci/runners/runners_scope.md#project-runners)

{{< /details >}}

您现在可以更高效地在项目中管理 runner。Runner 以单列布局显示，并在各自的列表中组织，而不是以前的双列视图。

这种改进的组织方式使查找和管理 runner 更加简单，新功能包括显示已分配项目的列表、runner 管理器以及 runner 已运行的作业。有关计划在极狐GitLab 18.0 中进行的其他 runner 管理改进的信息，请参阅相关规划。

<a id="gitlab-runner-17-11"></a>

### 极狐GitLab Runner 17.11

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Links: [文档](https://gitlab.cn/docs/runner)

{{< /details >}}

我们今天还发布了极狐GitLab Runner 17.11！极狐GitLab Runner 是高度可扩展的构建代理，用于运行您的 CI/CD 作业并将结果发送回极狐GitLab 实例。极狐GitLab Runner 与极狐GitLab CI/CD 协同工作，极狐GitLab CI/CD 是极狐GitLab 附带的开源持续集成服务。

所有变更的列表位于极狐GitLab Runner [CHANGELOG](https://jihulab.com/gitlab-cn/gitlab-runner/blob/17-11-stable/CHANGELOG.md)。