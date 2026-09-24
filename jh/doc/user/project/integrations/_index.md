---
stage: none
group: unassigned
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
title: 项目集成
description: "User documentation for project and group integrations. Includes a list of available integrations."
---

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: JihuLab.com，私有化部署

{{< /details >}}

> [!note]
> 本页面包含项目集成的用户文档。有关管理员文档，请参阅[项目集成管理](../../../administration/settings/project_integration_management.md)。

你可以与外部应用程序集成，为极狐GitLab 添加功能。

你可以查看和管理以下范围的集成：

- [实例](../../../administration/settings/project_integration_management.md#configure-default-settings-for-an-integration)（私有化部署）
- [群组](#manage-group-default-settings-for-a-project-integration)

你可以使用：

- [项目集成的实例或群组默认设置](#use-instance-or-group-default-settings-for-a-project-integration)
- [项目或群组集成的自定义设置](#use-custom-settings-for-a-project-or-group-integration)

<a id="manage-group-default-settings-for-a-project-integration"></a>

## 管理项目集成的群组默认设置

先决条件：

- 你必须具有群组的所有者角色。

要管理项目集成的群组默认设置：

1. 在顶部栏，选择 **搜索或跳转到** 并找到你的群组。
1. 在左侧边栏，选择 **设置** > **集成**。
1. 选择一个集成。
1. 填写字段。
1. 选择 **保存更改**。

> [!warning]
> 这可能会影响属于该群组的所有或大部分子群组和项目。请查看以下详情。

如果这是你首次为集成设置群组设置：

- 如果你在群组设置中打开了 **启用集成** 切换开关，则该集成会对所有尚未配置此集成的属于该群组的子群组和项目启用。
- 已配置该集成的子群组和项目不受影响，但可以随时选择使用继承的设置。

当你进一步更改群组默认设置时：

- 它们会立即应用于所有设置了使用默认设置的属于该群组的子群组和项目。
- 它们会立即应用于较新的子群组和项目，即使是在你上次保存集成默认设置之后创建的也是如此。如果你的群组默认设置打开了 **启用集成** 切换开关，则该集成会自动为所有这些子群组和项目启用。
- 为集成选择了自定义设置的项目和子群组不会立即受到影响，并且可以随时选择使用最新的默认设置。

如果同一集成也配置了[实例设置](../../../administration/settings/project_integration_management.md#configure-default-settings-for-an-integration)，则群组中的项目将从群组继承设置。

只能继承集成的完整设置。按字段继承在[史诗 2137](https://jihulab.com/gitlab-cn/-/epics/2137) 中提出。

<a id="remove-a-group-default-setting"></a>

### 移除群组默认设置

先决条件：

- 你必须具有群组的所有者角色。

要移除群组默认设置：

1. 在顶部栏，选择 **搜索或跳转到** 并找到你的群组。
1. 在左侧边栏，选择 **设置** > **集成**。
1. 选择一个集成。
1. 选择 **重置** 并确认。

重置群组默认设置会移除使用默认设置且属于该群组项目或子群组的集成。

<a id="use-instance-or-group-default-settings-for-a-project-integration"></a>

## 使用实例或群组默认设置进行项目集成

先决条件：

- 你必须具有项目的维护者或所有者角色。

要使用实例或群组默认设置进行项目集成：

1. 在顶部栏，选择 **搜索或跳转到** 并找到你的项目。
1. 在左侧边栏，选择 **设置** > **集成**。
1. 选择一个集成。
1. 在右侧，从下拉列表中选择 **使用默认设置**。
1. 在 **启用集成** 下，确保勾选了 **活跃** 复选框。
1. 填写字段。
1. 选择 **保存更改**。

<a id="use-custom-settings-for-a-project-or-group-integration"></a>

## 使用自定义设置进行项目或群组集成

先决条件：

- 对于项目集成，你必须具有维护者或所有者角色。
- 对于群组集成，你必须具有所有者角色。

要使用自定义设置进行项目或群组集成：

1. 在顶部栏，选择 **搜索或跳转到** 并找到你的项目或群组。
1. 在左侧边栏，选择 **设置** > **集成**。
1. 选择一个集成。
1. 在右侧，从下拉列表中选择 **使用自定义设置**。
1. 在 **启用集成** 下，确保勾选了 **活跃** 复选框。
1. 填写字段。
1. 选择 **保存更改**。

<a id="available-integrations"></a>

## 可用集成

以下集成可在极狐GitLab 实例上使用。
如果实例管理员配置了[集成允许列表](../../../administration/settings/project_integration_management.md#integration-allowlist)，则仅有列表中的集成可用。

<a id="cicd"></a>

### CI/CD

| 集成 | 描述 | 集成钩子 |
|------|------|----------|
| [Atlassian Bamboo](bamboo.md) | 使用 Atlassian Bamboo 运行 CI/CD 流水线。 | {{< yes >}} |
| Buildkite | 使用 Buildkite 运行 CI/CD 流水线。 | {{< yes >}} |
| Drone | 使用 Drone 运行 CI/CD 流水线。 | {{< yes >}} |
| [Jenkins](../../../integration/jenkins.md) | 使用 Jenkins 运行 CI/CD 流水线。 | {{< yes >}} |
| JetBrains TeamCity | 使用 TeamCity 运行 CI/CD 流水线。 | {{< yes >}} |

<a id="event-notifications"></a>

### 事件通知

这些集成都没有集成钩子。

| 集成 | 描述 |
|------|------|
| Campfire | 连接 Campfire 进行聊天。 |
| [Discord Notifications](discord_notifications.md) | 将项目事件的通知发送到 Discord 频道。 |
| [Google Chat](hangouts_chat.md) | 从你的极狐GitLab 项目向 Google Chat 空间发送通知。 |
| [irker (IRC gateway)](irker.md) | 向 IRC 频道发送事件通知。 |
| [Matrix notifications](matrix.md) | 将项目事件的通知发送到 Matrix。 |
| [Mattermost notifications](mattermost.md) | 将项目事件的通知发送到 Mattermost 频道。 |
| [Microsoft Teams notifications](microsoft_teams.md) | 将事件通知发送到 Microsoft Teams。 |
| [Pumble](pumble.md) | 将事件通知发送到 Pumble 频道。 |
| Pushover | 将事件通知发送到你的设备。 |
| [Telegram](telegram.md) | 将项目事件的通知发送到 Telegram。 |
| [Unify Circuit](unify_circuit.md) | 将项目事件的通知发送到 Unify Circuit。 |
| [Webex Teams](webex_teams.md) | 将事件通知发送到 Webex Teams。 |

<a id="stores"></a>

### 商店

| 集成 | 描述 | 集成钩子 |
|------|------|----------|
| [Apple App Store Connect](apple_app_store.md) | 使用极狐GitLab 在 Apple App Store 中构建和发布应用。 | {{< no >}} |
| [Google Play](google_play.md) | 使用极狐GitLab 在 Google Play 中构建和发布应用。 | {{< no >}} |
| [Harbor](harbor.md) | 使用 Harbor 作为极狐GitLab 的容器镜像仓库。 | {{< no >}} |
| Packagist | 在 Packagist 中更新你的 PHP 依赖项。 | {{< yes >}} |

<a id="external-issue-trackers"></a>

### 外部议题跟踪器

以下集成在你的项目左侧边栏中添加指向[外部议题跟踪器](../../../integration/external-issue-tracker.md)的链接。这些集成都没有集成钩子。

| 集成 | 描述 | 议题同步 | 可以创建新议题 |
|------|------|----------|----------------|
| [Bugzilla](bugzilla.md) | 使用 Bugzilla 作为议题跟踪器。 | {{< no >}} | {{< yes >}} |
| [ClickUp](clickup.md) | 使用 ClickUp 作为议题跟踪器。 | {{< no >}} | {{< no >}} |
| [Custom issue tracker](custom_issue_tracker.md) | 使用自定义议题跟踪器。 | {{< no >}} | {{< no >}} |
| [Engineering Workflow Management (EWM)](ewm.md) | 使用 EWM 作为议题跟踪器。 | {{< no >}} | {{< yes >}} |
| [Linear](linear.md) | 使用 Linear 作为议题跟踪器。 | {{< no >}} | {{< no >}} |
| [Phorge](phorge.md) | 使用 Phorge 作为议题跟踪器。 | {{< no >}} | {{< yes >}} |
| [Redmine](redmine.md) | 使用 Redmine 作为议题跟踪器。 | {{< no >}} | {{< yes >}} |
| [YouTrack](youtrack.md) | 使用 JetBrains YouTrack 作为你项目的议题跟踪器。 | {{< yes >}} | {{< no >}} |

<a id="external-wikis"></a>

### 外部 Wiki

以下集成在你的项目左侧边栏中添加指向外部 Wiki 的链接。这些集成都没有集成钩子。

| 集成 | 描述 |
|------|------|
| [Confluence Workspace](confluence.md) | 使用 Confluence Cloud Workspace 作为内部 Wiki。 |
| [External wiki](../wiki/_index.md#link-an-external-wiki) | 链接一个外部 Wiki。 |

<a id="other"></a>

### 其他

| 集成 | 描述 | 集成钩子 |
|------|------|----------|
| [Asana](asana.md) | 将提交消息作为评论添加到 Asana 任务。 | {{< no >}} |
| Assembla | 使用 Assembla 管理项目。 | {{< no >}} |
| [Beyond Identity](beyond_identity.md) | 验证 GPG 密钥是否由 Beyond Identity Authenticator 授权。 | {{< no >}} |
| [Datadog](../../../integration/datadog.md) | 使用 Datadog 跟踪你的极狐GitLab 流水线。 | {{< yes >}} |
| [Diffblue Cover](../../../integration/diffblue_cover.md) | 自动编写全面、类似人类的 Java 单元测试。 | {{< yes >}} |
| [Emails on push](emails_on_push.md) | 通过电子邮件发送推送时的提交和差异。 | {{< no >}} |
| [GitGuardian](git_guardian.md) | 根据 GitGuardian 策略拒绝提交。 | {{< no >}} |
| [GitHub](github.md) | 接收提交和拉取请求的状态。 | {{< no >}} |
| [GitLab for Slack app](gitlab_slack_application.md) | 使用原生 Slack 应用接收通知并运行命令。 | {{< no >}} |
| [Google Artifact Management](google_artifact_management.md) | 在 Google Artifact Registry 中管理你的产物。 | {{< no >}} |
| [Google Cloud IAM](../../../integration/google_cloud_iam.md) | 使用 Identity and Access Management (IAM) 管理 Google Cloud 资源的权限。 | {{< no >}} |
| [Jira](../../../integration/jira/_index.md) | 使用 Jira 作为议题跟踪器。 | {{< no >}} |
| [Mattermost slash commands](mattermost_slash_commands.md) | 从 Mattermost 聊天环境中运行斜杠命令。 | {{< no >}} |
| [Pipeline status emails](pipeline_status_emails.md) | 通过电子邮件将流水线状态发送给收件人列表。 | {{< no >}} |
| [Pivotal Tracker](pivotal_tracker.md) | 将提交消息作为评论添加到 Pivotal Tracker 故事。 | {{< no >}} |
| [Squash TM](squash_tm.md) | 当极狐GitLab 议题被修改时，更新 Squash TM 需求。 | {{< yes >}} |

<a id="project-webhooks"></a>

## 项目 Webhook

一些集成使用 [Webhook](webhooks.md) 与外部应用程序交互。

你可以配置项目 Webhook 监听特定事件，如推送、议题或合并请求。当 Webhook 被触发时，极狐GitLab 会向指定的 Webhook URL 发送带数据的 POST 请求。

有关使用 Webhook 的集成列表，请参阅[可用集成](#available-integrations)。

<a id="push-hook-limit"></a>

## 推送钩子限制

如果一次推送包含对超过三个分支或标签的更改，则不会执行由 `push_hooks` 和 `tag_push_hooks` 事件支持的集成。

要更改支持的分支或标签数量，请配置 [`push_event_hooks_limit` 设置](../../../api/settings.md#available-settings)。

<a id="ssl-verification"></a>

## SSL 验证

默认情况下，针对外发 HTTP 请求的 SSL 证书会基于内部证书颁发机构列表进行验证。SSL 证书不能是自签名的。

在配置 [Webhook](webhooks.md#configure-webhooks) 和某些集成时，你可以禁用 SSL 验证。

<a id="related-topics"></a>

## 相关主题

- [集成 API](../../../api/project_integrations.md)
- [极狐GitLab 开发者门户](https://developer.gitlab.com)