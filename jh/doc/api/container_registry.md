```markdown
---
stage: Package
group: Container Registry
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
title: 容器镜像仓库 API
description: Manage your GitLab container registry with the REST API.
---

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: JihuLab.com，私有化部署

{{< /details >}}

使用此 API 管理[极狐GitLab 容器镜像仓库](../user/packages/container_registry/_index.md)。

要从 CI/CD 作业通过这些端点进行认证，请将 [`$CI_JOB_TOKEN`](../ci/jobs/ci_job_token.md)
变量作为 `JOB-TOKEN` 标头传递。作业令牌只能访问创建该流水线的项目的容器镜像仓库。

<a id="change-the-visibility-of-the-container-registry"></a>

## 更改容器镜像仓库的可见性

更改指定项目的容器镜像仓库的可见性。

```plaintext
PUT /projects/:id/
```

| 属性                              | 类型              | 是否必需 | 描述 |
|-----------------------------------|-------------------|----------|-------------|
| `id`                              | integer 或 string | 是      | 认证用户可以访问的项目的 ID 或 [URL 编码路径](rest/_index.md#namespaced-paths)。 |
| `container_registry_access_level` | string            | 否       | 容器镜像仓库所需的可见性。可选值为 `enabled`（默认）、`private` 或 `disabled`。 |

`container_registry_access_level` 可选值的描述：

- `enabled`（默认）：容器镜像仓库对能访问项目的所有人可见。如果项目是公开的，容器镜像仓库也是公开的。如果项目是内部或私有的，容器镜像仓库也是内部或私有的。
- `private`：容器镜像仓库仅对具有报告者及以上角色的项目成员可见。此行为类似于容器镜像仓库可见性已启用的私有项目。
- `disabled`：容器镜像仓库已禁用。

有关此设置授予用户的权限的更多详细信息，请参阅[容器镜像仓库可见性权限](../user/packages/container_registry/_index.md#container-registry-visibility-permissions)。

```shell
curl --request PUT "https://gitlab.example.com/api/v4/projects/5/" \
  --header 'PRIVATE-TOKEN: <your_access_token>' \
  --header 'Accept: application/json' \
  --header 'Content-Type: application/json' \
  --data-raw '{
      "container_registry_access_level": "private"
  }'
```

响应示例：

```json
{
  "id": 5,
  "name": "Project 5",
  "container_registry_access_level": "private",
  ...
}
```

<a id="list-all-registry-repositories"></a>

## 列出所有镜像仓库

<a id="within-a-project"></a>

### 在项目内

列出指定项目的所有镜像仓库。

响应是[分页](rest/_index.md#pagination)的，默认返回 20 条结果。

```plaintext
GET /projects/:id/registry/repositories
```

| 属性    | 类型           | 是否必需 | 描述 |
|--------------|----------------|----------|-------------|
| `id`         | integer 或 string | 是      | 认证用户可以访问的项目的 ID 或 [URL 编码路径](rest/_index.md#namespaced-paths)。 |
| `tags`       | boolean        | 否       | 如果参数包含为 true，每个仓库的响应中包含一个 `"tags"` 数组。 |
| `tags_count` | boolean        | 否       | 如果参数包含为 true，每个仓库的响应中包含 `"tags_count"`。 |

```shell
curl --header "PRIVATE-TOKEN: <your_access_token>" \
  --url "https://gitlab.example.com/api/v4/projects/5/registry/repositories"
