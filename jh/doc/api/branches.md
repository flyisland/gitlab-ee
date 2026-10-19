根据提供的翻译要求和原文，以下是翻译后的内容。我会严格遵守所有规则，包括文件头处理、术语替换、链接处理、标题锚点添加、代码块和表格翻译，以及删除不必要的部分。

```markdown
---
stage: Create
group: Source Code
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
description: Documentation for the REST API for Git branches in GitLab.
title: 分支 API
---

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: JihuLab.com，私有化部署

{{< /details >}}

使用此 API 管理 [Git 分支](../user/project/repository/branches/_index.md)。

要更改项目的分支保护配置，请使用 [受保护分支 API](protected_branches.md)。

<a id="list-all-repository-branches"></a>

## 列出所有仓库分支

列出项目的所有仓库分支，按名称字母顺序排序。可以按名称搜索，或使用正则表达式查找特定的分支模式。返回有关分支的详细信息，包括其保护状态、合并状态和提交详情。

> [!note]
> 如果仓库可公开访问，则无需认证即可访问此端点。

```plaintext
GET /projects/:id/repository/branches
```

支持的属性：

| 属性 | 类型 | 是否必需 | 描述 |
|-----------|-------------------|----------|-------------|
| `id` | 整数或字符串 | 是 | ID 或项目的 [URL 编码路径](rest/_index.md#namespaced-paths)。 |
| `regex` | 字符串 | 否 | 返回与 [re2](https://github.com/google/re2/wiki/Syntax) 正则表达式匹配的分支名称列表。不能与 `search` 一起使用。 |
| `search` | 字符串 | 否 | 返回包含搜索字符串的分支列表。可以使用 `^term` 查找以 `term` 开头的分支，使用 `term$` 查找以 `term` 结尾的分支。 |

如果成功，返回 [`200 OK`](rest/troubleshooting.md#status-codes) 和以下响应属性：

| 属性 | 类型 | 描述 |
|----------------------------|---------------------|-------------|
| `can_push` | 布尔值 | 如果为 `true`，表示已认证用户可以推送到此分支。 |
| `commit` | 对象 | 有关分支上最新提交的详细信息。 |
| `commit.author_email` | 字符串 | 提交作者的邮箱地址。 |
| `commit.author_name` | 字符串 | 提交作者的姓名。 |
| `commit.authored_date` | 日期时间 (ISO 8601) | 提交的编写时间。 |
| `commit.committed_date` | 日期时间 (ISO 8601) | 提交的提交时间。 |
| `commit.committer_email` | 字符串 | 提交人员的邮箱地址。 |
| `commit.committer_name` | 字符串 | 提交人员的姓名。 |
| `commit.created_at` | 日期时间 (ISO 8601) | 提交的创建时间。 |
| `commit.extended_trailers` | 对象 | 从提交消息中解析出的扩展 Git 尾部信息。 |
| `commit.id` | 字符串 | 提交的完整 SHA。 |
| `commit.message` | 字符串 | 完整的提交消息。 |
| `commit.parent_ids` | 数组 | 父提交 SHA 的数组。 |
| `commit.short_id` | 字符串 | 提交的缩写 SHA。 |
| `commit.title` | 字符串 | 提交消息的标题。 |
| `commit.trailers` | 对象 | 从提交消息中解析出的 Git 尾部信息。 |
| `commit.web_url` | 字符串 | 在极狐GitLab UI 中查看提交的 URL。 |
| `default` | 布尔值 | 如果为 `true`，表示该分支是项目的默认分支。 |
| `developers_can_merge` | 布尔值 | 如果为 `true`，具有开发者、维护者或所有者角色的用户可以合并到此分支。 |
| `developers_can_push` | 布尔值 | 如果为 `true`，具有开发者、维护者或所有者角色的用户可以推送到此分支。 |
| `merged` | 布尔值 | 如果为 `true`，表示该分支已合并到默认分支。 |
| `name` | 字符串 | 分支名称。 |
| `protected` | 布尔值 | 如果为 `true`，表示该分支受保护，免受强制推送和删除。 |
| `web_url` | 字符串 | 在极狐GitLab UI 中查看分支的 URL。 |

示例请求：

```shell
curl --header "PRIVATE-TOKEN: <your_access_token>" \
  --url "https://gitlab.example.com/api/v4/projects/5/repository/branches"
