---
stage: Tenant Scale
group: Organizations
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
description: 用于创建、检索、更新、删除和管理项目及项目功能的 REST API。
title: 项目 API
---

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: JihuLab.com，私有化部署

{{< /details >}}

使用此 API 管理极狐GitLab 项目及其相关设置。项目是协作的中心枢纽，您可以在其中存储代码、跟踪议题并组织团队活动。
更多信息，请参阅[创建项目](../user/project/_index.md)。

项目 API 包含以下端点：

- 检索项目信息和元数据
- 创建、编辑和删除项目
- 控制项目可见性、访问权限和安全设置
- 管理议题跟踪、合并请求和 CI/CD 等项目功能
- 归档和取消归档项目
- 在命名空间之间转移项目
- 管理部署和容器镜像仓库设置

<a id="prerequisites"></a>

## 先决条件

- 对项目具有任何[默认角色](../user/permissions.md#roles)以读取项目属性。
- 对项目具有维护者或所有者角色以编辑项目属性。

<a id="project-visibility-level"></a>

## 项目可见性级别

极狐GitLab 中的项目可以具有以下可见性级别之一：

- 私有
- 内部
- 公开

可见性级别由项目中的 `visibility` 字段决定。

更多信息，请参阅[项目可见性](../user/public_access.md)。

响应中返回的字段根据已认证用户的[权限](../user/permissions.md)而有所不同。

<a id="project-feature-visibility-level"></a>

## 项目功能可见性级别

您可以在创建或编辑项目时控制项目设置的可用性。
例如，要为现有项目禁用 `forking_access_level`：

```shell
curl --request PUT \
  --header "PRIVATE-TOKEN: <your_access_token>" \
  --header "Content-Type: application/json" \
  --data '{"forking_access_level": "disabled"}' \
  --url "https://gitlab.example.com/api/v4/projects/<project_id>"
```

每个设置可以独立定义，并接受以下值：

- `disabled`：禁用该功能。
- `private`：启用并将该功能设置为**仅项目成员**。
- `enabled`：启用并将该功能设置为**所有具有访问权限的人**。
- `public`：启用并将该功能设置为**所有人**。仅适用于 `pages_access_level`。

更多信息，请参阅[更改项目中单个功能的可见性](../user/public_access.md#change-the-visibility-of-individual-features-in-a-project)。

| 属性                              | 类型   | 必填 | 描述 |
|:---------------------------------------|:-------|:---------|:------------|
| `analytics_access_level`               | string | 否       | 设置[分析](../user/analytics/_index.md)的可见性。 |
| `builds_access_level`                  | string | 否       | 设置[流水线](../ci/pipelines/settings.md#change-which-users-can-view-your-pipelines)的可见性。 |
| `container_registry_access_level`      | string | 否       | 设置[容器镜像仓库](../user/packages/container_registry/_index.md#change-visibility-of-the-container-registry)的可见性。 |
| `environments_access_level`            | string | 否       | 设置[环境](../ci/environments/_index.md)的可见性。 |
| `feature_flags_access_level`           | string | 否       | 设置[功能标志](../operations/feature_flags.md)的可见性。 |
| `forking_access_level`                 | string | 否       | 设置[复刻](../user/project/repository/forking_workflow.md)的可见性。 |
| `infrastructure_access_level`          | string | 否       | 设置[基础设施管理](../user/infrastructure/_index.md)的可见性。 |
| `issues_access_level`                  | string | 否       | 设置[议题](../user/project/issues/_index.md)的可见性。 |
| `merge_requests_access_level`          | string | 否       | 设置[合并请求](../user/project/merge_requests/_index.md)的可见性。 |
| `model_experiments_access_level`       | string | 否       | 设置[机器学习模型实验](../user/project/ml/experiment_tracking/_index.md)的可见性。 |
| `model_registry_access_level`          | string | 否       | 设置[机器学习模型仓库](../user/project/ml/model_registry/_index.md#access-the-model-registry)的可见性。 |
| `monitor_access_level`                 | string | 否       | 设置[应用程序性能监控](../operations/_index.md)的可见性。 |
| `pages_access_level`                   | string | 否       | 设置[GitLab Pages](../user/project/pages/pages_access_control.md)的可见性。 |
| `releases_access_level`                | string | 否       | 设置[发布](../user/project/releases/_index.md)的可见性。 |
| `repository_access_level`              | string | 否       | 设置[代码仓库](../user/project/repository/_index.md)的可见性。 |
| `requirements_access_level`            | string | 否       | 设置[需求管理](../user/project/requirements/_index.md)的可见性。 |
| `security_and_compliance_access_level` | string | 否       | 设置[安全与合规](../user/application_security/_index.md)的可见性。 |
| `snippets_access_level`                | string | 否       | 设置[代码片段](../user/snippets.md#change-default-visibility-of-snippets)的可见性。 |
| `wiki_access_level`                    | string | 否       | 设置[Wiki](../user/project/wiki/_index.md#enable-or-disable-a-project-wiki)的可见性。 |

<a id="deprecated-attributes"></a>

## 已弃用的属性

这些属性已弃用，可能会在 REST API 的未来版本中移除。
请改用替代属性。

| 已弃用的属性     | 替代 |
|:-------------------------|:------------|
| `tag_list`               | 改用 `topics`。 |
| `marked_for_deletion_at` | 改用 `marked_for_deletion_on`。仅限专业版和旗舰版。 |
| `approvals_before_merge` | 在极狐GitLab 16.0 中[已弃用](https://gitlab.com/gitlab-org/gitlab/-/work_items/353097)。请改用[合并请求审批 API](merge_request_approvals.md)。仅限专业版和旗舰版。 |
| `packages_enabled` | 在极狐GitLab 17.10 中[已弃用](https://gitlab.com/gitlab-org/gitlab/-/work_items/454759)。请改用 `package_registry_access_level`。 |
| `container_registry_enabled` | 请改用 `container_registry_access_level`。 |
| `public_builds` | 请改用 `public_jobs`。 |
| `emails_disabled` | 请改用 `emails_enabled`。 |
| `issues_enabled` | 请改用 `issues_access_level`。 |
| `jobs_enabled` | 请改用 `builds_access_level`。 |
| `merge_requests_enabled` | 请改用 `merge_request_access_level`。 |
| `snippets_enabled` | 请改用 `snippets_access_level`。 |
| `wiki_enabled` | 请改用 `wiki_access_level`。 |
| `restrict_user_defined_variables` | 在极狐GitLab 17.7 中[已弃用](https://gitlab.com/gitlab-org/gitlab/-/merge_requests/154510)。请改用 `ci_pipeline_variables_minimum_override_role`。 |

<a id="retrieve-a-project"></a>

## 检索项目

检索指定项目。如果项目是公开可访问的，则此端点可以在无需认证的情况下访问。

```plaintext
GET /projects/:id
```

支持的属性：

| 属性                | 类型              | 必填 | 描述 |
|:-------------------------|:------------------|:---------|:------------|
| `id`                     | integer or string | 是      | 项目的 ID 或 [URL 编码路径](rest/_index.md#namespaced-paths)。 |
| `license`                | boolean           | 否       | 包含项目许可证数据。 |
| `statistics`             | boolean           | 否       | 包含项目统计信息。仅对具有报告者、开发者、维护者或所有者角色的用户可用。 |
| `with_custom_attributes` | boolean           | 否       | 在响应中包含[自定义属性](custom_attributes.md)。需要管理员访问权限。 |

如果成功，返回 [`200 OK`](rest/troubleshooting.md#status-codes) 以及以下响应属性：

<!-- markdownlint-disable MD055 MD056 -->

| 属性                | 类型              | 描述 |
|:-------------------------|:------------------|:------------|
| `id` | integer | 项目的 ID。 |
| `description` | string | 项目的描述。 |
| `description_html` | string | 项目的 HTML 格式描述。 |
| `name` | string | 项目的名称。 |
| `name_with_namespace` | string | 项目及其命名空间的名称。 |
| `path` | string | 项目的路径。 |
| `path_with_namespace` | string | 项目及其命名空间的路径。 |
| `created_at` | datetime | 项目创建时的时间戳。 |
| `default_branch` | string | 项目的默认分支。 |
| `tag_list` | array of strings | 已弃用。请改用 `topics`。项目的标签列表。 |
| `topics` | array of strings | 项目的主题列表。 |
| `ssh_url_to_repo` | string | 用于克隆代码仓库的 SSH URL。 |
| `http_url_to_repo` | string | 用于克隆代码仓库的 HTTP URL。 |
| `web_url` | string | 在浏览器中访问项目的 URL。 |
| `readme_url` | string | 项目 README 文件的 URL。 |
| `forks_count` | integer | 项目的复刻数量。 |
| `avatar_url` | string | 项目头像图片的 URL。 |
| `star_count` | integer | 项目获得的星标数量。 |
| `last_activity_at` | datetime | 项目中最后活动的时间戳。 |
| `visibility` | string | 项目的可见性级别。可能的值：`private`、`internal` 或 `public`。 |
| `namespace` | object | 项目的命名空间信息。 |
| `namespace.id` | integer | 命名空间的 ID。 |
| `namespace.name` | string | 命名空间的名称。 |
| `namespace.path` | string | 命名空间的路径。 |
| `namespace.kind` | string | 命名空间的类型。可能的值：`user` 或 `group`。 |
| `namespace.full_path` | string | 命名空间的完整路径。 |
| `namespace.parent_id` | integer | 父命名空间的 ID（如果适用）。 |
| `namespace.avatar_url` | string | 命名空间头像图片的 URL。 |
| `namespace.web_url` | string | 在浏览器中访问命名空间的 URL。 |
| `container_registry_image_prefix` | string | 容器镜像仓库镜像的前缀。 |
| `_links` | object | 与项目相关的 API 端点链接集合。 |
| `_links.self` | string | 项目资源的 URL。 |
| `_links.issues` | string | 项目议题的 URL。 |
| `_links.merge_requests` | string | 项目合并请求的 URL。 |
| `_links.repo_branches` | string | 项目代码仓库分支的 URL。 |
| `_links.labels` | string | 项目标记的 URL。 |
| `_links.events` | string | 项目事件的 URL。 |
| `_links.members` | string | 项目成员的 URL。 |
| `_links.cluster_agents` | string | 项目集群代理的 URL。 |
| `marked_for_deletion_at` | date | 已弃用。请改用 `marked_for_deletion_on`。项目计划删除的日期。 |
| `marked_for_deletion_on` | date | 项目计划删除的日期。 |
| `packages_enabled` | boolean | 项目是否启用了软件包仓库。 |
| `empty_repo` | boolean | 代码仓库是否为空。 |
| `archived` | boolean | 项目是否已归档。 |
| `owner` | object | 项目所有者的信息。 |
| `owner.id` | integer | 项目所有者的 ID。 |
| `owner.username` | string | 所有者的用户名。 |
| `owner.public_email` | string | 所有者的公开电子邮件地址。 |
| `owner.name` | string | 项目所有者的名称。 |
| `owner.state` | string | 所有者账户的当前状态。 |
| `owner.locked` | boolean | 指示所有者账户是否被锁定。 |
| `owner.avatar_url` | string | 所有者头像图片的 URL。 |
| `owner.web_url` | string | 所有者个人资料的 Web URL。 |
| `owner.created_at` | datetime | 所有者创建时的时间戳。 |
| `resolve_outdated_diff_discussions` | boolean | 过时的差异讨论是否自动解决。 |
| `container_expiration_policy` | object | 容器镜像过期策略的设置。 |
| `container_expiration_policy.cadence` | string | 容器过期策略运行的频率。 |
| `container_expiration_policy.enabled` | boolean | 容器过期策略是否已启用。 |
| `container_expiration_policy.keep_n` | integer | 要保留的容器镜像数量。 |
| `container_expiration_policy.older_than` | string | 删除早于此值的容器镜像。 |
| `container_expiration_policy.name_regex` | string | 已弃用。请改用 `name_regex_delete`。用于匹配容器镜像名称的正则表达式。 |
| `container_expiration_policy.name_regex_delete` | string | 用于匹配要删除的容器镜像名称的正则表达式。 |
| `container_expiration_policy.name_regex_keep` | string | 用于匹配要保留的容器镜像名称的正则表达式。 |
| `container_expiration_policy.next_run_at` | datetime | 下次计划策略运行的时间戳。 |
| `repository_object_format` | string | 代码仓库使用的对象格式。可能的值：`sha1` 或 `sha256`。 |
| `issues_enabled` | boolean | 项目是否启用了议题。 |
| `merge_requests_enabled` | boolean | 项目是否启用了合并请求。 |
| `wiki_enabled` | boolean | 项目是否启用了 Wiki。 |
| `jobs_enabled` | boolean | 项目是否启用了作业。 |
| `snippets_enabled` | boolean | 项目是否启用了代码片段。 |
| `container_registry_enabled` | boolean | 已弃用。请改用 `container_registry_access_level`。容器镜像仓库是否已启用。 |
| `service_desk_enabled` | boolean | 项目是否启用了服务台。 |
| `service_desk_address` | string | 服务台的电子邮件地址。 |
| `can_create_merge_request_in` | boolean | 当前用户是否可以在项目中创建合并请求。 |
| `issues_access_level` | string | 议题功能的访问级别。可能的值：`disabled`、`private` 或 `enabled`。 |
| `repository_access_level` | string | 代码仓库功能的访问级别。可能的值：`disabled`、`private` 或 `enabled`。 |
| `merge_requests_access_level` | string | 合并请求功能的访问级别。可能的值：`disabled`、`private` 或 `enabled`。 |
| `forking_access_level` | string | 复刻项目的访问级别。可能的值：`disabled`、`private` 或 `enabled`。 |
| `wiki_access_level` | string | Wiki 功能的访问级别。可能的值：`disabled`、`private` 或 `enabled`。 |
| `builds_access_level` | string | CI/CD 构建功能的访问级别。可能的值：`disabled`、`private` 或 `enabled`。 |
| `snippets_access_level` | string | 代码片段功能的访问级别。可能的值：`disabled`、`private` 或 `enabled`。 |
| `pages_access_level` | string | GitLab Pages 的访问级别。可能的值：`disabled`、`private`、`enabled` 或 `public`。 |
| `analytics_access_level` | string | 分析功能的访问级别。可能的值：`disabled`、`private` 或 `enabled`。 |
| `container_registry_access_level` | string | 容器镜像仓库的访问级别。可能的值：`disabled`、`private` 或 `enabled`。 |
| `security_and_compliance_access_level` | string | 安全与合规功能的访问级别。可能的值：`disabled`、`private` 或 `enabled`。 |
| `releases_access_level` | string | 发布功能的访问级别。可能的值：`disabled`、`private` 或 `enabled`。 |
| `environments_access_level` | string | 环境功能的访问级别。可能的值：`disabled`、`private` 或 `enabled`。 |
| `feature_flags_access_level` | string | 功能标志功能的访问级别。可能的值：`disabled`、`private` 或 `enabled`。 |
| `infrastructure_access_level` | string | 基础设施功能的访问级别。可能的值：`disabled`、`private` 或 `enabled`。 |
| `monitor_access_level` | string | 监控功能的访问级别。可能的值：`disabled`、`private` 或 `enabled`。 |
| `model_experiments_access_level` | string | 模型实验功能的访问级别。可能的值：`disabled`、`private` 或 `enabled`。 |
| `model_registry_access_level` | string | 模型仓库功能的访问级别。可能的值：`disabled`、`private` 或 `enabled`。 |
| `package_registry_access_level` | string | 软件包仓库功能的访问级别。可能的值：`disabled`、`private` 或 `enabled`。 |
| `emails_disabled` | boolean | 指示项目的电子邮件是否已禁用。 |
| `emails_enabled` | boolean | 指示项目的电子邮件是否已启用。 |
| `show_diff_preview_in_email` | boolean | 指示电子邮件通知中是否显示差异预览。 |
| `shared_runners_enabled` | boolean | 项目是否启用了共享 Runner。 |
| `lfs_enabled` | boolean | 指示项目是否启用了 Git LFS。 |
| `creator_id` | integer | 创建项目的用户的 ID。 |
| `import_url` | string | 项目导入来源的 URL。 |
| `import_type` | string | 项目使用的导入类型。 |
| `import_status` | string | 项目导入的状态。 |
| `import_error` | string | 导入失败时的错误消息。 |
| `open_issues_count` | integer | 未关闭的议题数量。 |
| `updated_at` | datetime | 项目最后更新的时间戳。 |
| `ci_default_git_depth` | integer | CI/CD 流水线的默认 Git 深度。仅当您具有管理员访问权限或项目的所有者角色时可见。 |
| `ci_delete_pipelines_in_seconds` | integer | 旧流水线被删除前的秒数。 |
| `ci_forward_deployment_enabled` | boolean | 是否启用了前向部署。仅当您具有管理员访问权限或项目的所有者角色时可见。 |
| `ci_forward_deployment_rollback_allowed` | boolean | 是否允许前向部署的回滚。 |
| `ci_job_token_scope_enabled` | boolean | 指示是否启用了 CI/CD 作业令牌范围。仅当您具有管理员访问权限或项目的所有者角色时可见。 |
| `ci_separated_caches` | boolean | CI/CD 缓存是否按分支分离。仅当您具有管理员访问权限或项目的所有者角色时可见。 |
| `ci_allow_fork_pipelines_to_run_in_parent_project` | boolean | 复刻的流水线是否可以在父项目中运行。仅当您具有管理员访问权限或项目的所有者角色时可见。 |
| `ci_id_token_sub_claim_components` | array of strings | CI/CD ID 令牌主题声明中包含的组件。 |
| `build_git_strategy` | string | CI/CD 构建使用的 Git 策略（fetch 或 clone）。仅当您具有管理员访问权限或项目的所有者角色时可见。 |
| `keep_latest_artifact` | boolean | 指示创建新产物时是否保留最新产物。仅当您具有管理员访问权限或项目的所有者角色时可见。 |
| `restrict_user_defined_variables` | boolean | 用户定义的变量是否受限。仅当您具有管理员访问权限或项目的所有者角色时可见。 |
| `ci_pipeline_variables_minimum_override_role` | string | 覆盖流水线变量所需的最低角色。 |
| `runner_token_expiration_interval` | integer | Runner 令牌的过期时间间隔（秒）。仅当您具有管理员访问权限或项目的所有者角色时可见。 |
| `group_runners_enabled` | boolean | 项目是否启用了群组 Runner。仅当您具有管理员访问权限或项目的所有者角色时可见。 |
| `resource_group_default_process_mode` | string | 资源组的默认处理模式。 |
| `auto_cancel_pending_pipelines` | string | 自动取消待处理流水线的设置。仅当您具有管理员访问权限或项目的所有者角色时可见。 |
| `build_timeout` | integer | CI/CD 作业的超时时间（秒）。仅当您具有管理员访问权限或项目的所有者角色时可见。 |
| `auto_devops_enabled` | boolean | 项目是否启用了 Auto DevOps。仅当您具有管理员访问权限或项目的所有者角色时可见。 |
| `auto_devops_deploy_strategy` | string | Auto DevOps 的部署策略。仅当您具有管理员访问权限或项目的所有者角色时可见。 |
| `ci_push_repository_for_job_token_allowed` | boolean | 是否允许使用作业令牌推送到代码仓库。 |
| `cicd_catalog_enabled` | boolean | 项目是否发布到 [CI/CD Catalog](../ci/components/_index.md#cicd-catalog)。在极狐GitLab 19.3 中[引入](https://gitlab.com/gitlab-org/gitlab/-/issues/463043)。 |
| `runners_token` | string | 用于向项目注册 Runner 的令牌。仅当您具有管理员访问权限或项目的所有者角色时可见。 |
| `ci_config_path` | string | CI/CD 配置文件的路径。 |
| `public_jobs` | boolean | 作业日志是否可公开访问。 |
| `shared_with_groups` | array of objects | 与项目共享的群组列表。 |
| `shared_with_groups[].group_id` | integer | 与项目共享的群组的 ID。 |
| `shared_with_groups[].group_name` | string | 与项目共享的群组的名称。 |
| `shared_with_groups[].group_full_path` | string | 与项目共享的群组的完整路径。 |
| `shared_with_groups[].group_access_level` | integer | 授予群组的访问级别。 |
| `only_allow_merge_if_pipeline_succeeds` | boolean | 是否仅当流水线成功时才允许合并。 |
| `allow_merge_on_skipped_pipeline` | boolean | 当流水线被跳过时是否允许合并。 |
| `request_access_enabled` | boolean | 用户是否可以请求访问项目。 |
| `only_allow_merge_if_all_discussions_are_resolved` | boolean | 是否仅当所有讨论都已解决时才允许合并。 |
| `remove_source_branch_after_merge` | boolean | 合并后是否自动删除源分支。 |
| `printing_merge_request_link_enabled` | boolean | 指示推送后是否打印合并请求链接。 |
| `printing_merge_requests_link_enabled` | boolean | 推送后是否打印合并请求链接。 |
| `merge_method` | string | 项目使用的合并方法。可能的值：`merge`、`rebase_merge` 或 `ff`。 |
| `merge_request_title_regex` | string | 用于验证合并请求标题的正则表达式模式。 |
| `merge_request_title_regex_description` | string | 合并请求标题正则表达式验证的描述。 |
| `squash_option` | string | 合并请求的压缩选项。 |
| `automatic_rebase_enabled` | boolean | 指示合并前是否自动变基源分支。 |
| `enforce_auth_checks_on_uploads` | boolean | 上传时是否强制执行身份验证检查。 |
| `suggestion_commit_message` | string | 建议的自定义提交消息。 |
| `merge_commit_template` | string | 合并提交消息的模板。 |
| `mr_default_title_template` | string | 合并请求标题的模板。 |
| `squash_commit_template` | string | 压缩提交消息的模板。 |
| `issue_branch_template` | string | 从议题创建的分支名称的模板。 |
| `warn_about_potentially_unwanted_characters` | boolean | 是否警告可能不需要的字符。 |
| `autoclose_referenced_issues` | boolean | 引用的议题是否自动关闭。 |
| `max_artifacts_size` | integer | CI/CD 产物的最大大小（MB）。 |
| `approvals_before_merge` | integer | 已弃用。请改用合并请求审批 API。合并前所需的审批数量。 |
| `mirror` | boolean | 项目是否为镜像。 |
| `external_authorization_classification_label` | string | 外部授权分类标记。 |
| `requirements_enabled` | boolean | 指示是否启用了需求管理。 |
| `requirements_access_level` | string | 需求功能的访问级别。 |
| `security_and_compliance_enabled` | boolean | 指示是否启用了安全与合规功能。 |
| `secret_push_protection_enabled` | boolean | 是否启用了密钥推送保护。 |
| `pre_receive_secret_detection_enabled` | boolean | 指示是否启用了预接收密钥检测。 |
| `compliance_frameworks` | array of strings | 应用于项目的合规框架。 |
| `issues_template` | string | 议题的默认描述。描述使用极狐GitLab 风格 Markdown 解析。仅限专业版和旗舰版。 |
| `merge_requests_template` | string | 合并请求描述的模板。仅限专业版和旗舰版。 |
| `ci_restrict_pipeline_cancellation_role` | string | 取消流水线所需的最低角色。 |
| `merge_pipelines_enabled` | boolean | 指示是否启用了合并流水线。 |
| `merge_trains_enabled` | boolean | 指示是否启用了合并列车。 |
| `merge_trains_skip_train_allowed` | boolean | 指示是否允许跳过合并列车。 |
| `merge_train_enforcement` | string | 合并列车强制级别。取值为 `allow_bypass`、`enforce_for_all_users` 或 `enforce_with_owner_override` 之一。除非为项目启用了合并列车，否则无效。 |
| `max_pipelines_per_merge_train` | integer | 每个合并列车的最大并行流水线数量。 |
| `only_allow_merge_if_all_status_checks_passed` | boolean | 是否仅当所有状态检查都已通过时才允许合并。仅限旗舰版。 |
| `allow_pipeline_trigger_approve_deployment` | boolean | 流水线触发器是否可以批准部署。 |
| `prevent_merge_without_jira_issue` | boolean | 指示合并是否要求关联的 Jira 议题。 |
| `reviewer_assignment_strategy` | string | 用于自动分配审核人到合并请求的策略。取值为 `disabled` 或 `code_owners` 之一。对于在极狐GitLab 19.4 之前配置的项目，此属性也可以返回 `dap_powered`。仅限专业版和旗舰版。 |
| `duo_remote_flows_enabled` | boolean | 指示是否启用了极狐GitLab Duo 远程任务流。 |
| `duo_foundational_flows_enabled` | boolean | 指示是否启用了极狐GitLab Duo 内置任务流。 |
| `duo_sast_fp_detection_enabled` | boolean | 指示是否启用了极狐GitLab Duo SAST 误报检测。 |
| `duo_sast_vr_workflow_enabled` | boolean | 指示是否启用了极狐GitLab Duo SAST 漏洞解决工作流。 |
| `web_based_commit_signing_enabled` | boolean | 指示是否启用了基于 Web 的提交签名。 |
| `spp_repository_pipeline_access` | boolean | 安全策略的代码仓库流水线访问。仅当安全编排策略功能可用时可见。 |
| `permissions` | object | 项目的用户权限。 |
| `permissions.project_access` | object | 用户的项目级访问权限。 |
| `permissions.project_access.access_level` | integer | 项目的访问级别。 |
| `permissions.project_access.notification_level` | integer | 项目的通知级别。 |
| `permissions.group_access` | object | 用户的群组级访问权限。 |
| `permissions.group_access.access_level` | integer | 群组的访问级别。 |
| `permissions.group_access.notification_level` | integer | 群组的通知级别。 |
| `license_url` | string | 项目许可证文件的 URL。 |
| `license.key` | string | 许可证的密钥标识符。 |
| `license.name` | string | 许可证的全名。 |
| `license.nickname` | string | 许可证的昵称。 |
| `license.html_url` | string | 查看许可证详细信息的 URL。 |
| `license.source_url` | string | 许可证源文本的 URL。 |
| `repository_storage` | string | 项目代码仓库的存储位置。 |
| `mirror_user_id` | integer | 设置镜像的用户的 ID。 |
| `mirror_trigger_builds` | boolean | 镜像更新是否触发构建。 |
| `only_mirror_protected_branches` | boolean | 是否仅镜像受保护的分支。 |
| `mirror_overwrites_diverged_branches` | boolean | 镜像是否覆盖已分叉的分支。 |
| `statistics.commit_count` | integer | 项目中的提交数量。 |
| `statistics.storage_size` | integer | 总存储大小（字节）。 |
| `statistics.repository_size` | integer | 代码仓库存储大小（字节）。 |
| `statistics.wiki_size` | integer | Wiki 存储大小（字节）。 |
| `statistics.lfs_objects_size` | integer | LFS 对象存储大小（字节）。 |
| `statistics.job_artifacts_size` | integer | 作业产物存储大小（字节）。 |
| `statistics.pipeline_artifacts_size` | integer | 流水线产物存储大小（字节）。 |
| `statistics.packages_size` | integer | 软件包存储大小（字节）。 |
| `statistics.snippets_size` | integer | 代码片段存储大小（字节）。 |
| `statistics.uploads_size` | integer | 上传存储大小（字节）。 |
| `statistics.container_registry_size` | integer | 项目中所有容器仓库使用的容器镜像仓库总存储大小（字节）。在推送或删除容器镜像时更新。对于极狐GitLab 私有化部署实例，需要启用容器镜像仓库元数据数据库。 |
| `forked_from_project` | object | 此项目复刻自的上游项目。如果上游项目是私有的，则需要身份验证令牌才能查看此字段。 |
| `mr_default_target_self` | boolean | 合并请求是否默认以该项目为目标。如果为 `false`，则合并请求以上游项目为目标。仅当项目是复刻时出现。 |
{.condensed}

<!-- markdownlint-enable MD055 MD056 -->

示例请求：

```shell
curl --header "PRIVATE-TOKEN: <your_access_token>" \
     --header "Accept: application/json" \
     --url "https://gitlab.example.com/api/v4/projects/<project_id>"
```

示例响应：

```json
{
  "id": 3,
  "description": "Lorem ipsum dolor sit amet, consectetur adipiscing elit.",
  "description_html": "<p data-sourcepos=\"1:1-1:56\" dir=\"auto\">Lorem ipsum dolor sit amet, consectetur adipiscing elit.</p>",
  "default_branch": "main",
  "visibility": "private",
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
  "owner": {
    "id": 3,
    "name": "Diaspora",
    "created_at": "2013-09-30T13:46:02Z"
  },
  "name": "Diaspora Project Site",
  "name_with_namespace": "Diaspora / Diaspora Project Site",
  "path": "diaspora-project-site",
  "path_with_namespace": "diaspora/diaspora-project-site",
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
  "container_expiration_policy": {
    "cadence": "7d",
    "enabled": false,
    "keep_n": null,
    "older_than": null,
    "name_regex": null, // to be deprecated in GitLab 13.0 in favor of `name_regex_delete`
    "name_regex_delete": null,
    "name_regex_keep": null,
    "next_run_at": "2020-01-07T21:42:58.658Z"
  },
  "created_at": "2013-09-30T13:46:02Z",
  "updated_at": "2013-09-30T13:46:02Z",
  "last_activity_at": "2013-09-30T13:46:02Z",
  "creator_id": 3,
  "namespace": {
    "id": 3,
    "name": "Diaspora",
    "path": "diaspora",
    "kind": "group",
    "full_path": "diaspora",
    "avatar_url": "http://localhost:3000/uploads/group/avatar/3/foo.jpg",
    "web_url": "http://localhost:3000/groups/diaspora"
  },
  "import_url": null,
  "import_type": null,
  "import_status": "none",
  "import_error": null,
  "permissions": {
    "project_access": {
      "access_level": 10,
      "notification_level": 3
    },
    "group_access": {
      "access_level": 50,
      "notification_level": 3
    }
  },
  "archived": false,
  "avatar_url": "http://example.com/uploads/project/avatar/3/uploads/avatar.png",
  "license_url": "http://example.com/diaspora/diaspora-client/blob/main/LICENSE",
  "license": {
    "key": "lgpl-3.0",
    "name": "GNU Lesser General Public License v3.0",
    "nickname": "GNU LGPLv3",
    "html_url": "http://choosealicense.com/licenses/lgpl-3.0/",
    "source_url": "http://www.gnu.org/licenses/lgpl-3.0.txt"
  },
  "shared_runners_enabled": true,
  "group_runners_enabled": true,
  "forks_count": 0,
  "star_count": 0,
  "runners_token": "b8bc4a7a29eb76ea83cf79e4908c2b",
  "ci_default_git_depth": 50,
  "ci_forward_deployment_enabled": true,
  "ci_forward_deployment_rollback_allowed": true,
  "ci_allow_fork_pipelines_to_run_in_parent_project": true,
  "ci_id_token_sub_claim_components": ["project_path", "ref_type", "ref"],
  "ci_separated_caches": true,
  "ci_restrict_pipeline_cancellation_role": "developer",
  "ci_pipeline_variables_minimum_override_role": "maintainer",
  "ci_push_repository_for_job_token_allowed": false,
  "ci_display_pipeline_variables": false,
  "cicd_catalog_enabled": false,
  "protect_merge_request_pipelines": true,
  "public_jobs": true,
  "shared_with_groups": [
    {
      "group_id": 4,
      "group_name": "Twitter",
      "group_full_path": "twitter",
      "group_access_level": 30
    },
    {
      "group_id": 3,
      "group_name": "Gitlab Org",
      "group_full_path": "gitlab-org",
      "group_access_level": 10
    }
  ],
  "repository_storage": "default",
  "only_allow_merge_if_pipeline_succeeds": false,
  "allow_merge_on_skipped_pipeline": false,
  "allow_pipeline_trigger_approve_deployment": false,
  "restrict_user_defined_variables": false,
  "only_allow_merge_if_all_discussions_are_resolved": false,
  "remove_source_branch_after_merge": false,
  "printing_merge_requests_link_enabled": true,
  "request_access_enabled": false,
  "merge_method": "merge",
  "squash_option": "default_on",
  "auto_devops_enabled": true,
  "auto_devops_deploy_strategy": "continuous",
  "approvals_before_merge": 0, // Deprecated. Use merge request approvals API instead.
  "mirror": false,
  "mirror_user_id": 45,
  "mirror_trigger_builds": false,
  "only_mirror_protected_branches": false,
  "mirror_overwrites_diverged_branches": false,
  "external_authorization_classification_label": null,
  "packages_enabled": true,
  "empty_repo": false,
  "service_desk_enabled": false,
  "service_desk_address": null,
  "autoclose_referenced_issues": true,
  "suggestion_commit_message": null,
  "enforce_auth_checks_on_uploads": true,
  "merge_commit_template": null,
  "mr_default_title_template": null,
  "squash_commit_template": null,
  "issue_branch_template": "gitlab/%{id}-%{title}",
  "marked_for_deletion_at": "2020-04-03", // Deprecated in favor of marked_for_deletion_on. Planned for removal in a future version of the REST API.
  "marked_for_deletion_on": "2020-04-03",
  "compliance_frameworks": [ "sox" ],
  "warn_about_potentially_unwanted_characters": true,
  "secret_push_protection_enabled": false,
  "statistics": {
    "commit_count": 37,
    "storage_size": 1038090,
    "repository_size": 1038090,
    "wiki_size" : 0,
    "lfs_objects_size": 0,
    "job_artifacts_size": 0,
    "pipeline_artifacts_size": 0,
    "packages_size": 0,
    "snippets_size": 0,
    "uploads_size": 0,
    "container_registry_size": 0
  },
  "container_registry_image_prefix": "registry.example.com/diaspora/diaspora-client",
  "_links": {
    "self": "http://example.com/api/v4/projects",
    "issues": "http://example.com/api/v4/projects/1/issues",
    "merge_requests": "http://example.com/api/v4/projects/1/merge_requests",
    "repo_branches": "http://example.com/api/v4/projects/1/repository_branches",
    "labels": "http://example.com/api/v4/projects/1/labels",
    "events": "http://example.com/api/v4/projects/1/events",
    "members": "http://example.com/api/v4/projects/1/members",
    "cluster_agents": "http://example.com/api/v4/projects/1/cluster_agents"
  },
  "spp_repository_pipeline_access": false // Only visible if the security_orchestration_policies feature is available
}
```

<a id="list-projects"></a>

## 列出项目

列出项目及项目属性。

<a id="list-all-projects"></a>

### 列出所有项目

列出实例上已认证用户可访问的所有项目。未认证的请求仅返回公开项目，且属性子集有限。

此端点支持分页：

- 使用基于偏移量的分页可访问最多 50,000 个项目。
- 使用基于键集的分页可列出超过 50,000 个项目。

更多信息，请参阅[分页](rest/_index.md#pagination)。

```plaintext
GET /projects
```

支持的属性：

<!-- markdownlint-disable MD055 MD056 -->

| 属性                     | 类型     | 必填 | 描述 |
|:------------------------------|:---------|:---------|:------------|
| `archived`                    | boolean  | 否       | 按归档状态限制。 |
| `custom_attributes`           | hash     | 否       | 按匹配所有指定键值对的[自定义属性](custom_attributes.md)限制。_（仅限管理员）_ |
| `id_after`                    | integer  | 否       | 将结果限制为 ID 大于指定 ID 的项目。 |
| `id_before`                   | integer  | 否       | 将结果限制为 ID 小于指定 ID 的项目。 |
| `imported`                    | boolean  | 否       | 将结果限制为当前用户从外部系统导入的项目。 |
| `include_hidden`              | boolean  | 否       | 包含隐藏项目。_（仅限管理员）_ 仅限专业版和旗舰版。 |
| `include_pending_delete`      | boolean  | 否       | 包含待删除的项目。_（仅限管理员）_ |
| `last_activity_after`         | datetime | 否       | 将结果限制为指定时间之后有活动的项目。格式：ISO 8601 (`YYYY-MM-DDTHH:MM:SSZ`) |
| `last_activity_before`        | datetime | 否       | 将结果限制为指定时间之前有活动的项目。格式：ISO 8601 (`YYYY-MM-DDTHH:MM:SSZ`) |
| `membership`                  | boolean  | 否       | 按当前用户是其成员的项目限制。 |
| `min_access_level`            | integer  | 否       | 限制为当前用户至少具有指定访问级别的项目。可能的值：`5`（最小访问权限）、`10`（访客）、`15`（计划者）、`20`（报告者）、`25`（安全管理员）、`30`（开发者）、`40`（维护者）或 `50`（所有者）。 |
| `order_by`                    | string   | 否       | 按 `id`、`name`、`path`、`created_at`、`updated_at`、`star_count`、`last_activity_at` 或 `similarity` 字段排序返回项目。`repository_size`、`storage_size`、`packages_size` 或 `wiki_size` 字段仅允许管理员使用。`similarity` 仅在搜索时可用，并且仅限于当前用户是其成员的项目。默认为 `created_at`。 |
| `owned`                       | boolean  | 否       | 按当前用户明确拥有的项目限制。 |
| `repository_checksum_failed`  | boolean  | 否       | 限制代码仓库校验和计算失败的项目。仅限专业版和旗舰版。 |
| `repository_storage`          | string   | 否       | 将结果限制为存储在 `repository_storage` 上的项目。_（仅限管理员）_ |
| `search_namespaces`           | boolean  | 否       | 匹配搜索条件时包含祖先命名空间。默认为 `false`。 |
| `search`                      | string   | 否       | 返回 `path`、`name` 或 `description` 与搜索条件匹配的项目列表（不区分大小写，子字符串匹配）。可以提供多个词条，用转义空格分隔，即 `+` 或 `%20`，并将进行 AND 运算。示例：`one+two` 将匹配子字符串 `one` 和 `two`（任意顺序）。 |
| `simple`                      | boolean  | 否       | 如果为 `true`，则仅返回每个项目的有限字段。未认证的请求仅返回具有有限字段的公开项目，即使未设置 `simple` 也是如此。 |
| `sort`                        | string   | 否       | 按 `asc` 或 `desc` 顺序排序返回项目。默认为 `desc`。 |
| `starred`                     | boolean  | 否       | 按当前用户加星标的项目限制。 |
| `statistics`                  | boolean  | 否       | 包含项目统计信息。仅对具有报告者、开发者、维护者或所有者角色的用户可用。 |
| `topic_id`                    | integer  | 否       | 将结果限制为具有给定主题 ID 分配的主题的项目。 |
| `topic`                       | string   | 否       | 逗号分隔的主题名称。将结果限制为匹配所有给定主题的项目。请参阅 `topics` 属性。 |
| `updated_after`               | datetime | 否       | 将结果限制为指定时间之后最后更新的项目。格式：ISO 8601 (`YYYY-MM-DDTHH:MM:SSZ`)。要使此过滤器生效，您还必须提供 `updated_at` 作为 `order_by` 属性。 |
| `updated_before`              | datetime | 否       | 将结果限制为指定时间之前最后更新的项目。格式：ISO 8601 (`YYYY-MM-DDTHH:MM:SSZ`)。要使此过滤器生效，您还必须提供 `updated_at` 作为 `order_by` 属性。 |
| `visibility`                  | string   | 否       | 按可见性 `public`、`internal` 或 `private` 限制。 |
| `wiki_checksum_failed`        | boolean  | 否       | 限制 Wiki 校验和计算失败的项目。仅限专业版和旗舰版。 |
| `with_custom_attributes`      | boolean  | 否       | 在响应中包含[自定义属性](custom_attributes.md)。_（仅限管理员）_ |
| `with_issues_enabled`         | boolean  | 否       | 按已启用的议题功能限制。 |
| `with_merge_requests_enabled` | boolean  | 否       | 按已启用的合并请求功能限制。 |
| `with_programming_language`   | string   | 否       | 按使用给定编程语言的项目限制。 |
| `marked_for_deletion_on`      | date     | 否       | 按项目标记为删除的日期过滤。在极狐GitLab 17.1 中[引入](https://gitlab.com/gitlab-org/gitlab/-/issues/463939)。仅限专业版和旗舰版。 |
| `active`                      | boolean  | 否       | 按未归档且未标记为删除的项目限制。 |
{.condensed}

<!-- markdownlint-enable MD055 MD056 -->

要按自定义属性过滤，请指定每个属性的键和值：

```plaintext
GET /projects?custom_attributes[<key>]=<value>&custom_attributes[<other_key>]=<other_value>
```

如果成功，返回 [`200 OK`](rest/troubleshooting.md#status-codes) 以及以下响应属性：

<!-- markdownlint-disable MD055 MD056 -->

| 属性 | 类型 | 描述 |
|-----------|------|-------------|
| `id` | integer | 项目的 ID。 |
| `description` | string | 项目的描述。 |
| `name` | string | 项目的名称。 |
| `name_with_namespace` | string | 项目及其命名空间的名称。 |
| `path` | string | 项目的路径。 |
| `path_with_namespace` | string | 项目及其命名空间的路径。 |
| `created_at` | datetime | 项目创建时的时间戳。 |
| `default_branch` | string | 项目的默认分支。 |
| `tag_list` | array of strings | 已弃用。请改用 `topics`。项目的标签列表。 |
| `topics` | array of strings | 项目的主题列表。 |
| `ssh_url_to_repo` | string | 用于克隆代码仓库的 SSH URL。 |
| `http_url_to_repo` | string | 用于克隆代码仓库的 HTTP URL。 |
| `web_url` | string | 在浏览器中访问项目的 URL。 |
| `readme_url` | string | 项目 README 文件的 URL。 |
| `forks_count` | integer | 项目的复刻数量。 |
| `avatar_url` | string | 项目头像图片的 URL。 |
| `star_count` | integer | 项目获得的星标数量。 |
| `last_activity_at` | datetime | 项目中最后活动的时间戳。 |
| `visibility` | string | 项目的可见性级别。可能的值：`private`、`internal` 或 `public`。 |
| `namespace` | object | 项目的命名空间信息。 |
| `namespace.id` | integer | 命名空间的 ID。 |
| `namespace.name` | string | 命名空间的名称。 |
| `namespace.path` | string | 命名空间的路径。 |
| `namespace.kind` | string | 命名空间的类型。可能的值：`user` 或 `group`。 |
| `namespace.full_path` | string | 命名空间的完整路径。 |
| `namespace.parent_id` | integer | 父命名空间的 ID（如果适用）。 |
| `namespace.avatar_url` | string | 命名空间头像图片的 URL。 |
| `namespace.web_url` | string | 在浏览器中访问命名空间的 URL。 |
| `container_registry_image_prefix` | string | 容器镜像仓库镜像的前缀。 |
| `_links` | object | 与项目相关的 API 端点链接集合。 |
| `_links.self` | string | 项目资源的 URL。 |
| `_links.issues` | string | 项目议题的 URL。 |
| `_links.merge_requests` | string | 项目合并请求的 URL。 |
| `_links.repo_branches` | string | 项目代码仓库分支的 URL。 |
| `_links.labels` | string | 项目标记的 URL。 |
| `_links.events` | string | 项目事件的 URL。 |
| `_links.members` | string | 项目成员的 URL。 |
| `_links.cluster_agents` | string | 项目集群代理的 URL。 |
| `marked_for_deletion_at` | date | 已弃用。请改用 `marked_for_deletion_on`。项目计划删除的日期。 |
| `marked_for_deletion_on` | date | 项目计划删除的日期。 |
| `packages_enabled` | boolean | 项目是否启用了软件包仓库。 |
| `empty_repo` | boolean | 代码仓库是否为空。 |
| `archived` | boolean | 项目是否已归档。 |
| `resolve_outdated_diff_discussions` | boolean | 过时的差异讨论是否自动解决。 |
| `container_expiration_policy` | object | 容器镜像过期策略的设置。 |
| `container_expiration_policy.cadence` | string | 容器过期策略运行的频率。 |
| `container_expiration_policy.enabled` | boolean | 容器过期策略是否已启用。 |
| `container_expiration_policy.keep_n` | integer | 要保留的容器镜像数量。 |
| `container_expiration_policy.older_than` | string | 删除早于此值的容器镜像。 |
| `container_expiration_policy.name_regex` | string | 已弃用。请改用 `name_regex_delete`。用于匹配容器镜像名称的正则表达式。 |
| `container_expiration_policy.name_regex_keep` | string | 用于匹配要保留的容器镜像名称的正则表达式。 |
| `container_expiration_policy.next_run_at` | datetime | 下次计划策略运行的时间戳。 |
| `repository_object_format` | string | 代码仓库使用的对象格式（sha1 或 sha256）。 |
| `issues_enabled` | boolean | 项目是否启用了议题。 |
| `merge_requests_enabled` | boolean | 项目是否启用了合并请求。 |
| `wiki_enabled` | boolean | 项目是否启用了 Wiki。 |
| `jobs_enabled` | boolean | 项目是否启用了作业。 |
| `snippets_enabled` | boolean | 项目是否启用了代码片段。 |
| `container_registry_enabled` | boolean | 已弃用。请改用 `container_registry_access_level`。容器镜像仓库是否已启用。 |
| `service_desk_enabled` | boolean | 项目是否启用了服务台。 |
| `can_create_merge_request_in` | boolean | 当前用户是否可以在项目中创建合并请求。 |
| `issues_access_level` | string | 议题功能的访问级别。可能的值：`disabled`、`private` 或 `enabled`。 |
| `repository_access_level` | string | 代码仓库功能的访问级别。可能的值：`disabled`、`private` 或 `enabled`。 |
| `merge_requests_access_level` | string | 合并请求功能的访问级别。可能的值：`disabled`、`private` 或 `enabled`。 |
| `forking_access_level` | string | 复刻项目的访问级别。可能的值：`disabled`、`private` 或 `enabled`。 |
| `wiki_access_level` | string | Wiki 功能的访问级别。可能的值：`disabled`、`private` 或 `enabled`。 |
| `builds_access_level` | string | CI/CD 构建功能的访问级别。可能的值：`disabled`、`private` 或 `enabled`。 |
| `snippets_access_level` | string | 代码片段功能的访问级别。可能的值：`disabled`、`private` 或 `enabled`。 |
| `pages_access_level` | string | GitLab Pages 的访问级别。可能的值：`disabled`、`private`、`enabled` 或 `public`。 |
| `analytics_access_level` | string | 分析功能的访问级别。可能的值：`disabled`、`private` 或 `enabled`。 |
| `container_registry_access_level` | string | 容器镜像仓库的访问级别。可能的值：`disabled`、`private` 或 `enabled`。 |
| `security_and_compliance_access_level` | string | 安全与合规功能的访问级别。可能的值：`disabled`、`private` 或 `enabled`。 |
| `releases_access_level` | string | 发布功能的访问级别。可能的值：`disabled`、`private` 或 `enabled`。 |
| `environments_access_level` | string | 环境功能的访问级别。可能的值：`disabled`、`private` 或 `enabled`。 |
| `feature_flags_access_level` | string | 功能标志功能的访问级别。可能的值：`disabled`、`private` 或 `enabled`。 |
| `infrastructure_access_level` | string | 基础设施功能的访问级别。可能的值：`disabled`、`private` 或 `enabled`。 |
| `monitor_access_level` | string | 监控功能的访问级别。可能的值：`disabled`、`private` 或 `enabled`。 |
| `model_experiments_access_level` | string | 模型实验功能的访问级别。可能的值：`disabled`、`private` 或 `enabled`。 |
| `model_registry_access_level` | string | 模型仓库功能的访问级别。可能的值：`disabled`、`private` 或 `enabled`。 |
| `package_registry_access_level` | string | 软件包仓库功能的访问级别。可能的值：`disabled`、`private` 或 `enabled`。 |
| `emails_disabled` | boolean | 指示项目的电子邮件是否已禁用。 |
| `emails_enabled` | boolean | 指示项目的电子邮件是否已启用。 |
| `show_diff_preview_in_email` | boolean | 指示电子邮件通知中是否显示差异预览。 |
| `shared_runners_enabled` | boolean | 项目是否启用了共享 Runner。 |
| `lfs_enabled` | boolean | 指示项目是否启用了 Git LFS。 |
| `creator_id` | integer | 创建项目的用户的 ID。 |
| `import_status` | string | 项目导入的状态。 |
| `open_issues_count` | integer | 未关闭的议题数量。 |
| `description_html` | string | 项目的 HTML 格式描述。 |
| `updated_at` | datetime | 项目最后更新的时间戳。 |
| `ci_config_path` | string | CI/CD 配置文件的路径。 |
| `public_jobs` | boolean | 作业日志是否可公开访问。 |
| `shared_with_groups` | array of objects | 与项目共享的群组列表。 |
| `only_allow_merge_if_pipeline_succeeds` | boolean | 是否仅当流水线成功时才允许合并。 |
| `allow_merge_on_skipped_pipeline` | boolean | 当流水线被跳过时是否允许合并。 |
| `request_access_enabled` | boolean | 用户是否可以请求访问项目。 |
| `only_allow_merge_if_all_discussions_are_resolved` | boolean | 是否仅当所有讨论都已解决时才允许合并。 |
| `remove_source_branch_after_merge` | boolean | 合并后是否自动删除源分支。 |
| `printing_merge_request_link_enabled` | boolean | 指示推送后是否打印合并请求链接。 |
| `merge_method` | string | 项目使用的合并方法。可能的值：`merge`、`rebase_merge` 或 `ff`。 |
| `merge_request_title_regex` | string | 用于验证合并请求标题的正则表达式模式。 |
| `merge_request_title_regex_description` | string | 合并请求标题正则表达式验证的描述。 |
| `squash_option` | string | 合并请求的压缩选项。 |
| `automatic_rebase_enabled` | boolean | 指示合并前是否自动变基源分支。 |
| `enforce_auth_checks_on_uploads` | boolean | 上传时是否强制执行身份验证检查。 |
| `suggestion_commit_message` | string | 建议的自定义提交消息。 |
| `merge_commit_template` | string | 合并提交消息的模板。 |
| `mr_default_title_template` | string | 合并请求标题的模板。 |
| `squash_commit_template` | string | 压缩提交消息的模板。 |
| `issue_branch_template` | string | 从议题创建的分支名称的模板。 |
| `warn_about_potentially_unwanted_characters` | boolean | 是否警告可能不需要的字符。 |
| `autoclose_referenced_issues` | boolean | 引用的议题是否自动关闭。 |
| `max_artifacts_size` | integer | CI/CD 产物的最大大小（MB）。 |
| `approvals_before_merge` | integer | 已弃用。请改用合并请求审批 API。合并前所需的审批数量。 |
| `mirror` | boolean | 项目是否为镜像。 |
| `external_authorization_classification_label` | string | 外部授权分类标记。 |
| `requirements_enabled` | boolean | 指示是否启用了需求管理。 |
| `requirements_access_level` | string | 需求功能的访问级别。 |
| `security_and_compliance_enabled` | boolean | 指示是否启用了安全与合规功能。 |
| `compliance_frameworks` | array of strings | 应用于项目的合规框架。 |
| `issues_template` | string | 议题的默认描述。描述使用极狐GitLab 风格 Markdown 解析。仅限专业版和旗舰版。 |
| `merge_requests_template` | string | 合并请求描述的模板。仅限专业版和旗舰版。 |
| `merge_pipelines_enabled` | boolean | 指示是否启用了合并流水线。 |
| `merge_trains_enabled` | boolean | 指示是否启用了合并列车。 |
| `merge_trains_skip_train_allowed` | boolean | 指示是否允许跳过合并列车。 |
| `merge_train_enforcement` | string | 合并列车强制级别。取值为 `allow_bypass`、`enforce_for_all_users` 或 `enforce_with_owner_override` 之一。除非为项目启用了合并列车，否则无效。 |
| `max_pipelines_per_merge_train` | integer | 每个合并列车的最大并行流水线数量。 |
| `only_allow_merge_if_all_status_checks_passed` | boolean | 是否仅当所有状态检查都已通过时才允许合并。仅限旗舰版。 |
| `allow_pipeline_trigger_approve_deployment` | boolean | 流水线触发器是否可以批准部署。 |
| `prevent_merge_without_jira_issue` | boolean | 指示合并是否要求关联的 Jira 议题。 |
| `reviewer_assignment_strategy` | string | 用于自动分配审核人到合并请求的策略。取值为 `disabled` 或 `code_owners` 之一。对于在极狐GitLab 19.4 之前配置的项目，此属性也可以返回 `dap_powered`。仅限专业版和旗舰版。 |
| `duo_remote_flows_enabled` | boolean | 指示是否启用了极狐GitLab Duo 远程任务流。 |
| `duo_foundational_flows_enabled` | boolean | 指示是否启用了极狐GitLab Duo 内置任务流。 |
| `duo_sast_fp_detection_enabled` | boolean | 指示是否启用了极狐GitLab Duo SAST 误报检测。 |
| `duo_sast_vr_workflow_enabled` | boolean | 指示是否启用了极狐GitLab Duo SAST 漏洞解决工作流。 |
| `spp_repository_pipeline_access` | boolean | 安全策略的代码仓库流水线访问。仅当安全编排策略功能可用时可见。 |
| `permissions` | object | 项目的用户权限。 |
| `permissions.project_access` | object | 用户的项目访问权限。 |
| `permissions.group_access` | object | 用户的群组访问权限。 |
{.condensed}

<!-- markdownlint-enable MD055 MD056 -->

示例请求：

```shell
curl --header "PRIVATE-TOKEN: <your_access_token>" \
     --header "Accept: application/json" \
     --url "https://gitlab.example.com/api/v4/projects"
```

示例响应：

```json
[
  {
    "id": 4,
    "description": "Lorem ipsum dolor sit amet, consectetur adipiscing elit.",
    "description_html": "<p data-sourcepos=\"1:1-1:56\" dir=\"auto\">Lorem ipsum dolor sit amet, consectetur adipiscing elit.</p>",
    "name": "Diaspora Client",
    "name_with_namespace": "Diaspora / Diaspora Client",
    "path": "diaspora-client",
    "path_with_namespace": "diaspora/diaspora-client",
    "created_at": "2013-09-30T13:46:02Z",
    "updated_at": "2013-09-30T13:46:02Z",
    "default_branch": "main",
    "tag_list": [ //deprecated, use `topics` instead
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
    "readme_url": "https://gitlab.example.com/diaspora/diaspora-client/blob/main/README.md",
    "avatar_url": "https://gitlab.example.com/uploads/project/avatar/4/uploads/avatar.png",
    "forks_count": 0,
    "star_count": 0,
    "last_activity_at": "2022-06-24T17:11:26.841Z",
    "namespace": {
      "id": 3,
      "name": "Diaspora",
      "path": "diaspora",
      "kind": "group",
      "full_path": "diaspora",
      "parent_id": null,
      "avatar_url": "https://gitlab.example.com/uploads/project/avatar/6/uploads/avatar.png",
      "web_url": "https://gitlab.example.com/diaspora"
    },
    "container_registry_image_prefix": "registry.gitlab.example.com/diaspora/diaspora-client",
    "_links": {
      "self": "https://gitlab.example.com/api/v4/projects/4",
      "issues": "https://gitlab.example.com/api/v4/projects/4/issues",
      "merge_requests": "https://gitlab.example.com/api/v4/projects/4/merge_requests",
      "repo_branches": "https://gitlab.example.com/api/v4/projects/4/repository/branches",
      "labels": "https://gitlab.example.com/api/v4/projects/4/labels",
      "events": "https://gitlab.example.com/api/v4/projects/4/events",
      "members": "https://gitlab.example.com/api/v4/projects/4/members",
      "cluster_agents": "https://gitlab.example.com/api/v4/projects/4/cluster_agents"
    },
    "packages_enabled": true, // deprecated, use package_registry_access_level instead
    "package_registry_access_level": "enabled",
    "empty_repo": false,
    "archived": false,
    "visibility": "public",
    "resolve_outdated_diff_discussions": false,
    "container_expiration_policy": {
      "cadence": "1month",
      "enabled": true,
      "keep_n": 1,
      "older_than": "14d",
      "name_regex": "",
      "name_regex_keep": ".*-main",
      "next_run_at": "2022-06-25T17:11:26.865Z"
    },
    "issues_enabled": true,
    "merge_requests_enabled": true,
    "wiki_enabled": true,
    "jobs_enabled": true,
    "snippets_enabled": true,
    "container_registry_enabled": true,
    "service_desk_enabled": true,
    "can_create_merge_request_in": true,
    "issues_access_level": "enabled",
    "repository_access_level": "enabled",
    "merge_requests_access_level": "enabled",
    "forking_access_level": "enabled",
    "wiki_access_level": "enabled",
    "builds_access_level": "enabled",
    "snippets_access_level": "enabled",
    "pages_access_level": "enabled",
    "analytics_access_level": "enabled",
    "container_registry_access_level": "enabled",
    "security_and_compliance_access_level": "private",
    "emails_disabled": null,
    "emails_enabled": null,
    "shared_runners_enabled": true,
    "group_runners_enabled": true,
    "lfs_enabled": true,
    "creator_id": 1,
    "import_url": null,
    "import_type": null,
    "import_status": "none",
    "import_error": null,
    "open_issues_count": 0,
    "ci_default_git_depth": 20,
    "ci_forward_deployment_enabled": true,
    "ci_forward_deployment_rollback_allowed": true,
    "ci_allow_fork_pipelines_to_run_in_parent_project": true,
    "ci_id_token_sub_claim_components": ["project_path", "ref_type", "ref"],
    "ci_job_token_scope_enabled": false,
    "ci_separated_caches": true,
    "ci_restrict_pipeline_cancellation_role": "developer",
    "ci_pipeline_variables_minimum_override_role": "maintainer",
    "ci_push_repository_for_job_token_allowed": false,
    "ci_display_pipeline_variables": false,
    "protect_merge_request_pipelines": true,
    "public_jobs": true,
    "build_timeout": 3600,
    "auto_cancel_pending_pipelines": "enabled",
    "ci_config_path": "",
    "shared_with_groups": [],
    "only_allow_merge_if_pipeline_succeeds": false,
    "allow_merge_on_skipped_pipeline": null,
    "allow_pipeline_trigger_approve_deployment": false,
    "restrict_user_defined_variables": false,
    "request_access_enabled": true,
    "only_allow_merge_if_all_discussions_are_resolved": false,
    "remove_source_branch_after_merge": true,
    "printing_merge_request_link_enabled": true,
    "merge_method": "merge",
    "squash_option": "default_off",
    "enforce_auth_checks_on_uploads": true,
    "suggestion_commit_message": null,
    "merge_commit_template": null,
    "mr_default_title_template": null,
    "squash_commit_template": null,
    "issue_branch_template": "gitlab/%{id}-%{title}",
    "auto_devops_enabled": false,
    "auto_devops_deploy_strategy": "continuous",
    "autoclose_referenced_issues": true,
    "keep_latest_artifact": true,
    "runner_token_expiration_interval": null,
    "external_authorization_classification_label": "",
    "requirements_enabled": false,
    "requirements_access_level": "enabled",
    "security_and_compliance_enabled": false,
    "secret_push_protection_enabled": false,
    "compliance_frameworks": [],
    "warn_about_potentially_unwanted_characters": true,
    "permissions": {
      "project_access": null,
      "group_access": null
    }
  },
  {
    ...
  }
]
```

> [!note]
> `last_activity_at` 根据[项目活动](../user/project/working_with_projects.md#view-project-activity)和[项目事件](events.md)更新。为优化数据库性能，此字段最多每小时更新一次。
> 在最后一次更新后一小时内发生的事件不会修改该时间戳。
> 因此，`last_activity_at` 可能最多滞后一小时。
> 每当项目记录在数据库中更改时，`updated_at` 都会更新。

<a id="list-all-personal-projects-for-a-user"></a>

### 列出用户的所有个人项目

列出指定用户的所有个人项目。适用以下限制：

- 仅返回用户个人命名空间中的项目，不返回群组或子群组项目。
- 如果用户个人资料为私有，则返回空列表。
- 未经身份验证的请求仅返回公共项目。

此端点支持分页：

- 使用基于偏移量的分页可访问最多 50,000 个项目。
- 使用基于键集的分页可列出超过 50,000 个项目。

有关更多信息，请参阅[分页](rest/_index.md#pagination)。

```plaintext
GET /users/:user_id/projects
```

支持的属性：

| 属性                     | 类型     | 必填 | 描述 |
|:------------------------------|:---------|:---------|:------------|
| `user_id`                     | string   | 是      | 用户的 ID 或用户名。 |
| `archived`                    | boolean  | 否       | 按归档状态限制。 |
| `id_after`                    | integer  | 否       | 将结果限制为 ID 大于指定 ID 的项目。 |
| `id_before`                   | integer  | 否       | 将结果限制为 ID 小于指定 ID 的项目。 |
| `membership`                  | boolean  | 否       | 按当前用户是其成员的项目进行限制。 |
| `min_access_level`            | integer  | 否       | 限制为当前用户至少具有指定访问级别的项目。可能的值：`5`（最小访问权限）、`10`（访客）、`15`（计划者）、`20`（报告者）、`25`（安全管理员）、`30`（开发者）、`40`（维护者）或 `50`（所有者）。 |
| `order_by`                    | string   | 否       | 按 `id`、`name`、`path`、`created_at`、`updated_at`、`star_count` 或 `last_activity_at` 字段排序返回项目。默认为 `created_at`。 |
| `owned`                       | boolean  | 否       | 按当前用户明确拥有的项目进行限制。 |
| `search`                      | string   | 否       | 返回与搜索条件匹配的项目列表。 |
| `simple`                      | boolean  | 否       | 如果为 `true`，则仅返回每个项目的有限字段。未经身份验证的请求仅返回具有有限字段的公共项目，即使未设置 `simple` 也是如此。 |
| `sort`                        | string   | 否       | 按 `asc` 或 `desc` 顺序返回排序后的项目。默认为 `desc`。 |
| `starred`                     | boolean  | 否       | 按当前用户加星标的项目进行限制。 |
| `statistics`                  | boolean  | 否       | 包含项目统计信息。仅对具有报告者、开发者、维护者或所有者角色的用户可用。 |
| `updated_after`               | datetime | 否       | 将结果限制为在指定时间之后最后更新的项目。格式：ISO 8601（`YYYY-MM-DDTHH:MM:SSZ`）。 |
| `updated_before`              | datetime | 否       | 将结果限制为在指定时间之前最后更新的项目。格式：ISO 8601（`YYYY-MM-DDTHH:MM:SSZ`）。 |
| `visibility`                  | string   | 否       | 按可见性限制。可能的值：`public`、`internal` 或 `private`。 |
| `with_custom_attributes`      | boolean  | 否       | 在响应中包含[自定义属性](custom_attributes.md)。需要管理员访问权限。 |
| `with_issues_enabled`         | boolean  | 否       | 按已启用的议题功能限制。 |
| `with_merge_requests_enabled` | boolean  | 否       | 按已启用的合并请求功能限制。 |
| `with_programming_language`   | string   | 否       | 按使用给定编程语言的项目进行限制。 |

如果成功，返回 [`200 OK`](rest/troubleshooting.md#status-codes) 以及以下响应属性：

<!-- markdownlint-disable MD055 MD056 -->

| 属性 | 类型 | 描述 |
|-----------|------|-------------|
| `id` | integer | 项目的 ID。 |
| `description` | string | 项目的描述。 |
| `name` | string | 项目的名称。 |
| `name_with_namespace` | string | 项目及其命名空间的名称。 |
| `path` | string | 项目的路径。 |
| `path_with_namespace` | string | 项目及其命名空间的路径。 |
| `created_at` | datetime | 项目创建时的时间戳。 |
| `default_branch` | string | 项目的默认分支。 |
| `tag_list` | array of strings | 已弃用。请改用 `topics`。项目的标签列表。 |
| `topics` | array of strings | 项目的主题列表。 |
| `ssh_url_to_repo` | string | 用于克隆代码仓库的 SSH URL。 |
| `http_url_to_repo` | string | 用于克隆代码仓库的 HTTP URL。 |
| `web_url` | string | 在浏览器中访问项目的 URL。 |
| `readme_url` | string | 项目 README 文件的 URL。 |
| `forks_count` | integer | 项目的派生（fork）数量。 |
| `avatar_url` | string | 项目头像图片的 URL。 |
| `star_count` | integer | 项目收到的星标数量。 |
| `last_activity_at` | datetime | 项目中最后活动的时间戳。 |
| `visibility` | string | 项目的可见性级别。可能的值：`private`、`internal` 或 `public`。 |
| `namespace` | object | 项目的命名空间信息。 |
| `namespace.id` | integer | 命名空间的 ID。 |
| `namespace.name` | string | 命名空间的名称。 |
| `namespace.path` | string | 命名空间的路径。 |
| `namespace.kind` | string | 命名空间的类型。可能的值：`user` 或 `group`。 |
| `namespace.full_path` | string | 命名空间的完整路径。 |
| `namespace.parent_id` | integer | 父命名空间的 ID（如果适用）。 |
| `namespace.avatar_url` | string | 命名空间头像图片的 URL。 |
| `namespace.web_url` | string | 在浏览器中访问命名空间的 URL。 |
| `container_registry_image_prefix` | string | 容器镜像仓库镜像的前缀。 |
| `_links` | object | 与项目相关的 API 端点链接集合。 |
| `_links.self` | string | 项目资源的 URL。 |
| `_links.issues` | string | 项目议题的 URL。 |
| `_links.merge_requests` | string | 项目合并请求的 URL。 |
| `_links.repo_branches` | string | 项目代码仓库分支的 URL。 |
| `_links.labels` | string | 项目标记的 URL。 |
| `_links.events` | string | 项目事件的 URL。 |
| `_links.members` | string | 项目成员的 URL。 |
| `_links.cluster_agents` | string | 项目集群代理的 URL。 |
| `marked_for_deletion_at` | date | 已弃用。请改用 `marked_for_deletion_on`。项目计划删除的日期。 |
| `marked_for_deletion_on` | date | 项目计划删除的日期。 |
| `packages_enabled` | boolean | 是否为项目启用了软件包仓库。 |
| `empty_repo` | boolean | 代码仓库是否为空。 |
| `archived` | boolean | 项目是否已归档。 |
| `resolve_outdated_diff_discussions` | boolean | 是否自动解决过时的差异讨论。 |
| `container_expiration_policy` | object | 容器镜像过期策略的设置。 |
| `container_expiration_policy.cadence` | string | 容器过期策略运行的频率。 |
| `container_expiration_policy.enabled` | boolean | 是否启用了容器过期策略。 |
| `container_expiration_policy.keep_n` | integer | 要保留的容器镜像数量。 |
| `container_expiration_policy.older_than` | string | 删除早于此值的容器镜像。 |
| `container_expiration_policy.name_regex` | string | 已弃用。请改用 `name_regex_delete`。用于匹配容器镜像名称的正则表达式。 |
| `container_expiration_policy.name_regex_keep` | string | 用于匹配要保留的容器镜像名称的正则表达式。 |
| `container_expiration_policy.next_run_at` | datetime | 下次计划策略运行的时间戳。 |
| `repository_object_format` | string | 代码仓库使用的对象格式（sha1 或 sha256）。 |
| `issues_enabled` | boolean | 是否为项目启用了议题。 |
| `merge_requests_enabled` | boolean | 是否为项目启用了合并请求。 |
| `wiki_enabled` | boolean | 是否为项目启用了 Wiki。 |
| `jobs_enabled` | boolean | 是否为项目启用了作业。 |
| `snippets_enabled` | boolean | 是否为项目启用了代码片段。 |
| `container_registry_enabled` | boolean | 已弃用。请改用 `container_registry_access_level`。是否启用了容器镜像仓库。 |
| `service_desk_enabled` | boolean | 是否为项目启用了服务台。 |
| `can_create_merge_request_in` | boolean | 当前用户是否可以在项目中创建合并请求。 |
| `issues_access_level` | string | 议题功能的访问级别。可能的值：`disabled`、`private` 或 `enabled`。 |
| `repository_access_level` | string | 代码仓库功能的访问级别。可能的值：`disabled`、`private` 或 `enabled`。 |
| `merge_requests_access_level` | string | 合并请求功能的访问级别。可能的值：`disabled`、`private` 或 `enabled`。 |
| `forking_access_level` | string | 派生（fork）项目的访问级别。可能的值：`disabled`、`private` 或 `enabled`。 |
| `wiki_access_level` | string | Wiki 功能的访问级别。可能的值：`disabled`、`private` 或 `enabled`。 |
| `builds_access_level` | string | CI/CD 构建功能的访问级别。可能的值：`disabled`、`private` 或 `enabled`。 |
| `snippets_access_level` | string | 代码片段功能的访问级别。可能的值：`disabled`、`private` 或 `enabled`。 |
| `pages_access_level` | string | GitLab Pages 的访问级别。可能的值：`disabled`、`private`、`enabled` 或 `public`。 |
| `analytics_access_level` | string | 分析功能的访问级别。可能的值：`disabled`、`private` 或 `enabled`。 |
| `container_registry_access_level` | string | 容器镜像仓库的访问级别。可能的值：`disabled`、`private` 或 `enabled`。 |
| `security_and_compliance_access_level` | string | 安全与合规功能的访问级别。可能的值：`disabled`、`private` 或 `enabled`。 |
| `releases_access_level` | string | 发布功能的访问级别。可能的值：`disabled`、`private` 或 `enabled`。 |
| `environments_access_level` | string | 环境功能的访问级别。可能的值：`disabled`、`private` 或 `enabled`。 |
| `feature_flags_access_level` | string | 功能标志功能的访问级别。可能的值：`disabled`、`private` 或 `enabled`。 |
| `infrastructure_access_level` | string | 基础设施功能的访问级别。可能的值：`disabled`、`private` 或 `enabled`。 |
| `monitor_access_level` | string | 监控功能的访问级别。可能的值：`disabled`、`private` 或 `enabled`。 |
| `model_experiments_access_level` | string | 模型实验功能的访问级别。可能的值：`disabled`、`private` 或 `enabled`。 |
| `model_registry_access_level` | string | 模型仓库功能的访问级别。可能的值：`disabled`、`private` 或 `enabled`。 |
| `package_registry_access_level` | string | 软件包仓库功能的访问级别。可能的值：`disabled`、`private` 或 `enabled`。 |
| `emails_disabled` | boolean | 指示是否为项目禁用了电子邮件。 |
| `emails_enabled` | boolean | 指示是否为项目启用了电子邮件。 |
| `show_diff_preview_in_email` | boolean | 指示是否在电子邮件通知中显示差异预览。 |
| `shared_runners_enabled` | boolean | 是否为项目启用了共享 Runner。 |
| `lfs_enabled` | boolean | 指示是否为项目启用了 Git LFS。 |
| `creator_id` | integer | 创建项目的用户的 ID。 |
| `import_status` | string | 项目导入的状态。 |
| `open_issues_count` | integer | 未关闭的议题数量。 |
| `description_html` | string | 项目描述的 HTML 格式。 |
| `updated_at` | datetime | 项目最后更新的时间戳。 |
| `ci_default_git_depth` | integer | CI/CD 流水线的默认 Git 深度。仅当您具有管理员访问权限或项目的所有者角色时可见。 |
| `ci_forward_deployment_enabled` | boolean | 是否启用了前向部署。仅当您具有管理员访问权限或项目的所有者角色时可见。 |
| `ci_job_token_scope_enabled` | boolean | 指示是否启用了 CI/CD 作业令牌范围。仅当您具有管理员访问权限或项目的所有者角色时可见。 |
| `ci_separated_caches` | boolean | CI/CD 缓存是否按分支分离。仅当您具有管理员访问权限或项目的所有者角色时可见。 |
| `ci_allow_fork_pipelines_to_run_in_parent_project` | boolean | 派生（fork）的流水线是否可以在父项目中运行。仅当您具有管理员访问权限或项目的所有者角色时可见。 |
| `build_git_strategy` | string | 用于 CI/CD 构建的 Git 策略（fetch 或 clone）。仅当您具有管理员访问权限或项目的所有者角色时可见。 |
| `keep_latest_artifact` | boolean | 指示创建新产物时是否保留最新产物。仅当您具有管理员访问权限或项目的所有者角色时可见。 |
| `restrict_user_defined_variables` | boolean | 是否限制用户定义的变量。仅当您具有管理员访问权限或项目的所有者角色时可见。 |
| `runners_token` | string | 用于向项目注册 Runner 的令牌。仅当您具有管理员访问权限或项目的所有者角色时可见。 |
| `runner_token_expiration_interval` | integer | Runner 令牌的过期时间间隔（秒）。仅当您具有管理员访问权限或项目的所有者角色时可见。 |
| `group_runners_enabled` | boolean | 是否为项目启用了群组 Runner。仅当您具有管理员访问权限或项目的所有者角色时可见。 |
| `auto_cancel_pending_pipelines` | string | 自动取消待处理流水线的设置。仅当您具有管理员访问权限或项目的所有者角色时可见。 |
| `build_timeout` | integer | CI/CD 作业的超时时间（秒）。仅当您具有管理员访问权限或项目的所有者角色时可见。 |
| `auto_devops_enabled` | boolean | 是否为项目启用了 Auto DevOps。仅当您具有管理员访问权限或项目的所有者角色时可见。 |
| `auto_devops_deploy_strategy` | string | Auto DevOps 的部署策略。仅当您具有管理员访问权限或项目的所有者角色时可见。 |
| `ci_config_path` | string | CI/CD 配置文件的路径。 |
| `public_jobs` | boolean | 作业日志是否可公开访问。 |
| `shared_with_groups` | array of objects | 与之共享项目的群组列表。 |
| `only_allow_merge_if_pipeline_succeeds` | boolean | 是否仅当流水线成功时才允许合并。 |
| `allow_merge_on_skipped_pipeline` | boolean | 当流水线被跳过时是否允许合并。 |
| `request_access_enabled` | boolean | 用户是否可以请求访问项目。 |
| `only_allow_merge_if_all_discussions_are_resolved` | boolean | 是否仅当所有讨论都已解决时才允许合并。 |
| `remove_source_branch_after_merge` | boolean | 合并后是否自动删除源分支。 |
| `printing_merge_request_link_enabled` | boolean | 指示推送后是否打印合并请求链接。 |
| `merge_method` | string | 项目使用的合并方法。可能的值：`merge`、`rebase_merge` 或 `ff`。 |
| `merge_request_title_regex` | string | 用于验证合并请求标题的正则表达式模式。 |
| `merge_request_title_regex_description` | string | 合并请求标题正则表达式验证的描述。 |
| `squash_option` | string | 合并请求的压缩（squash）选项。 |
| `automatic_rebase_enabled` | boolean | 指示合并前是否自动变基（rebase）源分支。 |
| `enforce_auth_checks_on_uploads` | boolean | 是否对上传强制执行身份验证检查。 |
| `suggestion_commit_message` | string | 建议的自定义提交消息。 |
| `merge_commit_template` | string | 合并提交消息的模板。 |
| `mr_default_title_template` | string | 合并请求标题的模板。 |
| `squash_commit_template` | string | 压缩（squash）提交消息的模板。 |
| `issue_branch_template` | string | 从议题创建的分支名称的模板。 |
| `warn_about_potentially_unwanted_characters` | boolean | 是否警告可能不需要的字符。 |
| `autoclose_referenced_issues` | boolean | 是否自动关闭被引用的议题。 |
| `max_artifacts_size` | integer | CI/CD 产物的最大大小（MB）。 |
| `approvals_before_merge` | integer | 已弃用。请改用合并请求审批 API。合并前所需的审批数量。 |
| `mirror` | boolean | 项目是否为镜像。 |
| `external_authorization_classification_label` | string | 外部授权分类标记。 |
| `requirements_enabled` | boolean | 指示是否启用了需求管理。 |
| `requirements_access_level` | string | 需求功能的访问级别。 |
| `security_and_compliance_enabled` | boolean | 指示是否启用了安全与合规功能。 |
| `compliance_frameworks` | array of strings | 应用于项目的合规框架。 |
| `issues_template` | string | 议题的默认描述。描述使用极狐GitLab 风格 Markdown 解析。仅限专业版和旗舰版。 |
| `merge_requests_template` | string | 合并请求描述的模板。仅限专业版和旗舰版。 |
| `merge_pipelines_enabled` | boolean | 指示是否启用了合并流水线。 |
| `merge_trains_enabled` | boolean | 指示是否启用了合并列车。 |
| `merge_trains_skip_train_allowed` | boolean | 指示是否允许跳过合并列车。 |
| `merge_train_enforcement` | string | 合并列车强制级别。可以是 `allow_bypass`、`enforce_for_all_users` 或 `enforce_with_owner_override` 之一。除非为项目启用了合并列车，否则无效。 |
| `max_pipelines_per_merge_train` | integer | 每个合并列车的最大并行流水线数量。 |
| `only_allow_merge_if_all_status_checks_passed` | boolean | 是否仅当所有状态检查都已通过时才允许合并。仅限旗舰版。 |
| `allow_pipeline_trigger_approve_deployment` | boolean | 流水线触发器是否可以批准部署。 |
| `prevent_merge_without_jira_issue` | boolean | 指示合并是否需要关联的 Jira 议题。 |
| `reviewer_assignment_strategy` | string | 用于自动分配审核人到合并请求的策略。取值为 `disabled` 或 `code_owners` 之一。对于在极狐GitLab 19.4 之前配置的项目，此属性也可以返回 `dap_powered`。仅限专业版和旗舰版。 |
| `duo_remote_flows_enabled` | boolean | 指示是否启用了极狐GitLab Duo 远程任务流。 |
| `duo_foundational_flows_enabled` | boolean | 指示是否启用了极狐GitLab Duo 内置任务流。 |
| `duo_sast_fp_detection_enabled` | boolean | 指示是否启用了极狐GitLab Duo SAST 误报检测。 |
| `duo_sast_vr_workflow_enabled` | boolean | 指示是否启用了极狐GitLab Duo SAST 漏洞解决工作流。 |
| `spp_repository_pipeline_access` | boolean | 安全策略的代码仓库流水线访问。仅当安全编排策略功能可用时可见。 |
| `permissions` | object | 用户对项目的权限。 |
| `permissions.project_access` | object | 用户的项目访问权限。 |
| `permissions.group_access` | object | 用户的群组访问权限。 |
{.condensed}

<!-- markdownlint-enable MD055 MD056 -->

示例请求：

```shell
curl --header "PRIVATE-TOKEN: <your_access_token>" \
     --header "Accept: application/json" \
     --url "https://gitlab.example.com/api/v4/users/:user_id/projects
```

示例响应：

```json
[
  {
    "id": 4,
    "description": "Lorem ipsum dolor sit amet, consectetur adipiscing elit.",
    "description_html": "<p data-sourcepos=\"1:1-1:56\" dir=\"auto\">Lorem ipsum dolor sit amet, consectetur adipiscing elit.</p>",
    "default_branch": "main",
    "visibility": "private",
    "ssh_url_to_repo": "git@example.com:diaspora/diaspora-client.git",
    "http_url_to_repo": "http://example.com/diaspora/diaspora-client.git",
    "web_url": "http://example.com/diaspora/diaspora-client",
    "readme_url": "http://example.com/diaspora/diaspora-client/blob/main/README.md",
    "tag_list": [ //deprecated, use `topics` instead
      "example",
      "disapora client"
    ],
    "topics": [
      "example",
      "disapora client"
    ],
    "owner": {
      "id": 3,
      "name": "Diaspora",
      "created_at": "2013-09-30T13:46:02Z"
    },
    "name": "Diaspora Client",
    "name_with_namespace": "Diaspora / Diaspora Client",
    "path": "diaspora-client",
    "path_with_namespace": "diaspora/diaspora-client",
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
    "import_url": null,
    "import_type": null,
    "import_status": "none",
    "import_error": null,
    "namespace": {
      "id": 3,
      "name": "Diaspora",
      "path": "diaspora",
      "kind": "group",
      "full_path": "diaspora"
    },
    "import_status": "none",
    "archived": false,
    "avatar_url": "http://example.com/uploads/project/avatar/4/uploads/avatar.png",
    "shared_runners_enabled": true,
    "group_runners_enabled": true,
    "forks_count": 0,
    "star_count": 0,
    "runners_token": "b8547b1dc37721d05889db52fa2f02",
    "ci_default_git_depth": 50,
    "ci_forward_deployment_enabled": true,
    "ci_forward_deployment_rollback_allowed": true,
    "ci_allow_fork_pipelines_to_run_in_parent_project": true,
    "ci_id_token_sub_claim_components": ["project_path", "ref_type", "ref"],
    "ci_separated_caches": true,
    "ci_restrict_pipeline_cancellation_role": "developer",
    "ci_pipeline_variables_minimum_override_role": "maintainer",
    "ci_push_repository_for_job_token_allowed": false,
    "ci_display_pipeline_variables": false,
    "protect_merge_request_pipelines": true,
    "public_jobs": true,
    "shared_with_groups": [],
    "only_allow_merge_if_pipeline_succeeds": false,
    "allow_merge_on_skipped_pipeline": false,
    "allow_pipeline_trigger_approve_deployment": false,
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
    "mr_default_title_template": null,
    "squash_commit_template": null,
    "secret_push_protection_enabled": false,
    "issue_branch_template": "gitlab/%{id}-%{title}",
    "marked_for_deletion_at": "2020-04-03", // Deprecated in favor of marked_for_deletion_on. Planned for removal in a future version of the REST API.
    "marked_for_deletion_on": "2020-04-03",
    "statistics": {
      "commit_count": 37,
      "storage_size": 1038090,
      "repository_size": 1038090,
      "wiki_size" : 0,
      "lfs_objects_size": 0,
      "job_artifacts_size": 0,
      "pipeline_artifacts_size": 0,
      "packages_size": 0,
      "snippets_size": 0,
      "uploads_size": 0,
      "container_registry_size": 0
    },
    "container_registry_image_prefix": "registry.example.com/diaspora/diaspora-client",
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
  },
  {
    "id": 6,
    "description": "Lorem ipsum dolor sit amet, consectetur adipiscing elit.",
    "description_html": "<p data-sourcepos=\"1:1-1:56\" dir=\"auto\">Lorem ipsum dolor sit amet, consectetur adipiscing elit.</p>",
    "default_branch": "main",
    "visibility": "private",
    "ssh_url_to_repo": "git@example.com:brightbox/puppet.git",
    "http_url_to_repo": "http://example.com/brightbox/puppet.git",
    "web_url": "http://example.com/brightbox/puppet",
    "readme_url": "http://example.com/brightbox/puppet/blob/main/README.md",
    "tag_list": [ //deprecated, use `topics` instead
      "example",
      "puppet"
    ],
    "topics": [
      "example",
      "puppet"
    ],
    "owner": {
      "id": 4,
      "name": "Brightbox",
      "created_at": "2013-09-30T13:46:02Z"
    },
    "name": "Puppet",
    "name_with_namespace": "Brightbox / Puppet",
    "path": "puppet",
    "path_with_namespace": "brightbox/puppet",
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
    "import_url": null,
    "import_type": null,
    "import_status": "none",
    "import_error": null,
    "namespace": {
      "id": 4,
      "name": "Brightbox",
      "path": "brightbox",
      "kind": "group",
      "full_path": "brightbox"
    },
    "import_status": "none",
    "import_error": null,
    "permissions": {
      "project_access": {
        "access_level": 10,
        "notification_level": 3
      },
      "group_access": {
        "access_level": 50,
        "notification_level": 3
      }
    },
    "archived": false,
    "avatar_url": null,
    "shared_runners_enabled": true,
    "group_runners_enabled": true,
    "forks_count": 0,
    "star_count": 0,
    "runners_token": "b8547b1dc37721d05889db52fa2f02",
    "ci_default_git_depth": 0,
    "ci_forward_deployment_enabled": true,
    "ci_forward_deployment_rollback_allowed": true,
    "ci_allow_fork_pipelines_to_run_in_parent_project": true,
    "ci_id_token_sub_claim_components": ["project_path", "ref_type", "ref"],
    "ci_separated_caches": true,
    "ci_restrict_pipeline_cancellation_role": "developer",
    "ci_pipeline_variables_minimum_override_role": "maintainer",
    "ci_push_repository_for_job_token_allowed": false,
    "ci_display_pipeline_variables": false,
    "protect_merge_request_pipelines": true,
    "public_jobs": true,
    "shared_with_groups": [],
    "only_allow_merge_if_pipeline_succeeds": false,
    "allow_merge_on_skipped_pipeline": false,
    "allow_pipeline_trigger_approve_deployment": false,
    "restrict_user_defined_variables": false,
    "only_allow_merge_if_all_discussions_are_resolved": false,
    "remove_source_branch_after_merge": false,
    "request_access_enabled": false,
    "merge_method": "merge",
    "squash_option": "default_on",
    "auto_devops_enabled": true,
    "auto_devops_deploy_strategy": "continuous",
    "repository_storage": "default",
    "approvals_before_merge": 0, // Deprecated. Use merge request approvals API instead.
    "mirror": false,
    "mirror_user_id": 45,
    "mirror_trigger_builds": false,
    "only_mirror_protected_branches": false,
    "mirror_overwrites_diverged_branches": false,
    "external_authorization_classification_label": null,
    "packages_enabled": true, // deprecated, use package_registry_access_level instead
    "empty_repo": false,
    "package_registry_access_level": "enabled",
    "service_desk_enabled": false,
    "service_desk_address": null,
    "autoclose_referenced_issues": true,
    "enforce_auth_checks_on_uploads": true,
    "suggestion_commit_message": null,
    "merge_commit_template": null,
    "mr_default_title_template": null,
    "squash_commit_template": null,
    "secret_push_protection_enabled": false,
    "issue_branch_template": "gitlab/%{id}-%{title}",
    "statistics": {
      "commit_count": 12,
      "storage_size": 2066080,
      "repository_size": 2066080,
      "wiki_size" : 0,
      "lfs_objects_size": 0,
      "job_artifacts_size": 0,
      "pipeline_artifacts_size": 0,
      "packages_size": 0,
      "snippets_size": 0,
      "uploads_size": 0,
      "container_registry_size": 0
    },
    "container_registry_image_prefix": "registry.example.com/brightbox/puppet",
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

<a id="list-all-projects-contributions-for-a-user"></a>

### 列出用户的所有项目贡献

列出指定用户对所有可见项目的贡献。仅返回过去一年的贡献。有关什么算作贡献的更多信息，请参阅[查看您参与的项目](../user/project/working_with_projects.md#view-projects-you-work-with)。

```plaintext
GET /users/:user_id/contributed_projects
```

支持的属性：

| 属性  | 类型    | 必填 | 描述 |
|:-----------|:--------|:---------|:------------|
| `user_id`  | string  | 是      | 用户的 ID 或用户名。 |
| `order_by` | string  | 否       | 按 `id`、`name`、`path`、`created_at`、`updated_at`、`star_count` 或 `last_activity_at` 字段排序返回项目。默认为 `created_at`。 |
| `simple`   | boolean | 否       | 如果为 `true`，则仅返回每个项目的有限字段。未经身份验证的请求仅返回具有有限字段的公共项目，即使未设置 `simple` 也是如此。 |
| `sort`     | string  | 否       | 按 `asc` 或 `desc` 顺序返回排序后的项目。默认为 `desc`。 |

如果成功，返回 [`200 OK`](rest/troubleshooting.md#status-codes) 以及以下响应属性：

<!-- markdownlint-disable MD055 MD056 -->

| 属性 | 类型 | 描述 |
|-----------|------|-------------|
| `id` | integer | 项目的 ID。 |
| `description` | string | 项目的描述。 |
| `name` | string | 项目的名称。 |
| `name_with_namespace` | string | 项目及其命名空间的名称。 |
| `path` | string | 项目的路径。 |
| `path_with_namespace` | string | 项目及其命名空间的路径。 |
| `created_at` | datetime | 项目创建时的时间戳。 |
| `default_branch` | string | 项目的默认分支。 |
| `tag_list` | array of strings | 已弃用。请改用 `topics`。项目的标签列表。 |
| `topics` | array of strings | 项目的主题列表。 |
| `ssh_url_to_repo` | string | 用于克隆代码仓库的 SSH URL。 |
| `http_url_to_repo` | string | 用于克隆代码仓库的 HTTP URL。 |
| `web_url` | string | 在浏览器中访问项目的 URL。 |
| `readme_url` | string | 项目 README 文件的 URL。 |
| `forks_count` | integer | 项目的派生（fork）数量。 |
| `avatar_url` | string | 项目头像图片的 URL。 |
| `star_count` | integer | 项目收到的星标数量。 |
| `last_activity_at` | datetime | 项目中最后活动的时间戳。 |
| `visibility` | string | 项目的可见性级别。可能的值：`private`、`internal` 或 `public`。 |
| `namespace` | object | 项目的命名空间信息。 |
| `namespace.id` | integer | 命名空间的 ID。 |
| `namespace.name` | string | 命名空间的名称。 |
| `namespace.path` | string | 命名空间的路径。 |
| `namespace.kind` | string | 命名空间的类型。可能的值：`user` 或 `group`。 |
| `namespace.full_path` | string | 命名空间的完整路径。 |
| `namespace.parent_id` | integer | 父命名空间的 ID（如果适用）。 |
| `namespace.avatar_url` | string | 命名空间头像图片的 URL。 |
| `namespace.web_url` | string | 在浏览器中访问命名空间的 URL。 |
| `container_registry_image_prefix` | string | 容器镜像仓库镜像的前缀。 |
| `_links` | object | 与项目相关的 API 端点链接集合。 |
| `_links.self` | string | 项目资源的 URL。 |
| `_links.issues` | string | 项目议题的 URL。 |
| `_links.merge_requests` | string | 项目合并请求的 URL。 |
| `_links.repo_branches` | string | 项目代码仓库分支的 URL。 |
| `_links.labels` | string | 项目标记的 URL。 |
| `_links.events` | string | 项目事件的 URL。 |
| `_links.members` | string | 项目成员的 URL。 |
| `_links.cluster_agents` | string | 项目集群代理的 URL。 |
| `marked_for_deletion_at` | date | 已弃用。请改用 `marked_for_deletion_on`。项目计划删除的日期。 |
| `marked_for_deletion_on` | date | 项目计划删除的日期。 |
| `packages_enabled` | boolean | 是否为项目启用了软件包仓库。 |
| `empty_repo` | boolean | 代码仓库是否为空。 |
| `archived` | boolean | 项目是否已归档。 |
| `resolve_outdated_diff_discussions` | boolean | 是否自动解决过时的差异讨论。 |
| `container_expiration_policy` | object | 容器镜像过期策略的设置。 |
| `container_expiration_policy.cadence` | string | 容器过期策略运行的频率。 |
| `container_expiration_policy.enabled` | boolean | 是否启用了容器过期策略。 |
| `container_expiration_policy.keep_n` | integer | 要保留的容器镜像数量。 |
| `container_expiration_policy.older_than` | string | 删除早于此值的容器镜像。 |
| `container_expiration_policy.name_regex` | string | 已弃用。请改用 `name_regex_delete`。用于匹配容器镜像名称的正则表达式。 |
| `container_expiration_policy.name_regex_keep` | string | 用于匹配要保留的容器镜像名称的正则表达式。 |
| `container_expiration_policy.next_run_at` | datetime | 下次计划策略运行的时间戳。 |
| `repository_object_format` | string | 代码仓库使用的对象格式（sha1 或 sha256）。 |
| `issues_enabled` | boolean | 是否为项目启用了议题。 |
| `merge_requests_enabled` | boolean | 是否为项目启用了合并请求。 |
| `wiki_enabled` | boolean | 是否为项目启用了 Wiki。 |
| `jobs_enabled` | boolean | 是否为项目启用了作业。 |
| `snippets_enabled` | boolean | 是否为项目启用了代码片段。 |
| `container_registry_enabled` | boolean | 已弃用。请改用 `container_registry_access_level`。是否启用了容器镜像仓库。 |
| `service_desk_enabled` | boolean | 是否为项目启用了服务台。 |
| `can_create_merge_request_in` | boolean | 当前用户是否可以在项目中创建合并请求。 |
| `issues_access_level` | string | 议题功能的访问级别。可能的值：`disabled`、`private` 或 `enabled`。 |
| `repository_access_level` | string | 代码仓库功能的访问级别。可能的值：`disabled`、`private` 或 `enabled`。 |
| `merge_requests_access_level` | string | 合并请求功能的访问级别。可能的值：`disabled`、`private` 或 `enabled`。 |
| `forking_access_level` | string | 派生（fork）项目的访问级别。可能的值：`disabled`、`private` 或 `enabled`。 |
| `wiki_access_level` | string | Wiki 功能的访问级别。可能的值：`disabled`、`private` 或 `enabled`。 |
| `builds_access_level` | string | CI/CD 构建功能的访问级别。可能的值：`disabled`、`private` 或 `enabled`。 |
| `snippets_access_level` | string | 代码片段功能的访问级别。可能的值：`disabled`、`private` 或 `enabled`。 |
| `pages_access_level` | string | GitLab Pages 的访问级别。可能的值：`disabled`、`private`、`enabled` 或 `public`。 |
| `analytics_access_level` | string | 分析功能的访问级别。可能的值：`disabled`、`private` 或 `enabled`。 |
| `container_registry_access_level` | string | 容器镜像仓库的访问级别。可能的值：`disabled`、`private` 或 `enabled`。 |
| `security_and_compliance_access_level` | string | 安全与合规功能的访问级别。可能的值：`disabled`、`private` 或 `enabled`。 |
| `releases_access_level` | string | 发布功能的访问级别。可能的值：`disabled`、`private` 或 `enabled`。 |
| `environments_access_level` | string | 环境功能的访问级别。可能的值：`disabled`、`private` 或 `enabled`。 |
| `feature_flags_access_level` | string | 功能标志功能的访问级别。可能的值：`disabled`、`private` 或 `enabled`。 |
| `infrastructure_access_level` | string | 基础设施功能的访问级别。可能的值：`disabled`、`private` 或 `enabled`。 |
| `monitor_access_level` | string | 监控功能的访问级别。可能的值：`disabled`、`private` 或 `enabled`。 |
| `model_experiments_access_level` | string | 模型实验功能的访问级别。可能的值：`disabled`、`private` 或 `enabled`。 |
| `model_registry_access_level` | string | 模型仓库功能的访问级别。可能的值：`disabled`、`private` 或 `enabled`。 |
| `package_registry_access_level` | string | 软件包仓库功能的访问级别。可能的值：`disabled`、`private` 或 `enabled`。 |
| `emails_disabled` | boolean | 指示是否为项目禁用了电子邮件。 |
| `emails_enabled` | boolean | 指示是否为项目启用了电子邮件。 |
| `show_diff_preview_in_email` | boolean | 指示是否在电子邮件通知中显示差异预览。 |
| `shared_runners_enabled` | boolean | 是否为项目启用了共享 Runner。 |
| `lfs_enabled` | boolean | 指示是否为项目启用了 Git LFS。 |
| `creator_id` | integer | 创建项目的用户的 ID。 |
| `import_status` | string | 项目导入的状态。 |
| `open_issues_count` | integer | 未关闭的议题数量。 |
| `description_html` | string | 项目描述的 HTML 格式。 |
| `updated_at` | datetime | 项目最后更新的时间戳。 |
| `ci_default_git_depth` | integer | CI/CD 流水线的默认 Git 深度。仅当您具有管理员访问权限或项目的所有者角色时可见。 |
| `ci_forward_deployment_enabled` | boolean | 是否启用了前向部署。仅当您具有管理员访问权限或项目的所有者角色时可见。 |
| `ci_job_token_scope_enabled` | boolean | 指示是否启用了 CI/CD 作业令牌范围。仅当您具有管理员访问权限或项目的所有者角色时可见。 |
| `ci_separated_caches` | boolean | CI/CD 缓存是否按分支分离。仅当您具有管理员访问权限或项目的所有者角色时可见。 |
| `ci_allow_fork_pipelines_to_run_in_parent_project` | boolean | 派生（fork）的流水线是否可以在父项目中运行。仅当您具有管理员访问权限或项目的所有者角色时可见。 |
| `build_git_strategy` | string | 用于 CI/CD 构建的 Git 策略（fetch 或 clone）。仅当您具有管理员访问权限或项目的所有者角色时可见。 |
| `keep_latest_artifact` | boolean | 指示创建新产物时是否保留最新产物。仅当您具有管理员访问权限或项目的所有者角色时可见。 |
| `restrict_user_defined_variables` | boolean | 是否限制用户定义的变量。仅当您具有管理员访问权限或项目的所有者角色时可见。 |
| `runners_token` | string | 用于向项目注册 Runner 的令牌。仅当您具有管理员访问权限或项目的所有者角色时可见。 |
| `runner_token_expiration_interval` | integer | Runner 令牌的过期时间间隔（秒）。仅当您具有管理员访问权限或项目的所有者角色时可见。 |
| `group_runners_enabled` | boolean | 是否为项目启用了群组 Runner。仅当您具有管理员访问权限或项目的所有者角色时可见。 |
| `auto_cancel_pending_pipelines` | string | 自动取消待处理流水线的设置。仅当您具有管理员访问权限或项目的所有者角色时可见。 |
| `build_timeout` | integer | CI/CD 作业的超时时间（秒）。仅当您具有管理员访问权限或项目的所有者角色时可见。 |
| `auto_devops_enabled` | boolean | 是否为项目启用了 Auto DevOps。仅当您具有管理员访问权限或项目的所有者角色时可见。 |
| `auto_devops_deploy_strategy` | string | Auto DevOps 的部署策略。仅当您具有管理员访问权限或项目的所有者角色时可见。 |
| `ci_config_path` | string | CI/CD 配置文件的路径。 |
| `public_jobs` | boolean | 作业日志是否可公开访问。 |
| `shared_with_groups` | array of objects | 与之共享项目的群组列表。 |
| `only_allow_merge_if_pipeline_succeeds` | boolean | 是否仅当流水线成功时才允许合并。 |
| `allow_merge_on_skipped_pipeline` | boolean | 当流水线被跳过时是否允许合并。 |
| `request_access_enabled` | boolean | 用户是否可以请求访问项目。 |
| `only_allow_merge_if_all_discussions_are_resolved` | boolean | 是否仅当所有讨论都已解决时才允许合并。 |
| `remove_source_branch_after_merge` | boolean | 合并后是否自动删除源分支。 |
| `printing_merge_request_link_enabled` | boolean | 指示推送后是否打印合并请求链接。 |
| `merge_method` | string | 项目使用的合并方法。可能的值：`merge`、`rebase_merge` 或 `ff`。 |
| `merge_request_title_regex` | string | 用于验证合并请求标题的正则表达式模式。 |
| `merge_request_title_regex_description` | string | 合并请求标题正则表达式验证的描述。 |
| `squash_option` | string | 合并请求的压缩（squash）选项。 |
| `automatic_rebase_enabled` | boolean | 指示合并前是否自动变基（rebase）源分支。 |
| `enforce_auth_checks_on_uploads` | boolean | 是否对上传强制执行身份验证检查。 |
| `suggestion_commit_message` | string | 建议的自定义提交消息。 |
| `merge_commit_template` | string | 合并提交消息的模板。 |
| `mr_default_title_template` | string | 合并请求标题的模板。 |
| `squash_commit_template` | string | 压缩（squash）提交消息的模板。 |
| `issue_branch_template` | string | 从议题创建的分支名称的模板。 |
| `warn_about_potentially_unwanted_characters` | boolean | 是否警告可能不需要的字符。 |
| `autoclose_referenced_issues` | boolean | 是否自动关闭被引用的议题。 |
| `max_artifacts_size` | integer | CI/CD 产物的最大大小（MB）。 |
| `approvals_before_merge` | integer | 已弃用。请改用合并请求审批 API。合并前所需的审批数量。 |
| `mirror` | boolean | 项目是否为镜像。 |
| `external_authorization_classification_label` | string | 外部授权分类标记。 |
| `requirements_enabled` | boolean | 指示是否启用了需求管理。 |
| `requirements_access_level` | string | 需求功能的访问级别。 |
| `security_and_compliance_enabled` | boolean | 指示是否启用了安全与合规功能。 |
| `compliance_frameworks` | array of strings | 应用于项目的合规框架。 |
| `issues_template` | string | 议题的默认描述。描述使用极狐GitLab 风格 Markdown 解析。仅限专业版和旗舰版。 |
| `merge_requests_template` | string | 合并请求描述的模板。仅限专业版和旗舰版。 |
| `merge_pipelines_enabled` | boolean | 指示是否启用了合并流水线。 |
| `merge_trains_enabled` | boolean | 指示是否启用了合并列车。 |
| `merge_trains_skip_train_allowed` | boolean | 指示是否允许跳过合并列车。 |
| `merge_train_enforcement` | string | 合并列车强制级别。可以是 `allow_bypass`、`enforce_for_all_users` 或 `enforce_with_owner_override` 之一。除非为项目启用了合并列车，否则无效。 |
| `max_pipelines_per_merge_train` | integer | 每个合并列车的最大并行流水线数量。 |
| `only_allow_merge_if_all_status_checks_passed` | boolean | 是否仅当所有状态检查都已通过时才允许合并。仅限旗舰版。 |
| `allow_pipeline_trigger_approve_deployment` | boolean | 流水线触发器是否可以批准部署。 |
| `prevent_merge_without_jira_issue` | boolean | 指示合并是否需要关联的 Jira 议题。 |
| `reviewer_assignment_strategy` | string | 用于自动分配审核人到合并请求的策略。取值为 `disabled` 或 `code_owners` 之一。对于在极狐GitLab 19.4 之前配置的项目，此属性也可以返回 `dap_powered`。仅限专业版和旗舰版。 |
| `duo_remote_flows_enabled` | boolean | 指示是否启用了极狐GitLab Duo 远程任务流。 |
| `duo_foundational_flows_enabled` | boolean | 指示是否启用了极狐GitLab Duo 内置任务流。 |
| `duo_sast_fp_detection_enabled` | boolean | 指示是否启用了极狐GitLab Duo SAST 误报检测。 |
| `duo_sast_vr_workflow_enabled` | boolean | 指示是否启用了极狐GitLab Duo SAST 漏洞解决工作流。 |
| `spp_repository_pipeline_access` | boolean | 安全策略的代码仓库流水线访问。仅当安全编排策略功能可用时可见。 |
| `permissions` | object | 用户对项目的权限。 |
| `permissions.project_access` | object | 用户的项目访问权限。 |
| `permissions.group_access` | object | 用户的群组访问权限。 |
{.condensed}

<!-- markdownlint-enable MD055 MD056 -->

示例请求：

```shell
curl --header "PRIVATE-TOKEN: <your_access_token>" \
  --url "https://gitlab.example.com/api/v4/users/5/contributed_projects"
```

示例响应：

```json
[
  {
    "id": 4,
    "description": "Lorem ipsum dolor sit amet, consectetur adipiscing elit.",
    "description_html": "<p data-sourcepos=\"1:1-1:56\" dir=\"auto\">Lorem ipsum dolor sit amet, consectetur adipiscing elit.</p>",
    "default_branch": "main",
    "visibility": "private",
    "ssh_url_to_repo": "git@example.com:diaspora/diaspora-client.git",
    "http_url_to_repo": "http://example.com/diaspora/diaspora-client.git",
    "web_url": "http://example.com/diaspora/diaspora-client",
    "readme_url": "http://example.com/diaspora/diaspora-client/blob/main/README.md",
    "tag_list": [ //deprecated, use `topics` instead
      "example",
      "disapora client"
    ],
    "topics": [
      "example",
      "disapora client"
    ],
    "owner": {
      "id": 3,
      "name": "Diaspora",
      "created_at": "2013-09-30T13:46:02Z"
    },
    "name": "Diaspora Client",
    "name_with_namespace": "Diaspora / Diaspora Client",
    "path": "diaspora-client",
    "path_with_namespace": "diaspora/diaspora-client",
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
    "archived": false,
    "avatar_url": "http://example.com/uploads/project/avatar/4/uploads/avatar.png",
    "shared_runners_enabled": true,
    "group_runners_enabled": true,
    "forks_count": 0,
    "star_count": 0,
    "runners_token": "b8547b1dc37721d05889db52fa2f02",
    "public_jobs": true,
    "shared_with_groups": [],
    "only_allow_merge_if_pipeline_succeeds": false,
    "allow_merge_on_skipped_pipeline": false,
    "allow_pipeline_trigger_approve_deployment": false,
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
    "mr_default_title_template": null,
    "squash_commit_template": null,
    "secret_push_protection_enabled": false,
    "issue_branch_template": "gitlab/%{id}-%{title}",
    "statistics": {
      "commit_count": 37,
      "storage_size": 1038090,
      "repository_size": 1038090,
      "lfs_objects_size": 0,
      "job_artifacts_size": 0,
      "pipeline_artifacts_size": 0,
      "packages_size": 0,
      "snippets_size": 0,
      "uploads_size": 0,
      "container_registry_size": 0
    },
    "container_registry_image_prefix": "registry.example.com/diaspora/diaspora-client",
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
  },
  {
    "id": 6,
    "description": "Lorem ipsum dolor sit amet, consectetur adipiscing elit.",
    "description_html": "<p data-sourcepos=\"1:1-1:56\" dir=\"auto\">Lorem ipsum dolor sit amet, consectetur adipiscing elit.</p>",
    "default_branch": "main",
    "visibility": "private",
    "ssh_url_to_repo": "git@example.com:brightbox/puppet.git",
    "http_url_to_repo": "http://example.com/brightbox/puppet.git",
    "web_url": "http://example.com/brightbox/puppet",
    "readme_url": "http://example.com/brightbox/puppet/blob/main/README.md",
    "tag_list": [ //deprecated, use `topics` instead
      "example",
      "puppet"
    ],
    "topics": [
      "example",
      "puppet"
    ],
    "owner": {
      "id": 4,
      "name": "Brightbox",
      "created_at": "2013-09-30T13:46:02Z"
    },
    "name": "Puppet",
    "name_with_namespace": "Brightbox / Puppet",
    "path": "puppet",
    "path_with_namespace": "brightbox/puppet",
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
      "id": 4,
      "name": "Brightbox",
      "path": "brightbox",
      "kind": "group",
      "full_path": "brightbox"
    },
    "import_status": "none",
    "import_error": null,
    "permissions": {
      "project_access": {
        "access_level": 10,
        "notification_level": 3
      },
      "group_access": {
        "access_level": 50,
        "notification_level": 3
      }
    },
    "archived": false,
    "avatar_url": null,
    "shared_runners_enabled": true,
    "group_runners_enabled": true,
    "forks_count": 0,
    "star_count": 0,
    "runners_token": "b8547b1dc37721d05889db52fa2f02",
    "public_jobs": true,
    "shared_with_groups": [],
    "only_allow_merge_if_pipeline_succeeds": false,
    "allow_merge_on_skipped_pipeline": false,
    "allow_pipeline_trigger_approve_deployment": false,
    "restrict_user_defined_variables": false,
    "only_allow_merge_if_all_discussions_are_resolved": false,
    "remove_source_branch_after_merge": false,
    "request_access_enabled": false,
    "merge_method": "merge",
    "squash_option": "default_on",
    "auto_devops_enabled": true,
    "auto_devops_deploy_strategy": "continuous",
    "repository_storage": "default",
    "approvals_before_merge": 0, // Deprecated. Use merge request approvals API instead.
    "mirror": false,
    "mirror_user_id": 45,
    "mirror_trigger_builds": false,
    "only_mirror_protected_branches": false,
    "mirror_overwrites_diverged_branches": false,
    "external_authorization_classification_label": null,
    "packages_enabled": true, // deprecated, use package_registry_access_level instead
    "empty_repo": false,
    "package_registry_access_level": "enabled",
    "service_desk_enabled": false,
    "service_desk_address": null,
    "autoclose_referenced_issues": true,
    "enforce_auth_checks_on_uploads": true,
    "suggestion_commit_message": null,
    "merge_commit_template": null,
    "mr_default_title_template": null,
    "squash_commit_template": null,
    "secret_push_protection_enabled": false,
    "issue_branch_template": "gitlab/%{id}-%{title}",
    "statistics": {
      "commit_count": 12,
      "storage_size": 2066080,
      "repository_size": 2066080,
      "lfs_objects_size": 0,
      "job_artifacts_size": 0,
      "pipeline_artifacts_size": 0,
      "packages_size": 0,
      "snippets_size": 0,
      "uploads_size": 0,
      "container_registry_size": 0
    },
    "container_registry_image_prefix": "registry.example.com/brightbox/puppet",
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

<a id="list-attributes"></a>

## 列出属性

列出项目的属性。

<a id="list-all-members-of-a-project"></a>

### 列出项目的所有成员

列出对指定项目具有访问权限的所有成员。

```plaintext
GET /projects/:id/users
```

支持的属性：

| 属性    | 类型              | 必填 | 描述 |
|:-------------|:------------------|:---------|:------------|
| `id`         | integer or string | 是      | 项目的 ID 或 [URL 编码路径](rest/_index.md#namespaced-paths)。 |
| `search`     | string            | 否       | 按成员的 `username` 或 `name` 搜索特定成员。 |
| `skip_users` | integer array     | 否       | 过滤掉具有指定 ID 的成员。 |

如果成功，返回 [`200 OK`](rest/troubleshooting.md#status-codes) 以及以下响应属性：

| 属性 | 类型 | 描述 |
|:----------|:-----|:------------|
| `id` | integer | 用户的 ID。 |
| `username` | string | 用户的用户名。 |
| `name` | string | 用户的全名。 |
| `state` | string | 用户帐户的状态。可能的值：`active` 或 `blocked`。 |
| `avatar_url` | string | 用户头像图片的 URL。 |
| `web_url` | string | 在浏览器中访问用户个人资料的 URL。 |

示例请求：

```shell
curl --header "PRIVATE-TOKEN: <your_access_token>" \
     --url "https://gitlab.com/api/v4/projects/<project_id>/users" \
```

示例响应：

```json
[
  {
    "id": 1,
    "username": "john_smith",
    "name": "John Smith",
    "state": "active",
    "avatar_url": "http://localhost:3000/uploads/user/avatar/1/cd8.jpeg",
    "web_url": "http://localhost:3000/john_smith"
  },
  {
    "id": 2,
    "username": "jack_smith",
    "name": "Jack Smith",
    "state": "blocked",
    "avatar_url": "http://gravatar.com/../e32131cd8.jpeg",
    "web_url": "http://localhost:3000/jack_smith"
  }
]
```

<a id="list-all-ancestor-groups"></a>

### 列出所有祖先群组

列出指定项目的所有祖先群组。

```plaintext
GET /projects/:id/groups
```

支持的属性：

| 属性                 | 类型              | 必填 | 描述 |
|:--------------------------|:------------------|:---------|:------------|
| `id`                      | integer or string | 是      | 项目的 ID 或 [URL 编码路径](rest/_index.md#namespaced-paths)。 |
| `search`                  | string            | 否       | 按群组 ID 搜索特定群组。 |
| `shared_min_access_level` | integer           | 否       | 限制为至少具有指定访问级别的共享群组。可能的值：`5`（最小访问权限）、`10`（访客）、`15`（计划者）、`20`（报告者）、`25`（安全管理员）、`30`（开发者）、`40`（维护者）或 `50`（所有者）。 |
| `shared_visible_only`     | boolean           | 否       | 如果为 `true`，则仅返回经过身份验证的用户可以访问的共享群组。 |
| `skip_groups`             | array of integers | 否       | 跳过传入的群组 ID。 |
| `with_shared`             | boolean           | 否       | 包含与此群组共享的项目。默认为 `false`。 |

如果成功，返回 [`200 OK`](rest/troubleshooting.md#status-codes) 以及以下响应属性：

| 属性 | 类型 | 描述 |
|:----------|:-----|:------------|
| `id` | integer | 群组的 ID。 |
| `name` | string | 群组的名称。 |
| `avatar_url` | string | 群组头像图片的 URL。 |
| `web_url` | string | 在浏览器中访问群组的 URL。 |
| `full_name` | string | 群组的全名。 |
| `full_path` | string | 群组的完整路径。 |

示例请求：

```shell
curl --header "PRIVATE-TOKEN: <your_access_token>" \
     --url "https://gitlab.example.com/api/v4/projects/<project_id>/groups"
```

示例响应：

```json
[
  {
    "id": 1,
    "name": "Foobar Group",
    "avatar_url": "http://localhost:3000/uploads/group/avatar/1/foo.jpg",
    "web_url": "http://localhost:3000/groups/foo-bar",
    "full_name": "Foobar Group",
    "full_path": "foo-bar"
  },
  {
    "id": 2,
    "name": "Shared Group",
    "avatar_url": "http://gitlab.example.com/uploads/group/avatar/1/bar.jpg",
    "web_url": "http://gitlab.example.com/groups/foo/bar",
    "full_name": "Shared Group",
    "full_path": "foo/shared"
  }
]
```

<a id="list-all-groups-available-to-invite-to-a-project"></a>

### 列出可邀请到项目的所有群组

列出可以邀请到项目的所有群组。

```plaintext
GET /projects/:id/share_locations
```

支持的属性：

| 属性 | 类型              | 必填 | 描述 |
|:----------|:------------------|:---------|:------------|
| `id`      | integer or string | 是      | 项目的 ID 或 [URL 编码路径](rest/_index.md#namespaced-paths)。 |
| `search`  | string            | 否       | 按群组 ID 搜索特定群组。 |

如果成功，返回 [`200 OK`](rest/troubleshooting.md#status-codes) 以及以下响应属性：

| 属性 | 类型 | 描述 |
|:----------|:-----|:------------|
| `id` | integer | 群组的 ID。 |
| `web_url` | string | 在浏览器中访问群组的 URL。 |
| `name` | string | 群组的名称。 |
| `avatar_url` | string | 群组头像图片的 URL。 |
| `full_name` | string | 群组的全名。 |
| `full_path` | string | 群组的完整路径。 |

示例请求：

```shell
curl --header "PRIVATE-TOKEN: <your_access_token>" \
     --url "https://gitlab.example.com/api/v4/projects/<project_id>/share_locations"
```

示例响应：

```json
[
  {
    "id": 22,
    "web_url": "http://127.0.0.1:3000/groups/gitlab-org",
    "name": "Gitlab Org",
    "avatar_url": null,
    "full_name": "Gitlab Org",
    "full_path": "gitlab-org"
  },
  {
    "id": 25,
    "web_url": "http://127.0.0.1:3000/groups/gnuwget",
    "name": "Gnuwget",
    "avatar_url": null,
    "full_name": "Gnuwget",
    "full_path": "gnuwget"
  }
]
```

<a id="list-all-invited-groups-in-a-project"></a>

### 列出项目中的所有受邀群组

列出项目中的所有受邀群组。未经身份验证访问时，仅返回公共受邀群组。
此端点按以下维度限制为每分钟 60 个请求：

- 对于经过身份验证的用户，按用户限制
- 对于未经身份验证的用户，按 IP 地址限制

此端点支持分页：

- 使用基于偏移量的分页可访问最多 50,000 个项目。
- 使用基于键集的分页可列出超过 50,000 个项目。

有关更多信息，请参阅[分页](rest/_index.md#pagination)。

```plaintext
GET /projects/:id/invited_groups
```

支持的属性：

| 属性                | 类型             | 必填 | 描述 |
|:-------------------------|:-----------------|:---------|:------------|
| `id`                     | integer or string   | 是      | 群组的 ID 或 [URL 编码路径](rest/_index.md#namespaced-paths)。 |
| `search`                 | string           | 否       | 返回与搜索条件匹配的授权群组列表。 |
| `min_access_level`       | integer          | 否       | 限制为当前用户至少具有指定访问级别的群组。可能的值：`5`（最小访问权限）、`10`（访客）、`15`（计划者）、`20`（报告者）、`25`（安全管理员）、`30`（开发者）、`40`（维护者）或 `50`（所有者）。 |
| `relation`               | array of strings | 否       | 按关系过滤群组。可能的值：`direct` 或 `inherited`。 |
| `with_custom_attributes` | boolean          | 否       | 如果为 `true`，则在响应中返回[自定义属性](custom_attributes.md)。需要管理员访问权限。 |

如果成功，返回 [`200 OK`](rest/troubleshooting.md#status-codes) 以及以下响应属性：

| 属性 | 类型 | 描述 |
|:----------|:-----|:------------|
| `id` | integer | 群组的 ID。 |
| `web_url` | string | 在浏览器中访问群组的 URL。 |
| `name` | string | 群组的名称。 |
| `avatar_url` | string | 群组头像图片的 URL。 |
| `full_name` | string | 群组的全名。 |
| `full_path` | string | 群组的完整路径。 |

示例请求：

```shell
curl --header "PRIVATE-TOKEN: <your_access_token>" \
     --url "https://gitlab.example.com/api/v4/projects/<project_id>/invited_groups"
```

示例响应：

```json
[
  {
    "id": 35,
    "web_url": "https://gitlab.example.com/groups/twitter",
    "name": "Twitter",
    "avatar_url": null,
    "full_name": "Twitter",
    "full_path": "twitter"
  }
]
```

<a id="retrieve-programming-language-usage-information"></a>

### 检索编程语言使用信息

检索指定项目中使用的所有编程语言的信息。

```plaintext
GET /projects/:id/languages
```

支持的属性：

| 属性 | 类型              | 必填 | 描述 |
|:----------|:------------------|:---------|:------------|
| `id`      | integer or string | 是      | 项目的 ID 或 [URL 编码路径](rest/_index.md#namespaced-paths)。 |

如果成功，返回 [`200 OK`](rest/troubleshooting.md#status-codes) 以及编程语言和使用百分比列表。

示例请求：

```shell
curl --header "PRIVATE-TOKEN: <your_access_token>" \
  --url "https://gitlab.example.com/api/v4/projects/5/languages"
```

示例响应：

```json
{
  "Ruby": 66.69,
  "JavaScript": 22.98,
  "HTML": 7.91,
  "CoffeeScript": 2.42
}
```

<a id="manage-projects"></a>

## 管理项目

管理项目，包括创建、删除和归档。

<a id="create-a-project"></a>

### 创建项目

创建由已认证用户拥有的项目。

如果您的 HTTP 代码仓库不公开可访问，请在 URL 中添加认证信息
`https://username:password@gitlab.company.com/group/project.git`，其中 `password` 是启用了 `api`
范围的公共访问密钥。

```plaintext
POST /projects
```

> [!note]
> 当您创建项目并将 `package_registry_access_level` 设置为 `disabled` 时，软件包仓库可能仍保持启用状态。
> 作为变通方法，请在同一个请求中也将 `packages_enabled` 设置为 `false`。
> 有关更多信息，请参阅[议题 572010](https://gitlab.com/gitlab-org/gitlab/-/work_items/572010)。

支持的一般项目属性：

| 属性                                          | 类型    | 必填                       | 描述 |
|:---------------------------------------------------|:--------|:-------------------------------|:------------|
| `name`                                             | string  | 是（如果未提供 `path`） | 新项目的名称。如果未提供，则等于路径。 |
| `path`                                             | string  | 是（如果未提供 `name`） | 新项目的代码仓库名称。如果未提供，则根据名称生成（生成为带连字符的小写形式）。路径不得以特殊字符开头或结尾，且不得包含连续的特殊字符。 |
| `allow_merge_on_skipped_pipeline`                  | boolean | 否                             | 设置合并请求是否可以在有跳过作业的情况下合并。 |
| `approvals_before_merge`                           | integer | 否                             | 默认情况下需要多少审批人批准合并请求。要配置审批规则，请参阅[合并请求审批 API](merge_request_approvals.md)。在极狐GitLab 16.0 中[已弃用](https://gitlab.com/gitlab-org/gitlab/-/issues/353097)。仅限专业版和旗舰版。 |
| `auto_cancel_pending_pipelines`                    | string  | 否                             | 自动取消待处理的流水线。此操作在启用状态和禁用状态之间切换；它不是布尔值。 |
| `auto_devops_deploy_strategy`                      | string  | 否                             | 自动部署策略（`continuous`、`manual` 或 `timed_incremental`）。 |
| `auto_devops_enabled`                              | boolean | 否                             | 为此项目启用 Auto DevOps。 |
| `autoclose_referenced_issues`                      | boolean | 否                             | 设置是否在默认分支上自动关闭引用的议题。 |
| `avatar`                                           | mixed   | 否                             | 项目头像的图像文件。 |
| `build_git_strategy`                               | string  | 否                             | Git 策略。默认为 `fetch`。 |
| `build_timeout`                                    | integer | 否                             | 作业可以运行的最长时间（以秒为单位）。 |
| `ci_config_path`                                   | string  | 否                             | CI 配置文件的路径。 |
| `cicd_catalog_enabled`                             | boolean | 否                             | 设置项目是否发布到 [CI/CD Catalog](../ci/components/_index.md#cicd-catalog)。需要项目的所有者角色。在极狐GitLab 19.3 中[引入](https://gitlab.com/gitlab-org/gitlab/-/issues/463043)。 |
| `container_expiration_policy_attributes`           | hash    | 否                             | 更新此项目的镜像清理策略。接受：`cadence`（string）、`keep_n`（integer）、`older_than`（string）、`name_regex`（string）、`name_regex_delete`（string）、`name_regex_keep`（string）、`enabled`（boolean）。有关 `cadence`、`keep_n` 和 `older_than` 值的更多信息，请参阅[容器镜像仓库](../user/packages/container_registry/reduce_container_registry_storage.md#use-the-cleanup-policy-api)文档。 |
| `container_registry_enabled`                       | boolean | 否                             | _（已弃用）_ 为此项目启用容器镜像仓库。请改用 `container_registry_access_level`。 |
| `default_branch`                                   | string  | 否                             | [默认分支](../user/project/repository/branches/default.md)名称。接受分支名称（例如，`main`）或完全限定的引用（例如，`refs/heads/main`）。如果提供了完全限定的引用，API 会去除 `refs/heads/` 前缀。要求 `initialize_with_readme` 为 `true`。 |
| `description`                                      | string  | 否                             | 简短的项目描述。 |
| `emails_disabled`                                  | boolean | 否                             | _（已弃用）_ 禁用电子邮件通知。请改用 `emails_enabled` |
| `emails_enabled`                                   | boolean | 否                             | 启用电子邮件通知。 |
| `external_authorization_classification_label`      | string  | 否                             | 项目的分类标记。仅限专业版和旗舰版。 |
| `group_runners_enabled`                            | boolean | 否                             | 为此项目启用群组 Runner。 |
| `group_with_project_templates_id`                  | integer | 否                             | 对于群组级自定义模板，指定所有自定义项目模板来源的群组 ID。对于实例级模板，请留空。要求 `use_custom_template` 为 true。仅限专业版和旗舰版。 |
| `import_url`                                       | string  | 否                             | 从中导入代码仓库的 URL。当 URL 值不为空时，您不得将 `initialize_with_readme` 设置为 `true`。这样做可能会导致[以下错误](https://gitlab.com/gitlab-org/gitlab/-/issues/360266)：`not a git repository`。 |
| `initialize_with_readme`                           | boolean | 否                             | 是否创建仅包含 `README.md` 文件的 Git 代码仓库。默认为 `false`。当此布尔值为 true 时，您不得传递 `import_url` 或此端点的其他指定代码仓库替代内容的属性。这样做可能会导致[以下错误](https://gitlab.com/gitlab-org/gitlab/-/issues/360266)：`not a git repository`。 |
| `issues_enabled`                                   | boolean | 否                             | _（已弃用）_ 为此项目启用议题。请改用 `issues_access_level`。 |
| `jobs_enabled`                                     | boolean | 否                             | _（已弃用）_ 为此项目启用作业。请改用 `builds_access_level`。 |
| `lfs_enabled`                                      | boolean | 否                             | 启用 LFS。 |
| `merge_method`                                     | string  | 否                             | 设置项目的[合并方法](../user/project/merge_requests/methods/_index.md)。可以是 `merge`（合并提交）、`rebase_merge`（半线性历史的合并提交）或 `ff`（快进合并）。 |
| `merge_pipelines_enabled`                          | boolean | 否                             | 启用或禁用合并结果流水线。 |
| `merge_requests_enabled`                           | boolean | 否                             | _（已弃用）_ 为此项目启用合并请求。请改用 `merge_requests_access_level`。 |
| `merge_trains_enabled`                             | boolean | 否                             | 启用或禁用合并列车。 |
| `merge_trains_skip_train_allowed`                  | boolean | 否                             | 允许合并列车合并请求无需等待流水线完成即可合并。 |
| `merge_train_enforcement`                          | string  | 否                             | 合并列车强制级别。可以是 `allow_bypass`、`enforce_for_all_users` 或 `enforce_with_owner_override` 之一。除非为项目启用了合并列车，否则无效。 |
| `max_pipelines_per_merge_train`                    | integer | 否                             | 每个合并列车的最大并行流水线数。 |
| `mirror_trigger_builds`                            | boolean | 否                             | 拉取镜像触发构建。仅限专业版和旗舰版。 |
| `mirror`                                           | boolean | 否                             | 在项目中启用拉取镜像。仅限专业版和旗舰版。 |
| `namespace_id`                                     | integer | 否                             | 新项目的命名空间。指定群组 ID 或子群组 ID。如果未提供，则默认为当前用户的个人命名空间。 |
| `only_allow_merge_if_all_discussions_are_resolved` | boolean | 否                             | 设置合并请求是否只能在所有讨论都解决后才能合并。 |
| `only_allow_merge_if_all_status_checks_passed`     | boolean | 否                             | 指示除非所有状态检查都已通过，否则应阻止合并请求的合并。默认为 false。仅限旗舰版。 |
| `only_allow_merge_if_pipeline_succeeds`            | boolean | 否                             | 设置合并请求是否只能在流水线成功时合并。此设置在项目设置中命名为 [**流水线必须成功**](../user/project/merge_requests/auto_merge.md#require-a-successful-pipeline-for-merge)。 |
| `packages_enabled`                                 | boolean | 否                             | 在极狐GitLab 17.10 中[已弃用](https://gitlab.com/gitlab-org/gitlab/-/issues/454759)。启用或禁用软件包仓库功能。请改用 `package_registry_access_level`。 |
| `package_registry_access_level`                    | string  | 否                             | 启用或禁用软件包仓库功能。 |
| `printing_merge_request_link_enabled`              | boolean | 否                             | 从命令行推送时显示创建/查看合并请求的链接。 |
| `public_builds`                                    | boolean | 否                             | _（已弃用）_ 如果为 `true`，则非项目成员可以查看作业。请改用 `public_jobs`。 |
| `public_jobs`                                      | boolean | 否                             | 如果为 `true`，则非项目成员可以查看作业。 |
| `repository_object_format`                         | string  | 否                             | 代码仓库对象格式。默认为 `sha1`。 |
| `remove_source_branch_after_merge`                 | boolean | 否                             | 默认对所有新合并请求启用 `Delete source branch` 选项。 |
| `repository_storage`                               | string  | 否                             | 代码仓库所在的存储分片。_（仅限管理员）_ |
| `request_access_enabled`                           | boolean | 否                             | 允许用户请求成员访问权限。 |
| `resolve_outdated_diff_discussions`                | boolean | 否                             | 在推送更改的行上自动解决合并请求差异讨论。 |
| `reviewer_assignment_strategy`                     | string  | 否                             | 用于自动将审核人分配给合并请求的策略。可以是 `disabled` 或 `code_owners` 之一。对于在极狐GitLab 19.4 之前配置的项目，此属性也可以返回 `dap_powered`。仅限专业版和旗舰版。 |
| `shared_runners_enabled`                           | boolean | 否                             | 为此项目启用实例 Runner。 |
| `show_default_award_emojis`                        | boolean | 否                             | 显示默认的表情符号反应。 |
| `snippets_enabled`                                 | boolean | 否                             | _（已弃用）_ 为此项目启用代码片段。请改用 `snippets_access_level`。 |
| `squash_option`                                    | string  | 否                             | 可以是 `never`、`always`、`default_on` 或 `default_off` 之一。 |
| `tag_list`                                         | array   | 否                             | 项目的标签列表；放置最终应分配给项目的标签数组。在极狐GitLab 14.0 中[已弃用](https://gitlab.com/gitlab-org/gitlab/-/issues/328226)。请改用 `topics`。 |
| `template_name`                                    | string  | 否                             | 当不与 `use_custom_template` 一起使用时，为[内置项目模板](../user/project/_index.md#create-a-project-from-a-built-in-template)的名称。当与 `use_custom_template` 一起使用时，为自定义项目模板的名称。 |
| `template_project_id`                              | integer | 否                             | 当与 `use_custom_template` 一起使用时，为自定义项目模板的项目 ID。使用项目 ID 优于使用 `template_name`，因为 `template_name` 可能不明确。仅限专业版和旗舰版。 |
| `topics`                                           | array   | 否                             | 项目的主题列表；放置最终应分配给项目的主题数组。 |
| `use_custom_template`                              | boolean | 否                             | 使用自定义[实例](../administration/project_templates.md)或[群组](../user/group/custom_project_templates.md)（使用 `group_with_project_templates_id`）项目模板。仅限专业版和旗舰版。 |
| `visibility`                                       | string  | 否                             | 请参阅[项目可见性级别](#project-visibility-level)。 |
| `warn_about_potentially_unwanted_characters`       | boolean | 否                             | 启用关于在此项目中使用可能不需要的字符的警告。 |
| `wiki_enabled`                                     | boolean | 否                             | _（已弃用）_ 为此项目启用 Wiki。请改用 `wiki_access_level`。 |

示例请求：

```shell
curl --request POST --header "PRIVATE-TOKEN: <your-token>" \
     --header "Content-Type: application/json" --data '{
        "name": "new_project", "description": "New Project", "path": "new_project",
        "namespace_id": "42", "initialize_with_readme": "true"}' \
     --url "https://gitlab.example.com/api/v4/projects/"
```

要设置单个项目功能的可见性级别，
请参阅[项目功能可见性级别](#project-feature-visibility-level)。

<a id="create-a-project-for-a-user"></a>

### 为用户创建项目

为用户创建项目。

先决条件：

- 您必须是管理员。

如果您的 HTTP 代码仓库不公开可访问，请在 URL 中添加认证信息。例如，
`https://username:password@gitlab.company.com/group/project.git`，其中 `password` 是启用了 `api`
范围的公共访问密钥。

```plaintext
POST /projects/user/:user_id
```

支持的一般项目属性：

| 属性                                          | 类型    | 必填 | 描述 |
|:---------------------------------------------------|:--------|:---------|:------------|
| `name`                                             | string  | 是      | 新项目的名称。 |
| `user_id`                                          | integer | 是      | 项目所有者的用户 ID。 |
| `allow_merge_on_skipped_pipeline`                  | boolean | 否       | 设置合并请求是否可以在有跳过作业的情况下合并。 |
| `approvals_before_merge`                           | integer | 否       | 默认情况下需要多少审批人批准合并请求。在极狐GitLab 16.0 中[已弃用](https://gitlab.com/gitlab-org/gitlab/-/issues/353097)。要配置审批规则，请参阅[合并请求审批 API](merge_request_approvals.md)。仅限专业版和旗舰版。 |
| `auto_cancel_pending_pipelines`                    | string  | 否       | 自动取消待处理的流水线。此操作在启用状态和禁用状态之间切换；它不是布尔值。 |
| `auto_devops_deploy_strategy`                      | string  | 否       | 自动部署策略（`continuous`、`manual` 或 `timed_incremental`）。 |
| `auto_devops_enabled`                              | boolean | 否       | 为此项目启用 Auto DevOps。 |
| `autoclose_referenced_issues`                      | boolean | 否       | 设置是否在默认分支上自动关闭引用的议题。 |
| `avatar`                                           | mixed   | 否       | 项目头像的图像文件。 |
| `build_git_strategy`                               | string  | 否       | Git 策略。默认为 `fetch`。 |
| `build_timeout`                                    | integer | 否       | 作业可以运行的最长时间（以秒为单位）。 |
| `ci_config_path`                                   | string  | 否       | CI 配置文件的路径。 |
| `cicd_catalog_enabled`                             | boolean | 否       | 设置项目是否发布到 [CI/CD Catalog](../ci/components/_index.md#cicd-catalog)。需要项目的所有者角色。在极狐GitLab 19.3 中[引入](https://gitlab.com/gitlab-org/gitlab/-/issues/463043)。 |
| `container_registry_enabled`                       | boolean | 否       | _（已弃用）_ 为此项目启用容器镜像仓库。请改用 `container_registry_access_level`。 |
| `default_branch`                                   | string  | 否       | [默认分支](../user/project/repository/branches/default.md)名称。要求 `initialize_with_readme` 为 `true`。 |
| `description`                                      | string  | 否       | 简短的项目描述。 |
| `emails_disabled`                                  | boolean | 否       | _（已弃用）_ 禁用电子邮件通知。请改用 `emails_enabled` |
| `emails_enabled`                                   | boolean | 否       | 启用电子邮件通知。 |
| `enforce_auth_checks_on_uploads`                   | boolean | 否       | 对上传强制执行[认证检查](../security/user_file_uploads.md#enable-authorization-checks-for-all-media-files)。 |
| `external_authorization_classification_label`      | string  | 否       | 项目的分类标记。仅限专业版和旗舰版。 |
| `group_runners_enabled`                            | boolean | 否       | 为此项目启用群组 Runner。 |
| `group_with_project_templates_id`                  | integer | 否       | 对于群组级自定义模板，指定所有自定义项目模板来源的群组 ID。对于实例级模板，请留空。要求 `use_custom_template` 为 true。仅限专业版和旗舰版。 |
| `import_url`                                       | string  | 否       | 从中导入代码仓库的 URL。 |
| `initialize_with_readme`                           | boolean | 否       | 默认为 `false`。 |
| `issue_branch_template`                            | string  | 否       | 用于建议[从议题创建的分支](../user/project/merge_requests/creating_merge_requests.md#from-an-issue)名称的模板。 |
| `issues_enabled`                                   | boolean | 否       | _（已弃用）_ 为此项目启用议题。请改用 `issues_access_level`。 |
| `jobs_enabled`                                     | boolean | 否       | _（已弃用）_ 为此项目启用作业。请改用 `builds_access_level`。 |
| `lfs_enabled`                                      | boolean | 否       | 启用 LFS。 |
| `merge_commit_template`                            | string  | 否       | 用于在合并请求中创建合并提交消息的[模板](../user/project/merge_requests/commit_templates.md)。 |
| `merge_method`                                     | string  | 否       | 设置项目的[合并方法](../user/project/merge_requests/methods/_index.md)。可以是 `merge`（合并提交）、`rebase_merge`（半线性历史的合并提交）或 `ff`（快进合并）。 |
| `merge_requests_enabled`                           | boolean | 否       | _（已弃用）_ 为此项目启用合并请求。请改用 `merge_requests_access_level`。 |
| `mr_default_title_template`                        | string  | 否       | 用于设置默认合并请求标题的[模板](../user/project/merge_requests/title_templates.md)。 |
| `mirror_trigger_builds`                            | boolean | 否       | 拉取镜像触发构建。仅限专业版和旗舰版。 |
| `mirror`                                           | boolean | 否       | 在项目中启用拉取镜像。仅限专业版和旗舰版。 |
| `namespace_id`                                     | integer | 否       | 新项目的命名空间（默认为当前用户的命名空间）。 |
| `only_allow_merge_if_all_discussions_are_resolved` | boolean | 否       | 设置合并请求是否只能在所有讨论都解决后才能合并。 |
| `only_allow_merge_if_all_status_checks_passed`     | boolean | 否       | 指示除非所有状态检查都已通过，否则应阻止合并请求的合并。默认为 false。仅限旗舰版。 |
| `only_allow_merge_if_pipeline_succeeds`            | boolean | 否       | 设置合并请求是否只能在作业成功时合并。 |
| `packages_enabled`                                 | boolean | 否       | 在极狐GitLab 17.10 中[已弃用](https://gitlab.com/gitlab-org/gitlab/-/issues/454759)。启用或禁用软件包仓库功能。请改用 `package_registry_access_level`。 |
| `package_registry_access_level`                    | string  | 否       | 启用或禁用软件包仓库功能。 |
| `path`                                             | string  | 否       | 新项目的自定义代码仓库名称。默认根据名称生成。 |
| `printing_merge_request_link_enabled`              | boolean | 否       | 从命令行推送时显示创建/查看合并请求的链接。 |
| `public_builds`                                    | boolean | 否       | _（已弃用）_ 如果为 `true`，则非项目成员可以查看作业。请改用 `public_jobs`。 |
| `public_jobs`                                      | boolean | 否       | 如果为 `true`，则非项目成员可以查看作业。 |
| `repository_object_format`                         | string  | 否       | 代码仓库对象格式。默认为 `sha1`。 |
| `remove_source_branch_after_merge`                 | boolean | 否       | 默认对所有新合并请求启用 `Delete source branch` 选项。 |
| `repository_storage`                               | string  | 否       | 代码仓库所在的存储分片。_（仅限管理员）_ |
| `request_access_enabled`                           | boolean | 否       | 允许用户请求成员访问权限。 |
| `resolve_outdated_diff_discussions`                | boolean | 否       | 在推送更改的行上自动解决合并请求差异讨论。 |
| `shared_runners_enabled`                           | boolean | 否       | 为此项目启用实例 Runner。 |
| `show_default_award_emojis`                        | boolean | 否       | 显示默认的表情符号反应。 |
| `snippets_enabled`                                 | boolean | 否       | _（已弃用）_ 为此项目启用代码片段。请改用 `snippets_access_level`。 |
| `squash_commit_template`                           | string  | 否       | 用于在合并请求中创建 squash 提交消息的[模板](../user/project/merge_requests/commit_templates.md)。 |
| `squash_option`                                    | string  | 否       | 可以是 `never`、`always`、`default_on` 或 `default_off` 之一。 |
| `suggestion_commit_message`                        | string  | 否       | 用于应用合并请求[建议](../user/project/merge_requests/reviews/suggestions.md)的提交消息。 |
| `tag_list`                                         | array   | 否       | _（在极狐GitLab 14.0 中[已弃用](https://gitlab.com/gitlab-org/gitlab/-/issues/328226)）_ 项目的标签列表；放置最终应分配给项目的标签数组。请改用 `topics`。 |
| `template_name`                                    | string  | 否       | 当不与 `use_custom_template` 一起使用时，为[内置项目模板](../user/project/_index.md#create-a-project-from-a-built-in-template)的名称。当与 `use_custom_template` 一起使用时，为自定义项目模板的名称。 |
| `topics`                                           | array   | 否       | 项目的主题列表。 |
| `use_custom_template`                              | boolean | 否       | 使用自定义[实例](../administration/project_templates.md)或[群组](../user/group/custom_project_templates.md)（使用 `group_with_project_templates_id`）项目模板。仅限专业版和旗舰版。 |
| `visibility`                                       | string  | 否       | 请参阅[项目可见性级别](#project-visibility-level)。 |
| `warn_about_potentially_unwanted_characters`       | boolean | 否       | 启用关于在此项目中使用可能不需要的字符的警告。 |
| `wiki_enabled`                                     | boolean | 否       | _（已弃用）_ 为此项目启用 Wiki。请改用 `wiki_access_level`。 |

要设置单个项目功能的可见性级别，
请参阅[项目功能可见性级别](#project-feature-visibility-level)。

<a id="update-a-project"></a>

### 更新项目

更新现有项目。

如果您的 HTTP 代码仓库不公开可访问，请在 URL 中添加认证信息
`https://username:password@gitlab.company.com/group/project.git`，
其中 `password` 是启用了 `api` 范围的公共访问密钥。

```plaintext
PUT /projects/:id
```

支持的一般项目属性：

| 属性                                          | 类型              | 必填 | 描述 |
|:---------------------------------------------------|:------------------|:---------|:------------|
| `id`                                               | integer or string | 是      | 项目的 ID 或 [URL 编码路径](rest/_index.md#namespaced-paths)。 |
| `allow_merge_on_skipped_pipeline`                  | boolean           | 否       | 设置合并请求是否可以在有跳过作业的情况下合并。 |
| `allow_pipeline_trigger_approve_deployment`        | boolean           | 否       | 设置是否允许流水线触发器批准部署。仅限专业版和旗舰版。 |
| `only_allow_merge_if_all_status_checks_passed`     | boolean           | 否       | 指示除非所有状态检查都已通过，否则应阻止合并请求的合并。默认为 false。仅限旗舰版。 |
| `approvals_before_merge`                           | integer           | 否       | 默认情况下需要多少审批人批准合并请求。在极狐GitLab 16.0 中[已弃用](https://gitlab.com/gitlab-org/gitlab/-/issues/353097)。要配置审批规则，请参阅[合并请求审批 API](merge_request_approvals.md)。仅限专业版和旗舰版。 |
| `auto_cancel_pending_pipelines`                    | string            | 否       | 自动取消待处理的流水线。此操作在启用状态和禁用状态之间切换；它不是布尔值。 |
| `auto_devops_deploy_strategy`                      | string            | 否       | 自动部署策略（`continuous`、`manual` 或 `timed_incremental`）。 |
| `auto_devops_enabled`                              | boolean           | 否       | 为此项目启用 Auto DevOps。 |
| `auto_duo_code_review_enabled`                     | boolean           | 否       | 启用极狐GitLab Duo 对合并请求的自动评审。请参阅[合并请求中的极狐GitLab Duo](../user/project/merge_requests/duo_in_merge_requests.md#use-gitlab-duo-to-review-your-code)。仅限旗舰版。 |
| `autoclose_referenced_issues`                      | boolean           | 否       | 设置是否在默认分支上自动关闭引用的议题。 |
| `automatic_rebase_enabled`                         | boolean           | 否       | 在合并前启用源分支的自动变基。适用于合并方法为快进合并或半线性历史的合并提交时。 |
| `avatar`                                           | mixed             | 否       | 项目头像的图像文件。 |
| `build_git_strategy`                               | string            | 否       | Git 策略。默认为 `fetch`。 |
| `build_timeout`                                    | integer           | 否       | 作业可以运行的最长时间（以秒为单位）。 |
| `ci_config_path`                                   | string            | 否       | CI 配置文件的路径。 |
| `ci_default_git_depth`                             | integer           | 否       | [浅克隆](../ci/pipelines/settings.md#limit-the-number-of-changes-fetched-during-clone)的默认修订数。 |
| `ci_delete_pipelines_in_seconds`                   | integer           | 否       | 超过配置时间的流水线将被删除。 |
| `ci_display_pipeline_variables`                    | boolean           | 否       | 手动运行流水线后，在流水线详情页显示所有手动定义的变量。 |
| `ci_forward_deployment_enabled`                    | boolean           | 否       | 启用或禁用[防止过时的部署作业](../ci/pipelines/settings.md#prevent-outdated-deployment-jobs)。 |
| `ci_forward_deployment_rollback_allowed`           | boolean           | 否       | 启用或禁用[允许回滚部署的作业重试](../ci/pipelines/settings.md#prevent-outdated-deployment-jobs)。 |
| `ci_allow_fork_pipelines_to_run_in_parent_project` | boolean           | 否       | 启用或禁用[在父项目中为来自 fork 的合并请求运行流水线](../ci/pipelines/merge_request_pipelines.md#run-pipelines-in-the-parent-project)。 |
| `ci_id_token_sub_claim_components`                 | array             | 否       | [ID Token](../ci/secrets/id_token_authentication.md) 的 `sub` 声明中包含的字段。接受以 `project_path` 或 `project_id` 开头的数组。该数组还可能包含 `ref_type`、`ref`、`ref_protected`、`environment_protected` 和 `deployment_tier`。默认为 `["project_path", "ref_type", "ref"]`。在极狐GitLab 17.10 中[引入](https://gitlab.com/gitlab-org/gitlab/-/issues/477260)。对 `environment_protected` 和 `deployment_tier` 的支持在极狐GitLab 18.7 中引入。对 `project_id` 作为第一个组件的支持在极狐GitLab 19.1 中[引入](https://gitlab.com/gitlab-org/gitlab/-/issues/600358)。 |
| `ci_separated_caches`                              | boolean           | 否       | 设置缓存是否应按分支保护状态[分离](../ci/caching/_index.md#cache-key-names)。 |
| `ci_restrict_pipeline_cancellation_role`           | string            | 否       | 设置[取消流水线或作业所需的角色](../ci/pipelines/settings.md#restrict-roles-that-can-cancel-pipelines-or-jobs)。可以是 `developer`、`maintainer` 或 `no_one` 之一。仅限专业版和旗舰版。 |
| `ci_pipeline_variables_minimum_override_role`      | string            | 否       | 您可以指定哪个角色可以覆盖变量。可以是 `owner`、`maintainer`、`developer` 或 `no_one_allowed` 之一。在极狐GitLab 17.1 中[引入](https://gitlab.com/gitlab-org/gitlab/-/issues/440338)。在极狐GitLab 17.1 到 17.7 中，必须启用 `restrict_user_defined_variables`。 |
| `ci_push_repository_for_job_token_allowed`         | boolean           | 否       | 启用或禁用使用作业令牌推送到项目代码仓库的能力。在极狐GitLab 17.2 中[引入](https://gitlab.com/gitlab-org/gitlab/-/issues/389060)。 |
| `cicd_catalog_enabled`                             | boolean           | 否       | 设置项目是否发布到 [CI/CD Catalog](../ci/components/_index.md#cicd-catalog)。需要项目的所有者角色。在极狐GitLab 19.3 中[引入](https://gitlab.com/gitlab-org/gitlab/-/issues/463043)。 |
| `container_expiration_policy_attributes`           | hash              | 否       | 更新此项目的镜像清理策略。接受：`cadence`（string）、`keep_n`（integer）、`older_than`（string）、`name_regex`（string）、`name_regex_delete`（string）、`name_regex_keep`（string）、`enabled`（boolean）。 |
| `container_registry_enabled`                       | boolean           | 否       | _（已弃用）_ 为此项目启用容器镜像仓库。请改用 `container_registry_access_level`。 |
| `default_branch`                                   | string            | 否       | [默认分支](../user/project/repository/branches/default.md)名称。 |
| `description`                                      | string            | 否       | 简短的项目描述。 |
| `duo_remote_flows_enabled`                         | boolean           | 否       | 确定[任务流](../user/duo_agent_platform/flows/_index.md)是否可以在您的项目中运行。 |
| `duo_sast_fp_detection_enabled` | boolean | 否 | 如果为 `true`，则开启 SAST 误报检测。需要安全管理员、维护者或所有者角色。请参阅[开启 SAST 误报检测](../user/application_security/vulnerabilities/false_positive_detection.md#turn-on-for-a-project)。 |
| `duo_secret_detection_fp_enabled` | boolean | 否 | 如果为 `true`，则开启密钥检测误报检测。需要安全管理员、维护者或所有者角色。请参阅[开启密钥检测误报检测](../user/application_security/vulnerabilities/secret_false_positive_detection.md#turn-on-for-a-project)。 |
| `duo_sast_vr_workflow_enabled` | boolean | 否 | 如果为 `true`，则开启 SAST 漏洞解决任务流。需要安全管理员、维护者或所有者角色。请参阅[开启 SAST 漏洞解决任务流](../user/duo_agent_platform/flows/foundational_flows/_index.md#turn-foundational-flows-on-or-off)。 |
| `emails_disabled`                                  | boolean           | 否       | _（已弃用）_ 禁用电子邮件通知。请改用 `emails_enabled` |
| `emails_enabled`                                   | boolean           | 否       | 启用电子邮件通知。 |
| `enforce_auth_checks_on_uploads`                   | boolean           | 否       | 对上传强制执行[认证检查](../security/user_file_uploads.md#enable-authorization-checks-for-all-media-files)。 |
| `external_authorization_classification_label`      | string            | 否       | 项目的分类标记。仅限专业版和旗舰版。 |
| `feature_flags_minimum_role`                       | string            | 否       | 创建、更新、切换和删除[功能标志](../operations/feature_flags.md#restrict-who-can-manage-feature-flags)所需的最低角色。可以是 `no_one_allowed`、`developer`、`maintainer` 或 `owner` 之一。默认为 `developer`。需要所有者角色才能将此设置从 `owner` 或 `no_one_allowed` 更改。 |
| `group_runners_enabled`                            | boolean           | 否       | 为此项目启用群组 Runner。 |
| `import_url`                                       | string            | 否       | 导入代码仓库的 URL。 |
| `issues_enabled`                                   | boolean           | 否       | _（已弃用）_ 为此项目启用议题。请改用 `issues_access_level`。 |
| `issues_template` | string | 否 | 新议题的默认描述。格式为极狐GitLab 风格 Markdown。仅限专业版和旗舰版。 |
| `merge_requests_template` | string | 否 | 新合并请求的默认描述。格式为极狐GitLab 风格 Markdown。仅限专业版和旗舰版。 |
| `jobs_enabled`                                     | boolean           | 否       | _（已弃用）_ 为此项目启用作业。请改用 `builds_access_level`。 |
| `keep_latest_artifact`                             | boolean           | 否       | 禁用或启用为此项目保留最新产物的能力。 |
| `lfs_enabled`                                      | boolean           | 否       | 启用 LFS。 |
| `max_artifacts_size`                               | integer           | 否       | 单个作业产物的最大文件大小（以兆字节为单位）。 |
| `merge_commit_template`                            | string            | 否       | 用于在合并请求中创建合并提交消息的[模板](../user/project/merge_requests/commit_templates.md)。 |
| `merge_method`                                     | string            | 否       | 设置项目的[合并方法](../user/project/merge_requests/methods/_index.md)。可以是 `merge`（合并提交）、`rebase_merge`（半线性历史的合并提交）或 `ff`（快进合并）。 |
| `merge_pipelines_enabled`                          | boolean           | 否       | 启用或禁用合并结果流水线。 |
| `merge_requests_enabled`                           | boolean           | 否       | _（已弃用）_ 为此项目启用合并请求。请改用 `merge_requests_access_level`。 |
| `mr_default_title_template`                        | string            | 否       | 用于设置默认合并请求标题的[模板](../user/project/merge_requests/title_templates.md)。 |
| `merge_trains_enabled`                             | boolean           | 否       | 启用或禁用合并列车。 |
| `merge_trains_skip_train_allowed`                  | boolean           | 否       | 允许合并列车合并请求无需等待流水线完成即可合并。 |
| `merge_train_enforcement`                          | string            | 否       | 合并列车强制级别。可以是 `allow_bypass`、`enforce_for_all_users` 或 `enforce_with_owner_override` 之一。除非为项目启用了合并列车，否则无效。 |
| `max_pipelines_per_merge_train`                    | integer           | 否       | 每个合并列车的最大并行流水线数。 |
| `mirror_overwrites_diverged_branches`              | boolean           | 否       | 拉取镜像覆盖分叉的分支。仅限专业版和旗舰版。 |
| `mirror_trigger_builds`                            | boolean           | 否       | 拉取镜像触发构建。仅限专业版和旗舰版。 |
| `mirror_user_id`                                   | integer           | 否       | 负责拉取镜像事件所有活动的用户。_（仅限管理员）_ 仅限专业版和旗舰版。 |
| `mirror`                                           | boolean           | 否       | 在项目中启用拉取镜像。仅限专业版和旗舰版。 |
| `mr_default_target_self`                           | boolean           | 否       | 对于 fork 项目，将合并请求目标设为此项目。如果为 `false`，则目标为上游项目。 |
| `name`                                             | string            | 否       | 项目的名称。 |
| `only_allow_merge_if_all_discussions_are_resolved` | boolean           | 否       | 设置合并请求是否只能在所有讨论都解决后才能合并。 |
| `only_allow_merge_if_pipeline_succeeds`            | boolean           | 否       | 设置合并请求是否只能在作业成功时合并。 |
| `only_mirror_protected_branches`                   | boolean           | 否       | 仅镜像受保护的分支。仅限专业版和旗舰版。 |
| `packages_enabled`                                 | boolean           | 否       | 在极狐GitLab 17.10 中[已弃用](https://gitlab.com/gitlab-org/gitlab/-/issues/454759)。启用或禁用软件包仓库功能。请改用 `package_registry_access_level`。 |
| `package_registry_access_level`                    | string  | 否                 | 启用或禁用软件包仓库功能。 |
| `path`                                             | string            | 否       | 项目的自定义代码仓库名称。默认根据名称生成。 |
| `prevent_merge_without_jira_issue`                 | boolean           | 否       | 设置合并请求是否需要关联的 Jira 议题。仅限旗舰版。 |
| `printing_merge_request_link_enabled`              | boolean           | 否       | 从命令行推送时显示创建/查看合并请求的链接。 |
| `protect_merge_request_pipelines`                  | boolean           | 否       | 启用或禁用[控制对受保护变量和 Runner 的访问](../ci/pipelines/merge_request_pipelines.md#control-access-to-protected-variables-and-runners)。 |
| `public_builds`                                    | boolean           | 否       | _（已弃用）_ 如果为 `true`，则非项目成员可以查看作业。请改用 `public_jobs`。 |
| `public_jobs`                                      | boolean           | 否       | 如果为 `true`，则非项目成员可以查看作业。 |
| `remove_source_branch_after_merge`                 | boolean           | 否       | 默认对所有新合并请求启用 `Delete source branch` 选项。 |
| `repository_storage`                               | string            | 否       | 代码仓库所在的存储分片。_（仅限管理员）_ |
| `request_access_enabled`                           | boolean           | 否       | 允许用户请求成员访问权限。 |
| `resolve_outdated_diff_discussions`                | boolean           | 否       | 在推送更改的行上自动解决合并请求差异讨论。 |
| `restrict_user_defined_variables`                  | boolean           | 否       | _（在极狐GitLab 17.7 中[已弃用](https://gitlab.com/gitlab-org/gitlab/-/merge_requests/154510)，改用 `ci_pipeline_variables_minimum_override_role`）_ 仅允许具有维护者角色的用户在触发流水线时传递用户定义的变量。例如，在 UI 中、通过 API 或通过触发令牌触发流水线时。 |
| `reviewer_assignment_strategy`                     | string            | 否       | 用于自动将审核人分配给合并请求的策略。可以是 `disabled` 或 `code_owners` 之一。对于在极狐GitLab 19.4 之前配置的项目，此属性也可以返回 `dap_powered`。仅限专业版和旗舰版。 |
| `service_desk_enabled`                             | boolean           | 否       | 启用或禁用服务台功能。 |
| `shared_runners_enabled`                           | boolean           | 否       | 为此项目启用实例 Runner。 |
| `show_default_award_emojis`                        | boolean           | 否       | 显示默认的表情符号反应。 |
| `snippets_enabled`                                 | boolean           | 否       | _（已弃用）_ 为此项目启用代码片段。请改用 `snippets_access_level`。 |
| `issue_branch_template`                            | string            | 否       | 用于建议[从议题创建的分支](../user/project/merge_requests/creating_merge_requests.md#from-an-issue)名称的模板。 |
| `spp_repository_pipeline_access`                   | boolean           | 否       | 允许用户和令牌对此项目具有只读访问权限，以获取安全策略配置。对于在使用此项目作为其安全策略来源的项目中强制执行安全策略是必需的。仅限旗舰版。 |
| `squash_commit_template`                           | string            | 否       | 用于在合并请求中创建 squash 提交消息的[模板](../user/project/merge_requests/commit_templates.md)。 |
| `squash_option`                                    | string            | 否       | 可以是 `never`、`always`、`default_on` 或 `default_off` 之一。 |
| `suggestion_commit_message`                        | string            | 否       | 用于应用合并请求建议的提交消息。 |
| `tag_list`                                         | array             | 否       | _（在极狐GitLab 14.0 中[已弃用](https://gitlab.com/gitlab-org/gitlab/-/issues/328226)）_ 项目的标签列表；放置最终应分配给项目的标签数组。请改用 `topics`。 |
| `topics`                                           | array             | 否       | 项目的主题列表。这会替换已添加到项目中的任何现有主题。 |
| `visibility`                                       | string            | 否       | 请参阅[项目可见性级别](#project-visibility-level)。 |
| `warn_about_potentially_unwanted_characters`       | boolean           | 否       | 启用关于在此项目中使用可能不需要的字符的警告。 |
| `wiki_enabled`                                     | boolean           | 否       | _（已弃用）_ 为此项目启用 Wiki。请改用 `wiki_access_level`。 |
| `web_based_commit_signing_enabled`                 | boolean           | 否       | 为从极狐GitLab UI 创建的提交启用基于 Web 的提交签名。仅在 JihuLab.com 上可用。 |

例如，要切换 [JihuLab.com 项目上的实例 Runner](../ci/runners/_index.md) 设置：

```shell
curl --request PUT --header "PRIVATE-TOKEN: <your-token>" \
     --url "https://gitlab.com/api/v4/projects/<your-project-ID>" \
     --data "shared_runners_enabled=true" # to turn off: "shared_runners_enabled=false"
```

要设置单个项目功能的可见性级别，
请参阅[项目功能可见性级别](#project-feature-visibility-level)。

<a id="turn-off-service-desk-for-multiple-projects"></a>

#### 为多个项目关闭服务台

极狐GitLab 为每个项目存储服务台设置。新项目默认启用服务台。要关闭命名空间中多个项目的服务台，请使用[更新项目](#update-a-project)端点更新每个项目。

先决条件：

- 您必须对要更改的每个项目具有维护者或所有者角色。

要为项目关闭服务台，请将 `service_desk_enabled` 属性设置为 `false`：

```shell
curl --request PUT --header "PRIVATE-TOKEN: <your_access_token>" \
  --data "service_desk_enabled=false" \
  --url "https://gitlab.example.com/api/v4/projects/<project_id>"
```

要查找命名空间中的项目，请使用
[列出群组项目](groups.md#list-projects)端点并设置 `include_subgroups=true`，
或使用[列出用户项目](#list-all-personal-projects-for-a-user)端点获取
个人命名空间。然后为要更改的每个项目运行之前的请求。

API 返回的 `service_desk_enabled` 字段是计算值。仅当项目设置开启且实例配置了接收邮件时，它才为 `true`。
如果未配置接收邮件，即使项目设置开启，该字段也会显示为 `false`。

<a id="import-members"></a>

### 导入成员

从另一个项目导入成员。

如果导入成员对目标项目的角色是：

- 维护者，则源项目中具有所有者角色的成员将以维护者角色导入。
- 所有者，则源项目中具有所有者角色的成员将以所有者角色导入。

```plaintext
POST /projects/:id/import_project_members/:project_id
```

支持的属性：

| 属性    | 类型              | 必填 | 描述 |
|:-------------|:------------------|:---------|:------------|
| `id`         | integer or string | 是      | 接收成员的目标项目的 ID 或 [URL 编码路径](rest/_index.md#namespaced-paths)。 |
| `project_id` | integer or string | 是      | 从中导入成员的源项目的 ID 或 [URL 编码路径](rest/_index.md#namespaced-paths)。 |

示例请求：

```shell
curl --request POST \
  --header "PRIVATE-TOKEN: <your_access_token>" \
  --url "https://gitlab.example.com/api/v4/projects/5/import_project_members/32"
```

返回：

- 成功时返回 `200 OK`。
- 如果目标或源项目不存在或请求者无法访问，则返回 `404 Project Not Found`。
- 如果项目成员导入未成功完成，则返回 `422 Unprocessable Entity`。

示例响应：

- 当所有电子邮件都成功发送时（`200` HTTP 状态码）：

  ```json
  {  "status":  "success"  }
  ```

- 当导入 1 个或多个成员时出现任何错误时（`200` HTTP 状态码）：

  ```json
  {
    "status": "error",
    "message": {
                 "john_smith": "Some individual error message",
                 "jane_smith": "Some individual error message"
               },
    "total_members_count": 3
  }
  ```

- 当出现系统错误时（`404` 和 `422` HTTP 状态码）：

```json
{  "message":  "Import failed"  }
```

<a id="archive-a-project"></a>

### 归档项目

归档指定项目。

先决条件：

- 您必须是管理员或被分配项目的所有者角色。

此端点是幂等的。归档已归档的项目不会更改该项目。

```plaintext
POST /projects/:id/archive
```

支持的属性：

| 属性 | 类型              | 必填 | 描述 |
|:----------|:------------------|:---------|:------------|
| `id`      | integer or string | 是      | 项目的 ID 或 [URL 编码路径](rest/_index.md#namespaced-paths)。 |

示例请求：

```shell
curl --request POST \
  --header "PRIVATE-TOKEN: <your_access_token>" \
  --url "https://gitlab.example.com/api/v4/projects/5/archive"
```

示例响应：

```json
{
  "id": 3,
  "description": "Lorem ipsum dolor sit amet, consectetur adipiscing elit.",
  "description_html": "<p data-sourcepos=\"1:1-1:56\" dir=\"auto\">Lorem ipsum dolor sit amet, consectetur adipiscing elit.</p>",
  "default_branch": "main",
  "visibility": "private",
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
  "owner": {
    "id": 3,
    "name": "Diaspora",
    "created_at": "2013-09-30T13:46:02Z"
  },
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
  "import_error": null,
  "permissions": {
    "project_access": {
      "access_level": 10,
      "notification_level": 3
    },
    "group_access": {
      "access_level": 50,
      "notification_level": 3
    }
  },
  "archived": true,
  "avatar_url": "http://example.com/uploads/project/avatar/3/uploads/avatar.png",
  "license_url": "http://example.com/diaspora/diaspora-client/blob/main/LICENSE",
  "license": {
    "key": "lgpl-3.0",
    "name": "GNU Lesser General Public License v3.0",
    "nickname": "GNU LGPLv3",
    "html_url": "http://choosealicense.com/licenses/lgpl-3.0/",
    "source_url": "http://www.gnu.org/licenses/lgpl-3.0.txt"
  },
  "shared_runners_enabled": true,
  "group_runners_enabled": true,
  "forks_count": 0,
  "star_count": 0,
  "runners_token": "b8bc4a7a29eb76ea83cf79e4908c2b",
  "ci_default_git_depth": 50,
  "ci_forward_deployment_enabled": true,
  "ci_forward_deployment_rollback_allowed": true,
  "ci_allow_fork_pipelines_to_run_in_parent_project": true,
  "ci_id_token_sub_claim_components": ["project_path", "ref_type", "ref"],
  "ci_separated_caches": true,
  "ci_restrict_pipeline_cancellation_role": "developer",
  "ci_pipeline_variables_minimum_override_role": "maintainer",
  "ci_push_repository_for_job_token_allowed": false,
  "ci_display_pipeline_variables": false,
  "cicd_catalog_enabled": false,
  "protect_merge_request_pipelines": true,
  "public_jobs": true,
  "shared_with_groups": [],
  "only_allow_merge_if_pipeline_succeeds": false,
  "allow_merge_on_skipped_pipeline": false,
  "allow_pipeline_trigger_approve_deployment": false,
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
  "mr_default_title_template": null,
  "secret_push_protection_enabled": false,
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
```

<a id="unarchive-a-project"></a>

### 取消归档项目

取消归档指定项目。

先决条件：

- 您必须是管理员或被分配项目的所有者角色。

此端点是幂等的。取消归档未归档的项目不会更改该项目。

```plaintext
POST /projects/:id/unarchive
```

支持的属性：

| 属性 | 类型              | 必填 | 描述 |
|:----------|:------------------|:---------|:------------|
| `id`      | integer or string | 是      | 项目的 ID 或 [URL 编码路径](rest/_index.md#namespaced-paths)。 |

示例请求：

```shell
curl --request POST \
  --header "PRIVATE-TOKEN: <your_access_token>" \
  --url "https://gitlab.example.com/api/v4/projects/5/unarchive"
```

示例响应：

```json
{
  "id": 3,
  "description": "Lorem ipsum dolor sit amet, consectetur adipiscing elit.",
  "description_html": "<p data-sourcepos=\"1:1-1:56\" dir=\"auto\">Lorem ipsum dolor sit amet, consectetur adipiscing elit.</p>",
  "default_branch": "main",
  "visibility": "private",
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
  "owner": {
    "id": 3,
    "name": "Diaspora",
    "created_at": "2013-09-30T13:46:02Z"
  },
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
  "import_error": null,
  "permissions": {
    "project_access": {
      "access_level": 10,
      "notification_level": 3
    },
    "group_access": {
      "access_level": 50,
      "notification_level": 3
    }
  },
  "archived": false,
  "avatar_url": "http://example.com/uploads/project/avatar/3/uploads/avatar.png",
  "license_url": "http://example.com/diaspora/diaspora-client/blob/main/LICENSE",
  "license": {
    "key": "lgpl-3.0",
    "name": "GNU Lesser General Public License v3.0",
    "nickname": "GNU LGPLv3",
    "html_url": "http://choosealicense.com/licenses/lgpl-3.0/",
    "source_url": "http://www.gnu.org/licenses/lgpl-3.0.txt"
  },
  "shared_runners_enabled": true,
  "group_runners_enabled": true,
  "forks_count": 0,
  "star_count": 0,
  "runners_token": "b8bc4a7a29eb76ea83cf79e4908c2b",
  "ci_default_git_depth": 50,
  "ci_forward_deployment_enabled": true,
  "ci_forward_deployment_rollback_allowed": true,
  "ci_allow_fork_pipelines_to_run_in_parent_project": true,
  "ci_id_token_sub_claim_components": ["project_path", "ref_type", "ref"],
  "ci_separated_caches": true,
  "ci_restrict_pipeline_cancellation_role": "developer",
  "ci_pipeline_variables_minimum_override_role": "maintainer",
  "ci_push_repository_for_job_token_allowed": false,
  "ci_display_pipeline_variables": false,
  "cicd_catalog_enabled": false,
  "protect_merge_request_pipelines": true,
  "public_jobs": true,
  "shared_with_groups": [],
  "only_allow_merge_if_pipeline_succeeds": false,
  "allow_merge_on_skipped_pipeline": false,
  "allow_pipeline_trigger_approve_deployment": false,
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
  "mr_default_title_template": null,
  "container_registry_image_prefix": "registry.example.com/diaspora/diaspora-project-site",
  "secret_push_protection_enabled": false,
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
```

<a id="delete-a-project"></a>

### 删除项目

先决条件：

- 您必须是管理员或具有项目的所有者角色。

将项目标记为待删除。项目将在保留期结束时被删除：

- 在 JihuLab.com 上，项目保留 30 天。
- 在极狐GitLab 私有化部署上，保留期由
  [实例设置](../administration/settings/visibility_and_access_controls.md#deletion-protection)控制。

此端点也可以立即删除之前标记为待删除的项目。

> [!warning]
> 在 JihuLab.com 上，项目删除后，其数据会保留 30 天，且无法永久删除。
> 如果您确实需要在 JihuLab.com 上立即删除项目，可以提交[支持工单](https://support.gitlab.com/)。

```plaintext
DELETE /projects/:id
```

支持的属性：

| 属性            | 类型              | 必填 | 描述 |
|:---------------------|:------------------|:---------|:------------|
| `id`                 | integer or string | 是      | 项目的 ID 或 [URL 编码路径](rest/_index.md#namespaced-paths)。 |
| `full_path`          | string            | 否       | 与 `permanently_remove` 一起使用的项目完整路径。在极狐GitLab 18.0 中移至基础版。要查找项目路径，请使用[获取单个项目](#retrieve-a-project)中的 `path_with_namespace`。 |
| `permanently_remove` | boolean/string    | 否       | 如果项目已标记为待删除，则立即删除该项目。在极狐GitLab 18.0 中移至基础版。在 JihuLab.com 和 Dedicated 上禁用。 |

<a id="restore-a-project-marked-for-deletion"></a>

### 恢复标记为待删除的项目

恢复指定标记为待删除的项目。

```plaintext
POST /projects/:id/restore
```

支持的属性：

| 属性 | 类型              | 必填 | 描述 |
|:----------|:------------------|:---------|:------------|
| `id`      | integer or string | 是      | 项目的 ID 或 [URL 编码路径](rest/_index.md#namespaced-paths)。 |

<a id="transfer-a-project-to-a-new-namespace"></a>

### 将项目转移到新的命名空间

将项目转移到新的命名空间。

有关转移项目先决条件的信息，请参阅
[将项目转移到另一个命名空间](../user/project/working_with_projects.md#transfer-a-project)。

```plaintext
PUT /projects/:id/transfer
```

支持的属性：

| 属性   | 类型              | 必填 | 描述 |
|:------------|:------------------|:---------|:------------|
| `id`        | integer or string | 是      | 项目的 ID 或 [URL 编码路径](rest/_index.md#namespaced-paths)。 |
| `namespace` | integer or string | 是      | 要将项目转移到的命名空间的 ID 或路径。 |

示例请求：

```shell
curl --request PUT \
  --header "PRIVATE-TOKEN: <your_access_token>" \
  --url "https://gitlab.example.com/api/v4/projects/5/transfer?namespace=14"
```

示例响应：

```json
  {
  "id": 7,
  "description": "Lorem ipsum dolor sit amet, consectetur adipiscing elit.",
  "description_html": "<p data-sourcepos=\"1:1-1:56\" dir=\"auto\">Lorem ipsum dolor sit amet, consectetur adipiscing elit.</p>",
  "name": "hello-world",
  "name_with_namespace": "cute-cats / hello-world",
  "path": "hello-world",
  "path_with_namespace": "cute-cats/hello-world",
  "created_at": "2020-10-15T16:25:22.415Z",
  "updated_at": "2020-10-15T16:25:22.415Z",
  "default_branch": "main",
  "tag_list": [], //deprecated, use `topics` instead
  "topics": [],
  "ssh_url_to_repo": "git@gitlab.example.com:cute-cats/hello-world.git",
  "http_url_to_repo": "https://gitlab.example.com/cute-cats/hello-world.git",
  "web_url": "https://gitlab.example.com/cute-cats/hello-world",
  "readme_url": "https://gitlab.example.com/cute-cats/hello-world/-/blob/main/README.md",
  "avatar_url": null,
  "forks_count": 0,
  "star_count": 0,
  "last_activity_at": "2020-10-15T16:25:22.415Z",
  "namespace": {
    "id": 18,
    "name": "cute-cats",
    "path": "cute-cats",
    "kind": "group",
    "full_path": "cute-cats",
    "parent_id": null,
    "avatar_url": null,
    "web_url": "https://gitlab.example.com/groups/cute-cats"
  },
  "container_registry_image_prefix": "registry.example.com/cute-cats/hello-world",
  "_links": {
    "self": "https://gitlab.example.com/api/v4/projects/7",
    "issues": "https://gitlab.example.com/api/v4/projects/7/issues",
    "merge_requests": "https://gitlab.example.com/api/v4/projects/7/merge_requests",
    "repo_branches": "https://gitlab.example.com/api/v4/projects/7/repository/branches",
    "labels": "https://gitlab.example.com/api/v4/projects/7/labels",
    "events": "https://gitlab.example.com/api/v4/projects/7/events",
    "members": "https://gitlab.example.com/api/v4/projects/7/members"
  },
  "packages_enabled": true, // deprecated, use package_registry_access_level instead
  "package_registry_access_level": "enabled",
  "empty_repo": false,
  "archived": false,
  "visibility": "private",
  "resolve_outdated_diff_discussions": false,
  "container_registry_enabled": true, // deprecated, use container_registry_access_level instead
  "container_registry_access_level": "enabled",
  "container_expiration_policy": {
    "cadence": "7d",
    "enabled": false,
    "keep_n": null,
    "older_than": null,
    "name_regex": null,
    "name_regex_keep": null,
    "next_run_at": "2020-10-22T16:25:22.746Z"
  },
  "issues_enabled": true,
  "merge_requests_enabled": true,
  "wiki_enabled": true,
  "jobs_enabled": true,
  "snippets_enabled": true,
  "service_desk_enabled": false,
  "service_desk_address": null,
  "can_create_merge_request_in": true,
  "issues_access_level": "enabled",
  "repository_access_level": "enabled",
  "merge_requests_access_level": "enabled",
  "forking_access_level": "enabled",
  "analytics_access_level": "enabled",
  "wiki_access_level": "enabled",
  "builds_access_level": "enabled",
  "snippets_access_level": "enabled",
  "pages_access_level": "enabled",
  "security_and_compliance_access_level": "enabled",
  "emails_disabled": null,
  "emails_enabled": null,
  "shared_runners_enabled": true,
  "group_runners_enabled": true,
  "lfs_enabled": true,
  "creator_id": 2,
  "import_status": "none",
  "open_issues_count": 0,
  "ci_default_git_depth": 50,
  "public_jobs": true,
  "build_timeout": 3600,
  "auto_cancel_pending_pipelines": "enabled",
  "ci_config_path": null,
  "shared_with_groups": [],
  "only_allow_merge_if_pipeline_succeeds": false,
  "allow_merge_on_skipped_pipeline": null,
  "allow_pipeline_trigger_approve_deployment": false,
  "restrict_user_defined_variables": false,
  "request_access_enabled": true,
  "only_allow_merge_if_all_discussions_are_resolved": false,
  "remove_source_branch_after_merge": true,
  "printing_merge_request_link_enabled": true,
  "merge_method": "merge",
  "squash_option": "default_on",
  "suggestion_commit_message": null,
  "merge_commit_template": null,
  "mr_default_title_template": null,
  "auto_devops_enabled": true,
  "auto_devops_deploy_strategy": "continuous",
  "autoclose_referenced_issues": true,
  "approvals_before_merge": 0, // Deprecated. Use merge request approvals API instead.
  "mirror": false,
  "compliance_frameworks": [],
  "warn_about_potentially_unwanted_characters": true,
  "secret_push_protection_enabled": false
}
```

<a id="list-groups-available-for-project-transfer"></a>

#### 列出可用于项目转移的群组

检索用户可以将项目转移到的群组列表。

```plaintext
GET /projects/:id/transfer_locations
```

支持的属性：

| 属性 | 类型              | 必填 | 描述 |
|:----------|:------------------|:---------|:------------|
| `id`      | integer or string | 是      | 项目的 ID 或 [URL 编码路径](rest/_index.md#namespaced-paths)。 |
| `search`  | string | 否       | 要搜索的群组名称。 |

示例请求：

```shell
curl --url "https://gitlab.example.com/api/v4/projects/1/transfer_locations"
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

<a id="upload-a-project-avatar"></a>

### 上传项目头像

为指定项目上传头像。

```plaintext
PUT /projects/:id
```

先决条件：

- 您必须具有该项目的维护者或所有者角色。
- 您的文件必须为 200 KB 或更小。理想图像尺寸为 192 x 192 像素。
- 图像必须是以下文件类型之一：
  - `.bmp`
  - `.gif`
  - `.ico`
  - `.jpeg`
  - `.png`
  - `.tiff`

支持的属性：

| 属性 | 类型              | 必填 | 描述 |
|:----------|:------------------|:---------|:------------|
| `avatar`  | string | 是      | 要上传的文件。 |
| `id`      | integer or string | 是      | 项目的 ID 或 [URL 编码路径](rest/_index.md#namespaced-paths)。 |

要从文件系统上传头像，请使用 `--form` 参数。这会使
cURL 使用 `Content-Type: multipart/form-data` 标头发布数据。
`avatar=` 参数必须指向文件系统上的图像文件，并且前面
加上 `@`。

示例请求：

```shell
curl --request PUT \
  --header "PRIVATE-TOKEN: <your_access_token>" \
  --url "https://gitlab.example.com/api/v4/projects/5" \
  --form "avatar=@dk.png"
```

示例响应：

```json
{
  "avatar_url": "https://gitlab.example.com/uploads/-/system/project/avatar/2/dk.png"
}
```

<a id="download-a-project-avatar"></a>

### 下载项目头像

下载项目头像。如果项目是公开可访问的，您可以在不进行身份验证的情况下访问此端点。

```plaintext
GET /projects/:id/avatar
```

支持的属性：

| 属性 | 类型              | 必填 | 描述 |
|:----------|:------------------|:---------|:------------|
| `id`      | integer or string | 是      | 项目的 ID 或 [URL 编码路径](rest/_index.md#namespaced-paths)。 |

示例请求：

```shell
curl --header "PRIVATE-TOKEN: <your_access_token>" \
  --url "https://gitlab.example.com/api/v4/projects/4/avatar"
```

<a id="remove-a-project-avatar"></a>

### 移除项目头像

要移除项目头像，请为 `avatar` 属性使用空值。

示例请求：

```shell
curl --request PUT --header "PRIVATE-TOKEN: <your_access_token>" \
     --data "avatar=" "https://gitlab.example.com/api/v4/projects/5"
```

<a id="share-projects"></a>

## 共享项目

与群组共享项目。

有关更多信息，请参阅 [邀请群组加入项目](../user/project/members/sharing_projects_groups.md#invite-a-group-to-a-project)。

<a id="share-a-project-with-a-group"></a>

### 与群组共享项目

与群组共享指定项目。

```plaintext
POST /projects/:id/share
```

支持的属性：

| 属性      | 类型              | 必填 | 描述 |
|:---------------|:------------------|:---------|:------------|
| `group_access` | integer | 是      | 授予群组的访问级别。可能的值：`5`（最小访问权限）、`10`（访客）、`15`（计划者）、`20`（报告者）、`25`（安全管理员）、`30`（开发者）、`40`（维护者）或 `50`（所有者）。 |
| `group_id`     | integer | 是      | 要共享的群组的 ID。 |
| `id`           | integer or string | 是      | 项目的 ID 或 [URL 编码路径](rest/_index.md#namespaced-paths)。 |
| `expires_at`   | string | 否       | ISO 8601 格式的共享过期日期。例如，`2016-09-26`。 |

<a id="delete-a-shared-project-link-in-a-group"></a>

### 删除群组中的共享项目链接

取消指定群组与项目的共享。成功时返回 `204` 且无内容。

```plaintext
DELETE /projects/:id/share/:group_id
```

支持的属性：

| 属性  | 类型              | 必填 | 描述 |
|:-----------|:------------------|:---------|:------------|
| `group_id` | integer | 是      | 群组的 ID。 |
| `id`       | integer or string | 是      | 项目的 ID 或 [URL 编码路径](rest/_index.md#namespaced-paths)。 |

示例请求：

```shell
curl --request DELETE \
  --header "PRIVATE-TOKEN: <your_access_token>" \
  --url "https://gitlab.example.com/api/v4/projects/5/share/17"
```

<a id="start-the-housekeeping-task-for-a-project"></a>

## 为项目启动维护任务

为项目启动[维护任务](../administration/housekeeping.md)。

```plaintext
POST /projects/:id/housekeeping
```

支持的属性：

| 属性 | 类型              | 必填 | 描述 |
|:----------|:------------------|:---------|:------------|
| `id`      | integer or string | 是      | 项目的 ID 或 [URL 编码路径](rest/_index.md#namespaced-paths)。 |
| `task`    | string | 否       | `prune` 以触发对不可达对象的手动清理，或 `eager` 以触发主动维护。 |

<a id="real-time-security-scan"></a>

## 实时安全扫描

{{< details >}}

- Tier: 旗舰版
- Offering: JihuLab.com
- Status: 实验

{{< /details >}}

实时返回单个文件的 SAST 扫描结果。

```plaintext
POST /projects/:id/security_scans/sast/scan
```

支持的属性：

| 属性 | 类型              | 必填 | 描述 |
|-----------|-------------------|----------|-------------|
| `id`      | integer or string | 是      | 项目的 ID 或 [URL 编码路径](rest/_index.md#namespaced-paths)。 |

示例请求：

```shell
curl --request POST --header "PRIVATE-TOKEN: <your_access_token>" \
 --header "Content-Type: application/json" \
 --data '{
  "file_path":"src/main.c",
  "content":"#include<string.h>\nint main(int argc, char **argv) {\n  char buff[128];\n  strcpy(buff, argv[1]);\n  return 0;\n}\n"
 }' \
 --url "https://gitlab.example.com/api/v4/projects/:id/security_scans/sast/scan"
```

示例响应：

```json
{
  "vulnerabilities": [
    {
      "name": "Insecure string processing function (strcpy)",
      "description": "The `strcpy` family of functions do not provide the ability to limit or check buffer\nsizes before copying to a destination buffer. This can lead to buffer overflows. Consider\nusing more secure alternatives such as `strncpy` and provide the correct limit to the\ndestination buffer and ensure the string is null terminated.\n\nFor more information please see: https://linux.die.net/man/3/strncpy\n\nIf developing for C Runtime Library (CRT), more secure versions of these functions should be\nused, see:\nhttps://learn.microsoft.com/en-us/cpp/c-runtime-library/reference/strncpy-s-strncpy-s-l-wcsncpy-s-wcsncpy-s-l-mbsncpy-s-mbsncpy-s-l?view=msvc-170\n",
      "severity": "High",
      "location": {
        "file": "src/main.c",
        "start_line": 5,
        "end_line": 5,
        "start_column": 3,
        "end_column": 23
      }
    }
  ]
}
```

<a id="download-snapshot-of-a-git-repository"></a>

## 下载 Git 代码仓库快照

此端点只能由管理员用户访问。

下载项目（或 Wiki，如果请求）Git 代码仓库的快照。此
快照始终为未压缩的 [tar](https://en.wikipedia.org/wiki/Tar_(computing))
格式。

如果代码仓库损坏到 `git clone` 无法工作的程度，
快照可能允许检索部分数据。

```plaintext
GET /projects/:id/snapshot
```

支持的属性：

| 属性 | 类型              | 必填 | 描述 |
|:----------|:------------------|:---------|:------------|
| `id`      | integer or string | 是      | 项目的 ID 或 [URL 编码路径](rest/_index.md#namespaced-paths)。 |
| `wiki`    | boolean | 否       | 是否下载 Wiki 代码仓库，而不是项目代码仓库。 |

<a id="retrieve-the-path-to-repository-storage"></a>

## 检索代码仓库存储的路径

检索指定项目的代码仓库存储路径。如果您使用的是 Gitaly 集群 (Praefect)，请参阅 [Praefect 生成的副本路径](../administration/gitaly/praefect/_index.md#praefect-generated-replica-paths)。

仅限管理员使用。

```plaintext
GET /projects/:id/storage
```

支持的属性：

| 属性 | 类型              | 必填 | 描述 |
|:----------|:------------------|:---------|:------------|
| `id`      | integer or string | 是      | 项目的 ID 或 [URL 编码路径](rest/_index.md#namespaced-paths)。 |

```json
[
  {
    "project_id": 1,
    "disk_path": "@hashed/6b/86/6b86b273ff34fce19d6b804eff5a3f5747ada4eaa22f1d49c01e52ddb7875b4b",
    "created_at": "2012-10-12T17:04:47Z",
    "repository_storage": "default"
  }
]
```

<a id="secret-push-protection-status"></a>

## 密钥推送保护状态

{{< details >}}

- Tier: 旗舰版

{{< /details >}}

如果您具有安全管理员、开发者、维护者或所有者角色，以下请求也可能返回 `secret_push_protection_enabled` 值。
其中一些请求对角色有更严格的要求。请参阅前面提到的端点以了解详情。
使用此信息来确定是否为项目启用了密钥推送保护。
要修改 `secret_push_protection_enabled` 值，请使用 [项目安全设置 API](project_security_settings.md)。

- `GET /projects`
- `GET /projects/:id`
- `GET /users/:user_id/projects`
- `GET /users/:user_id/contributed_projects`
- `PUT /projects/:project_id/transfer?namespace=:namespace_id`
- `PUT /projects/:id`
- `POST /projects`
- `POST /projects/user/:user_id`
- `POST /projects/:id/archive`
- `POST /projects/:id/unarchive`

示例响应：

```json
{
  "id": 1,
  "project_id": 3,
  "secret_push_protection_enabled": true,
  ...
}
```

<a id="troubleshooting"></a>

## 故障排查

<a id="unexpected-restrict_user_defined_variables-value-in-response"></a>

### 响应中出现意外的 `restrict_user_defined_variables` 值

如果您为 `restrict_user_defined_variables` 和 `ci_pipeline_variables_minimum_override_role` 设置了冲突的值，
响应值可能与您的预期不同，因为 `pipeline_variables_minimum_override_role`
设置具有更高优先级。

例如，如果您：

- 将 `restrict_user_defined_variables` 设置为 `true`，并将 `ci_pipeline_variables_minimum_override_role` 设置为 `developer`，
  响应将返回 `restrict_user_defined_variables: false`。将 `ci_pipeline_variables_minimum_override_role`
  设置为 `developer` 优先，变量不受限制。
- 将 `restrict_user_defined_variables` 设置为 `false`，并将 `ci_pipeline_variables_minimum_override_role` 设置为 `maintainer`，
  响应将返回 `restrict_user_defined_variables: true`，因为将 `ci_pipeline_variables_minimum_override_role`
  设置为 `maintainer` 优先，变量受到限制。
