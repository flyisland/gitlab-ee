---
stage: Create
group: Source Code
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
title: 群组级别受保护分支 API
---

{{< details >}}

- Tier: 专业版，旗舰版
- Offering: 私有化部署

{{< /details >}}

{{< history >}}

- 在极狐GitLab 17.6 中 GA。功能标志 `group_protected_branches` 已移除。

{{< /history >}}

使用此 API 管理[受保护分支设置](../user/project/repository/branches/protected.md#in-a-group)，这些设置由群组中的所有项目继承。群组受保护分支仅支持[有效访问级别](#valid-access-levels)。无法指定单个用户和群组。

> [!warning]
> 群组的受保护分支设置仅限于顶级群组。

<a id="valid-access-levels"></a>

## 有效访问级别

访问级别在 `ProtectedRefAccess.allowed_access_levels` 方法中定义。识别以下级别：

```plaintext
0  => 无访问权限
30 => 开发者访问权限
40 => 维护者访问权限
60 => 管理员访问权限
```

<a id="list-protected-branches"></a>

## 列出受保护分支

获取群组中的受保护分支列表。如果设置了通配符，则返回通配符而不是与该通配符匹配的分支的确切名称。

```plaintext
GET /groups/:id/protected_branches
```

| 属性 | 类型 | 必需 | 描述 |
| --------- | ---- | -------- | ----------- |
| `id` | integer or string | yes | 群组的 ID 或 [URL 编码路径](rest/_index.md#namespaced-paths)。 |
| `search` | string | no | 要搜索的受保护分支的名称或部分名称。 |

```shell
curl --header "PRIVATE-TOKEN: <your_access_token>" \
  --url "https://gitlab.example.com/api/v4/groups/5/protected_branches"
```

示例响应：

```json
[
  {
    "id": 1,
    "name": "main",
    "push_access_levels": [
      {
        "id":  1,
        "access_level": 40,
        "user_id": null,
        "group_id": null,
        "access_level_description": "Maintainers"
      }
    ],
    "merge_access_levels": [
      {
        "id":  1,
        "access_level": 40,
        "user_id": null,
        "group_id": null,
        "access_level_description": "Maintainers"
      }
    ],
    "allow_force_push":false,
    "code_owner_approval_required": false
  },
  {
    "id": 1,
    "name": "release/*",
    "push_access_levels": [
      {
        "id":  1,
        "access_level": 40,
        "user_id": null,
        "group_id": null,
        "access_level_description": "Maintainers"
      }
    ],
    "merge_access_levels": [
      {
        "id":  1,
        "access_level": 40,
        "user_id": null,
        "group_id": null,
        "access_level_description": "Maintainers"
      }
    ],
    "allow_force_push":false,
    "code_owner_approval_required": false
  },
  ...
]
```

<a id="get-a-single-protected-branch-or-wildcard-protected-branch"></a>

## 获取单个受保护分支或通配符受保护分支

获取单个受保护分支或通配符受保护分支。

```plaintext
GET /groups/:id/protected_branches/:name
```

| 属性 | 类型 | 必需 | 描述 |
| --------- | ---- | -------- | ----------- |
| `id` | integer or string | yes | 群组的 ID 或 [URL 编码路径](rest/_index.md#namespaced-paths)。 |
| `name` | string | yes | 分支或通配符的名称。 |

```shell
curl --header "PRIVATE-TOKEN: <your_access_token>" \
  --url "https://gitlab.example.com/api/v4/groups/5/protected_branches/main"
```

示例响应：

```json
{
  "id": 1,
  "name": "main",
  "push_access_levels": [
    {
      "id":  1,
      "access_level": 40,
      "user_id": null,
      "group_id": null,
      "access_level_description": "Maintainers"
    }
  ],
  "merge_access_levels": [
    {
      "id":  1,
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

<a id="protect-repository-branches"></a>

## 保护代码库分支

使用通配符受保护分支保护单个代码库分支。

```plaintext
POST /groups/:id/protected_branches
```

```shell
curl --request POST \
  --header "PRIVATE-TOKEN: <your_access_token>" \
  --url "https://gitlab.example.com/api/v4/groups/5/protected_branches?name=*-stable&push_access_level=30&merge_access_level=30&unprotect_access_level=40"
```

| 属性                                    | 类型 | 必需 | 描述 |
| -------------------------------------------- | ---- | -------- | ----------- |
| `id`                                         | integer or string | yes | 群组的 ID 或 [URL 编码路径](rest/_index.md#namespaced-paths)。 |
| `name`                                       | string         | yes | 分支或通配符的名称。 |
| `allow_force_push`                           | boolean        | no  | 允许所有具有推送权限的用户强制推送。默认：`false`。 |
| `allowed_to_merge`                           | array          | no  | 允许合并的访问级别数组，每个由 `{user_id: integer}`、`{group_id: integer}` 或 `{access_level: integer}` 格式的哈希描述。 |
| `allowed_to_push`                            | array          | no  | 允许推送的访问级别数组，每个由 `{user_id: integer}`、`{group_id: integer}` 或 `{access_level: integer}` 格式的哈希描述。 |
| `allowed_to_unprotect`                       | array          | no  | 允许取消保护的访问级别数组，每个由 `{user_id: integer}`、`{group_id: integer}` 或 `{access_level: integer}` 格式的哈希描述。 |
| `code_owner_approval_required`               | boolean        | no  | 如果与此分支匹配的项在 [`CODEOWNERS` 文件](../user/project/codeowners/_index.md) 中，则阻止推送。默认：`false`。 |
| `merge_access_level`                         | integer        | no  | 允许合并的访问级别。默认：`40`，维护者角色。 |
| `push_access_level`                          | integer        | no  | 允许推送的访问级别。默认：`40`，维护者角色。 |
| `unprotect_access_level`                     | integer        | no  | 允许取消保护的访问级别。默认：`40`，维护者角色。 |

示例响应：

```json
{
  "id": 1,
  "name": "*-stable",
  "push_access_levels": [
    {
      "id":  1,
      "access_level": 30,
      "user_id": null,
      "group_id": null,
      "access_level_description": "Developers + Maintainers"
    }
  ],
  "merge_access_levels": [
    {
      "id":  1,
      "access_level": 30,
      "user_id": null,
      "group_id": null,
      "access_level_description": "Developers + Maintainers"
    }
  ],
  "unprotect_access_levels": [
    {
      "id":  1,
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

<a id="example-with-access-levels"></a>

### 带有访问级别的示例

使用访问级别配置群组受保护分支：

```shell
curl --request POST \
  --header "PRIVATE-TOKEN: <your_access_token>" \
  --header "Content-Type: application/json" \
  --data '{
    "name": "main",
    "allowed_to_push": [{"access_level": 30}],
    "allowed_to_merge": [{
        "access_level": 30
      },{
        "access_level": 40
      }
    ]}'
    --url "https://gitlab.example.com/api/v4/groups/5/protected_branches"
```

示例响应：

```json
{
    "id": 5,
    "name": "main",
    "push_access_levels": [
        {
            "id": 1,
            "access_level": 30,
            "access_level_description": "Developers + Maintainers",
            "user_id": null,
            "group_id": null
        }
    ],
    "merge_access_levels": [
        {
            "id": 1,
            "access_level": 30,
            "access_level_description": "Developers + Maintainers",
            "user_id": null,
            "group_id": null
        },
        {
            "id": 2,
            "access_level": 40,
            "access_level_description": "Maintainers",
            "user_id": null,
            "group_id": null
        }
    ],
    "unprotect_access_levels": [
        {
            "id": 1,
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

<a id="unprotect-repository-branches"></a>

## 取消保护代码库分支

取消保护给定的受保护分支或通配符受保护分支。

```plaintext
DELETE /groups/:id/protected_branches/:name
```

```shell
curl --request DELETE \
  --header "PRIVATE-TOKEN: <your_access_token>" \
  --url "https://gitlab.example.com/api/v4/groups/5/protected_branches/*-stable"
```

| 属性 | 类型 | 必需 | 描述 |
| --------- | ---- | -------- | ----------- |
| `id` | integer or string | yes | 群组的 ID 或 [URL 编码路径](rest/_index.md#namespaced-paths)。 |
| `name` | string | yes | 分支的名称。 |

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

<a id="update-a-protected-branch"></a>

## 更新受保护分支

更新受保护分支。

```plaintext
PATCH /groups/:id/protected_branches/:name
```

```shell
curl --request PATCH \
  --header "PRIVATE-TOKEN: <your_access_token>" \
  --url "https://gitlab.example.com/api/v4/groups/5/protected_branches/feature-branch?allow_force_push=true&code_owner_approval_required=true"
```

| 属性                                    | 类型           | 必需 | 描述 |
| -------------------------------------------- | ---- | -------- | ----------- |
| `id`                                         | integer or string | yes      | 群组的 ID 或 [URL 编码路径](rest/_index.md#namespaced-paths)。 |
| `name`                                       | string         | yes      | 分支的名称。 |
| `allow_force_push`                           | boolean        | no       | 启用时，可以推送到此分支的成员也可以强制推送。 |
| `allowed_to_push`                            | array          | no       | 推送访问级别数组，每个由哈希描述。 |
| `allowed_to_merge`                           | array          | no       | 合并访问级别数组，每个由哈希描述。 |
| `allowed_to_unprotect`                       | array          | no       | 取消保护访问级别数组，每个由哈希描述。 |
| `code_owner_approval_required`               | boolean        | no       | 如果与此分支匹配的项在 [`CODEOWNERS` 文件](../user/project/codeowners/_index.md) 中，则阻止推送。默认：`false`。 |

`allowed_to_push`、`allowed_to_merge` 和 `allowed_to_unprotect` 数组中的元素应采用 `{access_level: integer}` 的形式。每个访问级别必须是 [有效访问级别](#valid-access-levels) 中的有效值。

- 要更新访问级别，你还必须在相应的哈希中传递 `access_level` 的 `id`。
- 要删除访问级别，你必须将 `_destroy` 设置为 `true`。请参见以下示例。

<a id="example-create-a-push_access_level-record"></a>

### 示例：创建 `push_access_level` 记录

```shell
curl --header 'Content-Type: application/json' --request PATCH \
  --data '{"allowed_to_push": [{access_level: 40}]}' \
  --header "PRIVATE-TOKEN: <your_access_token>" \
  --url "https://gitlab.example.com/api/v4/groups/22034114/protected_branches/main"
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
  --data '{"allowed_to_push": [{"id": 12, "access_level": 0}]' \
  --header "PRIVATE-TOKEN: <your_access_token>" \
  --url "https://gitlab.example.com/api/v4/groups/22034114/protected_branches/main"
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
  --url "https://gitlab.example.com/api/v4/groups/22034114/protected_branches/main"
```

示例响应：

```json
{
   "name": "main",
   "push_access_levels": []
}
```