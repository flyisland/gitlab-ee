```markdown
---
stage: Verify
group: Runner Core
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
title: 群组级受保护环境 API
---

{{< details >}}

- Tier: 专业版，旗舰版
- Offering: JihuLab.com，私有化部署

{{< /details >}}

{{< history >}}

- 在 GitLab 14.0 中引入。部署在 `group_level_protected_environments` 功能标志后，默认禁用。
- 功能标志 `group_level_protected_environments` 在 GitLab 14.3 中移除。
- 在 GitLab 14.3 中 GA。

{{< /history >}}

使用此 API 与[群组级受保护环境](../ci/environments/protected_environments.md#group-level-protected-environments)进行交互。

> [!注意]
> 有关受保护环境，请参见[受保护环境 API](protected_environments.md)

<a id="valid-access-levels"></a>

## 有效的访问级别

访问级别定义在 `ProtectedEnvironments::DeployAccessLevel::ALLOWED_ACCESS_LEVELS` 方法中。
目前，系统可识别以下级别：

```plaintext
30 => 开发者访问
40 => 维护者访问
60 => 管理员访问
```

<a id="list-all-group-level-protected-environments"></a>

## 列出所有群组级受保护环境

列出指定群组的所有受保护环境。

```plaintext
GET /groups/:id/protected_environments
```

| 属性 | 类型 | 必需 | 描述 |
| --------- | ---- | -------- | ----------- |
| `id` | 整数或字符串 | 是 | 经认证用户维护的群组的 ID 或 [URL 编码路径](rest/_index.md#namespaced-paths)。 |

```shell
curl --request GET \
  --header "PRIVATE-TOKEN: <your_access_token>" \
  --url "https://gitlab.example.com/api/v4/groups/5/protected_environments/"
```

示例响应：

```json
[
   {
      "name":"production",
      "deploy_access_levels":[
         {
            "id": 12,
            "access_level": 40,
            "access_level_description": "Maintainers",
            "user_id": null,
            "group_id": null
         }
      ],
      "required_approval_count": 0
   }
]
```

<a id="retrieve-a-single-protected-environment"></a>

## 获取单个受保护环境

从群组中获取指定的受保护环境。

```plaintext
GET /groups/:id/protected_environments/:name
```

| 属性 | 类型 | 必需 | 描述 |
| --------- | ---- | -------- | ----------- |
| `id` | 整数或字符串 | 是 | 经认证用户维护的群组的 ID 或 [URL 编码路径](rest/_index.md#namespaced-paths)。 |
| `name`    | 字符串 | 是    | 受保护环境的[部署层级](../ci/environments/_index.md#deployment-tier-of-environments)。可选值：`production`、`staging`、`testing`、`development` 或 `other`。|

```shell
curl --request GET \
  --header "PRIVATE-TOKEN: <your_access_token>" \
  --url "https://gitlab.example.com/api/v4/groups/5/protected_environments/production"
