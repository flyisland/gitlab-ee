---
stage: Verify
group: Runner Core
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
description: API endpoints for managing 极狐GitLab environments including listing, creating, updating, stopping, and deleting environments.
title: 环境 API
---

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: JihuLab.com，私有化部署

{{< /details >}}

{{< history >}}

- 参数 `auto_stop_setting` 在极狐GitLab 17.8 [添加]。
- 对 [极狐GitLab CI/CD 作业令牌](../ci/jobs/ci_job_token.md) 认证的支持在极狐GitLab 16.2 [引入]。

{{< /history >}}

使用此 API 与 [极狐GitLab 环境](../ci/environments/_index.md) 进行交互。

<a id="list-all-environments"></a>

## 列出所有环境

列出一个指定项目的所有环境。

```plaintext
GET /projects/:id/environments
```

| 属性 | 类型 | 是否必填 | 描述 |
|-----------|----------------|----------|-------------|
| `id`      | integer or string | 是      | 项目的 ID 或 [URL 编码](rest/_index.md#namespaced-paths) 路径。 |
| `name`    | string         | 否       | 返回具有此名称的环境。与 `search` 互斥。 |
| `search`  | string         | 否       | 返回符合搜索条件的环境列表。与 `name` 互斥。必须至少为 3 个字符。 |
| `states`  | string         | 否       | 列出所有匹配特定状态的环境。可接受的值：`available`、`stopping` 或 `stopped`。若未提供状态值，则返回所有环境。 |

```shell
curl --header "PRIVATE-TOKEN: <your_access_token>" \
  --url "https://gitlab.example.com/api/v4/projects/1/environments?name=review%2Ffix-foo"
```

示例响应：

```json
[
  {
    "id": 1,
    "name": "review/fix-foo",
    "slug": "review-fix-foo-dfjre3",
    "description": "This is review environment",
    "external_url": "https://review-fix-foo-dfjre3.gitlab.example.com",
    "state": "available",
    "tier": "development",
    "created_at": "2019-05-25T18:55:13.252Z",
    "updated_at": "2019-05-27T18:55:13.252Z",
    "enable_advanced_logs_querying": false,
    "logs_api_path": "/project/-/logs/k8s.json?environment_name=review%2Ffix-foo",
    "auto_stop_at": "2019-06-03T18:55:13.252Z",
    "kubernetes_namespace": "flux-system",
    "flux_resource_path": "HelmRelease/flux-system",
    "auto_stop_setting": "always"
  }
]
```

<a id="retrieve-an-environment"></a>

## 获取一个环境

获取一个项目的指定环境。

```plaintext
GET /projects/:id/environments/:environment_id
```

| 属性        | 类型           | 是否必填 | 描述 |
|------------------|----------------|----------|-------------|
| `id`             | integer or string | 是      | 项目的 ID 或 [URL 编码](rest/_index.md#namespaced-paths) 路径。 |
| `environment_id` | integer        | 是      | 环境的 ID。 |

```shell
curl --header "PRIVATE-TOKEN: <your_access_token>" \
  --url "https://gitlab.example.com/api/v4/projects/1/environments/1"
```

响应示例：

```json
{
  "id": 1,
  "name": "review/fix-foo",
  "slug": "review-fix-foo-dfjre3",
  "description": "This is review environment",
  "external_url": "https://review-fix-foo-dfjre3.gitlab.example.com",
  "state": "available",
  "tier": "development",
  "created_at": "2019-05-25T18:55:13.252Z",
  "updated_at": "2019-05-27T18:55:13.252Z",
  "enable_advanced_logs_querying": false,
  "logs_api_path": "/project/-/logs/k8s.json?environment_name=review%2Ffix-foo",
  "auto_stop_at": "2019-06-03T18:55:13.252Z",
  "last_deployment": {
    "id": 100,
    "iid": 34,
    "ref": "fdroid",
    "sha": "416d8ea11849050d3d1f5104cf8cf51053e790ab",
    "created_at": "2019-03-25T18:55:13.252Z",
    "status": "success",
    "user": {
      "id": 1,
      "name": "Administrator",
      "state": "active",
      "username": "root",
      "avatar_url": "http://www.gravatar.com/avatar/e64c7d89f26bd1972efa854d13d7dd61?s=80&d=identicon",
      "web_url": "http://localhost:3000/root"
    },
    "deployable": {
      "id": 710,
      "status": "success",
      "stage": "deploy",
      "name": "staging",
      "ref": "fdroid",
      "tag": false,
      "coverage": null,
      "created_at": "2019-03-25T18:55:13.215Z",
      "started_at": "2019-03-25T12:54:50.082Z",
      "finished_at": "2019-03-25T18:55:13.216Z",
      "duration": 21623.13423,
      "project": {
        "ci_job_token_scope_enabled": false
      },
      "user": {
        "id": 1,
        "name": "Administrator",
        "username": "root",
        "state": "active",
        "avatar_url": "http://www.gravatar.com/avatar/e64c7d89f26bd1972efa854d13d7dd61?s=80&d=identicon",
        "web_url": "http://gitlab.dev/root",
        "created_at": "2015-12-21T13:14:24.077Z",
        "bio": null,
        "location": null,
        "public_email": "",
        "linkedin": "",
        "twitter": "",
        "website_url": "",
        "organization": null
      },
      "commit": {
        "id": "416d8ea11849050d3d1f5104cf8cf51053e790ab",
        "short_id": "416d8ea1",
        "created_at": "2016-01-02T15:39:18.000Z",
        "parent_ids": [
          "e9a4449c95c64358840902508fc827f1a2eab7df"
        ],
        "title": "Removed fabric to fix #40",
        "message": "Removed fabric to fix #40\n",
        "author_name": "Administrator",
        "author_email": "admin@example.com",
        "authored_date": "2016-01-02T15:39:18.000Z",
        "committer_name": "Administrator",
        "committer_email": "admin@example.com",
        "committed_date": "2016-01-02T15:39:18.000Z"
      },
      "pipeline": {
        "id": 34,
        "sha": "416d8ea11849050d3d1f5104cf8cf51053e790ab",
        "ref": "fdroid",
        "status": "success",
        "web_url": "http://localhost:3000/Commit451/lab-coat/pipelines/34"
      },
      "web_url": "http://localhost:3000/Commit451/lab-coat/-/jobs/710",
      "artifacts": [
        {
          "file_type": "trace",
          "size": 1305,
          "filename": "job.log",
          "file_format": null
        }
      ],
      "runner": null,
      "artifacts_expire_at": null
    }
  },
  "cluster_agent": {
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
  "kubernetes_namespace": "flux-system",
  "flux_resource_path": "HelmRelease/flux-system",
  "auto_stop_setting": "always"
}
```

<a id="create-an-environment"></a>

## 创建环境

为指定项目创建一个环境。

```plaintext
POST /projects/:id/environments
```

| 属性              | 类型           | 是否必填 | 描述 |
|------------------------|----------------|----------|-------------|
| `id`                   | integer or string | 是      | 项目的 ID 或 [URL 编码](rest/_index.md#namespaced-paths) 路径。 |
| `name`                 | string         | 是      | 环境的名称。 |
| `description`          | string         | 否       | 环境的描述。 |
| `external_url`         | string         | 否       | 此环境的链接地址。 |
| `tier`                 | string         | 否       | 新环境的层级。允许的值：`production`、`staging`、`testing`、`development` 和 `other`。 |
| `cluster_agent_id`     | integer        | 否       | 与此环境关联的集群代理。 |
| `kubernetes_namespace` | string         | 否       | 与此环境关联的 Kubernetes 命名空间。 |
| `flux_resource_path`   | string         | 否       | 与此环境关联的 Flux 资源路径。必须为完整的资源路径。例如，`helm.toolkit.fluxcd.io/v2/namespaces/gitlab-agent/helmreleases/gitlab-agent`。 |
| `auto_stop_setting`    | string         | 否       | 环境的自动停止设置。允许的值：`always` 或 `with_action`。 |

若成功，返回 `201`；若参数错误，返回 `400`。

```shell
curl --data "name=deploy&external_url=https://deploy.gitlab.example.com" \
  --header "PRIVATE-TOKEN: <your_access_token>" \
  --url "https://gitlab.example.com/api/v4/projects/1/environments"
```

示例响应：

```json
{
  "id": 1,
  "name": "deploy",
  "slug": "deploy",
  "description": null,
  "external_url": "https://deploy.gitlab.example.com",
  "state": "available",
  "tier": "production",
  "created_at": "2019-05-25T18:55:13.252Z",
  "updated_at": "2019-05-27T18:55:13.252Z",
  "kubernetes_namespace": "flux-system",
  "flux_resource_path": "HelmRelease/flux-system",
  "auto_stop_setting": "always"
}
```

<a id="update-an-existing-environment"></a>

## 更新现有环境

{{< history >}}

- 参数 `name` 在极狐GitLab 16.0 [移除]。

{{< /history >}}

更新一个项目的现有环境。

```plaintext
PUT /projects/:id/environments/:environments_id
```

| 属性              | 类型            | 是否必填 | 描述 |
|------------------------|-----------------|----------|-------------|
| `id`                   | integer or string  | 是      | 项目的 ID 或 [URL 编码路径](rest/_index.md#namespaced-paths)。 |
| `environment_id`       | integer         | 是      | 环境的 ID。 |
| `description`          | string          | 否       | 环境的描述。 |
| `external_url`         | string          | 否       | 新的 `external_url`。 |
| `tier`                 | string          | 否       | 新环境的层级。允许的值：`production`、`staging`、`testing`、`development` 和 `other`。 |
| `cluster_agent_id`     | integer or null | 否       | 与此环境关联的集群代理，或 `null` 移除关联。 |
| `kubernetes_namespace` | string or null  | 否       | 与此环境关联的 Kubernetes 命名空间，或 `null` 移除关联。 |
| `flux_resource_path`   | string or null  | 否       | 与此环境关联的 Flux 资源路径，或 `null` 移除关联。 |
| `auto_stop_setting`    | string or null  | 否       | 环境的自动停止设置。允许的值：`always` 或 `with_action`。 |

若成功，返回 `200`；若出错，返回 `400`。

```shell
curl --request PUT \
  --data "external_url=https://staging.gitlab.example.com" \
  --header "PRIVATE-TOKEN: <your_access_token>" \
  --url "https://gitlab.example.com/api/v4/projects/1/environments/1"
```

示例响应：

```json
{
  "id": 1,
  "name": "staging",
  "slug": "staging",
  "description": null,
  "external_url": "https://staging.gitlab.example.com",
  "state": "available",
  "tier": "staging",
  "created_at": "2019-05-25T18:55:13.252Z",
  "updated_at": "2019-05-27T18:55:13.252Z",
  "kubernetes_namespace": "flux-system",
  "flux_resource_path": "HelmRelease/flux-system",
  "auto_stop_setting": "always"
}
```

<a id="delete-an-environment"></a>

## 删除环境

从项目中删除一个环境。环境必须已先停止。

```plaintext
DELETE /projects/:id/environments/:environment_id
```

| 属性        | 类型           | 是否必填 | 描述 |
|------------------|----------------|----------|-------------|
| `id`             | integer or string | 是      | 项目的 ID 或 [URL 编码](rest/_index.md#namespaced-paths) 路径。 |
| `environment_id` | integer        | 是      | 环境的 ID。 |

若成功，返回 `204`；若环境不存在，返回 `404`；若环境未停止，返回 `403`。

```shell
curl --request DELETE \
  --header "PRIVATE-TOKEN: <your_access_token>" \
  --url "https://gitlab.example.com/api/v4/projects/1/environments/1"
```

<a id="delete-multiple-stopped-review-apps"></a>

## 删除多个已停止的评审应用

计划删除多个已经[停止](../ci/environments/_index.md#stopping-an-environment)并且[位于评审应用文件夹中](../ci/review_apps/_index.md)的环境。实际删除将在执行后的一周进行。默认情况下，仅删除存在 30 天或更久的环境。

```plaintext
DELETE /projects/:id/environments/review_apps
```

| 属性 | 类型           | 是否必填 | 描述 |
|-----------|----------------|----------|-------------|
| `id`      | integer or string | 是      | 项目的 ID 或 [URL 编码](rest/_index.md#namespaced-paths) 路径。 |
| `before`  | datetime       | 否       | 在此日期之前的环境可被删除。默认为 30 天前。要求 ISO 8601 格式 (`YYYY-MM-DDTHH:MM:SSZ`)。 |
| `limit`   | integer        | 否       | 要删除的最大环境数量。默认为 100。 |
| `dry_run` | boolean        | 否       | 默认为 `true`（出于安全考虑）。执行一次演练，不会实际删除。设置为 `false` 以真正删除环境。 |

```shell
curl --request DELETE \
  --header "PRIVATE-TOKEN: <your_access_token>" \
  --url "https://gitlab.example.com/api/v4/projects/1/environments/review_apps"
```

示例响应：

```json
{
  "scheduled_entries": [
    {
      "id": 387,
      "name": "review/023f1bce01229c686a73",
      "slug": "review-023f1bce01-3uxznk",
      "external_url": null
    },
    {
      "id": 388,
      "name": "review/85d4c26a388348d3c4c0",
      "slug": "review-85d4c26a38-5giw1c",
      "external_url": null
    }
  ],
  "unprocessable_entries": []
}
```

<a id="stop-an-environment"></a>

## 停止环境

停止一个正在运行的环境。

```plaintext
POST /projects/:id/environments/:environment_id/stop
```

| 属性        | 类型           | 是否必填 | 描述 |
|------------------|----------------|----------|-------------|
| `id`             | integer or string | 是      | 项目的 ID 或 [URL 编码](rest/_index.md#namespaced-paths) 路径。 |
| `environment_id` | integer        | 是      | 环境的 ID。 |
| `force`          | boolean        | 否       | 是否强制停止环境而不执行 `on_stop` 动作。 |

```shell
curl --request POST \
  --header "PRIVATE-TOKEN: <your_access_token>" \
  --url "https://gitlab.example.com/api/v4/projects/1/environments/1/stop"
```

示例响应：

```json
{
  "id": 1,
  "name": "deploy",
  "slug": "deploy",
  "external_url": "https://deploy.gitlab.example.com",
  "state": "stopped",
  "created_at": "2019-05-25T18:55:13.252Z",
  "updated_at": "2019-05-27T18:55:13.252Z",
  "kubernetes_namespace": "flux-system",
  "flux_resource_path": "HelmRelease/flux-system",
  "auto_stop_setting": "always"
}
```

<a id="stop-stale-environments"></a>

## 停止过期环境

停止所有在指定日期之前最后修改或部署的环境。不包括受保护的环境。

```plaintext
POST /projects/:id/environments/stop_stale
```

| 属性 | 类型           | 是否必填 | 描述 |
|-----------|----------------|----------|-------------|
| `id`      | integer or string | 是      | 项目的 ID 或 [URL 编码](rest/_index.md#namespaced-paths) 路径。 |
| `before`  | date           | 是      | 停止在此日期之前修改或部署的环境。要求 ISO 8601 格式 (`2019-03-15T08:00:00Z`)。有效输入介于 10 年前和 1 周前之间。 |

```shell
curl --request POST \
  --header "PRIVATE-TOKEN: <your_access_token>" \
  --url "https://gitlab.example.com/api/v4/projects/1/environments/stop_stale?before=10%2F10%2F2021"
```

示例响应：

```json
{
  "message": "Successfully requested stop for all stale environments"
}
```