---
stage: Plan
group: Project Management
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
title: 项目迭代 API
---

{{< details >}}

- Tier: 专业版，旗舰版
- Offering: JihuLab.com，私有化部署

{{< /details >}}

使用此 API 访问[项目迭代](../user/group/iterations/_index.md)。

对于群组迭代，请使用[群组迭代 API](group_iterations.md)。

我们不再有项目级别的迭代，但你可以使用此端点获取项目祖先群组的迭代。

<a id="list-all-project-iterations"></a>

## 列出所有项目迭代

列出指定项目的所有迭代。

在[迭代节奏](../user/group/iterations/_index.md#iteration-cadences)中通过**启用自动调度**创建的迭代，其 `title` 和 `description` 字段会返回 `null`。

```plaintext
GET /projects/:id/iterations
GET /projects/:id/iterations?state=opened
GET /projects/:id/iterations?state=closed
GET /projects/:id/iterations?search=version
GET /projects/:id/iterations?include_ancestors=false
GET /projects/:id/iterations?include_descendants=true
GET /projects/:id/iterations?updated_before=2013-10-02T09%3A24%3A18Z
GET /projects/:id/iterations?updated_after=2013-10-02T09%3A24%3A18Z
```

| 属性             | 类型     | 是否必需 | 描述 |
| --------------------- | -------- | -------- | ----------- |
| `state`               | string   | 否       | 返回 `opened`、`upcoming`、`current`、`closed` 或 `all` 迭代。                       |
| `search`              | string   | 否       | 仅返回标题与提供的字符串匹配的迭代。                              |
| `in`                  | array of strings | 否 | 使用参数 `search` 中提供的查询进行模糊搜索的字段。可用选项为 `title` 和 `cadence_title`。默认为 `[title]`。[引入于](https://jihulab.com/gitlab-cn/gitlab/-/issues/350991) 极狐GitLab 16.2。 |
| `include_ancestors`   | boolean  | 否       | 包含父群组及其祖先的迭代。默认为 `true`。                    |
| `include_descendants` | boolean  | 否       | 包含父群组及其后代的迭代。默认为 `false`。[引入于](https://jihulab.com/gitlab-cn/gitlab/-/merge_requests/135764) 极狐GitLab 16.7。 |
| `updated_before`      | datetime | 否       | 仅返回在给定日期时间之前更新的迭代。预期为 ISO 8601 格式（`2019-03-15T08:00:00Z`）。[引入于](https://jihulab.com/gitlab-cn/gitlab/-/issues/378662) 极狐GitLab 15.10。 |
| `updated_after`       | datetime | 否       | 仅返回在给定日期时间之后更新的迭代。预期为 ISO 8601 格式（`2019-03-15T08:00:00Z`）。[引入于](https://jihulab.com/gitlab-cn/gitlab/-/issues/378662) 极狐GitLab 15.10。 |

示例请求：

```shell
curl --request GET \
  --header "PRIVATE-TOKEN: <your_access_token>" \
  --url "https://gitlab.example.com/api/v4/projects/5/iterations"
```

示例响应：

```json
[
  {
    "id": 53,
    "iid": 13,
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