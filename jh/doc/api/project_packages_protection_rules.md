---
stage: Package
group: Package Registry
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
description: Documentation for the REST API for Package Protection Rules in GitLab.
title: 受保护的软件包 API
---

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: 私有化部署

{{< /details >}}

{{< history >}}

- 在极狐GitLab 17.1 中引入，通过一个名为 `packages_protected_packages` 的功能标志。默认禁用。
- 在极狐GitLab 17.5 中于 JihuLab.com 上启用。
- 在极狐GitLab 17.6 中 GA。功能标志 `packages_protected_packages` 已移除。
- 在极狐GitLab 17.11 中添加了 `minimum_access_level_for_delete` 属性，通过一个名为 `packages_protected_packages_delete` 的功能标志。默认禁用。

{{< /history >}}

使用此 API 管理[软件包的保护规则](../user/packages/package_registry/package_protection_rules.md)。

<a id="list-all-package-protection-rules"></a>

## 列出所有软件包保护规则

列出指定项目的所有软件包保护规则。

```plaintext
GET /api/v4/projects/:id/packages/protection/rules
```

支持的属性：

| 属性                         | 类型            | 是否必需 | 描述                    |
|------------------------------|-----------------|----------|--------------------------------|
| `id`                         | 整数或字符串    | 是       | ID 或[项目的 URL 编码路径](rest/_index.md#namespaced-paths)。 |

如果成功，返回 [`200`](rest/troubleshooting.md#status-codes) 以及软件包保护规则列表。

可能返回以下状态码：

- `200 OK`：软件包保护规则列表。
- `401 Unauthorized`：访问令牌无效。
- `403 Forbidden`：用户无权列出此项目的软件包保护规则。
- `404 Not Found`：未找到项目。

示例请求：

```shell
curl --header "PRIVATE-TOKEN: <your_access_token>" \
  --url "https://gitlab.example.com/api/v4/projects/7/packages/protection/rules"
```

示例响应：

```json
[
 {
  "id": 1,
  "project_id": 7,
  "package_name_pattern": "@flightjs/flight-package-0",
  "package_type": "npm",
  "minimum_access_level_for_delete": "owner",
  "minimum_access_level_for_push": "maintainer"
 },
 {
  "id": 2,
  "project_id": 7,
  "package_name_pattern": "@flightjs/flight-package-1",
  "package_type": "npm",
  "minimum_access_level_for_delete": "owner",
  "minimum_access_level_for_push": "maintainer"
 }
]
```

<a id="create-a-package-protection-rule"></a>

## 创建软件包保护规则

为指定项目创建软件包保护规则。

```plaintext
POST /api/v4/projects/:id/packages/protection/rules
```

支持的属性：

| 属性                                 | 类型            | 是否必需 | 描述                    |
|--------------------------------------|-----------------|----------|--------------------------------|
| `id`                                 | 整数或字符串    | 是       | ID 或[项目的 URL 编码路径](rest/_index.md#namespaced-paths)。 |
| `package_name_pattern`               | 字符串          | 是       | 受保护规则保护的软件包名称。例如 `@my-scope/my-package-*`。允许使用通配符 `*`。 |
| `package_type`                       | 字符串          | 是       | 受保护规则保护的软件包类型。例如 `npm`。 |
| `minimum_access_level_for_delete`    | 字符串          | 是       | 删除软件包所需的最低极狐GitLab 访问级别。有效值包括 `null`、`owner` 或 `admin`。如果值为 `null`，则默认最低访问级别为 `maintainer`。当未设置 `minimum_access_level_for_push` 时必须提供。通过一个名为 `packages_protected_packages_delete` 的功能标志。默认禁用。 |
| `minimum_access_level_for_push`      | 字符串          | 是       | 推送软件包所需的最低极狐GitLab 访问级别。有效值包括 `null`、`maintainer`、`owner` 或 `admin`。如果值为 `null`，则默认最低访问级别为 `developer`。当未设置 `minimum_access_level_for_delete` 时必须提供。 |

如果成功，返回 [`201`](rest/troubleshooting.md#status-codes) 以及创建的软件包保护规则。

可能返回以下状态码：

- `201 Created`：软件包保护规则创建成功。
- `400 Bad Request`：软件包保护规则无效。
- `401 Unauthorized`：访问令牌无效。
- `403 Forbidden`：用户无权创建软件包保护规则。
- `404 Not Found`：未找到项目。
- `422 Unprocessable Entity`：无法创建软件包保护规则，例如 `package_name_pattern` 已被占用。

示例请求：

```shell
curl --request POST \
  --header "PRIVATE-TOKEN: <your_access_token>" \
  --header "Content-Type: application/json" \
  --url "https://gitlab.example.com/api/v4/projects/7/packages/protection/rules" \
  --data '{
       "package_name_pattern": "package-name-pattern-*",
       "package_type": "npm",
       "minimum_access_level_for_delete": "owner",
       "minimum_access_level_for_push": "maintainer"
    }'
```

<a id="update-a-package-protection-rule"></a>

## 更新软件包保护规则

更新指定项目的软件包保护规则。

```plaintext
PATCH /api/v4/projects/:id/packages/protection/rules/:package_protection_rule_id
```

支持的属性：

| 属性                                 | 类型            | 是否必需 | 描述                    |
|--------------------------------------|-----------------|----------|--------------------------------|
| `id`                                 | 整数或字符串    | 是       | ID 或[项目的 URL 编码路径](rest/_index.md#namespaced-paths)。 |
| `package_protection_rule_id`         | 整数            | 是       | 要更新的软件包保护规则的 ID。 |
| `package_name_pattern`               | 字符串          | 否       | 受保护规则保护的软件包名称。例如 `@my-scope/my-package-*`。允许使用通配符 `*`。 |
| `package_type`                       | 字符串          | 否       | 受保护规则保护的软件包类型。例如 `npm`。 |
| `minimum_access_level_for_delete`    | 字符串          | 否       | 删除软件包所需的最低极狐GitLab 访问级别。有效值包括 `null`、`owner` 或 `admin`。如果值为 `null`，则默认最低访问级别为 `maintainer`。当未设置 `minimum_access_level_for_push` 时必须提供。通过一个名为 `packages_protected_packages_delete` 的功能标志。默认禁用。 |
| `minimum_access_level_for_push`      | 字符串          | 否       | 推送软件包所需的最低极狐GitLab 访问级别。有效值包括 `null`、`maintainer`、`owner` 或 `admin`。如果值为 `null`，则默认最低访问级别为 `developer`。当未设置 `minimum_access_level_for_delete` 时必须提供。 |

如果成功，返回 [`200`](rest/troubleshooting.md#status-codes) 以及更新后的软件包保护规则。

可能返回以下状态码：

- `200 OK`：软件包保护规则已成功更新。
- `400 Bad Request`：更新无效。
- `401 Unauthorized`：访问令牌无效。
- `403 Forbidden`：用户无权更新软件包保护规则。
- `404 Not Found`：未找到项目。
- `422 Unprocessable Entity`：无法更新软件包保护规则，例如 `package_name_pattern` 已被占用。

示例请求：

```shell
curl --request PATCH \
  --header "PRIVATE-TOKEN: <your_access_token>" \
  --header "Content-Type: application/json" \
  --url "https://gitlab.example.com/api/v4/projects/7/packages/protection/rules/32" \
  --data '{
       "package_name_pattern": "new-package-name-pattern-*"
    }'
```

<a id="delete-a-package-protection-rule"></a>

## 删除软件包保护规则

从指定项目中删除软件包保护规则。

```plaintext
DELETE /api/v4/projects/:id/packages/protection/rules/:package_protection_rule_id
```

支持的属性：

| 属性                         | 类型            | 是否必需 | 描述                    |
|------------------------------|-----------------|----------|--------------------------------|
| `id`                         | 整数或字符串    | 是       | ID 或[项目的 URL 编码路径](rest/_index.md#namespaced-paths)。 |
| `package_protection_rule_id` | 整数            | 是       | 要删除的软件包保护规则的 ID。 |

如果成功，返回 [`204 No Content`](rest/troubleshooting.md#status-codes)。

可能返回以下状态码：

- `204 No Content`：软件包保护规则删除成功。
- `400 Bad Request`：`id` 或 `package_protection_rule_id` 缺失或无效。
- `401 Unauthorized`：访问令牌无效。
- `403 Forbidden`：用户无权删除软件包保护规则。
- `404 Not Found`：未找到项目或软件包保护规则。

示例请求：

```shell
curl --request DELETE --header "PRIVATE-TOKEN: <your_access_token>" \
  --url "https://gitlab.example.com/api/v4/projects/7/packages/protection/rules/32"
```