```

示例响应：

```json
[
  {
    "name": "main",
    "merged": false,
    "protected": true,
    "default": true,
    "developers_can_push": false,
    "developers_can_merge": false,
    "can_push": true,
    "web_url": "https://gitlab.example.com/my-group/my-project/-/tree/main",
    "commit": {
      "id": "7b5c3cc8be40ee161ae89a06bba6229da1032a0c",
      "short_id": "7b5c3cc",
      "created_at": "2024-06-28T03:44:20-07:00",
      "parent_ids": [
        "4ad91d3c1144c406e50c7b33bae684bd6837faf8"
      ],
      "title": "add projects API",
      "message": "add projects API",
      "author_name": "John Smith",
      "author_email": "john@example.com",
      "authored_date": "2024-06-27T05:51:39-07:00",
      "committer_name": "John Smith",
      "committer_email": "john@example.com",
      "committed_date": "2024-06-28T03:44:20-07:00",
      "trailers": {},
      "extended_trailers": {},
      "web_url": "https://gitlab.example.com/my-group/my-project/-/commit/7b5c3cc8be40ee161ae89a06bba6229da1032a0c"
    }
  },
  ...
]
```

<a id="retrieve-a-repository-branch"></a>

## 获取仓库分支

获取指定的项目仓库分支。

> [!note]
> 如果仓库可公开访问，则无需认证即可访问此端点。

```plaintext
GET /projects/:id/repository/branches/:branch
```

支持的属性：

| 属性 | 类型 | 是否必需 | 描述 |
|-----------|-------------------|----------|-------------|
| `id` | 整数或字符串 | 是 | ID 或项目的 [URL 编码路径](rest/_index.md#namespaced-paths)。 |
| `branch` | 字符串 | 是 | 分支的 [URL 编码名称](rest/_index.md#namespaced-paths)。 |

如果成功，返回 [`200 OK`](rest/troubleshooting.md#status-codes) 和以下响应属性：

| 属性 | 类型 | 描述 |
|--------------------------|---------|-------------|
| `can_push` | 布尔值 | 是否允许已认证用户推送到此分支。 |
| `commit` | 对象 | 有关分支上最新提交的详细信息。 |
| `commit.author_email` | 字符串 | 提交作者的邮箱地址。 |
| `commit.author_name` | 字符串 | 提交作者的姓名。 |
| `commit.authored_date` | 字符串 | 提交的编写时间，ISO 8601 格式。 |
| `commit.committer_email` | 字符串 | 提交人员的邮箱地址。 |
| `commit.committer_name` | 字符串 | 提交人员的姓名。 |
| `commit.committed_date` | 字符串 | 提交的提交时间，ISO 8601 格式。 |
| `commit.created_at` | 字符串 | 提交的创建时间，ISO 8601 格式。 |
| `commit.extended_trailers` | 对象 | 从提交消息中解析出的扩展 Git 尾部信息。 |
| `commit.id` | 字符串 | 提交的完整 SHA。 |
| `commit.message` | 字符串 | 完整的提交消息。 |
| `commit.parent_ids` | 数组 | 父提交 SHA 的数组。 |
| `commit.short_id` | 字符串 | 提交的缩写 SHA。 |
| `commit.title` | 字符串 | 提交消息的标题。 |
| `commit.trailers` | 对象 | 从提交消息中解析出的 Git 尾部信息。 |
| `commit.web_url` | 字符串 | 在极狐GitLab UI 中查看提交的 URL。 |
| `default` | 布尔值 | 是否为项目的默认分支。 |
| `developers_can_merge` | 布尔值 | 是否允许具有开发者角色的用户合并到此分支。 |
| `developers_can_push` | 布尔值 | 是否允许具有开发者角色的用户推送到此分支。 |
| `merged` | 布尔值 | 该分支是否已合并到默认分支。 |
| `name` | 字符串 | 分支名称。 |
| `protected` | 布尔值 | 该分支是否受保护，免受强制推送和删除。 |
| `web_url` | 字符串 | 在极狐GitLab UI 中查看分支的 URL。 |

示例请求：

```shell
curl --header "PRIVATE-TOKEN: <your_access_token>" \
  --url "https://gitlab.example.com/api/v4/projects/5/repository/branches/main"