```

响应示例：

```json
[
  {
    "id": 1,
    "name": "",
    "path": "group/project",
    "project_id": 9,
    "location": "gitlab.example.com:5000/group/project",
    "created_at": "2019-01-10T13:38:57.391Z",
    "cleanup_policy_started_at": "2020-01-10T15:40:57.391Z",
    "status": null
  },
  {
    "id": 2,
    "name": "releases",
    "path": "group/project/releases",
    "project_id": 9,
    "location": "gitlab.example.com:5000/group/project/releases",
    "created_at": "2019-01-10T13:39:08.229Z",
    "cleanup_policy_started_at": "2020-08-17T03:12:35.489Z",
    "status": "delete_ongoing"
  }
]
```

<a id="within-a-group"></a>

### 在群组内

{{< history >}}

- 在极狐GitLab 15.0 中已移除 `tags` 和 `tag_count` 属性。

{{< /history >}}

列出指定群组的所有镜像仓库。

响应是[分页](rest/_index.md#pagination)的，默认返回 20 条结果。

```plaintext
GET /groups/:id/registry/repositories
```

| 属性 | 类型           | 是否必需 | 描述 |
|-----------|----------------|----------|-------------|
| `id`      | integer 或 string | 是      | 认证用户可以访问的群组的 ID 或 [URL 编码路径](rest/_index.md#namespaced-paths)。 |

```shell
curl --header "PRIVATE-TOKEN: <your_access_token>" \
  --url "https://gitlab.example.com/api/v4/groups/2/registry/repositories"
```

响应示例：

```json
[
  {
    "id": 1,
    "name": "",
    "path": "group/project",
    "project_id": 9,
    "location": "gitlab.example.com:5000/group/project",
    "created_at": "2019-01-10T13:38:57.391Z",
    "cleanup_policy_started_at": "2020-08-17T03:12:35.489Z",
  },
  {
    "id": 2,
    "name": "",
    "path": "group/other_project",
    "project_id": 11,
    "location": "gitlab.example.com:5000/group/other_project",
    "created_at": "2019-01-10T13:39:08.229Z",
    "cleanup_policy_started_at": "2020-01-10T15:40:57.391Z",
  }
]
```

<a id="retrieve-details-of-a-single-repository"></a>

## 获取单个仓库的详细信息

获取指定镜像仓库的详细信息。

```plaintext
GET /registry/repositories/:id
```

| 属性    | 类型           | 是否必需 | 描述 |
|--------------|----------------|----------|-------------|
| `id`         | integer 或 string | 是      | 认证用户可以访问的镜像仓库的 ID。 |
| `tags`       | boolean        | 否       | 如果参数为 `true`，响应中包含 `"tags"` 数组。 |
| `tags_count` | boolean        | 否       | 如果参数为 `true`，响应中包含 `"tags_count"`。 |
| `size`       | boolean        | 否       | 如果参数为 `true`，响应中包含 `"size"`。这是仓库中所有镜像的去重大小。去重会消除相同数据的额外副本。例如，如果你上传了相同的镜像两次，容器镜像仓库只存储一个副本。此字段仅在 JihuLab.com 上可用于 `2021-11-04` 之后创建的仓库。 |

```shell
curl --header "PRIVATE-TOKEN: <your_access_token>" \
  --url "https://gitlab.example.com/api/v4/registry/repositories/2?tags=true&tags_count=true&size=true"
```

响应示例：

```json
{
  "id": 2,
  "name": "",
  "path": "group/project",
  "project_id": 9,
  "location": "gitlab.example.com:5000/group/project",
  "created_at": "2019-01-10T13:38:57.391Z",
  "cleanup_policy_started_at": "2020-08-17T03:12:35.489Z",
  "tags_count": 1,
  "tags": [
    {
      "name": "0.0.1",
      "path": "group/project:0.0.1",
      "location": "gitlab.example.com:5000/group/project:0.0.1"
    }
  ],
  "size": 2818413,
  "status": "delete_scheduled"
}
```

<a id="delete-registry-repository"></a>

## 删除镜像仓库

删除镜像仓库中指定的仓库。

此操作是异步执行的，可能需要一些时间才能完成。

```plaintext
DELETE /projects/:id/registry/repositories/:repository_id
```

| 属性       | 类型           | 是否必需 | 描述 |
|-----------------|----------------|----------|-------------|
| `id`            | integer 或 string | 是      | 项目的 ID 或 [URL 编码路径](rest/_index.md#namespaced-paths)。 |
| `repository_id` | integer        | 是      | 镜像仓库的 ID。 |

```shell
curl --request DELETE \
  --header "PRIVATE-TOKEN: <your_access_token>" \
  --url "https://gitlab.example.com/api/v4/projects/5/registry/repositories/2"
