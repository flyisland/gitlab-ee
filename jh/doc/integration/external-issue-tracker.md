---
stage: Plan
group: Work Items
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
title: 外部议题跟踪器
description: 为极狐GitLab 项目配置外部议题跟踪器，以引用和链接来自 Bugzilla 或 YouTrack 等工具的议题。
---

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: JihuLab.com，私有化部署

{{< /details >}}

极狐GitLab 有自己的[议题跟踪器](../user/project/issues/_index.md)，但您也可以为每个极狐GitLab 项目配置外部议题跟踪器。之后您可以使用：

- 外部议题跟踪器与极狐GitLab 议题跟踪器配合使用
- 仅使用外部议题跟踪器

使用外部跟踪器时，您可以使用 `CODE-123` 格式在极狐GitLab 合并请求、提交和评论中提及外部议题，其中：

- `CODE` 是跟踪器的唯一代码。
- `123` 是跟踪器中的议题编号。

引用会显示为议题链接。

<a id="disable-the-gitlab-issue-tracker"></a>

## 禁用极狐GitLab 议题跟踪器

要关闭项目的工作项（包括极狐GitLab 议题跟踪器）：

1. 在顶部栏中，选择**搜索或跳转到**，然后找到您的项目。
1. 在左侧边栏中，选择**设置** > **通用**。
1. 展开**可见性、项目功能、权限**。
1. 在**工作项**下，关闭开关。
1. 选择**保存更改**。

关闭工作项设置后，左侧边栏中将不再显示**工作项**。如果您已配置[外部议题跟踪器](#configure-an-external-issue-tracker)，它仍会保留在左侧边栏中。

<a id="configure-an-external-issue-tracker"></a>

## 配置外部议题跟踪器

您可以配置以下任意外部议题跟踪器：

- [Bugzilla](../user/project/integrations/bugzilla.md)
- [ClickUp](../user/project/integrations/clickup.md)
- [自定义议题跟踪器](../user/project/integrations/custom_issue_tracker.md)
- [Engineering Workflow Management (EWM)](../user/project/integrations/ewm.md)
- [Jira](jira/_index.md)
- [Linear](../user/project/integrations/linear.md)
- [Phorge](../user/project/integrations/phorge.md)
- [Redmine](../user/project/integrations/redmine.md)
- [YouTrack](../user/project/integrations/youtrack.md)