```

示例响应：

```json
{
  "name": "main",
  "merged": false,
  "protected": true,
  "default": true,
  "developers_can_push": false,
  "developers_can_merge": false,
  "can_push": true,
  "web_url": "https://gitlab.example.com/my-group/my-project/-/tree/main",
  "commit": {
    "id": "7b5c3cc8be40ee161ae89a06bba6229da1032a0c",
    "short_id": "7b5c3cc",
    "created_at": "2012-06-28T03:44:20-07:00",
    "parent_ids": [
      "4ad91d3c1144c406e50c7b33bae684bd6837faf8"
    ],
    "title": "add projects API",
    "message": "add projects API",
    "author_name": "John Smith",
    "author_email": "john@example.com",
    "authored_date": "2012-06-27T05:51:39-07:00",
    "committer_name": "John Smith",
    "committer_email": "john@example.com",
    "committed_date": "2012-06-28T03:44:20-07:00",
    "trailers": {},
    "extended_trailers": {},
    "web_url": "https://gitlab.example.com/my-group/my-project/-/commit/7b5c3cc8be40ee161ae89a06bba6229da1032a0c"
  }
}
```

<a id="protect-repository-branch"></a>

## 保护仓库分支

有关保护仓库分支的信息，请参阅 [`POST /projects/:id/protected_branches`](protected_branches.md#protect-repository-branches)。

<a id="unprotect-repository-branch"></a>

## 取消保护仓库分支

有关取消保护仓库分支的信息，请参阅 [`DELETE /projects/:id/protected_branches/:name`](protected_branches.md#unprotect-repository-branches)。

<a id="create-repository-branch"></a>

## 创建仓库分支

在仓库中创建一个新分支。

```plaintext
POST /projects/:id/repository/branches
```

支持的属性：

| 属性 | 类型 | 是否必需 | 描述 |
|-----------|-------------------|----------|-------------|
| `id` | 整数或字符串 | 是 | ID 或项目的 [URL 编码路径](rest/_index.md#namespaced-paths)。 |
| `branch` | 字符串 | 是 | 分支名称。不能包含空格或除连字符和下划线以外的特殊字符。 |
| `ref` | 字符串 | 是 | 创建分支所基于的分支名或提交 SHA。 |

如果成功，返回 [`201 Created`](rest/troubleshooting.md#status-codes) 和以下响应属性：

| 属性 | 类型 | 描述 |
|----------------------------|---------|-------------|
| `can_push` | 布尔值 | 如果为 `true`，表示已认证用户可以推送到此分支。 |
| `commit` | 对象 | 有关分支上最新提交的详细信息。 |
| `commit.author_email` | 字符串 | 提交作者的邮箱地址。 |
| `commit.author_name` | 字符串 | 提交作者的姓名。 |
| `commit.authored_date` | 字符串 | 提交的编写时间，ISO 8601 格式。 |
| `commit.committed_date` | 字符串 | 提交的提交时间，ISO 8601 格式。 |
| `commit.committer_email` | 字符串 | 提交人员的邮箱地址。 |
| `commit.committer_name` | 字符串 | 提交人员的姓名。 |
| `commit.created_at` | 字符串 | 提交的创建时间，ISO 8601 格式。 |
| `commit.extended_trailers` | 对象 | 从提交消息中解析出的扩展 Git 尾部信息。 |
| `commit.id` | 字符串 | 提交的完整 SHA。 |
| `commit.message` | 字符串 | 完整的提交消息。 |
| `commit.parent_ids` | 数组 | 父提交 SHA 的数组。 |
| `commit.short_id` | 字符串 | 提交的缩写 SHA。 |
| `commit.title` | 字符串 | 提交消息的标题。 |
| `commit.trailers` | 对象 | 从提交消息中解析出的 Git 尾部信息。 |
| `commit.web_url` | 字符串 | 在极狐GitLab UI 中查看提交的 URL。 |
| `default` | 布尔值 | 如果为 `true`，则将此分支设置为项目的默认分支。 |
| `developers_can_merge` | 布尔值 | 如果为 `true`，具有开发者角色的用户可以合并到此分支。 |
| `developers_can_push` | 布尔值 | 如果为 `true`，具有开发者角色的用户可以推送到此分支。 |
| `merged` | 布尔值 | 如果为 `true`，表示分支已合并到默认分支。 |
| `name` | 字符串 | 分支名称。 |
| `protected` | 布尔值 | 如果为 `true`，表示分支受保护，免受强制推送和删除。 |
| `web_url` | 字符串 | 在极狐GitLab UI 中查看分支的 URL。 |

示例请求：

```shell
curl --request POST \
  --header "PRIVATE-TOKEN: <your_access_token>" \
  --url "https://gitlab.example.com/api/v4/projects/5/repository/branches?branch=newbranch&ref=main"