```

<a id="list-all-registry-repository-tags"></a>

## 列出所有镜像仓库标签

<a id="within-a-project-1"></a>

### 在项目内

{{< history >}}

- 在极狐GitLab 16.10 中引入（仅限 JihuLab.com）。

{{< /history >}}

列出指定镜像仓库的所有标签。

响应是[分页](rest/_index.md#pagination)的，默认返回 20 条结果。

> [!note]
> 偏移分页已弃用，现在首选键集分页。

```plaintext
GET /projects/:id/registry/repositories/:repository_id/tags
```

| 属性       | 类型           | 是否必需 | 描述 |
|-----------------|----------------|----------|-------------|
| `id`            | integer 或 string | 是      | 认证用户可以访问的项目的 ID 或 [URL 编码路径](rest/_index.md#namespaced-paths)。 |
| `repository_id` | integer        | 是      | 镜像仓库的 ID。 |

```shell
curl --header "PRIVATE-TOKEN: <your_access_token>" \
  --url "https://gitlab.example.com/api/v4/projects/5/registry/repositories/2/tags"
```

响应示例：

```json
[
  {
    "name": "A",
    "path": "group/project:A",
    "location": "gitlab.example.com:5000/group/project:A"
  },
  {
    "name": "latest",
    "path": "group/project:latest",
    "location": "gitlab.example.com:5000/group/project:latest"
  }
]
```

<a id="retrieve-details-of-a-registry-repository-tag"></a>

## 获取镜像仓库标签的详细信息

获取指定镜像仓库标签的详细信息。

```plaintext
GET /projects/:id/registry/repositories/:repository_id/tags/:tag_name
```

| 属性       | 类型           | 是否必需 | 描述 |
|-----------------|----------------|----------|-------------|
| `id`            | integer 或 string | 是      | 认证用户可以访问的项目的 ID 或 [URL 编码路径](rest/_index.md#namespaced-paths)。 |
| `repository_id` | integer        | 是      | 镜像仓库的 ID。 |
| `tag_name`      | string         | 是      | 标签的名称。 |

```shell
curl --header "PRIVATE-TOKEN: <your_access_token>" \
  --url "https://gitlab.example.com/api/v4/projects/5/registry/repositories/2/tags/v10.0.0"
```

响应示例：

```json
{
  "name": "v10.0.0",
  "path": "group/project:latest",
  "location": "gitlab.example.com:5000/group/project:latest",
  "revision": "e9ed9d87c881d8c2fd3a31b41904d01ba0b836e7fd15240d774d811a1c248181",
  "short_revision": "e9ed9d87c",
  "digest": "sha256:c3490dcf10ffb6530c1303522a1405dfaf7daecd8f38d3e6a1ba19ea1f8a1751",
  "created_at": "2019-01-06T16:49:51.272+00:00",
  "total_size": 350224384
}
```

<a id="delete-a-registry-repository-tag"></a>

## 删除镜像仓库标签

删除指定的容器镜像仓库标签。

如果标签与项目中的任何保护规则匹配，此端点将返回 [`403 Forbidden`](rest/troubleshooting.md#status-codes) 错误。
有关标签保护规则的更多信息，请参阅[受保护的容器标签](../user/packages/container_registry/protected_container_tags.md)。

```plaintext
DELETE /projects/:id/registry/repositories/:repository_id/tags/:tag_name
```

| 属性       | 类型           | 是否必需 | 描述 |
|-----------------|----------------|----------|-------------|
| `id`            | integer 或 string | 是      | 项目的 ID 或 [URL 编码路径](rest/_index.md#namespaced-paths)。 |
| `repository_id` | integer        | 是      | 镜像仓库的 ID。 |
| `tag_name`      | string         | 是      | 标签的名称。 |

```shell
curl --request DELETE \
  --header "PRIVATE-TOKEN: <your_access_token>" \
  --url "https://gitlab.example.com/api/v4/projects/5/registry/repositories/2/tags/v10.0.0"
