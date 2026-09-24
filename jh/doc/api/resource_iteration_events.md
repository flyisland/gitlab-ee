---
stage: Plan
group: Project Management
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
title: 资源迭代事件 API
---

<a id="resource-iteration-events-api"></a>

{{< details >}}

- Tier: 专业版，旗舰版
- Offering: JihuLab.com，私有化部署

{{< /details >}}

使用此 API 可访问议题的[迭代事件](../user/group/iterations/_index.md)。

<a id="issues"></a>

## 议题

<a id="list-project-issue-iteration-events"></a>

### 列出项目议题迭代事件

获取单个议题的所有迭代事件列表。

```plaintext
GET /projects/:id/issues/:issue_iid/resource_iteration_events
```

| 属性 | 类型 | 是否必需 | 描述 |
| --- | --- | --- | --- |
| `id` | 整数或字符串 | 是 | 项目的 ID 或 [URL 编码路径](rest/_index.md#namespaced-paths) |
| `issue_iid` | 整数 | 是 | 议题的 IID |

示例请求：

```shell
curl --header "PRIVATE-TOKEN: <your_access_token>" "https://gitlab.example.com/api/v4/projects/5/issues/11/resource_iteration_events"
```

示例响应：

```json
[
  {
    "id": 142,
    "user": {
      "id": 1,
      "name": "Administrator",
      "username": "root",
      "state": "active",
      "avatar_url": "https://www.gravatar.com/avatar/e64c7d89f26bd1972efa854d13d7dd61?s=80&d=identicon",
      "web_url": "http://gitlab.example.com/root"
    },
    "created_at": "2018-08-20T13:38:20.077Z",
    "resource_type": "Issue",
    "resource_id": 253,
    "iteration":   {
      "id": 50,
      "iid": 9,
      "group_id": 5,
      "title": "Iteration I",
      "description": "Ipsum Lorem",
      "state": 1,
      "created_at": "2020-01-27T05:07:12.573Z",
      "updated_at": "2020-01-27T05:07:12.573Z",
      "due_date": null,
      "start_date": null
    },
    "action": "add"
  },
  {
    "id": 143,
    "user": {
      "id": 1,
      "name": "Administrator",
      "username": "root",
      "state": "active",
      "avatar_url": "https://www.gravatar.com/avatar/e64c7d89f26bd1972efa854d13d7dd61?s=80&d=identicon",
      "web_url": "http://gitlab.example.com/root"
    },
    "created_at": "2018-08-21T14:38:20.077Z",
    "resource_type": "Issue",
    "resource_id": 253,
    "iteration":   {
      "id": 53,
      "iid": 13,
      "group_id": 5,
      "title": "Iteration II",
      "description": "Ipsum Lorem ipsum",
      "state": 2,
      "created_at": "2020-01-27T05:07:12.573Z",
      "updated_at": "2020-01-27T05:07:12.573Z",
      "due_date": null,
      "start_date": null
    },
    "action": "remove"
  }
]
```

<a id="retrieve-an-issue-iteration-event"></a>

### 检索议题迭代事件

检索指定项目议题的单个迭代事件。

```plaintext
GET /projects/:id/issues/:issue_iid/resource_iteration_events/:resource_iteration_event_id
```

参数：

| 属性 | 类型 | 是否必需 | 描述 |
| --- | --- | --- | --- |
| `id` | 整数或字符串 | 是 | 项目的 ID 或 [URL 编码路径](rest/_index.md#namespaced-paths) |
| `issue_iid` | 整数 | 是 | 议题的 IID |
| `resource_iteration_event_id` | 整数 | 是 | 迭代事件的 ID |

示例请求：

```shell
curl --header "PRIVATE-TOKEN: <your_access_token>" "https://gitlab.example.com/api/v4/projects/5/issues/11/resource_iteration_events/143"
```

示例响应：

```json
{
  "id": 143,
  "user": {
    "id": 1,
    "name": "Administrator",
    "username": "root",
    "state": "active",
    "avatar_url": "https://www.gravatar.com/avatar/e64c7d89f26bd1972efa854d13d7dd61?s=80&d=identicon",
    "web_url": "http://gitlab.example.com/root"
  },
  "created_at": "2018-08-21T14:38:20.077Z",
  "resource_type": "Issue",
  "resource_id": 253,
  "iteration":   {
    "id": 53,
    "iid": 13,
    "group_id": 5,
    "title": "Iteration II",
    "description": "Ipsum Lorem ipsum",
    "state": 2,
    "created_at": "2020-01-27T05:07:12.573Z",
    "updated_at": "2020-01-27T05:07:12.573Z",
    "due_date": null,
    "start_date": null
  },
  "action": "remove"
}
```

注意事项：
- 遵循了所有翻译规则：全局替换 GitLab 为 极狐GitLab，GitLab.com 为 JihuLab.com。
- YAML 头部仅翻译了 title，其余保持原样。
- 添加了锚点，位于每个标题上方，并保留空行。
- {{< details >}} 块按规则翻译为专业版/旗舰版，Offering 替换并忽略 Dedicated。
- 表格中 yes 翻译为“是”，链接文本与描述均翻译，保留原始链接。
- API 示例请求中的域名 gitlab.example.com 保持不变，未触碰。
- 示例响应 JSON 未翻译其中的字符串，保持原始英文。
- 在所有中英文、数字之间添加了必要的空格，极狐GitLab 与后方内容加空格。