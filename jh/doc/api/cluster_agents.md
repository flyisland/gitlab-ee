---
stage: Verify
group: Runner Core
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
title: Kubernetes Agent API
---

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: JihuLab.com，私有化部署

{{< /details >}}

使用此 API 与[极狐GitLab Kubernetes Agent](../user/clusters/agent/_index.md) 交互。

<a id="list-all-agents"></a>

## 列出所有 Agent

列出为项目注册的所有 Agent。

您必须具有开发者、维护者或所有者角色才能使用此端点。

```plaintext
GET /projects/:id/cluster_agents
```

参数：

| 属性 | 类型              | 是否必需  | 描述                                                                                                     |
|-----------|-------------------|-----------|-----------------------------------------------------------------------------------------------------------------|
| `id`      | integer or string | 是       | 由已认证用户维护的项目的 ID 或 [URL 编码路径](rest/_index.md#namespaced-paths) |

响应：

响应是包含以下字段的 Agent 列表：

| 属性                            | 类型     | 描述                                          |
|--------------------------------------|----------|------------------------------------------------------|
| `id`                                 | integer  | Agent 的 ID                                      |
| `name`                               | string   | Agent 的名称                                    |
| `config_project`                     | object   | 表示 Agent 所属项目的对象 |
| `config_project.id`                  | integer  | 项目的 ID                                    |
| `config_project.description`         | string   | 项目的描述                           |
| `config_project.name`                | string   | 项目的名称                                  |
| `config_project.name_with_namespace` | string   | 项目的完整名称（含命名空间）              |
| `config_project.path`                | string   | 项目的路径                                  |
| `config_project.path_with_namespace` | string   | 项目的完整路径（含命名空间）              |
| `config_project.created_at`          | string   | 项目创建时的 ISO8601 日期时间        |
| `created_at`                         | string   | Agent 创建时的 ISO8601 日期时间          |
| `created_by_user_id`                 | integer  | 创建该 Agent 的用户的 ID                 |
| `is_receptive`                       | boolean  | 该 Agent 是否为可接收 Agent               |

示例请求：

```shell
curl --request GET \
  --header "PRIVATE-TOKEN: <your_access_token>" \
  --url "https://gitlab.example.com/api/v4/projects/20/cluster_agents"
```

示例响应：

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
    "created_by_user_id": 42,
    "is_receptive": false
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
    "created_by_user_id": 42,
    "is_receptive": false
  }
]
```

<a id="retrieve-an-agent"></a>

## 检索 Agent

检索单个 Agent 的详细信息。

您必须具有开发者、维护者或所有者角色才能使用此端点。

```plaintext
GET /projects/:id/cluster_agents/:agent_id
```

参数：

| 属性  | 类型              | 是否必需 | 描述                                                                                                     |
|------------|-------------------|----------|-----------------------------------------------------------------------------------------------------------------|
| `id`       | integer or string | 是      | 由已认证用户维护的项目的 ID 或 [URL 编码路径](rest/_index.md#namespaced-paths) |
| `agent_id` | integer           | 是      | Agent 的 ID                                                                                                 |

响应：

响应是包含以下字段的单个 Agent：

| 属性                            | 类型    | 描述                                          |
|--------------------------------------|---------|------------------------------------------------------|
| `id`                                 | integer | Agent 的 ID                                      |
| `name`                               | string  | Agent 的名称                                    |
| `config_project`                     | object  | 表示 Agent 所属项目的对象 |
| `config_project.id`                  | integer | 项目的 ID                                    |
| `config_project.description`         | string  | 项目的描述                           |
| `config_project.name`                | string  | 项目的名称                                  |
| `config_project.name_with_namespace` | string  | 项目的完整名称（含命名空间）              |
| `config_project.path`                | string  | 项目的路径                                  |
| `config_project.path_with_namespace` | string  | 项目的完整路径（含命名空间）              |
| `config_project.created_at`          | string  | 项目创建时的 ISO8601 日期时间        |
| `created_at`                         | string  | Agent 创建时的 ISO8601 日期时间          |
| `created_by_user_id`                 | integer | 创建该 Agent 的用户的 ID                 |
| `is_receptive`                       | boolean | 该 Agent 是否为可接收 Agent               |

示例请求：

```shell
curl --request GET \
  --header "PRIVATE-TOKEN: <your_access_token>" \
  --url "https://gitlab.example.com/api/v4/projects/20/cluster_agents/1"
```

示例响应：

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
  "created_by_user_id": 42,
  "is_receptive": false
}
```

<a id="create-an-agent"></a>

## 创建 Agent

为项目创建新的 Agent。

