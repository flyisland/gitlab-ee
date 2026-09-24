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

您可以向极狐GitLab 管理员举报其他极狐GitLab 用户的滥用行为。

极狐GitLab 管理员[可以选择](../administration/review_abuse_reports.md)：

- 移除该用户，将其从实例中删除。
- 封锁该用户，禁止其访问实例。
- 或者移除举报，保留该用户对实例的访问权限。

您可以通过以下方式举报用户：

- [个人资料](#从用户个人资料页面举报滥用行为)
- [评论](#从用户评论举报滥用行为)
- [议题](#从议题举报滥用行为)
- [任务](#从任务举报滥用行为)
- [目标](#从目标举报滥用行为)
- [关键结果](#从关键结果举报滥用行为)
- [合并请求](#从合并请求举报滥用行为)
- [代码片段](snippets.md#mark-snippet-as-spam)

您也可以从代理或流程举报滥用行为。

<a id="report-abuse-from-the-users-profile-page"></a>

## 从用户个人资料页面举报滥用行为

{{< history >}}

- 从溢出菜单举报滥用行为在 GitLab 16.4 中引入，并作为功能标志，名为 `user_profile_overflow_menu_vue`。默认禁用。
- 在 GitLab 16.4 中于 JihuLab.com 启用。
- 在 GitLab 16.6 中正式发布（GA）。功能标志 `user_profile_overflow_menu_vue` 已移除。

{{< /history >}}

从用户个人资料页面举报滥用行为：

1. 在极狐GitLab 任意位置，选择用户名称。
1. 在用户个人资料的右上角，选择垂直省略号（{{< icon name="ellipsis_v" >}}），然后选择 **举报滥用行为**。
1. 选择举报该用户的原因。
1. 填写滥用行为报告。
1. 选择 **发送报告**。

<a id="report-abuse-from-a-users-comment"></a>

## 从用户评论举报滥用行为

{{< history >}}

- 从史诗评论中举报滥用行为在 GitLab 15.10 中引入。

{{< /history >}}

从用户评论举报滥用行为：

1. 在评论的右上角，选择 **更多操作**（{{< icon name="ellipsis_v" >}}）。
1. 选择 **举报滥用行为**。
1. 选择举报该用户的原因。
1. 填写滥用行为报告。
1. 选择 **发送报告**。

> [!注意]
> 被举报用户评论的 URL 已预填在滥用行为报告的 **消息** 字段中。

<a id="report-abuse-from-an-issue"></a>

## 从议题举报滥用行为

1. 在议题的右上角，选择 **议题操作**（{{< icon name="ellipsis_v" >}}）。
1. 选择 **举报滥用行为**。
1. 选择举报该用户的原因。
1. 填写滥用行为报告。
1. 选择 **发送报告**。

<a id="report-abuse-from-a-task"></a>

## 从任务举报滥用行为

{{< history >}}

- 在 GitLab 17.3 中引入。

{{< /history >}}

1. 在任务的右上角，选择 **更多操作**（{{< icon name="ellipsis_v" >}}）。
1. 选择 **举报滥用行为**。
1. 选择举报该用户的原因。
1. 填写滥用行为报告。
1. 选择 **发送报告**。

<a id="report-abuse-from-an-objective"></a>

## 从目标举报滥用行为

{{< history >}}

- 在 GitLab 17.3 中引入。

{{< /history >}}

1. 在目标的右上角，选择 **更多操作**（{{< icon name="ellipsis_v" >}}）。
1. 选择 **举报滥用行为**。
1. 选择举报该用户的原因。
1. 填写滥用行为报告。
1. 选择 **发送报告**。

<a id="report-abuse-from-a-key-result"></a>

## 从关键结果举报滥用行为

{{< history >}}

- 在 GitLab 17.3 中引入。

{{< /history >}}

1. 在关键结果的右上角，选择 **更多操作**（{{< icon name="ellipsis_v" >}}）。
1. 选择 **举报滥用行为**。
1. 选择举报该用户的原因。
1. 填写滥用行为报告。
1. 选择 **发送报告**。

<a id="report-abuse-from-a-merge-request"></a>

## 从合并请求举报滥用行为

1. 在合并请求的右上角，选择 **合并请求操作**（{{< icon name="ellipsis_v" >}}）。
1. 选择 **举报滥用行为**。
1. 选择举报该用户的原因。
1. 填写滥用行为报告。
1. 选择 **发送报告**。

<a id="report-abuse-from-an-agent"></a>

## 从代理举报滥用行为

先决条件：

- 已登录极狐GitLab。
- 属于已[获得访问极狐GitLab Duo Agent Platform 权限](../administration/gitlab_duo/configure/access_control.md)的群组。
- 管理员必须为实例配置了[滥用行为报告通知邮件](../administration/review_abuse_reports.md)。

从代理举报滥用行为：

1. 在代理详情视图的右上角，选择 **更多操作**（{{< icon name="ellipsis_v" >}}）。
1. 选择 **向管理员举报**。
1. 选择举报该代理的原因。
1. 可选。添加额外信息。
1. 选择 **提交**。

<a id="report-abuse-from-a-flow"></a>

## 从流程举报滥用行为

先决条件：

- 已登录极狐GitLab。
- 属于已[获得访问极狐GitLab Duo Agent Platform 权限](../administration/gitlab_duo/configure/access_control.md)的群组。
- 管理员必须为实例配置了[滥用行为报告通知邮件](../administration/review_abuse_reports.md)。

从流程举报滥用行为：

1. 在流程详情视图的右上角，选择 **更多操作**（{{< icon name="ellipsis_v" >}}）。
1. 选择 **向管理员举报**。
1. 选择举报该流程的原因。
1. 可选。添加额外信息。
1. 选择 **提交**。