---
stage: Package
group: Container Registry
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
title: 容器虚拟注册表 API
description: 创建和管理容器镜像仓库的虚拟注册表，以及配置上游容器镜像仓库。
---

{{< details >}}

- Tier: 专业版，旗舰版
- Offering: JihuLab.com，私有化部署
- Status: Beta

{{< /details >}}

{{< history >}}

- 在极狐GitLab 18.5 [通过一个功能标志](../administration/feature_flags/_index.md)引入，名为 `container_virtual_registries`。默认禁用。
- 在极狐GitLab 18.9 中从实验阶段变更为测试阶段。
- 在极狐GitLab 18.10 中在 JihuLab.com 和私有化部署上启用。

{{< /history >}}

> [!flag]
> 这些端点的可用性由功能标志控制。
> 更多信息，请参见历史记录。

使用此 API 可以：

- 为容器镜像仓库创建和管理虚拟注册表。
- 配置上游容器镜像仓库。
- 管理缓存的容器镜像和清单。

有关通过虚拟注册表拉取容器镜像的信息，请参见
[容器虚拟注册表](../user/packages/virtual_registry/container/_index.md)。

> [!note]
> 不支持云提供商注册表，但议题 20919 提议更改此行为。

<a id="manage-virtual-registries"></a>

## 管理虚拟注册表

使用以下端点创建和管理容器镜像仓库的虚拟注册表。

<a id="list-all-virtual-registries"></a>

### 列出所有虚拟注册表

列出一个群组的所有容器虚拟注册表。

```plaintext
GET /groups/:id/-/virtual_registries/container/registries
```

支持的属性：

| 属性 | 类型 | 必需 | 描述 |
|:----------|:-----|:---------|:------------|
| `id` | 字符串或整数 | 是 | 群组 ID 或完整群组路径。必须是顶级群组。 |

请求示例：

```shell
curl --header "PRIVATE-TOKEN: <your_access_token>" \
     --header "Accept: application/json" \
     --url "https://gitlab.example.com/api/v4/groups/5/-/virtual_registries/container/registries"
```

响应示例：

```json
[
  {
    "id": 1,
    "group_id": 5,
    "name": "my-container-virtual-registry",
    "description": "My container virtual registry",
    "created_at": "2024-05-30T12:28:27.855Z",
    "updated_at": "2024-05-30T12:28:27.855Z"
  }
]
```

<a id="create-a-virtual-registry"></a>

### 创建虚拟注册表

为一个群组创建容器虚拟注册表。

```plaintext
POST /groups/:id/-/virtual_registries/container/registries
```

| 属性 | 类型 | 必需 | 描述 |
| --------- | ---- | -------- | ----------- |
| `id` | 字符串或整数 | 是 | 群组 ID 或完整群组路径。必须是顶级群组。 |
| `name` | 字符串 | 是 | 虚拟注册表的名称。 |
| `description` | 字符串 | 否 | 虚拟注册表的描述。 |

> [!note]
> 每个群组最多可以创建 5 个虚拟注册表。

请求示例：

```shell
curl --request POST \
     --header "PRIVATE-TOKEN: <your_access_token>" \
     --header "Content-Type: application/json" \
     --header "Accept: application/json" \
     --data '{"name": "my-container-virtual-registry", "description": "My container virtual registry"}' \
     --url "https://gitlab.example.com/api/v4/groups/5/-/virtual_registries/container/registries"
```

响应示例：

```json
{
  "id": 1,
  "group_id": 5,
  "name": "my-container-virtual-registry",
  "description": "My container virtual registry",
  "created_at": "2024-05-30T12:28:27.855Z",
  "updated_at": "2024-05-30T12:28:27.855Z"
}
```

<a id="retrieve-a-virtual-registry"></a>

### 获取虚拟注册表

获取指定的容器虚拟注册表。

```plaintext
GET /virtual_registries/container/registries/:id
```

参数：

| 属性 | 类型 | 必需 | 描述 |
| --------- | ---- | -------- | ----------- |
| `id` | 整数 | 是 | 容器虚拟注册表的 ID。 |

请求示例：

```shell
curl --header "PRIVATE-TOKEN: <your_access_token>" \
     --header "Accept: application/json" \
     --url "https://gitlab.example.com/api/v4/virtual_registries/container/registries/1"
```

响应示例：

