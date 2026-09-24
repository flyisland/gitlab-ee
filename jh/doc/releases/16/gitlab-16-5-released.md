---
stage: Release Notes
group: Monthly Release
date: 2023-10-22
title: "极狐GitLab 16.5 发布说明"
description: "GitLab 16.5 released with Compliance standards adherence report"
---

<!-- markdownlint-disable -->
<!-- vale off -->

2023 年 10 月 22 日，极狐GitLab 16.5 发布了以下功能。

<a id="primary-features"></a>

## 主要功能

<a id="compliance-standards-adherence-report"></a>

### 合规标准遵循报告

{{< details >}}

- Tier: 旗舰版
- Offering: JihuLab.com
- Links: [Documentation](../../user/compliance/compliance_center/_index.md)

{{< /details >}}

合规中心现在新增了一个标准遵循报告选项卡。该报告最初包含极狐GitLab 最佳实践标准，显示群组中的项目何时未满足标准中包含的检查要求。最初显示的三个检查是：

- 存在要求合并请求至少需要 2 名审批者的审批规则
- 存在禁止合并请求作者合并的审批规则
- 存在禁止合并请求提交者合并的审批规则

该报告包含每个项目每项检查状态的详细信息。它还会显示检查上次运行的时间、检查适用的标准，以及如何修复报告中可能显示的任何失败或问题。未来的迭代将添加更多检查，并扩大范围以包含更多法规和标准。此外，我们将增加对报告进行分组和过滤的改进，以便您可以专注于对组织最重要的项目或标准。

<a id="create-rules-to-set-target-branches-for-merge-requests"></a>

### 创建规则以为合并请求设置目标分支

{{< details >}}

