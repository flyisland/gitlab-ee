---
stage: Software Supply Chain Security
group: Pipeline Security
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
title: CI/CD 作业令牌范围 API
---

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: JihuLab.com，私有化部署

{{< /details >}}

使用此 API 与 [CI/CD 作业令牌](../ci/jobs/ci_job_token.md) 范围进行交互。

> [!note]
> 所有对 CI/CD 作业令牌范围 API 端点的请求都必须[经过身份验证](rest/authentication.md)。
> 经过身份验证的用户必须具有项目的维护者或所有者角色。

<a id="retrieve-the-ci-cd-job-token-access-settings-for-a-project"></a>

## 获取项目的 CI/CD 作业令牌访问设置

检索指定项目的 [CI/CD 作业令牌访问设置](../ci/jobs/ci_job_token.md#control-job-token-access-to-your-project)
（作业令牌范围）。

```plaintext
获取 /projects/:id/job_token_scope
```

支持的属性：

| 属性 | 类型           | 是否必需 | 描述 |
|-----------|----------------|----------|-------------|
| `id`      | 整数或字符串 | 是      | ID 或[项目的 URL 编码路径](rest/_index.md#namespaced-paths)。 |

如果成功，返回 [`200`](rest/troubleshooting.md#status-codes) 以及以下响应属性：

| 属性          | 类型    | 描述 |
|--------------------|---------|-------------|
| `inbound_enabled`  | 布尔值 | 指示是否为白名单启用了[**已授权的群组和项目**](../ci/jobs/ci_job_token.md#add-a-group-or-project-to-the-job-token-allowlist) 设置。如果禁用，则[所有项目都有访问权限](../ci/jobs/ci_job_token.md#allow-any-project-to-access-your-project)。此值显示白名单当前是否处于活动状态，由于[**强制执行作业令牌白名单**](../administration/settings/continuous_integration.md#enforce-job-token-allowlist) 实例设置，该值可能为 `true`。 |
| `outbound_enabled` | 布尔值 | 指示此项目中生成的 CI/CD 作业令牌是否有权访问其他项目。[已弃用并计划在极狐GitLab 18.0 中移除](../update/deprecations.md#cicd-job-token---limit-access-from-your-project-setting-removal)。 |

示例请求：

```shell
curl --request GET \
  --header "PRIVATE-TOKEN: <your_access_token>" \
  --url "https://gitlab.example.com/api/v4/projects/1/job_token_scope"
```

示例响应：

```json
{
  "inbound_enabled": true,
  "outbound_enabled": false
}
```

<a id="update-the-ci-cd-job-token-access-settings-for-a-project"></a>

## 更新项目的 CI/CD 作业令牌访问设置

{{< history >}}

- 在极狐GitLab 16.3 中，从 **允许使用 CI_JOB_TOKEN 访问此项目** 重命名为 **限制对此项目的访问**。
- 在极狐GitLab 17.2 中，从 **限制对此项目的访问** 重命名为 **已授权的群组和项目**。

{{< /history >}}

更新指定项目的[**已授权的群组和项目** 设置](../ci/jobs/ci_job_token.md#add-a-group-or-project-to-the-job-token-allowlist)
（作业令牌范围）。

```plaintext
PATCH /projects/:id/job_token_scope
```

支持的属性：

| 属性 | 类型              | 是否必需 | 描述 |
|-----------|-------------------|----------|-------------|
| `id`      | 整数或字符串 | 是      | ID 或[项目的 URL 编码路径](rest/_index.md#namespaced-paths)。 |
| `enabled` | 布尔值           | 是      | 仅限制作业令牌访问白名单中的项目。设置为 `false` 允许所有项目的访问。此参数可以被[**强制执行作业令牌白名单**](../administration/settings/continuous_integration.md#enforce-job-token-allowlist) 实例设置覆盖。 |

如果成功，返回 [`204`](rest/troubleshooting.md#status-codes) 并且没有响应主体。

如果启用了**强制执行作业令牌白名单**实例设置，并且您尝试将 `enabled` 设置为 `false`,
则返回 [`400`](rest/troubleshooting.md#status-codes) 并包含错误信息。

示例请求：

```shell
curl --request PATCH \
  --url "https://gitlab.example.com/api/v4/projects/1/job_token_scope" \
  --header 'PRIVATE-TOKEN: <your_access_token>' \
  --header 'Content-Type: application/json' \
  --data '{ "enabled": false }'
```

<a id="list-all-projects-in-a-ci-cd-job-token-allowlist"></a>

## 列出 CI/CD 作业令牌白名单中的所有项目

列出指定项目的 [CI/CD 作业令牌白名单](../ci/jobs/ci_job_token.md#add-a-group-or-project-to-the-job-token-allowlist) 中的所有项目。

```plaintext
GET /projects/:id/job_token_scope/allowlist
```

支持的属性：

| 属性 | 类型           | 是否必需 | 描述 |
|-----------|----------------|----------|-------------|
| `id`      | 整数或字符串 | 是      | ID 或[项目的 URL 编码路径](rest/_index.md#namespaced-paths)。 |

此端点支持[基于偏移的分页](rest/_index.md#offset-based-pagination)。

如果成功，返回 [`200`](rest/troubleshooting.md#status-codes) 以及一个项目列表，每个项目包含有限的字段。

示例请求：

```shell
curl --request GET \
  --header "PRIVATE-TOKEN: <your_access_token>" \
  --url "https://gitlab.example.com/api/v4/projects/1/job_token_scope/allowlist"
```

示例响应：

```json
[
  {
    "id": 4,
    "description": null,
    "name": "Diaspora Client",
    "name_with_namespace": "Diaspora / Diaspora Client",
    "path": "diaspora-client",
    "path_with_namespace": "diaspora/diaspora-client",
    "created_at": "2013-09-30T13:46:02Z",
    "default_branch": "main",
    "tag_list": [
      "example",
      "disapora client"
    ],
    "topics": [
      "example",
      "disapora client"
    ],
    "ssh_url_to_repo": "git@gitlab.example.com:diaspora/diaspora-client.git",
    "http_url_to_repo": "https://gitlab.example.com/diaspora/diaspora-client.git",
    "web_url": "https://gitlab.example.com/diaspora/diaspora-client",
    "avatar_url": "https://gitlab.example.com/uploads/project/avatar/4/uploads/avatar.png",
    "star_count": 0,
    "last_activity_at": "2013-09-30T13:46:02Z",
    "namespace": {
      "id": 2,
      "name": "Diaspora",
      "path": "diaspora",
      "kind": "group",
      "full_path": "diaspora",
      "parent_id": null,
      "avatar_url": null,
      "web_url": "https://gitlab.example.com/diaspora"
    }
  },
  {
    ...
  }
]
```

<a id="add-a-project-to-a-ci-cd-job-token-allowlist"></a>

## 将项目添加到 CI/CD 作业令牌白名单

将项目添加到指定项目的 [CI/CD 作业令牌白名单](../ci/jobs/ci_job_token.md#add-a-group-or-project-to-the-job-token-allowlist) 中。

```plaintext
POST /projects/:id/job_token_scope/allowlist
```

支持的属性：

| 属性           | 类型           | 是否必需 | 描述 |
|---------------------|----------------|----------|-------------|
| `id`                | 整数或字符串 | 是      | ID 或[项目的 URL 编码路径](rest/_index.md#namespaced-paths)。 |
| `target_project_id` | 整数        | 是      | 添加到 CI/CD 作业令牌入站白名单中的项目的 ID。 |

如果成功，返回 [`201`](rest/troubleshooting.md#status-codes) 以及以下响应属性：

| 属性           | 类型    | 描述 |
|---------------------|---------|-------------|
| `source_project_id` | 整数 | 包含要更新的 CI/CD 作业令牌入站白名单的项目的 ID。 |
| `target_project_id` | 整数 | 添加到源项目入站白名单中的项目的 ID。 |

示例请求：

```shell
curl --request POST \
  --url "https://gitlab.example.com/api/v4/projects/1/job_token_scope/allowlist" \
  --header 'PRIVATE-TOKEN: <your_access_token>' \
  --header 'Content-Type: application/json' \
  --data '{ "target_project_id": 2 }'
```

示例响应：

```json
{
  "source_project_id": 1,
  "target_project_id": 2
}
```

<a id="delete-a-project-from-a-ci-cd-job-token-allowlist"></a>

## 从 CI/CD 作业令牌白名单中删除项目

从指定项目的 [CI/CD 作业令牌白名单](../ci/jobs/ci_job_token.md#add-a-group-or-project-to-the-job-token-allowlist) 中删除项目。

```plaintext
DELETE /projects/:id/job_token_scope/allowlist/:target_project_id
```

支持的属性：

| 属性           | 类型           | 是否必需 | 描述 |
|---------------------|----------------|----------|-------------|
| `id`                | 整数或字符串 | 是      | ID 或[项目的 URL 编码路径](rest/_index.md#namespaced-paths)。 |
| `target_project_id` | 整数        | 是      | 要从 CI/CD 作业令牌入站白名单中移除的项目的 ID。 |

如果成功，返回 [`204`](rest/troubleshooting.md#status-codes) 并且没有响应主体。

示例请求：

```shell
curl --request DELETE \
  --url "https://gitlab.example.com/api/v4/projects/1/job_token_scope/allowlist/2" \
  --header 'PRIVATE-TOKEN: <your_access_token>' \
  --header 'Content-Type: application/json'
```

<a id="list-all-groups-in-a-ci-cd-job-token-allowlist"></a>

## 列出 CI/CD 作业令牌白名单中的所有群组

列出指定项目的 [CI/CD 作业令牌白名单](../ci/jobs/ci_job_token.md#add-a-group-or-project-to-the-job-token-allowlist) 中的所有群组。

```plaintext
GET /projects/:id/job_token_scope/groups_allowlist
```

支持的属性：

| 属性 | 类型           | 是否必需 | 描述 |
|-----------|----------------|----------|-------------|
| `id`      | 整数或字符串 | 是      | ID 或[项目的 URL 编码路径](rest/_index.md#namespaced-paths)。 |

此端点支持[基于偏移的分页](rest/_index.md#offset-based-pagination)。

如果成功，返回 [`200`](rest/troubleshooting.md#status-codes) 以及一个群组列表，每个群组包含有限的字段。

示例请求：

```shell
curl --request GET \
  --header "PRIVATE-TOKEN: <your_access_token>" \
  --url "https://gitlab.example.com/api/v4/projects/1/job_token_scope/groups_allowlist"
```

示例响应：

```json
[
  {
    "id": 4,
    "web_url": "https://gitlab.example.com/groups/diaspora/diaspora-group",
    "name": "namegroup"
  },
  {
    ...
  }
]
```

<a id="add-a-group-to-a-ci-cd-job-token-allowlist"></a>

## 将群组添加到 CI/CD 作业令牌白名单

将群组添加到指定项目的 [CI/CD 作业令牌白名单](../ci/jobs/ci_job_token.md#add-a-group-or-project-to-the-job-token-allowlist) 中。

```plaintext
POST /projects/:id/job_token_scope/groups_allowlist
```

支持的属性：

| 属性         | 类型           | 是否必需 | 描述 |
|-------------------|----------------|----------|-------------|
| `id`              | 整数或字符串 | 是      | ID 或[项目的 URL 编码路径](rest/_index.md#namespaced-paths)。 |
| `target_group_id` | 整数        | 是      | 添加到 CI/CD 作业令牌群组白名单中的群组的 ID。 |

如果成功，返回 [`201`](rest/troubleshooting.md#status-codes) 以及以下响应属性：

| 属性           | 类型    | 描述 |
|---------------------|---------|-------------|
| `source_project_id` | 整数 | 包含要更新的 CI/CD 作业令牌入站白名单的项目的 ID。 |
| `target_group_id`   | 整数 | 添加到源项目群组白名单中的群组的 ID。 |

示例请求：

```shell
curl --request POST \
  --url "https://gitlab.example.com/api/v4/projects/1/job_token_scope/groups_allowlist" \
  --header 'PRIVATE-TOKEN: <your_access_token>' \
  --header 'Content-Type: application/json' \
  --data '{ "target_group_id": 2 }'
```

示例响应：

```json
{
  "source_project_id": 1,
  "target_group_id": 2
}
```

<a id="delete-a-group-from-a-ci-cd-job-token-allowlist"></a>

## 从 CI/CD 作业令牌白名单中删除群组

从指定项目的 [CI/CD 作业令牌白名单](../ci/jobs/ci_job_token.md#add-a-group-or-project-to-the-job-token-allowlist) 中删除群组。

```plaintext
DELETE /projects/:id/job_token_scope/groups_allowlist/:target_group_id
```

支持的属性：

| 属性         | 类型           | 是否必需 | 描述 |
|-------------------|----------------|----------|-------------|
| `id`              | 整数或字符串 | 是      | ID 或[项目的 URL 编码路径](rest/_index.md#namespaced-paths)。 |
| `target_group_id` | 整数        | 是      | 要从 CI/CD 作业令牌群组白名单中移除的群组的 ID。 |

如果成功，返回 [`204`](rest/troubleshooting.md#status-codes) 并且没有响应主体。

示例请求：

```shell
curl --request DELETE \
  --url "https://gitlab.example.com/api/v4/projects/1/job_token_scope/groups_allowlist/2" \
  --header 'PRIVATE-TOKEN: <your_access_token>' \
  --header 'Content-Type: application/json'
```