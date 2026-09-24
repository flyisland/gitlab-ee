---
stage: Software Supply Chain Security
group: Authentication
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
title: 应用程序设置 API
---

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: 私有化部署

{{< /details >}}

使用此 API 与您的极狐GitLab 实例的
[应用程序设置](#available-settings)
进行交互。

对应用程序设置的更改受缓存影响，可能不会立即生效。
默认情况下，极狐GitLab 会将应用程序设置缓存 60 秒。
有关如何控制实例的应用程序设置缓存的信息，请参阅[应用程序缓存间隔](../administration/application_settings_cache.md)。

先决条件：

- 您必须具有该实例的管理员访问权限。

<a id="retrieve-details-on-current-application-settings"></a>

## 检索当前应用程序设置的详细信息

检索此极狐GitLab 实例的当前[应用程序设置](#available-settings)的详细信息。

```plaintext
GET /application/settings
```

```shell
curl --request GET \
  --header "PRIVATE-TOKEN: <your_access_token>" \
  --url "https://gitlab.example.com/api/v4/application/settings"
```

示例响应：

```json
{
  "default_projects_limit" : 100000,
  "signup_enabled" : true,
  "id" : 1,
  "default_branch_protection" : 2,
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
  "default_preferred_language" : "en",
  "deletion_adjourned_period": 7,
  "failed_login_attempts_unlock_period_in_minutes": 30,
  "restricted_visibility_levels" : [],
  "sign_in_restrictions": {},
  "password_authentication_enabled_for_web" : true,
  "after_sign_out_path" : null,
  "max_attachment_size" : 100,
  "max_decompressed_archive_size": 25600,
  "max_export_size": 50,
  "max_import_size": 50,
  "max_import_remote_file_size": 10240,
  "max_login_attempts": 3,
  "user_oauth_applications" : true,
  "updated_at" : "2016-01-04T15:44:55.176Z",
  "session_expire_delay" : 10080,
  "home_page_url" : null,
  "default_snippet_visibility" : "private",
  "outbound_local_requests_whitelist": [],
  "domain_allowlist" : [],
  "domain_denylist_enabled" : false,
  "domain_denylist" : [],
  "created_at" : "2016-01-04T15:44:55.176Z",
  "default_ci_config_path" : null,
  "default_project_visibility" : "private",
  "default_group_visibility" : "private",
  "gravatar_enabled" : true,
  "container_expiration_policies_enable_historic_entries": true,
  "container_registry_cleanup_tags_service_max_list_size": 200,
  "container_registry_delete_tags_service_timeout": 250,
  "container_registry_expiration_policies_caching": true,
  "container_registry_expiration_policies_worker_capacity": 4,
  "container_registry_token_expire_delay": 5,
  "oauth_access_token_expires_in": 7200,
  "decompress_archive_file_timeout": 210,
  "repository_storages_weighted": {"default": 100},
  "plantuml_enabled": false,
  "plantuml_url": null,
  "diagramsnet_enabled": true,
  "diagramsnet_url": "https://embed.diagrams.net",
  "kroki_enabled": false,
  "kroki_url": null,
  "terminal_max_session_time": 0,
  "polling_interval_multiplier": 1.0,
  "rsa_key_restriction": 0,
  "dsa_key_restriction": 0,
  "ecdsa_key_restriction": 0,
  "ed25519_key_restriction": 0,
  "ecdsa_sk_key_restriction": 0,
  "ed25519_sk_key_restriction": 0,
  "first_day_of_week": 0,
  "enforce_terms": true,
  "terms": "Hello world!",
  "inactive_resource_access_tokens_delete_after_days": 30,
  "performance_bar_allowed_group_id": 42,
  "user_show_add_ssh_key_message": true,
  "allow_account_deletion": true,
  "updating_name_disabled_for_users": false,
  "local_markdown_version": 0,
  "allow_local_requests_from_hooks_and_services": true,
  "allow_local_requests_from_web_hooks_and_services": true,
  "allow_local_requests_from_system_hooks": false,
  "asset_proxy_enabled": true,
  "asset_proxy_url": "https://assets.example.com",
  "asset_proxy_whitelist": ["example.com", "*.example.com", "your-instance.com"],
  "asset_proxy_allowlist": ["example.com", "*.example.com", "your-instance.com"],
  "maven_package_requests_forwarding": true,
  "npm_package_requests_forwarding": true,
  "pypi_package_requests_forwarding": true,
  "rubygems_package_requests_forwarding": false,
  "snippet_size_limit": 52428800,
  "issues_create_limit": 300,
  "raw_blob_request_limit": 300,
  "raw_blob_request_limit_unauthenticated": 800,
  "wiki_page_max_content_bytes": 5242880,
  "require_admin_approval_after_user_signup": false,
  "require_personal_access_token_expiry": true,
  "personal_access_token_prefix": "glpat-",
  "rate_limiting_response_text": null,
  "keep_latest_artifact": true,
  "admin_mode": false,
  "floc_enabled": false,
  "external_pipeline_validation_service_timeout": null,
  "external_pipeline_validation_service_token": null,
  "external_pipeline_validation_service_url": null,
  "jira_connect_application_key": null,
  "jira_connect_public_key_storage_enabled": false,
  "jira_connect_proxy_url": null,
  "jira_connect_additional_audience_url": null,
  "silent_mode_enabled": false,
  "package_registry_allow_anyone_to_pull_option": true,
  "bulk_import_max_download_file_size": 5120,
  "project_jobs_api_rate_limit": 600,
  "runner_jobs_request_api_limit": 2000,
  "runner_jobs_patch_trace_api_limit": 200,
  "runner_jobs_endpoints_api_limit": 200,
  "security_txt_content": null,
  "security_scan_stale_after_days": 90,
  "bulk_import_concurrent_pipeline_batch_limit": 25,
  "concurrent_relation_batch_export_limit": 25,
  "concurrent_relation_export_limit": 25,
  "relation_export_batch_size": 50,
  "concurrent_github_import_jobs_limit": 1000,
  "concurrent_bitbucket_import_jobs_limit": 100,
  "concurrent_bitbucket_server_import_jobs_limit": 100,
  "concurrent_pull_request_import_jobs_limit": 200,
  "import_jobs_concurrency_limit": 100,
  "silent_admin_exports_enabled": false,
  "top_level_group_creation_enabled": true,
  "disable_invite_members": false,
  "enforce_pipl_compliance": true,
  "model_prompt_cache_enabled": true,
  "lock_model_prompt_cache_enabled": false
}
```

[极狐GitLab 专业版或旗舰版](https://gitlab.cn/pricing) 用户可能还会看到
以下参数：

- `allow_all_integrations`
- `allowed_integrations`
- `default_project_deletion_protection`
- `delete_unconfirmed_users`
- `dependency_scanning_sbom_scan_api_download_limit`
- `dependency_scanning_sbom_scan_api_upload_limit`
- `disable_personal_access_tokens`
- `duo_features_enabled`
- `elasticsearch_index_settings`
- `file_template_project_id`
- `geo_node_allowed_ips`
- `geo_status_timeout`
- `group_owners_can_manage_default_branch_protection`
- `lock_duo_features_enabled`
- `scan_execution_policies_action_limit`
- `scan_execution_policies_schedule_limit`
- `secret_push_protection_available`
- `security_approval_policies_limit`
- `security_policy_global_group_approvers_enabled`
- `unconfirmed_users_delete_after_days`
- `use_clickhouse_for_analytics`
- `virtual_registries_endpoints_api_limit`
- `project_secrets_limit`
- `group_secrets_limit`
- `security_mr_report_cache_lifetime_minutes`
- `security_scan_stale_after_days`
- `service_access_tokens_expiration_enforced`

```json
{
  "allow_all_integrations": true,
  "allowed_integrations": [],
  "default_project_deletion_protection": false,
  "disable_personal_access_tokens": false,
  "duo_features_enabled": true,
  "elasticsearch_index_settings": [
    {
      "alias_name": "gitlab-production",
      "number_of_shards": 5,
      "number_of_replicas": 1
    }
  ],
  "file_template_project_id": 1,
  "geo_node_allowed_ips": "0.0.0.0/0, ::/0",
  "group_owners_can_manage_default_branch_protection": true,
  "id": 1,
  "lock_duo_features_enabled": false,
  "signup_enabled": true,
  "virtual_registries_endpoints_api_limit": 4000,
  "project_secrets_limit": 100,
  "group_secrets_limit": 500
  ...
}
```

<a id="update-application-settings"></a>

## 更新应用程序设置

更新此极狐GitLab 实例的当前[应用程序设置](#available-settings)。

```plaintext
PUT /application/settings
```

```shell
curl --request PUT \
  --header "PRIVATE-TOKEN: <your_access_token>" \
  --url "https://gitlab.example.com/api/v4/application/settings" \
  --data "signup_enabled=false" \
  --data "default_project_visibility=internal"
```

示例响应：

```json
{
  "id": 1,
  "default_projects_limit": 100000,
  "default_preferred_language": "en",
  "failed_login_attempts_unlock_period_in_minutes": 30,
  "signup_enabled": false,
  "password_authentication_enabled_for_web": true,
  "gravatar_enabled": true,
  "created_at": "2015-06-12T15:51:55.432Z",
  "updated_at": "2015-06-30T13:22:42.210Z",
  "home_page_url": "",
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
  "restricted_visibility_levels": [],
  "sign_in_restrictions": {},
  "max_attachment_size": 100,
  "max_decompressed_archive_size": 25600,
  "max_export_size": 50,
  "max_import_size": 50,
  "max_import_remote_file_size": 10240,
  "max_login_attempts": 3,
  "session_expire_delay": 10080,
  "default_ci_config_path" : null,
  "default_project_visibility": "internal",
  "default_snippet_visibility": "private",
  "default_group_visibility": "private",
  "outbound_local_requests_whitelist": [],
  "domain_allowlist": [],
  "domain_denylist_enabled" : false,
  "domain_denylist" : [],
  "external_authorization_service_enabled": true,
  "external_authorization_service_url": "https://authorize.me",
  "external_authorization_service_default_label": "default",
  "external_authorization_service_timeout": 0.5,
  "user_oauth_applications": true,
  "after_sign_out_path": "",
  "container_expiration_policies_enable_historic_entries": true,
  "container_registry_cleanup_tags_service_max_list_size": 200,
  "container_registry_delete_tags_service_timeout": 250,
  "container_registry_expiration_policies_caching": true,
  "container_registry_expiration_policies_worker_capacity": 4,
  "container_registry_token_expire_delay": 5,
  "oauth_access_token_expires_in": 7200,
  "decompress_archive_file_timeout": 210,
  "package_registry_cleanup_policies_worker_capacity": 2,
  "plantuml_enabled": false,
  "plantuml_url": null,
  "diagramsnet_enabled": true,
  "diagramsnet_url": "https://embed.diagrams.net",
  "terminal_max_session_time": 0,
  "polling_interval_multiplier": 1.0,
  "rsa_key_restriction": 0,
  "dsa_key_restriction": 0,
  "ecdsa_key_restriction": 0,
  "ed25519_key_restriction": 0,
  "ecdsa_sk_key_restriction": 0,
  "ed25519_sk_key_restriction": 0,
  "first_day_of_week": 0,
  "enforce_terms": true,
  "terms": "Hello world!",
  "inactive_resource_access_tokens_delete_after_days": 30,
  "performance_bar_allowed_group_id": 42,
  "user_show_add_ssh_key_message": true,
  "file_template_project_id": 1,
  "local_markdown_version": 0,
  "asset_proxy_enabled": true,
  "asset_proxy_url": "https://assets.example.com",
  "asset_proxy_allowlist": ["example.com", "*.example.com", "your-instance.com"],
  "globally_allowed_ips": "",
  "geo_node_allowed_ips": "0.0.0.0/0, ::/0",
  "allow_local_requests_from_hooks_and_services": true,
  "allow_local_requests_from_web_hooks_and_services": true,
  "allow_local_requests_from_system_hooks": false,
  "maven_package_requests_forwarding": true,
  "npm_package_requests_forwarding": true,
  "pypi_package_requests_forwarding": true,
  "rubygems_package_requests_forwarding": false,
  "snippet_size_limit": 52428800,
  "issues_create_limit": 300,
  "raw_blob_request_limit": 300,
  "raw_blob_request_limit_unauthenticated": 800,
  "wiki_page_max_content_bytes": 5242880,
  "require_admin_approval_after_user_signup": false,
  "require_personal_access_token_expiry": true,
  "personal_access_token_prefix": "glpat-",
  "rate_limiting_response_text": null,
  "keep_latest_artifact": true,
  "admin_mode": false,
  "external_pipeline_validation_service_timeout": null,
  "external_pipeline_validation_service_token": null,
  "external_pipeline_validation_service_url": null,
  "can_create_group": false,
  "jira_connect_application_key": "123",
  "jira_connect_public_key_storage_enabled": true,
  "jira_connect_proxy_url": "http://gitlab.example.com",
  "user_defaults_to_private_profile": true,
  "projects_api_rate_limit_unauthenticated": 400,
  "runner_jobs_request_api_limit": 2000,
  "runner_jobs_patch_trace_api_limit": 200,
  "runner_jobs_endpoints_api_limit": 200,
  "users_api_limit_followers": 100,
  "users_api_limit_following": 100,
  "users_api_limit_status": 240,
  "users_api_limit_ssh_keys": 120,
  "users_api_limit_ssh_key": 120,
  "users_api_limit_gpg_keys": 120,
  "users_api_limit_gpg_key": 120,
  "web_hook_event_resend_limit": 5,
  "web_hook_test_limit": 5,
  "silent_mode_enabled": false,
  "security_policy_global_group_approvers_enabled": true,
  "security_approval_policies_limit": 5,
  "scan_execution_policies_action_limit": 0,
  "scan_execution_policies_schedule_limit": 0,
  "package_registry_allow_anyone_to_pull_option": true,
  "bulk_import_max_download_file_size": 5120,
  "project_jobs_api_rate_limit": 600,
  "security_txt_content": null,
  "security_scan_stale_after_days": 90,
  "bulk_import_concurrent_pipeline_batch_limit": 25,
  "concurrent_relation_batch_export_limit": 25,
  "concurrent_relation_export_limit": 25,
  "relation_export_batch_size": 50,
  "downstream_pipeline_trigger_limit_per_project_user_sha": 0,
  "concurrent_github_import_jobs_limit": 1000,
  "concurrent_bitbucket_import_jobs_limit": 100,
  "concurrent_bitbucket_server_import_jobs_limit": 100,
  "concurrent_pull_request_import_jobs_limit": 200,
  "import_jobs_concurrency_limit": 100,
  "silent_admin_exports_enabled": false,
  "enforce_pipl_compliance": true
}
```

[极狐GitLab 专业版或旗舰版](https://gitlab.cn/pricing) 用户可能还会看到
以下参数：

- `allow_all_integrations`
- `allowed_integrations`
- `group_owners_can_manage_default_branch_protection`
- `file_template_project_id`
- `geo_node_allowed_ips`
- `geo_status_timeout`
- `default_project_deletion_protection`
- `disable_personal_access_tokens`
- `security_policy_global_group_approvers_enabled`
- `security_approval_policies_limit`
- `scan_execution_policies_action_limit`
- `scan_execution_policies_schedule_limit`
- `delete_unconfirmed_users`
- `unconfirmed_users_delete_after_days`
- `duo_features_enabled`
- `lock_duo_features_enabled`
- `use_clickhouse_for_analytics`
- `virtual_registries_endpoints_api_limit`
- `lock_memberships_to_saml`
- `security_mr_report_cache_lifetime_minutes`
- `security_scan_stale_after_days`
- `service_access_tokens_expiration_enforced`

示例响应：

```json
  "file_template_project_id": 1,
  "geo_node_allowed_ips": "0.0.0.0/0, ::/0",
  "duo_features_enabled": true,
  "lock_duo_features_enabled": false,
  "allow_all_integrations": true,
  "allowed_integrations": [],
  "virtual_registries_endpoints_api_limit": 4000
```

<a id="available-settings"></a>

## 可用设置

<!--
This heading is referenced by a script: `scripts/cells/application-settings-analysis.rb`
 Any updates to this heading should be reflected for the DOC_API_SETTINGS_TABLE_REGEX variable.
 -->

通常，所有设置都是可选的。启用某些设置时，您可能还需要
配置其他相关设置。这些要求位于下表的 `Required` 列中。

| 属性                                | 类型             | 必填                             | 描述 |
|------------------------------------------|------------------|:------------------------------------:|-------------|
| `admin_mode`                             | boolean          | 否                                   | 要求管理员通过重新认证启用管理员模式，以执行管理任务。 |
| `admin_notification_email`               | string           | 否                                   | 已弃用：请改用 `abuse_notification_email`。如果设置，[滥用报告](../administration/review_abuse_reports.md)将发送到此地址。滥用报告始终可在**管理员**区域中查看。 |
| `abuse_notification_email`               | string           | 否                                   | 如果设置，[滥用报告](../administration/review_abuse_reports.md)将发送到此地址。滥用报告始终可在**管理员**区域中查看。 |
| `notify_on_unknown_sign_in`              | boolean          | 否                                   | 启用从未知 IP 地址登录时发送通知。 |
| `after_sign_out_path`                    | string           | 否                                   | 用户注销后重定向到的位置。 |
| `email_restrictions_enabled`             | boolean          | 否                                   | 阻止新用户使用某些电子邮件地址创建账户。 |
| `email_restrictions`                     | string           | 由以下项要求：`email_restrictions_enabled` | 用于检查注册时所用电子邮件地址的正则表达式。 |
| `after_sign_up_text`                     | string           | 否                                   | 用户注册后显示的文本。 |
| `ai_action_api_rate_limit`               | integer          | 否                                   | 每个用户每八小时允许对 `aiAction` GraphQL 变更发起的最大请求数。默认值：`160`。设置为 `0` 可禁用速率限制。 |
| `akismet_api_key`                        | string           | 由以下项要求：`akismet_enabled`     | 用于 Akismet 垃圾信息防护的 API 密钥。 |
| `akismet_enabled`                        | boolean          | 否                                   | （**如果启用，则需要**：`akismet_api_key`）启用或禁用 Akismet 垃圾信息防护。 |
| `allow_all_integrations`                 | boolean          | 否                                   | 当 `false` 时，实例上仅允许 `allowed_integrations` 中的集成。仅限旗舰版。 |
| `allowed_integrations`                   | array of strings | 否                                   | 当 `allow_all_integrations` 为 `false` 时，实例上仅允许此列表中的集成。仅限旗舰版。 |
| `allow_account_deletion`                 | boolean          | 否                                   | 设置为 `true` 以允许用户删除其账户。仅限专业版和旗舰版。 |
| `allow_group_owners_to_manage_ldap`      | boolean          | 否                                   | 设置为 `true` 以允许群组所有者管理 LDAP。仅限专业版和旗舰版。 |
| `allow_local_requests_from_hooks_and_services` | boolean    | 否                                   | （已弃用：请改用 `allow_local_requests_from_web_hooks_and_services`）允许来自 webhook 和集成的对本地网络的请求。 |
| `allow_local_requests_from_system_hooks` | boolean          | 否                                   | 允许来自系统钩子的对本地网络的请求。 |
| `allow_local_requests_from_web_hooks_and_services` | boolean | 否                                  | 允许来自 webhook 和集成的对本地网络的请求。 |
| `allow_project_creation_for_guest_and_below` | boolean      | 否                                   | 指示被分配至访客及以下角色的用户是否可以创建群组和个人项目。默认为 `true`。 |
| `allow_runner_registration_token`        | boolean          | 否                                   | 允许使用注册令牌创建 Runner。默认为 `true`。 |
| `archive_builds_in_human_readable`       | string           | 否                                   | 设置作业被视为旧作业和过期作业的时长。超过该时间后，作业将被归档，且无法再重试。将其留空以永不过期作业。该值不得少于 1 天，例如：`15 days`、`1 month`、`2 years`。 |
| `asset_proxy_enabled`                    | boolean          | 否                                   | （**如果启用，则需要**：`asset_proxy_url`）启用资源代理。应用更改需要重启极狐GitLab。 |
| `asset_proxy_secret_key`                 | string           | 否                                   | 与资源代理服务器共享的密钥。应用更改需要重启极狐GitLab。 |
| `asset_proxy_url`                        | string           | 否                                   | 资源代理服务器的 URL。应用更改需要重启极狐GitLab。 |
| `asset_proxy_whitelist`                  | string or array of strings | 否                         | （已弃用：请改用 `asset_proxy_allowlist`）匹配这些域名的资源不会被代理。允许使用通配符。您的极狐GitLab 安装 URL 会自动加入白名单。应用更改需要重启极狐GitLab。 |
| `asset_proxy_allowlist`                  | string or array of strings | 否                         | 匹配这些域名的资源不会被代理。允许使用通配符。您的极狐GitLab 安装 URL 会自动加入白名单。应用更改需要重启极狐GitLab。 |
| `authn_data_retention_cleanup_enabled`   | boolean          | 否                                   | 如果为 `true`，则运行清理工作进程，永久删除超过一年的身份验证登录历史，以及超过一个月前撤销的 OAuth 访问令牌和授权。默认值：`false`。[引入](https://gitlab.com/gitlab-org/gitlab/-/work_items/579002)于极狐GitLab 18.7。 |
| `authorized_keys_enabled`                | boolean          | 否                                   | 默认情况下，`authorized_keys` 文件支持通过 SSH 进行 Git 操作，无需额外配置。极狐GitLab 可以优化为通过数据库文件验证 SSH 密钥。仅当您已将 OpenSSH 服务器配置为使用 AuthorizedKeysCommand 时，才禁用此选项。 |
| `auto_accept_awarded_achievements`       | boolean          | 否                                   | 如果为 `true`，新授予的成就将自动接受，并立即显示在用户个人资料中。不影响启用此设置之前授予的成就。接收者仍可隐藏任何成就。默认值：`false`。[引入](https://gitlab.com/gitlab-org/gitlab/-/work_items/607750)于极狐GitLab 19.4。 |
| `auto_devops_domain`                     | string           | 否                                   | 为每个项目的 Auto Review Apps 和 Auto Deploy 阶段指定默认使用的域名。 |
| `auto_devops_enabled`                    | boolean          | 否                                   | 默认情况下为项目启用 Auto DevOps。它会根据预定义的 CI/CD 配置自动构建、测试和部署应用程序。 |
| `autocomplete_users`                     | integer          | 否                                   | 每分钟对 `GET /autocomplete/users` 端点的已认证请求的最大数量。 |
| `autocomplete_users_unauthenticated`     | integer          | 否                                   | 每分钟对 `GET /autocomplete/users` 端点的未认证请求的最大数量。 |
| `automatic_purchased_storage_allocation` | boolean          | 否                                   | 启用此选项允许在命名空间中自动分配已购买的存储。仅与企业版发行版相关。 |
| `bulk_import_enabled`                    | boolean          | 否                                   | 启用通过直接传输迁移极狐GitLab 群组。此设置也可在**管理员**区域中[使用](../administration/settings/import_and_export_settings.md#enable-migration-of-groups-and-projects-by-direct-transfer)。 |
| `offline_transfer_exports_enabled`       | boolean          | 否                                   | 启用通过离线传输导出极狐GitLab 群组和项目。[引入](https://gitlab.com/gitlab-org/gitlab/-/work_items/588971)于极狐GitLab 19.3。 |
| `offline_transfer_imports_enabled`       | boolean          | 否                                   | 启用通过离线传输导入极狐GitLab 群组和项目。[引入](https://gitlab.com/gitlab-org/gitlab/-/work_items/588971)于极狐GitLab 19.3。 |
| `bulk_import_max_download_file_size`     | integer          | 否                                   | 通过直接传输从源极狐GitLab 实例导入时的最大下载文件大小。 |
| `allow_bypass_placeholder_confirmation`  | boolean          | 否                                   | 管理员重新分配占位用户时跳过确认。[引入](https://gitlab.com/gitlab-org/gitlab/-/issues/534330)于极狐GitLab 18.0。 |
| `allow_s3_compatible_storage_for_offline_transfer` | boolean | 否                                  | 允许将兼容 S3 的对象存储用于离线传输。[引入](https://gitlab.com/gitlab-org/gitlab/-/work_items/579705)于极狐GitLab 18.9。 |
| `allow_application_default_credentials_for_offline_transfer` | boolean | 否                        | 允许将 Google Cloud 应用默认凭据用于离线传输。即使启用，也只有管理员可以使用这些凭据，且存储桶名称必须以 `gitlab-offline-transfer-` 开头。对 JihuLab.com 无效。更多信息，请参阅[允许应用默认凭据用于离线传输](../administration/settings/import_and_export_settings.md#allow-application-default-credentials-for-offline-transfer)。[引入](https://gitlab.com/gitlab-org/gitlab/-/work_items/602489)于极狐GitLab 19.3。 |
| `built_in_project_templates_enabled`     | boolean          | 否                                   | 用户创建项目时启用内置项目模板。仅限专业版和旗舰版。[引入](https://gitlab.com/gitlab-org/gitlab/-/merge_requests/235284)于极狐GitLab 19.0，[带有一个功能标志](../administration/feature_flags/_index.md)，名为 `use_built_in_project_templates_enabled`。默认禁用。[正式发布](https://gitlab.com/gitlab-org/gitlab/-/work_items/593623)于极狐GitLab 19.2。功能标志 `use_built_in_project_templates_enabled` 已移除。 |
| `lock_built_in_project_templates_enabled` | boolean         | 否                                   | 对所有群组强制执行 `built_in_project_templates_enabled` 设置。仅限专业版和旗舰版。[引入](https://gitlab.com/gitlab-org/gitlab/-/merge_requests/235284)于极狐GitLab 19.0，[带有一个功能标志](../administration/feature_flags/_index.md)，名为 `use_built_in_project_templates_enabled`。默认禁用。[正式发布](https://gitlab.com/gitlab-org/gitlab/-/work_items/593623)于极狐GitLab 19.2。功能标志 `use_built_in_project_templates_enabled` 已移除。 |
| `can_create_group`                       | boolean          | 否                                   | 指示用户是否可以创建顶级群组。默认为 `true`。 |
| `check_namespace_plan`                   | boolean          | 否                                   | 启用此选项后，仅当项目命名空间的套餐包含该功能或项目为公开时，许可的企业版功能才对项目可用。仅限专业版和旗舰版。 |
| `ci_delete_pipelines_in_seconds_limit_human_readable` | string | 否                                | 配置流水线保留期所允许的最大值。默认为 `1 year`。 |
| `ci_job_live_trace_enabled`              | boolean          | 否                                   | 为作业日志开启增量日志记录。开启后，归档的作业日志会增量上传到对象存储。必须配置对象存储。您也可以在[**管理员**区域](../administration/settings/continuous_integration.md#access-job-log-settings)配置此设置。 |
| `git_push_pipeline_limit`                | integer          | 否                                   | 设置单次 Git 推送可触发的标签或分支流水线的最大数量。有关此限制的更多信息，请参阅[每次 Git 推送的流水线数量](../administration/cicd/limits.md#number-of-pipelines-per-git-push)。 |
| `ci_max_total_yaml_size_bytes`           | integer          | 否                                   | 可为流水线配置（包括所有包含的 YAML 配置文件）分配的最大内存量（以字节为单位）。 |
| `ci_max_includes`                        | integer          | 否                                   | 每个流水线的[最大包含数](../administration/cicd/limits.md#maximum-number-of-includes)。默认为 `150`。 |
| `ci_partitions_size_limit`               | integer          | 否                                   | 在创建新分区之前，CI 表的数据库分区可使用的最大磁盘空间量（以字节为单位）。默认为 `100 GB`。[移除](https://gitlab.com/gitlab-org/gitlab/-/issues/429675)于极狐GitLab 18.11。 |
| `ci_partitions_in_seconds_limit_human_readable` | string    | 否                                   | 在创建新的 CI 分区且系统切换到下一组分区之前的时间窗口。必须介于 `1 month` 和 `6 months` 之间。默认为 `1 month`。 |
| `ci_partitions_in_seconds_limit`         | integer          | 否                                   | 在创建新的 CI 分区且系统切换到下一组分区之前的时间窗口（以秒为单位）。必须介于 1 个月和 6 个月之间。默认为 1 个月（`2592000`）。只写。不会在 GET 响应中返回。已弃用，推荐使用 `ci_partitions_in_seconds_limit_human_readable`，并计划在 API v5 中移除。 |
| `concurrent_github_import_jobs_limit`    | integer          | 否                                   | GitHub 导入器的最大同时导入作业数。默认为 1000。 |
| `concurrent_bitbucket_import_jobs_limit` | integer          | 否                                   | Bitbucket Cloud 导入器的最大同时导入作业数。默认为 100。 |
| `concurrent_bitbucket_server_import_jobs_limit` | integer   | 否                                   | Bitbucket Server 导入器的最大同时导入作业数。默认为 100。 |
| `concurrent_pull_request_import_jobs_limit` | integer | 否                                         | GitHub、Bitbucket Cloud 和 Bitbucket Server 导入器的最大同时拉取请求导入作业数。默认为 200。 |
| `import_jobs_concurrency_limit`          | integer          | 否                                   | 每种导入工作进程类型（项目和群组文件基础导入、直接传输以及 GitHub、Bitbucket Cloud 和 Bitbucket Server 导入器阶段）的最大并发运行作业数。按工作进程类型独立应用。默认为 100。于极狐GitLab 19.1 引入 |
| `commit_email_hostname`                  | string           | 否                                   | 自定义主机名（用于私有提交电子邮件）。 |
| `container_expiration_policies_enable_historic_entries`   | boolean | 否                           | 为所有项目启用[清理策略](../user/packages/container_registry/reduce_container_registry_storage.md#enable-the-cleanup-policy)。 |
| `container_registry_cleanup_tags_service_max_list_size`   | integer | 否                           | 在单次执行[清理策略](../user/packages/container_registry/reduce_container_registry_storage.md#set-cleanup-limits-to-conserve-resources)中可删除的最大标签数。 |
| `container_registry_delete_tags_service_timeout`          | integer | 否                           | 清理过程为[清理策略](../user/packages/container_registry/reduce_container_registry_storage.md#set-cleanup-limits-to-conserve-resources)删除一批标签所需的最长时间（以秒为单位）。 |
| `container_registry_expiration_policies_caching`          | boolean | 否                           | 执行[清理策略](../user/packages/container_registry/reduce_container_registry_storage.md#set-cleanup-limits-to-conserve-resources)期间的缓存。 |
| `container_registry_expiration_policies_worker_capacity`  | integer | 否                           | 用于[清理策略](../user/packages/container_registry/reduce_container_registry_storage.md#set-cleanup-limits-to-conserve-resources)的工作进程数。 |
| `container_registry_token_expire_delay`                   | integer | 否                           | 容器镜像仓库令牌的有效期（以分钟为单位）。 |
| `package_registry_cleanup_policies_worker_capacity`       | integer | 否                           | 分配给软件包清理策略的工作进程数。 |
| `updating_name_disabled_for_users`       | boolean          | 否                                   | [禁用用户个人资料名称更改](../administration/settings/account_and_limit_settings.md#disable-user-profile-name-changes)。 |
| `deactivate_dormant_users`               | boolean          | 否                                   | 启用[自动停用休眠用户](../administration/moderate_users.md#automatically-deactivate-dormant-users)。 |
| `deactivate_dormant_users_period`        | integer          | 否                                   | 用户被视为休眠用户所需的时间（以天为单位）。 |
| `decompress_archive_file_timeout`        | integer          | 否                                   | 解压归档文件的默认超时时间（以秒为单位）。设置为 0 可禁用超时。 |
| `default_artifacts_expire_in`            | string           | 否                                   | 设置每个作业产物的默认过期时间。 |
| `default_branch_name`                    | string           | 否                                   | 为实例中的所有项目[设置初始分支名称](../user/project/repository/branches/default.md#change-the-default-branch-name-for-new-projects-in-an-instance)。 |
| `default_branch_protection`              | integer          | 否                                   | 在极狐GitLab 17.0 中[已弃用](https://gitlab.com/gitlab-org/gitlab/-/issues/408314)。请改用 `default_branch_protection_defaults`。 |
| `default_branch_protection_defaults`     | hash             | 否                                   | 在极狐GitLab 17.0 中[引入](https://gitlab.com/gitlab-org/gitlab/-/issues/408314)。有关可用选项，请参阅[`default_branch_protection_defaults` 的选项](groups.md#options-for-default_branch_protection_defaults)。 |
| `default_ci_config_path`                 | string           | 否                                   | 新项目的默认 CI/CD 配置文件和路径（如果未设置，则为 `.gitlab-ci.yml`）。 |
| `default_group_visibility`               | string           | 否                                   | 新群组接收的可见性级别。可接受 `private`、`internal` 和 `public` 作为参数。默认为 `private`。不能设置为 `restricted_visibility_levels` 中的任何级别。 |
| `default_preferred_language`             | string           | 否                                   | 未登录用户的默认首选语言。 |
| `default_project_creation`               | integer          | 否                                   | 创建项目所需的默认最低角色。可接受：`0` _（无）_、`1` _（维护者）_、`2` _（开发者）_、`3` _（管理员）_ 或 `4` _（所有者）_。 |
| `default_project_visibility`             | string           | 否                                   | 新项目接收的可见性级别。可接受 `private`、`internal` 和 `public` 作为参数。默认为 `private`。不能设置为 `restricted_visibility_levels` 中的任何级别。 |
| `default_projects_limit`                 | integer          | 否                                   | 每个用户的项目限制。默认为 `100000`。 |
| `default_snippet_visibility`             | string           | 否                                   | 新代码片段接收的可见性级别。可接受 `private`、`internal` 和 `public` 作为参数。默认为 `private`。 |
| `default_syntax_highlighting_theme`      | integer          | 否                                   | 新用户或未登录用户的默认语法高亮主题。请参阅[可用主题的 ID](https://gitlab.com/gitlab-org/gitlab/blob/master/lib/gitlab/themes.rb#L16)。 |
| `default_dark_syntax_highlighting_theme` | integer          | 否                                   | 新用户或未登录用户的默认深色模式语法高亮主题。请参阅[可用主题的 ID](https://gitlab.com/gitlab-org/gitlab/blob/master/lib/gitlab/themes.rb#L16)。 |
| `default_project_deletion_protection`    | boolean          | 否                                   | 启用默认项目删除保护，以便只有管理员才能删除项目。默认为 `false`。仅限极狐GitLab 私有化部署、专业版和旗舰版。 |
| `delete_unconfirmed_users`               | boolean          | 否                                   | 指定是否应删除未确认电子邮件的用户。默认为 `false`。设置为 `true` 时，未确认用户将在 `unconfirmed_users_delete_after_days` 天后被删除。仅限极狐GitLab 私有化部署、专业版和旗舰版。 |
| `deletion_adjourned_period`              | integer          | 否                                   | 删除标记为删除的项目或群组之前等待的天数。值必须介于 `1` 和 `90` 之间。默认为 `30`。 |
| `dependency_management_settings`         | hash             | 否                                   | 依赖项管理设置。设置 `security_update_scheduler_max_concurrency`（整数）以限制整个 Sidekiq 集群中并发运行的安全更新调度作业数。默认值：`30`。上限为 `200`。设置为 `0` 以暂停调度。仅限旗舰版。[引入](https://gitlab.com/gitlab-org/gitlab/-/merge_requests/239173)于极狐GitLab 19.1。 |
| `description_and_note_max_size`          | integer          | 否                                   | 工作项、合并请求和漏洞描述及评论内容的最大大小（以字节为单位）。默认为 `1048576`。 |
| `diagramsnet_enabled`                    | boolean          | 否                                   | （如果启用，则需要 `diagramsnet_url`）启用 [Diagrams.net 集成](../administration/integration/diagrams_net.md)。默认为 `true`。 |
| `diagramsnet_url`                        | string           | 由以下项要求：`diagramsnet_enabled` | 用于集成的 Diagrams.net 实例 URL。 |
| `diff_max_patch_bytes`                   | integer          | 否                                   | 最大 [diff 补丁大小](../administration/diff_limits.md)（以字节为单位）。 |
| `diff_max_files`                         | integer          | 否                                   | [diff 中的最大文件数](../administration/diff_limits.md)。 |
| `diff_max_lines`                         | integer          | 否                                   | [diff 中的最大行数](../administration/diff_limits.md)。 |
| `diff_max_versions`                      | integer          | 否                                   | 每个合并请求的 [diff 版本](../administration/diff_limits.md)最大数量。 |
| `diff_max_commits`                       | integer          | 否                                   | 每个合并请求的 [diff 提交](../administration/diff_limits.md)最大数量。 |
| `disable_admin_oauth_scopes`             | boolean          | 否                                   | 阻止管理员将其极狐GitLab 账户连接到具有 `api`、`read_api`、`read_repository`、`write_repository`、`read_registry`、`write_registry` 或 `sudo` 范围的不可信 OAuth 2.0 应用程序。 |
| `disable_feed_token`                     | boolean          | 否                                   | 禁用 RSS/Atom 和日历订阅令牌的显示。 |
| `disable_personal_access_tokens`         | boolean          | 否                                   | 禁用个人访问令牌。仅限极狐GitLab 私有化部署、专业版和旗舰版。没有可用的方法可以通过 API 启用已禁用的个人访问令牌。这是一个[已知问题](https://gitlab.com/gitlab-org/gitlab/-/issues/399233)。有关可用变通方法的更多信息，请参阅[变通方法](https://gitlab.com/gitlab-org/gitlab/-/issues/399233#workaround)。     |
| `disabled_oauth_sign_in_sources`         | array of strings | 否                                   | 禁用的 OAuth 登录源。 |
| `disable_password_authentication_for_users_with_sso_identities` | boolean | 否                     | 为具有 SSO 身份的用户禁用 Web 界面中的密码认证。这不影响通过 HTTP(S) 进行的 Git 操作。默认为 `false`。 |
| `dns_rebinding_protection_enabled`       | boolean          | 否                                   | 强制实施 DNS 重绑定攻击防护。 |
| `domain_denylist_enabled`                | boolean          | 否                                   | （**如果启用，则需要**：`domain_denylist`）允许您阻止使用特定域名的电子邮件地址注册新用户账户。 |
| `domain_denylist`                        | array of strings | 否                                   | 电子邮件地址匹配这些域名的用户无法创建新账户。允许使用通配符。在单独的行中输入多个条目。例如：`domain.com`、`*.domain.com`。 |
| `domain_allowlist`                       | array of strings | 否                                   | 强制用户在创建账户时仅使用企业电子邮件。默认为 `null`，表示没有限制。 |
| `downstream_pipeline_trigger_limit_per_project_user_sha` | integer | 否                            | [最大下游流水线触发速率](../administration/cicd/limits.md#limit-downstream-pipeline-trigger-rate)。默认值：`0`（无限制）。 |
| `dsa_key_restriction`                    | integer          | 否                                   | 上传的 DSA 密钥允许的最小位长度。默认为 `0`（无限制）。`-1` 禁用 DSA 密钥。 |
| `ecdsa_key_restriction`                  | integer          | 否                                   | 上传的 ECDSA 密钥允许的最小曲线大小（以位为单位）。默认为 `0`（无限制）。`-1` 禁用 ECDSA 密钥。 |
| `ecdsa_sk_key_restriction`               | integer          | 否                                   | 上传的 ECDSA_SK 密钥允许的最小曲线大小（以位为单位）。默认为 `0`（无限制）。`-1` 禁用 ECDSA_SK 密钥。 |
| `ed25519_key_restriction`                | integer          | 否                                   | 上传的 ED25519 密钥允许的最小曲线大小（以位为单位）。默认为 `0`（无限制）。`-1` 禁用 ED25519 密钥。 |
| `ed25519_sk_key_restriction`             | integer          | 否                                   | 上传的 ED25519_SK 密钥允许的最小曲线大小（以位为单位）。默认为 `0`（无限制）。`-1` 禁用 ED25519_SK 密钥。 |
| `eks_access_key_id`                      | string           | 否                                   | AWS IAM 访问密钥 ID。 |
| `eks_account_id`                         | string           | 否                                   | Amazon 账户 ID。 |
| `eks_integration_enabled`                | boolean          | 否                                   | 启用与 Amazon EKS 的集成。 |
| `eks_secret_access_key`                  | string           | 否                                   | AWS IAM 秘密访问密钥。 |
| `elasticsearch_aws_access_key`           | string           | 否                                   | AWS IAM 访问密钥。仅限专业版和旗舰版。 |
| `elasticsearch_aws_region`               | string           | 否                                   | 配置 Elasticsearch 域的 AWS 区域。仅限专业版和旗舰版。 |
| `elasticsearch_aws_secret_access_key`    | string           | 否                                   | AWS IAM 秘密访问密钥。仅限专业版和旗舰版。 |
| `elasticsearch_aws`                      | boolean          | 否                                   | 启用使用 AWS 托管的 Elasticsearch。仅限专业版和旗舰版。 |
| `elasticsearch_client_adapter`           | string           | 否                                   | Elasticsearch Ruby Client 使用的 Faraday 适配器。默认为 `typhoeus`。可能的值是 `typhoeus` 和 `net_http`。[引入](https://gitlab.com/gitlab-org/gitlab/-/issues/550805)于极狐GitLab 18.5。仅限专业版和旗舰版。 |
| `elasticsearch_indexed_field_length_limit` | integer        | 否                                   | Elasticsearch 索引的文本字段的最大大小。0 值表示无限制。这不适用于代码仓库和 Wiki 索引。仅限专业版和旗舰版。 |
| `elasticsearch_indexed_file_size_limit_kb` | integer        | 否                                   | Elasticsearch 索引的代码仓库和 Wiki 文件的最大大小。仅限专业版和旗舰版。 |
| `elasticsearch_indexing`                   | boolean        | 否                                   | 为高级搜索开启索引。仅限专业版和旗舰版。 |
| `elasticsearch_requeue_workers`            | boolean        | 否                                   | 启用索引工作进程的自动重新排队。这通过将 Sidekiq 作业入队直到所有文档都被处理来提高非代码索引吞吐量。仅限专业版和旗舰版。 |
| `elasticsearch_limit_indexing`             | boolean        | 否                                   | 限制 Elasticsearch 仅索引特定的命名空间和项目。仅限专业版和旗舰版。 |
| `elasticsearch_max_bulk_concurrency`       | integer        | 否                                   | 每次索引操作的 Elasticsearch 批量请求的最大并发数。这仅适用于代码仓库索引操作。仅限专业版和旗舰版。 |
| `elasticsearch_max_code_indexing_concurrency` | integer     | 否                                   | Elasticsearch 代码索引后台作业的最大并发数。这仅适用于代码仓库索引操作。仅限专业版和旗舰版。 |
| `elasticsearch_worker_number_of_shards`    | integer        | 否                                   | 索引工作进程分片数。这通过将更多并行 Sidekiq 作业入队来提高非代码索引吞吐量。默认为 `2`。仅限专业版和旗舰版。 |
| `elasticsearch_max_bulk_size_mb`           | integer        | 否                                   | Elasticsearch 批量索引请求的最大大小（以 MB 为单位）。这仅适用于代码仓库索引操作。仅限专业版和旗舰版。 |
| `elasticsearch_namespace_ids`              | array of integers | 否                                | 如果启用了 `elasticsearch_limit_indexing`，则通过 Elasticsearch 索引的命名空间。仅限专业版和旗舰版。 |
| `elasticsearch_project_ids`                | array of integers | 否                                | 如果启用了 `elasticsearch_limit_indexing`，则通过 Elasticsearch 索引的项目。仅限专业版和旗舰版。 |
| `elasticsearch_search`                     | boolean        | 否                                   | 启用 Elasticsearch 搜索。仅限专业版和旗舰版。 |
| `elasticsearch_url`                        | string or array of strings | 否                       | 用于连接 Elasticsearch 的 URL。使用逗号分隔的列表或数组来支持集群（例如，`http://localhost:9200, http://localhost:9201` 或 `["http://localhost:9200", "http://localhost:9201"]`）。仅限专业版和旗舰版。 |
| `elasticsearch_username`                   | string         | 否                                   | 您的 Elasticsearch 实例的 `username`。仅限专业版和旗舰版。 |
| `elasticsearch_password`                   | string         | 否                                   | 您的 Elasticsearch 实例的密码。仅限专业版和旗舰版。 |
| `elasticsearch_prefix`                     | string         | 否                                   | Elasticsearch 索引名称的自定义前缀。默认为 `gitlab`。必须为 1-100 个字符，仅包含小写字母数字字符、连字符和下划线，且不能以连字符或下划线开头或结尾。仅限专业版和旗舰版。 |
| `elasticsearch_retry_on_failure`           | integer        | 否                                   | Elasticsearch 搜索请求的最大可能重试次数。仅限专业版和旗舰版。 |
| `elasticsearch_shards`                     | integer or object | 是，如果 `elasticsearch_replicas` 定义为对象 | Elasticsearch 索引的分片数。使用整数将所有索引设置为相同的值。使用对象设置每个索引的值。例如：`{"gitlab-production": 5, "gitlab-production-notes": 3}`。<br>使用对象时，必须为每个索引提供 `elasticsearch_shards` 和 `elasticsearch_replicas`。如果某个索引缺少任一值，该索引将被跳过。仅限专业版和旗舰版。 |
| `elasticsearch_replicas`                   | integer or object | 是，如果 `elasticsearch_shards` 定义为对象 | Elasticsearch 索引的副本数。使用整数将所有索引设置为相同的值。使用对象设置每个索引的值。例如：`{"gitlab-production": 1, "gitlab-production-notes": 2}`。<br>使用对象时，必须为每个索引提供 `elasticsearch_shards` 和 `elasticsearch_replicas`。如果某个索引缺少任一值，该索引将被跳过。仅限专业版和旗舰版。 |
| `email_additional_text`                    | string         | 否                                   | 出于法律/审计/合规原因，添加到每封电子邮件底部的附加文本。仅限专业版和旗舰版。 |
| `email_author_in_body`                   | boolean          | 否                                   | 某些电子邮件服务器不支持覆盖电子邮件发件人名称。启用此选项可在电子邮件正文中包含议题、合并请求或评论作者的名字。 |
| `email_confirmation_setting`             | string           | 否                                   | 指定用户登录前是否必须确认其电子邮件。可能的值是 `off`、`soft` 和 `hard`。 |
| `email_otp_enabled`                      | boolean          | 否                                   | 启用基于电子邮件的一次性密码（OTP）作为多因素认证方法。默认禁用。要求 `require_email_verification_on_account_locked` 为 `true`。 |
| `custom_http_clone_url_root`             | string           | 否                                   | 为 HTTP(S) 设置自定义 Git 克隆 URL。 |
| `enabled_git_access_protocol`            | string           | 否                                   | 为 Git 访问启用的协议。允许的值为：`ssh`、`http` 和 `all` 以允许两种协议。 |
| `enforce_namespace_storage_limit`        | boolean          | 否                                   | 启用此选项允许强制执行命名空间存储限制。 |
| `enforce_terms`                          | boolean          | 否                                   | （**如果启用，则需要**：`terms`）对所有用户强制执行应用程序服务条款。 |
| `external_auth_client_cert`              | string           | 否                                   | （**如果启用，则需要**：`external_auth_client_key`）用于与外部授权服务进行认证的证书。 |
| `external_auth_client_key_pass`          | string           | 否                                   | 与外部服务认证时用于私钥的密码短语，存储时会加密。 |
| `external_auth_client_key`               | string           | 由以下项要求：`external_auth_client_cert` | 当外部授权服务需要认证时用于证书的私钥，存储时会加密。 |
| `external_authorization_service_default_label` | string     | 由以下项要求：<br>`external_authorization_service_enabled` | 请求授权且项目上未指定分类标签时使用的默认分类标签。 |
| `external_authorization_service_enabled`       | boolean    | 否                                   | （**如果启用，则需要**：`external_authorization_service_default_label`、`external_authorization_service_timeout` 和 `external_authorization_service_url`）启用使用外部授权服务来访问项目。 |
| `external_authorization_service_timeout`       | float      | 由以下项要求：<br>`external_authorization_service_enabled` | 授权请求中止前的超时时间（以秒为单位）。请求超时时，用户将被拒绝访问。（最小值：0.001，最大值：10，步长：0.001）。 |
| `external_authorization_service_url`           | string     | 由以下项要求：<br>`external_authorization_service_enabled` | 授权请求发送到的 URL。 |
| `external_pipeline_validation_service_url`     | string     | 否                                   | 用于流水线验证请求的 URL。 |
| `external_pipeline_validation_service_token`   | string     | 否                                   | 可选。在向 `external_pipeline_validation_service_url` 中的 URL 发起请求时，作为 `X-Gitlab-Token` 请求头包含的令牌。 |
| `external_pipeline_validation_service_timeout` | integer    | 否                                   | 等待流水线验证服务响应的时间。如果超时，则假定为 `OK`。 |
| `static_objects_external_storage_url`        | string       | 否                                   | 用于代码仓库静态对象的外部存储的 URL。 |
| `static_objects_external_storage_auth_token` | string       | 由以下项要求：`static_objects_external_storage_url` | 用于 `static_objects_external_storage_url` 中链接的外部存储的认证令牌。 |
| `failed_login_attempts_unlock_period_in_minutes` | integer  | 否                                   | 达到最大失败登录尝试次数后，用户被解锁的时间段（以分钟为单位）。 |
| `file_template_project_id`               | integer          | 否                                   | 从中加载自定义文件模板的项目的 ID。仅限专业版和旗舰版。 |
| `first_day_of_week`                      | integer          | 否                                   | 日历视图和日期选择器的每周开始日。有效值为 `0`（默认）表示星期日，`1` 表示星期一，`6` 表示星期六。 |
| `globally_allowed_ips`                   | string           | 否                                   | 始终允许入站流量的 IP 地址和 CIDR 的逗号分隔列表。例如，`1.1.1.1, 2.2.2.0/24`。 |
| `geo_node_allowed_ips`                   | string           | 是                                  | 允许的从节点的 IP 和 CIDR 的逗号分隔列表。例如，`1.1.1.1, 2.2.2.0/24`。仅限极狐GitLab 私有化部署、专业版和旗舰版。 |
| `geo_status_timeout`                     | integer          | 否                                   | 获取从节点状态的请求超时时间（以秒为单位）。仅限极狐GitLab 私有化部署、专业版和旗舰版。 |
| `git_two_factor_session_expiry`          | integer          | 否                                   | 启用 2FA 时，Git 操作会话的最长持续时间（以分钟为单位）。仅限专业版和旗舰版。 |
| `gitaly_timeout_default`                 | integer          | 否                                   | 默认 Gitaly 超时时间（以秒为单位）。此超时不适用于 Git fetch/push 操作或 Sidekiq 作业。设置为 `0` 可禁用超时。 |
| `gitaly_timeout_fast`                    | integer          | 否                                   | Gitaly 快速操作超时时间（以秒为单位）。某些 Gitaly 操作预期会很快完成。如果超过此阈值，则存储分片可能存在问题，“快速失败”有助于维持极狐GitLab 实例的稳定性。设置为 `0` 可禁用超时。 |
| `gitaly_timeout_medium`                  | integer          | 否                                   | 中等 Gitaly 超时时间（以秒为单位）。此值应介于快速超时和默认超时之间。设置为 `0` 可禁用超时。 |
| `gitlab_environment_toolkit_instance`    | boolean          | 否                                   | 指示实例是否使用 GitLab Environment Toolkit 进行预配，用于 Service Ping 报告。 |
| `gitlab_shell_operation_limit`           | integer          | 否                                   | 用户每分钟可执行的 Git 操作最大数量。默认值：`600`。 |
| `grafana_enabled`                        | boolean          | 否                                   | 启用 Grafana。 |
| `grafana_url`                            | string           | 否                                   | Grafana URL。 |
| `gravatar_enabled`                       | boolean          | 否                                   | 启用 Gravatar。 |
| `group_owners_can_manage_default_branch_protection` | boolean | 否                                 | 阻止覆盖默认分支保护。仅限极狐GitLab 私有化部署、专业版和旗舰版。 |
| `hashed_storage_enabled`                 | boolean          | 否                                   | 使用哈希存储路径创建新项目：启用不可变的、基于哈希的路径和代码仓库名称，以在磁盘上存储代码仓库。这可以防止在项目 URL 更改时移动或重命名代码仓库，并可能提高磁盘 I/O 性能。（在极狐GitLab 13.0 及更高版本中始终启用，配置计划在 14.0 中移除） |
| `help_page_hide_commercial_content`      | boolean          | 否                                   | 从帮助中隐藏营销相关条目。 |
| `help_page_support_url`                  | string           | 否                                   | 帮助页面和帮助下拉列表的备用支持 URL。 |
| `help_page_documentation_base_url`       | string           | 否                                   | 备用文档页面 URL。 |
| `help_page_text`                         | string           | 否                                   | 在帮助页面上显示的自定义文本。 |
| `hide_third_party_offers`                | boolean          | 否                                   | 不在极狐GitLab 中显示第三方优惠。 |
| `home_page_url`                          | string           | 否                                   | 未登录时重定向到此 URL。 |
| `housekeeping_bitmaps_enabled`           | boolean          | 否                                   | 已弃用。Git packfile 位图创建始终启用，无法通过 API 和 UI 更改。始终返回 `true`。 |
| `housekeeping_enabled`                   | boolean          | 否                                   | 启用或禁用 Git 维护。需要设置其他字段。 |
| `housekeeping_full_repack_period`        | integer          | 否                                   | 已弃用。运行增量 `git repack` 之前的 Git 推送次数。请改用 `housekeeping_optimize_repository_period`。 |
| `housekeeping_gc_period`                 | integer          | 否                                   | 已弃用。运行 `git gc` 之前的 Git 推送次数。请改用 `housekeeping_optimize_repository_period`。 |
| `housekeeping_incremental_repack_period` | integer          | 否                                   | 已弃用。运行增量 `git repack` 之前的 Git 推送次数。请改用 `housekeeping_optimize_repository_period`。 |
| `housekeeping_optimize_repository_period` | integer          | 否                                   | 运行增量 `git repack` 之前的 Git 推送次数。 |
| `html_emails_enabled`                    | boolean          | 否                                   | 启用 HTML 电子邮件。 |
| `import_sources`                         | array of strings | 否                                   | 允许从中导入项目的源，可能的值：`github`、`bitbucket`、`bitbucket_server`、`fogbugz`、`git`、`gitlab_project`、`gitea` 和 `manifest`。 |
| `invisible_captcha_enabled`              | boolean          | 否                                   | 在账户创建期间启用隐形 CAPTCHA 垃圾信息检测。默认禁用。 |
| `issues_create_limit`                    | integer          | 否                                   | 每个用户每分钟创建议题请求的最大数量。默认禁用。 |
| `jira_connect_application_key`           | string           | 否                                   | 用于与 GitLab for Jira Cloud 应用进行认证的 OAuth 应用程序的 ID。 |
| `jira_connect_public_key_storage_enabled` | boolean         | 否                                   | 为 GitLab for Jira Cloud 应用启用公钥存储。 |
| `jira_connect_proxy_url`                 | string           | 否                                   | 用作 GitLab for Jira Cloud 应用代理的极狐GitLab 实例的 URL。 |
| `keep_latest_artifact`                   | boolean          | 否                                   | 防止删除最近成功作业的产物，无论其过期时间如何。默认启用。 |
| `local_markdown_version`                 | integer          | 否                                   | 当任何缓存的 Markdown 应失效时，增加此值。 |
| `lock_memberships_to_saml`               | boolean          | 否                                   | 强制实施[SAML 群组成员资格的全局锁定](../user/group/saml_sso/group_sync.md#global-saml-group-memberships-lock)。 |
| `mailgun_signing_key`                    | string           | 否                                   | 用于从 webhook 接收事件的 Mailgun HTTP webhook 签名密钥。 |
| `mailgun_events_enabled`                 | boolean          | 否                                   | 启用 Mailgun 事件接收器。 |
| `maintenance_mode_message`               | string           | 否                                   | 实例处于维护模式时显示的消息。仅限专业版和旗舰版。 |
| `maintenance_mode`                       | boolean          | 否                                   | 当实例处于维护模式时，非管理员用户可以以只读访问权限登录并发出只读 API 请求。仅限专业版和旗舰版。 |
| `max_artifacts_size`                     | integer          | 否                                   | 最大产物大小（以 MB 为单位）。 |
| `max_attachment_size`                    | integer          | 否                                   | 限制附件大小（以 MB 为单位）。 |
| `max_decompressed_archive_size`          | integer          | 否                                   | 导入归档的最大解压文件大小（以 MB 为单位）。设置为 `0` 表示无限制。默认为 `25600`。 |
| `max_export_size`                        | integer          | 否                                   | 最大导出大小（以 MB 为单位）。0 表示无限制。默认 = 0（无限制）。 |
| `max_github_response_size_limit`         | integer          | 否                                   | 允许的最大 GitHub API 响应大小（以 MB 为单位）。0 表示无限制。 |
| `max_github_response_json_value_count`   | integer          | 否                                   | GitHub API 响应允许的最大值计数。0 表示无限制。计数是基于响应中 `:`、`,`、`{` 和 `[` 出现次数的估算值。 |
| `max_http_decompressed_size`             | integer          | 否                                   | 出站请求的 Gzip 压缩 HTTP 响应解压后允许的最大大小（以 MiB 为单位）。0 表示无限制。 |
| `max_http_response_json_depth`           | integer          | 否                                   | 出站请求的 JSON HTTP 响应中允许的最大嵌套深度。 |
| `max_http_response_json_structural_chars` | integer         | 否                                   | 出站请求的 JSON HTTP 响应中允许的最大对象数。计数是基于响应中 `:`、`,`、`{` 和 `[` 出现次数的估算值。于极狐GitLab 18.4 引入。 |
| `max_http_response_xml_structural_chars` | integer          | 否                                   | 出站请求的 XML HTTP 响应中允许的最大对象数。计数是基于响应中 `<` 和 `=` 出现次数的估算值。于极狐GitLab 18.4 引入。 |
| `max_http_response_csv_structural_chars` | integer          | 否                                   | 出站请求的 CSV HTTP 响应中允许的最大对象数。计数是基于响应中 `,`、`;`、`\t` 和 `\n` 出现次数的估算值。于极狐GitLab 18.4 引入。 |
| `max_http_response_size_limit`           | integer          | 否                                   | 出站请求的 HTTP 响应允许的最大大小（以 MiB 为单位）。0 表示无限制。适用于集成、导入器和 webhook。于极狐GitLab 18.4 引入。 |
| `max_import_size`                        | integer          | 否                                   | 最大导入大小（以 MB 为单位）。0 表示无限制。默认 = 0（无限制）。 |
| `max_import_remote_file_size`            | integer          | 否                                   | 从外部对象存储导入的最大远程文件大小。 |
| `max_login_attempts`                     | integer          | 否                                   | 锁定用户之前允许的最大登录尝试次数。 |
| `max_pages_size`                         | integer          | 否                                   | Pages 代码仓库的最大大小（以 MB 为单位）。 |
| `max_personal_access_token_lifetime`     | integer          | 否                                   | 访问令牌允许的最长生命周期（以天为单位）。留空时，应用默认值 365。设置时，值必须为 365 或更小。更改时，过期日期超过最大允许生命周期的现有访问令牌将被撤销。仅限极狐GitLab 私有化部署、旗舰版。在极狐GitLab 17.6 或更高版本中，可以通过启用名为 `buffered_token_expiration_limit` 的[功能标志](../administration/feature_flags/_index.md)将最大生命周期限制[延长至 400 天](https://gitlab.com/gitlab-org/gitlab/-/issues/461901)。 |
| `max_ssh_key_lifetime`                   | integer          | 否                                   | SSH 密钥允许的最长生命周期（以天为单位）。仅限极狐GitLab 私有化部署、旗舰版。在极狐GitLab 17.6 或更高版本中，可以通过启用名为 `buffered_token_expiration_limit` 的[功能标志](../administration/feature_flags/_index.md)将最大生命周期限制[延长至 400 天](https://gitlab.com/gitlab-org/gitlab/-/issues/461901)。 |
| `max_terraform_state_size_bytes`         | integer          | 否                                   | [Terraform 状态](../administration/terraform_state.md)文件的最大大小（以字节为单位）。将此设置为 0 表示文件大小无限制。 |
| `metrics_method_call_threshold`          | integer          | 否                                   | 仅当方法调用耗时超过给定毫秒数时才进行跟踪。 |
| `max_number_of_repository_downloads`     | integer          | 否                                   | 用户在指定时间段内可下载的唯一代码仓库的最大数量，超过后将被封禁。默认值：0，最大值：10,000 个代码仓库。仅限极狐GitLab 私有化部署、旗舰版。 |
| `max_number_of_repository_downloads_within_time_period` | integer | 否                             | 报告时间段（以秒为单位）。默认值：0，最大值：864000 秒（10 天）。仅限极狐GitLab 私有化部署、旗舰版。 |
| `max_yaml_depth`                         | integer          | 否                                   | 使用 [`include` 关键字](../ci/yaml/_index.md#include)添加的嵌套 CI/CD 配置的最大深度。默认值：`100`。 |
| `max_yaml_size_bytes`                    | integer          | 否                                   | 单个 CI/CD 配置文件的最大大小（以字节为单位）。默认值：`2097152`。 |
| `git_rate_limit_users_allowlist`         | array of strings  | 否                                  | 从 Git 反滥用速率限制中排除的用户名列表。默认值：`[]`，最大值：100 个用户名。仅限极狐GitLab 私有化部署、旗舰版。 |
| `git_rate_limit_users_alertlist`         | array of integers | 否                                  | 当 Git 滥用速率限制被超过时，通过电子邮件通知的用户 ID 列表。默认值：`[]`，最大值：100 个用户 ID。仅限极狐GitLab 私有化部署、旗舰版。 |
| `auto_ban_user_on_excessive_projects_download` | boolean    | 否                                   | 启用后，当用户在 `max_number_of_repository_downloads` 和 `max_number_of_repository_downloads_within_time_period` 指定的时间段内下载超过最大数量的唯一项目时，将被自动封禁。仅限极狐GitLab 私有化部署、旗舰版。 |
| `mirror_available`                       | boolean          | 否                                   | 允许项目维护者配置代码仓库镜像。如果禁用，只有管理员才能配置代码仓库镜像。 |
| `mirror_capacity_threshold`              | integer          | 否                                   | 在预先调度更多镜像之前需要可用的最小容量。仅限专业版和旗舰版。 |
| `mirror_max_capacity`                    | integer          | 否                                   | 可以同时同步的最大镜像数。仅限专业版和旗舰版。 |
| `mirror_max_delay`                       | integer          | 否                                   | 镜像在计划同步时，两次更新之间的最大时间（以分钟为单位）。仅限专业版和旗舰版。 |
| `maven_package_requests_forwarding`      | boolean          | 否                                   | 当在极狐GitLab 软件包仓库中找不到 Maven 软件包时，使用 repo.maven.apache.org 作为默认远程仓库。仅限专业版和旗舰版。 |
| `npm_package_requests_forwarding`        | boolean          | 否                                   | 当在极狐GitLab 软件包仓库中找不到 npm 软件包时，使用 npmjs.org 作为默认远程仓库。仅限专业版和旗舰版。 |
| `pypi_package_requests_forwarding`       | boolean          | 否                                   | 当在极狐GitLab 软件包仓库中找不到 PyPI 软件包时，使用 pypi.org 作为默认远程仓库。仅限专业版和旗舰版。 |
| `rubygems_package_requests_forwarding`   | boolean          | 否                                   | 当在极狐GitLab 软件包仓库中找不到 RubyGems 软件包时，使用 rubygems.org 作为默认远程仓库。仅限专业版和旗舰版。 |
| `oauth_access_token_expires_in`          | integer          | 否                                   | 实例签发的所有新 OAuth 访问令牌的最长生命周期（以秒为单位）。最小值：`300`（5 分钟）。默认值：`7200`（2 小时）。如果为空或 `null`，则使用默认值。不影响现有的 OAuth 访问令牌。 |
| `outbound_local_requests_whitelist`      | array of strings | 否                                   | 定义受信任的域名或 IP 地址列表，当 webhook 和集成的本地请求被禁用时，允许向这些地址发起本地请求。目前，此属性无法更新。有关详细信息，请参阅[议题 569729](https://gitlab.com/gitlab-org/gitlab/-/issues/569729)。 |
| `package_registry_allow_anyone_to_pull_option` | boolean    | 否                                   | 启用以[允许任何人从软件包仓库拉取](../user/packages/package_registry/_index.md#allow-anyone-to-pull-from-package-registry)可见和可更改。 |
| `package_metadata_purl_types`            | array of integers | 否                                  | [要同步的软件包仓库元数据](../administration/settings/security_and_compliance.md#choose-package-registry-metadata-to-sync)列表。请参阅[可用值列表](https://gitlab.com/gitlab-org/gitlab/-/blob/ace16c20d5da7c4928dd03fb139692638b557fe3/app/models/concerns/enums/package_metadata.rb#L5)。仅限极狐GitLab 私有化部署、旗舰版。 |
| `pages_domain_verification_enabled`       | boolean         | 否                                   | 要求用户证明自定义域名的所有权。域名验证是公共极狐GitLab 站点的重要安全措施。用户必须证明他们控制某个域名后，该域名才会被启用。 |
| `pages_unique_domain_default_enabled`    | boolean         | 否                                   | 默认情况下为 Pages 站点启用唯一域名，以避免给定命名空间下的站点之间共享 cookie。默认为 `true`。 |
| `password_authentication_enabled_for_git` | boolean         | 否                                   | 启用通过极狐GitLab 账户密码进行 HTTP(S) Git 认证。默认为 `true`。 |
| `password_authentication_enabled_for_web` | boolean         | 否                                   | 启用通过极狐GitLab 账户密码进行 Web 界面认证。默认为 `true`。 |
| `minimum_password_length`                | integer          | 否                                   | 指示密码是否需要最小长度。仅限专业版和旗舰版。 |
| `password_number_required`               | boolean          | 否                                   | 指示密码是否至少需要一个数字。仅限专业版和旗舰版。 |
| `password_symbol_required`               | boolean          | 否                                   | 指示密码是否至少需要一个符号字符。仅限专业版和旗舰版。 |
| `password_uppercase_required`            | boolean          | 否                                   | 指示密码是否至少需要一个大写字母。仅限专业版和旗舰版。 |
| `password_lowercase_required`            | boolean          | 否                                   | 指示密码是否至少需要一个小写字母。仅限专业版和旗舰版。 |
| `performance_bar_allowed_group_id`       | string           | 否                                   | （已弃用：请改用 `performance_bar_allowed_group_path`）允许切换性能栏的群组的路径。 |
| `performance_bar_allowed_group_path`     | string           | 否                                   | 允许切换性能栏的群组的路径。 |
| `performance_bar_enabled`                | boolean          | 否                                   | （已弃用：请改为传递 `performance_bar_allowed_group_path: nil`）允许启用性能栏。 |
| `personal_access_token_prefix`           | string           | 否                                   | 所有生成的个人访问令牌的前缀。 |
| `pipeline_limit_per_project_user_sha`    | integer          | 否                                   | 每个用户和提交每分钟创建流水线请求的最大数量。默认禁用。 |
| `pipeline_limit_per_user`                | integer          | 否                                   | 每个用户每分钟创建流水线请求的最大数量。 |
| `ci_lint_limit_per_user`                 | integer          | 否                                   | 每个用户每分钟 CI Lint 请求的最大数量。默认禁用。 |
| `gitpod_enabled`                         | boolean          | 否                                   | （**如果启用，则需要**：`gitpod_url`）启用 [Ona 集成](../integration/gitpod.md)。默认为 `false`。 |
| `gitpod_url`                             | string           | 由以下项要求：`gitpod_enabled`      | 用于集成的 Ona 实例 URL。 |
| `inactive_resource_access_tokens_delete_after_days` | integer | 否                                   | 指定不活跃的项目和群组访问令牌的保留期。默认为 `30`。 |
| `kroki_enabled`                          | boolean          | 否                                   | （**如果启用，则需要**：`kroki_url`）启用 [Kroki 集成](../administration/integration/kroki.md)。默认为 `false`。 |
| `kroki_url`                              | string           | 由以下项要求：`kroki_enabled`       | 用于集成的 Kroki 实例 URL。 |
| `kroki_formats`                          | object           | 否                                   | Kroki 实例支持的附加格式。对于格式 `bpmn`、`blockdiag`、`excalidraw` 和 `mermaid`，可能的值是 `true` 或 `false`，格式为 `<format>: true` 或 `<format>: false`。 |
| `kroki_diagram_proxy_enabled`            | boolean          | 否                                   | 启用 [Kroki 图表代理](../administration/integration/diagram_proxy.md)。默认为 `false`。 |
| `plantuml_enabled`                       | boolean          | 否                                   | （**如果启用，则需要**：`plantuml_url`）启用 [PlantUML 集成](../administration/integration/plantuml.md)。默认为 `false`。 |
| `plantuml_url`                           | string           | 由以下项要求：`plantuml_enabled`    | 用于集成的 PlantUML 实例 URL。 |
| `plantuml_diagram_proxy_enabled`         | boolean          | 否                                   | 启用 [PlantUML 图表代理](../administration/integration/diagram_proxy.md)。默认为 `false`。 |
| `polling_interval_multiplier`            | float            | 否                                   | 执行轮询的端点使用的间隔乘数。设置为 `0` 可禁用轮询。 |
| `project_export_enabled`                 | boolean          | 否                                   | 启用项目导出。 |
| `project_jobs_api_rate_limit`            | integer          | 否                                   | 每分钟对 `/project/:id/jobs` 的已认证请求的最大数量。默认值：600。 |
| `projects_api_rate_limit_unauthenticated` | integer         | 否                                   | 对[列出所有项目 API](projects.md#list-all-projects)的未认证请求，每个 IP 地址每 10 分钟的最大请求数。默认值：400。要禁用限流，请设置为 0。 |
| `runner_jobs_request_api_limit`          | integer          | 否                                   | 对 `/jobs/request` Runner 作业 API 端点的请求，每个 Runner 令牌每分钟的最大请求数。默认值：2000。要禁用限流，请设置为 0。[引入](https://gitlab.com/gitlab-org/gitlab/-/issues/462537)于极狐GitLab 18.5。 |
| `runner_jobs_patch_trace_api_limit`      | integer          | 否                                   | 对 `PATCH /jobs/:id/trace` Runner 作业 API 端点的请求，每个 Runner 令牌每分钟的最大请求数。默认值：2000。要禁用限流，请设置为 0。[引入](https://gitlab.com/gitlab-org/gitlab/-/issues/462537)于极狐GitLab 18.5。 |
| `runner_jobs_endpoints_api_limit`        | integer          | 否                                   | 对 `/jobs/*` Runner 作业 API 端点的请求，每个作业令牌每分钟的最大请求数。默认值：200。要禁用限流，请设置为 0。[引入](https://gitlab.com/gitlab-org/gitlab/-/issues/462537)于极狐GitLab 18.5。 |
| `users_api_limit_following` | integer |    否    | 每个用户或 IP 地址每分钟的最大请求数。默认值：100。设置为 `0` 可禁用限制。[引入](https://gitlab.com/gitlab-org/gitlab/-/merge_requests/181054)于极狐GitLab 17.10。 |
| `users_api_limit_followers` | integer |    否    | 每个用户或 IP 地址每分钟的最大请求数。默认值：100。设置为 `0` 可禁用限制。[引入](https://gitlab.com/gitlab-org/gitlab/-/merge_requests/181054)于极狐GitLab 17.10。 |
| `users_api_limit_status`    | integer |    否    | 每个用户或 IP 地址每分钟的最大请求数。默认值：240。设置为 `0` 可禁用限制。[引入](https://gitlab.com/gitlab-org/gitlab/-/merge_requests/181054)于极狐GitLab 17.10。 |
| `users_api_limit_keys`      | integer |    否    | 每个用户或 IP 地址每分钟的最大请求数。默认值：120。设置为 `0` 可禁用限制。[引入](https://gitlab.com/gitlab-org/gitlab/-/merge_requests/181054)于极狐GitLab 17.10。 |
| `users_api_limit_key`       | integer |    否    | 每个用户或 IP 地址每分钟的最大请求数。默认值：120。设置为 `0` 可禁用限制。[引入](https://gitlab.com/gitlab-org/gitlab/-/merge_requests/181054)于极狐GitLab 17.10。 |
| `users_api_limit_gpg_keys`  | integer |    否    | 每个用户或 IP 地址每分钟的最大请求数。默认值：120。设置为 `0` 可禁用限制。[引入](https://gitlab.com/gitlab-org/gitlab/-/merge_requests/181054)于极狐GitLab 17.10。 |
| `users_api_limit_gpg_key`   | integer |    否    | 每个用户或 IP 地址每分钟的最大请求数。默认值：120。设置为 `0` 可禁用限制。[引入](https://gitlab.com/gitlab-org/gitlab/-/merge_requests/181054)于极狐GitLab 17.10。 |
| `virtual_registries_endpoints_api_limit`          | integer          | 否                                   | 每个 IP 地址每 15 秒在虚拟仓库端点上的最大请求数。默认值：4000。要禁用限制，请设置为 `0`。[引入](https://gitlab.com/gitlab-org/gitlab/-/issues/521692)于极狐GitLab 17.11。 |
| `project_secrets_limit`                           | integer          | 否                                   | Secrets Manager 中每个项目允许的最大密钥数。默认值：100。要禁用限制，请设置为 `0`。仅限旗舰版。[引入](https://gitlab.com/gitlab-org/gitlab/-/merge_requests/219436)于极狐GitLab 18.9。 |
| `group_secrets_limit`                             | integer          | 否                                   | Secrets Manager 中每个群组允许的最大密钥数。默认值：500。要禁用限制，请设置为 `0`。仅限旗舰版。[引入](https://gitlab.com/gitlab-org/gitlab/-/merge_requests/219436)于极狐GitLab 18.9。 |
| `prometheus_metrics_enabled`             | boolean          | 否                                   | 启用 Prometheus 指标。 |
| `protected_ci_variables`                 | boolean          | 否                                   | CI/CD 变量默认受保护。 |
| `disable_overriding_approvers_per_merge_request` | boolean  | 否                                   | 防止在项目和合并请求中编辑审批规则 |
| `prevent_merge_requests_author_approval`         | boolean  | 否                                   | 防止合并请求创建者（作者）进行审批 |
| `prevent_merge_requests_committers_approval`     | boolean  | 否                                   | 防止合并请求的提交者进行审批 |
| `push_event_activities_limit`            | integer          | 否                                   | 单次推送中更改（分支或标签）的最大数量，超过该数量将[创建批量推送事件](../administration/settings/push_event_activities_limit.md)。设置为 `0` 不会禁用节流。 |
| `push_event_hooks_limit`                 | integer          | 否                                   | 单次推送中更改（分支或标签）的最大数量，超过该数量将不触发 Webhook 和集成。设置为 `0` 不会禁用节流。默认值：`3`。 |
| `rate_limiting_response_text`            | string           | 否                                   | 当通过 `throttle_*` 设置启用速率限制时，在超过速率限制时发送此纯文本响应。如果此项为空，则发送“稍后重试”。 |
| `raw_blob_request_limit`                 | integer          | 否                                   | 每个原始路径每分钟的最大请求数（默认值为 `300`）。设置为 `0` 可禁用节流。 |
| `raw_blob_request_limit_unauthenticated` | integer          | 否                                   | 项目中所有原始路径每分钟的未认证请求最大数量（默认值为 `800`）。设置为 `0` 可禁用节流。 |
| `search_rate_limit`                      | integer          | 否                                   | 认证状态下每分钟执行搜索的最大请求数。默认值：30。要禁用节流，请设置为 0。 |
| `search_rate_limit_unauthenticated`      | integer          | 否                                   | 未认证状态下每分钟执行搜索的最大请求数。默认值：10。要禁用节流，请设置为 0。 |
| `recaptcha_enabled`                      | boolean          | 否                                   | （**如果启用，则需要**：`recaptcha_private_key` 和 `recaptcha_site_key`）启用 reCAPTCHA。 |
| `login_recaptcha_protection_enabled`     | boolean          | 否                                   | 为登录启用 reCAPTCHA。 |
| `recaptcha_private_key`                  | string           | 由以下项要求：`recaptcha_enabled`     | reCAPTCHA 的私钥。 |
| `recaptcha_site_key`                     | string           | 由以下项要求：`recaptcha_enabled`     | reCAPTCHA 的站点密钥。 |
| `receptive_cluster_agents_enabled`       | boolean          | 否                                   | 为 Kubernetes 的极狐GitLab Agent 启用接收模式。 |
| `receive_max_input_size`                 | integer          | 否                                   | 最大推送大小（MB）。 |
| `relation_export_batch_size`             | integer          | 否                                   | 导出批量关系时每批的大小。[引入](https://gitlab.com/gitlab-org/gitlab/-/merge_requests/194607)于极狐GitLab 18.2。 |
| `remember_me_enabled`                    | boolean          | 否                                   | 启用[**记住我**设置](../administration/settings/account_and_limit_settings.md#configure-the-remember-me-option)。 |
| `repository_checks_enabled`              | boolean          | 否                                   | 极狐GitLab 定期在所有项目和 Wiki 代码仓库中运行 `git fsck`，以查找静默磁盘损坏问题。 |
| `repository_size_limit`                  | integer          | 否                                   | 每个代码仓库的大小限制（MB）。仅限专业版和旗舰版。 |
| `repository_storages_weighted`           | hash of strings to integers | 否                        | 取自 `gitlab.yml` 的名称哈希，对应[权重](../administration/repository_storage_paths.md#configure-where-new-repositories-are-stored)。新项目将在这些存储中创建，通过加权随机选择确定。 |
| `require_admin_approval_after_user_signup` | boolean        | 否                                   | 启用后，任何使用注册表单注册账户的用户都将处于**待审批**状态，必须由管理员明确[批准](../administration/moderate_users.md)。 |
| `require_email_verification_on_account_locked` | boolean    | 否                                   | 如果为 `true`，则在检测到可疑登录活动后，实例上的所有用户都必须验证其身份。 |
| `require_personal_access_token_expiry`   | boolean          | 否                                   | 启用后，用户在创建群组或项目访问令牌，或创建非服务账号拥有的个人访问令牌时，必须设置过期日期。 |
| `require_sha_for_merge`                  | boolean          | 否                                   | 实例默认设置，要求调用[合并合并请求](merge_requests.md#merge-a-merge-request)端点时提供有效的提交 `sha`。[引入](https://gitlab.com/gitlab-org/gitlab/-/merge_requests/236732)于极狐GitLab 19.2。 |
| `lock_require_sha_for_merge`             | boolean          | 否                                   | 对实例上的所有群组强制执行 `require_sha_for_merge` 设置。[引入](https://gitlab.com/gitlab-org/gitlab/-/merge_requests/236732)于极狐GitLab 19.2。 |
| `require_two_factor_authentication`      | boolean          | 否                                   | （**如果启用，则需要**：`two_factor_grace_period`）要求所有用户设置双因素认证。 |
| `resource_usage_limits`                | hash             | 否                                   | 在 Sidekiq 工作进程中强制执行的资源使用限制定义。此设置仅适用于 JihuLab.com。 |
| `restricted_visibility_levels`           | array of strings | 否                                   | 非管理员用户不能为群组、项目或代码片段选择这些级别。可接受 `private`、`internal` 和 `public` 作为参数。默认值为 `null`，表示没有限制。不能选择已设置为 `default_project_visibility` 和 `default_group_visibility` 的级别。 |
| `rsa_key_restriction`                    | integer          | 否                                   | 上传的 RSA 密钥允许的最小位长度。默认值为 `0`（无限制）。`-1` 禁用 RSA 密钥。 |
| `session_expire_delay`                   | integer          | 否                                   | 会话持续时间（分钟）。应用更改需要重启极狐GitLab。 |
| `session_expire_from_init`               | boolean          | 否                                   | 如果为 `true`，会话将在创建后的若干分钟后过期，而不是在最后一次活动后过期。此会话的生命周期由 `session_expire_delay` 定义。 |
| `security_policy_global_group_approvers_enabled` | boolean  | 否                                   | 是否在全局或项目层级内查找合并请求审批策略的审批群组。 |
| `security_approval_policies_limit`       | integer          | 否                                   | 每个安全策略项目允许的最大活动合并请求审批策略数。默认值：5。最大值：20 |
| `scan_execution_policies_action_limit`   | integer          | 否                                   | 每个扫描执行策略允许的最大 `actions` 数量。默认值：0。最大值：20 |
| `scan_execution_policies_schedule_limit` | integer          | 否                                   | 每个扫描执行策略允许的最大 `type: schedule` 规则数。默认值：0。最大值：20 |
| `security_txt_content`                    | string          | 否                                   | [公开安全联系信息](../administration/settings/security_contact_information.md)。 |
| `security_mr_report_cache_lifetime_minutes` | integer       | 否                                   | 在合并请求上缓存安全报告的分钟数（10-60）。默认值：10。仅限专业版和旗舰版。[引入](https://gitlab.com/gitlab-org/gitlab/-/merge_requests/223399)于极狐GitLab 18.10。 |
| `security_scan_stale_after_days`          | integer          | 否                                   | 清除前保留安全扫描数据的天数。必须在 7 到 90 天之间。默认值：JihuLab.com 为 30 天，极狐GitLab 私有化部署为 90 天。仅限专业版和旗舰版。[引入](https://gitlab.com/gitlab-org/gitlab/-/merge_requests/222998)于极狐GitLab 18.9。 |
| `service_access_tokens_expiration_enforced` | boolean       | 否                                   | 指示服务账号用户的令牌过期日期是否可以为可选项的标志。仅限专业版和旗舰版。 |
| `shared_runners_enabled`                 | boolean          | 否                                   | （**如果启用，则需要**：`shared_runners_text` 和 `shared_runners_minutes`）为新项目启用实例 Runner。 |
| `shared_runners_minutes`                 | integer          | 由以下项要求：`shared_runners_enabled` | 设置群组每月可在实例 Runner 上使用的最大计算分钟数。仅限专业版和旗舰版。 |
| `shared_runners_text`                    | string           | 由以下项要求：`shared_runners_enabled` | 实例 Runner 文本。 |
| `runner_token_expiration_interval`         | integer        | 否                                   | 设置新注册的实例 Runner 认证令牌的过期时间（秒）。最小值为 7200 秒。更多信息，请参阅[自动轮换认证令牌](../ci/runners/configure_runners.md#automatically-rotate-runner-authentication-tokens)。 |
| `group_runner_token_expiration_interval`   | integer        | 否                                   | 设置新注册的群组 Runner 认证令牌的过期时间（秒）。最小值为 7200 秒。更多信息，请参阅[自动轮换认证令牌](../ci/runners/configure_runners.md#automatically-rotate-runner-authentication-tokens)。 |
| `project_runner_token_expiration_interval` | integer        | 否                                   | 设置新注册的项目 Runner 认证令牌的过期时间（秒）。最小值为 7200 秒。更多信息，请参阅[自动轮换认证令牌](../ci/runners/configure_runners.md#automatically-rotate-runner-authentication-tokens)。 |
| `sidekiq_job_limiter_mode`                        | string  | 否                                   | `track` 或 `compress`。设置 [Sidekiq 作业大小限制](../administration/settings/sidekiq.md)的行为。默认值：'compress'。 |
| `sidekiq_job_limiter_compression_threshold_bytes` | integer | 否                                   | Sidekiq 作业在存储到 Redis 之前进行压缩的字节阈值。默认值：100,000 字节（100 KB）。 |
| `sidekiq_job_limiter_limit_bytes`                 | integer | 否                                   | 拒绝 Sidekiq 作业的字节阈值。默认值：0 字节（不拒绝任何作业）。 |
| `sidekiq_timezone_override`               | string           | 否                                   | 应用于所有 Sidekiq 定时作业的 IANA 时区标识符（例如，`America/Chicago`）。留空时不应用任何覆盖，定时作业将使用 Rails 应用程序时区。 |
| `signin_enabled`                         | string           | 否                                   | （已弃用：请改用 `password_authentication_enabled_for_web`）指示 Web 界面是否启用密码认证的标志。 |
| `sign_in_restrictions`                   | hash             | 否                                   | 应用程序登录限制。 |
| `signup_enabled`                         | boolean          | 否                                   | 启用注册。默认值为 `true`。 |
| `silent_admin_exports_enabled`           | boolean          | 否                                   | 启用[静默管理员导出](../administration/settings/import_and_export_settings.md#enable-silent-admin-exports)。默认值为 `false`。 |
| `silent_mode_enabled`                    | boolean          | 否                                   | 启用[静默模式](../administration/silent_mode/_index.md)。默认值为 `false`。 |
| `slack_app_enabled`                      | boolean          | 否                                   | （**如果启用，则需要**：`slack_app_id`、`slack_app_secret`、`slack_app_signing_secret` 和 `slack_app_verification_token`）启用 GitLab for Slack 应用。 |
| `slack_app_id`                           | string           | 由以下项要求：`slack_app_enabled`     | GitLab for Slack 应用的客户端 ID。 |
| `slack_app_secret`                       | string           | 由以下项要求：`slack_app_enabled`     | GitLab for Slack 应用的客户端密钥。用于认证来自应用的 OAuth 请求。 |
| `slack_app_signing_secret`               | string           | 由以下项要求：`slack_app_enabled`     | GitLab for Slack 应用的签名密钥。用于认证来自应用的 API 请求。 |
| `slack_app_verification_token`           | string           | 由以下项要求：`slack_app_enabled`     | GitLab for Slack 应用的验证令牌。此认证方法已被 Slack 弃用，仅用于认证来自应用的斜杠命令。 |
| `snippet_size_limit`                     | integer          | 否                                   | 代码片段内容的最大大小（**字节**）。默认值：52428800 字节（50 MB）。 |
| `snowplow_app_id`                        | string           | 否                                   | Snowplow 站点名称 / 应用程序 ID。（例如，`gitlab`） |
| `snowplow_collector_hostname`            | string           | 由以下项要求：`snowplow_enabled`      | Snowplow 收集器主机名。（例如，`snowplowprd.trx.gitlab.net`） |
| `snowplow_database_collector_hostname`   | string           | 否                                   | 用于数据库事件的 Snowplow 收集器主机名。（例如，`db-snowplow.trx.gitlab.net`） |
| `snowplow_cookie_domain`                 | string           | 否                                   | Snowplow Cookie 域。（例如，`.gitlab.com`） |
| `snowplow_enabled`                       | boolean          | 否                                   | 启用 Snowplow 跟踪。 |
| `sourcegraph_enabled`                    | boolean          | 否                                   | 启用 Sourcegraph 集成。默认值为 `false`。**如果启用，则需要** `sourcegraph_url`。 |
| `sourcegraph_public_only`                | boolean          | 否                                   | 阻止 Sourcegraph 在私有和内部项目中加载。默认值为 `true`。 |
| `sourcegraph_url`                        | string           | 由以下项要求：`sourcegraph_enabled`   | 用于集成的 Sourcegraph 实例 URL。 |
| `spam_check_endpoint_enabled`            | boolean          | 否                                   | 启用使用外部 Spam Check API 端点进行垃圾邮件检查。默认值为 `false`。 |
| `spam_check_endpoint_url`                | string           | 否                                   | 外部 Spamcheck 服务端点的 URL。有效的 URI 方案为 `grpc` 或 `tls`。指定 `tls` 将强制通信加密。 |
| `spam_check_api_key`                     | string           | 否                                   | 极狐GitLab 用于访问 Spam Check 服务端点的 API 密钥。 |
| `enable_artifact_external_redirect_warning_page` | boolean  | 否                                   | 显示外部重定向页面，警告您 GitLab Pages 中的用户生成内容。 |
| `terminal_max_session_time`              | integer          | 否                                   | Web 终端 WebSocket 连接的最长时间（秒）。设置为 `0` 表示无限时间。 |
| `terms`                                  | text             | 由以下项要求：`enforce_terms`         | （**由以下项要求**：`enforce_terms`）服务条款的 Markdown 内容。 |
| `throttle_authenticated_api_enabled`                      | boolean | 否                                                              | （**如果启用，则需要**：`throttle_authenticated_api_period_in_seconds` 和 `throttle_authenticated_api_requests_per_period`）启用已认证 API 请求速率限制。有助于减少请求量（例如，来自爬虫或恶意机器人）。 |
| `throttle_authenticated_api_period_in_seconds`            | integer | 由以下项要求：<br>`throttle_authenticated_api_enabled`            | 速率限制周期（秒）。 |
| `throttle_authenticated_api_requests_per_period`          | integer | 由以下项要求：<br>`throttle_authenticated_api_enabled`            | 每个用户每个周期的最大请求数。 |
| `throttle_authenticated_git_http_enabled`             | boolean | 条件性 | 如果为 `true`，则强制执行已认证 Git HTTP 请求速率限制。默认值：`false`。 |
| `throttle_authenticated_git_http_period_in_seconds`   | integer | 否            | 速率限制周期（秒）。`throttle_authenticated_git_http_enabled` 必须为 `true`。默认值：`3600`。 |
| `throttle_authenticated_git_http_requests_per_period` | integer | 否            | 每个用户每个周期的最大请求数。`throttle_authenticated_git_http_enabled` 必须为 `true`。默认值：`3600`。 |
| `throttle_authenticated_packages_api_enabled`             | boolean | 否                                                              | （**如果启用，则需要**：`throttle_authenticated_packages_api_period_in_seconds` 和 `throttle_authenticated_packages_api_requests_per_period`）启用已认证 API 请求速率限制。有助于减少请求量（例如，来自爬虫或恶意机器人）。查看[软件包仓库速率限制](../rate_limits/api/package-registry.md)了解更多详情。 |
| `throttle_authenticated_packages_api_period_in_seconds`   | integer | 由以下项要求：<br>`throttle_authenticated_packages_api_enabled`   | 速率限制周期（秒）。查看[软件包仓库速率限制](../rate_limits/api/package-registry.md)了解更多详情。 |
| `throttle_authenticated_packages_api_requests_per_period` | integer | 由以下项要求：<br>`throttle_authenticated_packages_api_enabled`   | 每个用户每个周期的最大请求数。查看[软件包仓库速率限制](../rate_limits/api/package-registry.md)了解更多详情。 |
| `throttle_authenticated_web_enabled`                      | boolean | 否                                                              | （**如果启用，则需要**：`throttle_authenticated_web_period_in_seconds` 和 `throttle_authenticated_web_requests_per_period`）启用已认证 Web 请求速率限制。有助于减少请求量（例如，来自爬虫或恶意机器人）。 |
| `throttle_authenticated_web_period_in_seconds`            | integer | 由以下项要求：<br>`throttle_authenticated_web_enabled`            | 速率限制周期（秒）。 |
| `throttle_authenticated_web_requests_per_period`          | integer | 由以下项要求：<br>`throttle_authenticated_web_enabled`            | 每个用户每个周期的最大请求数。 |
| `throttle_unauthenticated_enabled`                        | boolean | 否                                                              | （[已弃用](https://gitlab.com/gitlab-org/gitlab/-/issues/335300)于极狐GitLab 14.3。请改用 `throttle_unauthenticated_web_enabled` 或 `throttle_unauthenticated_api_enabled`。）（**如果启用，则需要**：`throttle_unauthenticated_period_in_seconds` 和 `throttle_unauthenticated_requests_per_period`）启用未认证 Web 请求速率限制。有助于减少请求量（例如，来自爬虫或恶意机器人）。 |
| `throttle_unauthenticated_period_in_seconds`              | integer | 由以下项要求：<br>`throttle_unauthenticated_enabled`              | （[已弃用](https://gitlab.com/gitlab-org/gitlab/-/issues/335300)于极狐GitLab 14.3。请改用 `throttle_unauthenticated_web_period_in_seconds` 或 `throttle_unauthenticated_api_period_in_seconds`。）速率限制周期（秒）。 |
| `throttle_unauthenticated_requests_per_period`            | integer | 由以下项要求：<br>`throttle_unauthenticated_enabled`              | （[已弃用](https://gitlab.com/gitlab-org/gitlab/-/issues/335300)于极狐GitLab 14.3。请改用 `throttle_unauthenticated_web_requests_per_period` 或 `throttle_unauthenticated_api_requests_per_period`。）每个 IP 每个周期的最大请求数。 |
| `throttle_unauthenticated_api_enabled`                    | boolean | 否                                                              | （**如果启用，则需要**：`throttle_unauthenticated_api_period_in_seconds` 和 `throttle_unauthenticated_api_requests_per_period`）启用未认证 API 请求速率限制。有助于减少请求量（例如，来自爬虫或恶意机器人）。 |
| `throttle_unauthenticated_api_period_in_seconds`          | integer | 由以下项要求：<br>`throttle_unauthenticated_api_enabled`          | 速率限制周期（秒）。 |
| `throttle_unauthenticated_api_requests_per_period`        | integer | 由以下项要求：<br>`throttle_unauthenticated_api_enabled`          | 每个 IP 每个周期的最大请求数。 |
| `throttle_unauthenticated_git_http_enabled`             | boolean | 条件性 | 如果为 `true`，则强制执行未认证 Git HTTP 请求速率限制。默认值：`false`。 |
| `throttle_unauthenticated_git_http_period_in_seconds`   | integer | 否            | 速率限制周期（秒）。`throttle_unauthenticated_git_http_enabled` 必须为 `true`。默认值：`3600`。 |
| `throttle_unauthenticated_git_http_requests_per_period` | integer | 否            | 每个 IP 每个周期的最大请求数。`throttle_unauthenticated_git_http_enabled` 必须为 `true`。默认值：`3600`。 |
| `throttle_unauthenticated_packages_api_enabled`           | boolean | 否                                                              | （**如果启用，则需要**：`throttle_unauthenticated_packages_api_period_in_seconds` 和 `throttle_unauthenticated_packages_api_requests_per_period`）启用未认证 API 请求速率限制。有助于减少请求量（例如，来自爬虫或恶意机器人）。查看[软件包仓库速率限制](../rate_limits/api/package-registry.md)了解更多详情。 |
| `throttle_unauthenticated_packages_api_period_in_seconds` | integer | 由以下项要求：<br>`throttle_unauthenticated_packages_api_enabled` | 速率限制周期（秒）。查看[软件包仓库速率限制](../rate_limits/api/package-registry.md)了解更多详情。 |
| `throttle_unauthenticated_packages_api_requests_per_period` | integer | 由以下项要求：<br>`throttle_unauthenticated_packages_api_enabled` | 每个用户每个周期的最大请求数。查看[软件包仓库速率限制](../rate_limits/api/package-registry.md)了解更多详情。 |
| `throttle_unauthenticated_web_enabled`                    | boolean | 否                                                              | （**如果启用，则需要**：`throttle_unauthenticated_web_period_in_seconds` 和 `throttle_unauthenticated_web_requests_per_period`）启用未认证 Web 请求速率限制。有助于减少请求量（例如，来自爬虫或恶意机器人）。 |
| `throttle_unauthenticated_web_period_in_seconds`          | integer | 由以下项要求：<br>`throttle_unauthenticated_web_enabled`          | 速率限制周期（秒）。 |
| `throttle_unauthenticated_web_requests_per_period`        | integer | 由以下项要求：<br>`throttle_unauthenticated_web_enabled`          | 每个 IP 每个周期的最大请求数。 |
| `time_tracking_limit_to_hours`           | boolean          | 否                                   | 将时间跟踪单位的显示限制为小时。默认值为 `false`。 |
| `top_level_group_creation_enabled`           | boolean          | 否                                   | 允许用户创建顶级群组。默认值为 `true`。 |
| `two_factor_grace_period`                | integer          | 由以下项要求：`require_two_factor_authentication` | 允许用户跳过强制配置双因素认证的时间量（小时）。 |
| `unconfirmed_users_delete_after_days`    | integer          | 否                                   | 指定账户创建后多少天删除未确认电子邮件的用户。仅当 `delete_unconfirmed_users` 设置为 `true` 时适用。必须为 `1` 或更大。默认值为 `7`。仅限极狐GitLab 私有化部署、专业版和旗舰版。 |
| `unique_ips_limit_enabled`               | boolean          | 否                                   | （**如果启用，则需要**：`unique_ips_limit_per_user` 和 `unique_ips_limit_time_window`）限制从多个 IP 登录。 |
| `unique_ips_limit_per_user`              | integer          | 由以下项要求：`unique_ips_limit_enabled` | 每个用户的最大 IP 数。 |
| `unique_ips_limit_time_window`           | integer          | 由以下项要求：`unique_ips_limit_enabled` | 一个 IP 被计入限制的秒数。 |
| `update_runner_versions_enabled`         | boolean          | 否                                   | 从 JihuLab.com 获取极狐GitLab Runner 发布版本数据。更多信息，请参阅如何[确定哪些 Runner 需要升级](../ci/runners/runners_scope.md#determine-which-runners-need-to-be-upgraded)。 |
| `usage_ping_enabled`                     | boolean          | 否                                   | 每周极狐GitLab 向 GitLab, Inc. 报告许可证使用情况。 |
| `gitlab_product_usage_data_enabled`      | boolean          | 否                                   | 指示是否启用产品使用数据收集。当设置了 `GITLAB_PRODUCT_USAGE_DATA_ENABLED` 环境变量时，API 返回环境变量中的有效值。 |
| `gitlab_product_usage_data_source`       | string           | 否                                   | 只读。指示 `gitlab_product_usage_data_enabled` 设置的来源。如果设置了 `GITLAB_PRODUCT_USAGE_DATA_ENABLED` 环境变量，则返回 `environment`，否则返回 `database`。 |
| `use_clickhouse_for_analytics`           | boolean          | 否                                   | 启用 ClickHouse 作为分析报告的数据源。必须配置 ClickHouse 才能使此设置生效。仅限专业版和旗舰版。 |
| `use_nats_for_audit_streaming`           | boolean          | 否                                   | 通过 NATS JetStream 路由审计事件流。必须配置 NATS 才能使此设置生效。仅限专业版和旗舰版。 |
| `include_optional_metrics_in_service_ping` | boolean         | 否                                   | Service Ping 中是否启用可选指标。 |
| `user_deactivation_emails_enabled`       | boolean          | 否                                   | 账户停用时向用户发送电子邮件。 |
| `user_default_external`                  | boolean          | 否                                   | 新注册用户默认为外部用户。 |
| `user_default_internal_regex`            | string           | 否                                   | 指定电子邮件地址正则表达式模式以识别默认内部用户。 |
| `user_defaults_to_private_profile`       | boolean          | 否                                   | 新创建的用户默认拥有私有个人资料。默认为 `false`。 |
| `user_oauth_applications`                | boolean          | 否                                   | 允许用户注册任何应用程序以使用极狐GitLab 作为 OAuth 提供方。此设置不影响群组级 OAuth 应用程序。 |
| `user_show_add_ssh_key_message`          | boolean          | 否                                   | 当设置为 `false` 时，禁用向未上传 SSH 密钥的用户显示的 `You won't be able to pull or push repositories via SSH until you add an SSH key to your profile` 警告。 |
| `version_check_enabled`                  | boolean          | 否                                   | 让极狐GitLab 在有可用更新时通知您。 |
| `valid_runner_registrars`                | array of strings | 否                                   | 允许注册极狐GitLab Runner 的类型列表。可以是 `[]`、`['group']`、`['project']` 或 `['group', 'project']`。 |
| `vscode_extension_marketplace`           | hash             | 否                                   | VS Code 扩展市场的设置。由 [Web IDE](../user/project/web_ide/_index.md) 和 [工作区](../user/workspace/_index.md) 使用。 |
| `web_hook_event_resend_limit`            | integer          | 否                                   | 对于给定项目或群组，每个用户每分钟的 Webhook 事件重发请求的最大数量。默认值：5。设置为 `0` 可禁用限制。[引入](https://gitlab.com/gitlab-org/gitlab/-/issues/587887)于极狐GitLab 19.3。 |
| `web_hook_test_limit`                    | integer          | 否                                   | 对于给定项目或群组，每个用户每分钟的 Webhook 测试请求的最大数量。默认值：5。设置为 `0` 可禁用限制。[引入](https://gitlab.com/gitlab-org/gitlab/-/issues/587887)于极狐GitLab 19.3。 |
| `whats_new_variant`                      | string           | 否                                   | 新功能变体，可能的值：`all_tiers`、`current_tier` 和 `disabled`。 |
| `wiki_page_max_content_bytes`            | integer          | 否                                   | Wiki 页面内容的最大大小（**字节**）。默认值：5242880 字节（5 MB）。最小值为 1024 字节。 |
| `bulk_import_concurrent_pipeline_batch_limit` | integer     | 否                                   | 要处理的最大同时直接传输批量导出数。 |
| `concurrent_relation_batch_export_limit` | integer          | 否                                   | 要处理的最大同时批量导出作业数。[引入](https://gitlab.com/gitlab-org/gitlab/-/merge_requests/169122)于极狐GitLab 17.6。 |
| `concurrent_relation_export_limit`       | integer          | 否                                   | 要处理的最大同时项目文件导出数。默认值：25。[引入](https://gitlab.com/gitlab-org/gitlab/-/work_items/599092)于极狐GitLab 19.4。 |
| `asciidoc_max_includes`                  | integer          | 否                                   | 任何单个文档中处理的 AsciiDoc include 指令的最大数量限制。默认值：32。最大值：64。 |
| `duo_custom_agents_enabled`              | boolean          | 否                                   | 指示此实例是否允许自定义 Agent。默认值：`true`。仅限极狐GitLab 私有化部署、专业版和旗舰版。[引入](https://gitlab.com/gitlab-org/gitlab/-/work_items/594615)于极狐GitLab 19.0。 |
| `duo_custom_flows_enabled`               | boolean          | 否                                   | 指示此实例是否允许自定义任务流。默认值：`true`。仅限极狐GitLab 私有化部署、专业版和旗舰版。[引入](https://gitlab.com/gitlab-org/gitlab/-/work_items/594615)于极狐GitLab 19.0。 |
| `duo_external_agents_enabled`            | boolean          | 否                                   | 指示此实例是否允许外部 Agent。默认值：`true`。仅限极狐GitLab 私有化部署、专业版和旗舰版。[引入](https://gitlab.com/gitlab-org/gitlab/-/work_items/594615)于极狐GitLab 19.0。 |
| `duo_features_enabled`                   | boolean          | 否                                   | 指示此实例是否启用极狐GitLab Duo 功能。仅限极狐GitLab 私有化部署、专业版和旗舰版。 |
| `lock_duo_custom_agents_enabled`         | boolean          | 否                                   | 指示是否对所有群组强制执行自定义 Agent 启用设置。默认值：`false`。仅限极狐GitLab 私有化部署、专业版和旗舰版。[引入](https://gitlab.com/gitlab-org/gitlab/-/work_items/594615)于极狐GitLab 19.0。 |
| `lock_duo_custom_flows_enabled`          | boolean          | 否                                   | 指示是否对所有群组强制执行自定义任务流启用设置。默认值：`false`。仅限极狐GitLab 私有化部署、专业版和旗舰版。[引入](https://gitlab.com/gitlab-org/gitlab/-/work_items/594615)于极狐GitLab 19.0。 |
| `lock_duo_external_agents_enabled`       | boolean          | 否                                   | 指示是否对所有群组强制执行外部 Agent 启用设置。默认值：`false`。仅限极狐GitLab 私有化部署、专业版和旗舰版。[引入](https://gitlab.com/gitlab-org/gitlab/-/work_items/594615)于极狐GitLab 19.0。 |
| `lock_duo_features_enabled`              | boolean          | 否                                   | 指示是否对所有子群组强制执行极狐GitLab Duo 功能启用设置。仅限极狐GitLab 私有化部署、专业版和旗舰版。 |
| `nuget_skip_metadata_url_validation` | boolean     | 否                                   | 指示是否跳过 NuGet 软件包的元数据 URL 验证。[引入](https://gitlab.com/gitlab-org/gitlab/-/merge_requests/145887)于极狐GitLab 17.0。 |
| `helm_max_packages_count` | integer     | 否                                   | 每个频道可以列出的最大 Helm 软件包数量。必须至少为 1。默认值为 1000。 |
| `require_admin_two_factor_authentication` | boolean         | 否 | 允许管理员要求实例上的所有管理员启用双因素认证。 |
| `secret_push_protection_available` | boolean         | 否 | 允许项目启用密钥推送保护。这不会启用密钥推送保护。仅限旗舰版。 |
| `disable_invite_members` | boolean         | 否 | 禁用群组的邀请成员功能。 |
| `enforce_pipl_compliance` | boolean | 否 | 设置是否对 SaaS 应用程序强制执行 pipl 合规性 |
| `iframe_rendering_enabled`               | boolean          | 否                                   | 允许在 Markdown 中渲染 iframe。默认禁用。 |
| `iframe_rendering_allowlist`             | array of strings | 否                                   | 用于内容安全策略和清理的允许 iframe `src` 主机[:端口] 条目列表。 |
| `iframe_rendering_allowlist_raw`         | string           | 否                                   | 允许的 iframe `src` 主机[:端口] 条目的原始换行符或逗号分隔列表。 |
| `usage_billing`                          | object           | 否                                   | 使用计费设置。检查 `ee/app/validators/json_schemas/usage_billing_settings.json` 获取架构定义 |

<a id="dormant-project-settings"></a>

### 休眠项目设置

您可以配置休眠项目的删除，或将其关闭。

| 属性                                | 类型             | 必填                             | 描述 |
|------------------------------------------|------------------|:------------------------------------:|-------------|
| `delete_inactive_projects`               | boolean          | 否                                   | 启用[休眠项目删除](../administration/dormant_project_deletion.md)。默认值为 `false`。 |
| `inactive_projects_delete_after_months`  | integer          | 否                                   | 如果 `delete_inactive_projects` 为 `true`，则设置删除休眠项目前的等待时间（以月为单位）。默认值为 `2`。 |
| `inactive_projects_min_size_mb`          | integer          | 否                                   | 如果 `delete_inactive_projects` 为 `true`，则设置检查项目是否处于非活动状态的最小代码仓库大小。默认值为 `0`。 |
| `inactive_projects_send_warning_email_after_months` | integer | 否                                 | 如果 `delete_inactive_projects` 为 `true`，则设置向维护者发送警告邮件前的等待时间（以月为单位），告知其项目因处于休眠状态而计划被删除。默认值为 `1`。 |

<a id="package-registry-settings-package-file-size-limits"></a>

### 软件包仓库设置：软件包文件大小限制

软件包文件大小限制不属于应用程序设置 API 的一部分。
相反，这些设置可以通过[计划限制 API](plan_limits.md)进行访问。
