---
stage: Release Notes
group: Monthly Release
date: 2023-10-22
title: "极狐GitLab 16.5 发布说明"
description: "极狐GitLab 16.5 发布，包含合规标准符合性报告"
---

<!-- markdownlint-disable -->
<!-- vale off -->

2023 年 10 月 22 日，极狐GitLab 16.5 发布了以下功能。

<a id="primary-features"></a>

## 主要功能

<a id="compliance-standards-adherence-report"></a>

### 合规标准符合性报告

<!-- categories: Compliance Management -->

{{< details >}}

- 适用版本: 旗舰版
- 交付方式: JihuLab.com、私有化部署
- 链接: [文档](../../user/compliance/compliance_center/_index.md)

{{< /details >}}

合规中心现在新增了一个标准符合性报告选项卡。该报告最初包含一项极狐GitLab 最佳实践标准，用于显示您群组中的项目何时未满足该标准中所含检查项的要求。最初显示的三项检查为：

- 存在审批规则，要求合并请求至少有 2 名审批人
- 存在审批规则，不允许合并请求作者进行合并
- 存在审批规则，不允许合并请求的提交者进行合并

该报告包含每个项目各项检查状态的详细信息。它还会向您显示该检查上次运行的时间、该检查适用于哪项标准，以及如何修复报告中可能显示的任何失败或问题。未来的迭代将增加更多检查，并扩大范围以涵盖更多法规和标准。此外，我们还将增加改进功能，以便对报告进行分组和筛选，让您可以专注于对您组织最重要的项目或标准。

<a id="create-rules-to-set-target-branches-for-merge-requests"></a>

### 创建规则以设置合并请求的目标分支

<!-- categories: Code Review Workflow -->

{{< details >}}

