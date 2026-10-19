---
stage: Create
group: Source Code
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
title: 项目远程镜像 API
---

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: JihuLab.com，私有化部署

{{< /details >}}

使用此 API 管理[远程镜像](../user/project/repository/mirror/push.md)。您可以使用远程镜像 API 查询和修改这些镜像的状态。

出于安全原因，API 响应中的 `url` 属性始终会擦除用户名和密码信息。

> [!note]
> [拉取镜像](../user/project/repository/mirror/pull.md) 使用[不同的 API 端点](project_pull_mirroring.md#update-project-pull-mirroring-settings) 来展示和更新它们。

<a id="list-all-remote-mirrors-for-a-project"></a>

## 列出项目的所有远程镜像

{{< history >}}

- 属性 `host_keys` 在极狐GitLab 18.4 引入。

{{< /history >}}

列出指定项目的所有远程镜像。

```plaintext
GET /projects/:id/remote_mirrors
```

支持的属性：

| 属性   | 类型              | 必需 | 描述                                                                      |
|--------|-------------------|------|---------------------------------------------------------------------------|
| `id`   | 整数或字符串      | 是   | ID 或 [项目的 URL 编码路径](rest/_index.md#namespaced-paths)。           |

如果成功，返回 [`200 OK`](rest/troubleshooting.md#status-codes) 和以下响应属性：

| 属性                      | 类型    | 描述 |
|---------------------------|---------|------|
| `auth_method`             | 字符串  | 镜像使用的认证方法。 |
| `enabled`                 | 布尔值  | 如果为 `true`，则镜像已启用。 |
| `host_keys`               | 数组    | 远程镜像的 SSH 主机密钥指纹数组。 |
| `id`                      | 整数    | 远程镜像的 ID。 |
| `keep_divergent_refs`     | 布尔值  | 如果为 `true`，镜像时保留偏离引用。 |
| `last_error`              | 字符串  | 上次镜像尝试的错误消息。成功时为 `null`。 |
| `last_successful_update_at` | 字符串  | 上次成功镜像更新的时间戳。ISO 8601 格式。 |
| `last_update_at`          | 字符串  | 上次镜像尝试的时间戳。ISO 8601 格式。 |
| `last_update_started_at`  | 字符串  | 上次镜像尝试开始的时间戳。ISO 8601 格式。 |
| `only_protected_branches` | 布尔值  | 如果为 `true`，则仅镜像受保护分支。 |
| `update_status`           | 字符串  | 镜像更新的状态。可能的值：`none`、`scheduled`、`started`、`finished`、`failed`。 |
| `url`                     | 字符串  | 出于安全考虑已擦除凭据的镜像 URL。 |

示例请求：

```shell
curl --request GET \
  --header "PRIVATE-TOKEN: <your_access_token>" \
  --url "https://gitlab.example.com/api/v4/projects/42/remote_mirrors"
```

示例响应：

```json
[
  {
    "enabled": true,
    "id": 101486,
    "auth_method": "ssh_public_key",
    "last_error": null,
    "last_successful_update_at": "2020-01-06T17:32:02.823Z",
    "last_update_at": "2020-01-06T17:32:02.823Z",
    "last_update_started_at": "2020-01-06T17:31:55.864Z",
    "only_protected_branches": true,
    "keep_divergent_refs": true,
    "update_status": "finished",
    "url": "https://*****:*****@gitlab.com/gitlab-org/security/gitlab.git",
    "host_keys": [
      {
        "fingerprint_sha256": "SHA256:HbW3g8zUjNSksFbqTiUWPWg2Bq1x8xdGUrliXFzSnUw"
      }
    ]
  }
]
```

<a id="retrieve-a-remote-mirror-for-a-project"></a>

## 获取项目的远程镜像

{{< history >}}

- 属性 `host_keys` 在极狐GitLab 18.4 引入。

{{< /history >}}

获取项目的指定远程镜像。

```plaintext
GET /projects/:id/remote_mirrors/:mirror_id
```

支持的属性：

| 属性       | 类型              | 必需 | 描述 |
|------------|-------------------|------|------|
| `id`       | 整数或字符串      | 是   | ID 或 [项目的 URL 编码路径](rest/_index.md#namespaced-paths)。 |
| `mirror_id`| 整数              | 是   | 远程镜像的 ID。 |

如果成功，返回 [`200 OK`](rest/troubleshooting.md#status-codes) 和以下响应属性：

| 属性                      | 类型    | 描述 |
|---------------------------|---------|------|
| `enabled`                 | 布尔值  | 如果为 `true`，则镜像已启用。 |
| `id`                      | 整数    | 远程镜像的 ID。 |
| `host_keys`               | 数组    | 远程镜像的 SSH 主机密钥指纹数组。 |
| `keep_divergent_refs`     | 布尔值  | 如果为 `true`，镜像时保留偏离引用。 |
| `last_error`              | 字符串  | 上次镜像尝试的错误消息。成功时为 `null`。 |
| `last_successful_update_at` | 字符串  | 上次成功镜像更新的时间戳。ISO 8601 格式。 |
| `last_update_at`          | 字符串  | 上次镜像尝试的时间戳。ISO 8601 格式。 |
| `last_update_started_at`  | 字符串  | 上次镜像尝试开始的时间戳。ISO 8601 格式。 |
| `only_protected_branches` | 布尔值  | 如果为 `true`，则仅镜像受保护分支。 |
| `update_status`           | 字符串  | 镜像更新的状态。可能的值：`none`、`scheduled`、`started`、`finished`、`failed`。 |
| `url`                     | 字符串  | 出于安全考虑已擦除凭据的镜像 URL。 |

示例请求：

```shell
curl --request GET \
  --header "PRIVATE-TOKEN: <your_access_token>" \
  --url "https://gitlab.example.com/api/v4/projects/42/remote_mirrors/101486"
```

示例响应：

```json
{
  "enabled": true,
  "id": 101486,
  "last_error": null,
  "last_successful_update_at": "2020-01-06T17:32:02.823Z",
  "last_update_at": "2020-01-06T17:32:02.823Z",
  "last_update_started_at": "2020-01-06T17:31:55.864Z",
  "only_protected_branches": true,
  "keep_divergent_refs": true,
  "update_status": "finished",
  "url": "https://*****:*****@gitlab.com/gitlab-org/security/gitlab.git",
  "host_keys": [
    {
      "fingerprint_sha256": "SHA256:HbW3g8zUjNSksFbqTiUWPWg2Bq1x8xdGUrliXFzSnUw"
    }
  ]
}
```

<a id="retrieve-a-public-key-for-a-remote-mirror"></a>

## 获取远程镜像的公钥

{{< history >}}

- 在极狐GitLab 17.9 引入。

{{< /history >}}

获取使用 SSH 认证的指定远程镜像的公钥。

```plaintext
GET /projects/:id/remote_mirrors/:mirror_id/public_key
```

支持的属性：

| 属性       | 类型              | 必需 | 描述 |
|------------|-------------------|------|------|
| `id`       | 整数或字符串      | 是   | ID 或 [项目的 URL 编码路径](rest/_index.md#namespaced-paths)。 |
| `mirror_id`| 整数              | 是   | 远程镜像的 ID。 |

如果成功，返回 [`200 OK`](rest/troubleshooting.md#status-codes) 和以下响应属性：

| 属性        | 类型   | 描述                        |
|-------------|--------|-----------------------------|
| `public_key`| 字符串 | 远程镜像的公钥。            |

示例请求：

```shell
curl --request GET \
  --header "PRIVATE-TOKEN: <your_access_token>" \
  --url "https://gitlab.example.com/api/v4/projects/42/remote_mirrors/101486/public_key"
```

示例响应：

```json
{
  "public_key": "ssh-rsa AAAAB3NzaC1yc2EA..."
}
```

<a id="create-a-pull-mirror"></a>

## 创建拉取镜像

了解如何使用[项目拉取镜像 API](project_pull_mirroring.md#update-project-pull-mirroring-settings) 配置拉取镜像。

<a id="create-a-push-mirror"></a>

## 创建推送镜像

{{< history >}}

- 在极狐GitLab 16.0 中[默认启用](https://gitlab.com/gitlab-org/gitlab/-/issues/381667)。
- 在极狐GitLab 16.2 中[GA](https://gitlab.com/gitlab-org/gitlab/-/issues/410354)。功能标志 `mirror_only_branches_match_regex` 移除。
- 字段 `auth_method` 在极狐GitLab 16.10 引入。
- 属性 `host_keys` 在极狐GitLab 18.4 引入。

{{< /history >}}

> [!note]
> 每个项目最多可启用 10 个推送镜像。更多信息，请参见[项目推送镜像的最大数量](../administration/instance_limits.md#maximum-number-of-project-push-mirrors)。

为项目创建推送镜像。推送镜像默认禁用。要启用它，请在创建镜像时包含可选参数 `enabled`。

```plaintext
POST /projects/:id/remote_mirrors
```

支持的属性：

| 属性                     | 类型              | 必需 | 描述 |
|--------------------------|-------------------|------|------|
| `id`                     | 整数或字符串      | 是   | ID 或 [项目的 URL 编码路径](rest/_index.md#namespaced-paths)。 |
| `url`                    | 字符串            | 是   | 镜像仓库的目标 URL。 |
| `auth_method`            | 字符串            | 否   | 镜像认证方法。接受值：`ssh_public_key`，`password`。 |
| `enabled`                | 布尔值            | 否   | 如果为 `true`，则镜像已启用。 |
| `host_keys`              | 字符串数组        | 否   | SSH 主机密钥，采用裸格式（`ssh-ed25519 AAAA...`）或完整 `known_hosts` 格式（`hostname ssh-ed25519 AAAA...`）。裸密钥使用镜像 URL 中的主机名。 |
| `keep_divergent_refs`    | 布尔值            | 否   | 如果为 `true`，镜像时保留偏离引用。 |
| `mirror_branch_regex`    | 字符串            | 否   | 用于匹配要镜像的分支名称的正则表达式。仅镜像名称匹配该正则表达式的分支。需要禁用 `only_protected_branches`。仅专业版和旗舰版。 |
| `only_protected_branches`| 布尔值            | 否   | 如果为 `true`，则仅镜像受保护分支。 |

如果成功，返回 [`201 Created`](rest/troubleshooting.md#status-codes) 和以下响应属性：

| 属性                      | 类型    | 描述 |
|---------------------------|---------|------|
| `auth_method`             | 字符串  | 镜像使用的认证方法。 |
| `enabled`                 | 布尔值  | 如果为 `true`，则镜像已启用。 |
| `host_keys`               | 数组    | 远程镜像的 SSH 主机密钥指纹数组。 |
| `id`                      | 整数    | 远程镜像的 ID。 |
| `keep_divergent_refs`     | 布尔值  | 如果为 `true`，镜像时保留偏离引用。 |
| `last_error`              | 字符串  | 上次镜像尝试的错误消息。成功时为 `null`。 |
| `last_successful_update_at` | 字符串  | 上次成功镜像更新的时间戳。ISO 8601 格式。 |
| `last_update_at`          | 字符串  | 上次镜像尝试的时间戳。ISO 8601 格式。 |
| `last_update_started_at`  | 字符串  | 上次镜像尝试开始的时间戳。ISO 8601 格式。 |
| `only_protected_branches` | 布尔值  | 如果为 `true`，则仅镜像受保护分支。 |
| `update_status`           | 字符串  | 镜像更新的状态。可能的值：`none`、`scheduled`、`started`、`finished`、`failed`。 |
| `url`                     | 字符串  | 出于安全考虑已擦除凭据的镜像 URL。 |

示例请求：

```shell
curl --request POST \
  --data "url=https://username:token@example.com/gitlab/example.git" \
  --header "PRIVATE-TOKEN: <your_access_token>" \
  --url "https://gitlab.example.com/api/v4/projects/42/remote_mirrors"
```

示例响应：

```json
{
    "enabled": false,
    "id": 101486,
    "auth_method": "password",
    "last_error": null,
    "last_successful_update_at": null,
    "last_update_at": null,
    "last_update_started_at": null,
    "only_protected_branches": false,
    "keep_divergent_refs": false,
    "update_status": "none",
    "url": "https://*****:*****@example.com/gitlab/example.git",
    "host_keys": [
      {
        "fingerprint_sha256": "SHA256:HbW3g8zUjNSksFbqTiUWPWg2Bq1x8xdGUrliXFzSnUw"
      }
    ]
}
```

<a id="update-a-remote-mirror-in-a-project"></a>

## 更新项目中的远程镜像

{{< history >}}

- 字段 `auth_method` 在极狐GitLab 16.10 引入。
- 属性 `host_keys` 在极狐GitLab 18.4 引入。

{{< /history >}}

更新指定远程镜像的配置或运行状态。

```plaintext
PUT /projects/:id/remote_mirrors/:mirror_id
```

支持的属性：

| 属性                     | 类型              | 必需 | 描述 |
|--------------------------|-------------------|------|------|
| `id`                     | 整数或字符串      | 是   | ID 或 [项目的 URL 编码路径](rest/_index.md#namespaced-paths)。 |
| `mirror_id`              | 整数              | 是   | 远程镜像的 ID。 |
| `auth_method`            | 字符串            | 否   | 镜像认证方法。接受值：`ssh_public_key`，`password`。 |
| `enabled`                | 布尔值            | 否   | 如果为 `true`，则镜像已启用。 |
| `host_keys`              | 字符串数组        | 否   | SSH 主机密钥，采用裸格式（`ssh-ed25519 AAAA...`）或完整 `known_hosts` 格式（`hostname ssh-ed25519 AAAA...`）。裸密钥使用镜像 URL 中的主机名。 |
| `keep_divergent_refs`    | 布尔值            | 否   | 如果为 `true`，镜像时保留偏离引用。 |
| `mirror_branch_regex`    | 字符串            | 否   | 用于匹配要镜像的分支名称的正则表达式。仅镜像名称匹配该正则表达式的分支。不能与启用的 `only_protected_branches` 一起使用。仅专业版和旗舰版。 |
| `only_protected_branches`| 布尔值            | 否   | 如果为 `true`，则仅镜像受保护分支。 |

如果成功，返回 [`200 OK`](rest/troubleshooting.md#status-codes) 和以下响应属性：

| 属性                      | 类型    | 描述 |
|---------------------------|---------|------|
| `auth_method`             | 字符串  | 镜像使用的认证方法。 |
| `enabled`                 | 布尔值  | 如果为 `true`，则镜像已启用。 |
| `host_keys`               | 数组    | 远程镜像的 SSH 主机密钥指纹数组。 |
| `id`                      | 整数    | 远程镜像的 ID。 |
| `keep_divergent_refs`     | 布尔值  | 如果为 `true`，镜像时保留偏离引用。 |
| `last_error`              | 字符串  | 上次镜像尝试的错误消息。成功时为 `null`。 |
| `last_successful_update_at` | 字符串  | 上次成功镜像更新的时间戳。ISO 8601 格式。 |
| `last_update_at`          | 字符串  | 上次镜像尝试的时间戳。ISO 8601 格式。 |
| `last_update_started_at`  | 字符串  | 上次镜像尝试开始的时间戳。ISO 8601 格式。 |
| `only_protected_branches` | 布尔值  | 如果为 `true`，则仅镜像受保护分支。 |
| `update_status`           | 字符串  | 镜像更新的状态。可能的值：`none`、`scheduled`、`started`、`finished`、`failed`。 |
| `url`                     | 字符串  | 出于安全考虑已擦除凭据的镜像 URL。 |

示例请求：

```shell
curl --request PUT \
  --data "enabled=false" \
  --header "PRIVATE-TOKEN: <your_access_token>" \
  --url "https://gitlab.example.com/api/v4/projects/42/remote_mirrors/101486"
```

示例响应：

```json
{
    "enabled": false,
    "id": 101486,
    "auth_method": "password",
    "last_error": null,
    "last_successful_update_at": "2020-01-06T17:32:02.823Z",
    "last_update_at": "2020-01-06T17:32:02.823Z",
    "last_update_started_at": "2020-01-06T17:31:55.864Z",
    "only_protected_branches": true,
    "keep_divergent_refs": true,
    "update_status": "finished",
    "url": "https://*****:*****@gitlab.com/gitlab-org/security/gitlab.git",
    "host_keys": [
      {
        "fingerprint_sha256": "SHA256:HbW3g8zUjNSksFbqTiUWPWg2Bq1x8xdGUrliXFzSnUw"
      }
    ]
}
```

<a id="force-push-mirror-update"></a>

## 强制更新推送镜像

{{< history >}}

- 在极狐GitLab 16.11 引入。

{{< /history >}}

[强制更新](../user/project/repository/mirror/_index.md#force-an-update) 一个推送镜像。

```plaintext
POST /projects/:id/remote_mirrors/:mirror_id/sync
```

支持的属性：

| 属性       | 类型              | 必需 | 描述 |
|------------|-------------------|------|------|
| `id`       | 整数或字符串      | 是   | ID 或 [项目的 URL 编码路径](rest/_index.md#namespaced-paths)。 |
| `mirror_id`| 整数              | 是   | 远程镜像的 ID。 |

如果成功，返回 [`204 No Content`](rest/troubleshooting.md#status-codes)。

示例请求：

```shell
curl --request POST \
  --header "PRIVATE-TOKEN: <your_access_token>" \
  --url "https://gitlab.example.com/api/v4/projects/42/remote_mirrors/101486/sync"
```

<a id="delete-a-remote-mirror-from-a-project"></a>

## 从项目中删除远程镜像

从项目中删除指定的远程镜像。

```plaintext
DELETE /projects/:id/remote_mirrors/:mirror_id
```

支持的属性：

| 属性       | 类型              | 必需 | 描述 |
|------------|-------------------|------|------|
| `id`       | 整数或字符串      | 是   | ID 或 [项目的 URL 编码路径](rest/_index.md#namespaced-paths)。 |
| `mirror_id`| 整数              | 是   | 远程镜像的 ID。 |

如果成功，返回 [`204 No Content`](rest/troubleshooting.md#status-codes)。

示例请求：

```shell
curl --request DELETE \
  --header "PRIVATE-TOKEN: <your_access_token>" \
  --url "https://gitlab.example.com/api/v4/projects/42/remote_mirrors/101486"
```