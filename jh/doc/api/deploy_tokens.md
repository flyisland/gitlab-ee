---
stage: Verify
group: Runner Core
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
title: 部署令牌 API
---

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: JihuLab.com，私有化部署

{{< /details >}}

使用此 API 与[部署令牌](../user/project/deploy_tokens/_index.md)交互。

<a id="list-all-deploy-tokens"></a>

## 列出所有部署令牌

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: 私有化部署

{{< /details >}}

列出极狐GitLab 实例中的所有部署令牌。此端点需要管理员权限。

```plaintext
GET /deploy_tokens
```

参数：

| 属性     | 类型    | 必需               | 描述             |
|----------|---------|--------------------|------------------|
| `active` | boolean | 否                 | 按激活状态限制。 |

示例请求：

```shell
curl --header "PRIVATE-TOKEN: <your_access_token>" \
  --url "https://gitlab.example.com/api/v4/deploy_tokens"
```

示例响应：

```json
[
  {
    "id": 1,
    "name": "MyToken",
    "username": "gitlab+deploy-token-1",
    "expires_at": "2020-02-14T00:00:00.000Z",
    "revoked": false,
    "expired": false,
    "scopes": [
      "read_repository",
      "read_registry"
    ]
  }
]
```

<a id="project-deploy-tokens"></a>

## 项目部署令牌

项目部署令牌 API 端点要求项目的维护者或所有者角色。

<a id="list-project-deploy-tokens"></a>

### 列出项目部署令牌

列出一个项目的部署令牌。

```plaintext
GET /projects/:id/deploy_tokens
```

参数：