- Tier: 专业版，旗舰版
- Offering: JihuLab.com
- Links: [Documentation](../../user/project/repository/branches/_index.md#configure-workflows-for-target-branches)

{{< /details >}}

一些项目使用多个长期分支进行开发，例如 `develop` 和 `qa`。在这些项目中，您可能希望将 `main` 保留为默认分支，因为它代表项目的生产状态。然而，开发工作期望合并请求的目标是 `develop` 或 `qa`。目标分支规则有助于确保合并请求针对适合您项目和开发工作流程的分支。

当您创建合并请求时，规则会检查分支的名称。如果分支名称与规则匹配，则合并请求会预选您在规则中指定的分支作为目标。如果分支名称不匹配，则合并请求以项目的默认分支为目标。

<a id="resolve-an-issue-thread"></a>

### 解决议题讨论串

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: JihuLab.com
- Links: [Documentation](../../user/discussions/_index.md#resolve-a-thread) | [Related issue](https://jihulab.com/gitlab-cn/gitlab/-/issues/31114)

{{< /details >}}

包含许多讨论串的长期议题可能难以阅读和跟踪。现在，当讨论主题结束时，您可以解决议题上的讨论串。

<a id="fast-forward-merge-trains-with-semi-linear-history"></a>

### 具有半线性历史的快进合并队列

{{< details >}}

- Tier: 专业版，旗舰版
- Offering: JihuLab.com
- Links: [Documentation](../../ci/pipelines/merge_trains.md) | [Related issue](https://jihulab.com/gitlab-cn/gitlab/-/issues/26996)

{{< /details >}}

在 16.4 中，我们发布了[快进合并队列](https://gitlab.cn/releases/2023/09/22/gitlab-16-4-released/#fast-forward-merge-support-for-merge-trains)，作为延续，我们希望确保支持所有[合并方法](../../user/project/merge_requests/methods/_index.md)。现在，如果您想确保半线性提交历史得以保持，可以使用半线性快进合并队列。

<a id="scale-and-deployments"></a>

## 规模化与部署

<a id="find-epics-with-advanced-search"></a>

### 使用高级搜索查找史诗

{{< details >}}

- Tier: 专业版，旗舰版
- Offering: JihuLab.com
- Links: [Documentation](../../user/search/_index.md) | [Related issue](https://jihulab.com/gitlab-cn/gitlab/-/issues/250699)

{{< /details >}}

史诗在极狐GitLab 中的受欢迎程度持续增长。以前，查找史诗比其他内容类型稍微困难一些。在此版本中，您现在可以在使用高级搜索时搜索并查看史诗的结果。

<a id="omnibus-improvements"></a>

### Omnibus 改进

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Links: [Documentation](https://gitlab.cn/docs/omnibus)

{{< /details >}}

- 极狐GitLab 16.5 的 `.deb` Linux 软件包已[从 gzip 切换到 xz 压缩](https://jihulab.com/gitlab-cn/omnibus-gitlab/-/issues/8197)，从而减小了软件包大小。此更改可能会导致安装期间解包速度变慢。
- 极狐GitLab 16.5 包含 [Mattermost 9.0](https://docs.mattermost.com/install/self-managed-changelog.html#release-v9-0-major-release)。此版本删除了已弃用的 Insights 功能，并且 [Mattermost Boards 和各种插件已过渡到社区支持](https://forum.mattermost.com/t/upcoming-product-changes-to-boards-and-various-plugins/16669)。
- 极狐GitLab 16.5 [将 GitLab SELinux 策略模块](https://jihulab.com/gitlab-cn/omnibus-gitlab/-/merge_requests/7165)从 `/opt/gitlab/embedded/selinux/rhel/7/` 移动到 `/opt/gitlab/embedded/selinux`，以反映该模块不仅适用于 RHEL 7。

<a id="reviewer-information-for-merge-requests-in-the-jira-development-panel"></a>

### Jira 开发面板中合并请求的审查者信息

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: JihuLab.com
- Links: [Documentation](../../integration/jira/development_panel.md#information-displayed-in-the-development-panel) | [Related issue](https://jihulab.com/gitlab-cn/gitlab/-/issues/364273)

{{< /details >}}

通过[适用于 Jira Cloud 的极狐GitLab 应用](../../integration/jira/connect-app.md)，您可以连接极狐GitLab 和 Jira Cloud，以实时同步开发信息。您可以在 Jira 开发面板中查看这些信息。以前，当为合并请求分配审查者时，审查者信息不会显示在 Jira 开发面板中。在此版本中，当您使用适用于 Jira Cloud 的极狐GitLab 应用时，审查者姓名、电子邮件和审批状态会显示在 Jira 开发面板中。

<a id="changing-context-just-got-easier"></a>

### 切换上下文变得更简单

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Links: [Documentation](../../tutorials/left_sidebar/_index.md)

{{< /details >}}

我们听到了您的反馈，在左侧边栏中，很难找到搜索按钮以及在项目和偏好设置等内容之间进行切换。在此版本中，我们使按钮更加突出。这有助于提高可发现性，并将工作流程简化为单一接触点。

您可以尝试选择 **搜索或跳转到…** 按钮，或使用键盘快捷键输入 / 或 s。

<a id="webhook-now-triggered-when-a-release-is-deleted"></a>

### 删除发布时现可触发 Webhook

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: JihuLab.com
- Links: [Documentation](../../user/project/integrations/webhook_events.md#release-events) | [Related issue](https://jihulab.com/gitlab-cn/gitlab/-/issues/418113)

{{< /details >}}

您可以使用发布事件来监控发布对象并对更改做出反应。以前，只有在创建或更新发布时才会触发 Webhook。在受到严格监管的行业中，删除发布是一个必须监控和跟进的关键事件。在极狐GitLab 16.5 中，删除发布时现也会触发 Webhook。

<a id="redesigned-service-desk-issues-list"></a>

### 重新设计的 Service Desk 议题列表

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Links: [Documentation](../../user/project/service_desk/using_service_desk.md)

{{< /details >}}

我们重新设计了 Service Desk 议题列表，使其加载更快、更流畅。它现在更接近常规议题列表。可用功能包括：

- 与议题列表相同的排序和排序选项。
- 相同的过滤器，包括 OR 运算符和按议题 ID 过滤。

<a id="geo-adds-bulk-resync-and-reverify-buttons-for-all-components"></a>

### Geo 为所有组件添加批量重新同步和重新验证按钮

{{< details >}}

- Tier: 专业版，旗舰版
- Links: [Documentation](../../administration/geo/_index.md) | [Related epic](https://jihulab.com/groups/gitlab-cn/-/epics/8212)

{{< /details >}}

您现在可以通过 Geo 管理 UI 中的按钮，为 Geo 管理的任何数据组件触发批量重新同步或重新验证。选择按钮将对该组件相关的所有数据项应用操作。以前，这只能通过登录 Rails 控制台来实现。这些操作现在更容易访问，并且改进了故障排除和应用需要完全重新同步或重新验证特定组件（例如移动存储位置）的大规模更改的体验。

<a id="back-up-and-restore-repository-data-in-the-cloud"></a>

### 在云端备份和恢复仓库数据

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Links: [Documentation](../../administration/backup_restore/backup_gitlab.md#create-server-side-repository-backups) | [Related epic](https://jihulab.com/groups/gitlab-cn/-/epics/10826)

{{< /details >}}

极狐GitLab 备份和恢复功能现在支持将仓库数据存储在对象存储中。此更新通过消除用于创建大型 tarball 的中间步骤来提高性能，该 tarball 需要手动存储在适当的位置。

通过此更新，仓库备份将存储在您选择的对象存储位置（Amazon S3、Google Cloud Storage、Azure Cloud Data Storage、MinIO 等）。此更改消除了手动将数据从 Gitaly 实例移出的需要。

<a id="unified-devops-and-security"></a>

## 统一的 DevOps 与安全

<a id="integrate-deployment-approval-and-approval-rule-changes-into-audit-events"></a>

### 将部署审批和审批规则更改集成到审计事件中

{{< details >}}

- Tier: 专业版，旗舰版
- Offering: JihuLab.com
- Links: [Documentation](../../user/compliance/audit_event_types.md#environment-management) | [Related issue](https://jihulab.com/gitlab-cn/gitlab/-/issues/415603)

{{< /details >}}

在受监管行业中的部署是合规性的核心主题。在之前的版本中，部署审批不是审计事件的一部分，这使得难以判断审批规则何时以及如何更改。

极狐GitLab 现在提供了一组新的审计事件，用于部署审批和审批规则更改。当部署审批规则更改或受保护环境的审批规则更改时，这些事件会触发。

<a id="use-the-api-to-delete-a-users-saml-and-scim-identities"></a>

### 使用 API 删除用户的 SAML 和 SCIM 身份

{{< details >}}

- Tier: 白银版，黄金版
- Offering: JihuLab.com
- Links: [Documentation](../../api/scim.md#delete-a-single-scim-identity) | [Related issue](https://jihulab.com/gitlab-cn/gitlab/-/issues/423592)

{{< /details >}}

以前，群组所有者无法通过编程方式删除 SAML 或 SCIM 身份。这使得解决用户配置和登录过程中的问题变得困难。现在，群组所有者可以使用新的端点来删除这些身份。

感谢 [jgao1025](https://gitlab.com/jgao1025) 的贡献！

<a id="export-the-compliance-violations-report"></a>

### 导出合规违规报告

{{< details >}}

- Tier: 旗舰版
- Offering: JihuLab.com
- Links: [Documentation](../../user/compliance/compliance_center/_index.md)

{{< /details >}}

合规违规报告可能包含大量信息。以前，您只能在极狐GitLab UI 中查看信息。这对于个别议题来说没问题，但如果您需要，例如：

- 为发布创建当前合规状态的人工制品。例如，向审计员证明违规次数为 0。
- 将数据与另一个数据集聚合或在另一个工具中处理它。

在极狐GitLab 16.5 中，您现在可以将合规违规报告中包含的项目列表导出为 CSV 格式。

<a id="new-customizable-permissions"></a>

### 新的可自定义权限

{{< details >}}

- Tier: 旗舰版
- Offering: JihuLab.com
- Links: [Documentation](../../user/custom_roles/_index.md) | [Related issue](https://jihulab.com/gitlab-cn/gitlab/-/issues/17364)

{{< /details >}}

管理群组成员和项目访问令牌的权限已添加到自定义角色框架中。您可以将这些权限添加到任何基础角色以创建自定义角色。通过创建仅具有完成特定任务所需权限的自定义角色，您无需不必要地将维护者和所有者等高权限角色分配给用户。

<a id="instance-level-audit-event-streaming-to-google-cloud-logging"></a>

### 实例级审计事件流式传输到 Google Cloud Logging

{{< details >}}

- Tier: 旗舰版
- Links: [Documentation](../../administration/compliance/audit_event_reports.md) | [Related epic](https://jihulab.com/groups/gitlab-cn/-/epics/11061)

{{< /details >}}

以前，您只能为 Google Cloud Logging 配置顶级群组流式传输审计事件。

在极狐GitLab 16.5 中，我们扩展了对 Google Cloud Logging 的支持，使其适用于实例级流式传输目标。

<a id="configurable-locked-user-policy"></a>

### 可配置的锁定用户策略

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Links: [Documentation](../../security/unlock_user.md) | [Related issue](https://jihulab.com/gitlab-cn/gitlab/-/issues/27048)

{{< /details >}}

管理员现在可以通过选择登录失败尝试次数以及用户锁定的时长来为其实例配置锁定用户策略。例如，五次登录失败尝试将锁定用户 60 分钟。这使管理员能够定义满足其安全和合规需求的锁定用户策略。以前，登录尝试次数和锁定用户时间段是不可配置的。

<a id="activate-and-deactivate-headers-for-streaming-audit-events"></a>

### 激活和停用流式传输审计事件的标头

{{< details >}}

- Tier: 旗舰版
- Offering: JihuLab.com
- Links: [Documentation](../../administration/compliance/audit_event_reports.md) | [Related issue](https://jihulab.com/groups/gitlab-cn/-/epics/11109)

{{< /details >}}

以前，即使您只想暂时停用，也必须删除添加到审计事件流式传输目标的 HTTP 标头。

在极狐GitLab 16.5 中，您可以使用极狐GitLab UI 中的 **Active** 复选框单独打开或关闭每个标头。您可以使用它来：

- 测试不同的标头。
- 暂时停用标头。
- 在同一标头的两个版本之间切换。

<a id="api-to-create-pat-for-currently-authenticated-user"></a>

### 为当前认证用户创建 PAT 的 API

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Links: [Documentation](../../api/users.md) | [Related issue](https://jihulab.com/gitlab-cn/gitlab/-/issues/425171)

{{< /details >}}

您现在可以使用位于 `user/personal_access_tokens` 的新 REST API 端点为当前认证用户创建新的个人访问令牌。出于安全原因，此令牌的范围仅限于 `k8s_proxy`，因此您只能使用它通过 Kubernetes 代理执行 Kubernetes API 调用。以前，只有实例管理员才能[通过 API 创建个人访问令牌](../../api/users.md)。

<a id="vulnerability-report-grouping-by-status-and-severity"></a>

### 按状态和严重性对漏洞报告进行分组

{{< details >}}

- Tier: 旗舰版
- Offering: JihuLab.com
- Links: [Documentation](../../user/application_security/vulnerability_report/_index.md#group-vulnerabilities) | [Related epic](https://jihulab.com/groups/gitlab-cn/-/epics/10164)

{{< /details >}}

作为用户，您需要能够对漏洞进行分组，以便更有效地对漏洞进行分类。在此版本中，您可以按严重性或状态进行分组。这将帮助您更好地回答诸如群组或项目中有多少已确认的漏洞，或者还有多少漏洞需要分类等问题。

<a id="export-individual-wiki-pages-as-pdf"></a>

### 将单个 Wiki 页面导出为 PDF

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: JihuLab.com
- Links: [Documentation](../../user/project/wiki/_index.md#export-a-wiki-page) | [Related issue](https://jihulab.com/gitlab-cn/gitlab/-/issues/414691)

{{< /details >}}

从极狐GitLab 16.5 开始，您可以将单个 Wiki 页面导出为 PDF 文件。现在，共享团队知识变得更加无缝。将 Wiki 导出为 PDF 可用于多种用例。例如，提供保存在 Wiki 中的技术文档副本，或共享 Wiki 中的项目状态信息。不再需要使用替代工具将 Markdown 文件转换为 PDF，因为在某些组织中，使用这些工具是被禁止的，这又带来了另一个挑战。感谢极狐贡献此功能！

<a id="add-a-child-task-objective-or-key-result-with-a-quick-action"></a>

### 使用快速操作添加子任务、目标或关键结果

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: JihuLab.com
- Links: [Documentation](../../user/project/quick_actions.md) | [Related issue](https://jihulab.com/gitlab-cn/gitlab/-/issues/420797)

{{< /details >}}

您现在可以通过使用 `/add_child` 快速操作，为任务、目标或关键结果添加子项。

<a id="linked-items-widget-in-tasks-objectives-and-key-results"></a>

### 任务、目标和关键结果中的关联项小组件

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: JihuLab.com
- Links: [Documentation](../../user/okrs.md#linked-items-in-okrs) | [Related issue](https://jihulab.com/gitlab-cn/gitlab/-/issues/416558)

{{< /details >}}

在此版本中，您可以将[任务](../../user/tasks.md#linked-items-in-tasks)和 [OKR](../../user/okrs.md#linked-items-in-okrs) 关联为“相关”、“被阻止”或“阻止”，以提供依赖和相关工作项之间的可追溯性。

当我们将[史诗](https://jihulab.com/groups/gitlab-cn/-/epics/9290)和[议题](https://jihulab.com/groups/gitlab-cn/-/epics/9584)迁移到工作项框架时，您将能够跨所有这些类型进行关联。

<a id="set-a-parent-for-a-task-objective-or-key-result-with-a-quick-action"></a>

### 使用快速操作为任务、目标或关键结果设置父项

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: JihuLab.com
- Links: [Documentation](../../user/project/quick_actions.md) | [Related issue](https://jihulab.com/gitlab-cn/gitlab/-/issues/420798)

{{< /details >}}

您现在可以通过使用 `/set_parent` 快速操作，为任务、目标或关键结果设置父项。

<a id="dast-analyzer-updates"></a>

### DAST 分析器更新

{{< details >}}

- Tier: 旗舰版
- Links: [Documentation](../../user/application_security/dast/browser/checks/_index.md) | [Related epic](https://jihulab.com/groups/gitlab-cn/-/epics/11426)

{{< /details >}}

在 16.5 发布里程碑期间，我们默认启用了以下基于浏览器的 DAST 的主动检查：

- 检查 78.1 取代 ZAP 检查 90020，识别命令注入，攻击者可通过在目标应用服务器上执行任意操作系统命令来利用此漏洞。这是一个可能导致系统完全被攻陷的严重漏洞。
- 检查 611.1 取代 ZAP 检查 90023，识别外部 XML 实体注入 (XXE)，攻击者可通过使应用程序的 XML 解析器包含外部资源来利用此漏洞。
- 检查 94.4 取代 ZAP 检查 90019，识别“服务器端代码注入 (NodeJS)”，攻击者可通过注入任意 JavaScript 代码在服务器上执行来利用此漏洞。
- 检查 113.1 取代 ZAP 检查 40003，识别“HTTP 标头中 CRLF 序列的不当中和 (‘HTTP 响应拆分’)”，攻击者可通过插入回车/换行 (CRLF) 字符将任意数据注入 HTTP 响应来利用此漏洞。

<a id="make-jobs-api-endpoint-rate-limit-configurable"></a>

### 使 jobs API 端点速率限制可配置

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: JihuLab.com
- Links: [Documentation](../../administration/settings/user_and_ip_rate_limits.md#maximum-authenticated-requests-to-projectidjobs-per-minute) | [Related issue](https://jihulab.com/gitlab-cn/gitlab/-/issues/395702)

{{< /details >}}

最近为 `project/:id/jobs` API 端点添加了速率限制，默认值为每个用户每分钟 600 个请求。作为后续迭代，我们使此限制可配置，使实例管理员能够设置最适合其要求的限制。

<a id="gitlab-runner-16-5"></a>

### 极狐GitLab Runner 16.5

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Links: [Documentation](https://gitlab.cn/docs/runner)

{{< /details >}}

我们今天还发布了极狐GitLab Runner 16.5！极狐GitLab Runner 是一个轻量级、高度可扩展的代理，用于运行您的 CI/CD 作业并将结果发送回极狐GitLab 实例。极狐GitLab Runner 与极狐GitLab CI/CD 配合使用，极狐GitLab CI/CD 是极狐GitLab 附带的开源持续集成服务。

<a id="whats-new"></a>

#### 新功能

- [适用于 AWS EC2 实例的 极狐GitLab Runner fleeting 插件 - 测试版](https://jihulab.com/gitlab-cn/gitlab-runner/-/issues/29404)

<a id="bug-fixes"></a>

#### 错误修复

- [终止 runner manager k8s pod 会导致孤立的 worker pod](https://jihulab.com/gitlab-cn/gitlab/-/issues/390645)
- [极狐GitLab Runner 15.8.0 无法检出带有特殊字符的分支](https://jihulab.com/gitlab-cn/gitlab-runner/-/issues/29606)
- [极狐GitLab Runner 在 arm64 计算主机上拉取 x86-64 辅助镜像，而不是 arm64 辅助镜像](https://jihulab.com/gitlab-cn/gitlab-runner/-/issues/27768)

所有更改的列表在极狐GitLab Runner [CHANGELOG](https://jihulab.com/gitlab-cn/gitlab-runner/blob/16-5-stable/CHANGELOG.md) 中。