您必须具有维护者或所有者角色才能使用此端点。

```plaintext
POST /projects/:id/cluster_agents
```

参数：

| 属性 | 类型              | 是否必需 | 描述                                                                                                     |
|-----------|-------------------|----------|-----------------------------------------------------------------------------------------------------------------|
| `id`      | integer or string | 是      | 由已认证用户维护的项目的 ID 或 [URL 编码路径](rest/_index.md#namespaced-paths) |
| `name`    | string            | 是      | Agent 的名称                                                                                              |

响应：

响应是包含以下字段的新 Agent：

| 属性                            | 类型    | 描述                                          |
|--------------------------------------|---------|------------------------------------------------------|
| `id`                                 | integer | Agent 的 ID                                      |
| `name`                               | string  | Agent 的名称                                    |
| `config_project`                     | object  | 表示 Agent 所属项目的对象 |
| `config_project.id`                  | integer | 项目的 ID                                    |
| `config_project.description`         | string  | 项目的描述                           |
| `config_project.name`                | string  | 项目的名称                                  |
| `config_project.name_with_namespace` | string  | 项目的完整名称（含命名空间）              |
| `config_project.path`                | string  | 项目的路径                                  |
| `config_project.path_with_namespace` | string  | 项目的完整路径（含命名空间）              |
| `config_project.created_at`          | string  | 项目创建时的 ISO8601 日期时间        |
| `created_at`                         | string  | Agent 创建时的 ISO8601 日期时间          |
| `created_by_user_id`                 | integer | 创建该 Agent 的用户的 ID                 |
| `is_receptive`                       | boolean | 该 Agent 是否为可接收 Agent               |

示例请求：

```shell
curl --request POST \
  --header "PRIVATE-TOKEN: <your_access_token>" \
  --header "Content-Type: application/json" \
  --url "https://gitlab.example.com/api/v4/projects/20/cluster_agents" \
  --data '{"name":"some-agent"}'
```

示例响应：

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
  "created_by_user_id": 42,
  "is_receptive": false
}
```

<a id="delete-an-agent"></a>

## 删除 Agent

删除现有的 Agent 注册。

您必须具有维护者或所有者角色才能使用此端点。

```plaintext
DELETE /projects/:id/cluster_agents/:agent_id
```

参数：

| 属性  | 类型              | 是否必需 | 描述                                                                                                     |
|------------|-------------------|----------|-----------------------------------------------------------------------------------------------------------------|
| `id`       | integer or string | 是      | 由已认证用户维护的项目的 ID 或 [URL 编码路径](rest/_index.md#namespaced-paths) |
| `agent_id` | integer           | 是      | Agent 的 ID                                                                                                 |

示例请求：

```shell
curl --request DELETE \
  --header "PRIVATE-TOKEN: <your_access_token>" \
  --url "https://gitlab.example.com/api/v4/projects/20/cluster_agents/1"
```

<a id="list-all-agent-tokens"></a>

## 列出所有 Agent 令牌

列出某个 Agent 的所有有效令牌。

您必须具有开发者、维护者或所有者角色才能使用此端点。

```plaintext
GET /projects/:id/cluster_agents/:agent_id/tokens
```

支持的属性：

| 属性  | 类型              | 是否必需  | 描述                                                                                                      |
|------------|-------------------|-----------|------------------------------------------------------------------------------------------------------------------|
| `id`       | integer or string | 是       | 由已认证用户维护的项目的 ID 或 [URL 编码路径](rest/_index.md#namespaced-paths)。 |
| `agent_id` | integer or string | 是       | Agent 的 ID。                                                                                                 |

响应：

响应是包含以下字段的令牌列表：

| 属性            | 类型           | 描述                                                       |
|----------------------|----------------|-------------------------------------------------------------------|
| `id`                 | integer        | 令牌的 ID。                                                  |
| `name`               | string         | 令牌的名称。                                                |
| `description`        | string or null | 令牌的描述。                                         |
| `agent_id`           | integer        | 该令牌所属 Agent 的 ID。                             |
| `status`             | string         | 令牌的状态。有效值为 `active` 和 `revoked`。 |
| `created_at`         | string         | 令牌创建时的 ISO8601 日期时间。                      |
| `created_by_user_id` | string         | 创建该令牌的用户的用户 ID。                        |

示例请求：

```shell
curl --request GET \
  --header "PRIVATE-TOKEN: <your_access_token>" \
  --url "https://gitlab.example.com/api/v4/projects/20/cluster_agents/5/tokens"
