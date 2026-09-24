---
stage: Plan
group: Project Management
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
title: 通知设置 API
---

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: JihuLab.com，私有化部署

{{< /details >}}

使用此 API 管理极狐GitLab 中的通知设置。
更多信息，请参见[通知邮件](../user/profile/notifications.md)。

<a id="notification-levels"></a>

### 通知级别

通知级别定义在 `NotificationSetting.level` 模型枚举中。
这些级别被识别：

- `禁用`：关闭所有通知
- `参与`：接收您参与过的讨论帖的通知
- `关注`：接收大多数活动的通知
- `全局`：使用您的全局通知设置
- `提及`：当您在评论中被提及时接收通知
- `自定义`：接收所选事件的通知

如果您使用 `自定义` 级别，您可以控制特定的邮件事件。可用事件由 `NotificationSetting.email_events` 返回。
这些事件被识别：

| 事件                          | 描述 |
| ------------------------------ | ----------- |
| `approver`                     | 当您有资格审批的合并请求被创建时 |
| `change_reviewer_merge_request`| 当合并请求的审核人变更时 |
| `close_issue`                  | 当议题关闭时 |
| `close_merge_request`          | 当合并请求关闭时 |
| `failed_pipeline`              | 当流水线失败时 |
| `fixed_pipeline`               | 当之前失败的流水线修复时 |
| `issue_due`                    | 当议题明天到期时 |
| `merge_merge_request`          | 当合并请求合并时 |
| `merge_when_pipeline_succeeds` | 当合并请求设置为自动合并时 |
| `moved_project`                | 当项目移动时 |
| `new_epic`                     | 当新史诗创建时（专业版和旗舰版） |
| `new_issue`                    | 当新议题创建时 |
| `new_merge_request`            | 当新合并请求创建时 |
| `new_note`                     | 当有人添加评论时 |
| `new_release`                  | 当新版本发布时 |
| `push_to_merge_request`        | 当有人向合并请求推送时 |
| `reassign_issue`               | 当议题重新指派时 |
| `reassign_merge_request`       | 当合并请求重新指派时 |
| `reopen_issue`                 | 当议题重新打开时 |
| `reopen_merge_request`         | 当合并请求重新打开时 |
| `success_pipeline`             | 当流水线成功完成时 |

<a id="retrieve-global-notification-settings"></a>

### 获取全局通知设置

获取全局通知级别和电子邮件地址。

```plaintext
GET /notification_settings
```

示例请求：

```shell
curl --header "PRIVATE-TOKEN: <your_access_token>" \
  --url "https://gitlab.example.com/api/v4/notification_settings"
```

