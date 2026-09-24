---
stage: Plan
group: Project Management
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
title: 资源权重事件 API
---

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: JihuLab.com，私有化部署

{{< /details >}}

使用此 API 访问议题的权重变更事件。

<a id="issues"></a>

## 议题

<a id="list-all-project-issue-weight-events"></a>

### 列出所有项目议题权重事件

列出单个议题的所有权重事件。

```plaintext
GET /projects/:id/issues/:issue_iid/resource_weight_events
```

| 属性 | 类型 | 是否必需 | 描述 |
| ----------- | -------------- | -------- | ------------------------------------------------------------------------------- |
| `id` | 整数或字符串 | 是 | 项目 ID 或 [URL 编码路径](rest/_index.md#namespaced-paths) |
| `issue_iid` | 整数 | 是 | 议题的 IID |

示例请求：

```shell
curl --request GET \
  --header "PRIVATE-TOKEN: <your_access_token>" \
  --url "https://gitlab.example.com/api/v4/projects/5/issues/11/resource_weight_events"
```

示例响应：

```json
[
  {
    "id": 142,
    "user": {
      "id": 1,
      "name": "管理员",
      "username": "root",
      "state": "active",
      "avatar_url": "https://www.gravatar.com/avatar/e64c7d89f26bd1972efa854d13d7dd61?s=80&d=identicon",
      "web_url": "http://gitlab.example.com/root"
    },
    "created_at": "2018-08-20T13:38:20.077Z",
    "issue_id": 253,
    "weight": 3
  },
  {
    "id": 143,
    "user": {
      "id": 1,
      "name": "管理员",
      "username": "root",
      "state": "active",
      "avatar_url": "https://www.gravatar.com/avatar/e64c7d89f26bd1972efa854d13d7dd61?s=80&d=identicon",
      "web_url": "http://gitlab.example.com/root"
    },
    "created_at": "2018-08-21T14:38:20.077Z",
    "issue_id": 253,
    "weight": 2
  }
]
```

<a id="retrieve-single-issue-weight-event"></a>

### 获取单个议题权重事件

获取特定项目议题的单个权重事件。

```plaintext
GET /projects/:id/issues/:issue_iid/resource_weight_events/:resource_weight_event_id
```

参数：

| 属性 | 类型 | 是否必需 | 描述 |
| ----------------------------- | -------------- | -------- | ------------------------------------------------------------------------------- |
| `id` | 整数或字符串 | 是 | 项目 ID 或 [URL 编码路径](rest/_index.md#namespaced-paths) |
| `issue_iid` | 整数 | 是 | 议题的 IID |
| `resource_weight_event_id` | 整数 | 是 | 权重事件的 ID |

示例请求：

```shell
curl --request GET \
  --header "PRIVATE-TOKEN: <your_access_token>" \
  --url "https://gitlab.example.com/api/v4/projects/5/issues/11/resource_weight_events/143"
```

示例响应：

```json
{
"id": 143,
"user": {
  "id": 1,
  "name": "管理员",
  "username": "root",
  "state": "active",
  "avatar_url": "https://www.gravatar.com/avatar/e64c7d89f26bd1972efa854d13d7dd61?s=80&d=identicon",
  "web_url": "http://gitlab.example.com/root"
},
"created_at": "2018-08-21T14:38:20.077Z",
"issue_id": 253,
"weight": 2
}
```