```json
{
  "id": 1,
  "group_id": 5,
  "name": "my-container-virtual-registry",
  "description": "My container virtual registry",
  "created_at": "2024-05-30T12:28:27.855Z",
  "updated_at": "2024-05-30T12:28:27.855Z",
  "registry_upstreams": [
    {
      "id": 2,
      "position": 1,
      "upstream_id": 2
    }
  ]
}
```

<a id="update-a-virtual-registry"></a>

### 更新虚拟注册表

更新指定的容器虚拟注册表。

```plaintext
PATCH /virtual_registries/container/registries/:id
```

| 属性 | 类型 | 必需 | 描述 |
| --------- | ---- | -------- | ----------- |
| `id` | 整数 | 是 | 容器虚拟注册表的 ID。 |
| `description` | 字符串 | 否 | 虚拟注册表的描述。 |
| `name` | 字符串 | 否 | 虚拟注册表的名称。 |

> [!note]
> 你必须在请求中提供至少一个可选参数（`name` 或 `description`）。

请求示例：

```shell
curl --request PATCH \
     --header "PRIVATE-TOKEN: <your_access_token>" \
     --header "Content-Type: application/json" \
     --data '{"name": "my-container-virtual-registry", "description": "My container virtual registry"}' \
     --url "https://gitlab.example.com/api/v4/virtual_registries/container/registries/1"
```