```

示例响应：

```json
{
   "name":"production",
   "deploy_access_levels":[
      {
         "id": 12,
         "access_level":40,
         "access_level_description":"Maintainers",
         "user_id":null,
         "group_id":null
      }
   ],
   "required_approval_count": 0
}
```

<a id="protect-a-single-environment"></a>

## 保护单个环境

保护单个环境。

```plaintext
POST /groups/:id/protected_environments
```

| 属性 | 类型 | 必需 | 描述 |
| --------- | ---- | -------- | ----------- |
| `id`      | 整数或字符串 | 是 | 经认证用户维护的群组的 ID 或 [URL 编码路径](rest/_index.md#namespaced-paths)。 |
| `name`    | 字符串 | 是    | 受保护环境的[部署层级](../ci/environments/_index.md#deployment-tier-of-environments)。可选值：`production`、`staging`、`testing`、`development` 或 `other`。|
| `deploy_access_levels`          | 数组          | 是 | 允许部署的访问级别数组，每个访问级别用一个哈希描述。可选值：`user_id`、`group_id` 或 `access_level`。格式为 `{user_id: integer}`、`{group_id: integer}` 或 `{access_level: integer}`。 |
| `approval_rules`                | 数组          | 否  | 允许审批的访问级别数组，每个访问级别用一个哈希描述。可选值：`user_id`、`group_id` 或 `access_level`。格式为 `{user_id: integer}`、`{group_id: integer}` 或 `{access_level: integer}`。您还可以通过 `required_approvals` 字段指定来自指定实体的所需审批数量。参见[多审批规则](../ci/environments/deployment_approvals.md#add-multiple-approval-rules)了解更多信息。 |

可分配的 `user_id` 是属于给定群组且具有维护者角色（或更高）的用户。
可分配的 `group_id` 是给定群组下的子群组。

```shell
curl --request POST \
  --header "PRIVATE-TOKEN: <your_access_token>" \
  --header "Content-Type: application/json" \
  --url "https://gitlab.example.com/api/v4/groups/22034114/protected_environments" \
  --data '{"name": "production", "deploy_access_levels": [{"group_id": 9899826}]}'
```

示例响应：

```json
{
   "name":"production",
   "deploy_access_levels":[
      {
         "id": 12,
         "access_level": 40,
         "access_level_description": "protected-access-group",
         "user_id": null,
         "group_id": 9899826
      }
   ],
   "required_approval_count": 0
}
```

包含多审批规则的示例：

```shell
curl --request POST \
  --header "PRIVATE-TOKEN: <your_access_token>" \
  --header "Content-Type: application/json" \
  --url "https://gitlab.example.com/api/v4/groups/128/protected_environments" \
  --data '{
    "name": "production",
    "deploy_access_levels": [{"group_id": 138}],
    "approval_rules": [
      {"group_id": 134},
      {"group_id": 135, "required_approvals": 2}
    ]
  }'
```

在此配置中，运维群组 `"group_id": 138` 只有在 QA 群组 `"group_id": 134` 和安全群组
`"group_id": 135` 都批准了部署之后，才能将部署作业执行到 `production` 环境。

<a id="update-a-protected-environment"></a>

## 更新受保护环境

{{< history >}}

- 在 GitLab 15.4 中引入。

{{< /history >}}

更新单个环境。

```plaintext
PUT /groups/:id/protected_environments/:name
```

| 属性 | 类型 | 必需 | 描述 |
| --------- | ---- | -------- | ----------- |
| `id`      | 整数或字符串 | 是 | 经认证用户维护的群组的 ID 或 [URL 编码路径](rest/_index.md#namespaced-paths)。 |
| `name`    | 字符串 | 是    | 受保护环境的[部署层级](../ci/environments/_index.md#deployment-tier-of-environments)。可选值：`production`、`staging`、`testing`、`development` 或 `other`。|
| `deploy_access_levels`          | 数组          | 否 | 允许部署的访问级别数组，每个访问级别用一个哈希描述。可选值：`user_id`、`group_id` 或 `access_level`。格式为 `{user_id: integer}`、`{group_id: integer}` 或 `{access_level: integer}`。 |
| `required_approval_count` | 整数        | 否       | 部署到此环境所需的审批数量。 |
| `approval_rules`                | 数组          | 否  | 允许审批的访问级别数组，每个访问级别用一个哈希描述。可选值：`user_id`、`group_id` 或 `access_level`。格式为 `{user_id: integer}`、`{group_id: integer}` 或 `{access_level: integer}`。您还可以通过 `required_approvals` 字段指定来自指定实体的所需审批数量。参见[多审批规则](../ci/environments/deployment_approvals.md#add-multiple-approval-rules)了解更多信息。 |

要更新：

- **`user_id`**：确保更新后的用户属于给定群组且具有维护者角色（或更高）。您还必须在相应的哈希中传递 `deploy_access_level` 或 `approval_rule` 的 `id`。
- **`group_id`**：确保更新后的群组是此受保护环境所属群组的子群组。您还必须在相应的哈希中传递 `deploy_access_level` 或 `approval_rule` 的 `id`。

要删除：

- 您必须将 `_destroy` 设置为 `true`。参见以下示例。

<a id="example-create-a-deploy_access_level-record"></a>

### 示例：创建 deploy_access_level 记录

```shell
curl --request PUT \
  --header "PRIVATE-TOKEN: <your_access_token>" \
  --header "Content-Type: application/json" \
  --url "https://gitlab.example.com/api/v4/groups/22034114/protected_environments/production" \
  --data '{"deploy_access_levels": [{"group_id": 9899829, "access_level": 40}]}'
