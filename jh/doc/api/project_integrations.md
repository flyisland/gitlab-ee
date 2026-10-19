---
stage: none
group: unassigned
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
title: 项目集成 API
description: "使用 REST API 为项目设置和管理集成。"
---

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: JihuLab.com，私有化部署

{{< /details >}}

使用此 API 管理项目的[集成](../user/project/integrations/_index.md)。

先决条件：

- 您必须具有该项目的维护者或所有者角色。

<a id="list-all-active-integrations"></a>

## 列出所有活跃集成

获取所有活跃项目集成的列表。`vulnerability_events` 字段仅适用于极狐GitLab 企业版。

```plaintext
GET /projects/:id/integrations
```

响应示例：

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

<a id="apple-app-store-connect"></a>

## Apple App Store Connect

<a id="set-up-apple-app-store-connect"></a>

### 设置 Apple App Store Connect

为项目设置 Apple App Store Connect 集成。

```plaintext
PUT /projects/:id/integrations/apple_app_store
```

参数：

| 参数 | 类型 | 必需 | 描述 |
| --------- | ---- | -------- | ----------- |
| `app_store_issuer_id` | string | 是 | Apple App Store Connect 颁发者 ID。 |
| `app_store_key_id` | string | 是 | Apple App Store Connect 密钥 ID。 |
| `app_store_private_key_file_name` | string | 是 | Apple App Store Connect 私钥文件名。 |
| `app_store_private_key` | string | 是 | Apple App Store Connect 私钥。 |
| `app_store_protected_refs` | boolean | 否 | 仅在受保护分支和标签上设置变量。 |
| `use_inherited_settings` | boolean | 否 | 指示是否继承默认设置。默认为 `false`。 |

<a id="disable-apple-app-store-connect"></a>

### 禁用 Apple App Store Connect

为项目禁用 Apple App Store Connect 集成。集成设置将被重置。

```plaintext
DELETE /projects/:id/integrations/apple_app_store
```

<a id="get-apple-app-store-connect-settings"></a>

### 获取 Apple App Store Connect 设置

获取项目的 Apple App Store Connect 集成设置。

```plaintext
GET /projects/:id/integrations/apple_app_store
```

<a id="asana"></a>

## Asana

<a id="set-up-asana"></a>

### 设置 Asana

为项目设置 Asana 集成。

```plaintext
PUT /projects/:id/integrations/asana
```

参数：

| 参数 | 类型 | 必需 | 描述 |
| --------- | ---- | -------- | ----------- |
| `api_key` | string | 是 | 用户 API 令牌。该用户必须有权访问该任务。所有评论都归属于该用户。 |
| `restrict_to_branch` | string | 否 | 要自动检查的分支列表，以逗号分隔。留空则包含所有分支。 |
| `use_inherited_settings` | boolean | 否 | 指示是否继承默认设置。默认为 `false`。 |

<a id="disable-asana"></a>

### 禁用 Asana

为项目禁用 Asana 集成。集成设置将被重置。

```plaintext
DELETE /projects/:id/integrations/asana
```

<a id="get-asana-settings"></a>

### 获取 Asana 设置

获取项目的 Asana 集成设置。

```plaintext
GET /projects/:id/integrations/asana
```

<a id="assembla"></a>

## Assembla

<a id="set-up-assembla"></a>

### 设置 Assembla

为项目设置 Assembla 集成。

```plaintext
PUT /projects/:id/integrations/assembla
```

参数：

| 参数 | 类型 | 必需 | 描述 |
| --------- | ---- | -------- | ----------- |
| `token` | string | 是 | 认证令牌。 |
| `subdomain` | string | 否 | 子域设置。 |
| `use_inherited_settings` | boolean | 否 | 指示是否继承默认设置。默认为 `false`。 |

<a id="disable-assembla"></a>

### 禁用 Assembla

为项目禁用 Assembla 集成。集成设置将被重置。

```plaintext
DELETE /projects/:id/integrations/assembla
```

<a id="get-assembla-settings"></a>

### 获取 Assembla 设置

获取项目的 Assembla 集成设置。

```plaintext
GET /projects/:id/integrations/assembla
```

<a id="atlassian-bamboo"></a>

## Atlassian Bamboo

<a id="set-up-atlassian-bamboo"></a>

### 设置 Atlassian Bamboo

为项目设置 Atlassian Bamboo 集成。

您必须在 Bamboo 中配置自动修订标记和代码仓库触发器。

```plaintext
PUT /projects/:id/integrations/bamboo
```

参数：

| 参数 | 类型 | 必需 | 描述 |
| --------- | ---- | -------- | ----------- |
| `bamboo_url` | string | 是 | Bamboo 根 URL（例如 `https://bamboo.example.com`）。 |
| `enable_ssl_verification` | boolean | 否 | 启用 SSL 验证。默认为 `true`（已启用）。 |
| `build_key` | string | 是 | Bamboo 构建计划键（例如 `KEY`）。 |
| `username` | string | 是 | 具有 Bamboo 服务器 API 访问权限的用户。 |
| `password` | string | 是 | 该用户的密码。 |
| `use_inherited_settings` | boolean | 否 | 指示是否继承默认设置。默认为 `false`。 |

<a id="disable-atlassian-bamboo"></a>

### 禁用 Atlassian Bamboo

为项目禁用 Atlassian Bamboo 集成。集成设置将被重置。

```plaintext
DELETE /projects/:id/integrations/bamboo
```

<a id="get-atlassian-bamboo-settings"></a>

### 获取 Atlassian Bamboo 设置

获取项目的 Atlassian Bamboo 集成设置。

```plaintext
GET /projects/:id/integrations/bamboo
```

<a id="bugzilla"></a>

## Bugzilla

<a id="set-up-bugzilla"></a>

### 设置 Bugzilla

为项目设置 Bugzilla 集成。

```plaintext
PUT /projects/:id/integrations/bugzilla
```

参数：

| 参数 | 类型 | 必需 | 描述 |
| --------- | ---- | -------- | ----------- |
| `new_issue_url` | string | 是 | 新议题的 URL。 |
| `issues_url` | string | 是 | 议题的 URL。 |
| `project_url` | string | 是 | 项目的 URL。 |
| `use_inherited_settings` | boolean | 否 | 指示是否继承默认设置。默认为 `false`。 |

<a id="disable-bugzilla"></a>

### 禁用 Bugzilla

为项目禁用 Bugzilla 集成。集成设置将被重置。

```plaintext
DELETE /projects/:id/integrations/bugzilla
```

<a id="get-bugzilla-settings"></a>

### 获取 Bugzilla 设置

获取项目的 Bugzilla 集成设置。

```plaintext
GET /projects/:id/integrations/bugzilla
```

<a id="buildkite"></a>

## Buildkite

<a id="set-up-buildkite"></a>

### 设置 Buildkite

为项目设置 Buildkite 集成。

```plaintext
PUT /projects/:id/integrations/buildkite
```

参数：

| 参数 | 类型 | 必需 | 描述 |
| --------- | ---- | -------- | ----------- |
| `token` | string | 是 | 使用极狐GitLab 代码仓库创建 Buildkite 流水线后获得的令牌。 |
| `project_url` | string | 是 | 流水线 URL（例如 `https://buildkite.com/example/pipeline`）。 |
| `enable_ssl_verification` | boolean | 否 | **已弃用**：此参数无效，因为 SSL 验证始终启用。 |
| `push_events` | boolean | 否 | 为推送事件启用通知。 |
| `merge_requests_events` | boolean | 否 | 为合并请求事件启用通知。 |
| `tag_push_events` | boolean | 否 | 为标签推送事件启用通知。 |
| `use_inherited_settings` | boolean | 否 | 指示是否继承默认设置。默认为 `false`。 |

<a id="disable-buildkite"></a>

### 禁用 Buildkite

为项目禁用 Buildkite 集成。集成设置将被重置。

```plaintext
DELETE /projects/:id/integrations/buildkite
```

<a id="get-buildkite-settings"></a>

### 获取 Buildkite 设置

获取项目的 Buildkite 集成设置。

```plaintext
GET /projects/:id/integrations/buildkite
```

<a id="campfire-classic"></a>

## Campfire 经典版

