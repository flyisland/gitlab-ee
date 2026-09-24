---
stage: Tenant Scale
group: Organizations
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
description: Use the Groups API to manage groups, subgroups, and project access.
title: 群组 API
---

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: JihuLab.com，私有化部署

{{< /details >}}

使用此 API 查看和管理 极狐GitLab 群组。更多信息，参见 [群组](../user/group/_index.md)。

端点响应可能因群组中已认证用户的[权限](../user/permissions.md)而有所不同。

<a id="retrieve-a-group"></a>

## 获取群组

获取群组详细信息。如果群组是公开可访问的，则无需认证即可访问此端点。如果请求用户是管理员，则返回额外信息。经过认证后，如果用户为管理员或具有所有者角色，将返回群组的 `runners_token` 和 `enabled_git_access_protocol`。

```plaintext
GET /groups/:id
```

参数：

| 属性 | 类型 | 是否必需 | 描述 |
| --- | --- | --- | --- |
| `id` | integer or string | yes | 群组的 ID 或 [URL 编码路径](rest/_index.md#namespaced-paths)。 |
| `with_custom_attributes` | boolean | no | 在响应中包含 [自定义属性](custom_attributes.md)（仅管理员）。 |
| `with_projects` | boolean | no | 包含属于指定群组的项目详情（默认值为 `true`）。（已弃用，[计划在 API v5 中移除](https://jihulab.com/gitlab-cn/gitlab/-/issues/213797)。要获取群组中所有项目的详情，请使用 [列出群组项目端点](#list-projects)。） |

> [!note]
> 响应中的 `projects` 和 `shared_projects` 属性已弃用，并[计划在 API v5 中移除](https://jihulab.com/gitlab-cn/gitlab/-/issues/213797)。
> 要获取群组中所有项目的详情，请使用 [列出群组项目](#list-projects) 或 [列出群组共享项目](#list-shared-projects) 端点。

```shell
curl --header "PRIVATE-TOKEN: <your_access_token>" \
  --url "https://gitlab.example.com/api/v4/groups/4"
```

此端点最多返回 100 个项目和共享项目。要获取群组中所有项目的详情，请改用 [列出群组项目端点](#list-projects)。

响应示例：

```json
{
  "id": 4,
  "name": "Twitter",
  "path": "twitter",
  "description": "Aliquid qui quis dignissimos distinctio ut commodi voluptas est.",
  "visibility": "public",
  "avatar_url": null,
  "web_url": "https://gitlab.example.com/groups/twitter",
  "request_access_enabled": false,
  "repository_storage": "default",
  "full_name": "Twitter",
  "full_path": "twitter",
  "runners_token": "ba324ca7b1c77fc20bb9",
  "file_template_project_id": 1,
  "parent_id": null,
  "enabled_git_access_protocol": "all",
  "created_at": "2020-01-15T12:36:29.590Z",
  "shared_with_groups": [
    {
      "group_id": 28,
      "group_name": "H5bp",
      "group_full_path": "h5bp",
      "group_access_level": 20,
      "expires_at": null
    }
  ],
  "prevent_sharing_groups_outside_hierarchy": false,
  "only_allow_merge_if_pipeline_succeeds": false,
  "allow_merge_on_skipped_pipeline": false,
  "only_allow_merge_if_all_discussions_are_resolved": false,
  "projects": [ // 已弃用，将在 API v5 中移除
    {
      "id": 7,
      "description": "Voluptas veniam qui et beatae voluptas doloremque explicabo facilis.",
      "default_branch": "main",
      "tag_list": [], //已弃用，请使用 `topics`
      "topics": [],
      "archived": false,
      "visibility": "public",
      "ssh_url_to_repo": "git@gitlab.example.com:twitter/typeahead-js.git",
      "http_url_to_repo": "https://gitlab.example.com/twitter/typeahead-js.git",
      "web_url": "https://gitlab.example.com/twitter/typeahead-js",
      "name": "Typeahead.Js",
      "name_with_namespace": "Twitter / Typeahead.Js",
      "path": "typeahead-js",
      "path_with_namespace": "twitter/typeahead-js",
      "issues_enabled": true,
      "merge_requests_enabled": true,
      "wiki_enabled": true,
      "jobs_enabled": true,
      "snippets_enabled": false,
      "container_registry_enabled": true,
      "created_at": "2016-06-17T07:47:25.578Z",
      "last_activity_at": "2016-06-17T07:47:25.881Z",
      "shared_runners_enabled": true,
      "creator_id": 1,
      "namespace": {
        "id": 4,
        "name": "Twitter",
        "path": "twitter",
        "kind": "group"
      },
      "avatar_url": null,
      "star_count": 0,
      "forks_count": 0,
      "open_issues_count": 3,
      "public_jobs": true,
      "shared_with_groups": [],
      "request_access_enabled": false
    },
    {
      "id": 6,
      "description": "Aspernatur omnis repudiandae qui voluptatibus eaque.",
      "default_branch": "main",
      "tag_list": [], //已弃用，请使用 `topics`
      "topics": [],
      "archived": false,
      "visibility": "internal",
      "ssh_url_to_repo": "git@gitlab.example.com:twitter/flight.git",
      "http_url_to_repo": "https://gitlab.example.com/twitter/flight.git",
      "web_url": "https://gitlab.example.com/twitter/flight",
      "name": "Flight",
      "name_with_namespace": "Twitter / Flight",
      "path": "flight",
      "path_with_namespace": "twitter/flight",
      "issues_enabled": true,
      "merge_requests_enabled": true,
      "wiki_enabled": true,
      "jobs_enabled": true,
      "snippets_enabled": false,
      "container_registry_enabled": true,
      "created_at": "2016-06-17T07:47:24.661Z",
      "last_activity_at": "2016-06-17T07:47:24.838Z",
      "shared_runners_enabled": true,
      "creator_id": 1,
      "namespace": {
        "id": 4,
        "name": "Twitter",
        "path": "twitter",
        "kind": "group"
      },
      "avatar_url": null,
      "star_count": 0,
      "forks_count": 0,
      "open_issues_count": 8,
      "public_jobs": true,
      "shared_with_groups": [],
      "request_access_enabled": false
    }
  ],
  "shared_projects": [ // 已弃用，将在 API v5 中移除
    {
      "id": 8,
      "description": "Velit eveniet provident fugiat saepe eligendi autem.",
      "default_branch": "main",
      "tag_list": [], //已弃用，请使用 `topics`
      "topics": [],
      "archived": false,
      "visibility": "private",
      "ssh_url_to_repo": "git@gitlab.example.com:h5bp/html5-boilerplate.git",
      "http_url_to_repo": "https://gitlab.example.com/h5bp/html5-boilerplate.git",
      "web_url": "https://gitlab.example.com/h5bp/html5-boilerplate",
      "name": "Html5 Boilerplate",
      "name_with_namespace": "H5bp / Html5 Boilerplate",
      "path": "html5-boilerplate",
      "path_with_namespace": "h5bp/html5-boilerplate",
      "issues_enabled": true,
      "merge_requests_enabled": true,
      "wiki_enabled": true,
      "jobs_enabled": true,
      "snippets_enabled": false,
      "container_registry_enabled": true,
      "created_at": "2016-06-17T07:47:27.089Z",
      "last_activity_at": "2016-06-17T07:47:27.310Z",
      "shared_runners_enabled": true,
      "creator_id": 1,
      "namespace": {
        "id": 5,
        "name": "H5bp",
        "path": "h5bp",
        "kind": "group"
      },
      "avatar_url": null,
      "star_count": 0,
      "forks_count": 0,
      "open_issues_count": 4,
      "public_jobs": true,
      "shared_with_groups": [
        {
          "group_id": 4,
          "group_name": "Twitter",
          "group_full_path": "twitter",
          "group_access_level": 30,
          "expires_at": null
        },
        {
          "group_id": 3,
          "group_name": "Gitlab Org",
          "group_full_path": "gitlab-org",
          "group_access_level": 10,
          "expires_at": "2018-08-14"
        }
      ]
    }
  ],
  "ip_restriction_ranges": null,
  "math_rendering_limits_enabled": true,
  "lock_math_rendering_limits_enabled": false
}
```

`prevent_sharing_groups_outside_hierarchy` 属性仅出现在顶级群组中。

[极狐GitLab 专业版或旗舰版](https://gitlab.cn/pricing/) 用户还会看到以下属性：

- `shared_runners_minutes_limit`
- `extra_shared_runners_minutes_limit`
- `marked_for_deletion_on`
- `membership_lock`
- `wiki_access_level`
- `duo_features_enabled`
- `lock_duo_features_enabled`
- `duo_availability`
- `experiment_features_enabled`

额外的响应属性：

```json
{
  "id": 4,
  "description": "Aliquid qui quis dignissimos distinctio ut commodi voluptas est.",
  "shared_runners_minutes_limit": 133,
  "extra_shared_runners_minutes_limit": 133,
  "marked_for_deletion_on": "2020-04-03",
  "membership_lock": false,
  "wiki_access_level": "disabled",
  "duo_features_enabled": true,
  "lock_duo_features_enabled": false,
  "duo_availability": "default_on",
  "experiment_features_enabled": false,
  ...
}
```

当添加参数 `with_projects=false` 时，不返回项目。

```shell
curl --header "PRIVATE-TOKEN: <your_access_token>" \
  --url "https://gitlab.example.com/api/v4/groups/4?with_projects=false"
```

响应示例：

```json
{
  "id": 4,
  "name": "Twitter",
  "path": "twitter",
  "description": "Aliquid qui quis dignissimos distinctio ut commodi voluptas est.",
  "visibility": "public",
  "avatar_url": null,
  "web_url": "https://gitlab.example.com/groups/twitter",
  "request_access_enabled": false,
  "repository_storage": "default",
  "full_name": "Twitter",
  "full_path": "twitter",
  "file_template_project_id": 1,
  "parent_id": null
}
```

<a id="list-groups"></a>

## 列出群组

<a id="list-all-groups"></a>

### 列出所有群组

列出已认证用户可见的群组。未认证访问时，仅返回公开群组。

默认情况下，此请求每次返回 20 条结果，因为 API 结果 [是分页的](rest/_index.md#pagination)。

未认证访问时，此端点也支持 [基于键集的分页](rest/_index.md#keyset-based-pagination)：

- 请求连续的结果页时，应使用键集分页。
- 超出特定偏移量限制（由 [用于基于偏移量分页的 REST API 最大偏移量](../administration/instance_limits.md#max-offset-allowed-by-the-rest-api-for-offset-based-pagination) 指定）时，基于偏移量的分页不可用。

参数：

| 属性 | 类型 | 是否必需 | 描述 |
| --- | --- | --- | --- |
| `skip_groups` | array of integers | no | 跳过传入的群组 ID。 |
| `all_available` | boolean | no | 为 `true` 时，返回所有可访问的群组。为 `false` 时，仅返回用户是其成员的群组。对用户默认值为 `false`，对管理员为 `true`。未认证请求始终返回所有公开群组。`owned` 和 `min_access_level` 属性优先级更高。 |
| `search` | string | no | 返回与搜索条件匹配的授权群组列表。 |
| `order_by` | string | no | 按 `name`、`path`、`id` 或 `similarity` 排序群组。默认值为 `name`。 |
| `sort` | string | no | 按 `asc` 或 `desc` 顺序排列群组。默认值为 `asc`。 |
| `statistics` | boolean | no | 包含群组统计信息（仅管理员）。<br> 对于顶级群组，响应会返回 UI 中显示的完整 `root_storage_statistics` 数据。[引入](https://jihulab.com/gitlab-cn/gitlab/-/issues/469254)于 极狐GitLab 17.4。 |
| `visibility` | string | no | 限制为具有 `public`、`internal` 或 `private` 可见性的群组。 |
| `with_custom_attributes` | boolean | no | 在响应中包含 [自定义属性](custom_attributes.md)（仅管理员）。 |
| `owned` | boolean | no | 限制为当前用户显式拥有的群组。 |
| `min_access_level` | integer | no | 限制为当前用户至少具有指定访问级别的群组。可选值：`5`（最小权限）、`10`（访客）、`15`（计划者）、`20`（报告者）、`25`（安全经理）、`30`（开发者）、`40`（维护者）或 `50`（所有者）。 |
| `top_level_only` | boolean | no | 限制为顶级群组，排除所有子群组。 |
| `repository_storage` | string | no | 按群组使用的仓库存储筛选（仅管理员）。[引入](https://jihulab.com/gitlab-cn/gitlab/-/issues/419643)于 极狐GitLab 16.3。仅限专业版和旗舰版。 |
| `marked_for_deletion_on` | date | no | 按群组标记为删除的日期筛选。[引入](https://jihulab.com/gitlab-cn/gitlab/-/issues/429315)于 极狐GitLab 17.1。仅限专业版和旗舰版。 |
| `active` | boolean | no | 限制为未归档且未标记为删除的群组。 |
| `archived` | boolean | no | 限制为已归档的群组。[引入](https://jihulab.com/gitlab-cn/gitlab/-/issues/519587)于 极狐GitLab 18.2。 |

```plaintext
GET /groups
```

```json
[
  {
    "id": 1,
    "name": "Foobar Group",
    "path": "foo-bar",
    "description": "An interesting group",
    "visibility": "public",
    "share_with_group_lock": false,
    "require_two_factor_authentication": false,
    "two_factor_grace_period": 48,
    "project_creation_level": "developer",
    "auto_devops_enabled": null,
    "subgroup_creation_level": "owner",
    "emails_disabled": null,
    "emails_enabled": null,
    "mentions_disabled": null,
    "lfs_enabled": true,
    "default_branch": null,
    "default_branch_protection": 2,
    "default_branch_protection_defaults": {
      "allowed_to_push": [
          {
              "access_level": 40
          }
      ],
      "allow_force_push": false,
      "allowed_to_merge": [
          {
              "access_level": 40
          }
      ]
    },
    "avatar_url": "http://localhost:3000/uploads/group/avatar/1/foo.jpg",
    "web_url": "http://localhost:3000/groups/foo-bar",
    "request_access_enabled": false,
    "repository_storage": "default",
    "full_name": "Foobar Group",
    "full_path": "foo-bar",
    "file_template_project_id": 1,
    "parent_id": null,
    "created_at": "2020-01-15T12:36:29.590Z",
    "ip_restriction_ranges": null
  }
]
```

当添加参数 `statistics=true` 且已认证用户为管理员时，会返回额外的群组统计信息。对于顶级群组，还会添加 `root_storage_statistics`。

```plaintext
GET /groups?statistics=true
```

当使用参数 `statistics=true` 且已认证用户为管理员时，响应中包含容器镜像仓库存储大小的信息：

- `container_registry_size`：群组及其子群组中所有容器仓库使用的总存储大小（字节）。计算为群组项目及子群组中所有仓库大小的总和。仅在容器镜像仓库元数据数据库启用时可用。
- `container_registry_size_is_estimated`：指示大小是精确计算（基于所有仓库的实际数据，`false`）还是因性能限制而估算（`true`）。

对于私有化部署实例，必须启用 [容器镜像仓库元数据数据库](../administration/packages/container_registry_metadata_database.md) 才能包含容器镜像仓库大小属性。

```json
[
  {
    "id": 1,
    "name": "Foobar Group",
    "path": "foo-bar",
    "description": "An interesting group",
    "visibility": "public",
    "share_with_group_lock": false,
    "require_two_factor_authentication": false,
    "two_factor_grace_period": 48,
    "project_creation_level": "developer",
    "auto_devops_enabled": null,
    "subgroup_creation_level": "owner",
    "emails_disabled": null,
    "emails_enabled": null,
    "mentions_disabled": null,
    "lfs_enabled": true,
    "default_branch": null,
    "default_branch_protection": 2,
    "default_branch_protection_defaults": {
      "allowed_to_push": [
          {
              "access_level": 40
          }
      ],
      "allow_force_push": false,
      "allowed_to_merge": [
          {
              "access_level": 40
          }
      ]
    },
    "avatar_url": "http://localhost:3000/uploads/group/avatar/1/foo.jpg",
    "web_url": "http://localhost:3000/groups/foo-bar",
    "request_access_enabled": false,
    "repository_storage": "default",
    "full_name": "Foobar Group",
    "full_path": "foo-bar",
    "file_template_project_id": 1,
    "parent_id": null,
    "created_at": "2020-01-15T12:36:29.590Z",
    "statistics": {
      "storage_size": 363,
      "repository_size": 33,
      "wiki_size": 100,
      "lfs_objects_size": 123,
      "job_artifacts_size": 57,
      "pipeline_artifacts_size": 0,
      "packages_size": 0,
      "snippets_size": 50,
      "uploads_size": 0
    },
    "root_storage_statistics": {
      "build_artifacts_size": 0,
      "container_registry_size": 0,
      "container_registry_size_is_estimated": false,
      "dependency_proxy_size": 0,
      "lfs_objects_size": 0,
      "packages_size": 0,
      "pipeline_artifacts_size": 0,
      "repository_size": 0,
      "snippets_size": 0,
      "storage_size": 0,
      "uploads_size": 0,
      "wiki_size": 0
  },
    "wiki_access_level": "private",
    "duo_features_enabled": true,
    "lock_duo_features_enabled": false,
    "duo_availability": "default_on",
    "experiment_features_enabled": false,
  }
]
```

[极狐GitLab 专业版或旗舰版](https://gitlab.cn/pricing/) 用户还会看到 `wiki_access_level`、`duo_features_enabled`、`lock_duo_features_enabled`、`duo_availability` 和 `experiment_features_enabled` 属性。

您可以按名称或路径搜索群组，见下文。

您可以使用以下方式按 [自定义属性](custom_attributes.md) 筛选：

```plaintext
GET /groups?custom_attributes[key]=value&custom_attributes[other_key]=other_value
```

#### Group pagination

按组分页。

默认情况下，由于 API 结果分页，每次仅显示 20 个群组。

要获取更多（最多 100 个），请将以下参数传递给 API 调用：

```plaintext
/groups?per_page=100
```

要切换页面，请添加：

```plaintext
/groups?per_page=100&page=2
```

<a id="search-for-a-group"></a>

### 搜索群组

搜索名称或路径中与字符串匹配的群组。

```plaintext
GET /groups?search=foobar
```

```json
[
  {
    "id": 1,
    "name": "Foobar Group",
    "path": "foo-bar",
    "description": "An interesting group"
  }
]
```

<a id="list-group-details"></a>

## 列出群组详情

<a id="list-projects"></a>

### 列出项目

列出群组中的项目。未认证访问时，仅返回公开项目。

默认情况下，此请求每次返回 20 条结果，因为 API 结果 [是分页的](rest/_index.md#pagination)。

```plaintext
GET /groups/:id/projects
```

参数：

| 属性 | 类型 | 是否必需 | 描述 |
| --- | --- | --- | --- |
| `id` | integer or string | yes | 群组的 ID 或 [URL 编码路径](rest/_index.md#namespaced-paths)。 |
| `active` | boolean | no | 按项目状态限制。为 `true` 时，返回活跃项目。为 `false` 时，返回已归档或标记为删除的项目。[引入](https://jihulab.com/gitlab-cn/gitlab/-/merge_requests/218053)于 极狐GitLab 18.8。 |
| `archived` | boolean | no | 按归档状态限制。 |
| `visibility` | string | no | 按可见性限制：`public`、`internal` 或 `private`。 |
| `order_by` | string | no | 按 `id`、`name`、`path`、`created_at`、`updated_at`、`similarity` <sup>1</sup>、`star_count` 或 `last_activity_at` 字段排序项目。默认值为 `created_at`。 |
| `sort` | string | no | 按 `asc` 或 `desc` 顺序返回排序后的项目。默认值为 `desc`。 |
| `search` | string | no | 返回与搜索条件匹配的授权项目列表。 |
| `simple` | boolean | no | 为每个项目仅返回有限字段。未认证时无操作，此时只返回简单字段。 |
| `owned` | boolean | no | 限制为当前用户拥有的项目。 |
| `starred` | boolean | no | 限制为当前用户星标的项目。 |
| `topic` | string | no | 返回与主题匹配的项目。 |
| `with_issues_enabled` | boolean | no | 限制为启用了议题功能的项目。默认值为 `false`。 |
| `with_merge_requests_enabled` | boolean | no | 限制为启用了合并请求功能的项目。默认值为 `false`。 |
| `with_shared` | boolean | no | 包含共享到此群组的项目。默认值为 `true`。 |
| `include_subgroups` | boolean | no | 包含此群组子群组中的项目。默认值为 `false`。 |
| `min_access_level` | integer | no | 限制为当前用户至少具有指定访问级别的项目。可选值：`5`（最小权限）、`10`（访客）、`15`（计划者）、`20`（报告者）、`25`（安全经理）、`30`（开发者）、`40`（维护者）或 `50`（所有者）。 |
| `with_custom_attributes` | boolean | no | 在响应中包含 [自定义属性](custom_attributes.md)（仅管理员）。 |
| `with_security_reports` | boolean | no | 仅返回在其任何构建中存在安全报告产物的项目。这意味着“已启用安全报告的项目”。默认值为 `false`。仅限旗舰版。 |

**脚注**:

1. 根据 `search` URL 参数计算的相似度分数对结果进行排序。
   当您使用 `order_by=similarity` 时，`sort` 参数将被忽略。
   如果未提供 `search` 参数，API 将按 `name` 返回项目。

响应示例：

```json
[
  {
    "id": 9,
    "description": "foo",
    "default_branch": "main",
    "tag_list": [], //已弃用，请使用 `topics`
    "topics": [],
    "archived": false,
    "visibility": "internal",
    "ssh_url_to_repo": "git@gitlab.example.com/html5-boilerplate.git",
    "http_url_to_repo": "http://gitlab.example.com/h5bp/html5-boilerplate.git",
    "web_url": "http://gitlab.example.com/h5bp/html5-boilerplate",
    "name": "Html5 Boilerplate",
    "name_with_namespace": "Experimental / Html5 Boilerplate",
    "path": "html5-boilerplate",
    "path_with_namespace": "h5bp/html5-boilerplate",
    "issues_enabled": true,
    "merge_requests_enabled": true,
    "wiki_enabled": true,
    "jobs_enabled": true,
    "snippets_enabled": true,
    "created_at": "2016-04-05T21:40:50.169Z",
    "last_activity_at": "2016-04-06T16:52:08.432Z",
    "shared_runners_enabled": true,
    "creator_id": 1,
    "namespace": {
      "id": 5,
      "name": "Experimental",
      "path": "h5bp",
      "kind": "group"
    },
    "avatar_url": null,
    "star_count": 1,
    "forks_count": 0,
    "open_issues_count": 3,
    "public_jobs": true,
    "shared_with_groups": [],
    "request_access_enabled": false
  }
]
```

> [!note]
> 要区分群组中的项目与共享到群组的项目，可以使用 `namespace` 属性。当项目已共享到群组时，其 `namespace` 与发起请求的群组不同。

<a id="list-shared-projects"></a>

### 列出共享项目

列出共享到群组的项目。未认证访问时，仅返回公开共享项目。

默认情况下，此请求每次返回 20 条结果，因为 API 结果 [是分页的](rest/_index.md#pagination)。

```plaintext
GET /groups/:id/projects/shared
```

参数：
| 属性                     | 类型           | 是否必需 | 描述 |
| ----------------------------- | -------------- | -------- | ----------- |
| `id`                          | 整数或字符串 | 是      | 群组的 ID 或 [URL 编码路径](rest/_index.md#namespaced-paths)。 |
| `archived`                    | 布尔值        | 否       | 按归档状态过滤。 |
| `visibility`                  | 字符串         | 否       | 按可见性 `public`、`internal` 或 `private` 过滤。 |
| `order_by`                    | 字符串         | 否       | 返回按 `id`、`name`、`path`、`created_at`、`updated_at`、`star_count` 或 `last_activity_at` 字段排序的项目。默认为 `created_at`。 |
| `sort`                        | 字符串         | 否       | 返回按 `asc` 或 `desc` 顺序排序的项目。默认为 `desc`。 |
| `search`                      | 字符串         | 否       | 返回与搜索条件匹配的已授权项目列表。 |
| `simple`                      | 布尔值        | 否       | 仅返回每个项目的有限字段。在未认证的情况下，此操作无效，因为只会返回简单字段。 |
| `starred`                     | 布尔值        | 否       | 按当前用户收藏的项目过滤。 |
| `with_issues_enabled`         | 布尔值        | 否       | 按启用了议题功能的项目过滤。默认为 `false`。 |
| `with_merge_requests_enabled` | 布尔值        | 否       | 按启用了合并请求功能的项目过滤。默认为 `false`。 |
| `min_access_level`            | 整数        | 否       | 限制为当前用户至少具有指定访问级别的项目。可能的值：`5`（最小权限）、`10`（访客）、`15`（计划者）、`20`（报告者）、`25`（安全经理）、`30`（开发者）、`40`（维护者）或 `50`（所有者）。 |
| `with_custom_attributes`      | 布尔值        | 否       | 在响应中包含[自定义属性](custom_attributes.md)（仅限管理员）。 |

响应示例：

```json
[
   {
      "id":8,
      "description":"Html5 Boilerplate 的共享项目",
      "name":"Html5 Boilerplate",
      "name_with_namespace":"H5bp / Html5 Boilerplate",
      "path":"html5-boilerplate",
      "path_with_namespace":"h5bp/html5-boilerplate",
      "created_at":"2020-04-27T06:13:22.642Z",
      "default_branch":"main",
      "tag_list":[], //已弃用，请使用 `topics` 代替
      "topics":[],
      "ssh_url_to_repo":"ssh://git@jihulab.com/h5bp/html5-boilerplate.git",
      "http_url_to_repo":"https://jihulab.com/h5bp/html5-boilerplate.git",
      "web_url":"https://jihulab.com/h5bp/html5-boilerplate",
      "readme_url":"https://jihulab.com/h5bp/html5-boilerplate/-/blob/main/README.md",
      "avatar_url":null,
      "star_count":0,
      "forks_count":4,
      "last_activity_at":"2020-04-27T06:13:22.642Z",
      "namespace":{
         "id":28,
         "name":"H5bp",
         "path":"h5bp",
         "kind":"group",
         "full_path":"h5bp",
         "parent_id":null,
         "avatar_url":null,
         "web_url":"https://jihulab.com/groups/h5bp"
      },
      "_links":{
         "self":"https://jihulab.com/api/v4/projects/8",
         "issues":"https://jihulab.com/api/v4/projects/8/issues",
         "merge_requests":"https://jihulab.com/api/v4/projects/8/merge_requests",
         "repo_branches":"https://jihulab.com/api/v4/projects/8/repository/branches",
         "labels":"https://jihulab.com/api/v4/projects/8/labels",
         "events":"https://jihulab.com/api/v4/projects/8/events",
         "members":"https://jihulab.com/api/v4/projects/8/members"
      },
      "empty_repo":false,
      "archived":false,
      "visibility":"public",
      "resolve_outdated_diff_discussions":false,
      "container_registry_enabled":true,
      "container_expiration_policy":{
         "cadence":"7d",
         "enabled":true,
         "keep_n":null,
         "older_than":null,
         "name_regex":null,
         "name_regex_keep":null,
         "next_run_at":"2020-05-04T06:13:22.654Z"
      },
      "issues_enabled":true,
      "merge_requests_enabled":true,
      "wiki_enabled":true,
      "jobs_enabled":true,
      "snippets_enabled":true,
      "can_create_merge_request_in":true,
      "issues_access_level":"enabled",
      "repository_access_level":"enabled",
      "merge_requests_access_level":"enabled",
      "forking_access_level":"enabled",
      "wiki_access_level":"enabled",
      "builds_access_level":"enabled",
      "snippets_access_level":"enabled",
      "pages_access_level":"enabled",
      "security_and_compliance_access_level":"enabled",
      "emails_disabled":null,
      "emails_enabled": null,
      "shared_runners_enabled":true,
      "lfs_enabled":true,
      "creator_id":1,
      "import_status":"failed",
      "open_issues_count":10,
      "ci_default_git_depth":50,
      "ci_forward_deployment_enabled":true,
      "ci_forward_deployment_rollback_allowed": true,
      "ci_allow_fork_pipelines_to_run_in_parent_project":true,
      "public_jobs":true,
      "build_timeout":3600,
      "auto_cancel_pending_pipelines":"enabled",
      "ci_config_path":null,
      "shared_with_groups":[
         {
            "group_id":24,
            "group_name":"Commit451",
            "group_full_path":"Commit451",
            "group_access_level":30,
            "expires_at":null
         }
      ],
      "only_allow_merge_if_pipeline_succeeds":false,
      "request_access_enabled":true,
      "only_allow_merge_if_all_discussions_are_resolved":false,
      "remove_source_branch_after_merge":true,
      "printing_merge_request_link_enabled":true,
      "merge_method":"merge",
      "suggestion_commit_message":null,
      "auto_devops_enabled":true,
      "auto_devops_deploy_strategy":"continuous",
      "autoclose_referenced_issues":true,
      "repository_storage":"default"
   }
]
```

<a id="list-all-saml-users"></a>

### 列出所有 SAML 用户

{{< details >}}

- Tier: 专业版，旗舰版
- Offering: JihuLab.com，私有化部署

{{< /details >}}

{{< history >}}

- 在极狐GitLab 18.1 中引入。

{{< /history >}}

列出给定顶级群组的所有 SAML 用户。

使用 `page` 和 `per_page` [分页参数](rest/_index.md#offset-based-pagination) 过滤结果。

```plaintext
GET /groups/:id/saml_users
```

支持的属性：

| 属性        | 类型           | 是否必需 | 描述 |
|:-----------------|:---------------|:---------|:------------|
| `id`             | 整数或字符串 | 是      | 顶级群组的 ID 或 [URL 编码路径](rest/_index.md#namespaced-paths)。 |
| `username`       | 字符串         | 否       | 返回具有给定用户名的用户。 |
| `search`         | 字符串         | 否       | 返回名称、电子邮件或用户名匹配的用户。使用部分值可增加结果。 |
| `active`         | 布尔值        | 否       | 仅返回活跃用户。 |
| `blocked`        | 布尔值        | 否       | 仅返回已阻止的用户。 |
| `created_after`  | 日期时间       | 否       | 返回在指定时间之后创建的用户。格式：ISO 8601 (`YYYY-MM-DDTHH:MM:SSZ`)。 |
| `created_before` | 日期时间       | 否       | 返回在指定时间之前创建的用户。格式：ISO 8601 (`YYYY-MM-DDTHH:MM:SSZ`)。 |

请求示例：

```shell
curl --header "PRIVATE-TOKEN: <your_access_token>" \
  --url "https://gitlab.example.com/api/v4/groups/:id/saml_users"
```

响应示例：

```json
[
  {
    "id": 66,
    "username": "user22",
    "name": "Sidney Jones22",
    "state": "active",
    "avatar_url": "https://www.gravatar.com/avatar/xxx?s=80&d=identicon",
    "web_url": "http://my.gitlab.com/user22",
    "created_at": "2021-09-10T12:48:22.381Z",
    "bio": "",
    "location": null,
    "public_email": "",
    "linkedin": "",
    "twitter": "",
    "website_url": "",
    "organization": null,
    "job_title": "",
    "pronouns": null,
    "bot": false,
    "work_information": null,
    "followers": 0,
    "following": 0,
    "local_time": null,
    "last_sign_in_at": null,
    "confirmed_at": "2021-09-10T12:48:22.330Z",
    "last_activity_on": null,
    "email": "user22@example.org",
    "theme_id": 1,
    "color_scheme_id": 1,
    "projects_limit": 100000,
    "current_sign_in_at": null,
    "identities": [
      {
        "provider": "group_saml",
        "extern_uid": "2435223452345",
        "saml_provider_id": 1
      }
    ],
    "can_create_group": true,
    "can_create_project": true,
    "two_factor_enabled": false,
    "external": false,
    "private_profile": false,
    "commit_email": "user22@example.org",
    "shared_runners_minutes_limit": null,
    "extra_shared_runners_minutes_limit": null,
    "scim_identities": [
      {
        "extern_uid": "2435223452345",
        "group_id": 1,
        "active": true
      }
    ]
  },
  ...
]
```

<a id="list-provisioned-users"></a>

### 列出已配置的用户

{{< details >}}

- Tier: 专业版，旗舰版
- Offering: JihuLab.com，私有化部署

{{< /details >}}

列出由群组配置的用户。不包括子群组。

需要在群组上具有维护者或所有者角色。

```plaintext
GET /groups/:id/provisioned_users
```

参数：

| 属性        | 类型           | 是否必需 | 描述 |
|:-----------------|:---------------|:---------|:------------|
| `id`             | 整数或字符串 | 是      | 群组的 ID 或 [URL 编码路径](rest/_index.md#namespaced-paths)。 |
| `username`       | 字符串         | 否       | 返回具有特定用户名的单个用户。 |
| `search`         | 字符串         | 否       | 按名称、电子邮件、用户名搜索用户。 |
| `active`         | 布尔值        | 否       | 仅返回活跃用户。 |
| `blocked`        | 布尔值        | 否       | 仅返回已阻止的用户。 |
| `created_after`  | 日期时间       | 否       | 返回在指定时间之后创建的用户。 |
| `created_before` | 日期时间       | 否       | 返回在指定时间之前创建的用户。 |

响应示例：

```json
[
  {
    "id": 66,
    "username": "user22",
    "name": "John Doe22",
    "state": "active",
    "avatar_url": "https://www.gravatar.com/avatar/xxx?s=80&d=identicon",
    "web_url": "http://my.gitlab.com/user22",
    "created_at": "2021-09-10T12:48:22.381Z",
    "bio": "",
    "location": null,
    "public_email": "",
    "linkedin": "",
    "twitter": "",
    "website_url": "",
    "organization": null,
    "job_title": "",
    "pronouns": null,
    "bot": false,
    "work_information": null,
    "followers": 0,
    "following": 0,
    "local_time": null,
    "last_sign_in_at": null,
    "confirmed_at": "2021-09-10T12:48:22.330Z",
    "last_activity_on": null,
    "email": "user22@example.org",
    "theme_id": 1,
    "color_scheme_id": 1,
    "projects_limit": 100000,
    "current_sign_in_at": null,
    "identities": [ ],
    "can_create_group": true,
    "can_create_project": true,
    "two_factor_enabled": false,
    "external": false,
    "private_profile": false,
    "commit_email": "user22@example.org",
    "shared_runners_minutes_limit": null,
    "extra_shared_runners_minutes_limit": null
  },
  ...
]
```

<a id="list-subgroups"></a>

### 列出子群组

列出群组中可见的直接子群组。

默认情况下，此请求每次返回 20 个结果，因为 API 结果[是分页的](rest/_index.md#pagination)。

如果你以以下身份请求此列表：

- 未认证用户，响应仅返回公开群组。
- 已认证用户，响应仅返回你所属的群组，不包括公开群组。

参数：

| 属性                | 类型              | 是否必需 | 描述 |
| ------------------------ | ----------------- | -------- | ----------- |
| `id`                     | 整数或字符串    | 是      | 直接父群组的 ID 或 [URL 编码路径](rest/_index.md#namespaced-paths)。 |
| `skip_groups`            | 整数数组 | 否       | 跳过传入的群组 ID。 |
| `all_available`          | 布尔值           | 否       | 显示你有权访问的所有群组（对于已认证用户默认为 `false`，对于管理员默认为 `true`）。属性 `owned` 和 `min_access_level` 具有优先级。 |
| `search`                 | 字符串            | 否       | 返回与搜索条件匹配的已授权群组列表。仅搜索子群组的短路径（不搜索完整路径）。 |
| `order_by`               | 字符串            | 否       | 按 `name`、`path` 或 `id` 对群组排序。默认为 `name`。 |
| `sort`                   | 字符串            | 否       | 按 `asc` 或 `desc` 顺序对群组排序。默认为 `asc`。 |
| `statistics`             | 布尔值           | 否       | 包含群组统计信息（仅限管理员）。 |
| `with_custom_attributes` | 布尔值           | 否       | 在响应中包含[自定义属性](custom_attributes.md)（仅限管理员）。 |
| `owned`                  | 布尔值           | 否       | 限制为当前用户明确拥有的群组。 |
| `min_access_level`       | 整数           | 否       | 限制为当前用户至少具有指定访问级别的群组。可能的值：`5`（最小权限）、`10`（访客）、`15`（计划者）、`20`（报告者）、`25`（安全经理）、`30`（开发者）、`40`（维护者）或 `50`（所有者）。 |
| `all_available`          | 布尔值           | 否       | 当为 `true` 时，返回所有可访问的群组。当为 `false` 时，仅返回用户是成员的群组。对于用户默认为 `false`，对于管理员默认为 `true`。未认证请求始终返回所有公开群组。`owned` 和 `min_access_level` 属性具有优先级。 |
| `active`                 | 布尔值           | 否       | 限制为未归档且未标记为删除的群组。 |

```plaintext
GET /groups/:id/subgroups
```

```json
[
  {
    "id": 1,
    "name": "Foobar Group",
    "path": "foo-bar",
    "description": "一个有趣的群组",
    "visibility": "public",
    "share_with_group_lock": false,
    "require_two_factor_authentication": false,
    "two_factor_grace_period": 48,
    "project_creation_level": "developer",
    "auto_devops_enabled": null,
    "subgroup_creation_level": "owner",
    "emails_disabled": null,
    "emails_enabled": null,
    "mentions_disabled": null,
    "lfs_enabled": true,
    "default_branch": null,
    "default_branch_protection": 2,
    "default_branch_protection_defaults": {
      "allowed_to_push": [
          {
              "access_level": 40
          }
      ],
      "allow_force_push": false,
      "allowed_to_merge": [
          {
              "access_level": 40
          }
      ]
    },
    "avatar_url": "http://gitlab.example.com/uploads/group/avatar/1/foo.jpg",
    "web_url": "http://gitlab.example.com/groups/foo-bar",
    "request_access_enabled": false,
    "repository_storage": "default",
    "full_name": "Foobar Group",
    "full_path": "foo-bar",
    "file_template_project_id": 1,
    "parent_id": 123,
    "created_at": "2020-01-15T12:36:29.590Z"
  }
]
```

[极狐GitLab 专业版或旗舰版](https://gitlab.cn/pricing/) 的用户还会看到 `wiki_access_level`、`duo_features_enabled`、`lock_duo_features_enabled`、`duo_availability` 和 `experiment_features_enabled` 属性。

<a id="list-descendant-groups"></a>

### 列出后代群组

列出群组的可见后代群组。
当未认证访问时，仅返回公开群组。

默认情况下，此请求每次返回 20 个结果，因为 API 结果[是分页的](rest/_index.md#pagination)。

参数：

| 属性                | 类型              | 是否必需 | 描述 |
| ------------------------ | ----------------- | -------- | ----------- |
| `id`                     | 整数或字符串    | 是      | 直接父群组的 ID 或 [URL 编码路径](rest/_index.md#namespaced-paths)。 |
| `skip_groups`            | 整数数组 | 否       | 跳过传入的群组 ID。 |
| `all_available`          | 布尔值           | 否       | 当为 `true` 时，返回所有可访问的群组。当为 `false` 时，仅返回用户是成员的群组。对于用户默认为 `false`，对于管理员默认为 `true`。未认证请求始终返回所有公开群组。`owned` 和 `min_access_level` 属性具有优先级。 |
| `search`                 | 字符串            | 否       | 返回与搜索条件匹配的已授权群组列表。仅搜索后代群组的短路径（不搜索完整路径）。 |
| `order_by`               | 字符串            | 否       | 按 `name`、`path` 或 `id` 对群组排序。默认为 `name`。 |
| `sort`                   | 字符串            | 否       | 按 `asc` 或 `desc` 顺序对群组排序。默认为 `asc`。 |
| `statistics`             | 布尔值           | 否       | 包含群组统计信息（仅限管理员）。 |
| `with_custom_attributes` | 布尔值           | 否       | 在响应中包含[自定义属性](custom_attributes.md)（仅限管理员）。 |
| `owned`                  | 布尔值           | 否       | 限制为当前用户明确拥有的群组。 |
| `min_access_level`       | 整数           | 否       | 限制为当前用户至少具有指定访问级别的群组。可能的值：`5`（最小权限）、`10`（访客）、`15`（计划者）、`20`（报告者）、`25`（安全经理）、`30`（开发者）、`40`（维护者）或 `50`（所有者）。 |
| `active`                 | 布尔值           | 否       | 限制为未归档且未标记为删除的群组。 |

```plaintext
GET /groups/:id/descendant_groups
```

```json
[
  {
    "id": 2,
    "name": "Bar Group",
    "path": "bar",
    "description": "Foo Group 的一个子群组",
    "visibility": "public",
    "share_with_group_lock": false,
    "require_two_factor_authentication": false,
    "two_factor_grace_period": 48,
    "project_creation_level": "developer",
    "auto_devops_enabled": null,
    "subgroup_creation_level": "owner",
    "emails_disabled": null,
    "emails_enabled": null,
    "mentions_disabled": null,
    "lfs_enabled": true,
    "default_branch": null,
    "default_branch_protection": 2,
    "default_branch_protection_defaults": {
      "allowed_to_push": [
          {
              "access_level": 40
          }
      ],
      "allow_force_push": false,
      "allowed_to_merge": [
          {
              "access_level": 40
          }
      ]
    },
    "avatar_url": "http://gitlab.example.com/uploads/group/avatar/1/bar.jpg",
    "web_url": "http://gitlab.example.com/groups/foo/bar",
    "request_access_enabled": false,
    "full_name": "Bar Group",
    "full_path": "foo/bar",
    "file_template_project_id": 1,
    "parent_id": 123,
    "created_at": "2020-01-15T12:36:29.590Z"
  },
  {
    "id": 3,
    "name": "Baz Group",
    "path": "baz",
    "description": "Bar Group 的一个子群组",
    "visibility": "public",
    "share_with_group_lock": false,
    "require_two_factor_authentication": false,
    "two_factor_grace_period": 48,
    "project_creation_level": "developer",
    "auto_devops_enabled": null,
    "subgroup_creation_level": "owner",
    "emails_disabled": null,
    "emails_enabled": null,
    "mentions_disabled": null,
    "lfs_enabled": true,
    "default_branch": null,
    "default_branch_protection": 2,
    "default_branch_protection_defaults": {
      "allowed_to_push": [
          {
              "access_level": 40
          }
      ],
      "allow_force_push": false,
      "allowed_to_merge": [
          {
              "access_level": 40
          }
      ]
    },
    "avatar_url": "http://gitlab.example.com/uploads/group/avatar/1/baz.jpg",
    "web_url": "http://gitlab.example.com/groups/foo/bar/baz",
    "request_access_enabled": false,
    "full_name": "Baz Group",
    "full_path": "foo/bar/baz",
    "file_template_project_id": 1,
    "parent_id": 123,
    "created_at": "2020-01-15T12:36:29.590Z"
  }
]
```

[极狐GitLab 专业版或旗舰版](https://gitlab.cn/pricing/) 的用户还会看到 `wiki_access_level`、`duo_features_enabled`、`lock_duo_features_enabled`、`duo_availability` 和 `experiment_features_enabled` 属性。

<a id="list-shared-groups"></a>

### 列出共享群组

列出给定群组已被邀请加入的群组。当未认证访问时，仅返回公开的共享群组。

默认情况下，此请求每次返回 20 个结果，因为 API 结果[是分页的](rest/_index.md#pagination)。

参数：

| 属性                             | 类型              | 是否必需 | 描述 |
| ------------------------------------- | ----------------- | -------- | ---------- |
| `id`                                  | 整数或字符串    | 是      | 群组的 ID 或 [URL 编码路径](rest/_index.md#namespaced-paths)。 |
| `skip_groups`                         | 整数数组 | 否       | 跳过指定的群组 ID。 |
| `search`                              | 字符串            | 否       | 返回与搜索条件匹配的已授权群组列表。 |
| `order_by`                            | 字符串            | 否       | 按 `name`、`path`、`id` 或 `similarity` 对群组排序。默认为 `name`。 |
| `sort`                                | 字符串            | 否       | 按 `asc` 或 `desc` 顺序对群组排序。默认为 `asc`。 |
| `visibility`                          | 字符串            | 否       | 限制为具有 `public`、`internal` 或 `private` 可见性的群组。 |
| `min_access_level`                    | 整数           | 否       | 限制为当前用户至少具有指定访问级别的群组。可能的值：`5`（最小权限）、`10`（访客）、`15`（计划者）、`20`（报告者）、`25`（安全经理）、`30`（开发者）、`40`（维护者）或 `50`（所有者）。 |
| `with_custom_attributes`              | 布尔值           | 否       | 在响应中包含[自定义属性](custom_attributes.md)（仅限管理员）。 |

```plaintext
GET /groups/:id/groups/shared
```

响应示例：

```json
[
  {
    "id": 101,
    "web_url": "http://gitlab.example.com/groups/some_path",
    "name": "group1",
    "path": "some_path",
    "description": "",
    "visibility": "public",
    "share_with_group_lock": "false",
    "require_two_factor_authentication": "false",
    "two_factor_grace_period": 48,
    "project_creation_level": "maintainer",
    "auto_devops_enabled": "nil",
    "subgroup_creation_level": "maintainer",
    "emails_disabled": "false",
    "emails_enabled": "true",
    "mentions_disabled": "nil",
    "lfs_enabled": "true",
    "math_rendering_limits_enabled": "true",
    "lock_math_rendering_limits_enabled": "false",
    "default_branch": "nil",
    "default_branch_protection": 2,
    "default_branch_protection_defaults": {
        "allowed_to_push": [
          {
              "access_level": 30
          }
        ],
        "allow_force_push": "true",
        "allowed_to_merge": [
          {
              "access_level": 30
          }
        ],
        "developer_can_initial_push": "false",
        "code_owner_approval_required": "false"
    },
    "avatar_url": "http://gitlab.example.com/uploads/-/system/group/avatar/101/banana_sample.gif",
    "request_access_enabled": "true",
    "full_name": "group1",
    "full_path": "some_path",
    "created_at": "2024-06-06T09:39:30.056Z",
    "parent_id": "nil",
    "organization_id": 1,
    "shared_runners_setting": "enabled",
    "ldap_cn": "nil",
    "ldap_access": "nil",
    "wiki_access_level": "enabled"
  }
]
```

<a id="list-invited-groups"></a>

### 列出受邀群组

列出一个群组中的受邀群组。当未认证访问时，仅返回公开的受邀群组。
此端点限制为每个用户（已认证）或 IP（未认证）每分钟 60 个请求。

默认情况下，此请求每次返回 20 个结果，因为 API 结果[是分页的](rest/_index.md#pagination)。

参数：
| 属性 | 类型 | 必需 | 描述 |
| ------------------------------------- | ----------------- | -------- | ---------- |
| `id` | integer or string | 是 | 群组的 ID 或 [URL 编码路径](rest/_index.md#namespaced-paths)。 |
| `search` | string | 否 | 返回与搜索条件匹配的授权群组列表。 |
| `min_access_level` | integer | 否 | 限制为当前用户至少具有指定访问级别的群组。可能的值：`5`（最低访问权限）、`10`（访客）、`15`（计划者）、`20`（报告者）、`25`（Security Manager）、`30`（开发者）、`40`（维护者）或 `50`（所有者）。 |
| `relation` | array of strings | 否 | 按关系筛选群组（直接或继承）。 |
| `with_custom_attributes` | boolean | 否 | 在响应中包含[自定义属性](custom_attributes.md)（仅限管理员）。 |

```plaintext
GET /groups/:id/invited_groups
```

示例响应：

```json
[
  {
    "id": 33,
    "web_url": "http://gitlab.example.com/groups/flightjs",
    "name": "Flightjs",
    "path": "flightjs",
    "description": "Illo dolorum tempore eligendi minima ducimus provident.",
    "visibility": "public",
    "share_with_group_lock": false,
    "require_two_factor_authentication": false,
    "two_factor_grace_period": 48,
    "project_creation_level": "developer",
    "auto_devops_enabled": null,
    "subgroup_creation_level": "maintainer",
    "emails_disabled": false,
    "emails_enabled": true,
    "mentions_disabled": null,
    "lfs_enabled": true,
    "math_rendering_limits_enabled": true,
    "lock_math_rendering_limits_enabled": false,
    "default_branch": null,
    "default_branch_protection": 2,
    "default_branch_protection_defaults": {
      "allowed_to_push": [
        {
          "access_level": 40
        }
      ],
      "allow_force_push": false,
      "allowed_to_merge": [
        {
          "access_level": 40
        }
      ],
      "developer_can_initial_push": false
    },
    "avatar_url": null,
    "request_access_enabled": true,
    "full_name": "Flightjs",
    "full_path": "flightjs",
    "created_at": "2024-07-09T10:31:08.307Z",
    "parent_id": null,
    "organization_id": 1,
    "shared_runners_setting": "enabled",
    "ldap_cn": null,
    "ldap_access": null,
    "wiki_access_level": "enabled"
  }
]
```

<a id="list-audit-events"></a>
### 列出审计事件

{{< details >}}

- Tier: 专业版、旗舰版
- Offering: JihuLab.com、私有化部署

{{< /details >}}

群组审计事件可通过[群组审计事件 API](audit_events.md#group-audit-events) 访问。

<a id="manage-groups"></a>
## 管理群组

<a id="create-a-group"></a>
### 创建群组

> [!note]
> 在 JihuLab.com 上，你必须使用极狐GitLab UI 创建无父群组的群组。你不能使用 API 执行此操作。

创建一个新的项目群组。仅适用于可以创建群组的用户。

```plaintext
POST /groups
```

参数：

| 属性 | 类型 | 必需 | 描述 |
|--------------------------------------|---------|----------|-------------|
| `name` | string | 是 | 群组的名称。 |
| `path` | string | 是 | 群组的路径。 |
| `auto_devops_enabled` | boolean | 否 | 默认为此群组内的所有项目启用 Auto DevOps 流水线。 |
| `avatar` | mixed | 否 | 群组头像的图像文件。 |
| `default_branch` | string | 否 | 群组项目的[默认分支](../user/project/repository/branches/default.md)名称。在极狐GitLab 16.11 中[引入](https://jihulab.com/gitlab-cn/gitlab/-/issues/442298)。 |
| `default_branch_protection` | integer | 否 | 在极狐GitLab 17.0 中[弃用](https://jihulab.com/gitlab-cn/gitlab/-/issues/408314)。请改用 `default_branch_protection_defaults`。 |
| `default_branch_protection_defaults` | hash | 否 | 在极狐GitLab 17.0 中引入。有关可用选项，请参阅[`default_branch_protection_defaults` 的选项](#options-for-default_branch_protection_defaults)。 |
| `description` | string | 否 | 群组的描述。 |
| `enabled_git_access_protocol` | string | 否 | 启用的 Git 访问协议。允许的值：`ssh`、`http` 和 `all` 以允许两种协议。在极狐GitLab 16.9 中[引入](https://jihulab.com/gitlab-cn/gitlab/-/issues/436618)。 |
| `emails_disabled` | boolean | 否 | （在极狐GitLab 16.5 中[弃用](https://jihulab.com/gitlab-cn/gitlab/-/merge_requests/127899)）禁用电子邮件通知。请改用 `emails_enabled`。 |
| `emails_enabled` | boolean | 否 | 启用电子邮件通知。 |
| `lfs_enabled` | boolean | 
- 在极狐GitLab 18.0 [GA]。功能标志 `limit_unique_project_downloads_per_namespace_user` 已移除。
- `web_based_commit_signing_enabled` 在极狐GitLab 18.2 [引入]，[附带一个功能标志](../administration/feature_flags/_index.md) 名为 `use_web_based_commit_signing_enabled`。默认禁用。
- `allow_personal_snippets` 在极狐GitLab 18.5 [引入]，[附带一个功能标志](../administration/feature_flags/_index.md) 名为 `allow_personal_snippets_setting`。默认禁用。
- `allow_personal_snippets` 在极狐GitLab 18.9 [GA]。功能标志 `allow_personal_snippets_setting` 已移除。

{{< /history >}}

> [!flag]
> `web_based_commit_signing_enabled` 属性的可用性由功能标志控制。
> 更多信息，请参见历史记录。
> 此功能可用于测试，但尚未准备好用于生产环境。

更新指定群组的属性。

先决条件：

- 您必须是管理员或拥有该群组的所有者角色。

```plaintext
PUT /groups/:id
```

| 属性                                                  | 类型              | 是否必需 | 描述 |
|------------------------------------------------------|-------------------|----------|-------------|
| `id`                                                 | integer           | 是      | 群组的 ID。 |
| `name`                                               | string            | 否       | 群组的名称。 |
| `path`                                               | string            | 否       | 群组的路径。 |
| `auto_devops_enabled`                                | boolean           | 否       | 为此群组内的所有项目默认启用 Auto DevOps 流水线。 |
| `avatar`                                             | mixed             | 否       | 群组头像的图片文件。 |
| `default_branch`                                     | string            | 否       | 群组项目的[默认分支](../user/project/repository/branches/default.md)名称。[引入] 于极狐GitLab 16.11。 |
| `default_branch_protection`                          | integer           | 否       | 在极狐GitLab 17.0 [弃用](https://gitlab.com/gitlab-org/gitlab/-/issues/408314)。请改用 `default_branch_protection_defaults`。 |
| `default_branch_protection_defaults`                 | hash              | 否       | [引入] 于极狐GitLab 17.0。有关可用选项，请参见[`default_branch_protection_defaults` 的选项](#options-for-default_branch_protection_defaults)。 |
| `description`                                        | string            | 否       | 群组的描述。 |
| `enabled_git_access_protocol`                        | string            | 否       | 启用的 Git 访问协议。允许的值为：`ssh`、`http` 和 `all`（允许两种协议）。[引入] 于极狐GitLab 16.9。 |
| `emails_disabled`                                    | boolean           | 否       | （在极狐GitLab 16.5 [弃用](https://gitlab.com/gitlab-org/gitlab/-/merge_requests/127899)。）禁用邮件通知。请改用 `emails_enabled`。 |
| `emails_enabled`                                     | boolean           | 否       | 启用邮件通知。 |
| `lfs_enabled`                                        | boolean           | 否       | 为此群组中的项目启用/禁用大文件存储（LFS）。 |
| `mentions_disabled`                                  | boolean           | 否       | 禁止群组被提及。 |
| `prevent_sharing_groups_outside_hierarchy`           | boolean           | 否       | 参见[防止在群组层次结构之外共享群组](../user/project/members/sharing_projects_groups.md#prevent-inviting-groups-outside-the-group-hierarchy)。此属性仅适用于顶级群组。 |
| `project_creation_level`                             | string            | 否       | 决定开发者是否可以在群组中创建项目。可以是 `noone`（无人）、`maintainer`（具有维护者角色的用户）或 `developer`（具有开发者或维护者角色的用户）。 |
| `request_access_enabled`                             | boolean           | 否       | 允许用户请求成员访问权限。 |
| `require_two_factor_authentication`                  | boolean           | 否       | 要求此群组中的所有用户设置双重身份验证。 |
| `shared_runners_setting`                             | string            | 否       | 参见[`shared_runners_setting` 的选项](#options-for-shared_runners_setting)。为群组的子群组和项目启用或禁用实例 runner。 |
| `share_with_group_lock`                              | boolean           | 否       | 防止与此群组内的另一个群组共享项目。 |
| `step_up_auth_required_oauth_provider`               | string            | 否       | 逐步身份验证所需的 OAuth 提供者。传递空字符串以禁用。[引入] 于极狐GitLab 18.4。当 `omniauth_step_up_auth_for_namespace` 功能标志启用时可用。 |
| `subgroup_creation_level`                            | string            | 否       | 允许[创建子群组](../user/group/subgroups/_index.md#create-a-subgroup)。可以是 `owner`（具有所有者角色的用户）或 `maintainer`（具有维护者角色的用户）。 |
| `two_factor_grace_period`                            | integer           | 否       | 强制执行双重身份验证前的宽限期（以小时为单位）。 |
| `visibility`                                         | string            | 否       | 群组的可见性级别。可以是 `private`、`internal` 或 `public`。 |
| `extra_shared_runners_minutes_limit`                 | integer           | 否       | 只能由管理员设置。此群组的额外计算分钟数。仅限极狐GitLab 私有化部署专业版和旗舰版。 |
| `file_template_project_id`                           | integer           | 否       | 从中加载自定义文件模板的项目的 ID。仅限专业版和旗舰版。 |
| `membership_lock`                                    | boolean           | 否       | 用户无法被添加到此群组中的项目。仅限专业版和旗舰版。 |
| `prevent_forking_outside_group`                      | boolean           | 否       | 启用后，用户无法将此群组的项目 fork 到外部命名空间。仅限专业版和旗舰版。 |
| `shared_runners_minutes_limit`                       | integer           | 否       | 只能由管理员设置。此群组每月计算分钟数的最大值。可以是 `nil`（默认；继承系统默认值）、`0`（无限制）或 `> 0`。仅限极狐GitLab 私有化部署专业版和旗舰版。 |
| `unique_project_download_limit`                      | integer           | 否       | 用户在指定时间段内可下载的唯一项目的最大数量，超过后将被禁止。仅适用于顶级群组。默认值：0，最大值：10,000。仅限旗舰版。 |
| `unique_project_download_limit_interval_in_seconds`  | integer           | 否       | 用户在被禁止之前可下载最大数量项目的时间段。仅适用于顶级群组。默认值：0，最大值：864,000 秒（10 天）。仅限旗舰版。 |
| `unique_project_download_limit_allowlist`            | array of strings  | 否       | 从唯一项目下载限制中排除的用户名列表。仅适用于顶级群组。默认值：`[]`，最大值：100 个用户名。仅限旗舰版。 |
| `unique_project_download_limit_alertlist`            | array of integers | 否       | 当超过唯一项目下载限制时，将通过电子邮件通知的用户 ID 列表。仅适用于顶级群组。默认值：`[]`，最大值：100 个用户 ID。仅限旗舰版。 |
| `auto_ban_user_on_excessive_projects_download`       | boolean           | 否       | 启用后，当用户下载的唯一项目数量超过 `unique_project_download_limit` 和 `unique_project_download_limit_interval_in_seconds` 指定的最大值时，该用户将被自动禁止。仅限旗舰版。 |
| `ip_restriction_ranges`                              | string      | 否       | 逗号分隔的 IP 地址或子网掩码列表，用于限制群组访问。仅限专业版和旗舰版。 |
| `allowed_email_domains_list`                         | string      | 否       | 逗号分隔的电子邮件地址域名列表，用于允许群组访问。[引入] 于 17.4。仅限极狐GitLab 专业版和旗舰版。 |
| `wiki_access_level`                                  | string            | 否       | Wiki 访问级别。可以是 `disabled`、`private` 或 `enabled`。仅限专业版和旗舰版。 |
| `duo_availability`                                   | string | 否 | 极狐GitLab Duo 可用性设置。有效值为：`default_on`、`default_off`、`never_on`。注意：在 UI 中，`never_on` 显示为“始终关闭”。 |
| `experiment_features_enabled`                        | boolean | 否 | 为此群组启用实验功能。 |
| `math_rendering_limits_enabled`                      | boolean           | 否       | 指示是否对此群组使用数学渲染限制。 |
| `lock_math_rendering_limits_enabled`                 | boolean           | 否       | 指示是否对所有后代群组锁定数学渲染限制。 |
| `duo_features_enabled`                               | boolean           | 否       | 指示是否为此群组启用极狐GitLab Duo 功能。[引入] 于极狐GitLab 16.10。仅限极狐GitLab 私有化部署专业版和旗舰版。 |
| `lock_duo_features_enabled`                          | boolean           | 否       | 指示是否对所有子群组强制执行极狐GitLab Duo 功能启用设置。[引入] 于极狐GitLab 16.10。仅限极狐GitLab 私有化部署专业版和旗舰版。 |
| `max_artifacts_size`                                 | integer           | 否       | 单个作业产物的最大文件大小（以兆字节为单位）。 |
| `web_based_commit_signing_enabled`                  | boolean           | 否       | 为从极狐GitLab UI 创建的提交启用基于 Web 的提交签名。仅适用于 JihuLab.com 上的顶级群组。为群组启用后，将应用于群组中的所有项目。 |
| `only_allow_merge_if_pipeline_succeeds`             | boolean           | 否       | 仅当流水线成功时才允许合并合并请求。为群组启用后，将应用于群组中的所有项目。仅限专业版和旗舰版。 |
| `allow_merge_on_skipped_pipeline`                   | boolean           | 否       | 当流水线被跳过时允许合并合并请求。仅在 `only_allow_merge_if_pipeline_succeeds` 为 `true` 时适用。仅限专业版和旗舰版。 |
| `only_allow_merge_if_all_discussions_are_resolved`  | boolean           | 否       | 仅当所有讨论都已解决时才允许合并合并请求。为群组启用后，将应用于群组中的所有项目。仅限专业版和旗舰版。 |
| `allow_personal_snippets`                           | boolean           | 否       | 允许此群组中的企业用户创建个人代码片段。禁用后，企业用户将无法在其个人命名空间中创建代码片段。 |

> [!note]
> 响应中的 `projects` 和 `shared_projects` 属性已弃用，并[计划在 API v5 中移除](https://gitlab.com/gitlab-org/gitlab/-/issues/213797)。
> 要获取群组内所有项目的详细信息，请使用[列出群组的项目](#list-projects)或[列出群组的共享项目](#list-shared-projects)端点。

```shell
curl --request PUT \
  --header "PRIVATE-TOKEN: <your_access_token>" \
  --url "https://gitlab.example.com/api/v4/groups/5?name=Experimental"
```

此端点最多返回 100 个项目和共享项目。要获取群组中所有项目的详细信息，请改用[列出群组的项目端点](#list-projects)。

示例响应：

```json
{
  "id": 5,
  "name": "Experimental",
  "path": "h5bp",
  "description": "foo",
  "visibility": "internal",
  "avatar_url": null,
  "web_url": "http://gitlab.example.com/groups/h5bp",
  "request_access_enabled": false,
  "repository_storage": "default",
  "full_name": "Foobar Group",
  "full_path": "h5bp",
  "file_template_project_id": 1,
  "parent_id": null,
  "enabled_git_access_protocol": "all",
  "created_at": "2020-01-15T12:36:29.590Z",
  "prevent_sharing_groups_outside_hierarchy": false,
  "only_allow_merge_if_pipeline_succeeds": false,
  "allow_merge_on_skipped_pipeline": false,
  "only_allow_merge_if_all_discussions_are_resolved": false,
  "allow_personal_snippets": true,
  "projects": [ // 已弃用，将在 API v5 中移除
    {
      "id": 9,
      "description": "foo",
      "default_branch": "main",
      "tag_list": [], // 已弃用，请使用 `topics`
      "topics": [],
      "public": false,
      "archived": false,
      "visibility": "internal",
      "ssh_url_to_repo": "git@gitlab.example.com/html5-boilerplate.git",
      "http_url_to_repo": "http://gitlab.example.com/h5bp/html5-boilerplate.git",
      "web_url": "http://gitlab.example.com/h5bp/html5-boilerplate",
      "name": "Html5 Boilerplate",
      "name_with_namespace": "Experimental / Html5 Boilerplate",
      "path": "html5-boilerplate",
      "path_with_namespace": "h5bp/html5-boilerplate",
      "issues_enabled": true,
      "merge_requests_enabled": true,
      "wiki_enabled": true,
      "jobs_enabled": true,
      "snippets_enabled": true,
      "created_at": "2016-04-05T21:40:50.169Z",
      "last_activity_at": "2016-04-06T16:52:08.432Z",
      "shared_runners_enabled": true,
      "creator_id": 1,
      "namespace": {
        "id": 5,
        "name": "Experimental",
        "path": "h5bp",
        "kind": "group"
      },
      "avatar_url": null,
      "star_count": 1,
      "forks_count": 0,
      "open_issues_count": 3,
      "public_jobs": true,
      "shared_with_groups": [],
      "request_access_enabled": false
    }
  ],
  "ip_restriction_ranges": null,
  "math_rendering_limits_enabled": true,
  "lock_math_rendering_limits_enabled": false
}
```

`prevent_sharing_groups_outside_hierarchy` 属性仅在顶级群组的响应中存在。

[极狐GitLab 专业版或旗舰版](https://gitlab.cn/pricing/) 的用户还会看到 `wiki_access_level`、`duo_features_enabled`、`lock_duo_features_enabled`、`duo_availability` 和 `experiment_features_enabled` 属性。

### `shared_runners_setting` 的选项

`shared_runners_setting` 属性决定是否为群组的子群组和项目启用实例 runner。

| 值                            | 描述 |
|------------------------------|-------------|
| `enabled`                    | 为此群组中的所有项目和子群组启用实例 runner。 |
| `disabled_and_overridable`   | 为此群组中的所有项目和子群组禁用实例 runner，但允许子群组覆盖此设置。 |
| `disabled_and_unoverridable` | 为此群组中的所有项目和子群组禁用实例 runner，并阻止子群组覆盖此设置。 |
| `disabled_with_override`     | （已弃用。请使用 `disabled_and_overridable`）为此群组中的所有项目和子群组禁用实例 runner，但允许子群组覆盖此设置。 |

## 更新群组头像

更新群组头像。

### 下载群组头像

获取群组头像。如果群组是公开可访问的，则无需身份验证即可访问此端点。

```plaintext
GET /groups/:id/avatar
```

| 属性 | 类型           | 是否必需 | 描述 |
|-----------|----------------|----------|-------------|
| `id`      | integer 或 string | 是      | 群组的 ID。 |

示例：

```shell
curl --header "PRIVATE-TOKEN: $GITLAB_LOCAL_TOKEN" \
  --remote-header-name \
  --remote-name \
  --url "https://gitlab.example.com/api/v4/groups/4/avatar"
```

### 上传群组头像

要从文件系统上传头像文件，请使用 `--form` 参数。这会使 curl 使用标头 `Content-Type: multipart/form-data` 发布数据。`file=` 参数必须指向文件系统上的文件，并以 `@` 开头。例如：

```shell
curl --request PUT \
  --header "PRIVATE-TOKEN: <your_access_token>" \
  --form "avatar=@/tmp/example.png" \
  --url "https://gitlab.example.com/api/v4/groups/22"
```

### 移除群组头像

要移除群组头像，请为 `avatar` 属性使用空值。

示例请求：

```shell
curl --request PUT \
  --header "PRIVATE-TOKEN: <your_access_token>" \
  --data "avatar=" \
  --url "https://gitlab.example.com/api/v4/groups/22"
```

## 将群组与 LDAP 同步

{{< details >}}

- Tier: 专业版，旗舰版
- Offering: 私有化部署

{{< /details >}}

将指定群组与其关联的 LDAP 群组同步。

先决条件：

- 您必须是管理员或拥有该群组的所有者角色。

```plaintext
POST /groups/:id/ldap_sync
```

| 属性 | 类型                | 是否必需 | 描述                            |
| --------- | ------------------- | -------- | -------------------------------------- |
| `id`      | integer 或 string   | 是      | 群组的 ID 或 URL 编码路径。 |

## 凭据清单管理

{{< details >}}

- Tier: 专业版，旗舰版
- Offering: JihuLab.com

{{< /details >}}

{{< history >}}

- 在极狐GitLab 18.6 [引入]，[附带一个功能标志](../administration/feature_flags/_index.md) 名为 `manage_pat_by_group_owners_ready`。默认禁用。
- 在极狐GitLab 18.7 [GA]。功能标志 `manage_pat_by_group_owners_ready` 已移除。

{{< /history >}}

查看、撤销和轮换 JihuLab.com 上企业用户的凭据。

先决条件：

- 您必须拥有该群组的所有者角色。

### 列出群组的所有个人访问令牌

列出与顶级群组中的企业用户关联的所有个人访问令牌。

```plaintext
GET /groups/:id/manage/personal_access_tokens
```

| 属性          | 类型                | 是否必需 | 描述 |
| ------------------ | ------------------- | -------- | ----------- |
| `id`               | integer 或 string   | 是      | 群组的 ID 或 [URL 编码路径](rest/_index.md#namespaced-paths)。 |
| `created_after`    | datetime (ISO 8601) | 否       | 如果定义，则返回在指定时间之后创建的令牌。 |
| `created_before`   | datetime (ISO 8601) | 否       | 如果定义，则返回在指定时间之前创建的令牌。 |
| `last_used_after`  | datetime (ISO 8601) | 否       | 如果定义，则返回在指定时间之后最后使用的令牌。 |
| `last_used_before` | datetime (ISO 8601) | 否       | 如果定义，则返回在指定时间之前最后使用的令牌。 |
| `revoked`          | boolean             | 否       | 如果为 `true`，则仅返回已撤销的令牌。 |
| `search`           | string              | 否       | 如果定义，则返回名称中包含指定值的令牌。 |
| `state`            | string              | 否       | 如果定义，则返回具有指定状态的令牌。可能的值：`active` 和 `inactive`。 |
| `sort`             | string              | 否       | 如果定义，则按指定值对结果进行排序。可能的值：`created_asc`、`created_desc`、`expires_asc`、`expires_desc`、`last_used_asc`、`last_used_desc`、`name_asc`、`name_desc`。 |

示例请求：

```shell
curl --header "PRIVATE-TOKEN: <group_owner_token>" \
  --url "https://gitlab.example.com/api/v4/groups/1/manage/personal_access_tokens"
```

示例响应：

```json
[
  {
    "id": 1,
    "name": "Test Token",
    "revoked": false,
    "created_at": "2020-07-23T14:31:47.729Z",
    "description": "Test Token description",
    "scopes": [
        "api"
    ],
    "user_id": 3,
    "last_used_at": "2021-10-06T17:58:37.550Z",
    "active": true,
    "expires_at": "2025-11-08"
  }
]
```

### 列出群组的所有群组和项目访问令牌

列出与顶级群组关联的所有群组和项目访问令牌。

```plaintext
GET /groups/:id/manage/resource_access_tokens
```

| 属性          | 类型                | 是否必需 | 描述 |
| ------------------ | ------------------- | -------- | ----------- |
| `id`               | integer 或 string   | 是      | 群组的 ID 或 [URL 编码路径](rest/_index.md#namespaced-paths)。 |
| `created_after`    | datetime (ISO 8601) | 否       | 如果定义，则返回在指定时间之后创建的令牌。 |
| `created_before`   | datetime (ISO 8601) | 否       | 如果定义，则返回在指定时间之前创建的令牌。 |
| `last_used_after`  | datetime (ISO 8601) | 否       | 如果定义，则返回在指定时间之后最后使用的令牌。 |
| `last_used_before` | datetime (ISO 8601) | 否       | 如果定义，则返回在指定时间之前最后使用的令牌。 |
| `revoked`          | boolean             | 否       | 如果为 `true`，则仅返回已撤销的令牌。 |
| `search`           | string              | 否       | 如果定义，则返回名称中包含指定值的令牌。 |
| `state`            | string              | 否       | 如果定义，则返回具有指定状态的令牌。可能的值：`active` 和 `inactive`。 |
| `sort`             | string              | 否       | 如果定义，则按指定值对结果进行排序。可能的值：`created_asc`、`created_desc`、`expires_asc`、`expires_desc`、`last_used_asc`、`last_used_desc`、`name_asc`、`name_desc`。 |

示例请求：

```shell
curl --header "PRIVATE-TOKEN: <group_owner_token>" \
  --url "https://gitlab.example.com/api/v4/groups/1/manage/resource_access_tokens"
```

示例响应：

```json
[
  {
    "id": 12767703,
    "name": "Test Group Token",
    "revoked": false,
    "created_at": "2025-01-07T00:25:02.128Z",
    "description": "",
    "scopes": [
        "read_registry"
    ],
    "user_id": 25365147,
    "last_used_at": null,
    "active": true,
    "expires_at": "2025-06-19",
    "access_level": 10,
    "resource_type": "group",
    "resource_id": 77449520
  }
]
```

### 列出群组的所有 SSH 密钥

列出与顶级群组中的企业用户关联的所有 SSH 公钥。

```plaintext
GET /groups/:id/manage/ssh_keys
```

| 属性        | 类型                | 是否必需 | 描述 |
| ---------------- | ------------------- | -------- | ----------- |
| `id`             | integer 或 string   | 是      | 群组的 ID 或 [URL 编码路径](rest/_index.md#namespaced-paths)。 |
| `created_after`  | datetime (ISO 8601) | 否       | 如果定义，则返回在指定时间之后创建的 SSH 密钥。 |
| `created_before` | datetime (ISO 8601) | 否       | 如果定义，则返回在指定时间之前创建的 SSH 密钥。 |
| `expires_before` | datetime (ISO 8601) | 否       | 如果定义，则返回在指定时间之前过期的 SSH 密钥。 |
| `expires_after`  | datetime (ISO 8601) | 否       | 如果定义，则返回在指定时间之后过期的 SSH 密钥。 |

```shell
curl --header "PRIVATE-TOKEN: <group_owner_token>" \
  --url "https://gitlab.example.com/api/v4/groups/1/manage/ssh_keys"
```

示例响应：

```json
[
  {
    "id":3,
    "title":"Sample key 3",
    "created_at":"2024-12-23T05:40:11.891Z",
    "expires_at":null,
    "last_used_at":"2024-12-23T05:40:11.891Z",
    "usage_type":"auth_and_signing",
    "user_id":3
  }
]
```

### 撤销企业用户的个人访问令牌

撤销企业用户的指定个人访问令牌。

```plaintext
DELETE groups/:id/manage/personal_access_tokens/:id
```

| 属性 | 类型    | 是否必需 | 描述         |
|-----------|---------|----------|---------------------|
| `id` | integer 或 string | 是 | 个人访问令牌的 ID 或关键字 `self`。 |

```shell
curl --request DELETE \
  --header "PRIVATE-TOKEN: <your_access_token>" \
  --url "https://gitlab.example.com/api/v4/groups/1/manage/personal_access_tokens/<personal_access_token_id>"
```

如果成功，返回 `204: No Content`。

其他可能的响应：
- `400: Bad Request`：未成功撤销时返回。
- `401: Unauthorized`：访问令牌无效时返回。
- `403: Forbidden`：访问令牌不具备所需权限时返回。

### 撤销企业用户的群组或项目访问令牌

撤销与顶级群组关联的企业用户的指定群组或项目访问令牌。

```plaintext
DELETE groups/:id/manage/resource_access_tokens/:id
```

| 属性 | 类型 | 是否必需 | 描述 |
|-----------|---------|----------|---------------------|
| `id` | integer 或 string | 是 | 资源访问令牌的 ID 或关键字 `self`。 |

```shell
curl --request DELETE \
  --header "PRIVATE-TOKEN: <your_access_token>" \
  --url "https://gitlab.example.com/api/v4/groups/1/manage/resource_access_tokens/<personal_access_token_id>"
```

如果成功，返回 `204: No Content`。

其他可能的响应：

- `400: Bad Request`：未成功撤销时返回。
- `401: Unauthorized`：访问令牌无效时返回。
- `403: Forbidden`：访问令牌不具备所需权限时返回。

### 删除企业用户的 SSH 密钥

删除与顶级群组关联的企业用户的指定 SSH 公钥。

```plaintext
DELETE /groups/:id/manage/ssh_keys/:key_id
```

支持的属性：

| 属性 | 类型 | 是否必需 | 描述 |
|:----------|:--------|:---------|:------------|
| `key_id`  | integer | 是 | 现有密钥的 ID。 |

如果成功，返回 `204: No Content`。

其他可能的响应：

- `400: Bad Request`：SSH 密钥未成功删除时返回。
- `401: Unauthorized`：SSH 密钥无效时返回。
- `403: Forbidden`：用户不具备所需权限时返回。

### 轮换企业用户的个人访问令牌

轮换与顶级群组关联的企业用户的指定个人访问令牌。此操作将撤销之前的令牌并创建一个新令牌，新令牌在一周后过期。

```plaintext
POST groups/:id/manage/personal_access_tokens/:id/rotate
```

| 属性 | 类型 | 是否必需 | 描述 |
|-----------|-----------|----------|---------------------|
| `id` | integer 或 string | 是 | 个人访问令牌的 ID 或关键字 `self`。 |
| `expires_at` | date | 否 | 访问令牌的到期日期，采用 ISO 格式 (`YYYY-MM-DD`)。该日期必须为轮换日期起一年或更短。如果未定义，令牌将在一周后过期。 |

```shell
curl --request POST \
  --header "PRIVATE-TOKEN: <your_access_token>" \
  --url "https://gitlab.example.com/api/v4/groups/:id/manage/personal_access_tokens/<personal_access_token_id>/rotate"
```

示例响应：

```json
{
    "id": 42,
    "name": "Rotated Token",
    "revoked": false,
    "created_at": "2023-08-01T15:00:00.000Z",
    "description": "Test Token 描述",
    "scopes": ["api"],
    "user_id": 1337,
    "last_used_at": null,
    "active": true,
    "expires_at": "2023-08-15",
    "token": "s3cr3t"
}
```

如果成功，返回 `200: OK`。

其他可能的响应：

- `400: Bad Request`：未成功轮换时返回。
- `401: Unauthorized`：如果以下任一条件成立则返回：
  - 令牌不存在。
  - 令牌已过期。
  - 令牌已被撤销。
  - 你没有访问指定令牌的权限。
- `403: Forbidden`：令牌不被允许轮换自身时返回。
- `404: Not Found`：用户具有所有者角色，但令牌不存在时返回。
- `405: Method Not Allowed`：令牌不是个人访问令牌时返回。

### 轮换企业用户的群组或项目访问令牌

轮换与顶级群组关联的企业用户的指定群组或项目访问令牌。此操作将撤销之前的令牌并创建一个新令牌，新令牌在一周后过期。

```plaintext
POST groups/:id/manage/resource_access_tokens/:id/rotate
```

| 属性 | 类型 | 是否必需 | 描述 |
|-----------|-----------|----------|---------------------|
| `id` | integer 或 string | 是 | 个人访问令牌的 ID 或关键字 `self`。 |
| `expires_at` | date | 否 | 访问令牌的到期日期，采用 ISO 格式 (`YYYY-MM-DD`)。该日期必须为轮换日期起一年或更短。如果未定义，令牌将在一周后过期。 |

```shell
curl --request POST \
  --header "PRIVATE-TOKEN: <your_access_token>" \
  --url "https://gitlab.example.com/api/v4/groups/:id/manage/resource_access_tokens/<resource_access_token_id>/rotate"
```

示例响应：

```json
{
    "id": 42,
    "name": "Rotated Token",
    "revoked": false,
    "created_at": "2023-08-01T15:00:00.000Z",
    "description": "Test Token 描述",
    "scopes": ["api"],
    "user_id": 1337,
    "last_used_at": null,
    "active": true,
    "expires_at": "2023-08-15",
    "token": "s3cr3t"
}
```

如果成功，返回 `200: OK`。

其他可能的响应：

- `400: Bad Request`：未成功轮换时返回。
- `401: Unauthorized`：如果以下任一条件成立则返回：
  - 令牌不存在。
  - 令牌已过期。
  - 令牌已被撤销。
  - 你没有访问指定令牌的权限。
- `403: Forbidden`：令牌不被允许轮换自身，或者令牌不是机器人用户令牌时返回。
- `404: Not Found`：用户具有所有者角色，但令牌不存在时返回。