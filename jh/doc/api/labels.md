---
stage: Plan
group: Project Management
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
title: 项目标签 API
---

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: JihuLab.com，私有化部署

{{< /details >}}

{{< history >}}

- `archived` 属性在极狐GitLab 18.3 中引入，[带有功能标志](../administration/feature_flags/_index.md)，名为 `labels_archive`。
- 在极狐GitLab 18.10 中 GA。功能标志 `labels_archive` 已移除。

{{< /history >}}

使用此 API 管理[项目标签](../user/project/labels.md)。

对于群组标签，请使用[群组标签 API](group_labels.md)。

<a id="list-all-project-labels"></a>

## 列出所有项目标签

列出指定项目的所有标签。

默认情况下，此请求每次返回 20 条结果，因为 API 结果[已分页](rest/_index.md#pagination)。

```plaintext
GET /projects/:id/labels
```

| 属性     | 类型           | 必填 | 描述                                                                                                                                                                  |
| ---------     | -------        | -------- | ---------------------                                                                                                                                                        |
| `id`          | integer 或 string | 是      | 项目的 ID 或 [URL 编码路径](rest/_index.md#namespaced-paths)                                                              |
| `with_counts` | boolean        | 否       | 是否包含议题和合并请求计数。默认为 `false`。 |
| `include_ancestor_groups` | boolean | 否 | 包含祖先群组。默认为 `true`。 |
| `search` | string | 否 | 用于过滤标签的关键词。 |
| `archived` | boolean | 否 | 如果为 `true`，则仅返回已归档标签。如果未设置，则返回所有标签。 |

```shell
curl \
  --header "PRIVATE-TOKEN: <your_access_token>" \
  --url "https://gitlab.example.com/api/v4/projects/1/labels?with_counts=true"
```

示例响应：

```json
[
  {
    "id" : 1,
    "name" : "缺陷",
    "color" : "#d9534f",
    "text_color" : "#FFFFFF",
    "description": "用户报告的缺陷",
    "description_html": "用户报告的缺陷",
    "open_issues_count": 1,
    "closed_issues_count": 0,
    "open_merge_requests_count": 1,
    "subscribed": false,
    "priority": 10,
    "is_project_label": true,
    "archived": false
  },
  {
    "id" : 4,
    "color" : "#d9534f",
    "text_color" : "#FFFFFF",
    "name" : "已确认",
    "description": "已确认的议题",
    "description_html": "已确认的议题",
    "open_issues_count": 2,
    "closed_issues_count": 5,
    "open_merge_requests_count": 0,
    "subscribed": false,
    "priority": null,
    "is_project_label": true,
    "archived": false
  },
  {
    "id" : 7,
    "name" : "严重",
    "color" : "#d9534f",
    "text_color" : "#FFFFFF",
    "description": "严重议题。需要尽快修复",
    "description_html": "严重议题。需要尽快修复",
    "open_issues_count": 1,
    "closed_issues_count": 3,
    "open_merge_requests_count": 1,
    "subscribed": false,
    "priority": null,
    "is_project_label": true,
    "archived": false
  },
  {
    "id" : 8,
    "name" : "文档",
    "color" : "#f0ad4e",
    "text_color" : "#FFFFFF",
    "description": "关于文档的议题",
    "description_html": "关于文档的议题",
    "open_issues_count": 1,
    "closed_issues_count": 0,
    "open_merge_requests_count": 2,
    "subscribed": false,
    "priority": null,
    "is_project_label": false,
    "archived": false
  },
  {
    "id" : 9,
    "color" : "#5cb85c",
    "text_color" : "#FFFFFF",
    "name" : "功能增强",
    "description": "功能增强提案",
    "description_html": "功能增强提案",
    "open_issues_count": 1,
    "closed_issues_count": 0,
    "open_merge_requests_count": 1,
    "subscribed": true,
    "priority": null,
    "is_project_label": true,
    "archived": false
  }
]
```

<a id="retrieve-a-project-label"></a>

## 获取项目标签

获取项目的指定标签。

```plaintext
GET /projects/:id/labels/:label_id
```

| 属性     | 类型           | 必填 | 描述                                                                                                                                                                  |
| ---------     | -------        | -------- | ---------------------                                                                                                                                                        |
| `id`          | integer 或 string | 是      | 项目的 ID 或 [URL 编码路径](rest/_index.md#namespaced-paths)                                                              |
| `label_id` | integer 或 string | 是 | 项目标签的 ID 或标题。 |
| `include_ancestor_groups` | boolean | 否 | 包含祖先群组。默认为 `true`。 |

```shell
curl \
  --header "PRIVATE-TOKEN: <your_access_token>" \
  --url "https://gitlab.example.com/api/v4/projects/1/labels/bug"
```

示例响应：

```json
{
  "id" : 1,
  "name" : "缺陷",
  "color" : "#d9534f",
  "text_color" : "#FFFFFF",
  "description": "用户报告的缺陷",
  "description_html": "用户报告的缺陷",
  "open_issues_count": 1,
  "closed_issues_count": 0,
  "open_merge_requests_count": 1,
  "subscribed": false,
  "priority": 10,
  "is_project_label": true,
  "archived": false
}
```

<a id="create-a-project-label"></a>

## 创建项目标签

为指定项目创建一个具有指定名称和颜色的标签。

```plaintext
POST /projects/:id/labels
```

| 属性     | 类型    | 必填 | 描述                  |
| ------------- | ------- | -------- | ---------------------------- |
| `id`      | integer 或 string    | 是      | 项目的 ID 或 [URL 编码路径](rest/_index.md#namespaced-paths) |
| `name`        | string  | 是      | 标签的名称        |
| `color`       | string  | 是      | 标签的颜色，使用 6 位十六进制表示法，带有前导 '#' 符号（例如 #FFAABB），或使用 [CSS 颜色名称](https://developer.mozilla.org/en-US/docs/Web/CSS/color_value#Color_keywords) |
| `description` | string  | 否       | 标签的描述 |
| `priority`    | integer | 否       | 标签的优先级。必须大于或等于零，或者为 `null` 以移除优先级。 |
| `archived`    | boolean | 否       | 如果为 `true`，则将标签标记为已归档。默认值：`false`。 |

```shell
curl --request POST \
  --header "PRIVATE-TOKEN: <your_access_token>" \
  --url "https://gitlab.example.com/api/v4/projects/1/labels" \
  --data "name=feature&color=#5843AD"
```

示例响应：

```json
{
  "id" : 10,
  "name" : "特性",
  "color" : "#5843AD",
  "text_color" : "#FFFFFF",
  "description":null,
  "description_html":null,
  "open_issues_count": 0,
  "closed_issues_count": 0,
  "open_merge_requests_count": 0,
  "subscribed": false,
  "priority": null,
  "is_project_label": true,
  "archived": false
}
```

<a id="delete-a-project-label"></a>

## 删除项目标签

从项目中删除指定的标签。

```plaintext
DELETE /projects/:id/labels/:label_id
```

| 属性 | 类型    | 必填 | 描述           |
| --------- | ------- | -------- | --------------------- |
| `id`            | integer 或 string | 是 | 项目的 ID 或 [URL 编码路径](rest/_index.md#namespaced-paths) |
| `label_id` | integer 或 string | 是 | 项目标签的 ID 或标题。 |

```shell
curl --request DELETE \
  --header "PRIVATE-TOKEN: <your_access_token>" \
  --url "https://gitlab.example.com/api/v4/projects/1/labels/bug"
```

> [!note]
> 旧端点 `DELETE /projects/:id/labels`（参数中带有 `name`）仍然可用，但已弃用。

<a id="update-a-project-label"></a>

## 更新项目标签

使用新名称或颜色更新项目的指定标签。更新标签至少需要一个参数。

```plaintext
PUT /projects/:id/labels/:label_id
```

| 属性       | 类型    | 必填                          | 描述                      |
| --------------- | ------- | --------------------------------- | -------------------------------  |
| `id`      | integer 或 string    | 是      | 项目的 ID 或 [URL 编码路径](rest/_index.md#namespaced-paths) |
| `label_id` | integer 或 string | 是 | 项目标签的 ID 或标题。 |
| `new_name`      | string  | 如果未提供 `color` 则为是    | 标签的新名称        |
| `color`         | string  | 如果未提供 `new_name` 则为是 | 标签的颜色，使用 6 位十六进制表示法，带有前导 '#' 符号（例如 #FFAABB），或使用 [CSS 颜色名称](https://developer.mozilla.org/en-US/docs/Web/CSS/color_value#Color_keywords) |
| `description`   | string  | 否                                | 标签的新描述 |
| `priority`    | integer | 否       | 标签的新优先级。必须大于或等于零，或者为 `null` 以移除优先级。 |
| `archived`    | boolean | 否       | 如果为 `true`，则将标签标记为已归档。默认值：`false`。 |

```shell
curl --request PUT \
  --header "PRIVATE-TOKEN: <your_access_token>" \
  --url "https://gitlab.example.com/api/v4/projects/1/labels/documentation" \
  --data "new_name=docs&color=#8E44AD&description=Documentation"
```

示例响应：

```json
{
  "id" : 8,
  "name" : "docs",
  "color" : "#8E44AD",
  "text_color" : "#FFFFFF",
  "description": "文档",
  "description_html": "文档",
  "open_issues_count": 1,
  "closed_issues_count": 0,
  "open_merge_requests_count": 2,
  "subscribed": false,
  "priority": null,
  "is_project_label": true,
  "archived": false
}
```

> [!note]
> 旧端点 `PUT /projects/:id/labels`（参数中带有 `name` 或 `label_id`）仍然可用，但已弃用。

<a id="promote-a-project-label-to-a-group-label"></a>

## 将项目标签提升为群组标签

将指定的项目标签提升为群组标签。该标签保留其 ID。

```plaintext
PUT /projects/:id/labels/:label_id/promote
```

| 属性       | 类型    | 必填                          | 描述                      |
| --------------- | ------- | --------------------------------- | -------------------------------  |
| `id`      | integer 或 string    | 是      | 项目的 ID 或 [URL 编码路径](rest/_index.md#namespaced-paths) |
| `label_id` | integer 或 string | 是 | 项目标签的 ID 或标题。 |

```shell
curl --request PUT \
  --header "PRIVATE-TOKEN: <your_access_token>" \
  --url "https://gitlab.example.com/api/v4/projects/1/labels/documentation/promote"
```

示例响应：

```json
{
  "id" : 8,
  "name" : "文档",
  "color" : "#8E44AD",
  "description": "文档",
  "description_html": "文档",
  "open_issues_count": 1,
  "closed_issues_count": 0,
  "open_merge_requests_count": 2,
  "subscribed": false,
  "archived": false
}
```

> [!note]
> 旧端点 `PUT /projects/:id/labels/promote`（参数中带有 `name`）仍然可用，但已弃用。

<a id="subscribe-to-a-project-label"></a>

## 订阅项目标签

让已认证用户订阅指定的项目标签以接收通知。如果用户已经订阅了该标签，则返回状态码 `304`。

```plaintext
POST /projects/:id/labels/:label_id/subscribe
```

| 属性  | 类型              | 必填 | 描述                          |
| ---------- | ----------------- | -------- | ------------------------------------ |
| `id`      | integer 或 string    | 是      | 项目的 ID 或 [URL 编码路径](rest/_index.md#namespaced-paths) |
| `label_id` | integer 或 string | 是      | 项目标签的 ID 或标题 |

```shell
curl --request POST \
  --header "PRIVATE-TOKEN: <your_access_token>" \
  --url "https://gitlab.example.com/api/v4/projects/5/labels/1/subscribe"
```

示例响应：

```json
{
  "id" : 1,
  "name" : "缺陷",
  "color" : "#d9534f",
  "text_color" : "#FFFFFF",
  "description": "用户报告的缺陷",
  "description_html": "用户报告的缺陷",
  "open_issues_count": 1,
  "closed_issues_count": 0,
  "open_merge_requests_count": 1,
  "subscribed": true,
  "priority": null,
  "is_project_label": true,
  "archived": false
}
```

<a id="unsubscribe-from-a-project-label"></a>

## 取消订阅项目标签

让已认证用户取消订阅指定的项目标签以停止接收通知。如果用户未订阅该标签，则返回状态码 `304`。

```plaintext
POST /projects/:id/labels/:label_id/unsubscribe
```

| 属性  | 类型              | 必填 | 描述                          |
| ---------- | ----------------- | -------- | ------------------------------------ |
| `id`      | integer 或 string    | 是      | 项目的 ID 或 [URL 编码路径](rest/_index.md#namespaced-paths) |
| `label_id` | integer 或 string | 是      | 项目标签的 ID 或标题 |

```shell
curl --request POST \
  --header "PRIVATE-TOKEN: <your_access_token>" \
  --url "https://gitlab.example.com/api/v4/projects/5/labels/1/unsubscribe"
```