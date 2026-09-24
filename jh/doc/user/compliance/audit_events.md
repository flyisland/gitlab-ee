---
stage: Software Supply Chain Security
group: Compliance
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
title: 审计事件
---

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: JihuLab.com，私有化部署

{{< /details >}}

安全审计是对您的基础设施进行的深入分析和审查，用于展示关注领域和潜在风险操作。为协助审计过程，极狐GitLab 提供审计事件，使您能够跟踪极狐GitLab 中的各种不同操作。
极狐GitLab 可帮助所有者和管理员通过生成全面的报告来回应审计员。这些审计报告的范围根据需求而有所不同。

例如，您可以使用审计事件来跟踪：

- 谁更改了特定用户在极狐GitLab 项目中的权限级别，以及何时更改。
- 谁添加了新用户或删除了用户，以及何时操作。

这些事件可用于审计，以评估风险、加强安全措施、响应事件并遵守合规要求。有关极狐GitLab 提供的完整审计事件列表，请参阅[审计事件类型](audit_event_types.md)。例如：

- 生成审计事件报告，以提供给要求提供特定日志记录能力证明的外部审计员。
- 提供一份所有用户的报告，显示其群组和项目成员资格，用于季度访问审查，以便审计员验证是否符合组织的访问管理策略。

审计事件无限期保留。由于没有保留时间限制，所有审计事件都可用。

<a id="prerequisites"></a>

## 先决条件

要查看特定类型的审计事件，您需要最低角色。

- 要查看群组中所有用户的群组审计事件，您必须具有该群组的[所有者角色](../permissions.md#roles)。
- 要查看项目中所有用户的项目审计事件，您必须至少具有该项目的[维护者角色](../permissions.md#roles)。
- 要根据您自己在群组或项目中的操作查看群组和项目审计事件，您必须至少具有该群组或项目的[开发者角色](../permissions.md#roles)。

具有[审计员访问级别](../../administration/auditor_users.md)的用户可以查看所有用户的群组和项目事件。

<a id="viewing-audit-events"></a>

## 查看审计事件

审计事件可以在群组、项目、实例和登录级别查看。每个级别有其记录的不同审计事件。

<a id="sign-in-audit-events"></a>

### 登录审计事件

成功的登录事件是所有层级中唯一可用的审计事件。要查看成功的登录事件：

1. 在右上角，选择您的头像。
1. 选择 **编辑资料**。
1. 在左侧边栏中，选择 **访问** > **身份验证日志**。

升级到付费层级后，您还可以在审计事件页面上查看成功的登录事件。

<a id="group-audit-events"></a>

### 群组审计事件

{{< details >}}

- Tier: 专业版，旗舰版
- Offering: JihuLab.com，私有化部署

{{< /details >}}

要查看群组的审计事件：

1. 在顶部栏中，选择 **搜索或跳转到** 并找到您的群组。
1. 在左侧边栏中，选择 **安全** > **审计事件**。
1. 按执行操作的项目成员（用户）和日期范围过滤审计事件。

群组审计事件也可以通过[群组审计事件 API](../../api/audit_events.md#group-audit-events) 访问。群组审计事件查询的 `created_after` 和 `created_before` 参数限制为日期之间最多 30 天的差异。

<a id="project-audit-events"></a>

### 项目审计事件

{{< details >}}

- Tier: 专业版，旗舰版
- Offering: JihuLab.com，私有化部署

{{< /details >}}

1. 在顶部栏中，选择 **搜索或跳转到** 并找到您的项目。
1. 在左侧边栏中，选择 **安全** > **审计事件**。
1. 按执行操作的项目成员（用户）和日期范围过滤审计事件。

项目审计事件也可以通过[项目审计事件 API](../../api/audit_events.md#project-audit-events) 访问。项目审计事件查询的 `created_after` 和 `created_before` 参数限制为日期之间最多 30 天的差异。

<a id="time-zones"></a>

## 时区

{{< history >}}

- 在极狐GitLab 15.7 中引入，极狐GitLab UI 以用户本地时区而非 UTC 显示日期和时间。

{{< /history >}}

审计事件使用的时区取决于您查看它们的位置：

- 在极狐GitLab UI 中，使用您本地的时区。
- [审计事件 API](../../api/audit_events.md) 默认返回 UTC 日期和时间，或者对于私有化部署，返回[配置的时区](../../administration/timezone.md)。
- 在 CSV 导出中，使用 UTC。

<a id="known-issues"></a>

## 已知问题

审计事件界面具有有限的搜索功能。不支持在审计事件详情中进行基于文本的搜索。您只能按以下条件过滤审计事件：

- 成员事件：执行操作的相关作者。
- 日期范围：最多 30 天的滚动周期。

扩展审计事件报告可用性的提案在[史诗 418](https://jihulab.com/groups/gitlab-cn/-/epics/418) 中提出。

对于审计事件的高级搜索和分析，请考虑[流式传输审计事件](audit_event_streaming.md)到外部目标，您可以在其中执行全面的文本搜索和分析。

<a id="contribute-to-audit-events"></a>

## 贡献审计事件

如果您在任何史诗中没有看到想要的事件，您可以：

- 为极狐GitLab 贡献代码并添加该事件。

<a id="administer-topics"></a>

## 管理主题

实例管理员可以从 **管理员** 区域[管理审计事件](../../administration/compliance/audit_event_reports.md)。