```

示例响应：

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

<a id="example-update-a-deploy_access_level-record"></a>

### 示例：更新 deploy_access_level 记录

```shell
curl --request PUT \
  --header "PRIVATE-TOKEN: <your_access_token>" \
  --header "Content-Type: application/json" \
  --url "https://gitlab.example.com/api/v4/groups/22034114/protected_environments/production" \
  --data '{"deploy_access_levels": [{"id": 12, "group_id": 22034120}]}'
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

<a id="example-delete-a-deploy_access_level-record"></a>

### 示例：删除 deploy_access_level 记录

```shell
curl --request PUT \
  --header "PRIVATE-TOKEN: <your_access_token>" \
  --header "Content-Type: application/json" \
  --url "https://gitlab.example.com/api/v4/groups/22034114/protected_environments/production" \
  --data '{"deploy_access_levels": [{"id": 12, "_destroy": true}]}'
```

示例响应：

```json
{
   "name": "production",
   "deploy_access_levels": [],
   "required_approval_count": 0
}
```

<a id="example-create-an-approval_rule-record"></a>

### 示例：创建 approval_rule 记录

```shell
curl --request PUT \
  --header "PRIVATE-TOKEN: <your_access_token>" \
  --header "Content-Type: application/json" \
  --url "https://gitlab.example.com/api/v4/groups/22034114/protected_environments/production" \
  --data '{"approval_rules": [{"group_id": 134, "required_approvals": 1}]}'
```

示例响应：

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

<a id="example-update-an-approval_rule-record"></a>

### 示例：更新 approval_rule 记录

```shell
curl --request PUT \
  --header "PRIVATE-TOKEN: <your_access_token>" \
  --header "Content-Type: application/json" \
  --url "https://gitlab.example.com/api/v4/groups/22034114/protected_environments/production" \
  --data '{"approval_rules": [{"id": 38, "group_id": 135, "required_approvals": 2}]}'
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

<a id="example-delete-an-approval_rule-record"></a>

### 示例：删除 approval_rule 记录

```shell
curl --request PUT \
  --header "PRIVATE-TOKEN: <your_access_token>" \
  --header "Content-Type: application/json" \
  --url "https://gitlab.example.com/api/v4/groups/22034114/protected_environments/production" \
  --data '{"approval_rules": [{"id": 38, "_destroy": true}]}'
```

示例响应：

```json
{
   "name": "production",
   "approval_rules": []
}
```

<a id="unprotect-a-single-environment"></a>

## 取消保护单个环境

取消保护指定的受保护环境。

```plaintext
DELETE /groups/:id/protected_environments/:name
```

| 属性 | 类型 | 必需 | 描述 |
| --------- | ---- | -------- | ----------- |
| `id` | 整数或字符串 | 是 | 经认证用户维护的群组的 ID 或 [URL 编码路径](rest/_index.md#namespaced-paths)。 |
| `name`    | 字符串 | 是    | 受保护环境的[部署层级](../ci/environments/_index.md#deployment-tier-of-environments)。可选值：`production`、`staging`、`testing`、`development` 或 `other`。|

```shell
curl --request DELETE \
  --header "PRIVATE-TOKEN: <your_access_token>" \
  --url "https://gitlab.example.com/api/v4/groups/5/protected_environments/staging"
```

响应应返回 200 状态码。

```