如果成功，返回 [`200 OK`](rest/troubleshooting.md#status-codes) 状态码。

<a id="delete-a-virtual-registry"></a>

### 删除虚拟注册表

> [!warning]
> 当你删除一个虚拟注册表时，你也会删除所有未与其他虚拟注册表共享的关联上游注册表，及其缓存的容器镜像和清单。

删除指定的容器虚拟注册表。

```plaintext
DELETE /virtual_registries/container/registries/:id
```

| 属性 | 类型 | 必需 | 描述 |
| --------- | ---- | -------- | ----------- |
| `id` | 整数 | 是 | 容器虚拟注册表的 ID。 |

请求示例：

```shell
curl --request DELETE --header "PRIVATE-TOKEN: <your_access_token>" \
     --header "Accept: application/json" \
     --url "https://gitlab.example.com/api/v4/virtual_registries/container/registries/1"
```

如果成功，返回 [`204 No Content`](rest/troubleshooting.md#status-codes) 状态码。

<a id="delete-cache-entries-for-a-virtual-registry"></a>

### 删除虚拟注册表的缓存条目

{{< history >}}

- 在极狐GitLab 18.7 [通过一个功能标志](../administration/feature_flags/_index.md)引入，名为 `container_virtual_registries`。默认禁用。
- 在极狐GitLab 18.9 中从实验阶段变更为测试阶段。
- 在极狐GitLab 18.10 中在 JihuLab.com 和私有化部署上启用。

{{< /history >}}

安排删除容器虚拟注册表的所有独占上游注册表中的所有缓存条目。对于与其他虚拟注册表关联的上游注册表，不会安排删除其缓存条目。

```plaintext
DELETE /virtual_registries/container/registries/:id/cache
```

| 属性 | 类型 | 必需 | 描述 |
| --------- | ---- | -------- | ----------- |
| `id` | 整数 | 是 | 容器虚拟注册表的 ID。 |

请求示例：

```shell
curl --request DELETE --header "PRIVATE-TOKEN: <your_access_token>" \
     --header "Accept: application/json" \
     --url "https://gitlab.example.com/api/v4/virtual_registries/container/registries/1/cache"
```

如果成功，返回 [`204 No Content`](rest/troubleshooting.md#status-codes) 状态码。

<a id="manage-upstream-registries"></a>

## 管理上游注册表

使用以下端点配置和管理上游容器镜像仓库。

<a id="list-all-upstream-registries-for-a-top-level-group"></a>

### 列出顶级群组的所有上游注册表

列出顶级群组的所有上游容器镜像仓库。

```plaintext
GET /groups/:id/-/virtual_registries/container/upstreams
```

支持的属性：

| 属性 | 类型 | 必需 | 描述 |
|:----------|:-----|:---------|:------------|
| `id` | 字符串或整数 | 是 | 群组 ID 或完整群组路径。必须是顶级群组。 |
| `page` | 整数 | 否 | 页码。默认为 1。 |
| `per_page` | 整数 | 否 | 每页条数。默认为 20。 |
| `upstream_name` | 字符串 | 否 | 用于按名称进行模糊搜索过滤的上游注册表名称。 |

请求示例：

```shell
curl --header "PRIVATE-TOKEN: <your_access_token>" \
     --header "Accept: application/json" \
     --url "https://gitlab.example.com/api/v4/groups/5/-/virtual_registries/container/upstreams"
```

响应示例：

```json
[
  {
    "id": 1,
    "group_id": 5,
    "url": "https://registry-1.docker.io",
    "name": "Docker Hub",
    "description": "Docker Hub registry",
    "cache_validity_hours": 24,
    "username": "user",
    "created_at": "2024-05-30T12:28:27.855Z",
    "updated_at": "2024-05-30T12:28:27.855Z"
  }
]
```

<a id="test-connection-before-creating-an-upstream-registry"></a>

### 在创建上游注册表之前测试连接

{{< history >}}

- 在极狐GitLab 18.9 [通过一个功能标志](../administration/feature_flags/_index.md)引入，名为 `container_virtual_registries`。默认禁用。
- 在极狐GitLab 18.9 中从实验阶段变更为测试阶段。
- 在极狐GitLab 18.10 中在 JihuLab.com 和私有化部署上启用。

{{< /history >}}

测试到尚未添加到虚拟注册表的容器上游注册表的连接。此端点会在创建上游注册表之前验证连通性和凭据。

```plaintext
POST /groups/:id/-/virtual_registries/container/upstreams/test
```

支持的属性：

| 属性 | 类型 | 必需 | 描述 |
|:----------|:-----|:---------|:------------|
| `id` | 字符串或整数 | 是 | 群组 ID 或完整群组路径。必须是顶级群组。 |
| `url` | 字符串 | 是 | 上游注册表的 URL。 |
| `password` | 字符串 | 否 | 上游注册表的密码。 |
| `username` | 字符串 | 否 | 上游注册表的用户名。 |

> [!note]
> 你必须同时在请求中包含 `username` 和 `password`，或者两者都不包含。如果不设置，则使用公共（匿名）请求访问上游。

#### 测试工作流

`test` 端点使用测试路径向提供的上游 URL 发送 HEAD 请求，以验证连通性和身份验证。从 HEAD 请求收到的响应解释如下：

<a id="test-workflow"></a>

| 上游响应 | 描述 | 结果 |
|:------------------|:--------|:-------|
| 2XX | 成功。上游可访问 | `{ "success": true }` |
| 404 | 成功。上游可访问，但未找到测试制品 | `{ "success": true }` |
| 401 | 身份验证失败 | `{ "success": false, "result": "错误：401 - 未授权" }` |
| 403 | 禁止访问 | `{ "success": false, "result": "错误：403 - 禁止访问" }` |
| 5XX | 上游服务器错误 | `{ "success": false, "result": "错误：5XX - 服务器错误" }` |
| 网络错误 | 连接/超时问题 | `{ "success": false, "result": "错误：连接超时" }` |

请求示例：

```shell
curl --request POST \
     --header "PRIVATE-TOKEN: <your_access_token>" \
     --header "Content-Type: application/json" \
     --url "https://gitlab.example.com/api/v4/groups/5/-/virtual_registries/container/upstreams/test"
     --data '{"url": "https://registry-1.docker.io", "username": "<your_username>", "password": "<your_password>"}' \
```

响应示例：

```json
{
  "success": true
}
```

> [!note]
> 上游注册表返回的 `2XX`（已找到）和 `404 Not Found` HTTP 状态码均被视为成功响应，因为这表明上游可访问且配置正确。

<a id="list-all-upstream-registries-for-a-virtual-registry"></a>

### 列出虚拟注册表的所有上游注册表

列出容器虚拟注册表的所有上游注册表。

```plaintext
GET /virtual_registries/container/registries/:id/upstreams
```

支持的属性：

| 属性 | 类型 | 必需 | 描述 |
|:----------|:-----|:---------|:------------|
| `id` | 整数 | 是 | 容器虚拟注册表的 ID。 |

请求示例：

```shell
curl --header "PRIVATE-TOKEN: <your_access_token>" \
     --header "Accept: application/json" \
     --url "https://gitlab.example.com/api/v4/virtual_registries/container/registries/1/upstreams"
```

响应示例：

```json
[
  {
    "id": 1,
    "group_id": 5,
    "url": "https://registry-1.docker.io",
    "name": "Docker Hub",
    "description": "Docker Hub registry",
    "cache_validity_hours": 24,
    "username": "user",
    "created_at": "2024-05-30T12:28:27.855Z",
    "updated_at": "2024-05-30T12:28:27.855Z",
    "registry_upstream": {
      "id": 1,
      "registry_id": 1,
      "position": 1
    }
  }
]
```

<a id="create-an-upstream-registry"></a>

### 创建上游注册表

为指定的容器虚拟注册表创建上游容器镜像仓库。

```plaintext
POST /virtual_registries/container/registries/:id/upstreams
```

| 属性 | 类型 | 必需 | 描述 |
| --------- | ---- | -------- | ----------- |
| `id` | 整数 | 是 | 容器虚拟注册表的 ID。 |
| `url` | 字符串 | 是 | 上游容器镜像仓库的 URL。 |
| `name` | 字符串 | 是 | 上游注册表的名称。 |
| `cache_validity_hours` | 整数 | 否 | 容器镜像的缓存有效期。默认为 24 小时。 |
| `description` | 字符串 | 否 | 上游注册表的描述。 |
| `password` | 字符串 | 否 | 上游注册表的密码。 |
| `username` | 字符串 | 否 | 上游注册表的用户名。 |

> [!note]
> 你必须同时在请求中包含 `username` 和 `password`，或者完全不包含。如果不设置，则使用公共（匿名）请求访问上游。

你不能将具有相同 URL 和凭据（`username` 和 `password`）的两个上游添加到同一个顶级群组。相反，你可以：

- 为同一 URL 的每个上游设置不同的凭据。
- 将一个上游与多个虚拟注册表关联。

> [!note]
> 每个虚拟注册表最多可以添加 5 个上游注册表。

请求示例：

```shell
curl --request POST --header "PRIVATE-TOKEN: <your_access_token>" \
     --header "Content-Type: application/json" \
     --data '{"url": "https://registry-1.docker.io", "name": "Docker Hub", "description": "Docker Hub registry", "username": "<your_username>", "password": "<your_password>", "cache_validity_hours": 48}' \
     --url "https://gitlab.example.com/api/v4/virtual_registries/container/registries/1/upstreams"
```

响应示例：

```json
{
  "id": 1,
  "group_id": 5,
  "url": "https://registry-1.docker.io",
  "name": "Docker Hub",
  "description": "Docker Hub registry",
  "cache_validity_hours": 48,
  "username": "user",
  "created_at": "2024-05-30T12:28:27.855Z",
  "updated_at": "2024-05-30T12:28:27.855Z",
  "registry_upstream": {
    "id": 1,
    "registry_id": 1,
    "position": 1
  }
}
```

<a id="retrieve-an-upstream-registry"></a>

### 获取上游注册表

获取指定的上游容器镜像仓库。

```plaintext
GET /virtual_registries/container/upstreams/:id
```

参数：

| 属性 | 类型 | 必需 | 描述 |
| --------- | ---- | -------- | ----------- |
| `id` | 整数 | 是 | 上游注册表的 ID。 |

请求示例：

```shell
curl --header "PRIVATE-TOKEN: <your_access_token>" \
     --header "Accept: application/json" \
     --url "https://gitlab.example.com/api/v4/virtual_registries/container/upstreams/1"
```

响应示例：

```json
{
  "id": 1,
  "group_id": 5,
  "url": "https://registry-1.docker.io",
  "name": "Docker Hub",
  "description": "Docker Hub registry",
  "cache_validity_hours": 24,
  "username": "user",
  "created_at": "2024-05-30T12:28:27.855Z",
  "updated_at": "2024-05-30T12:28:27.855Z",
  "registry_upstreams": [
    {
      "id": 1,
      "registry_id": 1,
      "position": 1
    }
  ]
}
```

<a id="update-an-upstream-registry"></a>

### 更新上游注册表

更新指定的上游容器镜像仓库。

```plaintext
PATCH /virtual_registries/container/upstreams/:id
```

| 属性 | 类型 | 必需 | 描述 |
| --------- | ---- | -------- | ----------- |
| `id` | 整数 | 是 | 上游注册表的 ID。 |
| `cache_validity_hours` | 整数 | 否 | 容器镜像的缓存有效期。默认为 24 小时。 |
| `description` | 字符串 | 否 | 上游注册表的描述。 |
| `name` | 字符串 | 否 | 上游注册表的名称。 |
| `password` | 字符串 | 否 | 上游注册表的密码。 |
| `url` | 字符串 | 否 | 上游注册表的 URL。 |
| `username` | 字符串 | 否 | 上游注册表的用户名。 |

> [!note]
> 你必须在请求中提供至少一个可选参数。
>
> `username` 和 `password` 必须同时提供，或者完全不提供。如果不设置，则使用公共（匿名）请求访问上游。

请求示例：

```shell
curl --request PATCH --header "PRIVATE-TOKEN: <your_access_token>" \
     --header "Content-Type: application/json" \
     --data '{"cache_validity_hours": 72}' \
     --url "https://gitlab.example.com/api/v4/virtual_registries/container/upstreams/1"
```

如果成功，返回 [`200 OK`](rest/troubleshooting.md#status-codes) 状态码。

<a id="update-an-upstream-registry-position"></a>

### 更新上游注册表位置

更新容器虚拟注册表的有序列表中上游容器镜像仓库的位置。

```plaintext
PATCH /virtual_registries/container/registry_upstreams/:id
```

| 属性 | 类型 | 必需 | 描述 |
| --------- | ---- | -------- | ----------- |
| `id` | 整数 | 是 | 上游注册表关联的 ID。 |
| `position` | 整数 | 是 | 上游注册表的位置。介于 1 到 20 之间。 |

请求示例：

```shell
curl --request PATCH --header "PRIVATE-TOKEN: <your_access_token>" \
     --header "Content-Type: application/json" \
     --data '{"position": 5}' \
     --url "https://gitlab.example.com/api/v4/virtual_registries/container/registry_upstreams/1"
```

如果成功，返回 [`200 OK`](rest/troubleshooting.md#status-codes) 状态码。

<a id="delete-an-upstream-registry"></a>

### 删除上游注册表

删除指定的上游容器镜像仓库。

```plaintext
DELETE /virtual_registries/container/upstreams/:id
```

| 属性 | 类型 | 必需 | 描述 |
| --------- | ---- | -------- | ----------- |
| `id` | 整数 | 是 | 上游注册表的 ID。 |

请求示例：

```shell
curl --request DELETE --header "PRIVATE-TOKEN: <your_access_token>" \
     --header "Accept: application/json" \
     --url "https://gitlab.example.com/api/v4/virtual_registries/container/upstreams/1"
```

如果成功，返回 [`204 No Content`](rest/troubleshooting.md#status-codes) 状态码。

<a id="associate-an-upstream-with-a-registry"></a>

### 将上游与注册表关联

将指定的上游容器镜像仓库与指定的容器虚拟注册表关联。

```plaintext
POST /virtual_registries/container/registry_upstreams
```

| 属性 | 类型 | 必需 | 描述 |
| --------- | ---- | -------- | ----------- |
| `registry_id` | 整数 | 是 | 容器虚拟注册表的 ID。 |
| `upstream_id` | 整数 | 是 | 容器上游注册表的 ID。 |

> [!note]
> 每个虚拟注册表最多可以关联 5 个上游注册表。

请求示例：

```shell
curl --request POST \
     --header "PRIVATE-TOKEN: <your_access_token>" \
     --header "Content-Type: application/json" \
     --header "Accept: application/json" \
     --data '{"registry_id": 1, "upstream_id": 2}' \
     --url "https://gitlab.example.com/api/v4/virtual_registries/container/registry_upstreams"
```

响应示例：

```json
{
  "id": 5,
  "registry_id": 1,
  "upstream_id": 2,
  "position": 2
}
```

<a id="disassociate-an-upstream-from-a-registry"></a>

### 取消上游与注册表的关联

移除指定上游容器镜像仓库与指定容器虚拟注册表之间的关联。

```plaintext
DELETE /virtual_registries/container/registry_upstreams/:id
```

| 属性 | 类型 | 必需 | 描述 |
| --------- | ---- | -------- | ----------- |
| `id` | 整数 | 是 | 上游注册表关联的 ID。 |

请求示例：

```shell
curl --request DELETE \
     --header "PRIVATE-TOKEN: <your_access_token>" \
     --header "Content-Type: application/json" \
     --header "Accept: application/json" \
     --url "https://gitlab.example.com/api/v4/virtual_registries/container/registry_upstreams/1"
```

如果成功，返回 [`204 No Content`](rest/troubleshooting.md#status-codes) 状态码。

<a id="delete-cache-entries-for-an-upstream-registry"></a>

### 删除上游注册表的缓存条目

{{< history >}}

- 在极狐GitLab 18.7 [通过一个功能标志](../administration/feature_flags/_index.md)引入，名为 `container_virtual_registries`。默认禁用。
- 在极狐GitLab 18.9 中从实验阶段变更为测试阶段。
- 在极狐GitLab 18.10 中在 JihuLab.com 和私有化部署上启用。

{{< /history >}}

安排删除指定上游注册表的所有缓存条目。

```plaintext
DELETE /virtual_registries/container/upstreams/:id/cache
```

| 属性 | 类型 | 必需 | 描述 |
| --------- | ---- | -------- | ----------- |
| `id` | 整数 | 是 | 上游注册表的 ID。 |

请求示例：

```shell
curl --request DELETE --header "PRIVATE-TOKEN: <your_access_token>" \
     --header "Accept: application/json" \
     --url "https://gitlab.example.com/api/v4/virtual_registries/container/upstreams/1/cache"
```

如果成功，返回 [`204 No Content`](rest/troubleshooting.md#status-codes) 状态码。

<a id="test-connection-to-an-upstream-registry-with-override-parameters"></a>

### 使用覆盖参数测试到上游注册表的连接

{{< history >}}

- 在极狐GitLab 18.9 [通过一个功能标志](../administration/feature_flags/_index.md)引入，名为 `container_virtual_registries`。默认禁用。
- 在极狐GitLab 18.9 中从实验阶段变更为测试阶段。
- 在极狐GitLab 18.10 中在 JihuLab.com 和私有化部署上启用。

{{< /history >}}

使用可选的参数覆盖，测试到现有容器上游注册表的连接。

这样，你可以在更新上游注册表配置之前，测试对 URL、用户名或密码的更改。

```plaintext
POST /virtual_registries/container/upstreams/:id/test
```

支持的属性：

| 属性 | 类型 | 必需 | 描述 |
| --------- | ---- | -------- | ----------- |
| `id` | 整数 | 是 | 上游注册表的 ID。 |
| `password` | 字符串 | 否 | 用于测试的覆盖密码。 |
| `url` | 字符串 | 否 | 用于测试的覆盖 URL。如果提供，将测试到此 URL 的连接，而不是上游配置的 URL。 |
| `username` | 字符串 | 否 | 用于测试的覆盖用户名。 |

<a id="how-the-test-works"></a>

#### 测试原理

此端点使用测试路径向上游 URL 发送 HEAD 请求，以验证连通性和身份验证。如果上游有缓存的制品，则会使用上游的相对路径进行测试。否则，使用占位路径。

测试行为取决于提供的参数：

- 无参数：使用其当前配置（现有 URL、用户名和密码）测试上游
- URL 覆盖：测试到新 URL 的连接性（用户名和密码必须同时提供，或者都不提供）
- 凭据覆盖：使用新凭据测试现有 URL

从 HEAD 请求收到的响应解释如下：

| 上游响应 | 含义 | 结果 |
|:------------------|:--------|:-------|
| 2XX | 成功。上游可访问 | `{ "success": true }` |
| 404 | 成功。上游可访问，但未找到测试制品 | `{ "success": true }` |
| 401 | 身份验证失败 | `{ "success": false, "result": "错误：401 - 未授权" }` |
| 403 | 禁止访问 | `{ "success": false, "result": "错误：403 - 禁止访问" }` |
| 5XX | 上游服务器错误 | `{ "success": false, "result": "错误：5XX - 服务器错误" }` |
| 网络错误 | 连接或超时问题 | `{ "success": false, "result": "错误：连接超时" }` |

> [!note]
> `2XX`（已找到）和 `404 Not Found` 响应均表示到上游注册表的连接和身份验证成功。此测试不验证特定制品是否存在。
示例请求（测试现有配置）：

```shell
curl --request POST \
     --header "PRIVATE-TOKEN: <your_access_token>" \
     --header "Content-Type: application/json" \
     --url "https://gitlab.example.com/api/v4/virtual_registries/container/upstreams/1/test"
```

示例请求（测试 URL 覆盖且无凭证）：

```shell
curl --request POST \
     --header "PRIVATE-TOKEN: <your_access_token>" \
     --header "Content-Type: application/json" \
     --data '{"url": "https://registry-1.docker.io"}' \
     --url "https://gitlab.example.com/api/v4/virtual_registries/container/upstreams/1/test"
```

示例请求（测试 URL 和凭证覆盖）：

```shell
curl --request POST \
     --header "PRIVATE-TOKEN: <your_access_token>" \
     --header "Content-Type: application/json" \
     --data '{"url": "https://registry-1.docker.io", "username": "<newuser>", "password": "<newpass>"}' \
     --url "https://gitlab.example.com/api/v4/virtual_registries/container/upstreams/1/test"
```

示例请求（测试凭证覆盖）：

```shell
curl --request POST \
     --header "PRIVATE-TOKEN: <your_access_token>" \
     --header "Content-Type: application/json" \
     --data '{"username": "<newuser>", "password": "<newpass>"}' \
     --url "https://gitlab.example.com/api/v4/virtual_registries/container/upstreams/1/test"
```

示例响应：

```json
{
  "success": true
}
```

## 管理缓存条目

使用以下端点管理容器虚拟镜像仓库的缓存容器镜像和清单。

### 列出上游镜像仓库缓存条目

列出容器上游镜像仓库的缓存容器镜像和清单。

```plaintext
GET /virtual_registries/container/upstreams/:id/cache_entries
```

支持的属性：

| 属性 | 类型 | 是否必需 | 描述 |
|:----------|:-----|:---------|:------------|
| `id` | integer | 是 | 上游镜像仓库的 ID。 |
| `page` | integer | 否 | 页码。默认为 1。 |
| `per_page` | integer | 否 | 每页的条目数。默认为 20。 |
| `search` | string | 否 | 容器镜像相对路径的搜索查询（例如，`library/nginx`）。 |

示例请求：

```shell
curl --header "PRIVATE-TOKEN: <your_access_token>" \
     --header "Accept: application/json" \
     --url "https://gitlab.example.com/api/v4/virtual_registries/container/upstreams/1/cache_entries?search=library/nginx"
```

示例响应：

```json
[
  {
    "id": "MTUgbGlicmFyeS9uZ2lueC9tYW5pZmVzdC9zaGEyNTY6YWJjZGVmZ2hpams=",
    "group_id": 5,
    "upstream_id": 1,
    "upstream_checked_at": "2024-05-30T12:28:27.855Z",
    "file_md5": "44f21d5190b5a6df8089f54799628d7e",
    "file_sha1": "74d101856d26f2db17b39bd22d3204021eb0bf7d",
    "size": 2048,
    "relative_path": "library/nginx/manifests/latest",
    "content_type": "application/vnd.docker.distribution.manifest.v2+json",
    "upstream_etag": "\"686897696a7c876b7e\"",
    "created_at": "2024-05-30T12:28:27.855Z",
    "updated_at": "2024-05-30T12:28:27.855Z",
    "downloads_count": 5,
    "downloaded_at": "2024-06-05T14:58:32.855Z"
  }
]
```

### 删除上游镜像仓库缓存条目

删除上游镜像仓库的指定缓存容器镜像或清单。

```plaintext
DELETE /virtual_registries/container/cache_entries/*id
```

| 属性 | 类型 | 是否必需 | 描述 |
| --------- | ---- | -------- | ----------- |
| `id` | string | 是 | 缓存条目 ID，它是上游 ID 和缓存条目相对路径的 base64 编码（例如，'bGlicmFyeS9uZ2lueC9tYW5pZmVzdHMvbGF0ZXN0'）。 |

示例请求：

```shell
curl --request DELETE --header "PRIVATE-TOKEN: <your_access_token>" \
     --header "Accept: application/json" \
     --url "https://gitlab.example.com/api/v4/virtual_registries/container/cache_entries/bGlicmFyeS9uZ2lueC9tYW5pZmVzdHMvbGF0ZXN0"
```

如果成功，返回 [`204 No Content`](rest/troubleshooting.md#status-codes) 状态码。