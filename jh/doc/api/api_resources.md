---
stage: Developer Experience
group: API Platform
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
title: REST API 资源
description: "按上下文（项目、群组、独立资源和模板）组织的极狐GitLab REST API 资源及其端点路径。"
---

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: JihuLab.com，私有化部署

{{< /details >}}

极狐GitLab REST API 让您能够以编程方式控制极狐GitLab 资源。
您可以将它与现有工具集成，自动执行重复性任务，并提取数据以生成自定义报告。无需使用 Web 界面即可访问和操作项目、群组、议题和合并请求。

使用 REST API 可以：

- 自动创建项目和管理用户。
- 从外部系统触发 CI/CD 流水线。
- 提取议题和合并请求数据以生成自定义仪表板。
- 将极狐GitLab 与第三方应用程序集成。
- 跨多个代码仓库实施自定义工作流。

REST API 资源分为以下几类：

- [项目资源](#project-resources)
- [群组资源](#group-resources)
- [独立资源](#standalone-resources)
- [模板资源](#template-resources)

<a id="project-resources"></a>

## 项目资源

以下 API 资源可在项目上下文中使用：

| 资源                                                                       | 可用端点 |
|--------------------------------------------------------------------------------|---------------------|
| [访问请求](access_requests.md)                                          | `/projects/:id/access_requests`（也可用于群组） |
| [访问令牌](project_access_tokens.md)                                      | `/projects/:id/access_tokens`（也可用于群组） |
| [Agent](cluster_agents.md)                                                    | `/projects/:id/cluster_agents` |
| [告警管理告警](alert_management_alerts.md)                          | `/projects/:id/alert_management_alerts/:alert_iid/metric_images` |
| [证明](attestations.md)                                                | `/projects/:id/attestations/:subject_digest` |
| [分支](branches.md)                                                        | `/projects/:id/repository/branches/`, `/projects/:id/repository/merged_branches` |
| [提交](commits.md)                                                          | `/projects/:id/repository/commits`, `/projects/:id/statuses` |
| [容器镜像仓库](container_registry.md)                                    | `/projects/:id/registry/repositories` |
| [容器仓库保护规则](container_repository_protection_rules.md)  | `/projects/:id/registry/protection/repository/rules` |
| [容器镜像仓库保护标签规则](container_registry_protection_tag_rules.md) | `/projects/:id/registry/protection/tag/rules` |
| [自定义属性](custom_attributes.md)                                      | `/projects/:id/custom_attributes`（也可用于群组和用户） |
| [Composer 发行版](packages/composer.md)                                 | `/projects/:id/packages/composer`（也可用于群组） |
| [Conan v1 发行版](packages/conan_v1.md)                                       | `/projects/:id/packages/conan`（也可独立使用） |
| [Conan v2 发行版](packages/conan_v2.md)                                       | `/projects/:id/packages/conan`（也可独立使用） |
| [Debian 发行版](packages/debian_project_distributions.md)               | `/projects/:id/debian_distributions`（也可用于群组） |
| [Debian 软件包](packages/debian.md)                                          | `/projects/:id/packages/debian`（也可用于群组） |
| [依赖项](dependencies.md)                                                | `/projects/:id/dependencies` |
| [依赖防火墙](dependency_firewall.md)                                  | `/projects/:id/dependency_firewall` |
| [部署密钥](deploy_keys.md)                                                  | `/projects/:id/deploy_keys`（也可独立使用） |
| [部署令牌](deploy_tokens.md)                                              | `/projects/:id/deploy_tokens`（也可用于群组和独立使用） |
| [部署](deployments.md)                                                  | `/projects/:id/deployments` |
| [DevOps 研究与评估 (DORA) 指标](dora/metrics.md)               | `/projects/:id/dora/metrics`（也可用于群组） |
| [讨论](discussions.md)（讨论串评论）                              | `/projects/:id/issues/.../discussions`, `/projects/:id/snippets/.../discussions`, `/projects/:id/merge_requests/.../discussions`, `/projects/:id/commits/.../discussions`（也可用于群组） |
| [草稿评论](draft_notes.md)（评论）                                       | `/projects/:id/merge_requests/.../draft_notes` |
| [Emoji 回应](emoji_reactions.md)                                          | `/projects/:id/issues/.../award_emoji`, `/projects/:id/merge_requests/.../award_emoji`, `/projects/:id/snippets/.../award_emoji` |
| [环境](environments.md)                                                | `/projects/:id/environments` |
| [错误跟踪](error_tracking.md)                                            | `/projects/:id/error_tracking/settings` |
| [事件](events.md)                                                            | `/projects/:id/events`（也可用于用户和独立使用） |
| [外部状态检查](status_checks.md)                                     | `/projects/:id/external_status_checks` |
| [功能标志用户列表](feature_flag_user_lists.md)                          | `/projects/:id/feature_flags_user_lists` |
| [功能标志](feature_flags.md)                                              | `/projects/:id/feature_flags` |
| [冻结期](freeze_periods.md)                                            | `/projects/:id/freeze_periods` |
| [Go 代理](packages/go_proxy.md)                                               | `/projects/:id/packages/go` |
| [Google Cloud 集成](google_cloud_integration.md)                        | `/projects/:id/google_cloud/setup/` |
| [Helm 仓库](packages/helm.md)                                            | `/projects/:id/packages/helm_repository` |
| [集成](project_integrations.md)（原“服务”）                          | `/projects/:id/integrations` |
| [邀请](invitations.md)                                                  | `/projects/:id/invitations`（也可用于群组） |
| [议题看板](boards.md)                                                      | `/projects/:id/boards` |
| [议题链接](issue_links.md)                                                  | `/projects/:id/issues/.../links` |
| [议题统计](issues_statistics.md)                                      | `/projects/:id/issues_statistics`（也可用于群组和独立使用） |
| [议题](issues.md)                                                            | `/projects/:id/issues`（也可用于群组和独立使用） |
| [迭代](iterations.md)                                                    | `/projects/:id/iterations`（也可用于群组） |
| [项目 CI/CD 作业令牌作用域](project_job_token_scopes.md)                   | `/projects/:id/job_token_scope` |
| [作业](jobs.md)                                                                | `/projects/:id/jobs`, `/projects/:id/pipelines/.../jobs` |
| [作业产物](job_artifacts.md)                                             | `/projects/:id/jobs/:job_id/artifacts` |
| [标记](labels.md)                                                            | `/projects/:id/labels` |
| [Markdown 上传](project_markdown_uploads.md)                                | `/projects/:id/uploads` |
| [Maven 仓库](packages/maven.md)                                          | `/projects/:id/packages/maven`（也可用于群组和独立使用） |
| [成员](project_members.md)                                                  | `/projects/:id/members`（也可用于群组） |
| [合并请求审批设置](merge_request_approval_settings.md)          | `/projects/:id/merge_request_approval_setting`（也可用于群组） |
| [合并请求审批](merge_request_approvals.md)                          | `/projects/:id/approvals`, `/projects/:id/merge_requests/.../approvals` |
| [合并请求上下文提交](merge_request_context_commits.md)              | `/projects/:id/merge_requests/:merge_request_iid/context_commits` |
| [合并请求](merge_requests.md)                                            | `/projects/:id/merge_requests`（也可用于群组和独立使用） |
| [合并列车](merge_trains.md)                                                | `/projects/:id/merge_trains` |
| [元数据](metadata.md)                                                        | `/metadata` |
| [模型注册表](model_registry.md)                                            | `/projects/:id/packages/ml_models/` |
| [评论](notes.md)（评论）                                                   | `/projects/:id/issues/.../notes`, `/projects/:id/snippets/.../notes`, `/projects/:id/merge_requests/.../notes`（也可用于群组） |
| [通知设置](notification_settings.md)                              | `/projects/:id/notification_settings`（也可用于群组和独立使用） |
| [NPM 仓库](packages/npm.md)                                              | `/projects/:id/packages/npm` |
| [NuGet 软件包](packages/nuget.md)                                            | `/projects/:id/packages/nuget`（也可用于群组） |
| [软件包](packages.md)                                                        | `/projects/:id/packages` |
| [Pages 域名](pages_domains.md)                                              | `/projects/:id/pages/domains`（也可独立使用） |
| [Pages 设置](pages.md)                                                     | `/projects/:id/pages` |
| [流水线计划](pipeline_schedules.md)                                    | `/projects/:id/pipeline_schedules` |
| [流水线触发器](pipeline_triggers.md)                                      | `/projects/:id/triggers` |
| [流水线](pipelines.md)                                                      | `/projects/:id/pipelines` |
| [项目徽章](project_badges.md)                                            | `/projects/:id/badges` |
| [项目集群](project_clusters.md)                                        | `/projects/:id/clusters` |
| [项目复刻](project_forks.md)                                              | `/projects/:id/fork`, `/projects/:id/forks` |
| [项目导入/导出](project_import_export.md)                              | `/projects/:id/export`, `/projects/import`, `/projects/:id/import` |
| [项目里程碑](milestones.md)                                            | `/projects/:id/milestones` |
| [项目推送规则](project_push_rules.md)                                    | `/projects/:id/push_rule` |
| [项目关系导出](project_relations_export.md)                        | `/projects/:id/export_relations` |
| [项目安全设置](project_security_settings.md)                      | `/projects/:id/security_settings` |
| [项目代码片段](project_snippets.md)                                        | `/projects/:id/snippets` |
| [项目加星](project_starring.md)                                        | `/projects/:id/star`, `/projects/:id/unstar`, `/projects/:id/starrers` |
| [项目统计](project_statistics.md)                                    | `/projects/:id/statistics` |
| [项目模板](project_templates.md)                                      | `/projects/:id/templates` |
| [项目漏洞](project_vulnerabilities.md).                         | `/projects/:id/vulnerabilities` |
| [项目 Webhook](project_webhooks.md)                                        | `/projects/:id/hooks` |
| [项目 Wiki](wikis.md)                                                      | `/projects/:id/wikis` |
| [项目级安全文件](secure_files.md)                                  | `/projects/:project_id/secure_files` |
| [项目级变量](project_level_variables.md)                          | `/projects/:id/variables` |
| [项目](projects.md)                                                        | `/projects`         |
| [受保护分支](protected_branches.md)                                    | `/projects/:id/protected_branches` |
| [受保护容器镜像仓库](container_repository_protection_rules.md)       | `/projects/:id/registry/protection/rules` |
| [受保护环境](protected_environments.md)                            | `/projects/:id/protected_environments` |
| [受保护软件包](project_packages_protection_rules.md)                     | `/projects/:id/packages/protection/rules` |
| [受保护标签](protected_tags.md)                                            | `/projects/:id/protected_tags` |
| [拉取镜像](project_pull_mirroring.md)                                    | `/projects/:id/mirror/pull` |
| [PyPI 软件包](packages/pypi.md)                                              | `/projects/:id/packages/pypi`（也可用于群组） |
| [发布链接](releases/links.md)                                             | `/projects/:id/releases/.../assets/links` |
| [发布](releases/_index.md)                                                 | `/projects/:id/releases` |
| [远程镜像](remote_mirrors.md)                                            | `/projects/:id/remote_mirrors` |
| [代码仓库](repositories.md)                                                | `/projects/:id/repository` |
| [代码仓库文件](repository_files.md)                                        | `/projects/:id/repository/files` |
| [代码仓库子模块](repository_submodules.md)                              | `/projects/:id/repository/submodules` |
| [资源组](resource_groups.md)                                           | `/projects/:id/resource_groups` |
| [资源迭代事件](resource_iteration_events.md)                      | `/projects/:id/issues/.../resource_iteration_events` |
| [资源标记事件](resource_label_events.md)                              | `/projects/:id/issues/.../resource_label_events`, `/projects/:id/merge_requests/.../resource_label_events`（也可用于群组） |
| [资源里程碑事件](resource_milestone_events.md)                      | `/projects/:id/issues/.../resource_milestone_events`, `/projects/:id/merge_requests/.../resource_milestone_events` |
| [资源状态事件](resource_state_events.md)                              | `/projects/:id/issues/.../resource_state_events`, `/projects/:id/merge_requests/.../resource_state_events`（也可用于群组） |
| [资源权重事件](resource_weight_events.md)                            | `/projects/:id/issues/.../resource_weight_events` |
| [Ruby gem](packages/rubygems.md)                                              | `/projects/:id/packages/rubygems` |
| [Runner](runners.md)                                                          | `/projects/:id/runners`（也可独立使用） |
| [搜索](search.md)                                                            | `/projects/:id/search`（也可用于群组和独立使用） |
| [密钥管理器](secrets_manager.md)                                          | `/projects/:id/secrets_manager/access_token`（也可用于群组） |
| [服务账号](service_accounts.md)                                        | `/projects/:id/service_accounts`（也可用于群组和独立使用） |
| [标签](tags.md)                                                                | `/projects/:id/repository/tags` |
| [Terraform 模块](packages/terraform-modules.md)                             | `/projects/:id/packages/terraform/modules`（也可独立使用） |
| [验证 `.gitlab-ci.yml` 文件](lint.md)                                      | `/projects/:id/ci/lint` |
| [漏洞](vulnerabilities.md)                                          | `/vulnerabilities/:id` |
| [漏洞归档导出](vulnerability_archive_exports.md)               | `/security/projects/:id/vulnerability_archive_exports` |
| [漏洞导出](vulnerability_exports.md)                              | `/projects/:id/vulnerability_exports` |
| [漏洞发现](vulnerability_findings.md)                            | `/projects/:id/vulnerability_findings` |

<a id="group-resources"></a>

## 群组资源

以下 API 资源可在群组上下文中使用：

| 资源                                                       | 可用端点 |
|----------------------------------------------------------------|---------------------|
| [访问请求](access_requests.md)                          | `/groups/:id/access_requests/`（也可用于项目） |
| [访问令牌](group_access_tokens.md)                        | `/groups/:id/access_tokens`（也可用于项目） |
| [容器虚拟仓库](container_virtual_registries.md)  | `/groups/:id/-/virtual_registries/container/registries` |
| [自定义属性](custom_attributes.md)                      | `/groups/:id/custom_attributes`（也可用于项目和用户） |
| [Debian 发行版](packages/debian_group_distributions.md) | `/groups/:id/-/packages/debian`（也可用于项目） |
| [依赖代理](dependency_proxy.md)                        | `/groups/:id/dependency_proxy/cache` |
| [部署令牌](deploy_tokens.md)                              | `/groups/:id/deploy_tokens`（也可用于项目和独立使用） |
| [DevOps 研究与评估 (DORA) 指标](dora/metrics.md) | `/groups/:id/dora/metrics`（也可用于项目） |
| [讨论](discussions.md)（评论和讨论串）           | `/groups/:id/epics/.../discussions`（也可用于项目） |
| [史诗议题](epic_issues.md)                                  | `/groups/:id/epics/.../issues` |
| [史诗链接](epic_links.md)                                    | `/groups/:id/epics/.../epics` |
| [史诗](epics.md)                                              | `/groups/:id/epics` |
| [群组](groups.md)                                            | `/groups`, `/groups/.../subgroups` |
| [群组徽章](group_badges.md)                                | `/groups/:id/badges` |
| [群组企业用户](group_enterprise_users.md)            | `/groups/:id/enterprise_users` |
| [群组史诗看板](group_epic_boards.md)                      | `/groups/:id/epic_boards` |
| [群组导入和导出](group_import_export.md)              | `/groups/:id/export`, `/groups/import` |
| [群组集成](group_integrations.md)                    | `/groups/:id/integrations` |
| [群组议题看板](group_boards.md)                          | `/groups/:id/boards` |
| [群组迭代](group_iterations.md)                        | `/groups/:id/iterations`（也可用于项目） |
| [群组标记](group_labels.md)                                | `/groups/:id/labels` |
| [群组 Markdown 上传](group_markdown_uploads.md)            | `/groups/:id/uploads` |
| [群组级受保护分支](group_protected_branches.md)  | `/groups/:id/protected_branches` |
| [群组级受保护环境](group_protected_environments.md) | `/groups/:id/protected_environments` |
| [群组级变量](group_level_variables.md)              | `/groups/:id/variables` |
| [群组里程碑](group_milestones.md)                        | `/groups/:id/milestones` |
| [群组占位符重新分配](group_placeholder_reassignments.md) | `/groups/:id/placeholder_reassignments` |
| [群组推送规则](group_push_rules.md)                        | `/groups/:id/push_rule` |
| [群组关系导出](group_relations_export.md)            | `/groups/:id/export_relations` |
| [群组发布](group_releases.md)                            | `/groups/:id/releases` |
| [群组安全设置](group_security_settings.md)          | `/groups/:id/security_settings` |
| [群组 SSH 证书](group_ssh_certificates.md)            | `/groups/:id/ssh_certificates` |
| [群组 Webhook](group_webhooks.md)                            | `/groups/:id/hooks` |
| [群组 Wiki](group_wikis.md)                                  | `/groups/:id/wikis` |
| [邀请](invitations.md)                                  | `/groups/:id/invitations`（也可用于项目） |
| [议题](issues.md)                                            | `/groups/:id/issues`（也可用于项目和独立使用） |
| [议题统计](issues_statistics.md)                      | `/groups/:id/issues_statistics`（也可用于项目和独立使用） |
| [LDAP 群组链接](group_ldap_links.md)                        | `/groups/:id/ldap_group_links` |
| [链接的史诗](linked_epics.md)                                | `/groups/:id/epics/.../related_epics` |
| [Maven虚拟仓库](maven_virtual_registries.md)          | `/groups/:id/-/virtual_registries/packages/maven/registries` |
| [成员角色](member_roles.md)                                | `/groups/:id/member_roles` |
| [成员](group_members.md)                                    | `/groups/:id/members`（也可用于项目） |
| [合并请求审批设置](merge_request_approval_settings.md) | `/groups/:id/merge_request_approval_setting`（也可用于项目） |
| [合并请求](merge_requests.md)                            | `/groups/:id/merge_requests`（也可用于项目和独立使用） |
| [评论](notes.md)（评论）                                   | `/groups/:id/epics/.../notes`（也可用于项目） |
| [通知设置](notification_settings.md)              | `/groups/:id/notification_settings`（也可用于项目和独立使用） |
| [资源标记事件](resource_label_events.md)              | `/groups/:id/epics/.../resource_label_events`（也可用于项目） |
| [资源状态事件](resource_state_events.md)              | `/groups/:id/epics/:epic_id/resource_state_events`（也可用于项目） |
| [SAML](saml.md)                                                | `/groups/:id/saml/identities`, `/groups/:id/saml_group_links` |
| [SCIM](scim.md)                                                | `/groups/:id/scim/identities` |
| [搜索](search.md)                                            | `/groups/:id/search`（也可用于项目和独立使用） |
| [密钥管理器](secrets_manager.md)                          | `/groups/:id/secrets_manager/access_token`（也可用于项目） |
| [服务账号](service_accounts.md)                        | `/groups/:id/service_accounts`（也可用于项目和独立使用） |
| [虚拟仓库清理策略](virtual_registries_cleanup_policies.md) | `/groups/:id/-/virtual_registries/cleanup/policy` |

<a id="standalone-resources"></a>

## 独立资源

以下 API 资源可在项目和群组上下文之外使用（包括 `/users`）：

| 资源                                                                                     | 可用端点 |
|----------------------------------------------------------------------------------------------|---------------------|
| [AI 目录管理员](admin/ai_catalog.md)                                                      | `/admin/ai_catalog/seed_external_agents` |
| [外观](appearance.md)                                                                  | `/application/appearance` |
| [应用程序](applications.md)                                                              | `/applications` |
| [审计事件](audit_events.md)                                                              | `/audit_events` |
| [头像](avatar.md)                                                                          | `/avatar` |
| [批处理后台迁移](admin/batched_background_migrations.md)                      | `/admin/batched_background_migrations` |
| [广播消息](broadcast_messages.md)                                                  | `/broadcast_messages` |
| [集群发现（基于证书）（已废弃）](cluster_discovery.md)| `/discover-cert-based-clusters` |
| [代码片段](snippets.md)                                                                 | `/snippets` |
| [代码建议](code_suggestions.md)                                                      | `/code_suggestions` |
| [合规与策略设置](compliance_policy_settings.md)                              | `/admin/security/compliance_policy_settings` |
| [自定义属性](custom_attributes.md)                                                    | `/users/:id/custom_attributes`（也可用于群组和项目） |
| [数据管理](admin/data_management.md)                                                  | `/admin/data_management/:model_name` |
| [数据库迁移](database_migrations.md)                                                | `/admin/migrations/:version/mark` |
| [依赖列表导出](dependency_list_export.md)                                         | `/pipelines/:id/dependency_list_exports`, `/projects/:id/dependency_list_exports`, `/groups/:id/dependency_list_exports`, `/security/dependency_list_exports/:id`, `/security/dependency_list_exports/:id/download` |
| [部署密钥](deploy_keys.md)                                                                | `/deploy_keys`（也可用于项目） |
| [部署令牌](deploy_tokens.md)                                                            | `/deploy_tokens`（也可用于项目和群组） |
| [事件](events.md)                                                                          | `/events`, `/users/:id/events`（也可用于项目） |
| [实验](experiments.md)（内部）                                                     | `/experiments` |
| [功能标志](features.md)                                                                 | `/features` |
| [Geo 节点](geo_nodes.md)                                                                    | `/geo_nodes` |
| [Geo 站点](geo_sites.md)                                                                    | `/geo_sites` |
| [极狐GitLab Duo Agent Platform 任务流](duo_agent_platform_flows.md)                               | `/ai/duo_workflows` |
| [极狐GitLab Duo Chat 补全](chat.md)（内部）                                            | `/chat/completions` |
| [GLQL](glql.md)                                                                              | `/glql`, `/glql/schema` |
| [群组活动分析](group_activity_analytics.md)                                      | `/analytics/group_activity/{issues_count}` |
| [通过直接传输进行群组和项目迁移](bulk_imports.md)                            | `/bulk_imports` |
| [群组代码仓库存储移动](group_repository_storage_moves.md)                          | `/group_repository_storage_moves` |
| [从 GitHub 导入代码仓库](import.md#import-repository-from-github)                     | `/import/github` |
| [从 Bitbucket Server 导入代码仓库](import.md#import-repository-from-bitbucket-server) | `/import/bitbucket_server` |
| [实例集群](instance_clusters.md)                                                    | `/admin/clusters` |
| [实例级 CI/CD 变量](instance_level_ci_variables.md)                             | `/admin/ci/variables` |
| [实例 SSH 证书](instance_ssh_certificates.md)                                     | `/admin/ssh_certificates` |
| [议题统计](issues_statistics.md)                                                    | `/issues_statistics`（也可用于群组和项目） |
| [议题](issues.md)                                                                          | `/issues`（也可用于群组和项目） |
| [作业](jobs.md)                                                                              | `/job` |
| [密钥](keys.md)                                                                              | `/keys` |
| [许可证](license.md)                                                                        | `/license` |
| [Markdown](markdown.md)                                                                      | `/markdown` |
| [合并请求](merge_requests.md)                                                          | `/merge_requests`（也可用于群组和项目） |
| [移动推送订阅](mobile_push_subscriptions.md)                                    | `/user/push_subscriptions` |
| [命名空间](namespaces.md)                                                                  | `/namespaces` |
| [通知设置](notification_settings.md)                                            | `/notification_settings`（也可用于群组和项目） |
| [Orbit](orbit.md)                                                                            | `/orbit/query` |
| [组织](organizations.md)                                                            | `/organizations` |
| [Pages 域名](pages_domains.md)                                                            | `/pages/domains`（也可用于项目） |
| [个人访问令牌](personal_access_tokens.md)                                          | `/personal_access_tokens` |
| [套餐限制](plan_limits.md)                                                                | `/application/plan_limits` |
| [策略存储](policy_store.md)                                                              | `/security/policy_store`, `/organizations/:id/security/policy_store` |
| [项目别名](project_aliases.md)                                                        | `/project_aliases` |
| [项目代码仓库存储移动](project_repository_storage_moves.md)                      | `/project_repository_storage_moves` |
| [项目](projects.md)                                                                      | `/users/:id/projects`（也可用于项目） |
| [Runner 控制器令牌](runner_controller_tokens.md)                                      | `/runner_controllers/:id/tokens` |
| [Runner 控制器](runner_controllers.md)                                                  | `/runner_controllers` |
| [Runner](runners.md)                                                                        | `/runners`（也可用于项目） |
| [搜索](search.md)                                                                          | `/search`（也可用于群组和项目） |
| [搜索管理](search_admin.md)                                                              | `/admin/search/migrations` |
| [服务账号](service_accounts.md)                                                      | `/service_accounts`（也可用于群组和项目） |
| [服务数据](usage_data.md)                                                                | `/usage_data`（仅限极狐GitLab 实例[管理员](../user/permissions.md)用户） |
| [设置](settings.md)                                                                      | `/application/settings` |
| [Sidekiq 指标](sidekiq_metrics.md)                                                        | `/sidekiq` |
| [Sidekiq 队列管理](admin_sidekiq_queues.md)                                     | `/admin/sidekiq/queues/:queue_name` |
| [代码片段代码仓库存储移动](snippet_repository_storage_moves.md)                      | `/snippet_repository_storage_moves` |
| [统计](statistics.md)                                                                  | `/application/statistics` |
| [建议](suggestions.md)                                                                | `/suggestions` |
| [系统钩子](system_hooks.md)                                                              | `/hooks` |
| [待办事项](todos.md)                                                                           | `/todos` |
| [令牌信息](admin/token.md)                                                          | `/admin/token` |
| [主题](topics.md)                                                                          | `/topics` |
| [用户应用程序](user_applications.md)                                                    | `/user/applications` |
| [用户电子邮件地址](user_email_addresses.md)                                              | `/user/emails` |
| [用户关注和取消关注](user_follow_unfollow.md)                                          | `/users/:id/follow`, `/users/:id/unfollow` |
| [用户审核](user_moderation.md)                                                        | `/users/:id/approve`, `/users/:id/reject` |
| [用户 SSH 和 GPG 密钥](user_keys.md)                                                        | `/user/keys` |
| [用户令牌](user_tokens.md)                                                                | `/users/:user_id/personal_access_tokens` |
| [用户](users.md)                                                                            | `/users` |
| [Web 提交](web_commits.md)                                                                | `/web_commits/public_key` |

<a id="template-resources"></a>

## 模板资源

以下资源提供端点：

- [Dockerfile 模板](templates/dockerfiles.md)
- [`.gitignore` 模板](templates/gitignores.md)
- [极狐GitLab CI/CD YAML 模板](templates/gitlab_ci_ymls.md)
- [开源许可证模板](templates/licenses.md)