```

示例响应：

```json
{
  "commit": {
    "id": "7b5c3cc8be40ee161ae89a06bba6229da1032a0c",
    "short_id": "7b5c3cc",
    "created_at": "2012-06-28T03:44:20-07:00",
    "parent_ids": [
      "4ad91d3c1144c406e50c7b33bae684bd6837faf8"
    ],
    "title": "add projects API",
    "message": "add projects API",
    "author_name": "John Smith",
    "author_email": "john@example.com",
    "authored_date": "2012-06-27T05:51:39-07:00",
    "committer_name": "John Smith",
    "committer_email": "john@example.com",
    "committed_date": "2012-06-28T03:44:20-07:00",
    "trailers": {},
    "extended_trailers": {},
    "web_url": "https://gitlab.example.com/my-group/my-project/-/commit/7b5c3cc8be40ee161ae89a06bba6229da1032a0c"
  },
  "name": "newbranch",
  "merged": false,
  "protected": false,
  "default": false,
  "developers_can_push": false,
  "developers_can_merge": false,
  "can_push": true,
  "web_url": "https://gitlab.example.com/my-group/my-project/-/tree/newbranch"
}
```

<a id="delete-repository-branch"></a>

## 删除仓库分支

从仓库中删除指定的分支。

> [!note]
> 如果发生错误，会提供解释消息。

```plaintext
DELETE /projects/:id/repository/branches/:branch
```

支持的属性：

| 属性 | 类型 | 是否必需 | 描述 |
|-----------|-------------------|----------|-------------|
| `id` | 整数或字符串 | 是 | ID 或项目的 [URL 编码路径](rest/_index.md#namespaced-paths)。 |
| `branch` | 字符串 | 是 | 分支的 [URL 编码名称](rest/_index.md#namespaced-paths)。不能删除默认分支或受保护分支。 |

如果成功，返回 [`204 No Content`](rest/troubleshooting.md#status-codes)。

示例请求：

```shell
curl --request DELETE \
  --header "PRIVATE-TOKEN: <your_access_token>" \
  --url "https://gitlab.example.com/api/v4/projects/5/repository/branches/newbranch"
```

> [!note]
> 删除分支不会完全清除所有相关数据。
> 一些信息会保留以维护项目历史记录并支持恢复过程。
> 有关更多信息，请参阅[处理敏感信息](../topics/git/undo.md#handle-sensitive-information)。

<a id="delete-all-merged-branches"></a>

## 删除所有已合并分支

删除所有已合并到项目默认分支的分支。

> [!note]
> [受保护分支](../user/project/repository/branches/protected.md) 不会在此操作中被删除。

```plaintext
DELETE /projects/:id/repository/merged_branches
```

支持的属性：

| 属性 | 类型 | 是否必需 | 描述 |
|-----------|-------------------|----------|-------------|
| `id` | 整数或字符串 | 是 | ID 或项目的 [URL 编码路径](rest/_index.md#namespaced-paths)。 |

如果成功，返回 [`202 Accepted`](rest/troubleshooting.md#status-codes)。

示例请求：

```shell
curl --request DELETE \
  --header "PRIVATE-TOKEN: <your_access_token>" \
  --url "https://gitlab.example.com/api/v4/projects/5/repository/merged_branches"
```

<a id="related-topics"></a>

## 相关主题

- [分支](../user/project/repository/branches/_index.md)
- [受保护分支](../user/project/repository/branches/protected.md)
- [受保护分支 API](protected_branches.md)
```