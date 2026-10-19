---
stage: Plan
group: Project Management
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
title: Slack 通知（已弃用）
---

<!--- start_remove The following content will be removed on remove_date: '2026-05-16' -->

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: JihuLab.com，私有化部署

{{< /details >}}

> [!warning]
> 此功能在极狐GitLab 15.9 中[已弃用](https://gitlab.com/gitlab-org/gitlab/-/issues/435909)
> 并计划在 19.0 中移除。请改用 [极狐GitLab for Slack 应用](gitlab_slack_application.md)。
> 此更改是一个重大更改。

Slack 通知集成使你的极狐GitLab 项目能够将事件
（例如议题创建）作为通知发送到你现有的 Slack 团队。设置
Slack 通知需要同时对 Slack 和极狐GitLab 进行配置更改。

<a id="configure-slack"></a>

## 配置 Slack

1. 登录你的 Slack 团队并[启动一个新的 Incoming WebHooks 配置](https://my.slack.com/services/new/incoming-webhook)。
1. 确定默认应发送通知的 Slack 频道。
   选择 **添加 Incoming WebHooks 集成** 以添加配置。
1. 复制 **Webhook URL**，稍后在配置极狐GitLab 时使用。

<a id="configure-gitlab"></a>

## 配置极狐GitLab

{{< history >}}

- 在极狐GitLab 15.9 中[更改](https://gitlab.com/gitlab-org/gitlab/-/merge_requests/106760)，将每个事件的 Slack 频道限制为 10 个。

{{< /history >}}

1. 在顶部栏中，选择 **搜索或跳转到** 并找到你的项目。
1. 在左侧边栏中，选择 **设置** > **集成**。
1. 选择 **Slack 通知**。
1. 在 **启用集成** 下，选中 **活跃** 复选框。
1. 在 **触发器** 部分，选中每种要作为通知发送到 Slack 的极狐GitLab
   事件类型的复选框。有关完整列表，请参阅
   [Slack 通知的触发器](#triggers-for-slack-notifications)。
   默认情况下，消息将发送到你在
   [Slack 配置](#configure-slack)期间配置的频道。
1. 可选。要将消息发送到不同的频道、多个频道或作为
   私信：
   - *要将消息发送到频道，* 输入 Slack 频道名称，用逗号分隔。
   - *要发送私信，* 使用在用户的 Slack 个人资料中找到的成员 ID。
1. 在 **Webhook** 中，输入你在
   [Slack 配置](#configure-slack)步骤中复制的 webhook URL。
1. 可选。在 **用户名** 中，输入发送通知的 Slack 机器人的用户名。
1. 选中 **仅通知失败的流水线** 复选框，以仅在失败时通知。
1. 选中 **仅当状态更改时通知** 复选框，以仅在引用的流水线状态更改时发送通知。
1. 在 **要发送通知的分支** 下拉列表中，选择要为其发送通知的分支类型。
1. 将 **要通知的标签** 字段留空以获取所有通知，或
   添加议题或合并请求必须具有的标签以触发
   通知。
1. 可选。选择 **测试设置**。
1. 选择 **保存更改**。

你的 Slack 团队现在开始按配置接收极狐GitLab 事件通知。

<a id="triggers-for-slack-notifications"></a>

## Slack 通知的触发器

以下触发器可用于 Slack 通知：

| 触发器名称                                                              | 触发事件 |
| ------------------------------------------------------------------------- | ------------- |
| **推送**                                                                  | 对仓库的推送。 |
| **议题**                                                                  | 工作项被创建、关闭或重新打开。 |
| **事件**                                                                  | 事件被创建、关闭或重新打开。 |
| **机密议题**                                                              | 机密工作项被创建、关闭或重新打开。 |
| **合并请求**                                                              | 合并请求被创建、合并、批准、关闭或重新打开。 |
| **评论**                                                                  | 添加了评论。 |
| **机密评论**                                                              | 在机密工作项上添加了内部备注或评论。 |
| **标签推送**                                                              | 新标签被推送到仓库或移除。 |
| **流水线**                                                                | 流水线状态更改。 |
| **Wiki 页面**                                                             | Wiki 页面被创建或更新。 |
| **部署**                                                                  | 部署开始或完成。 |
| **警报**                                                                  | 记录了一个新的、唯一的警报。 |
| **公开中的[群组提及](#trigger-notifications-for-group-mentions)**         | 在公开上下文中提及了群组。 |
| **私有中的[群组提及](#trigger-notifications-for-group-mentions)**         | 在机密上下文中提及了群组。 |
| [**漏洞**](../../application_security/vulnerabilities/_index.md)          | 记录了一个新的、唯一的漏洞。 |

<a id="trigger-notifications-for-group-mentions"></a>

## 为群组提及触发通知

{{< history >}}

- 在极狐GitLab 16.4 中[引入](https://gitlab.com/gitlab-org/gitlab/-/issues/417751)。
- 在极狐GitLab 18.3 中[引入](https://gitlab.com/gitlab-org/gitlab/-/merge_requests/134677)了通知触发器的限制，[带有功能标志](../../../administration/feature_flags/_index.md)名为 `group_mention_access_check`。默认禁用。

{{< /history >}}

要触发群组提及的[通知事件](#triggers-for-slack-notifications)，请在以下位置使用 `@<group_name>`：

- 议题和合并请求描述
- 议题、合并请求和提交的评论

仅当所有直接群组成员都有权查看提及所在的资源
（例如合并请求）时，才会触发通知。每个事件最多只会向 3 个群组发送通知。

<a id="troubleshooting"></a>

## 故障排除

如果你的 Slack 集成不工作，请通过
搜索 [Sidekiq 日志](../../../administration/logs/_index.md#sidekiqlog)
中与你的 Slack 服务相关的错误来开始故障排除。

<a id="error-something-went-wrong-on-our-end"></a>

### 错误：`Something went wrong on our end`

你可能会在极狐GitLab UI 中收到此通用错误消息。
查看[日志](../../../administration/logs/_index.md#productionlog)以查找
错误消息并继续从那里进行故障排除。

<a id="error-certificate-verify-failed"></a>

### 错误：`certificate verify failed`

你可能会在 Sidekiq 日志中看到类似以下的条目：

```plaintext
2019-01-10_13:22:08.42572 2019-01-10T13:22:08.425Z 6877 TID-abcdefg Integrations::ExecuteWorker JID-3bade5fb3dd47a85db6d78c5 ERROR: {:class=>"Integrations::ExecuteWorker :integration_class=>"SlackService", :message=>"SSL_connect returned=1 errno=0 state=error: certificate verify failed"}
```

当极狐GitLab 与 Slack 通信或极狐GitLab 与自身通信出现问题时，会发生此问题。
前者不太可能，因为 Slack 安全证书应始终受信任。

要查看这些问题是哪一个导致了问题：

1. 启动 Rails 控制台：

   ```shell
   sudo gitlab-rails console -e production

   # 对于源代码安装：
   bundle exec rails console -e production
   ```

1. 运行以下命令：

   ```ruby
   # 将 <SLACK URL> 替换为你的实际 Slack URL
   result = Net::HTTP.get(URI('https://<SLACK URL>'));0

   # 将 <GITLAB URL> 替换为你的实际极狐GitLab URL
   result = Net::HTTP.get(URI('https://<GITLAB URL>'));0
   ```

如果极狐GitLab 不信任到自身的 HTTPS 连接，
[将你的证书添加到极狐GitLab 受信任的证书](https://gitlab.cn/docs/omnibus/settings/ssl/#install-custom-public-certificates)。

如果极狐GitLab 不信任到 Slack 的连接，
则极狐GitLab OpenSSL 信任存储区不正确。典型原因包括：

- 使用 `gitlab_rails['env'] = {"SSL_CERT_FILE" => "/path/to/file.pem"}` 覆盖信任存储区。
- 意外修改了默认 CA 包 `/opt/gitlab/embedded/ssl/certs/cacert.pem`。

<a id="bulk-update-to-disable-the-slack-notification-integration"></a>

### 批量更新以禁用 Slack 通知集成

要禁用所有启用了 Slack 集成的项目的通知，
[启动 Rails 控制台会话](../../../administration/operations/rails_console.md#starting-a-rails-console-session)并使用类似以下脚本：

> [!warning]
> 更改数据的命令如果未正确运行或在适当条件下运行，可能会导致损坏。始终先在测试环境中运行命令，并准备好备份实例以便恢复。

```ruby
# 获取所有启用了 Slack 通知的项目
p = Project.find_by_sql("SELECT p.id FROM projects p LEFT JOIN integrations s ON p.id = s.project_id WHERE s.type_new = 'Integrations::Slack' AND s.active = true")

# 在找到的每个项目上禁用集成。
p.each do |project|
  project.slack_integration.update!(:active, false)
end
```

<!--- end_remove -->