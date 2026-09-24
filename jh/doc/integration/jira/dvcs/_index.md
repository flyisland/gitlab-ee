---
stage: Plan
group: Project Management
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
title: Jira DVCS 连接器
---

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: JihuLab.com，私有化部署

{{< /details >}}

如果您使用 Jira Data Center 或 Jira Server 自托管 Jira 实例，并希望使用 [Jira 开发面板](../development_panel.md)，可以使用 Jira DVCS（分布式版本控制系统）连接器。Jira DVCS 连接器由 Atlassian 开发和维护。

要配置 Jira DVCS 连接器，请参阅[使用 DVCS 与开发工具集成](https://confluence.atlassian.com/adminjiraserver/integrating-with-development-tools-using-dvcs-1047552689.html)。您只能在 Jira 8.14 及更高版本的 Jira Data Center 或 Jira Server 中使用 Jira DVCS 连接器。

Jira 在极狐GitLab 项目中创建一个 Webhook 以提供实时更新。要配置此 Webhook，您必须具有项目的维护者或所有者角色。有关更多信息，请参阅[配置 Webhook 安全](https://confluence.atlassian.com/adminjiraserver/configuring-webhook-security-1299913153.html)。

Jira Cloud 的 Jira DVCS 连接器在极狐GitLab 16.0 中[被移除](https://jihulab.com/gitlab-cn/gitlab/-/merge_requests/118126)。请改用[极狐GitLab for Jira Cloud 应用](../connect-app.md)。有关更多信息，请参阅[安装极狐GitLab for Jira Cloud 应用](../connect-app.md#install-the-gitlab-for-jira-cloud-app)。

<a id="refresh-data-imported-to-jira"></a>

## 刷新导入到 Jira 的数据

默认情况下，Jira 每 60 分钟导入一次极狐GitLab 项目的提交和分支。要在 Jira 中手动刷新数据：

1. 以您配置集成时使用的用户身份登录到您的 Jira 实例。
1. 在顶部栏的右上角，选择 **管理** ({{< icon name="settings" >}}) > **应用**。
1. 在左侧边栏中，选择 **DVCS 账户**。
1. 要刷新 DVCS 账户中的一个或多个仓库：
   - **对于所有仓库**，在账户旁边，选择省略号 ({{< icon name="ellipsis_h" >}}) > **刷新仓库**。
   - **对于单个仓库**：
     1. 选择该账户。
     1. 将鼠标悬停在要刷新的仓库上，在 **最后活动** 列中，选择 **点击同步仓库** ({{< icon name="retry" >}})。