| 属性      | 类型           | 必需               | 描述                                                         |
|:----------|:---------------|:-------------------|:-------------------------------------------------------------|
| `id`      | integer 或 string | 是                 | ID 或[项目的 URL 编码路径](rest/_index.md#namespaced-paths)。 |
| `active`  | boolean        | 否                 | 按激活状态限制。                                           |

示例请求：

```shell
curl --header "PRIVATE-TOKEN: <your_access_token>" \
  --url "https://gitlab.example.com/api/v4/projects/1/deploy_tokens"
```

示例响应：

```json
[
  {
    "id": 1,
    "name": "MyToken",
    "username": "gitlab+deploy-token-1",
    "expires_at": "2020-02-14T00:00:00.000Z",
    "revoked": false,
    "expired": false,
    "scopes": [
      "read_repository",
      "read_registry"
    ]
  }
]
```

<a id="retrieve-a-project-deploy-token"></a>

### 检索项目部署令牌

按 ID 检索单个项目的部署令牌。

```plaintext
GET /projects/:id/deploy_tokens/:token_id
```

参数：

| 属性      | 类型           | 必需               | 描述                                                         |
|-----------|----------------|--------------------|--------------------------------------------------------------|
| `id`      | integer 或 string | 是                 | ID 或[项目的 URL 编码路径](rest/_index.md#namespaced-paths) |
| `token_id` | integer       | 是                 | 部署令牌的 ID                                                 |

示例请求：

```shell
curl --header "PRIVATE-TOKEN: <your_access_token>" \
  --url "https://gitlab.example.com/api/v4/projects/1/deploy_tokens/1"
```

示例响应：

```json
{
  "id": 1,
  "name": "MyToken",
  "username": "gitlab+deploy-token-1",
  "expires_at": "2020-02-14T00:00:00.000Z",
  "revoked": false,
  "expired": false,
  "scopes": [
    "read_repository",
    "read_registry"
  ]
}
```

<a id="create-a-project-deploy-token"></a>

### 创建项目部署令牌

创建一个项目部署令牌。

```plaintext
POST /projects/:id/deploy_tokens
```

参数：

| 属性         | 类型             | 必需               | 描述                                                                                                                       |
|--------------|------------------|--------------------|----------------------------------------------------------------------------------------------------------------------------|
| `id`         | integer 或 string | 是                 | ID 或[项目的 URL 编码路径](rest/_index.md#namespaced-paths)                                                                |
| `name`       | string           | 是                 | 新部署令牌的名称                                                                                                           |
| `scopes`     | array of strings | 是                 | 指示部署令牌的范围。必须至少为 `read_repository`、`read_registry`、`write_registry`、`read_package_registry`、`write_package_registry`、`read_virtual_registry` 或 `write_virtual_registry` 之一。 |
| `expires_at` | datetime         | 否                 | 部署令牌的到期日期。如果未提供值，则永不过期。期望的格式为 ISO 8601 (`2019-03-15T08:00:00Z`)                                    |
| `username`   | string           | 否                 | 部署令牌的用户名。默认为 `gitlab+deploy-token-{n}`                                                                        |

示例请求：

```shell
curl --request POST \
  --header "PRIVATE-TOKEN: <your_access_token>" \
  --header "Content-Type: application/json" \
  --data '{"name": "My deploy token", "expires_at": "2021-01-01", "username": "custom-user", "scopes": ["read_repository"]}' \
  --url "https://gitlab.example.com/api/v4/projects/5/deploy_tokens/"
```

示例响应：

```json
{
  "id": 1,
  "name": "My deploy token",
  "username": "custom-user",
  "expires_at": "2021-01-01T00:00:00.000Z",
  "token": "jMRvtPNxrn3crTAGukpZ",
  "revoked": false,
  "expired": false,
  "scopes": [
    "read_repository"
  ]
}
```

<a id="delete-a-project-deploy-token"></a>

### 删除项目部署令牌

从项目中删除部署令牌。

```plaintext
DELETE /projects/:id/deploy_tokens/:token_id
```

参数：

| 属性      | 类型           | 必需               | 描述                                                         |
|-----------|----------------|--------------------|--------------------------------------------------------------|
| `id`      | integer 或 string | 是                 | ID 或[项目的 URL 编码路径](rest/_index.md#namespaced-paths) |
| `token_id` | integer       | 是                 | 部署令牌的 ID                                                 |

示例请求：

```shell
curl --request DELETE \
  --header "PRIVATE-TOKEN: <your_access_token>" \
  --url "https://gitlab.example.com/api/v4/projects/5/deploy_tokens/13"
```

<a id="group-deploy-tokens"></a>

## 群组部署令牌

拥有群组维护者或所有者角色的用户可以列出群组部署令牌。只有群组所有者可以创建和删除群组部署令牌。

<a id="list-group-deploy-tokens"></a>

### 列出群组部署令牌

列出一个群组的部署令牌

```plaintext
GET /groups/:id/deploy_tokens
```

参数：

| 属性      | 类型           | 必需               | 描述                                                |
|:----------|:---------------|:-------------------|:----------------------------------------------------|
| `id`      | integer 或 string | 是                 | 群组的 ID 或[URL 编码路径](rest/_index.md#namespaced-paths)。 |
| `active`  | boolean        | 否                 | 按激活状态限制。                                    |

示例请求：

```shell
curl --header "PRIVATE-TOKEN: <your_access_token>" \
  --url "https://gitlab.example.com/api/v4/groups/1/deploy_tokens"
```

示例响应：

```json
[
  {
    "id": 1,
    "name": "MyToken",
    "username": "gitlab+deploy-token-1",
    "expires_at": "2020-02-14T00:00:00.000Z",
    "revoked": false,
    "expired": false,
    "scopes": [
      "read_repository",
      "read_registry"
    ]
  }
]
```

<a id="retrieve-a-group-deploy-token"></a>

### 检索群组部署令牌

按 ID 检索单个群组的部署令牌。

```plaintext
GET /groups/:id/deploy_tokens/:token_id
```

参数：

| 属性       | 类型           | 必需               | 描述                                                |
|------------|----------------|--------------------|-----------------------------------------------------|
| `id`       | integer 或 string | 是                 | 群组的 ID 或[URL 编码路径](rest/_index.md#namespaced-paths) |
| `token_id` | integer        | 是                 | 部署令牌的 ID                                       |

示例请求：

```shell
curl --header "PRIVATE-TOKEN: <your_access_token>" \
  --url "https://gitlab.example.com/api/v4/groups/1/deploy_tokens/1"
```

示例响应：

```json
{
  "id": 1,
  "name": "MyToken",
  "username": "gitlab+deploy-token-1",
  "expires_at": "2020-02-14T00:00:00.000Z",
  "revoked": false,
  "expired": false,
  "scopes": [
    "read_repository",
    "read_registry"
  ]
}
```

<a id="create-a-group-deploy-token"></a>

### 创建群组部署令牌

创建一个群组部署令牌。

```plaintext
POST /groups/:id/deploy_tokens
```

参数：

| 属性         | 类型             | 必需               | 描述                                                                                                                       |
|--------------|------------------|--------------------|----------------------------------------------------------------------------------------------------------------------------|
| `id`         | integer 或 string | 是                 | 群组的 ID 或[URL 编码路径](rest/_index.md#namespaced-paths)                                                                 |
| `name`       | string           | 是                 | 新部署令牌的名称                                                                                                           |
| `scopes`     | array of strings | 是                 | 指示部署令牌的范围。必须至少为 `read_repository`、`read_registry`、`write_registry`、`read_package_registry` 或 `write_package_registry` 之一。 |
| `expires_at` | datetime         | 否                 | 部署令牌的到期日期。如果未提供值，则永不过期。期望的格式为 ISO 8601 (`2019-03-15T08:00:00Z`)                                    |
| `username`   | string           | 否                 | 部署令牌的用户名。默认为 `gitlab+deploy-token-{n}`                                                                        |

示例请求：

```shell
curl --request POST \
  --header "PRIVATE-TOKEN: <your_access_token>" \
  --header "Content-Type: application/json" \
  --data '{"name": "My deploy token", "expires_at": "2021-01-01", "username": "custom-user", "scopes": ["read_repository"]}' \
  --url "https://gitlab.example.com/api/v4/groups/5/deploy_tokens/"
```

示例响应：

```json
{
  "id": 1,
  "name": "My deploy token",
  "username": "custom-user",
  "expires_at": "2021-01-01T00:00:00.000Z",
  "token": "jMRvtPNxrn3crTAGukpZ",
  "revoked": false,
  "expired": false,
  "scopes": [
    "read_registry"
  ]
}
```

<a id="delete-a-group-deploy-token"></a>

### 删除群组部署令牌

从群组中删除部署令牌。

```plaintext
DELETE /groups/:id/deploy_tokens/:token_id
```

参数：

| 属性       | 类型           | 必需               | 描述                                                |
|------------|----------------|--------------------|-----------------------------------------------------|
| `id`       | integer 或 string | 是                 | 群组的 ID 或[URL 编码路径](rest/_index.md#namespaced-paths) |
| `token_id` | integer        | 是                 | 部署令牌的 ID                                       |

示例请求：

```shell
curl --request DELETE \
  --header "PRIVATE-TOKEN: <your_access_token>" \
  --url "https://gitlab.example.com/api/v4/groups/5/deploy_tokens/13"
```