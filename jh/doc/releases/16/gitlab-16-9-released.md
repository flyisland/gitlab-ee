---
stage: 发布说明
group: 月度发布
date: 2024-02-15
title: "极狐GitLab 16.9 发布说明"
description: "极狐GitLab 16.9 发布，极狐GitLab Duo Chat Beta 现已在专业版中可用"
---

<!-- markdownlint-disable -->
<!-- vale off -->

2024 年 2 月 15 日，极狐GitLab 16.9 发布，包含以下功能。

<a id="primary-features"></a>

## 主要功能

<a id="gitlab-duo-chat-beta-now-available-in-premium"></a>

### 极狐GitLab Duo Chat Beta 现已在专业版中可用

{{< details >}}

- Tier: 专业版，旗舰版
- Offering: JihuLab.com
- Links: [文档](../../user/gitlab_duo_chat/_index.md) | [相关史诗](https://jihulab.com/groups/gitlab-cn/-/epics/11251)

{{< /details >}}

在 16.8 版本中，我们使极狐GitLab Duo Chat 可用于私有化部署实例。在 16.9 版本中，我们在 Chat 仍处于 Beta 阶段的同时，将其提供给专业版客户。

极狐GitLab Duo Chat 可以：

- 解释或总结议题、史诗和代码。
- 回答关于这些构件的具体问题，例如“总结该议题中评论提出的所有关于所提议解决方案的论点”。
- 根据这些构件中的信息生成代码或内容。例如，“你能为这段代码编写文档吗？”
- 帮助你启动一个流程。例如，“创建一个用于在极狐GitLab CI/CD 流水线中测试和构建 Ruby on Rails 应用程序的 .GitLab-ci.yml 配置文件”。
- 回答你所有的 DevSecOps 相关问题，无论你是新手还是专家。例如，“如何为 REST API 设置动态应用程序安全测试？”
- 回答后续问题，以便你可以通过迭代方式逐步完成所有前述场景。

极狐GitLab Duo Chat 作为 Beta 功能提供。它也集成到我们的 Web IDE 中作为实验功能。在这些 IDE 中，你还可以使用[预定义的聊天命令来帮助你更快地完成标准任务](../../user/gitlab_duo_chat/examples.md)，例如编写测试。

<a id="request-changes-on-merge-requests"></a>

### 合并请求的请求变更

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Links: [文档](../../user/project/merge_requests/reviews/_index.md#submit-a-review)

{{< /details >}}

审查合并请求的最后一步是沟通审查结果。虽然批准是明确的，但留下评论则不然。它们需要作者阅读你的评论，然后确定这些评论是纯粹的信息性意见，还是描述了需要进行的更改。现在，当你完成审查时，可以从三个选项中进行选择：

- **评论**：提交一般性反馈，但不明确批准。
- **批准**：提交反馈并批准更改。
- **请求变更**：提交反馈，这些反馈应在合并之前解决。

现在，侧边栏会在你的名字旁边显示你的审查结果。目前，以**请求变更**结束审查并不会阻止合并请求被合并，但它为合并请求中的其他参与者提供了额外的上下文。

<a id="improvements-to-the-cicd-variables-user-interface"></a>

### CI/CD 变量用户界面的改进

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Links: [文档](../../ci/variables/_index.md)

{{< /details >}}

在极狐GitLab 16.9 中，我们对 CI/CD 变量用户体验进行了一系列改进。我们通过以下更改改进了变量创建流程：

- 改善了当变量值不符合要求时的验证。
- 在变量创建期间提供帮助文本。
- 允许调整变量表单中值字段的大小。

其他改进包括一个新的、可选的群组和项目变量描述字段，以帮助管理变量。我们还使得添加或编辑多个变量变得更加容易，从而降低了软件开发工作流程中的摩擦，并使开发人员能够更高效地完成工作。

<a id="expanded-options-for-auto-canceling-pipelines"></a>

### 自动取消流水线的扩展选项

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Links: [文档](../../ci/yaml/_index.md#workflowauto_cancelon_new_commit)

{{< /details >}}

目前，要使用[自动取消冗余流水线功能](../../ci/pipelines/settings.md#auto-cancel-redundant-pipelines)，你必须将可取消的作业设置为 [`interruptible: true`](../../ci/yaml/_index.md#interruptible) 以确定是否可以取消流水线。但这仅适用于极狐GitLab 尝试取消流水线时正在运行的作业。任何尚未启动（处于“待处理”状态）的作业也被视为可以安全取消，无论其 `interruptible` 配置如何。

这种缺乏灵活性的情况阻碍了那些希望更精确控制自动取消流水线功能可以取消哪些作业的用户。为了解决这一限制，我们很高兴地宣布引入 `auto_cancel:on_new_commit` 关键字，并提供更精细的作业取消控制。如果旧行为不适合你，你现在可以选择将流水线配置为仅取消显式设置为 `interruptible: true` 的作业，即使它们尚未启动。你还可以将作业设置为永远不会被自动取消。

<a id="scale-and-deployments"></a>

## 扩展与部署

<a id="limit-concurrent-code-indexing-jobs-for-advanced-search"></a>

### 限制高级搜索的并发代码索引作业数量

{{< details >}}

- Tier: 专业版，旗舰版
- Links: [文档](../../integration/advanced_search/elasticsearch.md#advanced-search-configuration)

{{< /details >}}

作为极狐GitLab 管理员，你现在可以设置可同时运行的 Elasticsearch 代码索引后台作业的最大数量。以前，你只能通过创建专用的 Sidekiq 进程来限制并发作业的数量。

<a id="custom-guidelines-for-managing-group-and-project-members"></a>

### 用于管理群组和项目成员的自定义指南

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Links: [文档](../../administration/appearance.md#member-guidelines)

{{< /details >}}

管理员现在可以添加文本指南，这些指南对有权在群组或项目的**成员**页面上管理成员的用户可见。管理员可以在**管理中心**设置中的**外观**部分访问这些指南。

指南对于使用外部工具管理群组或项目成员的团队非常有用。例如，指南可以链接到用户应使用的预定义群组，而不是管理单个成员的成员身份。

感谢 @bufferoverflow 的社区贡献！

<a id="show-import-stats-for-direct-transfer"></a>

### 显示直接迁移的导入统计信息

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: JihuLab.com
- Links: [文档](../../user/group/import/_index.md)

{{< /details >}}

通过直接迁移完成的极狐GitLab 群组和项目的迁移会显示徽章（**完成**、**部分完成**和**失败**），以告知用户迁移的总体最终结果。用户还可以通过单击**查看失败项**链接来访问未导入的项目列表。

然而，对于部分导入的项目，没有快速的方法来了解每种类型的项目有多少成功导入，以及有多少没有导入。

在此版本中，我们为群组和项目添加了导入结果统计信息。要访问统计信息，请在直接迁移历史记录页面上选择**详细信息**链接。

<a id="enable-jira-issues-at-the-group-level"></a>

### 在群组级别启用 Jira 议题

{{< details >}}

- Tier: 专业版，旗舰版
- Offering: JihuLab.com
- Links: [文档](../../integration/jira/configure.md#view-jira-issues)

{{< /details >}}

通过此版本，你可以为极狐GitLab 群组中的所有项目启用 Jira 议题。以前，你只能为每个极狐GitLab 项目单独启用 Jira 议题。

<a id="rest-api-support-for-the-gitlab-for-slack-app"></a>

### 极狐GitLab Slack 应用的 REST API 支持

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: JihuLab.com
- Links: [文档](../../api/group_integrations.md#gitlab-for-slack-app)

{{< /details >}}

在此版本中，我们为极狐GitLab Slack 应用添加了 REST API 支持。

你不能通过 API 创建极狐GitLab Slack 应用。相反，你必须从极狐GitLab UI [安装应用](../../user/project/integrations/gitlab_slack_application.md#install-the-gitlab-for-slack-app)。然后，你可以检索集成设置并更新或禁用项目的应用。

<a id="access-gitlab-usage-data-through-the-rest-api"></a>

### 通过 REST API 访问极狐GitLab 使用数据

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Links: [文档](../../api/usage_data.md#export-service-ping-data)

{{< /details >}}

私有化部署用户现在可以通过 REST API 连接无缝访问服务 Ping 数据，从而促进与下游系统的直接集成。这相对于之前的文件下载方法是一个显著的改进。新方法为私有化部署用户提供了一种更高效、实时的方式来进行定制分析，并从其极狐GitLab 使用数据中获得特定洞察。

<a id="unified-devops-and-security"></a>

## 统一 DevOps 与安全

<a id="authenticate-and-sign-commits-with-ssh-certificates"></a>

### 使用 SSH 证书进行身份验证和签名提交

{{< details >}}

- Tier: Silver, Gold
- Links: [文档](../../user/group/ssh_certificates.md)

{{< /details >}}

以前，JihuLab.com 上的 Git 访问控制选项依赖于用户帐户中设置的凭据。现在，你可以设置一个流程，仅使用 SSH 证书即可实现 Git 访问。你还可以使用这些证书对提交进行签名。

<a id="limit-workspaces-per-user-on-the-gitlab-agent"></a>

### 限制极狐GitLab agent 上每个用户的工作空间数量

{{< details >}}

- Tier: 专业版，旗舰版
- Links: [文档](../../user/workspace/gitlab_agent_configuration.md)

{{< /details >}}

在极狐GitLab 16.8 中，我们为极狐GitLab Kubernetes agent 引入了设置，以限制每个工作空间的 CPU 和内存使用量。

现在，在 16.9 中，你还可以限制每个用户的工作空间数量。有了这个新设置，你可以更好地控制云资源，并防止个别开发人员增加云支出。

<a id="allow-users-to-cleanup-partial-resources-from-failed-deployments"></a>

### 允许用户清理失败部署产生的部分资源

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: JihuLab.com
- Links: [文档](../../ci/environments/_index.md#run-a-pipeline-job-when-environment-is-stopped)

{{< /details >}}

环境 [`auto_stop_in`](../../ci/yaml/_index.md#environmentauto_stop_in) 功能已更新，可从上次完成的流水线而不是上次成功的流水线中运行作业。这避免了由于没有任何成功的流水线而导致自动停止作业无法运行的边缘情况。

在某些情况下，此行为可能被视为重大变更。新行为当前受功能标志控制，并将在 17.0 中成为默认行为，同时，我们将弃用旧行为，并在 18.0 中从极狐GitLab 中移除。我们建议所有人立即开始过渡或配置功能标志，以最大程度地降低在首次 17.x 升级时发生重大变更的风险。

<a id="kubernetes-129-support"></a>

### Kubernetes 1.29 支持

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: JihuLab.com
- Links: [文档](../../user/clusters/agent/_index.md)

{{< /details >}}

此版本增加了对 2023 年 12 月发布的 Kubernetes 版本 1.29 的全面支持。如果你将应用程序部署到 Kubernetes，现在可以将连接的集群升级到最新版本，并利用其所有功能。

你可以阅读有关我们的 Kubernetes 支持政策和其他受支持 Kubernetes 版本的更多信息。

<a id="enterprise-user-email-address-accessible-through-ui-and-api"></a>

### 企业用户电子邮件地址可通过 UI 和 API 访问

{{< details >}}

- Tier: Silver, Gold
- Offering: JihuLab.com
- Links: [文档](../../user/enterprise_user/_index.md)

{{< /details >}}

拥有[企业用户](../../user/enterprise_user/_index.md)的群组所有者现在可以使用用户管理 UI 和[群组及项目成员 API](../../api/group_members.md) 来查看这些用户的电子邮件地址。以前，仅返回经配置的用户的电子邮件地址。

<a id="add-or-remove-service-accounts-from-groups-with-ldap-group-sync"></a>

### 通过 LDAP 群组同步向群组添加或移除服务帐户

{{< details >}}

- Tier: 专业版，旗舰版
- Links: [文档](../../user/group/access_and_permissions.md)

{{< /details >}}

以前，如果一个群组启用了 LDAP 同步，管理员无法邀请或移除该群组中的任何用户。现在，管理员可以使用群组和项目成员 API 邀请服务帐户用户加入启用了 LDAP 同步的群组，或从该群组中移除服务帐户用户。管理员仍然无法邀请人类用户加入或从启用了 LDAP 同步的群组中移除人类用户。这确保了 LDAP 群组同步是人类用户帐户成员身份的唯一真实来源，同时允许灵活地使用服务帐户向 LDAP 同步的群组添加自动化操作。

<a id="audit-event-for-updating-or-deleting-a-custom-role"></a>

### 更新或删除自定义角色的审计事件

{{< details >}}

- Tier: 旗舰版
- Offering: JihuLab.com
- Links: [文档](../../administration/compliance/audit_event_reports.md)

{{< /details >}}

极狐GitLab 现在会在更新或删除自定义角色时记录审计事件。此事件对于识别在权限提升的情况下是否添加或更改了权限非常重要。

<a id="improved-ux-for-expired-saml-sso-sessions"></a>

### 改进 SAML SSO 会话过期的用户体验

{{< details >}}

- Tier: Silver, Gold
- Offering: JihuLab.com
- Links: [文档](../../user/group/saml_sso/_index.md)

{{< /details >}}

如果你属于一个要求进行 SAML SSO 身份验证的群组，但你没有该群组的有效会话，则会显示一个横幅，提示你刷新会话。以前，当会话过期时，议题和合并请求不会显示，但这对于用户来说并不明确。现在，用户可以清楚地知道何时必须重新进行身份验证才能查看所有工作项。

<a id="standards-adherence-report-improvements"></a>

### 标准符合性报告改进

{{< details >}}

- Tier: 旗舰版
- Offering: JihuLab.com
- Links: [文档](../../user/compliance/compliance_center/_index.md)

{{< /details >}}

[合规中心](../../user/compliance/compliance_center/_index.md)内的[标准符合性报告](../../user/compliance/compliance_center/_index.md)是合规团队监控其合规态势的目的地。

在极狐GitLab 16.5 中，我们引入了带有极狐GitLab 标准的报告——这是一组所有合规团队都应监控的通用合规要求。该标准帮助你了解哪些项目满足这些要求，哪些项目未达标，以及如何使其达到合规。随着时间的推移，我们将在报告中引入更多标准。

在此里程碑中，我们进行了一些改进，使报告更加可靠和可操作。这些改进包括：

- 按检查对结果进行分组
- 按项目、检查和标准进行筛选
- 导出为 CSV（通过电子邮件发送）
- 改进的分页功能

<a id="rich-text-editor-broader-availability"></a>

### 富文本编辑器更广泛的可用性

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: JihuLab.com
- Links: [文档](../../user/rich_text_editor.md)

{{< /details >}}

在极狐GitLab 16.2 中，[我们发布了](https://gitlab.cn/releases/2023/07/22/gitlab-16-2-released/) 富文本编辑器，作为纯文本编辑器的替代方案。富文本编辑器提供了一个“所见即所得”的编辑界面，以及一个可扩展的基础，用于进一步的开发。然而，直到此版本，富文本编辑器仅在议题、史诗和合并请求中可用。

从极狐GitLab 16.9 开始，富文本编辑器现在可在以下位置使用：

- 需求描述
- 漏洞发现
- 发布描述
- 设计评论

通过改进对富文本编辑器的访问，你可以更高效地协作，而无需之前的 Markdown 经验。

<a id="allow-duplicate-terraform-modules"></a>

### 允许重复的 Terraform 模块

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Links: [文档](../../user/packages/terraform_module_registry/_index.md#allow-duplicate-terraform-modules)

{{< /details >}}

你可以使用极狐GitLab 软件包仓库来发布和下载 Terraform 模块。默认情况下，你不能在每个项目中多次发布相同的模块名称和版本。

但是，你可能希望允许重复上传，尤其是对于发布版本。在此版本中，极狐GitLab 扩展了软件包仓库的群组设置，以便你可以允许或拒绝重复模块。

<a id="validate-terraform-modules-from-your-group-or-subgroup"></a>

### 验证来自群组或子群组的 Terraform 模块

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Links: [文档](../../user/packages/package_registry/_index.md#view-packages)

{{< /details >}}

使用极狐GitLab Terraform 仓库时，对所有模块进行跨项目查看非常重要。直到最近，用户界面仅在项目级别可用。如果你的群组结构复杂，则可能难以查找和验证模块。

从极狐GitLab 16.9 开始，你可以在极狐GitLab 中查看所有群组和子群组模块。增加的可见性可以让你更好地了解仓库，并降低名称冲突的可能性。

<a id="boards-work-in-progress-line"></a>

### 看板在制品线

{{< details >}}

- Tier: 专业版，旗舰版
- Links: [文档](../../user/project/issue_board.md#work-in-progress-limits)

{{< /details >}}

你现在可以在看板列表中可视化你的在制品限制。当超出限制时，列表中会出现一条指示线，帮助你了解哪些项目超出了限制，并相应地管理列表。

<a id="new-stage-events-for-custom-value-stream-analytics"></a>

### 用于自定义价值流分析的新阶段事件

{{< details >}}

- Tier: 专业版，旗舰版
- Offering: JihuLab.com
- Links: [文档](../../user/group/value_stream_analytics/_index.md#value-stream-stage-events)

{{< /details >}}

为了改进[极狐GitLab 中开发工作流程的跟踪](https://about.gitlab.com/blog/value-stream-total-time-chart/)，价值流分析已扩展了一个新的阶段事件：`Issue first added to iteration`。你可以使用此事件来检测因团队计划过早而缺乏敏捷性或因迭代间有议题叠加而面临执行挑战的团队所导致的问题。例如，你现在可以添加一个“已计划”阶段，该阶段从 `Issue first added to iteration` 开始，到 `Issue first assigned` 结束。

<a id="improvements-to-operational-container-scanning"></a>

### 操作容器扫描的改进

{{< details >}}

- Tier: 旗舰版
- Links: [文档](../../user/clusters/agent/vulnerabilities.md)

{{< /details >}}

我们改进了操作容器扫描 (OCS) 的报告和稳定性。值得注意的是，Trivy 报告大小限制已增加，这为用户提供了更稳定的体验。将 Trivy 报告大小从 10MB 扩大到 100MB，使受报告大小限制约束的客户能够利用 OCS 保护其集群中的容器镜像。

随着对 OCS 的此更改，在 FIPS 模式下运行 `gitlab-agent` 的用户无法运行操作容器扫描。有关更多详细信息，请参见我们的文档，并在议题 [#440849](https://gitlab.com/gitlab-org/gitlab/-/issues/440849) 中提供反馈。

<a id="dast-analyzer-updates"></a>

### DAST 分析器更新

{{< details >}}

- Tier: 旗舰版
- Links: [文档](../../user/application_security/dast/browser/_index.md)

{{< /details >}}

我们在 16.9 发布里程碑期间解决了以下错误：

- 当浏览器转换到新页面时，基于浏览器的 DAST 在尝试获取缓存资源的响应正文时出错。有关更多详细信息，请参见该议题。
- 基于浏览器的 DAST 爬虫任务未并行运行，导致性能下降。有关更多详细信息，请参见该议题。

<a id="updated-sast-rules-for-higher-quality-results"></a>

### 更新的 SAST 规则以获得更高质量的结果

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Links: [文档](../../user/application_security/sast/rules.md#important-rule-changes)

{{< /details >}}

我们已更新了 40 多条默认的极狐GitLab SAST 规则，以：

- 通过更新 C#、Go、Java、JavaScript 和 Python 的检测逻辑规则，提高真阳性结果（正确识别的漏洞）并减少假阴性结果（错误识别的漏洞）。
- 为 C#、Go、Java 和 Python 规则添加 [OWASP 映射](https://gitlab.com/gitlab-org/gitlab/-/issues/438561)。

规则更改包含在基于 Semgrep 的极狐GitLab SAST [分析器](../../user/application_security/sast/analyzers.md) 的更新版本中。
除非你已[将 SAST 分析器固定到特定版本](../../user/application_security/sast/_index.md)，否则此更新将在极狐GitLab 16.0 或更高版本上自动应用。
我们正在[史诗 10907](https://gitlab.com/groups/gitlab-org/-/epics/10907) 中致力于更多 SAST 规则改进。
{{< details >}}

- Tier: 旗舰版
- Links: [文档](../../editor_extensions/visual_studio_code/_index.md) | 相关史诗

{{< /details >}}

我们改进了 [GitLab Workflow 扩展](https://marketplace.visualstudio.com/items?itemName=GitLab.gitlab-workflow#security-findings) 在 Visual Studio Code（VS Code）中安全发现的显示方式。
现在可以看到以前未显示的更多安全发现详情，包括：

- 带有富文本格式的完整描述。
- 漏洞的解决方案（如果有）。
- 指向代码库中问题发生位置的链接。
- 指向所发现漏洞类型更多信息的链接。

我们还：

- 改进了扩展在结果就绪前显示安全扫描状态的方式。
- 进行了其他可用性改进。

<a id="control-which-roles-can-cancel-pipelines-or-jobs"></a>

### 控制可以取消流水线或作业的角色

{{< details >}}

- Tier: 专业版，旗舰版
- Offering: JihuLab.com
- Links: [文档](../../ci/pipelines/settings.md#restrict-roles-that-can-cancel-pipelines-or-jobs) | 相关议题

{{< /details >}}

组织可能希望控制哪些用户角色可以取消流水线。以前，任何能运行流水线的人也都可以取消流水线。现在，项目维护者可以更新一项设置，将流水线和作业的取消权限限制为特定角色，甚至完全禁止取消！

<a id="fleet-dashboard-compute-minutes-used-on-instance-runners-per-project-metric-card"></a>

### 舰队仪表板：每个项目在实例级 Runner 上使用的计算分钟数指标卡片

{{< details >}}

- Tier: 旗舰版
- Links: [文档](../../ci/runners/runner_fleet_dashboard.md) | 相关议题

{{< /details >}}

在大规模管理极狐GitLab Runner 舰队时，您告诉我们，了解哪些项目在 Runner 上消耗的计算分钟最多至关重要。对您来说，这些信息对于帮助团队优化 CI/CD 流水线，以及帮助您做出有关舰队成本优化的正确决策至关重要。

现在，作为之前发布的按 CSV 导出 CI/CD 计算分钟数功能的补充，按项目统计的 Runner 计算用量指标卡片已在 Runner 舰队仪表板中可用。您可以查看消耗实例级 Runner 分钟数的热门项目，以及极狐GitLab 环境中使用最频繁的实例级 Runner。

<a id="gitlab-runner-16-9"></a>

### 极狐GitLab Runner 16.9

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Links: [文档](https://gitlab.cn/docs/runner)

{{< /details >}}

我们今天还将发布极狐GitLab Runner 16.9！极狐GitLab Runner 是轻量级、高扩展性的代理，用于运行您的 CI/CD 作业并将结果返回给极狐GitLab 实例。极狐GitLab Runner 与极狐GitLab CI/CD（极狐GitLab 包含的开源持续集成服务）协同工作。

#### 新增功能

- 使 Kubernetes API 重试可配置

#### 错误修复

- 随机警告：无法删除 ***：目录非空

极狐GitLab Runner 的 [CHANGELOG](https://jihulab.com/gitlab-cn/gitlab-runner/blob/16-9-stable/CHANGELOG.md) 中包含了所有变更的列表。

<a id="show-mr-link-for-branch-based-pipelines"></a>

### 为基于分支的流水线显示合并请求链接

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: JihuLab.com
- Links: [文档](../../ci/pipelines/_index.md#view-pipelines) | 相关议题

{{< /details >}}

如果您使用基于分支的流水线，现在可以从流水线详情页面快速查看和访问相关的合并请求。