如果成功，返回 [`200 OK`](rest/troubleshooting.md#status-codes) 及以下响应属性：

| 属性            | 类型   | 描述 |
| -------------------- | ------ | ----------- |
| `level`              | 字符串 | 全局通知级别 |
| `notification_email` | 字符串 | 发送通知的电子邮件地址 |

示例响应：

```json
{
  "level": "participating",
  "notification_email": "admin@example.com"
}
```

<a id="update-global-notification-settings"></a>

### 更新全局通知设置

更新通知设置和电子邮件地址。

```plaintext
PUT /notification_settings
```

示例请求：

```shell
curl --request PUT --header "PRIVATE-TOKEN: <your_access_token>" \
  --url "https://gitlab.example.com/api/v4/notification_settings?level=watch"
```

支持的属性：

| 属性                      | 类型    | 必需 | 描述 |
| ------------------------------ | ------- | -------- | ----------- |
| `approver`                     | 布尔 | 否       | 当您有资格审批的合并请求被创建时开启通知 |
| `change_reviewer_merge_request`| 布尔 | 否       | 当合并请求的审核人变更时开启通知 |
| `close_issue`                  | 布尔 | 否       | 当议题关闭时开启通知 |
| `close_merge_request`          | 布尔 | 否       | 当合并请求关闭时开启通知 |
| `failed_pipeline`              | 布尔 | 否       | 当流水线失败时开启通知 |
| `fixed_pipeline`               | 布尔 | 否       | 当之前失败的流水线修复时开启通知 |
| `issue_due`                    | 布尔 | 否       | 当议题明天到期时开启通知 |
| `level`                        | 字符串  | 否       | 全局通知级别 |
| `merge_merge_request`          | 布尔 | 否       | 当合并请求合并时开启通知 |
| `merge_when_pipeline_succeeds` | 布尔 | 否       | 当合并请求设置为自动合并时开启通知 |
| `moved_project`                | 布尔 | 否       | 当项目移动时开启通知 |
| `new_epic`                     | 布尔 | 否       | 当新史诗创建时开启通知（专业版和旗舰版） |
| `new_issue`                    | 布尔 | 否       | 当新议题创建时开启通知 |
| `new_merge_request`            | 布尔 | 否       | 当新合并请求创建时开启通知 |
| `new_note`                     | 布尔 | 否       | 当有新评论添加时开启通知 |
| `new_release`                  | 布尔 | 否       | 当新版本发布时开启通知 |
| `notification_email`           | 字符串  | 否       | 发送通知的电子邮件地址 |
| `push_to_merge_request`        | 布尔 | 否       | 当有人向合并请求推送时开启通知 |
| `reassign_issue`               | 布尔 | 否       | 当议题重新指派时开启通知 |
| `reassign_merge_request`       | 布尔 | 否       | 当合并请求重新指派时开启通知 |
| `reopen_issue`                 | 布尔 | 否       | 当议题重新打开时开启通知 |
| `reopen_merge_request`         | 布尔 | 否       | 当合并请求重新打开时开启通知 |
| `success_pipeline`             | 布尔 | 否       | 当流水线成功完成时开启通知 |

如果成功，返回 [`200 OK`](rest/troubleshooting.md#status-codes) 及以下响应属性：

| 属性            | 类型   | 描述 |
| -------------------- | ------ | ----------- |
| `level`              | 字符串 | 全局通知级别 |
| `notification_email` | 字符串 | 发送通知的电子邮件地址 |

示例响应：

```json
{
  "level": "watch",
  "notification_email": "admin@example.com"
}
```

<a id="retrieve-notification-settings"></a>

### 获取通知设置

获取指定群组或项目的通知级别。

```plaintext
GET /groups/:id/notification_settings
GET /projects/:id/notification_settings
```

示例请求：

```shell
curl --header "PRIVATE-TOKEN: <your_access_token>" \
  --url "https://gitlab.example.com/api/v4/groups/5/notification_settings"
```

```shell
curl --header "PRIVATE-TOKEN: <your_access_token>" \
  --url "https://gitlab.example.com/api/v4/projects/8/notification_settings"
```

支持的属性：

| 属性 | 类型              | 必需 | 描述 |
| --------- | ----------------- | -------- | ----------- |
| `id`      | 整数或字符串 | 是      | 群组或项目的 ID 或 [URL 编码路径](rest/_index.md#namespaced-paths) |

如果成功，返回 [`200 OK`](rest/troubleshooting.md#status-codes) 及以下响应属性：

| 属性 | 类型   | 描述 |
| --------- | ------ | ----------- |
| `level`   | 字符串 | 通知级别 |

标准通知级别的示例响应：

```json
{
  "level": "global"
}
```

自定义通知级别的群组示例响应：

```json
{
  "level": "custom",
  "events": {
    "new_release": null,
    "new_note": null,
    "new_issue": null,
    "reopen_issue": null,
    "close_issue": null,
    "reassign_issue": null,
    "issue_due": null,
    "new_merge_request": null,
    "push_to_merge_request": null,
    "reopen_merge_request": null,
    "close_merge_request": null,
    "reassign_merge_request": null,
    "change_reviewer_merge_request": null,
    "merge_merge_request": null,
    "failed_pipeline": null,
    "fixed_pipeline": null,
    "success_pipeline": null,
    "moved_project": true,
    "merge_when_pipeline_succeeds": false,
    "new_epic": null
  }
}
```

此响应中：

- `true` 表示通知已开启。
- `false` 表示通知已关闭。
- `null` 表示通知使用默认设置。

> [!note]
> `new_epic` 属性仅在专业版和旗舰版中可用。

<a id="update-group-or-project-notification-settings"></a>

### 更新群组或项目通知设置

更新群组或项目的通知设置。

```plaintext
PUT /groups/:id/notification_settings
PUT /projects/:id/notification_settings
```

示例请求：

```shell
curl --request PUT --header "PRIVATE-TOKEN: <your_access_token>" \
  --url "https://gitlab.example.com/api/v4/groups/5/notification_settings?level=watch"
```

```shell
curl --request PUT --header "PRIVATE-TOKEN: <your_access_token>" \
  --url "https://gitlab.example.com/api/v4/projects/8/notification_settings?level=custom&new_note=true"
```

支持的属性：

| 属性                      | 类型              | 必需 | 描述 |
| ------------------------------ | ----------------- | -------- | ----------- |
| `approver`                     | 布尔           | 否       | 当您有资格审批的合并请求被创建时开启通知 |
| `change_reviewer_merge_request`| 布尔           | 否       | 当合并请求的审核人变更时开启通知 |
| `close_issue`                  | 布尔           | 否       | 当议题关闭时开启通知 |
| `close_merge_request`          | 布尔           | 否       | 当合并请求关闭时开启通知 |
| `failed_pipeline`              | 布尔           | 否       | 当流水线失败时开启通知 |
| `fixed_pipeline`               | 布尔           | 否       | 当之前失败的流水线修复时开启通知 |
| `id`                           | 整数或字符串 | 是      | 群组或项目的 ID 或 [URL 编码路径](rest/_index.md#namespaced-paths) |
| `issue_due`                    | 布尔           | 否       | 当议题明天到期时开启通知 |
| `level`                        | 字符串            | 否       | 此群组或项目的通知级别 |
| `merge_merge_request`          | 布尔           | 否       | 当合并请求合并时开启通知 |
| `merge_when_pipeline_succeeds` | 布尔           | 否       | 当合并请求设置为流水线成功后合并时开启通知 |
| `moved_project`                | 布尔           | 否       | 当项目移动时开启通知 |
| `new_epic`                     | 布尔           | 否       | 当新史诗创建时开启通知（专业版和旗舰版） |
| `new_issue`                    | 布尔           | 否       | 当新议题创建时开启通知 |
| `new_merge_request`            | 布尔           | 否       | 当新合并请求创建时开启通知 |
| `new_note`                     | 布尔           | 否       | 当有新评论添加时开启通知 |
| `new_release`                  | 布尔           | 否       | 当新版本发布时开启通知 |
| `push_to_merge_request`        | 布尔           | 否       | 当有人向合并请求推送时开启通知 |
| `reassign_issue`               | 布尔           | 否       | 当议题重新指派时开启通知 |
| `reassign_merge_request`       | 布尔           | 否       | 当合并请求重新指派时开启通知 |
| `reopen_issue`                 | 布尔           | 否       | 当议题重新打开时开启通知 |
| `reopen_merge_request`         | 布尔           | 否       | 当合并请求重新打开时开启通知 |
| `success_pipeline`             | 布尔           | 否       | 当流水线成功完成时开启通知 |

如果成功，返回 [`200 OK`](rest/troubleshooting.md#status-codes) 以及以下响应格式之一。

对于非自定义通知级别：

```json
{
  "level": "watch"
}
```

对于自定义通知级别，响应包含 `events` 对象，显示每个通知的状态：

```json
{
  "level": "custom",
  "events": {
    "new_release": null,
    "new_note": true,
    "new_issue": false,
    "reopen_issue": null,
    "close_issue": null,
    "reassign_issue": null,
    "issue_due": null,
    "new_merge_request": null,
    "push_to_merge_request": null,
    "reopen_merge_request": null,
    "close_merge_request": null,
    "reassign_merge_request": null,
    "change_reviewer_merge_request": null,
    "merge_merge_request": null,
    "failed_pipeline": false,
    "fixed_pipeline": null,
    "success_pipeline": null,
    "moved_project": false,
    "merge_when_pipeline_succeeds": false,
    "new_epic": null
  }
}
```

此响应中：

- `true` 表示通知已开启。
- `false` 表示通知已关闭。
- `null` 表示通知使用默认设置。

> [!note]
> `new_epic` 属性仅在专业版和旗舰版中可用。