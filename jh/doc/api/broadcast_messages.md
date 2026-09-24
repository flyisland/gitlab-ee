---
stage: Growth
group: Acquisition
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
title: 广播消息 API
description: 管理广播消息，支持用户角色定向、路径过滤和可定制主题。
---

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: 私有化部署

{{< /details >}}

{{< history >}}

- `target_access_levels` 在极狐GitLab 14.8 [通过一个功能标志](../administration/feature_flags/_index.md) 引入，名为 `role_targeted_broadcast_messages`，默认禁用。
- `color` 参数在极狐GitLab 15.6 [移除](https://gitlab.com/gitlab-org/gitlab/-/merge_requests/95829)。
- `theme` 在极狐GitLab 17.6 [引入](https://gitlab.com/gitlab-org/gitlab/-/issues/498900)。

{{< /history >}}

使用此 API 与用户界面中显示的横幅和通知进行交互。更多信息请参见[广播消息](../administration/broadcast_messages.md)。

GET 请求无需认证。所有其他广播消息 API 端点仅管理员可访问。非 GET 请求由以下角色发出时：

- 访客 会得到 `401 Unauthorized`。
- 普通用户会得到 `403 Forbidden`。

<a id="list-all-broadcast-messages"></a>

### 列出所有广播消息

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: JihuLab.com，私有化部署

{{< /details >}}

列出所有广播消息。

```plaintext
GET /broadcast_messages
```

示例请求：

```shell
curl "https://gitlab.example.com/api/v4/broadcast_messages"
```

示例响应：

```json
[
    {
        "message":"示例广播消息",
        "starts_at":"2016-08-24T23:21:16.078Z",
        "ends_at":"2016-08-26T23:21:16.080Z",
        "font":"#FFFFFF",
        "id":1,
        "active": false,
        "target_access_levels": [10,30],
        "target_path": "*/welcome",
        "broadcast_type": "banner",
        "dismissable": false,
        "theme": "indigo"
    }
]
```

<a id="retrieve-a-broadcast-message"></a>

### 获取单个广播消息

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: JihuLab.com，私有化部署

{{< /details >}}

获取指定的广播消息。

```plaintext
GET /broadcast_messages/:id
```

参数：

| 属性 | 类型 | 是否必需 | 描述 |
|:----------|:--------|:---------|:-------------------------------------|
| `id` | integer | 是 | 要获取的广播消息 ID。 |

示例请求：

```shell
curl "https://gitlab.example.com/api/v4/broadcast_messages/1"
```

示例响应：

```json
{
    "message":"正在进行部署",
    "starts_at":"2016-08-24T23:21:16.078Z",
    "ends_at":"2016-08-26T23:21:16.080Z",
    "font":"#FFFFFF",
    "id":1,
    "active":false,
    "target_access_levels": [10,30],
    "target_path": "*/welcome",
    "broadcast_type": "banner",
    "dismissable": false,
    "theme": "indigo"
}
```

<a id="create-a-broadcast-message"></a>

### 创建广播消息

> [!warning]
> 广播消息无论定向设置如何，均可通过 API 公开访问。不要包含敏感或机密信息，也不要使用广播消息向特定群组或项目传达私人信息。

创建一条广播消息。

```plaintext
POST /broadcast_messages
```

参数：

| 属性 | 类型 | 是否必需 | 描述 |
|:-----------------------|:------------------|:---------|:------------|
| `message` | string | 是 | 要显示的消息。 |
| `starts_at` | datetime | 否 | 开始时间（默认为当前 UTC 时间）。应为 ISO 8601 格式（`2019-03-15T08:00:00Z`） |
| `ends_at` | datetime | 否 | 结束时间（默认为当前 UTC 时间后一小时）。应为 ISO 8601 格式（`2019-03-15T08:00:00Z`） |
| `font` | string | 否 | 前景色十六进制代码。 |
| `target_access_levels` | array of integers | 否 | 广播消息的目标访问级别（角色）。 |
| `target_path` | string | 否 | 广播消息的目标路径。 |
| `broadcast_type` | string | 否 | 显示类型（默认为 banner） |
| `dismissable` | boolean | 否 | 用户可否关闭该消息？ |
| `theme` | string | 否 | 广播消息的颜色主题（仅横幅）。 |

`target_access_levels` 定义在 `Gitlab::Access` 模块中。以下级别有效：

- 访客（`10`）
- 计划者（`15`）
- 报告者（`20`）
- 安全管理员（`25`）
- 开发者（`30`）
- 维护者（`40`）
- 所有者（`50`）

`theme` 选项定义在 `System::BroadcastMessage` 类中。以下主题有效：

- `indigo`（默认）
- `light-indigo`
- `blue`
- `light-blue`
- `green`
- `light-green`
- `red`
- `light-red`
- `dark`
- `light`

示例请求：

```shell
curl --data "message=正在进行部署&target_access_levels[]=10&target_access_levels[]=30&theme=red" \
  --header "PRIVATE-TOKEN: <your_access_token>" \
  --url "https://gitlab.example.com/api/v4/broadcast_messages"
```

示例响应：

```json
{
    "message":"正在进行部署",
    "starts_at":"2016-08-26T00:41:35.060Z",
    "ends_at":"2016-08-26T01:41:35.060Z",
    "font":"#FFFFFF",
    "id":1,
    "active": true,
    "target_access_levels": [10,30],
    "target_path": "*/welcome",
    "broadcast_type": "notification",
    "dismissable": false,
    "theme": "red"
}
```

<a id="update-a-broadcast-message"></a>

### 更新广播消息

> [!warning]
> 广播消息无论定向设置如何，均可通过 API 公开访问。不要包含敏感或机密信息，也不要使用广播消息向特定群组或项目传达私人信息。

更新指定的广播消息。

```plaintext
PUT /broadcast_messages/:id
```

参数：

| 属性 | 类型 | 是否必需 | 描述 |
|:-----------------------|:------------------|:---------|:------------|
| `id` | integer | 是 | 要更新的广播消息 ID。 |
| `message` | string | 否 | 要显示的消息。 |
| `starts_at` | datetime | 否 | 开始时间（UTC）。应为 ISO 8601 格式（`2019-03-15T08:00:00Z`） |
| `ends_at` | datetime | 否 | 结束时间（UTC）。应为 ISO 8601 格式（`2019-03-15T08:00:00Z`） |
| `font` | string | 否 | 前景色十六进制代码。 |
| `target_access_levels` | array of integers | 否 | 广播消息的目标访问级别（角色）。 |
| `target_path` | string | 否 | 广播消息的目标路径。 |
| `broadcast_type` | string | 否 | 显示类型（默认为 banner） |
| `dismissable` | boolean | 否 | 用户可否关闭该消息？ |
| `theme` | string | 否 | 广播消息的颜色主题（仅横幅）。 |

`target_access_levels` 定义在 `Gitlab::Access` 模块中。以下级别有效：

- 访客（`10`）
- 计划者（`15`）
- 报告者（`20`）
- 开发者（`30`）
- 维护者（`40`）
- 所有者（`50`）

`theme` 选项定义在 `System::BroadcastMessage` 类中。以下主题有效：

- `indigo`（默认）
- `light-indigo`
- `blue`
- `light-blue`
- `green`
- `light-green`
- `red`
- `light-red`
- `dark`
- `light`

示例请求：

```shell
curl --request PUT \
  --data "message=更新消息" \
  --header "PRIVATE-TOKEN: <your_access_token>" \
  --url "https://gitlab.example.com/api/v4/broadcast_messages/1"
```

示例响应：

```json
{
    "message":"更新消息",
    "starts_at":"2016-08-26T00:41:35.060Z",
    "ends_at":"2016-08-26T01:41:35.060Z",
    "font":"#FFFFFF",
    "id":1,
    "active": true,
    "target_access_levels": [10,30],
    "target_path": "*/welcome",
    "broadcast_type": "notification",
    "dismissable": false,
    "theme": "indigo"
}
```

<a id="delete-a-broadcast-message"></a>

### 删除广播消息

删除指定的广播消息。

```plaintext
DELETE /broadcast_messages/:id
```

参数：

| 属性 | 类型 | 是否必需 | 描述 |
|:----------|:--------|:---------|:-----------------------------------|
| `id` | integer | 是 | 要删除的广播消息 ID。 |

示例请求：

```shell
curl --request DELETE \
  --header "PRIVATE-TOKEN: <your_access_token>" \
  --url "https://gitlab.example.com/api/v4/broadcast_messages/1"
```