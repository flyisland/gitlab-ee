---
stage: Release Notes
group: Monthly Release
date: 2024-02-15
title: "极狐GitLab 16.9 发布说明"
description: "极狐GitLab 16.9 发布，极狐GitLab Duo Chat 测试版现已在专业版中提供"
---

<!-- markdownlint-disable -->
<!-- vale off -->

2024 年 2 月 15 日，极狐GitLab 16.9 发布，包含以下功能。

<a id="primary-features"></a>

## 主要功能

<a id="gitlab-duo-chat-beta-now-available-in-premium"></a>

### 极狐GitLab Duo Chat 测试版现已在专业版中提供

<!-- categories: Duo Chat -->

{{< details >}}

- 适用版本: 专业版、旗舰版
- 交付方式: JihuLab.com、私有化部署
- 链接: [文档](../../user/gitlab_duo_chat/_index.md) | [相关史诗](https://gitlab.com/groups/gitlab-org/-/epics/11251)

{{< /details >}}

在 16.8 中，我们让私有化部署实例可以使用极狐GitLab Duo Chat。在 16.9 中，我们让专业版客户可以使用 Chat，目前它仍处于测试版阶段。

极狐GitLab Duo Chat 可以：

- 解释或总结议题、史诗和代码。
- 回答关于这些产物的具体问题，例如“收集此议题中所提解决方案相关评论中提出的所有论点。”
- 根据这些产物中的信息生成代码或内容。例如，“你能为这段代码编写文档吗？”
- 帮助您启动一个流程。例如，“创建一个 .GitLab-ci.yml 配置文件，用于在极狐GitLab CI/CD 流水线中测试和构建 Ruby on Rails 应用程序。”
- 回答您所有 DevSecOps 相关问题，无论您是初学者还是专家。例如，“如何为 REST API 设置动态应用程序安全测试？”
- 回答后续问题，以便您可以迭代地处理前面所有场景。

极狐GitLab Duo Chat 作为测试版功能提供。它也已作为实验性功能集成到我们的 Web IDE 和 VS Code 的极狐GitLab Workflow 扩展中。在这些 IDE 中，您还可以使用[预定义的聊天命令，帮助您更快速地完成标准任务](../../user/gitlab_duo_chat/examples.md)，例如编写测试。

您可以通过在产品内或通过我们的[反馈议题](https://gitlab.com/gitlab-org/gitlab/-/issues/430124)提供您使用极狐GitLab Duo Chat 的体验反馈，帮助我们完善这些功能。

<a id="request-changes-on-merge-requests"></a>

### 在合并请求上请求更改

<!-- categories: Code Review Workflow -->

{{< details >}}

- 适用版本: 基础版、专业版、旗舰版
- 交付方式: 私有化部署
- 链接: [文档](../../user/project/merge_requests/reviews/_index.md#submit-a-review)

{{< /details >}}

评审合并请求的最后一步是传达评审结果。批准的含义很明确，但留下评论的含义则不然。它们要求作者阅读您的评论，然后判断这些评论是纯粹的信息性内容，还是描述了需要进行的更改。现在，当您完成评审时，可以从三个选项中选择：

- **评论**：提交一般反馈，但不明确批准。
- **批准**：提交反馈并批准更改。
- **请求更改**：提交应在合并前处理的反馈。

侧边栏现在会在您的姓名旁边显示您的评审结果。目前，以**请求更改**结束评审不会阻止合并请求被合并，但它为合并请求中的其他参与者提供了额外的上下文。

您可以在我们的[反馈议题](https://gitlab.com/gitlab-org/gitlab/-/issues/438573)中留下关于**请求更改**功能的反馈。

<a id="improvements-to-the-cicd-variables-user-interface"></a>

### CI/CD 变量用户界面的改进

<!-- categories: Secrets Management -->

{{< details >}}

- 适用版本: 基础版、专业版、旗舰版
- 交付方式: 私有化部署
- 链接: [文档](../../ci/variables/_index.md) | [相关议题](https://gitlab.com/gitlab-org/gitlab/-/issues/418331)

{{< /details >}}

在极狐GitLab 16.9 中，我们发布了一系列针对 CI/CD 变量用户体验的改进。我们通过以下更改改进了变量创建流程：

- [当变量值不符合要求时改进验证](https://gitlab.com/gitlab-org/gitlab/-/issues/365934)。
- [变量创建期间的帮助文本](https://gitlab.com/gitlab-org/gitlab/-/issues/410220)。
- [允许调整变量表单中值字段的大小](https://gitlab.com/gitlab-org/gitlab/-/issues/434667)。

其他改进包括为群组和项目变量新增了[可选的描述字段](https://gitlab.com/gitlab-org/gitlab/-/issues/378938)，以协助管理变量。我们还让[添加或编辑多个变量](https://gitlab.com/gitlab-org/gitlab/-/issues/434666)变得更加容易，降低了软件开发工作流程中的阻力，使开发者能够更高效地完成工作。

我们始终重视并感谢您[对这些更改的反馈](https://gitlab.com/gitlab-org/gitlab/-/issues/441177)。

<a id="expanded-options-for-auto-canceling-pipelines"></a>

### 自动取消流水线的扩展选项

<!-- categories: Pipeline Composition -->

{{< details >}}

- 适用版本: 基础版、专业版、旗舰版
- 交付方式: 私有化部署
- 链接: [文档](../../ci/yaml/_index.md#workflowauto_cancelon_new_commit) | [相关议题](https://gitlab.com/gitlab-org/gitlab/-/issues/412473)

{{< /details >}}

目前，要使用[自动取消冗余流水线功能](../../ci/pipelines/settings.md#auto-cancel-redundant-pipelines)，您必须将可取消的作业设置为 [`interruptible: true`](../../ci/yaml/_index.md#interruptible)，以确定流水线是否可以被取消。但这仅适用于当极狐GitLab 尝试取消流水线时正在运行的作业。任何尚未启动（处于“pending”状态）的作业也被视为可以安全取消，无论其 `interruptible` 配置如何。

这种灵活性的缺乏阻碍了那些希望对自动取消流水线功能可以取消哪些具体作业拥有更多控制权的用户。为了解决这一限制，我们很高兴地宣布引入 `auto_cancel:on_new_commit` 关键字，提供对作业取消更细粒度的控制。如果旧行为不适用于您，您现在可以选择将流水线配置为仅取消明确设置为 `interruptible: true`的作业，即使它们尚未启动。您还可以将作业设置为永不自动取消。

<a id="scale-and-deployments"></a>

## 规模与部署

<a id="limit-concurrent-code-indexing-jobs-for-advanced-search"></a>

### 限制高级搜索的并发代码索引作业

<!-- categories: Global Search -->

{{< details >}}

- 适用版本: 专业版、旗舰版
- 交付方式: 私有化部署
- 链接: [文档](../../integration/advanced_search/elasticsearch.md#advanced-search-configuration) | [相关议题](https://gitlab.com/gitlab-org/gitlab/-/issues/435402)

{{< /details >}}

作为极狐GitLab 管理员，您现在可以设置可并发运行的 Elasticsearch 代码索引后台作业的最大数量。以前，您只能通过创建专用的 Sidekiq 进程来限制并发作业的数量。

<a id="custom-guidelines-for-managing-group-and-project-members"></a>

### 管理群组和项目成员的自定义准则

<!-- categories: Groups & Projects -->

{{< details >}}

- 适用版本: 基础版、专业版、旗舰版
- 交付方式: 私有化部署
- 链接: [文档](../../administration/appearance.md#member-guidelines) | [相关议题](https://gitlab.com/gitlab-org/gitlab/-/issues/433093)

{{< /details >}}

管理员现在可以添加文本准则，这些准则对有权在群组或项目的**成员**页面上管理成员的用户可见。管理员可以在**管理区域**设置的**外观**部分访问这些准则。

对于使用外部工具管理群组或项目成员的团队来说，准则很有帮助。例如，准则可以链接到用户应使用的预定义群组，而不是管理单个成员的成员资格。

感谢 @bufferoverflow 的这一社区贡献！

<a id="show-import-stats-for-direct-transfer"></a>

### 显示直接转移的导入统计信息

<!-- categories: Importers -->

{{< details >}}

- 适用版本: 基础版、专业版、旗舰版
- 交付方式: JihuLab.com、私有化部署
- 链接: [文档](../../user/group/import/_index.md) | [相关议题](https://gitlab.com/gitlab-org/gitlab/-/issues/437874)

{{< /details >}}

通过直接转移完成的极狐GitLab 群组和项目迁移会显示徽章（**完成**、**部分完成**和**失败**），以告知用户迁移的总体最终结果。用户还可以通过点击**查看失败项**链接访问未导入条目的列表。

然而，对于部分导入的项目，没有快速的方法来了解每种类型有多少条目成功导入，有多少未成功导入。

在此版本中，我们为群组和项目添加了导入结果统计信息。要访问统计信息，请在直接转移历史页面上选择**详情**链接。

<a id="enable-jira-issues-at-the-group-level"></a>

### 在群组级别启用 Jira 议题

<!-- categories: Settings -->

{{< details >}}

- 适用版本: 专业版、旗舰版
- 交付方式: JihuLab.com、私有化部署
- 链接: [文档](../../integration/jira/configure.md#view-jira-issues) | [相关议题](https://gitlab.com/gitlab-org/gitlab/-/issues/325715)

{{< /details >}}

在此版本中，您可以为极狐GitLab 群组中的所有项目启用 Jira 议题。以前，您只能为每个极狐GitLab 项目单独启用 Jira 议题。

<a id="rest-api-support-for-the-gitlab-for-slack-app"></a>

### GitLab for Slack 应用的 REST API 支持

<!-- categories: Settings -->

{{< details >}}

- 适用版本: 基础版、专业版、旗舰版
- 交付方式: JihuLab.com、私有化部署
- 链接: [文档](../../api/group_integrations.md#gitlab-for-slack-app) | [相关议题](https://gitlab.com/gitlab-org/gitlab/-/issues/364440)

{{< /details >}}

在此版本中，我们为 GitLab for Slack 应用添加了 REST API 支持。

您无法通过 API 创建 GitLab for Slack 应用。相反，您必须从极狐GitLab UI [安装该应用](../../user/project/integrations/gitlab_slack_application.md#install-the-gitlab-for-slack-app)。然后，您可以检索集成设置，并为项目更新或禁用该应用。

<a id="access-gitlab-usage-data-through-the-rest-api"></a>

### 通过 REST API 访问极狐GitLab 使用数据

<!-- categories: Application Instrumentation -->

{{< details >}}

- 适用版本: 基础版、专业版、旗舰版
- 交付方式: 私有化部署
- 链接: [文档](../../api/usage_data.md#export-service-ping-data) | [相关史诗](https://gitlab.com/groups/gitlab-org/-/epics/12251)

{{< /details >}}

私有化部署用户现在可以通过 REST API 连接无缝访问 Service Ping 数据，便于与下游系统直接集成。这相比以前通过文件下载的方式有了显著改进。新方法为私有化部署用户提供了一种更高效、更实时的方式，以进行自定义分析并从其极狐GitLab 使用数据中获取特定洞察。

<a id="unified-devops-and-security"></a>

## 统一 DevOps 与安全

<a id="authenticate-and-sign-commits-with-ssh-certificates"></a>

### 使用 SSH 证书进行身份验证和签署提交

<!-- categories: Source Code Management -->

{{< details >}}

- 链接: [文档](../../user/group/ssh_certificates.md)

{{< /details >}}

以前，JihuLab.com 上的 Git 访问控制选项依赖于用户账户中设置的凭据。现在，您可以设置一个流程，仅使用 SSH 证书即可实现 Git 访问。您还可以使用这些证书来签署提交。

<a id="limit-workspaces-per-user-on-the-gitlab-agent"></a>

### 限制极狐GitLab Agent 上每个用户的工作区数量

<!-- categories: Workspaces -->

{{< details >}}

- 适用版本: 专业版、旗舰版
- 交付方式: 私有化部署
- 链接: [文档](../../user/workspace/gitlab_agent_configuration.md)

{{< /details >}}

在极狐GitLab 16.8 中，我们引入了极狐GitLab Kubernetes Agent 的设置，以限制每个工作区的 CPU 和内存使用量。

现在在 16.9 中，您还可以限制每个用户的工作区数量。通过这项新设置，您可以更好地控制云资源，并防止个别开发者增加云支出。

<a id="allow-users-to-cleanup-partial-resources-from-failed-deployments"></a>

### 允许用户清理失败部署中的部分资源

<!-- categories: Environment Management -->

{{< details >}}

- 适用版本: 基础版、专业版、旗舰版
- 交付方式: JihuLab.com、私有化部署
- 链接: [文档](../../ci/environments/_index.md#run-a-pipeline-job-when-environment-is-stopped) | [相关议题](https://gitlab.com/gitlab-org/gitlab/-/issues/435128)

{{< /details >}}

环境 [`auto_stop_in`](../../ci/yaml/_index.md#environmentauto_stop_in) 功能已更新为从最后一个已完成的流水线运行作业，而不是从最后一个成功的流水线运行。这避免了因没有任何成功的流水线而导致自动停止作业无法运行的边缘情况。

在某些情况下，此行为可能被视为破坏性变更。新行为目前受功能标志控制，并将在 17.0 中成为默认行为，同时，我们将弃用旧行为，并在极狐GitLab 18.0 中移除。我们建议所有人立即开始过渡或配置功能标志，以最大程度降低首次升级到 17.x 时破坏性变更的风险。

<a id="kubernetes-129-support"></a>

### 支持 Kubernetes 1.29

<!-- categories: Deployment Management -->

{{< details >}}

- 适用版本: 基础版、专业版、旗舰版
- 交付方式: JihuLab.com、私有化部署
- 链接: [文档](../../user/clusters/agent/_index.md) | [相关议题](https://gitlab.com/gitlab-org/gitlab/-/issues/435293)

{{< /details >}}

此版本增加了对 2023 年 12 月发布的 Kubernetes 1.29 版本的全面支持。如果您将应用部署到 Kubernetes，现在可以将已连接的集群升级到最新版本，并利用其所有功能。

您可以阅读更多关于我们的 Kubernetes 支持政策和其他受支持的 Kubernetes 版本的信息。

<a id="enterprise-user-email-address-accessible-through-ui-and-api"></a>

### 可通过 UI 和 API 访问企业用户电子邮件地址

<!-- categories: User Management -->

{{< details >}}

- 交付方式: JihuLab.com
- 链接: [文档](../../user/enterprise_user/_index.md) | [相关议题](https://gitlab.com/gitlab-org/gitlab/-/issues/391453)

{{< /details >}}

拥有[企业用户](../../user/enterprise_user/_index.md)的群组所有者现在可以使用用户管理 UI 和[群组与项目成员 API](../../api/group_members.md) 来查看这些用户的电子邮件地址。以前，仅返回已预配用户的电子邮件地址。

<a id="add-or-remove-service-accounts-from-groups-with-ldap-group-sync"></a>

### 使用 LDAP 群组同步在群组中添加或移除服务账号

<!-- categories: User Management -->

{{< details >}}

- 适用版本: 专业版、旗舰版
- 交付方式: 私有化部署
- 链接: [文档](../../user/group/access_and_permissions.md) | [相关议题](https://gitlab.com/gitlab-org/gitlab/-/issues/425947)

{{< /details >}}

以前，如果群组启用了 LDAP 同步，管理员无法邀请或移除该群组中的任何用户。现在，管理员可以使用群组和项目成员 API 将服务账号用户邀请到启用了 LDAP 同步的群组中，或从该群组中移除这些用户。管理员仍然无法将人类用户邀请到启用了 LDAP 同步的群组中，或从该群组中移除这些用户。这确保了 LDAP 群组同步是人类用户账户成员资格的唯一事实来源，同时允许灵活地使用服务账号为 LDAP 同步的群组添加自动化。

<a id="audit-event-for-updating-or-deleting-a-custom-role"></a>

### 更新或删除自定义角色的审计事件

<!-- categories: Permissions -->

{{< details >}}

- 适用版本: 旗舰版
- 交付方式: JihuLab.com、私有化部署
- 链接: [文档](../../administration/compliance/audit_event_reports.md) | [相关议题](https://gitlab.com/gitlab-org/gitlab/-/issues/437672)

{{< /details >}}

极狐GitLab 现在会在更新或删除自定义角色时记录审计事件。在发生权限提升的情况下，此事件对于识别权限是否已被添加或更改非常重要。

<a id="improved-ux-for-expired-saml-sso-sessions"></a>

### 改进过期 SAML SSO 会话的用户体验

<!-- categories: System Access -->

{{< details >}}

- 交付方式: JihuLab.com
- 链接: [文档](../../user/group/saml_sso/_index.md) | [相关议题](https://gitlab.com/gitlab-org/gitlab/-/issues/414475)

{{< /details >}}

如果您属于一个需要 SAML SSO 身份验证的群组，但您没有该群组的有效会话，则会显示一个横幅，提示您刷新会话。以前，当会话过期时，议题和合并请求不会显示，但用户并不清楚这一点。现在，用户可以清楚地知道何时必须重新进行身份验证才能看到其所有工作项。

<a id="standards-adherence-report-improvements"></a>

### 标准遵循报告改进

<!-- categories: Compliance Management -->

{{< details >}}

- 适用版本: 旗舰版
- 交付方式: JihuLab.com、私有化部署
- 链接: [文档](../../user/compliance/compliance_center/_index.md) | [相关史诗](https://gitlab.com/groups/gitlab-org/-/epics/11053)

{{< /details >}}

[合规中心](../../user/compliance/compliance_center/_index.md)内的[标准遵循报告](../../user/compliance/compliance_center/_index.md)是合规团队监控其合规状况的目标位置。

在极狐GitLab 16.5 中，我们引入了该报告以及极狐GitLab 标准——一组所有合规团队都应监控的常见合规要求。该标准可帮助您了解哪些项目满足这些要求，哪些项目未达标，以及如何使其合规。随着时间的推移，我们将把更多标准引入报告中。

在此里程碑中，我们进行了一些改进，使报告更加稳健且更具可操作性。这些改进包括：

- 按检查项对结果进行分组
- 按项目、检查项和标准进行筛选
- 导出为 CSV（通过电子邮件交付）
- 改进分页

<a id="rich-text-editor-broader-availability"></a>

### 富文本编辑器更广泛的可用性

<!-- categories: Team Planning, Portfolio Management -->

{{< details >}}

- 适用版本: 基础版、专业版、旗舰版
- 交付方式: JihuLab.com、私有化部署
- 链接: [文档](../../user/rich_text_editor.md) | [相关史诗](https://gitlab.com/groups/gitlab-org/-/epics/7098)

{{< /details >}}

在极狐GitLab 16.2 中，[我们发布了](gitlab-16-2-released.md)富文本编辑器，作为纯文本编辑器的替代方案。富文本编辑器提供了“所见即所得”的编辑界面，以及可扩展的基础，便于进一步开发。然而，在此版本之前，富文本编辑器仅在议题、史诗和合并请求中可用。

在极狐GitLab 16.9 中，富文本编辑器现已在以下位置可用：

- [需求描述](https://gitlab.com/gitlab-org/gitlab/-/issues/407493)
- [漏洞发现](https://gitlab.com/gitlab-org/gitlab/-/issues/407491)
- [发布描述](https://gitlab.com/gitlab-org/gitlab/-/issues/407494)
- [设计评论](https://gitlab.com/gitlab-org/gitlab/-/issues/407505)

通过改进对富文本编辑器的访问，您可以更高效地协作，而无需具备 Markdown 经验。

<a id="allow-duplicate-terraform-modules"></a>

### 允许重复的 Terraform 模块

<!-- categories: Package Registry -->

{{< details >}}

- 适用版本: 基础版、专业版、旗舰版
- 交付方式: 私有化部署
- 链接: [文档](../../user/packages/terraform_module_registry/_index.md#allow-duplicate-terraform-modules) | [相关议题](https://gitlab.com/gitlab-org/gitlab/-/issues/368040)

{{< /details >}}

您可以使用极狐GitLab 软件包仓库发布和下载 Terraform 模块。默认情况下，每个项目不能多次发布相同的模块名称和版本。

然而，您可能希望允许重复上传，尤其是在发布时。在此版本中，极狐GitLab 扩展了软件包仓库的群组设置，因此您可以允许或拒绝重复的模块。

<a id="validate-terraform-modules-from-your-group-or-subgroup"></a>

### 从群组或子群组验证 Terraform 模块

<!-- categories: Package Registry -->

{{< details >}}

- 适用版本: 基础版、专业版、旗舰版
- 交付方式: 私有化部署
- 链接: [文档](../../user/packages/package_registry/_index.md#view-packages) | [相关议题](https://gitlab.com/gitlab-org/gitlab/-/issues/352041)

{{< /details >}}

使用极狐GitLab Terraform 注册中心时，拥有所有模块的跨项目视图非常重要。直到最近，用户界面仅在项目级别可用。如果您的群组结构复杂，您可能难以找到和验证您的模块。

从极狐GitLab 16.9 开始，您可以在极狐GitLab 中查看所有群组和子群组模块。更高的可见性让您更好地了解您的注册中心，并降低名称冲突的可能性。

<a id="boards-work-in-progress-line"></a>

### 看板进行中限制线

<!-- categories: Portfolio Management -->

{{< details >}}

- 适用版本: 专业版、旗舰版
- 交付方式: 私有化部署
- 链接: [文档](../../user/project/issue_board.md#work-in-progress-limits) | [相关议题](https://gitlab.com/gitlab-org/gitlab/-/issues/440540)

{{< /details >}}

您现在可以在看板列表中可视化您的进行中限制。当超出限制时，列表中会出现一条指示线，帮助您了解哪些条目超出了限制，并相应地管理列表。

<a id="new-stage-events-for-custom-value-stream-analytics"></a>

### 自定义价值流分析的新阶段事件

<!-- categories: Value Stream Management -->

{{< details >}}

- 适用版本: 专业版、旗舰版
- 交付方式: JihuLab.com、私有化部署
- 链接: [文档](../../user/group/value_stream_analytics/_index.md#value-stream-stage-events) | [相关议题](https://gitlab.com/gitlab-org/gitlab/-/issues/431934)

{{< /details >}}

为了改进[在极狐GitLab 中跟踪开发工作流程](https://about.gitlab.com/blog/value-stream-total-time-chart/)，价值流分析扩展了一个新的阶段事件：`Issue first added to iteration`。您可以使用此事件来检测因团队规划过于超前而缺乏敏捷性所导致的问题，或检测那些议题从一个迭代滚动到下一个迭代的团队所面临的执行挑战。例如，您现在可以添加一个“已计划”阶段，该阶段从 `Issue first added to iteration` 开始，到 `Issue first assigned` 结束。

<a id="improvements-to-operational-container-scanning"></a>

### 运维容器扫描的改进

<!-- categories: Software Composition Analysis -->

{{< details >}}

- 适用版本: 旗舰版
- 交付方式: 私有化部署
- 链接: [文档](../../user/clusters/agent/vulnerabilities.md) | [相关史诗](https://gitlab.com/groups/gitlab-org/-/epics/11968)

{{< /details >}}

我们对运维容器扫描（OCS）进行了报告和稳定性方面的改进。值得注意的是，Trivy 报告大小限制已提高，这为用户提供了更稳定的体验。将 Trivy 报告大小从 10MB 扩展到 100MB，使受报告大小限制的客户能够利用 OCS 来保护其集群中的容器镜像。

随着 OCS 的这一更改，在 FIPS 模式下运行 `gitlab-agent`的用户无法运行运维容器扫描。有关此内容的更多详细信息，请参阅我们的文档，并在议题 [#440849](https://gitlab.com/gitlab-org/gitlab/-/issues/440849)中提供反馈。

<a id="dast-analyzer-updates"></a>

### DAST 分析器更新

<!-- categories: DAST -->

{{< details >}}

- 适用版本: 旗舰版
- 交付方式: 私有化部署
- 链接: [文档](../../user/application_security/dast/browser/_index.md) | [相关史诗](https://gitlab.com/groups/gitlab-org/-/epics/12685)

{{< /details >}}

我们在 16.9 版本里程碑期间解决了以下缺陷：

- 当浏览器已切换到新页面时，基于浏览器的 DAST 在尝试获取缓存资源的响应正文时出错。[查看议题](https://gitlab.com/gitlab-org/gitlab/-/issues/435175)了解更多详情。
- 基于浏览器的 DAST 爬取任务未并行运行，导致性能下降。[查看议题](https://gitlab.com/gitlab-org/gitlab/-/issues/435325)了解更多详情。

<a id="updated-sast-rules-for-higher-quality-results"></a>

### 更新 SAST 规则以获得更高质量的结果

<!-- categories: SAST -->

{{< details >}}

- 适用版本: 基础版、专业版、旗舰版
- 交付方式: 私有化部署
- 链接: [文档](../../user/application_security/sast/rules.md#important-rule-changes) | [相关史诗](https://gitlab.com/groups/gitlab-org/-/epics/10971)

{{< /details >}}

我们更新了 40 多条默认极狐GitLab SAST 规则，以：

- 通过更新 C#、Go、Java、JavaScript 和 Python 的检测逻辑规则，增加真阳性结果（正确识别的漏洞）并减少假阴性结果（错误识别的漏洞）。
- 为 C#、Go、Java 和 Python 规则添加 [OWASP 映射](https://gitlab.com/gitlab-org/gitlab/-/issues/438561)。

规则更改包含在基于 Semgrep 的极狐GitLab SAST [分析器](../../user/application_security/sast/analyzers.md)的更新版本中。除非您[将 SAST 分析器固定到特定版本](../../user/application_security/sast/_index.md)，否则此更新会在极狐GitLab 16.0 或更高版本上自动应用。我们正在[史诗 10907](https://gitlab.com/groups/gitlab-org/-/epics/10907)中开展更多 SAST 规则改进。

<a id="more-detailed-security-findings-in-vs-code"></a>

### VS Code 中更详细的安全发现

<!-- categories: Editor Extensions, API Security, Container Scanning, DAST, Fuzz Testing, SAST, Secret Detection, Software Composition Analysis, Vulnerability Management -->

{{< details >}}

- 适用版本: 旗舰版
- 交付方式: 私有化部署
- 链接: [文档](../../editor_extensions/visual_studio_code/_index.md) | [相关史诗](https://gitlab.com/groups/gitlab-org/-/epics/10996)

{{< /details >}}

我们改进了[极狐GitLab Workflow 扩展](https://marketplace.visualstudio.com/items?itemName=GitLab.gitlab-workflow#security-findings)在 Visual Studio Code (VS Code) 中显示安全发现的方式。
您现在可以查看以前未显示的更多安全发现详情，包括：

- 完整描述，带有富文本格式。
- 漏洞的解决方案（如果有）。
- 指向代码库中问题发生位置的链接。
- 指向有关所发现漏洞类型的更多信息的链接。

我们还：

- 改进了扩展在结果就绪前显示安全扫描状态的方式。
- 进行了其他可用性改进。

<a id="control-which-roles-can-cancel-pipelines-or-jobs"></a>

### 控制哪些角色可以取消流水线或作业

<!-- categories: Continuous Integration (CI) -->

{{< details >}}

- 适用版本: 专业版、旗舰版
- 交付方式: JihuLab.com、私有化部署
- 链接: [文档](../../ci/pipelines/settings.md#restrict-roles-that-can-cancel-pipelines-or-jobs) | [相关议题](https://gitlab.com/gitlab-org/gitlab/-/issues/410634)

{{< /details >}}

组织可能希望控制哪些用户角色能够取消流水线。以前，任何可以运行流水线的人也可以取消流水线。现在，项目维护者可以更新一项设置，将流水线和作业取消限制为特定角色，甚至完全阻止取消！

<a id="fleet-dashboard-compute-minutes-used-on-instance-runners-per-project-metric-card"></a>

### 集群仪表板：实例 Runner 上每个项目使用的计算分钟指标卡

<!-- categories: Fleet Visibility -->

{{< details >}}

- 适用版本: 旗舰版
- 交付方式: 私有化部署
- 链接: [文档](../../ci/runners/runner_fleet_dashboard.md) | [相关议题](https://gitlab.com/gitlab-org/gitlab/-/issues/421457)

{{< /details >}}

在大规模管理极狐GitLab Runner 集群时，您告诉我们，了解哪些项目在 Runner 上使用最多的计算分钟至关重要。对您来说，这些信息对于帮助团队优化 CI/CD 流水线以及帮助您就集群成本优化做出正确决策都必不可少。

现在，Runner 集群仪表板中提供了按项目统计的 Runner 计算使用量指标卡，它是对之前发布的按 CSV 导出 CI/CD 计算分钟功能的补充。您可以查看消耗实例 Runner 分钟数最多的项目，以及您的极狐GitLab 环境中使用最多的实例 Runner。

<a id="gitlab-runner-169"></a>

### 极狐GitLab Runner 16.9

<!-- categories: GitLab Runner Core -->

{{< details >}}

- 适用版本: 基础版、专业版、旗舰版
- 交付方式: 私有化部署
- 链接: [文档](https://gitlab.cn/docs/runner/)

{{< /details >}}

我们今天还发布了极狐GitLab Runner 16.9！极狐GitLab Runner 是轻量级、高度可扩展的代理，用于运行您的 CI/CD 作业并将结果发送回极狐GitLab 实例。极狐GitLab Runner 与极狐GitLab CI/CD 协同工作，后者是极狐GitLab 中包含的开源持续集成服务。

<a id="whats-new"></a>

#### 新增功能

- [使 Kubernetes API 重试可配置](https://gitlab.com/gitlab-org/gitlab-runner/-/issues/37349)

<a id="bug-fixes"></a>

#### 缺陷修复

- [随机警告：无法移除 ***：目录不为空](https://gitlab.com/gitlab-org/gitlab-runner/-/issues/3185)

所有更改的列表位于极狐GitLab Runner [CHANGELOG](https://gitlab.com/gitlab-org/gitlab-runner/blob/16-9-stable/CHANGELOG.md)中。

<a id="show-mr-link-for-branch-based-pipelines"></a>

### 为基于分支的流水线显示合并请求链接

<!-- categories: Continuous Integration (CI) -->

{{< details >}}

- 适用版本: 基础版、专业版、旗舰版
- 交付方式: JihuLab.com、私有化部署
- 链接: [文档](../../ci/pipelines/_index.md#view-pipelines) | [相关议题](https://gitlab.com/gitlab-org/gitlab/-/issues/416134)

{{< /details >}}

如果您使用分支流水线，现在可以从流水线详情页面快速查看和访问相关的合并请求。
