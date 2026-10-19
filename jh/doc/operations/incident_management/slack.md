---
stage: Analytics
group: Platform Insights
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
description: 使用 GitLab for Slack 应用直接从 Slack 管理极狐GitLab 事件，包括声明事件、使用快速操作以及接收通知。
title: Slack 事件管理
---

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: JihuLab.com
- Status: 测试版

{{< /details >}}

> [!flag]
> 此功能的可用性由功能标志控制。
> 此功能可用于测试，但尚未准备好用于生产环境。

许多团队会在 Slack 中接收告警，并在事件处理期间实时协作。
使用 GitLab for Slack 应用可以：

- 从 Slack 创建极狐GitLab 事件。
- 接收事件通知。

Slack 事件管理仅适用于 JihuLab.com。

如需了解最新动态，请关注[史诗 1211](https://gitlab.com/groups/gitlab-org/-/epics/1211)。

<a id="manage-an-incident-from-slack"></a>

## 从 Slack 管理事件

先决条件：

1. 安装 [GitLab for Slack 应用](../../user/project/integrations/gitlab_slack_application.md)。
   这样，您就可以在 Slack 中使用斜杠命令来创建和更新极狐GitLab 事件。
1. 启用 [Slack 通知](../../user/project/integrations/gitlab_slack_application.md#slack-notifications)。请务必为
   `Incident` 事件启用通知，并定义一个 Slack 频道来接收相关通知。
1. 授权极狐GitLab 代表您的 Slack 用户执行操作。
   每个用户都必须先完成此操作，然后才能使用任何事件斜杠命令。

   要开始授权流程，请尝试执行一个非事件的 [Slack 斜杠命令](../../user/project/integrations/gitlab_slack_application.md#slash-commands)，
   例如 `/gitlab <project-alias> issue show <id>`。
   您选择的 `<project-alias>` 必须是已设置 GitLab for Slack 应用的项目。选择对话框最多只能显示 100 个项目。
   更多信息，请参见[议题 377548](https://gitlab.com/gitlab-org/gitlab/-/issues/377548)。

<a id="declare-an-incident"></a>

## 声明事件

要从 Slack 声明极狐GitLab 事件：

1. 在 Slack 的任意频道或私信中，输入 `/gitlab incident declare` 斜杠命令。
1. 在模态窗口中，选择相关的事件详细信息，包括：

   - 事件标题和描述。
   - 应在其中创建事件的项目。
   - 事件的严重性。

   如果您的项目已有[事件模板](alerts.md#trigger-actions-from-alerts)，
   该模板会自动应用到描述文本框中。仅当描述文本框为空时，才会应用该模板。

   您还可以在描述文本框中添加[快速操作](../../user/project/quick_actions.md)。
   例如，输入 `/link https://example.slack.com/archives/123456789 Dedicated Slack channel`
   会为您创建的事件添加一个专用 Slack 频道。有关事件的完整快速操作列表，
   请参见[使用极狐GitLab 快速操作](#use-gitlab-quick-actions)。
1. 可选。添加指向现有 Zoom 会议的链接。
1. 选择**创建**。

如果事件创建成功，Slack 会显示确认通知。

<a id="use-gitlab-quick-actions"></a>

### 使用极狐GitLab 快速操作

从 Slack 创建极狐GitLab 事件时，可在描述文本框中使用[快速操作](../../user/project/quick_actions.md)。以下快速操作可能与您最相关：

| 命令                  | 描述                               |
| ------------------------ | ----------------------------------------- |
| `/assign @user1 @user2`  | 为极狐GitLab 事件添加指派人。  |
| `/label ~label1 ~label2` | 为极狐GitLab 事件添加标记。       |
| `/link <URL> <text>`     | 将指向专用 Slack 频道、runbook 或任何相关资源的链接添加到事件的 `Related resources` 部分。 |
| `/zoom <URL>`            | 为事件添加 Zoom 会议链接。 |

<a id="send-gitlab-incident-notifications-to-slack"></a>

## 将极狐GitLab 事件通知发送到 Slack

如果您已为事件[启用通知](#manage-an-incident-from-slack)，则每当事件被打开、关闭或更新时，您都应会在所选 Slack 频道中收到通知。