```

示例响应：

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
> 令牌的 `last_used_at` 字段仅在获取单个 Agent 令牌时返回。

<a id="retrieve-an-agent-token"></a>

## 检索 Agent 令牌

检索单个 Agent 令牌。

您必须具有开发者、维护者或所有者角色才能使用此端点。

如果 Agent 令牌已被撤销，则返回 `404`。

```plaintext
GET /projects/:id/cluster_agents/:agent_id/tokens/:token_id
```

支持的属性：

| 属性  | 类型              | 是否必需 | 描述                                                                                                       |
|------------|-------------------|----------|-------------------------------------------------------------------------------------------------------------------|
| `id`       | integer or string | 是      | 由已认证用户维护的项目的 ID 或 [URL 编码路径](rest/_index.md#namespaced-paths)。  |
| `agent_id` | integer           | 是      | Agent 的 ID。                                                                                                  |
| `token_id` | integer           | 是      | 令牌的 ID。                                                                                                  |

响应：

响应是包含以下字段的单个令牌：

| 属性            | 类型           | 描述                                                       |
|----------------------|----------------|-------------------------------------------------------------------|
| `id`                 | integer        | 令牌的 ID。                                                  |
| `name`               | string         | 令牌的名称。                                                |
| `description`        | string or null | 令牌的描述。                                         |
| `agent_id`           | integer        | 该令牌所属 Agent 的 ID。                             |
| `status`             | string         | 令牌的状态。有效值为 `active` 和 `revoked`。 |
| `created_at`         | string         | 令牌创建时的 ISO8601 日期时间。                      |
| `created_by_user_id` | string         | 创建该令牌的用户的用户 ID。                        |
| `last_used_at`       | string or null | 令牌上次使用时的 ISO8601 日期时间。                    |

示例请求：

```shell
curl --request GET \
  --header "PRIVATE-TOKEN: <your_access_token>" \
  --url "https://gitlab.example.com/api/v4/projects/20/cluster_agents/5/token/1"
```

示例响应：

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

## 创建 Agent 令牌

为 Agent 创建新令牌。

您必须具有维护者或所有者角色才能使用此端点。

一个 Agent 同时只能有两个有效令牌。

```plaintext
POST /projects/:id/cluster_agents/:agent_id/tokens
```

支持的属性：

| 属性     | 类型              | 是否必需 | 描述                                                                                                      |
|---------------|-------------------|----------|------------------------------------------------------------------------------------------------------------------|
| `id`          | integer or string | 是      | 由已认证用户维护的项目的 ID 或 [URL 编码路径](rest/_index.md#namespaced-paths)。 |
| `agent_id`    | integer           | 是      | Agent 的 ID。                                                                                                 |
| `name`        | string            | 是      | 令牌的名称。                                                                                              |
| `description` | string            | 否       | 令牌的描述。                                                                                       |

响应：

响应是包含以下字段的新令牌：

| 属性            | 类型           | 描述                                                       |
|----------------------|----------------|-------------------------------------------------------------------|
| `id`                 | integer        | 令牌的 ID。                                                  |
| `name`               | string         | 令牌的名称。                                                |
| `description`        | string or null | 令牌的描述。                                         |
| `agent_id`           | integer        | 该令牌所属 Agent 的 ID。                             |
| `status`             | string         | 令牌的状态。有效值为 `active` 和 `revoked`。 |
| `created_at`         | string         | 令牌创建时的 ISO8601 日期时间。                      |
| `created_by_user_id` | string         | 创建该令牌的用户的用户 ID。                        |
| `last_used_at`       | string or null | 令牌上次使用时的 ISO8601 日期时间。                    |
| `token`              | string         | 密钥令牌值。                                           |

> [!note]
> `token` 仅在 `POST` 端点的响应中返回，之后无法再获取。

示例请求：

```shell
curl --request POST \
  --header "PRIVATE-TOKEN: <your_access_token>" \
  --header "Content-Type: application/json" \
  --url "https://gitlab.example.com/api/v4/projects/20/cluster_agents/5/tokens" \
  --data '{"name":"some-token"}'
```

示例响应：

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

## 撤销 Agent 令牌

撤销 Agent 令牌。

您必须具有维护者或所有者角色才能使用此端点。

```plaintext
DELETE /projects/:id/cluster_agents/:agent_id/tokens/:token_id
```

支持的属性：

| 属性  | 类型              | 是否必需 | 描述                                                                                                      |
|------------|-------------------|----------|-----------------------------------------------------------------------------------------------------------------|
| `id`       | integer or string | 是      | 由已认证用户维护的项目的 ID 或 [URL 编码路径](rest/_index.md#namespaced-paths)。 |
| `agent_id` | integer           | 是      | Agent 的 ID。                                                                                                 |
| `token_id` | integer           | 是      | 令牌的 ID。                                                                                                 |

示例请求：

```shell
curl --request DELETE \
  --header "PRIVATE-TOKEN: <your_access_token>" \
  --url "https://gitlab.example.com/api/v4/projects/20/cluster_agents/5/tokens/1"
