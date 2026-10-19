---
stage: Release Notes
group: Monthly Release
date: 2024-06-20
title: "极狐GitLab 17.1 发布说明"
description: "极狐GitLab 17.1 发布，模型注册表以测试版形式提供"
---

<!-- markdownlint-disable -->
<!-- vale off -->

2024 年 6 月 20 日，极狐GitLab 17.1 正式发布，带来了以下新功能。

<a id="primary-features"></a>

## 主要功能

<a id="model-registry-available-in-beta"></a>

### 模型注册表以测试版形式提供

<!-- categories: MLOps -->

{{< details >}}

- 适用版本: 基础版、专业版、旗舰版
- 交付方式: JihuLab.com、私有化部署
- 链接: [文档](../../user/project/ml/model_registry/_index.md) | [相关史诗](https://gitlab.com/groups/gitlab-org/-/epics/9423)

{{< /details >}}

极狐GitLab 现已正式支持模型注册表，将其作为一项一等概念，目前处于测试版。您可以直接通过 UI 添加和编辑模型，也可以使用 MLflow 集成，将极狐GitLab 用作模型注册表后端。

模型注册表是一个中心枢纽，帮助数据科学团队管理机器学习模型及其相关元数据。它为组织提供了一个集中位置，用于存储、版本化、记录和发现已训练的机器学习模型。它确保在整个模型生命周期中实现更好的协作、可复现性和治理。

我们将模型注册表视为一项基石概念，使团队能够协作、部署、监控并持续训练模型，我们非常期待您的反馈。欢迎在我们的[反馈议题](https://gitlab.com/gitlab-org/gitlab/-/issues/465405)中留言，我们会与您联系！

<a id="see-multiple-gitlab-duo-code-suggestions-in-vs-code"></a>

### 在 VS Code 中查看多个极狐GitLab Duo 代码建议

<!-- categories: Editor Extensions, Code Suggestions -->

{{< details >}}

- 适用版本: 专业版、旗舰版
- 交付方式: JihuLab.com、私有化部署
- 链接: [文档](../../user/project/repository/code_suggestions/_index.md#view-multiple-code-suggestions) | [相关议题](https://gitlab.com/gitlab-org/gitlab-vscode-extension/-/issues/1325)

{{< /details >}}

VS Code 中的极狐GitLab Duo 代码建议现在会向您显示是否有多个建议可用。只需将鼠标悬停在建议上，然后使用箭头或键盘快捷键即可循环浏览这些建议。

<a id="secret-push-protection-available-in-beta"></a>

### 密钥推送保护以测试版形式提供

<!-- categories: Secret Detection -->

{{< details >}}

- 交付方式: JihuLab.com
- 链接: [文档](../../user/application_security/secret_detection/secret_push_protection/_index.md) | [相关议题](https://gitlab.com/groups/gitlab-org/-/epics/12729)

{{< /details >}}

如果密钥（例如密钥或 API 令牌）被意外提交到 Git 代码仓库，任何拥有代码仓库访问权限的人都可以冒充该密钥的用户进行恶意操作。为应对这一风险，大多数组织要求撤销并替换已泄露的密钥，但您可以通过从一开始就阻止密钥被推送，来节省修复时间并降低风险。

密钥推送保护会检查推送到极狐GitLab 的每个提交的内容。[如果检测到任何密钥](../../user/application_security/secret_detection/secret_push_protection/_index.md#detected-secrets)，推送会被阻止，并显示有关该提交的信息，包括：

- 包含密钥的提交 ID。
- 包含密钥的文件名和行号。
- 密钥的类型。

需要在测试时绕过密钥推送保护？当您跳过密钥推送检测时，极狐GitLab 会记录一条审计事件，以便您进行调查。

密钥推送保护在 JihuLab.com 上以测试版功能形式提供，可以[按项目](../../user/application_security/secret_detection/secret_push_protection/_index.md#enable-secret-push-protection-in-a-project)启用。您可以在[议题 467408](https://gitlab.com/gitlab-org/gitlab/-/issues/467408)中提供反馈，帮助我们改进密钥推送保护。

<a id="gitlab-runner-autoscaler-is-generally-available"></a>

### 极狐GitLab Runner 自动扩缩器已正式发布

<!-- categories: GitLab Runner Core -->

{{< details >}}

- 适用版本: 基础版、专业版、旗舰版
- 交付方式: 私有化部署
- 链接: [文档](https://gitlab.cn/docs/runner/runner_autoscale/) | [相关议题](https://gitlab.com/gitlab-org/gitlab-runner/-/issues/29221)

{{< /details >}}

在早期版本的极狐GitLab 中，一些客户需要在公有云平台的虚拟机实例上为极狐GitLab Runner 提供自动扩缩解决方案。这些客户不得不依赖旧版的 [Docker Machine 执行器](https://gitlab.cn/docs/runner/configuration/autoscale/)，或使用云提供商技术拼凑而成的自定义解决方案。

今天，我们很高兴地宣布极狐GitLab Runner 自动扩缩器正式发布。极狐GitLab Runner 自动扩缩器由极狐GitLab 开发的 taskscaler 和 [fleeting](https://gitlab.cn/docs/runner/fleet_scaling/fleeting/) 技术以及 Google Compute Engine 的云提供商插件组成。

<a id="gitlab-connector-application-now-available-on-the-snowflake-marketplace"></a>

### 极狐GitLab 连接器应用现已在 Snowflake Marketplace 上提供

<!-- categories: Audit Events, Compliance Management -->

{{< details >}}

- 适用版本: 专业版、旗舰版
- 交付方式: JihuLab.com、私有化部署
- 链接: [文档](../../integration/snowflake.md) | [相关史诗](https://gitlab.com/groups/gitlab-org/-/epics/13004)

{{< /details >}}

审计事件在极狐GitLab 中创建和存储。在此版本之前，审计事件只能从极狐GitLab 中访问，使用极狐GitLab UI 查看结果，或设置流式目标以结构化 JSON 形式接收所有审计事件。

然而，客户还希望能够在第三方目标（例如 Snowflake 等 SIEM 解决方案）中获取审计事件，以便更轻松地：

- 查看、合并、操作和报告来自组织多个系统（包括极狐GitLab）的所有审计事件数据。
- 只查看他们关心的特定审计事件，以便快速回答他们感兴趣的问题。
- 全面了解极狐GitLab 内部发生的情况，并能够在事后进行审查。

为帮助客户完成这些任务，我们为 [Snowflake Marketplace](https://app.snowflake.com/marketplace/listing/GZTYZXESENG/gitlab-gitlab-data-connector) 创建了一个极狐GitLab 连接器应用，它使用审计事件 API。要使用此功能，客户必须使用 Snowflake Marketplace 部署和管理该应用。

<a id="improved-wiki-user-experience"></a>

### 改进的 Wiki 用户体验

<!-- categories: Wiki -->

{{< details >}}

- 适用版本: 基础版、专业版、旗舰版
- 交付方式: JihuLab.com、私有化部署
- 链接: [文档](../../user/project/wiki/_index.md) | [相关议题](https://gitlab.com/gitlab-org/gitlab/-/issues/452225)

{{< /details >}}

极狐GitLab 17.1 中的 Wiki 功能提供了更统一、更高效的工作流：

- [更简单、更快速的克隆](https://gitlab.com/gitlab-org/gitlab/-/issues/281830)，新增了代码仓库克隆按钮。这改善了协作，并加快了访问 Wiki 内容以进行编辑或查看的速度。
- [更明显的删除选项](https://gitlab.com/gitlab-org/gitlab/-/issues/335169)，位于更易发现的位置。这减少了查找它所花费的时间，并最大限度地减少了管理 Wiki 页面时可能出现的错误或困惑。
- [允许空页面有效](https://gitlab.com/gitlab-org/gitlab/-/issues/221061)，提高了灵活性。您可以在需要时创建空占位符。专注于更好地规划和组织 Wiki 内容，之后再填充空页面。

这些增强功能改善了 Wiki 工作流的易用性、可发现性和内容管理。我们希望您的 Wiki 体验高效且用户友好。通过让克隆代码仓库更易访问、重新定位关键选项以提高可见性，以及允许创建空占位符，我们正在改进平台，以更好地满足您用户的需求。

<a id="new-value-stream-management-report-generator-tool"></a>

### 新的价值流管理报告生成器工具

<!-- categories: Value Stream Management, DORA Metrics -->

{{< details >}}

- 适用版本: 旗舰版
- 交付方式: JihuLab.com、私有化部署
- 链接: [文档](../../user/analytics/value_streams_dashboard.md#schedule-reports) | [相关议题](https://gitlab.com/groups/gitlab-org/-/epics/10880)

{{< /details >}}

随着新的价值流管理报告生成工具的加入，我们使决策者能够更高效、更有效地优化软件开发生命周期（SDLC）。

您现在可以安排 [DevSecOps 对比指标报告](https://gitlab.com/components/vsd-reports-generator#example-for-monthly-executive-value-streams-report)或 [AI 影响分析](gitlab-17-0-released.md#ai-impact-analytics-in-the-value-streams-dashboard)报告自动、主动地投递，并在极狐GitLab 议题中提供相关信息。通过计划报告，管理者可以专注于分析洞察并做出明智决策，而不必花时间手动搜索具有所需数据的正确仪表板。

您可以使用 [CI/CD Catalog](https://gitlab.com/explore/catalog) 访问计划报告工具。

<a id="container-images-linked-to-signatures"></a>

### 容器镜像与其签名关联

<!-- categories: Container Registry -->

{{< details >}}

- 适用版本: 基础版
- 交付方式: JihuLab.com
- 链接: [文档](../../user/packages/container_registry/_index.md#container-image-signatures) | [相关史诗](https://gitlab.com/groups/gitlab-org/-/epics/7856)

{{< /details >}}

极狐GitLab 容器镜像仓库现在将已签名的容器镜像与其签名关联起来。通过这一改进，用户可以更轻松地：

- 识别哪些镜像已签名，哪些未签名。
- 查找并验证与容器镜像关联的签名。

此改进仅在 JihuLab.com 上正式发布。私有化部署支持处于测试版，需要用户启用[下一代容器镜像仓库](../../administration/packages/container_registry_metadata_database.md)，该功能也处于测试版。

<a id="require-confirmation-for-manual-jobs"></a>

### 手动作业需要确认

<!-- categories: Continuous Integration (CI) -->

{{< details >}}

- 适用版本: 基础版、专业版、旗舰版
- 交付方式: JihuLab.com、私有化部署
- 链接: [文档](../../ci/jobs/job_control.md#require-confirmation-for-manual-jobs) | [相关议题](https://gitlab.com/gitlab-org/gitlab/-/issues/18906)

{{< /details >}}

手动作业可用于在您的 CI 流水线中触发高度关键的操作，例如部署到生产环境。在此版本中，您现在可以配置手动作业在运行前需要确认。将 `manual_confirmation` 与 `when: manual` 一起使用，可在手动运行作业时在 UI 中显示确认对话框。要求手动作业进行确认提供了额外的安全性和控制层。

特别感谢 [Phawin](https://gitlab.com/lifez)的这一社区贡献！

<a id="runner-fleet-dashboard-for-groups"></a>

### 群组的 Runner 集群仪表板

<!-- categories: Fleet Visibility -->

{{< details >}}

- 适用版本: 旗舰版
- 交付方式: JihuLab.com、私有化部署
- 链接: [文档](../../ci/runners/runner_fleet_dashboard_groups.md) | [相关议题](https://gitlab.com/gitlab-org/gitlab/-/issues/424789)

{{< /details >}}

在群组级别管理私有化部署 Runner 集群的运维人员需要可观测性，以及能够一目了然地快速回答有关其 Runner 集群基础设施的关键问题。通过群组的 Runner 集群仪表板，您可以直接在极狐GitLab UI 中获得 Runner 集群可观测性和可操作的洞察。您现在可以快速确定 Runner 健康状况，并深入了解 Runner 使用指标以及 CI/CD 作业队列服务能力，以符合您组织的目标服务级别目标。

JihuLab.com 上的客户可以使用目前群组可用的所有集群仪表板指标。私有化部署客户可以使用大多数集群仪表板指标，但必须配置 ClickHouse 分析数据库才能使用 **Runner 使用情况**和**选中作业的等待时间**指标。

<a id="scale-and-deployments"></a>

## 扩展与部署

<a id="omnibus-improvements"></a>

### Omnibus 改进

<!-- categories: Omnibus Package -->

{{< details >}}

- 适用版本: 基础版、专业版、旗舰版
- 交付方式: 私有化部署
- 链接: [文档](https://gitlab.cn/docs/omnibus/)

{{< /details >}}

极狐GitLab 17.1 包含支持 [Ubuntu Noble 24.04](../../install/package/_index.md)的软件包。

<a id="new-graphql-api-argument-markedfordeletionon-for-groups-and-projects"></a>

### 群组和项目的新 GraphQL API 参数 `markedForDeletionOn`

<!-- categories: Groups & Projects -->

{{< details >}}

- 适用版本: 专业版、旗舰版
- 交付方式: JihuLab.com、私有化部署
- 链接: [文档](../../api/graphql/reference/_index.md#querygroups) | [相关议题](https://gitlab.com/gitlab-org/gitlab/-/issues/463809)

{{< /details >}}

您现在可以使用新的 GraphQL API 参数 `markedForDeletionOn` 列出在特定日期被标记为删除的群组或项目。

感谢 [@imskr](https://gitlab.com/imskr)的这一社区贡献！

<a id="new-placeholders-for-group-and-project-badges"></a>

### 群组和项目徽章的新占位符

<!-- categories: Groups & Projects -->

{{< details >}}

- 适用版本: 基础版、专业版、旗舰版
- 交付方式: JihuLab.com、私有化部署
- 链接: [文档](../../user/project/badges.md#placeholders) | [相关议题](https://gitlab.com/gitlab-org/gitlab/-/issues/22278)

{{< /details >}}

您现在可以使用四个新占位符创建徽章链接和图片 URL：

- `%{project_namespace}` - 引用项目命名空间的完整路径
- `%{group_name}` - 引用群组名称
- `%{gitlab_server}` - 引用群组或项目的服务器名称
- `%{gitlab_pages_domain}` - 引用群组或项目的域名

感谢 [@TamsilAmani](https://gitlab.com/TamsilAmani)的这一社区贡献！

<a id="new-latest_tag-placeholder-for-badges"></a>

### 徽章的新 `%{latest_tag}` 占位符

<!-- categories: Groups & Projects -->

{{< details >}}

- 适用版本: 基础版、专业版、旗舰版
- 交付方式: JihuLab.com、私有化部署
- 链接: [文档](../../user/project/badges.md#placeholders) | [相关议题](https://gitlab.com/gitlab-org/gitlab/-/issues/26420)

{{< /details >}}

您现在可以使用 `%{latest_tag}` 占位符创建徽章链接和图片 URL。此占位符引用为代码仓库发布的最新标签。

感谢 [@TamsilAmani](https://gitlab.com/TamsilAmani)的这一社区贡献！

<a id="filter-groups-by-marked_for_deletion_on-date-with-the-groups-api"></a>

### 使用群组 API 按 `marked_for_deletion_on` 日期筛选群组

<!-- categories: Groups & Projects -->

{{< details >}}

- 适用版本: 专业版、旗舰版
- 交付方式: JihuLab.com、私有化部署
- 链接: [文档](../../api/groups.md#list-groups) | [相关议题](https://gitlab.com/gitlab-org/gitlab/-/issues/429315)

{{< /details >}}

您现在可以使用属性 `marked_for_deletion_on` 筛选群组 API 中的响应，该属性返回在特定日期被标记为删除的群组。

感谢 [@imskr](https://gitlab.com/imskr)的这一社区贡献！

<a id="list-contributed-projects-of-a-user-with-graphql-api"></a>

### 使用 GraphQL API 列出用户贡献的项目

<!-- categories: Groups & Projects -->

{{< details >}}

- 适用版本: 基础版、专业版、旗舰版
- 交付方式: JihuLab.com、私有化部署
- 链接: [文档](../../api/graphql/reference/_index.md#usercontributedprojects) | [相关议题](https://gitlab.com/gitlab-org/gitlab/-/issues/450191)

{{< /details >}}

您现在可以使用新的 GraphQL API 字段 `User.contributedProjects` 列出用户贡献过的项目。

感谢 [@yasuk](https://gitlab.com/yasuk)的这一社区贡献！

<a id="add-members-by-username-with-the-members-api"></a>

### 使用成员 API 按用户名添加成员

<!-- categories: User Management, Groups & Projects -->

{{< details >}}

- 适用版本: 基础版、专业版、旗舰版
- 交付方式: JihuLab.com、私有化部署
- 链接: [文档](../../api/group_members.md#add-a-group-member) | [相关议题](https://gitlab.com/gitlab-org/gitlab/-/issues/28208)

{{< /details >}}

此前，使用成员 API 时，您只能通过用户 ID 将成员添加到群组和项目。在此版本中，您现在还可以通过用户名添加成员。

感谢 [@imskr](https://gitlab.com/imskr)的这一社区贡献！

<a id="updated-sorting-and-filtering-functionality-in-explore"></a>

### 更新了探索页面的排序和筛选功能

<!-- categories: Groups & Projects -->

{{< details >}}

- 适用版本: 基础版、专业版、旗舰版
- 交付方式: JihuLab.com、私有化部署
- 链接: [文档](../../user/project/working_with_projects.md#explore-all-projects-on-an-instance)

{{< /details >}}

我们更新了群组和项目探索页面的排序和筛选功能。筛选栏现在更宽，以提高可读性。

在项目探索页面中，您现在可以使用标准化排序选项，包括**名称**、**创建日期**、**更新日期**和**星标**，以及用于按升序或降序排序的导航元素。语言筛选器已移至筛选菜单。新增的**非活跃**选项卡显示已归档项目，以便更专注地搜索。此外，您可以使用**角色**筛选器搜索您作为所有者的项目。

在群组探索页面中，我们已将排序选项标准化为包括**名称**、**创建日期**和**更新日期**，并添加了用于按升序或降序排序的导航元素。

欢迎在[议题 438322](https://gitlab.com/gitlab-org/gitlab/-/issues/438322)中提供有关这些更改的反馈。

<a id="improved-visibility-level-selection"></a>

### 改进的可见性级别选择

<!-- categories: Groups & Projects -->

{{< details >}}

- 适用版本: 基础版、专业版、旗舰版
- 交付方式: JihuLab.com、私有化部署
- 链接: [文档](../../user/public_access.md#change-group-visibility) | [相关议题](https://gitlab.com/gitlab-org/gitlab/-/issues/455668)

{{< /details >}}

此前，群组或项目的常规设置仅显示允许的可见性级别。这种视图常常让试图理解为什么其他选项不可用的用户感到困惑，并可能导致信息显示不正确。新视图显示所有可见性级别，将不可选择的选项置灰。此外，弹出框会提供有关某个选项为何不可用的更多背景信息。例如，某个可见性级别可能因管理员限制了它而不可用，或者它会与项目或父群组的可见性设置产生冲突。

我们希望这些更改能帮助您解决选择所需可见性选项时的冲突。感谢 [@gerardo-navarro](https://gitlab.com/gerardo-navarro)的这一社区贡献！

<a id="filter-projects-by-marked_for_deletion_on-date-with-the-projects-api"></a>

### 使用项目 API 按 `marked_for_deletion_on` 日期筛选项目

<!-- categories: Groups & Projects -->

{{< details >}}

- 适用版本: 专业版、旗舰版
- 交付方式: JihuLab.com、私有化部署
- 链接: [文档](../../api/projects.md#list-all-projects) | [相关议题](https://gitlab.com/gitlab-org/gitlab/-/issues/463939)

{{< /details >}}

您现在可以使用属性 `marked_for_deletion_on` 筛选项目 API 中的响应，该属性返回在特定日期被标记为删除的项目。

感谢 [@imskr](https://gitlab.com/imskr)的这一社区贡献！

<a id="audit-event-on-webhook-creation"></a>

### 创建 Webhook 时的审计事件

<!-- categories: Notifications, Audit Events -->

{{< details >}}

- 适用版本: 专业版、旗舰版
- 交付方式: JihuLab.com、私有化部署
- 链接: [文档](../../user/compliance/audit_event_types.md#webhooks) | [相关议题](https://gitlab.com/gitlab-org/gitlab/-/issues/8068)

{{< /details >}}

审计事件记录在极狐GitLab 中执行的重要操作。到目前为止，当用户添加系统、群组或项目 Webhook 时，不会创建审计事件。

在此版本中，我们添加了当用户创建系统、群组或项目 Webhook 时的审计事件。

<a id="use-rest-api-to-cancel-a-running-direct-transfer-migration"></a>

### 使用 REST API 取消正在运行的直接转移迁移

<!-- categories: Importers -->

{{< details >}}

- 适用版本: 基础版、专业版、旗舰版
- 交付方式: JihuLab.com、私有化部署
- 链接: [文档](../../api/bulk_imports.md#cancel-a-migration) | [相关议题](https://gitlab.com/gitlab-org/gitlab/-/issues/438281)

{{< /details >}}

到目前为止，取消正在运行的直接转移迁移[需要访问 Rails 控制台](../../user/group/import/direct_transfer_migrations.md#cancel-a-running-migration)。

在此版本中，我们添加了管理员使用 REST API 取消迁移的功能。

<a id="test-group-hooks-with-the-rest-api"></a>

### 使用 REST API 测试群组钩子

<!-- categories: Notifications -->

{{< details >}}

- 适用版本: 专业版、旗舰版
- 交付方式: JihuLab.com、私有化部署
- 链接: [文档](../../api/group_webhooks.md#trigger-a-test-group-hook) | [相关议题](https://gitlab.com/gitlab-org/gitlab/-/issues/455589)

{{< /details >}}

此前，您只能使用 REST API 测试项目钩子。在此版本中，您还可以为指定的群组触发测试钩子。

此端点有特殊速率限制，即每个群组钩子每分钟三次请求。要在私有化部署的极狐GitLab 上禁用此限制，管理员可以禁用 `web_hook_test_api_endpoint_rate_limit` 功能标志。

感谢 [Phawin](https://gitlab.com/lifez)的[这一社区贡献](https://gitlab.com/gitlab-org/gitlab/-/merge_requests/150486)！

<a id="re-import-a-chosen-project-relation-by-using-the-api"></a>

### 使用 API 重新导入选定的项目关联

<!-- categories: Importers -->

{{< details >}}

- 适用版本: 基础版、专业版、旗舰版
- 交付方式: JihuLab.com、私有化部署
- 链接: [文档](../../api/project_import_export.md#import-project-resources) | [相关议题](https://gitlab.com/gitlab-org/gitlab/-/issues/455889)

{{< /details >}}

当从包含许多同类型条目（例如合并请求或流水线）的导出文件导入项目时，有时其中一些条目不会被导入。

在此版本中，我们添加了一个 API 端点，用于重新导入指定的关联，跳过已导入的条目。该 API 需要同时提供：

- 项目导出归档文件。
- 类型。可以是议题、合并请求、流水线或里程碑。

<a id="keep-inherited-membership-structure-when-importing-by-direct-transfer"></a>

### 通过直接转移导入时保留继承的成员关系结构

<!-- categories: Importers -->

{{< details >}}

- 适用版本: 基础版、专业版、旗舰版
- 交付方式: JihuLab.com、私有化部署
- 链接: [文档](../../user/group/import/direct_transfer_migrations.md#user-membership-mapping) | [相关议题](https://gitlab.com/gitlab-org/gitlab/-/issues/458834)

{{< /details >}}

到目前为止，通过直接转移进行迁移时，[继承的成员关系](../../user/project/members/_index.md#membership-types)无法可靠地导入。这意味着项目的继承成员被导入为直接成员。

从此版本开始，极狐GitLab 现在会先迁移群组成员关系，然后再迁移项目成员关系。这会在源极狐GitLab 实例上复制继承的成员关系。

<a id="use-the-rest-api-to-set-custom-webhook-headers"></a>

### 使用 REST API 设置自定义 Webhook 请求头

<!-- categories: Source Code Management, Notifications -->

{{< details >}}

- 适用版本: 基础版、专业版、旗舰版
- 交付方式: JihuLab.com、私有化部署
- 链接: [文档](../../api/project_webhooks.md#set-a-custom-header) | [相关议题](https://gitlab.com/gitlab-org/gitlab/-/issues/455528)

{{< /details >}}

在极狐GitLab 16.11 中，我们引入了[在创建或编辑 Webhook 时添加自定义请求头](../16/gitlab-16-11-released.md#custom-webhook-headers)的功能。

在此版本中，您现在可以使用极狐GitLab REST API 设置自定义 Webhook 请求头。

感谢 [Niklas](https://gitlab.com/Taucher2003)的[这一社区贡献](https://gitlab.com/gitlab-org/gitlab/-/merge_requests/153768)！

<a id="backups-include-external-merge-request-diffs-stored-on-disk"></a>

### 备份包含存储在磁盘上的外部合并请求差异

<!-- categories: Backup/Restore of GitLab instances -->

{{< details >}}

- 适用版本: 基础版、专业版、旗舰版
- 交付方式: 私有化部署
- 链接: [文档](../../administration/backup_restore/backup_gitlab.md#backup-command)

{{< /details >}}

`gitlab-backup` 工具现在支持备份存储在本地磁盘上的[外部合并请求差异](../../administration/merge_request_diffs.md)。请注意，`gitlab-backup` 工具不会备份存储在对象存储上的文件。因此，如果外部合并差异存储在对象存储上，则需要手动备份。

用于 Cloud Native Hybrid 环境的 `backup-utility` 已支持备份外部合并请求差异，此功能保持不变。

<a id="unified-devops-and-security"></a>

## 统一 DevOps 与安全

<a id="disable-diff-previews-in-code-review-emails"></a>

### 在代码评审邮件中禁用差异预览

<!-- categories: Code Review Workflow -->

{{< details >}}

- 适用版本: 基础版、专业版、旗舰版
- 交付方式: 私有化部署
- 链接: [文档](../../user/group/manage.md#disable-diff-previews-in-email-notifications)

{{< /details >}}

当您在合并请求中评审代码并对某行代码发表评论时，极狐GitLab 会在发送给参与者的邮件通知中包含几行差异。一些组织的策略将电子邮件视为安全性较低的系统，或者可能无法控制自己的电子邮件基础设施。这可能会给源代码的知识产权或访问控制带来风险。

群组和项目中提供了新设置，使组织能够从合并请求邮件中移除差异预览。这有助于确保敏感信息不会在极狐GitLab 之外可用。

非常感谢 [Joe Snyder](https://gitlab.com/joe-snyder) 贡献了此功能！

<a id="administrators-can-search-users-by-partial-email-address"></a>

### 管理员可以按部分电子邮件地址搜索用户

<!-- categories: User Management -->

{{< details >}}

- 适用版本: 基础版、专业版、旗舰版
- 交付方式: 私有化部署
- 链接: [文档](../../administration/admin_area.md#administering-users) | [相关议题](https://gitlab.com/gitlab-org/gitlab/-/issues/20381)

{{< /details >}}

管理员现在可以在管理区域的用户概览中按部分电子邮件地址搜索用户。例如，您可以按特定电子邮件域筛选用户，以查找来自某个特定机构的所有用户。此功能仅限管理员使用，以防止非特权用户访问其他账号的电子邮件地址。

感谢 [@zzaakiirr](https://gitlab.com/zzaakiirr)的这一社区贡献！

<a id="show-release-rss-icon-on-releases-page"></a>

### 在发布页面显示发布 RSS 图标

<!-- categories: Release Orchestration -->

{{< details >}}

- 适用版本: 基础版、专业版、旗舰版
- 交付方式: JihuLab.com、私有化部署
- 链接: [文档](../../user/project/releases/_index.md#track-releases-with-an-rss-feed) | [相关议题](https://gitlab.com/gitlab-org/gitlab/-/issues/30988)

{{< /details >}}

您需要在发布新版本时收到通知吗？极狐GitLab 现在为发布提供 RSS 源。您可以使用项目发布页面上的 RSS 图标订阅发布源。

感谢 [Martin Schurz](https://gitlab.com/schurzi)的贡献！

<a id="new-permissions-for-custom-roles"></a>

### 自定义角色的新权限

<!-- categories: Permissions -->

{{< details >}}

- 适用版本: 旗舰版
- 交付方式: JihuLab.com、私有化部署
- 链接: [文档](../../user/custom_roles/_index.md) | [相关议题](https://gitlab.com/gitlab-org/gitlab/-/issues/391760)

{{< /details >}}

在极狐GitLab 17.1 中，您可以使用以下新权限创建自定义角色：

- [管理合并请求设置](../../user/custom_roles/abilities.md#code-review-workflow)
- [管理集成](../../user/custom_roles/abilities.md#integrations)
- [管理部署令牌](../../user/custom_roles/abilities.md#continuous-delivery)
- [读取 CRM 联系人](../../user/custom_roles/abilities.md#team-planning)

通过自定义角色，您可以通过创建具有同等权限的用户来减少拥有所有者角色的用户数量。这有助于您定义专门针对群组需求定制的角色，并防止不必要的权限提升。

<a id="merge-request-approval-policies-fail-openclosed-policy-editor"></a>

### 合并请求审批策略失败开放/失败关闭（策略编辑器）

<!-- categories: Security Policy Management -->

{{< details >}}

- 适用版本: 旗舰版
- 交付方式: JihuLab.com、私有化部署
- 链接: [文档](../../user/application_security/policies/merge_request_approval_policies.md#fallback_behavior) | [相关史诗](https://gitlab.com/groups/gitlab-org/-/epics/13227)

{{< /details >}}

在之前的[迭代](https://gitlab.com/groups/gitlab-org/-/epics/10816)基础上，我们在策略编辑器中引入了一个新选项，允许用户将安全策略切换为失败开放或失败关闭。此增强功能扩展了 YAML 支持，以便在策略编辑器视图中进行更简单的配置。

例如，配置为失败开放的合并请求策略允许在没有足够证据评估条件时合并合并请求。缺乏证据可能是因为项目未启用分析器，或者分析器未能生成结果供策略评估。这种方法允许在团队努力确保正确执行扫描和强制实施的同时，逐步推出策略。

<a id="project-owners-receive-expiring-access-token-notifications"></a>

### 项目所有者收到访问令牌即将过期的通知

<!-- categories: System Access -->

{{< details >}}

- 适用版本: 基础版、专业版、旗舰版
- 交付方式: JihuLab.com、私有化部署
- 链接: [文档](../../security/tokens/_index.md#project-access-tokens) | [相关议题](https://gitlab.com/gitlab-org/gitlab/-/issues/460818)

{{< /details >}}

具有直接成员关系的项目所有者和维护者现在都会在其项目访问令牌即将过期时收到电子邮件通知。此前，只有项目维护者会收到此通知。这有助于让更多人了解即将到来的令牌过期。

感谢 [Jacob Henner](https://gitlab.com/arcesium-henner)的贡献！

<a id="downscale-pasted-images-on-image-upload"></a>

### 在上传图片时缩小粘贴的图片

<!-- categories: Team Planning, Portfolio Management -->

{{< details >}}

- 适用版本: 基础版、专业版、旗舰版
- 交付方式: JihuLab.com、私有化部署
- 链接: [文档](../../user/markdown.md#change-image-or-video-dimensions) | [相关议题](https://gitlab.com/gitlab-org/gitlab/-/issues/419913)

{{< /details >}}

极狐GitLab 17.1 增强了对高分辨率图片的处理，使其能够在上传时缩小。此前，图片以其原始尺寸显示，导致显示质量不佳。此改进确保大图片不会破坏其所在页面的视觉流。

<a id="draggable-media-in-the-rich-text-editor"></a>

### 富文本编辑器中的可拖动媒体

<!-- categories: Team Planning -->

{{< details >}}

- 适用版本: 基础版、专业版、旗舰版
- 交付方式: JihuLab.com、私有化部署
- 链接: [文档](../../user/rich_text_editor.md) | [相关议题](https://gitlab.com/gitlab-org/gitlab/-/issues/452233)

{{< /details >}}

此前，在富文本编辑器中移动媒体需要您手动复制并粘贴每个条目。这常常会减慢在议题、史诗和 Wiki 中纳入媒体的速度。在极狐GitLab 17.1 中，您现在可以在富文本编辑器中拖放媒体，显著提高编辑效率。

<a id="pages-support-for-mutual-tls-in-gitlab-api-calls"></a>

### Pages 在极狐GitLab API 调用中支持双向 TLS

<!-- categories: Pages -->

{{< details >}}

- 适用版本: 基础版、专业版、旗舰版
- 交付方式: 私有化部署
- 链接: [文档](../../administration/pages/_index.md#support-mutual-tls-when-calling-the-gitlab-api) | [相关议题](https://gitlab.com/gitlab-org/gitlab-pages/-/issues/548)

{{< /details >}}

极狐GitLab 可以配置为[使用 SSL 证书强制执行客户端认证](https://gitlab.cn/docs/omnibus/settings/ssl/#enable-2-way-ssl-client-authentication)。然而，GitLab Pages 服务与该功能不兼容，因为它无法配置为使用客户端证书，并且对内部 API 的调用会被拒绝。

从极狐GitLab 17.1 开始，您可以为 GitLab Pages 配置客户端证书。这允许您启用与极狐GitLab API 的客户端认证，增强极狐GitLab 实例的安全性。

<a id="redirect-wiki-pages-to-new-url-when-renamed"></a>

### Wiki 页面重命名时重定向到新 URL

<!-- categories: Wiki -->

{{< details >}}

- 适用版本: 基础版、专业版、旗舰版
- 交付方式: JihuLab.com、私有化部署
- 链接: [文档](../../user/project/wiki/_index.md) | [相关议题](https://gitlab.com/gitlab-org/gitlab/-/issues/257892)

{{< /details >}}

极狐GitLab 17.1 引入了对 Wiki 页面重定向的重大增强。当您重命名 Wiki 页面时，任何尝试访问旧页面的人都会自动重定向到新页面，确保所有现有链接保持有效。此改进简化了管理页面名称更改的工作流，并增强了整体知识管理体验。

<a id="updated-pages-ui"></a>

### 更新了 Pages UI

<!-- categories: Pages -->

{{< details >}}

- 适用版本: 基础版、专业版、旗舰版
- 交付方式: JihuLab.com、私有化部署
- 链接: [文档](../../user/project/pages/_index.md) | [相关议题](https://gitlab.com/gitlab-org/gitlab/-/merge_requests/153250)

{{< /details >}}

在极狐GitLab 17.1 中，我们改进了 Pages 用户界面。改进包括更高效地利用屏幕空间。这些 UI 改进侧重于改善管理 Pages 时的用户体验和效率。

<a id="display-the-last-published-date-for-container-images"></a>

### 显示容器镜像的最后发布日期

<!-- categories: Container Registry -->

{{< details >}}

- 适用版本: 基础版
- 链接: [文档](../../user/packages/container_registry/_index.md#view-the-container-registry) | [相关议题](https://gitlab.com/gitlab-org/gitlab/-/issues/290949)

{{< /details >}}

此前，容器镜像仓库用户界面中的发布时间戳常常不正确。这意味着您无法依赖这一重要数据来查找和验证您的容器镜像。

在极狐GitLab 17.1 中，我们更新了 UI，以包含准确的 `last_published_at` 时间戳。您可以通过导航到**部署 > 容器镜像仓库**并选择一个标签以查看更多详细信息来找到此信息。最后发布日期位于页面顶部。

此改进仅在 JihuLab.com 上正式发布。私有化部署支持处于测试版，仅在已启用测试版[下一代容器镜像仓库](../../administration/packages/container_registry_metadata_database.md)的实例上可用。

<a id="sort-container-registry-tags-by-publish-date"></a>

### 按发布日期对容器镜像仓库标签排序

<!-- categories: Container Registry -->

{{< details >}}

- 适用版本: 基础版
- 交付方式: JihuLab.com
- 链接: [文档](../../user/packages/container_registry/_index.md#view-the-container-registry) | [相关议题](https://gitlab.com/groups/gitlab-org/-/epics/7856)

{{< /details >}}

您可以使用极狐GitLab 容器镜像仓库，与源代码以及流水线一起查看、推送和拉取 Docker 或 OCI 镜像。在构建容器镜像后，您通常需要查找并验证它是否已正确构建。对于许多客户来说，使用用户界面查找正确的容器镜像可能具有挑战性。

您现在可以按发布日期对容器镜像仓库标签列表进行排序。您可以使用此功能快速查找并验证最近发布的容器镜像。

此改进仅在 JihuLab.com 上正式发布。私有化部署支持处于测试版，因为它需要下一代容器镜像仓库，而后者也处于测试版。要了解更多信息，请参阅[容器镜像仓库元数据数据库文档](../../administration/packages/container_registry_metadata_database.md)。

<a id="real-time-board-updates-for-a-smoother-workflow"></a>

### 实时看板更新，实现更顺畅的工作流

<!-- categories: Portfolio Management -->

{{< details >}}

- 适用版本: 基础版、专业版、旗舰版
- 交付方式: JihuLab.com、私有化部署
- 链接: [文档](../../user/project/issue_board.md) | [相关议题](https://gitlab.com/gitlab-org/gitlab/-/issues/468187)

{{< /details >}}

您现在会注意到在[看板](../../user/project/issue_board.md)上更新议题时体验更顺畅！您在边栏中所做的更改会立即显示在看板上，无需再刷新。这种响应式看板体验简化了您的工作流，让您可以快速进行更新并实时看到反映。

<a id="track-time-on-tasks"></a>

### 在任务上跟踪时间

<!-- categories: Team Planning -->

{{< details >}}

- 适用版本: 基础版、专业版、旗舰版
- 交付方式: JihuLab.com、私有化部署
- 链接: [文档](../../user/project/time_tracking.md) | [相关议题](https://gitlab.com/gitlab-org/gitlab/-/issues/438577)

{{< /details >}}

在此版本中，您现在可以使用[快速操作](../../user/project/quick_actions.md)或任务边栏中的时间跟踪小组件，为任务设置时间估算并记录花费的时间。任务上花费的时间可以通过任务的时间跟踪报告查看。

<a id="understand-an-epics-progress-percentage"></a>

### 了解史诗的进度百分比

<!-- categories: Portfolio Management -->

{{< details >}}

- 适用版本: 专业版、旗舰版
- 交付方式: JihuLab.com、私有化部署
- 链接: [文档](../../user/group/epics/manage_epics.md#manage-issues-assigned-to-an-epic) | [相关议题](https://gitlab.com/gitlab-org/gitlab/-/issues/5163)

{{< /details >}}

您现在可以根据史诗子项的权重完成情况，轻松查看史诗的整体进度。层级小组件中的这一新进度汇总使您更容易了解史诗的完整工作范围，并随时跟踪进度。

<a id="api-security-testing-analyzer-updates"></a>

### API 安全测试分析器更新

<!-- categories: API Security -->

{{< details >}}

- 适用版本: 旗舰版
- 交付方式: JihuLab.com、私有化部署
- 链接: [文档](../../user/application_security/api_security_testing/configuration/variables.md) | [相关议题](https://gitlab.com/groups/gitlab-org/-/epics/14170)

{{< /details >}}

极狐GitLab 17.1 为 API 安全测试添加了以下配置变量：

1. `APISEC_SUCCESS_STATUS_CODES` 创建一个以逗号分隔的 HTTP 成功状态码列表，用于定义 API 安全测试扫描作业是否已通过。
1. `APISEC_TARGET_CHECK_DISABLED` 禁用在扫描开始前等待目标 API 变为可用。
1. `APISEC_TARGET_CHECK_STATUS_CODE` 指定 API 目标可用性检查的预期状态码。如果未提供，则任何非 500 状态码对扫描器来说都是可接受的。

这些新变量提供了更大的自定义和灵活性，以确保扫描成功运行。

DAST API 在 16.10 中已重命名为 API 安全测试。变量名称现在以 `APISEC` 前缀开头。此前，它们以 `DAST_API` 开头。以 `DAST_API` 为前缀的变量将支持到 18.0（2025 年 5 月）。为确保您的配置按预期工作，您应尽快更新变量名称。

<a id="container-scanning-for-registry"></a>

### 容器镜像仓库的容器扫描

<!-- categories: Software Composition Analysis -->

{{< details >}}

- 适用版本: 旗舰版
- 交付方式: JihuLab.com、私有化部署
- 链接: [文档](../../user/application_security/container_scanning/_index.md) | [相关史诗](https://gitlab.com/groups/gitlab-org/-/epics/2340)

{{< /details >}}

极狐GitLab 成分分析现在支持容器镜像仓库的容器扫描。

如果项目已启用容器镜像仓库的容器扫描，并且容器镜像被推送到您项目中的容器镜像仓库，极狐GitLab 会检查其标签和扫描限制。

如果标签为 `latest`，且扫描次数低于限制（每天 50 次扫描），则极狐GitLab 会创建一个新的流水线，在该镜像上运行 `container_scanning` 作业。该流水线与将镜像推送到镜像仓库的用户关联。

扫描作业会生成一个 CycloneDX SBOM，并上传到极狐GitLab。持续漏洞扫描功能会被激活，并扫描 SBOM 中检测到的软件包。

注意：只有在发布新的公告时才会执行漏洞扫描。这发生在[软件包元数据同步](../../administration/settings/security_and_compliance.md)时。

一如既往，我们感谢对我们新发布功能的反馈。要提供反馈，请在此[反馈议题](https://gitlab.com/gitlab-org/gitlab/-/issues/466117)中发表评论。

<a id="fuzz-testing-analyzer-updates"></a>

### 模糊测试分析器更新

<!-- categories: Fuzz Testing -->

{{< details >}}

- 适用版本: 旗舰版
- 交付方式: JihuLab.com、私有化部署
- 链接: [文档](../../user/application_security/api_fuzzing/configuration/variables.md) | [相关议题](https://gitlab.com/gitlab-org/gitlab/-/issues/442699)

{{< /details >}}

极狐GitLab 17.1 为模糊测试添加了以下配置变量：

1. `FUZZAPI_SUCCESS_STATUS_CODES` 创建一个以逗号分隔的 HTTP 成功状态码列表，用于定义模糊测试作业是否已通过。
1. `FUZZAPI_TARGET_CHECK_SKIP` 禁用在扫描开始前等待目标 API 变为可用。
1. `FUZZAPI_TARGET_CHECK_STATUS_CODE` 指定 API 目标可用性检查的预期状态码。如果未提供，则任何非 500 状态码对扫描器来说都是可接受的。

这些新变量为确保扫描运行提供了更大的自定义和灵活性。

<a id="enhanced-control-over-who-can-override-user-defined-variables"></a>

### 增强对谁可以覆盖用户定义变量的控制

<!-- categories: Secrets Management -->

{{< details >}}

- 适用版本: 基础版、专业版、旗舰版
- 交付方式: JihuLab.com、私有化部署
- 链接: [文档](../../ci/variables/_index.md#restrict-pipeline-variables) | [相关议题](https://gitlab.com/gitlab-org/gitlab/-/issues/440338)

{{< /details >}}

为了更好地控制谁可以覆盖用户定义变量，我们引入了 `ci_pipeline_variables_minimum_role` 项目设置。此新设置比现有的 [`restrict_user_defined_variables`](../../ci/variables/_index.md#restrict-pipeline-variables) 设置提供了更大的灵活性。您现在可以将覆盖权限限制为没有用户，或仅限至少具有开发者、维护者或所有者角色的用户。

<a id="gitlab-runner-171-released"></a>

### 极狐GitLab Runner 17.1 发布

<!-- categories: GitLab Runner Core -->

{{< details >}}

- 适用版本: 基础版、专业版、旗舰版
- 交付方式: 私有化部署
- 链接: [文档](https://gitlab.cn/docs/runner/) | [相关议题](https://gitlab.com/gitlab-org/gitlab-runner/-/issues/36942)

{{< /details >}}

今天我们发布极狐GitLab Runner 17.1！极狐GitLab Runner 是轻量级、高度可扩展的代理，用于运行您的 CI/CD 作业并将结果发送回极狐GitLab 实例。极狐GitLab Runner 与极狐GitLab CI/CD 协同工作，后者是极狐GitLab 中包含的开源持续集成服务。

<a id="whats-new"></a>

#### 新增内容

- [GitLab Runner 用于 GCP Compute Engine 的 fleeting 插件](https://gitlab.com/gitlab-org/gitlab-runner/-/issues/29221)

<a id="bug-fixes"></a>

#### 缺陷修复

- [Runner 辅助镜像缺少入口点](https://gitlab.com/gitlab-org/gitlab-runner/-/issues/37689)

所有更改的列表在极狐GitLab Runner [变更日志](https://gitlab.com/gitlab-org/gitlab-runner/blob/17-1-stable/CHANGELOG.md)中。
