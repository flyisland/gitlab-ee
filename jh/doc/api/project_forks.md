---
stage: Tenant Scale
group: Organizations
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
title: 项目 forks API
---

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: JihuLab.com，私有化部署

{{< /details >}}

使用此 API 管理极狐GitLab 项目的 forks。更多信息，请参见 [forks](../user/project/repository/forking_workflow.md)。

<a id="create-a-fork-of-a-project"></a>

## 创建项目的 fork

创建指定项目的 fork。

先决条件：

- 您必须通过身份验证。

项目的 forking 操作是异步的，会在后台作业中完成。请求会立即返回。要确定项目的 fork 是否已完成，请查询新项目的 `import_status`。

```plaintext
POST /projects/:id/fork
```

| 属性                | 类型              | 是否必需 | 描述 |
|:-------------------------|:------------------|:---------|:------------|
| `id`                     | integer or string | 是      | 项目的 ID 或 [URL 编码路径](rest/_index.md#namespaced-paths)。 |
| `branches`               | string            | 否       | 要 fork 的分支（留空表示所有分支）。 |
| `description`            | string            | 否       | forking 后分配给生成项目的描述。 |
| `mr_default_target_self` | boolean           | 否       | 对于 forked 的项目，将合并请求的目标设为此项目。如果为 `false`，则目标为上游项目。 |
| `name`                   | string            | 否       | forking 后分配给生成项目的名称。 |
| `namespace_id`           | integer           | 否       | 项目 forked 到的命名空间 ID。 |
| `namespace_path`         | string            | 否       | 项目 forked 到的命名空间路径。 |
| `namespace`              | integer or string | 否       | _（已弃用）_ 项目 forked 到的命名空间 ID 或路径。 |
| `path`                   | string            | 否       | forking 后分配给生成项目的路径。 |
| `visibility`             | string            | 否       | forking 后分配给生成项目的[可见性级别](projects.md#project-visibility-level)。生成的可见性绝不会比上游项目的可见性或目标命名空间的可见性更宽松。如果您传入更宽松的值，极狐GitLab 会改用更严格的值。 |

> [!note]
> 使用服务账号 fork 项目时，您必须提供 `namespace_id` 或 `namespace_path`。
> 服务账号无法将项目 fork 到其个人命名空间。更多信息，请参见
> [将服务账号添加到群组或项目](../user/profile/service_accounts.md#add-a-service-account-to-a-group-or-project)。

<a id="list-all-forks-of-a-project"></a>

## 列出项目的所有 forks

列出指定项目的所有 forks。仅返回您可访问的 forks。

```plaintext
GET /projects/:id/forks
```

支持的属性：

| 属性                     | 类型              | 是否必需 | 描述 |
|:------------------------------|:------------------|:---------|:------------|
| `id`                          | integer or string | 是      | 项目的 ID 或 [URL 编码路径](rest/_index.md#namespaced-paths)。 |
| `archived`                    | boolean           | 否       | 按归档状态限制。 |
| `membership`                  | boolean           | 否       | 按当前用户是其成员的项目限制。 |
| `min_access_level`            | integer           | 否       | 限制为当前用户至少具有指定访问权限级别的项目。可能的值：`5`（最小访问权限）、`10`（访客）、`15`（计划者）、`20`（报告者）、`25`（安全管理员）、`30`（开发者）、`40`（维护者）或 `50`（所有者）。 |
| `order_by`                    | string            | 否       | 按 `id`、`name`、`path`、`created_at`、`updated_at`、`star_count` 或 `last_activity_at` 字段返回排序后的项目。默认为 `created_at`。 |
| `owned`                       | boolean           | 否       | 按当前用户明确拥有的项目限制。 |
| `search`                      | string            | 否       | 返回与搜索条件匹配的项目列表。 |
| `simple`                      | boolean           | 否       | 仅返回每个项目的有限字段。未经身份验证时，此操作为空操作；仅返回简单字段。 |
| `sort`                        | string            | 否       | 按 `asc` 或 `desc` 顺序返回排序后的项目。默认为 `desc`。 |
| `starred`                     | boolean           | 否       | 按当前用户加星标的项目限制。 |
| `statistics`                  | boolean           | 否       | 包含项目统计信息。仅对具有报告者、开发者、维护者或所有者角色的用户可用。 |
| `updated_after`               | datetime          | 否       | 将结果限制为在指定时间之后最后更新的项目。格式：ISO 8601（`YYYY-MM-DDTHH:MM:SSZ`）。 |
| `updated_before`              | datetime          | 否       | 将结果限制为在指定时间之前最后更新的项目。格式：ISO 8601（`YYYY-MM-DDTHH:MM:SSZ`）。 |
| `visibility`                  | string            | 否       | 按可见性 `public`、`internal` 或 `private` 限制。 |
| `with_custom_attributes`      | boolean           | 否       | 在响应中包含[自定义属性](custom_attributes.md)。_（仅限管理员）_ |
| `with_issues_enabled`         | boolean           | 否       | 按已启用的议题功能限制。 |
| `with_merge_requests_enabled` | boolean           | 否       | 按已启用的合并请求功能限制。 |

示例请求：

```shell
curl --request GET \
  --header "PRIVATE-TOKEN: <your_access_token>" \
  --url "https://gitlab.example.com/api/v4/projects/5/forks"
```

示例响应：

```json
[
  {
    "id": 3,
    "description": "Lorem ipsum dolor sit amet, consectetur adipiscing elit.",
    "description_html": "<p data-sourcepos=\"1:1-1:56\" dir=\"auto\">Lorem ipsum dolor sit amet, consectetur adipiscing elit.</p>",
    "default_branch": "main",
    "visibility": "internal",
    "ssh_url_to_repo": "git@example.com:diaspora/diaspora-project-site.git",
    "http_url_to_repo": "http://example.com/diaspora/diaspora-project-site.git",
    "web_url": "http://example.com/diaspora/diaspora-project-site",
    "readme_url": "http://example.com/diaspora/diaspora-project-site/blob/main/README.md",
    "tag_list": [ //deprecated, use `topics` instead
      "example",
      "disapora project"
    ],
    "topics": [
      "example",
      "disapora project"
    ],
    "name": "Diaspora Project Site",
    "name_with_namespace": "Diaspora / Diaspora Project Site",
    "path": "diaspora-project-site",
    "path_with_namespace": "diaspora/diaspora-project-site",
    "repository_object_format": "sha1",
    "issues_enabled": true,
    "open_issues_count": 1,
    "merge_requests_enabled": true,
    "jobs_enabled": true,
    "wiki_enabled": true,
    "snippets_enabled": false,
    "can_create_merge_request_in": true,
    "resolve_outdated_diff_discussions": false,
    "container_registry_enabled": false, // deprecated, use container_registry_access_level instead
    "container_registry_access_level": "disabled",
    "security_and_compliance_access_level": "disabled",
    "created_at": "2013-09-30T13:46:02Z",
    "updated_at": "2013-09-30T13:46:02Z",
    "last_activity_at": "2013-09-30T13:46:02Z",
    "creator_id": 3,
    "namespace": {
      "id": 3,
      "name": "Diaspora",
      "path": "diaspora",
      "kind": "group",
      "full_path": "diaspora"
    },
    "import_status": "none",
    "archived": true,
    "avatar_url": "http://example.com/uploads/project/avatar/3/uploads/avatar.png",
    "shared_runners_enabled": true,
    "group_runners_enabled": true,
    "forks_count": 0,
    "star_count": 1,
    "public_jobs": true,
    "shared_with_groups": [],
    "only_allow_merge_if_pipeline_succeeds": false,
    "allow_merge_on_skipped_pipeline": false,
    "restrict_user_defined_variables": false,
    "only_allow_merge_if_all_discussions_are_resolved": false,
    "remove_source_branch_after_merge": false,
    "request_access_enabled": false,
    "merge_method": "merge",
    "squash_option": "default_on",
    "autoclose_referenced_issues": true,
    "enforce_auth_checks_on_uploads": true,
    "suggestion_commit_message": null,
    "merge_commit_template": null,
    "container_registry_image_prefix": "registry.example.com/diaspora/diaspora-project-site",
    "_links": {
      "self": "http://example.com/api/v4/projects",
      "issues": "http://example.com/api/v4/projects/1/issues",
      "merge_requests": "http://example.com/api/v4/projects/1/merge_requests",
      "repo_branches": "http://example.com/api/v4/projects/1/repository_branches",
      "labels": "http://example.com/api/v4/projects/1/labels",
      "events": "http://example.com/api/v4/projects/1/events",
      "members": "http://example.com/api/v4/projects/1/members",
      "cluster_agents": "http://example.com/api/v4/projects/1/cluster_agents"
    }
  }
]
```

<a id="create-a-fork-relationship"></a>

## 创建 fork 关系

在两个指定项目之间创建 fork 关系。

先决条件：

- 您必须是管理员，或在项目上被分配所有者角色。

```plaintext
POST /projects/:id/fork/:forked_from_id
```

支持的属性：

| 属性        | 类型              | 是否必需 | 描述 |
|:-----------------|:------------------|:---------|:------------|
| `forked_from_id` | ID                | 是      | 被 forked 的项目的 ID。 |
| `id`             | integer or string | 是      | 项目的 ID 或 [URL 编码路径](rest/_index.md#namespaced-paths)。 |

<a id="delete-a-fork-relationship"></a>

## 删除 fork 关系

删除两个指定项目之间的 fork 关系。

先决条件：

- 您必须是管理员，或在项目上被分配所有者角色。

```plaintext
DELETE /projects/:id/fork
```

支持的属性：

| 属性 | 类型              | 是否必需 | 描述 |
|:----------|:------------------|:---------|:------------|
| `id`      | integer or string | 是      | 项目的 ID 或 [URL 编码路径](rest/_index.md#namespaced-paths)。 |
