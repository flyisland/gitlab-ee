---
stage: Create
group: Code Review
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
description: Documentation for the REST API for merge request approvals in GitLab.
title: 合并请求审批 API
---

{{< details >}}

- Tier: 专业版，旗舰版
- Offering: JihuLab.com，私有化部署

{{< /details >}}

{{< history >}}

- 端点 `/approvals` 在 极狐GitLab 16.0 中已移除。

{{< /history >}}

使用此 API 管理[合并请求审批](../user/project/merge_requests/approvals/_index.md)。

所有端点都需要身份验证。

<a id="approve-merge-request"></a>

## 审批合并请求

审批指定的合并请求。当前已认证的用户必须是[符合条件的审批人](../user/project/merge_requests/approvals/rules.md#eligible-approvers)。

`sha` 参数确保你正在审批合并请求的当前版本。如果定义，该值必须与合并请求的 HEAD 提交 SHA 匹配。不匹配将返回 `409 Conflict` 响应。这与[接受合并请求](merge_requests.md#merge-a-merge-request)的行为一致。

```plaintext
POST /projects/:id/merge_requests/:merge_request_iid/approve
```

支持的属性：

| 属性 | 类型 | 必需 | 描述 |
|---------------------|-------------------|----------|-------------|
| `id` | integer 或 string | 是 | 项目的 ID 或 [URL 编码路径](rest/_index.md#namespaced-paths)。 |
| `approval_password` | string | 否 | 当前用户的密码。如果在项目设置中启用了[**要求用户重新认证以审批**](../user/project/merge_requests/approvals/settings.md#require-user-re-authentication-to-approve)，则为必需。如果群组或极狐GitLab 私有化部署实例配置为强制 SAML 认证，则始终失败。 |
| `merge_request_iid` | integer | 是 | 合并请求的 IID。 |
| `sha` | string | 否 | 合并请求的 `HEAD`。 |

```json
{
  "id": 5,
  "iid": 5,
  "project_id": 1,
  "title": "Approvals API",
  "description": "Test",
  "state": "opened",
  "created_at": "2016-06-08T00:19:52.638Z",
  "updated_at": "2016-06-09T21:32:14.105Z",
  "merge_status": "can_be_merged",
  "approvals_required": 2,
  "approvals_left": 0,
  "approved_by": [
    {
      "user": {
        "name": "Administrator",
        "username": "root",
        "id": 1,
        "state": "active",
        "avatar_url": "http://www.gravatar.com/avatar/e64c7d89f26bd1972efa854d13d7dd61?s=80\u0026d=identicon",
        "web_url": "http://localhost:3000/root"
      },
      "approved_at": "2016-06-10T04:21:41.050Z"
    },
    {
      "user": {
        "name": "Nico Cartwright",
        "username": "ryley",
        "id": 2,
        "state": "active",
        "avatar_url": "http://www.gravatar.com/avatar/cf7ad14b34162a76d593e3affca2adca?s=80\u0026d=identicon",
        "web_url": "http://localhost:3000/ryley"
      },
      "approved_at": "2016-06-10T09:17:13.520Z"
    }
  ]
}
```

<a id="prevent-approval-resets-in-automated-merge-requests"></a>

### 防止自动化合并请求中的审批重置

如果你使用 API 创建并立即审批合并请求，你的自动化可能会在提交完全处理之前审批该合并请求。默认情况下，向合并请求添加新提交会[重置所有现有审批](../user/project/merge_requests/approvals/settings.md#remove-all-approvals-when-commits-are-added-to-the-source-branch)。发生这种情况时，合并请求的**活动**区域会显示类似以下的消息序列：

- `(botname)` 在 5 分钟前审批了此合并请求
- `(botname)` 在 5 分钟前添加了 1 个提交
- `(botname)` 通过推送到分支在 5 分钟前重置了来自 `(botname)` 的审批

为确保自动化审批不会在提交处理完成之前应用，你的自动化应添加等待（或 `sleep`）函数，直到：

- `detailed_merge_status` 属性不处于 `checking` 或 `approvals_syncing` 状态。
- 合并请求差异包含一个不为 NULL 的 `patch_id_sha`。

<a id="unapprove-a-merge-request"></a>

## 取消审批合并请求

移除当前已认证用户对指定合并请求的审批。

```plaintext
POST /projects/:id/merge_requests/:merge_request_iid/unapprove
```

支持的属性：

| 属性 | 类型 | 必需 | 描述 |
|---------------------|-------------------|----------|-------------|
| `id` | integer 或 string | 是 | 项目的 ID 或 [URL 编码路径](rest/_index.md#namespaced-paths)。 |
| `merge_request_iid` | integer | 是 | 合并请求的 IID。 |

<a id="reset-approvals-for-a-merge-request"></a>

## 重置合并请求的审批

重置指定合并请求的所有审批。仅适用于具有有效项目或群组令牌的[机器人用户](../user/project/settings/project_access_tokens.md#bot-users-for-projects)。人类用户会收到 `401 Unauthorized` 响应。

```plaintext
PUT /projects/:id/merge_requests/:merge_request_iid/reset_approvals
```

| 属性 | 类型 | 必需 | 描述 |
|---------------------|-------------------|----------|-------------|
| `id` | integer 或 string | 是 | 项目的 ID 或 [URL 编码路径](rest/_index.md#namespaced-paths)。 |
| `merge_request_iid` | integer | 是 | 合并请求的内部 ID。 |

```shell
curl --request PUT \
  --header "PRIVATE-TOKEN: <your_access_token>" \
  --url "https://gitlab.example.com/api/v4/projects/76/merge_requests/1/reset_approvals"
```

<a id="approval-rules-for-projects"></a>

## 项目审批规则

这些端点适用于项目及其审批规则。所有端点都需要身份验证。

<a id="retrieve-approval-configuration-for-a-project"></a>

### 获取项目的审批配置

获取项目的审批配置。

```plaintext
GET /projects/:id/approvals
```

支持的属性：

| 属性 | 类型 | 必需 | 描述 |
|-----------|-------------------|----------|-------------|
| `id` | integer 或 string | 是 | 项目的 ID 或 [URL 编码路径](rest/_index.md#namespaced-paths)。 |

```json
{
  "approvers": [], // 在 极狐GitLab 12.3 中已弃用，始终返回空
  "approver_groups": [], // 在 极狐GitLab 12.3 中已弃用，始终返回空
  "approvals_before_merge": 2, // 在 极狐GitLab 12.3 中已弃用，请改用审批规则
  "reset_approvals_on_push": true,
  "selective_code_owner_removals": false,
  "disable_overriding_approvers_per_merge_request": false,
  "merge_requests_author_approval": true,
  "merge_requests_disable_committers_approval": false,
  "require_password_to_approve": true, // 在 16.9 中已弃用，请改用 require_reauthentication_to_approve
  "require_reauthentication_to_approve": true
}
```

<a id="update-approval-configuration-for-a-project"></a>

### 更新项目的审批配置

更新项目的审批配置。当前已认证的用户必须是[符合条件的审批人](../user/project/merge_requests/approvals/rules.md#eligible-approvers)。

```plaintext
POST /projects/:id/approvals
```

支持的属性：

| 属性 | 类型 | 必需 | 描述 |
|--------------------------------------------------|-------------------|----------|-------------|
| `id` | integer 或 string | 是 | 项目的 ID 或 [URL 编码路径](rest/_index.md#namespaced-paths)。 |
| `approvals_before_merge`（已弃用） | integer | 否 | 合并请求合并前所需的审批数量。在 极狐GitLab 12.3 中[已弃用](https://gitlab.com/gitlab-org/gitlab/-/issues/11132)。请改为[创建审批规则](#create-an-approval-rule-for-a-project)。 <!-- 在字段实际移除前请勿删除此行 --> |
| `disable_overriding_approvers_per_merge_request` | boolean | 否 | 如果为 `true`，则阻止在合并请求中覆盖审批人。 |
| `merge_requests_author_approval` | boolean | 否 | 如果为 `true`，则作者可以自行审批自己的合并请求。 |
| `merge_requests_disable_committers_approval` | boolean | 否 | 如果为 `true`，则在合并请求上提交的用户不能审批它。 |
| `require_password_to_approve`（已弃用） | boolean | 否 | 如果为 `true`，则要求审批人在添加审批前使用密码进行身份验证。在 极狐GitLab 16.9 中[已弃用](https://gitlab.com/gitlab-org/gitlab/-/issues/431346)。请改用 `require_reauthentication_to_approve`。 |
| `require_reauthentication_to_approve` | boolean | 否 | 如果为 `true`，则要求审批人在添加审批前进行身份验证。在 极狐GitLab 17.1 中[引入](https://gitlab.com/gitlab-org/gitlab/-/issues/431346)。 |
| `reset_approvals_on_push` | boolean | 否 | 如果为 `true`，则在推送时重置审批。 |
| `selective_code_owner_removals` | boolean | 否 | 如果为 `true`，则当代码所有者的文件发生更改时，重置其审批。要使用此字段，`reset_approvals_on_push` 必须为 `false`。 |

```json
{
  "approvals_before_merge": 2, // 请改用审批规则
  "reset_approvals_on_push": true,
  "selective_code_owner_removals": false,
  "disable_overriding_approvers_per_merge_request": false,
  "merge_requests_author_approval": false,
  "merge_requests_disable_committers_approval": false,
  "require_password_to_approve": true,
  "require_reauthentication_to_approve": true
}
```

<a id="list-all-approval-rules-for-a-project"></a>

### 列出项目的所有审批规则

列出指定项目的所有审批规则及其相关详细信息。

```plaintext
GET /projects/:id/approval_rules
```

要限制审批规则列表，请使用 `page` 和 `per_page` [分页](rest/_index.md#offset-based-pagination)参数。

支持的属性：

| 属性 | 类型 | 必需 | 描述 |
|-----------|-------------------|----------|-------------|
| `id` | integer 或 string | 是 | 项目的 ID 或 [URL 编码路径](rest/_index.md#namespaced-paths)。 |

```json
[
  {
    "id": 1,
    "name": "security",
    "rule_type": "regular",
    "report_type": null,
    "eligible_approvers": [
      {
        "id": 5,
        "name": "John Doe",
        "username": "jdoe",
        "state": "active",
        "avatar_url": "https://www.gravatar.com/avatar/0?s=80&d=identicon",
        "web_url": "http://localhost/jdoe"
      },
      {
        "id": 50,
        "name": "Group Member 1",
        "username": "group_member_1",
        "state": "active",
        "avatar_url": "https://www.gravatar.com/avatar/0?s=80&d=identicon",
        "web_url": "http://localhost/group_member_1"
      }
    ],
    "approvals_required": 3,
    "users": [
      {
        "id": 5,
        "name": "John Doe",
        "username": "jdoe",
        "state": "active",
        "avatar_url": "https://www.gravatar.com/avatar/0?s=80&d=identicon",
        "web_url": "http://localhost/jdoe"
      }
    ],
    "groups": [
      {
        "id": 5,
        "name": "group1",
        "path": "group1",
        "description": "",
        "visibility": "public",
        "lfs_enabled": false,
        "avatar_url": null,
        "web_url": "http://localhost/groups/group1",
        "request_access_enabled": false,
        "full_name": "group1",
        "full_path": "group1",
        "parent_id": null,
        "ldap_cn": null,
        "ldap_access": null
      }
    ],
    "applies_to_all_protected_branches": false,
    "protected_branches": [
      {
        "id": 1,
        "name": "main",
        "push_access_levels": [
          {
            "access_level": 30,
            "access_level_description": "Developers + Maintainers"
          }
        ],
        "merge_access_levels": [
          {
            "access_level": 30,
            "access_level_description": "Developers + Maintainers"
          }
        ],
        "unprotect_access_levels": [
          {
            "access_level": 40,
            "access_level_description": "Maintainers"
          }
        ],
        "code_owner_approval_required": "false"
      }
    ],
    "contains_hidden_groups": false,
  },
  {
    "id": 2,
    "name": "Coverage-Check",
    "rule_type": "report_approver",
    "report_type": "code_coverage",
    "eligible_approvers": [
      {
        "id": 5,
        "name": "John Doe",
        "username": "jdoe",
        "state": "active",
        "avatar_url": "https://www.gravatar.com/avatar/0?s=80&d=identicon",
        "web_url": "http://localhost/jdoe"
      },
      {
        "id": 50,
        "name": "Group Member 1",
        "username": "group_member_1",
        "state": "active",
        "avatar_url": "https://www.gravatar.com/avatar/0?s=80&d=identicon",
        "web_url": "http://localhost/group_member_1"
      }
    ],
    "approvals_required": 3,
    "users": [
      {
        "id": 5,
        "name": "John Doe",
        "username": "jdoe",
        "state": "active",
        "avatar_url": "https://www.gravatar.com/avatar/0?s=80&d=identicon",
        "web_url": "http://localhost/jdoe"
      }
    ],
    "groups": [
      {
        "id": 5,
        "name": "group1",
        "path": "group1",
        "description": "",
        "visibility": "public",
        "lfs_enabled": false,
        "avatar_url": null,
        "web_url": "http://localhost/groups/group1",
        "request_access_enabled": false,
        "full_name": "group1",
        "full_path": "group1",
        "parent_id": null,
        "ldap_cn": null,
        "ldap_access": null
      }
    ],
    "applies_to_all_protected_branches": false,
    "protected_branches": [
      {
        "id": 1,
        "name": "main",
        "push_access_levels": [
          {
            "access_level": 30,
            "access_level_description": "Developers + Maintainers"
          }
        ],
        "merge_access_levels": [
          {
            "access_level": 30,
            "access_level_description": "Developers + Maintainers"
          }
        ],
        "unprotect_access_levels": [
          {
            "access_level": 40,
            "access_level_description": "Maintainers"
          }
        ],
        "code_owner_approval_required": "false"
      }
    ],
    "contains_hidden_groups": false,
  }
]
```

<a id="retrieve-an-approval-rule-for-a-project"></a>

### 获取项目的审批规则

获取项目的指定审批规则的信息。

```plaintext
GET /projects/:id/approval_rules/:approval_rule_id
```

支持的属性：

| 属性 | 类型 | 必需 | 描述 |
|--------------------|-------------------|----------|-------------|
| `id` | integer 或 string | 是 | 项目的 ID 或 [URL 编码路径](rest/_index.md#namespaced-paths)。 |
| `approval_rule_id` | integer | 是 | 审批规则的 ID。 |

```json
{
  "id": 1,
  "name": "security",
  "rule_type": "regular",
  "report_type": null,
  "eligible_approvers": [
    {
      "id": 5,
      "name": "John Doe",
      "username": "jdoe",
      "state": "active",
      "avatar_url": "https://www.gravatar.com/avatar/0?s=80&d=identicon",
      "web_url": "http://localhost/jdoe"
    },
    {
      "id": 50,
      "name": "Group Member 1",
      "username": "group_member_1",
      "state": "active",
      "avatar_url": "https://www.gravatar.com/avatar/0?s=80&d=identicon",
      "web_url": "http://localhost/group_member_1"
    }
  ],
  "approvals_required": 3,
  "users": [
    {
      "id": 5,
      "name": "John Doe",
      "username": "jdoe",
      "state": "active",
      "avatar_url": "https://www.gravatar.com/avatar/0?s=80&d=identicon",
      "web_url": "http://localhost/jdoe"
    }
  ],
  "groups": [
    {
      "id": 5,
      "name": "group1",
      "path": "group1",
      "description": "",
      "visibility": "public",
      "lfs_enabled": false,
      "avatar_url": null,
      "web_url": "http://localhost/groups/group1",
      "request_access_enabled": false,
      "full_name": "group1",
      "full_path": "group1",
      "parent_id": null,
      "ldap_cn": null,
      "ldap_access": null
    }
  ],
  "applies_to_all_protected_branches": false,
  "protected_branches": [
    {
      "id": 1,
      "name": "main",
      "push_access_levels": [
        {
          "access_level": 30,
          "access_level_description": "Developers + Maintainers"
        }
      ],
      "merge_access_levels": [
        {
          "access_level": 30,
          "access_level_description": "Developers + Maintainers"
        }
      ],
      "unprotect_access_levels": [
        {
          "access_level": 40,
          "access_level_description": "Maintainers"
        }
      ],
      "code_owner_approval_required": "false"
    }
  ],
  "contains_hidden_groups": false
}
```

<a id="create-an-approval-rule-for-a-project"></a>

### 为项目创建审批规则

为项目创建审批规则。

`rule_type` 字段支持以下规则类型：

- `any_approver`：一个预配置的默认规则，`approvals_required` 设置为 `0`。
- `regular`：用于常规的[合并请求审批规则](../user/project/merge_requests/approvals/rules.md)。
- `report_approver`：当极狐GitLab 从已配置并启用的[合并请求审批策略](../user/application_security/policies/merge_request_approval_policies.md)创建审批规则时使用。使用此 API 创建审批规则时，请勿使用此值。

```plaintext
POST /projects/:id/approval_rules
```

支持的属性：

| 属性 | 类型 | 必需 | 描述 |
|-------------------------------------|-------------------|----------|-------------|
| `id` | integer 或 string | 是 | 项目的 ID 或 [URL 编码路径](rest/_index.md#namespaced-paths)。 |
| `approvals_required` | integer | 是 | 此规则所需的审批数量。 |
| `name` | string | 是 | 审批规则的名称。限制为 1024 个字符。 |
| `applies_to_all_protected_branches` | boolean | 否 | 如果为 `true`，则将规则应用于所有受保护分支，并忽略 `protected_branch_ids` 属性。 |
| `group_ids` | Array | 否 | 作为审批人的群组 ID。 |
| `protected_branch_ids` | Array | 否 | 用于限定规则范围的受保护分支的 ID。要识别 ID，请使用[列出受保护分支](protected_branches.md#list-protected-branches) API。 |
| `report_type` | string | 否 | 报告类型。当规则类型为 `report_approver` 时必需。支持的报告类型有 `license_scanning` [（在 极狐GitLab 15.9 中已弃用）](../update/deprecations.md#license-check-and-the-policies-tab-on-the-license-compliance-page) 和 `code_coverage`。 <!-- 在字段实际移除前请勿删除此行 --> |
| `rule_type` | string | 否 | 规则类型。支持的值包括 `any_approver`、`regular` 和 `report_approver`。 |
| `user_ids` | Array | 否 | 作为审批人的用户 ID。如果与 `usernames` 一起使用，则会添加两个列表中的用户。 |
| `usernames` | string array | 否 | 审批人的用户名。如果与 `user_ids` 一起使用，则会添加两个列表中的用户。 |

```json
{
  "id": 1,
  "name": "security",
  "rule_type": "regular",
  "eligible_approvers": [
    {
      "id": 2,
      "name": "John Doe",
      "username": "jdoe",
      "state": "active",
      "avatar_url": "https://www.gravatar.com/avatar/0?s=80&d=identicon",
      "web_url": "http://localhost/jdoe"
    },
    {
      "id": 50,
      "name": "Group Member 1",
      "username": "group_member_1",
      "state": "active",
      "avatar_url": "https://www.gravatar.com/avatar/0?s=80&d=identicon",
      "web_url": "http://localhost/group_member_1"
    }
  ],
  "approvals_required": 1,
  "users": [
    {
      "id": 2,
      "name": "John Doe",
      "username": "jdoe",
      "state": "active",
      "avatar_url": "https://www.gravatar.com/avatar/0?s=80&d=identicon",
      "web_url": "http://localhost/jdoe"
    }
  ],
  "groups": [
    {
      "id": 5,
      "name": "group1",
      "path": "group1",
      "description": "",
      "visibility": "public",
      "lfs_enabled": false,
      "avatar_url": null,
      "web_url": "http://localhost/groups/group1",
      "request_access_enabled": false,
      "full_name": "group1",
      "full_path": "group1",
      "parent_id": null,
      "ldap_cn": null,
      "ldap_access": null
    }
  ],
  "applies_to_all_protected_branches": false,
  "protected_branches": [
    {
      "id": 1,
      "name": "main",
      "push_access_levels": [
        {
          "access_level": 30,
          "access_level_description": "Developers + Maintainers"
        }
      ],
      "merge_access_levels": [
        {
          "access_level": 30,
          "access_level_description": "Developers + Maintainers"
        }
      ],
      "unprotect_access_levels": [
        {
          "access_level": 40,
          "access_level_description": "Maintainers"
        }
      ],
      "code_owner_approval_required": "false"
    }
  ],
  "contains_hidden_groups": false
}
```

要增加默认的 0 个必需审批人数：

```shell
curl --request POST \
  --header "PRIVATE-TOKEN: <your_access_token>" \
  --header 'Content-Type: application/json' \
  --data '{"name": "Any name", "rule_type": "any_approver", "approvals_required": 2}' \
  --url "https://gitlab.example.com/api/v4/projects/<project_id>/approval_rules"
```

另一个示例是创建用户特定的规则：

```shell
curl --request POST \
  --header "PRIVATE-TOKEN: <your_access_token>" \
  --header 'Content-Type: application/json' \
  --data '{"name": "Name of your rule", "approvals_required": 3, "user_ids": [123, 456, 789]}' \
  --url "https://gitlab.example.com/api/v4/projects/<project_id>/approval_rules"
```

<a id="update-an-approval-rule-for-a-project"></a>

### 更新项目的审批规则

更新项目的指定审批规则。此端点会移除未在 `group_ids`、`user_ids` 或 `usernames` 属性中定义的任何审批人和群组。

默认情况下，不在 `users` 或 `groups` 参数中的隐藏群组（用户无权查看的私有群组）会被保留。要移除它们，请将 `remove_hidden_groups` 设置为 `true`。这确保了在用户更新审批规则时，隐藏群组不会被意外移除。

```plaintext
PUT /projects/:id/approval_rules/:approval_rule_id
```

支持的属性：

| 属性 | 类型 | 必需 | 描述 |
|-------------------------------------|-------------------|----------|-------------|
| `approval_rule_id` | integer | 是 | 审批规则的 ID。 |
| `id` | integer 或 string | 是 | 项目的 ID 或 [URL 编码路径](rest/_index.md#namespaced-paths)。 |
| `applies_to_all_protected_branches` | boolean | 否 | 如果为 `true`，则将规则应用于所有受保护分支，并忽略 `protected_branch_ids` 属性。 |
| `approvals_required` | integer | 否 | 此规则所需的审批数量。 |
| `group_ids` | Array | 否 | 作为审批人的群组 ID。 |
| `name` | string | 否 | 审批规则的名称。限制为 1024 个字符。 |
| `protected_branch_ids` | Array | 否 | 用于限定规则范围的受保护分支的 ID。要识别 ID，请使用[列出受保护分支](protected_branches.md#list-protected-branches) API。 |
| `remove_hidden_groups` | boolean | 否 | 如果为 `true`，则从审批规则中移除隐藏群组。 |
| `user_ids` | Array | 否 | 作为审批人的用户 ID。如果与 `usernames` 一起使用，则会添加两个列表中的用户。 |
| `usernames` | string array | 否 | 审批人的用户名。如果与 `user_ids` 一起使用，则会添加两个列表中的用户。 |
```json
{
  "id": 1,
  "name": "security",
  "rule_type": "regular",
  "eligible_approvers": [
    {
      "id": 2,
      "name": "John Doe",
      "username": "jdoe",
      "state": "active",
      "avatar_url": "https://www.gravatar.com/avatar/0?s=80&d=identicon",
      "web_url": "http://localhost/jdoe"
    },
    {
      "id": 50,
      "name": "Group Member 1",
      "username": "group_member_1",
      "state": "active",
      "avatar_url": "https://www.gravatar.com/avatar/0?s=80&d=identicon",
      "web_url": "http://localhost/group_member_1"
    }
  ],
  "approvals_required": 1,
  "users": [
    {
      "id": 2,
      "name": "John Doe",
      "username": "jdoe",
      "state": "active",
      "avatar_url": "https://www.gravatar.com/avatar/0?s=80&d=identicon",
      "web_url": "http://localhost/jdoe"
    }
  ],
  "groups": [
    {
      "id": 5,
      "name": "group1",
      "path": "group1",
      "description": "",
      "visibility": "public",
      "lfs_enabled": false,
      "avatar_url": null,
      "web_url": "http://localhost/groups/group1",
      "request_access_enabled": false,
      "full_name": "group1",
      "full_path": "group1",
      "parent_id": null,
      "ldap_cn": null,
      "ldap_access": null
    }
  ],
  "applies_to_all_protected_branches": false,
  "protected_branches": [
    {
      "id": 1,
      "name": "main",
      "push_access_levels": [
        {
          "access_level": 30,
          "access_level_description": "Developers + Maintainers"
        }
      ],
      "merge_access_levels": [
        {
          "access_level": 30,
          "access_level_description": "Developers + Maintainers"
        }
      ],
      "unprotect_access_levels": [
        {
          "access_level": 40,
          "access_level_description": "Maintainers"
        }
      ],
      "code_owner_approval_required": "false"
    }
  ],
  "contains_hidden_groups": false
}
```

### 删除项目审批规则

删除指定项目的审批规则。

```plaintext
DELETE /projects/:id/approval_rules/:approval_rule_id
```

支持的属性：

| 属性                | 类型               | 是否必需 | 描述 |
|--------------------|-------------------|----------|-------------|
| `id`               | integer 或 string | 是       | 项目的 ID 或 [URL 编码路径](rest/_index.md#namespaced-paths)。 |
| `approval_rule_id` | integer           | 是       | 审批规则的 ID。 |

## 合并请求的审批规则

这些端点适用于单个合并请求。所有端点都需要身份验证。

### 获取合并请求的审批状态

获取指定合并请求的审批状态。

在响应中，`approved_by` 包含该合并请求的所有审批者的信息，无论这些审批是否满足任何审批规则。有关合并请求中审批规则以及收到的审批是否满足这些规则的更详细信息，请参阅 [`/approval_state` 端点](#retrieve-approval-details-for-a-merge-request)。

```plaintext
GET /projects/:id/merge_requests/:merge_request_iid/approvals
```

支持的属性：

| 属性                 | 类型               | 是否必需 | 描述 |
|---------------------|-------------------|----------|-------------|
| `id`                | integer 或 string | 是       | 项目的 ID 或 [URL 编码路径](rest/_index.md#namespaced-paths)。 |
| `merge_request_iid` | integer           | 是       | 合并请求的 IID。 |

```json
{
  "id": 5,
  "iid": 5,
  "project_id": 1,
  "title": "Approvals API",
  "description": "Test",
  "state": "opened",
  "created_at": "2016-06-08T00:19:52.638Z",
  "updated_at": "2016-06-08T21:20:42.470Z",
  "merge_status": "cannot_be_merged",
  "approvals_required": 2,
  "approvals_left": 1,
  "approved_by": [
    {
      "user": {
        "name": "Administrator",
        "username": "root",
        "id": 1,
        "state": "active",
        "avatar_url": "http://www.gravatar.com/avatar/e64c7d89f26bd1972efa854d13d7dd61?s=80\u0026d=identicon",
        "web_url": "http://localhost:3000/root"
      },
      "approved_at": "2016-06-09T01:45:21.720Z"
    }
  ]
}
```

### 获取合并请求的审批详情

获取指定合并请求的审批详情。

如果用户修改了合并请求的审批规则，响应将包括：

- `approval_rules_overwritten`：如果为 `true`，表示默认审批规则已被修改。
- `approved`：如果为 `true`，表示关联的审批规则已获批准。
- `approved_by`：如果已定义，表示批准了关联审批规则的用户详情。不匹配审批规则的用户不会被返回。要返回所有审批用户，请参阅 [`/approvals` 端点](#retrieve-approval-state-for-a-merge-request)。

```plaintext
GET /projects/:id/merge_requests/:merge_request_iid/approval_state
```

支持的属性：

| 属性                 | 类型               | 是否必需 | 描述 |
|---------------------|-------------------|----------|-------------|
| `id`                | integer 或 string | 是       | 项目的 ID 或 [URL 编码路径](rest/_index.md#namespaced-paths)。 |
| `merge_request_iid` | integer           | 是       | 合并请求的 IID。 |

```json
{
  "approval_rules_overwritten": true,
  "rules": [
    {
      "id": 1,
      "name": "Ruby",
      "rule_type": "regular",
      "eligible_approvers": [
        {
          "id": 4,
          "name": "John Doe",
          "username": "jdoe",
          "state": "active",
          "avatar_url": "https://www.gravatar.com/avatar/0?s=80&d=identicon",
          "web_url": "http://localhost/jdoe"
        }
      ],
      "approvals_required": 2,
      "users": [
        {
          "id": 4,
          "name": "John Doe",
          "username": "jdoe",
          "state": "active",
          "avatar_url": "https://www.gravatar.com/avatar/0?s=80&d=identicon",
          "web_url": "http://localhost/jdoe"
        }
      ],
      "groups": [],
      "contains_hidden_groups": false,
      "approved_by": [
        {
          "id": 4,
          "name": "John Doe",
          "username": "jdoe",
          "state": "active",
          "avatar_url": "https://www.gravatar.com/avatar/0?s=80&d=identicon",
          "web_url": "http://localhost/jdoe"
        }
      ],
      "source_rule": null,
      "approved": true,
      "overridden": false
    }
  ]
}
```

### 列出合并请求的所有审批规则

列出指定合并请求的所有审批规则及其相关详情。

可以使用 `page` 和 `per_page` [分页参数](rest/_index.md#offset-based-pagination) 来限制审批规则列表。

```plaintext
GET /projects/:id/merge_requests/:merge_request_iid/approval_rules
```

支持的属性：

| 属性                 | 类型               | 是否必需 | 描述 |
|---------------------|-------------------|----------|-------------|
| `id`                | integer 或 string | 是       | 项目的 ID 或 [URL 编码路径](rest/_index.md#namespaced-paths)。 |
| `merge_request_iid` | integer           | 是       | 合并请求的 IID。 |

```json
[
  {
    "id": 1,
    "name": "security",
    "rule_type": "regular",
    "report_type": null,
    "eligible_approvers": [
      {
        "id": 5,
        "name": "John Doe",
        "username": "jdoe",
        "state": "active",
        "avatar_url": "https://www.gravatar.com/avatar/0?s=80&d=identicon",
        "web_url": "http://localhost/jdoe"
      },
      {
        "id": 50,
        "name": "Group Member 1",
        "username": "group_member_1",
        "state": "active",
        "avatar_url": "https://www.gravatar.com/avatar/0?s=80&d=identicon",
        "web_url": "http://localhost/group_member_1"
      }
    ],
    "approvals_required": 3,
    "source_rule": null,
    "users": [
      {
        "id": 5,
        "name": "John Doe",
        "username": "jdoe",
        "state": "active",
        "avatar_url": "https://www.gravatar.com/avatar/0?s=80&d=identicon",
        "web_url": "http://localhost/jdoe"
      }
    ],
    "groups": [
      {
        "id": 5,
        "name": "group1",
        "path": "group1",
        "description": "",
        "visibility": "public",
        "lfs_enabled": false,
        "avatar_url": null,
        "web_url": "http://localhost/groups/group1",
        "request_access_enabled": false,
        "full_name": "group1",
        "full_path": "group1",
        "parent_id": null,
        "ldap_cn": null,
        "ldap_access": null
      }
    ],
    "contains_hidden_groups": false,
    "overridden": false
  },
  {
    "id": 2,
    "name": "Coverage-Check",
    "rule_type": "report_approver",
    "report_type": "code_coverage",
    "eligible_approvers": [
      {
        "id": 5,
        "name": "John Doe",
        "username": "jdoe",
        "state": "active",
        "avatar_url": "https://www.gravatar.com/avatar/0?s=80&d=identicon",
        "web_url": "http://localhost/jdoe"
      },
      {
        "id": 50,
        "name": "Group Member 1",
        "username": "group_member_1",
        "state": "active",
        "avatar_url": "https://www.gravatar.com/avatar/0?s=80&d=identicon",
        "web_url": "http://localhost/group_member_1"
      }
    ],
    "approvals_required": 3,
    "source_rule": null,
    "users": [
      {
        "id": 5,
        "name": "John Doe",
        "username": "jdoe",
        "state": "active",
        "avatar_url": "https://www.gravatar.com/avatar/0?s=80&d=identicon",
        "web_url": "http://localhost/jdoe"
      }
    ],
    "groups": [
      {
        "id": 5,
        "name": "group1",
        "path": "group1",
        "description": "",
        "visibility": "public",
        "lfs_enabled": false,
        "avatar_url": null,
        "web_url": "http://localhost/groups/group1",
        "request_access_enabled": false,
        "full_name": "group1",
        "full_path": "group1",
        "parent_id": null,
        "ldap_cn": null,
        "ldap_access": null
      }
    ],
    "contains_hidden_groups": false,
    "overridden": false
  }
]
```

### 获取特定合并请求的审批规则

获取特定合并请求的审批规则信息。

```plaintext
GET /projects/:id/merge_requests/:merge_request_iid/approval_rules/:approval_rule_id
```

支持的属性：

| 属性                 | 类型               | 是否必需 | 描述 |
|---------------------|-------------------|----------|-------------|
| `id`                | integer 或 string | 是       | 项目的 ID 或 [URL 编码路径](rest/_index.md#namespaced-paths)。 |
| `approval_rule_id`  | integer           | 是       | 审批规则的 ID。 |
| `merge_request_iid` | integer           | 是       | 合并请求的 IID。 |

```json
{
  "id": 1,
  "name": "security",
  "rule_type": "regular",
  "report_type": null,
  "eligible_approvers": [
    {
      "id": 5,
      "name": "John Doe",
      "username": "jdoe",
      "state": "active",
      "avatar_url": "https://www.gravatar.com/avatar/0?s=80&d=identicon",
      "web_url": "http://localhost/jdoe"
    },
    {
      "id": 50,
      "name": "Group Member 1",
      "username": "group_member_1",
      "state": "active",
      "avatar_url": "https://www.gravatar.com/avatar/0?s=80&d=identicon",
      "web_url": "http://localhost/group_member_1"
    }
  ],
  "approvals_required": 3,
  "source_rule": null,
  "users": [
    {
      "id": 5,
      "name": "John Doe",
      "username": "jdoe",
      "state": "active",
      "avatar_url": "https://www.gravatar.com/avatar/0?s=80&d=identicon",
      "web_url": "http://localhost/jdoe"
    }
  ],
  "groups": [
    {
      "id": 5,
      "name": "group1",
      "path": "group1",
      "description": "",
      "visibility": "public",
      "lfs_enabled": false,
      "avatar_url": null,
      "web_url": "http://localhost/groups/group1",
      "request_access_enabled": false,
      "full_name": "group1",
      "full_path": "group1",
      "parent_id": null,
      "ldap_cn": null,
      "ldap_access": null
    }
  ],
  "contains_hidden_groups": false,
  "overridden": false
}
```

### 为合并请求创建审批规则

为特定合并请求创建审批规则。如果设置了 `approval_project_rule_id` 为项目现有审批规则的 ID，此端点会：

- 从项目规则中复制 `name`、`users` 和 `groups` 的值。
- 使用你指定的 `approvals_required` 值。

```plaintext
POST /projects/:id/merge_requests/:merge_request_iid/approval_rules
```

支持的属性：

| 属性                        | 类型               | 是否必需 | 描述 |
|----------------------------|-------------------|----------|------|
| `id`                       | integer 或 string | 是       | 项目的 ID 或 [URL 编码路径](rest/_index.md#namespaced-paths)。 |
| `approvals_required`       | integer           | 是       | 此规则所需的审批数量。 |
| `merge_request_iid`        | integer           | 是       | 合并请求的 IID。 |
| `name`                     | string            | 是       | 审批规则名称，最多 1024 个字符。 |
| `approval_project_rule_id` | integer           | 否       | 项目审批规则的 ID。 |
| `group_ids`                | Array             | 否       | 作为审批者的群组 ID。 |
| `user_ids`                 | Array             | 否       | 作为审批者的用户 ID。若与 `usernames` 同时使用，则合并两个列表。 |
| `usernames`                | string array      | 否       | 审批者的用户名。若与 `user_ids` 同时使用，则合并两个列表。 |

```json
{
  "id": 1,
  "name": "security",
  "rule_type": "regular",
  "eligible_approvers": [
    {
      "id": 2,
      "name": "John Doe",
      "username": "jdoe",
      "state": "active",
      "avatar_url": "https://www.gravatar.com/avatar/0?s=80&d=identicon",
      "web_url": "http://localhost/jdoe"
    },
    {
      "id": 50,
      "name": "Group Member 1",
      "username": "group_member_1",
      "state": "active",
      "avatar_url": "https://www.gravatar.com/avatar/0?s=80&d=identicon",
      "web_url": "http://localhost/group_member_1"
    }
  ],
  "approvals_required": 1,
  "source_rule": null,
  "users": [
    {
      "id": 2,
      "name": "John Doe",
      "username": "jdoe",
      "state": "active",
      "avatar_url": "https://www.gravatar.com/avatar/0?s=80&d=identicon",
      "web_url": "http://localhost/jdoe"
    }
  ],
  "groups": [
    {
      "id": 5,
      "name": "group1",
      "path": "group1",
      "description": "",
      "visibility": "public",
      "lfs_enabled": false,
      "avatar_url": null,
      "web_url": "http://localhost/groups/group1",
      "request_access_enabled": false,
      "full_name": "group1",
      "full_path": "group1",
      "parent_id": null,
      "ldap_cn": null,
      "ldap_access": null
    }
  ],
  "contains_hidden_groups": false,
  "overridden": false
}
```

### 更新合并请求的审批规则

更新指定合并请求的审批规则。此端点会移除未包含在 `group_ids`、`user_ids` 或 `usernames` 属性中的任何审批者和群组。

`report_approver` 或 `code_owner` 规则由系统生成，无法编辑。

```plaintext
PUT /projects/:id/merge_requests/:merge_request_iid/approval_rules/:approval_rule_id
```

支持的属性：

| 属性                    | 类型               | 是否必需 | 描述 |
|------------------------|-------------------|----------|------|
| `id`                   | integer 或 string | 是       | 项目的 ID 或 [URL 编码路径](rest/_index.md#namespaced-paths)。 |
| `approval_rule_id`     | integer           | 是       | 审批规则的 ID。 |
| `merge_request_iid`    | integer           | 是       | 合并请求的 IID。 |
| `approvals_required`   | integer           | 否       | 此规则所需的审批数量。 |
| `group_ids`            | Array             | 否       | 作为审批者的群组 ID。 |
| `name`                 | string            | 否       | 审批规则名称，最多 1024 个字符。 |
| `remove_hidden_groups` | boolean           | 否       | 若为 `true`，移除隐藏群组。 |
| `user_ids`             | Array             | 否       | 作为审批者的用户 ID。若与 `usernames` 同时使用，则合并两个列表。 |
| `usernames`            | string array      | 否       | 审批者的用户名。若与 `user_ids` 同时使用，则合并两个列表。 |

```json
{
  "id": 1,
  "name": "security",
  "rule_type": "regular",
  "eligible_approvers": [
    {
      "id": 2,
      "name": "John Doe",
      "username": "jdoe",
      "state": "active",
      "avatar_url": "https://www.gravatar.com/avatar/0?s=80&d=identicon",
      "web_url": "http://localhost/jdoe"
    },
    {
      "id": 50,
      "name": "Group Member 1",
      "username": "group_member_1",
      "state": "active",
      "avatar_url": "https://www.gravatar.com/avatar/0?s=80&d=identicon",
      "web_url": "http://localhost/group_member_1"
    }
  ],
  "approvals_required": 1,
  "source_rule": null,
  "users": [
    {
      "id": 2,
      "name": "John Doe",
      "username": "jdoe",
      "state": "active",
      "avatar_url": "https://www.gravatar.com/avatar/0?s=80&d=identicon",
      "web_url": "http://localhost/jdoe"
    }
  ],
  "groups": [
    {
      "id": 5,
      "name": "group1",
      "path": "group1",
      "description": "",
      "visibility": "public",
      "lfs_enabled": false,
      "avatar_url": null,
      "web_url": "http://localhost/groups/group1",
      "request_access_enabled": false,
      "full_name": "group1",
      "full_path": "group1",
      "parent_id": null,
      "ldap_cn": null,
      "ldap_access": null
    }
  ],
  "contains_hidden_groups": false,
  "overridden": false
}
```

### 删除合并请求的审批规则

删除指定合并请求的审批规则。

```plaintext
DELETE /projects/:id/merge_requests/:merge_request_iid/approval_rules/:approval_rule_id
```

`report_approver` 或 `code_owner` 规则由系统生成，无法编辑。

支持的属性：

| 属性                 | 类型               | 是否必需 | 描述 |
|---------------------|-------------------|----------|------|
| `id`                | integer 或 string | 是       | 项目的 ID 或 [URL 编码路径](rest/_index.md#namespaced-paths)。 |
| `approval_rule_id`  | integer           | 是       | 审批规则的 ID。 |
| `merge_request_iid` | integer           | 是       | 合并请求的 IID。 |

## 群组审批规则

{{< details >}}

- 状态：实验阶段

{{< /details >}}

{{< history >}}

- 在极狐GitLab 16.7 中引入，带有一个名为 `approval_group_rules` 的功能标志，默认禁用。此功能是实验性的。

{{< /history >}}

> [!flag]
> 在私有化部署的极狐GitLab 上，此功能默认不可用。要使其可用，管理员可以启用名为 `approval_group_rules` 的功能标志。
> 此功能尚未准备好用于生产环境。

群组审批规则适用于该群组中所有项目的所有受保护分支。

### 列出群组的所有审批规则

{{< history >}}

- 在极狐GitLab 16.10 中引入。

{{< /history >}}

列出指定群组的所有审批规则及其相关详情。仅限群组管理员使用。

可以使用 `page` 和 `per_page` [分页参数](rest/_index.md#offset-based-pagination) 来限制审批规则列表。

```plaintext
GET /groups/:id/approval_rules
```

支持的属性：

| 属性     | 类型               | 是否必需 | 描述 |
|----------|-------------------|----------|------|
| `id`     | integer 或 string | 是       | 项目的 ID 或 [URL 编码路径](rest/_index.md#namespaced-paths)。 |

请求示例：

```shell
curl --request GET \
  --header "PRIVATE-TOKEN: <your_access_token>" \
  --url "https://gitlab.example.com/api/v4/groups/29/approval_rules"
```

响应示例：

```json
[
  {
    "id": 2,
    "name": "rule1",
    "rule_type": "any_approver",
    "report_type": null,
    "eligible_approvers": [],
    "approvals_required": 3,
    "users": [],
    "groups": [],
    "contains_hidden_groups": false,
    "protected_branches": [],
    "applies_to_all_protected_branches": true
  },
  {
    "id": 3,
    "name": "rule2",
    "rule_type": "code_owner",
    "report_type": null,
    "eligible_approvers": [],
    "approvals_required": 2,
    "users": [],
    "groups": [],
    "contains_hidden_groups": false,
    "protected_branches": [],
    "applies_to_all_protected_branches": true
  },
  {
    "id": 4,
    "name": "rule2",
    "rule_type": "report_approver",
    "report_type": "code_coverage",
    "eligible_approvers": [],
    "approvals_required": 2,
    "users": [],
    "groups": [],
    "contains_hidden_groups": false,
    "protected_branches": [],
    "applies_to_all_protected_branches": true
  }
]
```

### 为群组创建审批规则

为群组创建审批规则。仅限群组管理员使用。

通过 API 构建审批规则时，请勿使用 `rule_type` 字段。此字段支持以下规则类型：

- `any_approver`：预配置的默认规则，`approvals_required` 设置为 `0`。
- `regular`：用于常规的合并请求审批规则。
- `report_approver`：当极狐GitLab 从配置并启用的合并请求审批策略创建审批规则时使用。

```plaintext
POST /groups/:id/approval_rules
```

支持的属性：

| 属性                  | 类型               | 是否必需 | 描述 |
|----------------------|-------------------|----------|------|
| `id`                 | integer 或 string | 是       | 群组的 ID 或 URL 编码路径。 |
| `approvals_required` | integer           | 是       | 此规则所需的审批数量。 |
| `name`               | string            | 是       | 审批规则名称，最多 1024 个字符。 |
| `group_ids`          | array             | 否       | 作为审批者的群组 ID。 |
| `rule_type`          | string            | 否       | 规则类型。支持的值包括 `any_approver`、`regular` 和 `report_approver`。 |
| `user_ids`           | array             | 否       | 作为审批者的用户 ID。 |

请求示例：

```shell
curl --request POST \
  --header "PRIVATE-TOKEN: <your_access_token>" \
  --url "https://gitlab.example.com/api/v4/groups/29/approval_rules?name=security&approvals_required=2"
```

响应示例：

```json
{
  "id": 5,
  "name": "security",
  "rule_type": "any_approver",
  "eligible_approvers": [],
  "approvals_required": 2,
  "users": [],
  "groups": [],
  "contains_hidden_groups": false,
  "protected_branches": [
    {
      "id": 5,
      "name": "master",
      "push_access_levels": [
        {
          "id": 5,
          "access_level": 40,
          "access_level_description": "Maintainers",
          "deploy_key_id": null,
          "user_id": null,
          "group_id": null
        }
      ],
      "merge_access_levels": [
        {
          "id": 5,
          "access_level": 40,
          "access_level_description": "Maintainers",
          "user_id": null,
          "group_id": null
        }
      ],
      "allow_force_push": false,
      "unprotect_access_levels": [],
      "code_owner_approval_required": false,
      "inherited": false
    }
  ],
  "applies_to_all_protected_branches": true
}
```

### 更新群组的审批规则

{{< history >}}

- 在极狐GitLab 16.10 中引入。

{{< /history >}}

更新群组的审批规则。仅限群组管理员使用。

通过 API 构建审批规则时，请勿使用 `rule_type` 字段。此字段支持以下规则类型：

-
- `any_approver`：预配置的默认规则，其 `approvals_required` 设置为 `0`。
- `regular`：用于常规的[合并请求审批规则](../user/project/merge_requests/approvals/rules.md)。
- `report_approver`：当极狐GitLab 根据已配置并启用的[合并请求审批策略](../user/application_security/policies/merge_request_approval_policies.md)创建审批规则时使用。

```shell
PUT /groups/:id/approval_rules/:approval_rule_id
```

支持的属性：

| 属性                  | 类型              | 是否必需 | 描述 |
|----------------------|-------------------|----------|-------------|
| `approval_rule_id`   | 整数           | 是      | 审批规则的 ID。 |
| `id`                 | 整数或字符串 | 是      | 群组的 ID 或 [URL 编码路径](rest/_index.md#namespaced-paths)。 |
| `approvals_required` | 字符串            | 否       | 此规则所需的审批数量。 |
| `group_ids`          | 整数           | 否       | 作为批准人的用户 ID。 |
| `name`               | 字符串            | 否       | 审批规则的名称，限 1024 个字符。 |
| `rule_type`          | 数组             | 否       | 规则类型。支持的值包括 `any_approver`、`regular` 和 `report_approver`。 |
| `user_ids`           | 数组             | 否       | 作为批准人的群组 ID。 |

示例请求：

```shell
curl --request PUT \
  --header "PRIVATE-TOKEN: <your_access_token>" \
  --url "https://gitlab.example.com/api/v4/groups/29/approval_rules/5?name=security2&approvals_required=1"
```

示例响应：

```json
{
  "id": 5,
  "name": "security2",
  "rule_type": "any_approver",
  "eligible_approvers": [],
  "approvals_required": 1,
  "users": [],
  "groups": [],
  "contains_hidden_groups": false,
  "protected_branches": [
    {
      "id": 5,
      "name": "master",
      "push_access_levels": [
        {
          "id": 5,
          "access_level": 40,
          "access_level_description": "维护者",
          "deploy_key_id": null,
          "user_id": null,
          "group_id": null
        }
      ],
      "merge_access_levels": [
        {
          "id": 5,
          "access_level": 40,
          "access_level_description": "维护者",
          "user_id": null,
          "group_id": null
        }
      ],
      "allow_force_push": false,
      "unprotect_access_levels": [],
      "code_owner_approval_required": false,
      "inherited": false
    }
  ],
  "applies_to_all_protected_branches": true
}
```