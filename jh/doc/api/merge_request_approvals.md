---
stage: AI Coding
group: Code Review
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
description: 极狐GitLab 中用于合并请求审批的 REST API 文档。
title: 合并请求审批 API
---

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: JihuLab.com，私有化部署

{{< /details >}}

使用此 API 管理[合并请求审批](../user/project/merge_requests/approvals/_index.md)。

所有端点都需要身份验证。

以下端点适用于所有层级，包括基础版：

- [批准合并请求](#approve-merge-request)
- [取消批准合并请求](#unapprove-a-merge-request)
- [重置合并请求的审批](#reset-approvals-for-a-merge-request)
- [检索合并请求的审批状态](#retrieve-approval-state-for-a-merge-request)

所有其他端点都需要专业版或旗舰版，并且每个端点都会显示其层级。

> [!note]
> `merge_request_iid` 和 `id` 路径参数必须各自为单个值。
> 不支持传入多个以空格分隔的值（例如 `451 454 458`），
> 否则会返回 `400 Bad Request`。要对多个合并请求执行操作，
> 请为每个合并请求 IID 发起一次请求。

<a id="approve-merge-request"></a>

## 批准合并请求

批准指定的合并请求。当前通过身份验证的用户必须是[符合条件的审批人](../user/project/merge_requests/approvals/rules.md#eligible-approvers)。

`sha` 参数可确保您批准的是合并请求的当前版本。如果已定义，该值必须与合并请求的 HEAD 提交 SHA 匹配。不匹配会返回 `409 Conflict` 响应。这与[接受合并请求](merge_requests.md#merge-a-merge-request)的行为一致。

```plaintext
POST /projects/:id/merge_requests/:merge_request_iid/approve
```

支持的属性：

| 属性           | 类型              | 是否必需 | 描述 |
|---------------------|-------------------|----------|-------------|
| `id`                | integer or string | 是      | 项目的 ID 或 [URL 编码路径](rest/_index.md#namespaced-paths)。 |
| `approval_password` | string            | 否       | 当前用户的密码。如果项目设置中启用了[**要求用户重新进行身份验证才能批准**](../user/project/merge_requests/approvals/settings.md#require-user-re-authentication-to-approve)，则此属性为必填。如果群组或极狐GitLab 私有化部署实例配置为强制 SAML 身份验证，则始终失败。 |
| `merge_request_iid` | integer           | 是      | 合并请求的 IID。 |
| `sha`               | string            | 否       | 合并请求的 `HEAD`。 |

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

> [!flag]
> 此功能的可用性由功能标志控制。

如果您使用 API 创建并立即批准一个合并请求，您的自动化流程可能会在提交完全处理之前就批准该合并请求。默认情况下，向合并请求添加新提交会[重置所有现有审批](../user/project/merge_requests/approvals/settings.md#remove-all-approvals-when-commits-are-added-to-the-source-branch)。发生这种情况时，合并请求的 **活动**区域会显示如下一系列消息：

- `(botname)` 在 5 分钟前批准了此合并请求
- `(botname)` 在 5 分钟前添加了 1 个提交
- `(botname)` 在 5 分钟前通过推送到分支重置了来自 `(botname)`的审批

为确保自动化审批不会在提交处理完成之前应用，您的自动化流程应添加等待（或 `sleep`）函数，直到：

- `detailed_merge_status` 属性既不处于 `checking` 状态，也不处于 `approvals_syncing` 状态。
- 合并请求差异包含一个不为 NULL 的 `patch_id_sha`。

或者，在创建合并请求后立即批准它时，发送 [`sha` 属性](#approve-merge-request)。极狐GitLab 使用 `sha` 记录已批准的版本，即使此时尚不存在差异，因此后续推送不会重置审批。

<a id="unapprove-a-merge-request"></a>

## 取消批准合并请求

从指定的合并请求中移除当前通过身份验证的用户的审批。

```plaintext
POST /projects/:id/merge_requests/:merge_request_iid/unapprove
```

支持的属性：

| 属性           | 类型              | 是否必需 | 描述 |
|---------------------|-------------------|----------|-------------|
| `id`                | integer or string | 是      | 项目的 ID 或 [URL 编码路径](rest/_index.md#namespaced-paths)。 |
| `merge_request_iid` | integer           | 是      | 合并请求的 IID。 |

<a id="reset-approvals-for-a-merge-request"></a>

## 重置合并请求的审批

重置指定合并请求的所有审批。

仅对拥有有效项目或群组令牌的 [机器人用户](../user/project/settings/project_access_tokens.md#bot-users-for-projects)可用。人类用户会收到 `401 Unauthorized` 响应。

```plaintext
PUT /projects/:id/merge_requests/:merge_request_iid/reset_approvals
```

| 属性           | 类型              | 是否必需 | 描述 |
|---------------------|-------------------|----------|-------------|
| `id`                | integer or string | 是      | 项目的 ID 或 [URL 编码路径](rest/_index.md#namespaced-paths)。 |
| `merge_request_iid` | integer           | 是      | 合并请求的内部 ID。 |

```shell
curl --request PUT \
  --header "PRIVATE-TOKEN: <your_access_token>" \
  --url "https://gitlab.example.com/api/v4/projects/76/merge_requests/1/reset_approvals"
```

<a id="approval-rules-for-projects"></a>

## 项目的审批规则

{{< details >}}

- Tier: 专业版，旗舰版
- Offering: JihuLab.com，私有化部署

{{< /details >}}

这些端点适用于项目及其审批规则。所有端点都需要身份验证。

<a id="retrieve-approval-configuration-for-a-project"></a>

### 检索项目的审批配置

检索项目的审批配置。

```plaintext
GET /projects/:id/approvals
```

支持的属性：

| 属性 | 类型              | 是否必需 | 描述 |
|-----------|-------------------|----------|-------------|
| `id`      | integer or string | 是      | 项目的 ID 或 [URL 编码路径](rest/_index.md#namespaced-paths)。 |

```json
{
  "approvers": [], // Deprecated in GitLab 12.3, always returns empty
  "approver_groups": [], // Deprecated in GitLab 12.3, always returns empty
  "approvals_before_merge": 2, // Deprecated in GitLab 12.3, use Approval Rules instead
  "reset_approvals_on_push": true,
  "selective_code_owner_removals": false,
  "disable_overriding_approvers_per_merge_request": false,
  "merge_requests_author_approval": true,
  "merge_requests_disable_committers_approval": false,
  "require_password_to_approve": true, // Deprecated in 16.9, use require_reauthentication_to_approve instead
  "require_reauthentication_to_approve": true
}
```

<a id="update-approval-configuration-for-a-project"></a>

### 更新项目的审批配置

更新项目的审批配置。当前通过身份验证的用户必须是[符合条件的审批人](../user/project/merge_requests/approvals/rules.md#eligible-approvers)。

```plaintext
POST /projects/:id/approvals
```

支持的属性：

| 属性                                        | 类型              | 是否必需 | 描述 |
|--------------------------------------------------|-------------------|----------|-------------|
| `id`                                             | integer or string | 是      | 项目的 ID 或 [URL 编码路径](rest/_index.md#namespaced-paths)。 |
| `approvals_before_merge` (deprecated)            | integer           | 否       | 合并请求可合并前所需的审批数量。在极狐GitLab 12.3 中[已弃用](https://gitlab.com/gitlab-org/gitlab/-/issues/11132)。请改为[创建审批规则](#create-an-approval-rule-for-a-project)。 <!-- Do not remove line until field is actually removed --> |
| `disable_overriding_approvers_per_merge_request` | boolean           | 否       | 如果为 `true`，则阻止在合并请求中覆盖审批人。 |
| `merge_requests_author_approval`                 | boolean           | 否       | 如果为 `true`，作者可以自行批准自己的合并请求。 |
| `merge_requests_disable_committers_approval`     | boolean           | 否       | 如果为 `true`，在合并请求上提交的用户无法批准它。 |
| `require_password_to_approve` (deprecated)       | boolean           | 否       | 如果为 `true`，则要求审批人在添加审批前使用密码进行身份验证。在极狐GitLab 16.9 中[已弃用](https://gitlab.com/gitlab-org/gitlab/-/issues/431346)。请改用 `require_reauthentication_to_approve`。 |
| `require_reauthentication_to_approve`            | boolean           | 否       | 如果为 `true`，则要求审批人在添加审批前进行身份验证。在极狐GitLab 17.1 中[引入](https://gitlab.com/gitlab-org/gitlab/-/issues/431346)。 |
| `reset_approvals_on_push`                        | boolean           | 否       | 如果为 `true`，推送时会重置审批。 |
| `selective_code_owner_removals`                  | boolean           | 否       | 如果为 `true`，当代码所有者的文件发生变更时，会重置其审批。要使用此字段，`reset_approvals_on_push` 必须为 `false`。 |

```json
{
  "approvals_before_merge": 2, // Use Approval Rules instead
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

列出指定项目的所有审批规则及任何相关详细信息。

```plaintext
GET /projects/:id/approval_rules
```

要限制审批规则列表，请使用 `page` 和 `per_page` [分页](rest/_index.md#offset-based-pagination)参数。

支持的属性：

| 属性 | 类型              | 是否必需 | 描述 |
|-----------|-------------------|----------|-------------|
| `id`      | integer or string | 是      | 项目的 ID 或 [URL 编码路径](rest/_index.md#namespaced-paths)。 |

示例响应：

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

响应中的每个对象都包含一个 `eligible_approvers` 数组。该数组列出了可以批准该规则所适用的合并请求的用户。符合条件的审批人取决于该规则的配置以及项目和群组成员关系。有关更多信息，请参阅[符合条件的审批人](../user/project/merge_requests/approvals/rules.md#eligible-approvers)。

<a id="retrieve-an-approval-rule-for-a-project"></a>

### 检索项目的审批规则

检索项目的指定审批规则的相关信息。

```plaintext
GET /projects/:id/approval_rules/:approval_rule_id
```

支持的属性：

| 属性          | 类型              | 是否必需 | 描述 |
|--------------------|-------------------|----------|-------------|
| `id`               | integer or string | 是      | 项目的 ID 或 [URL 编码路径](rest/_index.md#namespaced-paths)。 |
| `approval_rule_id` | integer           | 是      | 审批规则的 ID。 |

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

- `any_approver`：预配置的默认规则，其 `approvals_required` 设置为 `0`。
- `regular`：用于常规的[合并请求审批规则](../user/project/merge_requests/approvals/rules.md)。
- `report_approver`：当极狐GitLab 根据已配置并启用的
  [合并请求审批策略](../user/application_security/policies/merge_request_approval_policies.md)创建审批规则时使用。
  使用此 API 创建审批规则时，请勿使用此值。

```plaintext
POST /projects/:id/approval_rules
```

支持的属性：

| 属性                           | 类型              | 是否必需 | 描述 |
|-------------------------------------|-------------------|----------|-------------|
| `id`                                | integer or string | 是      | 项目的 ID 或 [URL 编码路径](rest/_index.md#namespaced-paths)。 |
| `approvals_required`                | integer           | 是      | 此规则所需的审批数量。 |
| `name`                              | string            | 是      | 审批规则的名称。限制为 1024 个字符。 |
| `applies_to_all_protected_branches` | boolean           | 否       | 如果为 `true`，则将该规则应用于所有受保护分支，并忽略 `protected_branch_ids` 属性。 |
| `group_ids`                         | Array             | 否       | 作为审批人的群组 ID。 |
| `protected_branch_ids`              | Array             | 否       | 用于限定规则范围的受保护分支 ID。要确定 ID，请使用[列出受保护分支](protected_branches.md#list-protected-branches) API。 |
| `report_type`                       | string            | 否       | 报告类型。当规则类型为 `report_approver` 时为必填。支持的报告类型为 `license_scanning`[（在极狐GitLab 15.9 中已弃用）](../update/deprecations.md#license-check-and-the-policies-tab-on-the-license-compliance-page)和 `code_coverage`。 <!-- Do not remove line until field is actually removed -->  |
| `rule_type`                         | string            | 否       | 规则类型。支持的值包括 `any_approver`、`regular` 和 `report_approver`。 |
| `user_ids`                          | Array             | 否       | 作为审批人的用户 ID。如果与 `usernames` 一起使用，则会添加两个用户列表。 |
| `usernames`                         | string array      | 否       | 审批人的用户名。如果与 `user_ids` 一起使用，则会添加两个用户列表。 |

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

要增加默认的 0 个所需审批人数量：

```shell
curl --request POST \
  --header "PRIVATE-TOKEN: <your_access_token>" \
  --header 'Content-Type: application/json' \
  --data '{"name": "Any name", "rule_type": "any_approver", "approvals_required": 2}' \
  --url "https://gitlab.example.com/api/v4/projects/<project_id>/approval_rules"
```

另一个示例是创建特定于用户的规则：

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

不在 `users` 或 `groups` 参数中的隐藏群组（用户无权查看的私有群组）默认会被保留。要移除它们，请将 `remove_hidden_groups` 设置为 `true`。这可确保用户更新审批规则时不会意外移除隐藏群组。

```plaintext
PUT /projects/:id/approval_rules/:approval_rule_id
```

支持的属性：

| 属性                           | 类型              | 是否必需 | 描述 |
|-------------------------------------|-------------------|----------|-------------|
| `approval_rule_id`                  | integer           | 是      | 审批规则的 ID。 |
| `id`                                | integer or string | 是      | 项目的 ID 或 [URL 编码路径](rest/_index.md#namespaced-paths)。 |
| `applies_to_all_protected_branches` | boolean           | 否       | 如果为 `true`，则将该规则应用于所有受保护分支，并忽略 `protected_branch_ids` 属性。 |
| `approvals_required`                | integer           | 否       | 此规则所需的审批数量。 |
| `group_ids`                         | Array             | 否       | 作为审批人的群组 ID。 |
| `name`                              | string            | 否       | 审批规则的名称。限制为 1024 个字符。 |
| `protected_branch_ids`              | Array             | 否       | 用于限定规则范围的受保护分支 ID。要确定 ID，请使用[列出受保护分支](protected_branches.md#list-protected-branches) API。 |
| `remove_hidden_groups`              | boolean           | 否       | 如果为 `true`，则从审批规则中移除隐藏群组。 |
| `user_ids`                          | Array             | 否       | 作为审批人的用户 ID。如果与 `usernames` 一起使用，则会添加两个用户列表。 |
| `usernames`                         | string array      | 否       | 审批人的用户名。如果与 `user_ids` 一起使用，则会添加两个用户列表。 |

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

<a id="delete-an-approval-rule-for-a-project"></a>

### 删除项目的审批规则

删除指定项目的审批规则。

```plaintext
DELETE /projects/:id/approval_rules/:approval_rule_id
```

支持的属性：

| 属性          | 类型              | 是否必需 | 描述 |
|--------------------|-------------------|----------|-------------|
| `id`               | integer or string | 是      | 项目的 ID 或 [URL 编码路径](rest/_index.md#namespaced-paths)。 |
| `approval_rule_id` | integer           | 是      | 审批规则的 ID。 |

<a id="approval-rules-for-a-merge-request"></a>

## 合并请求的审批规则

这些端点适用于单个合并请求。所有端点都需要身份验证。

<a id="retrieve-approval-state-for-a-merge-request"></a>

### 检索合并请求的审批状态

检索指定合并请求的审批状态。

在响应中，`approved_by` 包含合并请求所有审批人的信息，无论这些审批是否满足任何审批规则。有关合并请求中审批规则的更详细信息，以及收到的审批是否满足这些规则，请参阅 [`/approval_state` 端点](#retrieve-approval-details-for-a-merge-request)。

`approved` 字段反映合并请求是否满足其审批要求，其值取决于所部署的版本：

- 在极狐GitLab 企业版上（包括未使用许可证的情况），当满足已配置的
  审批规则时，`approved` 为 `true`。
  当没有适用的审批规则时，即使 `approved_by` 为空，`approved` 也为 `true`。
- 在极狐GitLab 基础版上，仅当至少存在一个审批时，`approved` 才为 `true`。

```plaintext
GET /projects/:id/merge_requests/:merge_request_iid/approvals
```

支持的属性：

| 属性           | 类型              | 是否必需 | 描述 |
|---------------------|-------------------|----------|-------------|
| `id`                | integer or string | 是      | 项目的 ID 或 [URL 编码路径](rest/_index.md#namespaced-paths)。 |
| `merge_request_iid` | integer           | 是      | 合并请求的 IID。 |

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
  "approved": true,
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

<a id="retrieve-approval-details-for-a-merge-request"></a>

### 检索合并请求的审批详情

{{< details >}}

- Tier: 专业版，旗舰版
- Offering: JihuLab.com，私有化部署

{{< /details >}}

检索指定合并请求的审批详情。

如果用户修改了合并请求的审批规则，响应会包含：

- `approval_rules_overwritten`：如果为 `true`，表示默认审批规则已被修改。
- `approved`：如果为 `true`，表示关联的审批规则已获批准。
- `approved_by`：如果已定义，表示批准关联审批规则的用户的详细信息。
  不匹配任何审批规则的用户不会被返回。要返回所有批准用户，请参阅
  [`/approvals` 端点](#retrieve-approval-state-for-a-merge-request)。

```plaintext
GET /projects/:id/merge_requests/:merge_request_iid/approval_state
```

支持的属性：

| 属性           | 类型              | 是否必需 | 描述 |
|---------------------|-------------------|----------|-------------|
| `id`                | integer or string | 是      | 项目的 ID 或 [URL 编码路径](rest/_index.md#namespaced-paths)。 |
| `merge_request_iid` | integer           | 是      | 合并请求的 IID。 |

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

<a id="list-all-approval-rules-for-a-merge-request"></a>

### 列出合并请求的所有审批规则

{{< details >}}

- Tier: 专业版，旗舰版
- Offering: JihuLab.com，私有化部署

{{< /details >}}

列出指定合并请求的所有审批规则及任何相关详细信息。

使用 `page` 和 `per_page` [分页](rest/_index.md#offset-based-pagination)参数来限制审批规则列表。

```plaintext
GET /projects/:id/merge_requests/:merge_request_iid/approval_rules
```

支持的属性：

| 属性           | 类型              | 是否必需 | 描述 |
|---------------------|-------------------|----------|-------------|
| `id`                | integer or string | 是      | 项目的 ID 或 [URL 编码路径](rest/_index.md#namespaced-paths)。 |
| `merge_request_iid` | integer           | 是      | 合并请求的 IID。 |

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

<a id="retrieve-an-approval-rule-for-a-specific-merge-request"></a>

### 检索特定合并请求的审批规则

{{< details >}}

- Tier: 专业版，旗舰版
- Offering: JihuLab.com，私有化部署

{{< /details >}}

检索特定合并请求的审批规则的相关信息。

```plaintext
GET /projects/:id/merge_requests/:merge_request_iid/approval_rules/:approval_rule_id
```

支持的属性：

| 属性           | 类型              | 是否必需 | 描述 |
|---------------------|-------------------|----------|-------------|
| `id`                | integer or string | 是      | 项目的 ID 或 [URL 编码路径](rest/_index.md#namespaced-paths)。 |
| `approval_rule_id`  | integer           | 是      | 审批规则的 ID。 |
| `merge_request_iid` | integer           | 是      | 合并请求的 IID。 |

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

<a id="create-an-approval-rule-for-a-merge-request"></a>

### 为合并请求创建审批规则

{{< details >}}

- Tier: 专业版，旗舰版
- Offering: JihuLab.com，私有化部署

{{< /details >}}

为特定合并请求创建审批规则。如果 `approval_project_rule_id` 设置为项目中现有审批规则的 ID，此端点会：

- 从项目的规则中复制 `name`、`users` 和 `groups`的值。
- 使用您指定的 `approvals_required` 值。

```plaintext
POST /projects/:id/merge_requests/:merge_request_iid/approval_rules
```

支持的属性：

| 属性                  | 类型              | 是否必需               | 描述                                                                  |
|----------------------------|-------------------|------------------------|------------------------------------------------------------------------------|
| `id`                       | integer or string | 是 | 项目的 ID 或 [URL 编码路径](rest/_index.md#namespaced-paths)。 |
| `approvals_required`       | integer           | 是 | 此规则所需的审批数量。                              |
| `merge_request_iid`        | integer           | 是 | 合并请求的 IID。                                                |
| `name`                     | string            | 是 | 审批规则的名称。限制为 1024 个字符。                                               |
| `approval_project_rule_id` | integer           | 否 | 项目审批规则的 ID。                                     |
| `group_ids`                | Array             | 否 | 作为审批人的群组 ID。                                              |
| `user_ids`                 | Array             | 否 | 作为审批人的用户 ID。如果与 `usernames` 一起使用，则会添加两个用户列表。 |
| `usernames`                | string array      | 否 | 审批人的用户名。如果与 `user_ids` 一起使用，则会添加两个用户列表。 |

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

<a id="update-an-approval-rule-for-a-merge-request"></a>

### 更新合并请求的审批规则

{{< details >}}

- Tier: 专业版，旗舰版
- Offering: JihuLab.com，私有化部署

{{< /details >}}

更新合并请求的指定审批规则。此端点会移除未包含在 `group_ids`、`user_ids` 或 `usernames` 属性中的任何审批人和群组。

`report_approver` 或 `code_owner` 规则由系统生成，您无法编辑它们。

```plaintext
PUT /projects/:id/merge_requests/:merge_request_iid/approval_rules/:approval_rule_id
```

支持的属性：

| 属性              | 类型              | 是否必需 | 描述 |
|------------------------|-------------------|----------|-------------|
| `id`                   | integer or string | 是      | 项目的 ID 或 [URL 编码路径](rest/_index.md#namespaced-paths)。 |
| `approval_rule_id`     | integer           | 是      | 审批规则的 ID。 |
| `merge_request_iid`    | integer           | 是      | 合并请求的 IID。 |
| `approvals_required`   | integer           | 否       | 此规则所需的审批数量。 |
| `group_ids`            | Array             | 否       | 作为审批人的群组 ID。 |
| `name`                 | string            | 否       | 审批规则的名称。限制为 1024 个字符。 |
| `remove_hidden_groups` | boolean           | 否       | 如果为 `true`，则移除隐藏群组。 |
| `user_ids`             | Array             | 否       | 作为审批人的用户 ID。如果与 `usernames` 一起使用，则会添加两个用户列表。 |
| `usernames`            | string array      | 否       | 审批人的用户名。如果与 `user_ids` 一起使用，则会添加两个用户列表。 |

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

<a id="delete-an-approval-rule-for-a-merge-request"></a>

### 删除合并请求的审批规则

{{< details >}}

- Tier: 专业版，旗舰版
- Offering: JihuLab.com，私有化部署

{{< /details >}}

删除指定合并请求的审批规则。

```plaintext
DELETE /projects/:id/merge_requests/:merge_request_iid/approval_rules/:approval_rule_id
```

`report_approver` 或 `code_owner` 规则由系统生成，您无法编辑它们。

支持的属性：

| 属性           | 类型              | 是否必需 | 描述 |
|---------------------|-------------------|----------|-------------|
| `id`                | integer or string | 是      | 项目的 ID 或 [URL 编码路径](rest/_index.md#namespaced-paths)。 |
| `approval_rule_id`  | integer           | 是      | 审批规则的 ID。 |
| `merge_request_iid` | integer           | 是      | 合并请求的 IID。 |

<a id="approval-rules-for-groups"></a>

## 群组的审批规则

{{< details >}}

- Tier: 专业版，旗舰版
- Offering: JihuLab.com，私有化部署
- Status: 实验

{{< /details >}}

> [!flag]
> 在极狐GitLab 私有化部署上，默认情况下此功能不可用。要使其可用，管理员可以[启用功能标志](../administration/feature_flags/_index.md)，名称为 `approval_group_rules`。
> 在 JihuLab.com 上，此功能不可用。
> 此功能尚未准备好用于生产环境。

群组审批规则适用于属于该群组的项目的所有受保护分支。

<a id="list-all-approval-rules-for-a-group"></a>

### 列出群组的所有审批规则

列出指定群组的所有审批规则及任何相关详细信息。仅限群组管理员。

使用 `page` 和 `per_page` [分页](rest/_index.md#offset-based-pagination)参数来限制审批规则列表。

```plaintext
GET /groups/:id/approval_rules
```

支持的属性：

| 属性 | 类型              | 是否必需 | 描述 |
|-----------|-------------------|----------|-------------|
| `id`      | integer or string | 是      | 项目的 ID 或 [URL 编码路径](rest/_index.md#namespaced-paths)。 |

示例请求：

```shell
curl --request GET \
  --header "PRIVATE-TOKEN: <your_access_token>" \
  --url "https://gitlab.example.com/api/v4/groups/29/approval_rules"
```

示例响应：

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

<a id="create-an-approval-rule-for-a-group"></a>

### 为群组创建审批规则

为群组创建审批规则。仅限群组管理员。

通过 API 构建审批规则时，请勿使用 `rule_type` 字段。该字段支持以下规则类型：

- `any_approver`：预配置的默认规则，其 `approvals_required` 设置为 `0`。
- `regular`：用于常规的[合并请求审批规则](../user/project/merge_requests/approvals/rules.md)。
- `report_approver`：当极狐GitLab 根据已配置并启用的
  [合并请求审批策略](../user/application_security/policies/merge_request_approval_policies.md)创建审批规则时使用。

```plaintext
POST /groups/:id/approval_rules
```

支持的属性：

| 属性            | 类型              | 是否必需 | 描述 |
|----------------------|-------------------|----------|-------------|
| `id`                 | integer or string | 是      | 群组的 ID 或 [URL 编码路径](rest/_index.md#namespaced-paths)。 |
| `approvals_required` | integer           | 是      | 此规则所需的审批数量。 |
| `name`               | string            | 是      | 审批规则的名称。限制为 1024 个字符。 |
| `group_ids`          | array             | 否       | 作为审批人的群组 ID。 |
| `rule_type`          | string            | 否       | 规则类型。支持的值包括 `any_approver`、`regular` 和 `report_approver`。 |
| `user_ids`           | array             | 否       | 作为审批人的用户 ID。 |

示例请求：

```shell
curl --request POST \
  --header "PRIVATE-TOKEN: <your_access_token>" \
  --url "https://gitlab.example.com/api/v4/groups/29/approval_rules?name=security&approvals_required=2"
```

示例响应：

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

<a id="update-an-approval-rule-for-a-group"></a>

### 更新群组的审批规则

更新群组的审批规则。仅限群组管理员。

通过 API 构建审批规则时，请勿使用 `rule_type` 字段。该字段支持以下规则类型：

- `any_approver`：预配置的默认规则，其 `approvals_required` 设置为 `0`。
- `regular`：用于常规的[合并请求审批规则](../user/project/merge_requests/approvals/rules.md)。
- `report_approver`：当极狐GitLab 根据已配置并启用的
  [合并请求审批策略](../user/application_security/policies/merge_request_approval_policies.md)创建审批规则时使用。

```shell
PUT /groups/:id/approval_rules/:approval_rule_id
```

支持的属性：

| 属性            | 类型              | 是否必需 | 描述 |
|----------------------|-------------------|----------|-------------|
| `approval_rule_id`   | integer           | 是      | 审批规则的 ID。 |
| `id`                 | integer or string | 是      | 群组的 ID 或 [URL 编码路径](rest/_index.md#namespaced-paths)。 |
| `approvals_required` | string            | 否       | 此规则所需的审批数量。 |
| `group_ids`          | integer           | 否       | 作为审批人的用户 ID。 |
| `name`               | string            | 否       | 审批规则的名称。限制为 1024 个字符。 |
| `rule_type`          | array             | 否       | 规则类型。支持的值包括 `any_approver`、`regular` 和 `report_approver`。 |
| `user_ids`           | array             | 否       | 作为审批人的群组 ID。 |

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
