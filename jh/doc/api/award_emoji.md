---
stage: Plan
group: Project Management
info: To determine the technical writer assigned to the Stage/Group associated with this page, see https://about.gitlab.com/handbook/product/ux/technical-writing/#assignments
---

# 表情符号回复 API **(BASIC ALL)**

> 从"奖励表情符号"重命名为"表情符号回复"于极狐GitLab 16.0。

[表情符号回复](../user/emoji_reactions.md)包含了万言千语。

我们把极狐GitLab 里可以使用表情符号的对象叫做“可被奖励的对象”。您可以在以下方面使用表情符号：

- [史诗](../user/group/epics/index.md) ([API](epics.md)) **(PREMIUM)**
- [议题](../user/project/issues/index.md) ([API](issues.md))
- [合并请求](../user/project/merge_requests/index.md) ([API](merge_requests.md))
- [代码片段](../user/snippets.md) ([API](snippets.md))
- [评论](../user/emoji_reactions.md#emoji-reactions-for-comments) ([API](notes.md))

表情符号同样也可以在评论中（又叫做备注）[使用](../user/emoji_reactions.md#award-emojis-for-comments)。您也可以查看[备注 API](notes.md)。

<a href="#issues-merge-requests-and-snippets"></a>

## 议题、合并请求以及代码片段

请查看[向评论添加反应](#add-reactions-to-comments)来了解如何为评论使用这些 API。

<a href="#list-an-awardables-award-emojis"></a>

### 列出可被奖励对象的表情符号回复

> 变更于极狐GitLab 15.1，允许对公开可奖励对象进行未授权访问。

获取指定可奖励对象的表情符号回复列表。如果可奖励对象可公开访问，则这个端点可以进行未授权访问。


```plaintext
GET /projects/:id/issues/:issue_iid/award_emoji
GET /projects/:id/merge_requests/:merge_request_iid/award_emoji
GET /projects/:id/snippets/:snippet_id/award_emoji
```

参数:

| 参数                                         | 类型           | 是否必需 | 描述                                                                        |
| :------------------------------------------- | :------------- | :------- | :-------------------------------------------------------------------------- |
| `id`                                         | integer/string | yes      | ID 或 [URL 编码的项目路径](rest/index.md#namespaced-path-encoding)。             |
| `issue_iid`/`merge_request_iid`/`snippet_id` | integer        | yes      | 可被奖励的对象的 ID (`iid` 当用在合并请求或议题中，`id` 当用在代码片段中)。 |

请求示例：

```shell
curl --header "PRIVATE-TOKEN: <your_access_token>" "https://gitlab.example.com/api/v4/projects/1/issues/80/award_emoji"
```

响应示例：

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

<a href="#get-single-award-emoji"></a>

### 获取单个表情符号回复

> 变更于极狐GitLab 15.1，允许对公开可奖励对象进行未授权访问。

从议题、代码片段或合并请求中获取单个表情符号回复。如果可奖励对象可公开访问，则这个端点可以进行未授权访问。

```plaintext
GET /projects/:id/issues/:issue_iid/award_emoji/:award_id
GET /projects/:id/merge_requests/:merge_request_iid/award_emoji/:award_id
GET /projects/:id/snippets/:snippet_id/award_emoji/:award_id
```

参数：

| 参数                                         | 类型           | 是否必需 | 描述                                                          |
| :------------------------------------------- | :------------- | :------- |:------------------------------------------------------------|
| `id`                                         | integer/string | yes      | ID 或 [URL 编码的项目路径](rest/index.md#namespaced-path-encoding)。 |
| `issue_iid`/`merge_request_iid`/`snippet_id` | integer        | yes      | ID                                                          |
| `award_id`                                   | integer        | yes      | 表情符号回复的 ID。                                                 |

请求示例：

```shell
curl --header "PRIVATE-TOKEN: <your_access_token>" "https://gitlab.example.com/api/v4/projects/1/issues/80/award_emoji/1"
```

响应示例：

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

<a href="#award-a-new-emoji"></a>

### 添加新的表情符号回复

为某个具体的可奖励对象创建新的表情符号回复。

```plaintext
POST /projects/:id/issues/:issue_iid/award_emoji
POST /projects/:id/merge_requests/:merge_request_iid/award_emoji
POST /projects/:id/snippets/:snippet_id/award_emoji
```

参数：

| 参数                                         | 类型           | 是否必需 | 描述                                                                            |
| :------------------------------------------- | :------------- | :------- |:------------------------------------------------------------------------------|
| `id`                                         | integer/string | yes      | ID 或 [URL 编码的项目路径](rest/index.md#namespaced-path-encoding)。                   |
| `issue_iid`/`merge_request_iid`/`snippet_id` | integer        | yes      | 可奖励对象的 ID（当对象为合并请求或议题时用 `iid`，当对象为代码片段时用 `id`）。                               |
| `name`                                       | string         | yes      | 不带有冒号的表情的名字。                                                                  |

```shell
curl --request POST --header "PRIVATE-TOKEN: <your_access_token>" "https://gitlab.example.com/api/v4/projects/1/issues/80/award_emoji?name=blowfish"
```

响应示例：

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

<a href="#delete-an-award-emoji"></a>

### 删除表情符号回复

有些时候有些表情不太适当并且您需要移除某个表情符号。

只有管理员或者表情符号回复的所有者可以删除相应的表情符号。

```plaintext
DELETE /projects/:id/issues/:issue_iid/award_emoji/:award_id
DELETE /projects/:id/merge_requests/:merge_request_iid/award_emoji/:award_id
DELETE /projects/:id/snippets/:snippet_id/award_emoji/:award_id
```

参数：

| 参数                                         | 类型           | 是否必需 | 描述                                                          |
| :------------------------------------------- | :------------- | :------- |:------------------------------------------------------------|
| `id`                                         | integer/string | yes      | ID 或 [URL 编码的项目路径](rest/index.md#namespaced-path-encoding)。 |
| `issue_iid`/`merge_request_iid`/`snippet_id` | integer        | yes      | 可奖励对象的 ID（当对象为合并请求或议题时用 `iid`，当对象为代码片段时用 `id`）。             |
| `award_id`                                   | integer        | yes      | 表情符号回复的 ID。                                                 |

```shell
curl --request DELETE --header "PRIVATE-TOKEN: <your_access_token>" "https://gitlab.example.com/api/v4/projects/1/issues/80/award_emoji/344"
```

<a href="#award-emojis-on-comments"></a>

## 向评论添加表情符号回复

评论（又被叫做备注）是议题、合并请求或代码片段的子资源。

NOTE:
下面的这些示例描述了如何在议题的评论中使用表情符号回复，但也可以用于合并请求和代码片段里的评论中。因此您需要把 `issue_iid` 替换为 `merge_request_iid` 或者是 `snippet_id`。

<a href="#list-a-comments-award-emojis"></a>

### 列出评论的所有表情符号回复

> 变更于极狐GitLab 15.1，允许对公开评论进行未授权访问。

获取评论的所有表情符号回复。如果评论是公开的，则此端点可以进行未授权访问。

```plaintext
GET /projects/:id/issues/:issue_iid/notes/:note_id/award_emoji
```

参数：

| 参数        | 类型           | 是否必需 | 描述                                                            |
| :---------- | :------------- | :------- | :-------------------------------------------------------------- |
| `id`        | integer/string | yes      | ID 或 [URL 编码的项目路径](rest/index.md#namespaced-path-encoding)。 |
| `issue_iid` | integer        | yes      | 议题的内部 ID。                                                 |
| `note_id`   | integer        | yes      | 评论（备注）的 ID。                                             |

请求示例：

```shell
curl --header "PRIVATE-TOKEN: <your_access_token>" "https://gitlab.example.com/api/v4/projects/1/issues/80/notes/1/award_emoji"
```

响应示例：

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

<a href="#get-an-award-emoji-for-a-comment"></a>

### 获取评论的表情符号回复

> 变更于极狐GitLab 15.1，允许对公开评论进行未授权访问。

获取评论（备注）的单个表情符号回复。如果评论是公开的，则此端点可以进行未授权访问。

```plaintext
GET /projects/:id/issues/:issue_iid/notes/:note_id/award_emoji/:award_id
```

参数：

| 参数        | 类型           | 是否必需 | 描述                                                          |
| :---------- | :------------- | :------- |:------------------------------------------------------------|
| `id`        | integer/string | yes      | ID 或 [URL 编码的项目路径](rest/index.md#namespaced-path-encoding)。 |
| `issue_iid` | integer        | yes      | 议题的内部 ID。                                                   |
| `note_id`   | integer        | yes      | 评论（备注）的 ID。                                                 |
| `award_id`  | integer        | yes      | 表情符号回复的 ID。                                                 |

请求示例：

```shell
curl --header "PRIVATE-TOKEN: <your_access_token>" "https://gitlab.example.com/api/v4/projects/1/issues/80/notes/1/award_emoji/2"
```

响应示例：

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

<a href="#award-a-new-emoji-on-a-comment"></a>

### 为评论创建新的奖励表情

为某个具体的评论（备注）创建新的表情符号回复。

```plaintext
POST /projects/:id/issues/:issue_iid/notes/:note_id/award_emoji
```

参数：

| 参数        | 类型           | 是否必需 | 描述                                                            |
| :---------- | :------------- | :------- | :-------------------------------------------------------------- |
| `id`        | integer/string | yes      | ID 或 [URL 编码的项目路径](rest/index.md#namespaced-path-encoding)。 |
| `issue_iid` | integer        | yes      | 议题的内部 ID。                                                 |
| `note_id`   | integer        | yes      | 评论（备注）的 ID。                                             |
| `name`      | string         | yes      | 表情符号不带有冒号的名字。                                      |

请求示例：

```shell
curl --request POST --header "PRIVATE-TOKEN: <your_access_token>" "https://gitlab.example.com/api/v4/projects/1/issues/80/notes/1/award_emoji?name=rocket"
```

响应示例：

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

<a href="#delete-an-award-emoji-from-a-comment"></a>

### 从评论中删除表情符号回复

有些时候有些表情不太适当并且您需要移除某个表情符号。

只有管理员或者表情符号回复的所有者可以删除相应的表情符号。

```plaintext
DELETE /projects/:id/issues/:issue_iid/notes/:note_id/award_emoji/:award_id
```

参数：

| 参数        | 类型           | 是否必需 | 描述                                                          |
| :---------- | :------------- | :------- |:------------------------------------------------------------|
| `id`        | integer/string | yes      | ID 或 [URL 编码的项目路径](rest/index.md#namespaced-path-encoding)。 |
| `issue_iid` | integer        | yes      | 议题的内部 ID。                                                   |
| `note_id`   | integer        | yes      | 评论（备注）的 ID。                                                 |
| `award_id`  | integer        | yes      | 表情符号回复 ID。                                                  |

请求示例：

```shell
curl --request DELETE --header "PRIVATE-TOKEN: <your_access_token>" "https://gitlab.example.com/api/v4/projects/1/issues/80/award_emoji/345"
```
