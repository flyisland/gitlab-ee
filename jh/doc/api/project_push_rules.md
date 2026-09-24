---
stage: Create
group: Source Code
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
title: 项目推送规则 API
description: 管理项目推送规则以强制执行提交标准、验证消息、防止密钥泄露并控制仓库操作。
---

{{< details >}}

- Tier: 专业版，旗舰版
- Offering: JihuLab.com，私有化部署

{{< /details >}}

使用此 API 管理项目[推送规则](../user/project/repository/push_rules.md)。

> [!note]
> 极狐GitLab 在推送规则中使用 [RE2 语法](https://github.com/google/re2/wiki/Syntax) 作为所有正则表达式。

<a id="retrieve-the-push-rules-of-a-project"></a>

## 获取项目的推送规则

获取指定项目的推送规则。

```plaintext
GET /projects/:id/push_rule
```

支持的属性：

| 属性 | 类型              | 是否必填 | 描述 |
|------|-------------------|----------|------|
| `id` | integer or string | 是       | 项目的 ID 或 [URL 编码路径](rest/_index.md#namespaced-paths)。 |

如果成功，返回 [`200 OK`](rest/troubleshooting.md#status-codes) 和以下响应属性：

| 属性                           | 类型    | 描述 |
|--------------------------------|---------|------|
| `author_email_regex`           | string  | 所有提交作者的电子邮件必须匹配此正则表达式。 |
| `branch_name_regex`            | string  | 所有分支名称必须匹配此正则表达式。 |
| `commit_committer_check`       | boolean | 如果为 `true`，则用户只能向此仓库推送提交，前提是提交者的电子邮件是他们自己的已验证电子邮件之一。 |
| `commit_committer_name_check`  | boolean | 如果为 `true`，则用户只能向此仓库推送提交，前提是提交者姓名与他们的极狐GitLab 账户名一致。 |
| `commit_message_negative_regex` | string | 任何提交消息都不允许匹配此正则表达式。 |
| `commit_message_regex`         | string  | 所有提交消息必须匹配此正则表达式。 |
| `created_at`                   | string  | 推送规则创建的日期和时间。 |
| `deny_delete_tag`              | boolean | 如果为 `true`，则拒绝删除标签。 |
| `file_name_regex`              | string  | 所有提交的文件名不得匹配此正则表达式。 |
| `id`                           | integer | 推送规则的 ID。 |
| `max_file_size`                | integer | 最大文件大小（MB）。 |
| `member_check`                 | boolean | 如果为 `true`，则将提交限制为仅限现有极狐GitLab 用户的作者（电子邮件）。 |
| `prevent_secrets`              | boolean | 如果为 `true`，极狐GitLab 将拒绝任何可能包含密钥的文件。 |
| `project_id`                   | integer | 项目的 ID。 |
| `reject_non_dco_commits`       | boolean | 如果为 `true`，则当未通过 DCO 认证时拒绝提交。 |
| `reject_unsigned_commits`      | boolean | 如果为 `true`，则当未签名时拒绝提交。 |

如果从未为项目配置推送规则，则返回 HTTP `200 OK`，响应正文为文本字符串 `"null"`。

> [!note]
> 这与[群组推送规则 API](group_push_rules.md#retrieve-the-push-rules-of-a-group) 不同，后者会返回 `404 Not Found` 错误。

示例请求：

```shell
curl --header "PRIVATE-TOKEN: <your_access_token>" \
  --url "https://gitlab.example.com/api/v4/projects/3/push_rule"
```

配置推送规则且所有设置禁用时的示例响应：

```json
{
  "id": 1,
  "project_id": 3,
  "created_at": "2012-10-12T17:04:47Z",
  "commit_message_regex": "Fixes \\d+\\..*",
  "commit_message_negative_regex": "ssh\\:\\/\\/",
  "branch_name_regex": "",
  "deny_delete_tag": false,
  "member_check": false,
  "prevent_secrets": false,
  "author_email_regex": "",
  "file_name_regex": "",
  "max_file_size": 0,
  "commit_committer_check": null,
  "commit_committer_name_check": false,
  "reject_unsigned_commits": null,
  "reject_non_dco_commits": null
}
```

如果以下属性被禁用，它们会返回 `null` 而不是 `false`：

- `commit_committer_check`
- `reject_unsigned_commits`
- `reject_non_dco_commits`

从未配置推送规则时的示例响应：

```plaintext
HTTP/1.1 200 OK
Content-Type: application/json
Content-Length: 4

null
```

这将返回文本字符串 `"null"`（4 个字符），而不是 JSON 的 `null` 值。

<a id="add-push-rules-to-a-project"></a>

## 向项目添加推送规则

向指定项目添加推送规则。

```plaintext
POST /projects/:id/push_rule
```

支持的属性：

| 属性                           | 类型              | 是否必填 | 描述 |
|--------------------------------|-------------------|----------|------|
| `id`                           | integer or string | 是       | 项目的 ID 或 [URL 编码路径](rest/_index.md#namespaced-paths)。 |
| `author_email_regex`           | string            | 否       | 所有提交作者的电子邮件必须匹配此正则表达式。 |
| `branch_name_regex`            | string            | 否       | 所有分支名称必须匹配此正则表达式。 |
| `commit_committer_check`       | boolean           | 否       | 如果为 `true`，则用户只能向此仓库推送提交，前提是提交者的电子邮件是他们自己的已验证电子邮件之一。 |
| `commit_committer_name_check`  | boolean           | 否       | 如果为 `true`，则用户只能向此仓库推送提交，前提是提交者姓名与他们的极狐GitLab 账户名一致。 |
| `commit_message_negative_regex` | string           | 否       | 任何提交消息都不允许匹配此正则表达式。 |
| `commit_message_regex`         | string            | 否       | 所有提交消息必须匹配此正则表达式。 |
| `deny_delete_tag`              | boolean           | 否       | 如果为 `true`，则拒绝删除标签。 |
| `file_name_regex`              | string            | 否       | 所有提交的文件名不得匹配此正则表达式。 |
| `max_file_size`                | integer           | 否       | 最大文件大小（MB）。 |
| `member_check`                 | boolean           | 否       | 如果为 `true`，则将提交限制为仅限现有极狐GitLab 用户的作者（电子邮件）。 |
| `prevent_secrets`              | boolean           | 否       | 如果为 `true`，极狐GitLab 将拒绝任何可能包含密钥的文件。 |
| `reject_non_dco_commits`       | boolean           | 否       | 如果为 `true`，则当未通过 DCO 认证时拒绝提交。 |
| `reject_unsigned_commits`      | boolean           | 否       | 如果为 `true`，则当未签名时拒绝提交。 |

如果成功，返回 [`201 Created`](rest/troubleshooting.md#status-codes) 和以下响应属性：

| 属性                           | 类型    | 描述 |
|--------------------------------|---------|------|
| `author_email_regex`           | string  | 所有提交作者的电子邮件必须匹配此正则表达式。 |
| `branch_name_regex`            | string  | 所有分支名称必须匹配此正则表达式。 |
| `commit_committer_check`       | boolean | 如果为 `true`，则用户只能向此仓库推送提交，前提是提交者的电子邮件是他们自己的已验证电子邮件之一。 |
| `commit_committer_name_check`  | boolean | 如果为 `true`，则用户只能向此仓库推送提交，前提是提交者姓名与他们的极狐GitLab 账户名一致。 |
| `commit_message_negative_regex` | string | 任何提交消息都不允许匹配此正则表达式。 |
| `commit_message_regex`         | string  | 所有提交消息必须匹配此正则表达式。 |
| `created_at`                   | string  | 推送规则创建的日期和时间。 |
| `deny_delete_tag`              | boolean | 如果为 `true`，则拒绝删除标签。 |
| `file_name_regex`              | string  | 所有提交的文件名不得匹配此正则表达式。 |
| `id`                           | integer | 推送规则的 ID。 |
| `max_file_size`                | integer | 最大文件大小（MB）。 |
| `member_check`                 | boolean | 如果为 `true`，则将提交限制为仅限现有极狐GitLab 用户的作者（电子邮件）。 |
| `prevent_secrets`              | boolean | 如果为 `true`，极狐GitLab 将拒绝任何可能包含密钥的文件。 |
| `project_id`                   | integer | 项目的 ID。 |
| `reject_non_dco_commits`       | boolean | 如果为 `true`，则当未通过 DCO 认证时拒绝提交。 |
| `reject_unsigned_commits`      | boolean | 如果为 `true`，则当未签名时拒绝提交。 |

示例请求：

```shell
curl --request POST \
  --header "PRIVATE-TOKEN: <your_access_token>" \
  --url "https://gitlab.example.com/api/v4/projects/3/push_rule" \
  --data "commit_message_regex=Fixes \\d+\\..*" \
  --data "deny_delete_tag=false"
```

示例响应：

```json
{
  "id": 1,
  "project_id": 3,
  "created_at": "2012-10-12T17:04:47Z",
  "commit_message_regex": "Fixes \\d+\\..*",
  "commit_message_negative_regex": "",
  "branch_name_regex": "",
  "deny_delete_tag": false,
  "member_check": false,
  "prevent_secrets": false,
  "author_email_regex": "",
  "file_name_regex": "",
  "max_file_size": 0,
  "commit_committer_check": false,
  "commit_committer_name_check": false,
  "reject_unsigned_commits": false,
  "reject_non_dco_commits": false
}
```

<a id="update-push-rules-of-a-project"></a>

## 更新项目的推送规则

更新指定项目的推送规则。

```plaintext
PUT /projects/:id/push_rule
```

支持的属性：

| 属性                           | 类型              | 是否必填 | 描述 |
|--------------------------------|-------------------|----------|------|
| `id`                           | integer or string | 是       | 项目的 ID 或 [URL 编码路径](rest/_index.md#namespaced-paths)。 |
| `author_email_regex`           | string            | 否       | 所有提交作者的电子邮件必须匹配此正则表达式。 |
| `branch_name_regex`            | string            | 否       | 所有分支名称必须匹配此正则表达式。 |
| `commit_committer_check`       | boolean           | 否       | 如果为 `true`，则用户只能向此仓库推送提交，前提是提交者的电子邮件是他们自己的已验证电子邮件之一。 |
| `commit_committer_name_check`  | boolean           | 否       | 如果为 `true`，则用户只能向此仓库推送提交，前提是提交者姓名与他们的极狐GitLab 账户名一致。 |
| `commit_message_negative_regex` | string           | 否       | 任何提交消息都不允许匹配此正则表达式。 |
| `commit_message_regex`         | string            | 否       | 所有提交消息必须匹配此正则表达式。 |
| `deny_delete_tag`              | boolean           | 否       | 如果为 `true`，则拒绝删除标签。 |
| `file_name_regex`              | string            | 否       | 所有提交的文件名不得匹配此正则表达式。 |
| `max_file_size`                | integer           | 否       | 最大文件大小（MB）。 |
| `member_check`                 | boolean           | 否       | 如果为 `true`，则将提交限制为仅限现有极狐GitLab 用户的作者（电子邮件）。 |
| `prevent_secrets`              | boolean           | 否       | 如果为 `true`，极狐GitLab 将拒绝任何可能包含密钥的文件。 |
| `reject_non_dco_commits`       | boolean           | 否       | 如果为 `true`，则当未通过 DCO 认证时拒绝提交。 |
| `reject_unsigned_commits`      | boolean           | 否       | 如果为 `true`，则当未签名时拒绝提交。 |

如果成功，返回 [`200 OK`](rest/troubleshooting.md#status-codes) 和以下响应属性：

| 属性                           | 类型    | 描述 |
|--------------------------------|---------|------|
| `author_email_regex`           | string  | 所有提交作者的电子邮件必须匹配此正则表达式。 |
| `branch_name_regex`            | string  | 所有分支名称必须匹配此正则表达式。 |
| `commit_committer_check`       | boolean | 如果为 `true`，则用户只能向此仓库推送提交，前提是提交者的电子邮件是他们自己的已验证电子邮件之一。 |
| `commit_committer_name_check`  | boolean | 如果为 `true`，则用户只能向此仓库推送提交，前提是提交者姓名与他们的极狐GitLab 账户名一致。 |
| `commit_message_negative_regex` | string | 任何提交消息都不允许匹配此正则表达式。 |
| `commit_message_regex`         | string  | 所有提交消息必须匹配此正则表达式。 |
| `created_at`                   | string  | 推送规则创建的日期和时间。 |
| `deny_delete_tag`              | boolean | 如果为 `true`，则拒绝删除标签。 |
| `file_name_regex`              | string  | 所有提交的文件名不得匹配此正则表达式。 |
| `id`                           | integer | 推送规则的 ID。 |
| `max_file_size`                | integer | 最大文件大小（MB）。 |
| `member_check`                 | boolean | 如果为 `true`，则将提交限制为仅限现有极狐GitLab 用户的作者（电子邮件）。 |
| `prevent_secrets`              | boolean | 如果为 `true`，极狐GitLab 将拒绝任何可能包含密钥的文件。 |
| `project_id`                   | integer | 项目的 ID。 |
| `reject_non_dco_commits`       | boolean | 如果为 `true`，则当未通过 DCO 认证时拒绝提交。 |
| `reject_unsigned_commits`      | boolean | 如果为 `true`，则当未签名时拒绝提交。 |

示例请求：

```shell
curl --request PUT \
  --header "PRIVATE-TOKEN: <your_access_token>" \
  --url "https://gitlab.example.com/api/v4/projects/3/push_rule" \
  --data "commit_message_regex=Fixes \\d+\\..*" \
  --data "deny_delete_tag=true"
```

示例响应：

```json
{
  "id": 1,
  "project_id": 3,
  "created_at": "2012-10-12T17:04:47Z",
  "commit_message_regex": "Fixes \\d+\\..*",
  "commit_message_negative_regex": "",
  "branch_name_regex": "",
  "deny_delete_tag": true,
  "member_check": false,
  "prevent_secrets": false,
  "author_email_regex": "",
  "file_name_regex": "",
  "max_file_size": 0,
  "commit_committer_check": false,
  "commit_committer_name_check": false,
  "reject_unsigned_commits": false,
  "reject_non_dco_commits": false
}
```

<a id="delete-the-push-rules-of-a-project"></a>

## 删除项目的推送规则

删除指定项目的所有推送规则。

```plaintext
DELETE /projects/:id/push_rule
```

支持的属性：

| 属性 | 类型              | 是否必填 | 描述 |
|------|-------------------|----------|------|
| `id` | integer or string | 是       | 项目的 ID 或 [URL 编码路径](rest/_index.md#namespaced-paths)。 |

如果成功，返回 [`204 No Content`](rest/troubleshooting.md#status-codes)。

示例请求：

```shell
curl --request DELETE \
  --header "PRIVATE-TOKEN: <your_access_token>" \
  --url "https://gitlab.example.com/api/v4/projects/3/push_rule"
```