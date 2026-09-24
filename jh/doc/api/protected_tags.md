---
stage: Create
group: Source Code
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
title: 受保护标签 API
---

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: JihuLab.com，私有化部署

{{< /details >}}

使用此 API 管理[受保护标签](../user/project/protected_tags.md)。

<a id="valid-access-levels"></a>

## 有效的访问级别

以下访问级别被识别：

- `0`：无访问权限
- `30`：开发者角色
- `40`：维护者角色

<a id="list-protected-tags"></a>

## 列出受保护标签

{{< history >}}

- 部署密钥信息在极狐GitLab 16.0 引入。

{{< /history >}}

从项目中获取[受保护标签](../user/project/protected_tags.md)列表。此函数接受分页参数 `page` 和 `per_page` 来限制受保护标签列表。

```plaintext
GET /projects/:id/protected_tags
```

支持的属性：

| 属性 | 类型 | 是否必需 | 描述 |
|------|------|----------|------|
| `id` | 整数或字符串 | 是 | ID 或[项目的 URL 编码路径](rest/_index.md#namespaced-paths)。 |

如果成功，返回 [`200 OK`](rest/troubleshooting.md#status-codes) 和以下响应属性：

| 属性 | 类型 | 描述 |
|------|------|------|
| `create_access_levels` | 数组 | 创建访问级别配置的数组。 |
| `create_access_levels[].access_level` | 整数 | 创建标签的访问级别。 |
| `create_access_levels[].access_level_description` | 字符串 | 访问级别的人类可读描述。 |
| `create_access_levels[].deploy_key_id` | 整数 | 具有创建访问权限的部署密钥的 ID。 |
| `create_access_levels[].group_id` | 整数 | 具有创建访问权限的群组的 ID。仅限于专业版和旗舰版。 |
| `create_access_levels[].id` | 整数 | 创建访问级别配置的 ID。 |
| `create_access_levels[].user_id` | 整数 | 具有创建访问权限的用户的 ID。仅限于专业版和旗舰版。 |
| `name` | 字符串 | 受保护标签的名称。 |

示例请求：

```shell
curl --request GET \
  --header "PRIVATE-TOKEN: <your_access_token>" \
  --url "https://gitlab.example.com/api/v4/projects/5/protected_tags"
```

示例响应：

```json
[
  {
    "name": "release-1-0",
    "create_access_levels": [
      {
        "id":1,
        "access_level": 40,
        "access_level_description": "Maintainers"
      },
      {
        "id": 2,
        "access_level": 40,
        "access_level_description": "Deploy key",
        "deploy_key_id": 1
      }
    ]
  }
]
```

<a id="get-a-protected-tag-or-wildcard-protected-tag"></a>

## 获取单个受保护标签或通配符受保护标签

获取单个受保护标签或通配符受保护标签。

```plaintext
GET /projects/:id/protected_tags/:name
```

支持的属性：

| 属性 | 类型 | 是否必需 | 描述 |
|------|------|----------|------|
| `id` | 整数或字符串 | 是 | ID 或[项目的 URL 编码路径](rest/_index.md#namespaced-paths)。 |
| `name` | 字符串 | 是 | 标签或通配符的名称。 |

如果成功，返回 [`200 OK`](rest/troubleshooting.md#status-codes) 和以下响应属性：

| 属性 | 类型 | 描述 |
|------|------|------|
| `create_access_levels` | 数组 | 创建访问级别配置的数组。 |
| `create_access_levels[].access_level` | 整数 | 创建标签的访问级别。 |
| `create_access_levels[].access_level_description` | 字符串 | 访问级别的人类可读描述。 |
| `create_access_levels[].deploy_key_id` | 整数 | 具有创建访问权限的部署密钥的 ID。 |
| `create_access_levels[].group_id` | 整数 | 具有创建访问权限的群组的 ID。仅限于专业版和旗舰版。 |
| `create_access_levels[].id` | 整数 | 创建访问级别配置的 ID。 |
| `create_access_levels[].user_id` | 整数 | 具有创建访问权限的用户的 ID。仅限于专业版和旗舰版。 |
| `name` | 字符串 | 受保护标签的名称。 |

示例请求：

```shell
curl --request GET \
  --header "PRIVATE-TOKEN: <your_access_token>" \
  --url "https://gitlab.example.com/api/v4/projects/5/protected_tags/release-1-0"
```

示例响应：

```json
{
  "name": "release-1-0",
  "create_access_levels": [
    {
      "id": 1,
      "access_level": 40,
      "access_level_description": "Maintainers"
    }
  ]
}
```

<a id="protect-a-repository-tag"></a>

## 保护仓库标签

{{< history >}}

- `deploy_key_id` 配置在极狐GitLab 17.5 引入。
- `deploy_key_id` 配置在极狐GitLab 18.10 从极狐GitLab 专业版移至极狐GitLab 基础版。

{{< /history >}}

保护单个仓库标签，或使用通配符受保护标签保护多个项目仓库标签。

```plaintext
POST /projects/:id/protected_tags
```

支持的属性：

| 属性 | 类型 | 是否必需 | 描述 |
|------|------|----------|------|
| `id` | 整数或字符串 | 是 | ID 或[项目的 URL 编码路径](rest/_index.md#namespaced-paths)。 |
| `name` | 字符串 | 是 | 标签或通配符的名称。 |
| `allowed_to_create` | 数组 | 否 | 允许创建标签的访问级别数组，每一项由 `{user_id: integer}`、`{group_id: integer}`、`{deploy_key_id: integer}` 或 `{access_level: integer}` 格式的哈希描述。`user_id`、`group_id` 和 `access_level` 仅限于专业版和旗舰版。 |
| `create_access_level` | 整数 | 否 | 允许创建的访问级别。默认为 `40`（维护者角色）。 |

如果成功，返回 [`201 Created`](rest/troubleshooting.md#status-codes) 和以下响应属性：

| 属性 | 类型 | 描述 |
|------|------|------|
| `create_access_levels` | 数组 | 创建访问级别配置的数组。 |
| `create_access_levels[].access_level` | 整数 | 创建标签的访问级别。 |
| `create_access_levels[].access_level_description` | 字符串 | 访问级别的人类可读描述。 |
| `create_access_levels[].deploy_key_id` | 整数 | 具有创建访问权限的部署密钥的 ID。 |
| `create_access_levels[].group_id` | 整数 | 具有创建访问权限的群组的 ID。仅限于专业版和旗舰版。 |
| `create_access_levels[].id` | 整数 | 创建访问级别配置的 ID。 |
| `create_access_levels[].user_id` | 整数 | 具有创建访问权限的用户的 ID。仅限于专业版和旗舰版。 |
| `name` | 字符串 | 受保护标签的名称。 |

示例请求：

```shell
curl --request POST \
  --header "PRIVATE-TOKEN: <your_access_token>" \
  --header "Content-Type: application/json" \
  --url "https://gitlab.example.com/api/v4/projects/5/protected_tags" \
  --data '{
   "allowed_to_create" : [
      {
         "user_id" : 1
      },
      {
         "access_level" : 30
      }
   ],
   "create_access_level" : 30,
   "name" : "*-stable"
}'
```

示例响应：

```json
{
  "name": "*-stable",
  "create_access_levels": [
    {
      "id": 1,
      "access_level": 30,
      "access_level_description": "Developers + Maintainers"
    }
  ]
}
```

<a id="example-with-user-and-group-access"></a>

### 使用用户和群组访问的示例

`allowed_to_create` 数组中的元素应采用 `{user_id: integer}`、`{group_id: integer}`、`{deploy_key_id: integer}` 或 `{access_level: integer}` 的形式。每个用户必须具有项目的访问权限，并且每个群组必须[已共享此项目](../user/project/members/sharing_projects_groups.md)。这些访问级别允许对受保护标签的访问进行更精细的控制。更多信息，请参阅[将群组添加到受保护标签](../user/project/protected_tags.md#add-a-group-to-protected-tags)。

此示例请求演示了如何创建允许特定用户和群组具有创建访问权限的受保护标签：

```shell
curl --request POST \
  --header "PRIVATE-TOKEN: <your_access_token>" \
  --url "https://gitlab.example.com/api/v4/projects/5/protected_tags" \
  --data "name=*-stable" \
  --data "allowed_to_create[][user_id]=10" \
  --data "allowed_to_create[][group_id]=20"
```

此示例响应包括：

- 名称为 `"*-stable"` 的受保护标签。
- ID 为 `1`、对应用户 ID `10` 的 `create_access_levels`。
- ID 为 `2`、对应群组 ID `20` 的 `create_access_levels`。

```json
{
  "name": "*-stable",
  "create_access_levels": [
    {
      "id": 1,
      "access_level": null,
      "user_id": 10,
      "group_id": null,
      "access_level_description": "Administrator"
    },
    {
      "id": 2,
      "access_level": null,
      "user_id": null,
      "group_id": 20,
      "access_level_description": "Example Create Group"
    }
  ]
}
```

<a id="unprotect-repository-tags"></a>

## 取消保护仓库标签

取消保护指定的受保护标签或通配符受保护标签。

```plaintext
DELETE /projects/:id/protected_tags/:name
```

支持的属性：

| 属性 | 类型 | 是否必需 | 描述 |
|------|------|----------|------|
| `id` | 整数或字符串 | 是 | ID 或[项目的 URL 编码路径](rest/_index.md#namespaced-paths)。 |
| `name` | 字符串 | 是 | 标签的名称。 |

如果成功，返回 [`204 No Content`](rest/troubleshooting.md#status-codes)。

示例请求：

```shell
curl --request DELETE \
  --header "PRIVATE-TOKEN: <your_access_token>" \
  --url "https://gitlab.example.com/api/v4/projects/5/protected_tags/*-stable"
```