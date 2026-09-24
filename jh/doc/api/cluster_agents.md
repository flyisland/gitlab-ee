---
stage: Verify
group: Runner Core
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
title: Kubernetes 代理 API
---

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: JihuLab.com，私有化部署

{{< /details >}}

{{< history >}}

- 在极狐GitLab 15.0 中引入。

{{< /history >}}

使用此 API 与 [极狐GitLab Kubernetes 代理](../user/clusters/agent/_index.md) 进行交互。

<a id="list-all-agents"></a>

## 列出所有代理

列出为该项目注册的所有代理。

您必须具有开发者、维护者或所有者角色才能使用此端点。

```plaintext
GET /projects/:id/cluster_agents
```

参数：

| 属性 | 类型 | 是否必需 | 描述 |
|-----------|-------------------|-----------|-----------------------------------------------------------------------------------------------------------------|
| `id` | integer 或 string | 是 | 由认证用户维护的项目的 ID 或 [URL 编码路径](rest/_index.md#namespaced-paths) |

响应：

响应是一个代理列表，包含以下字段：

| 属性 | 类型 | 描述 |
|--------------------------------------|----------|------------------------------------------------------|
| `id` | integer | 代理的 ID |
| `name` | string | 代理的名称 |
| `config_project` | object | 表示代理所属项目的对象 |
| `config_project.id` | integer | 项目的 ID |
| `config_project.description` | string | 项目的描述 |
| `config_project.name` | string | 项目的名称 |
| `config_project.name_with_namespace` | string | 项目带命名空间的完整名称 |
| `config_project.path` | string | 项目的路径 |
| `config_project.path_with_namespace` | string | 项目带命名空间的完整路径 |
| `config_project.created_at` | string | 项目创建时的 ISO8601 日期时间 |
| `created_at` | string | 代理创建时的 ISO8601 日期时间 |
| `created_by_user_id` | integer | 创建代理的用户的 ID |

请求示例：

```shell
curl \
  --header "PRIVATE-TOKEN: <your_access_token>" \
  --url "https://gitlab.example.com/api/v4/projects/20/cluster_agents"
```

响应示例：

```json
[
  {
    "id": 1,
    "name": "agent-1",
    "config_project": {
      "id": 20,
      "description": "",
      "name": "test",
      "name_with_namespace": "Administrator / test",
      "path": "test",
      "path_with_namespace": "root/test",
      "created_at": "2022-03-20T20:42:40.221Z"
    },
    "created_at": "2022-04-20T20:42:40.221Z",
    "created_by_user_id": 42
  },
  {
    "id": 2,
    "name": "agent-2",
    "config_project": {
      "id": 20,
      "description": "",
      "name": "test",
      "name_with_namespace": "Administrator / test",
      "path": "test",
      "path_with_namespace": "root/test",
      "created_at": "2022-03-20T20:42:40.221Z"
    },
    "created_at": "2022-04-20T20:42:40.221Z",
    "created_by_user_id": 42
  }
]
```

<a id="retrieve-an-agent"></a>

## 获取单个代理

获取单个代理的详细信息。

您必须具有开发者、维护者或所有者角色才能使用此端点。

```plaintext
GET /projects/:id/cluster_agents/:agent_id
```

参数：

| 属性 | 类型 | 是否必需 | 描述 |
|------------|-------------------|----------|-----------------------------------------------------------------------------------------------------------------|
| `id` | integer 或 string | 是 | 由认证用户维护的项目的 ID 或 [URL 编码路径](rest/_index.md#namespaced-paths) |
| `agent_id` | integer | 是 | 代理的 ID |

响应：

响应是一个包含以下字段的单个代理：

| 属性 | 类型 | 描述 |
|--------------------------------------|---------|------------------------------------------------------|
| `id` | integer | 代理的 ID |
| `name` | string | 代理的名称 |
| `config_project` | object | 表示代理所属项目的对象 |
| `config_project.id` | integer | 项目的 ID |
| `config_project.description` | string | 项目的描述 |
| `config_project.name` | string | 项目的名称 |
| `config_project.name_with_namespace` | string | 项目带命名空间的完整名称 |
| `config_project.path` | string | 项目的路径 |
| `config_project.path_with_namespace` | string | 项目带命名空间的完整路径 |
| `config_project.created_at` | string | 项目创建时的 ISO8601 日期时间 |
| `created_at` | string | 代理创建时的 ISO8601 日期时间 |
| `created_by_user_id` | integer | 创建代理的用户的 ID |

请求示例：

```shell
curl \
  --header "PRIVATE-TOKEN: <your_access_token>" \
  --url "https://gitlab.example.com/api/v4/projects/20/cluster_agents/1"
```

响应示例：

```json
{
  "id": 1,
  "name": "agent-1",
  "config_project": {
    "id": 20,
    "description": "",
    "name": "test",
    "name_with_namespace": "Administrator / test",
    "path": "test",
    "path_with_namespace": "root/test",
    "created_at": "2022-03-20T20:42:40.221Z"
  },
  "created_at": "2022-04-20T20:42:40.221Z",
  "created_by_user_id": 42
}
```

<a id="create-an-agent"></a>

## 创建代理

为项目创建一个新代理。

您必须具有维护者或所有者角色才能使用此端点。

```plaintext
POST /projects/:id/cluster_agents
```

参数：

| 属性 | 类型 | 是否必需 | 描述 |
|-----------|-------------------|----------|-----------------------------------------------------------------------------------------------------------------|
| `id` | integer 或 string | 是 | 由认证用户维护的项目的 ID 或 [URL 编码路径](rest/_index.md#namespaced-paths) |
| `name` | string | 是 | 代理的名称 |

响应：

响应是包含以下字段的新代理：

| 属性 | 类型 | 描述 |
|--------------------------------------|---------|------------------------------------------------------|
| `id` | integer | 代理的 ID |
| `name` | string | 代理的名称 |
| `config_project` | object | 表示代理所属项目的对象 |
| `config_project.id` | integer | 项目的 ID |
| `config_project.description` | string | 项目的描述 |
| `config_project.name` | string | 项目的名称 |
| `config_project.name_with_namespace` | string | 项目带命名空间的完整名称 |
| `config_project.path` | string | 项目的路径 |
| `config_project.path_with_namespace` | string | 项目带命名空间的完整路径 |
| `config_project.created_at` | string | 项目创建时的 ISO8601 日期时间 |
| `created_at` | string | 代理创建时的 ISO8601 日期时间 |
| `created_by_user_id` | integer | 创建代理的用户的 ID |

请求示例：

```shell
curl --request POST \
  --header "PRIVATE-TOKEN: <your_access_token>" \
  --header "Content-Type: application/json" \
  --url "https://gitlab.example.com/api/v4/projects/20/cluster_agents" \
  --data '{"name":"some-agent"}'
```

响应示例：

```json
{
  "id": 1,
  "name": "agent-1",
  "config_project": {
    "id": 20,
    "description": "",
    "name": "test",
    "name_with_namespace": "Administrator / test",
    "path": "test",
    "path_with_namespace": "root/test",
    "created_at": "2022-03-20T20:42:40.221Z"
  },
  "created_at": "2022-04-20T20:42:40.221Z",
  "created_by_user_id": 42
}
```

<a id="delete-an-agent"></a>

## 删除代理

删除一个现有的代理注册。

您必须具有维护者或所有者角色才能使用此端点。

```plaintext
DELETE /projects/:id/cluster_agents/:agent_id
```

参数：

| 属性 | 类型 | 是否必需 | 描述 |
|------------|-------------------|----------|-----------------------------------------------------------------------------------------------------------------|
| `id` | integer 或 string | 是 | 由认证用户维护的项目的 ID 或 [URL 编码路径](rest/_index.md#namespaced-paths) |
| `agent_id` | integer | 是 | 代理的 ID |

请求示例：

```shell
curl --request DELETE \
  --header "PRIVATE-TOKEN: <your_access_token>" \
  --url "https://gitlab.example.com/api/v4/projects/20/cluster_agents/1"
```

<a id="list-all-agent-tokens"></a>

## 列出所有代理令牌

{{< history >}}

- 在极狐GitLab 15.0 中引入。

{{< /history >}}

列出一个代理的所有活跃令牌。

您必须具有开发者、维护者或所有者角色才能使用此端点。

```plaintext
GET /projects/:id/cluster_agents/:agent_id/tokens
```

支持的属性：

| 属性 | 类型 | 是否必需 | 描述 |
|------------|-------------------|-----------|------------------------------------------------------------------------------------------------------------------|
| `id` | integer 或 string | 是 | 由认证用户维护的项目的 ID 或 [URL 编码路径](rest/_index.md#namespaced-paths)。 |
| `agent_id` | integer 或 string | 是 | 代理的 ID。 |

响应：

响应是一个令牌列表，包含以下字段：

| 属性 | 类型 | 描述 |
|----------------------|----------------|-------------------------------------------------------------------|
| `id` | integer | 令牌的 ID。 |
| `name` | string | 令牌的名称。 |
| `description` | string 或 null | 令牌的描述。 |
| `agent_id` | integer | 令牌所属代理的 ID。 |
| `status` | string | 令牌的状态。有效值为 `active` 和 `revoked`。 |
| `created_at` | string | 令牌创建时的 ISO8601 日期时间。 |
| `created_by_user_id` | string | 创建令牌的用户的 ID。 |

请求示例：

```shell
curl \
  --header "PRIVATE-TOKEN: <your_access_token>" \
  --url "https://gitlab.example.com/api/v4/projects/20/cluster_agents/5/tokens"
```

响应示例：

```json
[
  {
    "id": 1,
    "name": "abcd",
    "description": "Some token",
    "agent_id": 5,
    "status": "active",
    "created_at": "2022-03-25T14:12:11.497Z",
    "created_by_user_id": 1
  },
  {
    "id": 2,
    "name": "foobar",
    "description": null,
    "agent_id": 5,
    "status": "active",
    "created_at": "2022-03-25T14:12:11.497Z",
    "created_by_user_id": 1
  }
]
```

> [!note]
> 令牌的 `last_used_at` 字段仅在获取单个代理令牌时返回。

<a id="retrieve-an-agent-token"></a>

## 获取单个代理令牌

{{< history >}}

- 在极狐GitLab 15.0 中引入。

{{< /history >}}

获取单个代理令牌。

您必须具有开发者、维护者或所有者角色才能使用此端点。

如果代理令牌已被撤销，则返回 `404`。

```plaintext
GET /projects/:id/cluster_agents/:agent_id/tokens/:token_id
```

支持的属性：

| 属性 | 类型 | 是否必需 | 描述 |
|------------|-------------------|----------|-------------------------------------------------------------------------------------------------------------------|
| `id` | integer 或 string | 是 | 由认证用户维护的项目的 ID 或 [URL 编码路径](rest/_index.md#namespaced-paths)。 |
| `agent_id` | integer | 是 | 代理的 ID。 |
| `token_id` | integer | 是 | 令牌的 ID。 |

响应：

响应是一个包含以下字段的单个令牌：

| 属性 | 类型 | 描述 |
|----------------------|----------------|-------------------------------------------------------------------|
| `id` | integer | 令牌的 ID。 |
| `name` | string | 令牌的名称。 |
| `description` | string 或 null | 令牌的描述。 |
| `agent_id` | integer | 令牌所属代理的 ID。 |
| `status` | string | 令牌的状态。有效值为 `active` 和 `revoked`。 |
| `created_at` | string | 令牌创建时的 ISO8601 日期时间。 |
| `created_by_user_id` | string | 创建令牌的用户的 ID。 |
| `last_used_at` | string 或 null | 令牌最后使用时的 ISO8601 日期时间。 |

请求示例：

```shell
curl \
  --header "PRIVATE-TOKEN: <your_access_token>" \
  --url "https://gitlab.example.com/api/v4/projects/20/cluster_agents/5/token/1"
```

响应示例：

```json
{
  "id": 1,
  "name": "abcd",
  "description": "Some token",
  "agent_id": 5,
  "status": "active",
  "created_at": "2022-03-25T14:12:11.497Z",
  "created_by_user_id": 1,
  "last_used_at": null
}
```

<a id="create-an-agent-token"></a>

## 创建代理令牌

{{< history >}}

- 在极狐GitLab 15.0 中引入。
- 在极狐GitLab 16.1 中引入两个令牌限制，带有名为 `cluster_agents_limit_tokens_created` 的功能标志。
- 在极狐GitLab 16.2 中两个令牌限制 GA。功能标志 `cluster_agents_limit_tokens_created` 已移除。

{{< /history >}}

为代理创建一个新令牌。

您必须具有维护者或所有者角色才能使用此端点。

一个代理一次只能拥有两个活跃令牌。

```plaintext
POST /projects/:id/cluster_agents/:agent_id/tokens
```

支持的属性：

| 属性 | 类型 | 是否必需 | 描述 |
|---------------|-------------------|----------|------------------------------------------------------------------------------------------------------------------|
| `id` | integer 或 string | 是 | 由认证用户维护的项目的 ID 或 [URL 编码路径](rest/_index.md#namespaced-paths)。 |
| `agent_id` | integer | 是 | 代理的 ID。 |
| `name` | string | 是 | 令牌的名称。 |
| `description` | string | 否 | 令牌的描述。 |

响应：

响应是包含以下字段的新令牌：

| 属性 | 类型 | 描述 |
|----------------------|----------------|-------------------------------------------------------------------|
| `id` | integer | 令牌的 ID。 |
| `name` | string | 令牌的名称。 |
| `description` | string 或 null | 令牌的描述。 |
| `agent_id` | integer | 令牌所属代理的 ID。 |
| `status` | string | 令牌的状态。有效值为 `active` 和 `revoked`。 |
| `created_at` | string | 令牌创建时的 ISO8601 日期时间。 |
| `created_by_user_id` | string | 创建令牌的用户的 ID。 |
| `last_used_at` | string 或 null | 令牌最后使用时的 ISO8601 日期时间。 |
| `token` | string | 密钥令牌值。 |

> [!note]
> `token` 仅在 `POST` 端点的响应中返回，之后无法获取。

请求示例：

```shell
curl --request POST \
  --header "PRIVATE-TOKEN: <your_access_token>" \
  --header "Content-Type: application/json" \
  --url "https://gitlab.example.com/api/v4/projects/20/cluster_agents/5/tokens" \
  --data '{"name":"some-token"}'
```

响应示例：

```json
{
  "id": 1,
  "name": "abcd",
  "description": "Some token",
  "agent_id": 5,
  "status": "active",
  "created_at": "2022-03-25T14:12:11.497Z",
  "created_by_user_id": 1,
  "last_used_at": null,
  "token": "qeY8UVRisx9y3Loxo1scLxFuRxYcgeX3sxsdrpP_fR3Loq4xyg"
}
```

<a id="revoke-an-agent-token"></a>

## 撤销代理令牌

{{< history >}}

- 在极狐GitLab 15.0 中引入。

{{< /history >}}

撤销一个代理令牌。

您必须具有维护者或所有者角色才能使用此端点。

```plaintext
DELETE /projects/:id/cluster_agents/:agent_id/tokens/:token_id
```

支持的属性：

| 属性 | 类型 | 是否必需 | 描述 |
|------------|-------------------|----------|-----------------------------------------------------------------------------------------------------------------|
| `id` | integer 或 string | 是 | 由认证用户维护的项目的 ID 或 [URL 编码路径](rest/_index.md#namespaced-paths)。 |
| `agent_id` | integer | 是 | 代理的 ID。 |
| `token_id` | integer | 是 | 令牌的 ID。 |

请求示例：

```shell
curl --request DELETE \
  --header "PRIVATE-TOKEN: <your_access_token>" \
  --url "https://gitlab.example.com/api/v4/projects/20/cluster_agents/5/tokens/1"
```

<a id="receptive-agents"></a>

## 接受型代理

{{< details >}}

- Tier: 旗舰版
- Offering: 私有化部署

{{< /details >}}

{{< history >}}

- 在极狐GitLab 17.4 中引入。

{{< /history >}}

[接受型代理](../user/clusters/agent/_index.md#receptive-agents) 允许极狐GitLab 与无法建立到极狐GitLab 实例的网络连接、但可以被极狐GitLab 连接的 Kubernetes 集集群成。

<a id="list-all-url-configurations"></a>

### 列出所有 URL 配置

列出指定代理的所有 URL 配置。

您必须具有开发者、维护者或所有者角色才能使用此端点。

```plaintext
GET /projects/:id/cluster_agents/:agent_id/url_configurations
```

支持的属性：

| 属性 | 类型 | 是否必需 | 描述 |
|------------|-------------------|-----------|-----------------------------------------------------------------------------------------------------------------------|
| `id` | integer 或 string | 是 | 由认证用户维护的项目的 ID 或 [URL 编码路径](rest/_index.md#namespaced-paths)。 |
| `agent_id` | integer 或 string | 是 | 代理的 ID。 |

响应：

响应是一个 URL 配置列表，包含以下字段：

| 属性 | 类型 | 描述 |
|----------------------|----------------|-----------------------------------------------------------------------------|
| `id` | integer | URL 配置的 ID。 |
| `agent_id` | integer | URL 配置所属代理的 ID。 |
| `url` | string | 此 URL 配置的 URL。 |
| `public_key` | string | （可选）如果使用 JWT 认证，则为 Base64 编码的公钥。 |
| `client_cert` | string | （可选）如果使用 mTLS 认证，则为 PEM 格式的客户端证书。 |
| `ca_cert` | string | （可选）用于验证代理端点的 PEM 格式的 CA 证书。 |
| `tls_host` | string | （可选）用于验证代理端点中服务器名称的 TLS 主机名。 |

请求示例：

```shell
curl \
  --header "PRIVATE-TOKEN: <your_access_token>" \
  --url "https://gitlab.example.com/api/v4/projects/20/cluster_agents/5/url_configurations"
```

响应示例：

```json
[
  {
    "id": 1,
    "agent_id": 5,
    "url": "grpcs://agent.example.com:4242",
    "public_key": "..."
  }
]
```

> [!note]
> `public_key` 或 `client_cert` 会设置其中一个，但绝不会同时设置两者。

<a id="retrieve-a-url-configuration"></a>

### 获取单个 URL 配置

获取单个代理 URL 配置。

您必须具有开发者、维护者或所有者角色才能使用此端点。

```plaintext
GET /projects/:id/cluster_agents/:agent_id/url_configurations/:url_configuration_id
```

支持的属性：
| 属性                   | 类型              | 是否必填 | 描述                                                                                                             |
|------------------------|-------------------|----------|------------------------------------------------------------------------------------------------------------------------|
| `id`                   | integer 或 string | 是       | 由认证用户维护的[项目 ID 或 URL 编码路径](rest/_index.md#namespaced-paths)。  |
| `agent_id`             | integer           | 是       | 代理 ID。                                                                                                       |
| `url_configuration_id` | integer           | 是       | URL 配置 ID。                                                                                           |

响应：

响应是单个 URL 配置，包含以下字段：

| 属性                 | 类型           | 描述                                                                 |
|----------------------|----------------|-----------------------------------------------------------------------------|
| `id`                 | integer        | URL 配置 ID。                                                |
| `agent_id`           | integer        | 该 URL 配置所属的代理 ID。                           |
| `url`                | string         | 此 URL 配置的代理 URL。                                             |
| `public_key`         | string         | （可选）如果使用 JWT 认证，则为 Base64 编码的公钥。         |
| `client_cert`        | string         | （可选）如果使用 mTLS 认证，则为 PEM 格式的客户端证书。 |
| `ca_cert`            | string         | （可选）用于验证代理端点的 PEM 格式 CA 证书。       |
| `tls_host`           | string         | （可选）用于验证代理端点中服务器名称的 TLS 主机名。       |

请求示例：

```shell
curl \
  --header "PRIVATE-TOKEN: <your_access_token>" \
  --url "https://gitlab.example.com/api/v4/projects/20/cluster_agents/5/url_configurations/1"
```

响应示例：

```json
{
  "id": 1,
  "agent_id": 5,
  "url": "grpcs://agent.example.com:4242",
  "public_key": "..."
}
```

> [!note]
> `public_key` 或 `client_cert` 会设置其中一个，但绝不会同时设置两者。

### 创建 URL 配置

为代理创建一个新的 URL 配置。

你必须具有维护者或所有者角色才能使用此端点。

一个代理一次只能有一个 URL 配置。

```plaintext
POST /projects/:id/cluster_agents/:agent_id/url_configurations
```

支持的属性：

| 属性          | 类型              | 是否必填 | 描述                                                                                                                        |
|---------------|-------------------|----------|-----------------------------------------------------------------------------------------------------------------------------------|
| `id`          | integer 或 string | 是       | 由认证用户维护的[项目 ID 或 URL 编码路径](rest/_index.md#namespaced-paths)。 |
| `agent_id`    | integer           | 是       | 代理 ID。                                                                                                      |
| `url`         | string            | 是       | 此 URL 配置的代理 URL。                                                                                 |
| `client_cert` | string            | 否       | 如果应使用 mTLS 认证，则为 PEM 格式的客户端证书。必须与 `client_key` 一起提供。           |
| `client_key`  | string            | 否       | 如果应使用 mTLS 认证，则为 PEM 格式的客户端密钥。必须与 `client_cert` 一起提供。                  |
| `ca_cert`     | string            | 否       | 用于验证代理端点的 PEM 格式 CA 证书。                                                            |
| `tls_host`    | string            | 否       | 用于验证代理端点中服务器名称的 TLS 主机名。                                                            |

响应：

响应是新创建的 URL 配置，包含以下字段：

| 属性                 | 类型           | 描述                                                                 |
|----------------------|----------------|-----------------------------------------------------------------------------|
| `id`                 | integer        | URL 配置 ID。                                                |
| `agent_id`           | integer        | 该 URL 配置所属的代理 ID。                           |
| `url`                | string         | 此 URL 配置的代理 URL。                                             |
| `public_key`         | string         | （可选）如果使用 JWT 认证，则为 Base64 编码的公钥。         |
| `client_cert`        | string         | （可选）如果使用 mTLS 认证，则为 PEM 格式的客户端证书。 |
| `ca_cert`            | string         | （可选）用于验证代理端点的 PEM 格式 CA 证书。       |
| `tls_host`           | string         | （可选）用于验证代理端点中服务器名称的 TLS 主机名。       |

使用 JWT 令牌创建 URL 配置的请求示例：

```shell
curl --request POST \
  --header "PRIVATE-TOKEN: <your_access_token>" \
  --header "Content-Type: application/json" \
  --url "https://gitlab.example.com/api/v4/projects/20/cluster_agents/5/url_configurations" \
  --data '{"url":"grpcs://agent.example.com:4242"}'
```

JWT 认证的响应示例：

```json
{
  "id": 1,
  "agent_id": 5,
  "url": "grpcs://agent.example.com:4242",
  "public_key": "..."
}
```

使用来自文件 `client.pem` 和 `client-key.pem` 的客户端证书和密钥，通过 mTLS 创建 URL 配置的请求示例：

```shell
curl --request POST \
  --header "PRIVATE-TOKEN: <your_access_token>" \
  --header "Content-Type: application/json" \
  --url "https://gitlab.example.com/api/v4/projects/20/cluster_agents/5/url_configurations" \
  --data '{"url":"grpcs://agent.example.com:4242", \
           "client_cert":"'"$(awk -v ORS='\\n' '1' client.pem)"'", \
           "client_key":"'"$(awk -v ORS='\\n' '1' client-key.pem)"'"}'
```

mTLS 的响应示例：

```json
{
  "id": 1,
  "agent_id": 5,
  "url": "grpcs://agent.example.com:4242",
  "client_cert": "..."
}
```

> [!note]
> 如果未提供 `client_cert` 和 `client_key`，则会生成一个私钥-公钥对，并使用 JWT 认证代替 mTLS。

### 删除 URL 配置

删除代理 URL 配置。

你必须具有维护者或所有者角色才能使用此端点。

```plaintext
DELETE /projects/:id/cluster_agents/:agent_id/url_configurations/:url_configuration_id
```

支持的属性：

| 属性                   | 类型              | 是否必填 | 描述                                                                                                            |
|------------------------|-------------------|----------|-----------------------------------------------------------------------------------------------------------------------|
| `id`                   | integer 或 string | 是       | 由认证用户维护的[项目 ID 或 URL 编码路径](rest/_index.md#namespaced-paths)。 |
| `agent_id`             | integer           | 是       | 代理 ID。                                                                                                      |
| `url_configuration_id` | integer           | 是       | URL 配置 ID。                                                                                          |

请求示例：

```shell
curl --request DELETE --header "PRIVATE-TOKEN: <your_access_token>" "https://gitlab.example.com/api/v4/projects/20/cluster_agents/5/url_configurations/1"
```