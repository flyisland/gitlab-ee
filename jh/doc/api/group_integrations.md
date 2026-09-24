---
stage: none
group: unassigned
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
title: 群组集成 API
description: "使用 REST API 设置和管理群组的集成。"
---

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: JihuLab.com，私有化部署

{{< /details >}}

{{< history >}}

- 在极狐GitLab 17.9 中[引入](https://gitlab.com/gitlab-org/gitlab/-/issues/328496)。

{{< /history >}}

使用此 API 管理群组及其子群组的[集成](../user/project/integrations/_index.md)。

前提条件：

- 您必须拥有群组的维护者或所有者角色。

<a id="list-all-active-integrations"></a>

## 列出所有活跃集成

获取所有活跃群组集成的列表。`vulnerability_events` 字段仅在极狐GitLab 企业版中可用。

```plaintext
GET /groups/:id/integrations
```

示例响应：

```json
[
  {
    "id": 75,
    "title": "Jenkins CI",
    "slug": "jenkins",
    "created_at": "2019-11-20T11:20:25.297Z",
    "updated_at": "2019-11-20T12:24:37.498Z",
    "active": true,
    "commit_events": true,
    "push_events": true,
    "issues_events": true,
    "alert_events": true,
    "confidential_issues_events": true,
    "merge_requests_events": true,
    "tag_push_events": false,
    "deployment_events": false,
    "note_events": true,
    "confidential_note_events": true,
    "pipeline_events": true,
    "wiki_page_events": true,
    "job_events": true,
    "comment_on_event_enabled": true,
    "inherited": false,
    "vulnerability_events": true
  },
  {
    "id": 76,
    "title": "Alerts endpoint",
    "slug": "alerts",
    "created_at": "2019-11-20T11:20:25.297Z",
    "updated_at": "2019-11-20T12:24:37.498Z",
    "active": true,
    "commit_events": true,
    "push_events": true,
    "issues_events": true,
    "alert_events": true,
    "confidential_issues_events": true,
    "merge_requests_events": true,
    "tag_push_events": true,
    "deployment_events": false,
    "note_events": true,
    "confidential_note_events": true,
    "pipeline_events": true,
    "wiki_page_events": true,
    "job_events": true,
    "comment_on_event_enabled": true,
    "inherited": false,
    "vulnerability_events": true
  }
]
```

<a id="asana"></a>

## Asana

<a id="set-up-asana"></a>

### 设置 Asana

为群组设置 Asana 集成。

```plaintext
PUT /groups/:id/integrations/asana
```

参数：

| 参数 | 类型 | 是否必需 | 描述 |
| --------- | ---- | -------- | ----------- |
| `api_key` | string | 是 | 用户 API 令牌。该用户必须有权访问任务。所有评论都将归属于此用户。 |
| `restrict_to_branch` | string | 否 | 要自动检查的分支的逗号分隔列表。留空以包含所有分支。 |
| `use_inherited_settings` | boolean | 否 | 指示是否继承默认设置。默认为 `false`。 |

<a id="disable-asana"></a>

### 禁用 Asana

禁用群组的 Asana 集成。集成设置将被重置。

```plaintext
DELETE /groups/:id/integrations/asana
```

<a id="get-asana-settings"></a>

### 获取 Asana 设置

获取群组的 Asana 集成设置。

```plaintext
GET /groups/:id/integrations/asana
```

<a id="assembla"></a>

## Assembla

<a id="set-up-assembla"></a>

### 设置 Assembla

为群组设置 Assembla 集成。

```plaintext
PUT /groups/:id/integrations/assembla
```

参数：

| 参数 | 类型 | 是否必需 | 描述 |
| --------- | ---- | -------- | ----------- |
| `token` | string | 是 | 认证令牌。 |
| `subdomain` | string | 否 | 子域名设置。 |
| `use_inherited_settings` | boolean | 否 | 指示是否继承默认设置。默认为 `false`。 |

<a id="disable-assembla"></a>

### 禁用 Assembla

禁用群组的 Assembla 集成。集成设置将被重置。

```plaintext
DELETE /groups/:id/integrations/assembla
```

<a id="get-assembla-settings"></a>

### 获取 Assembla 设置

获取群组的 Assembla 集成设置。

```plaintext
GET /groups/:id/integrations/assembla
```

<a id="atlassian-bamboo"></a>

## Atlassian Bamboo

<a id="set-up-atlassian-bamboo"></a>

### 设置 Atlassian Bamboo

为群组设置 Atlassian Bamboo 集成。

您必须在 Bamboo 中配置自动修订标记和仓库触发器。

```plaintext
PUT /groups/:id/integrations/bamboo
```

参数：

| 参数 | 类型 | 是否必需 | 描述 |
| --------- | ---- | -------- | ----------- |
| `bamboo_url` | string | 是 | Bamboo 根 URL（例如，`https://bamboo.example.com`）。 |
| `enable_ssl_verification` | boolean | 否 | 启用 SSL 验证。默认为 `true`（启用）。 |
| `build_key` | string | 是 | Bamboo 构建计划键（例如，`KEY`）。 |
| `username` | string | 是 | 具有 Bamboo 服务器 API 访问权限的用户。 |
| `password` | string | 是 | 该用户的密码。 |
| `use_inherited_settings` | boolean | 否 | 指示是否继承默认设置。默认为 `false`。 |

<a id="disable-atlassian-bamboo"></a>

### 禁用 Atlassian Bamboo

禁用群组的 Atlassian Bamboo 集成。集成设置将被重置。

```plaintext
DELETE /groups/:id/integrations/bamboo
```

<a id="get-atlassian-bamboo-settings"></a>

### 获取 Atlassian Bamboo 设置

获取群组的 Atlassian Bamboo 集成设置。

```plaintext
GET /groups/:id/integrations/bamboo
```

<a id="bugzilla"></a>

## Bugzilla

<a id="set-up-bugzilla"></a>

### 设置 Bugzilla

为群组设置 Bugzilla 集成。

```plaintext
PUT /groups/:id/integrations/bugzilla
```

参数：

| 参数 | 类型 | 是否必需 | 描述 |
| --------- | ---- | -------- | ----------- |
| `new_issue_url` | string | 是 | 新议题的 URL。 |
| `issues_url` | string | 是 | 议题的 URL。 |
| `project_url` | string | 是 | 项目的 URL。 |
| `use_inherited_settings` | boolean | 否 | 指示是否继承默认设置。默认为 `false`。 |

<a id="disable-bugzilla"></a>

### 禁用 Bugzilla

禁用群组的 Bugzilla 集成。集成设置将被重置。

```plaintext
DELETE /groups/:id/integrations/bugzilla
```

<a id="get-bugzilla-settings"></a>

### 获取 Bugzilla 设置

获取群组的 Bugzilla 集成设置。

```plaintext
GET /groups/:id/integrations/bugzilla
```

<a id="buildkite"></a>

## Buildkite

<a id="set-up-buildkite"></a>

### 设置 Buildkite

为群组设置 Buildkite 集成。

```plaintext
PUT /groups/:id/integrations/buildkite
```

参数：

| 参数 | 类型 | 是否必需 | 描述 |
| --------- | ---- | -------- | ----------- |
| `token` | string | 是 | Buildkite 项目极狐GitLab 令牌。 |
| `project_url` | string | 是 | 流水线 URL（例如，`https://buildkite.com/example/pipeline`）。 |
| `enable_ssl_verification` | boolean | 否 | **已弃用**：此参数无效，因为 SSL 验证始终启用。 |
| `push_events` | boolean | 否 | 为推送事件启用通知。 |
| `merge_requests_events` | boolean | 否 | 为合并请求事件启用通知。 |
| `tag_push_events` | boolean | 否 | 为标签推送事件启用通知。 |
| `use_inherited_settings` | boolean | 否 | 指示是否继承默认设置。默认为 `false`。 |

<a id="disable-buildkite"></a>

### 禁用 Buildkite

禁用群组的 Buildkite 集成。集成设置将被重置。

```plaintext
DELETE /groups/:id/integrations/buildkite
```

<a id="get-buildkite-settings"></a>

### 获取 Buildkite 设置

获取群组的 Buildkite 集成设置。

```plaintext
GET /groups/:id/integrations/buildkite
```

<a id="campfire-classic"></a>

## Campfire Classic

您可以通过 Campfire Classic 进行集成。但是，Campfire Classic 是一款旧产品，Basecamp 已[不再销售](https://gitlab.com/gitlab-org/gitlab/-/issues/329337)。

<a id="set-up-campfire-classic"></a>

### 设置 Campfire Classic

为群组设置 Campfire Classic 集成。

```plaintext
PUT /groups/:id/integrations/campfire
```

参数：

| 参数     | 类型    | 是否必需 | 描述                                                                                 |
|---------------|---------|----------|---------------------------------------------------------------------------------------------|
| `token`       | string  | 是     | 来自 Campfire Classic 的 API 认证令牌。要获取令牌，请登录 Campfire Classic 并选择 **My info**。 |
| `subdomain`   | string  | 否    | 登录时的 `.campfirenow.com` 子域名。 |
| `room`        | string  | 否    | Campfire Classic 房间 URL 的 ID 部分。 |
| `use_inherited_settings` | boolean | 否 | 指示是否继承默认设置。默认为 `false`。 |

<a id="disable-campfire-classic"></a>

### 禁用 Campfire Classic

禁用群组的 Campfire Classic 集成。集成设置将被重置。

```plaintext
DELETE /groups/:id/integrations/campfire
```

<a id="get-campfire-classic-settings"></a>

### 获取 Campfire Classic 设置

获取群组的 Campfire Classic 集成设置。

```plaintext
GET /groups/:id/integrations/campfire
```

<a id="clickup"></a>

## ClickUp

<a id="set-up-clickup"></a>

### 设置 ClickUp

为群组设置 ClickUp 集成。

```plaintext
PUT /groups/:id/integrations/clickup
```

参数：

| 参数     | 类型   | 是否必需 | 描述    |
| ------------- | ------ | -------- | -------------- |
| `issues_url`  | string | 是     | 议题的 URL。     |
| `project_url` | string | 是     | 项目的 URL。   |
| `use_inherited_settings` | boolean | 否 | 指示是否继承默认设置。默认为 `false`。 |

<a id="disable-clickup"></a>

### 禁用 ClickUp

禁用群组的 ClickUp 集成。集成设置将被重置。

```plaintext
DELETE /groups/:id/integrations/clickup
```

<a id="get-clickup-settings"></a>

### 获取 ClickUp 设置

获取群组的 ClickUp 集成设置。

```plaintext
GET /groups/:id/integrations/clickup
```

<a id="confluence-workspace"></a>

## Confluence Workspace

<a id="set-up-confluence-workspace"></a>

### 设置 Confluence Workspace

为群组设置 Confluence Workspace 集成。

```plaintext
PUT /groups/:id/integrations/confluence
```

参数：

| 参数 | 类型 | 是否必需 | 描述 |
| --------- | ---- | -------- | ----------- |
| `confluence_url` | string | 是 | 托管在 `atlassian.net` 上的 Confluence Workspace URL。 |
| `use_inherited_settings` | boolean | 否 | 指示是否继承默认设置。默认为 `false`。 |

<a id="disable-confluence-workspace"></a>

### 禁用 Confluence Workspace

禁用群组的 Confluence Workspace 集成。集成设置将被重置。

```plaintext
DELETE /groups/:id/integrations/confluence
```

<a id="get-confluence-workspace-settings"></a>

### 获取 Confluence Workspace 设置

获取群组的 Confluence Workspace 集成设置。

```plaintext
GET /groups/:id/integrations/confluence
```

<a id="custom-issue-tracker"></a>

## 自定义议题追踪器

<a id="set-up-a-custom-issue-tracker"></a>

### 设置自定义议题追踪器

为群组设置自定义议题追踪器。

```plaintext
PUT /groups/:id/integrations/custom-issue-tracker
```

参数：

| 参数 | 类型 | 是否必需 | 描述 |
| --------- | ---- | -------- | ----------- |
| `new_issue_url` | string | 是 | 新议题的 URL。 |
| `issues_url` | string | 是 | 议题的 URL。 |
| `project_url` | string | 是 | 项目的 URL。 |
| `use_inherited_settings` | boolean | 否 | 指示是否继承默认设置。默认为 `false`。 |

<a id="disable-a-custom-issue-tracker"></a>

### 禁用自定义议题追踪器

禁用群组的自定义议题追踪器。集成设置将被重置。

```plaintext
DELETE /groups/:id/integrations/custom-issue-tracker
```

<a id="get-custom-issue-tracker-settings"></a>

### 获取自定义议题追踪器设置

获取群组的自定义议题追踪器设置。

```plaintext
GET /groups/:id/integrations/custom-issue-tracker
```

<a id="datadog"></a>

## Datadog

<a id="set-up-datadog"></a>

### 设置 Datadog

为群组设置 Datadog 集成。

```plaintext
PUT /groups/:id/integrations/datadog
```

参数：

| 参数              | 类型    | 是否必需 | 描述                                                                                                                                                                            |
|------------------------|---------|----------|----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| `api_key`              | string  | 是     | 用于 Datadog 认证的 API 密钥。                                                                                                                                          |
| `api_url`              | string  | 否    | （高级）您的 Datadog 站点的完整 URL。                                                                                                                                          |
| `datadog_env`          | string  | 否    | 对于私有化部署，设置发送到 Datadog 的所有数据的 `env%` 标签。                                                                                                      |
| `datadog_service`      | string  | 否    | 在 Datadog 中标记来自此极狐GitLab 实例的所有数据。在管理多个私有化部署时使用。                                                                          |
| `datadog_site`         | string  | 否    | 要将数据发送到的 Datadog 站点。要将数据发送到 EU 站点，请使用 `datadoghq.eu`。                                                                                                      |
| `datadog_tags`         | string  | 否    | Datadog 中的自定义标签。指定格式为 `key:value\nkey2:value2` 的每行一个标签                                                                                                 |
| `archive_trace_events` | boolean | 否    | 启用后，作业日志将由 Datadog 收集并与流水线执行追踪一起显示。 |
| `use_inherited_settings` | boolean | 否 | 指示是否继承默认设置。默认为 `false`。 |

<a id="disable-datadog"></a>

### 禁用 Datadog

禁用群组的 Datadog 集成。集成设置将被重置。

```plaintext
DELETE /groups/:id/integrations/datadog
```

<a id="get-datadog-settings"></a>

### 获取 Datadog 设置

获取群组的 Datadog 集成设置。

```plaintext
GET /groups/:id/integrations/datadog
```

<a id="diffblue-cover"></a>

## Diffblue Cover

<a id="set-up-diffblue-cover"></a>

### 设置 Diffblue Cover

为群组设置 Diffblue Cover 集成。

```plaintext
PUT /groups/:id/integrations/diffblue-cover
```

参数：

| 参数 | 类型 | 是否必需 | 描述 |
| --------- | ---- | -------- | ----------- |
| `diffblue_license_key` | string | 是 | Diffblue Cover 许可证密钥。 |
| `diffblue_access_token_name` | string | 是 | 在流水线中由 Diffblue Cover 使用的访问令牌名称。 |
| `diffblue_access_token_secret` | string  | 是 | 在流水线中由 Diffblue Cover 使用的访问令牌密钥。 |
| `use_inherited_settings` | boolean | 否 | 指示是否继承默认设置。默认为 `false`。 |

<a id="disable-diffblue-cover"></a>

### 禁用 Diffblue Cover

禁用群组的 Diffblue Cover 集成。集成设置将被重置。

```plaintext
DELETE /groups/:id/integrations/diffblue-cover
```

<a id="get-diffblue-cover-settings"></a>

### 获取 Diffblue Cover 设置

获取群组的 Diffblue Cover 集成设置。

```plaintext
GET /groups/:id/integrations/diffblue-cover
```

<a id="discord-notifications"></a>

## Discord Notifications

<a id="set-up-discord-notifications"></a>

### 设置 Discord 通知

为群组设置 Discord 通知。

```plaintext
PUT /groups/:id/integrations/discord
```

参数：

| 参数 | 类型 | 是否必需 | 描述 |
| --------- | ---- | -------- | ----------- |
| `webhook` | string | 是 | Discord webhook（例如，`https://discord.com/api/webhooks/...`）。 |
| `branches_to_be_notified` | string | 否 | 要发送通知的分支。有效选项为 `all`、`default`、`protected` 和 `default_and_protected`。默认值为 `default`。 |
| `confidential_issues_events` | boolean | 否 | 为机密议题事件启用通知。 |
| `confidential_issue_channel` | string | 否 | 用于接收机密议题事件通知的 webhook 覆盖。 |
| `confidential_note_events` | boolean | 否 | 为机密评论事件启用通知。 |
| `confidential_note_channel` | string | 否 | 用于接收机密评论事件通知的 webhook 覆盖。 |
| `deployment_events` | boolean | 否 | 为部署事件启用通知。 |
| `deployment_channel` | string | 否 | 用于接收部署事件通知的 webhook 覆盖。 |
| `group_confidential_mentions_events` | boolean | 否 | 为群组机密提及事件启用通知。 |
| `group_confidential_mentions_channel` | string | 否 | 用于接收群组机密提及事件通知的 webhook 覆盖。 |
| `group_mentions_events` | boolean | 否 | 为群组提及事件启用通知。 |
| `group_mentions_channel` | string | 否 | 用于接收群组提及事件通知的 webhook 覆盖。 |
| `issues_events` | boolean | 否 | 为议题事件启用通知。 |
| `issue_channel` | string | 否 | 用于接收议题事件通知的 webhook 覆盖。 |
| `merge_requests_events` | boolean | 否 | 为合并请求事件启用通知。 |
| `merge_request_channel` | string | 否 | 用于接收合并请求事件通知的 webhook 覆盖。 |
| `note_events` | boolean | 否 | 为评论事件启用通知。 |
| `note_channel` | string | 否 | 用于接收评论事件通知的 webhook 覆盖。 |
| `notify_only_broken_pipelines` | boolean | 否 | 仅为损坏的流水线发送通知。 |
| `notify_only_when_pipeline_status_changes` | boolean | 否 | 仅当 ref 的流水线状态更改时发送通知。 |
| `pipeline_events` | boolean | 否 | 为流水线事件启用通知。 |
| `pipeline_channel` | string | 否 | 用于接收流水线事件通知的 webhook 覆盖。 |
| `push_events` | boolean | 否 | 为推送事件启用通知。 |
| `push_channel` | string | 否 | 用于接收推送事件通知的 webhook 覆盖。 |
| `tag_push_events` | boolean | 否 | 为标签推送事件启用通知。 |
| `tag_push_channel` | string | 否 | 用于接收标签推送事件通知的 webhook 覆盖。 |
| `wiki_page_events` | boolean | 否 | 为 Wiki 页面事件启用通知。 |
| `wiki_page_channel` | string | 否 | 用于接收 Wiki 页面事件通知的 webhook 覆盖。 |
| `use_inherited_settings` | boolean | 否 | 指示是否继承默认设置。默认为 `false`。 |

<a id="disable-discord-notifications"></a>

### 禁用 Discord 通知

禁用群组的 Discord 通知。集成设置将被重置。

```plaintext
DELETE /groups/:id/integrations/discord
```

<a id="get-discord-notifications-settings"></a>

### 获取 Discord 通知设置

获取群组的 Discord 通知设置。

```plaintext
GET /groups/:id/integrations/discord
```

<a id="drone"></a>

## Drone

<a id="set-up-drone"></a>

### 设置 Drone

为群组设置 Drone 集成。

```plaintext
PUT /groups/:id/integrations/drone-ci
```

参数：

| 参数 | 类型 | 是否必需 | 描述 |
| --------- | ---- | -------- | ----------- |
| `token` | string | 是 | Drone CI 项目特定令牌。 |
| `drone_url` | string | 是 | `http://drone.example.com`。 |
| `enable_ssl_verification` | boolean | 否 | 启用 SSL 验证。默认为 `true`（启用）。 |
| `push_events` | boolean | 否 | 为推送事件启用通知。 |
| `merge_requests_events` | boolean | 否 | 为合并请求事件启用通知。 |
| `tag_push_events` | boolean | 否 | 为标签推送事件启用通知。 |
| `use_inherited_settings` | boolean | 否 | 指示是否继承默认设置。默认为 `false`。 |

<a id="disable-drone"></a>

### 禁用 Drone

禁用群组的 Drone 集成。集成设置将被重置。

```plaintext
DELETE /groups/:id/integrations/drone-ci
```

<a id="get-drone-settings"></a>

### 获取 Drone 设置

获取群组的 Drone 集成设置。

```plaintext
GET /groups/:id/integrations/drone-ci
```

<a id="emails-on-push"></a>

## 推送时的电子邮件

<a id="set-up-emails-on-push"></a>

### 设置推送时的电子邮件

为群组设置推送时的电子邮件集成。

```plaintext
PUT /groups/:id/integrations/emails-on-push
```

参数：

| 参数 | 类型 | 是否必需 | 描述 |
| --------- | ---- | -------- | ----------- |
| `recipients` | string | 是 | 用空格分隔的电子邮件地址。 |
| `disable_diffs` | boolean | 否 | 禁用代码差异。 |
| `send_from_committer_email` | boolean | 否 | 从提交者处发送。 |
| `push_events` | boolean | 否 | 为推送事件启用通知。 |
| `tag_push_events` | boolean | 否 | 为标签推送事件启用通知。 |
| `branches_to_be_notified` | string | 否 | 要发送通知的分支。有效选项为 `all`、`default`、`protected` 和 `default_and_protected`。标签推送总是会触发通知。默认值为 `all`。 |
| `use_inherited_settings` | boolean | 否 | 指示是否继承默认设置。默认为 `false`。 |

<a id="disable-emails-on-push"></a>

### 禁用推送时的电子邮件

禁用群组的推送时的电子邮件集成。集成设置将被重置。

```plaintext
DELETE /groups/:id/integrations/emails-on-push
```

<a id="get-emails-on-push-settings"></a>

### 获取推送时的电子邮件设置

获取群组的推送时的电子邮件集成设置。

```plaintext
GET /groups/:id/integrations/emails-on-push
```

<a id="engineering-workflow-management-ewm"></a>

## Engineering Workflow Management (EWM)

<a id="set-up-ewm"></a>

### 设置 EWM

为群组设置 EWM 集成。

```plaintext
PUT /groups/:id/integrations/ewm
```

参数：

| 参数 | 类型 | 是否必需 | 描述 |
| --------- | ---- | -------- | ----------- |
| `new_issue_url` | string | 是 | 新议题的 URL。 |
| `project_url`   | string | 是 | 项目的 URL。 |
| `issues_url`    | string | 是 | 议题的 URL。 |
| `use_inherited_settings` | boolean | 否 | 指示是否继承默认设置。默认为 `false`。 |

<a id="disable-ewm"></a>

### 禁用 EWM

禁用群组的 EWM 集成。集成设置将被重置。

```plaintext
DELETE /groups/:id/integrations/ewm
```

<a id="get-ewm-settings"></a>

### 获取 EWM 设置

获取群组的 EWM 集成设置。

```plaintext
GET /groups/:id/integrations/ewm
```

<a id="external-wiki"></a>

## 外部 Wiki

<a id="set-up-an-external-wiki"></a>

### 设置外部 Wiki

为群组设置外部 Wiki。

```plaintext
PUT /groups/:id/integrations/external-wiki
```

参数：

| 参数 | 类型 | 是否必需 | 描述 |
| --------- | ---- | -------- | ----------- |
| `external_wiki_url` | string | 是 | 外部 Wiki 的 URL。 |
| `use_inherited_settings` | boolean | 否 | 指示是否继承默认设置。默认为 `false`。 |

<a id="disable-an-external-wiki"></a>

### 禁用外部 Wiki

禁用群组的外部 Wiki。集成设置将被重置。

```plaintext
DELETE /groups/:id/integrations/external-wiki
```

<a id="get-external-wiki-settings"></a>

### 获取外部 Wiki 设置

获取群组的外部 Wiki 设置。

```plaintext
GET /groups/:id/integrations/external-wiki
```

<a id="gitguardian"></a>

## GitGuardian

{{< details >}}

- Tier: 专业版，旗舰版
- Offering: 私有化部署

{{< /details >}}

> [!FLAG]
> 在极狐GitLab 私有化部署上，此功能默认可用。要隐藏该功能，请管理员[禁用功能标志](../administration/feature_flags/_index.md) `git_guardian_integration`。
> 在 JihuLab.com 上，此功能不可用。在 GitLab Dedicated 上，此功能可用。

[GitGuardian](https://www.gitguardian.com/) 是一个网络安全服务，可以检测源代码仓库中的敏感数据，例如 API 密钥和密码。它会扫描 Git 仓库，对策略违规发出警报，并帮助组织在黑客利用安全问题之前修复它们。

您可以配置极狐GitLab 根据 GitGuardian 策略拒绝提交。

有关已知问题和故障排除步骤，请参阅 [GitGuardian 故障排除](../user/project/integrations/git_guardian.md#troubleshooting)。

<a id="set-up-gitguardian"></a>

### 设置 GitGuardian

为群组设置 GitGuardian 集成。

```plaintext
PUT /groups/:id/integrations/git-guardian
```

参数：

| 参数 | 类型 | 是否必需 | 描述                                   |
| --------- | ---- | -------- |-----------------------------------------------|
| `token` | string | 是 | 具有 `scan` 作用域的 GitGuardian API 令牌。 |
| `use_inherited_settings` | boolean | 否 | 指示是否继承默认设置。默认为 `false`。 |

<a id="disable-gitguardian"></a>

### 禁用 GitGuardian

禁用群组的 GitGuardian 集成。集成设置将被重置。

```plaintext
DELETE /groups/:id/integrations/git-guardian
```

<a id="get-gitguardian-settings"></a>

### 获取 GitGuardian 设置

获取群组的 GitGuardian 集成设置。

```plaintext
GET /groups/:id/integrations/git-guardian
```

<a id="github"></a>

## GitHub

{{< details >}}

- Tier: 专业版，旗舰版
- Offering: JihuLab.com，私有化部署

{{< /details >}}

<a id="set-up-github"></a>

### 设置 GitHub

为群组设置 GitHub 集成。

```plaintext
PUT /groups/:id/integrations/github
```

参数：

| 参数 | 类型 | 是否必需 | 描述 |
| --------- | ---- | -------- | ----------- |
| `token` | string | 是 | 具有 `repo:status` OAuth 作用域的 GitHub API 令牌。 |
| `repository_url` | string | 是 | GitHub 仓库 URL。 |
| `static_context` | boolean | 否 | 将您的极狐GitLab 实例的主机名附加到[状态检查名称](../user/project/integrations/github.md#static-or-dynamic-status-check-names)。 |
| `use_inherited_settings` | boolean | 否 | 指示是否继承默认设置。默认为 `false`。 |

<a id="disable-github"></a>

### 禁用 GitHub
禁用群组的 GitHub 集成。集成设置将被重置。

```plaintext
DELETE /groups/:id/integrations/github
```

### 获取 GitHub 设置

获取群组的 GitHub 集成设置。

```plaintext
GET /groups/:id/integrations/github
```

## 极狐GitLab for Jira Cloud 应用

极狐GitLab for Jira Cloud 应用集成会通过 [Jira 中的群组链接与取消链接](../integration/jira/connect-app.md#configure-the-gitlab-for-jira-cloud-app) 自动启用或禁用。你无法通过极狐GitLab 集成表单或 API 来启用或禁用该集成。

### 更新群组集成

使用此 API 端点更新在 Jira 中通过群组链接创建的集成。

```plaintext
PUT /groups/:id/integrations/jira-cloud-app
```

参数：

| 参数 | 类型 | 是否必需 | 描述 |
| --------- | ---- | -------- | ----------- |
| `jira_cloud_app_service_ids` | string | 否 | Jira Service Management 服务 ID。使用逗号 (`,`) 分隔多个 ID。 |
| `jira_cloud_app_enable_deployment_gating` | boolean | 否 | 为被 Jira Service Management 阻止的极狐GitLab 部署启用部署门禁。 |
| `jira_cloud_app_deployment_gating_environments` | string | 否 | 要启用部署门禁的环境（生产、预发、测试或开发）。如果启用了部署门禁，则为必需。使用逗号 (`,`) 分隔多个环境。 |

### 获取极狐GitLab for Jira Cloud 应用设置

获取群组的极狐GitLab for Jira Cloud 应用集成设置。

```plaintext
GET /groups/:id/integrations/jira-cloud-app
```

## 极狐GitLab for Slack 应用

### 设置极狐GitLab for Slack 应用

更新群组的极狐GitLab for Slack 应用集成。

你无法通过 API 创建极狐GitLab for Slack 应用，因为该集成需要一个 OAuth 2.0 令牌，而该令牌无法仅从极狐GitLab API 获取。
你必须改为从极狐GitLab UI [安装该应用](../user/project/integrations/gitlab_slack_application.md#install-the-gitlab-for-slack-app)。
然后你可以使用此 API 端点更新该集成。

```plaintext
PUT /groups/:id/integrations/gitlab-slack-application
```

参数：

| 参数 | 类型 | 是否必需 | 描述 |
| --------- | ---- | -------- | ----------- |
| `channel` | string | 否 | 未配置其他频道时使用的默认频道。 |
| `notify_only_broken_pipelines` | boolean | 否 | 发送已损坏流水线的通知。 |
| `notify_only_when_pipeline_status_changes` | boolean | 否 | 仅在引用的流水线状态发生变化时发送通知。 |
| `notify_only_default_branch` | boolean | 否 | **已弃用**：此参数已被 `branches_to_be_notified` 替换。 |
| `branches_to_be_notified` | string | 否 | 要发送通知的分支。有效选项为 `all`、`default`、`protected` 和 `default_and_protected`。默认值为 `default`。 |
| `alert_events` | boolean | 否 | 启用告警事件通知。 |
| `issues_events` | boolean | 否 | 启用议题事件通知。 |
| `confidential_issues_events` | boolean | 否 | 启用机密议题事件通知。 |
| `merge_requests_events` | boolean | 否 | 启用合并请求事件通知。 |
| `note_events` | boolean | 否 | 启用评论事件通知。 |
| `confidential_note_events` | boolean | 否 | 启用机密评论事件通知。 |
| `deployment_events` | boolean | 否 | 启用部署事件通知。 |
| `incidents_events` | boolean | 否 | 启用事件警通知。 |
| `pipeline_events` | boolean | 否 | 启用流水线事件通知。 |
| `push_events` | boolean | 否 | 启用推送事件通知。 |
| `tag_push_events` | boolean | 否 | 启用标签推送事件通知。 |
| `vulnerability_events` | boolean | 否 | 启用漏洞事件通知。 |
| `wiki_page_events` | boolean | 否 | 启用 Wiki 页面事件通知。 |
| `labels_to_be_notified` | string | 否 | 要发送通知的标签。如果未设置，则接收所有事件通知。 |
| `labels_to_be_notified_behavior` | string | 否 | 要通知的标签行为。有效选项为 `match_any` 和 `match_all`。默认为 `match_any`。 |
| `push_channel` | string | 否 | 接收推送事件通知的频道名称。 |
| `issue_channel` | string | 否 | 接收议题事件通知的频道名称。 |
| `confidential_issue_channel` | string | 否 | 接收机密议题事件通知的频道名称。 |
| `merge_request_channel` | string | 否 | 接收合并请求事件通知的频道名称。 |
| `note_channel` | string | 否 | 接收评论事件通知的频道名称。 |
| `confidential_note_channel` | string | 否 | 接收机密评论事件通知的频道名称。 |
| `tag_push_channel` | string | 否 | 接收标签推送事件通知的频道名称。 |
| `pipeline_channel` | string | 否 | 接收流水线事件通知的频道名称。 |
| `wiki_page_channel` | string | 否 | 接收 Wiki 页面事件通知的频道名称。 |
| `deployment_channel` | string | 否 | 接收部署事件通知的频道名称。 |
| `incident_channel` | string | 否 | 接收事件警通知的频道名称。 |
| `vulnerability_channel` | string | 否 | 接收漏洞事件通知的频道名称。 |
| `alert_channel` | string | 否 | 接收告警事件通知的频道名称。 |
| `use_inherited_settings` | boolean | 否 | 是否继承默认设置。默认为 `false`。 |

### 禁用极狐GitLab for Slack 应用

禁用群组的极狐GitLab for Slack 应用集成。集成设置将被重置。

```plaintext
DELETE /groups/:id/integrations/gitlab-slack-application
```

### 获取极狐GitLab for Slack 应用设置

获取群组的极狐GitLab for Slack 应用集成设置。

```plaintext
GET /groups/:id/integrations/gitlab-slack-application
```

## Google Chat

### 设置 Google Chat

为群组设置 Google Chat 集成。

```plaintext
PUT /groups/:id/integrations/hangouts-chat
```

参数：

| 参数 | 类型 | 是否必需 | 描述 |
| --------- | ---- | -------- | ----------- |
| `webhook` | string | 是 | Hangouts Chat 的 webhook（例如 `https://chat.googleapis.com/v1/spaces...`）。 |
| `notify_only_broken_pipelines` | boolean | 否 | 发送已损坏流水线的通知。 |
| `notify_only_when_pipeline_status_changes` | boolean | 否 | 仅在引用的流水线状态发生变化时发送通知。 |
| `notify_only_default_branch` | boolean | 否 | **已弃用**：此参数已被 `branches_to_be_notified` 替换。 |
| `branches_to_be_notified` | string | 否 | 要发送通知的分支。有效选项为 `all`、`default`、`protected` 和 `default_and_protected`。默认值为 `default`。 |
| `push_events` | boolean | 否 | 启用推送事件通知。 |
| `issues_events` | boolean | 否 | 启用议题事件通知。 |
| `confidential_issues_events` | boolean | 否 | 启用机密议题事件通知。 |
| `merge_requests_events` | boolean | 否 | 启用合并请求事件通知。 |
| `tag_push_events` | boolean | 否 | 启用标签推送事件通知。 |
| `note_events` | boolean | 否 | 启用评论事件通知。 |
| `confidential_note_events` | boolean | 否 | 启用机密评论事件通知。 |
| `pipeline_events` | boolean | 否 | 启用流水线事件通知。 |
| `wiki_page_events` | boolean | 否 | 启用 Wiki 页面事件通知。 |
| `use_inherited_settings` | boolean | 否 | 是否继承默认设置。默认为 `false`。 |

### 禁用 Google Chat

禁用群组的 Google Chat 集成。集成设置将被重置。

```plaintext
DELETE /groups/:id/integrations/hangouts-chat
```

### 获取 Google Chat 设置

获取群组的 Google Chat 集成设置。

```plaintext
GET /groups/:id/integrations/hangouts-chat
```

## Google Artifact Management

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: JihuLab.com
- 状态：测试版

{{< /details >}}

此功能处于 [测试阶段](../policy/development_stages_support.md)。

### 设置 Google Artifact Management

为群组设置 Google Artifact Management 集成。

```plaintext
PUT /groups/:id/integrations/google-cloud-platform-artifact-registry
```

参数：

| 参数 | 类型 | 是否必需 | 描述 |
| --------- | ---- | -------- | ----------- |
| `artifact_registry_project_id` | string | 是 | Google Cloud 项目的 ID。 |
| `artifact_registry_location` | string | 是 | Artifact Registry 仓库的位置。 |
| `artifact_registry_repositories` | string | 是 | Artifact Registry 的仓库。 |
| `use_inherited_settings` | boolean | 否 | 是否继承默认设置。默认为 `false`。 |

### 禁用 Google Artifact Management

禁用群组的 Google Artifact Management 集成。集成设置将被重置。

```plaintext
DELETE /groups/:id/integrations/google-cloud-platform-artifact-registry
```

### 获取 Google Artifact Management 设置

获取群组的 Google Artifact Management 集成设置。

```plaintext
GET /groups/:id/integrations/google-cloud-platform-artifact-registry
```

## Google Cloud Identity and Access Management (IAM)

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: JihuLab.com
- 状态：测试版

{{< /details >}}

此功能处于 [测试阶段](../policy/development_stages_support.md)。

### 设置 Google Cloud Identity and Access Management

为群组设置 Google Cloud Identity and Access Management 集成。

```plaintext
PUT /groups/:id/integrations/google-cloud-platform-workload-identity-federation
```

参数：

| 参数 | 类型 | 是否必需 | 描述 |
| --------- | ---- | -------- | ----------- |
| `workload_identity_federation_project_id` | string | 是 | 用于工作负载身份联合的 Google Cloud 项目 ID。 |
| `workload_identity_federation_project_number` | integer | 是 | 用于工作负载身份联合的 Google Cloud 项目编号。 |
| `workload_identity_pool_id` | string | 是 | 工作负载身份池的 ID。 |
| `workload_identity_pool_provider_id` | string | 是 | 工作负载身份池提供程序的 ID。 |
| `use_inherited_settings` | boolean | 否 | 是否继承默认设置。默认为 `false`。 |

### 禁用 Google Cloud Identity and Access Management

禁用群组的 Google Cloud Identity and Access Management 集成。集成设置将被重置。

```plaintext
DELETE /groups/:id/integrations/google-cloud-platform-workload-identity-federation
```

### 获取 Google Cloud Identity and Access Management

获取群组的 Google Cloud Identity and Access Management 设置。

```plaintext
GET /groups/:id/integration/google-cloud-platform-workload-identity-federation
```

## Harbor

### 设置 Harbor

为群组设置 Harbor 集成。

```plaintext
PUT /groups/:id/integrations/harbor
```

参数：

| 参数 | 类型 | 是否必需 | 描述 |
| --------- | ---- | -------- | ----------- |
| `url` | string | 是 | 链接到极狐GitLab 项目的 Harbor 实例的基础 URL。例如 `https://demo.goharbor.io`。 |
| `project_name` | string | 是 | Harbor 实例中项目的名称。例如 `testproject`。 |
| `username` | string | 是 | 在 Harbor 界面中创建的用户名。 |
| `password` | string | 是 | 用户的密码。 |
| `use_inherited_settings` | boolean | 否 | 是否继承默认设置。默认为 `false`。 |

### 禁用 Harbor

禁用群组的 Harbor 集成。集成设置将被重置。

```plaintext
DELETE /groups/:id/integrations/harbor
```

### 获取 Harbor 设置

获取群组的 Harbor 集成设置。

```plaintext
GET /groups/:id/integrations/harbor
```

## irker (IRC 网关)

### 设置 irker

为群组设置 irker 集成。

```plaintext
PUT /groups/:id/integrations/irker
```

参数：

| 参数 | 类型 | 是否必需 | 描述 |
| --------- | ---- | -------- | ----------- |
| `recipients` | string | 是 | 收件人或频道，以空格分隔。 |
| `default_irc_uri` | string | 否 | `irc://irc.network.net:6697/`。 |
| `server_host` | string | 否 | localhost。 |
| `server_port` | integer | 否 | 6659。 |
| `colorize_messages` | boolean | 否 | 彩色显示消息。 |
| `use_inherited_settings` | boolean | 否 | 是否继承默认设置。默认为 `false`。 |

### 禁用 irker

禁用群组的 irker 集成。集成设置将被重置。

```plaintext
DELETE /groups/:id/integrations/irker
```

### 获取 irker 设置

获取群组的 irker 集成设置。

```plaintext
GET /groups/:id/integrations/irker
```

## JetBrains TeamCity

### 设置 JetBrains TeamCity

为群组设置 JetBrains TeamCity 集成。

TeamCity 中的构建配置必须使用构建号格式 `%build.vcs.number%`。
在 VCS 根的高级设置中，为所有分支配置监控，以便合并请求可以构建。

```plaintext
PUT /groups/:id/integrations/teamcity
```

参数：

| 参数 | 类型 | 是否必需 | 描述 |
| --------- | ---- | -------- | ----------- |
| `teamcity_url` | string | 是 | TeamCity 根 URL（例如 `https://teamcity.example.com`）。 |
| `enable_ssl_verification` | boolean | 否 | 启用 SSL 验证。默认为 `true`（已启用）。 |
| `build_type` | string | 是 | 构建配置 ID。 |
| `username` | string | 是 | 有权触发手动构建的用户。 |
| `password` | string | 是 | 用户的密码。 |
| `push_events` | boolean | 否 | 启用推送事件通知。 |
| `merge_requests_events` | boolean | 否 | 启用合并请求事件通知。 |
| `use_inherited_settings` | boolean | 否 | 是否继承默认设置。默认为 `false`。 |

### 禁用 JetBrains TeamCity

禁用群组的 JetBrains TeamCity 集成。集成设置将被重置。

```plaintext
DELETE /groups/:id/integrations/teamcity
```

### 获取 JetBrains TeamCity 设置

获取群组的 JetBrains TeamCity 集成设置。

```plaintext
GET /groups/:id/integrations/teamcity
```

## Jira

### 设置 Jira

为群组设置 Jira 集成。

```plaintext
PUT /groups/:id/integrations/jira
```

参数：

| 参数 | 类型 | 是否必需 | 描述 |
| --------- | ---- | -------- | ----------- |
| `url`           | string | 是 | 链接到此极狐GitLab 项目的 Jira 项目的 URL（例如 `https://jira.example.com`）。 |
| `api_url`   | string | 否 | Jira 实例 API 的基础 URL。如果未设置，则使用 Web URL 值（例如 `https://jira-api.example.com`）。 |
| `username`      | string | 否   | 用于 Jira 的电子邮件或用户名。对于 Jira Cloud，使用电子邮件；对于 Jira Data Center 和 Jira Server，使用用户名。使用基本身份验证时需要（`jira_auth_type` 为 `0`）。 |
| `password`      | string | 是  | 用于 Jira 的 Jira API 令牌、密码或个人访问令牌。当身份验证方法为基本（`jira_auth_type` 为 `0`）时，对于 Jira Cloud 使用 API 令牌，对于 Jira Data Center 或 Jira Server 使用密码。当身份验证方法为 Jira 个人访问令牌（`jira_auth_type` 为 `1`）时，使用个人访问令牌。 |
| `jira_auth_type`| integer | 否  | 用于 Jira 的身份验证方法。`0` 表示基本身份验证。`1` 表示 Jira 个人访问令牌。默认为 `0`。 |
| `jira_issue_prefix` | string | 否 | 匹配 Jira 议题键的前缀。 |
| `jira_issue_regex` | string | 否 | 匹配 Jira 议题键的正则表达式。 |
| `jira_issue_transition_automatic` | boolean | 否 | 启用 [自动议题转换](../integration/jira/issues.md#automatic-issue-transitions)。如果启用，则优先于 `jira_issue_transition_id`。默认为 `false`。 |
| `jira_issue_transition_id` | string | 否 | 用于 [自定义议题转换](../integration/jira/issues.md#custom-issue-transitions) 的一个或多个转换的 ID。如果启用了 `jira_issue_transition_automatic`，则忽略此参数。默认为空字符串，即禁用自定义转换。 |
| `commit_events` | boolean | 否 | 启用提交事件通知。 |
| `merge_requests_events` | boolean | 否 | 启用合并请求事件通知。 |
| `comment_on_event_enabled` | boolean | 否 | 在每个极狐GitLab 事件（提交或合并请求）上启用 Jira 议题评论。 |
| `issues_enabled` | boolean | 否 | 允许在极狐GitLab 中查看 Jira 议题。 |
| `project_keys` | array of strings | 否 | Jira 项目的键。当 `issues_enabled` 为 `true` 时，此设置指定可从极狐GitLab 查看其议题的 Jira 项目。 |
| `use_inherited_settings` | boolean | 否 | 是否继承默认设置。默认为 `false`。 |

### 禁用 Jira

禁用群组的 Jira 集成。集成设置将被重置。

```plaintext
DELETE /groups/:id/integrations/jira
```

### 获取 Jira 设置

获取群组的 Jira 集成设置。

```plaintext
GET /groups/:id/integrations/jira
```

## Linear

{{< history >}}

- 在极狐GitLab 18.3 中引入。

{{< /history >}}

### 设置 Linear

为群组设置 Linear 集成。

```plaintext
PUT /groups/:id/integrations/linear
```

参数：

| 参数     | 类型   | 是否必需 | 描述    |
| ------------- | ------ | -------- | -------------- |
| `workspace_url`  | string | 是     | 议题的 URL。     |
| `use_inherited_settings` | boolean | 否 | 是否继承默认设置。默认为 `false`。 |

### 禁用 Linear

禁用群组的 Linear 集成。集成设置将被重置。

```plaintext
DELETE /groups/:id/integrations/linear
```

### 获取 Linear 设置

获取群组的 Linear 集成设置。

```plaintext
GET /groups/:id/integrations/linear
```

## Matrix 通知

### 设置 Matrix 通知

为群组设置 Matrix 通知。

```plaintext
PUT /groups/:id/integrations/matrix
```

参数：

| 参数 | 类型 | 是否必需 | 描述 |
| --------- | ---- | -------- | ----------- |
| `hostname`   | string | 否 | Matrix 服务器的自定义主机名。默认值为 `https://matrix.org`。 |
| `token`   | string | 是 | Matrix 访问令牌（例如 `syt-zyx57W2v1u123ew11`）。 |
| `room` | string | 是 | 目标房间的唯一标识符（格式为 `!qPKKM111FFKKsfoCVy:matrix.org`）。 |
| `notify_only_broken_pipelines` | boolean | 否 | 发送已损坏流水线的通知。 |
| `notify_only_when_pipeline_status_changes` | boolean | 否 | 仅在引用的流水线状态发生变化时发送通知。 |
| `branches_to_be_notified` | string | 否 | 要发送通知的分支。有效选项为 `all`、`default`、`protected` 和 `default_and_protected`。默认值为 `default`。 |
| `push_events` | boolean | 否 | 启用推送事件通知。 |
| `issues_events` | boolean | 否 | 启用议题事件通知。 |
| `confidential_issues_events` | boolean | 否 | 启用机密议题事件通知。 |
| `merge_requests_events` | boolean | 否 | 启用合并请求事件通知。 |
| `tag_push_events` | boolean | 否 | 启用标签推送事件通知。 |
| `note_events` | boolean | 否 | 启用评论事件通知。 |
| `confidential_note_events` | boolean | 否 | 启用机密评论事件通知。 |
| `pipeline_events` | boolean | 否 | 启用流水线事件通知。 |
| `wiki_page_events` | boolean | 否 | 启用 Wiki 页面事件通知。 |
| `use_inherited_settings` | boolean | 否 | 是否继承默认设置。默认为 `false`。 |

### 禁用 Matrix 通知

禁用群组的 Matrix 通知。集成设置将被重置。

```plaintext
DELETE /groups/:id/integrations/matrix
```

### 获取 Matrix 通知设置

获取群组的 Matrix 通知设置。

```plaintext
GET /groups/:id/integrations/matrix
```

## Mattermost 通知

### 设置 Mattermost 通知

为群组设置 Mattermost 通知。

```plaintext
PUT /groups/:id/integrations/mattermost
```

参数：

| 参数 | 类型 | 是否必需 | 描述 |
| --------- | ---- | -------- | ----------- |
| `webhook` | string | 是 | Mattermost 通知 webhook（例如 `http://mattermost.example.com/hooks/...`）。 |
| `username` | string | 否 | Mattermost 通知用户名。 |
| `channel` | string | 否 | 未配置其他频道时使用的默认频道。 |
| `notify_only_broken_pipelines` | boolean | 否 | 发送已损坏流水线的通知。 |
| `notify_only_when_pipeline_status_changes` | boolean | 否 | 仅在引用的流水线状态发生变化时发送通知。 |
| `notify_only_default_branch` | boolean | 否 | **已弃用**：此参数已被 `branches_to_be_notified` 替换。 |
| `branches_to_be_notified` | string | 否 | 要发送通知的分支。有效选项为 `all`、`default`、`protected` 和 `default_and_protected`。默认值为 `default`。 |
| `labels_to_be_notified` | string | 否 | 要发送通知的标签。留空则接收所有事件通知。 |
| `labels_to_be_notified_behavior` | string | 否 | 要通知的标签行为。有效选项为 `match_any` 和 `match_all`。默认值为 `match_any`。 |
| `push_events` | boolean | 否 | 启用推送事件通知。 |
| `issues_events` | boolean | 否 | 启用议题事件通知。 |
| `confidential_issues_events` | boolean | 否 | 启用机密议题事件通知。 |
| `merge_requests_events` | boolean | 否 | 启用合并请求事件通知。 |
| `tag_push_events` | boolean | 否 | 启用标签推送事件通知。 |
| `note_events` | boolean | 否 | 启用评论事件通知。 |
| `confidential_note_events` | boolean | 否 | 启用机密评论事件通知。 |
| `pipeline_events` | boolean | 否 | 启用流水线事件通知。 |
| `wiki_page_events` | boolean | 否 | 启用 Wiki 页面事件通知。 |
| `push_channel` | string | 否 | 接收推送事件通知的频道名称。 |
| `issue_channel` | string | 否 | 接收议题事件通知的频道名称。 |
| `confidential_issue_channel` | string | 否 | 接收机密议题事件通知的频道名称。 |
| `merge_request_channel` | string | 否 | 接收合并请求事件通知的频道名称。 |
| `note_channel` | string | 否 | 接收评论事件通知的频道名称。 |
| `confidential_note_channel` | string | 否 | 接收机密评论事件通知的频道名称。 |
| `tag_push_channel` | string | 否 | 接收标签推送事件通知的频道名称。 |
| `pipeline_channel` | string | 否 | 接收流水线事件通知的频道名称。 |
| `wiki_page_channel` | string | 否 | 接收 Wiki 页面事件通知的频道名称。 |
| `use_inherited_settings` | boolean | 否 | 是否继承默认设置。默认为 `false`。 |

### 禁用 Mattermost 通知

禁用群组的 Mattermost 通知。集成设置将被重置。

```plaintext
DELETE /groups/:id/integrations/mattermost
```

### 获取 Mattermost 通知设置

获取群组的 Mattermost 通知设置。

```plaintext
GET /groups/:id/integrations/mattermost
```

## Mattermost 斜杠命令

### 设置 Mattermost 斜杠命令

为群组设置 Mattermost 斜杠命令。

```plaintext
PUT /groups/:id/integrations/mattermost-slash-commands
```

参数：

| 参数 | 类型   | 是否必需 | 描述           |
| --------- | ------ | -------- | --------------------- |
| `token`   | string | 是      | Mattermost 令牌。 |
| `use_inherited_settings` | boolean | 否 | 是否继承默认设置。默认为 `false`。 |

### 禁用 Mattermost 斜杠命令

禁用群组的 Mattermost 斜杠命令。集成设置将被重置。

```plaintext
DELETE /groups/:id/integrations/mattermost-slash-commands
```
### 获取 Mattermost 斜杠命令设置

获取群组的 Mattermost 斜杠命令设置。

```plaintext
GET /groups/:id/integrations/mattermost-slash-commands
```

## Microsoft Teams 通知

### 设置 Microsoft Teams 通知

为群组设置 Microsoft Teams 通知。

```plaintext
PUT /groups/:id/integrations/microsoft-teams
```

参数：

| 参数 | 类型 | 是否必需 | 描述 |
| --------- | ---- | -------- | ----------- |
| `webhook` | string | 是 | Microsoft Teams webhook（例如，`https://outlook.office.com/webhook/...`）。 |
| `notify_only_broken_pipelines` | boolean | 否 | 为失败的流水线发送通知。 |
| `notify_only_when_pipeline_status_changes` | boolean | 否 | 仅在引用（ref）的流水线状态变更时发送通知。 |
| `notify_only_default_branch` | boolean | 否 | **已弃用**：此参数已被 `branches_to_be_notified` 替代。 |
| `branches_to_be_notified` | string | 否 | 发送通知的分支。有效选项为 `all`、`default`、`protected` 和 `default_and_protected`。默认值为 `default`。 |
| `push_events` | boolean | 否 | 启用推送事件通知。 |
| `issues_events` | boolean | 否 | 启用议题事件通知。 |
| `confidential_issues_events` | boolean | 否 | 启用机密议题事件通知。 |
| `merge_requests_events` | boolean | 否 | 启用合并请求事件通知。 |
| `tag_push_events` | boolean | 否 | 启用标签推送事件通知。 |
| `note_events` | boolean | 否 | 启用评论事件通知。 |
| `confidential_note_events` | boolean | 否 | 启用机密评论事件通知。 |
| `pipeline_events` | boolean | 否 | 启用流水线事件通知。 |
| `wiki_page_events` | boolean | 否 | 启用 Wiki 页面事件通知。 |
| `use_inherited_settings` | boolean | 否 | 指示是否继承默认设置。默认为 `false`。 |

### 禁用 Microsoft Teams 通知

为群组禁用 Microsoft Teams 通知。集成设置将被重置。

```plaintext
DELETE /groups/:id/integrations/microsoft-teams
```

### 获取 Microsoft Teams 通知设置

获取群组的 Microsoft Teams 通知设置。

```plaintext
GET /groups/:id/integrations/microsoft-teams
```

## Mock CI

此集成仅在开发环境中可用。
有关 Mock CI 服务器的示例，请参见 [`gitlab-org/gitlab-mock-ci-service`](https://jihulab.com/gitlab-cn/gitlab-mock-ci-service)。

### 设置 Mock CI

为群组设置 Mock CI 集成。

```plaintext
PUT /groups/:id/integrations/mock-ci
```

参数：

| 参数 | 类型 | 是否必需 | 描述 |
| --------- | ---- | -------- | ----------- |
| `mock_service_url` | string | 是 | Mock CI 集成的 URL。 |
| `enable_ssl_verification` | boolean | 否 | 启用 SSL 验证。默认为 `true`（启用）。 |
| `use_inherited_settings` | boolean | 否 | 指示是否继承默认设置。默认为 `false`。 |

### 禁用 Mock CI

为群组禁用 Mock CI 集成。集成设置将被重置。

```plaintext
DELETE /groups/:id/integrations/mock-ci
```

### 获取 Mock CI 设置

获取群组的 Mock CI 集成设置。

```plaintext
GET /groups/:id/integrations/mock-ci
```

## Packagist

### 设置 Packagist

为群组设置 Packagist 集成。

```plaintext
PUT /groups/:id/integrations/packagist
```

参数：

| 参数 | 类型 | 是否必需 | 描述 |
| --------- | ---- | -------- | ----------- |
| `username` | string | 是 | Packagist 账号的用户名。 |
| `token` | string | 是 | 用于访问 Packagist 服务器的 API 令牌。 |
| `server` | boolean | 否 | Packagist 服务器的 URL。留空则默认为 `https://packagist.org`。 |
| `push_events` | boolean | 否 | 启用推送事件通知。 |
| `merge_requests_events` | boolean | 否 | 启用合并请求事件通知。 |
| `tag_push_events` | boolean | 否 | 启用标签推送事件通知。 |
| `use_inherited_settings` | boolean | 否 | 指示是否继承默认设置。默认为 `false`。 |

### 禁用 Packagist

为群组禁用 Packagist 集成。集成设置将被重置。

```plaintext
DELETE /groups/:id/integrations/packagist
```

### 获取 Packagist 设置

获取群组的 Packagist 集成设置。

```plaintext
GET /groups/:id/integrations/packagist
```

## Phorge

### 设置 Phorge

为群组设置 Phorge 集成。

```plaintext
PUT /groups/:id/integrations/phorge
```

参数：

| 参数       | 类型   | 是否必需 | 描述           |
|-----------------|--------|----------|-----------------------|
| `issues_url`    | string | 是     | 议题的 URL。     |
| `project_url`   | string | 是     | 项目的 URL。   |
| `use_inherited_settings` | boolean | 否 | 指示是否继承默认设置。默认为 `false`。 |

### 禁用 Phorge

为群组禁用 Phorge 集成。集成设置将被重置。

```plaintext
DELETE /groups/:id/integrations/phorge
```

### 获取 Phorge 设置

获取群组的 Phorge 集成设置。

```plaintext
GET /groups/:id/integrations/phorge
```

## 流水线状态邮件

### 设置流水线状态邮件

为群组设置流水线状态邮件。

```plaintext
PUT /groups/:id/integrations/pipelines-email
```

参数：

| 参数 | 类型 | 是否必需 | 描述 |
| --------- | ---- | -------- | ----------- |
| `recipients` | string | 是 | 以逗号分隔的收件人电子邮件地址列表。 |
| `notify_only_broken_pipelines` | boolean | 否 | 为失败的流水线发送通知。 |
| `branches_to_be_notified` | string | 否 | 发送通知的分支。有效选项为 `all`、`default`、`protected` 和 `default_and_protected`。默认值为 `default`。 |
| `notify_only_default_branch` | boolean | 否 | 为默认分支发送通知。 |
| `pipeline_events` | boolean | 否 | 启用流水线事件通知。 |
| `use_inherited_settings` | boolean | 否 | 指示是否继承默认设置。默认为 `false`。 |

### 禁用流水线状态邮件

为群组禁用流水线状态邮件。集成设置将被重置。

```plaintext
DELETE /groups/:id/integrations/pipelines-email
```

### 获取流水线状态邮件设置

获取群组的流水线状态邮件设置。

```plaintext
GET /groups/:id/integrations/pipelines-email
```

## Pivotal Tracker

### 设置 Pivotal Tracker

为群组设置 Pivotal Tracker 集成。

```plaintext
PUT /groups/:id/integrations/pivotaltracker
```

参数：

| 参数 | 类型 | 是否必需 | 描述 |
| --------- | ---- | -------- | ----------- |
| `token` | string | 是 | Pivotal Tracker 令牌。 |
| `restrict_to_branch` | boolean | 否 | 以逗号分隔的自动检查的分支列表。留空包含所有分支。 |
| `use_inherited_settings` | boolean | 否 | 指示是否继承默认设置。默认为 `false`。 |

### 禁用 Pivotal Tracker

为群组禁用 Pivotal Tracker 集成。集成设置将被重置。

```plaintext
DELETE /groups/:id/integrations/pivotaltracker
```

### 获取 Pivotal Tracker 设置

获取群组的 Pivotal Tracker 集成设置。

```plaintext
GET /groups/:id/integrations/pivotaltracker
```

## Pumble

### 设置 Pumble

为群组设置 Pumble 集成。

```plaintext
PUT /groups/:id/integrations/pumble
```

参数：

| 参数 | 类型 | 是否必需 | 描述 |
| --------- | ---- | -------- | ----------- |
| `webhook` | string | 是 | Pumble webhook（例如，`https://api.pumble.com/workspaces/x/...`）。 |
| `branches_to_be_notified` | string | 否 | 发送通知的分支。有效选项为 `all`、`default`、`protected` 和 `default_and_protected`。默认为 `default`。 |
| `confidential_issues_events` | boolean | 否 | 启用机密议题事件通知。 |
| `confidential_note_events` | boolean | 否 | 启用机密评论事件通知。 |
| `issues_events` | boolean | 否 | 启用议题事件通知。 |
| `merge_requests_events` | boolean | 否 | 启用合并请求事件通知。 |
| `note_events` | boolean | 否 | 启用评论事件通知。 |
| `notify_only_broken_pipelines` | boolean | 否 | 为失败的流水线发送通知。 |
| `notify_only_when_pipeline_status_changes` | boolean | 否 | 仅在引用（ref）的流水线状态变更时发送通知。 |
| `pipeline_events` | boolean | 否 | 启用流水线事件通知。 |
| `push_events` | boolean | 否 | 启用推送事件通知。 |
| `tag_push_events` | boolean | 否 | 启用标签推送事件通知。 |
| `wiki_page_events` | boolean | 否 | 启用 Wiki 页面事件通知。 |
| `use_inherited_settings` | boolean | 否 | 指示是否继承默认设置。默认为 `false`。 |

### 禁用 Pumble

为群组禁用 Pumble 集成。集成设置将被重置。

```plaintext
DELETE /groups/:id/integrations/pumble
```

### 获取 Pumble 设置

获取群组的 Pumble 集成设置。

```plaintext
GET /groups/:id/integrations/pumble
```

## Pushover

### 设置 Pushover

为群组设置 Pushover 集成。

```plaintext
PUT /groups/:id/integrations/pushover
```

参数：

| 参数 | 类型 | 是否必需 | 描述 |
| --------- | ---- | -------- | ----------- |
| `api_key` | string | 是 | 你的应用程序密钥。 |
| `user_key` | string | 是 | 你的用户密钥。 |
| `priority` | string | 是 | 优先级。 |
| `device` | string | 否 | 留空则所有活跃设备都会收到。 |
| `sound` | string | 否 | 通知的声音。 |
| `use_inherited_settings` | boolean | 否 | 指示是否继承默认设置。默认为 `false`。 |

### 禁用 Pushover

为群组禁用 Pushover 集成。集成设置将被重置。

```plaintext
DELETE /groups/:id/integrations/pushover
```

### 获取 Pushover 设置

获取群组的 Pushover 集成设置。

```plaintext
GET /groups/:id/integrations/pushover
```

## Redmine

### 设置 Redmine

为群组设置 Redmine 集成。

```plaintext
PUT /groups/:id/integrations/redmine
```

参数：

| 参数 | 类型 | 是否必需 | 描述 |
| --------- | ---- | -------- | ----------- |
| `new_issue_url` | string | 是 | 新建议题的 URL。 |
| `project_url` | string | 是 | 项目的 URL。 |
| `issues_url` | string | 是 | 议题的 URL。 |
| `use_inherited_settings` | boolean | 否 | 指示是否继承默认设置。默认为 `false`。 |

### 禁用 Redmine

为群组禁用 Redmine 集成。集成设置将被重置。

```plaintext
DELETE /groups/:id/integrations/redmine
```

### 获取 Redmine 设置

获取群组的 Redmine 集成设置。

```plaintext
GET /groups/:id/integrations/redmine
```

## Slack 通知

### 设置 Slack 通知

为群组设置 Slack 通知。

```plaintext
PUT /groups/:id/integrations/slack
```

参数：

| 参数 | 类型 | 是否必需 | 描述 |
| --------- | ---- | -------- | ----------- |
| `webhook` | string | 是 | Slack 通知 webhook（例如，`https://hooks.slack.com/services/...`）。 |
| `username` | string | 否 | Slack 通知用户名。 |
| `channel` | string | 否 | 如果没有配置其他频道，则使用此默认频道。 |
| `notify_only_broken_pipelines` | boolean | 否 | 为失败的流水线发送通知。 |
| `notify_only_when_pipeline_status_changes` | boolean | 否 | 仅在引用（ref）的流水线状态变更时发送通知。 |
| `notify_only_default_branch` | boolean | 否 | **已弃用**：此参数已被 `branches_to_be_notified` 替代。 |
| `branches_to_be_notified` | string | 否 | 发送通知的分支。有效选项为 `all`、`default`、`protected` 和 `default_and_protected`。默认值为 `default`。 |
| `labels_to_be_notified` | string | 否 | 为其发送通知的标签。留空则为所有事件接收通知。 |
| `labels_to_be_notified_behavior` | string | 否 | 要通知的标签行为。有效选项为 `match_any` 和 `match_all`。默认值为 `match_any`。 |
| `alert_channel` | string | 否 | 接收告警事件通知的频道名称。 |
| `alert_events` | boolean | 否 | 启用告警事件通知。 |
| `commit_events` | boolean | 否 | 启用提交事件通知。 |
| `confidential_issue_channel` | string | 否 | 接收机密议题事件通知的频道名称。 |
| `confidential_issues_events` | boolean | 否 | 启用机密议题事件通知。 |
| `confidential_note_channel` | string | 否 | 接收机密评论事件通知的频道名称。 |
| `confidential_note_events` | boolean | 否 | 启用机密评论事件通知。 |
| `deployment_channel` | string | 否 | 接收部署事件通知的频道名称。 |
| `deployment_events` | boolean | 否 | 启用部署事件通知。 |
| `incident_channel` | string | 否 | 接收故障事件通知的频道名称。 |
| `incidents_events` | boolean | 否 | 启用故障事件通知。 |
| `issue_channel` | string | 否 | 接收议题事件通知的频道名称。 |
| `issues_events` | boolean | 否 | 启用议题事件通知。 |
| `job_events` | boolean | 否 | 启用作业事件通知。 |
| `merge_request_channel` | string | 否 | 接收合并请求事件通知的频道名称。 |
| `merge_requests_events` | boolean | 否 | 启用合并请求事件通知。 |
| `note_channel` | string | 否 | 接收评论事件通知的频道名称。 |
| `note_events` | boolean | 否 | 启用评论事件通知。 |
| `pipeline_channel` | string | 否 | 接收流水线事件通知的频道名称。 |
| `pipeline_events` | boolean | 否 | 启用流水线事件通知。 |
| `push_channel` | string | 否 | 接收推送事件通知的频道名称。 |
| `push_events` | boolean | 否 | 启用推送事件通知。 |
| `tag_push_channel` | string | 否 | 接收标签推送事件通知的频道名称。 |
| `tag_push_events` | boolean | 否 | 启用标签推送事件通知。 |
| `wiki_page_channel` | string | 否 | 接收 Wiki 页面事件通知的频道名称。 |
| `wiki_page_events` | boolean | 否 | 启用 Wiki 页面事件通知。 |
| `use_inherited_settings` | boolean | 否 | 指示是否继承默认设置。默认为 `false`。 |

### 禁用 Slack 通知

为群组禁用 Slack 通知。集成设置将被重置。

```plaintext
DELETE /groups/:id/integrations/slack
```

### 获取 Slack 通知设置

获取群组的 Slack 通知设置。

```plaintext
GET /groups/:id/integrations/slack
```

## Squash TM

### 设置 Squash TM

为群组设置 Squash TM 集成设置。

```plaintext
PUT /groups/:id/integrations/squash-tm
```

参数：

| 参数               | 类型   | 是否必需 | 描述                   |
|-------------------------|--------|----------|-------------------------------|
| `url`                   | string | 是      | Squash TM webhook 的 URL。 |
| `token`                 | string | 否       | 密钥令牌。                 |
| `use_inherited_settings` | boolean | 否 | 指示是否继承默认设置。默认为 `false`。 |

### 禁用 Squash TM

为群组禁用 Squash TM 集成。集成设置将被保留。

```plaintext
DELETE /groups/:id/integrations/squash-tm
```

### 获取 Squash TM 设置

获取群组的 Squash TM 集成设置。

```plaintext
GET /groups/:id/integrations/squash-tm
```

## Telegram

### 设置 Telegram

为群组设置 Telegram 集成。

```plaintext
PUT /groups/:id/integrations/telegram
```

参数：

| 参数 | 类型 | 是否必需 | 描述 |
| --------- | ---- | -------- | ----------- |
| `hostname`   | string | 否 | Telegram API 的自定义主机名。默认值为 `https://api.telegram.org`。 |
| `token`   | string | 是 | Telegram 机器人令牌（例如，`123456:ABC-DEF1234ghIkl-zyx57W2v1u123ew11`）。 |
| `room` | string | 是 | 目标聊天的唯一标识符或目标频道的用户名（格式为 `@channelusername`）。 |
| `thread` | integer | 否 | 目标消息主题的唯一标识符（论坛超级群组中的主题）。 |
| `notify_only_broken_pipelines` | boolean | 否 | 为失败的流水线发送通知。 |
| `notify_only_when_pipeline_status_changes` | boolean | 否 | 仅在引用（ref）的流水线状态变更时发送通知。 |
| `branches_to_be_notified` | string | 否 | 发送通知的分支。有效选项为 `all`、`default`、`protected` 和 `default_and_protected`。默认值为 `default`。 |
| `push_events` | boolean | 是 | 启用推送事件通知。 |
| `issues_events` | boolean | 是 | 启用议题事件通知。 |
| `confidential_issues_events` | boolean | 是 | 启用机密议题事件通知。 |
| `merge_requests_events` | boolean | 是 | 启用合并请求事件通知。 |
| `tag_push_events` | boolean | 是 | 启用标签推送事件通知。 |
| `note_events` | boolean | 是 | 启用评论事件通知。 |
| `confidential_note_events` | boolean | 是 | 启用机密评论事件通知。 |
| `pipeline_events` | boolean | 是 | 启用流水线事件通知。 |
| `wiki_page_events` | boolean | 是 | 启用 Wiki 页面事件通知。 |
| `use_inherited_settings` | boolean | 否 | 指示是否继承默认设置。默认为 `false`。 |

### 禁用 Telegram

为群组禁用 Telegram 集成。集成设置将被重置。

```plaintext
DELETE /groups/:id/integrations/telegram
```

### 获取 Telegram 设置

获取群组的 Telegram 集成设置。

```plaintext
GET /groups/:id/integrations/telegram
```

## Unify Circuit

### 设置 Unify Circuit

为群组设置 Unify Circuit 集成。

```plaintext
PUT /groups/:id/integrations/unify-circuit
```

参数：

| 参数 | 类型 | 是否必需 | 描述 |
| --------- | ---- | -------- | ----------- |
| `webhook` | string | 是 | Unify Circuit webhook（例如，`https://circuit.com/rest/v2/webhooks/incoming/...`）。 |
| `notify_only_broken_pipelines` | boolean | 否 | 为失败的流水线发送通知。 |
| `notify_only_when_pipeline_status_changes` | boolean | 否 | 仅在引用（ref）的流水线状态变更时发送通知。 |
| `branches_to_be_notified` | string | 否 | 发送通知的分支。有效选项为 `all`、`default`、`protected` 和 `default_and_protected`。默认值为 `default`。 |
| `push_events` | boolean | 否 | 启用推送事件通知。 |
| `issues_events` | boolean | 否 | 启用议题事件通知。 |
| `confidential_issues_events` | boolean | 否 | 启用机密议题事件通知。 |
| `merge_requests_events` | boolean | 否 | 启用合并请求事件通知。 |
| `tag_push_events` | boolean | 否 | 启用标签推送事件通知。 |
| `note_events` | boolean | 否 | 启用评论事件通知。 |
| `confidential_note_events` | boolean | 否 | 启用机密评论事件通知。 |
| `pipeline_events` | boolean | 否 | 启用流水线事件通知。 |
| `wiki_page_events` | boolean | 否 | 启用 Wiki 页面事件通知。 |
| `use_inherited_settings` | boolean | 否 | 指示是否继承默认设置。默认为 `false`。 |

### 禁用 Unify Circuit

为群组禁用 Unify Circuit 集成。集成设置将被重置。

```plaintext
DELETE /groups/:id/integrations/unify-circuit
```

### 获取 Unify Circuit 设置

获取群组的 Unify Circuit 集成设置。

```plaintext
GET /groups/:id/integrations/unify-circuit
```

## Webex Teams

### 设置 Webex Teams

为群组设置 Webex Teams。

```plaintext
PUT /groups/:id/integrations/webex-teams
```

参数：

| 参数 | 类型 | 是否必需 | 描述 |
| --------- | ---- | -------- | ----------- |
| `webhook` | string | 是 | Webex Teams webhook（例如，`https://api.ciscospark.com/v1/webhooks/incoming/...`）。 |
| `notify_only_broken_pipelines` | boolean | 否 | 为失败的流水线发送通知。 |
| `notify_only_when_pipeline_status_changes` | boolean | 否 | 仅在引用（ref）的流水线状态变更时发送通知。 |
| `branches_to_be_notified` | string | 否 | 发送通知的分支。有效选项为 `all`、`default`、`protected` 和 `default_and_protected`。默认值为 `default`。 |
| `push_events` | boolean | 否 | 启用推送事件通知。 |
| `issues_events` | boolean | 否 | 启用议题事件通知。 |
| `confidential_issues_events` | boolean | 否 | 启用机密议题事件通知。 |
| `merge_requests_events` | boolean | 否 | 启用合并请求事件通知。 |
| `tag_push_events` | boolean | 否 | 启用标签推送事件通知。 |
| `note_events` | boolean | 否 | 启用评论事件通知。 |
| `confidential_note_events` | boolean | 否 | 启用机密评论事件通知。 |
| `pipeline_events` | boolean | 否 | 启用流水线事件通知。 |
| `wiki_page_events` | boolean | 否 | 启用 Wiki 页面事件通知。 |
| `use_inherited_settings` | boolean | 否 | 指示是否继承默认设置。默认为 `false`。 |

### 禁用 Webex Teams

为群组禁用 Webex Teams。集成设置将被重置。

```plaintext
DELETE /groups/:id/integrations/webex-teams
```

### 获取 Webex Teams 设置

获取群组的 Webex Teams 设置。

```plaintext
GET /groups/:id/integrations/webex-teams
```

## YouTrack

### 设置 YouTrack

为群组设置 YouTrack 集成。

```plaintext
PUT /groups/:id/integrations/youtrack
```

参数：

| 参数 | 类型 | 是否必需 | 描述 |
| --------- | ---- | -------- | ----------- |
| `issues_url` | string | 是 | 议题的 URL。 |
| `project_url` | string | 是 | 项目的 URL。 |
| `use_inherited_settings` | boolean | 否 | 指示是否继承默认设置。默认为 `false`。 |

### 禁用 YouTrack

为群组禁用 YouTrack 集成。集成设置将被重置。

```plaintext
DELETE /groups/:id/integrations/youtrack
```

### 获取 YouTrack 设置

获取群组的 YouTrack 集成设置。

```plaintext
GET /groups/:id/integrations/youtrack
```