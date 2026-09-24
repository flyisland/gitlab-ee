---
stage: Plan
group: Work Items
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
title: 极狐GitLab for Slack 应用
description: "配置极狐GitLab for Slack 应用，以使用斜杠命令、接收通知，并从您的 Slack 工作区与极狐GitLab Duo 交互。"
---

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: JihuLab.com，私有化部署

{{< /details >}}

> [!note]
> 管理员文档，请参阅 [极狐GitLab for Slack 应用管理](../../../administration/settings/slack_app.md)。

极狐GitLab for Slack 应用是一个原生 Slack 应用，在您的 Slack 工作区中提供[斜杠命令](#slash-commands)、[通知](#slack-notifications)和[极狐GitLab Duo 集成](#gitlab-duo)。极狐GitLab 将您的 Slack 用户与您的极狐GitLab 用户关联，以便您在 Slack 中运行的任何命令都由您关联的极狐GitLab 用户执行。

<a id="install-the-gitlab-for-slack-app"></a>

## 安装极狐GitLab for Slack 应用

先决条件：

- 您必须拥有[将应用添加到 Slack 工作区的适当权限](https://slack.com/help/articles/202035138-Add-apps-to-your-Slack-workspace)。
- 在极狐GitLab 私有化部署上，管理员必须[开启该集成](../../../administration/settings/slack_app.md)。

极狐GitLab for Slack 应用使用[细粒度权限](https://medium.com/slack-developer-blog/more-precision-less-restrictions-a3550006f9c3)。虽然功能没有变化，但您应该[重新安装该应用](#reinstall-the-gitlab-for-slack-app)。

<a id="from-the-project-or-group-settings"></a>

### 从项目或群组设置中安装

要从项目或群组设置中安装极狐GitLab for Slack 应用：

1. 在顶部栏中，选择 **搜索或跳转到** 并找到您的项目或群组。
1. 在左侧边栏中，选择 **设置** > **集成**。
1. 选择 **极狐GitLab for Slack 应用**。
1. 选择 **安装极狐GitLab for Slack 应用**。您将被重定向到 Slack 确认页面。
1. 在 Slack 确认页面上：
   1. 可选。如果您登录了多个 Slack 工作区，请在右上角的下拉列表中选择要安装该应用的工作区。在极狐GitLab 私有化部署上，管理员必须首先[启用多工作区支持](../../../administration/settings/slack_app.md#enable-support-for-multiple-workspaces)，下拉列表才会出现。
   1. 选择 **允许**。

当您为群组安装该应用时，该集成也会为群组中所有尚未配置该集成的子群组和项目开启。已配置该集成的子群组和项目不受影响，但可以随时使用继承的设置。有关更多信息，请参阅[管理项目集成的群组默认设置](_index.md#manage-group-default-settings-for-a-project-integration)。每个项目都会根据其项目路径获得一个项目特定的别名，您可以在[斜杠命令](#slash-commands)中使用该别名。

<a id="from-the-slack-app-directory"></a>

### 从 Slack 应用目录

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: JihuLab.com

{{< /details >}}

在 JihuLab.com 上，您也可以从 [Slack 应用目录](https://slack-platform.slack.com/apps/A676ADMV5-gitlab)安装极狐GitLab for Slack 应用。

要从 Slack 应用目录安装极狐GitLab for Slack 应用：

1. 转到 [极狐GitLab for Slack 页面](https://gitlab.com/-/profile/slack/edit)。
1. 选择一个极狐GitLab 项目以关联到您的 Slack 工作区。

<a id="reinstall-the-gitlab-for-slack-app"></a>

## 重新安装极狐GitLab for Slack 应用

当极狐GitLab 为极狐GitLab for Slack 应用发布新功能时，您可能需要重新安装该应用才能使用这些功能。

要重新安装极狐GitLab for Slack 应用：

1. 在顶部栏中，选择 **搜索或跳转到** 并找到您的项目。
1. 在左侧边栏中，选择 **设置** > **集成**。
1. 选择 **极狐GitLab for Slack 应用**。
1. 选择 **安装极狐GitLab for Slack 应用**。您将被重定向到 Slack 确认页面。
1. 在 Slack 确认页面上：
   1. 可选。如果您登录了多个 Slack 工作区，请在右上角的下拉列表中选择要重新安装该应用的工作区。在极狐GitLab 私有化部署上，管理员必须首先[启用多工作区支持](../../../administration/settings/slack_app.md#enable-support-for-multiple-workspaces)，下拉列表才会出现。
   1. 选择 **允许**。

极狐GitLab for Slack 应用会为所有使用该集成的项目更新。

或者，您可以重新[配置该集成](https://about.gitlab.com/solutions/slack/)。

<a id="gitlab-duo"></a>

## 极狐GitLab Duo

{{< details >}}

- Tier: 旗舰版
- Offering: JihuLab.com
- Status: 实验

{{< /details >}}

> [!flag]
> 此功能的可用性由功能标志控制。此功能可用于测试，但尚未准备好用于生产环境。

<!-- markdownlint-disable-next-line MD028 -- Two distinct notes, so the blank line between them is intentional. -->

> [!note]
> 如果您在没有 Slack Enterprise Grid 的情况下使用多个 Slack 安装，Slack 会将极狐GitLab Duo 限制为每分钟 15 个对话对象。
> 这会阻止集成正常运行，因为单次调用会从频道历史中请求 50 条消息作为上下文。
> 为避免 Slack 中极狐GitLab Duo 的速率限制，请将您的所有 Slack 工作区保留在单个 Enterprise Grid 组织中。

您可以通过在机器人所在的任何频道或线程中提及极狐GitLab 机器人，直接在 Slack 中与[极狐GitLab Duo](../../gitlab_duo/_index.md)交互。极狐GitLab Duo 会读取完整的对话线程和最近的频道历史作为上下文，在 CI/CD Runner 上运行任务流，并将结果发布回 Slack 线程。

例如，您可以要求极狐GitLab Duo 执行以下操作：

- 将对话转换为极狐GitLab 议题。
- 搜索现有议题或合并请求。
- 总结讨论线程。
- 回答有关您项目的问题。

> [!note]
> 当您在线程中提及极狐GitLab 机器人时，完整的对话内容（包括所有参与者的消息）会发送到大型语言模型 (LLM) 以生成响应。请勿在提及极狐GitLab Duo 的线程中分享敏感信息。

<a id="prerequisites"></a>

### 先决条件

- [开启极狐GitLab Duo Agent Platform](../../duo_agent_platform/turn_on_off.md#turn-gitlab-duo-agent-platform-on-or-off)。
- [开启测试版和实验性功能](../../gitlab_duo/turn_on_off.md#turn-on-beta-and-experimental-features)。
- 将 Slack 账号关联到您的极狐GitLab 账号。
  如果您的账号未关联，极狐GitLab 会在您首次提及时向您发送一条
  包含授权连接链接的消息。
- [设置默认的极狐GitLab Duo 命名空间](../../profile/preferences.md#set-a-default-gitlab-duo-namespace)。
- 为顶级群组开启[开发者任务流](../../duo_agent_platform/flows/foundational_flows/developer.md)。
- 将极狐GitLab 机器人添加到您要使用它的 Slack 频道。
- 对于现有安装，[重新安装极狐GitLab for Slack 应用](#reinstall-the-gitlab-for-slack-app)以授予极狐GitLab Duo 所需的额外权限。

<a id="use-gitlab-duo-in-slack"></a>

### 在 Slack 中使用极狐GitLab Duo

要在 Slack 中使用极狐GitLab Duo：

1. 在 Slack 频道或线程中，输入 `@GitLab` 后跟您的请求（例如，`@GitLab create an issue to track this bug`）。
1. 极狐GitLab Duo 确认您的请求并开始处理任务。
1. 任务完成后，极狐GitLab Duo 会发布包含结果的线程回复。

如果发生错误，极狐GitLab Duo 会向您发送一条包含问题详情的消息。此消息仅对您可见。

<a id="workspace-project"></a>

### 工作区项目

当您首次从 Slack 使用极狐GitLab Duo 时，会在您的默认极狐GitLab Duo 命名空间中自动创建一个名为 `duo-workspace` 的工作区项目。此项目用作从 Slack 触发的任何任务流的执行环境。

您可以在工作区项目中自定义 Agent 行为。有关更多信息，请参阅[开发者任务流](../../duo_agent_platform/flows/foundational_flows/developer.md)。

<a id="gitlab-for-slack-app-permissions"></a>

### 极狐GitLab for Slack 应用权限

极狐GitLab Duo 需要以下额外的极狐GitLab for Slack 应用权限：

| 范围               | 用途 |
|---------------------|---------|
| `app_mentions:read` | 当用户在频道中提及机器人时接收事件。 |
| `channels:history`  | 读取公共频道中的对话历史，以向 Agent 提供线程和频道上下文。 |
| `groups:history`    | 读取私人频道中的对话历史，以向 Agent 提供线程和频道上下文。 |
| `reactions:write`   | 向消息添加表情符号反应，以指示 Agent 生命周期状态。 |

新安装会自动获得这些权限。现有安装只有在您[重新安装极狐GitLab for Slack 应用](#reinstall-the-gitlab-for-slack-app)后才会获得这些权限。

<a id="slash-commands"></a>

## 斜杠命令

您可以使用斜杠命令来运行常见的极狐GitLab 操作。

对于极狐GitLab for Slack 应用：

- 当您运行第一个斜杠命令时，必须授权您的 Slack 用户。
- 您可以将 `<project>` 替换为项目完整路径，或为斜杠命令[创建项目别名](#create-a-project-alias)。

如果您改用 [Mattermost 斜杠命令](mattermost_slash_commands.md)：

- 将 `/gitlab` 替换为您为这些集成配置的触发器名称。
- 移除 `<project>`。

以下斜杠命令可用于极狐GitLab：

| 命令 | 描述 |
| ------- | ----------- |
| `/gitlab help` | 显示所有可用的斜杠命令。 |
| `/gitlab <project> issue show <id>` | 显示 ID 为 `<id>` 的议题。 |
| `/gitlab <project> issue new <title>` <kbd>Shift</kbd>+<kbd>Enter</kbd> `<description>` | 创建标题为 `<title>`、描述为 `<description>` 的议题。 |
| `/gitlab <project> issue search <query>` | 显示最多五个与 `<query>` 匹配的议题。 |
| `/gitlab <project> issue move <id> to <project>` | 将 ID 为 `<id>` 的议题移动到 `<project>`。 |
| `/gitlab <project> issue close <id>` | 关闭 ID 为 `<id>` 的议题。 |
| `/gitlab <project> issue comment <id>` <kbd>Shift</kbd>+<kbd>Enter</kbd> `<comment>` | 向 ID 为 `<id>` 的议题添加评论，评论内容为 `<comment>`。 |
| `/gitlab <project> deploy <from> to <to>` | 从 `<from>` 环境[部署](#deploy-command)到 `<to>` 环境。 |
| `/gitlab <project> run <job name> <arguments>` | 在默认分支上执行 [ChatOps](../../../ci/chatops/_index.md) 作业 `<job name>`。 |
| `/gitlab incident declare` | 打开一个对话框以[从 Slack 创建事件](../../../operations/incident_management/slack.md)。 |

<a id="deploy-command"></a>

### `deploy` 命令

要部署到环境，极狐GitLab 会尝试在流水线中查找手动部署操作。

如果为某个环境只定义了一个部署操作，则会触发该操作。如果定义了多个部署操作，极狐GitLab 会尝试查找与环境名称匹配的操作名称。

如果极狐GitLab 找不到匹配的部署操作，该命令将返回错误。

<a id="create-a-project-alias"></a>

### 创建项目别名

在极狐GitLab for Slack 应用中，斜杠命令默认使用项目完整路径。您可以使用项目别名代替。

要为极狐GitLab for Slack 应用中的斜杠命令创建项目别名：

1. 在顶部栏中，选择 **搜索或跳转到** 并找到您的项目。
1. 在左侧边栏中，选择 **设置** > **集成**。
1. 选择 **极狐GitLab for Slack 应用**。
1. 在项目路径或别名旁边，选择 **编辑**。
1. 输入新别名并选择 **保存更改**。

如果在 Slack 工作区中发生别名冲突（例如，多个项目或群组尝试使用相同的别名），极狐GitLab 会自动分配一个备用别名，格式如下：

- 对于项目：`p-<project_id>`（例如，`p-12345`）
- 对于群组：`g-<group_id>`（例如，`g-67890`）

当首选别名不可用时，您可以在斜杠命令中使用这些备用别名。

<a id="slack-notifications"></a>

## Slack 通知

您可以针对某些极狐GitLab [事件](#notification-events)接收 Slack 频道通知。

<a id="configure-notifications"></a>

### 配置通知

要配置 Slack 通知：

1. 在顶部栏中，选择 **搜索或跳转到** 并找到您的项目。
1. 在左侧边栏中，选择 **设置** > **集成**。
1. 选择 **极狐GitLab for Slack 应用**。
1. 在 **触发器** 部分：
   - 为您希望在 Slack 中接收通知的每个极狐GitLab [事件](#notification-events)选中复选框。
   - 为您选中的每个复选框，输入您希望接收通知的 Slack 频道名称。您最多可以输入 10 个频道名称，用逗号分隔（例如，`#channel-one, #channel-two`）。

     > [!note]
     > 如果 Slack 频道是私人的，您必须[将极狐GitLab for Slack 应用添加到该频道](#receive-notifications-to-a-private-channel)。

1. 可选。在 **通知设置** 部分：
   - 选中 **仅通知失败的流水线** 复选框，以仅接收失败流水线的通知。
   - 选中 **仅在状态更改时通知** 复选框，以仅在引用的流水线状态更改时接收通知。
   - 从 **要发送通知的分支** 下拉列表中，选择您希望接收通知的分支。

     由这些分支创建的标签触发的流水线也会发送通知。

     漏洞通知仅由默认分支触发，无论选择哪个分支。有关更多详细信息，请参阅 [议题 469373](https://gitlab.com/gitlab-org/gitlab/-/issues/469373)。
   - 对于 **要通知的标记**，输入极狐GitLab 议题、合并请求或评论必须具有的任意或全部标记才能接收通知。留空以接收所有事件的通知。
1. 可选。选择 **测试设置**。
1. 选择 **保存更改**。

<a id="receive-notifications-to-a-private-channel"></a>

### 接收私人频道的通知

要接收私人 Slack 频道的通知，您必须将极狐GitLab for Slack 应用添加到该频道：

1. 在频道中输入 `@GitLab` 提及该应用。
1. 选择 **添加到频道**。

<a id="notification-events"></a>

### 通知事件

以下极狐GitLab 事件可以在 Slack 中触发通知：

| 事件                                                                 | 描述 |
| --------------------------------------------------------------------- | ----------- |
| 推送                                                                  | 向代码仓库进行推送。 |
| 议题                                                                 | 创建、关闭或重新打开工作项。 |
| 机密议题                                                    | 创建、关闭或重新打开机密工作项。 |
| 合并请求                                                         | 创建、合并、批准、关闭或重新打开合并请求。 |
| 评论                                                                  | 添加评论。 |
| 机密评论                                                     | 添加关于机密工作项的内部评论或评论。 |
| 标签推送                                                              | 向代码仓库推送或移除标签。 |
| 流水线                                                              | 流水线状态更改。 |
| Wiki 页面                                                             | 创建或更新 Wiki 页面。 |
| 部署                                                            | 开始或完成部署。 |
| 公共频道中的[群组提及](#trigger-notifications-for-group-mentions)  | 在公共频道中提及群组。 |
| 私人频道中的[群组提及](#trigger-notifications-for-group-mentions) | 在私人频道中提及群组。 |
| [事件](../../../operations/incident_management/slack.md)          | 创建、关闭或重新打开事件。 |
| [漏洞](../../application_security/vulnerabilities/_index.md) | 在默认分支上记录新的、唯一的漏洞。 |
| 警报                                                                 | 记录新的、唯一的警报。 |

<a id="trigger-notifications-for-group-mentions"></a>

### 触发群组提及的通知

要触发群组提及的[通知事件](#notification-events)，请在以下位置使用 `@<group_name>`：

- 议题和合并请求描述
- 议题、合并请求和提交的评论
