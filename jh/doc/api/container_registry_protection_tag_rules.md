---
stage: Package
group: Container Registry
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
description: 极狐GitLab 中容器镜像仓库保护标签规则 REST API 的文档。
title: 容器镜像仓库保护标签规则 API
---

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: JihuLab.com，私有化部署

{{< /details >}}

使用此 API 管理[受保护的容器标签](../user/packages/container_registry/protected_container_tags.md)。

<a id="list-container-registry-protection-tag-rules"></a>

## 列出容器镜像仓库保护标签规则

获取项目的容器镜像仓库保护标签规则列表。

```plaintext
GET /api/v4/projects/:id/registry/protection/tag/rules
```

支持的属性：

| 属性 | 类型              | 是否必需 | 描述                                                                     |
|-----------|-------------------|----------|---------------------------------------------------------------------------------|
| `id`      | integer or string | 是      | 项目的 ID 或 [URL 编码路径](rest/_index.md#namespaced-paths)。      |

如果成功，返回 [`200 OK`](rest/troubleshooting.md#status-codes) 以及以下响应属性：

| 属性 | 类型 | 描述 |
|-----------|------|-------------|
| `id` | integer | 受保护容器标签规则的 ID。 |
| `minimum_access_level_for_delete` | string | 删除标签所需的最低访问级别。可能的值：`maintainer`、`owner` 或 `admin`。 |
| `minimum_access_level_for_push` | string | 推送标签所需的最低访问级别。可能的值：`maintainer`、`owner` 或 `admin`。 |
| `project_id` | integer | 项目的 ID。 |
| `tag_name_pattern` | string | 标签名称模式。例如，`v*-release` 或 `latest`。 |

可能返回以下状态码：

- `200 OK`：保护规则列表。
- `401 Unauthorized`：访问令牌无效。
- `403 Forbidden`：该用户没有权限列出此项目的保护规则。
- `404 Not Found`：未找到该项目。

示例请求：

```shell
curl --request GET \
  --header "PRIVATE-TOKEN: <your_access_token>" \
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

为项目创建容器镜像仓库保护标签规则。

```plaintext
POST /api/v4/projects/:id/registry/protection/tag/rules
```

支持的属性：

| 属性 | 类型 | 是否必需 | 描述 |
|-----------|------|----------|-------------|
| `id` | integer or string | 是 | 项目的 ID 或 [URL 编码路径](rest/_index.md#namespaced-paths)。 |
| `tag_name_pattern` | string | 是 | 由保护规则保护的容器标签名称模式。例如，`v*-release`。允许使用通配符 `*`。 |
| `minimum_access_level_for_push` | string | 是 | 推送容器标签所需的最低极狐GitLab 访问级别。可能的值：`maintainer`、`owner` 或 `admin`。 |
| `minimum_access_level_for_delete` | string | 是 | 删除容器标签所需的最低极狐GitLab 访问级别。可能的值：`maintainer`、`owner` 或 `admin`。 |

如果成功，返回 [`201 Created`](rest/troubleshooting.md#status-codes) 以及以下响应属性：

| 属性 | 类型 | 描述 |
|-----------|------|-------------|
| `id` | integer | 容器标签规则的唯一标识符。 |
| `project_id` | integer | 此容器标签规则所属项目的 ID。 |
| `tag_name_pattern` | string | 用于匹配容器标签名称的 glob 模式。例如，`v*-release`。 |
| `minimum_access_level_for_push` | string | 推送匹配此模式的容器标签所需的最低访问级别。可能的值：`maintainer`、`owner` 或 `admin`。 |
| `minimum_access_level_for_delete` | string | 删除匹配此模式的容器标签所需的最低访问级别。可能的值：`maintainer`、`owner` 或 `admin`。 |

可能返回以下状态码：

- `201 Created`：保护规则创建成功。
- `400 Bad Request`：保护规则无效。
- `401 Unauthorized`：访问令牌无效。
- `403 Forbidden`：该用户没有权限创建保护规则。
- `404 Not Found`：未找到该项目。
- `422 Unprocessable Entity`：无法创建保护规则。例如，因为 `tag_name_pattern` 已被占用。

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

更新项目的容器镜像仓库保护标签规则。

```plaintext
PATCH /api/v4/projects/:id/registry/protection/tag/rules/:protection_rule_id
```

支持的属性：

| 属性 | 类型 | 是否必需 | 描述 |
|-----------|------|----------|-------------|
| `id` | integer or string | 是 | 项目的 ID 或 [URL 编码路径](rest/_index.md#namespaced-paths)。 |
| `protection_rule_id` | integer | 是 | 要更新的保护标签规则的 ID。 |
| `minimum_access_level_for_delete` | string | 否 | 删除容器标签所需的最低访问级别。可能的值：`maintainer`、`owner` 或 `admin`。要取消设置该值，请使用空字符串（`""`）。 |
| `minimum_access_level_for_push` | string | 否 | 推送容器标签所需的最低访问级别。可能的值：`maintainer`、`owner` 或 `admin`。要取消设置该值，请使用空字符串（`""`）。 |
| `tag_name_pattern` | string | 否 | 由保护规则保护的容器标签名称模式。例如，`v*-release`。允许使用通配符 `*`。 |

如果成功，返回 [`200 OK`](rest/troubleshooting.md#status-codes) 以及以下响应属性：

| 属性 | 类型 | 描述 |
|-----------|------|-------------|
| `id` | integer | 容器标签规则的唯一标识符。 |
| `project_id` | integer | 此容器标签规则所属项目的 ID。 |
| `tag_name_pattern` | string | 用于匹配容器标签名称的 glob 模式。例如，`v*-release`。 |
| `minimum_access_level_for_push` | string | 推送匹配此模式的容器标签所需的最低访问级别。可能的值：`maintainer`、`owner` 或 `admin`。 |
| `minimum_access_level_for_delete` | string | 删除匹配此模式的容器标签所需的最低访问级别。可能的值：`maintainer`、`owner` 或 `admin`。 |

可能返回以下状态码：

- `200 OK`：保护规则更新成功。
- `400 Bad Request`：保护规则无效。
- `401 Unauthorized`：访问令牌无效。
- `403 Forbidden`：该用户没有权限更新保护规则。
- `404 Not Found`：未找到该项目。
- `422 Unprocessable Entity`：无法更新保护规则。例如，因为 `tag_name_pattern` 已被占用。

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

从项目中删除容器镜像仓库保护标签规则。

```plaintext
DELETE /api/v4/projects/:id/registry/protection/tag/rules/:protection_rule_id
```

支持的属性：

| 属性 | 类型 | 是否必需 | 描述 |
|-----------|------|----------|-------------|
| `id` | integer or string | 是 | 项目的 ID 或 [URL 编码路径](rest/_index.md#namespaced-paths)。 |
| `protection_rule_id` | integer | 是 | 要删除的容器镜像仓库保护标签规则的 ID。 |

如果成功，返回 [`204 No Content`](rest/troubleshooting.md#status-codes)。

可能返回以下状态码：

- `204 No Content`：保护规则删除成功。
- `400 Bad Request`：缺少 `id` 或 `protection_rule_id`，或者它们无效。
- `401 Unauthorized`：访问令牌无效。
- `403 Forbidden`：该用户没有权限删除保护规则。
- `404 Not Found`：未找到该项目或保护规则。

示例请求：

```shell
curl --request DELETE \
  --header "PRIVATE-TOKEN: <your_access_token>" \
  --url "https://gitlab.example.com/api/v4/projects/7/registry/protection/tag/rules/1"
```
