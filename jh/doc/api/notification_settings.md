---
stage: Plan
group: Work Items
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
description: REST API，用于检索和更新您的账号、群组和项目的通知设置。
title: 通知设置 API
---

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: JihuLab.com，私有化部署

{{< /details >}}

使用此 API 管理极狐GitLab 中的通知设置。更多信息，请参阅[通知邮件](../user/profile/notifications.md)。

<a id="notification-levels"></a>

## 通知级别

通知级别在 `NotificationSetting.level` 模型枚举中定义。可识别以下级别：

- `disabled`：关闭所有通知
- `participating`：接收您参与过的讨论串的通知
- `watch`：接收大多数活动的通知
- `global`：使用您的全局通知设置
- `mention`：当您在评论中被提及时接收通知
- `custom`：接收所选事件的通知

如果您使用 `custom` 级别，可以控制特定的邮件事件。可用事件由 `NotificationSetting.email_events` 返回。可识别以下事件：

| 事件                          | 描述 |
| ------------------------------ | ----------- |
| `approver`                     | 创建了您有资格批准的合并请求 |
| `change_reviewer_merge_request`| 当合并请求的审核人发生变更时 |
| `close_issue`                  | 当议题被关闭时 |
| `close_merge_request`          | 当合并请求被关闭时 |
| `failed_pipeline`              | 当流水线失败时 |
| `fixed_pipeline`               | 当之前失败的流水线被修复时 |
| `issue_due`                    | 当议题明天到期时 |
| `merge_merge_request`          | 当合并请求被合并时 |
| `merge_when_pipeline_succeeds` | 当合并请求被设置为自动合并时 |
| `moved_project`                | 当项目被移动时 |
| `new_epic`                     | 当创建新史诗时（在专业版和旗舰版中） |
| `new_issue`                    | 当创建新议题时 |
| `new_merge_request`            | 当创建新合并请求时 |
| `new_note`                     | 当有人添加评论时 |
| `new_release`                  | 当发布新版本时 |
| `push_to_merge_request`        | 当有人推送到合并请求时 |
| `reassign_issue`               | 当议题被重新指派时 |
| `reassign_merge_request`       | 当合并请求被重新指派时 |
| `reopen_issue`                 | 当议题被重新打开时 |
| `reopen_merge_request`         | 当合并请求被重新打开时 |
| `success_pipeline`             | 当流水线成功完成时 |

<a id="retrieve-global-notification-settings"></a>

## 检索全局通知设置

检索全局通知级别和电子邮件地址。

```plaintext
GET /notification_settings
```

示例请求：

```shell
curl --request GET \
  --header "PRIVATE-TOKEN: <your_access_token>" \
  --url "https://gitlab.example.com/api/v4/notification_settings"
```