```

此操作不会删除 blob。要回收磁盘空间，请[运行垃圾回收](../administration/packages/container_registry.md#container-registry-garbage-collection)。

<a id="delete-registry-repository-tags-in-bulk"></a>

## 批量删除镜像仓库标签

根据指定条件批量删除镜像仓库标签。

```plaintext
DELETE /projects/:id/registry/repositories/:repository_id/tags
```

| 属性           | 类型           | 是否必需 | 描述 |
|---------------------|----------------|----------|-------------|
| `id`                | integer 或 string | 是      | 项目的 ID 或 [URL 编码路径](rest/_index.md#namespaced-paths)。 |
| `repository_id`     | integer        | 是      | 镜像仓库的 ID。 |
| `keep_n`            | integer        | 否       | 要保留的给定名称的最新标签数量。 |
| `name_regex`        | string         | 否       | 要删除的名称的 [re2](https://github.com/google/re2/wiki/Syntax) 正则表达式。要删除所有标签，请指定 `.*`。注意：`name_regex` 已弃用，建议使用 `name_regex_delete`。此字段会进行验证。 |
| `name_regex_delete` | string         | 是      | 要删除的名称的 [re2](https://github.com/google/re2/wiki/Syntax) 正则表达式。要删除所有标签，请指定 `.*`。此字段会进行验证。 |
| `name_regex_keep`   | string         | 否       | 要保留的名称的 [re2](https://github.com/google/re2/wiki/Syntax) 正则表达式。此值会覆盖 `name_regex_delete` 的任何匹配。此字段会进行验证。注意：设置为 `.*` 会导致无操作。 |
| `older_than`        | string         | 否       | 删除早于给定时间的标签，时间以可读形式编写，如 `1h`、`1d`、`1month`。 |

如果成功，此 API 返回 [HTTP 响应状态码 202](https://developer.mozilla.org/en-US/docs/Web/HTTP/Status/202)，并执行以下操作：

- 按创建日期对所有标签排序。创建日期是 manifest 创建的时间，而不是标签推送的时间。
- 仅删除与给定 `name_regex_delete`（或已弃用的 `name_regex`）匹配的标签，保留与 `name_regex_keep` 匹配的任何标签。
- 永远不会删除名为 `latest` 的标签。
- 保留 N 个最新匹配的标签（如果指定了 `keep_n`）。
- 仅删除早于 X 时间的标签（如果指定了 `older_than`）。
- 排除[受保护的标签](../user/packages/container_registry/protected_container_tags.md)。
- 将异步作业安排在后台执行。

这些操作是异步执行的，可能需要一些时间才能完成。对于给定的容器仓库，最多每小时运行一次。

此操作不会删除 blob。要回收磁盘空间，请[运行垃圾回收](../administration/packages/container_registry.md#container-registry-garbage-collection)。

> [!warning]
> 由于容器镜像仓库的规模，在 JihuLab.com 上此 API 删除的标签数量有限。
> 如果你的容器镜像仓库有大量标签需要删除，则只会删除其中的一部分，你可能需要多次调用此 API。
> 要安排标签自动删除，请改用[清理策略](../user/packages/container_registry/reduce_container_registry_storage.md#cleanup-policy)。

示例：

- 删除与正则表达式（Git SHA）匹配的标签名称，始终保留至少 5 个，并删除早于 2 天的标签：

  ```shell
  curl --request DELETE \
    --data 'name_regex_delete=[0-9a-z]{40}' \
    --data 'keep_n=5' \
    --data 'older_than=2d' \
    --header "PRIVATE-TOKEN: <your_access_token>" \
    --url "https://gitlab.example.com/api/v4/projects/5/registry/repositories/2/tags"
  ```

- 删除所有标签，但始终保留最新的 5 个：

  ```shell
  curl --request DELETE \
    --data 'name_regex_delete=.*' \
    --data 'keep_n=5' \
    --header "PRIVATE-TOKEN: <your_access_token>" \
    --url "https://gitlab.example.com/api/v4/projects/5/registry/repositories/2/tags"
  ```

- 删除所有标签，但始终保留以 `stable` 开头的标签：

  ```shell
  curl --request DELETE \
    --data 'name_regex_delete=.*' \
    --data 'name_regex_keep=stable.*' \
    --header "PRIVATE-TOKEN: <your_access_token>" \
    --url "https://gitlab.example.com/api/v4/projects/5/registry/repositories/2/tags"
  ```

- 删除超过 1 个月的所有标签：

  ```shell
  curl --request DELETE \
    --data 'name_regex_delete=.*' \
    --data 'older_than=1month' \
    --header "PRIVATE-TOKEN: <your_access_token>" \
    --url "https://gitlab.example.com/api/v4/projects/5/registry/repositories/2/tags"
  ```

<a id="use-curl-with-a-regular-expression-that-contains-+"></a>

### 在 cURL 中使用包含 `+` 的正则表达式

使用 cURL 时，正则表达式中的 `+` 字符必须进行 [URL 编码](https://curl.se/docs/manpage.html#--data-urlencode)，才能被极狐GitLab Rails 后端正确处理。例如：

```shell
curl --request DELETE \
  --data-urlencode 'name_regex_delete=dev-.+' \
  --header "PRIVATE-TOKEN: <your_access_token>" \
  --url "https://gitlab.example.com/api/v4/projects/5/registry/repositories/2/tags"
