---
stage: Tenant Scale
group: Organizations
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
title: 项目派生 API
---

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: JihuLab.com，私有化部署

{{< /details >}}

使用此 API 管理极狐GitLab 项目的派生。更多信息，请参见[派生](../user/project/repository/forking_workflow.md)。

<a id="create-a-fork-of-a-project"></a>

## 创建项目派生

为指定项目创建派生。

先决条件：

- 您必须经过身份验证。

项目的派生操作是异步的，在后台作业中完成。请求立即返回。要确定项目派生是否已完成，请查询新项目的 `import_status`。

```plaintext
POST /projects/:id/fork
```

| 属性                         | 类型              | 必需   | 描述                                                                                                                     |
|:-----------------------------|:------------------|:-------|:-------------------------------------------------------------------------------------------------------------------------|
| `id`                         | 整数或字符串       | 是     | 项目的 ID 或 [URL 编码路径](rest/_index.md#namespaced-paths)。                                                                |
| `branches`                   | 字符串            | 否     | 要派生的分支（留空表示所有分支）。                                                                                         |
| `description`                | 字符串            | 否     | 派生后分配给结果项目的描述。                                                                                              |
| `mr_default_target_self`     | 布尔值            | 否     | 对于派生项目，将合并请求的目标设置为该项目。如果为 `false`，则目标为上游项目。                                                |
| `name`                       | 字符串            | 否     | 派生后分配给结果项目的名称。                                                                                              |
| `namespace_id`               | 整数              | 否     | 项目派生到的命名空间的 ID。                                                                                               |
| `namespace_path`             | 字符串            | 否     | 项目派生到的命名空间的路径。                                                                                              |
| `namespace`                  | 整数或字符串       | 否     | （已弃用）项目派生到的命名空间的 ID 或路径。                                                                               |
| `path`                       | 字符串            | 否     | 派生后分配给结果项目的路径。                                                                                              |
| `visibility`                 | 字符串            | 否     | 派生后分配给结果项目的[可见性级别](projects.md#project-visibility-level)。                                                  |

> [!note]
> 在使用服务账号派生项目时，您必须提供 `namespace_id` 或 `namespace_path`。
> 服务账号无法将项目派生到其个人命名空间。更多信息，请参见[将服务账号添加到群组或项目](../user/profile/service_accounts.md#add-a-service-account-to-a-group-or-project)。

<a id="list-all-forks-of-a-project"></a>

## 列出项目的所有派生

列出指定项目的所有派生。仅返回您可以访问的派生。

```plaintext
GET /projects/:id/forks
```

支持的属性：

| 属性                            | 类型              | 必需   | 描述                                                                                                                                                                                                                                                                                                                  |
|:--------------------------------|:------------------|:-------|:----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| `id`                            | 整数或字符串       | 是     | 项目的 ID 或 [URL 编码路径](rest/_index.md#namespaced-paths)。                                                                                                                                                                                                                                                             |
| `archived`                      | 布尔值            | 否     | 按归档状态限制。                                                                                                                                                                                                                                                                                                       |
| `membership`                    | 布尔值            | 否     | 按当前用户是成员的项目限制。                                                                                                                                                                                                                                                                                           |
| `min_access_level`              | 整数              | 否     | 按当前用户至少具有指定访问级别的项目限制。可能的值：`5`（最低访问权限），`10`（访客），`15`（计划者），`20`（报告者），`25`（安全经理），`30`（开发者），`40`（维护者）或 `50`（所有者）。                                                                                                                            |
| `order_by`                      | 字符串            | 否     | 按 `id`、`name`、`path`、`created_at`、`updated_at`、`star_count` 或 `last_activity_at` 字段排序返回项目。默认为 `created_at`。                                                                                                                                                                                          |
| `owned`                         | 布尔值            | 否     | 按当前用户明确拥有的项目限制。                                                                                                                                                                                                                                                                                         |
| `search`                        | 字符串            | 否     | 返回与搜索条件匹配的项目列表。                                                                                                                                                                                                                                                                                         |
| `simple`                        | 布尔值            | 否     | 仅为每个项目返回有限字段。未认证时，此操作无实际效果；仅返回简单字段。                                                                                                                                                                                                                                                   |
| `sort`                          | 字符串            | 否     | 返回按 `asc` 或 `desc` 顺序排序的项目。默认为 `desc`。                                                                                                                                                                                                                                                                 |
| `starred`                       | 布尔值            | 否     | 按当前用户标星的项目限制。                                                                                                                                                                                                                                                                                             |
| `statistics`                    | 布尔值            | 否     | 包含项目统计信息。仅对具有报告者、开发者、维护者或所有者角色的用户可用。                                                                                                                                                                                                                                              |
| `updated_after`                 | 日期时间          | 否     | 将结果限制为在指定时间之后最后更新的项目。格式：ISO 8601 (`YYYY-MM-DDTHH:MM:SSZ`)。引入于极狐GitLab 15.10。                                                                                                                                                                                                            |
| `updated_before`                | 日期时间          | 否     | 将结果限制为在指定时间之前最后更新的项目。格式：ISO 8601 (`YYYY-MM-DDTHH:MM:SSZ`)。引入于极狐GitLab 15.10。                                                                                                                                                                                                            |
| `visibility`                    | 字符串            | 否     | 按可见性 `public`、`internal` 或 `private` 限制。                                                                                                                                                                                                                                                                    |
| `with_custom_attributes`        | 布尔值            | 否     | 在响应中包含[自定义属性](custom_attributes.md)。（仅管理员）                                                                                                                                                                                                                                                            |
| `with_issues_enabled`           | 布尔值            | 否     | 按已启用议题功能限制。                                                                                                                                                                                                                                                                                                 |
| `with_merge_requests_enabled`   | 布尔值            | 否     | 按已启用合并请求功能限制。                                                                                                                                                                                                                                                                                             |

示例请求：

```shell
curl --header "PRIVATE-TOKEN: <your_access_token>" "https://gitlab.example.com/api/v4/projects/5/forks"
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
    "tag_list": [ //已弃用，请改用 `topics`
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
    "container_registry_enabled": false, //已弃用，请改用 container_registry_access_level
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

## 创建派生关系

在两个指定的项目之间创建派生关系。

先决条件：

- 您必须是管理员或在项目上被分配为所有者角色。

```plaintext
POST /projects/:id/fork/:forked_from_id
```

支持的属性：

| 属性              | 类型              | 必需   | 描述                                                                   |
|:------------------|:------------------|:-------|:-----------------------------------------------------------------------|
| `forked_from_id`  | ID                | 是     | 派生来源的项目 ID。                                                    |
| `id`              | 整数或字符串       | 是     | 项目的 ID 或 [URL 编码路径](rest/_index.md#namespaced-paths)。            |

<a id="delete-a-fork-relationship"></a>

## 删除派生关系

删除两个指定项目之间的派生关系。

先决条件：

- 您必须是管理员或在项目上被分配为所有者角色。

```plaintext
DELETE /projects/:id/fork
```

支持的属性：

| 属性   | 类型              | 必需   | 描述                                                                   |
|:-------|:------------------|:-------|:-----------------------------------------------------------------------|
| `id`   | 整数或字符串       | 是     | 项目的 ID 或 [URL 编码路径](rest/_index.md#namespaced-paths)。            |