您可以与 Campfire 经典版集成。但是，Campfire 经典版是一款旧产品，Basecamp 已
[不再销售](https://gitlab.com/gitlab-org/gitlab/-/issues/329337)。

<a id="set-up-campfire-classic"></a>

### 设置 Campfire 经典版

为项目设置 Campfire 经典版集成。

```plaintext
PUT /projects/:id/integrations/campfire
```

参数：

| 参数     | 类型    | 必需 | 描述                                                                                 |
|---------------|---------|----------|---------------------------------------------------------------------------------------------|
| `token`       | string  | 是     | 来自 Campfire 经典版的 API 认证令牌。要获取该令牌，请登录 Campfire 经典版并选择 **我的信息**。 |
| `subdomain`   | string  | 否    | 您登录时的 `.campfirenow.com` 子域。 |
| `room`        | string  | 否    | Campfire 经典版房间 URL 中的 ID 部分。 |
| `use_inherited_settings` | boolean | 否 | 指示是否继承默认设置。默认为 `false`。 |

<a id="disable-campfire-classic"></a>

### 禁用 Campfire 经典版

为项目禁用 Campfire 经典版集成。集成设置将被重置。

```plaintext
DELETE /projects/:id/integrations/campfire
```

<a id="get-campfire-classic-settings"></a>

### 获取 Campfire 经典版设置

获取项目的 Campfire 经典版集成设置。

```plaintext
GET /projects/:id/integrations/campfire
```

<a id="clickup"></a>

## ClickUp

<a id="set-up-clickup"></a>

### 设置 ClickUp

为项目设置 ClickUp 集成。

```plaintext
PUT /projects/:id/integrations/clickup
```

参数：

| 参数     | 类型   | 必需 | 描述    |
| ------------- | ------ | -------- | -------------- |
| `issues_url`  | string | 是     | 议题的 URL。     |
| `project_url` | string | 是     | 项目的 URL。   |
| `use_inherited_settings` | boolean | 否 | 指示是否继承默认设置。默认为 `false`。 |

<a id="disable-clickup"></a>

### 禁用 ClickUp

为项目禁用 ClickUp 集成。集成设置将被重置。

```plaintext
DELETE /projects/:id/integrations/clickup
```

<a id="get-clickup-settings"></a>

### 获取 ClickUp 设置

获取项目的 ClickUp 集成设置。

```plaintext
GET /projects/:id/integrations/clickup
```

<a id="confluence-workspace"></a>

## Confluence 工作区

使用 Confluence Cloud 工作区作为您的项目 Wiki。

<a id="set-up-confluence-workspace"></a>

### 设置 Confluence 工作区

为项目设置 Confluence 工作区集成。

```plaintext
PUT /projects/:id/integrations/confluence
```

参数：

| 参数 | 类型 | 必需 | 描述 |
| --------- | ---- | -------- | ----------- |
| `confluence_url` | string | 是 | 托管在 `atlassian.net` 上的 Confluence 工作区的 URL。 |
| `use_inherited_settings` | boolean | 否 | 指示是否继承默认设置。默认为 `false`。 |

<a id="disable-confluence-workspace"></a>

### 禁用 Confluence 工作区

为项目禁用 Confluence 工作区集成。集成设置将被重置。

```plaintext
DELETE /projects/:id/integrations/confluence
```

<a id="get-confluence-workspace-settings"></a>

### 获取 Confluence 工作区设置

获取项目的 Confluence 工作区集成设置。

```plaintext
GET /projects/:id/integrations/confluence
```

<a id="custom-issue-tracker"></a>

## 自定义议题跟踪器

<a id="set-up-a-custom-issue-tracker"></a>

### 设置自定义议题跟踪器

为项目设置自定义议题跟踪器。

```plaintext
PUT /projects/:id/integrations/custom-issue-tracker
```

参数：

| 参数 | 类型 | 必需 | 描述 |
| --------- | ---- | -------- | ----------- |
| `new_issue_url` | string | 是 | 新议题的 URL。 |
| `issues_url` | string | 是 | 议题的 URL。 |
| `project_url` | string | 是 | 项目的 URL。 |
| `use_inherited_settings` | boolean | 否 | 指示是否继承默认设置。默认为 `false`。 |

<a id="disable-a-custom-issue-tracker"></a>

### 禁用自定义议题跟踪器

为项目禁用自定义议题跟踪器。集成设置将被重置。

```plaintext
DELETE /projects/:id/integrations/custom-issue-tracker
```

<a id="get-custom-issue-tracker-settings"></a>

### 获取自定义议题跟踪器设置

获取项目的自定义议题跟踪器设置。

```plaintext
GET /projects/:id/integrations/custom-issue-tracker
```

<a id="datadog"></a>

## Datadog

<a id="set-up-datadog"></a>

### 设置 Datadog

为项目设置 Datadog 集成。

```plaintext
PUT /projects/:id/integrations/datadog
```

参数：

| 参数              | 类型    | 必需 | 描述                                                                                                                                                                            |
|------------------------|---------|----------|----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| `api_key`              | string  | 是     | 用于向 Datadog 进行认证的 [API 密钥](https://docs.datadoghq.com/account_management/api-app-keys/)。 |
| `datadog_ci_visibility`| boolean | 是     | 启用后在 Datadog 中收集流水线和作业事件，以显示流水线执行跟踪。 |
| `api_url`              | string  | 否    | 您的 Datadog 站点的完整 URL。 |
| `datadog_env`          | string  | 否    | 对于极狐GitLab 私有化部署，为发送到 Datadog 的所有数据添加 `env%` 标签。 |
| `datadog_service`      | string  | 否    | 在 Datadog 中为所有数据添加标签的极狐GitLab 实例。在管理多个极狐GitLab 私有化部署时可以使用。 |
| `datadog_tags`         | string  | 否    | Datadog 中的自定义标签。每行指定一个标签，格式为 `key:value\nkey2:value2`。 |
| `archive_trace_events` | boolean | 否    | 启用后，作业日志由 Datadog 收集，并与流水线执行跟踪一起显示。 |
| `use_inherited_settings` | boolean | 否 | 指示是否继承默认设置。默认为 `false`。 |

<a id="disable-datadog"></a>

### 禁用 Datadog

为项目禁用 Datadog 集成。集成设置将被重置。

```plaintext
DELETE /projects/:id/integrations/datadog
```

<a id="get-datadog-settings"></a>

### 获取 Datadog 设置

获取项目的 Datadog 集成设置。

```plaintext
GET /projects/:id/integrations/datadog
```

<a id="diffblue-cover"></a>

## Diffblue Cover

<a id="set-up-diffblue-cover"></a>

### 设置 Diffblue Cover

为项目设置 Diffblue Cover 集成。

```plaintext
PUT /projects/:id/integrations/diffblue-cover
```

参数：

| 参数 | 类型 | 必需 | 描述 |
| --------- | ---- | -------- | ----------- |
| `diffblue_license_key` | string | 是 | Diffblue Cover 许可证密钥。 |
| `diffblue_access_token_name` | string | 是 | Diffblue Cover 在流水线中使用的访问令牌名称。 |
| `diffblue_access_token_secret` | string  | 是 | Diffblue Cover 在流水线中使用的访问令牌密钥。 |
| `use_inherited_settings` | boolean | 否 | 指示是否继承默认设置。默认为 `false`。 |

<a id="disable-diffblue-cover"></a>

### 禁用 Diffblue Cover

为项目禁用 Diffblue Cover 集成。集成设置将被重置。

```plaintext
DELETE /projects/:id/integrations/diffblue-cover
```

<a id="get-diffblue-cover-settings"></a>

### 获取 Diffblue Cover 设置

获取项目的 Diffblue Cover 集成设置。

```plaintext
GET /projects/:id/integrations/diffblue-cover
```

<a id="discord-notifications"></a>

## Discord 通知

<a id="set-up-discord-notifications"></a>

### 设置 Discord 通知

为项目设置 Discord 通知。

```plaintext
PUT /projects/:id/integrations/discord
```

参数：

| 参数 | 类型 | 必需 | 描述 |
| --------- | ---- | -------- | ----------- |
| `webhook` | string | 是 | Discord webhook（例如 `https://discord.com/api/webhooks/...`）。 |
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
| `notify_only_broken_pipelines` | boolean | 否 | 为失败的流水线发送通知。 |
| `notify_only_when_pipeline_status_changes` | boolean | 否 | 仅当 ref 的流水线状态发生变化时发送通知。 |
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

为项目禁用 Discord 通知。集成设置将被重置。

```plaintext
DELETE /projects/:id/integrations/discord
```

<a id="get-discord-notifications-settings"></a>

### 获取 Discord 通知设置

获取项目的 Discord 通知设置。

```plaintext
GET /projects/:id/integrations/discord
```

<a id="drone"></a>

## Drone

<a id="set-up-drone"></a>

### 设置 Drone

为项目设置 Drone 集成。

```plaintext
PUT /projects/:id/integrations/drone-ci
```

参数：

| 参数 | 类型 | 必需 | 描述 |
| --------- | ---- | -------- | ----------- |
| `token` | string | 是 | Drone CI 令牌。 |
| `drone_url` | string | 是 | Drone CI URL（例如 `http://drone.example.com`）。 |
| `enable_ssl_verification` | boolean | 否 | 启用 SSL 验证。默认为 `true`（已启用）。 |
| `push_events` | boolean | 否 | 为推送事件启用通知。 |
| `merge_requests_events` | boolean | 否 | 为合并请求事件启用通知。 |
| `tag_push_events` | boolean | 否 | 为标签推送事件启用通知。 |
| `use_inherited_settings` | boolean | 否 | 指示是否继承默认设置。默认为 `false`。 |

<a id="disable-drone"></a>

### 禁用 Drone

为项目禁用 Drone 集成。集成设置将被重置。

```plaintext
DELETE /projects/:id/integrations/drone-ci
```

<a id="get-drone-settings"></a>

### 获取 Drone 设置

获取项目的 Drone 集成设置。

```plaintext
GET /projects/:id/integrations/drone-ci
```

<a id="emails-on-push"></a>

## 推送邮件

<a id="set-up-emails-on-push"></a>

### 设置推送邮件

为项目设置推送邮件集成。

```plaintext
PUT /projects/:id/integrations/emails-on-push
```

参数：

| 参数 | 类型 | 必需 | 描述 |
| --------- | ---- | -------- | ----------- |
| `recipients` | string | 是 | 以空白字符分隔的电子邮件地址。 |
| `disable_diffs` | boolean | 否 | 禁用代码差异。 |
| `send_from_committer_email` | boolean | 否 | 从提交者发送。 |
| `push_events` | boolean | 否 | 为推送事件启用通知。 |
| `tag_push_events` | boolean | 否 | 为标签推送事件启用通知。 |
| `branches_to_be_notified` | string | 否 | 要发送通知的分支。有效选项为 `all`、`default`、`protected` 和 `default_and_protected`。标签推送始终会触发通知。默认值为 `all`。 |
| `use_inherited_settings` | boolean | 否 | 指示是否继承默认设置。默认为 `false`。 |

<a id="disable-emails-on-push"></a>

### 禁用推送邮件

为项目禁用推送邮件集成。集成设置将被重置。

```plaintext
DELETE /projects/:id/integrations/emails-on-push
```

<a id="get-emails-on-push-settings"></a>

### 获取推送邮件设置

获取项目的推送邮件集成设置。

```plaintext
GET /projects/:id/integrations/emails-on-push
```

<a id="engineering-workflow-management-ewm"></a>

## 工程工作流管理 (EWM)

<a id="set-up-ewm"></a>

### 设置 EWM

为项目设置 EWM 集成。

```plaintext
PUT /projects/:id/integrations/ewm
```

参数：

| 参数 | 类型 | 必需 | 描述 |
| --------- | ---- | -------- | ----------- |
| `new_issue_url` | string | 是 | 新议题的 URL。 |
| `project_url`   | string | 是 | 项目的 URL。 |
| `issues_url`    | string | 是 | 议题的 URL。 |
| `use_inherited_settings` | boolean | 否 | 指示是否继承默认设置。默认为 `false`。 |

<a id="disable-ewm"></a>

### 禁用 EWM

为项目禁用 EWM 集成。集成设置将被重置。

```plaintext
DELETE /projects/:id/integrations/ewm
```

<a id="get-ewm-settings"></a>

### 获取 EWM 设置

获取项目的 EWM 集成设置。

```plaintext
GET /projects/:id/integrations/ewm
```

<a id="external-wiki"></a>

## 外部 Wiki

<a id="set-up-an-external-wiki"></a>

### 设置外部 Wiki

为项目设置外部 Wiki。

```plaintext
PUT /projects/:id/integrations/external-wiki
```

参数：

| 参数 | 类型 | 必需 | 描述 |
| --------- | ---- | -------- | ----------- |
| `external_wiki_url` | string | 是 | 外部 Wiki 的 URL。 |
| `use_inherited_settings` | boolean | 否 | 指示是否继承默认设置。默认为 `false`。 |

<a id="disable-an-external-wiki"></a>

### 禁用外部 Wiki

为项目禁用外部 Wiki。集成设置将被重置。

```plaintext
DELETE /projects/:id/integrations/external-wiki
```

<a id="get-external-wiki-settings"></a>

### 获取外部 Wiki 设置

获取项目的外部 Wiki 设置。

```plaintext
GET /projects/:id/integrations/external-wiki
```

<a id="gitguardian"></a>

## GitGuardian

{{< details >}}

- Tier: 专业版，旗舰版
- Offering: JihuLab.com，私有化部署

{{< /details >}}

[GitGuardian](https://www.gitguardian.com/) 是一项网络安全服务，可检测源代码仓库中的敏感数据，例如 API 密钥和密码。它会扫描 Git 代码仓库、就策略违规发出告警，并帮助组织在黑客利用安全问题之前将其修复。

您可以配置极狐GitLab，使其根据 GitGuardian 策略拒绝提交。

有关已知问题和故障排除步骤，请参阅 [GitGuardian 故障排除](../user/project/integrations/git_guardian.md#troubleshooting)。

<a id="set-up-gitguardian"></a>

### 设置 GitGuardian

为项目设置 GitGuardian 集成。

```plaintext
PUT /projects/:id/integrations/git-guardian
```

参数：

| 参数 | 类型 | 必需 | 描述                                   |
| --------- | ---- | -------- |-----------------------------------------------|
| `token` | string | 是 | 具有 `scan` 范围的 GitGuardian API 令牌。 |
| `use_inherited_settings` | boolean | 否 | 指示是否继承默认设置。默认为 `false`。 |

<a id="disable-gitguardian"></a>

### 禁用 GitGuardian

为项目禁用 GitGuardian 集成。集成设置将被重置。

```plaintext
DELETE /projects/:id/integrations/git-guardian
```

<a id="get-gitguardian-settings"></a>

### 获取 GitGuardian 设置

获取项目的 GitGuardian 集成设置。

```plaintext
GET /projects/:id/integrations/git-guardian
```

<a id="github"></a>

## GitHub

{{< details >}}

- Tier: 专业版，旗舰版
- Offering: JihuLab.com，私有化部署

{{< /details >}}

<a id="set-up-github"></a>

### 设置 GitHub

为项目设置 GitHub 集成。

```plaintext
PUT /projects/:id/integrations/github
```

参数：

| 参数 | 类型 | 必需 | 描述 |
| --------- | ---- | -------- | ----------- |
| `token` | string | 是 | 具有 `repo:status` OAuth 范围的 GitHub API 令牌。 |
| `repository_url` | string | 是 | GitHub 代码仓库 URL。 |
| `static_context` | boolean | 否 | 将极狐GitLab 实例的主机名附加到[状态检查名称](../user/project/integrations/github.md#static-or-dynamic-status-check-names)。 |
| `use_inherited_settings` | boolean | 否 | 指示是否继承默认设置。默认为 `false`。 |

<a id="disable-github"></a>

### 禁用 GitHub

为项目禁用 GitHub 集成。集成设置将被重置。

```plaintext
DELETE /projects/:id/integrations/github
```

<a id="get-github-settings"></a>

### 获取 GitHub 设置

获取项目的 GitHub 集成设置。

```plaintext
GET /projects/:id/integrations/github
```

<a id="gitlab-for-jira-cloud-app"></a>

## GitLab for Jira Cloud 应用

GitLab for Jira Cloud 应用集成通过 [Jira 中的群组关联和取消关联](../integration/jira/connect-app.md#configure-the-gitlab-for-jira-cloud-app)自动启用或禁用。您无法通过极狐GitLab 集成表单或 API 启用或禁用该集成。

<a id="update-integration-for-a-project"></a>

### 更新项目的集成

使用此 API 端点更新您在 Jira 中通过群组关联创建的集成。

```plaintext
PUT /projects/:id/integrations/jira-cloud-app
```

参数：

| 参数 | 类型 | 必需 | 描述 |
| --------- | ---- | -------- | ----------- |
| `jira_cloud_app_service_ids` | string | 否 | Jira Service Management 服务 ID。使用逗号（`,`）分隔多个 ID。 |
| `jira_cloud_app_enable_deployment_gating` | boolean | 否 | 为来自 Jira Service Management 的已阻止极狐GitLab 部署启用部署门控。 |
| `jira_cloud_app_deployment_gating_environments` | string | 否 | 要启用部署门控的环境（production、staging、testing 或 development）。如果启用了部署门控，则此参数为必需。使用逗号（`,`）分隔多个环境。 |

<a id="get-gitlab-for-jira-cloud-app-settings"></a>

### 获取 GitLab for Jira Cloud 应用设置

获取项目的 GitLab for Jira Cloud 应用集成设置。

```plaintext
GET /projects/:id/integrations/jira-cloud-app
```

<a id="gitlab-for-slack-app"></a>

## GitLab for Slack 应用

<a id="set-up-gitlab-for-slack-app"></a>

### 设置 GitLab for Slack 应用

更新项目的 GitLab for Slack 应用集成。

您无法通过 API 创建 GitLab for Slack 应用，因为该集成
需要一个无法仅从极狐GitLab API 获取的 OAuth 2.0 令牌。您必须从极狐GitLab UI [安装该应用](../user/project/integrations/gitlab_slack_application.md#install-the-gitlab-for-slack-app)。然后您可以使用此 API 端点更新该集成。

```plaintext
PUT /projects/:id/integrations/gitlab-slack-application
```

参数：

| 参数 | 类型 | 必需 | 描述 |
| --------- | ---- | -------- | ----------- |
| `channel` | string | 否 | 未配置其他频道时使用的默认频道。 |
| `notify_only_broken_pipelines` | boolean | 否 | 为失败的流水线发送通知。 |
| `notify_only_when_pipeline_status_changes` | boolean | 否 | 仅当 ref 的流水线状态发生变化时发送通知。 |
| `notify_only_default_branch` | boolean | 否 | **已弃用**：此参数已被 `branches_to_be_notified` 取代。 |
| `branches_to_be_notified` | string | 否 | 要发送通知的分支。有效选项为 `all`、`default`、`protected` 和 `default_and_protected`。默认值为 `default`。 |
| `alert_events` | boolean | 否 | 为告警事件启用通知。 |
| `issues_events` | boolean | 否 | 为议题事件启用通知。 |
| `confidential_issues_events` | boolean | 否 | 为机密议题事件启用通知。 |
| `merge_requests_events` | boolean | 否 | 为合并请求事件启用通知。 |
| `note_events` | boolean | 否 | 为评论事件启用通知。 |
| `confidential_note_events` | boolean | 否 | 为机密评论事件启用通知。 |
| `deployment_events` | boolean | 否 | 为部署事件启用通知。 |
| `incidents_events` | boolean | 否 | 为故障事件启用通知。 |
| `pipeline_events` | boolean | 否 | 为流水线事件启用通知。 |
| `push_events` | boolean | 否 | 为推送事件启用通知。 |
| `tag_push_events` | boolean | 否 | 为标签推送事件启用通知。 |
| `vulnerability_events` | boolean | 否 | 为漏洞事件启用通知。 |
| `wiki_page_events` | boolean | 否 | 为 Wiki 页面事件启用通知。 |
| `labels_to_be_notified` | string | 否 | 要发送通知的标记。如果未设置，则接收所有事件的通知。 |
| `labels_to_be_notified_behavior` | string | 否 | 要通知的标记。有效选项为 `match_any` 和 `match_all`。默认为 `match_any`。 |
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
| `incident_channel` | string | 否 | 接收故障事件通知的频道名称。 |
| `vulnerability_channel` | string | 否 | 接收漏洞事件通知的频道名称。 |
| `alert_channel` | string | 否 | 接收告警事件通知的频道名称。 |
| `use_inherited_settings` | boolean | 否 | 指示是否继承默认设置。默认为 `false`。 |

<a id="disable-gitlab-for-slack-app"></a>

### 禁用 GitLab for Slack 应用

为项目禁用 GitLab for Slack 应用集成。集成设置将被重置。

```plaintext
DELETE /projects/:id/integrations/gitlab-slack-application
```

<a id="get-gitlab-for-slack-app-settings"></a>

### 获取 GitLab for Slack 应用设置

获取项目的 GitLab for Slack 应用集成设置。

```plaintext
GET /projects/:id/integrations/gitlab-slack-application
```

<a id="google-chat"></a>

## Google Chat

<a id="set-up-google-chat"></a>

### 设置 Google Chat

为项目设置 Google Chat 集成。

```plaintext
PUT /projects/:id/integrations/hangouts-chat
```

参数：

| 参数 | 类型 | 必需 | 描述 |
| --------- | ---- | -------- | ----------- |
| `webhook` | string | 是 | Hangouts Chat webhook（例如 `https://chat.googleapis.com/v1/spaces...`）。 |
| `notify_only_broken_pipelines` | boolean | 否 | 为失败的流水线发送通知。 |
| `notify_only_when_pipeline_status_changes` | boolean | 否 | 仅当 ref 的流水线状态发生变化时发送通知。 |
| `notify_only_default_branch` | boolean | 否 | **已弃用**：此参数已被 `branches_to_be_notified` 取代。 |
| `branches_to_be_notified` | string | 否 | 要发送通知的分支。有效选项为 `all`、`default`、`protected` 和 `default_and_protected`。默认值为 `default`。 |
| `push_events` | boolean | 否 | 为推送事件启用通知。 |
| `issues_events` | boolean | 否 | 为议题事件启用通知。 |
| `confidential_issues_events` | boolean | 否 | 为机密议题事件启用通知。 |
| `merge_requests_events` | boolean | 否 | 为合并请求事件启用通知。 |
| `tag_push_events` | boolean | 否 | 为标签推送事件启用通知。 |
| `note_events` | boolean | 否 | 为评论事件启用通知。 |
| `confidential_note_events` | boolean | 否 | 为机密评论事件启用通知。 |
| `pipeline_events` | boolean | 否 | 为流水线事件启用通知。 |
| `wiki_page_events` | boolean | 否 | 为 Wiki 页面事件启用通知。 |
| `use_inherited_settings` | boolean | 否 | 指示是否继承默认设置。默认为 `false`。 |

<a id="disable-google-chat"></a>

### 禁用 Google Chat

为项目禁用 Google Chat 集成。集成设置将被重置。

```plaintext
DELETE /projects/:id/integrations/hangouts-chat
```

<a id="get-google-chat-settings"></a>

### 获取 Google Chat 设置

获取项目的 Google Chat 集成设置。

```plaintext
GET /projects/:id/integrations/hangouts-chat
```

<a id="google-artifact-management"></a>

## Google Artifact Management

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: JihuLab.com
- Status: 测试版

{{< /details >}}

此功能处于[测试版](../policy/development_stages_support.md)。

<a id="set-up-google-artifact-management"></a>

### 设置 Google Artifact Management

为项目设置 Google Artifact Management 集成。

```plaintext
PUT /projects/:id/integrations/google-cloud-platform-artifact-registry
```

参数：

| 参数 | 类型 | 必需 | 描述 |
| --------- | ---- | -------- | ----------- |
| `artifact_registry_project_id` | string | 是 | Google Cloud 项目的 ID。 |
| `artifact_registry_location` | string | 是 | 制品仓库的位置。 |
| `artifact_registry_repositories` | string | 是 | 制品仓库。 |
| `use_inherited_settings` | boolean | 否 | 指示是否继承默认设置。默认为 `false`。 |

<a id="disable-google-artifact-management"></a>

### 禁用 Google Artifact Management

为项目禁用 Google Artifact Management 集成。集成设置将被重置。

```plaintext
DELETE /projects/:id/integrations/google-cloud-platform-artifact-registry
```

<a id="get-google-artifact-management-settings"></a>

### 获取 Google Artifact Management 设置

获取项目的 Google Artifact Management 集成设置。

```plaintext
GET /projects/:id/integrations/google-cloud-platform-artifact-registry
```

<a id="google-cloud-identity-and-access-management-iam"></a>

## Google Cloud Identity and Access Management (IAM)

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: JihuLab.com
- Status: 测试版

{{< /details >}}

此功能处于[测试版](../policy/development_stages_support.md)。

<a id="set-up-google-cloud-identity-and-access-management"></a>

### 设置 Google Cloud Identity and Access Management

为项目设置 Google Cloud Identity and Access Management 集成。

```plaintext
PUT /projects/:id/integrations/google-cloud-platform-workload-identity-federation
```

参数：

| 参数 | 类型 | 必需 | 描述 |
| --------- | ---- | -------- | ----------- |
| `workload_identity_federation_project_id` | string | 是 | 用于工作负载身份联合的 Google Cloud 项目 ID。 |
| `workload_identity_federation_project_number` | integer | 是 | 用于工作负载身份联合的 Google Cloud 项目编号。 |
| `workload_identity_pool_id` | string | 是 | 工作负载身份池的 ID。 |
| `workload_identity_pool_provider_id` | string | 是 | 工作负载身份池提供程序的 ID。 |
| `use_inherited_settings` | boolean | 否 | 指示是否继承默认设置。默认为 `false`。 |

<a id="disable-google-cloud-identity-and-access-management"></a>

### 禁用 Google Cloud Identity and Access Management

为项目禁用 Google Cloud Identity and Access Management 集成。集成设置将被重置。

```plaintext
DELETE /projects/:id/integrations/google-cloud-platform-workload-identity-federation
```

<a id="get-google-cloud-identity-and-access-management"></a>

### 获取 Google Cloud Identity and Access Management

获取项目的 Google Cloud Identity and Access Management 设置。

```plaintext
GET /projects/:id/integration/google-cloud-platform-workload-identity-federation
```

<a id="google-play"></a>

## Google Play

<a id="set-up-google-play"></a>

### 设置 Google Play

为项目设置 Google Play 集成。

```plaintext
PUT /projects/:id/integrations/google-play
```

参数：

| 参数 | 类型 | 必需 | 描述 |
| --------- | ---- | -------- | ----------- |
| `package_name` | string | 是 | Google Play 中应用的软件包名称。 |
| `service_account_key` | string | 是 | Google Play 服务账号密钥。 |
| `service_account_key_file_name` | string | 是 | Google Play 服务账号密钥的文件名。 |
| `google_play_protected_refs` | boolean | 否 | 仅在受保护分支和标签上设置变量。 |
| `use_inherited_settings` | boolean | 否 | 指示是否继承默认设置。默认为 `false`。 |

<a id="disable-google-play"></a>

### 禁用 Google Play

为项目禁用 Google Play 集成。集成设置将被重置。

```plaintext
DELETE /projects/:id/integrations/google-play
```

<a id="get-google-play-settings"></a>

### 获取 Google Play 设置

获取项目的 Google Play 集成设置。

```plaintext
GET /projects/:id/integrations/google-play
```

<a id="harbor"></a>

## Harbor

<a id="set-up-harbor"></a>

### 设置 Harbor

为项目设置 Harbor 集成。

```plaintext
PUT /projects/:id/integrations/harbor
```

参数：

| 参数 | 类型 | 必需 | 描述 |
| --------- | ---- | -------- | ----------- |
| `url` | string | 是 | 链接到极狐GitLab 项目的 Harbor 实例的基础 URL。例如 `https://demo.goharbor.io`。 |
| `project_name` | string | 是 | Harbor 实例中的项目名称。例如 `testproject`。 |
| `username` | string | 是 | 在 Harbor 界面中创建的用户名。 |
| `password` | string | 是 | 该用户的密码。 |
| `use_inherited_settings` | boolean | 否 | 指示是否继承默认设置。默认为 `false`。 |

<a id="disable-harbor"></a>

### 禁用 Harbor

为项目禁用 Harbor 集成。集成设置将被重置。

```plaintext
DELETE /projects/:id/integrations/harbor
```

<a id="get-harbor-settings"></a>

### 获取 Harbor 设置

获取项目的 Harbor 集成设置。

```plaintext
GET /projects/:id/integrations/harbor
```

<a id="irker-irc-gateway"></a>

## irker (IRC 网关)

<a id="set-up-irker"></a>

### 设置 irker

为项目设置 irker 集成。

```plaintext
PUT /projects/:id/integrations/irker
```

参数：

| 参数 | 类型 | 必需 | 描述 |
| --------- | ---- | -------- | ----------- |
| `recipients` | string | 是 | 以逗号分隔的频道或电子邮件地址列表。 |
| `default_irc_uri` | string | 否 | 在每个收件人之前添加的 URI。默认值为 `irc://irc.network.net:6697/`。 |
| `server_host` | string | 否 | irker 守护进程主机名。默认值为 `localhost`。 |
| `server_port` | integer | 否 | irker 守护进程端口。默认值为 `6659`。 |
| `colorize_messages` | boolean | 否 | 为消息着色。 |
| `use_inherited_settings` | boolean | 否 | 指示是否继承默认设置。默认为 `false`。 |

<a id="disable-irker"></a>

### 禁用 irker

为项目禁用 irker 集成。集成设置将被重置。

```plaintext
DELETE /projects/:id/integrations/irker
```

<a id="get-irker-settings"></a>

### 获取 irker 设置

获取项目的 irker 集成设置。

```plaintext
GET /projects/:id/integrations/irker
```

<a id="jenkins"></a>

## Jenkins

<a id="set-up-jenkins"></a>

### 设置 Jenkins

为项目设置 Jenkins 集成。

```plaintext
PUT /projects/:id/integrations/jenkins
```

参数：

| 参数 | 类型 | 必需 | 描述 |
| --------- | ---- | -------- | ----------- |
| `jenkins_url` | string | 是 | Jenkins 服务器的 URL。 |
| `enable_ssl_verification` | boolean | 否 | 启用 SSL 验证。默认为 `true`（已启用）。 |
| `project_name` | string | 是 | Jenkins 项目的名称。 |
| `username` | string | 否 | Jenkins 服务器的用户名。 |
| `password` | string | 否 | Jenkins 服务器的密码。 |
| `push_events` | boolean | 否 | 为推送事件启用通知。 |
| `merge_requests_events` | boolean | 否 | 为合并请求事件启用通知。 |
| `tag_push_events` | boolean | 否 | 为标签推送事件启用通知。 |
| `use_inherited_settings` | boolean | 否 | 指示是否继承默认设置。默认为 `false`。 |

<a id="disable-jenkins"></a>

### 禁用 Jenkins

为项目禁用 Jenkins 集成。集成设置将被重置。

```plaintext
DELETE /projects/:id/integrations/jenkins
```

<a id="get-jenkins-settings"></a>

### 获取 Jenkins 设置

获取项目的 Jenkins 集成设置。

```plaintext
GET /projects/:id/integrations/jenkins
```

<a id="jetbrains-teamcity"></a>

## JetBrains TeamCity

<a id="set-up-jetbrains-teamcity"></a>

### 设置 JetBrains TeamCity

为项目设置 JetBrains TeamCity 集成。

TeamCity 中的构建配置必须使用构建编号格式 `%build.vcs.number%`。在 VCS 根的高级设置中，为所有分支配置监控，以便合并请求可以构建。

```plaintext
PUT /projects/:id/integrations/teamcity
```

参数：

| 参数 | 类型 | 必需 | 描述 |
| --------- | ---- | -------- | ----------- |
| `teamcity_url` | string | 是 | TeamCity 根 URL（例如 `https://teamcity.example.com`）。 |
| `enable_ssl_verification` | boolean | 否 | 启用 SSL 验证。默认为 `true`（已启用）。 |
| `build_type` | string | 是 | TeamCity 项目的构建配置 ID。 |
| `username` | string | 是 | 具有触发手动构建权限的用户。 |
| `password` | string | 是 | 该用户的密码。 |
| `push_events` | boolean | 否 | 为推送事件启用通知。 |
| `merge_requests_events` | boolean | 否 | 为合并请求事件启用通知。 |
| `use_inherited_settings` | boolean | 否 | 指示是否继承默认设置。默认为 `false`。 |

<a id="disable-jetbrains-teamcity"></a>

### 禁用 JetBrains TeamCity

为项目禁用 JetBrains TeamCity 集成。集成设置将被重置。

```plaintext
DELETE /projects/:id/integrations/teamcity
```

<a id="get-jetbrains-teamcity-settings"></a>

### 获取 JetBrains TeamCity 设置

获取项目的 JetBrains TeamCity 集成设置。

```plaintext
GET /projects/:id/integrations/teamcity
```

<a id="jira-issues"></a>

## Jira 议题

<a id="set-up-jira-issues"></a>

### 设置 Jira 议题

为项目设置 [Jira 议题集成](../integration/jira/configure.md)。

```plaintext
PUT /projects/:id/integrations/jira
```

参数：

| 参数 | 类型 | 必需 | 描述 |
| --------- | ---- | -------- | ----------- |
| `url`           | string | 是 | 链接到此极狐GitLab 项目的 Jira 项目的 URL（例如 `https://jira.example.com`）。 |
| `api_url`   | string | 否 | Jira 实例 API 的基础 URL。如果未设置，则使用 Web URL 值（例如 `https://jira-api.example.com`）。 |
| `username`      | string | 否   | 用于 Jira 的电子邮件或用户名。Jira Cloud 使用电子邮件，Jira Data Center 和 Jira Server 使用用户名。使用基本认证时（`jira_auth_type` 为 `0`）为必需。 |
| `password`      | string | 是  | 用于 Jira 的 Jira API 令牌、密码或个人访问令牌。对于基本认证（`jira_auth_type` 为 `0`），Jira Cloud 使用 API 令牌，Jira Data Center 或 Jira Server 使用密码。对于 Jira 个人访问令牌认证（`jira_auth_type` 为 `1`），使用个人访问令牌。对于 Jira Cloud 服务账号认证，使用 API 令牌。 |
| `jira_auth_type`| integer | 否  | 用于 Jira 的认证方法。使用 `0` 表示基本认证，`1` 表示 Jira 个人访问令牌，`2` 表示 Jira Cloud 服务账号。默认为 `0`。 |
| `jira_issue_prefix` | string | 否 | 用于匹配 Jira 议题键的前缀。 |
| `jira_issue_regex` | string | 否 | 用于匹配 Jira 议题键的正则表达式。 |
| `jira_issue_transition_automatic` | boolean | 否 | 启用[自动议题转换](../integration/jira/issues.md#automatic-issue-transitions)。如果启用，则优先于 `jira_issue_transition_id`。默认为 `false`。 |
| `jira_issue_transition_id` | string | 否 | 用于[自定义议题转换](../integration/jira/issues.md#custom-issue-transitions)的一个或多个转换的 ID。当 `jira_issue_transition_automatic` 启用时忽略。默认为空字符串，即禁用自定义转换。 |
| `commit_events` | boolean | 否 | 为提交事件启用通知。 |
| `merge_requests_events` | boolean | 否 | 为合并请求事件启用通知。 |
| `comment_on_event_enabled` | boolean | 否 | 在每个极狐GitLab 事件（提交或合并请求）上启用 Jira 议题中的评论。 |
| `issues_enabled` | boolean | 否 | 启用在极狐GitLab 中查看 Jira 议题。[引入](https://gitlab.com/gitlab-org/gitlab/-/issues/267015)于极狐GitLab 17.0。 |
| `project_keys` | array of strings | 否 | Jira 项目的键。当 `issues_enabled` 为 `true` 时，此设置指定在极狐GitLab 中查看哪些 Jira 项目的议题。[引入](https://gitlab.com/gitlab-org/gitlab/-/issues/267015)于极狐GitLab 17.0。 |
| `use_inherited_settings` | boolean | 否 | 指示是否继承默认设置。默认为 `false`。 |
| `vulnerabilities_enabled` | boolean | 否 | 仅在极狐GitLab 企业版中可用。设置为 `true` 时，为极狐GitLab 漏洞创建 Jira 议题。 |
| `vulnerabilities_issuetype` | number | 否 | 仅在极狐GitLab 企业版中可用。从漏洞创建议题时要使用的 Jira 议题类型 ID。 |
| `project_key` | string | 否 | 仅在极狐GitLab 企业版中可用。从漏洞创建议题时要使用的项目键。如果使用该集成从漏洞创建议题，则此参数为必需。 |
| `customize_jira_issue_enabled` | boolean | 否 | 仅在极狐GitLab 企业版中可用。设置为 `true` 时，从漏洞创建 Jira 议题时会在 Jira 实例上打开预填表单。 |

<a id="disable-jira"></a>

### 禁用 Jira

为项目禁用 Jira 议题集成。集成设置将被重置。

```plaintext
DELETE /projects/:id/integrations/jira
```

<a id="get-jira-settings"></a>

### 获取 Jira 设置

获取项目的 Jira 议题集成设置。

```plaintext
GET /projects/:id/integrations/jira
```

<a id="linear"></a>

## Linear

<a id="set-up-linear"></a>

### 设置 Linear

为群组设置 Linear 集成。

```plaintext
PUT /projects/:id/integrations/linear
```

参数：

| 参数     | 类型   | 必需 | 描述    |
| ------------- | ------ | -------- | -------------- |
| `workspace_url`  | string | 是     | 议题的 URL。     |
| `use_inherited_settings` | boolean | 否 | 指示是否继承默认设置。默认为 `false`。 |

<a id="disable-linear"></a>

### 禁用 Linear

为群组禁用 Linear 集成。集成设置将被重置。

```plaintext
DELETE /projects/:id/integrations/linear
```

<a id="get-linear-settings"></a>

### 获取 Linear 设置

获取群组的 Linear 集成设置。

```plaintext
GET /projects/:id/integrations/linear
```

<a id="matrix-notifications"></a>

## Matrix 通知

<a id="set-up-matrix-notifications"></a>

### 设置 Matrix 通知

为项目设置 Matrix 通知。

```plaintext
PUT /projects/:id/integrations/matrix
```

参数：

| 参数 | 类型 | 必需 | 描述 |
| --------- | ---- | -------- | ----------- |
| `hostname`   | string | 否 | Matrix 服务器的自定义主机名。默认值为 `https://matrix.org`。 |
| `token`   | string | 是 | Matrix 访问令牌（例如 `syt-zyx57W2v1u123ew11`）。 |
| `room` | string | 是 | 目标房间的唯一标识符（格式为 `!qPKKM111FFKKsfoCVy:matrix.org`）。 |
| `notify_only_broken_pipelines` | boolean | 否 | 为失败的流水线发送通知。 |
| `notify_only_when_pipeline_status_changes` | boolean | 否 | 仅当 ref 的流水线状态发生变化时发送通知。 |
| `branches_to_be_notified` | string | 否 | 要发送通知的分支。有效选项为 `all`、`default`、`protected` 和 `default_and_protected`。默认值为 `default`。 |
| `push_events` | boolean | 否 | 为推送事件启用通知。 |
| `issues_events` | boolean | 否 | 为议题事件启用通知。 |
| `confidential_issues_events` | boolean | 否 | 为机密议题事件启用通知。 |
| `merge_requests_events` | boolean | 否 | 为合并请求事件启用通知。 |
| `tag_push_events` | boolean | 否 | 为标签推送事件启用通知。 |
| `note_events` | boolean | 否 | 为评论事件启用通知。 |
| `confidential_note_events` | boolean | 否 | 为机密评论事件启用通知。 |
| `pipeline_events` | boolean | 否 | 为流水线事件启用通知。 |
| `wiki_page_events` | boolean | 否 | 为 Wiki 页面事件启用通知。 |
| `use_inherited_settings` | boolean | 否 | 指示是否继承默认设置。默认为 `false`。 |

<a id="disable-matrix-notifications"></a>

### 禁用 Matrix 通知

为项目禁用 Matrix 通知。集成设置将被重置。

```plaintext
DELETE /projects/:id/integrations/matrix
```

<a id="get-matrix-notifications-settings"></a>

### 获取 Matrix 通知设置

获取项目的 Matrix 通知设置。

```plaintext
GET /projects/:id/integrations/matrix
```

<a id="mattermost-notifications"></a>

## Mattermost 通知

<a id="set-up-mattermost-notifications"></a>

### 设置 Mattermost 通知

为项目设置 Mattermost 通知。

```plaintext
PUT /projects/:id/integrations/mattermost
```

参数：

| 参数 | 类型 | 必需 | 描述 |
| --------- | ---- | -------- | ----------- |
| `webhook` | string | 是 | Mattermost 通知 webhook（例如 `http://mattermost.example.com/hooks/...`）。 |
| `username` | string | 否 | Mattermost 通知用户名。 |
| `channel` | string | 否 | 未配置其他频道时使用的默认频道。 |
| `notify_only_broken_pipelines` | boolean | 否 | 为失败的流水线发送通知。 |
| `notify_only_when_pipeline_status_changes` | boolean | 否 | 仅当 ref 的流水线状态发生变化时发送通知。 |
| `notify_only_default_branch` | boolean | 否 | **已弃用**：此参数已被 `branches_to_be_notified` 取代。 |
| `branches_to_be_notified` | string | 否 | 要发送通知的分支。有效选项为 `all`、`default`、`protected` 和 `default_and_protected`。默认值为 `default`。 |
| `labels_to_be_notified` | string | 否 | 要发送通知的标记。留空则接收所有事件的通知。 |
| `labels_to_be_notified_behavior` | string | 否 | 要通知的标记。有效选项为 `match_any` 和 `match_all`。默认值为 `match_any`。 |
| `push_events` | boolean | 否 | 为推送事件启用通知。 |
| `issues_events` | boolean | 否 | 为议题事件启用通知。 |
| `confidential_issues_events` | boolean | 否 | 为机密议题事件启用通知。 |
| `merge_requests_events` | boolean | 否 | 为合并请求事件启用通知。 |
| `tag_push_events` | boolean | 否 | 为标签推送事件启用通知。 |
| `note_events` | boolean | 否 | 为评论事件启用通知。 |
| `confidential_note_events` | boolean | 否 | 为机密评论事件启用通知。 |
| `pipeline_events` | boolean | 否 | 为流水线事件启用通知。 |
| `wiki_page_events` | boolean | 否 | 为 Wiki 页面事件启用通知。 |
| `push_channel` | string | 否 | 接收推送事件通知的频道名称。 |
| `issue_channel` | string | 否 | 接收议题事件通知的频道名称。 |
| `confidential_issue_channel` | string | 否 | 接收机密议题事件通知的频道名称。 |
| `merge_request_channel` | string | 否 | 接收合并请求事件通知的频道名称。 |
| `note_channel` | string | 否 | 接收评论事件通知的频道名称。 |
| `confidential_note_channel` | string | 否 | 接收机密评论事件通知的频道名称。 |
| `tag_push_channel` | string | 否 | 接收标签推送事件通知的频道名称。 |
| `pipeline_channel` | string | 否 | 接收流水线事件通知的频道名称。 |
| `wiki_page_channel` | string | 否 | 接收 Wiki 页面事件通知的频道名称。 |
| `use_inherited_settings` | boolean | 否 | 指示是否继承默认设置。默认为 `false`。 |

<a id="disable-mattermost-notifications"></a>

### 禁用 Mattermost 通知

为项目禁用 Mattermost 通知。集成设置将被重置。

```plaintext
DELETE /projects/:id/integrations/mattermost
```

<a id="get-mattermost-notifications-settings"></a>

### 获取 Mattermost 通知设置

获取项目的 Mattermost 通知设置。

```plaintext
GET /projects/:id/integrations/mattermost
```

<a id="mattermost-slash-commands"></a>

## Mattermost 斜杠命令

<a id="set-up-mattermost-slash-commands"></a>

### 设置 Mattermost 斜杠命令

为项目设置 Mattermost 斜杠命令。

```plaintext
PUT /projects/:id/integrations/mattermost-slash-commands
```

参数：

| 参数 | 类型   | 必需 | 描述           |
| --------- | ------ | -------- | --------------------- |
| `token`   | string | 是      | Mattermost 令牌。 |
| `use_inherited_settings` | boolean | 否 | 指示是否继承默认设置。默认为 `false`。 |

<a id="disable-mattermost-slash-commands"></a>

### 禁用 Mattermost 斜杠命令

为项目禁用 Mattermost 斜杠命令。集成设置将被重置。

```plaintext
DELETE /projects/:id/integrations/mattermost-slash-commands
```

<a id="get-mattermost-slash-commands-settings"></a>

### 获取 Mattermost 斜杠命令设置

获取项目的 Mattermost 斜杠命令设置。

```plaintext
GET /projects/:id/integrations/mattermost-slash-commands
```

<a id="microsoft-teams-notifications"></a>

## Microsoft Teams 通知

<a id="set-up-microsoft-teams-notifications"></a>

### 设置 Microsoft Teams 通知

为项目设置 Microsoft Teams 通知。

```plaintext
PUT /projects/:id/integrations/microsoft-teams
```

参数：

| 参数 | 类型 | 必需 | 描述 |
| --------- | ---- | -------- | ----------- |
| `webhook` | string | 是 | Microsoft Teams webhook（例如 `https://outlook.office.com/webhook/...`）。 |
| `notify_only_broken_pipelines` | boolean | 否 | 为失败的流水线发送通知。 |
| `notify_only_when_pipeline_status_changes` | boolean | 否 | 仅当 ref 的流水线状态发生变化时发送通知。 |
| `notify_only_default_branch` | boolean | 否 | **已弃用**：此参数已被 `branches_to_be_notified` 取代。 |
| `branches_to_be_notified` | string | 否 | 要发送通知的分支。有效选项为 `all`、`default`、`protected` 和 `default_and_protected`。默认值为 `default`。 |
| `push_events` | boolean | 否 | 为推送事件启用通知。 |
| `issues_events` | boolean | 否 | 为议题事件启用通知。 |
| `confidential_issues_events` | boolean | 否 | 为机密议题事件启用通知。 |
| `merge_requests_events` | boolean | 否 | 为合并请求事件启用通知。 |
| `tag_push_events` | boolean | 否 | 为标签推送事件启用通知。 |
| `note_events` | boolean | 否 | 为评论事件启用通知。 |
| `confidential_note_events` | boolean | 否 | 为机密评论事件启用通知。 |
| `pipeline_events` | boolean | 否 | 为流水线事件启用通知。 |
| `wiki_page_events` | boolean | 否 | 为 Wiki 页面事件启用通知。 |
| `use_inherited_settings` | boolean | 否 | 指示是否继承默认设置。默认为 `false`。 |

<a id="disable-microsoft-teams-notifications"></a>

### 禁用 Microsoft Teams 通知

为项目禁用 Microsoft Teams 通知。集成设置将被重置。

```plaintext
DELETE /projects/:id/integrations/microsoft-teams
```

<a id="get-microsoft-teams-notifications-settings"></a>

### 获取 Microsoft Teams 通知设置

获取项目的 Microsoft Teams 通知设置。

```plaintext
GET /projects/:id/integrations/microsoft-teams
```

<a id="mock-ci"></a>

## Mock CI

此集成仅在开发环境中可用。有关 Mock CI 服务器的示例，请参见 [`gitlab-org/gitlab-mock-ci-service`](https://gitlab.com/gitlab-org/gitlab-mock-ci-service)。

<a id="set-up-mock-ci"></a>

### 设置 Mock CI

为项目设置 Mock CI 集成。

```plaintext
PUT /projects/:id/integrations/mock-ci
```

参数：

| 参数 | 类型 | 必需 | 描述 |
| --------- | ---- | -------- | ----------- |
| `mock_service_url` | string | 是 | Mock CI 集成的 URL。 |
| `enable_ssl_verification` | boolean | 否 | 启用 SSL 验证。默认为 `true`（启用）。 |
| `use_inherited_settings` | boolean | 否 | 指示是否继承默认设置。默认为 `false`。 |

<a id="disable-mock-ci"></a>

### 禁用 Mock CI

为项目禁用 Mock CI 集成。集成设置将被重置。

```plaintext
DELETE /projects/:id/integrations/mock-ci
```

<a id="get-mock-ci-settings"></a>

### 获取 Mock CI 设置

获取项目的 Mock CI 集成设置。

```plaintext
GET /projects/:id/integrations/mock-ci
```

<a id="packagist"></a>

## Packagist

<a id="set-up-packagist"></a>

### 设置 Packagist

为项目设置 Packagist 集成。

```plaintext
PUT /projects/:id/integrations/packagist
```

参数：

| 参数 | 类型 | 必需 | 描述 |
| --------- | ---- | -------- | ----------- |
| `username` | string | 是 | Packagist 账号的用户名。 |
| `token` | string | 是 | Packagist 服务器的 API 令牌。 |
| `server` | boolean | 否 | Packagist 服务器的 URL。默认值为 `https://packagist.org`。 |
| `push_events` | boolean | 否 | 为推送事件启用通知。 |
| `merge_requests_events` | boolean | 否 | 为合并请求事件启用通知。 |
| `tag_push_events` | boolean | 否 | 为标签推送事件启用通知。 |
| `use_inherited_settings` | boolean | 否 | 指示是否继承默认设置。默认为 `false`。 |

<a id="disable-packagist"></a>

### 禁用 Packagist

为项目禁用 Packagist 集成。集成设置将被重置。

```plaintext
DELETE /projects/:id/integrations/packagist
```

<a id="get-packagist-settings"></a>

### 获取 Packagist 设置

获取项目的 Packagist 集成设置。

```plaintext
GET /projects/:id/integrations/packagist
```

<a id="phorge"></a>

## Phorge

<a id="set-up-phorge"></a>

### 设置 Phorge

为项目设置 Phorge 集成。

```plaintext
PUT /projects/:id/integrations/phorge
```

参数：

| 参数       | 类型   | 必需 | 描述           |
|-----------------|--------|----------|-----------------------|
| `issues_url`    | string | 是     | 议题的 URL。     |
| `project_url`   | string | 是     | 项目的 URL。   |
| `use_inherited_settings` | boolean | 否 | 指示是否继承默认设置。默认为 `false`。 |

<a id="disable-phorge"></a>

### 禁用 Phorge

为项目禁用 Phorge 集成。集成设置将被重置。

```plaintext
DELETE /projects/:id/integrations/phorge
```

<a id="get-phorge-settings"></a>

### 获取 Phorge 设置

获取项目的 Phorge 集成设置。

```plaintext
GET /projects/:id/integrations/phorge
```

<a id="pipeline-status-emails"></a>

## 流水线状态邮件

<a id="set-up-pipeline-status-emails"></a>

### 设置流水线状态邮件

为项目设置流水线状态邮件。

```plaintext
PUT /projects/:id/integrations/pipelines-email
```

参数：

| 参数 | 类型 | 必需 | 描述 |
| --------- | ---- | -------- | ----------- |
| `recipients` | string | 是 | 以逗号分隔的收件人电子邮件地址列表。 |
| `notify_only_broken_pipelines` | boolean | 否 | 为失败的流水线发送通知。 |
| `branches_to_be_notified` | string | 否 | 要发送通知的分支。有效选项为 `all`、`default`、`protected` 和 `default_and_protected`。默认值为 `default`。 |
| `notify_only_default_branch` | boolean | 否 | 为默认分支发送通知。 |
| `pipeline_events` | boolean | 否 | 为流水线事件启用通知。 |
| `use_inherited_settings` | boolean | 否 | 指示是否继承默认设置。默认为 `false`。 |

<a id="disable-pipeline-status-emails"></a>

### 禁用流水线状态邮件

为项目禁用流水线状态邮件。集成设置将被重置。

```plaintext
DELETE /projects/:id/integrations/pipelines-email
```

<a id="get-pipeline-status-emails-settings"></a>

### 获取流水线状态邮件设置

获取项目的流水线状态邮件设置。

```plaintext
GET /projects/:id/integrations/pipelines-email
```

<a id="pivotal-tracker"></a>

## Pivotal Tracker

<a id="set-up-pivotal-tracker"></a>

### 设置 Pivotal Tracker

为项目设置 Pivotal Tracker 集成。

```plaintext
PUT /projects/:id/integrations/pivotaltracker
```

参数：

| 参数 | 类型 | 必需 | 描述 |
| --------- | ---- | -------- | ----------- |
| `token` | string | 是 | Pivotal Tracker 令牌。 |
| `restrict_to_branch` | boolean | 否 | 要自动检查的以逗号分隔的分支列表。留空以包含所有分支。 |
| `use_inherited_settings` | boolean | 否 | 指示是否继承默认设置。默认为 `false`。 |

<a id="disable-pivotal-tracker"></a>

### 禁用 Pivotal Tracker

为项目禁用 Pivotal Tracker 集成。集成设置将被重置。

```plaintext
DELETE /projects/:id/integrations/pivotaltracker
```

<a id="get-pivotal-tracker-settings"></a>

### 获取 Pivotal Tracker 设置

获取项目的 Pivotal Tracker 集成设置。

```plaintext
GET /projects/:id/integrations/pivotaltracker
```

<a id="pumble"></a>

## Pumble

<a id="set-up-pumble"></a>

### 设置 Pumble

为项目设置 Pumble 集成。

```plaintext
PUT /projects/:id/integrations/pumble
```

参数：

| 参数 | 类型 | 必需 | 描述 |
| --------- | ---- | -------- | ----------- |
| `webhook` | string | 是 | Pumble webhook（例如 `https://api.pumble.com/workspaces/x/...`）。 |
| `branches_to_be_notified` | string | 否 | 要发送通知的分支。有效选项为 `all`、`default`、`protected` 和 `default_and_protected`。默认为 `default`。 |
| `confidential_issues_events` | boolean | 否 | 为机密议题事件启用通知。 |
| `confidential_note_events` | boolean | 否 | 为机密评论事件启用通知。 |
| `issues_events` | boolean | 否 | 为议题事件启用通知。 |
| `merge_requests_events` | boolean | 否 | 为合并请求事件启用通知。 |
| `note_events` | boolean | 否 | 为评论事件启用通知。 |
| `notify_only_broken_pipelines` | boolean | 否 | 为失败的流水线发送通知。 |
| `pipeline_events` | boolean | 否 | 为流水线事件启用通知。 |
| `push_events` | boolean | 否 | 为推送事件启用通知。 |
| `tag_push_events` | boolean | 否 | 为标签推送事件启用通知。 |
| `wiki_page_events` | boolean | 否 | 为 Wiki 页面事件启用通知。 |
| `use_inherited_settings` | boolean | 否 | 指示是否继承默认设置。默认为 `false`。 |

<a id="disable-pumble"></a>

### 禁用 Pumble

为项目禁用 Pumble 集成。集成设置将被重置。

```plaintext
DELETE /projects/:id/integrations/pumble
```

<a id="get-pumble-settings"></a>

### 获取 Pumble 设置

获取项目的 Pumble 集成设置。

```plaintext
GET /projects/:id/integrations/pumble
```

<a id="pushover"></a>

## Pushover

<a id="set-up-pushover"></a>

### 设置 Pushover

为项目设置 Pushover 集成。

```plaintext
PUT /projects/:id/integrations/pushover
```

参数：

| 参数 | 类型 | 必需 | 描述 |
| --------- | ---- | -------- | ----------- |
| `api_key` | string | 是 | 应用程序密钥。 |
| `user_key` | string | 是 | 用户密钥。 |
| `priority` | string | 是 | 优先级。 |
| `device` | string | 否 | 留空以发送到所有活动设备。 |
| `sound` | string | 否 | 通知的声音。 |
| `use_inherited_settings` | boolean | 否 | 指示是否继承默认设置。默认为 `false`。 |

<a id="disable-pushover"></a>

### 禁用 Pushover

为项目禁用 Pushover 集成。集成设置将被重置。

```plaintext
DELETE /projects/:id/integrations/pushover
```

<a id="get-pushover-settings"></a>

### 获取 Pushover 设置

获取项目的 Pushover 集成设置。

```plaintext
GET /projects/:id/integrations/pushover
```

<a id="redmine"></a>

## Redmine

<a id="set-up-redmine"></a>

### 设置 Redmine

为项目设置 Redmine 集成。

```plaintext
PUT /projects/:id/integrations/redmine
```

参数：

| 参数 | 类型 | 必需 | 描述 |
| --------- | ---- | -------- | ----------- |
| `new_issue_url` | string | 是 | 新议题的 URL。 |
| `project_url` | string | 是 | 项目的 URL。 |
| `issues_url` | string | 是 | 议题的 URL。 |
| `use_inherited_settings` | boolean | 否 | 指示是否继承默认设置。默认为 `false`。 |

<a id="disable-redmine"></a>

### 禁用 Redmine

为项目禁用 Redmine 集成。集成设置将被重置。

```plaintext
DELETE /projects/:id/integrations/redmine
```

<a id="get-redmine-settings"></a>

### 获取 Redmine 设置

获取项目的 Redmine 集成设置。

```plaintext
GET /projects/:id/integrations/redmine
```

<a id="slack-notifications"></a>

## Slack 通知

<a id="set-up-slack-notifications"></a>

### 设置 Slack 通知

为项目设置 Slack 通知。

```plaintext
PUT /projects/:id/integrations/slack
```

参数：

| 参数 | 类型 | 必需 | 描述 |
| --------- | ---- | -------- | ----------- |
| `webhook` | string | 是 | Slack 通知 webhook（例如 `https://hooks.slack.com/services/...`）。 |
| `username` | string | 否 | Slack 通知用户名。 |
| `channel` | string | 否 | 未配置其他频道时使用的默认频道。 |
| `notify_only_broken_pipelines` | boolean | 否 | 为失败的流水线发送通知。 |
| `notify_only_when_pipeline_status_changes` | boolean | 否 | 仅当 ref 的流水线状态发生变化时发送通知。 |
| `notify_only_default_branch` | boolean | 否 | **已弃用**：此参数已被 `branches_to_be_notified` 取代。 |
| `branches_to_be_notified` | string | 否 | 要发送通知的分支。有效选项为 `all`、`default`、`protected` 和 `default_and_protected`。默认值为 `default`。 |
| `labels_to_be_notified` | string | 否 | 要发送通知的标记。留空以接收所有事件的通知。 |
| `labels_to_be_notified_behavior` | string | 否 | 要通知的标记。有效选项为 `match_any` 和 `match_all`。默认值为 `match_any`。 |
| `alert_channel` | string | 否 | 接收告警事件通知的频道名称。 |
| `alert_events` | boolean | 否 | 为告警事件启用通知。 |
| `commit_events` | boolean | 否 | 为提交事件启用通知。 |
| `confidential_issue_channel` | string | 否 | 接收机密议题事件通知的频道名称。 |
| `confidential_issues_events` | boolean | 否 | 为机密议题事件启用通知。 |
| `confidential_note_channel` | string | 否 | 接收机密评论事件通知的频道名称。 |
| `confidential_note_events` | boolean | 否 | 为机密评论事件启用通知。 |
| `deployment_channel` | string | 否 | 接收部署事件通知的频道名称。 |
| `deployment_events` | boolean | 否 | 为部署事件启用通知。 |
| `incident_channel` | string | 否 | 接收故障事件通知的频道名称。 |
| `incidents_events` | boolean | 否 | 为故障事件启用通知。 |
| `issue_channel` | string | 否 | 接收议题事件通知的频道名称。 |
| `issues_events` | boolean | 否 | 为议题事件启用通知。 |
| `job_events` | boolean | 否 | 为作业事件启用通知。 |
| `merge_request_channel` | string | 否 | 接收合并请求事件通知的频道名称。 |
| `merge_requests_events` | boolean | 否 | 为合并请求事件启用通知。 |
| `note_channel` | string | 否 | 接收评论事件通知的频道名称。 |
| `note_events` | boolean | 否 | 为评论事件启用通知。 |
| `pipeline_channel` | string | 否 | 接收流水线事件通知的频道名称。 |
| `pipeline_events` | boolean | 否 | 为流水线事件启用通知。 |
| `push_channel` | string | 否 | 接收推送事件通知的频道名称。 |
| `push_events` | boolean | 否 | 为推送事件启用通知。 |
| `tag_push_channel` | string | 否 | 接收标签推送事件通知的频道名称。 |
| `tag_push_events` | boolean | 否 | 为标签推送事件启用通知。 |
| `wiki_page_channel` | string | 否 | 接收 Wiki 页面事件通知的频道名称。 |
| `wiki_page_events` | boolean | 否 | 为 Wiki 页面事件启用通知。 |
| `use_inherited_settings` | boolean | 否 | 指示是否继承默认设置。默认为 `false`。 |

<a id="disable-slack-notifications"></a>

### 禁用 Slack 通知

为项目禁用 Slack 通知。集成设置将被重置。

```plaintext
DELETE /projects/:id/integrations/slack
```

<a id="get-slack-notifications-settings"></a>

### 获取 Slack 通知设置

获取项目的 Slack 通知设置。

```plaintext
GET /projects/:id/integrations/slack
```

<a id="squash-tm"></a>

## Squash TM

<a id="set-up-squash-tm"></a>

### 设置 Squash TM

为项目设置 Squash TM 集成设置。

```plaintext
PUT /projects/:id/integrations/squash-tm
```

参数：

| 参数               | 类型   | 必需 | 描述                   |
|-------------------------|--------|----------|-------------------------------|
| `url`                   | string | 是      | Squash TM webhook 的 URL。 |
| `token`                 | string | 否       | 密钥令牌。                 |
| `use_inherited_settings` | boolean | 否 | 指示是否继承默认设置。默认为 `false`。 |

<a id="disable-squash-tm"></a>

### 禁用 Squash TM

为项目禁用 Squash TM 集成。集成设置将被保留。

```plaintext
DELETE /projects/:id/integrations/squash-tm
```

<a id="get-squash-tm-settings"></a>

### 获取 Squash TM 设置

获取项目的 Squash TM 集成设置。

```plaintext
GET /projects/:id/integrations/squash-tm
```

<a id="telegram"></a>

## Telegram

<a id="set-up-telegram"></a>

### 设置 Telegram

为项目设置 Telegram 集成。

```plaintext
PUT /projects/:id/integrations/telegram
```

参数：

| 参数 | 类型 | 必需 | 描述 |
| --------- | ---- | -------- | ----------- |
| `hostname`   | string | 否 | Telegram API 的自定义主机名（[引入](https://gitlab.com/gitlab-org/gitlab/-/issues/461313)于极狐GitLab 17.1）。默认值为 `https://api.telegram.org`。 |
| `token`   | string | 是 | Telegram 机器人令牌（例如 `123456:ABC-DEF1234ghIkl-zyx57W2v1u123ew11`）。 |
| `room` | string | 是 | 目标聊天的唯一标识符或目标频道的用户名（格式为 `@channelusername`）。 |
| `thread` | integer | 否 | 目标消息讨论串的唯一标识符（论坛超级群组中的话题）。 |
| `notify_only_broken_pipelines` | boolean | 否 | 为失败的流水线发送通知。 |
| `notify_only_when_pipeline_status_changes` | boolean | 否 | 仅当 ref 的流水线状态发生变化时发送通知。 |
| `branches_to_be_notified` | string | 否 | 要发送通知的分支。有效选项为 `all`、`default`、`protected` 和 `default_and_protected`。默认值为 `default`。 |
| `push_events` | boolean | 是 | 为推送事件启用通知。 |
| `issues_events` | boolean | 是 | 为议题事件启用通知。 |
| `confidential_issues_events` | boolean | 是 | 为机密议题事件启用通知。 |
| `merge_requests_events` | boolean | 是 | 为合并请求事件启用通知。 |
| `tag_push_events` | boolean | 是 | 为标签推送事件启用通知。 |
| `note_events` | boolean | 是 | 为评论事件启用通知。 |
| `confidential_note_events` | boolean | 是 | 为机密评论事件启用通知。 |
| `pipeline_events` | boolean | 是 | 为流水线事件启用通知。 |
| `wiki_page_events` | boolean | 是 | 为 Wiki 页面事件启用通知。 |
| `use_inherited_settings` | boolean | 否 | 指示是否继承默认设置。默认为 `false`。 |

<a id="disable-telegram"></a>

### 禁用 Telegram

为项目禁用 Telegram 集成。集成设置将被重置。

```plaintext
DELETE /projects/:id/integrations/telegram
```

<a id="get-telegram-settings"></a>

### 获取 Telegram 设置

获取项目的 Telegram 集成设置。

```plaintext
GET /projects/:id/integrations/telegram
```

<a id="unify-circuit"></a>

## Unify Circuit

<a id="set-up-unify-circuit"></a>

### 设置 Unify Circuit

为项目设置 Unify Circuit 集成。

```plaintext
PUT /projects/:id/integrations/unify-circuit
```

参数：

| 参数 | 类型 | 必需 | 描述 |
| --------- | ---- | -------- | ----------- |
| `webhook` | string | 是 | Unify Circuit webhook（例如 `https://circuit.com/rest/v2/webhooks/incoming/...`）。 |
| `notify_only_broken_pipelines` | boolean | 否 | 为失败的流水线发送通知。 |
| `notify_only_when_pipeline_status_changes` | boolean | 否 | 仅当 ref 的流水线状态发生变化时发送通知。 |
| `branches_to_be_notified` | string | 否 | 要发送通知的分支。有效选项为 `all`、`default`、`protected` 和 `default_and_protected`。默认值为 `default`。 |
| `push_events` | boolean | 否 | 为推送事件启用通知。 |
| `issues_events` | boolean | 否 | 为议题事件启用通知。 |
| `confidential_issues_events` | boolean | 否 | 为机密议题事件启用通知。 |
| `merge_requests_events` | boolean | 否 | 为合并请求事件启用通知。 |
| `tag_push_events` | boolean | 否 | 为标签推送事件启用通知。 |
| `note_events` | boolean | 否 | 为评论事件启用通知。 |
| `confidential_note_events` | boolean | 否 | 为机密评论事件启用通知。 |
| `pipeline_events` | boolean | 否 | 为流水线事件启用通知。 |
| `wiki_page_events` | boolean | 否 | 为 Wiki 页面事件启用通知。 |
| `use_inherited_settings` | boolean | 否 | 指示是否继承默认设置。默认为 `false`。 |

<a id="disable-unify-circuit"></a>

### 禁用 Unify Circuit

为项目禁用 Unify Circuit 集成。集成设置将被重置。

```plaintext
DELETE /projects/:id/integrations/unify-circuit
```

<a id="get-unify-circuit-settings"></a>

### 获取 Unify Circuit 设置

获取项目的 Unify Circuit 集成设置。

```plaintext
GET /projects/:id/integrations/unify-circuit
```

<a id="webex-teams"></a>

## Webex Teams

<a id="set-up-webex-teams"></a>

### 设置 Webex Teams

为项目设置 Webex Teams。

```plaintext
PUT /projects/:id/integrations/webex-teams
```

参数：

| 参数 | 类型 | 必需 | 描述 |
| --------- | ---- | -------- | ----------- |
| `webhook` | string | 是 | Webex Teams webhook（例如 `https://api.ciscospark.com/v1/webhooks/incoming/...`）。 |
| `notify_only_broken_pipelines` | boolean | 否 | 为失败的流水线发送通知。 |
| `branches_to_be_notified` | string | 否 | 要发送通知的分支。有效选项为 `all`、`default`、`protected` 和 `default_and_protected`。默认值为 `default`。 |
| `push_events` | boolean | 否 | 为推送事件启用通知。 |
| `issues_events` | boolean | 否 | 为议题事件启用通知。 |
| `confidential_issues_events` | boolean | 否 | 为机密议题事件启用通知。 |
| `merge_requests_events` | boolean | 否 | 为合并请求事件启用通知。 |
| `tag_push_events` | boolean | 否 | 为标签推送事件启用通知。 |
| `note_events` | boolean | 否 | 为评论事件启用通知。 |
| `confidential_note_events` | boolean | 否 | 为机密评论事件启用通知。 |
| `pipeline_events` | boolean | 否 | 为流水线事件启用通知。 |
| `wiki_page_events` | boolean | 否 | 为 Wiki 页面事件启用通知。 |
| `use_inherited_settings` | boolean | 否 | 指示是否继承默认设置。默认为 `false`。 |

<a id="disable-webex-teams"></a>

### 禁用 Webex Teams

为项目禁用 Webex Teams。集成设置将被重置。

```plaintext
DELETE /projects/:id/integrations/webex-teams
```

<a id="get-webex-teams-settings"></a>

### 获取 Webex Teams 设置

获取项目的 Webex Teams 设置。

```plaintext
GET /projects/:id/integrations/webex-teams
```

<a id="youtrack"></a>

## YouTrack

<a id="set-up-youtrack"></a>

### 设置 YouTrack

为项目设置 YouTrack 集成。

```plaintext
PUT /projects/:id/integrations/youtrack
```

参数：

| 参数 | 类型 | 必需 | 描述 |
| --------- | ---- | -------- | ----------- |
| `issues_url` | string | 是 | 议题的 URL。 |
| `project_url` | string | 是 | 项目的 URL。 |
| `use_inherited_settings` | boolean | 否 | 指示是否继承默认设置。默认为 `false`。 |

<a id="disable-youtrack"></a>

### 禁用 YouTrack

为项目禁用 YouTrack 集成。集成设置将被重置。

```plaintext
DELETE /projects/:id/integrations/youtrack
```

<a id="get-youtrack-settings"></a>

### 获取 YouTrack 设置

获取项目的 YouTrack 集成设置。

```plaintext
GET /projects/:id/integrations/youtrack
```