```

<a id="instance-wide-endpoints"></a>

## 实例范围的端点

除了前面介绍的群组和项目特定的极狐GitLab API 之外，容器镜像仓库还有自己的端点。要查询这些端点，请遵循镜像仓库的内置机制获取并使用[认证令牌](https://distribution.github.io/distribution/spec/auth/token/)。

> [!note]
> 这些与极狐GitLab 应用程序中的项目或个人访问令牌不同。

<a id="obtain-token-from-gitlab"></a>

### 从极狐GitLab 获取令牌

```plaintext
GET ${CI_SERVER_URL}/jwt/auth?service=container_registry&scope=*
```

你必须指定正确的[作用域和操作](https://distribution.github.io/distribution/spec/auth/scope/)才能获取有效令牌：

```shell
SCOPE="repository:${CI_PROJECT_PATH}:delete" # 或 push, pull

curl --request GET \
  --user "${CI_REGISTRY_USER}:${CI_REGISTRY_PASSWORD}" \
  --url "${CI_SERVER_URL}/jwt/auth?service=container_registry&scope=${SCOPE}"
```

<a id="delete-image-tags-by-reference"></a>

### 通过引用删除镜像标签

{{< history >}}

- 在极狐GitLab 16.4 中引入端点 `v2/<name>/manifests/<tag>` 并弃用端点 `v2/<name>/tags/reference/<tag>`。

{{< /history >}}

```plaintext
DELETE http(s)://${CI_REGISTRY}/v2/${CI_REGISTRY_IMAGE}/tags/reference/${CI_COMMIT_SHORT_SHA}
```

你可以使用通过预定义的 `CI_REGISTRY_USER` 和 `CI_REGISTRY_PASSWORD` 变量获取的令牌，在极狐GitLab 实例上按引用删除容器镜像标签。必须启用 `tag_delete` [容器镜像仓库功能](https://gitlab.com/gitlab-org/container-registry/-/blob/master/docs/spec/docker/v2/api.md#delete-tag)。

```shell
$ curl --request DELETE \
    --header "Authorization: Bearer <token_from_above>" \
    --header "Accept: application/vnd.docker.distribution.manifest.v2+json" \
    --url "https://gitlab.example.com:5050/v2/${CI_REGISTRY_IMAGE}/manifests/${CI_COMMIT_SHORT_SHA}"
```

<a id="listing-all-container-repositories"></a>

### 列出所有容器仓库

```plaintext
GET http(s)://${CI_REGISTRY}/v2/_catalog
```

要列出极狐GitLab 实例上的所有容器仓库，需要管理员凭据：

```shell
$ SCOPE="registry:catalog:*"

$ curl --request GET \
    --user "<admin-username>:<admin-password>" \
    --url "https://gitlab.example.com/jwt/auth?service=container_registry&scope=${SCOPE}"
{"token":" ... "}

$ curl --header "Authorization: Bearer <token_from_above>" \
    --url "https://gitlab.example.com:5050/v2/_catalog"
```

```