---
stage: Analytics
group: Platform Insights
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
description: Manage GitLab incidents directly from Slack using the GitLab for Slack app, including declaring incidents, using quick actions, and receiving notifications.
title: Slack 的事件管理
---

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: JihuLab.com
- Status: Beta

{{< /details >}}

{{< history >}}

- 引入于 极狐GitLab 15.7，带有一个名为 `incident_declare_slash_command` 的功能标志，默认禁用。
- 在 JihuLab.com 上于 极狐GitLab 15.10 启用，处于 [beta](../../policy/development_stages_support.md#beta) 阶段。

{{< /history >}}

> [!flag]
> 此功能的可用性由功能标志控制。
> 更多信息，请参阅历史记录。
> 此功能可用于测试，但尚未准备好用于生产环境。

许多团队在 Slack 中接收警报并在事件期间进行实时协作。
使用极狐GitLab for Slack 应用可以：

- 从 Slack 创建极狐GitLab 事件。
- 接收事件通知。

Slack 的事件管理仅适用于 JihuLab.com。

要了解最新动态，请关注 [史诗 1211](https://jihulab.com/groups/gitlab-cn/-/epics/1211)。

<a id="manage-an-incident-from-slack"></a>

## 从 Slack 管理事件

先决条件：

1. 安装 [极狐GitLab for Slack 应用](../../user/project/integrations/gitlab_slack_application.md)。
   这样，你可以在 Slack 中使用斜杠命令来创建和更新极狐GitLab 事件。
1. 启用 [Slack 通知](../../user/project/integrations/gitlab_slack_application.md#slack-notifications)。请务必为 `Incident` 事件启用通知，并定义一个 Slack 频道以接收相关通知。
1. 授权极狐GitLab 代表你的 Slack 用户执行操作。
   每个用户在使用任何事件斜杠命令之前都必须执行此操作。

   要开始授权流程，请尝试执行一个非事件的 [Slack 斜杠命令](../../user/project/integrations/gitlab_slack_application.md#slash-commands)，
   例如 `/gitlab <project-alias> issue show <id>`。
   你选择的 `<project-alias>` 必须是已设置极狐GitLab for Slack 应用的项目。选择对话框有 100 个项目的硬性限制。
   更多信息，请参阅 [议题 377548](https://jihulab.com/gitlab-cn/gitlab/-/issues/377548)。

<a id="declare-an-incident"></a>

## 声明事件

要从 Slack 声明一个极狐GitLab 事件：

1. 在 Slack 中，在任何频道或私信中，输入 `/gitlab incident declare` 斜杠命令。
1. 从模态窗口中，选择相关事件详情，包括：

   - 事件标题和描述。
   - 应创建事件的项目。
   - 事件的严重程度。

   如果你的项目有现有的 [事件模板](alerts.md#trigger-actions-from-alerts)，该模板会自动应用到描述文本框中。仅在描述文本框为空时才会应用该模板。

   你还可以在描述文本框中包含 [快速操作](../../user/project/quick_actions.md)。例如，输入 `/link https://example.slack.com/archives/123456789 专用 Slack 频道`
   会将一个专用 Slack 频道添加到你所创建的事件中。有关事件的完整快速操作列表，请参见 [使用极狐GitLab 快速操作](#use-gitlab-quick-actions)。
1. 可选。添加一个现有 Zoom 会议的链接。
1. 选择 **创建**。

如果事件创建成功，Slack 会显示一个确认通知。

<a id="use-gitlab-quick-actions"></a>

### 使用极狐GitLab 快速操作

在从 Slack 创建极狐GitLab 事件时，可以在描述文本框中使用 [快速操作](../../user/project/quick_actions.md)。以下快速操作可能对你最相关：

| 命令                    | 描述                                        |
| ----------------------- | ------------------------------------------- |
| `/assign @user1 @user2` | 为极狐GitLab 事件添加指派人。                |
| `/label ~label1 ~label2`| 为极狐GitLab 事件添加标签。                  |
| `/link <URL> <text>`    | 将一个链接添加到专用 Slack 频道、操作手册或任何相关资源到事件的 `Related resources` 部分。 |
| `/zoom <URL>`           | 为事件添加一个 Zoom 会议链接。               |

<a id="send-gitlab-incident-notifications-to-slack"></a>

## 将极狐GitLab 事件通知发送到 Slack

如果你已经为事件 [启用了通知](#manage-an-incident-from-slack)，你每次打开、关闭或更新事件时，都应该在选定的 Slack 频道中收到通知。