```

<a id="receptive-agents"></a>

## 可接收 Agent

{{< details >}}

- Tier: 旗舰版
- Offering: 私有化部署

{{< /details >}}

[可接收 Agent](../user/clusters/agent/_index.md#receptive-agents) 允许极狐GitLab 与无法建立到极狐GitLab 实例的网络连接、但可由极狐GitLab 连接的 Kubernetes 集群集成。

<a id="list-all-url-configurations"></a>

### 列出所有 URL 配置

列出指定 Agent 的所有 URL 配置。

您必须具有开发者、维护者或所有者角色才能使用此端点。

```plaintext
GET /projects/:id/cluster_agents/:agent_id/url_configurations
```

支持的属性：

| 属性  | 类型              | 是否必需  | 描述                                                                                                           |
|------------|-------------------|-----------|-----------------------------------------------------------------------------------------------------------------------|
| `id`       | integer or string | 是       | 由已认证用户维护的项目的 ID 或 [URL 编码路径](rest/_index.md#namespaced-paths)。 |
| `agent_id` | integer or string | 是       | Agent 的 ID。                                                                                                      |

响应：

响应是包含以下字段的 URL 配置列表：

| 属性            | 类型           | 描述                                                                 |
|----------------------|----------------|-----------------------------------------------------------------------------|
| `id`                 | integer        | URL 配置的 ID。                                                |
| `agent_id`           | integer        | 该 URL 配置所属 Agent 的 ID。                           |
| `url`                | string         | 此 URL 配置的 URL。                                             |
| `public_key`         | string         | （可选）如果使用 JWT 认证，则为 Base64 编码的公钥。         |
| `client_cert`        | string         | （可选）如果使用 mTLS 认证，则为 PEM 格式的客户端证书。 |
| `ca_cert`            | string         | （可选）用于验证 Agent 端点的 PEM 格式 CA 证书。       |
| `tls_host`           | string         | （可选）用于验证 Agent 端点中服务器名称的 TLS 主机名。       |

示例请求：

```shell
curl --request GET \
  --header "PRIVATE-TOKEN: <your_access_token>" \
  --url "https://gitlab.example.com/api/v4/projects/20/cluster_agents/5/url_configurations"
```

示例响应：

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

### 检索 URL 配置

检索单个 Agent URL 配置。

您必须具有开发者、维护者或所有者角色才能使用此端点。

```plaintext
GET /projects/:id/cluster_agents/:agent_id/url_configurations/:url_configuration_id
```

支持的属性：

| 属性              | 类型              | 是否必需 | 描述                                                                                                            |
|------------------------|-------------------|----------|------------------------------------------------------------------------------------------------------------------------|
| `id`                   | integer or string | 是      | 由已认证用户维护的项目的 ID 或 [URL 编码路径](rest/_index.md#namespaced-paths)。  |
| `agent_id`             | integer           | 是      | Agent 的 ID。                                                                                                       |
| `url_configuration_id` | integer           | 是      | URL 配置的 ID。                                                                                           |

响应：

响应是包含以下字段的单个 URL 配置：

| 属性            | 类型           | 描述                                                                 |
|----------------------|----------------|-----------------------------------------------------------------------------|
| `id`                 | integer        | URL 配置的 ID。                                                |
| `agent_id`           | integer        | 该 URL 配置所属 Agent 的 ID。                           |
| `url`                | string         | 此 URL 配置的 Agent URL。                                             |
| `public_key`         | string         | （可选）如果使用 JWT 认证，则为 Base64 编码的公钥。         |
| `client_cert`        | string         | （可选）如果使用 mTLS 认证，则为 PEM 格式的客户端证书。 |
| `ca_cert`            | string         | （可选）用于验证 Agent 端点的 PEM 格式 CA 证书。       |
| `tls_host`           | string         | （可选）用于验证 Agent 端点中服务器名称的 TLS 主机名。       |

示例请求：

```shell
curl --request GET \
  --header "PRIVATE-TOKEN: <your_access_token>" \
  --url "https://gitlab.example.com/api/v4/projects/20/cluster_agents/5/url_configurations/1"
