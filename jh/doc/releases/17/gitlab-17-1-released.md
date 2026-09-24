---

stage: Release Notes
group: Monthly Release
date: 2024-06-20
title: "极狐GitLab 17.1 发布说明"
description: "极狐GitLab 17.1 发布，模型仓库功能以 Beta 版本上线"
---

<!-- markdownlint-disable -->
<!-- vale off -->

2024 年 6 月 20 日，极狐GitLab 17.1 正式发布，带来了以下新功能。

此外，我们要感谢我们的所有贡献者，包括本月的杰出贡献者。

## 本月的杰出贡献者

每个人都可以[提名极狐GitLab 的社区贡献者](https://gitlab.com/gitlab-org/developer-relations/contributor-success/team-task/-/issues/490)！
为你支持的活跃候选人投票，或添加新的提名！🙌

Shubham Kumar [在 17.1 版本中完成了 7 个议题](https://gitlab.com/dashboard/issues?sort=due_date_desc&state=closed&assignee_username%5B%5D=imskr&milestone_title=17.1)
并且自 2021 年以来持续为极狐GitLab 做贡献。
他现在的合并贡献数已超过 50 个！
Shubham 是一位[极狐GitLab 英雄](https://contributors.gitlab.com/docs/previous-heroes)，也是前 Google Summer of Code 的贡献者。

Shubham 由极狐GitLab 高级产品经理 [Christina Lohr](https://gitlab.com/lohrc) 提名。
“Shubham 在过去的几周和几个月里帮助解决了很多议题，特别是在弥合我们 API 产品中的差距方面，” Christina 说。
“我写发布博文的速度都赶不上 Shubham 推动的所有新增功能了！”

“开源社区令人惊叹，” Shubham 说。
“我感激这个机遇和被认可，并且期待继续为极狐GitLab 平台贡献我的力量。”

Joe Snyder 由极狐GitLab 首席产品经理 [Kai Armstrong](https://gitlab.com/phikai) 提名，
因为他构建了一项呼声很高的功能：[限制在邮件中包含 diff](https://gitlab.com/gitlab-org/gitlab/-/issues/24733)。
这项贡献跨越了 10 个以上的合并请求，最早可以追溯到极狐GitLab 15.3。
“这是一个宏大的功能，历经多个里程碑、复杂的迁移以及对产品的修改才得以支持，” Kai 说。
“Joe 在这些里程碑中与许多维护者和协作者不知疲倦地工作，最终完成了这项工作。”

[Jocelyn Eillis](https://gitlab.com/jocelynjane)，极狐GitLab 产品经理，通过强调修复一个 Bug 的额外工作，支持了对 Joe 的提名。该 Bug 曾导致 [`build:resource_group` 中的嵌套变量未被展开](https://gitlab.com/gitlab-org/gitlab/-/issues/361438)。
“这个 Bug 除了在议题本身中记录了客户需求外，还有 23 个点赞，” Jocelyn 说。
“对审查者反馈的快速响应意味着我们能够将其纳入极狐GitLab 17.1！”

这是 Joe 继之前在 [极狐GitLab 16.6](https://about.gitlab.com/releases/2023/11/16/gitlab-16-6-released/#mvp) 中获得奖项后，第二次荣获极狐GitLab MVP。
Joe 是 [Kitware](https://www.kitware.com/) 的高级研发工程师，自 2021 年以来一直为极狐GitLab做贡献。

## 主要功能

### 模型仓库 Beta 版本上线

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: JihuLab.com
- Links: [文档](../../user/project/ml/model_registry/_index.md) | [相关史诗](https://gitlab.com/groups/gitlab-org/-/epics/9423)

{{< /details >}}

极狐GitLab 现在正式以 Beta 版本支持模型仓库作为一等公民概念。你可以直接通过 UI 添加和编辑模型，或使用 MLflow 集成将极狐GitLab 作为模型仓库后端。

模型仓库是一个帮助数据科学团队管理机器学习模型及其相关元数据的中心。它作为组织存储、版本化、文档化和发现已训练机器学习模型的集中位置，确保在整个模型生命周期中实现更好的协作、可复现性和治理。

我们将模型仓库视为一个基石概念，它使团队能够协作、部署、监控和持续训练模型，并且我们对你的反馈非常感兴趣。请随时在我们的[反馈议题](https://gitlab.com/gitlab-org/gitlab/-/issues/465405)中留下意见，我们会与你联系！

### 在 VS Code 中查看多个 CodeRider 代码建议

{{< details >}}

- Tier: 专业版，旗舰版
- Offering: JihuLab.com
- Links: [文档](../../user/project/repository/code_suggestions/_index.md#view-multiple-code-suggestions) | [相关议题](https://gitlab.com/gitlab-org/gitlab-vscode-extension/-/issues/1325)

{{< /details >}}

VS Code 中的 CodeRider 代码建议现在会向你显示是否存在多个可用建议。只需将鼠标悬停在建议上，然后使用箭头键或键盘快捷键在各个建议之间循环切换。

### 密钥推送保护 Beta 版本上线

{{< details >}}

- Tier: Gold
- Offering: JihuLab.com
- Links: [文档](../../user/application_security/secret_detection/secret_push_protection/_index.md) | [相关议题](https://gitlab.com/groups/gitlab-org/-/epics/12729)

{{< /details >}}

如果密钥（如密钥或 API 令牌）被意外提交到 Git 仓库，任何拥有仓库访问权限的人都可以模拟该密钥的用户进行恶意活动。为了解决此风险，大多数组织都要求撤销并替换已暴露的密钥，但通过从一开始就阻止密钥被推送，可以节省补救时间并降低风险。

密钥推送保护会检查推送到极狐GitLab 的每个提交的内容。[如果检测到任何密钥](../../user/application_security/secret_detection/secret_push_protection/_index.md#detected-secrets)，推送将被阻止，并显示有关该提交的信息，包括：

- 包含密钥的提交 ID。
- 包含密钥的文件名和行号。
- 密钥的类型。

需要绕过密钥推送保护进行测试吗？当你跳过密钥推送检测时，极狐GitLab 会记录一个审计事件，以便你进行调查。

密钥推送保护在 JihuLab.com 上作为 Beta 功能提供，并且可以[基于每个项目](../../user/application_security/secret_detection/secret_push_protection/_index.md#enable-secret-push-protection-in-a-project)启用。你可以通过在[议题 467408](https://gitlab.com/gitlab-org/gitlab/-/issues/467408) 中提供反馈来帮助我们改进密钥推送保护。

### 极狐GitLab Runner 自动扩缩器正式可用

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Links: [文档](https://gitlab.cn/docs/runner/runner_autoscale/) | [相关议题](https://gitlab.com/gitlab-org/gitlab-runner/-/issues/29221)

{{< /details >}}

在极狐GitLab 的早期版本中，一些客户需要在公有云平台上的虚拟机实例上为极狐GitLab Runner 提供自动扩缩解决方案。这些客户不得不依赖传统的 [Docker Machine 执行器](https://docs.gitlab.com/runner/configuration/autoscale.html)或使用云服务商的技术拼凑自定义方案。

今天，我们很高兴地宣布极狐GitLab Runner 自动扩缩器正式可用。极狐GitLab Runner 自动扩缩器由极狐GitLab 开发的 taskscaler 和 [fleeting](https://gitlab.cn/docs/runner/fleet_scaling/fleeting.html) 技术以及用于 Google Compute Engine 的云服务商插件组成。

### 极狐GitLab 连接器应用现已在 Snowflake Marketplace 上线

{{< details >}}

- Tier: 专业版，旗舰版
- Offering: JihuLab.com
- Links: [文档](../../integration/snowflake.md) | [相关史诗](https://gitlab.com/groups/gitlab-org/-/epics/13004)

{{< /details >}}

审计事件在极狐GitLab 中创建并存储。在此版本之前，审计事件只能从极狐GitLab 内部访问，结果通过极狐GitLab UI 审查，或设置流式传输目标以结构化 JSON 格式接收所有审计事件。

然而，客户还希望能够将审计事件放到第三方目标（例如像 Snowflake 这样的 SIEM 解决方案）中，以便更容易地：

- 查看、组合、处理和报告来自组织多个系统（包括极狐GitLab）的所有审计事件数据。
- 仅查看他们关心的特定审计事件，以便快速回答他们感兴趣的问题。
- 全面了解极狐GitLab 内部发生的情况，并能够事后进行审查。

为了帮助客户完成这些任务，我们为 [Snowflake Marketplace](https://app.snowflake.com/marketplace/listing/GZTYZXESENG/gitlab-gitlab-data-connector) 创建了一个使用审计事件 API 的极狐GitLab 连接器应用。
要使用此功能，客户必须通过 Snowflake Marketplace 部署并管理该应用。

### 改进的 Wiki 用户体验

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: JihuLab.com
- Links: [文档](../../user/project/wiki/_index.md) | [相关议题](https://gitlab.com/gitlab-org/gitlab/-/issues/452225)

{{< /details >}}

极狐GitLab 17.1 中的 Wiki 功能提供了更统一、更高效的工作流：

- [更轻松、更快捷的克隆](https://gitlab.com/gitlab-org/gitlab/-/issues/281830)，带有新的仓库克隆按钮。这改进了协作，并加速了对 Wiki 内容的访问以进行编辑或查看。
- [一个更明显的删除选项](https://gitlab.com/gitlab-org/gitlab/-/issues/335169)，位于更易发现的位置。这减少了寻找它所花费的时间，并最大限度地减少了管理 Wiki 页面时可能出现的错误或混乱。
- [允许空页面有效](https://gitlab.com/gitlab-org/gitlab/-/issues/221061)，提高了灵活性。在你需要的时候创建空的占位符，专注于更好地规划和组织 Wiki 内容，并在以后填充空页面。

这些增强功能提高了 Wiki 工作流的易用性、可发现性和内容管理效率。我们希望你的 Wiki 体验高效且用户友好。通过使克隆仓库更易于访问、重新定位关键选项以提高可见性以及允许创建空的占位符，我们正在完善平台，以更好地满足你用户的需求。

### 新的价值流管理报告生成工具

{{< details >}}

- Tier: 旗舰版
- Offering: JihuLab.com
- Links: [文档](../../user/analytics/value_streams_dashboard.md#schedule-reports) | [相关史诗](https://gitlab.com/groups/gitlab-org/-/epics/10880)

{{< /details >}}

通过增加新的价值流管理报告生成工具，我们赋能决策者在软件开发生命周期优化中更加高效和有效。

你现在可以安排 [DevSecOps 对比度量报告](https://gitlab.com/components/vsd-reports-generator#example-for-monthly-executive-value-streams-report)或 [AI 影响分析](https://about.gitlab.com/releases/2024/05/16/gitlab-17-0-released/#ai-impact-analytics-in-the-value-streams-dashboard)报告，使其在极狐GitLab 议题中主动地、自动地交付，并提供相关信息。有了计划的报告，管理者可以专注于分析洞察和做出明智决策，而不是花费时间手动搜索包含所需数据的正确仪表盘。

你可以使用 [CI/CD 目录](https://gitlab.com/explore/catalog)访问计划的报告工具。

### 链接到签名的容器镜像

{{< details >}}

- Tier: 基础版，Silver，Gold
- Offering: JihuLab.com
- Links: [文档](../../user/packages/container_registry/_index.md#container-image-signatures) | [相关史诗](https://gitlab.com/groups/gitlab-org/-/epics/7856)

{{< /details >}}

极狐GitLab 容器镜像仓库现在会将已签名的容器镜像与其签名关联起来。通过此改进，用户可以更轻松地：

- 识别哪些镜像已签名，哪些未签名。
- 查找并验证与容器镜像关联的签名。

此改进仅在 JihuLab.com 上正式可用。私有化部署的支持处于 Beta 阶段，并要求用户启用
[下一代容器镜像仓库](../../administration/packages/container_registry_metadata_database.md)，该功能也处于 Beta 阶段。

### 要求对手动作业进行确认

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: JihuLab.com
- Links: [文档](../../ci/jobs/job_control.md#require-confirmation-for-manual-jobs) | [相关议题](https://gitlab.com/gitlab-org/gitlab/-/issues/18906)

{{< /details >}}

手动作业可用于触发 CI 流水线中高度关键的操作，例如部署到生产环境。在此版本中，你现在可以配置一个手动作业，要求它在运行前进行确认。将 `manual_confirmation` 与 `when: manual` 一起使用，可在手动运行作业时在 UI 中显示一个确认对话框。要求对手动作业进行确认为控制提供了额外的安全保障。

特别感谢 [Phawin](https://gitlab.com/lifez) 的社区贡献！

### 群组的 Runner 集群仪表盘

{{< details >}}

- Tier: 旗舰版
- Offering: JihuLab.com
- Links: [文档](../../ci/runners/runner_fleet_dashboard_groups.md) | [相关议题](https://gitlab.com/gitlab-org/gitlab/-/issues/424789)

{{< /details >}}

在群组级别操作私有化部署 Runner 集群的运营者需要可观测性，以及能够快速回答有关其 Runner 集群基础设施的关键问题的能力。借助群组的 Runner 集群仪表盘，你可以直接在极狐GitLab UI 中获得 Runner 集群的可观测性和可操作的洞察。你现在可以快速确定 Runner 的健康状况，并深入了解 Runner 使用指标以及 CI/CD 作业队列服务能力，以实现你组织的目标服务水平目标。

JihuLab.com 上的客户现在可以使用适用于群组的所有集群仪表盘指标。私有化部署客户可以使用大多数集群仪表盘指标，但必须配置 ClickHouse 分析数据库才能使用 **Runner 使用量** 和 **等待分配作业的时间** 指标。

## 规模化与部署

### Omnibus 改进

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Links: [文档](https://gitlab.cn/docs/omnibus/)

{{< /details >}}

极狐GitLab 17.1 包含了对 [Ubuntu Noble 24.04](../../install/package/_index.md) 进行支持的软件包。

### 用于群组和项目的新的 GraphQL API 参数 `markedForDeletionOn`

{{< details >}}

- Tier: 专业版，旗舰版
- Offering: JihuLab.com
- Links: [文档](../../api/graphql/reference/_index.md#querygroups) | [相关议题](https://gitlab.com/gitlab-org/gitlab/-/issues/463809)

{{< /details >}}

你现在可以使用新的 GraphQL API 参数 `markedForDeletionOn` 来列出于特定日期被标记为删除的群组或项目。

感谢 [@imskr](https://gitlab.com/imskr) 的社区贡献！

### 用于群组和项目徽章的新占位符

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: JihuLab.com
- Links: [文档](../../user/project/badges.md#placeholders) | [相关议题](https://gitlab.com/gitlab-org/gitlab/-/issues/22278)

{{< /details >}}

你现在可以使用四个新的占位符创建徽章链接和图片 URL：

- `%{project_namespace}` - 引用项目命名空间的完整路径
- `%{group_name}` - 引用群组名称
- `%{gitlab_server}` - 引用群组或项目的服务器名称
- `%{gitlab_pages_domain}` - 引用群组或项目的域名

感谢 [@TamsilAmani](https://gitlab.com/TamsilAmani) 的社区贡献！

### 用于徽章的新 `%{latest_tag}` 占位符

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: JihuLab.com
- Links: [文档](../../user/project/badges.md#placeholders) | [相关议题](https://gitlab.com/gitlab-org/gitlab/-/issues/26420)

{{< /details >}}

你现在可以使用 `%{latest_tag}` 占位符创建徽章链接和图片 URL。这个占位符引用为仓库发布的最新标签。

感谢 [@TamsilAmani](https://gitlab.com/TamsilAmani) 的社区贡献！

### 使用群组 API 按 `marked_for_deletion_on` 日期过滤群组

{{< details >}}

- Tier: 专业版，旗舰版
- Offering: JihuLab.com
- Links: [文档](../../api/groups.md#list-groups) | [相关议题](https://gitlab.com/gitlab-org/gitlab/-/issues/429315)

{{< /details >}}

你现在可以使用 `marked_for_deletion_on` 属性过滤群组 API 的响应，该属性返回于特定日期被标记为删除的群组。

感谢 [@imskr](https://gitlab.com/imskr) 的社区贡献！

### 使用 GraphQL API 列出用户的贡献项目

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: JihuLab.com
- Links: [文档](../../api/graphql/reference/_index.md#usercontributedprojects) | [相关议题](https://gitlab.com/gitlab-org/gitlab/-/issues/450191)

{{< /details >}}

你现在可以使用新的 GraphQL API 字段 `User.contributedProjects` 来列出用户贡献过的项目。

感谢 [@yasuk](https://gitlab.com/yasuk) 的社区贡献！

### 使用成员 API 通过用户名添加成员

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: JihuLab.com
- Links: [文档](../../api/group_members.md#add-a-group-member) | [相关议题](https://gitlab.com/gitlab-org/gitlab/-/issues/28208)

{{< /details >}}

以前，使用成员 API 时，你只能通过用户 ID 向群组和项目添加成员。在此版本中，你现在也可以通过用户名添加成员。

感谢 [@imskr](https://gitlab.com/imskr) 的社区贡献！

### 更新了“探索”中的排序和过滤功能

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: JihuLab.com
- Links: [文档](../../user/project/working_with_projects.md#explore-all-projects-on-an-instance)

{{< /details >}}

我们更新了群组和项目“探索”页面的排序和过滤功能。过滤栏现在更宽，以提供更好的可读性。

在项目的“探索”页面中，你现在可以使用标准化的排序选项，包括 **名称**、**创建日期**、**更新日期** 和 **星标**，以及一个用于升序或降序排序的导航元素。语言过滤器已移至过滤菜单。一个新的 **未激活** 选项卡会显示已归档的项目，以实现更集中的搜索。此外，你可以使用 **角色** 过滤器来搜索你是所有者的项目。

在群组的“探索”页面中，我们标准化了排序选项，包括 **名称**、**创建日期** 和 **更新日期**，并添加了一个用于升序或降序排序的导航元素。

我们欢迎你在[议题 438322](https://gitlab.com/gitlab-org/gitlab/-/issues/438322) 中提供关于这些变更的反馈。

### 改进的可见性级别选择

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: JihuLab.com
- Links: [文档](../../user/public_access.md#change-group-visibility) | [相关议题](https://gitlab.com/gitlab-org/gitlab/-/issues/455668)

{{< /details >}}

以前，群组或项目的通用设置仅显示允许的可见性级别。这种视图常常让试图理解为何无法选择其他选项的用户感到困惑，并可能导致信息显示不正确。新视图显示所有可见性级别，将不可选的选项灰显。此外，一个弹出框提供了关于为何某个选项不可用的进一步说明。例如，某个可见性级别可能因为管理员限制了它而不可用，或者因为它会与项目或其父群组的可见性设置冲突。

我们希望这些变更能帮助你解决在选择所需可见性选项时的冲突。感谢 [@gerardo-navarro](https://gitlab.com/gerardo-navarro) 的社区贡献！

### 使用项目 API 按 `marked_for_deletion_on` 日期过滤项目

{{< details >}}

- Tier: 专业版，旗舰版
- Offering: JihuLab.com
- Links: [文档](../../api/projects.md#list-all-projects) | [相关议题](https://gitlab.com/gitlab-org/gitlab/-/issues/463939)

{{< /details >}}

你现在可以使用 `marked_for_deletion_on` 属性过滤项目 API 的响应，该属性返回于特定日期被标记为删除的项目。

感谢 [@imskr](https://gitlab.com/imskr) 的社区贡献！

### 创建 Webhook 时的审计事件

{{< details >}}

- Tier: 专业版，旗舰版
- Offering: JihuLab.com
- Links: [文档](../../user/compliance/audit_event_types.md#webhooks) | [相关议题](https://gitlab.com/gitlab-org/gitlab/-/issues/8068)

{{< /details >}}

审计事件记录了在极狐GitLab 中执行的重要操作。到目前为止，当用户添加系统、群组或项目 Webhook 时，不会创建任何审计事件。

在此版本中，我们为用户创建系统、群组或项目 Webhook 时增加了一个审计事件。

### 使用 REST API 取消正在运行的直接迁移

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: JihuLab.com
- Links: [文档](../../api/bulk_imports.md#cancel-a-migration) | [相关议题](https://gitlab.com/gitlab-org/gitlab/-/issues/438281)

{{< /details >}}

直到现在，取消一个正在运行的直接迁移
[需要访问 Rails 控制台](../../user/group/import/direct_transfer_migrations.md#cancel-a-running-migration)。

在此版本中，我们为管理员增加了使用 REST API 取消迁移的功能。

### 使用 REST API 测试群组钩子

{{< details >}}

- Tier: 专业版，旗舰版
- Offering: JihuLab.com
- Links: [文档](../../api/group_webhooks.md#trigger-a-test-group-hook) | [相关议题](https://gitlab.com/gitlab-org/gitlab/-/issues/455589)

{{< /details >}}

以前，你只能使用 REST API 测试项目钩子。在此版本中，你还可以为指定的群组触发测试钩子。

此端点有一个特殊的速率限制，即每个群组钩子每分钟三个请求。要在私有化部署的极狐GitLab 上禁用此限制，管理员可以禁用 `web_hook_test_api_endpoint_rate_limit` 功能标志。

感谢 [Phawin](https://gitlab.com/lifez) 的[此社区贡献](https://gitlab.com/gitlab-org/gitlab/-/merge_requests/150486)！

### 使用 API 重新导入选定的项目关系

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: JihuLab.com
- Links: [文档](../../api/project_import_export.md#import-project-resources) | [相关议题](https://gitlab.com/gitlab-org/gitlab/-/issues/455889)

{{< /details >}}

当从包含许多相同类型条目（例如，合并请求或流水线）的导出文件导入项目时，有时这些条目中的一部分不会被导入。

在此版本中，我们增加了一个 API 端点，用于重新导入一个命名的关系，并跳过已导入的条目。该 API 需要：

- 一个项目导出归档文件。
- 一个类型，可以是议题、合并请求、流水线或里程碑。

### 通过直接迁移导入时保留继承的成员结构

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: JihuLab.com
- Links: [文档](../../user/group/import/direct_transfer_migrations.md#user-membership-mapping) | [相关议题](https://gitlab.com/gitlab-org/gitlab/-/issues/458834)

{{< /details >}}

到目前为止，在通过直接迁移进行迁移时，[继承的成员](../../user/project/members/_index.md#membership-types)无法被可靠地导入。
这意味着项目的继承成员会被导入为直接成员。

从此版本开始，极狐GitLab 现在会先迁移群组成员资格，然后再迁移项目成员资格。这将复制源极狐GitLab 实例上的继承成员资格。

### 使用 REST API 设置自定义 Webhook 标头

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: JihuLab.com
- Links: [文档](../../api/project_webhooks.md#set-a-custom-header) | [相关议题](https://gitlab.com/gitlab-org/gitlab/-/issues/455528)

{{< /details >}}

在极狐GitLab 16.11 中，我们引入了在创建或编辑 Webhook 时
[添加自定义标头的功能](https://about.gitlab.com/releases/2024/04/18/gitlab-16-11-released/#custom-webhook-headers)。

在此版本中，你现在可以使用极狐GitLab REST API 设置自定义 Webhook 标头。

感谢 [Niklas](https://gitlab.com/Taucher2003) 的[此社区贡献](https://gitlab.com/gitlab-org/gitlab/-/merge_requests/153768)！

### 备份包含存储在磁盘上的外部合并请求 diff

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Links: [文档](../../administration/backup_restore/backup_gitlab.md#backup-command)

{{< /details >}}
`gitlab-backup` 工具现在支持备份存储在本地磁盘上的[外部合并请求差异](../../administration/merge_request_diffs.md)。请注意，`gitlab-backup` 工具不会备份存储在对象存储上的文件。因此，如果外部合并差异存储在对象存储上，则需要手动备份。

针对云原生混合环境的 `backup-utility` 已经支持备份外部合并请求差异，此功能保持不变。

## 统一的 DevOps 与安全

### 在代码审查邮件中禁用差异预览

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Links: [文档](../../user/group/manage.md#disable-diff-previews-in-email-notifications)

{{< /details >}}

当你在合并请求中审查代码并对某行代码进行评论时，极狐GitLab 会在发送给参与者的电子邮件通知中包含几行代码差异。某些组织策略将电子邮件视为安全性较低的系统，或者可能无法控制自己的电子邮件基础设施。这可能会给源代码的 IP 或访问控制带来风险。

群组和项目中新增了设置，使组织能够从合并请求电子邮件中移除差异预览。这有助于确保敏感信息不会扩散到极狐GitLab 之外。

非常感谢 [Joe Snyder](https://gitlab.com/joe-snyder) 为此做出的贡献！

### 管理员可以通过部分电子邮件地址搜索用户

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Links: [文档](../../administration/admin_area.md#administering-users) | [相关议题](https://gitlab.com/gitlab-org/gitlab/-/issues/20381)

{{< /details >}}

管理员现在可以在管理中心区域的用户概览中，通过部分电子邮件地址搜索用户。例如，你可以通过特定的电子邮件域过滤用户，以查找来自某个特定机构的所有用户。此功能仅限于管理员使用，以防止非特权用户访问其他账户的电子邮件地址。

感谢 [@zzaakiirr](https://gitlab.com/zzaakiirr) 为社区做出的贡献！

### 在发布页面上显示发布 RSS 图标

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: JihuLab.com
- Links: [文档](../../user/project/releases/_index.md#track-releases-with-an-rss-feed) | [相关议题](https://gitlab.com/gitlab-org/gitlab/-/issues/30988)

{{< /details >}}

你是否需要在有新的发布版本时收到通知？极狐GitLab 现在为发布版本提供了 RSS 订阅源。你可以通过项目发布页面上的 RSS 图标订阅发布版本订阅源。

感谢 [Martin Schurz](https://gitlab.com/schurzi) 的贡献！

### 自定义角色的新权限

{{< details >}}

- Tier: 旗舰版
- Offering: JihuLab.com
- Links: [文档](../../user/custom_roles/_index.md) | [相关议题](https://gitlab.com/gitlab-org/gitlab/-/issues/391760)

{{< /details >}}

在极狐GitLab 17.1 中，你可以创建具有以下新权限的自定义角色：

- [管理合并请求设置](../../user/custom_roles/abilities.md#code-review-workflow)
- [管理集成](../../user/custom_roles/abilities.md#integrations)
- [管理部署令牌](../../user/custom_roles/abilities.md#continuous-delivery)
- [读取 CRM 联系人](../../user/custom_roles/abilities.md#team-planning)

通过自定义角色，你可以减少拥有所有者角色的用户数量，而通过创建具有等效权限的用户来实现。这有助于你定义完全根据群组需求量身定制的角色，并防止不必要的权限提升。

### 合并请求批准策略的失败时开放/关闭（策略编辑器）

{{< details >}}

- Tier: 旗舰版
- Offering: JihuLab.com
- Links: [文档](../../user/application_security/policies/merge_request_approval_policies.md#fallback_behavior) | [相关史诗](https://gitlab.com/groups/gitlab-org/-/epics/13227)

{{< /details >}}

基于之前的[迭代](https://gitlab.com/groups/gitlab-org/-/epics/10816)，我们在策略编辑器中引入了一个新选项，允许用户将安全策略切换为“失败时开放”或“失败时关闭”。此增强功能扩展了 YAML 支持，以便在策略编辑器视图中进行更简单的配置。

例如，一个配置为“失败时开放”的合并请求策略，如果没有足够的证据来评估标准，则允许合并请求合并。缺乏证据可能是因为项目未启用分析器，或者分析器未能生成供策略评估的结果。这种方法允许团队在努力确保正确执行扫描和强制实施的同时，逐步推行策略。

### 项目所有者接收即将过期的访问令牌通知

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: JihuLab.com
- Links: [文档](../../security/tokens/_index.md#project-access-tokens) | [相关议题](https://gitlab.com/gitlab-org/gitlab/-/issues/460818)

{{< /details >}}

现在，作为直接成员的项目所有者和维护者都会在他们的项目访问令牌即将过期时收到电子邮件通知。以前，只有项目维护者会收到此通知。这有助于让更多人了解即将到来的令牌过期情况。

感谢 [Jacob Henner](https://gitlab.com/arcesium-henner) 的贡献！

### 图片上传时缩小已粘贴的图片

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: JihuLab.com
- Links: [文档](../../user/markdown.md#change-image-or-video-dimensions) | [相关议题](https://gitlab.com/gitlab-org/gitlab/-/issues/419913)

{{< /details >}}

极狐GitLab 17.1 增强了高分辨率图片的处理能力，使其可以在上传过程中被缩小。以前，图片以其原始尺寸显示，导致显示质量不佳。这项改进确保了大图片不会破坏它们所在页面的视觉流。

### 富文本编辑器中可拖动的媒体

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: JihuLab.com
- Links: [文档](../../user/rich_text_editor.md) | [相关议题](https://gitlab.com/gitlab-org/gitlab/-/issues/452233)

{{< /details >}}

以前，在富文本编辑器中移动媒体需要你手动复制和粘贴每个项目。这常常减慢在议题、史诗和 Wiki 中添加媒体的速度。在极狐GitLab 17.1 中，你现在可以在富文本编辑器中拖放媒体，从而显著提高编辑效率。

### Pages 支持在极狐GitLab API 调用中使用双向 TLS

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Links: [文档](../../administration/pages/_index.md#support-mutual-tls-when-calling-the-gitlab-api) | [相关议题](https://gitlab.com/gitlab-org/gitlab-pages/-/issues/548)

{{< /details >}}

极狐GitLab 可以配置为[使用 SSL 证书强制进行客户端身份验证](https://gitlab.com/gitlab-org/omnibus-gitlab/blob/master/doc/settings/ssl.md#enable-2-way-ssl-client-authentication)。然而，极狐GitLab Pages 服务与该功能不兼容，因为它无法配置为使用客户端证书，并且对内部 API 的调用会被拒绝。

从极狐GitLab 17.1 开始，你可以为极狐GitLab Pages 配置客户端证书。这允许你在极狐GitLab API 上启用客户端身份验证，从而加强你的极狐GitLab 实例的安全性。

### Wiki 页面重命名时重定向到新 URL

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: JihuLab.com
- Links: [文档](../../user/project/wiki/_index.md) | [相关议题](https://gitlab.com/gitlab-org/gitlab/-/issues/257892)

{{< /details >}}

极狐GitLab 17.1 引入了对 Wiki 页面重定向的重大增强。当你重命名一个 Wiki 页面时，任何尝试访问旧页面的用户都会被自动重定向到新页面，确保所有现有链接保持有效。这一改进简化了管理页面名称变更的工作流程，并提升了整体知识管理的体验。

### 更新后的 Pages 用户界面

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: JihuLab.com
- Links: [文档](../../user/project/pages/_index.md) | [相关议题](https://gitlab.com/gitlab-org/gitlab/-/merge_requests/153250)

{{< /details >}}

在极狐GitLab 17.1 中，我们改进了 Pages 的用户界面。改进之处包括更有效地利用屏幕空间。这些 UI 改进的重点是提升管理 Pages 时的用户体验和效率。

### 显示容器镜像的最后发布日期

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Links: [文档](../../user/packages/container_registry/_index.md#view-the-container-registry) | [相关议题](https://gitlab.com/gitlab-org/gitlab/-/issues/290949)

{{< /details >}}

以前，容器镜像仓库用户界面中的发布时间戳常常不正确。这意味着你无法依赖这个重要数据来查找和验证你的容器镜像。

在极狐GitLab 17.1 中，我们更新了 UI，以包含准确的 `last_published_at` 时间戳。你可以通过导航到 **部署 > 容器镜像仓库** 并选择一个标签来查看更多详细信息。最后发布日期位于页面顶部。

此改进仅在 JihuLab.com 上为 GA。私有化部署支持处于测试阶段，仅适用于已启用测试版[新一代容器镜像仓库](../../administration/packages/container_registry_metadata_database.md)的实例。

### 按发布日期排序容器镜像仓库标签

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: JihuLab.com
- Links: [文档](../../user/packages/container_registry/_index.md#view-the-container-registry) | [相关议题](https://gitlab.com/groups/gitlab-org/-/epics/7856)

{{< /details >}}

你使用极狐GitLab 容器镜像仓库来查看、推送和拉取 Docker 或 OCI 镜像，以及与你的源代码和流水线一起管理它们。在构建容器镜像后，你通常需要找到并验证它是否已正确构建。对于许多客户来说，使用用户界面找到正确的容器镜像可能具有挑战性。

你现在可以按发布日期对容器镜像仓库标签列表进行排序。你可以使用此功能快速查找和验证最近发布的容器镜像。

此改进仅在 JihuLab.com 上为 GA。私有化部署支持处于测试阶段，因为它需要同样处于测试阶段的新一代容器镜像仓库。要了解更多信息，请参阅[容器镜像仓库元数据数据库文档](../../administration/packages/container_registry_metadata_database.md)。

### 看板实时更新，实现更流畅的工作流

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: JihuLab.com
- Links: [文档](../../user/project/issue_board.md) | [相关议题](https://gitlab.com/gitlab-org/gitlab/-/issues/468187)

{{< /details >}}

你现在会注意到在[看板](../../user/project/issue_board.md)上更新议题时体验更流畅了！你在侧边栏中所做的更改会立即反映在看板上，不再需要刷新。这种响应式看板体验简化了你的工作流程，使你能够快速进行更新，同时实时查看它们的变化。

### 跟踪任务上的时间

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: JihuLab.com
- Links: [文档](../../user/project/time_tracking.md) | [相关议题](https://gitlab.com/gitlab-org/gitlab/-/issues/438577)

{{< /details >}}

通过此版本，你现在可以使用[快速操作](../../user/project/quick_actions.md)或在任务侧边栏的时间跟踪小部件中，为任务设置时间预估并记录花费的时间。可以通过任务的时间跟踪报告查看在任务上花费的时间。

### 了解史诗的进度百分比

{{< details >}}

- Tier: 专业版，旗舰版
- Offering: JihuLab.com
- Links: [文档](../../user/group/epics/manage_epics.md#manage-issues-assigned-to-an-epic) | [相关议题](https://gitlab.com/gitlab-org/gitlab/-/issues/5163)

{{< /details >}}

你现在可以基于史诗中子项的权重完成情况，轻松查看史诗的总体进度。层级小部件中这个新的进度汇总功能让你更容易理解史诗的全部工作范围，并在过程中跟踪进度。

### API 安全测试分析器更新

{{< details >}}

- Tier: 旗舰版
- Offering: JihuLab.com
- Links: [文档](../../user/application_security/api_security_testing/configuration/variables.md) | [相关议题](https://gitlab.com/groups/gitlab-org/-/epics/14170)

{{< /details >}}

极狐GitLab 17.1 为 API 安全测试添加了以下配置变量：

1. `APISEC_SUCCESS_STATUS_CODES` 创建一个以逗号分隔的 HTTP 成功状态码列表，用于定义 API 安全测试扫描作业是否通过。
1. `APISEC_TARGET_CHECK_DISABLED` 禁用在扫描开始前等待目标 API 变为可用。
1. `APISEC_TARGET_CHECK_STATUS_CODE` 指定 API 目标可用性检查的预期状态码。如果未提供，扫描器将接受任何非 500 的状态码。

这些新变量提供了更大的自定义性和灵活性，以确保扫描成功运行。

DAST API 在 16.10 中更名为 API 安全测试。变量名现在以前缀 `APISEC` 开头。以前，它们以 `DAST_API` 开头。带有 `DAST_API` 前缀的变量将被支持到 18.0（2025 年 5 月）。为确保你的配置按预期工作，应尽快更新你的变量名。

### 镜像仓库的容器扫描

{{< details >}}

- Tier: 旗舰版
- Offering: JihuLab.com
- Links: [文档](../../user/application_security/container_scanning/_index.md) | [相关史诗](https://gitlab.com/groups/gitlab-org/-/epics/2340)

{{< /details >}}

极狐GitLab 组合分析现在支持对镜像仓库的容器扫描。

如果项目已启用对镜像仓库的容器扫描，并且一个容器镜像被推送到项目的容器镜像仓库，极狐GitLab 会检查其标签和扫描限制。

如果标签是 `latest`，并且扫描次数在限制（50 次扫描/天）以内，那么极狐GitLab 会创建一个新的流水线，对该镜像运行 `container_scanning` 作业。该流水线与将镜像推送到仓库的用户相关联。

扫描作业会生成一个 CycloneDX SBOM，并上传到极狐GitLab。持续漏洞扫描功能会被激活，并扫描 SBOM 中检测到的软件包。

注意：只有在新的安全公告发布时才会执行漏洞扫描。这发生在[软件包元数据同步时](../../administration/settings/security_and_compliance.md)。

一如既往，我们欢迎你对新发布功能的反馈。要提供反馈，请在[反馈议题](https://gitlab.com/gitlab-org/gitlab/-/issues/466117)中发表评论。

### 模糊测试分析器更新

{{< details >}}

- Tier: 旗舰版
- Offering: JihuLab.com
- Links: [文档](../../user/application_security/api_fuzzing/configuration/variables.md) | [相关议题](https://gitlab.com/gitlab-org/gitlab/-/issues/442699)

{{< /details >}}

极狐GitLab 17.1 为模糊测试添加了以下配置变量：

1. `FUZZAPI_SUCCESS_STATUS_CODES` 创建一个以逗号分隔的 HTTP 成功状态码列表，用于定义模糊测试作业是否通过。
1. `FUZZAPI_TARGET_CHECK_SKIP` 禁用在扫描开始前等待目标 API 变为可用。
1. `FUZZAPI_TARGET_CHECK_STATUS_CODE` 指定 API 目标可用性检查的预期状态码。如果未提供，扫描器将接受任何非 500 的状态码。

这些新变量为确扫描运行提供了更大的自定义性和灵活性。

### 增强对谁可以覆盖用户定义变量的控制

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: JihuLab.com
- Links: [文档](../../ci/variables/_index.md#restrict-pipeline-variables) | [相关议题](https://gitlab.com/gitlab-org/gitlab/-/issues/440338)

{{< /details >}}

为了更好地控制谁可以覆盖用户定义的变量，我们引入了 `ci_pipeline_variables_minimum_role` 项目设置。与现有的 [`restrict_user_defined_variables`](../../ci/variables/_index.md#restrict-pipeline-variables) 设置相比，这个新设置提供了更大的灵活性。你现在可以将覆盖权限限制为无人，或仅限具有至少开发者、维护者或所有者角色的用户。

### 极狐GitLab Runner 17.1 发布

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Links: [文档](https://docs.gitlab.com/runner) | [相关议题](https://gitlab.com/gitlab-org/gitlab-runner/-/issues/36942)

{{< /details >}}

今天我们正式发布极狐GitLab Runner 17.1！极狐GitLab Runner 是轻量级、高扩展性的代理，用于运行你的 CI/CD 作业并将结果返回给极狐GitLab 实例。极狐GitLab Runner 与极狐GitLab CI/CD 协同工作，极狐GitLab CI/CD 是极狐GitLab 内置的开源持续集成服务。

#### 新功能

- [针对 GCP Compute Engine 的极狐GitLab Runner fleeting 插件](https://gitlab.com/gitlab-org/gitlab-runner/-/issues/29221)

#### Bug 修复

- [Runner helper 镜像缺少入口点](https://gitlab.com/gitlab-org/gitlab-runner/-/issues/37689)

所有变更的列表在极狐GitLab Runner [变更日志](https://gitlab.com/gitlab-org/gitlab-runner/blob/17-1-stable/CHANGELOG.md)中。

## 相关主题

- [Bug 修复](https://gitlab.com/groups/gitlab-org/-/issues/?sort=updated_desc&state=closed&label_name%5B%5D=type%3A%3Abug&or%5Blabel_name%5D%5B%5D=workflow%3A%3Acomplete&or%5Blabel_name%5D%5B%5D=workflow%3A%3Averification&or%5Blabel_name%5D%5B%5D=workflow%3A%3Aproduction&milestone_title=17.1)
- [性能改进](https://gitlab.com/groups/gitlab-org/-/issues/?sort=updated_desc&state=closed&label_name%5B%5D=bug%3A%3Aperformance&or%5Blabel_name%5D%5B%5D=workflow%3A%3Acomplete&or%5Blabel_name%5D%5B%5D=workflow%3A%3Averification&or%5Blabel_name%5D%5B%5D=workflow%3A%3Aproduction&milestone_title=17.1)
- [UI 改进](https://papercuts.gitlab.com/?milestone=17.1)
- [弃用和移除](../../update/deprecations.md)
- [升级说明](../../update/versions/_index.md)