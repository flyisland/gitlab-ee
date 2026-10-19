---
stage: Plan
group: Work Items
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
title: 极狐GitLab for Slack 应用故障排查
description: "极狐GitLab for Slack 应用故障排查指南。涵盖常见问题，如项目缺失和通知问题。"
---

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: JihuLab.com，私有化部署

{{< /details >}}

使用极狐GitLab for Slack 应用时，您可能会遇到以下问题。

<a id="app-does-not-appear-in-the-list-of-integrations"></a>

## 应用未出现在集成列表中

极狐GitLab for Slack 应用可能不会出现在集成列表中。要让极狐GitLab for Slack 应用出现在您的极狐GitLab 私有化部署实例上，管理员必须[开启该集成](../../../administration/settings/slack_app.md)。在 JihuLab.com 上，极狐GitLab for Slack 应用默认可用。

<a id="error-project-or-alias-not-found"></a>

## 错误：`Project or alias not found`

某些 Slack 命令必须提供项目完整路径或别名，如果找不到项目，则会失败并显示以下错误：

```plaintext
GitLab error: project or alias not found
```

要解决此问题，请确保：

- 项目完整路径正确。
- 如果使用[项目别名](gitlab_slack_application.md#create-a-project-alias)，则别名正确。
- 极狐GitLab for Slack 应用已[为项目开启](gitlab_slack_application.md#from-the-project-or-group-settings)。

<a id="slash-commands-return-dispatch_failed-in-slack"></a>

## 斜杠命令在 Slack 中返回 `dispatch_failed`

斜杠命令可能会在 Slack 中返回 `/gitlab failed with the error "dispatch_failed"`。

要解决此问题，请确保管理员已在您的极狐GitLab 私有化部署实例上正确配置了[极狐GitLab for Slack 应用设置](../../../administration/settings/slack_app.md)。

<a id="notifications-not-received-to-a-channel"></a>

## 未向频道发送通知

如果您没有收到 Slack 频道的通知，请确保：

- 您配置的频道名称正确。
- 如果频道是私有的，您已[将极狐GitLab for Slack 应用添加到该频道](gitlab_slack_application.md#receive-notifications-to-a-private-channel)。

<a id="app-home-does-not-display-properly"></a>

## 应用主页显示异常

如果[应用主页](https://api.slack.com/start/overview#app_home)显示异常，请确保您的[应用是最新版本](gitlab_slack_application.md#reinstall-the-gitlab-for-slack-app)。

<a id="error-this-alias-has-already-been-taken"></a>

## 错误：`This alias has already been taken`

尝试在新项目上进行设置时，您可能会遇到错误 `422: The change you requested was rejected`。返回的 Rails 错误可能是：

```plaintext
"exception.message": "Validation failed: Alias This alias has already been taken"
```

要解决此问题：

1. 在您的命名空间中搜索已开启极狐GitLab for Slack 应用的名称相似的项目。
1. 在这些项目中，检查是否有与失败项目使用相同别名的项目。
1. 编辑别名，使其不同，然后再次尝试为失败的项目开启极狐GitLab for Slack 应用。

<a id="gitlab-duo-mention-failures"></a>

## 极狐GitLab Duo `@mention` 失败

当您在 Slack 中 `@mention` 极狐GitLab 应用以触发极狐GitLab Duo 时，如果出现问题，应用会在该讨论串中发布一条消息。
请使用消息文本识别原因并应用修复。

| Slack 消息 | 原因 | 修复 |
|---|---|---|
| 锁定表情符号（🔒）和授权提示 | 您的 Slack 账户未关联到极狐GitLab 账户。 | 完成授权流程，将您的 Slack 和极狐GitLab 账户关联起来。 |
| `"You do not have access to this feature yet"` | 您的账户未启用 `slack_duo_agent` 功能标志。 | 请管理员为您的用户启用该功能标志。 |
| `"This feature requires experiment and beta GitLab Duo features to be turned on"` | 实验版和测试版极狐GitLab Duo 功能已关闭。 | 开启[测试版和实验性功能](../../gitlab_duo/turn_on_off.md#turn-on-beta-and-experimental-features)。在 JihuLab.com 上，此设置适用于顶级群组。在极狐GitLab 私有化部署上，此设置适用于整个实例。 |
| `"This feature requires GitLab Duo Agent Platform"` | 您的账户没有极狐GitLab Duo Agent Platform 许可证。 | 与您的管理员核对您的极狐GitLab Duo 授权。 |
| `"Set your default Duo namespace in your preferences"` | 您的极狐GitLab 账户未配置默认的极狐GitLab Duo 命名空间。 | 在您的极狐GitLab 偏好设置中设置默认的极狐GitLab Duo 命名空间。在 JihuLab.com 上，您必须在命名空间中拥有有效的极狐GitLab Duo 附加席位。 |
| `"The Duo Developer flow is not enabled for your namespace"` | 您的命名空间未开启内置极狐GitLab Duo 任务流。 | 请群组所有者前往极狐GitLab Duo Agent Platform 设置中开启该任务流。 |
| `"Could not set up the service account…"` | 无法为您的命名空间预配服务账号。 | 检查您命名空间的极狐GitLab Duo 配置和服务账号预配情况。 |
| `"Could not set up the workspace project…"` | 极狐GitLab 无法在您的命名空间中找到或创建 `duo-workspace` 项目。 | 验证您是否可以在该命名空间中创建项目。您的角色和命名空间的 `project_creation_level` 设置必须允许创建项目。 |
| `"Failed to start the Duo Developer workflow"` 或 `"Something went wrong…"` | 极狐GitLab Duo 任务流触发或执行失败。 | 查看 CI 作业日志和极狐GitLab 集成日志以获取详细信息。 |

<a id="debugging-tips-for-gitlab-duo-mention"></a>

### 极狐GitLab Duo `@mention` 的调试技巧

- 集成日志写入 `integrations_json.log`。每条记录都包含
  `slack_workspace_id` 字段，并且通常包含 `slack_user_id` 和 `channel_id`。按
  `slack_workspace_id` 筛选，以查找与您的工作区相关的记录。
- Sidekiq 工作进程日志（`sidekiq.log`）也包含 `slack_workspace_id` 和 `slack_user_id`
  用于 `Integrations::SlackEventWorker` 作业。使用这些信息来追踪事件是否已
  接收并处理。
- 如果机器人完全无法做出反应或回复，问题可能出在 Slack 集成
  配置或机器人令牌上。检查 `integrations_json.log` 中是否包含
  `"message": "SlackInstallation record has no bot token"` 的记录。如果机器人有反应但随后
  发布错误，则问题出在用户侧的授权门控或命名空间解析上。
- `duo-workspace` 项目在任务流首次运行时自动创建，之后会重复使用。
  如果项目创建失败，请使用您至少具有维护者
  角色的命名空间，或请群组所有者调整 `project_creation_level` 设置。
