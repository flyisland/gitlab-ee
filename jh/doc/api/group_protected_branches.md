---
stage: Create
group: Source Code
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
title: 群组级受保护分支 API
---

{{< details >}}

- Tier: 专业版，旗舰版
- Offering: 私有化部署

{{< /details >}}

使用此 API 管理由群组中所有项目继承的[受保护分支设置](../user/project/repository/branches/protected.md#in-a-group)。群组受保护分支仅支持[有效访问级别](#valid-access-levels)，并且在极狐GitLab 旗舰版中，还支持[自定义角色](../user/custom_roles/_index.md)。不能指定单个用户和群组。

> [!warning]
> 群组的受保护分支设置仅限顶级群组使用。

<a id="valid-access-levels"></a>

## 有效访问级别

访问级别在 `ProtectedRefAccess.allowed_access_levels` 方法中定义。可识别以下级别：

```plaintext
0  => No access
30 => Developer access
40 => Maintainer access
60 => Admin access
```

<a id="list-protected-branches"></a>

## 列出受保护分支

获取群组中的受保护分支列表。如果设置了通配符，则返回该通配符，而不是匹配该通配符的分支的确切名称。

```plaintext
GET /groups/:id/protected_branches
```

| 属性 | 类型 | 是否必需 | 描述 |
| --------- | ---- | -------- | ----------- |
| `id` | integer or string | 是 | 群组的 ID 或 [URL 编码路径](rest/_index.md#namespaced-paths)。 |
| `search` | string | 否 | 要搜索的受保护分支的名称或名称的一部分。 |

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

| 属性 | 类型 | 是否必需 | 描述 |
| --------- | ---- | -------- | ----------- |
| `id` | integer or string | 是 | 群组的 ID 或 [URL 编码路径](rest/_index.md#namespaced-paths)。 |
| `name` | string | 是 | 分支或通配符的名称。 |

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

## 保护代码仓库分支

使用通配符受保护分支保护单个代码仓库分支。

```plaintext
POST /groups/:id/protected_branches
```

```shell
curl --request POST \
  --header "PRIVATE-TOKEN: <your_access_token>" \
  --url "https://gitlab.example.com/api/v4/groups/5/protected_branches?name=*-stable&push_access_level=30&merge_access_level=30&unprotect_access_level=40"
```

| 属性                                    | 类型 | 是否必需 | 描述 |
| -------------------------------------------- | ---- | -------- | ----------- |
| `id`                                         | integer or string | 是 | 群组的 ID 或 [URL 编码路径](rest/_index.md#namespaced-paths)。 |
| `name`                                       | string         | 是 | 分支或通配符的名称。 |
| `allow_force_push`                           | boolean        | 否  | 允许所有具有推送权限的用户强制推送。默认值：`false`。 |
| `allowed_to_merge`                           | array          | 否  | 允许合并的访问级别数组，每个级别由 `{access_level: integer}` 或 `{member_role_id: integer}` 形式的哈希描述。`member_role_id` 仅适用于旗舰版。 |
| `allowed_to_push`                            | array          | 否  | 允许推送的访问级别数组，每个级别由 `{access_level: integer}` 或 `{member_role_id: integer}` 形式的哈希描述。`member_role_id` 仅适用于旗舰版。 |
| `allowed_to_unprotect`                       | array          | 否  | 允许取消保护的访问级别数组，每个级别由 `{access_level: integer}` 或 `{member_role_id: integer}` 形式的哈希描述。`member_role_id` 仅适用于旗舰版。 |
| `code_owner_approval_required`               | boolean        | 否  | 如果该分支与 [`CODEOWNERS` 文件](../user/project/codeowners/_index.md)中的某项匹配，则阻止推送到该分支。默认值：`false`。 |
| `merge_access_level`                         | integer        | 否  | 允许合并的访问级别。默认值：`40`，维护者角色。不支持自定义角色。请改用带 `member_role_id`的 `allowed_to_merge`。 |
| `push_access_level`                          | integer        | 否  | 允许推送的访问级别。默认值：`40`，维护者角色。不支持自定义角色。请改用带 `member_role_id`的 `allowed_to_push`。 |
| `unprotect_access_level`                     | integer        | 否  | 允许取消保护的访问级别。默认值：`40`，维护者角色。不支持自定义角色。请改用带 `member_role_id`的 `allowed_to_unprotect`。 |

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

### 使用访问级别的示例

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
    ]}' \
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

<a id="example-with-a-custom-role"></a>

### 使用自定义角色的示例

{{< details >}}

- Tier: 旗舰版

{{< /details >}}

使用 `member_role_id` 允许[自定义角色](../user/custom_roles/_index.md)合并到群组受保护分支。该自定义角色必须与受保护分支属于同一顶级群组。

```shell
curl --request POST \
  --header "PRIVATE-TOKEN: <your_access_token>" \
  --header "Content-Type: application/json" \
  --data '{
    "name": "main",
    "allowed_to_merge": [{"member_role_id": 42}],
    "push_access_level": 40
  }' \
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
            "access_level": 40,
            "access_level_description": "Maintainers",
            "user_id": null,
            "group_id": null
        }
    ],
    "merge_access_levels": [
        {
            "id": 1,
            "access_level": 30,
            "access_level_description": "Lead Developer",
            "user_id": null,
            "group_id": null,
            "member_role_id": 42,
            "member_role_name": "Lead Developer"
        }
    ],
    "allow_force_push":false,
    "code_owner_approval_required": false
}
```

<a id="unprotect-repository-branches"></a>

## 取消保护代码仓库分支

取消对给定受保护分支或通配符受保护分支的保护。

```plaintext
DELETE /groups/:id/protected_branches/:name
```

```shell
curl --request DELETE \
  --header "PRIVATE-TOKEN: <your_access_token>" \
  --url "https://gitlab.example.com/api/v4/groups/5/protected_branches/*-stable"
```

| 属性 | 类型 | 是否必需 | 描述 |
| --------- | ---- | -------- | ----------- |
| `id` | integer or string | 是 | 群组的 ID 或 [URL 编码路径](rest/_index.md#namespaced-paths)。 |
| `name` | string | 是 | 分支的名称。 |

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

| 属性                                    | 类型           | 是否必需 | 描述                                                                                                                          |
| -------------------------------------------- | ---- | -------- | ----------- |
| `id`                                         | integer or string | 是      | 群组的 ID 或 [URL 编码路径](rest/_index.md#namespaced-paths)。                       |
| `name`                                       | string         | 是      | 分支的名称。                                                                                                               |
| `allow_force_push`                           | boolean        | 否       | 启用后，可以推送到此分支的成员也可以强制推送。                                                               |
| `allowed_to_push`                            | array          | 否       | 推送访问级别数组，每个级别由哈希描述。                                                                          |
| `allowed_to_merge`                           | array          | 否       | 合并访问级别数组，每个级别由哈希描述。                                                                         |
| `allowed_to_unprotect`                       | array          | 否       | 取消保护访问级别数组，每个级别由哈希描述。                                                                     |
| `code_owner_approval_required`               | boolean        | 否       | 如果该分支与 [`CODEOWNERS` 文件](../user/project/codeowners/_index.md)中的某项匹配，则阻止推送到该分支。默认值：`false`。 |

`allowed_to_push`、`allowed_to_merge` 和 `allowed_to_unprotect` 数组中的元素应采用 `{access_level: integer}` 形式，或在极狐GitLab 旗舰版中使用 `{member_role_id: integer}` 以允许[自定义角色](../user/custom_roles/_index.md)。每个访问级别必须是[有效访问级别](#valid-access-levels)中的有效值。`member_role_id` 引用的自定义角色必须与受保护分支属于同一顶级群组。

- 要更新访问级别，您还必须在相应的哈希中传递 `access_level`的 `id`。
- 要删除访问级别，您必须传递设置为 `true`的 `_destroy`。请参见以下示例。

<a id="example-create-a-push_access_level-record"></a>

### 示例：创建 `push_access_level` 记录

```shell
curl --request PATCH \
  --header "PRIVATE-TOKEN: <your_access_token>" \
  --header "Content-Type: application/json" \
  --data '{"allowed_to_push": [{"access_level": 40}]}' \
  --url "https://gitlab.example.com/api/v4/groups/5/protected_branches/main"
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
curl --request PATCH \
  --header "PRIVATE-TOKEN: <your_access_token>" \
  --header "Content-Type: application/json" \
  --data '{"allowed_to_push": [{"id": 12, "access_level": 0}]}' \
  --url "https://gitlab.example.com/api/v4/groups/5/protected_branches/main"
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
curl --request PATCH \
  --header "PRIVATE-TOKEN: <your_access_token>" \
  --header "Content-Type: application/json" \
  --data '{"allowed_to_push": [{"id": 12, "_destroy": true}]}' \
  --url "https://gitlab.example.com/api/v4/groups/5/protected_branches/main"
```

示例响应：

```json
{
   "name": "main",
   "push_access_levels": []
}
```
