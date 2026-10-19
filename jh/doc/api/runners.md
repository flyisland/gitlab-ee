---
stage: Verify
group: Runner Core
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
title: Runners API
---

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: JihuLab.com，私有化部署

{{< /details >}}

使用此 API 管理注册到实例的 [runners](../ci/runners/_index.md)。

要创建新的实例、群组或项目 runner，请使用 [`POST /user/runners`](users.md#create-a-runner-linked-to-a-user) 端点。
使用此 API 管理现有 runner。

以下 API 端点支持[分页](rest/_index.md#pagination)（默认返回 20 项）：

```plaintext
GET /runners
GET /runners/all
GET /runners/:id/jobs
GET /projects/:id/runners
GET /groups/:id/runners
```

<a id="registration-and-authentication-tokens"></a>

## 注册和认证令牌

要连接 runner 与极狐GitLab，您需要两个令牌。

| 令牌 | 描述 |
| ----- | ----------- |
| 注册令牌（旧版） | 用于[注册 runner](https://gitlab.cn/docs/runner/register/) 的令牌。可以通过极狐GitLab [获取](../ci/runners/_index.md)。 |
| 认证令牌 | 用于验证 runner 与极狐GitLab 实例的令牌。当您[注册 runner](https://gitlab.cn/docs/runner/register/) 时自动获得，或通过 Runners API 手动[注册 runner](#create-a-runner) 或[重置认证令牌](#reset-runners-authentication-token-by-using-the-runner-id)时获得。您也可以使用 [`POST /user/runners`](users.md#create-a-runner-linked-to-a-user) 端点获取令牌。 |

以下是如何使用令牌进行 runner 注册的示例：

1. 使用极狐GitLab API 通过注册令牌注册 runner 以接收认证令牌。
1. 将认证令牌添加到 [runner 的配置文件](https://gitlab.cn/docs/runner/commands/#configuration-file)：

   ```toml
   [[runners]]
     token = "<authentication_token>"
   ```

随后极狐GitLab 和 runner 即连接成功。

<a id="list-all-available-runners"></a>

## 列出所有可用的 runner

列出用户可用的所有 runner。

前提条件：

- 对于群组 runner，您必须在所有者命名空间中具有所有者角色。
- 对于项目 runner，您必须在分配给 runner 的项目中具有安全管理员、维护者或所有者角色。

```plaintext
GET /runners
GET /runners?scope=active
GET /runners?type=project_type
GET /runners?status=online
GET /runners?paused=true
GET /runners?tag_list=tag1,tag2
```

| 属性        | 类型         | 必需 | 描述 |
|------------------|--------------|----------|-------------|
| `scope`          | string       | 否       | 已弃用：改用 `type` 或 `status`。要返回的 runner 范围，可选值：`active`、`paused`、`online` 和 `offline`；如果未提供，则显示所有 runner |
| `type`           | string       | 否       | 要返回的 runner 类型，可选值：`instance_type`、`group_type`、`project_type` |
| `status`         | string       | 否       | 要返回的 runner 状态，可选值：`online`、`offline`、`stale` 或 `never_contacted`。<br/>其他可能的值是已弃用的 `active` 和 `paused`。<br/>请求 `offline` 状态的 runner 可能也会返回 `stale` 状态的 runner，因为 `stale` 包含在 `offline` 中。 |
| `paused`         | boolean      | 否       | 是否仅包含接受或忽略新作业的 runner |
| `tag_list`       | string array | 否       | runner 标签列表 |
| `version_prefix` | string       | 否       | 要返回的 runner 版本前缀。例如 `15.0`、`14`、`16.1.241` |

```shell
curl --header "PRIVATE-TOKEN: <your_access_token>" \
     --url "https://gitlab.example.com/api/v4/runners"
```

> [!warning]
> 弃用项：
>
> - `status` 查询参数中的 `active` 和 `paused` 值已弃用，计划在未来的 REST API 版本中移除。请改用 `paused` 查询参数。
> - 响应中的 `active` 属性已弃用，计划在未来的 REST API 版本中移除。请改用 `paused` 属性。
> - 响应中的 `ip_address` 属性已弃用于极狐GitLab 16.1，并计划在未来的 REST API 版本中移除。在极狐GitLab 17.0 中，该属性返回空字符串。`ipAddress` 属性可以在相应的 runner 管理器内找到，只能通过 GraphQL [`CiRunnerManager` 类型](graphql/reference/_index.md#cirunnermanager)获取。

示例响应：

```json
[
    {
        "active": true,
        "paused": false,
        "description": "test-1-20150125",
        "id": 6,
        "ip_address": "",
        "is_shared": false,
        "runner_type": "project_type",
        "name": null,
        "online": true,
        "status": "online",
        "job_execution_status": "idle"
    },
    {
        "active": true,
        "paused": false,
        "description": "test-2-20150125",
        "id": 8,
        "ip_address": "",
        "is_shared": false,
        "runner_type": "group_type",
        "name": null,
        "online": false,
        "status": "offline",
        "job_execution_status": "idle"
    }
]
```

<a id="list-all-runners"></a>

## 列出所有 runner

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: 私有化部署

{{< /details >}}

列出极狐GitLab 实例中的所有 runner（项目和共享 runner）。

前提条件：

- 您必须具有管理员访问权限或审计员访问权限。

```plaintext
GET /runners/all
GET /runners/all?scope=online
GET /runners/all?type=project_type
GET /runners/all?status=online
GET /runners/all?paused=true
GET /runners/all?tag_list=tag1,tag2
```

| 属性        | 类型         | 必需 | 描述 |
|------------------|--------------|----------|-------------|
| `scope`          | string       | 否       | 已弃用：改用 `type` 或 `status`。要返回的 runner 范围，可选值：`specific`、`shared`、`active`、`paused`、`online` 和 `offline`；如果未提供，则显示所有 runner |
| `type`           | string       | 否       | 要返回的 runner 类型，可选值：`instance_type`、`group_type`、`project_type` |
| `status`         | string       | 否       | 要返回的 runner 状态，可选值：`online`、`offline`、`stale` 或 `never_contacted`。<br/>其他可能的值是已弃用的 `active` 和 `paused`。<br/>请求 `offline` 状态的 runner 可能也会返回 `stale` 状态的 runner，因为 `stale` 包含在 `offline` 中。 |
| `paused`         | boolean      | 否       | 是否仅包含接受或忽略新作业的 runner |
| `tag_list`       | string array | 否       | runner 标签列表 |
| `version_prefix` | string       | 否       | 要返回的 runner 版本前缀。例如 `15.0`、`16.1.241` |

```shell
curl --header "PRIVATE-TOKEN: <your_access_token>" \
     --url "https://gitlab.example.com/api/v4/runners/all"
```

> [!warning]
> 弃用项：
>
> - `status` 查询参数中的 `active` 和 `paused` 值已弃用，计划在未来的 REST API 版本中移除。请改用 `paused` 查询参数。
> - 响应中的 `active` 属性已弃用，计划在未来的 REST API 版本中移除。请改用 `paused` 属性。
> - 响应中的 `ip_address` 属性已弃用于极狐GitLab 16.1，并计划在未来的 REST API 版本中移除。在极狐GitLab 17.0 中，该属性返回空字符串。`ipAddress` 属性可以在相应的 runner 管理器内找到，只能通过 GraphQL [`CiRunnerManager` 类型](graphql/reference/_index.md#cirunnermanager)获取。
> - 响应中的 `version`、`revision`、`platform` 和 `architecture` 属性已弃用于极狐GitLab 17.0，并计划在未来的 REST API 版本中移除。相同的属性可以在相应的 runner 管理器内找到，只能通过 GraphQL [`CiRunnerManager` 类型](graphql/reference/_index.md#cirunnermanager)获取。

示例响应：

```json
[
    {
        "active": true,
        "paused": false,
        "description": "shared-runner-1",
        "id": 1,
        "ip_address": "",
        "is_shared": true,
        "runner_type": "instance_type",
        "name": null,
        "online": true,
        "status": "online",
        "job_execution_status": "idle"
    },
    {
        "active": true,
        "paused": false,
        "description": "shared-runner-2",
        "id": 3,
        "ip_address": "",
        "is_shared": true,
        "runner_type": "instance_type",
        "name": null,
        "online": false,
        "status": "offline",
        "job_execution_status": "idle"
    },
    {
        "active": true,
        "paused": false,
        "description": "test-1-20150125",
        "id": 6,
        "ip_address": "",
        "is_shared": false,
        "runner_type": "project_type",
        "name": null,
        "online": true,
        "status": "paused",
        "job_execution_status": "idle"
    },
    {
        "active": true,
        "paused": false,
        "description": "test-2-20150125",
        "id": 8,
        "ip_address": "",
        "is_shared": false,
        "runner_type": "group_type",
        "name": null,
        "online": false,
        "status": "offline",
        "job_execution_status": "idle"
    }
]
```

要查看前 20 个之后的 runner，请使用[分页](rest/_index.md#pagination)。

<a id="retrieve-runners-details"></a>

## 获取 runner 详情

获取 runner 的详细信息。

实例 runner 详情通过此端点对所有已认证用户可用。

前提条件：

- 用户访问权限：您必须具有以下之一：
  - 对于群组 runner：在所有者命名空间中具有维护者或所有者角色。
  - 对于项目 runner：在拥有该 runner 的项目中具有安全管理员、维护者或所有者角色。
  - 在相关群组或项目中具有 `admin_runners` 权限的自定义角色。
- 具有 `manage_runner` 范围及相应角色的访问令牌。

```plaintext
GET /runners/:id
```

| 属性 | 类型    | 必需 | 描述 |
|-----------|---------|----------|-------------|
| `id`      | integer | 是      | runner 的 ID |

```shell
curl --header "PRIVATE-TOKEN: <your_access_token>" \
     --url "https://gitlab.example.com/api/v4/runners/6"
```

> [!warning]
> 弃用项：
>
> - 响应中的 `active` 属性已弃用，计划在未来的 REST API 版本中移除。请改用 `paused` 属性。
> - 响应中的 `ip_address` 属性已弃用于极狐GitLab 16.1，并计划在未来的 REST API 版本中移除。在极狐GitLab 17.0 中，该属性返回空字符串。`ipAddress` 属性可以在相应的 runner 管理器内找到，只能通过 GraphQL [`CiRunnerManager` 类型](graphql/reference/_index.md#cirunnermanager)获取。
> - 响应中的 `version`、`revision`、`platform` 和 `architecture` 属性已弃用于极狐GitLab 17.0，并计划在未来的 REST API 版本中移除。相同的属性可以在相应的 runner 管理器内找到，只能通过 GraphQL [`CiRunnerManager` 类型](graphql/reference/_index.md#cirunnermanager)获取。

示例响应：

```json
{
    "active": true,
    "paused": false,
    "architecture": null,
    "description": "test-1-20150125",
    "id": 6,
    "ip_address": "",
    "is_shared": false,
    "runner_type": "project_type",
    "contacted_at": "2016-01-25T16:39:48.066Z",
    "maintenance_note": null,
    "name": null,
    "online": true,
    "status": "online",
    "job_execution_status": "idle",
    "platform": null,
    "projects": [
        {
            "id": 1,
            "name": "极狐GitLab 基础版",
            "name_with_namespace": "极狐GitLab.org / 极狐GitLab 基础版",
            "path": "gitlab-foss",
            "path_with_namespace": "gitlab-org/gitlab-foss"
        }
    ],
    "revision": null,
    "tag_list": [
        "ruby",
        "mysql"
    ],
    "version": null,
    "access_level": "ref_protected",
    "maximum_timeout": 3600
}
```

<a id="update-runners-details"></a>

## 更新 runner 详情

更新 runner 的详细信息。

```plaintext
PUT /runners/:id
```

前提条件：

- 用户访问权限：您必须具有以下之一：
  - 对于实例 runner：对极狐GitLab 实例具有管理员访问权限。
  - 对于群组 runner：在所有者命名空间中具有所有者角色。
  - 对于项目 runner：在分配给 runner 的项目中具有维护者或所有者角色。
  - 在相关群组或项目中具有 `admin_runners` 权限的自定义角色。
- 具有 `manage_runner` 范围及相应角色的访问令牌。

| 属性          | 类型    | 必需 | 描述 |
|--------------------|---------|----------|-------------|
| `id`               | integer | 是      | runner 的 ID |
| `description`      | string  | 否       | runner 的描述 |
| `active`           | boolean | 否       | 已弃用：改用 `paused`。指定 runner 是否允许接收作业的标志 |
| `paused`           | boolean | 否       | 指定 runner 是否应忽略新作业 |
| `tag_list`         | array   | 否       | runner 的标签列表 |
| `run_untagged`     | boolean | 否       | 指定 runner 是否可以执行无标签的作业 |
| `locked`           | boolean | 否       | 指定 runner 是否被锁定 |
| `access_level`     | string  | 否       | runner 的访问级别；`not_protected` 或 `ref_protected` |
| `maximum_timeout`  | integer | 否       | 限制 runner 运行作业的最长时间（秒） |
| `maintenance_note` | string  | 否       | runner 的自由格式维护说明（1024 个字符） |

```shell
curl --request PUT \
     --header "PRIVATE-TOKEN: <your_access_token>" \
     --url "https://gitlab.example.com/api/v4/runners/6" \
     --form "description=test-1-20150125-test" \
     --form "tag_list=ruby,mysql,tag1,tag2"
```

> [!warning]
> 弃用项：
>
> - `active` 查询参数已弃用，计划在未来的 REST API 版本中移除。请改用 `paused` 属性。
> - 响应中的 `ip_address` 属性已弃用于极狐GitLab 16.1，并计划在未来的 REST API 版本中移除。在极狐GitLab 17.0 中，该属性返回空字符串。`ipAddress` 属性可以在相应的 runner 管理器内找到，只能通过 GraphQL [`CiRunnerManager` 类型](graphql/reference/_index.md#cirunnermanager)获取。

示例响应：

```json
{
    "active": true,
    "architecture": null,
    "description": "test-1-20150125-test",
    "id": 6,
    "ip_address": "",
    "is_shared": false,
    "runner_type": "group_type",
    "contacted_at": "2016-01-25T16:39:48.066Z",
    "maintenance_note": null,
    "name": null,
    "online": true,
    "status": "online",
    "job_execution_status": "idle",
    "platform": null,
    "projects": [
        {
            "id": 1,
            "name": "极狐GitLab 基础版",
            "name_with_namespace": "极狐GitLab.org / 极狐GitLab 基础版",
            "path": "gitlab-foss",
            "path_with_namespace": "gitlab-org/gitlab-foss"
        }
    ],
    "revision": null,
    "tag_list": [
        "ruby",
        "mysql",
        "tag1",
        "tag2"
    ],
    "version": null,
    "access_level": "ref_protected",
    "maximum_timeout": null
}
```

<a id="pause-a-runner"></a>

### 暂停一个 runner

暂停一个 runner。

前提条件：

- 用户访问权限：您必须具有以下之一：
  - 对于实例 runner：对极狐GitLab 实例具有管理员访问权限。
  - 对于群组 runner：在所有者命名空间中具有所有者角色。
  - 对于项目 runner：在分配给 runner 的项目中具有维护者或所有者角色。
  - 在相关群组或项目中具有 `admin_runners` 权限的自定义角色。
- 具有 `manage_runner` 范围及相应角色的访问令牌。

```plaintext
PUT --form "paused=true" /runners/:runner_id

# --或--

# 已弃用：计划在 16.0 中移除
PUT --form "active=false" /runners/:runner_id
```

| 属性   | 类型    | 必需 | 描述 |
|-------------|---------|----------|-------------|
| `runner_id` | integer | 是      | runner 的 ID |

```shell
curl --request PUT \
     --header "PRIVATE-TOKEN: <your_access_token>" \
     --form "paused=true"  \
     --url "https://gitlab.example.com/api/v4/runners/6"

# --或--

# 已弃用：计划在 16.0 中移除
curl --request PUT \
     --header "PRIVATE-TOKEN: <your_access_token>" \
     --form "active=false"  \
     --url "https://gitlab.example.com/api/v4/runners/6"
```

> [!warning]
> `active` 表单属性已弃用，计划在未来的 REST API 版本中移除。请改用 `paused` 属性。

<a id="list-all-jobs-processed-by-a-runner"></a>

## 列出 runner 处理的所有作业

列出指定 runner 正在处理或已处理的所有作业。作业列表仅限于用户具有报告者、开发者、维护者或所有者角色的项目。

```plaintext
GET /runners/:id/jobs
```

| 属性   | 类型    | 必需 | 描述 |
|-------------|---------|----------|-------------|
| `id`        | integer | 是      | runner 的 ID |
| `system_id` | string  | 否       | runner 管理器运行所在的机器的系统 ID |
| `status`    | string  | 否       | 作业状态；可选值：`running`、`success`、`failed`、`canceled` |
| `order_by`  | string  | 否       | 按 `id` 排序作业 |
| `sort`      | string  | 否       | 按 `asc` 或 `desc` 顺序排序（默认：`desc`）。如果指定了 `sort`，则必须同时指定 `order_by` |

```shell
curl --header "PRIVATE-TOKEN: <your_access_token>" \
     --url "https://gitlab.example.com/api/v4/runners/1/jobs?status=running"
```

示例响应：

```json
[
    {
        "id": 2,
        "status": "running",
        "stage": "test",
        "name": "test",
        "ref": "main",
        "tag": false,
        "coverage": null,
        "created_at": "2017-11-16T08:50:29.000Z",
        "started_at": "2017-11-16T08:51:29.000Z",
        "finished_at": "2017-11-16T08:53:29.000Z",
        "duration": 120,
        "queued_duration": 2,
        "user": {
            "id": 1,
            "name": "John Doe2",
            "username": "user2",
            "state": "active",
            "avatar_url": "http://www.gravatar.com/avatar/c922747a93b40d1ea88262bf1aebee62?s=80&d=identicon",
            "web_url": "http://localhost/user2",
            "created_at": "2017-11-16T18:38:46.000Z",
            "bio": null,
            "location": null,
            "public_email": "",
            "linkedin": "",
            "twitter": "",
            "website_url": "",
            "organization": null
        },
        "commit": {
            "id": "97de212e80737a608d939f648d959671fb0a0142",
            "short_id": "97de212e",
            "title": "Update configuration\r",
            "created_at": "2017-11-16T08:50:28.000Z",
            "parent_ids": [
                "1b12f15a11fc6e62177bef08f47bc7b5ce50b141",
                "498214de67004b1da3d820901307bed2a68a8ef6"
            ],
            "message": "See merge request !123",
            "author_name": "John Doe2",
            "author_email": "user2@example.org",
            "authored_date": "2017-11-16T08:50:27.000Z",
            "committer_name": "John Doe2",
            "committer_email": "user2@example.org",
            "committed_date": "2017-11-16T08:50:27.000Z"
        },
        "pipeline": {
            "id": 2,
            "sha": "97de212e80737a608d939f648d959671fb0a0142",
            "ref": "main",
            "status": "running"
        },
        "project": {
            "id": 1,
            "description": null,
            "name": "project1",
            "name_with_namespace": "John Doe2 / project1",
            "path": "project1",
            "path_with_namespace": "namespace1/project1",
            "created_at": "2017-11-16T18:38:46.620Z"
        }
    }
]
```

<a id="list-all-runners-managers"></a>

## 列出 runner 的所有管理器

列出 runner 的所有管理器。

```plaintext
GET /runners/:id/managers
```

| 属性 | 类型    | 必需 | 描述 |
|-----------|---------|----------|-------------|
| `id`      | integer | 是      | runner 的 ID |

```shell
curl --header "PRIVATE-TOKEN: <your_access_token>" \
     --url "https://gitlab.example.com/api/v4/runners/1/managers"
```

示例响应：

```json
[
    {
      "id": 1,
      "system_id": "s_89e5e9956577",
      "version": "16.11.1",
      "revision": "535ced5f",
      "platform": "linux",
      "architecture": "amd64",
      "created_at": "2024-06-09T11:12:02.507Z",
      "contacted_at": "2024-06-09T06:30:09.355Z",
      "ip_address": "127.0.0.1",
      "status": "offline",
      "job_execution_status": "idle"
    },
    {
      "id": 2,
      "system_id": "runner-2",
      "version": "16.11.0",
      "revision": "91a27b2a",
      "platform": "linux",
      "architecture": "amd64",
      "created_at": "2024-06-09T09:12:02.507Z",
      "contacted_at": "2024-06-09T06:30:09.355Z",
      "ip_address": "127.0.0.1",
      "status": "offline",
      "job_execution_status": "idle"
    }
]
```

<a id="list-all-of-a-projects-runners"></a>

## 列出项目的所有 runner

列出项目中所有可用的 runner，包括来自祖先群组和[任何允许的实例 runner](../ci/runners/runners_scope.md#enable-instance-runners-for-a-project)。

前提条件：

- 您必须是极狐GitLab 实例的管理员，或者对于目标项目至少具有维护者或审计员角色。

```plaintext
GET /projects/:id/runners
GET /projects/:id/runners?scope=active
GET /projects/:id/runners?type=project_type
GET /projects/:id/runners?status=online
GET /projects/:id/runners?paused=true
GET /projects/:id/runners?tag_list=tag1,tag2
```

| 属性        | 类型           | 必需 | 描述 |
|------------------|----------------|----------|-------------|
| `id`             | integer 或 string | 是      | 项目的 ID 或 [URL 编码路径](rest/_index.md#namespaced-paths) |
| `scope`          | string         | 否       | 已弃用：改用 `type` 或 `status`。要返回的 runner 范围，可选值：`active`、`paused`、`online` 和 `offline`；如果未提供，则显示所有 runner |
| `type`           | string         | 否       | 要返回的 runner 类型，可选值：`instance_type`、`group_type`、`project_type` |
| `status`         | string         | 否       | 要返回的 runner 状态，可选值：`online`、`offline`、`stale` 或 `never_contacted`。<br/>其他可能的值是已弃用的 `active` 和 `paused`。<br/>请求 `offline` 状态的 runner 可能也会返回 `stale` 状态的 runner，因为 `stale` 包含在 `offline` 中。 |
| `paused`         | boolean        | 否       | 是否仅包含接受或忽略新作业的 runner |
| `tag_list`       | string array   | 否       | runner 标签列表 |
| `version_prefix` | string         | 否       | 要返回的 runner 版本前缀。例如 `15.0`、`14`、`16.1.241` |

```shell
curl --header "PRIVATE-TOKEN: <your_access_token>" \
     --url "https://gitlab.example.com/api/v4/projects/9/runners"
```


> [!warning]
> 弃用项：
>
> - `status` 查询参数中的 `active` 和 `paused` 值已弃用，
>   并计划在 REST API 的未来版本中移除。
>   请改用 `paused` 查询参数。
> - 响应中的 `active` 属性已弃用，
>   并计划在 REST API 的未来版本中移除。
>   请改用 `paused` 属性。
> - 响应中的 `ip_address` 属性已弃用，
>   在极狐GitLab 16.1 中已弃用，并计划在
>   REST API 的未来版本中移除。
>   在极狐GitLab 17.0 中，此属性返回空字符串。
>   `ipAddress` 属性可在相应的 Runner 管理器内找到。
>   它仅通过 GraphQL
>   [`CiRunnerManager` 类型](graphql/reference/_index.md#cirunnermanager) 提供。

示例响应：

```json
[
    {
        "active": true,
        "paused": false,
        "description": "test-2-20150125",
        "id": 8,
        "ip_address": "",
        "is_shared": false,
        "runner_type": "project_type",
        "name": null,
        "online": false,
        "status": "offline",
        "job_execution_status": "idle"
    },
    {
        "active": true,
        "paused": false,
        "description": "development_runner",
        "id": 5,
        "ip_address": "",
        "is_shared": true,
        "runner_type": "instance_type",
        "name": null,
        "online": true,
        "status": "online",
        "job_execution_status": "idle"
    }
]
```

## 将 Runner 分配给项目

将可用的项目 Runner 分配给项目。

先决条件：

- 用户访问权限：您必须具有以下之一：
  - 在拥有该 Runner 的源项目和目标项目中具有维护者或所有者角色。
  - 在相关群组或项目中具有 `admin_runners` 权限的自定义角色。

```plaintext
POST /projects/:id/runners
```

| 属性 | 类型 | 是否必需 | 描述 |
|-------------|----------------|----------|-------------|
| `id` | 整数或字符串 | 是 | 项目 ID 或 [URL 编码路径](rest/_index.md#namespaced-paths) |
| `runner_id` | 整数 | 是 | Runner 的 ID |

```shell
curl --request POST \
     --header "PRIVATE-TOKEN: <your_access_token>" \
     --url "https://gitlab.example.com/api/v4/projects/9/runners" \
     --form "runner_id=9"
```

> [!warning]
> 响应中的 `ip_address` 属性已弃用，
> 在极狐GitLab 16.1 中已弃用，并计划在
> REST API 的未来版本中移除。
> 在极狐GitLab 17.0 中，此属性返回空字符串。
> `ipAddress` 属性可在相应的 Runner 管理器内找到。它仅通过 GraphQL
> [`CiRunnerManager` 类型](graphql/reference/_index.md#cirunnermanager) 提供。

示例响应：

```json
{
    "active": true,
    "description": "test-2016-02-01",
    "id": 9,
    "ip_address": "",
    "is_shared": false,
    "runner_type": "project_type",
    "name": null,
    "online": true,
    "status": "online",
    "job_execution_status": "idle"
}
```

## 从项目中取消分配 Runner

从项目中取消分配项目 Runner。
您不能从所属项目中取消分配 Runner。如果尝试此操作，会发生错误。
请改用 [删除 Runner](#删除runner) 的调用。

先决条件：

- 您不能锁定该 Runner，除非您是管理员。
- 用户访问权限：您必须具有以下之一：
  - 在要取消分配的项目中具有维护者或所有者角色。
  - 在相关群组或项目中具有 `admin_runners` 权限的自定义角色。
- 具有 `manage_runner` 范围和适当角色的访问令牌。

```plaintext
DELETE /projects/:id/runners/:runner_id
```

| 属性 | 类型 | 是否必需 | 描述 |
|-------------|----------------|----------|-------------|
| `id` | 整数或字符串 | 是 | 项目 ID 或 [URL 编码路径](rest/_index.md#namespaced-paths) |
| `runner_id` | 整数 | 是 | Runner 的 ID |

```shell
curl --request DELETE \
     --header "PRIVATE-TOKEN: <your_access_token>" \
     --url "https://gitlab.example.com/api/v4/projects/9/runners/9"
```

## 列出群组的所有 Runner

列出群组及其上级群组中所有可用的 Runner，包括 [任何允许的实例 Runner](../ci/runners/runners_scope.md#enable-instance-runners-for-a-group)。

先决条件：

- 用户访问权限：您必须具有以下之一：
  - 极狐GitLab 实例的管理员访问权限。
  - 在群组中具有所有者或审计员角色。
  - 在群组中具有 `admin_runners` 权限的自定义角色。
- 具有 `manage_runner` 范围和适当角色的访问令牌。

```plaintext
GET /groups/:id/runners
GET /groups/:id/runners?type=group_type
GET /groups/:id/runners/all?status=online
GET /groups/:id/runners/all?paused=true
GET /groups/:id/runners?tag_list=tag1,tag2
```

| 属性 | 类型 | 是否必需 | 描述 |
|------------------|--------------|----------|-------------|
| `id` | 整数 | 是 | 群组的 ID |
| `type` | 字符串 | 否 | 要返回的 Runner 类型，可选值：`instance_type`、`group_type`、`project_type`。`project_type` 值已[弃用](https://gitlab.com/gitlab-org/gitlab/-/issues/351466) 并计划在极狐GitLab 15.0 中移除 |
| `status` | 字符串 | 否 | 要返回的 Runner 状态，可选值：`online`、`offline`、`stale` 或 `never_contacted`。<br/>其他可选值为已弃用的 `active` 和 `paused`。<br/>请求 `offline` Runner 可能也会返回 `stale` Runner，因为 `stale` 包含在 `offline` 中。 |
| `paused` | 布尔值 | 否 | 是否仅包含正在接受或忽略新作业的 Runner |
| `tag_list` | 字符串数组 | 否 | Runner 标签列表 |
| `version_prefix` | 字符串 | 否 | 要返回的 Runner 版本前缀。例如，`15.0`、`14`、`16.1.241` |

> [!warning]
> 弃用项：
>
> - `status` 查询参数中的 `active` 和 `paused` 值已弃用，
>   并计划在 REST API 的未来版本中移除。
>   请改用 `paused` 查询参数。
> - 响应中的 `active` 属性已弃用，
>   并计划在 REST API 的未来版本中移除。
>   请改用 `paused` 属性。

```shell
curl --header "PRIVATE-TOKEN: <your_access_token>" \
     --url "https://gitlab.example.com/api/v4/groups/9/runners"
```

> [!warning]
> 响应中的 `ip_address` 属性已弃用，
> 在极狐GitLab 16.1 中已弃用，并计划在
> REST API 的未来版本中移除。
> 在极狐GitLab 中，此属性返回空字符串。
> `ipAddress` 属性可在相应的 Runner 管理器内找到。它仅通过 GraphQL
> [`CiRunnerManager` 类型](graphql/reference/_index.md#cirunnermanager) 提供。

示例响应：

```json
[
  {
    "id": 3,
    "description": "Shared",
    "ip_address": "",
    "active": true,
    "paused": false,
    "is_shared": true,
    "runner_type": "instance_type",
    "name": "gitlab-runner",
    "online": null,
    "status": "never_contacted",
    "job_execution_status": "idle"
  },
  {
    "id": 6,
    "description": "Test",
    "ip_address": "",
    "active": true,
    "paused": false,
    "is_shared": true,
    "runner_type": "instance_type",
    "name": "gitlab-runner",
    "online": false,
    "status": "offline",
    "job_execution_status": "idle"
  },
  {
    "id": 8,
    "description": "Test 2",
    "ip_address": "",
    "active": true,
    "paused": false,
    "is_shared": false,
    "runner_type": "group_type",
    "name": "gitlab-runner",
    "online": null,
    "status": "never_contacted",
    "job_execution_status": "idle"
  }
]
```

## 创建 Runner

> [!warning]
> 该端点使用注册令牌（[已弃用](https://gitlab.com/gitlab-org/gitlab/-/issues/380872)），
> 在极狐GitLab 17.0 及更高版本中默认禁用。
> 请改用 [`POST /user/runners`](users.md#create-a-runner-linked-to-a-user) 以推荐的工作流创建 Runner。

使用 Runner 注册令牌创建 Runner。

如果在项目或群组设置中禁用了使用 Runner 注册令牌进行注册，
此端点将返回 `HTTP 410 Gone` 状态码。如果使用 Runner 注册令牌进行注册被禁用，
请改用 [`POST /user/runners`](users.md#create-a-runner-linked-to-a-user) 端点来创建和注册 Runner。

```plaintext
POST /runners
```

| 属性 | 类型 | 是否必需 | 描述 |
|--------------------|--------------|----------|-------------|
| `token` | 字符串 | 是 | [注册令牌](#registration-and-authentication-tokens) |
| `description` | 字符串 | 否 | Runner 的描述 |
| `info` | 哈希 | 否 | Runner 的元数据。可以包含 `name`、`version`、`revision`、`platform` 和 `architecture`，但仅 `version`、`platform` 和 `architecture` 显示在 UI 的 **管理员** 区域 |
| `active` | 布尔值 | 否 | 已弃用：请改用 `paused`。指定 Runner 是否允许接收新作业 |
| `paused` | 布尔值 | 否 | 指定 Runner 是否应忽略新作业 |
| `locked` | 布尔值 | 否 | 指定 Runner 是否应锁定到当前项目 |
| `run_untagged` | 布尔值 | 否 | 指定 Runner 是否应处理未标记的作业 |
| `tag_list` | 字符串数组 | 否 | Runner 标签列表 |
| `access_level` | 字符串 | 否 | Runner 的访问级别；`not_protected` 或 `ref_protected` |
| `maximum_timeout` | 整数 | 否 | 限制 Runner 运行作业的最大超时时间（以秒为单位） |
| `maintainer_note` | 字符串 | 否 | [已弃用](https://gitlab.com/gitlab-org/gitlab/-/issues/350730)，请参见 `maintenance_note` |
| `maintenance_note` | 字符串 | 否 | Runner 的自由格式维护说明（1024 个字符） |

```shell
curl --request POST \
     --url "https://gitlab.example.com/api/v4/runners" \
     --form "token=<registration_token>" --form "description=test-1-20150125-test" \
     --form "tag_list=ruby,mysql,tag1,tag2"
```

响应：

| 状态 | 描述 |
|--------|-------------|
| 201 | Runner 已创建 |
| 403 | Runner 注册令牌无效 |
| 410 | Runner 注册已禁用 |

示例响应：

```json
{
    "id": 12345,
    "token": "6337ff461c94fd3fa32ba3b1ff4125",
    "token_expires_at": "2021-09-27T21:05:03.203Z"
}
```

## 删除 Runner

您可以通过指定以下内容来删除 Runner：

- Runner ID
- Runner 的认证令牌

### 通过 ID 删除 Runner

要通过 ID 删除 Runner，请使用您的访问令牌和 Runner 的 ID：

先决条件：

- 用户访问权限：您必须具有以下之一：
  - 对于实例 Runner：极狐GitLab 实例的管理员访问权限。
  - 对于群组 Runner：所有者命名空间中的所有者角色。
  - 对于项目 Runner：在拥有该 Runner 的项目中具有维护者或所有者角色。
  - 在相关群组或项目中具有 `admin_runners` 权限的自定义角色。
- 具有 `manage_runner` 范围和适当角色的访问令牌。

```plaintext
DELETE /runners/:id
```

| 属性 | 类型 | 是否必需 | 描述 |
|-----------|---------|----------|-------------|
| `id` | 整数 | 是 | Runner 的 ID。该 ID 在 UI 中可见，位于 **设置** > **CI/CD** 下。展开 **Runner**，在 **移除 Runner** 下方有一个井号前的 ID，例如 `#6`。 |

```shell
curl --request DELETE \
     --header "PRIVATE-TOKEN: <your_access_token>" \
     --url "https://gitlab.example.com/api/v4/runners/6"
```

### 通过认证令牌删除 Runner

使用其认证令牌删除 Runner。

```plaintext
DELETE /runners
```

| 属性 | 类型 | 是否必需 | 描述 |
|-----------|--------|----------|-------------|
| `token` | 字符串 | 是 | Runner 的[认证令牌](#registration-and-authentication-tokens)。 |

```shell
curl --request DELETE \
     --url "https://gitlab.example.com/api/v4/runners" \
     --form "token=<authentication_token>"
```

响应：

| 状态 | 描述 |
|--------|-------------|
| 204 | Runner 已删除 |

## 验证已注册 Runner 的认证信息

验证已注册 Runner 的认证凭据。

```plaintext
POST /runners/verify
```

| 属性 | 类型 | 是否必需 | 描述 |
|-------------|--------|----------|-------------|
| `token` | 字符串 | 是 | Runner 的[认证令牌](#registration-and-authentication-tokens)。 |
| `system_id` | 字符串 | 否 | Runner 的系统标识符。如果 `token` 以 `glrt-` 开头，则此属性是必需的。 |

```shell
curl --request POST \
     --url "https://gitlab.example.com/api/v4/runners/verify" \
     --form "token=<authentication_token>"
```

响应：

| 状态 | 描述 |
|--------|-------------|
| 200 | 凭据有效 |
| 403 | 凭据无效 |

示例响应：

```json
{
    "id": 12345,
    "token": "glrt-6337ff461c94fd3fa32ba3b1ff4125",
    "token_expires_at": "2021-09-27T21:05:03.203Z"
}
```

## 重置实例的 Runner 注册令牌

> [!warning]
> 传递 Runner 注册令牌的选项以及对某些配置参数的支持被视为旧版做法，
> 不推荐使用。
> 请使用 [Runner 创建工作流](https://gitlab.cn/docs/runner/register/#register-with-a-runner-authentication-token)
> 生成认证令牌来注册 Runner。此过程提供了 Runner 所有权的完全可追溯性，并增强了您的 Runner 车队的安全性。
>
> 有关更多信息，请参见
> [迁移至新的 Runner 注册工作流](../ci/runners/new_creation_workflow.md)。

重置极狐GitLab 实例的 Runner 注册令牌。

```plaintext
POST /runners/reset_registration_token
```

```shell
curl --request POST \
     --header "PRIVATE-TOKEN: <your_access_token>" \
     --url "https://gitlab.example.com/api/v4/runners/reset_registration_token"
```

## 重置项目的 Runner 注册令牌

> [!warning]
> 传递 Runner 注册令牌的选项以及对某些配置参数的支持被视为旧版做法，
> 不推荐使用。
> 请使用 [Runner 创建工作流](https://gitlab.cn/docs/runner/register/#register-with-a-runner-authentication-token)
> 生成认证令牌来注册 Runner。此过程提供了 Runner 所有权的完全可追溯性，并增强了您的 Runner 车队的安全性。
> 有关更多信息，请参见
> [迁移至新的 Runner 注册工作流](../ci/runners/new_creation_workflow.md)。

重置项目的 Runner 注册令牌。

```plaintext
POST /projects/:id/runners/reset_registration_token
```

```shell
curl --request POST \
     --header "PRIVATE-TOKEN: <your_access_token>" \
     --url "https://gitlab.example.com/api/v4/projects/9/runners/reset_registration_token"
```

## 重置群组的 Runner 注册令牌

> [!warning]
> 传递 Runner 注册令牌的选项以及对某些配置参数的支持被视为旧版做法，
> 不推荐使用。
> 请使用 [Runner 创建工作流](https://gitlab.cn/docs/runner/register/#register-with-a-runner-authentication-token)
> 生成认证令牌来注册 Runner。此过程提供了 Runner 所有权的完全可追溯性，并增强了您的 Runner 车队的安全性。
> 有关更多信息，请参见
> [迁移至新的 Runner 注册工作流](../ci/runners/new_creation_workflow.md)。

重置群组的 Runner 注册令牌。

```plaintext
POST /groups/:id/runners/reset_registration_token
```

```shell
curl --request POST \
     --header "PRIVATE-TOKEN: <your_access_token>" \
     --url "https://gitlab.example.com/api/v4/groups/9/runners/reset_registration_token"
```

## 使用 Runner ID 重置 Runner 的认证令牌

通过使用其 Runner ID 重置 Runner 的认证令牌。

先决条件：

- 用户访问权限：您必须具有以下之一：
  - 对于实例 Runner：极狐GitLab 实例的管理员访问权限。
  - 对于群组 Runner：所有者命名空间中的所有者角色。
  - 对于项目 Runner：分配给 Runner 的项目中的维护者或所有者角色。
  - 在相关群组或项目中具有 `admin_runners` 权限的自定义角色。
- 具有 `manage_runner` 范围和适当角色的访问令牌。

```plaintext
POST /runners/:id/reset_authentication_token
```

| 属性 | 类型 | 是否必需 | 描述 |
|-----------|---------|----------|-------------|
| `id` | 整数 | 是 | Runner 的 ID |

```shell
curl --request POST \
     --header "PRIVATE-TOKEN: <your_access_token>" \
     --url "https://gitlab.example.com/api/v4/runners/1/reset_authentication_token"
```

示例响应：

```json
{
    "token": "6337ff461c94fd3fa32ba3b1ff4125",
    "token_expires_at": "2021-09-27T21:05:03.203Z"
}
```

## 使用当前令牌重置 Runner 的认证令牌

通过使用当前令牌值作为输入来重置 Runner 的认证令牌。

```plaintext
POST /runners/reset_authentication_token
```

| 属性 | 类型 | 是否必需 | 描述 |
|-----------|--------|----------|-------------|
| `token` | 字符串 | 是 | Runner 的认证令牌 |

```shell
curl --request POST \
     --form "token=<current token>" \
     --url "https://gitlab.example.com/api/v4/runners/reset_authentication_token"
```

示例响应：

```json
{
    "token": "6337ff461c94fd3fa32ba3b1ff4125",
    "token_expires_at": "2021-09-27T21:05:03.203Z"
}
```

## 发现 Job Router 信息

{{< history >}}

- 引入于极狐GitLab 18.7 [带有功能标志](../administration/feature_flags/_index.md) 名为 `job_router` 和 `job_router_instance_runners`。默认禁用。

{{< /history >}}

获取 Runner 的 Job Router 发现信息。

先决条件：

- 您必须提供有效的 Runner 认证令牌。

```plaintext
GET /runners/router/discovery
```

```shell
curl --header "Runner-Token: <runner_authentication_token>" \
     --url "https://gitlab.example.com/api/v4/runners/router/discovery"
```

响应：

响应包含以下字段：

| 属性 | 类型 | 描述 |
|--------------|----------|-----------------------|
| `server_url` | 字符串 | Job Router 的 URL |

响应返回以下状态码之一：

| 状态 | 描述 |
|--------|-----------------------------------------------|
| `200` | 成功检索到 Job Router 信息 |
| `403` | 禁止访问 |
| `501` | Job Router 不可用 |

示例响应：

```json
{
    "server_url": "wss://kas.example.com"
}
```