---
stage: Plan
group: Project Management
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
title: 群组迭代 API
---

{{< details >}}

- Tier: 专业版，旗舰版
- Offering: JihuLab.com，私有化部署

{{< /details >}}

使用此 API 访问[群组迭代](../user/group/iterations/_index.md)。

对于项目迭代，请使用[项目迭代 API](iterations.md)。

## 列出所有群组迭代

<a id="list-all-group-iterations"></a>

列出指定群组的所有迭代。

在[迭代节奏](../user/group/iterations/_index.md#iteration-cadences)中通过 **启用自动排期** 创建的迭代，其 `title` 和 `description` 字段会返回 `null`。

```plaintext
GET /groups/:id/iterations
GET /groups/:id/iterations?state=opened
GET /groups/:id/iterations?state=closed
GET /groups/:id/iterations?search=version
GET /groups/:id/iterations?include_ancestors=false
GET /groups/:id/iterations?include_descendants=true
GET /groups/:id/iterations?updated_before=2013-10-02T09%3A24%3A18Z
GET /groups/:id/iterations?updated_after=2013-10-02T09%3A24%3A18Z
```

| 属性                   | 类型       | 是否必需 | 描述 |
| --------------------- | -------- | -------- | ----------- |
| `state`               | 字符串     | 否       | 返回 `opened`、`upcoming`、`current`、`closed` 或 `all` 迭代。 |
| `search`              | 字符串     | 否       | 仅返回标题匹配所提供字符串的迭代。                              |
| `in`                  | 字符串数组 | 否       | 指定使用 `search` 参数中的查询进行模糊搜索的字段。可用选项为 `title` 和 `cadence_title`。默认为 `[title]`。在极狐GitLab 16.2 引入。 |
| `include_ancestors`   | 布尔值     | 否       | 包含群组及其祖先的迭代。默认为 `true`。                    |
| `include_descendants` | 布尔值     | 否       | 包含群组及其后代的迭代。默认为 `false`。在极狐GitLab 16.7 引入。 |
| `updated_before`      | 日期时间   | 否       | 仅返回在给定日期时间之前更新的迭代。预期为 ISO 8601 格式（`2019-03-15T08:00:00Z`）。在极狐GitLab 15.10 引入。 |
| `updated_after`       | 日期时间   | 否       | 仅返回在给定日期时间之后更新的迭代。预期为 ISO 8601 格式（`2019-03-15T08:00:00Z`）。在极狐GitLab 15.10 引入。 |

示例请求：

```shell
  curl --header "PRIVATE-TOKEN: <your_access_token>" \
  --url "https://gitlab.example.com/api/v4/groups/5/iterations"
```

示例响应：

```json
[
  {
    "id": 53,
    "iid": 13,
    "sequence": 1,
    "group_id": 5,
    "title": "Iteration II",
    "description": "Ipsum Lorem ipsum",
    "state": 2,
    "created_at": "2020-01-27T05:07:12.573Z",
    "updated_at": "2020-01-27T05:07:12.573Z",
    "due_date": "2020-02-01",
    "start_date": "2020-02-14",
    "web_url": "http://gitlab.example.com/groups/my-group/-/iterations/13"
  }
]
```