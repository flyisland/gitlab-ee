---
stage: Create
group: Source Code
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
title: 受保护分支 API
---

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: JihuLab.com，私有化部署

{{< /details >}}

使用此 API 管理[受保护分支](../user/project/repository/branches/protected.md)。

极狐GitLab 专业版和极狐GitLab 旗舰版支持对分支推送进行更精细的保护。管理员可以仅向部署密钥授予修改和推送受保护分支的权限，而不是授予特定用户。

<a id="valid-access-levels"></a>

## 有效访问级别

`ProtectedRefAccess.allowed_access_levels` 方法定义了在推送、合并和取消保护配置中使用的以下访问级别。

- `0`：无访问权限 - 仅对推送和合并访问级别有效。对取消保护访问级别无效。
- `30`：开发者
- `40`：维护者
- `60`：管理员 - 仅对极狐GitLab 私有化部署有效。

除基于角色的访问级别外，您还可以通过以下方式分配访问权限：

- 用户（`user_id`）：对推送、合并和取消保护访问级别有效。
- 群组（`group_id`）：对推送、合并和取消保护访问级别有效。该群组必须对项目具有开发者、维护者或所有者角色。
- 部署密钥（`deploy_key_id`）：仅对推送访问级别有效。

更多信息，请参见[保护代码仓库分支示例](#protect-repository-branches)。

> [!note]
> 为避免永久锁定分支的保护设置，请确保始终至少有一个用户或群组保留该分支的取消保护权限。
> 更多信息，请参见[控制谁可以取消保护分支](../user/project/repository/branches/protected.md#control-who-can-unprotect-branches)。

<a id="list-protected-branches"></a>

## 列出受保护分支

从项目中获取在 UI 中定义的[受保护分支](../user/project/repository/branches/protected.md)列表。如果设置了通配符，则返回通配符，而不是匹配该通配符的分支的确切名称。

```plaintext
GET /projects/:id/protected_branches
```

支持的属性：

| 属性 | 类型              | 必填 | 描述 |
|-----------|-------------------|----------|-------------|
| `id`      | integer or string | 是      | 项目的 ID 或 [URL 编码路径](rest/_index.md#namespaced-paths)。 |
| `search`  | string            | 否       | 要搜索的受保护分支的名称或名称的一部分。 |

如果成功，返回 [`200 OK`](rest/troubleshooting.md#status-codes) 和以下响应属性：

| 属性                                        | 类型    | 描述 |
|--------------------------------------------------|---------|-------------|
| `allow_force_push`                               | boolean | 如果为 `true`，则允许对该分支进行强制推送。 |
| `code_owner_approval_required`                   | boolean | 如果为 `true`，则推送到该分支需要代码所有者审批。 |
| `id`                                             | integer | 受保护分支的 ID。 |
| `inherited`                                      | boolean | 如果为 `true`，则保护设置继承自父群组。仅限专业版和旗舰版。 |
| `merge_access_levels`                            | array   | 合并访问级别配置的数组。 |
| `merge_access_levels[].access_level`             | integer | 合并的访问级别。 |
| `merge_access_levels[].access_level_description` | string  | 访问级别的可读描述。 |
| `merge_access_levels[].group_id`                 | integer | 具有合并访问权限的群组的 ID。仅限专业版和旗舰版。 |
| `merge_access_levels[].id`                       | integer | 合并访问级别配置的 ID。 |
| `merge_access_levels[].member_role_id`           | integer | 具有合并访问权限的自定义成员角色的 ID。仅限旗舰版。 |
| `merge_access_levels[].user_id`                  | integer | 具有合并访问权限的用户的 ID。仅限专业版和旗舰版。 |
| `name`                                           | string  | 受保护分支的名称。 |
| `push_access_levels`                             | array   | 推送访问级别配置的数组。 |
| `push_access_levels[].access_level`              | integer | 推送的访问级别。 |
| `push_access_levels[].access_level_description`  | string  | 访问级别的可读描述。 |
| `push_access_levels[].deploy_key_id`             | integer | 具有推送访问权限的部署密钥的 ID。 |
| `push_access_levels[].group_id`                  | integer | 具有推送访问权限的群组的 ID。仅限专业版和旗舰版。 |
| `push_access_levels[].id`                        | integer | 推送访问级别配置的 ID。 |
| `push_access_levels[].member_role_id`            | integer | 具有推送访问权限的自定义成员角色的 ID。仅限旗舰版。 |
| `push_access_levels[].user_id`                   | integer | 具有推送访问权限的用户的 ID。仅限专业版和旗舰版。 |

在以下示例请求中，项目 ID 为 `5`。

```shell
curl --header "PRIVATE-TOKEN: <your_access_token>" \
  --url "https://gitlab.example.com/api/v4/projects/5/protected_branches"
```

以下示例响应包括：

- 两个受保护分支，ID 分别为 `100` 和 `101`。
- `push_access_levels`，ID 分别为 `1001`、`1002` 和 `1003`。
- `merge_access_levels`，ID 分别为 `2001` 和 `2002`。

```json
[
  {
    "id": 100,
    "name": "main",
    "push_access_levels": [
      {
        "id":  1001,
        "access_level": 40,
        "access_level_description": "Maintainers"
      },
      {
        "id": 1002,
        "access_level": 40,
        "access_level_description": "Deploy key",
        "deploy_key_id": 1
      }
    ],
    "merge_access_levels": [
      {
        "id":  2001,
        "access_level": 40,
        "access_level_description": "Maintainers"
      }
    ],
    "allow_force_push":false,
    "code_owner_approval_required": false
  },
  {
    "id": 101,
    "name": "release/*",
    "push_access_levels": [
      {
        "id":  1003,
        "access_level": 40,
        "access_level_description": "Maintainers"
      }
    ],
    "merge_access_levels": [
      {
        "id":  2002,
        "access_level": 40,
        "access_level_description": "Maintainers"
      }
    ],
    "allow_force_push":false,
    "code_owner_approval_required": false
  }
]
```

极狐GitLab 专业版或旗舰版上的用户还可以看到 `user_id`、`group_id` 和 `inherited` 参数。如果存在 `inherited` 参数，则该设置继承自项目所属的群组。

以下示例响应包括：

- 一个受保护分支，ID 为 `100`。
- `push_access_levels`，ID 分别为 `1001` 和 `1002`。
- `merge_access_levels`，ID 为 `2001`。

```json
[
  {
    "id": 101,
    "name": "main",
    "push_access_levels": [
      {
        "id":  1001,
        "access_level": 40,
        "user_id": null,
        "group_id": null,
        "access_level_description": "Maintainers"
      },
      {
        "id": 1002,
        "access_level": 40,
        "access_level_description": "Deploy key",
        "deploy_key_id": 1,
        "user_id": null,
        "group_id": null
      }
    ],
    "merge_access_levels": [
      {
        "id":  2001,
        "access_level": null,
        "user_id": null,
        "group_id": 1234,
        "access_level_description": "Example Merge Group"
      }
    ],
    "allow_force_push":false,
    "code_owner_approval_required": false,
    "inherited": true
  }
]
```

<a id="retrieve-a-protected-branch-or-wildcard-protected-branch"></a>

## 获取受保护分支或通配符受保护分支

获取指定的受保护分支或通配符受保护分支。

```plaintext
GET /projects/:id/protected_branches/:name
```

支持的属性：

| 属性 | 类型              | 必填 | 描述 |
|-----------|-------------------|----------|-------------|
| `id`      | integer or string | 是      | 项目的 ID 或 [URL 编码路径](rest/_index.md#namespaced-paths)。 |
| `name`    | string            | 是      | 分支或通配符的名称。 |

如果成功，返回 [`200 OK`](rest/troubleshooting.md#status-codes) 和以下响应属性：

| 属性                                        | 类型    | 描述 |
|--------------------------------------------------|---------|-------------|
| `allow_force_push`                               | boolean | 如果为 `true`，则允许对该分支进行强制推送。 |
| `code_owner_approval_required`                   | boolean | 如果为 `true`，则推送到该分支需要代码所有者审批。 |
| `id`                                             | integer | 受保护分支的 ID。 |
| `merge_access_levels`                            | array   | 合并访问级别配置的数组。 |
| `merge_access_levels[].access_level`             | integer | 合并的访问级别。 |
| `merge_access_levels[].access_level_description` | string  | 访问级别的可读描述。 |
| `merge_access_levels[].group_id`                 | integer | 具有合并访问权限的群组的 ID。仅限专业版和旗舰版。 |
| `merge_access_levels[].id`                       | integer | 合并访问级别配置的 ID。 |
| `merge_access_levels[].member_role_id`           | integer | 具有合并访问权限的自定义成员角色的 ID。仅限旗舰版。 |
| `merge_access_levels[].user_id`                  | integer | 具有合并访问权限的用户的 ID。仅限专业版和旗舰版。 |
| `name`                                           | string  | 受保护分支的名称。 |
| `push_access_levels`                             | array   | 推送访问级别配置的数组。 |
| `push_access_levels[].access_level`              | integer | 推送的访问级别。 |
| `push_access_levels[].access_level_description`  | string  | 访问级别的可读描述。 |
| `push_access_levels[].group_id`                  | integer | 具有推送访问权限的群组的 ID。仅限专业版和旗舰版。 |
| `push_access_levels[].id`                        | integer | 推送访问级别配置的 ID。 |
| `push_access_levels[].member_role_id`            | integer | 具有推送访问权限的自定义成员角色的 ID。仅限旗舰版。 |
| `push_access_levels[].user_id`                   | integer | 具有推送访问权限的用户的 ID。仅限专业版和旗舰版。 |

在以下示例请求中，项目 ID 为 `5`，分支名称为 `main`：

```shell
curl --header "PRIVATE-TOKEN: <your_access_token>" \
  --url "https://gitlab.example.com/api/v4/projects/5/protected_branches/main"
```

示例响应：

```json
{
  "id": 101,
  "name": "main",
  "push_access_levels": [
    {
      "id":  1001,
      "access_level": 40,
      "access_level_description": "Maintainers"
    }
  ],
  "merge_access_levels": [
    {
      "id":  2001,
      "access_level": 40,
      "access_level_description": "Maintainers"
    }
  ],
  "allow_force_push":false,
  "code_owner_approval_required": false
}
```

极狐GitLab 专业版或旗舰版上的用户还可以看到 `user_id` 和 `group_id` 参数。

示例响应：

```json
{
  "id": 101,
  "name": "main",
  "push_access_levels": [
    {
      "id":  1001,
      "access_level": 40,
      "user_id": null,
      "group_id": null,
      "access_level_description": "Maintainers"
    }
  ],
  "merge_access_levels": [
    {
      "id":  2001,
      "access_level": null,
      "user_id": null,
      "group_id": 1234,
      "access_level_description": "Example Merge Group"
    }
  ],
  "allow_force_push":false,
  "code_owner_approval_required": false
}
```

<a id="protect-repository-branches"></a>

## 保护代码仓库分支

保护单个代码仓库分支，或使用通配符受保护分支保护多个项目代码仓库分支。

```plaintext
POST /projects/:id/protected_branches
```

支持的属性：

| 属性                      | 类型              | 必填 | 描述 |
|--------------------------------|-------------------|----------|-------------|
| `id`                           | integer or string | 是      | 项目的 ID 或 [URL 编码路径](rest/_index.md#namespaced-paths)。 |
| `name`                         | string            | 是      | 分支或通配符的名称。 |
| `allow_force_push`             | boolean           | 否       | 如果为 `true`，则能够推送到该分支的成员也可以强制推送。默认为 `false`。 |
| `allowed_to_merge`             | array             | 否       | 合并访问级别的数组，每个访问级别由以下形式的哈希描述：`{user_id: integer}`、`{group_id: integer}`、`{member_role_id: integer}` 或 `{access_level: integer}`。`user_id`、`group_id` 和 `access_level` 仅限专业版和旗舰版。`member_role_id` 仅限旗舰版。 |
| `allowed_to_push`              | array             | 否       | 推送访问级别的数组，每个访问级别由以下形式的哈希描述：`{user_id: integer}`、`{group_id: integer}`、`{member_role_id: integer}`、`{deploy_key_id: integer}` 或 `{access_level: integer}`。`user_id`、`group_id` 和 `access_level` 仅限专业版和旗舰版。`member_role_id` 仅限旗舰版。 |
| `allowed_to_unprotect`         | array             | 否       | 取消保护访问级别的数组，每个访问级别由以下形式的哈希描述：`{user_id: integer}`、`{group_id: integer}`、`{member_role_id: integer}` 或 `{access_level: integer}`。`user_id`、`group_id` 和 `access_level` 仅限专业版和旗舰版。`member_role_id` 仅限旗舰版。此字段不支持访问级别 `No access`。 |
| `code_owner_approval_required` | boolean           | 否       | 如果为 `true`，则当推送目标分支与 [`CODEOWNERS` 文件](../user/project/codeowners/_index.md)中的条目匹配时，阻止推送到该分支。默认为 `false`。仅限专业版和旗舰版。 |
| `merge_access_level`           | integer           | 否       | 允许合并的访问级别。默认为 `40`（维护者角色）。 |
| `push_access_level`            | integer           | 否       | 允许推送的访问级别。默认为 `40`（维护者角色）。 |
| `unprotect_access_level`       | integer           | 否       | 允许取消保护的访问级别。默认为 `40`（维护者角色）。`0`（无访问权限）无效。 |

配置访问级别时：

- 您可以同时为 `allowed_to_push` 和 `allowed_to_merge` 设置多个访问级别。
- 最宽松的访问级别决定谁可以执行该操作。
- 不要在 `allowed_to_push`、`allowed_to_merge` 或 `allowed_to_unprotect` 数组中包含 `id`。
  `id` 字段用于标识现有的访问级别记录，仅在您[更新受保护分支](#update-a-protected-branch)时有效。如果您包含的 `id` 与现有记录不匹配，API 会返回 `404 Not Found`。

此行为与 UI 不同，UI 在您选择**无人**（`access_level: 0`）时会自动清除其他角色选择。

如果成功，返回 [`201 Created`](rest/troubleshooting.md#status-codes) 和以下响应属性：

| 属性                                            | 类型    | 描述 |
|------------------------------------------------------|---------|-------------|
| `allow_force_push`                                   | boolean | 如果为 `true`，则允许对该分支进行强制推送。 |
| `code_owner_approval_required`                       | boolean | 如果为 `true`，则推送到该分支需要代码所有者审批。 |
| `id`                                                 | integer | 受保护分支的 ID。 |
| `merge_access_levels`                                | array   | 合并访问级别配置的数组。 |
| `merge_access_levels[].access_level`                 | integer | 合并的访问级别。 |
| `merge_access_levels[].access_level_description`     | string  | 访问级别的可读描述。 |
| `merge_access_levels[].group_id`                     | integer | 具有合并访问权限的群组的 ID。仅限专业版和旗舰版。 |
| `merge_access_levels[].id`                           | integer | 合并访问级别配置的 ID。 |
| `merge_access_levels[].member_role_id`               | integer | 具有合并访问权限的自定义成员角色的 ID。仅限旗舰版。 |
| `merge_access_levels[].user_id`                      | integer | 具有合并访问权限的用户的 ID。仅限专业版和旗舰版。 |
| `name`                                               | string  | 受保护分支的名称。 |
| `push_access_levels`                                 | array   | 推送访问级别配置的数组。 |
| `push_access_levels[].access_level`                  | integer | 推送的访问级别。 |
| `push_access_levels[].access_level_description`      | string  | 访问级别的可读描述。 |
| `push_access_levels[].deploy_key_id`                 | integer | 具有推送访问权限的部署密钥的 ID。 |
| `push_access_levels[].group_id`                      | integer | 具有推送访问权限的群组的 ID。仅限专业版和旗舰版。 |
| `push_access_levels[].id`                            | integer | 推送访问级别配置的 ID。 |
| `push_access_levels[].member_role_id`                | integer | 具有推送访问权限的自定义成员角色的 ID。仅限旗舰版。 |
| `push_access_levels[].user_id`                       | integer | 具有推送访问权限的用户的 ID。仅限专业版和旗舰版。 |
| `unprotect_access_levels`                            | array   | 取消保护访问级别配置的数组。 |
| `unprotect_access_levels[].access_level`             | integer | 取消保护的访问级别。 |
| `unprotect_access_levels[].access_level_description` | string  | 访问级别的可读描述。 |
| `unprotect_access_levels[].group_id`                 | integer | 具有取消保护访问权限的群组的 ID。仅限专业版和旗舰版。 |
| `unprotect_access_levels[].id`                       | integer | 取消保护访问级别配置的 ID。 |
| `unprotect_access_levels[].member_role_id`           | integer | 具有取消保护访问权限的自定义成员角色的 ID。仅限旗舰版。 |
| `unprotect_access_levels[].user_id`                  | integer | 具有取消保护访问权限的用户的 ID。仅限专业版和旗舰版。 |

在以下示例请求中，项目 ID 为 `5`，分支名称为 `*-stable`。

```shell
curl --request POST \
  --header "PRIVATE-TOKEN: <your_access_token>" \
  --url "https://gitlab.example.com/api/v4/projects/5/protected_branches?name=*-stable&push_access_level=30&merge_access_level=30&unprotect_access_level=40"
```

示例响应包括：

- 一个受保护分支，ID 为 `101`。
- `push_access_levels`，ID 为 `1001`。
- `merge_access_levels`，ID 为 `2001`。
- `unprotect_access_levels`，ID 为 `3001`。

```json
{
  "id": 101,
  "name": "*-stable",
  "push_access_levels": [
    {
      "id":  1001,
      "access_level": 30,
      "access_level_description": "Developers + Maintainers"
    }
  ],
  "merge_access_levels": [
    {
      "id":  2001,
      "access_level": 30,
      "access_level_description": "Developers + Maintainers"
    }
  ],
  "unprotect_access_levels": [
    {
      "id":  3001,
      "access_level": 40,
      "access_level_description": "Maintainers"
    }
  ],
  "allow_force_push":false,
  "code_owner_approval_required": false
}
```

极狐GitLab 专业版或旗舰版上的用户还可以看到 `user_id` 和 `group_id` 参数：

以下示例响应包括：

- 一个受保护分支，ID 为 `101`。
- `push_access_levels`，ID 为 `1001`。
- `merge_access_levels`，ID 为 `2001`。
- `unprotect_access_levels`，ID 为 `3001`。

```json
{
  "id": 1,
  "name": "*-stable",
  "push_access_levels": [
    {
      "id":  1001,
      "access_level": 30,
      "user_id": null,
      "group_id": null,
      "access_level_description": "Developers + Maintainers"
    }
  ],
  "merge_access_levels": [
    {
      "id":  2001,
      "access_level": 30,
      "user_id": null,
      "group_id": null,
      "access_level_description": "Developers + Maintainers"
    }
  ],
  "unprotect_access_levels": [
    {
      "id":  3001,
      "access_level": 40,
      "user_id": null,
      "group_id": null,
      "access_level_description": "Maintainers"
    }
  ],
  "allow_force_push":false,
  "code_owner_approval_required": false
}
```

<a id="example-with-user-push-access-and-group-merge-access"></a>

### 用户推送访问和群组合并访问示例

{{< details >}}

- Tier: 专业版，旗舰版
- Offering: JihuLab.com，私有化部署

{{< /details >}}

`allowed_to_push` / `allowed_to_merge` / `allowed_to_unprotect` 数组中的元素应采用 `{user_id: integer}`、`{group_id: integer}` 或 `{access_level: integer}` 的形式。每个用户都必须具有该项目的访问权限，每个群组都必须[已共享此项目](../user/project/members/sharing_projects_groups.md)。这些访问级别允许对受保护分支访问进行更精细的控制。更多信息，请参见[配置群组权限](../user/project/repository/branches/protected.md#with-group-permissions)。

以下示例请求创建了一个具有用户推送访问权限和群组合并访问权限的受保护分支。`user_id` 为 `2`，`group_id` 为 `3`。

```shell
curl --request POST \
  --header "PRIVATE-TOKEN: <your_access_token>" \
  --url "https://gitlab.example.com/api/v4/projects/5/protected_branches?name=*-stable&allowed_to_push%5B%5D%5Buser_id%5D=2&allowed_to_merge%5B%5D%5Bgroup_id%5D=3"
```

以下示例响应包括：

- 一个受保护分支，ID 为 `101`。
- `push_access_levels`，ID 为 `1001`。
- `merge_access_levels`，ID 为 `2001`。
- `unprotect_access_levels`，ID 为 `3001`。

```json
{
  "id": 101,
  "name": "*-stable",
  "push_access_levels": [
    {
      "id":  1001,
      "access_level": null,
      "user_id": 2,
      "group_id": null,
      "access_level_description": "Administrator"
    }
  ],
  "merge_access_levels": [
    {
      "id":  2001,
      "access_level": null,
      "user_id": null,
      "group_id": 3,
      "access_level_description": "Example Merge Group"
    }
  ],
  "unprotect_access_levels": [
    {
      "id":  3001,
      "access_level": 40,
      "user_id": null,
      "group_id": null,
      "access_level_description": "Maintainers"
    }
  ],
  "allow_force_push":false,
  "code_owner_approval_required": false
}
```

<a id="example-with-deploy-key-access"></a>

### 部署密钥访问示例

`allowed_to_push` 数组中的元素应采用 `{user_id: integer}`、`{group_id: integer}`、`{deploy_key_id: integer}` 或 `{access_level: integer}` 的形式。部署密钥必须为您的项目启用，并且必须对您的项目代码仓库具有写入权限。其他要求，请参见[允许部署密钥推送到受保护分支](../user/project/repository/branches/protected.md#enable-deploy-key-access)。

示例请求：

```shell
curl --request POST \
  --header "PRIVATE-TOKEN: <your_access_token>" \
  --url "https://gitlab.example.com/api/v4/projects/5/protected_branches?name=*-stable&allowed_to_push[][deploy_key_id]=1"
```

以下示例响应包括：

- 一个受保护分支，ID 为 `101`。
- `push_access_levels`，ID 为 `1001`。
- `merge_access_levels`，ID 为 `2001`。
- `unprotect_access_levels`，ID 为 `3001`。

```json
{
  "id": 101,
  "name": "*-stable",
  "push_access_levels": [
    {
      "id":  1001,
      "access_level": null,
      "user_id": null,
      "group_id": null,
      "deploy_key_id": 1,
      "access_level_description": "Deploy"
    }
  ],
  "merge_access_levels": [
    {
      "id":  2001,
      "access_level": 40,
      "user_id": null,
      "group_id": null,
      "access_level_description": "Maintainers"
    }
  ],
  "unprotect_access_levels": [
    {
      "id":  3001,
      "access_level": 40,
      "user_id": null,
      "group_id": null,
      "access_level_description": "Maintainers"
    }
  ],
  "allow_force_push":false,
  "code_owner_approval_required": false
}
```

<a id="example-with-allow-to-push-and-allow-to-merge-access"></a>

### 允许推送和允许合并访问示例

{{< details >}}

- Tier: 专业版，旗舰版
- Offering: JihuLab.com，私有化部署

{{< /details >}}

示例请求：

```shell
curl --request POST \
  --header "PRIVATE-TOKEN: <your_access_token>" \
  --header "Content-Type: application/json" \
  --data '{
    "name": "main",
    "allowed_to_push": [
      {"access_level": 30}
    ],
    "allowed_to_merge": [
      {"access_level": 30},
      {"access_level": 40}
    ]
  }' \
  --url "https://gitlab.example.com/api/v4/projects/5/protected_branches"
```

以下示例响应包括：

- 一个受保护分支，ID 为 `105`。
- `push_access_levels`，ID 为 `1001`。
- `merge_access_levels`，ID 分别为 `2001` 和 `2002`。
- `unprotect_access_levels`，ID 为 `3001`。

```json
{
    "id": 105,
    "name": "main",
    "push_access_levels": [
        {
            "id": 1001,
            "access_level": 30,
            "access_level_description": "Developers + Maintainers",
            "user_id": null,
            "group_id": null
        }
    ],
    "merge_access_levels": [
        {
            "id": 2001,
            "access_level": 30,
            "access_level_description": "Developers + Maintainers",
            "user_id": null,
            "group_id": null
        },
        {
            "id": 2002,
            "access_level": 40,
            "access_level_description": "Maintainers",
            "user_id": null,
            "group_id": null
        }
    ],
    "unprotect_access_levels": [
        {
            "id": 3001,
            "access_level": 40,
            "access_level_description": "Maintainers",
            "user_id": null,
            "group_id": null
        }
    ],
    "allow_force_push":false,
    "code_owner_approval_required": false
}
```

<a id="examples-with-unprotect-access-levels"></a>

### 取消保护访问级别示例

{{< details >}}

- Tier: 专业版，旗舰版
- Offering: JihuLab.com，私有化部署

{{< /details >}}

要创建仅特定群组可以取消保护分支的受保护分支：

```shell
curl --request POST \
  --header "PRIVATE-TOKEN: <your_access_token>" \
  --header "Content-Type: application/json" \
  --data '{
    "name": "production",
    "allowed_to_unprotect": [
      {"group_id": 789}
    ]
  }' \
  --url "https://gitlab.example.com/api/v4/projects/5/protected_branches"
```

要允许多种类型的用户取消保护分支：

```shell
curl --request POST \
  --header "PRIVATE-TOKEN: <your_access_token>" \
  --header "Content-Type: application/json" \
  --data '{
    "name": "main",
    "allowed_to_unprotect": [
      {"user_id": 123},
      {"group_id": 456},
      {"access_level": 40}
    ]
  }' \
  --url "https://gitlab.example.com/api/v4/projects/5/protected_branches"
```

此配置允许以下用户取消保护分支：

- ID 为 `123`的用户。
- ID 为 `456`的群组的成员。
- 具有维护者或所有者角色的用户（访问级别 40）。

<a id="unprotect-repository-branches"></a>

## 取消保护代码仓库分支

取消保护指定的受保护分支或通配符受保护分支。

```plaintext
DELETE /projects/:id/protected_branches/:name
```

支持的属性：

| 属性 | 类型              | 必填 | 描述 |
|-----------|-------------------|----------|-------------|
| `id`      | integer or string | 是      | 项目的 ID 或 [URL 编码路径](rest/_index.md#namespaced-paths)。 |
| `name`    | string            | 是      | 分支的名称。 |

如果成功，返回 [`204 No Content`](rest/troubleshooting.md#status-codes)。

在以下示例请求中，项目 ID 为 `5`，分支名称为 `*-stable`：

```shell
curl --request DELETE \
  --header "PRIVATE-TOKEN: <your_access_token>" \
  --url "https://gitlab.example.com/api/v4/projects/5/protected_branches/*-stable"
```

<a id="update-a-protected-branch"></a>

## 更新受保护分支

更新受保护分支。

```plaintext
PATCH /projects/:id/protected_branches/:name
```

支持的属性：

| 属性                      | 类型              | 必填 | 描述 |
|--------------------------------|-------------------|----------|-------------|
| `id`                           | integer or string | 是      | 项目的 ID 或 [URL 编码路径](rest/_index.md#namespaced-paths)。 |
| `name`                         | string            | 是      | 分支或通配符的名称。 |
| `allow_force_push`             | boolean           | 否       | 如果为 `true`，则能够推送到该分支的成员也可以强制推送。 |
| `allowed_to_merge`             | array             | 否       | 合并访问级别的数组，每个访问级别由以下形式的哈希描述：`{user_id: integer}`、`{group_id: integer}`、`{member_role_id: integer}` 或 `{access_level: integer}`。`user_id`、`group_id` 和 `access_level` 仅限专业版和旗舰版。`member_role_id` 仅限旗舰版。 |
| `allowed_to_push`              | array             | 否       | 推送访问级别的数组，每个访问级别由以下形式的哈希描述：`{user_id: integer}`、`{group_id: integer}`、`{member_role_id: integer}`、`{deploy_key_id: integer}` 或 `{access_level: integer}`。`user_id`、`group_id` 和 `access_level` 仅限专业版和旗舰版。`member_role_id` 仅限旗舰版。 |
| `allowed_to_unprotect`         | array             | 否       | 取消保护访问级别的数组，每个访问级别由以下形式的哈希描述：`{user_id: integer}`、`{group_id: integer}`、`{member_role_id: integer}`、`{access_level: integer}`，或使用 `{id: integer, _destroy: true}` 销毁现有访问级别。`user_id`、`group_id` 和 `access_level` 仅限专业版和旗舰版。`member_role_id` 仅限旗舰版。此字段不支持访问级别 `No access`。 |
| `code_owner_approval_required` | boolean           | 否       | 如果为 `true`，则当推送目标分支与 [`CODEOWNERS` 文件](../user/project/codeowners/_index.md)中的条目匹配时，阻止推送到该分支。仅限专业版和旗舰版。 |

有关设置多个值时访问级别如何相互作用的信息，请参见[保护代码仓库分支](#protect-repository-branches)。

如果成功，返回 [`200 OK`](rest/troubleshooting.md#status-codes) 和以下响应属性：

| 属性                                            | 类型    | 描述 |
|------------------------------------------------------|---------|-------------|
| `allow_force_push`                                   | boolean | 如果为 `true`，则允许对该分支进行强制推送。 |
| `code_owner_approval_required`                       | boolean | 如果为 `true`，则推送到该分支需要代码所有者审批。 |
| `id`                                                 | integer | 受保护分支的 ID。 |
| `merge_access_levels`                                | array   | 合并访问级别配置的数组。 |
| `merge_access_levels[].access_level`                 | integer | 合并的访问级别。 |
| `merge_access_levels[].access_level_description`     | string  | 访问级别的可读描述。 |
| `merge_access_levels[].group_id`                     | integer | 具有合并访问权限的群组的 ID。仅限专业版和旗舰版。 |
| `merge_access_levels[].id`                           | integer | 合并访问级别配置的 ID。 |
| `merge_access_levels[].member_role_id`               | integer | 具有合并访问权限的自定义成员角色的 ID。仅限旗舰版。 |
| `merge_access_levels[].user_id`                      | integer | 具有合并访问权限的用户的 ID。仅限专业版和旗舰版。 |
| `name`                                               | string  | 受保护分支的名称。 |
| `push_access_levels`                                 | array   | 推送访问级别配置的数组。 |
| `push_access_levels[].access_level`                  | integer | 推送的访问级别。 |
| `push_access_levels[].access_level_description`      | string  | 访问级别的可读描述。 |
| `push_access_levels[].deploy_key_id`                 | integer | 具有推送访问权限的部署密钥的 ID。 |
| `push_access_levels[].group_id`                      | integer | 具有推送访问权限的群组的 ID。仅限专业版和旗舰版。 |
| `push_access_levels[].id`                            | integer | 推送访问级别配置的 ID。 |
| `push_access_levels[].member_role_id`                | integer | 具有推送访问权限的自定义成员角色的 ID。仅限旗舰版。 |
| `push_access_levels[].user_id`                       | integer | 具有推送访问权限的用户的 ID。仅限专业版和旗舰版。 |
| `unprotect_access_levels`                            | array   | 取消保护访问级别配置的数组。 |
| `unprotect_access_levels[].access_level`             | integer | 取消保护的访问级别。 |
| `unprotect_access_levels[].access_level_description` | string  | 访问级别的可读描述。 |
| `unprotect_access_levels[].group_id`                 | integer | 具有取消保护访问权限的群组的 ID。仅限专业版和旗舰版。 |
| `unprotect_access_levels[].id`                       | integer | 取消保护访问级别配置的 ID。 |
| `unprotect_access_levels[].member_role_id`           | integer | 具有取消保护访问权限的自定义成员角色的 ID。仅限旗舰版。 |
| `unprotect_access_levels[].user_id`                  | integer | 具有取消保护访问权限的用户的 ID。仅限专业版和旗舰版。 |

示例请求：

```shell
curl --request PATCH \
  --header "PRIVATE-TOKEN: <your_access_token>" \
  --url "https://gitlab.example.com/api/v4/projects/5/protected_branches/feature-branch?allow_force_push=true&code_owner_approval_required=true"
```

`allowed_to_push`、`allowed_to_merge` 和 `allowed_to_unprotect` 数组中的元素应为 `user_id`、`group_id`、`member_role_id` 或 `access_level` 之一，并采用 `{user_id: integer}`、`{group_id: integer}`、`{member_role_id: integer}` 或 `{access_level: integer}` 的形式。

`allowed_to_push` 包含一个额外元素 `deploy_key_id`，其形式为 `{deploy_key_id: integer}`。

要更新：

- `user_id`：确保更新后的用户具有该项目的访问权限。在哈希中包含访问级别记录的 `id`。
- `group_id`：确保更新后的群组[已共享此项目](../user/project/members/sharing_projects_groups.md)。在哈希中包含访问级别记录的 `id`。
- `deploy_key_id`：确保部署密钥已为您的项目启用，并且对您的项目代码仓库具有写入权限。

要更新现有访问级别记录上的任何其他字段，请在哈希中包含该记录的 `id`。

要删除，您必须传递设置为 `true`的 `_destroy`。请参见以下示例。

<a id="example-create-a-push_access_level-record"></a>

### 示例：创建 `push_access_level` 记录

```shell
curl --header 'Content-Type: application/json' --request PATCH \
  --data '{"allowed_to_push": [{"access_level": 40}]}' \
  --header "PRIVATE-TOKEN: <your_access_token>" \
  --url "https://gitlab.example.com/api/v4/projects/22034114/protected_branches/main"
```

示例响应：

```json
{
   "name": "main",
   "push_access_levels": [
      {
         "id": 12,
         "access_level": 40,
         "access_level_description": "Maintainers",
         "user_id": null,
         "group_id": null
      }
   ]
}
```

<a id="example-update-a-push_access_level-record"></a>

### 示例：更新 `push_access_level` 记录

```shell
curl --header 'Content-Type: application/json' --request PATCH \
  --data '{"allowed_to_push": [{"id": 12, "access_level": 0}]}' \
  --header "PRIVATE-TOKEN: <your_access_token>" \
  --url "https://gitlab.example.com/api/v4/projects/22034114/protected_branches/main"
```

示例响应：

```json
{
   "name": "main",
   "push_access_levels": [
      {
         "id": 12,
         "access_level": 0,
         "access_level_description": "No One",
         "user_id": null,
         "group_id": null
      }
   ]
}
```

<a id="example-delete-a-push_access_level-record"></a>

### 示例：删除 `push_access_level` 记录

```shell
curl --header 'Content-Type: application/json' --request PATCH \
  --data '{"allowed_to_push": [{"id": 12, "_destroy": true}]}' \
  --header "PRIVATE-TOKEN: <your_access_token>" \
  --url "https://gitlab.example.com/api/v4/projects/22034114/protected_branches/main"
```

示例响应：

```json
{
   "name": "main",
   "push_access_levels": []
}
```

<a id="example-update-an-unprotect_access_level-record"></a>

### 示例：更新 `unprotect_access_level` 记录

先决条件：

- 调用此 API 的用户必须包含在 `allowed_to_unprotect` 配置中。
- 由 `user_id` 指定的用户必须是项目成员。
- 由 `group_id` 指定的群组必须具有该项目的访问权限。

要修改谁可以取消保护现有受保护分支，请包含现有访问级别记录的 `id`。例如：

```shell
curl --request PATCH \
  --header "PRIVATE-TOKEN: <your_access_token>" \
  --header "Content-Type: application/json" \
  --data '{
    "allowed_to_unprotect": [
      {"id": 17486, "user_id": 3791}
    ]
  }' \
  --url "https://gitlab.example.com/api/v4/projects/5/protected_branches/main"
```

要移除特定访问级别，请使用 `_destroy: true`。
