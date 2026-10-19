---
stage: Verify
group: Runner Core
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
title: 受保护环境 API
---

{{< details >}}

- Tier: 专业版，旗舰版
- Offering: JihuLab.com，私有化部署

{{< /details >}}

使用此 API 与[受保护环境](../ci/environments/protected_environments.md)进行交互。

> [!note]
> 对于群组级别的受保护环境，请参见[群组级受保护环境 API](group_protected_environments.md)

<a id="valid-access-levels"></a>

## 有效的访问级别

访问级别在 `ProtectedEnvironments::DeployAccessLevel::ALLOWED_ACCESS_LEVELS` 方法中定义。
目前，系统识别的级别如下：

```plaintext
30 => 开发者访问
40 => 维护者访问
60 => 管理员访问
```

<a id="group-inheritance-types"></a>

## 群组继承类型

群组继承允许部署访问级别和访问规则将继承的群组成员资格考虑在内。群组继承类型由 `ProtectedEnvironments::Authorizable::GROUP_INHERITANCE_TYPE` 定义。
系统识别的类型如下：

```plaintext
0 => 仅直接群组成员（默认）
1 => 所有继承的群组
```

<a id="list-protected-environments"></a>

## 列出受保护环境

从项目中获取受保护环境列表：

```plaintext
GET /projects/:id/protected_environments
```

