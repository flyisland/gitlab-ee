---
stage: Verify
group: Runner Core
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
title: 群组发布 API
---

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: JihuLab.com，私有化部署

{{< /details >}}

{{< history >}}

- 在极狐GitLab 14.10 引入，带有一个功能标志，名称为 `group_releases_finder_inoperator`，默认情况下禁用。
- 在极狐GitLab 15.0 GA，功能标志 `group_releases_finder_inoperator` 已移除。

{{< /history >}}

使用此 API 与群组中的[项目发布](../user/project/releases/_index.md)进行交互。

> [!note]
> 要直接与项目发布交互，请参阅[项目发布 API](releases/_index.md)。

<a id="list-all-releases-in-a-group"></a>

## 列出群组中的所有发布

列出指定群组中所有项目的发布。

```plaintext
GET /groups/:id/releases
GET /groups/:id/releases?simple=true
```

参数：

| 属性 | 类型 | 是否必需 | 描述 |
| --------- | -------------- | -------- | ----------- |
| `id` | 整数或字符串 | 是 | 群组的 ID 或 [URL 编码路径](rest/_index.md#namespaced-paths)。 |
| `sort` | 字符串 | 否 | 排序方向。可能的值为 `desc` 或 `asc`。 |
| `simple` | 布尔值 | 否 | 如果为 `true`，仅为每个发布返回有限字段。 |

```shell
curl --header "PRIVATE-TOKEN: <your_access_token>"
   --url "https://gitlab.example.com/api/v4/groups/5/releases"
```

示例响应：

```json
[
  {
    "name": "standard release",
    "tag_name": "releasetag",
    "description": "",
    "created_at": "2022-01-10T15:23:15.529Z",
    "released_at": "2022-01-10T15:23:15.529Z",
    "author": {
      "id": 1,
      "username": "root",
      "name": "Administrator",
      "state": "active",
      "avatar_url": "https://www.gravatar.com/avatar/e64c7d89f26bd1972efa854d13d7dd61?s=80&d=identicon",
      "web_url": "https://gitlab.com/root"
    },
    "commit": {
      "id": "e8cbb845ae5a53a2fef2938cf63cf82efc10d993",
      "short_id": "e8cbb845",
      "created_at": "2022-01-10T15:20:29.000+00:00",
      "parent_ids": [],
      "title": "Update test",
      "message": "Update test",
      "author_name": "Administrator",
      "author_email": "admin@example.com",
      "authored_date": "2022-01-10T15:20:29.000+00:00",
      "committer_name": "Administrator",
      "committer_email": "admin@example.com",
      "committed_date": "2022-01-10T15:20:29.000+00:00",
      "trailers": {},
      "web_url": "https://gitlab.com/groups/gitlab-org/-/commit/e8cbb845ae5a53a2fef2938cf63cf82efc10d993"
    },
    "upcoming_release": false,
    "commit_path": "/testgroup/test/-/commit/e8cbb845ae5a53a2fef2938cf63cf82efc10d993",
    "tag_path": "/testgroup/test/-/tags/testtag"
  }
]
```

