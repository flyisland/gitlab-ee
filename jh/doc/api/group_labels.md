---
stage: Plan
group: Project Management
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
title: 群组标签 API
---

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: JihuLab.com，私有化部署

{{< /details >}}

{{< history >}}

- `archived` 属性在极狐GitLab 18.3 中引入，受功能标志 `labels_archive` 控制。
- 在极狐GitLab 18.10 中 GA。功能标志 `labels_archive` 已移除。

{{< /history >}}

使用此 API 管理[群组标签](../user/project/labels.md#types-of-labels)。

对于项目标签，请使用[项目标签 API](labels.md)。

## 列出群组标签

<a id="list-group-labels"></a>

获取给定群组的所有标签。

```plaintext
GET /groups/:id/labels
```

| 属性     | 类型           | 是否必需 | 描述                                                                                                                                                                  |
| ---------     | ----           | -------- | -----------                                                                                                                                                                  |
| `id`          | integer 或 string | 是      | 群组的 ID 或 [URL 编码路径](rest/_index.md#namespaced-paths)。                                                               |
| `with_counts` | boolean        | 否       | 是否包含议题和合并请求计数。默认为 `false`。 |
| `include_ancestor_groups` | boolean | 否 | 包含祖先群组。默认为 `true`。 |
| `include_descendant_groups` | boolean | 否 | 包含后代群组。默认为 `false`。 |
| `only_group_labels` | boolean | 否 | 切换为仅包含群组标签或也包含项目标签。默认为 `true`。 |
| `search` | string | 否 | 用于过滤标签的关键字。 |
| `archived` | boolean | 否 | 如果为 `true`，则仅返回已归档的标签。如果未设置，则返回所有标签。 |

```shell
curl \
  --header "PRIVATE-TOKEN: <your_access_token>" \
  --url "https://gitlab.example.com/api/v4/groups/5/labels?with_counts=true"
```

示例响应：

```json
[
  {
    "id": 7,
    "name": "bug",
    "color": "#FF0000",
    "text_color" : "#FFFFFF",
    "description": null,
    "description_html": null,
    "open_issues_count": 0,
    "closed_issues_count": 0,
    "open_merge_requests_count": 0,
    "subscribed": false,
    "archived": false
  },
  {
    "id": 4,
    "name": "feature",
    "color": "#228B22",
    "text_color" : "#FFFFFF",
    "description": null,
    "description_html": null,
    "open_issues_count": 0,
    "closed_issues_count": 0,
    "open_merge_requests_count": 0,
    "subscribed": false,
    "archived": false
  }
]
```

## 获取单个群组标签

<a id="get-a-single-group-label"></a>

获取给定群组的单个标签。

```plaintext
GET /groups/:id/labels/:label_id
```

| 属性     | 类型           | 是否必需 | 描述                                                                                                                                                                  |
| ---------     | ----           | -------- | -----------                                                                                                                                                                  |
| `id`          | integer 或 string | 是      | 群组的 ID 或 [URL 编码路径](rest/_index.md#namespaced-paths)。                                                               |
| `label_id` | integer 或 string | 是 | 群组标签的 ID 或标题。 |
| `include_ancestor_groups` | boolean | 否 | 包含祖先群组。默认为 `true`。 |
| `include_descendant_groups` | boolean | 否 | 包含后代群组。默认为 `false`。 |
| `only_group_labels` | boolean | 否 | 切换为仅包含群组标签或也包含项目标签。默认为 `true`。 |

```shell
curl \
  --header "PRIVATE-TOKEN: <your_access_token>" \
  --url "https://gitlab.example.com/api/v4/groups/5/labels/bug"
```

示例响应：

```json
{
  "id": 7,
  "name": "bug",
  "color": "#FF0000",
  "text_color" : "#FFFFFF",
  "description": null,
  "description_html": null,
  "open_issues_count": 0,
  "closed_issues_count": 0,
  "open_merge_requests_count": 0,
  "subscribed": false,
  "archived": false
}
```

## 创建新群组标签

<a id="create-a-new-group-label"></a>

为给定群组创建一个新的群组标签。

```plaintext
POST /groups/:id/labels
```

| 属性     | 类型    | 是否必需 | 描述                  |
| ------------- | ------- | -------- | ---------------------------- |
| `id` | integer 或 string | 是 | 群组的 ID 或 [URL 编码路径](rest/_index.md#namespaced-paths)。 |
| `name`        | string  | 是      | 标签的名称。        |
| `color`       | string  | 是      | 6 位十六进制符号表示的标签颜色，前面带有 '#' 符号（例如，#FFAABB）或 [CSS 颜色名称](https://developer.mozilla.org/en-US/docs/Web/CSS/color_value#Color_keywords)之一。 |
| `description` | string  | 否       | 标签的描述。 |
| `archived`    | boolean | 否       | 如果为 `true`，则将标签标记为已归档。默认值：`false`。 |

```shell
curl --request POST \
  --header "PRIVATE-TOKEN: <your_access_token>" \
  --header "Content-Type: application/json" \
  --data '{
    "name": "Feature Proposal",
    "color": "#FFA500",
    "description": "Describes new ideas"
  }' \
  --url "https://gitlab.example.com/api/v4/groups/5/labels"
```

示例响应：

```json
{
  "id": 9,
  "name": "Feature Proposal",
  "color": "#FFA500",
  "text_color" : "#FFFFFF",
  "description": "Describes new ideas",
  "description_html": "Describes new ideas",
  "open_issues_count": 0,
  "closed_issues_count": 0,
  "open_merge_requests_count": 0,
  "subscribed": false,
  "archived": false
}
```

## 更新群组标签

<a id="update-a-group-label"></a>

更新现有的群组标签。要更新群组标签，至少需要一个参数。

```plaintext
PUT /groups/:id/labels/:label_id
```

| 属性     | 类型    | 是否必需 | 描述                  |
| ------------- | ------- | -------- | ---------------------------- |
| `id` | integer 或 string | 是 | 群组的 ID 或 [URL 编码路径](rest/_index.md#namespaced-paths)。 |
| `label_id` | integer 或 string | 是 | 群组标签的 ID 或标题。 |
| `new_name`    | string  | 否      | 标签的新名称。        |
| `color`       | string  | 否      | 6 位十六进制符号表示的标签颜色，前面带有 '#' 符号（例如，#FFAABB）或 [CSS 颜色名称](https://developer.mozilla.org/en-US/docs/Web/CSS/color_value#Color_keywords)之一。 |
| `description` | string  | 否       | 标签的描述。 |
| `archived`    | boolean | 否       | 如果为 `true`，则将标签标记为已归档。默认值：`false`。 |

```shell
curl --request PUT \
  --header "PRIVATE-TOKEN: <your_access_token>" \
  --header "Content-Type: application/json" \
  --data '{"new_name": "Feature Idea"}' \
  --url "https://gitlab.example.com/api/v4/groups/5/labels/Feature%20Proposal"
```

示例响应：

```json
{
  "id": 9,
  "name": "Feature Idea",
  "color": "#FFA500",
  "text_color" : "#FFFFFF",
  "description": "Describes new ideas",
  "description_html": "Describes new ideas",
  "open_issues_count": 0,
  "closed_issues_count": 0,
  "open_merge_requests_count": 0,
  "subscribed": false,
  "archived": false
}
```

> [!note]
> 一个较旧的端点 `PUT /groups/:id/labels`（参数中包含 `name`）仍然可用，但已弃用。

## 删除群组标签

<a id="delete-a-group-label"></a>

删除给定名称的群组标签。

```plaintext
DELETE /groups/:id/labels/:label_id
```

| 属性 | 类型    | 是否必需 | 描述           |
| --------- | ------- | -------- | --------------------- |
| `id`      | integer 或 string    | 是      | 群组的 ID 或 [URL 编码路径](rest/_index.md#namespaced-paths)。 |
| `label_id` | integer 或 string | 是 | 群组标签的 ID 或标题。 |

```shell
curl --request DELETE \
  --header "PRIVATE-TOKEN: <your_access_token>" \
  --url "https://gitlab.example.com/api/v4/groups/5/labels/bug"
```

> [!note]
> 一个较旧的端点 `DELETE /groups/:id/labels`（参数中包含 `name`）仍然可用，但已弃用。

## 订阅群组标签

<a id="subscribe-to-a-group-label"></a>

为已认证用户订阅群组标签以接收通知。如果用户已订阅该标签，则返回状态码 `304`。

```plaintext
POST /groups/:id/labels/:label_id/subscribe
```

| 属性  | 类型              | 是否必需 | 描述                          |
| ---------- | ----------------- | -------- | ------------------------------------ |
| `id`      | integer 或 string    | 是      | 群组的 ID 或 [URL 编码路径](rest/_index.md#namespaced-paths)。 |
| `label_id` | integer 或 string | 是      | 群组标签的 ID 或标题。 |

```shell
curl --request POST \
  --header "PRIVATE-TOKEN: <your_access_token>" \
  --url "https://gitlab.example.com/api/v4/groups/5/labels/9/subscribe"
```

示例响应：

```json
{
  "id": 9,
  "name": "Feature Idea",
  "color": "#FFA500",
  "text_color" : "#FFFFFF",
  "description": "Describes new ideas",
  "description_html": "Describes new ideas",
  "open_issues_count": 0,
  "closed_issues_count": 0,
  "open_merge_requests_count": 0,
  "subscribed": true,
  "archived": false
}
```

## 取消订阅群组标签

<a id="unsubscribe-from-a-group-label"></a>

为已认证用户取消订阅群组标签以停止接收通知。如果用户未订阅该标签，则返回状态码 `304`。

```plaintext
POST /groups/:id/labels/:label_id/unsubscribe
```

| 属性  | 类型              | 是否必需 | 描述                          |
| ---------- | ----------------- | -------- | ------------------------------------ |
| `id`      | integer 或 string    | 是      | 群组的 ID 或 [URL 编码路径](rest/_index.md#namespaced-paths)。 |
| `label_id` | integer 或 string | 是      | 群组标签的 ID 或标题。 |

```shell
curl --request POST \
  --header "PRIVATE-TOKEN: <your_access_token>" \
  --url "https://gitlab.example.com/api/v4/groups/5/labels/9/unsubscribe"
```

示例响应：

```json
{
  "id": 9,
  "name": "Feature Idea",
  "color": "#FFA500",
  "text_color" : "#FFFFFF",
  "description": "Describes new ideas",
  "description_html": "Describes new ideas",
  "open_issues_count": 0,
  "closed_issues_count": 0,
  "open_merge_requests_count": 0,
  "subscribed": false,
  "archived": false
}
```