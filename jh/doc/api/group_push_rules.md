---
stage: Create
group: Source Code
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
description: Use push rules to control the content and format of Git commits your repository accepts. Set standards for commit messages, and block secrets or credentials from being added accidentally.
title: 群组推送规则 API
---

{{< details >}}

- Tier: 专业版，旗舰版
- Offering: JihuLab.com，私有化部署

{{< /details >}}

使用此 API 为群组中新建的项目管理 [群组推送规则](../user/project/repository/push_rules.md#group-push-rules)。

先决条件：

- 你必须拥有群组的所有者角色，或者是实例的管理员。

<a id="retrieve-the-push-rules-of-a-group"></a>

## 获取群组的推送规则

获取指定群组的推送规则。

```plaintext
GET /groups/:id/push_rule
```

支持的属性：

| 属性 | 类型           | 是否必需 | 描述 |
|-----------|----------------|----------|-------------|
| `id`      | 整数或字符串 | 是      | 群组的 ID 或 [URL 编码路径](rest/_index.md#namespaced-paths)。 |

如果成功，返回 [`200 OK`](rest/troubleshooting.md#status-codes) 及以下响应属性：

| 属性                         | 类型    | 描述 |
|-----------------------------------|---------|-------------|
| `author_email_regex`              | 字符串  | 仅允许与此正则表达式匹配的提交者电子邮件。 |
| `branch_name_regex`               | 字符串  | 仅允许与此正则表达式匹配的分支名称。 |
| `commit_committer_check`          | 布尔值 | 如果为 `true`，仅当提交者的电子邮件是其已验证电子邮件之一时，才允许用户提交。 |
| `commit_committer_name_check`     | 布尔值 | 如果为 `true`，仅当提交者姓名与其极狐GitLab 账户名一致时，才允许用户提交。 |
| `commit_message_negative_regex`   | 字符串  | 拒绝与此正则表达式匹配的提交消息。 |
| `commit_message_regex`            | 字符串  | 仅允许与此正则表达式匹配的提交消息。 |
| `created_at`                      | 字符串  | 推送规则创建的日期和时间。 |
| `deny_delete_tag`                 | 布尔值 | 如果为 `true`，则拒绝删除标签。 |
| `file_name_regex`                 | 字符串  | 拒绝与此正则表达式匹配的文件名。 |
| `id`                              | 整数 | 推送规则的 ID。 |
| `max_file_size`                   | 整数 | 允许的最大文件大小（MB）。 |
| `member_check`                    | 布尔值 | 如果为 `true`，仅允许极狐GitLab 用户创作提交。 |
| `prevent_secrets`                 | 布尔值 | 如果为 `true`，则拒绝可能包含密钥的文件。 |
| `reject_non_dco_commits`          | 布尔值 | 如果为 `true`，则拒绝未经 DCO 认证的提交。 |
| `reject_unsigned_commits`         | 布尔值 | 如果为 `true`，则拒绝未签名的提交。 |

示例请求：

```shell
curl --header "PRIVATE-TOKEN: <your_access_token>" \
  --url "https://gitlab.example.com/api/v4/groups/2/push_rule"
```

当推送规则已配置但所有设置均为禁用时的示例响应：

```json
{
  "id": 1,
  "created_at": "2020-08-17T19:09:19.580Z",
  "commit_message_regex": "[a-zA-Z]",
  "commit_message_negative_regex": "[x+]",
  "branch_name_regex": "[a-z]",
  "author_email_regex": "^[A-Za-z0-9.]+@gitlab.com$",
  "file_name_regex": "(exe)$",
  "deny_delete_tag": false,
  "member_check": false,
  "prevent_secrets": false,
  "max_file_size": 0,
  "commit_committer_check": null,
  "commit_committer_name_check": false,
  "reject_unsigned_commits": null,
  "reject_non_dco_commits": null
}
```

如果从未为群组配置过推送规则，则返回 [`404 Not Found`](rest/troubleshooting.md#status-codes)：

```json
{
  "message": "404 Not Found"
}
```

> [!note]
> 这与 [项目推送规则 API](project_push_rules.md#retrieve-the-push-rules-of-a-project) 不同，后者在未配置推送规则时返回 HTTP `200 OK` 以及字面字符串 `"null"`。

禁用时，某些布尔属性会返回 `null` 而非 `false`。例如：

- `commit_committer_check`
- `reject_unsigned_commits`
- `reject_non_dco_commits`

<a id="add-push-rules-to-a-group"></a>

## 添加推送规则到群组

向指定群组添加推送规则。仅在尚未定义任何推送规则时使用。

```plaintext
POST /groups/:id/push_rule
```

支持的属性：

| 属性                         | 类型           | 是否必需 | 描述 |
|-----------------------------------|----------------|----------|-------------|
| `id`                              | 整数或字符串 | 是   | 群组的 ID 或 [URL 编码路径](rest/_index.md#namespaced-paths)。 |
| `author_email_regex`              | 字符串         | 否       | 仅允许与此属性中提供的正则表达式匹配的提交者电子邮件，例如 `@my-company.com$`。 |
| `branch_name_regex`               | 字符串         | 否       | 仅允许与此属性中提供的正则表达式匹配的分支名称，例如 `(feature\|hotfix)\/.*`。 |
| `commit_committer_check`          | 布尔值        | 否       | 如果为 `true`，仅当提交者的电子邮件是其已验证电子邮件之一时，才允许用户提交。 |
| `commit_committer_name_check`     | 布尔值        | 否       | 如果为 `true`，仅当提交者姓名与其极狐GitLab 账户名一致时，才允许用户提交。 |
| `commit_message_negative_regex`   | 字符串         | 否       | 拒绝与此属性中提供的正则表达式匹配的提交消息，例如 `ssh\:\/\/`。 |
| `commit_message_regex`            | 字符串         | 否       | 如果设置，仅允许与此属性中提供的正则表达式匹配的提交消息，例如 `Fixed \d+\..*`。 |
| `deny_delete_tag`                 | 布尔值        | 否       | 拒绝删除标签。 |
| `file_name_regex`                 | 字符串         | 否       | 拒绝与此属性中提供的正则表达式匹配的文件名，例如 `(jar\|exe)$`。 |
| `max_file_size`                   | 整数        | 否       | 允许的最大文件大小（MB）。 |
| `member_check`                    | 布尔值        | 否       | 如果为 `true`，仅允许极狐GitLab 用户创作提交。 |
| `prevent_secrets`                 | 布尔值        | 否       | 如果为 `true`，则拒绝可能 [包含密钥](https://jihulab.com/gitlab-cn/gitlab/-/blob/master/ee/lib/gitlab/checks/files_denylist.yml) 的文件。 |
| `reject_non_dco_commits`          | 布尔值        | 否       | 如果为 `true`，则拒绝未经 DCO 认证的提交。 |
| `reject_unsigned_commits`         | 布尔值        | 否       | 如果为 `true`，则拒绝未签名的提交。 |

如果成功，返回 [`201 Created`](rest/troubleshooting.md#status-codes) 及以下响应属性：

| 属性                         | 类型    | 描述 |
|-----------------------------------|---------|-------------|
| `author_email_regex`              | 字符串  | 仅允许与此正则表达式匹配的提交者电子邮件。 |
| `branch_name_regex`               | 字符串  | 仅允许与此正则表达式匹配的分支名称。 |
| `commit_committer_check`          | 布尔值 | 如果为 `true`，仅当提交者的电子邮件是其已验证电子邮件之一时，才允许用户提交。 |
| `commit_committer_name_check`     | 布尔值 | 如果为 `true`，仅当提交者姓名与其极狐GitLab 账户名一致时，才允许用户提交。 |
| `commit_message_negative_regex`   | 字符串  | 拒绝与此正则表达式匹配的提交消息。 |
| `commit_message_regex`            | 字符串  | 如果为 `true`，仅允许与此正则表达式匹配的提交消息。 |
| `created_at`                      | 字符串  | 推送规则创建的日期和时间。 |
| `deny_delete_tag`                 | 布尔值 | 如果为 `true`，则拒绝删除标签。 |
| `file_name_regex`                 | 字符串  | 拒绝与此正则表达式匹配的文件名。 |
| `id`                              | 整数 | 推送规则的 ID。 |
| `max_file_size`                   | 整数 | 允许的最大文件大小（MB）。 |
| `member_check`                    | 布尔值 | 如果为 `true`，仅允许极狐GitLab 用户创作提交。 |
| `prevent_secrets`                 | 布尔值 | 如果为 `true`，则拒绝可能包含密钥的文件。 |
| `reject_non_dco_commits`          | 布尔值 | 如果为 `true`，则拒绝未经 DCO 认证的提交。 |
| `reject_unsigned_commits`         | 布尔值 | 如果为 `true`，则拒绝未签名的提交。 |

示例请求：

```shell
curl --request POST \
  --header "PRIVATE-TOKEN: <your_access_token>" \
  --url "https://gitlab.example.com/api/v4/groups/19/push_rule?prevent_secrets=true"
```

示例响应：

```json
{
  "id": 1,
  "created_at": "2020-08-31T15:53:00.073Z",
  "commit_committer_check": false,
  "commit_committer_name_check": false,
  "reject_unsigned_commits": false,
  "reject_non_dco_commits": false,
  "commit_message_regex": "[a-zA-Z]",
  "commit_message_negative_regex": "[x+]",
  "branch_name_regex": null,
  "deny_delete_tag": false,
  "member_check": false,
  "prevent_secrets": true,
  "author_email_regex": "^[A-Za-z0-9.]+@gitlab.com$",
  "file_name_regex": null,
  "max_file_size": 100
}
```

<a id="update-push-rules-of-a-group"></a>

## 更新群组的推送规则

更新指定群组的推送规则。

```plaintext
PUT /groups/:id/push_rule
```

支持的属性：

| 属性                         | 类型           | 是否必需 | 描述 |
|-----------------------------------|----------------|----------|-------------|
| `id`                              | 整数或字符串 | 是   | 群组的 ID 或 [URL 编码路径](rest/_index.md#namespaced-paths)。 |
| `author_email_regex`              | 字符串         | 否       | 仅允许与此属性中提供的正则表达式匹配的提交者电子邮件，例如 `@my-company.com$`。 |
| `branch_name_regex`               | 字符串         | 否       | 仅允许与此属性中提供的正则表达式匹配的分支名称，例如 `(feature\|hotfix)\/.*`。 |
| `commit_committer_check`          | 布尔值        | 否       | 如果为 `true`，仅当提交者的电子邮件是其已验证电子邮件之一时，才允许用户提交。 |
| `commit_committer_name_check`     | 布尔值        | 否       | 如果为 `true`，仅当提交者姓名与其极狐GitLab 账户名一致时，才允许用户提交。 |
| `commit_message_negative_regex`   | 字符串         | 否       | 拒绝与此属性中提供的正则表达式匹配的提交消息，例如 `ssh\:\/\/`。 |
| `commit_message_regex`            | 字符串         | 否       | 如果设置，仅允许与此属性中提供的正则表达式匹配的提交消息，例如 `Fixed \d+\..*`。 |
| `deny_delete_tag`                 | 布尔值        | 否       | 如果为 `true`，则拒绝删除标签。 |
| `file_name_regex`                 | 字符串         | 否       | 拒绝与此属性中提供的正则表达式匹配的文件名，例如 `(jar\|exe)$`。 |
| `max_file_size`                   | 整数        | 否       | 允许的最大文件大小（MB）。 |
| `member_check`                    | 布尔值        | 否       | 如果为 `true`，仅允许极狐GitLab 用户创作提交。 |
| `prevent_secrets`                 | 布尔值        | 否       | 如果为 `true`，则拒绝可能 [包含密钥](https://jihulab.com/gitlab-cn/gitlab/-/blob/master/ee/lib/gitlab/checks/files_denylist.yml) 的文件。 |
| `reject_non_dco_commits`          | 布尔值        | 否       | 如果为 `true`，则拒绝未经 DCO 认证的提交。 |
| `reject_unsigned_commits`         | 布尔值        | 否       | 如果为 `true`，则拒绝未签名的提交。 |

如果成功，返回 [`200 OK`](rest/troubleshooting.md#status-codes) 及以下响应属性：

| 属性                         | 类型    | 描述 |
|-----------------------------------|---------|-------------|
| `author_email_regex`              | 字符串  | 仅允许与此正则表达式匹配的提交者电子邮件。 |
| `branch_name_regex`               | 字符串  | 仅允许与此正则表达式匹配的分支名称。 |
| `commit_committer_check`          | 布尔值 | 如果为 `true`，仅当提交者的电子邮件是其已验证电子邮件之一时，才允许用户提交。 |
| `commit_committer_name_check`     | 布尔值 | 如果为 `true`，仅当提交者姓名与其极狐GitLab 账户名一致时，才允许用户提交。 |
| `commit_message_negative_regex`   | 字符串  | 拒绝与此正则表达式匹配的提交消息。 |
| `commit_message_regex`            | 字符串  | 如果为 `true`，仅允许与此正则表达式匹配的提交消息。 |
| `created_at`                      | 字符串  | 推送规则创建的日期和时间。 |
| `deny_delete_tag`                 | 布尔值 | 如果为 `true`，则拒绝删除标签。 |
| `file_name_regex`                 | 字符串  | 拒绝与此正则表达式匹配的文件名。 |
| `id`                              | 整数 | 推送规则的 ID。 |
| `max_file_size`                   | 整数 | 允许的最大文件大小（MB）。 |
| `member_check`                    | 布尔值 | 如果为 `true`，仅允许极狐GitLab 用户创作提交。 |
| `prevent_secrets`                 | 布尔值 | 如果为 `true`，则拒绝可能包含密钥的文件。 |
| `reject_non_dco_commits`          | 布尔值 | 如果为 `true`，则拒绝未经 DCO 认证的提交。 |
| `reject_unsigned_commits`         | 布尔值 | 如果为 `true`，则拒绝未签名的提交。 |

示例请求：

```shell
curl --request PUT \
  --header "PRIVATE-TOKEN: <your_access_token>" \
  --url "https://gitlab.example.com/api/v4/groups/19/push_rule?member_check=true"
```

示例响应：

```json
{
  "id": 19,
  "created_at": "2020-08-31T15:53:00.073Z",
  "commit_committer_check": false,
  "commit_committer_name_check": false,
  "reject_unsigned_commits": false,
  "reject_non_dco_commits": false,
  "commit_message_regex": "[a-zA-Z]",
  "commit_message_negative_regex": "[x+]",
  "branch_name_regex": null,
  "deny_delete_tag": false,
  "member_check": true,
  "prevent_secrets": false,
  "author_email_regex": "^[A-Za-z0-9.]+@staging.gitlab.com$",
  "file_name_regex": null,
  "max_file_size": 100
}
```

<a id="delete-the-push-rules-of-a-group"></a>

## 删除群组的推送规则

删除指定群组的所有推送规则。

```plaintext
DELETE /groups/:id/push_rule
```

支持的属性：

| 属性 | 类型           | 是否必需 | 描述 |
|-----------|----------------|----------|-------------|
| `id`      | 整数或字符串 | 是      | 群组的 ID 或 [URL 编码路径](rest/_index.md#namespaced-paths)。 |

如果成功，返回 [`204 No Content`](rest/troubleshooting.md#status-codes)，无响应正文。

示例请求：

```shell
curl --request DELETE \
  --header "PRIVATE-TOKEN: <your_access_token>" \
  --url "https://gitlab.example.com/api/v4/groups/19/push_rule"
```