- 适用版本: 专业版、旗舰版
- 交付方式: JihuLab.com、私有化部署
- 链接: [文档](../../user/project/repository/branches/_index.md#configure-workflows-for-target-branches)

{{< /details >}}

有些项目使用多个长期分支进行开发，例如 `develop` 和 `qa`。在这些项目中，您可能希望将 `main` 保留为默认分支，因为它代表项目的生产状态。但是，开发工作期望合并请求以 `develop` 或 `qa` 为目标。目标分支规则有助于确保合并请求以适合您项目和开发工作流的分支为目标。

当您创建合并请求时，该规则会检查分支的名称。如果分支名称与规则匹配，合并请求会预先选择您在规则中指定的分支作为目标。如果分支名称不匹配，合并请求会以项目的默认分支为目标。

<a id="resolve-an-issue-thread"></a>

### 解决议题讨论串

<!-- categories: Team Planning -->

{{< details >}}

- 适用版本: 基础版、专业版、旗舰版
- 交付方式: JihuLab.com、私有化部署
- 链接: [文档](../../user/discussions/_index.md#resolve-a-thread) | [相关议题](https://gitlab.com/gitlab-org/gitlab/-/issues/31114)

{{< /details >}}

包含许多讨论串的长期议题可能难以阅读和跟踪。现在，当讨论主题结束时，您可以解决议题上的讨论串。

<a id="fast-forward-merge-trains-with-semi-linear-history"></a>

### 使用半线性历史快进合并列车

<!-- categories: Merge Trains -->

{{< details >}}

- 适用版本: 专业版、旗舰版
- 交付方式: JihuLab.com、私有化部署
- 链接: [文档](../../ci/pipelines/merge_trains.md) | [相关议题](https://gitlab.com/gitlab-org/gitlab/-/issues/26996)

{{< /details >}}

在 16.4 中，我们发布了[快进合并列车](gitlab-16-4-released.md#fast-forward-merge-support-for-merge-trains)，作为延续，我们希望确保支持所有[合并方法](../../user/project/merge_requests/methods/_index.md)。现在，如果您希望确保维护半线性提交历史，可以使用半线性快进合并列车。

<a id="scale-and-deployments"></a>

## 规模与部署

<a id="find-epics-with-advanced-search"></a>

### 使用高级搜索查找史诗

<!-- categories: Global Search -->

{{< details >}}

- 适用版本: 专业版、旗舰版
- 交付方式: JihuLab.com、私有化部署
- 链接: [文档](../../user/search/_index.md) | [相关议题](https://gitlab.com/gitlab-org/gitlab/-/issues/250699)

{{< /details >}}

史诗在极狐GitLab 中越来越受欢迎。此前，查找史诗比其他内容类型要困难一些。在此版本中，当您使用高级搜索时，现在可以搜索并查看史诗的结果。

<a id="omnibus-improvements"></a>

### Omnibus 改进

<!-- categories: Omnibus Package -->

{{< details >}}

- 适用版本: 基础版、专业版、旗舰版
- 交付方式: 私有化部署
- 链接: [文档](https://gitlab.cn/docs/omnibus/)

{{< /details >}}

- 极狐GitLab 16.5 的 `.deb` Linux 软件包[已从 gzip 压缩切换为 xz 压缩](https://gitlab.com/gitlab-org/omnibus-gitlab/-/issues/8197)，
从而使软件包体积更小。此更改可能会导致安装期间解包时间变慢。
- 极狐GitLab 16.5 包含 [Mattermost 9.0](https://docs.mattermost.com/install/self-managed-changelog.html#release-v9-0-major-release)。
此版本移除了已弃用的 Insights 功能，并且
[Mattermost Boards 和各种插件已转为社区支持](https://forum.mattermost.com/t/upcoming-product-changes-to-boards-and-various-plugins/16669)。
- 极狐GitLab 16.5 [移动了极狐GitLab SELinux 策略模块](https://gitlab.com/gitlab-org/omnibus-gitlab/-/merge_requests/7165)，
从 `/opt/gitlab/embedded/selinux/rhel/7/` 移动到 `/opt/gitlab/embedded/selinux`，以反映该模块并非仅适用于 RHEL 7。

<a id="reviewer-information-for-merge-requests-in-the-jira-development-panel"></a>

### Jira 开发面板中合并请求的审核人信息

<!-- categories: Settings -->

{{< details >}}

- 适用版本: 基础版、专业版、旗舰版
- 交付方式: JihuLab.com、私有化部署
- 链接: [文档](../../integration/jira/development_panel.md#information-displayed-in-the-development-panel) | [相关议题](https://gitlab.com/gitlab-org/gitlab/-/issues/364273)

{{< /details >}}

借助 [GitLab for Jira Cloud 应用](../../integration/jira/connect-app.md)，您可以连接极狐GitLab 和 Jira Cloud，以实时同步开发信息。您可以在 Jira 开发面板中查看此信息。
此前，当审核人被指派到合并请求时，审核人信息不会显示在 Jira 开发面板中。在此版本中，当您使用 GitLab for Jira Cloud 应用时，审核人的姓名、电子邮件和审批状态会显示在 Jira 开发面板中。

<a id="changing-context-just-got-easier"></a>

### 切换上下文变得更轻松

<!-- categories: Navigation -->

{{< details >}}

- 适用版本: 基础版、专业版、旗舰版
- 交付方式: 私有化部署
- 链接: [文档](../../tutorials/left_sidebar/_index.md)

{{< /details >}}

我们收到了您的反馈，指出在左侧边栏中很难找到搜索按钮，也很难在项目和偏好设置等内容之间切换。在此版本中，我们使该按钮更加醒目。这有助于提高可发现性，并将工作流整合到单一触点。

您可以通过选择**搜索或跳转到…** 按钮来试用，或使用键盘快捷键输入 / 或 s。

<a id="webhook-now-triggered-when-a-release-is-deleted"></a>

### 删除发布时现在会触发 Webhook

<!-- categories: Notifications -->

{{< details >}}

- 适用版本: 基础版、专业版、旗舰版
- 交付方式: JihuLab.com、私有化部署
- 链接: [文档](../../user/project/integrations/webhook_events.md#release-events) | [相关议题](https://gitlab.com/gitlab-org/gitlab/-/issues/418113)

{{< /details >}}

您可以使用发布事件来监控发布对象并对更改做出响应。此前，只有在创建或更新发布时才会触发 Webhook。在受到严格监管的行业中，删除发布是一项必须监控和跟进的关键事件。在极狐GitLab 16.5 中，删除发布时现在也会触发 Webhook。

<a id="redesigned-service-desk-issues-list"></a>

### 重新设计的服务台议题列表

<!-- categories: Service Desk -->

{{< details >}}

- 适用版本: 基础版、专业版、旗舰版
- 交付方式: 私有化部署
- 链接: [文档](../../user/project/service_desk/using_service_desk.md)

{{< /details >}}

我们重新设计了服务台议题列表，使其加载更快、更流畅。它现在与常规议题列表更加一致。可用功能包括：

- 与议题列表相同的排序和排列选项。
- 相同的筛选器，包括 OR 运算符和按议题 ID 筛选。

<a id="geo-adds-bulk-resync-and-reverify-buttons-for-all-components"></a>

### Geo 为所有组件添加批量重新同步和重新验证按钮

<!-- categories: Geo Replication, Disaster Recovery -->

{{< details >}}

- 适用版本: 专业版、旗舰版
- 交付方式: 私有化部署
- 链接: [文档](../../administration/geo/_index.md) | [相关史诗](https://gitlab.com/groups/gitlab-org/-/epics/8212)

{{< /details >}}

现在，您可以通过 Geo 管理 UI 中的按钮，为 Geo 管理的任何数据组件触发批量重新同步或重新验证。选择该按钮将对与相应组件相关的所有数据项应用该操作。此前，这只能通过登录 Rails 控制台来实现。这些操作现在更易于访问，并且排查故障以及应用需要完全重新同步或重新验证特定组件（例如移动存储位置）的大规模更改的体验也得到了改善。

<a id="back-up-and-restore-repository-data-in-the-cloud"></a>

### 在云中备份和恢复代码仓库数据

<!-- categories: Gitaly, Backup/Restore of GitLab instances -->

{{< details >}}

- 适用版本: 基础版、专业版、旗舰版
- 交付方式: 私有化部署
- 链接: [文档](../../administration/backup_restore/backup_gitlab.md#create-server-side-repository-backups) | [相关史诗](https://gitlab.com/groups/gitlab-org/-/epics/10826)

{{< /details >}}

极狐GitLab 备份和恢复功能现在支持将代码仓库数据存储在对象存储中。此更新通过消除用于创建大型 tarball 的中间步骤（这些 tarball 需要手动存储在适当位置）来提高性能。

通过此更新，代码仓库备份会存储在您选择的对象存储位置（Amazon S3、Google Cloud Storage、Azure Cloud Data Storage、MinIO 等）。此更改消除了手动将数据移出 Gitaly 实例的需要。

<a id="unified-devops-and-security"></a>

## 统一 DevOps 与安全

<a id="integrate-deployment-approval-and-approval-rule-changes-into-audit-events"></a>

### 将部署审批和审批规则更改集成到审计事件中

<!-- categories: Environment Management -->

{{< details >}}

- 适用版本: 专业版、旗舰版
- 交付方式: JihuLab.com、私有化部署
- 链接: [文档](../../user/compliance/audit_event_types.md#environment-management) | [相关议题](https://gitlab.com/gitlab-org/gitlab/-/issues/415603)

{{< /details >}}

在受到严格监管的行业中，部署是合规的核心主题。在之前的版本中，部署审批不属于审计事件，这使得很难判断审批规则何时以及如何发生变化。

极狐GitLab 现在提供了一组新的审计事件，用于部署审批和审批规则更改。当部署审批规则发生变化，或受保护环境的审批规则发生变化时，这些事件会触发。

<a id="use-the-api-to-delete-a-users-saml-and-scim-identities"></a>

### 使用 API 删除用户的 SAML 和 SCIM 身份

<!-- categories: User Management -->

{{< details >}}

- 交付方式: JihuLab.com
- 链接: [文档](../../api/scim.md#delete-a-single-scim-identity) | [相关议题](https://gitlab.com/gitlab-org/gitlab/-/issues/423592)

{{< /details >}}

此前，群组所有者无法以编程方式删除 SAML 或 SCIM 身份。这使得排查用户预配和登录过程中的问题变得困难。现在，群组所有者可以使用新的端点来删除这些身份。

感谢 [jgao1025](https://gitlab.com/jgao1025)的贡献！

<a id="export-the-compliance-violations-report"></a>

### 导出合规违规报告

<!-- categories: Compliance Management -->

{{< details >}}

- 适用版本: 旗舰版
- 交付方式: JihuLab.com、私有化部署
- 链接: [文档](../../user/compliance/compliance_center/_index.md)

{{< /details >}}

合规违规报告可能包含大量信息。此前，您只能在极狐GitLab UI 中查看这些信息。这对于单个议题来说没问题，但如果您需要执行以下操作，可能会比较棘手，例如：

- 为某个发布创建当前合规状态的产物。例如，向审计员证明违规数为 0。
- 将数据与另一个数据集聚合，或在另一个工具中处理它。

在极狐GitLab 16.5 中，您现在可以以 CSV 格式导出合规违规报告中包含的条目列表。

<a id="new-customizable-permissions"></a>

### 新的可自定义权限

<!-- categories: User Management -->

{{< details >}}

- 适用版本: 旗舰版
- 交付方式: JihuLab.com、私有化部署
- 链接: [文档](../../user/custom_roles/_index.md) | [相关议题](https://gitlab.com/gitlab-org/gitlab/-/issues/17364)

{{< /details >}}

管理群组成员和项目访问令牌的权限已添加到自定义角色框架中。您可以将这些权限添加到任何基础角色以创建自定义角色。通过创建仅包含完成特定任务集所需权限的自定义角色，您就不必不必要地将维护者和所有者等高权限角色分配给用户。

<a id="instance-level-audit-event-streaming-to-google-cloud-logging"></a>

### 实例级审计事件流式传输到 Google Cloud Logging

<!-- categories: Audit Events -->

{{< details >}}

- 适用版本: 旗舰版
- 交付方式: 私有化部署
- 链接: [文档](../../administration/compliance/audit_event_reports.md) | [相关史诗](https://gitlab.com/groups/gitlab-org/-/epics/11061)

{{< /details >}}

此前，您只能为 Google Cloud Logging 配置顶级群组流式审计事件。

在极狐GitLab 16.5 中，我们将 Google Cloud Logging 的支持扩展到了实例级流式传输目标。

<a id="configurable-locked-user-policy"></a>

### 可配置的锁定用户策略

<!-- categories: System Access -->

{{< details >}}

- 适用版本: 基础版、专业版、旗舰版
- 交付方式: 私有化部署
- 链接: [文档](../../security/unlock_user.md) | [相关议题](https://gitlab.com/gitlab-org/gitlab/-/issues/27048)

{{< /details >}}

管理员现在可以通过选择登录失败次数以及用户被锁定的时长，为其实例配置锁定用户策略。例如，五次登录失败会将用户锁定 60 分钟。这使管理员能够定义满足其安全和合规需求的锁定用户策略。此前，登录尝试次数和用户锁定时长不可配置。

<a id="activate-and-deactivate-headers-for-streaming-audit-events"></a>

### 为流式审计事件激活和停用请求头

<!-- categories: Audit Events -->

{{< details >}}

- 适用版本: 旗舰版
- 交付方式: JihuLab.com、私有化部署
- 链接: [文档](../../administration/compliance/audit_event_reports.md) | [相关议题](https://gitlab.com/groups/gitlab-org/-/epics/11109)

{{< /details >}}

此前，您必须删除添加到审计事件流式传输目标的 HTTP 请求头，即使您只是想暂时停用它们。

在极狐GitLab 16.5 中，您可以使用极狐GitLab UI 中的**活跃**复选框来单独开启和关闭每个请求头。您可以使用它来：

- 测试不同的请求头。
- 暂时停用某个请求头。
- 在同一请求头的两个版本之间切换。

<a id="api-to-create-pat-for-currently-authenticated-user"></a>

### 为当前已认证用户创建 PAT 的 API

<!-- categories: System Access -->

{{< details >}}

- 适用版本: 基础版、专业版、旗舰版
- 交付方式: 私有化部署
- 链接: [文档](../../api/users.md) | [相关议题](https://gitlab.com/gitlab-org/gitlab/-/issues/425171)

{{< /details >}}

您现在可以使用位于 `user/personal_access_tokens`的新 REST API 端点，为当前已认证用户创建新的个人访问令牌。出于安全原因，此令牌的作用域仅限于 `k8s_proxy`，因此您只能使用它通过极狐GitLab Kubernetes Agent 执行 Kubernetes API 调用。此前，只有实例管理员才能[通过 API 创建个人访问令牌](../../api/users.md)。

<a id="vulnerability-report-grouping-by-status-and-severity"></a>

### 按状态和严重性对漏洞报告进行分组

<!-- categories: Vulnerability Management -->

{{< details >}}

- 适用版本: 旗舰版
- 交付方式: JihuLab.com、私有化部署
- 链接: [文档](../../user/application_security/vulnerability_report/_index.md#group-vulnerabilities) | [相关史诗](https://gitlab.com/groups/gitlab-org/-/epics/10164)

{{< /details >}}

作为用户，您需要能够对漏洞进行分组，以便更高效地排查漏洞。在此版本中，您可以按严重性或状态进行分组。这将帮助您更好地回答诸如某个群组或项目中有多少已确认漏洞，或还有多少漏洞需要排查等问题。

<a id="export-individual-wiki-pages-as-pdf"></a>

### 将单个 Wiki 页面导出为 PDF

<!-- categories: Wiki -->

{{< details >}}

- 适用版本: 基础版、专业版、旗舰版
- 交付方式: JihuLab.com、私有化部署
- 链接: [文档](../../user/project/wiki/_index.md#export-a-wiki-page) | [相关议题](https://gitlab.com/gitlab-org/gitlab/-/issues/414691)

{{< /details >}}

从极狐GitLab 16.5 开始，您可以将单个 Wiki 页面导出为 PDF 文件。现在，分享团队知识变得更加无缝。将 Wiki 导出为 PDF 可用于多种用例。例如，提供保存在 Wiki 中的技术文档副本，或与项目状态一起分享 Wiki 中的信息。不再需要借助替代工具将 Markdown 文件转换为 PDF，因为在某些组织中，使用这些工具是被禁止的，这又带来了另一个挑战。感谢极狐贡献此功能！

<a id="add-a-child-task-objective-or-key-result-with-a-quick-action"></a>

### 使用快速操作添加子任务、目标或关键结果

<!-- categories: Portfolio Management -->

{{< details >}}

- 适用版本: 基础版、专业版、旗舰版
- 交付方式: JihuLab.com、私有化部署
- 链接: [文档](../../user/project/quick_actions.md) | [相关议题](https://gitlab.com/gitlab-org/gitlab/-/issues/420797)

{{< /details >}}

您现在可以使用 `/add_child` 快速操作为任务、目标或关键结果添加子项。

<a id="linked-items-widget-in-tasks-objectives-and-key-results"></a>

### 任务、目标和关键结果中的已链接项小组件

<!-- categories: Portfolio Management -->

{{< details >}}

- 适用版本: 基础版、专业版、旗舰版
- 交付方式: JihuLab.com、私有化部署
- 链接: [文档](../../user/okrs.md#linked-items-in-okrs) | [相关议题](https://gitlab.com/gitlab-org/gitlab/-/issues/416558)

{{< /details >}}

在此版本中，您可以将[任务](../../user/tasks.md#linked-items-in-tasks)和 [OKR](../../user/okrs.md#linked-items-in-okrs) 链接为“相关”、“被阻塞”或“阻塞”，以在依赖和相关工作项之间提供可追溯性。

当我们将[史诗](https://gitlab.com/groups/gitlab-org/-/epics/9290)和[议题](https://gitlab.com/groups/gitlab-org/-/epics/9584)迁移到工作项框架时，您将能够跨所有这些类型进行链接。

<a id="set-a-parent-for-a-task-objective-or-key-result-with-a-quick-action"></a>

### 使用快速操作为任务、目标或关键结果设置父项

<!-- categories: Portfolio Management -->

{{< details >}}

- 适用版本: 基础版、专业版、旗舰版
- 交付方式: JihuLab.com、私有化部署
- 链接: [文档](../../user/project/quick_actions.md) | [相关议题](https://gitlab.com/gitlab-org/gitlab/-/issues/420798)

{{< /details >}}

您现在可以使用 `/set_parent` 快速操作为任务、目标或关键结果设置父项。

<a id="dast-analyzer-updates"></a>

### DAST 分析器更新

<!-- categories: DAST -->

{{< details >}}

- 适用版本: 旗舰版
- 交付方式: 私有化部署
- 链接: [文档](../../user/application_security/dast/browser/checks/_index.md) | [相关史诗](https://gitlab.com/groups/gitlab-org/-/epics/11426)

{{< /details >}}

在 16.5 发布里程碑期间，我们为基于浏览器的 DAST 默认启用了以下主动检查：

- 检查 78.1 取代 ZAP 检查 90020，用于识别命令注入，攻击者可通过在目标应用服务器上执行任意操作系统命令来利用该漏洞。这是一个严重漏洞，可能导致整个系统被攻陷。
- 检查 611.1 取代 ZAP 检查 90023，用于识别外部 XML 实体注入 (XXE)，攻击者可通过使应用程序的 XML 解析器包含外部资源来利用该漏洞。
- 检查 94.4 取代 ZAP 检查 90019，用于识别“服务器端代码注入 (NodeJS)”，攻击者可通过注入要在服务器上执行的任意 JavaScript 代码来利用该漏洞。
- 检查 113.1 取代 ZAP 检查 40003，用于识别“HTTP 请求头中 CRLF 序列的不当中和（‘HTTP 响应拆分’）”，攻击者可通过插入回车/换行 (CRLF) 字符将任意数据注入 HTTP 响应来利用该漏洞。

<a id="make-jobs-api-endpoint-rate-limit-configurable"></a>

### 使作业 API 端点速率限制可配置

<!-- categories: Continuous Integration (CI) -->

{{< details >}}

- 适用版本: 基础版、专业版、旗舰版
- 交付方式: JihuLab.com、私有化部署
- 链接: [文档](../../administration/settings/user_and_ip_rate_limits.md#maximum-authenticated-requests-to-projectidjobs-per-minute) | [相关议题](https://gitlab.com/gitlab-org/gitlab/-/issues/395702)

{{< /details >}}

最近为 `project/:id/jobs` API 端点添加了速率限制，默认值为每用户每分钟 600 个请求。作为后续迭代，我们正在使此限制可配置，使实例管理员能够设置最符合其要求的限制。

<a id="gitlab-runner-165"></a>

### 极狐GitLab Runner 16.5

<!-- categories: GitLab Runner Core -->

{{< details >}}

- 适用版本: 基础版、专业版、旗舰版
- 交付方式: 私有化部署
- 链接: [文档](https://gitlab.cn/docs/runner/)

{{< /details >}}

我们今天还发布了极狐GitLab Runner 16.5！极狐GitLab Runner 是轻量级、高度可扩展的代理，用于运行您的 CI/CD 作业并将结果发送回极狐GitLab 实例。极狐GitLab Runner 与极狐GitLab CI/CD 协同工作，后者是极狐GitLab 中包含的开源持续集成服务。

<a id="whats-new"></a>

#### 新增功能

- [GitLab Runner 用于 AWS EC2 实例的 fleeting 插件 - 测试版](https://gitlab.com/gitlab-org/gitlab-runner/-/issues/29404)

<a id="bug-fixes"></a>

#### 缺陷修复

- [终止 runner manager 的 k8s pod 会导致工作进程 pod 成为孤立资源](https://gitlab.com/gitlab-org/gitlab/-/issues/390645)
- [GitLab Runner 15.8.0 无法检出包含特殊字符的分支](https://gitlab.com/gitlab-org/gitlab-runner/-/issues/29606)
- [GitLab Runner 在 arm64 计算主机上拉取 x86-64 辅助镜像，而不是 arm64 辅助镜像](https://gitlab.com/gitlab-org/gitlab-runner/-/issues/27768)

所有更改的列表位于极狐GitLab Runner [CHANGELOG](https://gitlab.com/gitlab-org/gitlab-runner/blob/16-5-stable/CHANGELOG.md)中。
