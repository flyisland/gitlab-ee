---
stage: Plan
group: Project Management
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
title: 表情反应 API
---

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: JihuLab.com，私有化部署

{{< /details >}}

{{< history >}}

- 在 极狐GitLab 16.0 中，从“award emoji”重命名为“emoji reactions”。

{{< /history >}}

使用此 API 管理[表情反应](../user/emoji_reactions.md)。

接受表情反应的 极狐GitLab 对象称为 awardables。
您可以对以下资源使用表情进行反应：

- [史诗](../user/group/epics/_index.md) ([API](epics.md))
- [议题](../user/project/issues/_index.md) ([API](issues.md))
- [合并请求](../user/project/merge_requests/_index.md) ([API](merge_requests.md))
- [代码片段](../user/snippets.md) ([API](snippets.md))
- [评论](../user/emoji_reactions.md#emoji-reactions-for-comments) ([API](notes.md))

<a id="issues-merge-requests-and-snippets"></a>

## 议题、合并请求和代码片段

有关在评论中使用这些端点的信息，请参见[向评论添加反应](#add-reactions-to-comments)。

<a id="list-all-emoji-reactions-for-a-resource"></a>

### 列出资源的所有表情反应

{{< history >}}

- 在 极狐GitLab 15.1 中变更，以允许对公共 awardables 进行未经身份验证的访问。

{{< /history >}}

列出指定议题、代码片段或合并请求的所有表情反应。如果 awardable 是公开可访问的，此端点无需身份验证即可访问。

```plaintext
GET /projects/:id/issues/:issue_iid/award_emoji
GET /projects/:id/merge_requests/:merge_request_iid/award_emoji
GET /projects/:id/snippets/:snippet_id/award_emoji
```

参数：

| 属性            | 类型            | 是否必需 | 描述                                                                          |
|:---------------|:---------------|:---------|:-----------------------------------------------------------------------------|
| `id`           | 整数或字符串     | 是       | ID 或[项目的 URL 编码路径](rest/_index.md#namespaced-paths)。               |
| `issue_iid`/`merge_request_iid`/`snippet_id` | 整数 | 是 | awardable 的 ID（合并请求/议题使用 `iid`，代码片段使用 `id`）。 |

示例请求：

```shell
curl --request GET \
  --header "PRIVATE-TOKEN: <your_access_token>" \
  --url "https://gitlab.example.com/api/v4/projects/1/issues/80/award_emoji"
```

示例响应：

```json
[
  {
    "id": 4,
    "name": "1234",
    "user": {
      "name": "Administrator",
      "username": "root",
      "id": 1,
      "state": "active",
      "avatar_url": "http://www.gravatar.com/avatar/e64c7d89f26bd1972efa854d13d7dd61?s=80&d=identicon",
      "web_url": "http://gitlab.example.com/root"
    },
    "created_at": "2016-06-15T10:09:34.206Z",
    "updated_at": "2016-06-15T10:09:34.206Z",
    "awardable_id": 80,
    "awardable_type": "Issue"
  },
  {
    "id": 1,
    "name": "microphone",
    "user": {
      "name": "User 4",
      "username": "user4",
      "id": 26,
      "state": "active",
      "avatar_url": "http://www.gravatar.com/avatar/7e65550957227bd38fe2d7fbc6fd2f7b?s=80&d=identicon",
      "web_url": "http://gitlab.example.com/user4"
    },
    "created_at": "2016-06-15T10:09:34.177Z",
    "updated_at": "2016-06-15T10:09:34.177Z",
    "awardable_id": 80,
    "awardable_type": "Issue"
  }
]
```

<a id="retrieve-an-emoji-reaction-from-a-resource"></a>

### 从资源中获取表情反应

{{< history >}}

- 在 极狐GitLab 15.1 中变更，以允许对公共 awardables 进行未经身份验证的访问。

{{< /history >}}

从指定的议题、代码片段或合并请求中获取指定的表情反应。如果 awardable 是公开可访问的，此端点无需身份验证即可访问。

```plaintext
GET /projects/:id/issues/:issue_iid/award_emoji/:award_id
GET /projects/:id/merge_requests/:merge_request_iid/award_emoji/:award_id
GET /projects/:id/snippets/:snippet_id/award_emoji/:award_id
```

参数：

| 属性            | 类型            | 是否必需 | 描述                                                                          |
|:---------------|:---------------|:---------|:-----------------------------------------------------------------------------|
| `id`           | 整数或字符串     | 是       | ID 或[项目的 URL 编码路径](rest/_index.md#namespaced-paths)。               |
| `issue_iid`/`merge_request_iid`/`snippet_id` | 整数 | 是 | awardable 的 ID（合并请求/议题使用 `iid`，代码片段使用 `id`）。 |
| `award_id`     | 整数            | 是       | 表情反应的 ID。                                                                |

示例请求：

```shell
curl --request GET \
  --header "PRIVATE-TOKEN: <your_access_token>" \
  --url "https://gitlab.example.com/api/v4/projects/1/issues/80/award_emoji/1"
```

示例响应：

```json
{
  "id": 1,
  "name": "microphone",
  "user": {
    "name": "User 4",
    "username": "user4",
    "id": 26,
    "state": "active",
    "avatar_url": "http://www.gravatar.com/avatar/7e65550957227bd38fe2d7fbc6fd2f7b?s=80&d=identicon",
    "web_url": "http://gitlab.example.com/user4"
  },
  "created_at": "2016-06-15T10:09:34.177Z",
  "updated_at": "2016-06-15T10:09:34.177Z",
  "awardable_id": 80,
  "awardable_type": "Issue"
}
```

<a id="add-an-emoji-reaction-to-a-resource"></a>

### 向资源添加表情反应

向议题、代码片段或合并请求添加表情反应。

```plaintext
POST /projects/:id/issues/:issue_iid/award_emoji
POST /projects/:id/merge_requests/:merge_request_iid/award_emoji
POST /projects/:id/snippets/:snippet_id/award_emoji
```

参数：

| 属性            | 类型            | 是否必需 | 描述                                                                          |
|:---------------|:---------------|:---------|:-----------------------------------------------------------------------------|
| `id`           | 整数或字符串     | 是       | ID 或[项目的 URL 编码路径](rest/_index.md#namespaced-paths)。               |
| `issue_iid`/`merge_request_iid`/`snippet_id` | 整数 | 是 | awardable 的 ID（合并请求/议题使用 `iid`，代码片段使用 `id`）。 |
| `name`         | 字符串          | 是       | 不带冒号的表情名称。                                                          |

```shell
curl --request POST \
  --header "PRIVATE-TOKEN: <your_access_token>" \
  --url "https://gitlab.example.com/api/v4/projects/1/issues/80/award_emoji?name=blowfish"
```

示例响应：

```json
{
  "id": 344,
  "name": "blowfish",
  "user": {
    "name": "Administrator",
    "username": "root",
    "id": 1,
    "state": "active",
    "avatar_url": "http://www.gravatar.com/avatar/e64c7d89f26bd1972efa854d13d7dd61?s=80&d=identicon",
    "web_url": "http://gitlab.example.com/root"
  },
  "created_at": "2016-06-17T17:47:29.266Z",
  "updated_at": "2016-06-17T17:47:29.266Z",
  "awardable_id": 80,
  "awardable_type": "Issue"
}
```

<a id="delete-an-emoji-reaction-from-a-resource"></a>

### 从资源中删除表情反应

从指定的议题、代码片段或合并请求中删除指定的表情反应。

只有管理员或反应作者才能删除表情反应。

```plaintext
DELETE /projects/:id/issues/:issue_iid/award_emoji/:award_id
DELETE /projects/:id/merge_requests/:merge_request_iid/award_emoji/:award_id
DELETE /projects/:id/snippets/:snippet_id/award_emoji/:award_id
```

参数：

| 属性            | 类型            | 是否必需 | 描述                                                                          |
|:---------------|:---------------|:---------|:-----------------------------------------------------------------------------|
| `id`           | 整数或字符串     | 是       | ID 或[项目的 URL 编码路径](rest/_index.md#namespaced-paths)。               |
| `issue_iid`/`merge_request_iid`/`snippet_id` | 整数 | 是 | awardable 的 ID（合并请求/议题使用 `iid`，代码片段使用 `id`）。 |
| `award_id`     | 整数            | 是       | 表情反应的 ID。                                                                |

```shell
curl --request DELETE \
  --header "PRIVATE-TOKEN: <your_access_token>" \
  --url "https://gitlab.example.com/api/v4/projects/1/issues/80/award_emoji/344"
```

<a id="add-reactions-to-comments"></a>

## 向评论添加反应

评论（也称为备注）是议题、合并请求和代码片段的子资源。

> [!note]
> 下面的示例描述了如何处理议题评论的表情反应，但可以适用于合并请求和代码片段的评论。因此，您需要将 `issue_iid` 替换为 `merge_request_iid` 或 `snippet_id`。

<a id="list-all-emoji-reactions-for-a-comment"></a>

### 列出评论的所有表情反应

{{< history >}}

- 在 极狐GitLab 15.1 中变更，以允许对公共评论进行未经身份验证的访问。

{{< /history >}}

列出指定评论的所有表情反应。如果评论是公开可访问的，此端点无需身份验证即可访问。

```plaintext
GET /projects/:id/issues/:issue_iid/notes/:note_id/award_emoji
```

参数：

| 属性         | 类型            | 是否必需 | 描述                                                                          |
|:------------|:---------------|:---------|:-----------------------------------------------------------------------------|
| `id`        | 整数或字符串     | 是       | ID 或[项目的 URL 编码路径](rest/_index.md#namespaced-paths)。               |
| `issue_iid` | 整数            | 是       | 议题的内部 ID。                                                               |
| `note_id`   | 整数            | 是       | 评论（备注）的 ID。                                                            |

示例请求：

```shell
curl --request GET \
  --header "PRIVATE-TOKEN: <your_access_token>" \
  --url "https://gitlab.example.com/api/v4/projects/1/issues/80/notes/1/award_emoji"
```

示例响应：

```json
[
  {
    "id": 2,
    "name": "mood_bubble_lightning",
    "user": {
      "name": "User 4",
      "username": "user4",
      "id": 26,
      "state": "active",
      "avatar_url": "http://www.gravatar.com/avatar/7e65550957227bd38fe2d7fbc6fd2f7b?s=80&d=identicon",
      "web_url": "http://gitlab.example.com/user4"
    },
    "created_at": "2016-06-15T10:09:34.197Z",
    "updated_at": "2016-06-15T10:09:34.197Z",
    "awardable_id": 1,
    "awardable_type": "Note"
  }
]
```

<a id="retrieve-an-emoji-reaction-from-a-comment"></a>

### 从评论中获取表情反应

{{< history >}}

- 在 极狐GitLab 15.1 中变更，以允许对公共评论进行未经身份验证的访问。

{{< /history >}}

从指定的评论中获取表情反应。如果评论是公开可访问的，此端点无需身份验证即可访问。

```plaintext
GET /projects/:id/issues/:issue_iid/notes/:note_id/award_emoji/:award_id
```

参数：

| 属性         | 类型            | 是否必需 | 描述                                                                          |
|:------------|:---------------|:---------|:-----------------------------------------------------------------------------|
| `id`        | 整数或字符串     | 是       | ID 或[项目的 URL 编码路径](rest/_index.md#namespaced-paths)。               |
| `issue_iid` | 整数            | 是       | 议题的内部 ID。                                                               |
| `note_id`   | 整数            | 是       | 评论（备注）的 ID。                                                            |
| `award_id`  | 整数            | 是       | 表情反应的 ID。                                                                |

示例请求：

```shell
curl --request GET \
  --header "PRIVATE-TOKEN: <your_access_token>" \
  --url "https://gitlab.example.com/api/v4/projects/1/issues/80/notes/1/award_emoji/2"
```

示例响应：

```json
{
  "id": 2,
  "name": "mood_bubble_lightning",
  "user": {
    "name": "User 4",
    "username": "user4",
    "id": 26,
    "state": "active",
    "avatar_url": "http://www.gravatar.com/avatar/7e65550957227bd38fe2d7fbc6fd2f7b?s=80&d=identicon",
    "web_url": "http://gitlab.example.com/user4"
  },
  "created_at": "2016-06-15T10:09:34.197Z",
  "updated_at": "2016-06-15T10:09:34.197Z",
  "awardable_id": 1,
  "awardable_type": "Note"
}
```

<a id="add-an-emoji-reaction-to-a-comment"></a>

### 向评论添加表情反应

向指定的评论添加表情反应。

```plaintext
POST /projects/:id/issues/:issue_iid/notes/:note_id/award_emoji
```

参数：

| 属性         | 类型            | 是否必需 | 描述                                                                          |
|:------------|:---------------|:---------|:-----------------------------------------------------------------------------|
| `id`        | 整数或字符串     | 是       | ID 或[项目的 URL 编码路径](rest/_index.md#namespaced-paths)。               |
| `issue_iid` | 整数            | 是       | 议题的内部 ID。                                                               |
| `note_id`   | 整数            | 是       | 评论（备注）的 ID。                                                            |
| `name`      | 字符串          | 是       | 不带冒号的表情名称。                                                          |

示例请求：

```shell
curl --request POST \
  --header "PRIVATE-TOKEN: <your_access_token>" \
  --url "https://gitlab.example.com/api/v4/projects/1/issues/80/notes/1/award_emoji?name=rocket"
```

示例响应：

```json
{
  "id": 345,
  "name": "rocket",
  "user": {
    "name": "Administrator",
    "username": "root",
    "id": 1,
    "state": "active",
    "avatar_url": "http://www.gravatar.com/avatar/e64c7d89f26bd1972efa854d13d7dd61?s=80&d=identicon",
    "web_url": "http://gitlab.example.com/root"
  },
  "created_at": "2016-06-17T19:59:55.888Z",
  "updated_at": "2016-06-17T19:59:55.888Z",
  "awardable_id": 1,
  "awardable_type": "Note"
}
```

<a id="delete-an-emoji-reaction-from-a-comment"></a>

### 从评论中删除表情反应

从指定的评论中删除表情反应。

只有管理员或反应作者才能删除表情反应。

```plaintext
DELETE /projects/:id/issues/:issue_iid/notes/:note_id/award_emoji/:award_id
```

参数：

| 属性         | 类型            | 是否必需 | 描述                                                                          |
|:------------|:---------------|:---------|:-----------------------------------------------------------------------------|
| `id`        | 整数或字符串     | 是       | ID 或[项目的 URL 编码路径](rest/_index.md#namespaced-paths)。               |
| `issue_iid` | 整数            | 是       | 议题的内部 ID。                                                               |
| `note_id`   | 整数            | 是       | 评论（备注）的 ID。                                                            |
| `award_id`  | 整数            | 是       | 表情反应的 ID。                                                                |

示例请求：

```shell
curl --request DELETE \
  --header "PRIVATE-TOKEN: <your_access_token>" \
  --url "https://gitlab.example.com/api/v4/projects/1/issues/80/award_emoji/345"
```