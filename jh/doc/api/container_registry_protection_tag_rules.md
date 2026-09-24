---
stage: Package
group: Container Registry
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
description: Documentation for the REST API for container registry protection tag rules in GitLab.
title: 容器镜像仓库保护标签规则 API
---

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: JihuLab.com，私有化部署

{{< /details >}}

{{< history >}}

- 在极狐GitLab 18.7 中引入。

{{< /history >}}

使用此 API 管理[受保护的容器标签](../user/packages/container_registry/protected_container_tags.md)。

<a id="list-container-registry-protection-tag-rules"></a>

## 列出容器镜像仓库保护标签规则

获取项目的容器镜像仓库保护标签规则列表。

```plaintext
GET /api/v4/projects/:id/registry/protection/tag/rules
```

支持的属性：

| 属性 | 类型 | 必需 | 描述 |
|-----------|-------------------|----------|---------------------------------------------------------------------------------|
| `id` | 整数或字符串 | 是 | 项目的 ID 或 [URL 编码路径](rest/_index.md#namespaced-paths)。 |

如果成功，返回 [`200 OK`](rest/troubleshooting.md#status-codes) 并包含以下响应属性：

| 属性 | 类型 | 描述 |
|-----------|------|-------------|
| `id` | 整数 | 受保护容器标签规则的 ID。 |
| `minimum_access_level_for_delete` | 字符串 | 删除标签所需的最低访问级别。可能的值：`维护者`、`所有者`或 `管理员`。 |
| `minimum_access_level_for_push` | 字符串 | 推送标签所需的最低访问级别。可能的值：`维护者`、`所有者`或 `管理员`。 |
| `project_id` | 整数 | 项目的 ID。 |
| `tag_name_pattern` | 字符串 | 标签名称模式。例如，`v*-release` 或 `latest`。 |

可返回以下状态码：

- `200 OK`：保护规则列表。
- `401 Unauthorized`：访问令牌无效。
- `403 Forbidden`：用户无权列出此项目的保护规则。
- `404 Not Found`：未找到项目。

示例请求：

```shell
curl --header "PRIVATE-TOKEN: <your_access_token>" \
  --url "https://gitlab.example.com/api/v4/projects/7/registry/protection/tag/rules"
```

示例响应：

```json
[
  {
    "id": 1,
    "project_id": 7,
    "tag_name_pattern": "v*-release",
    "minimum_access_level_for_push": "maintainer",
    "minimum_access_level_for_delete": "maintainer"
  },
  {
    "id": 2,
    "project_id": 7,
    "tag_name_pattern": "latest",
    "minimum_access_level_for_push": "owner",
    "minimum_access_level_for_delete": "owner"
  }
]
```

<a id="create-a-container-registry-protection-tag-rule"></a>

## 创建容器镜像仓库保护标签规则

{{< history >}}

- 在极狐GitLab 18.8 中引入。

{{< /history >}}

为项目创建容器镜像仓库保护标签规则。

```plaintext
POST /api/v4/projects/:id/registry/protection/tag/rules
```

支持的属性：

| 属性 | 类型 | 必需 | 描述 |
|-----------|------|----------|-------------|
| `id` | 整数或字符串 | 是 | 项目的 ID 或 [URL 编码路径](rest/_index.md#namespaced-paths)。 |
| `tag_name_pattern` | 字符串 | 是 | 由保护规则保护的容器标签名称模式。例如，`v*-release`。支持通配符 `*`。 |
| `minimum_access_level_for_push` | 字符串 | 是 | 推送容器标签所需的最低极狐GitLab 访问级别。可能的值：`维护者`、`所有者`或 `管理员`。 |
| `minimum_access_level_for_delete` | 字符串 | 是 | 删除容器标签所需的最低极狐GitLab 访问级别。可能的值：`维护者`、`所有者`或 `管理员`。 |

如果成功，返回 [`201 Created`](rest/troubleshooting.md#status-codes) 并包含以下响应属性：

| 属性 | 类型 | 描述 |
|-----------|------|-------------|
| `id` | 整数 | 容器标签规则的唯一标识符。 |
| `project_id` | 整数 | 此容器标签规则所属项目的 ID。 |
| `tag_name_pattern` | 字符串 | 用于匹配容器标签名称的 glob 模式。例如，`v*-release`。 |
| `minimum_access_level_for_push` | 字符串 | 推送符合该模式的容器标签所需的最低访问级别。可能的值：`维护者`、`所有者`或 `管理员`。 |
| `minimum_access_level_for_delete` | 字符串 | 删除符合该模式的容器标签所需的最低访问级别。可能的值：`维护者`、`所有者`或 `管理员`。 |

可返回以下状态码：

- `201 Created`：保护规则已成功创建。
- `400 Bad Request`：保护规则无效。
- `401 Unauthorized`：访问令牌无效。
- `403 Forbidden`：用户无权创建保护规则。
- `404 Not Found`：未找到项目。
- `422 Unprocessable Entity`：保护规则无法创建。例如，`tag_name_pattern` 已被占用。

示例请求：

```shell
curl --request POST \
  --header "PRIVATE-TOKEN: <your_access_token>" \
  --header "Content-Type: application/json" \
  --url "https://gitlab.example.com/api/v4/projects/7/registry/protection/tag/rules" \
  --data '{
        "tag_name_pattern": "v*-release",
        "minimum_access_level_for_push": "maintainer",
        "minimum_access_level_for_delete": "maintainer"
    }'
```

示例响应：

```json
{
  "id": 1,
  "project_id": 7,
  "tag_name_pattern": "v*-release",
  "minimum_access_level_for_push": "maintainer",
  "minimum_access_level_for_delete": "maintainer"
}
```

<a id="update-a-container-registry-protection-tag-rule"></a>

## 更新容器镜像仓库保护标签规则

{{< history >}}

- 在极狐GitLab 18.9 中引入。

{{< /history >}}

更新项目的容器镜像仓库保护标签规则。

```plaintext
PATCH /api/v4/projects/:id/registry/protection/tag/rules/:protection_rule_id
```

支持的属性：

| 属性 | 类型 | 必需 | 描述 |
|-----------|------|----------|-------------|
| `id` | 整数或字符串 | 是 | 项目的 ID 或 [URL 编码路径](rest/_index.md#namespaced-paths)。 |
| `protection_rule_id` | 整数 | 是 | 要更新的保护标签规则的 ID。 |
| `minimum_access_level_for_delete` | 字符串 | 否 | 删除容器标签所需的最低访问级别。可能的值：`维护者`、`所有者`或 `管理员`。要取消设置，请使用空字符串（`""`）。 |
| `minimum_access_level_for_push` | 字符串 | 否 | 推送容器标签所需的最低访问级别。可能的值：`维护者`、`所有者`或 `管理员`。要取消设置，请使用空字符串（`""`）。 |
| `tag_name_pattern` | 字符串 | 否 | 由保护规则保护的容器标签名称模式。例如，`v*-release`。支持通配符 `*`。 |

如果成功，返回 [`200 OK`](rest/troubleshooting.md#status-codes) 并包含以下响应属性：

| 属性 | 类型 | 描述 |
|-----------|------|-------------|
| `id` | 整数 | 容器标签规则的唯一标识符。 |
| `project_id` | 整数 | 此容器标签规则所属项目的 ID。 |
| `tag_name_pattern` | 字符串 | 用于匹配容器标签名称的 glob 模式。例如，`v*-release`。 |
| `minimum_access_level_for_push` | 字符串 | 推送符合该模式的容器标签所需的最低访问级别。可能的值：`维护者`、`所有者`或 `管理员`。 |
| `minimum_access_level_for_delete` | 字符串 | 删除符合该模式的容器标签所需的最低访问级别。可能的值：`维护者`、`所有者`或 `管理员`。 |

可返回以下状态码：

- `200 OK`：保护规则已成功更新。
- `400 Bad Request`：保护规则无效。
- `401 Unauthorized`：访问令牌无效。
- `403 Forbidden`：用户无权更新保护规则。
- `404 Not Found`：未找到项目。
- `422 Unprocessable Entity`：保护规则无法更新。例如，`tag_name_pattern` 已被占用。

示例请求：

```shell
curl --request PATCH \
  --header "PRIVATE-TOKEN: <your_access_token>" \
  --header "Content-Type: application/json" \
  --url "https://gitlab.example.com/api/v4/projects/7/registry/protection/tag/rules/1" \
  --data '{
       "tag_name_pattern": "v*-stable"
    }'
```

示例响应：

```json
{
  "id": 1,
  "project_id": 7,
  "tag_name_pattern": "v*-stable",
  "minimum_access_level_for_push": "maintainer",
  "minimum_access_level_for_delete": "maintainer"
}
```

<a id="delete-a-container-registry-protection-tag-rule"></a>

## 删除容器镜像仓库保护标签规则

{{< history >}}

- 在极狐GitLab 18.9 中引入。

{{< /history >}}

从项目中删除容器镜像仓库保护标签规则。

```plaintext
DELETE /api/v4/projects/:id/registry/protection/tag/rules/:protection_rule_id
```

支持的属性：

| 属性 | 类型 | 必需 | 描述 |
|-----------|------|----------|-------------|
| `id` | 整数或字符串 | 是 | 项目的 ID 或 [URL 编码路径](rest/_index.md#namespaced-paths)。 |
| `protection_rule_id` | 整数 | 是 | 要删除的容器镜像仓库保护标签规则的 ID。 |

如果成功，返回 [`204 No Content`](rest/troubleshooting.md#status-codes)。

可返回以下状态码：

- `204 No Content`：保护规则已成功删除。
- `400 Bad Request`：`id` 或 `protection_rule_id` 缺失或无效。
- `401 Unauthorized`：访问令牌无效。
- `403 Forbidden`：用户无权删除保护规则。
- `404 Not Found`：未找到项目或保护规则。

示例请求：

```shell
curl --request DELETE \
  --header "PRIVATE-TOKEN: <your_access_token>" \
  --url "https://gitlab.example.com/api/v4/projects/7/registry/protection/tag/rules/1"
```