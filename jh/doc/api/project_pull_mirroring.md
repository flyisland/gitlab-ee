---
stage: Create
group: Source Code
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
title: 拉取镜像 API
description: 管理项目的拉取镜像。查看镜像详情、配置镜像设置并启动镜像更新。
---

{{< details >}}

- Tier: 专业版，旗舰版
- Offering: JihuLab.com，私有化部署

{{< /details >}}

使用此 API 管理项目的[拉取镜像](../user/project/repository/mirror/pull.md)。

<a id="retrieve-project-pull-mirror-details"></a>

## 获取项目拉取镜像详情

获取指定项目的拉取镜像详情。

```plaintext
GET /projects/:id/mirror/pull
```

支持的属性：

| 属性 | 类型              | 是否必需 | 描述 |
|:----------|:------------------|:---------|:------------|
| `id`      | integer or string | 是      | 项目 ID 或 [URL 编码的项目路径](rest/_index.md#namespaced-paths)。 |

如果成功，返回 [`200 OK`](rest/troubleshooting.md#status-codes) 及以下响应属性：

| 属性                             | 类型            | 描述 |
|---------------------------------------|-----------------|-------------|
| `enabled`                             | boolean         | 如果为 `true`，表示镜像处于活动状态。 |
| `id`                                  | integer         | 镜像配置的唯一标识符。 |
| `last_error`                          | string or null  | 最近的错误消息（如有）。如果没有发生错误，则为 `null`。 |
| `last_successful_update_at`           | string          | 上次成功镜像更新的时间戳。 |
| `last_update_at`                      | string          | 最近一次镜像更新尝试的时间戳。 |
| `last_update_started_at`              | string          | 上次镜像更新进程开始的时间戳。 |
| `mirror_branch_regex`                 | string or null  | 用于筛选要镜像的分支的正则表达式模式。如果未设置，则为 `null`。 |
| `mirror_overwrites_diverged_branches` | boolean         | 如果为 `true`，则在镜像过程中覆盖已分叉的分支。 |
| `mirror_trigger_builds`               | boolean         | 如果为 `true`，则为镜像更新触发构建。 |
| `only_mirror_protected_branches`      | boolean or null | 如果为 `true`，则仅镜像受保护分支。如果未设置，则该值为 `null`。 |
| `update_status`                       | string          | 镜像更新进程的状态。可能的值：`none`、`scheduled`、`started`、`finished`、`failed` 或 `canceled`。 |
| `url`                                 | string          | 被镜像代码仓库的 URL。 |

示例请求：

```shell
curl --header "PRIVATE-TOKEN: <your_access_token>" \
  --url "https://gitlab.example.com/api/v4/projects/:id/mirror/pull"
```

示例响应：

```json
{
  "id": 101486,
  "last_error": null,
  "last_successful_update_at": "2020-01-06T17:32:02.823Z",
  "last_update_at": "2020-01-06T17:32:02.823Z",
  "last_update_started_at": "2020-01-06T17:31:55.864Z",
  "update_status": "finished",
  "url": "https://*****:*****@gitlab.com/gitlab-org/security/gitlab.git",
  "enabled": true,
  "mirror_trigger_builds": true,
  "only_mirror_protected_branches": null,
  "mirror_overwrites_diverged_branches": false,
  "mirror_branch_regex": null
}
```

<a id="update-project-pull-mirroring-settings"></a>

## 更新项目拉取镜像设置

更新项目的拉取镜像设置。

```plaintext
PUT /projects/:id/mirror/pull
```

支持的属性：

| 属性                             | 类型              | 是否必需 | 描述 |
|:--------------------------------------|:------------------|:---------|:------------|
| `id`                                  | integer or string | 是      | 项目 ID 或 [URL 编码的项目路径](rest/_index.md#namespaced-paths)。 |
| `auth_password`                       | string            | 否       | 用于项目拉取镜像身份验证的密码。 |
| `auth_user`                           | string            | 否       | 用于项目拉取镜像身份验证的用户名。 |
| `enabled`                             | boolean           | 否       | 如果设置为 `true`，则为 `true` 时在项目上启用拉取镜像。 |
| `mirror_branch_regex`                 | string            | 否       | 包含正则表达式。仅镜像名称与正则表达式匹配的分支。使用此属性时，请省略 `only_mirror_protected_branches`。同时发送两者会返回 `400 Bad Request`，即使 `only_mirror_protected_branches` 为 `false` 也是如此。 |
| `mirror_overwrites_diverged_branches` | boolean           | 否       | 如果为 `true`，则覆盖已分叉的分支。 |
| `mirror_trigger_builds`               | boolean           | 否       | 如果为 `true`，则为镜像更新触发流水线。 |
| `only_mirror_protected_branches`      | boolean           | 否       | 如果为 `true`，则将镜像限制为仅受保护分支。使用此属性时，请省略 `mirror_branch_regex`。同时发送两者会返回 `400 Bad Request`。 |
| `url`                                 | string            | 否       | 被镜像的远程代码仓库的 URL。 |

如果成功，返回 [`200 OK`](rest/troubleshooting.md#status-codes) 及更新后的拉取镜像配置。

添加拉取镜像的示例请求：

```shell
curl --request PUT \
  --header "PRIVATE-TOKEN: <your_access_token>" \
  --header "Content-Type: application/json" \
  --data '{
    "enabled": true,
    "url": "https://gitlab.example.com/group/project.git",
    "auth_user": "user",
    "auth_password": "password"
  }' \
  --url "https://gitlab.example.com/api/v4/projects/:id/mirror/pull"
```

移除拉取镜像的示例请求：

```shell
curl --request PUT \
  --header "PRIVATE-TOKEN: <your_access_token>" \
  --data "enabled=false" \
  --url "https://gitlab.example.com/api/v4/projects/:id/mirror/pull"
```

示例响应：

```json
{
  "id": 101486,
  "last_error": null,
  "last_successful_update_at": "2020-01-06T17:32:02.823Z",
  "last_update_at": "2020-01-06T17:32:02.823Z",
  "last_update_started_at": "2020-01-06T17:31:55.864Z",
  "update_status": "finished",
  "url": "https://gitlab.example.com/group/project.git",
  "enabled": true,
  "mirror_trigger_builds": false,
  "only_mirror_protected_branches": null,
  "mirror_overwrites_diverged_branches": false,
  "mirror_branch_regex": null
}
```

<a id="update-pull-mirroring-for-a-project-deprecated"></a>

## 更新项目的拉取镜像（已弃用）

> [!warning]
> 此配置选项已在极狐GitLab 17.6 中[弃用](https://gitlab.com/gitlab-org/gitlab/-/issues/494294)，
> 并计划在 API v5 中移除。请改用[新的配置和端点](#update-project-pull-mirroring-settings)。
> 此更改属于破坏性更改。

如果远程代码仓库可公开访问或使用 `username:token` 身份验证，请在[创建](projects.md#create-a-project)或[更新](projects.md#update-a-project)项目时使用 API 配置拉取镜像。

如果您的 HTTP 代码仓库不可公开访问，您可以将身份验证信息添加到 URL 中。例如，`https://username:token@gitlab.company.com/group/project.git`，其中 `token` 是启用了 `api` 作用域的[个人访问令牌](../user/profile/personal_access_tokens.md)。

支持的属性：

| 属性                        | 类型    | 是否必需 | 描述 |
|:---------------------------------|:--------|:---------|:------------|
| `import_url`                     | string  | 是      | 被镜像的远程代码仓库的 URL（如有需要，可包含 `user:token`）。 |
| `mirror`                         | boolean | 是      | 如果为 `true`，则启用拉取镜像。 |
| `mirror_branch_regex`            | string  | 否       | 包含正则表达式。仅镜像名称与正则表达式匹配的分支。要求禁用 `only_mirror_protected_branches`。 |
| `mirror_trigger_builds`          | boolean | 否       | 如果为 `true`，则为镜像更新触发流水线。 |
| `only_mirror_protected_branches` | boolean | 否       | 如果为 `true`，则将镜像限制为仅受保护分支。 |

创建带拉取镜像的项目的示例：

```shell
curl --request POST \
  --header "PRIVATE-TOKEN: <your_access_token>" \
  --header "Content-Type: application/json" \
  --data '{
    "name": "new_project",
    "namespace_id": "1",
    "mirror": true,
    "import_url": "https://username:token@gitlab.example.com/group/project.git"
  }' \
  --url "https://gitlab.example.com/api/v4/projects/"
```

添加拉取镜像的示例：

```shell
curl --request PUT \
  --header "PRIVATE-TOKEN: <your_access_token>" \
  --data "mirror=true&import_url=https://username:token@gitlab.example.com/group/project.git" \
  --url "https://gitlab.example.com/api/v4/projects/:id"
```

移除拉取镜像的示例：

```shell
curl --request PUT \
  --header "PRIVATE-TOKEN: <your_access_token>" \
  --data "mirror=false" \
  --url "https://gitlab.example.com/api/v4/projects/:id"
```

<a id="start-the-pull-mirroring-process-for-a-project"></a>

## 启动项目的拉取镜像进程

启动项目的拉取镜像进程。

```plaintext
POST /projects/:id/mirror/pull
```

支持的属性：

| 属性 | 类型              | 是否必需 | 描述 |
|:----------|:------------------|:---------|:------------|
| `id`      | integer or string | 是      | 项目 ID 或 [URL 编码的项目路径](rest/_index.md#namespaced-paths)。 |
| `force`   | boolean           | 否       | 如果为 `true`，则重置硬失败的镜像并重试更新。对于使用 GitHub webhook 签名进行身份验证的请求，此属性将被忽略。 |

如果成功，返回 [`200 OK`](rest/troubleshooting.md#status-codes)。

示例请求：

```shell
curl --request POST \
  --header "PRIVATE-TOKEN: <your_access_token>" \
  --url "https://gitlab.example.com/api/v4/projects/:id/mirror/pull"
```

要恢复硬失败的镜像，请将 `force` 设置为 `true`。更多信息，请参阅[修复镜像时的硬失败](../user/project/repository/mirror/pull.md#fix-hard-failures-when-mirroring)。

示例请求：

```shell
curl --request POST \
  --header "PRIVATE-TOKEN: <your_access_token>" \
  --data "force=true" \
  --url "https://gitlab.example.com/api/v4/projects/:id/mirror/pull"
```
