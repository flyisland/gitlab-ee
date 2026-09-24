---
stage: Package
group: Package Registry
info: 要确定与此页面关联的阶段/群组指派人，请参阅 <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
title: Maven 虚拟仓库 API
---

{{< details >}}

- Tier: 专业版，旗舰版
- Offering: JihuLab.com，私有化部署
- Status: Beta

{{< /details >}}

{{< history >}}

- 在极狐GitLab 17.4 中引入，[带有功能标志](../administration/feature_flags/_index.md) `virtual_registry_maven`，默认禁用。
- 在极狐GitLab 18.1 中，功能标志[变更为](https://gitlab.com/gitlab-org/gitlab/-/issues/540276) `maven_virtual_registry`，默认禁用。功能标志 `virtual_registry_maven` 已移除。
- 在极狐GitLab 18.1 中，从实验阶段[转为](https://gitlab.com/gitlab-org/gitlab/-/issues/540276) Beta 阶段。
- 在极狐GitLab 18.2 中，[在 JihuLab.com、私有化部署上启用](https://gitlab.com/gitlab-org/gitlab/-/merge_requests/197432)。

{{< /history >}}

> [!flag]
> 这些端点的可用性由功能标志控制。
> 更多信息，请参见历史记录。

使用此 API 可以：

- 创建和管理 Maven 虚拟仓库。
- 配置上游仓库。
- 管理缓存条目。
- 处理软件包下载和上传。

## 管理 Maven 虚拟仓库

使用以下端点创建和管理 Maven 虚拟仓库。

### 列出所有虚拟仓库

{{< history >}}

- `downloads_count` 和 `downloaded_at` 在极狐GitLab 18.4 中[引入](https://gitlab.com/gitlab-org/gitlab/-/merge_requests/201790)。

{{< /history >}}

列出指定群组的所有 Maven 虚拟仓库。

```plaintext
GET /groups/:id/-/virtual_registries/packages/maven/registries
```

支持的属性：

| 属性 | 类型 | 是否必需 | 描述 |
|:----------|:-----|:---------|:------------|
| `id` | string/integer | 是 | 群组 ID 或完整群组路径。必须是顶级群组。 |

请求示例：

```shell
curl --header "PRIVATE-TOKEN: <your_access_token>" \
     --header "Accept: application/json" \
     --url "https://gitlab.example.com/api/v4/groups/5/-/virtual_registries/packages/maven/registries"
```

响应示例：

```json
[
  {
    "id": 1,
    "group_id": 5,
    "name": "my-virtual-registry",
    "description": "My virtual registry",
    "created_at": "2024-05-30T12:28:27.855Z",
    "updated_at": "2024-05-30T12:28:27.855Z"
  }
]
```

### 创建虚拟仓库

为指定群组创建 Maven 虚拟仓库。

```plaintext
POST /groups/:id/-/virtual_registries/packages/maven/registries
```

| 属性 | 类型 | 是否必需 | 描述 |
| --------- | ---- | -------- | ----------- |
| `id` | string/integer | 是 | 群组 ID 或完整群组路径。必须是顶级群组。 |
| `name` | string | 是 | 虚拟仓库的名称。 |
| `description` | string | 否 | 虚拟仓库的描述。 |

请求示例：

```shell
curl --request POST \
     --header "PRIVATE-TOKEN: <your_access_token>" \
     --header "Content-Type: application/json" \
     --header "Accept: application/json" \
     --data '{"name": "my-virtual-registry", "description": "My virtual registry"}' \
     --url "https://gitlab.example.com/api/v4/groups/5/-/virtual_registries/packages/maven/registries"
```

响应示例：

```json
{
  "id": 1,
  "group_id": 5,
  "name": "my-virtual-registry",
  "description": "My virtual registry",
  "created_at": "2024-05-30T12:28:27.855Z",
  "updated_at": "2024-05-30T12:28:27.855Z"
}
```

### 获取虚拟仓库

获取指定的 Maven 虚拟仓库。

```plaintext
GET /virtual_registries/packages/maven/registries/:id
```

参数：

| 属性 | 类型 | 是否必需 | 描述 |
| --------- | ---- | -------- | ----------- |
| `id` | integer | 是 | Maven 虚拟仓库的 ID。 |

请求示例：

```shell
curl --header "PRIVATE-TOKEN: <your_access_token>" \
     --header "Accept: application/json" \
     --url "https://gitlab.example.com/api/v4/virtual_registries/packages/maven/registries/1"
```

响应示例：

```json
{
  "id": 1,
  "group_id": 5,
  "name": "my-virtual-registry",
  "description": "My virtual registry",
  "created_at": "2024-05-30T12:28:27.855Z",
  "updated_at": "2024-05-30T12:28:27.855Z"
}
```

### 更新虚拟仓库

更新指定的 Maven 虚拟仓库。

```plaintext
PATCH /virtual_registries/packages/maven/registries/:id
```

| 属性 | 类型 | 是否必需 | 描述 |
| --------- | ---- | -------- | ----------- |
| `id` | integer | 是 | Maven 虚拟仓库的 ID。 |
| `name` | string | 是 | 虚拟仓库的名称。 |
| `description` | string | 否 | 虚拟仓库的描述。 |

请求示例：

```shell
curl --request PATCH \
     --header "PRIVATE-TOKEN: <your_access_token>" \
     --header "Content-Type: application/json" \
     --data '{"name": "my-virtual-registry", "description": "My virtual registry"}' \
     --url "https://gitlab.example.com/api/v4/virtual_registries/packages/maven/registries/1"
```

如果成功，返回 [`200 OK`](rest/troubleshooting.md#status-codes) 状态码。

### 删除虚拟仓库

> [!warning]
> 删除虚拟仓库也会删除所有与之关联且未与其他虚拟仓库共享的上游仓库及其缓存条目。

删除指定的 Maven 虚拟仓库。

```plaintext
DELETE /virtual_registries/packages/maven/registries/:id
```

| 属性 | 类型 | 是否必需 | 描述 |
| --------- | ---- | -------- | ----------- |
| `id` | integer | 是 | Maven 虚拟仓库的 ID。 |

请求示例：

```shell
curl --request DELETE --header "PRIVATE-TOKEN: <your_access_token>" \
     --header "Accept: application/json" \
     --url "https://gitlab.example.com/api/v4/virtual_registries/packages/maven/registries/1"
```

如果成功，返回 [`204 No Content`](rest/troubleshooting.md#status-codes) 状态码。

### 删除虚拟仓库的缓存条目

{{< history >}}

- 在极狐GitLab 18.2 中[引入](https://gitlab.com/gitlab-org/gitlab/-/issues/538327)，[带有功能标志](../administration/feature_flags/_index.md) `maven_virtual_registry`，默认启用。

{{< /history >}}

为 Maven 虚拟仓库的所有独占上游仓库中的缓存条目安排删除。不会为与其他虚拟仓库关联的上游仓库安排删除缓存条目。

```plaintext
DELETE /virtual_registries/packages/maven/registries/:id/cache
```

| 属性 | 类型 | 是否必需 | 描述 |
| --------- | ---- | -------- | ----------- |
| `id` | integer | 是 | Maven 虚拟仓库的 ID。 |

请求示例：

```shell
curl --request DELETE --header "PRIVATE-TOKEN: <your_access_token>" \
     --header "Accept: application/json" \
     --url "https://gitlab.example.com/api/v4/virtual_registries/packages/maven/registries/1/cache"
```

如果成功，返回 [`204 No Content`](rest/troubleshooting.md#status-codes) 状态码。

## 管理上游仓库

使用以下端点配置和管理上游 Maven 仓库。

### 列出所有上游仓库

{{< history >}}

- 在极狐GitLab 18.3 中[引入](https://gitlab.com/gitlab-org/gitlab/-/issues/550728)，[带有功能标志](../administration/feature_flags/_index.md) `maven_virtual_registry`，默认启用。
- `upstream_name` 在极狐GitLab 18.4 中[引入](https://gitlab.com/gitlab-org/gitlab/-/issues/561675)。

{{< /history >}}

列出指定顶级群组的所有上游 Maven 仓库。

```plaintext
GET /groups/:id/-/virtual_registries/packages/maven/upstreams
```

支持的属性：

| 属性 | 类型 | 是否必需 | 描述 |
|:----------|:-----|:---------|:------------|
| `id` | string/integer | 是 | 群组 ID 或完整群组路径。必须是顶级群组。 |
| `page` | integer | 否 | 页码。默认为 1。 |
| `per_page` | integer | 否 | 每页条目数。默认为 20。 |
| `upstream_name` | string | 否 | 用于按名称进行模糊搜索过滤的上游仓库名称。 |

请求示例：

```shell
curl --header "PRIVATE-TOKEN: <your_access_token>" \
     --header "Accept: application/json" \
     --url "https://gitlab.example.com/api/v4/groups/5/-/virtual_registries/packages/maven/upstreams"
```

响应示例：

```json
[
  {
    "id": 1,
    "group_id": 5,
    "url": "https://repo.maven.apache.org/maven2",
    "name": "Maven Central",
    "description": "Maven Central repository",
    "cache_validity_hours": 24,
    "metadata_cache_validity_hours": 24,
    "username": "user",
    "created_at": "2024-05-30T12:28:27.855Z",
    "updated_at": "2024-05-30T12:28:27.855Z"
  }
]
```

### 创建前测试上游仓库连接

{{< history >}}

- 在极狐GitLab 18.3 中[引入](https://gitlab.com/gitlab-org/gitlab/-/issues/535637)，[带有功能标志](../administration/feature_flags/_index.md) `maven_virtual_registry`，默认启用。

{{< /history >}}

测试与尚未添加到虚拟仓库的 Maven 上游仓库的连接。此端点在创建上游仓库之前验证连通性和凭证。

```plaintext
POST /groups/:id/-/virtual_registries/packages/maven/upstreams/test
```

支持的属性：

| 属性 | 类型 | 是否必需 | 描述 |
|:----------|:-----|:---------|:------------|
| `id` | string/integer | 是 | 群组 ID 或完整群组路径。必须是顶级群组。 |
| `url` | string | 是 | 上游仓库的 URL。 |
| `password` | string | 否 | 上游仓库的密码。 |
| `username` | string | 否 | 上游仓库的用户名。 |

> [!note]
> 您必须在请求中同时包含 `username` 和 `password`，或者都不包含。如果未设置，则使用公共（匿名）请求来测试连接。

#### 测试工作流

`test` 端点使用测试路径向提供的上游 URL 发送 HEAD 请求，以验证连通性和认证。接收到的 HEAD 请求响应解释如下：

| 上游响应 | 描述 | 结果 |
|:------------------|:--------|:-------|
| 2XX | 成功 - 上游可访问 | `{ "success": true }` |
| 404 | 成功 - 上游可访问，但测试产物未找到 | `{ "success": true }` |
| 401 | 认证失败 | `{ "success": false, "result": "Error: 401 - Unauthorized" }` |
| 403 | 访问被禁止 | `{ "success": false, "result": "Error: 403 - Forbidden" }` |
| 5XX | 上游服务器错误 | `{ "success": false, "result": "Error: 5XX - Server Error" }` |
| 网络错误 | 连接或超时问题 | `{ "success": false, "result": "Error: Connection timeout" }` |

请求示例：

```shell
curl --header "PRIVATE-TOKEN: <your_access_token>" \
     --header "Content-Type: application/json" \
     --url "https://gitlab.example.com/api/v4/groups/5/-/virtual_registries/packages/maven/upstreams/test" \
     --data '{"url": "https://repo.maven.apache.org/maven2"}'
```

响应示例：

```json
{
  "success": true
}
```

### 列出虚拟仓库的所有上游仓库

列出指定虚拟仓库的所有上游 Maven 仓库。

```plaintext
GET /virtual_registries/packages/maven/registries/:id/upstreams
```

支持的属性：

| 属性 | 类型 | 是否必需 | 描述 |
|:----------|:-----|:---------|:------------|
| `id` | integer | 是 | Maven 虚拟仓库的 ID。 |

请求示例：

```shell
curl --header "PRIVATE-TOKEN: <your_access_token>" \
     --header "Accept: application/json" \
     --url "https://gitlab.example.com/api/v4/virtual_registries/packages/maven/registries/1/upstreams"
```

响应示例：

```json
[
  {
    "id": 1,
    "group_id": 5,
    "url": "https://repo.maven.apache.org/maven2",
    "name": "Maven Central",
    "description": "Maven Central repository",
    "cache_validity_hours": 24,
    "metadata_cache_validity_hours": 24,
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

### 创建上游仓库

{{< history >}}

- `metadata_cache_validity_hours` 在极狐GitLab 18.3 中[引入](https://gitlab.com/gitlab-org/gitlab/-/issues/556138)。

{{< /history >}}

为指定的 Maven 虚拟仓库创建上游仓库。

```plaintext
POST /virtual_registries/packages/maven/registries/:id/upstreams
```

| 属性 | 类型 | 是否必需 | 描述 |
| --------- | ---- | -------- | ----------- |
| `id` | integer | 是 | Maven 虚拟仓库的 ID。 |
| `url` | string | 是 | 上游仓库的 URL。 |
| `cache_validity_hours` | integer | 否 | 缓存有效期。默认为 24 小时。 |
| `description` | string | 否 | 上游仓库的描述。 |
| `metadata_cache_validity_hours` | integer | 否 | 元数据缓存有效期。默认为 24 小时。 |
| `name` | string | 否 | 上游仓库的名称。 |
| `password` | string | 否 | 上游仓库的密码。 |
| `username` | string | 否 | 上游仓库的用户名。 |

> [!note]
> 您必须在请求中同时包含 `username` 和 `password`，或者都不包含。如果未设置，则使用公共（匿名）请求访问上游。
>
> 您不能将两个具有相同 URL 和凭证（`username` 和 `password`）的上游添加到同一个顶级群组。相反，您可以：
>
> - 为具有相同 URL 的每个上游设置不同的凭证。
> - [将上游关联](#associate-an-upstream-registry-with-a-virtual-registry) 到多个虚拟仓库。

请求示例：

```shell
curl --request POST --header "PRIVATE-TOKEN: <your_access_token>" \
     --header "Content-Type: application/json" \
     --data '{"url": "https://repo.maven.apache.org/maven2", "name": "Maven Central", "description": "Maven Central repository", "username": <your_username>, "password": <your_password>, "cache_validity_hours": 48, "metadata_cache_validity_hours": 1}' \
     --url "https://gitlab.example.com/api/v4/virtual_registries/packages/maven/registries/1/upstreams"
```

响应示例：

```json
{
  "id": 1,
  "group_id": 5,
  "url": "https://repo.maven.apache.org/maven2",
  "name": "Maven Central",
  "description": "Maven Central repository",
  "cache_validity_hours": 48,
  "metadata_cache_validity_hours": 1,
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

### 获取上游仓库

获取指定的上游仓库。

```plaintext
GET /virtual_registries/packages/maven/upstreams/:id
```

参数：

| 属性 | 类型 | 是否必需 | 描述 |
| --------- | ---- | -------- | ----------- |
| `id` | integer | 是 | 上游仓库的 ID。 |

请求示例：

```shell
curl --header "PRIVATE-TOKEN: <your_access_token>" \
     --header "Accept: application/json" \
     --url "https://gitlab.example.com/api/v4/virtual_registries/packages/maven/upstreams/1"
```

响应示例：

```json
{
  "id": 1,
  "group_id": 5,
  "url": "https://repo.maven.apache.org/maven2",
  "name": "Maven Central",
  "description": "Maven Central repository",
  "cache_validity_hours": 24,
  "metadata_cache_validity_hours": 24,
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

### 更新上游仓库

{{< history >}}

- `metadata_cache_validity_hours` 在极狐GitLab 18.3 中[引入](https://gitlab.com/gitlab-org/gitlab/-/issues/556138)。

{{< /history >}}

更新指定的上游仓库。

```plaintext
PATCH /virtual_registries/packages/maven/upstreams/:id
```

| 属性 | 类型 | 是否必需 | 描述 |
| --------- | ---- | -------- | ----------- |
| `id` | integer | 是 | 上游仓库的 ID。 |
| `cache_validity_hours` | integer | 否 | 缓存有效期。默认为 24 小时。 |
| `description` | string | 否 | 上游仓库的描述。 |
| `metadata_cache_validity_hours` | integer | 否 | 元数据缓存有效期。默认为 24 小时。 |
| `name` | string | 否 | 上游仓库的名称。 |
| `password` | string | 否 | 上游仓库的密码。 |
| `url` | string | 否 | 上游仓库的 URL。 |
| `username` | string | 否 | 上游仓库的用户名。 |

> [!note]
> 您必须在请求中至少提供一个可选参数。
>
> `username` 和 `password` 必须一起提供，或者都不提供。如果未设置，则使用公共（匿名）请求访问上游。

请求示例：

```shell
curl --request PATCH --header "PRIVATE-TOKEN: <your_access_token>" \
     --header "Content-Type: application/json" \
     --data '{"cache_validity_hours": 72}' \
     --url "https://gitlab.example.com/api/v4/virtual_registries/packages/maven/upstreams/1"
```

如果成功，返回 [`200 OK`](rest/troubleshooting.md#status-codes) 状态码。

### 更新上游仓库位置

更新 Maven 虚拟仓库的有序列表中上游仓库的位置。

```plaintext
PATCH /virtual_registries/packages/maven/registry_upstreams/:id
```

| 属性 | 类型 | 是否必需 | 描述 |
| --------- | ---- | -------- | ----------- |
| `id` | integer | 是 | 上游仓库的 ID。 |
| `position` | integer | 是 | 上游仓库的位置。介于 1 到 20 之间。 |

请求示例：

```shell
curl --request PATCH --header "PRIVATE-TOKEN: <your_access_token>" \
     --header "Content-Type: application/json" \
     --data '{"position": 5}' \
     --url "https://gitlab.example.com/api/v4/virtual_registries/packages/maven/registry_upstreams/1"
```

如果成功，返回 [`200 OK`](rest/troubleshooting.md#status-codes) 状态码。

### 删除上游仓库

删除指定的上游仓库。

```plaintext
DELETE /virtual_registries/packages/maven/upstreams/:id
```

| 属性 | 类型 | 是否必需 | 描述 |
| --------- | ---- | -------- | ----------- |
| `id` | integer | 是 | 上游仓库的 ID。 |

请求示例：

```shell
curl --request DELETE --header "PRIVATE-TOKEN: <your_access_token>" \
     --header "Accept: application/json" \
     --url "https://gitlab.example.com/api/v4/virtual_registries/packages/maven/upstreams/1"
```

如果成功，返回 [`204 No Content`](rest/troubleshooting.md#status-codes) 状态码。

### 将上游仓库关联到虚拟仓库

{{< history >}}

- 在极狐GitLab 18.1 中[引入](https://gitlab.com/gitlab-org/gitlab/-/issues/540276)，[带有功能标志](../administration/feature_flags/_index.md) `maven_virtual_registry`，默认禁用。
- 在极狐GitLab 18.2 中，[在 JihuLab.com、私有化部署上启用](https://gitlab.com/gitlab-org/gitlab/-/merge_requests/197432)。

{{< /history >}}

将现有上游仓库与指定的 Maven 虚拟仓库关联。

```plaintext
POST /virtual_registries/packages/maven/registry_upstreams
```

| 属性 | 类型 | 是否必需 | 描述 |
| --------- | ---- | -------- | ----------- |
| `registry_id` | integer | 是 | Maven 虚拟仓库的 ID。 |
| `upstream_id` | integer | 是 | Maven 上游仓库的 ID。 |

请求示例：

```shell
curl --request POST \
     --header "PRIVATE-TOKEN: <your_access_token>" \
     --header "Content-Type: application/json" \
     --header "Accept: application/json" \
     --data '{"registry_id": 1, "upstream_id": 2}' \
     --url "https://gitlab.example.com/api/v4/virtual_registries/packages/maven/registry_upstreams"
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

### 取消上游仓库与虚拟仓库的关联

{{< history >}}

- 在极狐GitLab 18.1 中[引入](https://gitlab.com/gitlab-org/gitlab/-/issues/540276)，[带有功能标志](../administration/feature_flags/_index.md) `maven_virtual_registry`，默认禁用。
- 在极狐GitLab 18.2 中，[在 JihuLab.com、私有化部署上启用](https://gitlab.com/gitlab-org/gitlab/-/merge_requests/197432)。

{{< /history >}}

取消上游仓库与指定 Maven 虚拟仓库的关联。

```plaintext
DELETE /virtual_registries/packages/maven/registry_upstreams/:id
```

| 属性 | 类型 | 是否必需 | 描述 |
| --------- | ---- | -------- | ----------- |
| `id` | integer | 是 | 仓库上游关联的 ID。 |

请求示例：

```shell
curl --request DELETE \
     --header "PRIVATE-TOKEN: <your_access_token>" \
     --header "Content-Type: application/json" \
     --header "Accept: application/json" \
     --url "https://gitlab.example.com/api/v4/virtual_registries/packages/maven/registry_upstreams/1"
```

如果成功，返回 [`204 No Content`](rest/troubleshooting.md#status-codes) 状态码。

### 删除上游仓库的缓存条目

{{< history >}}

- 在极狐GitLab 18.2 中[引入](https://gitlab.com/gitlab-org/gitlab/-/issues/538327)，[带有功能标志](../administration/feature_flags/_index.md) `maven_virtual_registry`，默认启用。

{{< /history >}}

为指定的上游仓库安排删除所有缓存条目。

```plaintext
DELETE /virtual_registries/packages/maven/upstreams/:id/cache
```

| 属性 | 类型 | 是否必需 | 描述 |
| --------- | ---- | -------- | ----------- |
| `id` | integer | 是 | 上游仓库的 ID。 |

请求示例：

```shell
curl --request DELETE --header "PRIVATE-TOKEN: <your_access_token>" \
     --header "Accept: application/json" \
     --url "https://gitlab.example.com/api/v4/virtual_registries/packages/maven/upstreams/1/cache"
```

如果成功，返回 [`204 No Content`](rest/troubleshooting.md#status-codes) 状态码。

### 测试上游仓库连接

{{< history >}}

- 在极狐GitLab 18.3 中[引入](https://gitlab.com/gitlab-org/gitlab/-/issues/535637)，[带有功能标志](../administration/feature_flags/_index.md) `maven_virtual_registry`，默认启用。

{{< /history >}}

测试与指定 Maven 上游仓库的连接。

```plaintext
GET /virtual_registries/packages/maven/upstreams/:id/test
```

#### 测试原理

该端点使用测试路径向上游 URL 执行 HEAD 请求，以验证连通性和认证。如果上游有缓存的产物，则使用其相对路径进行测试；否则使用虚拟路径。接收到的 HEAD 请求响应解释如下：

| 上游响应 | 含义 | 结果 |
|:------------------|:--------|:-------|
| 2XX | 成功 - 上游可访问 | `{ "success": true }` |
| 404 | 成功 - 上游可访问，但测试产物未找到 | `{ "success": true }` |
| 401 | 认证失败 | `{ "success": false, "result": "Error: 401 - Unauthorized" }` |
| 403 | 访问被禁止 | `{ "success": false, "result": "Error: 403 - Forbidden" }` |
| 5XX | 上游服务器错误 | `{ "success": false, "result": "Error: 5XX - Server Error" }` |
| 网络错误 | 连接/超时问题 | `{ "success": false, "result": "Error: Connection timeout" }` |

> [!note]
> `2XX`（已找到）和 `404`（未找到）响应均表示与上游仓库的连通性和认证成功。该测试验证极狐GitLab 是否可以连接到上游并进行认证，而非验证特定产物是否存在。

请求示例：

```shell
curl --header "PRIVATE-TOKEN: <your_access_token>" \
     --header "Accept: application/json" \
     --url "https://gitlab.example.com/api/v4/virtual_registries/packages/maven/upstreams/1/test"
```

响应示例：

```json
{
  "success": true
}
```

### 使用覆盖参数测试上游仓库连接

{{< history >}}

- 在极狐GitLab 18.7 中[引入](https://gitlab.com/gitlab-org/gitlab/-/issues/565897)，[带有功能标志](../administration/feature_flags/_index.md) `maven_virtual_registry`，默认启用。

{{< /history >}}

使用可选参数覆盖来测试与指定 Maven 上游仓库的连接。

这样，您可以在更新上游仓库配置之前测试对 URL、用户名或密码的更改。

```plaintext
POST /virtual_registries/packages/maven/upstreams/:id/test
```

支持的属性：
| 属性 | 类型 | 必需 | 描述 |
| --------- | ---- | -------- | ----------- |
| `id` | integer | 是 | 上游镜像仓库的 ID。 |
| `password` | string | 否 | 用于测试的覆盖密码。 |
| `url` | string | 否 | 用于测试的覆盖 URL。如果提供，将测试连接到此 URL，而不是上游配置的 URL。 |
| `username` | string | 否 | 用于测试的覆盖用户名。 |

<a id="how-the-test-works"></a>

#### 测试工作原理

该端点向上游 URL 发送 HEAD 请求，使用测试路径来验证连通性和认证。
如果上游有缓存的产物，则使用上游的相对路径进行测试。否则，使用占位路径。

测试行为取决于提供的参数：

- 无参数：使用当前配置（现有 URL、用户名和密码）测试上游
- URL 覆盖：测试与新 URL 的连通性，用户名和密码必须同时提供或都不提供
- 凭证覆盖：使用新凭证测试现有 URL

对 HEAD 请求收到的响应解读如下：

| 上游响应 | 含义 | 结果 |
|:------------------|:--------|:-------|
| 2XX | 成功。上游可访问 | `{ "success": true }` |
| 404 | 成功。上游可访问，但未找到测试产物 | `{ "success": true }` |
| 401 | 认证失败 | `{ "success": false, "result": "Error: 401 - Unauthorized" }` |
| 403 | 访问被禁止 | `{ "success": false, "result": "Error: 403 - Forbidden" }` |
| 5XX | 上游服务器错误 | `{ "success": false, "result": "Error: 5XX - Server Error" }` |
| 网络错误 | 连接或超时问题 | `{ "success": false, "result": "Error: Connection timeout" }` |

> [!note]
> `2XX`（找到）和 `404`（未找到）响应均表示与上游镜像仓库的连通性和认证成功。该测试不会验证特定产物是否存在。

示例请求（测试现有配置）：

```shell
curl --request POST \
     --header "PRIVATE-TOKEN: <your_access_token>" \
     --header "Content-Type: application/json" \
     --url "https://gitlab.example.com/api/v4/virtual_registries/packages/maven/upstreams/1/test"
```

示例请求（使用 URL 覆盖且无凭证测试）：

```shell
curl --request POST \
     --header "PRIVATE-TOKEN: <your_access_token>" \
     --header "Content-Type: application/json" \
     --data '{"url": "<https://new-repo.example.com/maven2>"}' \
     --url "https://gitlab.example.com/api/v4/virtual_registries/packages/maven/upstreams/1/test"
```

示例请求（使用 URL 和凭证覆盖测试）：

```shell
curl --request POST \
     --header "PRIVATE-TOKEN: <your_access_token>" \
     --header "Content-Type: application/json" \
     --data '{"url": "<https://new-repo.example.com/maven2>", "username": "<newuser>", "password": "<newpass>"}' \
     --url "https://gitlab.example.com/api/v4/virtual_registries/packages/maven/upstreams/1/test"
```

示例请求（使用凭证覆盖测试）：

```shell
curl --request POST \
     --header "PRIVATE-TOKEN: <your_access_token>" \
     --header "Content-Type: application/json" \
     --data '{"username": "<newuser>", "password": "<newpass>"}' \
     --url "https://gitlab.example.com/api/v4/virtual_registries/packages/maven/upstreams/1/test"
```

示例响应：

```json
{
  "success": true
}
```

<a id="manage-cache-entries"></a>

## 管理缓存条目

使用以下端点管理 Maven 虚拟镜像仓库的缓存条目。

<a id="list-all-upstream-registry-cache-entries"></a>

### 列出所有上游镜像仓库缓存条目

列出指定 Maven 上游镜像仓库的所有缓存条目。

```plaintext
GET /virtual_registries/packages/maven/upstreams/:id/cache_entries
```

支持的属性：

| 属性 | 类型 | 必需 | 描述 |
|:----------|:-----|:---------|:------------|
| `id` | integer | 是 | 上游镜像仓库的 ID。 |
| `page` | integer | 否 | 页码。默认为 1。 |
| `per_page` | integer | 否 | 每页条目数。默认为 20。 |
| `search` | string | 否 | 软件包相对路径的搜索查询（例如，`foo/bar/mypkg`）。 |

示例请求：

```shell
curl --header "PRIVATE-TOKEN: <your_access_token>" \
     --header "Accept: application/json" \
     --url "https://gitlab.example.com/api/v4/virtual_registries/packages/maven/upstreams/1/cache_entries?search=foo/bar"
```

示例响应：

```json
[
  {
    "id": "MTUgZm9vL2Jhci9teXBrZy8xLjAtU05BUFNIT1QvbXlwa2ctMS4wLVNOQVBTSE9ULmphcg==",
    "group_id": 5,
    "upstream_id": 1,
    "upstream_checked_at": "2024-05-30T12:28:27.855Z",
    "file_md5": "44f21d5190b5a6df8089f54799628d7e",
    "file_sha1": "74d101856d26f2db17b39bd22d3204021eb0bf7d",
    "size": 2048,
    "relative_path": "foo/bar/package-1.0.0.pom",
    "content_type": "application/xml",
    "upstream_etag": "\"686897696a7c876b7e\"",
    "created_at": "2024-05-30T12:28:27.855Z",
    "updated_at": "2024-05-30T12:28:27.855Z",
    "downloads_count": 6,
    "downloaded_at": "2024-06-05T14:58:32.855Z"
  }
]
```

<a id="delete-an-upstream-registry-cache-entry"></a>

### 删除上游镜像仓库缓存条目

删除 Maven 上游镜像仓库的指定缓存条目。

```plaintext
DELETE /virtual_registries/packages/maven/cache_entries/*id
```

| 属性 | 类型 | 必需 | 描述 |
| --------- | ---- | -------- | ----------- |
| `id` | string | 是 | 缓存条目的 base64 编码上游 ID 和相对路径（例如，'Zm9vL2Jhci9teXBrZy5wb20='）。 |

示例请求：

```shell
curl --request DELETE --header "PRIVATE-TOKEN: <your_access_token>" \
     --header "Accept: application/json" \
     --url "https://gitlab.example.com/api/v4/virtual_registries/packages/maven/cache_entries/Zm9vL2Jhci9teXBrZy5wb20="
```

如果成功，返回 [`204 No Content`](rest/troubleshooting.md#status-codes) 状态码。

<a id="manage-package-operations"></a>

## 管理软件包操作

使用以下端点管理 Maven 虚拟镜像仓库的软件包操作。

> [!warning]
> 这些端点仅供极狐GitLab 内部使用，通常不用于手动调用。

这些端点不遵循 [REST API 认证方法](rest/authentication.md)。
有关支持哪些标头和令牌类型的更多信息，
请参见 [Maven 虚拟镜像仓库](../user/packages/virtual_registry/maven/_index.md)。未记录的认证方法可能会在未来被移除。

<a id="download-a-package"></a>

### 下载软件包

从指定的 Maven 虚拟镜像仓库下载软件包。要访问此资源，你必须[向镜像仓库进行认证](../user/packages/package_registry/supported_functionality.md#authenticate-with-the-registry)。

```plaintext
GET /virtual_registries/packages/maven/:id/*path
```

支持的属性：

| 属性 | 类型 | 必需 | 描述 |
|:----------|:-----|:---------|:------------|
| `id` | integer | 是 | Maven 虚拟镜像仓库的 ID。 |
| `path` | string | 是 | 完整的软件包路径（例如，`foo/bar/mypkg/1.0-SNAPSHOT/mypkg-1.0-SNAPSHOT.jar`）。 |

示例请求：

```shell
curl --header "PRIVATE-TOKEN: <your_access_token>" \
     --url "https://gitlab.example.com/api/v4/virtual_registries/packages/maven/1/foo/bar/mypkg/1.0-SNAPSHOT/mypkg-1.0-SNAPSHOT.jar" \
     --output mypkg-1.0-SNAPSHOT.jar
```

如果成功，返回 [`200 OK`](rest/troubleshooting.md#status-codes) 和以下响应标头：

- `x-checksum-sha1`：文件的 SHA1 校验和
- `x-checksum-md5`：文件的 MD5 校验和
- `Content-Type`：文件的 MIME 类型
- `Content-Length`：文件大小（字节）

<a id="upload-a-package"></a>

### 上传软件包

将软件包上传到指定的 Maven 虚拟镜像仓库。此端点只能由 [极狐GitLab Workhorse](../development/workhorse/_index.md) 访问。

```plaintext
POST /virtual_registries/packages/maven/:id/*path/upload
```

| 属性 | 类型 | 必需 | 描述 |
| --------- | ---- | -------- | ----------- |
| `id` | integer | 是 | Maven 虚拟镜像仓库的 ID。 |
| `file` | file | 是 | 正在上传的文件。 |
| `path` | string | 是 | 完整的软件包路径（例如，`foo/bar/mypkg/1.0-SNAPSHOT/mypkg-1.0-SNAPSHOT.jar`）。 |

请求标头：

- `Etag`：文件的实体标签
- `GitLab-Workhorse-Send-Dependency-Content-Type`：文件的内容类型
- `Upstream-GID`：目标上游的全局 ID

如果成功，返回 [`200 OK`](rest/troubleshooting.md#status-codes) 状态码。