如果成功，返回 [`200 OK`](rest/troubleshooting.md#status-codes) 以及以下响应属性：

| 属性            | 类型   | 描述 |
| -------------------- | ------ | ----------- |
| `level`              | string | 全局通知级别 |
| `notification_email` | string | 发送通知的电子邮件地址 |

示例响应：

```json
{
  "level": "participating",
  "notification_email": "admin@example.com"
}
```

<a id="update-global-notification-settings"></a>

## 更新全局通知设置

更新通知设置和电子邮件地址。

```plaintext
PUT /notification_settings
```

示例请求：

```shell
curl --request PUT \
  --header "PRIVATE-TOKEN: <your_access_token>" \
  --url "https://gitlab.example.com/api/v4/notification_settings?level=watch"
```

支持的属性：

| 属性                      | 类型    | 是否必需 | 描述 |
| ------------------------------ | ------- | -------- | ----------- |
| `approver`                     | boolean | 否       | 当创建您有资格批准的合并请求时开启通知 |
| `change_reviewer_merge_request`| boolean | 否       | 当合并请求的审核人发生变更时开启通知 |
| `close_issue`                  | boolean | 否       | 当议题被关闭时开启通知 |
| `close_merge_request`          | boolean | 否       | 当合并请求被关闭时开启通知 |
| `failed_pipeline`              | boolean | 否       | 当流水线失败时开启通知 |
| `fixed_pipeline`               | boolean | 否       | 当之前失败的流水线被修复时开启通知 |
| `issue_due`                    | boolean | 否       | 当议题明天到期时开启通知 |
| `level`                        | string  | 否       | 全局通知级别 |
| `merge_merge_request`          | boolean | 否       | 当合并请求被合并时开启通知 |
| `merge_when_pipeline_succeeds` | boolean | 否       | 当合并请求被设置为自动合并时开启通知 |
| `moved_project`                | boolean | 否       | 当项目被移动时开启通知 |
| `new_epic`                     | boolean | 否       | 当创建新史诗时开启通知（在专业版和旗舰版中） |
| `new_issue`                    | boolean | 否       | 当创建新议题时开启通知 |
| `new_merge_request`            | boolean | 否       | 当创建新合并请求时开启通知 |
| `new_note`                     | boolean | 否       | 当添加新评论时开启通知 |
| `new_release`                  | boolean | 否       | 当发布新版本时开启通知 |
| `notification_email`           | string  | 否       | 发送通知的电子邮件地址 |
| `push_to_merge_request`        | boolean | 否       | 当有人推送到合并请求时开启通知 |
| `reassign_issue`               | boolean | 否       | 当议题被重新指派时开启通知 |
| `reassign_merge_request`       | boolean | 否       | 当合并请求被重新指派时开启通知 |
| `reopen_issue`                 | boolean | 否       | 当议题被重新打开时开启通知 |
| `reopen_merge_request`         | boolean | 否       | 当合并请求被重新打开时开启通知 |
| `success_pipeline`             | boolean | 否       | 当流水线成功完成时开启通知 |

如果成功，返回 [`200 OK`](rest/troubleshooting.md#status-codes) 以及以下响应属性：

| 属性            | 类型   | 描述 |
| -------------------- | ------ | ----------- |
| `level`              | string | 全局通知级别 |
| `notification_email` | string | 发送通知的电子邮件地址 |

示例响应：

```json
{
  "level": "watch",
  "notification_email": "admin@example.com"
}
```

<a id="retrieve-notification-settings"></a>

## 检索通知设置

检索指定群组或项目的通知级别。

```plaintext
GET /groups/:id/notification_settings
GET /projects/:id/notification_settings
```

示例请求：

```shell
curl --request GET \
  --header "PRIVATE-TOKEN: <your_access_token>" \
  --url "https://gitlab.example.com/api/v4/groups/5/notification_settings"
```

```shell
curl --request GET \
  --header "PRIVATE-TOKEN: <your_access_token>" \
  --url "https://gitlab.example.com/api/v4/projects/8/notification_settings"
```

支持的属性：

| 属性 | 类型              | 是否必需 | 描述 |
| --------- | ----------------- | -------- | ----------- |
| `id`      | integer or string | 是      | 群组或项目的 ID 或 [URL 编码路径](rest/_index.md#namespaced-paths) |

如果成功，返回 [`200 OK`](rest/troubleshooting.md#status-codes) 以及以下响应属性：

| 属性 | 类型   | 描述 |
| --------- | ------ | ----------- |
| `level`   | string | 通知级别 |

标准通知级别的示例响应：

```json
{
  "level": "global"
}
```

具有自定义通知级别的群组的示例响应：

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

在此响应中：

- `true` 表示通知已开启。
- `false` 表示通知已关闭。
- `null` 表示通知使用默认设置。

> [!note]
> `new_epic` 属性仅在专业版和旗舰版中可用。

<a id="update-group-or-project-notification-settings"></a>

## 更新群组或项目通知设置

更新群组或项目的通知设置。

```plaintext
PUT /groups/:id/notification_settings
PUT /projects/:id/notification_settings
```

示例请求：

```shell
curl --request PUT \
  --header "PRIVATE-TOKEN: <your_access_token>" \
  --url "https://gitlab.example.com/api/v4/groups/5/notification_settings?level=watch"
```

```shell
curl --request PUT \
  --header "PRIVATE-TOKEN: <your_access_token>" \
  --url "https://gitlab.example.com/api/v4/projects/8/notification_settings?level=custom&new_note=true"
```

支持的属性：

| 属性                      | 类型              | 是否必需 | 描述 |
| ------------------------------ | ----------------- | -------- | ----------- |
| `approver`                     | boolean           | 否       | 当创建您有资格批准的合并请求时开启通知 |
| `change_reviewer_merge_request`| boolean           | 否       | 当合并请求的审核人发生变更时开启通知 |
| `close_issue`                  | boolean           | 否       | 当议题被关闭时开启通知 |
| `close_merge_request`          | boolean           | 否       | 当合并请求被关闭时开启通知 |
| `failed_pipeline`              | boolean           | 否       | 当流水线失败时开启通知 |
| `fixed_pipeline`               | boolean           | 否       | 当之前失败的流水线被修复时开启通知 |
| `id`                           | integer or string | 是      | 群组或项目的 ID 或 [URL 编码路径](rest/_index.md#namespaced-paths) |
| `issue_due`                    | boolean           | 否       | 当议题明天到期时开启通知 |
| `level`                        | string            | 否       | 此群组或项目的通知级别 |
| `merge_merge_request`          | boolean           | 否       | 当合并请求被合并时开启通知 |
| `merge_when_pipeline_succeeds` | boolean           | 否       | 当合并请求被设置为流水线成功后自动合并时开启通知 |
| `moved_project`                | boolean           | 否       | 当项目被移动时开启通知 |
| `new_epic`                     | boolean           | 否       | 当创建新史诗时开启通知（在专业版和旗舰版中） |
| `new_issue`                    | boolean           | 否       | 当创建新议题时开启通知 |
| `new_merge_request`            | boolean           | 否       | 当创建新合并请求时开启通知 |
| `new_note`                     | boolean           | 否       | 当添加新评论时开启通知 |
| `new_release`                  | boolean           | 否       | 当发布新版本时开启通知 |
| `push_to_merge_request`        | boolean           | 否       | 当有人推送到合并请求时开启通知 |
| `reassign_issue`               | boolean           | 否       | 当议题被重新指派时开启通知 |
| `reassign_merge_request`       | boolean           | 否       | 当合并请求被重新指派时开启通知 |
| `reopen_issue`                 | boolean           | 否       | 当议题被重新打开时开启通知 |
| `reopen_merge_request`         | boolean           | 否       | 当合并请求被重新打开时开启通知 |
| `success_pipeline`             | boolean           | 否       | 当流水线成功完成时开启通知 |

如果成功，返回 [`200 OK`](rest/troubleshooting.md#status-codes) 以及以下响应格式之一。

对于非自定义通知级别：

```json
{
  "level": "watch"
}
```

对于自定义通知级别，响应包含一个 `events` 对象，显示每个通知的状态：

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

在此响应中：

- `true` 表示通知已开启。
- `false` 表示通知已关闭。
- `null` 表示通知使用默认设置。

> [!note]
> `new_epic` 属性仅在专业版和旗舰版中可用。
