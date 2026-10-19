---
stage: Tenant Scale
group: Organizations
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
description: 使用群组 API 管理群组、子群组和项目访问权限。
title: 群组 API
---

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: JihuLab.com，私有化部署

{{< /details >}}

使用此 API 查看和管理极狐GitLab 群组。更多信息，请参见[群组](../user/group/_index.md)。

端点响应可能会因已认证用户在群组中的[权限](../user/permissions.md)而有所不同。

<a id="retrieve-a-group"></a>

## 检索群组

检索群组的详细信息。如果群组可公开访问，则无需身份验证即可访问此端点。如果请求用户是管理员，则会返回额外信息。通过身份验证后，如果用户是管理员或具有所有者角色，则会返回群组的 `runners_token` 和 `enabled_git_access_protocol`。

```plaintext
GET /groups/:id
```

参数：

| 属性                | 类型           | 是否必需 | 描述 |
|--------------------------|----------------|----------|-------------|
| `id`                     | integer or string | 是      | 群组的 ID 或 [URL 编码路径](rest/_index.md#namespaced-paths)。 |
| `with_custom_attributes` | boolean        | 否       | 在响应中包含[自定义属性](custom_attributes.md)（仅限管理员）。 |
| `with_projects`          | boolean        | 否       | 包含属于指定群组的项目详细信息（默认为 `true`）。（已废弃，[计划在 API v5 中移除](https://gitlab.com/gitlab-org/gitlab/-/issues/213797)。要获取群组中所有项目的详细信息，请使用[列出群组项目端点](#list-projects)。） |

> [!note]
> 响应中的 `projects` 和 `shared_projects` 属性已废弃，[计划在 API v5 中移除](https://gitlab.com/gitlab-org/gitlab/-/issues/213797)。
> 要获取群组中所有项目的详细信息，请使用[列出群组项目](#list-projects)或[列出群组共享项目](#list-shared-projects)端点。

```shell
curl --request GET \
  --header "PRIVATE-TOKEN: <your_access_token>" \
  --url "https://gitlab.example.com/api/v4/groups/4"
```

此端点最多返回 100 个项目和共享项目。要获取群组中所有项目的详细信息，请改用[列出群组项目端点](#list-projects)。

示例响应：

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
  "projects": [ // Deprecated and will be removed in API v5
    {
      "id": 7,
      "description": "Voluptas veniam qui et beatae voluptas doloremque explicabo facilis.",
      "default_branch": "main",
      "tag_list": [], //deprecated, use `topics` instead
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
      "tag_list": [], //deprecated, use `topics` instead
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
  "shared_projects": [ // Deprecated and will be removed in API v5
    {
      "id": 8,
      "description": "Velit eveniet provident fugiat saepe eligendi autem.",
      "default_branch": "main",
      "tag_list": [], //deprecated, use `topics` instead
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
  "lock_math_rendering_limits_enabled": false,
  "require_sha_for_merge": false,
  "lock_require_sha_for_merge": false
}
```

`prevent_sharing_groups_outside_hierarchy` 属性仅存在于顶级群组上。

[极狐GitLab 专业版或旗舰版](https://gitlab.cn/pricing)的用户还会看到以下属性：

- `shared_runners_minutes_limit`
- `extra_shared_runners_minutes_limit`
- `marked_for_deletion_on`
- `membership_lock`
- `wiki_access_level`
- `duo_features_enabled`
- `lock_duo_features_enabled`
- `duo_availability`
- `experiment_features_enabled`

其他响应属性：

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
  "ai_settings": {
    "duo_agent_platform_enabled": true,
    "duo_workflow_mcp_enabled": false,
    "foundational_agents_default_enabled": true,
    "ai_catalog_restricted_to_group_hierarchy": false,
    "ai_usage_data_collection_enabled": false,
    "prompt_injection_protection_level": "no_checks",
    "web_search_enabled": false,
    "include_recommended_allowed": false,
    "allow_all_unix_sockets": false,
    "allow_project_extension": true,
    "minimum_access_level_execute": "developer",
    "minimum_access_level_execute_async": "developer",
    "minimum_access_level_manage": "maintainer",
    "minimum_access_level_enable_on_projects": "maintainer"
  },
  ...
}
```

`ai_settings` 对象包含群组的 AI 相关设置。有关详细信息，请参见 [`ai_settings`的响应属性](#response-attributes-for-ai_settings)。

<a id="response-attributes-for-ai_settings"></a>

### `ai_settings`的响应属性

对于可以读取该群组的用户，当群组可使用极狐GitLab Duo Agent Platform 时，响应中会包含 `ai_settings` 对象。该对象包含以下属性：

| 属性 | 类型 | 描述 |
|-----------|------|-------------|
| `ai_catalog_restricted_to_group_hierarchy` | boolean | 当为 `true` 时，AI 目录仅限于此顶级群组层级中的条目。仅限专业版和旗舰版。 |
| `ai_usage_data_collection_enabled` | boolean | 当为 `true` 时，为此群组启用 AI 使用数据收集。仅限 JihuLab.com。 |
| `allow_all_unix_sockets` | boolean | 当为 `true` 时，允许极狐GitLab Duo Agent Platform 使用所有 Unix 套接字。 |
| `allow_project_extension` | boolean | 当为 `true` 时，项目可以扩展极狐GitLab Duo Agent Platform 的网络访问域允许名单。 |
| `duo_agent_platform_enabled` | boolean | 当为 `true` 时，为此群组启用极狐GitLab Duo Agent Platform 功能。专业版和旗舰版。在 JihuLab.com 上，使用极狐GitLab Credits 的基础版也可用。 |
| `duo_workflow_mcp_enabled` | boolean | 当为 `true` 时，启用极狐GitLab Duo Agent Platform 的 MCP 支持。专业版和旗舰版。在 JihuLab.com 上，使用极狐GitLab Credits 的基础版也可用。 |
| `foundational_agents_default_enabled` | boolean | 当为 `true` 时，为此群组默认启用新的内置 Agent。专业版和旗舰版。在 JihuLab.com 上，使用极狐GitLab Credits 的基础版也可用。 |
| `include_recommended_allowed` | boolean | 当为 `true` 时，推荐的域会包含在极狐GitLab Duo Agent Platform 的网络访问允许名单中。 |
| `minimum_access_level_enable_on_projects` | string | 在项目上启用极狐GitLab Duo Agent Platform 所需的最低访问级别。取值为 `developer`、`maintainer` 或 `owner` 之一。当启用 `dap_group_customizable_permissions` 功能标志时返回。 |
| `minimum_access_level_execute` | string | 用户与极狐GitLab Duo Agent Platform 功能交互所需的最低访问级别。取值为 `guest`、`planner`、`reporter`、`developer`、`maintainer` 或 `owner` 之一。当启用 `dap_group_customizable_permissions` 功能标志时返回。 |
| `minimum_access_level_execute_async` | string | 在 CI/CD 中执行极狐GitLab Duo Agent Platform 功能所需的最低访问级别。取值为 `developer`、`maintainer` 或 `owner` 之一。当启用 `dap_group_customizable_permissions` 功能标志时返回。 |
| `minimum_access_level_manage` | string | 管理极狐GitLab Duo Agent Platform 所需的最低访问级别。取值为 `developer`、`maintainer` 或 `owner` 之一。当启用 `dap_group_customizable_permissions` 功能标志时返回。 |
| `prompt_injection_protection_level` | string | 提示注入防护级别。取值为 `no_checks`、`log_only` 或 `interrupt` 之一。 |
| `web_search_enabled` | boolean | 当为 `true` 时，为此群组在极狐GitLab Duo Chat 中启用 Web 搜索。 |

添加参数 `with_projects=false` 时，不会返回项目。

```shell
curl --request GET \
  --header "PRIVATE-TOKEN: <your_access_token>" \
  --url "https://gitlab.example.com/api/v4/groups/4?with_projects=false"
```

示例响应：

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

列出已认证用户可见的群组。在未进行身份验证的情况下访问时，仅返回公开群组。

默认情况下，此请求每次返回 20 个结果，因为 API 结果[已分页](rest/_index.md#pagination)。

在未进行身份验证的情况下访问时，此端点还支持[键集分页](rest/_index.md#keyset-based-pagination)：

- 请求连续的结果页时，应使用键集分页。
- 超过特定偏移量限制（由 [REST API 对基于偏移量的分页允许的最大偏移量](../administration/instance_limits.md#max-offset-allowed-by-the-rest-api-for-offset-based-pagination)指定）后，基于偏移量的分页不可用。

参数：

| 属性                | 类型              | 是否必需 | 描述 |
|--------------------------|-------------------|----------|-------------|
| `skip_groups`            | array of integers | 否       | 跳过传入的群组 ID。 |
| `all_available`          | boolean           | 否       | 当为 `true` 时，返回所有可访问的群组。当为 `false` 时，仅返回用户是其成员的群组。对于用户默认为 `false`，对于管理员默认为 `true`。未认证的请求始终返回所有公开群组。`owned` 和 `min_access_level` 属性优先。 |
| `search`                 | string            | 否       | 返回与搜索条件匹配的已授权群组列表。 |
| `order_by`               | string            | 否       | 按 `name`、`path`、`id` 或 `similarity` 对群组排序。默认为 `name`。 |
| `sort`                   | string            | 否       | 按 `asc` 或 `desc` 顺序对群组排序。默认为 `asc`。 |
| `statistics`             | boolean           | 否       | 包含群组统计信息（仅限管理员）。<br> 对于顶级群组，响应会返回 UI 中显示的完整 `root_storage_statistics` 数据。[引入](https://gitlab.com/gitlab-org/gitlab/-/issues/469254)于极狐GitLab 17.4。 |
| `visibility`             | string            | 否       | 限制为具有 `public`、`internal` 或 `private` 可见性的群组。 |
| `with_custom_attributes` | boolean           | 否       | 在响应中包含[自定义属性](custom_attributes.md)（仅限管理员）。 |
| `owned`                  | boolean           | 否       | 限制为当前用户明确拥有的群组。 |
| `min_access_level`       | integer           | 否       | 限制为当前用户至少具有指定访问级别的群组。可能的值：`5`（最小访问权限）、`10`（访客）、`15`（计划者）、`20`（报告者）、`25`（安全管理员）、`30`（开发者）、`40`（维护者）或 `50`（所有者）。 |
| `top_level_only`         | boolean           | 否       | 限制为顶级群组，排除所有子群组。 |
| `repository_storage`     | string            | 否       | 按群组使用的代码仓库存储进行筛选（仅限管理员）。仅限专业版和旗舰版。 |
| `marked_for_deletion_on` | date              | 否       | 按群组被标记删除的日期进行筛选。[引入](https://gitlab.com/gitlab-org/gitlab/-/issues/429315)于极狐GitLab 17.1。仅限专业版和旗舰版。 |
| `active`                 | boolean           | 否       | 限制为未归档且未标记删除的群组。 |
| `archived`               | boolean           | 否       | 限制为已归档的群组。[引入](https://gitlab.com/gitlab-org/gitlab/-/issues/519587)于极狐GitLab 18.2。 |

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

添加参数 `statistics=true` 且已认证用户是管理员时，会返回额外的群组统计信息。对于顶级群组，还会添加 `root_storage_statistics`。

```plaintext
GET /groups?statistics=true
```

使用参数 `statistics=true` 且已认证用户是管理员时，响应会包含容器镜像仓库存储大小的信息：

- `container_registry_size`：群组及其子群组中所有容器仓库使用的总存储大小（以字节为单位）。计算方式为群组项目及子群组中所有仓库大小的总和。仅在启用容器镜像仓库元数据数据库时可用。
- `container_registry_size_is_estimated`：指示该大小是基于所有仓库的实际数据精确计算得出的（`false`），还是由于性能限制而估算得出的（`true`）。

对于极狐GitLab 私有化部署实例，必须启用[容器镜像仓库元数据数据库](../administration/packages/container_registry_metadata_database.md)才能包含容器镜像仓库大小属性。

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

[极狐GitLab 专业版或旗舰版](https://gitlab.cn/pricing)的用户还会看到 `wiki_access_level`、
`duo_features_enabled`、
`lock_duo_features_enabled`、
`duo_availability` 和 `experiment_features_enabled` 属性。

您可以按名称或路径搜索群组，详见下文。

您可以使用以下方式按[自定义属性](custom_attributes.md)进行筛选：

```plaintext
GET /groups?custom_attributes[key]=value&custom_attributes[other_key]=other_value
```

<a id="group-pagination"></a>

#### 群组分页

默认情况下，每次仅显示 20 个群组，因为 API 结果已分页。

要获取更多结果（最多 100 个），请将以下内容作为参数传递给 API 调用：

```plaintext
/groups?per_page=100
```

要切换页面，请添加：

```plaintext
/groups?per_page=100&page=2
```

<a id="search-for-a-group"></a>

### 搜索群组

搜索名称或路径中匹配某个字符串的群组。

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

## 列出群组详细信息

<a id="list-projects"></a>

### 列出项目

列出群组中的项目。在未进行身份验证的情况下访问时，仅返回公开项目。

默认情况下，此请求每次返回 20 个结果，因为 API 结果[已分页](rest/_index.md#pagination)。

```plaintext
GET /groups/:id/projects
```

参数：

| 属性                     | 类型           | 是否必需 | 描述 |
|-------------------------------|----------------|----------|-------------|
| `id`                          | integer or string | 是      | 群组的 ID 或 [URL 编码路径](rest/_index.md#namespaced-paths)。 |
| `active`                      | boolean        | 否       | 按项目状态限制。当为 `true` 时，返回活跃项目。当为 `false` 时，返回已归档或标记删除的项目。[引入](https://gitlab.com/gitlab-org/gitlab/-/merge_requests/218053)于极狐GitLab 18.8。 |
| `archived`                    | boolean        | 否       | 按归档状态限制。 |
| `visibility`                  | string         | 否       | 按可见性 `public`、`internal` 或 `private` 限制。 |
| `order_by`                    | string         | 否       | 按 `id`、`name`、`path`、`created_at`、`updated_at`、`similarity`[^orders-results-similarity]、`star_count` 或 `last_activity_at` 字段返回排序后的项目。默认为 `created_at`。 |
| `sort`                        | string         | 否       | 按 `asc` 或 `desc` 顺序返回排序后的项目。默认为 `desc`。 |
| `search`                      | string         | 否       | 返回与搜索条件匹配的已授权项目列表。 |
| `simple`                      | boolean        | 否       | 仅返回每个项目的有限字段。在未认证的情况下此参数无效，此时仅返回简单字段。 |
| `owned`                       | boolean        | 否       | 按当前用户拥有的项目限制。 |
| `starred`                     | boolean        | 否       | 按当前用户加星标的项目限制。 |
| `topic`                       | string         | 否       | 返回与主题匹配的项目。 |
| `with_issues_enabled`         | boolean        | 否       | 按启用了议题功能的项目限制。默认为 `false`。 |
| `with_merge_requests_enabled` | boolean        | 否       | 按启用了合并请求功能的项目限制。默认为 `false`。 |
| `with_shared`                 | boolean        | 否       | 包含共享到此群组的项目。默认为 `true`。 |
| `include_subgroups`           | boolean        | 否       | 包含此群组子群组中的项目。默认为 `false`。 |
| `min_access_level`            | integer        | 否       | 限制为当前用户至少具有指定访问级别的项目。可能的值：`5`（最小访问权限）、`10`（访客）、`15`（计划者）、`20`（报告者）、`25`（安全管理员）、`30`（开发者）、`40`（维护者）或 `50`（所有者）。 |
| `with_custom_attributes`      | boolean        | 否       | 在响应中包含[自定义属性](custom_attributes.md)（仅限管理员）。 |
| `with_security_reports`       | boolean        | 否       | 仅返回在其任何构建中具有安全报告产物的项目。这意味着“启用了安全报告的项目”。默认为 `false`。仅限旗舰版。 |

[^orders-results-similarity]: 根据 `search` URL 参数计算得出的相似度分数对结果排序。
    当您使用 `order_by=similarity` 时，`sort` 参数会被忽略。
    当未提供 `search` 参数时，API 返回按 `name` 排序的项目。

示例响应：

```json
[
  {
    "id": 9,
    "description": "foo",
    "default_branch": "main",
    "tag_list": [], //deprecated, use `topics` instead
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
> 要区分群组中的项目与共享到群组的项目，可以使用 `namespace` 属性。当项目已共享到群组时，其 `namespace` 与请求所针对的群组不同。

<a id="list-shared-projects"></a>

### 列出共享项目

列出共享到群组的项目。在未进行身份验证的情况下访问时，仅返回公开的共享项目。

默认情况下，此请求每次返回 20 个结果，因为 API 结果[已分页](rest/_index.md#pagination)。

```plaintext
GET /groups/:id/projects/shared
```

参数：

| 属性                     | 类型           | 是否必需 | 描述 |
| ----------------------------- | -------------- | -------- | ----------- |
| `id`                          | integer or string | 是      | 群组的 ID 或 [URL 编码路径](rest/_index.md#namespaced-paths)。 |
| `archived`                    | boolean        | 否       | 按归档状态限制。 |
| `visibility`                  | string         | 否       | 按可见性 `public`、`internal` 或 `private` 限制。 |
| `order_by`                    | string         | 否       | 按 `id`、`name`、`path`、`created_at`、`updated_at`、`star_count` 或 `last_activity_at` 字段返回排序后的项目。默认为 `created_at`。 |
| `sort`                        | string         | 否       | 按 `asc` 或 `desc` 顺序返回排序后的项目。默认为 `desc`。 |
| `search`                      | string         | 否       | 返回与搜索条件匹配的已授权项目列表。 |
| `simple`                      | boolean        | 否       | 仅返回每个项目的有限字段。在未认证的情况下此参数无效，此时仅返回简单字段。 |
| `starred`                     | boolean        | 否       | 按当前用户加星标的项目限制。 |
| `with_issues_enabled`         | boolean        | 否       | 按启用了议题功能的项目限制。默认为 `false`。 |
| `with_merge_requests_enabled` | boolean        | 否       | 按启用了合并请求功能的项目限制。默认为 `false`。 |
| `min_access_level`            | integer        | 否       | 限制为当前用户至少具有指定访问级别的项目。可能的值：`5`（最小访问权限）、`10`（访客）、`15`（计划者）、`20`（报告者）、`25`（安全管理员）、`30`（开发者）、`40`（维护者）或 `50`（所有者）。 |
| `with_custom_attributes`      | boolean        | 否       | 在响应中包含[自定义属性](custom_attributes.md)（仅限管理员）。 |

示例响应：

```json
[
   {
      "id":8,
      "description":"Shared project for Html5 Boilerplate",
      "name":"Html5 Boilerplate",
      "name_with_namespace":"H5bp / Html5 Boilerplate",
      "path":"html5-boilerplate",
      "path_with_namespace":"h5bp/html5-boilerplate",
      "created_at":"2020-04-27T06:13:22.642Z",
      "default_branch":"main",
      "tag_list":[], //deprecated, use `topics` instead
      "topics":[],
      "ssh_url_to_repo":"ssh://git@gitlab.com/h5bp/html5-boilerplate.git",
      "http_url_to_repo":"https://gitlab.com/h5bp/html5-boilerplate.git",
      "web_url":"https://gitlab.com/h5bp/html5-boilerplate",
      "readme_url":"https://gitlab.com/h5bp/html5-boilerplate/-/blob/main/README.md",
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
         "web_url":"https://gitlab.com/groups/h5bp"
      },
      "_links":{
         "self":"https://gitlab.com/api/v4/projects/8",
         "issues":"https://gitlab.com/api/v4/projects/8/issues",
         "merge_requests":"https://gitlab.com/api/v4/projects/8/merge_requests",
         "repo_branches":"https://gitlab.com/api/v4/projects/8/repository/branches",
         "labels":"https://gitlab.com/api/v4/projects/8/labels",
         "events":"https://gitlab.com/api/v4/projects/8/events",
         "members":"https://gitlab.com/api/v4/projects/8/members"
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

<a id="delete-a-shared-project"></a>

### 删除共享项目

删除共享到群组的项目。需要群组的所有者角色。

```plaintext
DELETE /groups/:id/shared_projects/:project_id
```

参数：

| 属性 | 类型 | 是否必需 | 描述 |
| --------- | ---- | -------- | ----------- |
| `id` | integer or string | 是 | 群组的 ID 或 [URL 编码路径](rest/_index.md#namespaced-paths)。 |
| `project_id` | integer | 是 | 项目的 ID。 |

如果成功，返回 `204 No Content`。

```shell
curl --request DELETE \
  --header "PRIVATE-TOKEN: <your_access_token>" \
  --url "https://gitlab.example.com/api/v4/groups/1/shared_projects/2"
```

<a id="list-all-saml-users"></a>

### 列出所有 SAML 用户

{{< details >}}

- Tier: 专业版，旗舰版
- Offering: JihuLab.com，私有化部署

{{< /details >}}

列出给定顶级群组的所有 SAML 用户。

使用 `page` 和 `per_page` [分页参数](rest/_index.md#offset-based-pagination)筛选结果。

```plaintext
GET /groups/:id/saml_users
```

支持的属性：

| 属性        | 类型           | 是否必需 | 描述 |
|:-----------------|:---------------|:---------|:------------|
| `id`             | integer or string | 是      | 顶级群组的 ID 或 [URL 编码路径](rest/_index.md#namespaced-paths)。 |
| `username`       | string         | 否       | 返回具有给定用户名的用户。 |
| `search`         | string         | 否       | 返回名称、电子邮件或用户名匹配的用户。使用部分值可增加结果数量。 |
| `active`         | boolean        | 否       | 仅返回活跃用户。 |
| `blocked`        | boolean        | 否       | 仅返回已封锁用户。 |
| `created_after`  | datetime       | 否       | 返回在指定时间之后创建的用户。格式：ISO 8601（`YYYY-MM-DDTHH:MM:SSZ`）。 |
| `created_before` | datetime       | 否       | 返回在指定时间之前创建的用户。格式：ISO 8601（`YYYY-MM-DDTHH:MM:SSZ`）。 |

示例请求：

```shell
curl --request GET \
  --header "PRIVATE-TOKEN: <your_access_token>" \
  --url "https://gitlab.example.com/api/v4/groups/:id/saml_users"
```

示例响应：

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

### 列出已预配用户

{{< details >}}

- Tier: 专业版，旗舰版
- Offering: JihuLab.com，私有化部署

{{< /details >}}

列出由群组预配的用户。不包括子群组。

需要群组的维护者或所有者角色。

```plaintext
GET /groups/:id/provisioned_users
```

参数：

| 属性        | 类型           | 是否必需 | 描述 |
|:-----------------|:---------------|:---------|:------------|
| `id`             | integer or string | 是      | 群组的 ID 或 [URL 编码路径](rest/_index.md#namespaced-paths)。 |
| `username`       | string         | 否       | 返回具有特定用户名的单个用户。 |
| `search`         | string         | 否       | 按名称、电子邮件、用户名搜索用户。 |
| `active`         | boolean        | 否       | 仅返回活跃用户。 |
| `blocked`        | boolean        | 否       | 仅返回已封锁用户。 |
| `created_after`  | datetime       | 否       | 返回在指定时间之后创建的用户。 |
| `created_before` | datetime       | 否       | 返回在指定时间之前创建的用户。 |

示例响应：

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

默认情况下，此请求每次返回 20 个结果，因为 API 结果[已分页](rest/_index.md#pagination)。

如果您以以下身份请求此列表：

- 未认证用户，响应仅返回公开群组。
- 已认证用户，响应仅返回您是成员的群组，
  且不包含公开群组。

参数：

| 属性                | 类型              | 是否必需 | 描述 |
| ------------------------ | ----------------- | -------- | ----------- |
| `id`                     | integer or string    | 是      | 直接父群组的 ID 或 [URL 编码路径](rest/_index.md#namespaced-paths)。 |
| `skip_groups`            | array of integers | 否       | 跳过传入的群组 ID。 |
| `all_available`          | boolean           | 否       | 显示您有权访问的所有群组（对于已认证用户默认为 `false`，对于管理员默认为 `true`）。属性 `owned` 和 `min_access_level` 优先。 |
| `search`                 | string            | 否       | 返回与搜索条件匹配的已授权群组列表。仅搜索子群组短路径（而非完整路径）。 |
| `order_by`               | string            | 否       | 按 `name`、`path` 或 `id` 对群组排序。默认为 `name`。 |
| `sort`                   | string            | 否       | 按 `asc` 或 `desc` 顺序对群组排序。默认为 `asc`。 |
| `statistics`             | boolean           | 否       | 包含群组统计信息（仅限管理员）。 |
| `with_custom_attributes` | boolean           | 否       | 在响应中包含[自定义属性](custom_attributes.md)（仅限管理员）。 |
| `owned`                  | boolean           | 否       | 限制为当前用户明确拥有的群组。 |
| `min_access_level`       | integer           | 否       | 限制为当前用户至少具有指定访问级别的群组。可能的值：`5`（最小访问权限）、`10`（访客）、`15`（计划者）、`20`（报告者）、`25`（安全管理员）、`30`（开发者）、`40`（维护者）或 `50`（所有者）。 |
| `all_available`          | boolean           | 否       | 当为 `true` 时，返回所有可访问的群组。当为 `false` 时，仅返回用户是其成员的群组。对于用户默认为 `false`，对于管理员默认为 `true`。未认证的请求始终返回所有公开群组。`owned` 和 `min_access_level` 属性优先。 |
| `active`                 | boolean           | 否       | 限制为未归档且未标记删除的群组。 |

```plaintext
GET /groups/:id/subgroups
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

[极狐GitLab 专业版或旗舰版](https://gitlab.cn/pricing)的用户还会看到 `wiki_access_level`、
`duo_features_enabled`、
`lock_duo_features_enabled`、
`duo_availability` 和 `experiment_features_enabled` 属性。

<a id="list-descendant-groups"></a>

### 列出后代群组

列出群组中可见的后代群组。在未进行身份验证的情况下访问时，仅返回公开群组。

默认情况下，此请求每次返回 20 个结果，因为 API 结果[已分页](rest/_index.md#pagination)。

参数：

| 属性                | 类型              | 是否必需 | 描述 |
| ------------------------ | ----------------- | -------- | ----------- |
| `id`                     | integer or string    | 是      | 直接父群组的 ID 或 [URL 编码路径](rest/_index.md#namespaced-paths)。 |
| `skip_groups`            | array of integers | 否       | 跳过传入的群组 ID。 |
| `all_available`          | boolean           | 否       | 当为 `true` 时，返回所有可访问的群组。当为 `false` 时，仅返回用户是其成员的群组。对于用户默认为 `false`，对于管理员默认为 `true`。未认证的请求始终返回所有公开群组。`owned` 和 `min_access_level` 属性优先。 |
| `search`                 | string            | 否       | 返回与搜索条件匹配的已授权群组列表。仅搜索后代群组短路径（而非完整路径）。 |
| `order_by`               | string            | 否       | 按 `name`、`path` 或 `id` 对群组排序。默认为 `name`。 |
| `sort`                   | string            | 否       | 按 `asc` 或 `desc` 顺序对群组排序。默认为 `asc`。 |
| `statistics`             | boolean           | 否       | 包含群组统计信息（仅限管理员）。 |
| `with_custom_attributes` | boolean           | 否       | 在响应中包含[自定义属性](custom_attributes.md)（仅限管理员）。 |
| `owned`                  | boolean           | 否       | 限制为当前用户明确拥有的群组。 |
| `min_access_level`       | integer           | 否       | 限制为当前用户至少具有指定访问级别的群组。可能的值：`5`（最小访问权限）、`10`（访客）、`15`（计划者）、`20`（报告者）、`25`（安全管理员）、`30`（开发者）、`40`（维护者）或 `50`（所有者）。 |
| `active`                 | boolean           | 否       | 限制为未归档且未标记删除的群组。 |

```plaintext
GET /groups/:id/descendant_groups
```

```json
[
  {
    "id": 2,
    "name": "Bar Group",
    "path": "bar",
    "description": "A subgroup of Foo Group",
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
    "description": "A subgroup of Bar Group",
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

[极狐GitLab 专业版或旗舰版](https://gitlab.cn/pricing)的用户还会看到 `wiki_access_level`、
`duo_features_enabled`、
`lock_duo_features_enabled`、
`duo_availability` 和 `experiment_features_enabled` 属性。

<a id="list-shared-groups"></a>

### 列出共享群组

列出给定群组被邀请加入的群组。在未进行身份验证的情况下访问时，仅返回公开的共享群组。

默认情况下，此请求每次返回 20 个结果，因为 API 结果[已分页](rest/_index.md#pagination)。

参数：

| 属性                             | 类型              | 是否必需 | 描述 |
| ------------------------------------- | ----------------- | -------- | ---------- |
| `id`                                  | integer or string    | 是      | 群组的 ID 或 [URL 编码路径](rest/_index.md#namespaced-paths)。 |
| `skip_groups`                         | array of integers | 否       | 跳过指定的群组 ID。 |
| `search`                              | string            | 否       | 返回与搜索条件匹配的已授权群组列表。 |
| `order_by`                            | string            | 否       | 按 `name`、`path`、`id` 或 `similarity` 对群组排序。默认为 `name`。 |
| `sort`                                | string            | 否       | 按 `asc` 或 `desc` 顺序对群组排序。默认为 `asc`。 |
| `visibility`                          | string            | 否       | 限制为具有 `public`、`internal` 或 `private` 可见性的群组。 |
| `min_access_level`                    | integer           | 否       | 限制为当前用户至少具有指定访问级别的群组。可能的值：`5`（最小访问权限）、`10`（访客）、`15`（计划者）、`20`（报告者）、`25`（安全管理员）、`30`（开发者）、`40`（维护者）或 `50`（所有者）。 |
| `with_custom_attributes`              | boolean           | 否       | 在响应中包含[自定义属性](custom_attributes.md)（仅限管理员）。 |

```plaintext
GET /groups/:id/groups/shared
```

示例响应：

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

### 列出被邀请的群组

列出群组中被邀请的群组。在未进行身份验证的情况下访问时，仅返回公开的被邀请群组。此端点的速率限制为每分钟每用户（对于已认证用户）或每 IP（对于未认证用户）60 个请求。

默认情况下，此请求每次返回 20 个结果，因为 API 结果[已分页](rest/_index.md#pagination)。

参数：

| 属性                             | 类型              | 是否必需 | 描述 |
| ------------------------------------- | ----------------- | -------- | ---------- |
| `id`                                  | integer or string    | 是      | 群组的 ID 或 [URL 编码路径](rest/_index.md#namespaced-paths)。 |
| `search`                              | string            | 否       | 返回与搜索条件匹配的已授权群组列表。 |
| `min_access_level`                    | integer           | 否       | 限制为当前用户至少具有指定访问级别的群组。可能的值：`5`（最小访问权限）、`10`（访客）、`15`（计划者）、`20`（报告者）、`25`（安全管理员）、`30`（开发者）、`40`（维护者）或 `50`（所有者）。 |
| `relation`                            | array of strings  | 否       | 按关系（直接或继承）筛选群组。 |
| `with_custom_attributes`              | boolean           | 否       | 在响应中包含[自定义属性](custom_attributes.md)（仅限管理员）。 |

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

- Tier: 专业版，旗舰版
- Offering: JihuLab.com，私有化部署

{{< /details >}}

群组审计事件可通过[群组审计事件 API](audit_events.md#group-audit-events) 访问

<a id="manage-groups"></a>

## 管理群组

<a id="create-a-group"></a>

### 创建群组

> [!note]
> 在 JihuLab.com 上，您必须使用极狐GitLab UI 创建没有父群组的群组。您不能
> 使用 API 来执行此操作。

创建一个新的项目群组。仅适用于可以创建群组的用户。

```plaintext
POST /groups
```

参数：

| 属性                            | 类型    | 必需 | 描述 |
|--------------------------------------|---------|----------|-------------|
| `name`                               | string  | 是      | 群组的名称。 |
| `path`                               | string  | 是      | 群组的路径。 |
| `auto_devops_enabled`                | boolean | 否       | 为此群组内的所有项目默认使用 Auto DevOps 流水线。 |
| `avatar`                             | mixed   | 否       | 群组头像的图片文件。 |
| `default_branch`                     | string  | 否       | 群组项目的[默认分支](../user/project/repository/branches/default.md)名称。 |
| `default_branch_protection`          | integer | 否       | 在极狐GitLab 17.0 中[已弃用](https://gitlab.com/gitlab-org/gitlab/-/issues/408314)。请改用 `default_branch_protection_defaults`。 |
| `default_branch_protection_defaults` | hash    | 否       | 在极狐GitLab 17.0 中引入。有关可用选项，请参见 [`default_branch_protection_defaults`的选项](#options-for-default_branch_protection_defaults)。 |
| `description`                        | string  | 否       | 群组的描述。 |
| `enabled_git_access_protocol`        | string  | 否       | 为 Git 访问启用的协议。允许的值为：`ssh`、`http` 和 `all`（允许两种协议）。 |
| `emails_disabled`                    | boolean | 否       | （在极狐GitLab 16.5 中[已弃用](https://gitlab.com/gitlab-org/gitlab/-/merge_requests/127899)。）禁用电子邮件通知。请改用 `emails_enabled`。 |
| `emails_enabled`                     | boolean | 否       | 启用电子邮件通知。 |
| `lfs_enabled`                        | boolean | 否       | 为此群组中的项目启用/禁用大文件存储（LFS）。 |
| `mentions_disabled`                  | boolean | 否       | 禁用群组被提及的功能。 |
| `organization_id`                    | integer | 否       | 群组的组织 ID。 |
| `parent_id`                          | integer | 否       | 用于创建嵌套群组的父群组 ID。 |
| `project_creation_level`             | string  | 否       | 确定开发者是否可以在群组中创建项目。可以是 `administrator`（启用了管理员模式的用户）、`noone`（无人）、`maintainer`（具有维护者角色的用户）或 `developer`（具有开发者或维护者角色的用户）。 |
| `request_access_enabled`             | boolean | 否       | 允许用户请求成员访问权限。 |
| `require_two_factor_authentication`  | boolean | 否       | 要求此群组中的所有用户设置双因素认证。 |
| `share_with_group_lock`              | boolean | 否       | 阻止与此群组内的另一个群组共享项目。 |
| `subgroup_creation_level`            | string  | 否       | 允许[创建子群组](../user/group/subgroups/_index.md#create-a-subgroup)。可以是 `owner`（具有所有者角色的用户）或 `maintainer`（具有维护者角色的用户）。 |
| `two_factor_grace_period`            | integer | 否       | 强制执行双因素认证之前的时间（以小时为单位）。 |
| `visibility`                         | string  | 否       | 群组的可见性。可以是 `private`、`internal` 或 `public`。 |
| `membership_lock`                    | boolean | 否       | 用户无法添加到此群组中的项目。仅专业版和旗舰版。 |
| `extra_shared_runners_minutes_limit` | integer | 否       | 只能由管理员设置。此群组的额外计算分钟。仅极狐GitLab 私有化部署、专业版和旗舰版。 |
| `shared_runners_minutes_limit`       | integer | 否       | 只能由管理员设置。此群组每月的最大计算分钟数。可以是 `nil`（默认；继承系统默认值）、`0`（无限制）或 `> 0`。仅极狐GitLab 私有化部署、专业版和旗舰版。 |
| `wiki_access_level`                  | string  | 否       | Wiki 访问级别。可以是 `disabled`、`private` 或 `enabled`。仅专业版和旗舰版。 |
| `duo_availability` | string | 否 | 极狐GitLab Duo 可用性设置。有效值为：`default_on`、`default_off`、`never_on`。注意：在 UI 中，`never_on` 显示为 "Always Off"。 |
| `experiment_features_enabled` | boolean | 否 | 为此群组启用实验功能。 |
| `ai_settings_attributes` | hash | 否 | 此群组的 AI 相关设置。有关可用选项，请参见 [`ai_settings_attributes`的选项](#options-for-ai_settings_attributes)。必须启用极狐GitLab Duo 功能。 |

<a id="options-for-default_branch_protection"></a>

#### `default_branch_protection`的选项

`default_branch_protection` 属性决定具有开发者或维护者角色的用户是否可以推送到适用的[默认分支](../user/project/repository/branches/default.md)，如下表所述：

| 值 | 描述 |
|-------|-------------|
| `0`   | 无保护。具有开发者或维护者角色的用户可以： <br>- 推送新提交。<br>- 强制推送更改。<br>- 删除分支。 |
| `1`   | 部分保护。具有开发者或维护者角色的用户可以： <br>- 推送新提交。 |
| `2`   | 完全保护。只有具有维护者角色的用户可以： <br>- 推送新提交。 |
| `3`   | 防止推送。具有维护者角色的用户可以： <br>- 推送新提交。<br>- 强制推送更改。<br>- 接受合并请求。<br>具有开发者角色的用户可以：<br>- 接受合并请求。 |
| `4`   | 初始推送后完全保护。具有开发者角色的用户可以： <br>- 推送到空代码仓库。<br> 具有维护者角色的用户可以： <br>- 推送新提交。<br>- 接受合并请求。 |

<a id="options-for-default_branch_protection_defaults"></a>

#### `default_branch_protection_defaults`的选项

`default_branch_protection_defaults` 属性描述默认分支保护默认值。所有参数均为可选。

| 键                            | 类型    | 描述 |
|:-------------------------------|:--------|:------------|
| `allowed_to_push`              | array   | 允许推送的访问级别数组。支持开发者（30）或维护者（40）。 |
| `allow_force_push`             | boolean | 允许所有具有推送访问权限的用户强制推送。 |
| `allowed_to_merge`             | array   | 允许合并的访问级别数组。支持开发者（30）或维护者（40）。 |
| `developer_can_initial_push`   | boolean | 允许开发者进行初始推送。 |
| `code_owner_approval_required` | boolean | 要求代码所有者审批。 |

<a id="create-a-subgroup"></a>

### 创建子群组

这与创建[新群组](#create-a-group)类似。您需要从[列出群组](#list-groups)调用中获取 `parent_id`。然后您可以输入所需的：

- `subgroup_path`
- `subgroup_name`

```shell
curl --request POST \
  --header "PRIVATE-TOKEN: <your_access_token>" \
  --header "Content-Type: application/json" \
  --data '{"path": "<subgroup_path>", "name": "<subgroup_name>", "parent_id": <parent_group_id> }' \
  --url "https://gitlab.example.com/api/v4/groups/"
```

<a id="schedule-a-group-for-deletion"></a>

### 计划删除群组

计划删除群组。群组将在保留期结束时删除：

- 在 JihuLab.com 上，群组保留 30 天。
- 在极狐GitLab 私有化部署上，保留期由
  [实例设置](../administration/settings/visibility_and_access_controls.md#deletion-protection)控制。

此端点还可以立即删除之前已计划删除的子群组。

先决条件：

- 您必须是管理员，或拥有该群组的所有者角色。

```plaintext
DELETE /groups/:id
```

| 属性            | 类型              | 必需 | 描述 |
|----------------------|-------------------|----------|-------------|
| `id`                 | integer or string | 是      | 群组的 ID 或 [URL 编码路径](rest/_index.md#namespaced-paths)。 |
| `full_path`          | string            | 有条件       | 子群组的完整路径。用于确认删除子群组。如果 `permanently_remove` 为 `true`，则此属性为必需。要查找子群组路径，请参见[群组详情](#retrieve-a-group)。 |
| `permanently_remove` | boolean/string    | 否       | 如果为 `true`，则立即删除已计划删除的子群组。无法删除顶级群组。 |

如果成功，返回 [`202 Accepted`](rest/troubleshooting.md#status-codes) 状态码。

示例请求：

```shell
curl --request DELETE \
  --header "PRIVATE-TOKEN: <your_access_token>" \
  --header "Accept: application/json" \
  --url "https://gitlab.example.com/api/v4/groups/:id"
```

> [!note]
> 您无法删除与订阅关联的 JihuLab.com 群组。您必须先将[订阅关联](../subscriptions/manage_subscription.md#link-subscription-to-a-group)到其他群组。

<a id="delete-a-group-permanently"></a>

#### 永久删除群组

绕过配置的保留期，永久删除群组及其数据。

先决条件：

- 您必须是管理员，或拥有该群组的所有者角色。

```plaintext
DELETE /groups/:id
```

| 属性            | 类型              | 必需 | 描述 |
|----------------------|-------------------|----------|-------------|
| `id`                 | integer or string | 是      | 群组的 ID 或 [URL 编码路径](rest/_index.md#namespaced-paths)。 |
| `full_path`          | string            | 是       | 子群组在计划删除后的修改后完整路径。如果 `permanently_remove` 为 `true`，则此属性为必需。要确认修改后的完整路径，请[检索群组](#retrieve-a-group)。 |
| `permanently_remove` | boolean/string    | 是       | 如果为 `true`，则永久删除已计划删除的子群组。无法删除顶级群组。 |

如果成功，返回 [`202 Accepted`](rest/troubleshooting.md#status-codes) 状态码。

要永久删除已计划删除的群组，您必须：

1. 通过 API 调用计划删除该群组。
1. 在第二次 API 调用中，删除该群组。

例如：

```shell
# Schedule a group for deletion
curl --request DELETE \
  --header "PRIVATE-TOKEN: <your_access_token>" \
  --header "Accept: application/json" \
  --url "https://gitlab.example.com/api/v4/groups/:id"

# Permanently delete a group scheduled for deletion
# Use the modified full_path of the subgroup
curl --request DELETE \
  --header "PRIVATE-TOKEN: <your_access_token>" \
  --header "Accept: application/json" \
  --header "Content-Type: application/json" \
  --data '{"full_path": "<path-after-soft-delete>", "permanently_remove": "true"}' \
  --url "https://gitlab.example.com/api/v4/groups/:id"
```

<a id="restore-a-group-marked-for-deletion"></a>

#### 恢复标记为删除的群组

恢复之前标记为删除的群组。

```plaintext
POST /groups/:id/restore
```

参数：

| 属性 | 类型           | 必需 | 描述 |
|-----------|----------------|----------|-------------|
| `id`      | integer or string | 是      | 群组的 ID 或 [URL 编码路径](rest/_index.md#namespaced-paths)。 |

<a id="archive-a-group"></a>

### 归档群组

归档群组。

先决条件：

- 您必须是管理员，或拥有该群组的所有者角色。

如果群组已归档，此端点返回 `422` 无法处理的实体错误。

```plaintext
POST /groups/:id/archive
```

参数：

| 属性 | 类型              | 必需 | 描述 |
|-----------|-------------------|----------|-------------|
| `id`      | integer or string | 是      | 经过身份验证的用户所拥有的群组的 ID 或 [URL 编码路径](rest/_index.md#namespaced-paths)。 |

示例响应：

```json
{
  "id": 96,
  "web_url": "https://gitlab.example.com/groups/test-1",
  "name": "test-1",
  "path": "test-1",
  "description": "",
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
  "archived": true,
  "math_rendering_limits_enabled": true,
  "lock_math_rendering_limits_enabled": false,
  "require_sha_for_merge": false,
  "lock_require_sha_for_merge": false,
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
  "full_name": "test-1",
  "full_path": "test-1",
  "created_at": "2025-03-25T12:05:24.813Z",
  "parent_id": null,
  "organization_id": 1,
  "shared_runners_setting": "enabled",
  "max_artifacts_size": null,
  "ldap_cn": null,
  "ldap_access": null,
  "wiki_access_level": "enabled",
  "shared_with_groups": [],
  "prevent_sharing_groups_outside_hierarchy": false,
  "shared_runners_minutes_limit": null,
  "extra_shared_runners_minutes_limit": null,
  "prevent_forking_outside_group": null,
  "membership_lock": false
}
```

<a id="unarchive-a-group"></a>

#### 取消归档群组

取消归档群组。

先决条件：

- 您必须是管理员，或拥有该群组的所有者角色。

如果群组未归档，此端点返回 `422` 无法处理的实体错误。

```plaintext
POST /groups/:id/unarchive
```

参数：

| 属性 | 类型              | 必需 | 描述 |
|-----------|-------------------|----------|-------------|
| `id`      | integer or string | 是      | 经过身份验证的用户所拥有的群组的 ID 或 [URL 编码路径](rest/_index.md#namespaced-paths)。 |

示例响应：

```json
{
  "id": 96,
  "web_url": "https://gitlab.example.com/groups/test-1",
  "name": "test-1",
  "path": "test-1",
  "description": "",
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
  "archived": false,
  "math_rendering_limits_enabled": true,
  "lock_math_rendering_limits_enabled": false,
  "require_sha_for_merge": false,
  "lock_require_sha_for_merge": false,
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
  "full_name": "test-1",
  "full_path": "test-1",
  "created_at": "2025-03-25T12:05:24.813Z",
  "parent_id": null,
  "organization_id": 1,
  "shared_runners_setting": "enabled",
  "max_artifacts_size": null,
  "ldap_cn": null,
  "ldap_access": null,
  "wiki_access_level": "enabled",
  "shared_with_groups": [],
  "prevent_sharing_groups_outside_hierarchy": false,
  "shared_runners_minutes_limit": null,
  "extra_shared_runners_minutes_limit": null,
  "prevent_forking_outside_group": null,
  "membership_lock": false
}
```

<a id="transfer-a-group"></a>

### 转移群组

将群组转移到新的父群组，或将子群组转换为顶级群组。

先决条件：

- 您必须拥有该群组的所有者角色。
- 如果要转移群组，您必须有权在新父群组中[创建子群组](../user/group/subgroups/_index.md#create-a-subgroup)。
- 如果要转换子群组，您必须拥有[创建顶级群组的权限](../administration/user_settings.md)。

```plaintext
POST /groups/:id/transfer
```

参数：

| 属性  | 类型    | 必需 | 描述 |
|------------|---------|----------|-------------|
| `id`       | integer | 是      | 要转移的群组 ID。 |
| `group_id` | integer | 否       | 新父群组的 ID。如果未指定，群组将转换为顶级群组。 |

```shell
curl --request POST \
  --header "PRIVATE-TOKEN: <your_access_token>" \
  --url "https://gitlab.example.com/api/v4/groups/4/transfer?group_id=7"
```

<a id="list-all-locations-available-for-group-transfer"></a>

#### 列出可用于群组转移的所有位置

列出可用于转移指定群组的所有可用父群组。

```plaintext
GET /groups/:id/transfer_locations
```

| 属性 | 类型              | 必需 | 描述 |
|-----------|-------------------|----------|-------------|
| `id`      | integer or string | 是      | 要转移的群组的 ID 或 [URL 编码路径](rest/_index.md#namespaced-paths)。 |
| `search`  | string            | 否       | 要搜索的特定群组的名称。 |

示例请求：

```shell
curl --request GET \
    --url "https://gitlab.example.com/api/v4/groups/1/transfer_locations"
```

示例响应：

```json
[
  {
    "id": 27,
    "web_url": "https://gitlab.example.com/groups/gitlab",
    "name": "GitLab",
    "avatar_url": null,
    "full_name": "GitLab",
    "full_path": "GitLab"
  },
  {
    "id": 31,
    "web_url": "https://gitlab.example.com/groups/foobar",
    "name": "FooBar",
    "avatar_url": null,
    "full_name": "FooBar",
    "full_path": "FooBar"
  }
]
```

<a id="transfer-a-project-to-a-group"></a>

#### 将项目转移到群组

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: 私有化部署

{{< /details >}}

将项目转移到另一个群组命名空间。或者，改用[将项目转移到新命名空间](projects.md#transfer-a-project-to-a-new-namespace)端点。

> [!note]
> 如果项目的代码仓库中存在带标签的软件包，转移过程可能会失败。

先决条件：

- 您必须是该实例的管理员。

```plaintext
POST /groups/:id/projects/:project_id
```

参数：

| 属性    | 类型           | 必需 | 描述 |
| ------------ | -------------- | -------- | ----------- |
| `id`         | integer or string | 是      | 目标群组的 ID 或 [URL 编码路径](rest/_index.md#namespaced-paths)。 |
| `project_id` | integer or string | 是      | 项目的 ID 或 [URL 编码路径](rest/_index.md#namespaced-paths)。 |

```shell
curl --request POST \
  --header "PRIVATE-TOKEN: <your_access_token>" \
  --url "https://gitlab.example.com/api/v4/groups/4/projects/56"
```

<a id="invite-groups"></a>

### 邀请群组

这些端点用于群组邀请。有关更多信息，请参见[邀请群组加入群组](../user/project/members/sharing_projects_groups.md#invite-a-group-to-a-group)。

<a id="create-a-group-invitation"></a>

#### 创建群组邀请

创建群组邀请，将目标群组添加到指定群组。

```plaintext
POST /groups/:id/share
```

参数：

| 属性        | 类型              | 必需 | 描述 |
|------------------|-------------------|----------|-------------|
| `id`             | integer or string | 是      | 目标群组的 ID 或 [URL 编码路径](rest/_index.md#namespaced-paths)。 |
| `group_id`       | integer           | 是      | 要邀请的群组 ID。 |
| `group_access`   | integer           | 是      | 分配给被邀请群组的默认 `access_level`。可能的值：`5`（最小访问权限）、`10`（访客）、`15`（计划者）、`20`（报告者）、`25`（安全管理员）、`30`（开发者）、`40`（维护者）或 `50`（所有者）。 |
| `expires_at`     | date (ISO 8601)   | 否       | 群组邀请到期的日期。 |
| `member_role_id` | integer           | 否       | 要分配给被邀请群组的[自定义角色](../user/custom_roles/_index.md#assign-a-custom-role-to-an-invited-group)的 ID。如果已定义，`group_access` 必须与用于创建自定义角色的基础角色匹配。 |

成功时返回 `200` 和群组详情。

<a id="delete-a-group-invitation"></a>

#### 删除群组邀请

删除群组邀请，并从指定群组移除对目标群组的访问权限。

```plaintext
DELETE /groups/:id/share/:group_id
```

| 属性  | 类型           | 必需 | 描述 |
|------------|----------------|----------|-------------|
| `id`       | integer or string | 是      | 目标群组的 ID 或 [URL 编码路径](rest/_index.md#namespaced-paths)。 |
| `group_id` | integer        | 是      | 要取消邀请的群组 ID。 |

成功时返回 `204` 且无内容。

<a id="update-group-attributes"></a>

## 更新群组属性

更新指定群组的属性。

先决条件：

- 您必须是管理员，或拥有该群组的所有者角色。

```plaintext
PUT /groups/:id
```

| 属性                                            | 类型              | 必需 | 描述 |
|------------------------------------------------------|-------------------|----------|-------------|
| `id`                                                 | integer           | 是      | 群组的 ID。 |
| `name`                                               | string            | 否       | 群组的名称。 |
| `path`                                               | string            | 否       | 群组的路径。 |
| `auto_devops_enabled`                                | boolean           | 否       | 为此群组内的所有项目默认使用 Auto DevOps 流水线。 |
| `avatar`                                             | mixed             | 否       | 群组头像的图片文件。 |
| `built_in_project_templates_enabled`                | boolean           | 否       | 当用户在群组中创建项目时启用内置项目模板。仅专业版和旗舰版。在极狐GitLab 19.0 中[引入](https://gitlab.com/gitlab-org/gitlab/-/merge_requests/235504)，[受功能标志控制](../administration/feature_flags/_index.md)，功能标志名为 `use_built_in_project_templates_enabled`。默认禁用。在极狐GitLab 19.2 中[正式发布](https://gitlab.com/gitlab-org/gitlab/-/work_items/593623)。功能标志 `use_built_in_project_templates_enabled` 已移除。 |
| `lock_built_in_project_templates_enabled`           | boolean           | 否       | 为所有子群组强制执行 `built_in_project_templates_enabled` 设置。仅专业版和旗舰版。在极狐GitLab 19.0 中[引入](https://gitlab.com/gitlab-org/gitlab/-/merge_requests/235504)，[受功能标志控制](../administration/feature_flags/_index.md)，功能标志名为 `use_built_in_project_templates_enabled`。默认禁用。在极狐GitLab 19.2 中[正式发布](https://gitlab.com/gitlab-org/gitlab/-/work_items/593623)。功能标志 `use_built_in_project_templates_enabled` 已移除。 |
| `default_branch`                                     | string            | 否       | 群组项目的[默认分支](../user/project/repository/branches/default.md)名称。 |
| `default_branch_protection`                          | integer           | 否       | 在极狐GitLab 17.0 中[已弃用](https://gitlab.com/gitlab-org/gitlab/-/issues/408314)。请改用 `default_branch_protection_defaults`。 |
| `default_branch_protection_defaults`                 | hash              | 否       | 在极狐GitLab 17.0 中[引入](https://gitlab.com/gitlab-org/gitlab/-/issues/408314)。有关可用选项，请参见 [`default_branch_protection_defaults`的选项](#options-for-default_branch_protection_defaults)。 |
| `description`                                        | string            | 否       | 群组的描述。 |
| `enabled_git_access_protocol`                        | string            | 否       | 为 Git 访问启用的协议。允许的值为：`ssh`、`http` 和 `all`（允许两种协议）。 |
| `emails_disabled`                                    | boolean           | 否       | （在极狐GitLab 16.5 中[已弃用](https://gitlab.com/gitlab-org/gitlab/-/merge_requests/127899)。）禁用电子邮件通知。请改用 `emails_enabled`。 |
| `emails_enabled`                                     | boolean           | 否       | 启用电子邮件通知。 |
| `lfs_enabled`                                        | boolean           | 否       | 为此群组中的项目启用/禁用大文件存储（LFS）。 |
| `mentions_disabled`                                  | boolean           | 否       | 禁用群组被提及的功能。 |
| `prevent_sharing_groups_outside_hierarchy`           | boolean           | 否       | 请参见[阻止在群组层级之外共享群组](../user/project/members/sharing_projects_groups.md#prevent-inviting-groups-outside-the-group-hierarchy)。此属性仅在顶级群组上可用。 |
| `project_creation_level`                             | string            | 否       | 确定开发者是否可以在群组中创建项目。可以是 `noone`（无人）、`maintainer`（具有维护者角色的用户）或 `developer`（具有开发者或维护者角色的用户）。 |
| `request_access_enabled`                             | boolean           | 否       | 允许用户请求成员访问权限。 |
| `require_two_factor_authentication`                  | boolean           | 否       | 要求此群组中的所有用户设置双因素认证。 |
| `shared_runners_setting`                             | string            | 否       | 请参见 [`shared_runners_setting`的选项](#options-for-shared_runners_setting)。为群组的子群组和项目启用或禁用实例 Runner。 |
| `share_with_group_lock`                              | boolean           | 否       | 阻止与此群组内的另一个群组共享项目。 |
| `step_up_auth_required_oauth_provider`               | string            | 否       | 提升身份验证所需的 OAuth 提供商。传递空字符串以禁用。在极狐GitLab 18.4 中[引入](https://gitlab.com/gitlab-org/gitlab/-/issues/556943)。当启用 `omniauth_step_up_auth_for_namespace` 功能标志时可用。 |
| `subgroup_creation_level`                            | string            | 否       | 允许[创建子群组](../user/group/subgroups/_index.md#create-a-subgroup)。可以是 `owner`（具有所有者角色的用户）或 `maintainer`（具有维护者角色的用户）。 |
| `two_factor_grace_period`                            | integer           | 否       | 强制执行双因素认证之前的时间（以小时为单位）。 |
| `visibility`                                         | string            | 否       | 群组的可见性级别。可以是 `private`、`internal` 或 `public`。 |
| `extra_shared_runners_minutes_limit`                 | integer           | 否       | 只能由管理员设置。此群组的额外计算分钟。仅极狐GitLab 私有化部署、专业版和旗舰版。 |
| `file_template_project_id`                           | integer           | 否       | 用于加载自定义文件模板的项目的 ID。仅专业版和旗舰版。 |
| `membership_lock`                                    | boolean           | 否       | 用户无法添加到此群组中的项目。仅专业版和旗舰版。 |
| `prevent_forking_outside_group`                      | boolean           | 否       | 启用后，用户无法将此群组中的项目 fork 到外部命名空间。仅专业版和旗舰版。 |
| `shared_runners_minutes_limit`                       | integer           | 否       | 只能由管理员设置。此群组每月的最大计算分钟数。可以是 `nil`（默认；继承系统默认值）、`0`（无限制）或 `> 0`。仅极狐GitLab 私有化部署、专业版和旗舰版。 |
| `unique_project_download_limit`                      | integer           | 否       | 用户在指定时间段内可下载的唯一项目最大数量，超过后将被封禁。仅在顶级群组上可用。默认值：0，最大值：10,000。仅旗舰版。 |
| `unique_project_download_limit_interval_in_seconds`  | integer           | 否       | 用户在被封禁前可下载最大项目数量的时间段。仅在顶级群组上可用。默认值：0，最大值：864,000 秒（10 天）。仅旗舰版。 |
| `unique_project_download_limit_allowlist`            | array of strings  | 否       | 排除在唯一项目下载限制之外的用户名列表。仅在顶级群组上可用。默认值：`[]`，最大值：100 个用户名。仅旗舰版。 |
| `unique_project_download_limit_alertlist`            | array of integers | 否       | 超过唯一项目下载限制时通过电子邮件通知的用户 ID 列表。仅在顶级群组上可用。默认值：`[]`，最大值：100 个用户 ID。仅旗舰版。 |
| `auto_ban_user_on_excessive_projects_download`       | boolean           | 否       | 启用后，当用户下载的唯一项目数量超过 `unique_project_download_limit` 和 `unique_project_download_limit_interval_in_seconds` 指定的最大数量时，将自动从群组中封禁该用户。仅旗舰版。 |
| `ip_restriction_ranges`                              | string      | 否       | 用于限制群组访问的 IP 地址或子网掩码的逗号分隔列表。仅专业版和旗舰版。 |
| `allowed_email_domains_list`                         | string      | 否       | 允许访问群组的电子邮件地址域的逗号分隔列表。在 17.4 中[引入](https://gitlab.com/gitlab-org/gitlab/-/issues/351494)。仅极狐GitLab 专业版和旗舰版。 |
| `wiki_access_level`                                  | string            | 否       | Wiki 访问级别。可以是 `disabled`、`private` 或 `enabled`。仅专业版和旗舰版。 |
| `duo_availability`                                   | string | 否 | 极狐GitLab Duo 可用性设置。有效值为：`default_on`、`default_off`、`never_on`。注意：在 UI 中，`never_on` 显示为 "Always Off"。 |
| `experiment_features_enabled`                        | boolean | 否 | 为此群组启用实验功能。 |
| `ai_settings_attributes`                             | hash | 否 | 此群组的 AI 相关设置。有关可用选项，请参见 [`ai_settings_attributes`的选项](#options-for-ai_settings_attributes)。必须启用极狐GitLab Duo 功能。 |
| `math_rendering_limits_enabled`                      | boolean           | 否       | 指示此群组是否使用数学渲染限制。 |
| `lock_math_rendering_limits_enabled`                 | boolean           | 否       | 指示是否为所有后代群组锁定数学渲染限制。 |
| `require_sha_for_merge`                              | boolean           | 否       | 指示此群组中的合并请求在调用[合并合并请求](merge_requests.md#merge-a-merge-request)端点时是否需要有效的提交 SHA。在极狐GitLab 19.5 中[引入](https://gitlab.com/gitlab-org/gitlab/-/merge_requests/256966)。 |
| `lock_require_sha_for_merge`                         | boolean           | 否       | 为所有后代群组强制执行 `require_sha_for_merge` 设置。在极狐GitLab 19.5 中[引入](https://gitlab.com/gitlab-org/gitlab/-/merge_requests/256966)。 |
| `duo_features_enabled`                               | boolean           | 否       | 指示此群组是否启用极狐GitLab Duo 功能。仅极狐GitLab 私有化部署、专业版和旗舰版。 |
| `lock_duo_features_enabled`                          | boolean           | 否       | 指示是否为所有子群组强制执行极狐GitLab Duo 功能启用设置。仅极狐GitLab 私有化部署、专业版和旗舰版。 |
| `ai_audit_events_storage_enabled`                    | boolean           | 否       | 指示是否为该群组存储 AI 审计事件。在极狐GitLab 19.2 中[引入](https://gitlab.com/gitlab-org/gitlab/-/merge_requests/245843)。仅专业版和旗舰版。 |
| `lock_ai_audit_events_storage_enabled`               | boolean           | 否       | 指示是否为所有子群组和项目强制执行 AI 审计事件存储设置。在极狐GitLab 19.2 中[引入](https://gitlab.com/gitlab-org/gitlab/-/merge_requests/245843)。仅专业版和旗舰版。 |
| `max_artifacts_size`                                 | integer           | 否       | 单个作业产物的最大文件大小（以兆字节为单位）。 |
| `web_based_commit_signing_enabled`                  | boolean           | 否       | 为从极狐GitLab UI 创建的提交启用基于 Web 的提交签名。仅在 JihuLab.com 上的顶级群组可用。为群组启用后，将应用于该群组中的所有项目。 |
| `only_allow_merge_if_pipeline_succeeds`             | boolean           | 否       | 仅当流水线成功时才允许合并合并请求。为群组启用后，将应用于该群组中的所有项目。仅专业版和旗舰版。 |
| `allow_merge_on_skipped_pipeline`                   | boolean           | 否       | 当流水线被跳过时允许合并合并请求。仅在 `only_allow_merge_if_pipeline_succeeds` 为 `true` 时适用。仅专业版和旗舰版。 |
| `only_allow_merge_if_all_discussions_are_resolved`  | boolean           | 否       | 仅当所有讨论都已解决时才允许合并合并请求。为群组启用后，将应用于该群组中的所有项目。仅专业版和旗舰版。 |
| `allow_personal_snippets`                           | boolean           | 否       | 允许此群组中的企业用户创建个人代码片段。禁用后，企业用户将无法在其个人命名空间中创建代码片段。 |

> [!note]
> 响应中的 `projects` 和 `shared_projects` 属性已弃用，并[计划在 API v5 中移除](https://gitlab.com/gitlab-org/gitlab/-/issues/213797)。
> 要获取群组内所有项目的详情，请使用[列出群组的项目](#list-projects)或[列出群组的共享项目](#list-shared-projects)端点。

```shell
curl --request PUT \
  --header "PRIVATE-TOKEN: <your_access_token>" \
  --url "https://gitlab.example.com/api/v4/groups/5?name=Experimental"
```

此端点最多返回 100 个项目和共享项目。要获取群组中所有项目的详情，请改用[列出群组的项目端点](#list-projects)。

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
  "projects": [ // Deprecated and will be removed in API v5
    {
      "id": 9,
      "description": "foo",
      "default_branch": "main",
      "tag_list": [], //deprecated, use `topics` instead
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
  "lock_math_rendering_limits_enabled": false,
  "require_sha_for_merge": false,
  "lock_require_sha_for_merge": false
}
```

`prevent_sharing_groups_outside_hierarchy` 属性仅在顶级群组的响应中出现。

[极狐GitLab 专业版或旗舰版](https://gitlab.cn/pricing)的用户还会看到 `wiki_access_level`、
`duo_features_enabled`、
`lock_duo_features_enabled`、
`duo_availability` 和 `experiment_features_enabled` 属性。

<a id="options-for-shared_runners_setting"></a>

### `shared_runners_setting`的选项

`shared_runners_setting` 属性决定是否为群组的子群组和项目启用实例 Runner。

| 值                        | 描述 |
|------------------------------|-------------|
| `enabled`                    | 为此群组中的所有项目和子群组启用实例 Runner。 |
| `disabled_and_overridable`   | 为此群组中的所有项目和子群组禁用实例 Runner，但允许子群组覆盖此设置。 |
| `disabled_and_unoverridable` | 为此群组中的所有项目和子群组禁用实例 Runner，并阻止子群组覆盖此设置。 |
| `disabled_with_override`     | （已弃用。请使用 `disabled_and_overridable`）为此群组中的所有项目和子群组禁用实例 Runner，但允许子群组覆盖此设置。 |

<a id="options-for-ai_settings_attributes"></a>

### `ai_settings_attributes`的选项

`ai_settings_attributes` 哈希配置群组的 AI 相关设置。所有属性均为可选。

| 属性 | 类型 | 描述 |
|-----|------|-------------|
| `ai_catalog_restricted_to_group_hierarchy` | boolean | 当为 `true` 时，将 AI 目录限制为此顶级群组层级中的条目。只能在顶级群组上设置。仅专业版和旗舰版。 |
| `ai_usage_data_collection_enabled` | boolean | 当为 `true` 时，为此群组启用 AI 使用数据收集。仅 JihuLab.com。 |
| `allow_all_unix_sockets` | boolean | 当为 `true` 时，允许极狐GitLab Duo Agent Platform 使用所有 Unix 套接字。 |
| `allow_project_extension` | boolean | 当为 `true` 时，允许项目扩展极狐GitLab Duo Agent Platform 的网络访问域允许名单。 |
| `duo_agent_platform_enabled` | boolean | 当为 `true` 时，为此群组启用极狐GitLab Duo Agent Platform 功能。在专业版和旗舰版上可用。在 JihuLab.com 上，使用极狐GitLab Credits 的基础版也可用。 |
| `duo_workflow_mcp_enabled` | boolean | 当为 `true` 时，为极狐GitLab Duo Agent Platform 启用 MCP 支持。在专业版和旗舰版上可用。在 JihuLab.com 上，使用极狐GitLab Credits 的基础版也可用。 |
| `foundational_agents_default_enabled` | boolean | 当为 `true` 时，为此群组默认启用新的内置 Agent。在专业版和旗舰版上可用。在 JihuLab.com 上，使用极狐GitLab Credits 的基础版也可用。 |
| `include_recommended_allowed` | boolean | 当为 `true` 时，在极狐GitLab Duo Agent Platform 的网络访问允许名单中包含推荐的域。 |
| `minimum_access_level_enable_on_projects` | integer | 在项目上启用极狐GitLab Duo Agent Platform 所需的最低访问级别。有效值：`30`（开发者）、`40`（维护者）、`50`（所有者）。当启用 `dap_group_customizable_permissions` 功能标志时可用。 |
| `minimum_access_level_execute` | integer | 用户使用极狐GitLab Duo Agent Platform 功能所需的最低访问级别。有效值：`10`（访客）、`15`（计划者）、`20`（报告者）、`30`（开发者）、`40`（维护者）、`50`（所有者）。当启用 `dap_group_customizable_permissions` 功能标志时可用。 |
| `minimum_access_level_execute_async` | integer | 在 CI/CD 中执行极狐GitLab Duo Agent Platform 功能所需的最低访问级别。有效值：`30`（开发者）、`40`（维护者）、`50`（所有者）。当启用 `dap_group_customizable_permissions` 功能标志时可用。 |
| `minimum_access_level_manage` | integer | 管理极狐GitLab Duo Agent Platform 所需的最低访问级别。有效值：`30`（开发者）、`40`（维护者）、`50`（所有者）。当启用 `dap_group_customizable_permissions` 功能标志时可用。 |
| `prompt_injection_protection_level` | string | 提示注入防护级别。有效值：`no_checks`、`log_only`、`interrupt`。 |
| `web_search_enabled` | boolean | 当为 `true` 时，为此群组在极狐GitLab Duo Chat 中启用 Web 搜索。只能在顶级群组上设置。 |

<a id="update-group-avatars"></a>

## 更新群组头像

更新群组头像。

<a id="download-a-group-avatar"></a>

### 下载群组头像

获取群组头像。如果群组可公开访问，则无需身份验证即可访问此端点。

```plaintext
GET /groups/:id/avatar
```

| 属性 | 类型           | 必需 | 描述 |
|-----------|----------------|----------|-------------|
| `id`      | integer or string | 是      | 群组的 ID。 |

示例：

```shell
curl --request GET \
  --header "PRIVATE-TOKEN: $GITLAB_LOCAL_TOKEN" \
  --remote-header-name \
  --remote-name \
  --url "https://gitlab.example.com/api/v4/groups/4/avatar"
```

<a id="upload-a-group-avatar"></a>

### 上传群组头像

要从文件系统上传头像文件，请使用 `--form` 参数。这会使 curl 使用请求头 `Content-Type: multipart/form-data` 提交数据。`file=` 参数必须指向您文件系统上的文件，并在前面加上 `@`。例如：

```shell
curl --request PUT \
  --header "PRIVATE-TOKEN: <your_access_token>" \
  --form "avatar=@/tmp/example.png" \
  --url "https://gitlab.example.com/api/v4/groups/22"
```

<a id="remove-a-group-avatar"></a>

### 移除群组头像

要移除群组头像，请为 `avatar` 属性使用空值。

示例请求：

```shell
curl --request PUT \
  --header "PRIVATE-TOKEN: <your_access_token>" \
  --data "avatar=" \
  --url "https://gitlab.example.com/api/v4/groups/22"
```

<a id="sync-a-group-with-ldap"></a>

## 将群组与 LDAP 同步

{{< details >}}

- Tier: 专业版，旗舰版
- Offering: 私有化部署

{{< /details >}}

将指定群组与其关联的 LDAP 群组同步。

先决条件：

- 您必须是管理员，或拥有该群组的所有者角色。

```plaintext
POST /groups/:id/ldap_sync
```

| 属性 | 类型                | 必需 | 描述                            |
| --------- | ------------------- | -------- | -------------------------------------- |
| `id`      | integer or string   | 是      | 群组的 ID 或 URL 编码路径。 |

<a id="credentials-inventory-management"></a>

## 凭据清单管理

{{< details >}}

- Tier: 专业版，旗舰版
- Offering: JihuLab.com

{{< /details >}}

查看、撤销和轮换 JihuLab.com 上企业用户的凭据。

先决条件：

- 您必须拥有该群组的所有者角色。

<a id="list-all-personal-access-tokens-for-a-group"></a>

### 列出群组的所有个人访问令牌

列出与顶级群组中企业用户关联的所有个人访问令牌。

```plaintext
GET /groups/:id/manage/personal_access_tokens
```

| 属性          | 类型                | 必需 | 描述 |
| ------------------ | ------------------- | -------- | ----------- |
| `id`               | integer or string   | 是      | 群组的 ID 或 [URL 编码路径](rest/_index.md#namespaced-paths)。 |
| `created_after`    | datetime (ISO 8601) | 否       | 如果已定义，返回在指定时间之后创建的令牌。 |
| `created_before`   | datetime (ISO 8601) | 否       | 如果已定义，返回在指定时间之前创建的令牌。 |
| `last_used_after`  | datetime (ISO 8601) | 否       | 如果已定义，返回在指定时间之后最后使用的令牌。 |
| `last_used_before` | datetime (ISO 8601) | 否       | 如果已定义，返回在指定时间之前最后使用的令牌。 |
| `revoked`          | boolean             | 否       | 如果为 `true`，则仅返回已撤销的令牌。 |
| `search`           | string              | 否       | 如果已定义，返回名称中包含指定值的令牌。 |
| `state`            | string              | 否       | 如果已定义，返回具有指定状态的令牌。可能的值：`active` 和 `inactive`。 |
| `sort`             | string              | 否       | 如果已定义，按指定值对结果排序。可能的值：`created_asc`、`created_desc`、`expires_asc`、`expires_desc`、`last_used_asc`、`last_used_desc`、`name_asc`、`name_desc`。 |

示例请求：

```shell
curl --request GET \
  --header "PRIVATE-TOKEN: <group_owner_token>" \
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
    "last_used_ips": ["192.0.2.10"],
    "active": true,
    "expires_at": "2025-11-08"
  }
]
```

<a id="list-all-group-and-project-access-tokens-for-a-group"></a>

### 列出群组的所有群组和项目访问令牌

列出与顶级群组关联的所有群组和项目访问令牌。

```plaintext
GET /groups/:id/manage/resource_access_tokens
```

| 属性          | 类型                | 必需 | 描述 |
| ------------------ | ------------------- | -------- | ----------- |
| `id`               | integer or string   | 是      | 群组的 ID 或 [URL 编码路径](rest/_index.md#namespaced-paths)。 |
| `created_after`    | datetime (ISO 8601) | 否       | 如果已定义，返回在指定时间之后创建的令牌。 |
| `created_before`   | datetime (ISO 8601) | 否       | 如果已定义，返回在指定时间之前创建的令牌。 |
| `last_used_after`  | datetime (ISO 8601) | 否       | 如果已定义，返回在指定时间之后最后使用的令牌。 |
| `last_used_before` | datetime (ISO 8601) | 否       | 如果已定义，返回在指定时间之前最后使用的令牌。 |
| `revoked`          | boolean             | 否       | 如果为 `true`，则仅返回已撤销的令牌。 |
| `search`           | string              | 否       | 如果已定义，返回名称中包含指定值的令牌。 |
| `state`            | string              | 否       | 如果已定义，返回具有指定状态的令牌。可能的值：`active` 和 `inactive`。 |
| `sort`             | string              | 否       | 如果已定义，按指定值对结果排序。可能的值：`created_asc`、`created_desc`、`expires_asc`、`expires_desc`、`last_used_asc`、`last_used_desc`、`name_asc`、`name_desc`。 |

示例请求：

```shell
curl --request GET \
  --header "PRIVATE-TOKEN: <group_owner_token>" \
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

<a id="list-all-ssh-keys-for-a-group"></a>

### 列出群组的所有 SSH 密钥

列出与顶级群组中企业用户关联的所有 SSH 公钥。

```plaintext
GET /groups/:id/manage/ssh_keys
```

| 属性        | 类型                | 必需 | 描述 |
| ---------------- | ------------------- | -------- | ----------- |
| `id`             | integer or string   | 是      | 群组的 ID 或 [URL 编码路径](rest/_index.md#namespaced-paths)。 |
| `created_after`  | datetime (ISO 8601) | 否       | 如果已定义，返回在指定时间之后创建的 SSH 密钥。 |
| `created_before` | datetime (ISO 8601) | 否       | 如果已定义，返回在指定时间之前创建的 SSH 密钥。 |
| `expires_before` | datetime (ISO 8601) | 否       | 如果已定义，返回在指定时间之前过期的 SSH 密钥。 |
| `expires_after`  | datetime (ISO 8601) | 否       | 如果已定义，返回在指定时间之后过期的 SSH 密钥。 |

```shell
curl --request GET \
  --header "PRIVATE-TOKEN: <group_owner_token>" \
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

<a id="revoke-a-personal-access-token-for-an-enterprise-user"></a>

### 撤销企业用户的个人访问令牌

撤销企业用户的指定个人访问令牌。

```plaintext
DELETE groups/:id/manage/personal_access_tokens/:id
```

| 属性 | 类型    | 必需 | 描述         |
|-----------|---------|----------|---------------------|
| `id` | integer or string | 是 | 个人访问令牌的 ID 或关键字 `self`。 |

```shell
curl --request DELETE \
  --header "PRIVATE-TOKEN: <your_access_token>" \
  --url "https://gitlab.example.com/api/v4/groups/1/manage/personal_access_tokens/<personal_access_token_id>"
```

如果成功，返回 `204: No Content`。

其他可能的响应：

- 如果未成功撤销，返回 `400: Bad Request`。
- 如果访问令牌无效，返回 `401: Unauthorized`。
- 如果访问令牌没有所需权限，返回 `403: Forbidden`。

<a id="revoke-a-group-or-project-access-token-for-an-enterprise-user"></a>

### 撤销企业用户的群组或项目访问令牌

撤销与顶级群组关联的企业用户的指定群组或项目访问令牌。

```plaintext
DELETE groups/:id/manage/resource_access_tokens/:id
```

| 属性 | 类型    | 必需 | 描述         |
|-----------|---------|----------|---------------------|
| `id` | integer or string | 是 | 资源访问令牌的 ID 或关键字 `self`。 |

```shell
curl --request DELETE \
  --header "PRIVATE-TOKEN: <your_access_token>" \
  --url "https://gitlab.example.com/api/v4/groups/1/manage/resource_access_tokens/<personal_access_token_id>"
```

如果成功，返回 `204: No Content`。

其他可能的响应：

- 如果未成功撤销，返回 `400: Bad Request`。
- 如果访问令牌无效，返回 `401: Unauthorized`。
- 如果访问令牌没有所需权限，返回 `403: Forbidden`。

<a id="delete-an-ssh-key-for-an-enterprise-user"></a>

### 删除企业用户的 SSH 密钥

删除与顶级群组关联的企业用户的指定 SSH 公钥。

```plaintext
DELETE /groups/:id/manage/ssh_keys/:key_id
```

支持的属性：

| 属性 | 类型    | 必需 | 描述 |
|:----------|:--------|:---------|:------------|
| `key_id`  | integer | 是      | 现有密钥的 ID。  |

如果成功，返回 `204: No Content`。

其他可能的响应：

- 如果 SSH 密钥未成功删除，返回 `400: Bad Request`。
- 如果 SSH 密钥无效，返回 `401: Unauthorized`。
- 如果用户没有所需权限，返回 `403: Forbidden`。

<a id="rotate-a-personal-access-token-for-an-enterprise-user"></a>

### 轮换企业用户的个人访问令牌

轮换与顶级群组关联的企业用户的指定个人访问令牌。这会撤销先前的令牌并创建一个新令牌，该令牌将在一周后过期。

```plaintext
POST groups/:id/manage/personal_access_tokens/:id/rotate
```

| 属性 | 类型      | 必需 | 描述         |
|-----------|-----------|----------|---------------------|
| `id` | integer or string | 是      | 个人访问令牌的 ID 或关键字 `self`。 |
| `expires_at` | date   | 否       | 访问令牌的到期日期，采用 ISO 格式（`YYYY-MM-DD`）。该日期距轮换日期必须不超过一年。如果未定义，令牌将在一周后过期。 |

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
    "description": "Test Token description",
    "scopes": ["api"],
    "user_id": 1337,
    "last_used_at": null,
    "last_used_ips": [],
    "active": true,
    "expires_at": "2023-08-15",
    "token": "s3cr3t"
}
```

如果成功，返回 `200: OK`。

其他可能的响应：

- 如果未成功轮换，返回 `400: Bad Request`。
- 如果满足以下任一条件，返回 `401: Unauthorized`：
  - 令牌不存在。
  - 令牌已过期。
  - 令牌已被撤销。
  - 您无权访问指定的令牌。
- 如果不允许该令牌自行轮换，返回 `403: Forbidden`。
- 如果用户拥有所有者角色，但令牌不存在，返回 `404: Not Found`。
- 如果该令牌不是个人访问令牌，返回 `405: Method Not Allowed`。

<a id="rotate-a-group-or-project-access-token-for-an-enterprise-user"></a>

### 轮换企业用户的群组或项目访问令牌

轮换与顶级群组关联的企业用户的指定群组或项目访问令牌。这会撤销先前的令牌并创建一个新令牌，该令牌将在一周后过期。

```plaintext
POST groups/:id/manage/resource_access_tokens/:id/rotate
```

| 属性 | 类型      | 必需 | 描述         |
|-----------|-----------|----------|---------------------|
| `id` | integer or string | 是      | 个人访问令牌的 ID 或关键字 `self`。 |
| `expires_at` | date   | 否       | 访问令牌的到期日期，采用 ISO 格式（`YYYY-MM-DD`）。该日期距轮换日期必须不超过一年。如果未定义，令牌将在一周后过期。 |

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
    "description": "Test Token description",
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

- 如果未成功轮换，返回 `400: Bad Request`。
- 如果满足以下任一条件，返回 `401: Unauthorized`：
  - 令牌不存在。
  - 令牌已过期。
  - 令牌已被撤销。
  - 您无权访问指定的令牌。
- 如果不允许该令牌自行轮换，或该令牌不是机器人用户令牌，返回 `403: Forbidden`。
- 如果用户拥有所有者角色，但令牌不存在，返回 `404: Not Found`。