```

示例响应：

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

<a id="create-a-url-configuration"></a>

### 创建 URL 配置

为 Agent 创建新的 URL 配置。

您必须具有维护者或所有者角色才能使用此端点。

一个 Agent 同时只能有一个 URL 配置。

```plaintext
POST /projects/:id/cluster_agents/:agent_id/url_configurations
```

支持的属性：

| 属性     | 类型              | 是否必需 | 描述                                                                                                           |
|---------------|-------------------|----------|-----------------------------------------------------------------------------------------------------------------------|
| `id`          | integer or string | 是      | 由已认证用户维护的项目的 ID 或 [URL 编码路径](rest/_index.md#namespaced-paths)。 |
| `agent_id`    | integer           | 是      | Agent 的 ID。                                                                                                      |
| `url`         | string            | 是      | 此 URL 配置的 Agent URL。                                                                                 |
| `client_cert` | string            | 否       | 如果应使用 mTLS 认证，则为 PEM 格式的客户端证书。必须与 `client_key` 一起提供。           |
| `client_key`  | string            | 否       | 如果应使用 mTLS 认证，则为 PEM 格式的客户端密钥。必须与 `client_cert` 一起提供。                  |
| `ca_cert`     | string            | 否       | 用于验证 Agent 端点的 PEM 格式 CA 证书。                                                            |
| `tls_host`    | string            | 否       | 用于验证 Agent 端点中服务器名称的 TLS 主机名。                                                            |

响应：

响应是包含以下字段的新 URL 配置：

| 属性            | 类型           | 描述                                                                 |
|----------------------|----------------|-----------------------------------------------------------------------------|
| `id`                 | integer        | URL 配置的 ID。                                                |
| `agent_id`           | integer        | 该 URL 配置所属 Agent 的 ID。                           |
| `url`                | string         | 此 URL 配置的 Agent URL。                                             |
| `public_key`         | string         | （可选）如果使用 JWT 认证，则为 Base64 编码的公钥。         |
| `client_cert`        | string         | （可选）如果使用 mTLS 认证，则为 PEM 格式的客户端证书。 |
| `ca_cert`            | string         | （可选）用于验证 Agent 端点的 PEM 格式 CA 证书。       |
| `tls_host`           | string         | （可选）用于验证 Agent 端点中服务器名称的 TLS 主机名。       |

使用 JWT 令牌创建 URL 配置的示例请求：

```shell
curl --request POST \
  --header "PRIVATE-TOKEN: <your_access_token>" \
  --header "Content-Type: application/json" \
  --url "https://gitlab.example.com/api/v4/projects/20/cluster_agents/5/url_configurations" \
  --data '{"url":"grpcs://agent.example.com:4242"}'
```

JWT 认证的示例响应：

```json
{
  "id": 1,
  "agent_id": 5,
  "url": "grpcs://agent.example.com:4242",
  "public_key": "..."
}
```

使用来自文件 `client.pem` 和 `client-key.pem`的客户端证书和密钥，通过 mTLS 创建 URL 配置的示例请求：

```shell
curl --request POST \
  --header "PRIVATE-TOKEN: <your_access_token>" \
  --header "Content-Type: application/json" \
  --url "https://gitlab.example.com/api/v4/projects/20/cluster_agents/5/url_configurations" \
  --data '{"url":"grpcs://agent.example.com:4242", \
           "client_cert":"'"$(awk -v ORS='\\n' '1' client.pem)"'", \
           "client_key":"'"$(awk -v ORS='\\n' '1' client-key.pem)"'"}'
```

mTLS 的示例响应：

```json
{
  "id": 1,
  "agent_id": 5,
  "url": "grpcs://agent.example.com:4242",
  "client_cert": "..."
}
```

> [!note]
> 如果未提供 `client_cert` 和 `client_key`，则会生成私钥-公钥对，并使用 JWT 认证而非 mTLS。

<a id="delete-a-url-configuration"></a>

### 删除 URL 配置

删除 Agent URL 配置。

您必须具有维护者或所有者角色才能使用此端点。

```plaintext
DELETE /projects/:id/cluster_agents/:agent_id/url_configurations/:url_configuration_id
```

支持的属性：

| 属性              | 类型              | 是否必需 | 描述                                                                                                           |
|------------------------|-------------------|----------|-----------------------------------------------------------------------------------------------------------------------|
| `id`                   | integer or string | 是      | 由已认证用户维护的项目的 ID 或 [URL 编码路径](rest/_index.md#namespaced-paths)。 |
| `agent_id`             | integer           | 是      | Agent 的 ID。                                                                                                      |
| `url_configuration_id` | integer           | 是      | URL 配置的 ID。                                                                                          |

示例请求：

```shell
curl --request DELETE \
  --header "PRIVATE-TOKEN: <your_access_token>" \
  --url "https://gitlab.example.com/api/v4/projects/20/cluster_agents/5/url_configurations/1
```
