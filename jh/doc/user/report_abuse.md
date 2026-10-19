---
stage: Software Supply Chain Security
group: Authorization
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
title: 报告滥用行为
---

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: JihuLab.com，私有化部署

{{< /details >}}

您可以将其他极狐GitLab 用户的滥用行为报告给极狐GitLab 管理员。

极狐GitLab 管理员随后[可以选择](../administration/review_abuse_reports.md)：

- 移除该用户，这会将其从实例中删除。
- 屏蔽该用户，这会拒绝其访问实例。
- 或者移除该报告，这会保留该用户对实例的访问权限。

您可以通过以下位置报告用户：

- [个人资料](#report-abuse-from-the-users-profile-page)
- [评论](#report-abuse-from-a-users-comment)
- [议题](#report-abuse-from-an-issue)
- [任务](#report-abuse-from-a-task)
- [目标](#report-abuse-from-an-objective)
- [关键结果](#report-abuse-from-a-key-result)
- [合并请求](#report-abuse-from-a-merge-request)
- [代码片段](snippets.md#mark-snippet-as-spam)

您也可以从 Agent 或任务流报告滥用行为。

<a id="report-abuse-from-the-users-profile-page"></a>

## 从用户个人资料页面报告滥用行为

要从用户个人资料页面报告滥用行为：

1. 在极狐GitLab 的任意位置，选择该用户的名称。
1. 在用户个人资料的右上角，选择垂直省略号 ({{< icon name="ellipsis_v" >}})，然后选择**报告滥用**。
1. 选择报告该用户的原因。
1. 填写滥用行为报告。
1. 选择**发送报告**。

<a id="report-abuse-from-a-users-comment"></a>

## 从用户评论报告滥用行为

要从用户评论报告滥用行为：

1. 在该评论的右上角，选择**更多操作** ({{< icon name="ellipsis_v" >}})。
1. 选择**报告滥用**。
1. 选择报告该用户的原因。
1. 填写滥用行为报告。
1. 选择**发送报告**。

> [!note]
> 被报告用户评论的 URL 会预先填入滥用行为报告的
> **消息**字段中。

<a id="report-abuse-from-an-issue"></a>

## 从议题报告滥用行为

1. 在该议题的右上角，选择**议题操作** ({{< icon name="ellipsis_v" >}})。
1. 选择**报告滥用**。
1. 选择报告该用户的原因。
1. 填写滥用行为报告。
1. 选择**发送报告**。

<a id="report-abuse-from-a-task"></a>

## 从任务报告滥用行为

1. 在该任务的右上角，选择**更多操作** ({{< icon name="ellipsis_v" >}})。
1. 选择**报告滥用**。
1. 选择报告该用户的原因。
1. 填写滥用行为报告。
1. 选择**发送报告**。

<a id="report-abuse-from-an-objective"></a>

## 从目标报告滥用行为

1. 在该目标的右上角，选择**更多操作** ({{< icon name="ellipsis_v" >}})。
1. 选择**报告滥用**。
1. 选择报告该用户的原因。
1. 填写滥用行为报告。
1. 选择**发送报告**。

<a id="report-abuse-from-a-key-result"></a>

## 从关键结果报告滥用行为

1. 在该关键结果的右上角，选择**更多操作** ({{< icon name="ellipsis_v" >}})。
1. 选择**报告滥用**。
1. 选择报告该用户的原因。
1. 填写滥用行为报告。
1. 选择**发送报告**。

<a id="report-abuse-from-a-merge-request"></a>

## 从合并请求报告滥用行为

1. 在该合并请求的右上角，选择**合并请求操作** ({{< icon name="ellipsis_v" >}})。
1. 选择**报告滥用**。
1. 选择报告该用户的原因。
1. 填写滥用行为报告。
1. 选择**发送报告**。

<a id="report-abuse-from-an-agent"></a>

## 从 Agent 报告滥用行为

先决条件：

- 已登录极狐GitLab。
- 属于已被[授予访问极狐GitLab Duo Agent Platform 权限](../administration/gitlab_duo/configure/access_control.md)的群组。
- 管理员必须已为实例配置[滥用行为报告通知电子邮件](../administration/review_abuse_reports.md)。

要从 Agent 报告滥用行为：

1. 在 Agent 详情视图中，选择右上角的**更多操作** ({{< icon name="ellipsis_v" >}})。
1. 选择**向管理员报告**。
1. 选择报告此 Agent 的原因。
1. 可选。添加其他信息。
1. 选择**提交**。

<a id="report-abuse-from-a-flow"></a>

## 从任务流报告滥用行为

先决条件：

- 已登录极狐GitLab。
- 属于已被[授予访问极狐GitLab Duo Agent Platform 权限](../administration/gitlab_duo/configure/access_control.md)的群组。
- 管理员必须已为实例配置[滥用行为报告通知电子邮件](../administration/review_abuse_reports.md)。

要从任务流报告滥用行为：

1. 在任务流详情视图中，选择右上角的**更多操作** ({{< icon name="ellipsis_v" >}})。
1. 选择**向管理员报告**。
1. 选择报告此任务流的原因。
1. 可选。添加其他信息。
1. 选择**提交**。
