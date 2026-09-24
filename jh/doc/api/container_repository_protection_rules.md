---
stage: Package
group: Container Registry
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
description: Documentation for the REST API for container repository protection rules in GitLab.
title: 容器仓库保护规则 API
---

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: JihuLab.com，私有化部署

{{< /details >}}

{{< history >}}

- 在极狐GitLab 17.2 引入，[带有功能标志](../administration/feature_flags/_index.md) 命名为 `container_registry_protected_containers`。默认禁用。
- 在 JihuLab.com 上启用于极狐GitLab 17.8。
- 在极狐GitLab 17.8 上 GA。功能标志 `container_registry_protected_containers` 已移除。

{{< /history >}}

使用该 API 管理[容器仓库保护规则](../user/packages/container_registry/protected_container_tags.md)。

<a id="list-all-container-repository-protection-rules"></a>

## 列出所有容器仓库保护规则

列出指定项目的所有容器仓库保护规则。

```plaintext
GET /api/v4/projects/:id/registry/protection/repository/rules
```

支持的属性：

| 属性                     | 类型            | 是否必需 | 描述                    |
|-------------------------------|-----------------|----------|--------------------------------|
| `id`                          | 整数或字符串  | 是      | 项目 ID 或 [URL 编码路径](rest/_index.md#namespaced-paths)。 |

如果成功，返回 [`200`](rest/troubleshooting.md#status-codes) 以及容器仓库保护规则列表。

可能返回以下状态码：

- `200 OK`：保护规则列表。
- `401 Unauthorized`：访问令牌无效。
- `403 Forbidden`：用户没有权限列出该项目的保护规则。
- `404 Not Found`：未找到项目。

示例请求：

```shell
curl --header "PRIVATE-TOKEN: <your_access_token>" \
  --url "https://gitlab.example.com/api/v4/projects/7/registry/protection/repository/rules"
```

示例响应：

```json
[
  {
    "id": 1,
    "project_id": 7,
    "repository_path_pattern": "flightjs/flight0",
    "minimum_access_level_for_push": "maintainer",
    "minimum_access_level_for_delete": "maintainer"
  },
  {
    "id": 2,
    "project_id": 7,
    "repository_path_pattern": "flightjs/flight1",
    "minimum_access_level_for_push": "maintainer",
    "minimum_access_level_for_delete": "maintainer"
  }
]
```

<a id="create-a-container-repository-protection-rule"></a>

## 创建容器仓库保护规则

{{< history >}}

- 引入于极狐GitLab 17.2。

{{< /history >}}

为指定项目创建容器仓库保护规则。

```plaintext
POST /api/v4/projects/:id/registry/protection/repository/rules
```

支持的属性：

| 属性                         | 类型           | 是否必需 | 描述 |
|-----------------------------------|----------------|----------|-------------|
| `id`                              | 整数或字符串 | 是      | 项目 ID 或 [URL 编码路径](rest/_index.md#namespaced-paths)。 |
| `repository_path_pattern`         | 字符串         | 是      | 受保护规则保护的容器仓库路径模式。例如 `flight/flight-*`。允许使用通配符 `*`。 |
| `minimum_access_level_for_delete` | 字符串         | 否       | 删除容器镜像仓库中容器镜像所需的最低极狐GitLab 访问级别。例如 `维护者`、`所有者`、`管理员`。当未设置 `minimum_access_level_for_push` 时必须提供。 |
| `minimum_access_level_for_push`   | 字符串         | 否       | 推送容器镜像到容器镜像仓库所需的最低极狐GitLab 访问级别。例如 `维护者`、`所有者` 或 `管理员`。当未设置 `minimum_access_level_for_delete` 时必须提供。 |

如果成功，返回 [`201`](rest/troubleshooting.md#status-codes) 以及创建的容器仓库保护规则。

可能返回以下状态码：

- `201 Created`：保护规则成功创建。
- `400 Bad Request`：保护规则无效。
- `401 Unauthorized`：访问令牌无效。
- `403 Forbidden`：用户没有权限创建保护规则。
- `404 Not Found`：未找到项目。
- `422 Unprocessable Entity`：无法创建保护规则。例如，因为 `repository_path_pattern` 已被占用。

示例请求：

```shell
curl --request POST \
  --header "PRIVATE-TOKEN: <your_access_token>" \
  --header "Content-Type: application/json" \
  --url "https://gitlab.example.com/api/v4/projects/7/registry/protection/repository/rules" \
  --data '{
        "repository_path_pattern": "flightjs/flight-needs-to-be-a-unique-path",
        "minimum_access_level_for_push": "maintainer",
        "minimum_access_level_for_delete": "maintainer"
    }'
```

<a id="update-a-container-repository-protection-rule"></a>

## 更新容器仓库保护规则

{{< history >}}

- 引入于极狐GitLab 17.2。

{{< /history >}}

更新指定项目的容器仓库保护规则。

```plaintext
PATCH /api/v4/projects/:id/registry/protection/repository/rules/:protection_rule_id
```

支持的属性：

| 属性                         | 类型           | 是否必需 | 描述 |
|-----------------------------------|----------------|----------|-------------|
| `id`                              | 整数或字符串 | 是      | 项目 ID 或 [URL 编码路径](rest/_index.md#namespaced-paths)。 |
| `protection_rule_id`              | 整数        | 是      | 要更新的保护规则 ID。 |
| `minimum_access_level_for_delete` | 字符串         | 否       | 删除容器镜像仓库中容器镜像所需的最低极狐GitLab 访问级别。例如 `维护者`、`所有者`、`管理员`。当未设置 `minimum_access_level_for_push` 时必须提供。要取消该值，请使用空字符串 `""`。 |
| `minimum_access_level_for_push`   | 字符串         | 否       | 推送容器镜像到容器镜像仓库所需的最低极狐GitLab 访问级别。例如 `维护者`、`所有者` 或 `管理员`。当未设置 `minimum_access_level_for_delete` 时必须提供。要取消该值，请使用空字符串 `""`。 |
| `repository_path_pattern`         | 字符串         | 否       | 受保护规则保护的容器仓库路径模式。例如 `flight/flight-*`。允许使用通配符 `*`。 |

如果成功，返回 [`200`](rest/troubleshooting.md#status-codes) 以及更新后的保护规则。

可能返回以下状态码：

- `200 OK`：保护规则成功更新。
- `400 Bad Request`：保护规则无效。
- `401 Unauthorized`：访问令牌无效。
- `403 Forbidden`：用户没有权限更新保护规则。
- `404 Not Found`：未找到项目。
- `422 Unprocessable Entity`：无法更新保护规则。例如，因为 `repository_path_pattern` 已被占用。

示例请求：

```shell
curl --request PATCH \
  --header "PRIVATE-TOKEN: <your_access_token>" \
  --header "Content-Type: application/json" \
  --url "https://gitlab.example.com/api/v4/projects/7/registry/protection/repository/rules/32" \
  --data '{
       "repository_path_pattern": "flight/flight-*"
    }'
```

<a id="delete-a-container-repository-protection-rule"></a>

## 删除容器仓库保护规则

{{< history >}}

- 引入于极狐GitLab 17.4。

{{< /history >}}

删除指定的容器仓库保护规则。

```plaintext
DELETE /api/v4/projects/:id/registry/protection/repository/rules/:protection_rule_id
```

支持的属性：

| 属性            | 类型           | 是否必需 | 描述 |
|----------------------|----------------|----------|-------------|
| `id`                 | 整数或字符串 | 是      | 项目 ID 或 [URL 编码路径](rest/_index.md#namespaced-paths)。 |
| `protection_rule_id` | 整数        | 是      | 要删除的容器仓库保护规则 ID。 |

如果成功，返回 [`204 No Content`](rest/troubleshooting.md#status-codes)。

可能返回以下状态码：

- `204 No Content`：保护规则成功删除。
- `400 Bad Request`：`id` 或 `protection_rule_id` 缺失或无效。
- `401 Unauthorized`：访问令牌无效。
- `403 Forbidden`：用户没有权限删除保护规则。
- `404 Not Found`：未找到项目或保护规则。

示例请求：

```shell
curl --request DELETE \
  --header "PRIVATE-TOKEN: <your_access_token>" \
  --url "https://gitlab.example.com/api/v4/projects/7/registry/protection/repository/rules/1"
```