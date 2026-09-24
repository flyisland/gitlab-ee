---
stage: Create
group: Source Code
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
title: 拉取镜像 API
description: Manage pull mirroring for projects. View mirror details, configure mirroring settings, and start mirror updates.
---

{{< details >}}

- Tier: 专业版，旗舰版
- Offering: JihuLab.com，私有化部署

{{< /details >}}

使用此 API 管理项目的[拉取镜像](../user/project/repository/mirror/pull.md)。

<a id="retrieve-project-pull-mirror-details"></a>

## 获取项目拉取镜像详情

{{< history >}}

- 在极狐GitLab 15.4 中扩展了响应，包含镜像配置信息，带有名为 `maven_central_request_forwarding` 的[功能标志](../../../administration/feature_flags/_index.md)，默认禁用。
- 在极狐GitLab 17.0 中，所需角色从维护者更改为所有者。

{{< /history >}}

获取指定项目的拉取镜像详情。

```plaintext
GET /projects/:id/mirror/pull
```

支持的属性：

| 属性 | 类型 | 必需 | 描述 |
|:------|:------|:------|:------|
| `id` | 整数或字符串 | 是 | ID 或[项目的 URL 编码路径](rest/_index.md#namespaced-paths)。 |

如果成功，返回 [`200 OK`](rest/troubleshooting.md#status-codes) 以及以下响应属性：

| 属性 | 类型 | 描述 |
|:------|:------|:------|
| `enabled` | 布尔 | 如果为 `true`，镜像处于活动状态。 |
| `id` | 整数 | 镜像配置的唯一标识符。 |
| `last_error` | 字符串或 null | 最近的错误消息（如果有）。如果没有发生错误则为 `null`。 |
| `last_successful_update_at` | 字符串 | 上次成功镜像更新的时间戳。 |
| `last_update_at` | 字符串 | 最近一次镜像更新尝试的时间戳。 |
| `last_update_started_at` | 字符串 | 上次镜像更新过程开始的时间戳。 |
| `mirror_branch_regex` | 字符串或 null | 用于过滤要镜像的分支的正则表达式模式。如果未设置则为 `null`。 |
| `mirror_overwrites_diverged_branches` | 布尔 | 如果为 `true`，在镜像过程中覆盖分叉的分支。 |
| `mirror_trigger_builds` | 布尔 | 如果为 `true`，为镜像更新触发构建。 |
| `only_mirror_protected_branches` | 布尔或 null | 如果为 `true`，仅镜像受保护的分支。如果未设置，值为 `null`。 |
| `update_status` | 字符串 | 镜像更新过程的状态。可能的取值：`none`、`scheduled`、`started`、`finished`、`failed` 或 `canceled`。 |
| `url` | 字符串 | 被镜像的仓库的 URL。 |

请求示例：

```shell
curl --header "PRIVATE-TOKEN: <your_access_token>" \
  --url "https://gitlab.example.com/api/v4/projects/:id/mirror/pull"
```

响应示例：

```json
{
  "id": 101486,
  "last_error": null,
  "last_successful_update_at": "2020-01-06T17:32:02.823Z",
  "last_update_at": "2020-01-06T17:32:02.823Z",
  "last_update_started_at": "2020-01-06T17:31:55.864Z",
  "update_status": "finished",
  "url": "https://*****:*****@jihulab.com/gitlab-cn/security/gitlab.git",
  "enabled": true,
  "mirror_trigger_builds": true,
  "only_mirror_protected_branches": null,
  "mirror_overwrites_diverged_branches": false,
  "mirror_branch_regex": null
}
```

<a id="update-project-pull-mirroring-settings"></a>

## 更新项目拉取镜像设置

{{< history >}}

- 在极狐GitLab 17.6 中引入。

{{< /history >}}

更新项目的拉取镜像设置。

```plaintext
PUT /projects/:id/mirror/pull
```

支持的属性：

| 属性 | 类型 | 必需 | 描述 |
|:------|:------|:------|:------|
| `id` | 整数或字符串 | 是 | ID 或[项目的 URL 编码路径](rest/_index.md#namespaced-paths)。 |
| `auth_password` | 字符串 | 否 | 用于拉取镜像的项目身份验证密码。 |
| `auth_user` | 字符串 | 否 | 用于拉取镜像的项目身份验证用户名。 |
| `enabled` | 布尔 | 否 | 如果设置为 `true`，则在项目上启用拉取镜像。 |
| `mirror_branch_regex` | 字符串 | 否 | 包含正则表达式。仅名称与该正则表达式匹配的分支会被镜像。需要禁用 `only_mirror_protected_branches`。 |
| `mirror_overwrites_diverged_branches` | 布尔 | 否 | 如果为 `true`，覆盖分叉的分支。 |
| `mirror_trigger_builds` | 布尔 | 否 | 如果为 `true`，为镜像更新触发流水线。 |
| `only_mirror_protected_branches` | 布尔 | 否 | 如果为 `true`，将镜像限制为仅受保护的分支。 |
| `url` | 字符串 | 否 | 被镜像的远程仓库的 URL。 |

如果成功，返回 [`200 OK`](rest/troubleshooting.md#status-codes) 以及更新后的拉取镜像配置。

添加拉取镜像的请求示例：

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

删除拉取镜像的请求示例：

```shell
curl --request PUT \
  --header "PRIVATE-TOKEN: <your_access_token>" \
  --data "enabled=false" \
  --url "https://gitlab.example.com/api/v4/projects/:id/mirror/pull"
```

响应示例：

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

{{< history >}}

- 功能标志 `mirror_only_branches_match_regex` 在极狐GitLab 16.0 中默认启用。
- 在极狐GitLab 16.2 中[GA](https://gitlab.com/gitlab-org/gitlab/-/issues/410354)。功能标志 `mirror_only_branches_match_regex` 已移除。
- 在极狐GitLab 17.6 中[弃用](https://gitlab.com/gitlab-org/gitlab/-/issues/494294)。

{{< /history >}}

> [!警告]
> 该配置选项在极狐GitLab 17.6 中[已弃用](https://gitlab.com/gitlab-org/gitlab/-/issues/494294)，并计划在 API v5 中移除。请改用[新的配置和端点](project_pull_mirroring.md#update-project-pull-mirroring-settings)。此更改是一个重大更改。

如果远程仓库可以公开访问或使用 `username:token` 身份验证，你可以在[创建项目](projects.md#create-a-project)或[更新项目](projects.md#update-a-project)时使用该 API 配置拉取镜像。

如果你的 HTTP 仓库不公开，你可以在 URL 中添加身份验证信息。例如，`https://username:token@gitlab.company.com/group/project.git`，其中 `token` 是具有 `api` 作用域的[个人访问令牌](../user/profile/personal_access_tokens.md)。

支持的属性：

| 属性 | 类型 | 必需 | 描述 |
|:------|:------|:------|:------|
| `import_url` | 字符串 | 是 | 被镜像的远程仓库的 URL（如果需要，包含 `user:token`）。 |
| `mirror` | 布尔 | 是 | 如果为 `true`，启用拉取镜像。 |
| `mirror_branch_regex` | 字符串 | 否 | 包含正则表达式。仅名称与该正则表达式匹配的分支会被镜像。需要禁用 `only_mirror_protected_branches`。 |
| `mirror_trigger_builds` | 布尔 | 否 | 如果为 `true`，为镜像更新触发流水线。 |
| `only_mirror_protected_branches` | 布尔 | 否 | 如果为 `true`，将镜像限制为仅受保护的分支。 |

创建带有拉取镜像的项目的请求示例：

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

添加拉取镜像的请求示例：

```shell
curl --request PUT \
  --header "PRIVATE-TOKEN: <your_access_token>" \
  --data "mirror=true&import_url=https://username:token@gitlab.example.com/group/project.git" \
  --url "https://gitlab.example.com/api/v4/projects/:id"
```

删除拉取镜像的请求示例：

```shell
curl --request PUT \
  --header "PRIVATE-TOKEN: <your_access_token>" \
  --data "mirror=false" \
  --url "https://gitlab.example.com/api/v4/projects/:id"
```

<a id="start-the-pull-mirroring-process-for-a-project"></a>

## 启动项目的拉取镜像过程

启动项目的拉取镜像过程。

```plaintext
POST /projects/:id/mirror/pull
```

支持的属性：

| 属性 | 类型 | 必需 | 描述 |
|:------|:------|:------|:------|
| `id` | 整数或字符串 | 是 | ID 或[项目的 URL 编码路径](rest/_index.md#namespaced-paths)。 |

如果成功，返回 [`202 Accepted`](rest/troubleshooting.md#status-codes)。

请求示例：

```shell
curl --request POST \
  --header "PRIVATE-TOKEN: <your_access_token>" \
  --url "https://gitlab.example.com/api/v4/projects/:id/mirror/pull"
```