| 属性 | 类型 | 是否必需 | 描述 |
| --------- | ---- | -------- | ----------- |
| `id` | 整数或字符串 | 是 | 项目的 ID 或 [URL 编码路径](rest/_index.md#namespaced-paths)。 |

```shell
curl --header "PRIVATE-TOKEN: <your_access_token>" \
  --url "https://gitlab.example.com/api/v4/projects/5/protected_environments/"
```

响应示例：

```json
[
   {
      "name":"production",
      "deploy_access_levels":[
         {
            "id": 12,
            "access_level":40,
            "access_level_description":"Maintainers",
            "user_id":null,
            "group_id":null,
            "group_inheritance_type": 0
         }
      ],
      "required_approval_count": 0
   }
]
```

<a id="get-a-single-protected-environment"></a>

## 获取单个受保护环境

获取单个受保护环境：

```plaintext
GET /projects/:id/protected_environments/:name
```

| 属性 | 类型 | 是否必需 | 描述 |
| --------- | ---- | -------- | ----------- |
| `id` | 整数或字符串 | 是 | 项目的 ID 或 [URL 编码路径](rest/_index.md#namespaced-paths) |
| `name` | 字符串 | 是 | 受保护环境的名称 |

```shell
curl --header "PRIVATE-TOKEN: <your_access_token>" \
  --url "https://gitlab.example.com/api/v4/projects/5/protected_environments/production"
```

响应示例：

```json
{
   "name":"production",
   "deploy_access_levels":[
      {
         "id": 12,
         "access_level": 40,
         "access_level_description": "Maintainers",
         "user_id": null,
         "group_id": null,
         "group_inheritance_type": 0
      }
   ],
   "required_approval_count": 0
}
```

<a id="protect-a-single-environment"></a>

## 保护单个环境

保护单个环境：

```plaintext
POST /projects/:id/protected_environments
```

| 属性 | 类型 | 是否必需 | 描述 |
| --------- | ---- | -------- | ----------- |
| `id`                            | 整数或字符串 | 是 | 项目的 ID 或 [URL 编码路径](rest/_index.md#namespaced-paths)。 |
| `name`                          | 字符串         | 是 | 环境的名称。 |
| `deploy_access_levels`          | 数组          | 是 | 允许部署的访问级别数组，每个都用一个散列来描述。 |
| `approval_rules`                | 数组          | 否  | 允许审批的访问级别数组，每个都用一个散列来描述。请参见[多审批规则](../ci/environments/deployment_approvals.md#add-multiple-approval-rules)。 |

`deploy_access_levels` 和 `approval_rules` 数组中的元素应为 `user_id`、`group_id` 或 `access_level` 之一，并采用 `{user_id: integer}`、`{group_id: integer}` 或 `{access_level: integer}` 的形式。你可以选择在每个元素上指定 `group_inheritance_type`，其值应为[有效的群组继承类型](#group-inheritance-types)之一。

每个用户都必须拥有项目的访问权限，并且每个群组必须[此项目已共享给该群组](../user/project/members/sharing_projects_groups.md)。

```shell
curl --header 'Content-Type: application/json' \
     --request POST \
     --data '{"name": "production", "deploy_access_levels": [{"group_id": 9899826}], "approval_rules": [{"group_id": 134}, {"group_id": 135, "required_approvals": 2}]}' \
     --header "PRIVATE-TOKEN: <your_access_token>" \
     --url "https://gitlab.example.com/api/v4/projects/22034114/protected_environments"
```

响应示例：

```json
{
   "name": "production",
   "deploy_access_levels": [
      {
         "id": 12,
         "access_level": 40,
         "access_level_description": "protected-access-group",
         "user_id": null,
         "group_id": 9899826,
         "group_inheritance_type": 0
      }
   ],
   "required_approval_count": 0,
   "approval_rules": [
      {
         "id": 38,
         "user_id": null,
         "group_id": 134,
         "access_level": null,
         "access_level_description": "qa-group",
         "required_approvals": 1,
         "group_inheritance_type": 0
      },
      {
         "id": 39,
         "user_id": null,
         "group_id": 135,
         "access_level": null,
         "access_level_description": "security-group",
         "required_approvals": 2,
         "group_inheritance_type": 0
      }
   ]
}
```

<a id="update-a-protected-environment"></a>

## 更新受保护环境

{{< history >}}

- 已在 极狐GitLab 15.4 中引入。

{{< /history >}}

更新单个环境。

```plaintext
PUT /projects/:id/protected_environments/:name
```

| 属性 | 类型 | 是否必需 | 描述 |
| --------- | ---- | -------- | ----------- |
| `id`                            | 整数或字符串 | 是 | 项目的 ID 或 [URL 编码路径](rest/_index.md#namespaced-paths)。 |
| `name`                          | 字符串         | 是 | 环境的名称。 |
| `deploy_access_levels`          | 数组          | 否  | 允许部署的访问级别数组，每个都用一个散列来描述。 |
| `approval_rules`                | 数组          | 否  | 允许审批的访问级别数组，每个都用一个散列来描述。有关更多信息，请参见[多审批规则](../ci/environments/deployment_approvals.md#add-multiple-approval-rules)。 |

`deploy_access_levels` 和 `approval_rules` 数组中的元素应为 `user_id`、`group_id` 或 `access_level` 之一，并采用 `{user_id: integer}`、`{group_id: integer}` 或 `{access_level: integer}` 的形式。你可以选择在每个元素上指定 `group_inheritance_type`，其值应为[有效的群组继承类型](#group-inheritance-types)之一。

更新要求：

- **`user_id`**：确保更新后的用户拥有项目的访问权限。你还必须在相应的散列中传递 `deploy_access_level` 或 `approval_rule` 的 `id`。
- **`group_id`**：确保更新后的群组已[共享该项目](../user/project/members/sharing_projects_groups.md)。你还必须在相应的散列中传递 `deploy_access_level` 或 `approval_rule` 的 `id`。

删除操作：

- 你必须将 `_destroy` 设置为 `true`。参见以下示例。

<a id="example-create-a-deploy-access-level-record"></a>

### 示例：创建 `deploy_access_level` 记录

```shell
curl --header 'Content-Type: application/json' \
     --request PUT \
     --data '{"deploy_access_levels": [{"group_id": 9899829, access_level: 40}]' \
     --header "PRIVATE-TOKEN: <your_access_token>" \
     --url "https://gitlab.example.com/api/v4/projects/22034114/protected_environments/production"
```

响应示例：

```json
{
   "name": "production",
   "deploy_access_levels": [
      {
         "id": 12,
         "access_level": 40,
         "access_level_description": "protected-access-group",
         "user_id": null,
         "group_id": 9899829,
         "group_inheritance_type": 1
      }
   ],
   "required_approval_count": 0
}
```

<a id="example-update-a-deploy-access-level-record"></a>

### 示例：更新 `deploy_access_level` 记录

```shell
curl --header 'Content-Type: application/json' \
     --request PUT \
     --data '{"deploy_access_levels": [{"id": 12, "group_id": 22034120}]}' \
     --header "PRIVATE-TOKEN: <your_access_token>" \
     --url "https://gitlab.example.com/api/v4/projects/22034114/protected_environments/production"
```

```json
{
   "name": "production",
   "deploy_access_levels": [
      {
         "id": 12,
         "access_level": 40,
         "access_level_description": "protected-access-group",
         "user_id": null,
         "group_id": 22034120,
         "group_inheritance_type": 0
      }
   ],
   "required_approval_count": 2
}
```

<a id="example-delete-a-deploy-access-level-record"></a>

### 示例：删除 `deploy_access_level` 记录

```shell
curl --header 'Content-Type: application/json' \
     --request PUT \
     --data '{"deploy_access_levels": [{"id": 12, "_destroy": true}]}' \
     --header "PRIVATE-TOKEN: <your_access_token>" \
     --url "https://gitlab.example.com/api/v4/projects/22034114/protected_environments/production"
```

响应示例：

```json
{
   "name": "production",
   "deploy_access_levels": [],
   "required_approval_count": 0
}
```

<a id="example-create-an-approval-rule-record"></a>

### 示例：创建 `approval_rule` 记录

```shell
curl --header 'Content-Type: application/json' \
     --request PUT \
     --data '{"approval_rules": [{"group_id": 134, "required_approvals": 1}]}' \
     --header "PRIVATE-TOKEN: <your_access_token>" \
     --url "https://gitlab.example.com/api/v4/projects/22034114/protected_environments/production"
```

响应示例：

```json
{
   "name": "production",
   "approval_rules": [
      {
         "id": 38,
         "user_id": null,
         "group_id": 134,
         "access_level": null,
         "access_level_description": "qa-group",
         "required_approvals": 1,
         "group_inheritance_type": 0
      }
   ]
}
```

<a id="example-update-an-approval-rule-record"></a>

### 示例：更新 `approval_rule` 记录

```shell
curl --header 'Content-Type: application/json' \
     --request PUT \
     --data '{"approval_rules": [{"id": 38, "group_id": 135, "required_approvals": 2}]}' \
     --header "PRIVATE-TOKEN: <your_access_token>" \
     --url "https://gitlab.example.com/api/v4/projects/22034114/protected_environments/production"
```

```json
{
   "name": "production",
   "approval_rules": [
      {
         "id": 38,
         "user_id": null,
         "group_id": 135,
         "access_level": null,
         "access_level_description": "security-group",
         "required_approvals": 2,
         "group_inheritance_type": 0
      }
   ]
}
```

<a id="example-delete-an-approval-rule-record"></a>

### 示例：删除 `approval_rule` 记录

```shell
curl --header 'Content-Type: application/json' \
     --request PUT \
     --data '{"approval_rules": [{"id": 38, "_destroy": true}]}' \
     --header "PRIVATE-TOKEN: <your_access_token>" \
     --url "https://gitlab.example.com/api/v4/projects/22034114/protected_environments/production"
```

响应示例：

```json
{
   "name": "production",
   "approval_rules": []
}
```

<a id="unprotect-a-single-environment"></a>

## 解除对单个环境的保护

解除对指定受保护环境的保护：

```plaintext
DELETE /projects/:id/protected_environments/:name
```

| 属性 | 类型 | 是否必需 | 描述 |
| --------- | ---- | -------- | ----------- |
| `id` | 整数或字符串 | 是 | 项目的 ID 或 [URL 编码路径](rest/_index.md#namespaced-paths)。 |
| `name` | 字符串 | 是 | 受保护环境的名称。 |

```shell
curl --request DELETE \
  --header "PRIVATE-TOKEN: <your_access_token>" \
  --url "https://gitlab.example.com/api/v4/projects/5/protected_environments/staging"
```