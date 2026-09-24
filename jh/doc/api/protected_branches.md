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

使用此 API 管理 [受保护分支](../user/project/repository/branches/protected.md)。

极狐GitLab 专业版 和 极狐GitLab 旗舰版 支持更细粒度的分支推送保护。管理员可以仅向部署密钥授予修改和推送到受保护分支的权限，而不是特定用户。

<a id="valid-access-levels"></a>

## 有效的访问级别

`ProtectedRefAccess.allowed_access_levels` 方法定义了在推送、合并和取消保护配置中使用的以下访问级别。

- `0`：无访问权限 - 仅对推送和合并访问级别有效。对取消保护访问级别无效。
- `30`：开发者
- `40`：维护者
- `60`：管理员 - 仅对私有化部署的极狐GitLab 有效。

除了基于角色的访问级别，你还可以通过以下方式分配访问权限：

- 用户 (`user_id`)：对推送、合并和取消保护访问级别有效。
- 群组 (`group_id`)：对推送、合并和取消保护访问级别有效。群组在该项目中必须具有 开发者、维护者 或 所有者 角色。
- 部署密钥 (`deploy_key_id`)：仅对推送访问级别有效。

更多信息，请参阅 [保护仓库分支示例](#protect-repository-branches)。

> [!note]
> 为避免永久锁定分支的保护设置，请确保至少一个用户或群组始终保留该分支的取消保护权限。
> 更多信息，请参阅 [控制谁可以取消保护分支](../user/project/repository/branches/protected.md#control-who-can-unprotect-branches)。

<a id="list-protected-branches"></a>

## 列出受保护分支

{{< history >}}

- 部署密钥信息 在 极狐GitLab 16.0 引入。

{{< /history >}}

从项目中获取 [受保护分支](../user/project/repository/branches/protected.md) 的列表，如 UI 中所定义。如果设置了通配符，则返回通配符而不是与该通配符匹配的分支的确切名称。

```plaintext
GET /projects/:id/protected_branches
```

支持的属性：

| 属性 | 类型 | 是否必需 | 描述 |
|-----------|-------------------|----------|-------------|
| `id` | 整数或字符串 | 是 | 项目的 ID 或 [URL 编码路径](rest/_index.md#namespaced-paths)。 |
| `search` | 字符串 | 否 | 要搜索的受保护分支的名称或名称的一部分。 |

如果成功，返回 [`200 OK`](rest/troubleshooting.md#status-codes) 和以下响应属性：

| 属性 | 类型 | 描述 |
|--------------------------------------------------|---------|-------------|
| `allow_force_push` | 布尔值 | 如果为 `true`，则允许对此分支强制推送。 |
| `code_owner_approval_required` | 布尔值 | 如果为 `true`，则推送到此分支需要代码所有者审批。 |
| `id` | 整数 | 受保护分支的 ID。 |
| `inherited` | 布尔值 | 如果为 `true`，则保护设置继承自父群组。仅专业版和旗舰版可用。 |
| `merge_access_levels` | 数组 | 合并访问级别配置的数组。 |
| `merge_access_levels[].access_level` | 整数 | 合并的访问级别。 |
| `merge_access_levels[].access_level_description` | 字符串 | 访问级别的可读描述。 |
| `merge_access_levels[].group_id` | 整数 | 具有合并访问权限的群组的 ID。仅专业版和旗舰版可用。 |
| `merge_access_levels[].id` | 整数 | 合并访问级别配置的 ID。 |
| `merge_access_levels[].user_id` | 整数 | 具有合并访问权限的用户的 ID。仅专业版和旗舰版可用。 |
| `name` | 字符串 | 受保护分支的名称。 |
| `push_access_levels` | 数组 | 推送访问级别配置的数组。 |
| `push_access_levels[].access_level` | 整数 | 推送的访问级别。 |
| `push_access_levels[].access_level_description` | 字符串 | 访问级别的可读描述。 |
| `push_access_levels[].deploy_key_id` | 整数 | 具有推送访问权限的部署密钥的 ID。 |
| `push_access_levels[].group_id` | 整数 | 具有推送访问权限的群组的 ID。仅专业版和旗舰版可用。 |
| `push_access_levels[].id` | 整数 | 推送访问级别配置的 ID。 |
| `push_access_levels[].user_id` | 整数 | 具有推送访问权限的用户的 ID。仅专业版和旗舰版可用。 |

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

极狐GitLab 专业版 或 极狐GitLab 旗舰版 上的用户还可以看到 `user_id`、`group_id` 和 `inherited` 参数。如果存在 `inherited` 参数，则表示该设置是从项目的群组继承的。

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

| 属性 | 类型 | 是否必需 | 描述 |
|-----------|-------------------|----------|-------------|
| `id` | 整数或字符串 | 是 | 项目的 ID 或 [URL 编码路径](rest/_index.md#namespaced-paths)。 |
| `name` | 字符串 | 是 | 分支或通配符的名称。 |

如果成功，返回 [`200 OK`](rest/troubleshooting.md#status-codes) 和以下响应属性：

| 属性 | 类型 | 描述 |
|--------------------------------------------------|---------|-------------|
| `allow_force_push` | 布尔值 | 如果为 `true`，则允许对此分支强制推送。 |
| `code_owner_approval_required` | 布尔值 | 如果为 `true`，则推送到此分支需要代码所有者审批。 |
| `id` | 整数 | 受保护分支的 ID。 |
| `merge_access_levels` | 数组 | 合并访问级别配置的数组。 |
| `merge_access_levels[].access_level` | 整数 | 合并的访问级别。 |
| `merge_access_levels[].access_level_description` | 字符串 | 访问级别的可读描述。 |
| `merge_access_levels[].group_id` | 整数 | 具有合并访问权限的群组的 ID。仅专业版和旗舰版可用。 |
| `merge_access_levels[].id` | 整数 | 合并访问级别配置的 ID。 |
| `merge_access_levels[].user_id` | 整数 | 具有合并访问权限的用户的 ID。仅专业版和旗舰版可用。 |
| `name` | 字符串 | 受保护分支的名称。 |
| `push_access_levels` | 数组 | 推送访问级别配置的数组。 |
| `push_access_levels[].access_level` | 整数 | 推送的访问级别。 |
| `push_access_levels[].access_level_description` | 字符串 | 访问级别的可读描述。 |
| `push_access_levels[].group_id` | 整数 | 具有推送访问权限的群组的 ID。仅专业版和旗舰版可用。 |
| `push_access_levels[].id` | 整数 | 推送访问级别配置的 ID。 |
| `push_access_levels[].user_id` | 整数 | 具有推送访问权限的用户的 ID。仅专业版和旗舰版可用。 |

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

极狐GitLab 专业版 或 极狐GitLab 旗舰版 上的用户还可以看到 `user_id` 和 `group_id` 参数。

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

## 保护仓库分支

{{< history >}}

- `deploy_key_id` 配置 在 极狐GitLab 17.5 引入。
- `deploy_key_id` 配置 在 极狐GitLab 18.10 中从 极狐GitLab 专业版 移至 极狐GitLab 基础版。

{{< /history >}}

保护单个仓库分支或使用通配符受保护分支保护多个项目仓库分支。

```plaintext
POST /projects/:id/protected_branches
```

支持的属性：

| 属性 | 类型 | 是否必需 | 描述 |
|--------------------------------|-------------------|----------|-------------|
| `id` | 整数或字符串 | 是 | 项目的 ID 或 [URL 编码路径](rest/_index.md#namespaced-paths)。 |
| `name` | 字符串 | 是 | 分支或通配符的名称。 |
| `allow_force_push` | 布尔值 | 否 | 如果为 `true`，可以推送此分支的成员也可以强制推送。默认为 `false`。 |
| `allowed_to_merge` | 数组 | 否 | 合并访问级别数组，每个都由 `{user_id: integer}`、`{group_id: integer}` 或 `{access_level: integer}` 形式的哈希描述。仅专业版和旗舰版可用。 |
| `allowed_to_push` | 数组 | 否 | 推送访问级别数组，每个都由 `{user_id: integer}`、`{group_id: integer}`、`{deploy_key_id: integer}` 或 `{access_level: integer}` 形式的哈希描述。`user_id`、`group_id` 和 `access_level` 仅专业版和旗舰版可用。 |
| `allowed_to_unprotect` | 数组 | 否 | 取消保护访问级别数组，每个都由 `{user_id: integer}`、`{group_id: integer}` 或 `{access_level: integer}` 形式的哈希描述。此字段不支持 `无访问权限` 访问级别。仅专业版和旗舰版可用。 |
| `code_owner_approval_required` | 布尔值 | 否 | 如果为 `true`，当此分支匹配 [`CODEOWNERS` 文件](../user/project/codeowners/_index.md) 中的条目时，将阻止推送。默认为 `false`。仅专业版和旗舰版可用。 |
| `merge_access_level` | 整数 | 否 | 允许合并的访问级别。默认为 `40`（维护者 角色）。 |
| `push_access_level` | 整数 | 否 | 允许推送的访问级别。默认为 `40`（维护者 角色）。 |
| `unprotect_access_level` | 整数 | 否 | 允许取消保护的访问级别。默认为 `40`（维护者 角色）。`0`（无访问权限）无效。 |

配置访问级别时：

- 你可以为 `allowed_to_push` 和 `allowed_to_merge` 同时设置多个访问级别。
- 最宽松的访问级别决定谁可以执行操作。
- 不要在 `allowed_to_push`、`allowed_to_merge` 或 `allowed_to_unprotect` 数组中包含 `id`。
  `id` 字段标识现有的访问级别记录，仅在 [更新受保护分支](#update-a-protected-branch) 时有效。如果包含的 `id` 与现有记录不匹配，API 会返回 `404 Not Found`。

此行为与 UI 不同，UI 在你选择 **无人** (`access_level: 0`) 时会自动清除其他角色选择。

如果成功，返回 [`201 Created`](rest/troubleshooting.md#status-codes) 和以下响应属性：

| 属性 | 类型 | 描述 |
|------------------------------------------------------|---------|-------------|
| `allow_force_push` | 布尔值 | 如果为 `true`，则允许对此分支强制推送。 |
| `code_owner_approval_required` | 布尔值 | 如果为 `true`，则推送到此分支需要代码所有者审批。 |
| `id` | 整数 | 受保护分支的 ID。 |
| `merge_access_levels` | 数组 | 合并访问级别配置的数组。 |
| `merge_access_levels[].access_level` | 整数 | 合并的访问级别。 |
| `merge_access_levels[].access_level_description` | 字符串 | 访问级别的可读描述。 |
| `merge_access_levels[].group_id` | 整数 | 具有合并访问权限的群组的 ID。仅专业版和旗舰版可用。 |
| `merge_access_levels[].id` | 整数 | 合并访问级别配置的 ID。 |
| `merge_access_levels[].user_id` | 整数 | 具有合并访问权限的用户的 ID。仅专业版和旗舰版可用。 |
| `name` | 字符串 | 受保护分支的名称。 |
| `push_access_levels` | 数组 | 推送访问级别配置的数组。 |
| `push_access_levels[].access_level` | 整数 | 推送的访问级别。 |
| `push_access_levels[].access_level_description` | 字符串 | 访问级别的可读描述。 |
| `push_access_levels[].deploy_key_id` | 整数 | 具有推送访问权限的部署密钥的 ID。 |
| `push_access_levels[].group_id` | 整数 | 具有推送访问权限的群组的 ID。仅专业版和旗舰版可用。 |
| `push_access_levels[].id` | 整数 | 推送访问级别配置的 ID。 |
| `push_access_levels[].user_id` | 整数 | 具有推送访问权限的用户的 ID。仅专业版和旗舰版可用。 |
| `unprotect_access_levels` | 数组 | 取消保护访问级别配置的数组。 |
| `unprotect_access_levels[].access_level` | 整数 | 取消保护的访问级别。 |
| `unprotect_access_levels[].access_level_description` | 字符串 | 访问级别的可读描述。 |
| `unprotect_access_levels[].group_id` | 整数 | 具有取消保护访问权限的群组的 ID。仅专业版和旗舰版可用。 |
| `unprotect_access_levels[].id` | 整数 | 取消保护访问级别配置的 ID。 |
| `unprotect_access_levels[].user_id` | 整数 | 具有取消保护访问权限的用户的 ID。仅专业版和旗舰版可用。 |

在以下示例请求中，项目 ID 为 `5`，分支名称为 `*-stable`。

```shell
curl --request POST \
  --header "PRIVATE-TOKEN: <your_access_token>" \
  --url "https://gitlab.example.com/api/v4/projects/5/protected_branches?name=*-stable&push_access_level=30&merge_access_level=30&unprotect_access_level=40"
```

示例响应包括：

- 受保护分支，ID 为 `101`。
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

极狐GitLab 专业版 或 极狐GitLab 旗舰版 上的用户还可以看到 `user_id` 和 `group_id` 参数：

以下示例响应包括：

- 受保护分支，ID 为 `101`。
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

`allowed_to_push` / `allowed_to_merge` / `allowed_to_unprotect` 数组中的元素应采用 `{user_id: integer}`、`{group_id: integer}` 或 `{access_level: integer}` 形式。
每个用户必须有项目的访问权限，每个群组必须 [已共享此项目](../user/project/members/sharing_projects_groups.md)。
这些访问级别可以更精细地控制受保护分支的访问。更多信息，请参阅 [配置群组权限](../user/project/repository/branches/protected.md#with-group-permissions)。

以下示例请求创建了一个具有用户推送访问权限和群组合并访问权限的受保护分支。
`user_id` 为 `2`，`group_id` 为 `3`。

```shell
curl --request POST \
  --header "PRIVATE-TOKEN: <your_access_token>" \
  --url "https://gitlab.example.com/api/v4/projects/5/protected_branches?name=*-stable&allowed_to_push%5B%5D%5Buser_id%5D=2&allowed_to_merge%5B%5D%5Bgroup_id%5D=3"
```

以下示例响应包括：

- 受保护分支，ID 为 `101`。
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

{{< history >}}

- 在 极狐GitLab 17.5 引入。
- 在 极狐GitLab 18.10 中从 极狐GitLab 专业版 移至 极狐GitLab 基础版。

{{< /history >}}

`allowed_to_push` 数组中的元素应采用 `{user_id: integer}`、`{group_id: integer}`、`{deploy_key_id: integer}` 或 `{access_level: integer}` 形式。
该部署密钥必须为你的项目启用，并且必须对你的项目仓库具有写入权限。其他要求，请参阅 [允许部署密钥推送到受保护分支](../user/project/repository/branches/protected.md#enable-deploy-key-access)。

示例请求：

```shell
curl --request POST \
  --header "PRIVATE-TOKEN: <your_access_token>" \
  --url "https://gitlab.example.com/api/v4/projects/5/protected_branches?name=*-stable&allowed_to_push[][deploy_key_id]=1"
```

以下示例响应包括：

- 受保护分支，ID 为 `101`。
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

{{< history >}}

- 在 13.9 移至 极狐GitLab 专业版。

{{< /history >}}

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

- 受保护分支，ID 为 `105`。
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
      "access_level_description": "Developers + Maintainers"
    }
  ],
  "merge_access_levels": [
    {
      "id": 2001,
      "access_level": 30,
      "access_level_description": "Developers + Maintainers"
    },
    {
      "id": 2002,
      "access_level": 40,
      "access_level_description": "Maintainers"
    }
  ],
  "unprotect_access_levels": [
    {
      "id": 3001,
      "access_level": 40,
      "access_level_description": "Maintainers"
    }
  ],
  "allow_force_push": false,
  "code_owner_approval_required": false
}
```
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

### 使用取消保护访问级别的示例

{{< details >}}

- Tier: 专业版，旗舰版
- Offering: JihuLab.com，私有化部署

{{< /details >}}

要创建一个仅特定群组可以取消保护的分支：

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

- 具有 ID `123` 的用户。
- ID `456` 群组的成员。
- 具有维护者或所有者角色的用户（访问级别为 40）。

<a id="unprotect-repository-branches"></a>

## 取消保护仓库分支

取消保护给定的受保护分支或通配符受保护分支。

```plaintext
DELETE /projects/:id/protected_branches/:name
```

支持的属性：

| 属性 | 类型              | 必填 | 描述 |
|-----------|-------------------|----------|-------------|
| `id`      | integer 或 string | 是      | ID 或 [项目的 URL 编码路径](rest/_index.md#namespaced-paths)。 |
| `name`    | string            | 是      | 分支名称。 |

如果成功，返回 [`204 无内容`](rest/troubleshooting.md#status-codes)。

在以下示例请求中，项目 ID 为 `5`，分支名称为 `*-stable`：

```shell
curl --request DELETE \
  --header "PRIVATE-TOKEN: <your_access_token>" \
  --url "https://gitlab.example.com/api/v4/projects/5/protected_branches/*-stable"
```

<a id="update-a-protected-branch"></a>

## 更新受保护分支

{{< history >}}

- `deploy_key_id` 配置在极狐GitLab 17.5 中引入。

{{< /history >}}

更新受保护分支。

```plaintext
PATCH /projects/:id/protected_branches/:name
```

支持的属性：

| 属性                      | 类型              | 必填 | 描述 |
|--------------------------------|-------------------|----------|-------------|
| `id`                           | integer 或 string | 是      | ID 或 [项目的 URL 编码路径](rest/_index.md#namespaced-paths)。 |
| `name`                         | string            | 是      | 分支名称或通配符。 |
| `allow_force_push`             | boolean           | 否       | 如果为 `true`，可以推送至此分支的成员也可以强制推送。 |
| `allowed_to_merge`             | array             | 否       | 合并访问级别数组，每个级别由格式为 `{user_id: integer}`、`{group_id: integer}` 或 `{access_level: integer}` 的哈希描述。仅专业版和旗舰版。 |
| `allowed_to_push`              | array             | 否       | 推送访问级别数组，每个级别由格式为 `{user_id: integer}`、`{group_id: integer}`、`{deploy_key_id: integer}` 或 `{access_level: integer}` 的哈希描述。`user_id`、`group_id` 和 `access_level` 仅专业版和旗舰版。 |
| `allowed_to_unprotect`         | array             | 否       | 取消保护访问级别数组，每个级别由格式为 `{user_id: integer}`、`{group_id: integer}`、`{access_level: integer}` 或 `{id: integer, _destroy: true}`（用于删除现有访问级别）的哈希描述。此字段不支持 `无访问权限` 访问级别。仅专业版和旗舰版。 |
| `code_owner_approval_required` | boolean           | 否       | 如果为 `true`，当分支与 [`CODEOWNERS` 文件](../user/project/codeowners/_index.md) 中的条目匹配时，阻止推送至此分支。仅专业版和旗舰版。 |

有关设置多个值时的访问级别交互方式的信息，请参见 [保护仓库分支](#protect-repository-branches)。

如果成功，返回 [`200 OK`](rest/troubleshooting.md#status-codes) 和以下响应属性：

| 属性                                            | 类型    | 描述 |
|--------------------------------------------------|---------|-------------|
| `allow_force_push`                                   | boolean | 如果为 `true`，则允许在此分支上强制推送。 |
| `code_owner_approval_required`                       | boolean | 如果为 `true`，则推送至此分支需要代码所有者批准。 |
| `id`                                                 | integer | 受保护分支的 ID。 |
| `merge_access_levels`                                | array   | 合并访问级别配置数组。 |
| `merge_access_levels[].access_level`                 | integer | 用于合并的访问级别。 |
| `merge_access_levels[].access_level_description`     | string  | 访问级别的人类可读描述。 |
| `merge_access_levels[].group_id`                     | integer | 具有合并访问权限的群组的 ID。仅专业版和旗舰版。 |
| `merge_access_levels[].id`                           | integer | 合并访问级别配置的 ID。 |
| `merge_access_levels[].user_id`                      | integer | 具有合并访问权限的用户的 ID。仅专业版和旗舰版。 |
| `name`                                               | string  | 受保护分支的名称。 |
| `push_access_levels`                                 | array   | 推送访问级别配置数组。 |
| `push_access_levels[].access_level`                  | integer | 用于推送的访问级别。 |
| `push_access_levels[].access_level_description`      | string  | 访问级别的人类可读描述。 |
| `push_access_levels[].deploy_key_id`                 | integer | 具有推送访问权限的部署密钥的 ID。 |
| `push_access_levels[].group_id`                      | integer | 具有推送访问权限的群组的 ID。仅专业版和旗舰版。 |
| `push_access_levels[].id`                            | integer | 推送访问级别配置的 ID。 |
| `push_access_levels[].user_id`                       | integer | 具有推送访问权限的用户的 ID。仅专业版和旗舰版。 |
| `unprotect_access_levels`                            | array   | 取消保护访问级别配置数组。 |
| `unprotect_access_levels[].access_level`             | integer | 用于取消保护的访问级别。 |
| `unprotect_access_levels[].access_level_description` | string  | 访问级别的人类可读描述。 |
| `unprotect_access_levels[].group_id`                 | integer | 具有取消保护访问权限的群组的 ID。仅专业版和旗舰版。 |
| `unprotect_access_levels[].id`                       | integer | 取消保护访问级别配置的 ID。 |
| `unprotect_access_levels[].user_id`                  | integer | 具有取消保护访问权限的用户的 ID。仅专业版和旗舰版。 |

示例请求：

```shell
curl --request PATCH \
  --header "PRIVATE-TOKEN: <your_access_token>" \
  --url "https://gitlab.example.com/api/v4/projects/5/protected_branches/feature-branch?allow_force_push=true&code_owner_approval_required=true"
```

`allowed_to_push`、`allowed_to_merge` 和 `allowed_to_unprotect` 数组中的元素应为 `user_id`、`group_id` 或 `access_level` 之一，格式为 `{user_id: integer}`、`{group_id: integer}` 或 `{access_level: integer}`。

`allowed_to_push` 包含一个额外元素 `deploy_key_id`，格式为 `{deploy_key_id: integer}`。

要更新：

- `user_id`：确保更新的用户有项目的访问权限。在哈希中包含访问级别记录的 `id`。
- `group_id`：确保更新的群组 [已共享此项目](../user/project/members/sharing_projects_groups.md)。在哈希中包含访问级别记录的 `id`。
- `deploy_key_id`：确保部署密钥已为你的项目启用，并对你的项目仓库具有写入权限。

要更新现有访问级别记录上的任何其他字段，请在哈希中包含该记录的 `id`。

要删除，必须将 `_destroy` 设置为 `true`。请参见以下示例。

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
- 由 `group_id` 指定的群组必须有权访问项目。

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

要移除特定的访问级别，请使用 `_destroy: true`。

