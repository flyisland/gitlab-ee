---
stage: Shared responsibility based on functional area
group: Shared responsibility based on functional area
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
title: 极狐GitLab Prometheus 指标
---

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: 私有化部署

{{< /details >}}

要启用极狐GitLab Prometheus 指标：

1. 以具有管理员访问权限的用户身份登录极狐GitLab。
1. 在右上角，选择**管理员**。
1. 在左侧边栏中，选择**设置** > **指标与性能分析**。
1. 找到**指标 - Prometheus** 部分，然后选择**启用极狐GitLab Prometheus 指标端点**。
1. [重启极狐GitLab](../../restart_gitlab.md#reconfigure-a-linux-package-installation) 以使更改生效。

对于自行编译安装，您必须自行配置。

<a id="collecting-the-metrics"></a>

## 收集指标

极狐GitLab 监控其自身的内部服务指标，并在 `/-/metrics` 端点提供这些指标。与其他 [Prometheus](https://prometheus.io) 导出器不同，要访问这些指标，客户端 IP 地址必须被[明确允许](../ip_allowlist.md)。

这些指标已为 Linux 软件包和 Helm Chart 安装启用并收集。对于自行编译安装，必须手动启用这些指标
并由 Prometheus 服务器收集。

有关从 Sidekiq 节点启用和查看指标的信息，请参阅 [Sidekiq 指标](#sidekiq-metrics)。

<a id="metrics-available"></a>

## 可用指标

以下指标可用：

| 指标 | 类型 | 引入版本 | 标签 | 描述 |
|:-------------------------------------------------------------------------------|:----------|------:|:------------------------------------------------------------------------|:------------|
| `action_cable_active_connections`                                              | Gauge     |  13.4 | `server_mode`                                                           | 当前已连接的 ActionCable WS 客户端数量 |
| `action_cable_broadcasts_total`                                                | Counter   | 13.10 | `server_mode`                                                           | 已发出的 ActionCable 广播数量 |
| `action_cable_pool_current_size`                                               | Gauge     |  13.4 | `server_mode`                                                           | ActionCable 线程池中当前工作线程数 |
| `action_cable_pool_largest_size`                                               | Gauge     |  13.4 | `server_mode`                                                           | 目前观察到的 ActionCable 线程池中最大工作线程数 |
| `action_cable_pool_max_size`                                                   | Gauge     |  13.4 | `server_mode`                                                           | ActionCable 线程池中最大工作线程数 |
| `action_cable_pool_min_size`                                                   | Gauge     |  13.4 | `server_mode`                                                           | ActionCable 线程池中最小工作线程数 |
| `action_cable_pool_pending_tasks`                                              | Gauge     |  13.4 | `server_mode`                                                           | ActionCable 线程池中等待执行的任务数 |
| `action_cable_pool_tasks_total`                                                | Gauge     |  13.4 | `server_mode`                                                           | ActionCable 线程池中已执行的任务总数 |
| `action_cable_single_client_transmissions_total`                               | Counter   | 13.10 | `server_mode`                                                           | 在任何频道中传输给任何客户端的 ActionCable 消息数量 |
| `action_cable_subscription_confirmations_total`                                | Counter   | 13.10 | `server_mode`                                                           | 已确认的客户端 ActionCable 订阅数量 |
| `action_cable_subscription_rejections_total`                                   | Counter   | 13.10 | `server_mode`                                                           | 已拒绝的客户端 ActionCable 订阅数量 |
| `action_cable_transmitted_bytes_total`                                         | Counter   |  16.0 | `operation`, `channel`                                                  | 通过 ActionCable 传输的字节总数 |
| `active_context_queue_size`                                                    | Gauge     |  18.7 | `queue_name`, `shard`                                                   | 每个 ActiveContext 队列中的条目数 |
| `artifact_report_<report_type>_builds_completed_total`                         | Counter   |  15.3 |                                                                         | 带有报告类型产物的已完成 CI 构建计数器，按报告类型分组并按状态标记 |
| `auto_devops_pipelines_completed_total`                                        | Counter   |  12.7 |                                                                         | 已完成的 Auto DevOps 流水线计数器，按状态标记 |
| `cached_object_operations_total`                                               | Counter   |  15.3 | `controller`, `action`, `endpoint_id`                                   | 为特定 Web 请求缓存的对象总数 |
| `ci_report_parser_duration_seconds`                                            | Histogram |  13.9 | `parser`                                                                | 解析 CI/CD 报告产物的时间 |
| `dependency_linker_usage`                                                      | Counter   |  16.8 | `used_on`                                                               | 依赖链接器被使用的次数 |
| `email_receiver_error`                                                         | Counter   |  14.1 |                                                                         | 处理传入电子邮件时的错误总数 |
| `failed_login_captcha_total`                                                   | Gauge     |  11.0 |                                                                         | 登录期间 CAPTCHA 尝试失败的计数器 |
| `gitlab_application_rate_limiter_throttle_utilization_ratio`                   | Histogram |  17.6 | `throttle_key`, `peek`, `feature_category`                              | 极狐GitLab 应用速率限制器中节流的利用率。 |
| `gitaly_circuit_breaker_requests_total`                                        | Counter   |  18.9 | `circuit_state`, `result`, `reason`                                     | 断路器处理的 Gitaly 请求总数。`result` 可以是 `allowed`、`rejected` 或 `error`。`reason` 提供错误详情（例如 `resource_exhausted`） |
| `gitaly_circuit_breaker_transitions_total`                                     | Counter   |  18.9 | `from_state`, `to_state`                                                | 断路器状态转换总数。状态为 `closed`、`open`。详细端点和存储信息可在结构化日志中找到 |
| `gitlab_audit_event_streaming_nats_consumer_lag_seconds`                       | Histogram |  19.3 | `feature_category`                                                      | 审计事件流 NATS 消费者延迟（发布到分发），以秒为单位 |
| `gitlab_audit_event_streaming_nats_consumer_unreachable_total`                 | Counter   |  19.4 | `feature_category`                                                      | 因 NATS 不可达而中止的审计事件消费者排空 |
| `gitlab_audit_event_streaming_nats_dispatch_destination_error_total`           | Counter   |  19.4 | `feature_category`                                                      | 因目标端错误而失败的审计事件批量分发（降级比率，不是错误） |
| `gitlab_audit_event_streaming_nats_publish_duration_seconds`                   | Histogram |  19.4 | `feature_category`                                                      | 审计事件流 NATS 同步发布持续时间，以秒为单位 |
| `gitlab_audit_event_streaming_nats_publish_fallback_total`                     | Counter   |  19.3 | `feature_category`                                                      | 从 NATS 回退到 Sidekiq 的审计事件发布（降级比率，不是错误） |
| `gitlab_audit_event_streaming_nats_publish_total`                              | Counter   |  19.3 | `feature_category`                                                      | 通过 NATS 的审计事件发布尝试 |
| `gitlab_authorized_projects_safety_net_refresh_rows_total`                     | Counter   |  19.3 | `trigger`, `direction`                                                  | 安全网刷新添加或删除的 `project_authorizations` 行总数 |
| `gitlab_blob_embeds_total`                                                     | Counter   |  19.4 | `outcome`                                                               | Blob 嵌入渲染尝试总数。结果可以是 `rendered`、`unrenderable`、`unauthorized`、`project_not_found`、`embed_limit_exceeded`、`email_preview_disabled`。 |
| `gitlab_bootsnap_compile_cache_events_total`                                   | Counter   |  19.3 | `event`                                                                 | 启动期间观察到的 Bootsnap 编译缓存事件数量，按类型（`hit`、`revalidated`、`miss`、`stale`）。命中率为 `(hit + revalidated) / total` |
| `gitlab_cache_misses_total`                                                    | Counter   |  10.2 | `controller`, `action`, `store`, `endpoint_id`                          | 缓存读取未命中 |
| `gitlab_cache_operation_duration_seconds`                                      | Histogram |  10.2 | `operation`, `store`, `endpoint_id`                                     | 缓存访问时间 |
| `gitlab_cache_operations_total`                                                | Counter   |  12.2 | `controller`, `action`, `operation`, `store`, `endpoint_id`             | 按控制器或操作划分的缓存操作 |
| `gitlab_cache_read_multikey_count`                                             | Histogram |  15.7 | `controller`, `action`, `store`, `endpoint_id`                          | 多键缓存读取操作中的键数量 |
| `gitlab_ci_active_jobs`                                                        | Histogram |  14.2 |                                                                         | 创建流水线时的活动作业数 |
| `gitlab_ci_build_trace_errors_total`                                           | Counter   |  14.4 | `error_reason`                                                          | 构建跟踪中不同错误类型的总数 |
| `gitlab_ci_current_queue_size`                                                 | Gauge     |  16.3 |                                                                         | 已初始化 CI/CD 构建队列的当前大小 |
| `gitlab_ci_job_failure_reasons`                                                | Counter   | 13.11 | `reason`, `runner_type`                                                 | 作业失败原因计数器。`runner_type` 标签在极狐GitLab 19.3 中[添加](https://gitlab.com/gitlab-org/gitlab/-/work_items/603882)。有关 `reason` 标签值，请参阅 [CI/CD 失败原因指标](#cicd-failure-reason-metrics) |
| `gitlab_ci_job_token_authorization_failures`                                   | Counter   | 17.11 | `same_root_ancestor`                                                    | 通过 CI 作业令牌授权失败的次数 |
| `gitlab_ci_job_token_inbound_access`                                           | Counter   |  17.2 |                                                                         | 通过 CI 作业令牌的入站访问次数 |
| `gitlab_ci_pipeline_builder_scoped_variables_duration`                         | Histogram |  14.5 |                                                                         | 为 CI/CD 作业创建作用域变量所需的时间（秒） |
| `gitlab_ci_pipeline_creation_duration_seconds`                                 | Histogram |  13.0 | `gitlab`                                                                | 创建 CI/CD 流水线所需的时间（秒） |
| `gitlab_ci_pipeline_failure_reasons`                                           | Counter   | 13.11 | `reason`                                                                | 流水线失败原因计数器。有关 `reason` 标签值，请参阅 [CI/CD 失败原因指标](#cicd-failure-reason-metrics) |
| `gitlab_ci_pipeline_security_orchestration_policy_processing_duration_seconds` | Histogram | 13.12 |                                                                         | 在 CI/CD 流水线中处理安全策略所需的时间（秒） |
| `gitlab_ci_pipeline_size_builds`                                               | Histogram |  13.1 | `source`                                                                | 按流水线来源分组的流水线内构建总数 |
| `gitlab_ci_pipeline_time_to_finished_seconds`                                  | Histogram |  19.2 | `source`, `status`                                                      | 从流水线创建到完成状态（成功、失败或取消）的挂钟时间（秒） |
| `gitlab_ci_queue_depth_total`                                                  | Histogram |  16.3 |                                                                         | 与操作结果相关的 CI/CD 构建队列大小 |
| `gitlab_ci_queue_iteration_duration_seconds`                                   | Histogram |  16.3 |                                                                         | 在 CI/CD 队列中查找构建所需的时间 |
| `gitlab_ci_queue_operations_total`                                             | Counter   |  16.3 |                                                                         | 统计队列内发生的所有操作 |
| `gitlab_ci_queue_retrieval_duration_seconds`                                   | Histogram |  16.3 |                                                                         | 执行 SQL 查询以检索构建队列所需的时间 |
| `gitlab_ci_queue_size_total`                                                   | Histogram |  16.3 |                                                                         | 已初始化 CI/CD 构建队列的大小 |
| `gitlab_ci_runner_authentication_failure_total`                                | Counter   |  15.2 |                                                                         | Runner 认证失败的总次数 |
| `gitlab_ci_runner_authentication_success_total`                                | Counter   |  15.2 | `type`                                                                  | Runner 认证成功的总次数 |
| `gitlab_ci_trace_bytes_total`                                                  | Counter   |  13.4 |                                                                         | 传输的构建跟踪字节总数 |
| `gitlab_ci_trace_finalize_duration_seconds`                                    | Histogram |  13.6 |                                                                         | 构建跟踪块迁移到对象存储的持续时间 |
| `gitlab_ci_trace_operations_total`                                             | Counter   |  13.4 | `operation`                                                             | 构建跟踪上不同操作的总数 |
| `gitlab_connection_pool_available_count`                                       | Gauge     |  16.7 |                                                                         | 池中可用连接数 |
| `gitlab_connection_pool_size`                                                  | Gauge     |  16.7 |                                                                         | 连接池大小 |
| `gitlab_database_transaction_seconds`                                          | Histogram |  12.1 |                                                                         | 数据库事务中花费的时间（秒） |
| `gitlab_dependency_paths_found_total`                                          | Counter   |  18.3 | `cyclic`                                                                | 统计为给定依赖项找到的祖先依赖路径数量。 |
| `gitlab_diffs_collection_real_duration_seconds`                                | Histogram |  15.8 | `controller`, `action`, `endpoint_id`                                   | 在差异批量请求中查询合并请求差异文件所花费的持续时间（秒） |
| `gitlab_diffs_comparison_real_duration_seconds`                                | Histogram |  15.8 | `controller`, `action`, `endpoint_id`                                   | 在差异批量请求中获取比较数据所花费的持续时间（秒） |
| `gitlab_diffs_highlight_cache_decorate_real_duration_seconds`                  | Histogram |  15.8 | `controller`, `action`, `endpoint_id`                                   | 在差异批量请求中从缓存设置高亮行所花费的持续时间（秒） |
| `gitlab_diffs_render_real_duration_seconds`                                    | Histogram |  15.8 | `controller`, `action`, `endpoint_id`                                   | 在差异批量请求中序列化和渲染差异所花费的持续时间（秒） |
| `gitlab_diffs_reorder_real_duration_seconds`                                   | Histogram |  15.8 | `controller`, `action`, `endpoint_id`                                   | 在差异批量请求中重新排序差异文件所花费的持续时间（秒） |
| `gitlab_diffs_unfold_real_duration_seconds`                                    | Histogram |  15.8 | `controller`, `action`, `endpoint_id`                                   | 在差异批量请求中展开位置所花费的持续时间（秒） |
| `gitlab_diffs_unfoldable_positions_real_duration_seconds`                      | Histogram |  15.8 | `controller`, `action`                                                  | 在差异批量请求中获取不可展开评论位置所花费的持续时间（秒） |
| `gitlab_diffs_write_cache_real_duration_seconds`                               | Histogram |  15.8 | `controller`, `action`, `endpoint_id`                                   | 在差异批量请求中缓存高亮行和统计信息所花费的持续时间（秒） |
| `gitlab_external_http_duration_seconds`                                        | Counter   |  13.8 |                                                                         | 每次对外部系统进行 HTTP 调用所花费的持续时间（秒） |
| `gitlab_external_http_exception_total`                                         | Counter   |  13.8 |                                                                         | 进行外部 HTTP 调用时引发的异常总数 |
| `gitlab_external_http_total`                                                   | Counter   |  13.8 | `controller`, `action`, `endpoint_id`                                   | 对外部系统的 HTTP 调用总数 |
| `gitlab_find_dependency_paths_real_duration_seconds`                           | Histogram |  18.3 |                                                                         | 为给定组件解析祖先依赖路径所花费的持续时间（秒）。 |
| `gitlab_ghost_user_migration_lag_seconds`                                      | Gauge     |  15.6 |                                                                         | 幽灵用户迁移最旧计划记录的等待时间（秒） |
| `gitlab_ghost_user_migration_scheduled_records_total`                          | Gauge     |  15.6 |                                                                         | 已计划的幽灵用户迁移总数 |
| `gitlab_graphql_return_type_conflicts_total`                                   | Counter   |  19.4 | `field`, `operation`, `types`                                           | 为同一响应键选择不匹配类型的 GraphQL 查询数量 |
| `gitlab_highlight_usage`                                                       | Counter   |  16.8 | `used_on`                                                               | `Gitlab::Highlight` 被使用的次数 |
| `gitlab_http_router_rule_total`                                                | Counter   |  17.4 | `rule_action`, `rule_type`                                              | 统计 HTTP 路由器规则的 `rule_action` 和 `rule_type` 出现次数 |
| `gitlab_issuable_fast_count_by_state_failures_total`                           | Counter   |  13.5 |                                                                         | **议题**和**合并请求**页面上软失败行计数操作的数量 |
| `gitlab_issuable_fast_count_by_state_total`                                    | Counter   |  13.5 |                                                                         | **议题**和**合并请求**页面上行计数操作的总数 |
| `gitlab_keeparound_refs_created_total`                                         | Counter   | 16.10 | `source`                                                                | 统计实际创建的保留引用数量 |
| `gitlab_keeparound_refs_requested_total`                                       | Counter   | 16.10 | `source`                                                                | 统计请求创建的保留引用数量 |
| `gitlab_memwd_violations_handled_total`                                        | Counter   |  15.9 |                                                                         | Ruby 进程内存违规被处理的总次数 |
| `gitlab_memwd_violations_total`                                                | Counter   |  15.9 |                                                                         | Ruby 进程违反内存阈值的总次数 |
| `gitlab_method_call_duration_seconds`                                          | Histogram |  10.2 | `controller`, `action`, `module`, `method`                              | 方法调用实际持续时间 |
| `gitlab_omniauth_login_total`                                                  | Counter   |  16.1 | `omniauth_provider`, `status`                                           | OmniAuth 登录尝试总数 |
| `gitlab_openbao_request_duration_seconds`                                      | Histogram |  19.4 | `operation`, `outcome`                                                  | 从 Rails 到 OpenBao 的每次 HTTP 调用的持续时间（秒）。仅限专业版和旗舰版。 |
| `gitlab_openbao_request_errors_total`                                          | Counter   |  19.4 | `operation`, `error_type`                                               | 从 Rails 到 OpenBao 的失败 HTTP 调用，按故障类型。仅限专业版和旗舰版。 |
| `gitlab_openbao_requests_total`                                                | Counter   |  19.4 | `operation`, `method`, `outcome`                                        | 从 Rails 到 OpenBao 的 HTTP 调用总数。仅限专业版和旗舰版。 |
| `gitlab_page_out_of_bounds`                                                    | Counter   |  12.8 | `controller`, `action`, `bot`                                           | PageLimiter 分页限制被触发的计数器 |
| `gitlab_plan_tier_lookups_total`                                               | Counter   |  19.5 | `subject`, `result`                                                     | 统计计划层级查找。`subject` 是 `user` 或 `namespace`。当每次请求存储或 Redis 应答时，`result` 为 `hit`；当查找查询数据库时，为 `miss`。没有 ID 的查找不计入。一个请求中的两次查找只有在解析相同缓存键时才复用每次请求存储，就像部署令牌在其自己的命名空间是请求所寻址的命名空间时所做的那样，因此应针对 `miss` 速率而不是命中率设置告警 |
| `gitlab_presentable_object_cacheless_render_real_duration_seconds`             | Histogram |  15.3 | `controller`, `action`, `endpoint_id`                                   | 缓存和表示特定 Web 请求对象所花费的实际时间 |
| `gitlab_rack_attack_events_total`                                              | Counter   |  17.6 | `event_type`, `event_name`                                              | 统计 Rack Attack 处理的事件总数。 |
| `gitlab_rack_attack_throttle_limit`                                            | Gauge     |  17.6 | `event_name`                                                            | 报告客户端在 Rack Attack 对其进行节流之前可以发出的最大请求数。 |
| `gitlab_rack_attack_throttle_period_seconds`                                   | Gauge     |  17.6 | `event_name`                                                            | 报告在 Rack Attack 对客户端进行节流之前，对其请求进行计数的持续时间。 |
| `gitlab_rails_boot_time_seconds`                                               | Gauge     |  14.8 |                                                                         | Rails 主进程完成启动所经过的时间 |
| `gitlab_rails_queue_duration_seconds`                                          | Histogram |   9.4 |                                                                         | 测量 GitLab Workhorse 将请求转发到 Rails 之间的延迟 |
| `gitlab_rate_limiter_git_basic_auth_ban_events_total`                                 | Counter   |  19.4 | `event`                                                                 | 统计 Git 和容器镜像仓库认证 IP 封禁事件。`event` 是 `failure`、`ban`、`blocked`、`already_banned` 或 `reset` 之一 |
| `gitlab_ref_cache_operations_total`                                            | Counter   |  19.4 | `operation`, `ref_type`, `status`                                       | 按结果统计引用缓存操作。`operation` 是 `fetch`、`search`、`include`、`update` 或 `rebuild`。`ref_type` 是 `branch`、`tag` 或 `unknown`。对于 `fetch`、`search` 和 `include`，`status` 是 `hit`、`miss_untrusted`、`miss_absent` 或 `error`。`miss_untrusted` 表示可恢复的未命中，即集合存在但不受信任，或者缓存重建产生了空集合，没有 Redis 键。`miss_absent` 表示产生了成员的冷读取。对于 `update`，`status` 是 `success`、`skipped` 或 `error`。对于 `rebuild`，`status` 是 `success`、`skipped_locked`、`skipped_trusted` 或 `error`。`update/skipped` 包括在重建期间排队并稍后通过对账应用的双写。 |
| `gitlab_ref_cache_trust_events_total`                                          | Counter   |  19.4 | `ref_type`, `event`                                                     | 引用缓存信任生命周期事件总数。`ref_type` 是 `branch`、`tag` 或 `unknown`。`event` 是 `granted`、`revoked` 或 `grant_skipped`。 |
| `gitlab_ruby_threads_max_expected_threads`                                     | Gauge     |  13.3 |                                                                         | 预期正在运行并执行应用工作的最大线程数 |
| `gitlab_ruby_threads_running_threads`                                          | Gauge     |  13.3 |                                                                         | 按名称统计正在运行的 Ruby 线程数 |
| `gitlab_secrets_manager_entitlement_resolutions_total`                         | Counter   |  19.4 | `source`                                                                | 查询 客户门户 的密钥管理器权益解析；离线和缓存解析不计入。`source` 是 `live`（客户门户 已应答）、`lkg_stale`（客户门户 不可达或应答 HTTP 5xx 错误，因此极狐GitLab 复用了其最后已知的良好应答）或 `fail_closed`（解析失败，因此极狐GitLab 拒绝访问）。仅限专业版和旗舰版。 |
| `gitlab_security_policies_policy_creation_duration_seconds`                    | Histogram |  17.6 |                                                                         | 创建策略相关配置所需的时间 |
| `gitlab_security_policies_policy_deletion_duration_seconds`                    | Histogram |  17.6 |                                                                         | 删除策略相关配置所需的时间 |
| `gitlab_security_policies_policy_sync_duration_seconds`                        | Histogram |  17.6 |                                                                         | 为策略配置同步策略更改所需的时间 |
| `gitlab_security_policies_scan_execution_configuration_rendering_seconds`      | Histogram |  17.3 |                                                                         | 渲染扫描执行策略 CI 配置所需的时间 |
| `gitlab_security_policies_scan_result_process_duration_seconds`                | Histogram |  16.7 |                                                                         | 处理合并请求审批策略所需的时间 |
| `gitlab_security_policies_sync_opened_merge_requests_duration_seconds`         | Histogram |  17.6 |                                                                         | 策略更改后同步已打开的合并请求所需的时间 |
| `gitlab_security_policies_update_configuration_duration_seconds`               | Histogram |  17.6 |                                                                         | 为策略配置更改安排同步所需的时间 |
| `gitlab_sli_openbao_client_calls_error_total`                                  | Counter   |  19.4 | `operation`                                                             | 从 Rails 到 OpenBao 的失败 HTTP 调用，作为应用 SLI 测量。仅限专业版和旗舰版。 |
| `gitlab_sli_openbao_client_calls_total`                                        | Counter   |  19.4 | `operation`                                                             | 从 Rails 到 OpenBao 的 HTTP 调用总数，作为应用 SLI 测量。仅限专业版和旗舰版。 |
| `gitlab_sli_rails_request_apdex_success_total`                                 | Counter   |  14.4 | `endpoint_id`, `feature_category`, `request_urgency`                    | 满足其紧急程度目标持续时间的成功请求总数。除以 `gitlab_sli_rails_requests_apdex_total` 可获得成功率 |
| `gitlab_sli_rails_request_apdex_total`                                         | Counter   |  14.4 | `endpoint_id`, `feature_category`, `request_urgency`                    | 请求 Apdex 测量总数。 |
| `gitlab_sli_rails_request_error_total`                                         | Counter   |  15.7 | `endpoint_id`, `feature_category`, `request_urgency`, `error`           | 请求错误测量总数。 |
| `gitlab_snowplow_events_total`                                                 | Counter   |  14.1 |                                                                         | 发出的极狐GitLab Snowplow Analytics Instrumentation 事件总数 |
| `gitlab_snowplow_failed_events_total`                                          | Counter   |  14.1 |                                                                         | 极狐GitLab Snowplow Analytics Instrumentation 事件发出失败总数 |
| `gitlab_snowplow_successful_events_total`                                      | Counter   |  14.1 |                                                                         | 极狐GitLab Snowplow Analytics Instrumentation 事件发出成功总数 |
| `gitlab_spamcheck_request_duration_seconds`                                    | Histogram | 13.12 |                                                                         | Rails 与反垃圾引擎之间请求的持续时间 |
| `gitlab_sql_<role>_duration_seconds`                                           | Histogram | 13.10 |                                                                         | SQL 执行时间，不包括 `SCHEMA` 操作和 `BEGIN` / `COMMIT`，按数据库角色（主/副本）分组 |
| `gitlab_sql_duration_seconds`                                                  | Histogram |  10.2 |                                                                         | SQL 执行时间，不包括 `SCHEMA` 操作和 `BEGIN` / `COMMIT` |
| `gitlab_transaction_cache_<key>_count_total`                                   | Counter   |  10.2 |                                                                         | Rails 缓存调用总数计数器（按键） |
| `gitlab_transaction_cache_<key>_duration_total`                                | Counter   |  10.2 |                                                                         | Rails 缓存调用中花费的总时间（秒）计数器（按键） |
| `gitlab_transaction_cache_count_total`                                         | Counter   |  10.2 |                                                                         | Rails 缓存调用总数计数器（聚合） |
| `gitlab_transaction_cache_duration_total`                                      | Counter   |  10.2 |                                                                         | Rails 缓存调用中花费的总时间（秒）计数器（聚合） |
| `gitlab_transaction_cache_read_hit_count_total`                                | Counter   |  10.2 | `controller`, `action`, `store`, `endpoint_id`                          | Rails 缓存调用缓存命中计数器 |
| `gitlab_transaction_cache_read_miss_count_total`                               | Counter   |  10.2 | `controller`, `action`, `store`, `endpoint_id`                          | Rails 缓存调用缓存未命中计数器 |
| `gitlab_transaction_db_<role>_cached_count_total`                              | Counter   |  13.1 | `controller`, `action`, `endpoint_id`                                   | 缓存 SQL 调用总数计数器，按数据库角色（主/副本）分组 |
| `gitlab_transaction_db_<role>_count_total`                                     | Counter   | 13.10 | `controller`, `action`, `endpoint_id`                                   | SQL 调用总数计数器，按数据库角色（主/副本）分组 |
| `gitlab_transaction_db_<role>_wal_cached_count_total`                          | Counter   |  14.1 | `controller`, `action`, `endpoint_id`                                   | 缓存的 WAL（预写日志位置）查询总数计数器，按数据库角色（主/副本）分组 |
| `gitlab_transaction_db_<role>_wal_count_total`                                 | Counter   |  14.0 | `controller`, `action`, `endpoint_id`                                   | WAL（预写日志位置）查询总数计数器，按数据库角色（主/副本）分组 |
| `gitlab_transaction_db_cached_count_total`                                     | Counter   |  13.1 | `controller`, `action`, `endpoint_id`                                   | 缓存 SQL 调用总数计数器 |
| `gitlab_transaction_db_count_total`                                            | Counter   |  13.1 | `controller`, `action`, `endpoint_id`                                   | SQL 调用总数计数器 |
| `gitlab_transaction_db_write_count_total`                                      | Counter   |  13.1 | `controller`, `action`, `endpoint_id`                                   | 写入 SQL 调用总数计数器 |
| `gitlab_transaction_duration_seconds`                                          | Histogram |  10.2 | `controller`, `action`, `endpoint_id`                                   | 成功请求的持续时间（`gitlab_transaction_*` 指标） |
| `gitlab_transaction_event_build_found_total`                                   | Counter   |   9.4 |                                                                         | API /jobs/request 找到构建的计数器 |
| `gitlab_transaction_event_build_invalid_total`                                 | Counter   |   9.4 |                                                                         | API /jobs/request 因并发冲突导致构建无效的计数器 |
| `gitlab_transaction_event_build_not_found_cached_total`                        | Counter   |   9.4 |                                                                         | API /jobs/request 构建未找到的缓存响应计数器 |
| `gitlab_transaction_event_build_not_found_total`                               | Counter   |   9.4 |                                                                         | API /jobs/request 构建未找到的计数器 |
| `gitlab_transaction_event_change_default_branch_total`                         | Counter   |   9.4 |                                                                         | 任何代码仓库默认分支被更改时的计数器 |
| `gitlab_transaction_event_create_repository_total`                             | Counter   |   9.4 |                                                                         | 任何代码仓库被创建时的计数器 |
| `gitlab_transaction_event_etag_caching_cache_hit_total`                        | Counter   |   9.4 | `endpoint`                                                              | ETag 缓存命中的计数器。 |
| `gitlab_transaction_event_etag_caching_header_missing_total`                   | Counter   |   9.4 | `endpoint`                                                              | ETag 缓存未命中 - 缺少请求头的计数器 |
| `gitlab_transaction_event_etag_caching_key_not_found_total`                    | Counter   |   9.4 | `endpoint`                                                              | ETag 缓存未命中 - 未找到键的计数器 |
| `gitlab_transaction_event_etag_caching_middleware_used_total`                  | Counter   |   9.4 | `endpoint`                                                              | ETag 中间件被访问的计数器 |
| `gitlab_transaction_event_etag_caching_resource_changed_total`                 | Counter   |   9.4 | `endpoint`                                                              | ETag 缓存未命中 - 资源已更改的计数器 |
| `gitlab_transaction_event_fork_repository_total`                               | Counter   |   9.4 |                                                                         | 代码仓库复刻计数器（RepositoryForkWorker）。仅在源代码仓库存在时递增 |
| `gitlab_transaction_event_import_repository_total`                             | Counter   |   9.4 |                                                                         | 代码仓库导入计数器（RepositoryImportWorker） |
| `gitlab_transaction_event_patch_hard_limit_bytes_hit_total`                    | Counter   |  13.9 |                                                                         | 差异补丁大小限制被触发的计数器 |
| `gitlab_transaction_event_push_branch_total`                                   | Counter   |   9.4 |                                                                         | 所有分支推送的计数器 |
| `gitlab_transaction_event_rails_exception_total`                               | Counter   |   9.4 |                                                                         | Rails 异常数量的计数器 |
| `gitlab_transaction_event_remove_branch_total`                                 | Counter   |   9.4 |                                                                         | 任何代码仓库分支被删除时的计数器 |
| `gitlab_transaction_event_remove_repository_total`                             | Counter   |   9.4 |                                                                         | 代码仓库被删除时的计数器 |
| `gitlab_transaction_event_remove_tag_total`                                    | Counter   |   9.4 |                                                                         | 任何代码仓库标签被删除时的计数器 |
| `gitlab_transaction_event_sidekiq_exception_total`                             | Counter   |   9.4 |                                                                         | Sidekiq 异常计数器 |
| `gitlab_transaction_event_stuck_import_jobs_total`                             | Counter   |   9.4 | `projects_without_jid_count`, `projects_with_jid_count`                 | 卡住的导入作业计数 |
| `gitlab_transaction_event_update_build_total`                                  | Counter   |   9.4 |                                                                         | API `/jobs/request/:id` 更新构建的计数器 |
| `gitlab_transaction_new_redis_connections_total`                               | Counter   |   9.4 |                                                                         | 新 Redis 连接的计数器 |
| `gitlab_transaction_rails_queue_duration_total`                                | Counter   |   9.4 | `controller`, `action`, `endpoint_id`                                   | 测量 GitLab Workhorse 将请求转发到 Rails 之间的延迟 |
| `gitlab_transaction_view_duration_total`                                       | Counter   |   9.4 | `controller`, `action`, `view`, `endpoint_id`                           | 视图持续时间 |
| `gitlab_view_rendering_duration_seconds`                                       | Histogram |  10.2 | `controller`, `action`, `view`, `endpoint_id`                           | 视图持续时间（直方图） |
| `gitlab_vulnerability_report_branch_comparison_cpu_duration_seconds`           | Histogram | 15.11 |                                                                         | 默认分支 SQL 查询上漏洞报告的 CPU 执行持续时间 |
| `gitlab_vulnerability_report_branch_comparison_real_duration_seconds`          | Histogram | 15.11 |                                                                         | 默认分支 SQL 查询上漏洞报告的墙上时钟执行持续时间 |
| `http_elasticsearch_requests_duration_seconds`                                 | Histogram |  13.1 | `controller`, `action`, `endpoint_id`                                   | Web 事务期间 Elasticsearch 请求持续时间。仅限专业版和旗舰版。 |
| `http_elasticsearch_requests_total`                                            | Counter   |  13.1 | `controller`, `action`, `endpoint_id`                                   | Web 事务期间 Elasticsearch 请求计数。仅限专业版和旗舰版。 |
| `http_zoekt_requests_duration_seconds`                                         | Histogram |  19.2 | `controller`, `action`, `feature_category`, `endpoint_id`               | Web 事务期间 Zoekt 服务器的查询时间。仅限专业版和旗舰版。 |
| `http_zoekt_requests_total`                                                    | Counter   |  19.2 | `controller`, `action`, `feature_category`, `endpoint_id`               | Web 事务期间对 Zoekt 服务器的调用量。仅限专业版和旗舰版。 |
| `http_request_duration_seconds`                                                | Histogram |   9.4 | `method`                                                                | 成功请求从 Rack 中间件返回的 HTTP 响应时间 |
| `http_requests_total`                                                          | Counter   |   9.4 | `method`, `status`                                                      | Rack 请求计数 |
| `job_queue_duration_seconds`                                                   | Histogram |   9.5 |                                                                         | 请求处理执行时间 |
| `job_register_attempts_failed_total`                                           | Counter   |   9.5 |                                                                         | 统计 Runner 注册作业失败的次数 |
| `job_register_attempts_total`                                                  | Counter   |   9.5 |                                                                         | 统计 Runner 尝试注册作业的次数 |
| `pipeline_graph_link_calculation_duration_seconds`                             | Histogram |  13.9 |                                                                         | 计算链接所花费的总时间（秒） |
| `pipeline_graph_links_per_job_ratio`                                           | Histogram |  13.9 |                                                                         | 每个图中链接与作业的比率 |
| `pipeline_graph_links_total`                                                   | Histogram |  13.9 |                                                                         | 每个图的链接数 |
| `pipelines_created_total`                                                      | Counter   |   9.4 | `source`, `partition_id`                                                | 已创建流水线的计数器 |
| `pipelines_finished_total`                                                     | Counter   |  19.2 | `source`, `partition_id`, `status`                                      | 已完成（成功、失败或取消）流水线的计数器 |
| `rack_uncaught_errors_total`                                                   | Counter   |   9.4 |                                                                         | 处理未捕获错误的 Rack 连接计数 |
| `redis_cache_generation_duration_seconds`                                      | Histogram |  15.6 | `cache_hit`, `cache_identifier`, `feature_category`, `backing_resource` | 生成 Redis 缓存的时间 |
| `redis_hit_miss_operations_total`                                              | Counter   |  15.6 | `cache_hit`, `cache_identifier`, `feature_category`, `backing_resource` | Redis 缓存命中和未命中的总数 |
| `search_advanced_boolean_settings`                                             | Gauge     |  17.3 | `name`                                                                  | 高级搜索布尔设置的当前状态 |
| `search_advanced_index_repair_total`                                           | Counter   |  17.3 | `document_type`                                                         | 统计索引修复操作的数量 |
| `service_desk_new_note_email`                                                  | Counter   |  14.0 |                                                                         | 新服务台评论的电子邮件通知总数 |
| `service_desk_thank_you_email`                                                 | Counter   |  14.0 |                                                                         | 对新服务台电子邮件的电子邮件回复总数 |
| `successful_login_captcha_total`                                               | Gauge     |  11.0 |                                                                         | 登录期间 CAPTCHA 尝试成功的计数器 |
| `upload_file_does_not_exist`                                                   | Counter   |  10.7 |                                                                         | 上传记录找不到其文件的次数。 |
| `user_session_logins_total`                                                    | Counter   |   9.4 |                                                                         | 自极狐GitLab 启动或重启以来已登录用户数的计数器 |
| `validity_check_network_errors_total`                                          | Counter   |  18.6 | `partner`, `error_class`                                                | 合作伙伴令牌验证 API 调用期间的网络错误总数。仅限旗舰版。 |
| `validity_check_partner_api_duration_seconds`                                  | Histogram |  18.6 | `partner`                                                               | 令牌验证请求的合作伙伴 API 响应时间（秒）。仅限旗舰版。 |
| `validity_check_partner_api_requests_total`                                    | Counter   |  18.6 | `partner`, `status`, `error_type`                                       | 具有成功/失败状态的合作伙伴 API 验证请求总数。仅限旗舰版。 |
| `validity_check_rate_limit_hits_total`                                         | Counter   |  18.6 | `limit_type`                                              | 合作伙伴令牌验证期间的速率限制命中总数。仅限旗舰版。 |

<a id="cicd-failure-reason-metrics"></a>

### CI/CD 失败原因指标

`gitlab_ci_job_failure_reasons` 和 `gitlab_ci_pipeline_failure_reasons` 计数器记录 CI/CD 作业和流水线失败的原因。无论哪个进程处理失败，都会递增计数器，因此相同的
指标会同时出现在 Rails（Puma）和 Sidekiq 指标端点上。例如，Runner 作业状态
更新由 Rails API 处理，而下游流水线创建在 Sidekiq 中运行。标签值在两个端点上具有相同的含义。仪表板应对所有端点的值求和。

<a id="job-failure-reasons"></a>

#### 作业失败原因

`reason` 标签的 `gitlab_ci_job_failure_reasons` 记录作业的失败原因。常见值：

- `script_failure`：作业脚本命令返回了非零退出码。对于 `docker`、
  `docker+machine` 和 `kubernetes` 执行器，此值也涵盖 Docker 镜像拉取失败。
  在极狐GitLab 19.1 及更高版本中，由无效镜像或标签引起的拉取失败记录为
  `runner_configuration_error`，由不可达的镜像仓库引起的拉取失败记录为
  `runner_external_dependency_failure`。
- `api_failure`：Runner 在作业期间无法与极狐GitLab API 通信，例如在
  发送作业跟踪、上传产物或报告作业状态时。
- `runner_system_failure`：Runner 在准备构建环境或执行器时失败，
  与作业脚本无关。
- `job_execution_timeout`：作业超过了为该作业设置的最大执行时间。
- `downstream_pipeline_creation_failed`：触发作业无法创建下游流水线。
- `unknown_failure`：未记录具体的失败原因。

有关完整值列表，请参阅 [`retry:when`](../../../ci/yaml/_index.md#retrywhen)。

<a id="pipeline-failure-reasons"></a>

#### 流水线失败原因

`reason` 标签的 `gitlab_ci_pipeline_failure_reasons` 记录流水线的失败原因：

| 值 | 描述 |
|:--------------------------------|:------------|
| `unknown_failure`               | 流水线失败的原因未知。 |
| `config_error`                  | 流水线因 CI/CD 配置文件中的错误而失败。 |
| `external_validation_failure`   | 外部流水线验证失败。 |
| `user_not_verified`             | 流水线因用户未经验证而失败。 |
| `size_limit_exceeded`           | 超出了流水线大小限制。 |
| `job_activity_limit_exceeded`   | 超出了流水线作业活动限制。 |
| `deployments_limit_exceeded`    | 超出了流水线部署限制。 |
| `project_deleted`               | 与流水线关联的项目被删除。 |
| `filtered_by_rules`             | 每个作业都被 `rules` 排除，因此流水线未被创建。此值是预期行为。 |
| `filtered_by_workflow_rules`    | 顶层 `workflow:rules` 阻止了流水线运行。此值是预期行为。 |
| `composite_identity_forbidden`  | 流水线未运行，因为代码必须先由非 AI 用户审查。 |
| `pipeline_ref_creation_failure` | 极狐GitLab 无法创建流水线引用。 |
| `filtered_by_no_pipeline`       | 提交是使用 `ci.no_pipeline` 选项推送的，因此流水线未运行。此值是预期行为。 |
| `gitaly_unavailable`            | 创建流水线时 Gitaly 暂时不可用。 |

`filtered_by_rules`、`filtered_by_workflow_rules`、`filtered_by_no_pipeline` 和 `gitaly_unavailable` 原因会被指标计数，但极狐GitLab 不会为它们持久化失败的流水线，因此它们永远不会在 UI 中显示为失败的流水线。

这两个计数器也列在 [Sidekiq 指标](#sidekiq-metrics)表中。

<a id="zoekt-metrics"></a>

## Zoekt 指标

{{< details >}}

- Tier: 专业版，旗舰版
- Offering: 私有化部署

{{< /details >}}

由 Zoekt 提供支持的[精确代码搜索](../../../user/search/exact_code_search.md)的指标。

<a id="per-request-and-per-job-metrics"></a>

### 每个请求和每个作业的指标

这些指标会针对从 GitLab Rails 到 Zoekt 节点的每个 HTTP 请求发出，包括来自 Web/Grape 请求和 Sidekiq 作业的请求。

| 指标 | 类型 | 引入版本 | 标签 | 描述 |
|:-------|:-----|------:|:-------|:------------|
| `http_zoekt_requests_total` | Counter | 19.2 | `controller`, `action`, `feature_category`, `endpoint_id` | Web 事务期间对 Zoekt 服务器的调用次数。仅限专业版和旗舰版。 |
| `http_zoekt_requests_duration_seconds` | Histogram | 19.2 | `controller`, `action`, `feature_category`, `endpoint_id` | Web 事务期间对 Zoekt 服务器的查询时间。仅限专业版和旗舰版。 |
| `sidekiq_zoekt_requests_total` | Counter | 19.2 | `queue`, `boundary`, `external_dependencies`, `feature_category`, `job_status`, `urgency`, `destination_shard_redis` | Sidekiq 作业执行期间的 Zoekt 请求。仅限专业版和旗舰版。 |
| `sidekiq_zoekt_requests_duration_seconds` | Histogram | 19.2 | `queue`, `boundary`, `external_dependencies`, `feature_category`, `job_status`, `urgency`, `destination_shard_redis` | Sidekiq 作业在对 Zoekt 服务器的请求中所花费的秒数。仅限专业版和旗舰版。 |

这两行 `sidekiq_zoekt_*` 指标也列在 Sidekiq 指标表中，与等效的 Elasticsearch 和 Redis 指标并列。

<a id="database-derived-zoekt-metrics-from-gitlab-exporter"></a>

### 数据库衍生的 Zoekt 指标（来自 GitLab exporter）

数据库衍生的 Zoekt 指标（节点状态、任务队列深度、索引状态、存储字节数）由 `gitlab-exporter` 进程在 `search_zoekt_*` 前缀下发出。`gitlab-exporter` 端点会发出这些指标，而不是 Rails 的 `/-/metrics` 端点。

| 指标 | 类型 | 引入版本 | 标签 | 描述 |
|:-------|:-----|------:|:-------|:------------|
| `search_zoekt_task_processing_queue_size` | Gauge | **无** | `node_name`, `node_id` | 等待 Zoekt 处理的任务数量。 |
| `search_zoekt_repositories_schema_version_count` | Gauge | **无** | `target_schema_version`, `zoekt_node_id`, `zoekt_node_name` | 不具备最新 schema 版本的 `zoekt_repositories` 数量。 |
| `search_zoekt_nodes_status` | Gauge | **无** | `zoekt_node_id`, `zoekt_node_name` | 每个 Zoekt 节点的状态。`0` 表示离线（上次出现时间超过 2 分钟前），`1` 表示在线。 |
| `search_zoekt_node_unclaimed_storage_bytes` | Gauge | **无** | `zoekt_node_id`, `zoekt_node_name` | Zoekt 节点的未占用存储字节数。 |
| `search_zoekt_node_storage_percent_used` | Gauge | **无** | `zoekt_node_id`, `zoekt_node_name` | Zoekt 节点已使用的存储比例（范围：`0` 到 `1`）。 |
| `search_zoekt_repositories_states_total` | Gauge | **无** | `state` | 处于每种状态的 Zoekt 代码仓库数量。 |
| `search_zoekt_indices_states` | Gauge | **无** | `state` | 处于每种状态的 Zoekt 索引数量。 |
| `search_zoekt_indices_watermark_levels` | Gauge | **无** | `watermark_level` | 处于每个水位级别的 Zoekt 索引数量。 |
| `search_zoekt_indices_reserved_storage_bytes` | Gauge | **无** | `zoekt_index_id`, `zoekt_node_name` | 每个 Zoekt 索引的预留存储字节数。 |
| `search_zoekt_indices_used_storage_bytes` | Gauge | **无** | `zoekt_index_id`, `zoekt_node_name` | 每个 Zoekt 索引的已用存储字节数。 |
| `search_zoekt_node_enabled_namespaces` | Gauge | 19.2 | `node_id`, `node_name` | 每个 Zoekt 节点已启用的命名空间数量。 |
| `search_zoekt_node_tasks` | Gauge | 19.2 | `node_id`, `node_name`, `state` | 节点上按状态细分的 Zoekt 索引任务数量。 |
| `search_zoekt_indices_with_stale_used_storage_bytes` | Gauge | 19.2 | **无** | 自上次索引运行以来，其 `used_storage_bytes` 值未更新的 Zoekt 索引数量。 |

<a id="sli-metrics"></a>

### SLI 指标

全局搜索 SLI 指标包含 `search_type="zoekt"` 标签下的 Zoekt 搜索。更多信息，请参阅[应用程序 SLI](../../../development/application_slis/_index.md)。

| 指标 | 类型 | 引入版本 | 标签 | 描述 |
|:-------|:-----|------:|:-------|:------------|
| `gitlab_sli_global_search_apdex_success_total` | Counter | 14.4 | `search_type`, `search_level`, `search_scope`, `endpoint_id` | 满足延迟目标（代码搜索为 15.52 秒）的 Zoekt 搜索总数。按 `search_type="zoekt"` 过滤 |
| `gitlab_sli_global_search_apdex_total` | Counter | 14.4 | `search_type`, `search_level`, `search_scope`, `endpoint_id` | Zoekt 搜索 Apdex 测量总数。按 `search_type="zoekt"` 过滤 |
| `gitlab_sli_global_search_error_total` | Counter | 14.4 | `search_type`, `search_level`, `search_scope`, `endpoint_id` | Zoekt 搜索错误测量总数。按 `search_type="zoekt"` 过滤 |
| `gitlab_sli_global_search_total` | Counter | 14.4 | `search_type`, `search_level`, `search_scope`, `endpoint_id` | 全局搜索错误率测量总数。将 `gitlab_sli_global_search_error_total` 除以 `gitlab_sli_global_search_total` 可得到错误率。按 `search_type="zoekt"` 过滤 |

<a id="zoekt-task-sli-metrics"></a>

### Zoekt 任务 SLI 指标

这些指标的 Apdex 目标为 `APDEX_THRESHOLD_S`，定义于 `ee/lib/gitlab/metrics/zoekt_tasks_slis.rb`。当该常量发生变化时，请更新本节。

| 指标 | 类型 | 引入版本 | 标签 | 描述 |
|:-------|:-----|------:|:-------|:------------|
| `gitlab_sli_search_zoekt_tasks_apdex_success_total` | Counter | 18.10 | `zoekt_node`, `task_type` | 在 7200 秒（两小时）目标内完成的 Zoekt 索引任务总数 |
| `gitlab_sli_search_zoekt_tasks_apdex_total` | Counter | 18.10 | `zoekt_node`, `task_type` | Zoekt 索引任务 Apdex 测量总数 |
| `gitlab_sli_search_zoekt_tasks_error_total` | Counter | 18.10 | `zoekt_node`, `task_type` | Zoekt 索引任务错误总数 |
| `gitlab_sli_search_zoekt_tasks_total` | Counter | 18.10 | `zoekt_node`, `task_type` | Zoekt 索引任务错误率测量总数。将 `gitlab_sli_search_zoekt_tasks_error_total` 除以 `gitlab_sli_search_zoekt_tasks_total` 可得到错误率 |
| `gitlab_sli_search_zoekt_tasks_requests_total` | Counter | 18.10 | `zoekt_node`, `task_type` | 添加到队列中的 Zoekt 任务总数 |
| `gitlab_search_zoekt_task_duration_seconds` | Histogram | 19.5 | `zoekt_node`, `task_type` | Zoekt 索引任务从计划时间到完成之间的秒数 |

<a id="audit-event-streaming-sli-metrics"></a>

### 审计事件流式传输 SLI 指标

这些 SLI 跟踪 NATS 审计事件流式传输流水线。更多信息，请参阅[应用程序 SLI](../../../development/application_slis/_index.md)。

| 指标 | 类型 | 引入版本 | 标签 | 描述 |
|:-------|:-----|------:|:-------|:------------|
| `gitlab_sli_audit_event_streaming_nats_dispatch_apdex_success_total` | Counter | 19.3 | `feature_category` | 满足消费者滞后目标的审计事件批量分发总数 |
| `gitlab_sli_audit_event_streaming_nats_dispatch_apdex_total` | Counter | 19.3 | `feature_category` | 审计事件批量分发 Apdex 测量总数 |
| `gitlab_sli_audit_event_streaming_nats_dispatch_error_total` | Counter | 19.3 | `feature_category` | 失败的审计事件批量分发总数 |
| `gitlab_sli_audit_event_streaming_nats_dispatch_total` | Counter | 19.3 | `feature_category` | 审计事件批量分发尝试总数 |

<a id="metrics-controlled-by-a-feature-flag"></a>

## 由功能标志控制的指标

以下指标可以由功能标志控制：

| 指标                                       | 功能标志 |
|:---------------------------------------------|:-------------|
| `gitlab_view_rendering_duration_seconds`     | `prometheus_metrics_view_instrumentation` |
| `gitlab_ci_queue_depth_total`                | `gitlab_ci_builds_queuing_metrics` |
| `gitlab_ci_queue_size`                       | `gitlab_ci_builds_queuing_metrics` |
| `gitlab_ci_queue_size_total`                 | `gitlab_ci_builds_queuing_metrics` |
| `gitlab_ci_queue_iteration_duration_seconds` | `gitlab_ci_builds_queuing_metrics` |
| `gitlab_ci_current_queue_size`               | `gitlab_ci_builds_queuing_metrics` |
| `gitlab_ci_queue_retrieval_duration_seconds` | `gitlab_ci_builds_queuing_metrics` |
| `gitlab_ci_queue_active_runners_total`       | `gitlab_ci_builds_queuing_metrics` |
| `gitaly_circuit_breaker_requests_total`      | `add_circuit_breaker_to_gitaly`    |
| `gitaly_circuit_breaker_transitions_total`   | `add_circuit_breaker_to_gitaly`    |
| `ruby_gvl_wait_seconds_total`                | `enable_sidekiq_gvl_metrics`       |
| `ruby_gvl_wait_seconds_total`                | `enable_puma_gvl_metrics`          |

<a id="praefect-metrics"></a>

## Praefect 指标

您可以[配置 Praefect](../../gitaly/praefect/configure.md#praefect) 以报告指标。有关可用指标的信息，请参阅[监控 Gitaly 集群（Praefect）](../../gitaly/praefect/monitoring.md)。

<a id="sidekiq-metrics"></a>

## Sidekiq 指标

Sidekiq 作业也可能收集指标，如果启用了 Sidekiq exporter，则可以访问这些指标：例如，使用 `gitlab.yml` 中的 `monitoring.sidekiq_exporter` 配置选项。这些指标从已配置端口上的 `/metrics` 路径提供。

| 指标 | 类型 | 引入版本 | 标签 | 描述 |
|:---------------------------------------------------------|:----------|:------|:------------------------------------------------------------------------------------------|:------------|
| `destroyed_job_artifacts_count_total`                    | Counter   | 13.6  |                                                                                           | 已销毁的过期作业产物数量 |
| `destroyed_pipeline_artifacts_count_total`               | Counter   | 13.8  |                                                                                           | 已销毁的过期流水线产物数量 |
| `geo_ci_secure_files_checksum_failed`                    | Gauge     | 15.3  | `url`                                                                                     | 主站点上校验和计算失败的安全文件数量 |
| `geo_ci_secure_files_checksum_total`                     | Gauge     | 15.3  | `url`                                                                                     | 主站点上需要计算校验和的安全文件数量 |
| `geo_ci_secure_files_checksummed`                        | Gauge     | 15.3  | `url`                                                                                     | 主站点上成功计算校验和的安全文件数量 |
| `geo_ci_secure_files_failed`                             | Gauge     | 15.3  | `url`                                                                                     | 从站点上同步失败的可同步安全文件数量 |
| `geo_ci_secure_files_registry`                           | Gauge     | 15.3  | `url`                                                                                     | 注册表中的安全文件数量 |
| `geo_ci_secure_files_synced`                             | Gauge     | 15.3  | `url`                                                                                     | 从站点上已同步的可同步安全文件数量 |
| `geo_ci_secure_files_verification_failed`                | Gauge     | 15.3  | `url`                                                                                     | 从站点上验证失败的安全文件数量 |
| `geo_ci_secure_files_verification_total`                 | Gauge     | 15.3  | `url`                                                                                     | 从站点上需要尝试验证的安全文件数量 |
| `geo_ci_secure_files_verified`                           | Gauge     | 15.3  | `url`                                                                                     | 从站点上成功验证的安全文件数量 |
| `geo_ci_secure_files`                                    | Gauge     | 15.3  | `url`                                                                                     | 主站点上的安全文件数量 |
| `geo_container_repositories_checksum_failed`             | Gauge     | 15.10 | `url`                                                                                     | 主站点上校验和计算失败的容器仓库数量 |
| `geo_container_repositories_checksum_total`              | Gauge     | 15.10 | `url`                                                                                     | 主站点上成功计算校验和的容器仓库数量 |
| `geo_container_repositories_checksummed`                 | Gauge     | 15.10 | `url`                                                                                     | 主站点上尝试计算校验和的容器仓库数量 |
| `geo_container_repositories_failed`                      | Gauge     | 15.4  | `url`                                                                                     | 从站点上同步失败的可同步容器仓库数量 |
| `geo_container_repositories_registry`                    | Gauge     | 15.4  | `url`                                                                                     | 注册表中的容器仓库数量 |
| `geo_container_repositories_synced`                      | Gauge     | 15.4  | `url`                                                                                     | 从站点上已同步的容器仓库数量 |
| `geo_container_repositories_verification_failed`         | Gauge     | 15.10 | `url`                                                                                     | 从站点上验证失败的容器仓库数量 |
| `geo_container_repositories_verification_total`          | Gauge     | 15.10 | `url`                                                                                     | 从站点上尝试验证的容器仓库数量 |
| `geo_container_repositories_verified`                    | Gauge     | 15.10 | `url`                                                                                     | 从站点上已验证的容器仓库数量 |
| `geo_container_repositories`                             | Gauge     | 15.4  | `url`                                                                                     | 主站点上的容器仓库数量 |
| `geo_cursor_last_event_id`                               | Gauge     | 10.2  | `url`                                                                                     | 从站点已处理的事件日志的最后一个数据库 ID |
| `geo_cursor_last_event_timestamp`                        | Gauge     | 10.2  | `url`                                                                                     | 从站点已处理的事件日志的最后一个 UNIX 时间戳 |
| `geo_db_replication_lag_seconds`                         | Gauge     | 10.2  | `url`                                                                                     | 数据库复制延迟（秒） |
| `geo_dependency_proxy_blob_checksum_failed`              | Gauge     | 15.6  |                                                                                           | 主站点上校验和计算失败的依赖代理 blob 数量 |
| `geo_dependency_proxy_blob_checksum_total`               | Gauge     | 15.6  |                                                                                           | 主站点上需要计算校验和的依赖代理 blob 数量 |
| `geo_dependency_proxy_blob_checksummed`                  | Gauge     | 15.6  |                                                                                           | 主站点上成功计算校验和的依赖代理 blob 数量 |
| `geo_dependency_proxy_blob_failed`                       | Gauge     | 15.6  |                                                                                           | 从站点上同步失败的依赖代理 blob 数量 |
| `geo_dependency_proxy_blob_registry`                     | Gauge     | 15.6  |                                                                                           | 注册表中的依赖代理 blob 数量 |
| `geo_dependency_proxy_blob_synced`                       | Gauge     | 15.6  |                                                                                           | 从站点上已同步的依赖代理 blob 数量 |
| `geo_dependency_proxy_blob_verification_failed`          | Gauge     | 15.6  |                                                                                           | 从站点上验证失败的依赖代理 blob 数量 |
| `geo_dependency_proxy_blob_verification_total`           | Gauge     | 15.6  |                                                                                           | 从站点上需要尝试验证的依赖代理 blob 数量 |
| `geo_dependency_proxy_blob_verified`                     | Gauge     | 15.6  |                                                                                           | 从站点上成功验证的依赖代理 blob 数量 |
| `geo_dependency_proxy_blob`                              | Gauge     | 15.6  |                                                                                           | 主站点上的依赖代理 blob 数量 |
| `geo_dependency_proxy_manifests_checksum_failed`         | Gauge     | 15.6  | `url`                                                                                     | 主站点上校验和计算失败的依赖代理清单数量 |
| `geo_dependency_proxy_manifests_checksum_total`          | Gauge     | 15.6  | `url`                                                                                     | 主站点上需要计算校验和的依赖代理清单数量 |
| `geo_dependency_proxy_manifests_checksummed`             | Gauge     | 15.6  | `url`                                                                                     | 主站点上成功计算校验和的依赖代理清单数量 |
| `geo_dependency_proxy_manifests_failed`                  | Gauge     | 15.6  | `url`                                                                                     | 从站点上同步失败的可同步依赖代理清单数量 |
| `geo_dependency_proxy_manifests_registry`                | Gauge     | 15.6  | `url`                                                                                     | 注册表中的依赖代理清单数量 |
| `geo_dependency_proxy_manifests_synced`                  | Gauge     | 15.6  | `url`                                                                                     | 从站点上已同步的可同步依赖代理清单数量 |
| `geo_dependency_proxy_manifests_verification_failed`     | Gauge     | 15.6  | `url`                                                                                     | 从站点上验证失败的依赖代理清单数量 |
| `geo_dependency_proxy_manifests_verification_total`      | Gauge     | 15.6  | `url`                                                                                     | 从站点上需要尝试验证的依赖代理清单数量 |
| `geo_dependency_proxy_manifests_verified`                | Gauge     | 15.6  | `url`                                                                                     | 从站点上成功验证的依赖代理清单数量 |
| `geo_dependency_proxy_manifests`                         | Gauge     | 15.6  | `url`                                                                                     | 主站点上的依赖代理清单数量 |
| `geo_design_management_repositories_checksum_failed`     | Gauge     | 16.1  | `url`                                                                                     | 主站点上校验和计算失败的设计仓库数量 |
| `geo_design_management_repositories_checksum_total`      | Gauge     | 16.1  | `url`                                                                                     | 主站点上尝试计算校验和的设计仓库数量 |
| `geo_design_management_repositories_checksummed`         | Gauge     | 16.1  | `url`                                                                                     | 主站点上成功计算校验和的设计仓库数量 |
| `geo_design_management_repositories_failed`              | Gauge     | 16.1  | `url`                                                                                     | 从站点上同步失败的可同步设计仓库数量 |
| `geo_design_management_repositories_registry`            | Gauge     | 16.1  | `url`                                                                                     | 注册表中的设计仓库数量 |
| `geo_design_management_repositories_synced`              | Gauge     | 16.1  | `url`                                                                                     | 从站点上已同步的可同步设计仓库数量 |
| `geo_design_management_repositories_verification_failed` | Gauge     | 16.1  | `url`                                                                                     | 从站点上验证失败的设计仓库数量 |
| `geo_design_management_repositories_verification_total`  | Gauge     | 16.1  | `url`                                                                                     | 从站点上尝试验证的设计仓库数量 |
| `geo_design_management_repositories_verified`            | Gauge     | 16.1  | `url`                                                                                     | 从站点上已验证的设计仓库数量 |
| `geo_design_management_repositories`                     | Gauge     | 16.1  | `url`                                                                                     | 主站点上的设计仓库数量 |
| `geo_group_wiki_repositories_checksum_failed`            | Gauge     | 13.10 | `url`                                                                                     | 主站点上校验和计算失败的群组 Wiki 数量 |
| `geo_group_wiki_repositories_checksum_total`             | Gauge     | 16.3  | `url`                                                                                     | 主站点上需要计算校验和的群组 Wiki 数量 |
| `geo_group_wiki_repositories_checksummed`                | Gauge     | 13.10 | `url`                                                                                     | 主站点上成功计算校验和的群组 Wiki 数量 |
| `geo_group_wiki_repositories_failed`                     | Gauge     | 13.10 | `url`                                                                                     | 从站点上同步失败的可同步群组 Wiki 数量 |
| `geo_group_wiki_repositories_registry`                   | Gauge     | 13.10 | `url`                                                                                     | 注册表中的群组 Wiki 数量 |
| `geo_group_wiki_repositories_synced`                     | Gauge     | 13.10 | `url`                                                                                     | 从站点上已同步的可同步群组 Wiki 数量 |
| `geo_group_wiki_repositories_verification_failed`        | Gauge     | 16.3  | `url`                                                                                     | 从站点上验证失败的群组 Wiki 数量 |
| `geo_group_wiki_repositories_verification_total`         | Gauge     | 16.3  | `url`                                                                                     | 从站点上需要尝试验证的群组 Wiki 数量 |
| `geo_group_wiki_repositories_verified`                   | Gauge     | 16.3  | `url`                                                                                     | 从站点上成功验证的群组 Wiki 数量 |
| `geo_group_wiki_repositories`                            | Gauge     | 13.10 | `url`                                                                                     | 主站点上的群组 Wiki 数量 |
| `geo_job_artifacts_checksum_failed`                      | Gauge     | 14.8  | `url`                                                                                     | 主站点上校验和计算失败的作业产物数量 |
| `geo_job_artifacts_checksum_total`                       | Gauge     | 14.8  | `url`                                                                                     | 主站点上需要计算校验和的作业产物数量 |
| `geo_job_artifacts_checksummed`                          | Gauge     | 14.8  | `url`                                                                                     | 主站点上成功计算校验和的作业产物数量 |
| `geo_job_artifacts_failed`                               | Gauge     | 14.8  | `url`                                                                                     | 从站点上同步失败的可同步作业产物数量 |
| `geo_job_artifacts_registry`                             | Gauge     | 14.8  | `url`                                                                                     | 注册表中的作业产物数量 |
| `geo_job_artifacts_synced`                               | Gauge     | 14.8  | `url`                                                                                     | 从站点上已同步的可同步作业产物数量 |
| `geo_job_artifacts_verification_failed`                  | Gauge     | 14.8  | `url`                                                                                     | 从站点上验证失败的作业产物数量 |
| `geo_job_artifacts_verification_total`                   | Gauge     | 14.8  | `url`                                                                                     | 从站点上需要尝试验证的作业产物数量 |
| `geo_job_artifacts_verified`                             | Gauge     | 14.8  | `url`                                                                                     | 从站点上成功验证的作业产物数量 |
| `geo_job_artifacts`                                      | Gauge     | 14.8  | `url`                                                                                     | 主站点上的作业产物数量 |
| `geo_last_event_id`                                      | Gauge     | 10.2  | `url`                                                                                     | 主站点上最新事件日志条目的数据库 ID |
| `geo_last_event_timestamp`                               | Gauge     | 10.2  | `url`                                                                                     | 主站点上最新事件日志条目的 UNIX 时间戳 |
| `geo_last_successful_status_check_timestamp`             | Gauge     | 10.2  | `url`                                                                                     | 状态成功更新的最后时间戳 |
| `geo_lfs_objects_checksum_failed`                        | Gauge     | 14.6  | `url`                                                                                     | 主站点上校验和计算失败的 LFS 对象数量 |
| `geo_lfs_objects_checksum_total`                         | Gauge     | 14.6  | `url`                                                                                     | 主站点上需要计算校验和的 LFS 对象数量 |
| `geo_lfs_objects_checksummed`                            | Gauge     | 14.6  | `url`                                                                                     | 主站点上成功计算校验和的 LFS 对象数量 |
| `geo_lfs_objects_failed`                                 | Gauge     | 10.2  | `url`                                                                                     | 从站点上同步失败的可同步 LFS 对象数量 |
| `geo_lfs_objects_registry`                               | Gauge     | 14.6  | `url`                                                                                     | 注册表中的 LFS 对象数量 |
| `geo_lfs_objects_synced`                                 | Gauge     | 10.2  | `url`                                                                                     | 从站点上已同步的可同步 LFS 对象数量 |
| `geo_lfs_objects_verification_failed`                    | Gauge     | 14.6  | `url`                                                                                     | 从站点上验证失败的 LFS 对象数量 |
| `geo_lfs_objects_verification_total`                     | Gauge     | 14.6  | `url`                                                                                     | 从站点上需要尝试验证的 LFS 对象数量 |
| `geo_lfs_objects_verified`                               | Gauge     | 14.6  | `url`                                                                                     | 从站点上成功验证的 LFS 对象数量 |
| `geo_lfs_objects`                                        | Gauge     | 10.2  | `url`                                                                                     | 主站点上的 LFS 对象数量 |
| `geo_merge_request_diffs_checksum_failed`                | Gauge     | 13.4  | `url`                                                                                     | 主站点上校验和计算失败的合并请求差异数量 |
| `geo_merge_request_diffs_checksum_total`                 | Gauge     | 13.12 | `url`                                                                                     | 主站点上需要计算校验和的合并请求差异数量 |
| `geo_merge_request_diffs_checksummed`                    | Gauge     | 13.4  | `url`                                                                                     | 主站点上成功计算校验和的合并请求差异数量 |
| `geo_merge_request_diffs_failed`                         | Gauge     | 13.4  | `url`                                                                                     | 从站点上同步失败的可同步合并请求差异数量 |
| `geo_merge_request_diffs_registry`                       | Gauge     | 13.4  | `url`                                                                                     | 注册表中的合并请求差异数量 |
| `geo_merge_request_diffs_synced`                         | Gauge     | 13.4  | `url`                                                                                     | 从站点上已同步的可同步合并请求差异数量 |
| `geo_merge_request_diffs_verification_failed`            | Gauge     | 13.12 | `url`                                                                                     | 从站点上验证失败的合并请求差异数量 |
| `geo_merge_request_diffs_verification_total`             | Gauge     | 13.12 | `url`                                                                                     | 从站点上需要尝试验证的合并请求差异数量 |
| `geo_merge_request_diffs_verified`                       | Gauge     | 13.12 | `url`                                                                                     | 从站点上成功验证的合并请求差异数量 |
| `geo_merge_request_diffs`                                | Gauge     | 13.4  | `url`                                                                                     | 主站点上的合并请求差异数量 |
| `geo_package_files_checksum_failed`                      | Gauge     | 13.0  | `url`                                                                                     | 主站点上校验和计算失败的软件包文件数量 |
| `geo_package_files_checksummed`                          | Gauge     | 13.0  | `url`                                                                                     | 主站点上已计算校验和的软件包文件数量 |
| `geo_package_files_failed`                               | Gauge     | 13.3  | `url`                                                                                     | 从站点上同步失败的可同步软件包文件数量 |
| `geo_package_files_registry`                             | Gauge     | 13.3  | `url`                                                                                     | 注册表中的软件包文件数量 |
| `geo_package_files_synced`                               | Gauge     | 13.3  | `url`                                                                                     | 从站点上已同步的可同步软件包文件数量 |
| `geo_package_files`                                      | Gauge     | 13.0  | `url`                                                                                     | 主站点上的软件包文件数量 |
| `geo_packages_nuget_symbols`                             | Gauge     | 18.6  | `url`                                                                                     | 主站点上的 NuGet 符号文件数量 |
| `geo_packages_nuget_symbols_checksum_total`              | Gauge     | 18.6  | `url`                                                                                     | 主站点上需要计算校验和的 NuGet 符号文件数量 |
| `geo_packages_nuget_symbols_checksummed`                 | Gauge     | 18.6  | `url`                                                                                     | 主站点上成功计算校验和的 NuGet 符号文件数量 |
| `geo_packages_nuget_symbols_checksum_failed`             | Gauge     | 18.6  | `url`                                                                                     | 主站点上校验和计算失败的 NuGet 符号文件数量 |
| `geo_packages_nuget_symbols_synced`                      | Gauge     | 18.6  | `url`                                                                                     | 从站点上已同步的可同步 NuGet 符号文件数量 |
| `geo_packages_nuget_symbols_failed`                      | Gauge     | 18.6  | `url`                                                                                     | 从站点上同步失败的可同步 NuGet 符号文件数量 |
| `geo_packages_nuget_symbols_registry`                    | Gauge     | 18.6  | `url`                                                                                     | 注册表中的 NuGet 符号文件数量 |
| `geo_packages_nuget_symbols_verification_total`          | Gauge     | 18.6  | `url`                                                                                     | 从站点上需要尝试验证的 NuGet 符号文件数量 |
| `geo_packages_nuget_symbols_verified`                    | Gauge     | 18.6  | `url`                                                                                     | 从站点上成功验证的 NuGet 符号文件数量 |
| `geo_packages_nuget_symbols_verification_failed`         | Gauge     | 18.6  | `url`                                                                                     | 从站点上验证失败的 NuGet 符号文件数量 |
| `geo_packages_helm_metadata_caches`                      | Gauge     | 18.9  | `url`                                                                                     | 主站点上的 Helm 元数据缓存数量 |
| `geo_packages_helm_metadata_caches_checksum_total`       | Gauge     | 18.9  | `url`                                                                                     | 主站点上需要计算校验和的 Helm 元数据缓存数量 |
| `geo_packages_helm_metadata_caches_checksummed`          | Gauge     | 18.9  | `url`                                                                                     | 主站点上成功计算校验和的 Helm 元数据缓存数量 |
| `geo_packages_helm_metadata_caches_checksum_failed`      | Gauge     | 18.9  | `url`                                                                                     | 主站点上校验和计算失败的 Helm 元数据缓存数量 |
| `geo_packages_helm_metadata_caches_synced`               | Gauge     | 18.9  | `url`                                                                                     | 从站点上已同步的可同步 Helm 元数据缓存数量 |
| `geo_packages_helm_metadata_caches_failed`               | Gauge     | 18.9  | `url`                                                                                     | 从站点上同步失败的可同步 Helm 元数据缓存数量 |
| `geo_packages_helm_metadata_caches_registry`             | Gauge     | 18.9  | `url`                                                                                     | 注册表中的 Helm 元数据缓存数量 |
| `geo_packages_helm_metadata_caches_verification_total`   | Gauge     | 18.9  | `url`                                                                                     | 从站点上需要尝试验证的 Helm 元数据缓存数量 |
| `geo_packages_helm_metadata_caches_verified`             | Gauge     | 18.9  | `url`                                                                                     | 从站点上成功验证的 Helm 元数据缓存数量 |
| `geo_packages_helm_metadata_caches_verification_failed`  | Gauge     | 18.9  | `url`                                                                                     | 从站点上验证失败的 Helm 元数据缓存数量 |
| `geo_pages_deployments_checksum_failed`                  | Gauge     | 14.6  | `url`                                                                                     | 主站点上校验和计算失败的 Pages 部署数量 |
| `geo_pages_deployments_checksum_total`                   | Gauge     | 14.6  | `url`                                                                                     | 主站点上需要计算校验和的 Pages 部署数量 |
| `geo_pages_deployments_checksummed`                      | Gauge     | 14.6  | `url`                                                                                     | 主站点上成功计算校验和的 Pages 部署数量 |
| `geo_pages_deployments_failed`                           | Gauge     | 14.3  | `url`                                                                                     | 从站点上同步失败的可同步 Pages 部署数量 |
| `geo_pages_deployments_registry`                         | Gauge     | 14.3  | `url`                                                                                     | 注册表中的 Pages 部署数量 |
| `geo_pages_deployments_synced`                           | Gauge     | 14.3  | `url`                                                                                     | 从站点上已同步的可同步 Pages 部署数量 |
| `geo_pages_deployments_verification_failed`              | Gauge     | 14.6  | `url`                                                                                     | 从站点上验证失败的 Pages 部署数量 |
| `geo_pages_deployments_verification_total`               | Gauge     | 14.6  | `url`                                                                                     | 从站点上需要尝试验证的 Pages 部署数量 |
| `geo_pages_deployments_verified`                         | Gauge     | 14.6  | `url`                                                                                     | 从站点上成功验证的 Pages 部署数量 |
| `geo_pages_deployments`                                  | Gauge     | 14.3  | `url`                                                                                     | 主站点上的 Pages 部署数量 |
| `geo_project_repositories_checksum_failed`               | Gauge     | 16.2  | `url`                                                                                     | 主站点上校验和计算失败的项目代码仓库数量 |
| `geo_project_repositories_checksum_total`                | Gauge     | 16.2  | `url`                                                                                     | 主站点上需要计算校验和的项目代码仓库数量 |
| `geo_project_repositories_checksummed`                   | Gauge     | 16.2  | `url`                                                                                     | 主站点上成功计算校验和的项目代码仓库数量 |
| `geo_project_repositories_failed`                        | Gauge     | 16.2  | `url`                                                                                     | 从站点上同步失败的可同步项目代码仓库数量 |
| `geo_project_repositories_registry`                      | Gauge     | 16.2  | `url`                                                                                     | 注册表中的项目代码仓库数量 |
| `geo_project_repositories_synced`                        | Gauge     | 16.2  | `url`                                                                                     | 从站点上已同步的可同步项目代码仓库数量 |
| `geo_project_repositories_verification_failed`           | Gauge     | 16.2  | `url`                                                                                     | 从站点上验证失败的项目代码仓库数量 |
| `geo_project_repositories_verification_total`            | Gauge     | 16.2  | `url`                                                                                     | 从站点上需要尝试验证的项目代码仓库数量 |
| `geo_project_repositories_verified`                      | Gauge     | 16.2  | `url`                                                                                     | 从站点上成功验证的项目代码仓库数量 |
| `geo_project_repositories`                               | Gauge     | 16.2  | `url`                                                                                     | 主站点上的项目代码仓库数量 |
| `geo_project_wiki_repositories_checksum_failed`          | Gauge     | 15.10 | `url`                                                                                     | 主站点上校验和计算失败的项目 Wiki 代码仓库数量 |
| `geo_project_wiki_repositories_checksum_total`           | Gauge     | 15.10 | `url`                                                                                     | 主站点上需要计算校验和的项目 Wiki 代码仓库数量 |
| `geo_project_wiki_repositories_checksummed`              | Gauge     | 15.10 | `url`                                                                                     | 主站点上成功计算校验和的项目 Wiki 代码仓库数量 |
| `geo_project_wiki_repositories_failed`                   | Gauge     | 15.10 | `url`                                                                                     | 从站点上同步失败的可同步项目 Wiki 代码仓库数量 |
| `geo_project_wiki_repositories_registry`                 | Gauge     | 15.10 | `url`                                                                                     | 注册表中的项目 Wiki 代码仓库数量 |
| `geo_project_wiki_repositories_synced`                   | Gauge     | 15.10 | `url`                                                                                     | 从站点上已同步的可同步项目 Wiki 代码仓库数量 |
| `geo_project_wiki_repositories_verification_failed`      | Gauge     | 15.10 | `url`                                                                                     | 从站点上验证失败的项目 Wiki 代码仓库数量 |
| `geo_project_wiki_repositories_verification_total`       | Gauge     | 15.10 | `url`                                                                                     | 从站点上需要尝试验证的项目 Wiki 代码仓库数量 |
| `geo_project_wiki_repositories_verified`                 | Gauge     | 15.10 | `url`                                                                                     | 从站点上成功验证的项目 Wiki 代码仓库数量 |
| `geo_project_wiki_repositories`                          | Gauge     | 15.10 | `url`                                                                                     | 主站点上的项目 Wiki 代码仓库数量 |
| `geo_repositories_checksum_failed`                       | Gauge     | 10.7  | `url`                                                                                     | 已弃用，计划于 17.0 移除。在 16.3 和 16.4 中缺失。由 `geo_project_repositories_checksum_failed` 替代。主站点上校验和计算失败的代码仓库数量 |
| `geo_repositories_checksummed`                           | Gauge     | 10.7  | `url`                                                                                     | 已弃用，计划于 17.0 移除。在 16.3 和 16.4 中缺失。由 `geo_project_repositories_checksummed` 替代。主站点上已计算校验和的代码仓库数量 |
| `geo_repositories_failed`                                | Gauge     | 10.2  | `url`                                                                                     | 已弃用，计划于 17.0 移除。在 16.3 和 16.4 中缺失。由 `geo_project_repositories_failed` 替代。从站点上同步失败的代码仓库数量 |
| `geo_repositories_synced`                                | Gauge     | 10.2  | `url`                                                                                     | 已弃用，计划于 17.0 移除。在 16.3 和 16.4 中缺失。由 `geo_project_repositories_synced` 替代。从站点上已同步的代码仓库数量 |
| `geo_repositories_verification_failed`                   | Gauge     | 10.7  | `url`                                                                                     | 已弃用，计划于 17.0 移除。在 16.3 和 16.4 中缺失。由 `geo_project_repositories_verification_failed` 替代。从站点上验证失败的代码仓库数量 |
| `geo_repositories_verified`                              | Gauge     | 10.7  | `url`                                                                                     | 已弃用，计划于 17.0 移除。在 16.3 和 16.4 中缺失。由 `geo_project_repositories_verified` 替代。从站点上成功验证的代码仓库数量 |
| `geo_repositories`                                       | Gauge     | 10.2  | `url`                                                                                     | 已于 17.9 弃用。未来移除该指标的极狐GitLab 版本尚未确定。请改用 `geo_project_repositories`。主站点上可用的代码仓库总数 |
| `geo_snippet_repositories_checksum_failed`               | Gauge     | 13.4  | `url`                                                                                     | 主站点上校验和计算失败的代码片段数量 |
| `geo_snippet_repositories_checksummed`                   | Gauge     | 13.4  | `url`                                                                                     | 主站点上已计算校验和的代码片段数量 |
| `geo_snippet_repositories_failed`                        | Gauge     | 13.4  | `url`                                                                                     | 从站点上失败的可同步代码片段数量 |
| `geo_snippet_repositories_registry`                      | Gauge     | 13.4  | `url`                                                                                     | 注册表中的可同步代码片段数量 |
| `geo_snippet_repositories_synced`                        | Gauge     | 13.4  | `url`                                                                                     | 从站点上已同步的可同步代码片段数量 |
| `geo_snippet_repositories`                               | Gauge     | 13.4  | `url`                                                                                     | 主站点上的代码片段数量 |
| `geo_abuse_report_uploads`                               | Gauge     | 18.10 | `url`                                                                                     | 主站点上的滥用举报上传数量 |
| `geo_abuse_report_uploads_checksum_total`                | Gauge     | 18.10 | `url`                                                                                     | 主站点上需要计算校验和的滥用举报上传数量 |
| `geo_abuse_report_uploads_checksummed`                   | Gauge     | 18.10 | `url`                                                                                     | 主站点上成功计算校验和的滥用举报上传数量 |
| `geo_abuse_report_uploads_checksum_failed`               | Gauge     | 18.10 | `url`                                                                                     | 主站点上校验和计算失败的滥用举报上传数量 |
| `geo_abuse_report_uploads_synced`                        | Gauge     | 18.10 | `url`                                                                                     | 从站点上已同步的可同步滥用举报上传数量 |
| `geo_abuse_report_uploads_failed`                        | Gauge     | 18.10 | `url`                                                                                     | 从站点上同步失败的可同步滥用举报上传数量 |
| `geo_abuse_report_uploads_registry`                      | Gauge     | 18.10 | `url`                                                                                     | 注册表中的滥用举报上传数量 |
| `geo_abuse_report_uploads_verification_total`            | Gauge     | 18.10 | `url`                                                                                     | 从站点上需要尝试验证的滥用举报上传数量 |
| `geo_abuse_report_uploads_verified`                      | Gauge     | 18.10 | `url`                                                                                     | 从站点上成功验证的滥用举报上传数量 |
| `geo_abuse_report_uploads_verification_failed`           | Gauge     | 18.10 | `url`                                                                                     | 从站点上验证失败的滥用举报上传数量 |
| `geo_project_uploads`                                    | Gauge     | 18.10 | `url`                                                                                     | 主站点上的项目上传数量 |
| `geo_project_uploads_checksum_total`                     | Gauge     | 18.10 | `url`                                                                                     | 主站点上需要计算校验和的项目上传数量 |
| `geo_project_uploads_checksummed`                        | Gauge     | 18.10 | `url`                                                                                     | 主站点上成功计算校验和的项目上传数量 |
| `geo_project_uploads_checksum_failed`                    | Gauge     | 18.10 | `url`                                                                                     | 主站点上校验和计算失败的项目上传数量 |
| `geo_project_uploads_synced`                             | Gauge     | 18.10 | `url`                                                                                     | 从站点上已同步的可同步项目上传数量 |
| `geo_project_uploads_failed`                             | Gauge     | 18.10 | `url`                                                                                     | 从站点上同步失败的可同步项目上传数量 |
| `geo_project_uploads_registry`                           | Gauge     | 18.10 | `url`                                                                                     | 注册表中的项目上传数量 |
| `geo_project_uploads_verification_total`                 | Gauge     | 18.10 | `url`                                                                                     | 从站点上需要尝试验证的项目上传数量 |
| `geo_project_uploads_verified`                           | Gauge     | 18.10 | `url`                                                                                     | 从站点上成功验证的项目上传数量 |
| `geo_project_uploads_verification_failed`                | Gauge     | 18.10 | `url`                                                                                     | 从站点上验证失败的项目上传数量 |
| `geo_group_uploads`                                      | Gauge     | 18.11 | `url`                                                                                     | 主站点上的群组上传数量 |
| `geo_group_uploads_checksum_total`                       | Gauge     | 18.11 | `url`                                                                                     | 主站点上需要计算校验和的群组上传数量 |
| `geo_group_uploads_checksummed`                          | Gauge     | 18.11 | `url`                                                                                     | 主站点上成功计算校验和的群组上传数量 |
| `geo_group_uploads_checksum_failed`                      | Gauge     | 18.11 | `url`                                                                                     | 主站点上校验和计算失败的群组上传数量 |
| `geo_group_uploads_synced`                               | Gauge     | 18.11 | `url`                                                                                     | 从站点上已同步的可同步群组上传数量 |
| `geo_group_uploads_failed`                               | Gauge     | 18.11 | `url`                                                                                     | 从站点上同步失败的可同步群组上传数量 |
| `geo_group_uploads_registry`                             | Gauge     | 18.11 | `url`                                                                                     | 注册表中的群组上传数量 |
| `geo_group_uploads_verification_total`                   | Gauge     | 18.11 | `url`                                                                                     | 从站点上需要尝试验证的群组上传数量 |
| `geo_group_uploads_verified`                             | Gauge     | 18.11 | `url`                                                                                     | 从站点上成功验证的群组上传数量 |
| `geo_group_uploads_verification_failed`                  | Gauge     | 18.11 | `url`                                                                                     | 从站点上验证失败的群组上传数量 |
| `geo_user_uploads`                                       | Gauge     | 18.11 | `url`                                                                                     | 主站点上的用户上传数量 |
| `geo_user_uploads_checksum_total`                        | Gauge     | 18.11 | `url`                                                                                     | 主站点上需要计算校验和的用户上传数量 |
| `geo_user_uploads_checksummed`                           | Gauge     | 18.11 | `url`                                                                                     | 主站点上成功计算校验和的用户上传数量 |
| `geo_user_uploads_checksum_failed`                       | Gauge     | 18.11 | `url`                                                                                     | 主站点上校验和计算失败的用户上传数量 |
| `geo_user_uploads_synced`                                | Gauge     | 18.11 | `url`                                                                                     | 从站点上已同步的可同步用户上传数量 |
| `geo_user_uploads_failed`                                | Gauge     | 18.11 | `url`                                                                                     | 从站点上同步失败的可同步用户上传数量 |
| `geo_user_uploads_registry`                              | Gauge     | 18.11 | `url`                                                                                     | 注册表中的用户上传数量 |
| `geo_user_uploads_verification_total`                    | Gauge     | 18.11 | `url`                                                                                     | 从站点上需要尝试验证的用户上传数量 |
| `geo_user_uploads_verified`                              | Gauge     | 18.11 | `url`                                                                                     | 从站点上成功验证的用户上传数量 |
| `geo_user_uploads_verification_failed`                   | Gauge     | 18.11 | `url`                                                                                     | 从站点上验证失败的用户上传数量 |
| `geo_design_management_action_uploads`                   | Gauge     | 18.11 | `url`                                                                                     | 主站点上的设计管理操作上传数量 |
| `geo_design_management_action_uploads_checksum_total`    | Gauge     | 18.11 | `url`                                                                                     | 主站点上需要计算校验和的设计管理操作上传数量 |
| `geo_design_management_action_uploads_checksummed`       | Gauge     | 18.11 | `url`                                                                                     | 主站点上成功计算校验和的设计管理操作上传数量 |
| `geo_design_management_action_uploads_checksum_failed`   | Gauge     | 18.11 | `url`                                                                                     | 主站点上校验和计算失败的设计管理操作上传数量 |
| `geo_design_management_action_uploads_synced`            | Gauge     | 18.11 | `url`                                                                                     | 从站点上已同步的可同步设计管理操作上传数量 |
| `geo_design_management_action_uploads_failed`            | Gauge     | 18.11 | `url`                                                                                     | 从站点上同步失败的可同步设计管理操作上传数量 |
| `geo_design_management_action_uploads_registry`          | Gauge     | 18.11 | `url`                                                                                     | 注册表中的设计管理操作上传数量 |
| `geo_design_management_action_uploads_verification_total`| Gauge     | 18.11 | `url`                                                                                     | 从站点上需要尝试验证的设计管理操作上传数量 |
| `geo_design_management_action_uploads_verified`          | Gauge     | 18.11 | `url`                                                                                     | 从站点上成功验证的设计管理操作上传数量 |
| `geo_design_management_action_uploads_verification_failed`| Gauge     | 18.11 | `url`                                                                                     | 从站点上验证失败的设计管理操作上传数量 |
| `geo_bulk_import_export_upload_uploads`                  | Gauge     | 19.0 | `url`                                                                                     | 主站点上的批量导入/导出归档文件数量 |
| `geo_bulk_import_export_upload_uploads_checksum_total`   | Gauge     | 19.0 | `url`                                                                                     | 主站点上需要计算校验和的批量导入/导出归档文件数量 |
| `geo_bulk_import_export_upload_uploads_checksummed`      | Gauge     | 19.0 | `url`                                                                                     | 主站点上成功计算校验和的批量导入/导出归档文件数量 |
| `geo_bulk_import_export_upload_uploads_checksum_failed`  | Gauge     | 19.0 | `url`                                                                                     | 主站点上校验和计算失败的批量导入/导出归档文件数量 |
| `geo_bulk_import_export_upload_uploads_synced`           | Gauge     | 19.0 | `url`                                                                                     | 从站点上已同步的可同步批量导入/导出归档文件数量 |
| `geo_bulk_import_export_upload_uploads_failed`           | Gauge     | 19.0 | `url`                                                                                     | 从站点上同步失败的可同步批量导入/导出归档文件数量 |
| `geo_bulk_import_export_upload_uploads_registry`         | Gauge     | 19.0 | `url`                                                                                     | 注册表中的批量导入/导出归档文件数量 |
| `geo_bulk_import_export_upload_uploads_verification_total`| Gauge     | 19.0 | `url`                                                                                     | 从站点上需要尝试验证的批量导入/导出归档文件数量 |
| `geo_bulk_import_export_upload_uploads_verified`         | Gauge     | 19.0 | `url`                                                                                     | 从站点上成功验证的批量导入/导出归档文件数量 |
| `geo_bulk_import_export_upload_uploads_verification_failed`| Gauge     | 19.0 | `url`                                                                                     | 从站点上验证失败的批量导入/导出归档文件数量 |
| `geo_achievement_uploads`                                | Gauge     | 18.11 | `url`                                                                                     | 主站点上的成就上传数量 |
| `geo_achievement_uploads_checksum_total`                 | Gauge     | 18.11 | `url`                                                                                     | 主站点上需要计算校验和的成就上传数量 |
| `geo_achievement_uploads_checksummed`                    | Gauge     | 18.11 | `url`                                                                                     | 主站点上成功计算校验和的成就上传数量 |
| `geo_achievement_uploads_checksum_failed`                | Gauge     | 18.11 | `url`                                                                                     | 主站点上校验和计算失败的成就上传数量 |
| `geo_achievement_uploads_synced`                         | Gauge     | 18.11 | `url`                                                                                     | 从站点上已同步的可同步成就上传数量 |
| `geo_achievement_uploads_failed`                         | Gauge     | 18.11 | `url`                                                                                     | 从站点上同步失败的可同步成就上传数量 |
| `geo_achievement_uploads_registry`                       | Gauge     | 18.11 | `url`                                                                                     | 注册表中的成就上传数量 |
| `geo_achievement_uploads_verification_total`             | Gauge     | 18.11 | `url`                                                                                     | 需要在从站点尝试验证的成就上传数量 |
| `geo_achievement_uploads_verified`                       | Gauge     | 18.11 | `url`                                                                                     | 在从站点成功验证的成就上传数量 |
| `geo_achievement_uploads_verification_failed`            | Gauge     | 18.11 | `url`                                                                                     | 在从站点验证失败的成就上传数量 |
| `geo_import_export_upload_uploads`                       | Gauge     | 19.0  | `url`                                                                                     | 主站点上的导入/导出归档上传数量 |
| `geo_import_export_upload_uploads_checksum_total`        | Gauge     | 19.0  | `url`                                                                                     | 需要在主站点计算校验和的导入/导出归档上传数量 |
| `geo_import_export_upload_uploads_checksummed`           | Gauge     | 19.0  | `url`                                                                                     | 在主站点成功计算校验和的导入/导出归档上传数量 |
| `geo_import_export_upload_uploads_checksum_failed`       | Gauge     | 19.0  | `url`                                                                                     | 在主站点计算校验和失败的导入/导出归档上传数量 |
| `geo_import_export_upload_uploads_synced`                | Gauge     | 19.0  | `url`                                                                                     | 在从站点同步的可同步导入/导出归档上传数量 |
| `geo_import_export_upload_uploads_failed`                | Gauge     | 19.0  | `url`                                                                                     | 在从站点同步失败的可同步导入/导出归档上传数量 |
| `geo_import_export_upload_uploads_registry`              | Gauge     | 19.0  | `url`                                                                                     | 注册表中的导入/导出归档上传数量 |
| `geo_import_export_upload_uploads_verification_total`    | Gauge     | 19.0  | `url`                                                                                     | 需要在从站点尝试验证的导入/导出归档上传数量 |
| `geo_import_export_upload_uploads_verified`              | Gauge     | 19.0  | `url`                                                                                     | 在从站点成功验证的导入/导出归档上传数量 |
| `geo_import_export_upload_uploads_verification_failed`   | Gauge     | 19.0  | `url`                                                                                     | 在从站点验证失败的导入/导出归档上传数量 |
| `geo_vulnerability_archive_export_uploads`               | Gauge     | 19.0 | `url`                                                                                     | 主站点上的漏洞归档导出上传数量 |
| `geo_vulnerability_archive_export_uploads_checksum_total`| Gauge     | 19.0 | `url`                                                                                     | 需要在主站点计算校验和的漏洞归档导出上传数量 |
| `geo_vulnerability_archive_export_uploads_checksummed`   | Gauge     | 19.0 | `url`                                                                                     | 在主站点成功计算校验和的漏洞归档导出上传数量 |
| `geo_vulnerability_archive_export_uploads_checksum_failed`| Gauge     | 19.0 | `url`                                                                                     | 在主站点计算校验和失败的漏洞归档导出上传数量 |
| `geo_vulnerability_archive_export_uploads_synced`        | Gauge     | 19.0 | `url`                                                                                     | 在从站点同步的可同步漏洞归档导出上传数量 |
| `geo_vulnerability_archive_export_uploads_failed`        | Gauge     | 19.0 | `url`                                                                                     | 在从站点同步失败的可同步漏洞归档导出上传数量 |
| `geo_vulnerability_archive_export_uploads_registry`      | Gauge     | 19.0 | `url`                                                                                     | 注册表中的漏洞归档导出上传数量 |
| `geo_vulnerability_archive_export_uploads_verification_total`| Gauge     | 19.0 | `url`                                                                                     | 需要在从站点尝试验证的漏洞归档导出上传数量 |
| `geo_vulnerability_archive_export_uploads_verified`      | Gauge     | 19.0 | `url`                                                                                     | 在从站点成功验证的漏洞归档导出上传数量 |
| `geo_vulnerability_archive_export_uploads_verification_failed`| Gauge     | 19.0 | `url`                                                                                     | 在从站点验证失败的漏洞归档导出上传数量 |
| `geo_project_import_export_relation_export_upload_uploads`| Gauge     | 19.0 | `url`                                                                                     | 主站点上的项目导入导出关系导出上传数量 |
| `geo_project_import_export_relation_export_upload_uploads_checksum_total`| Gauge     | 19.0 | `url`                                                                                     | 需要在主站点计算校验和的项目导入导出关系导出上传数量 |
| `geo_project_import_export_relation_export_upload_uploads_checksummed`| Gauge     | 19.0 | `url`                                                                                     | 在主站点成功计算校验和的项目导入导出关系导出上传数量 |
| `geo_project_import_export_relation_export_upload_uploads_checksum_failed`| Gauge     | 19.0 | `url`                                                                                     | 在主站点计算校验和失败的项目导入导出关系导出上传数量 |
| `geo_project_import_export_relation_export_upload_uploads_synced`| Gauge     | 19.0 | `url`                                                                                     | 在从站点同步的可同步项目导入导出关系导出上传数量 |
| `geo_project_import_export_relation_export_upload_uploads_failed`| Gauge     | 19.0 | `url`                                                                                     | 在从站点同步失败的可同步项目导入导出关系导出上传数量 |
| `geo_project_import_export_relation_export_upload_uploads_registry`| Gauge     | 19.0 | `url`                                                                                     | 注册表中的项目导入导出关系导出上传数量 |
| `geo_project_import_export_relation_export_upload_uploads_verification_total`| Gauge     | 19.0 | `url`                                                                                     | 需要在从站点尝试验证的项目导入导出关系导出上传数量 |
| `geo_project_import_export_relation_export_upload_uploads_verified`| Gauge     | 19.0 | `url`                                                                                     | 在从站点成功验证的项目导入导出关系导出上传数量 |
| `geo_project_import_export_relation_export_upload_uploads_verification_failed`| Gauge     | 19.0 | `url`                                                                                     | 在从站点验证失败的项目导入导出关系导出上传数量 |
| `geo_project_import_export_relation_export_upload_uploads_oldest_unsynced_time`| Gauge     | 19.0 | `url`                                                                                     | 从站点上最旧未同步项目导入导出关系导出上传的时间戳 |
| `geo_vulnerability_export_part_uploads`                  | Gauge     | 19.1 | `url`                                                                                     | 主站点上的漏洞导出分片上传数量 |
| `geo_vulnerability_export_part_uploads_checksum_total`   | Gauge     | 19.1 | `url`                                                                                     | 需要在主站点计算校验和的漏洞导出分片上传数量 |
| `geo_vulnerability_export_part_uploads_checksummed`      | Gauge     | 19.1 | `url`                                                                                     | 在主站点成功计算校验和的漏洞导出分片上传数量 |
| `geo_vulnerability_export_part_uploads_checksum_failed`  | Gauge     | 19.1 | `url`                                                                                     | 在主站点计算校验和失败的漏洞导出分片上传数量 |
| `geo_vulnerability_export_part_uploads_synced`           | Gauge     | 19.1 | `url`                                                                                     | 在从站点同步的可同步漏洞导出分片上传数量 |
| `geo_vulnerability_export_part_uploads_failed`           | Gauge     | 19.1 | `url`                                                                                     | 在从站点同步失败的可同步漏洞导出分片上传数量 |
| `geo_vulnerability_export_part_uploads_registry`         | Gauge     | 19.1 | `url`                                                                                     | 注册表中的漏洞导出分片上传数量 |
| `geo_vulnerability_export_part_uploads_verification_total`| Gauge     | 19.1 | `url`                                                                                     | 需要在从站点尝试验证的漏洞导出分片上传数量 |
| `geo_vulnerability_export_part_uploads_verified`         | Gauge     | 19.1 | `url`                                                                                     | 在从站点成功验证的漏洞导出分片上传数量 |
| `geo_vulnerability_export_part_uploads_verification_failed`| Gauge     | 19.1 | `url`                                                                                     | 在从站点验证失败的漏洞导出分片上传数量 |
| `geo_vulnerability_export_part_uploads_oldest_unsynced_time`| Gauge     | 19.1 | `url`                                                                                     | 从站点上最旧未同步漏洞导出分片上传的时间戳 |
| `geo_vulnerability_export_uploads`                       | Gauge     | 19.0 | `url`                                                                                     | 主站点上的漏洞导出上传数量 |
| `geo_vulnerability_export_uploads_checksum_total`        | Gauge     | 19.0 | `url`                                                                                     | 需要在主站点计算校验和的漏洞导出上传数量 |
| `geo_vulnerability_export_uploads_checksummed`           | Gauge     | 19.0 | `url`                                                                                     | 在主站点成功计算校验和的漏洞导出上传数量 |
| `geo_vulnerability_export_uploads_checksum_failed`       | Gauge     | 19.0 | `url`                                                                                     | 在主站点计算校验和失败的漏洞导出上传数量 |
| `geo_vulnerability_export_uploads_synced`                | Gauge     | 19.0 | `url`                                                                                     | 在从站点同步的可同步漏洞导出上传数量 |
| `geo_vulnerability_export_uploads_failed`                | Gauge     | 19.0 | `url`                                                                                     | 在从站点同步失败的可同步漏洞导出上传数量 |
| `geo_vulnerability_export_uploads_registry`              | Gauge     | 19.0 | `url`                                                                                     | 注册表中的漏洞导出上传数量 |
| `geo_vulnerability_export_uploads_verification_total`    | Gauge     | 19.0 | `url`                                                                                     | 需要在从站点尝试验证的漏洞导出上传数量 |
| `geo_vulnerability_export_uploads_verified`              | Gauge     | 19.0 | `url`                                                                                     | 在从站点成功验证的漏洞导出上传数量 |
| `geo_vulnerability_export_uploads_verification_failed`   | Gauge     | 19.0 | `url`                                                                                     | 在从站点验证失败的漏洞导出上传数量 |
| `geo_user_permission_export_upload_uploads`              | Gauge     | 19.0 | `url`                                                                                     | 主站点上的用户权限导出上传数量 |
| `geo_user_permission_export_upload_uploads_checksum_total`| Gauge     | 19.0 | `url`                                                                                     | 需要在主站点计算校验和的用户权限导出上传数量 |
| `geo_user_permission_export_upload_uploads_checksummed`  | Gauge     | 19.0 | `url`                                                                                     | 在主站点成功计算校验和的用户权限导出上传数量 |
| `geo_user_permission_export_upload_uploads_checksum_failed`| Gauge     | 19.0 | `url`                                                                                     | 在主站点计算校验和失败的用户权限导出上传数量 |
| `geo_user_permission_export_upload_uploads_synced`       | Gauge     | 19.0 | `url`                                                                                     | 在从站点同步的可同步用户权限导出上传数量 |
| `geo_user_permission_export_upload_uploads_failed`       | Gauge     | 19.0 | `url`                                                                                     | 在从站点同步失败的可同步用户权限导出上传数量 |
| `geo_user_permission_export_upload_uploads_registry`     | Gauge     | 19.0 | `url`                                                                                     | 注册表中的用户权限导出上传数量 |
| `geo_user_permission_export_upload_uploads_verification_total`| Gauge     | 19.0 | `url`                                                                                     | 需要在从站点尝试验证的用户权限导出上传数量 |
| `geo_user_permission_export_upload_uploads_verified`     | Gauge     | 19.0 | `url`                                                                                     | 在从站点成功验证的用户权限导出上传数量 |
| `geo_user_permission_export_upload_uploads_verification_failed`| Gauge     | 19.0 | `url`                                                                                     | 在从站点验证失败的用户权限导出上传数量 |
| `geo_user_permission_export_upload_uploads_oldest_unsynced_time`| Gauge     | 19.0 | `url`                                                                                     | 从站点上最旧未同步用户权限导出上传的时间戳 |
| `geo_issuable_metric_image_uploads`                      | Gauge     | 19.1 | `url`                                                                                     | 主站点上的可议题化指标图片上传数量 |
| `geo_issuable_metric_image_uploads_checksum_total`       | Gauge     | 19.1 | `url`                                                                                     | 需要在主站点计算校验和的可议题化指标图片上传数量 |
| `geo_issuable_metric_image_uploads_checksummed`          | Gauge     | 19.1 | `url`                                                                                     | 在主站点成功计算校验和的可议题化指标图片上传数量 |
| `geo_issuable_metric_image_uploads_checksum_failed`      | Gauge     | 19.1 | `url`                                                                                     | 在主站点计算校验和失败的可议题化指标图片上传数量 |
| `geo_issuable_metric_image_uploads_synced`               | Gauge     | 19.1 | `url`                                                                                     | 在从站点同步的可同步可议题化指标图片上传数量 |
| `geo_issuable_metric_image_uploads_failed`               | Gauge     | 19.1 | `url`                                                                                     | 在从站点同步失败的可同步可议题化指标图片上传数量 |
| `geo_issuable_metric_image_uploads_registry`             | Gauge     | 19.1 | `url`                                                                                     | 注册表中的可议题化指标图片上传数量 |
| `geo_issuable_metric_image_uploads_verification_total`   | Gauge     | 19.1 | `url`                                                                                     | 需要在从站点尝试验证的可议题化指标图片上传数量 |
| `geo_issuable_metric_image_uploads_verified`             | Gauge     | 19.1 | `url`                                                                                     | 在从站点成功验证的可议题化指标图片上传数量 |
| `geo_issuable_metric_image_uploads_verification_failed`  | Gauge     | 19.1 | `url`                                                                                     | 在从站点验证失败的可议题化指标图片上传数量 |
| `geo_issuable_metric_image_uploads_oldest_unsynced_time` | Gauge     | 19.1 | `url`                                                                                     | 从站点上最旧未同步可议题化指标图片上传的时间戳 |
| `geo_dependency_list_export_uploads`                     | Gauge     | 19.1 | `url`                                                                                     | 主站点上的依赖列表导出上传数量 |
| `geo_dependency_list_export_uploads_checksum_total`      | Gauge     | 19.1 | `url`                                                                                     | 需要在主站点计算校验和的依赖列表导出上传数量 |
| `geo_dependency_list_export_uploads_checksummed`         | Gauge     | 19.1 | `url`                                                                                     | 在主站点成功计算校验和的依赖列表导出上传数量 |
| `geo_dependency_list_export_uploads_checksum_failed`     | Gauge     | 19.1 | `url`                                                                                     | 在主站点计算校验和失败的依赖列表导出上传数量 |
| `geo_dependency_list_export_uploads_synced`              | Gauge     | 19.1 | `url`                                                                                     | 在从站点同步的可同步依赖列表导出上传数量 |
| `geo_dependency_list_export_uploads_failed`              | Gauge     | 19.1 | `url`                                                                                     | 在从站点同步失败的可同步依赖列表导出上传数量 |
| `geo_dependency_list_export_uploads_registry`            | Gauge     | 19.1 | `url`                                                                                     | 注册表中的依赖列表导出上传数量 |
| `geo_dependency_list_export_uploads_verification_total`  | Gauge     | 19.1 | `url`                                                                                     | 需要在从站点尝试验证的依赖列表导出上传数量 |
| `geo_dependency_list_export_uploads_verified`            | Gauge     | 19.1 | `url`                                                                                     | 在从站点成功验证的依赖列表导出上传数量 |
| `geo_dependency_list_export_uploads_verification_failed` | Gauge     | 19.1 | `url`                                                                                     | 在从站点验证失败的依赖列表导出上传数量 |
| `geo_dependency_list_export_uploads_oldest_unsynced_time`| Gauge     | 19.1 | `url`                                                                                     | 从站点上最旧未同步依赖列表导出上传的时间戳 |
| `geo_packages_debian_project_component_files`                     | Gauge     | 19.1 | `url`                                                                                     | 主站点上的 Debian 项目组件文件数量 |
| `geo_packages_debian_project_component_files_checksum_total`      | Gauge     | 19.1 | `url`                                                                                     | 需要在主站点计算校验和的 Debian 项目组件文件数量 |
| `geo_packages_debian_project_component_files_checksummed`         | Gauge     | 19.1 | `url`                                                                                     | 在主站点成功计算校验和的 Debian 项目组件文件数量 |
| `geo_packages_debian_project_component_files_checksum_failed`     | Gauge     | 19.1 | `url`                                                                                     | 在主站点计算校验和失败的 Debian 项目组件文件数量 |
| `geo_packages_debian_project_component_files_synced`              | Gauge     | 19.1 | `url`                                                                                     | 在从站点同步的可同步 Debian 项目组件文件数量 |
| `geo_packages_debian_project_component_files_failed`              | Gauge     | 19.1 | `url`                                                                                     | 在从站点同步失败的可同步 Debian 项目组件文件数量 |
| `geo_packages_debian_project_component_files_registry`            | Gauge     | 19.1 | `url`                                                                                     | 注册表中的 Debian 项目组件文件数量 |
| `geo_packages_debian_project_component_files_verification_total`  | Gauge     | 19.1 | `url`                                                                                     | 需要在从站点尝试验证的 Debian 项目组件文件数量 |
| `geo_packages_debian_project_component_files_verified`            | Gauge     | 19.1 | `url`                                                                                     | 在从站点成功验证的 Debian 项目组件文件数量 |
| `geo_packages_debian_project_component_files_verification_failed` | Gauge     | 19.1 | `url`                                                                                     | 在从站点验证失败的 Debian 项目组件文件数量 |
| `geo_alert_management_metric_image_uploads`              | Gauge     | 19.1 | `url`                                                                                     | 主站点上的告警管理指标图片上传数量 |
| `geo_alert_management_metric_image_uploads_checksum_total`| Gauge     | 19.1 | `url`                                                                                     | 需要在主站点计算校验和的告警管理指标图片上传数量 |
| `geo_alert_management_metric_image_uploads_checksummed`  | Gauge     | 19.1 | `url`                                                                                     | 在主站点成功计算校验和的告警管理指标图片上传数量 |
| `geo_alert_management_metric_image_uploads_checksum_failed`| Gauge     | 19.1 | `url`                                                                                     | 在主站点计算校验和失败的告警管理指标图片上传数量 |
| `geo_alert_management_metric_image_uploads_synced`       | Gauge     | 19.1 | `url`                                                                                     | 在从站点同步的可同步告警管理指标图片上传数量 |
| `geo_alert_management_metric_image_uploads_failed`       | Gauge     | 19.1 | `url`                                                                                     | 在从站点同步失败的可同步告警管理指标图片上传数量 |
| `geo_alert_management_metric_image_uploads_registry`     | Gauge     | 19.1 | `url`                                                                                     | 注册表中的告警管理指标图片上传数量 |
| `geo_alert_management_metric_image_uploads_verification_total`| Gauge     | 19.1 | `url`                                                                                     | 需要在从站点尝试验证的告警管理指标图片上传数量 |
| `geo_alert_management_metric_image_uploads_verified`     | Gauge     | 19.1 | `url`                                                                                     | 在从站点成功验证的告警管理指标图片上传数量 |
| `geo_alert_management_metric_image_uploads_verification_failed`| Gauge     | 19.1 | `url`                                                                                     | 在从站点验证失败的告警管理指标图片上传数量 |
| `geo_alert_management_metric_image_uploads_oldest_unsynced_time`| Gauge     | 19.1 | `url`                                                                                     | 从站点上最旧未同步告警管理指标图片上传的时间戳 |
| `geo_personal_snippet_uploads`                           | Gauge     | 19.1 | `url`                                                                                     | 主站点上的个人代码片段上传数量 |
| `geo_personal_snippet_uploads_checksum_total`            | Gauge     | 19.1 | `url`                                                                                     | 需要在主站点计算校验和的个人代码片段上传数量 |
| `geo_personal_snippet_uploads_checksummed`               | Gauge     | 19.1 | `url`                                                                                     | 在主站点成功计算校验和的个人代码片段上传数量 |
| `geo_personal_snippet_uploads_checksum_failed`           | Gauge     | 19.1 | `url`                                                                                     | 在主站点计算校验和失败的个人代码片段上传数量 |
| `geo_personal_snippet_uploads_synced`                    | Gauge     | 19.1 | `url`                                                                                     | 在从站点同步的可同步个人代码片段上传数量 |
| `geo_personal_snippet_uploads_failed`                    | Gauge     | 19.1 | `url`                                                                                     | 在从站点同步失败的可同步个人代码片段上传数量 |
| `geo_personal_snippet_uploads_registry`                  | Gauge     | 19.1 | `url`                                                                                     | 注册表中的个人代码片段上传数量 |
| `geo_personal_snippet_uploads_verification_total`        | Gauge     | 19.1 | `url`                                                                                     | 需要在从站点尝试验证的个人代码片段上传数量 |
| `geo_personal_snippet_uploads_verified`                  | Gauge     | 19.1 | `url`                                                                                     | 在从站点成功验证的个人代码片段上传数量 |
| `geo_personal_snippet_uploads_verification_failed`       | Gauge     | 19.1 | `url`                                                                                     | 在从站点验证失败的个人代码片段上传数量 |
| `geo_personal_snippet_uploads_oldest_unsynced_time`      | Gauge     | 19.1 | `url`                                                                                     | 从站点上最旧未同步个人代码片段上传的时间戳 |
| `geo_project_topic_uploads`                              | Gauge     | 19.2 | `url`                                                                                     | 主站点上的项目主题上传数量 |
| `geo_project_topic_uploads_checksum_total`               | Gauge     | 19.2 | `url`                                                                                     | 需要在主站点计算校验和的项目主题上传数量 |
| `geo_project_topic_uploads_checksummed`                  | Gauge     | 19.2 | `url`                                                                                     | 在主站点成功计算校验和的项目主题上传数量 |
| `geo_project_topic_uploads_checksum_failed`              | Gauge     | 19.2 | `url`                                                                                     | 在主站点计算校验和失败的项目主题上传数量 |
| `geo_project_topic_uploads_synced`                       | Gauge     | 19.2 | `url`                                                                                     | 在从站点同步的可同步项目主题上传数量 |
| `geo_project_topic_uploads_failed`                       | Gauge     | 19.2 | `url`                                                                                     | 在从站点同步失败的可同步项目主题上传数量 |
| `geo_project_topic_uploads_registry`                     | Gauge     | 19.2 | `url`                                                                                     | 注册表中的项目主题上传数量 |
| `geo_project_topic_uploads_verification_total`           | Gauge     | 19.2 | `url`                                                                                     | 需要在从站点尝试验证的项目主题上传数量 |
| `geo_project_topic_uploads_verified`                     | Gauge     | 19.2 | `url`                                                                                     | 在从站点成功验证的项目主题上传数量 |
| `geo_project_topic_uploads_verification_failed`          | Gauge     | 19.2 | `url`                                                                                     | 在从站点验证失败的项目主题上传数量 |
| `geo_project_topic_uploads_oldest_unsynced_time`         | Gauge     | 19.2 | `url`                                                                                     | 从站点上最旧未同步项目主题上传的时间戳 |
| `geo_organization_detail_uploads`                        | Gauge     | 19.2 | `url`                                                                                     | 主站点上的组织详情上传数量 |
| `geo_organization_detail_uploads_checksum_total`         | Gauge     | 19.2 | `url`                                                                                     | 需要在主站点计算校验和的组织详情上传数量 |
| `geo_organization_detail_uploads_checksummed`            | Gauge     | 19.2 | `url`                                                                                     | 在主站点成功计算校验和的组织详情上传数量 |
| `geo_organization_detail_uploads_checksum_failed`        | Gauge     | 19.2 | `url`                                                                                     | 在主站点计算校验和失败的组织详情上传数量 |
| `geo_organization_detail_uploads_synced`                 | Gauge     | 19.2 | `url`                                                                                     | 在从站点同步的可同步组织详情上传数量 |
| `geo_organization_detail_uploads_failed`                 | Gauge     | 19.2 | `url`                                                                                     | 在从站点同步失败的可同步组织详情上传数量 |
| `geo_organization_detail_uploads_registry`               | Gauge     | 19.2 | `url`                                                                                     | 注册表中的组织详情上传数量 |
| `geo_organization_detail_uploads_verification_total`     | Gauge     | 19.2 | `url`                                                                                     | 需要在从站点尝试验证的组织详情上传数量 |
| `geo_organization_detail_uploads_verified`               | Gauge     | 19.2 | `url`                                                                                     | 在从站点成功验证的组织详情上传数量 |
| `geo_organization_detail_uploads_verification_failed`    | Gauge     | 19.2 | `url`                                                                                     | 在从站点验证失败的组织详情上传数量 |
| `geo_organization_detail_uploads_oldest_unsynced_time`   | Gauge     | 19.2 | `url`                                                                                     | 从站点上最旧未同步组织详情上传的时间戳 |
| `geo_dependency_list_export_part_uploads`                | Gauge     | 19.2 | `url`                                                                                     | 主站点上的依赖列表导出分片上传数量 |
| `geo_dependency_list_export_part_uploads_checksum_total` | Gauge     | 19.2 | `url`                                                                                     | 需要在主站点计算校验和的依赖列表导出分片上传数量 |
| `geo_dependency_list_export_part_uploads_checksummed`    | Gauge     | 19.2 | `url`                                                                                     | 在主站点成功计算校验和的依赖列表导出分片上传数量 |
| `geo_dependency_list_export_part_uploads_checksum_failed`| Gauge     | 19.2 | `url`                                                                                     | 在主站点计算校验和失败的依赖列表导出分片上传数量 |
| `geo_dependency_list_export_part_uploads_synced`         | Gauge     | 19.2 | `url`                                                                                     | 在从站点同步的可同步依赖列表导出分片上传数量 |
| `geo_dependency_list_export_part_uploads_failed`         | Gauge     | 19.2 | `url`                                                                                     | 在从站点同步失败的可同步依赖列表导出分片上传数量 |
| `geo_dependency_list_export_part_uploads_registry`       | Gauge     | 19.2 | `url`                                                                                     | 注册表中的依赖列表导出分片上传数量 |
| `geo_dependency_list_export_part_uploads_verification_total`| Gauge     | 19.2 | `url`                                                                                     | 需要在从站点尝试验证的依赖列表导出分片上传数量 |
| `geo_dependency_list_export_part_uploads_verified`       | Gauge     | 19.2 | `url`                                                                                     | 在从站点成功验证的依赖列表导出分片上传数量 |
| `geo_dependency_list_export_part_uploads_verification_failed`| Gauge     | 19.2 | `url`                                                                                     | 在从站点验证失败的依赖列表导出分片上传数量 |
| `geo_dependency_list_export_part_uploads_oldest_unsynced_time`| Gauge     | 19.2 | `url`                                                                                     | 从站点上最旧未同步依赖列表导出分片上传的时间戳 |
| `geo_vulnerability_remediation_uploads`                  | Gauge     | 19.2 | `url`                                                                                     | 主站点上的漏洞修复上传数量 |
| `geo_vulnerability_remediation_uploads_checksum_total`   | Gauge     | 19.2 | `url`                                                                                     | 需要在主站点计算校验和的漏洞修复上传数量 |
| `geo_vulnerability_remediation_uploads_checksummed`      | Gauge     | 19.2 | `url`                                                                                     | 在主站点成功计算校验和的漏洞修复上传数量 |
| `geo_vulnerability_remediation_uploads_checksum_failed`  | Gauge     | 19.2 | `url`                                                                                     | 在主站点计算校验和失败的漏洞修复上传数量 |
| `geo_vulnerability_remediation_uploads_synced`           | Gauge     | 19.2 | `url`                                                                                     | 在从站点同步的可同步漏洞修复上传数量 |
| `geo_vulnerability_remediation_uploads_failed`           | Gauge     | 19.2 | `url`                                                                                     | 在从站点同步失败的可同步漏洞修复上传数量 |
| `geo_vulnerability_remediation_uploads_registry`         | Gauge     | 19.2 | `url`                                                                                     | 注册表中的漏洞修复上传数量 |
| `geo_vulnerability_remediation_uploads_verification_total`| Gauge     | 19.2 | `url`                                                                                     | 需要在从站点尝试验证的漏洞修复上传数量 |
| `geo_vulnerability_remediation_uploads_verified`         | Gauge     | 19.2 | `url`                                                                                     | 在从站点成功验证的漏洞修复上传数量 |
| `geo_vulnerability_remediation_uploads_verification_failed`| Gauge     | 19.2 | `url`                                                                                     | 在从站点验证失败的漏洞修复上传数量 |
| `geo_vulnerability_remediation_uploads_oldest_unsynced_time`| Gauge     | 19.2 | `url`                                                                                     | 从站点上最旧未同步漏洞修复上传的时间戳 |
| `geo_appearance_uploads`                                 | Gauge     | 19.2 | `url`                                                                                     | 主站点上的外观上传数量 |
| `geo_appearance_uploads_checksum_total`                  | Gauge     | 19.2 | `url`                                                                                     | 需要在主站点计算校验和的外观上传数量 |
| `geo_appearance_uploads_checksummed`                     | Gauge     | 19.2 | `url`                                                                                     | 在主站点成功计算校验和的外观上传数量 |
| `geo_appearance_uploads_checksum_failed`                 | Gauge     | 19.2 | `url`                                                                                     | 在主站点计算校验和失败的外观上传数量 |
| `geo_appearance_uploads_synced`                          | Gauge     | 19.2 | `url`                                                                                     | 在从站点同步的可同步外观上传数量 |
| `geo_appearance_uploads_failed`                          | Gauge     | 19.2 | `url`                                                                                     | 在从站点同步失败的可同步外观上传数量 |
| `geo_appearance_uploads_registry`                        | Gauge     | 19.2 | `url`                                                                                     | 注册表中的外观上传数量 |
| `geo_appearance_uploads_verification_total`              | Gauge     | 19.2 | `url`                                                                                     | 需要在从站点尝试验证的外观上传数量 |
| `geo_appearance_uploads_verified`                        | Gauge     | 19.2 | `url`                                                                                     | 在从站点成功验证的外观上传数量 |
| `geo_appearance_uploads_verification_failed`             | Gauge     | 19.2 | `url`                                                                                     | 在从站点验证失败的外观上传数量 |
| `geo_appearance_uploads_oldest_unsynced_time`            | Gauge     | 19.2 | `url`                                                                                     | 从站点上最旧未同步外观上传的时间戳 |
| `geo_status_failed_total`                                | Counter   | 10.2  | `url`                                                                                     | 从 Geo 节点检索状态失败的次数 |
| `geo_terraform_state_versions_checksum_failed`           | Gauge     | 13.5  | `url`                                                                                     | 在主站点计算校验和失败的 Terraform 状态版本数量 |
| `geo_terraform_state_versions_checksum_total`            | Gauge     | 13.12 | `url`                                                                                     | 需要在主站点计算校验和的 Terraform 状态版本数量 |
| `geo_terraform_state_versions_checksummed`               | Gauge     | 13.5  | `url`                                                                                     | 在主站点成功计算校验和的 Terraform 状态版本数量 |
| `geo_terraform_state_versions_failed`                    | Gauge     | 13.5  | `url`                                                                                     | 在从站点同步失败的可同步 Terraform 状态版本数量 |
| `geo_terraform_state_versions_registry`                  | Gauge     | 13.5  | `url`                                                                                     | 注册表中的 Terraform 状态版本数量 |
| `geo_terraform_state_versions_synced`                    | Gauge     | 13.5  | `url`                                                                                     | 在从站点同步的可同步 Terraform 状态版本数量 |
| `geo_terraform_state_versions_verification_failed`       | Gauge     | 13.12 | `url`                                                                                     | 在从站点验证失败的 Terraform 状态版本数量 |
| `geo_terraform_state_versions_verification_total`        | Gauge     | 13.12 | `url`                                                                                     | 需要在从站点尝试验证的 Terraform 状态版本数量 |
| `geo_terraform_state_versions_verified`                  | Gauge     | 13.12 | `url`                                                                                     | 在从站点成功验证的 Terraform 状态版本数量 |
| `geo_terraform_state_versions`                           | Gauge     | 13.5  | `url`                                                                                     | 主站点上的 Terraform 状态版本数量 |
| `geo_uploads_checksum_failed`                            | Gauge     | 14.6  | `url`                                                                                     | 在主站点计算校验和失败的上传数量 |
| `geo_uploads_checksum_total`                             | Gauge     | 14.6  | `url`                                                                                     | 需要在主站点计算校验和的上传数量 |
| `geo_uploads_checksummed`                                | Gauge     | 14.6  | `url`                                                                                     | 在主站点成功计算校验和的上传数量 |
| `geo_uploads_failed`                                     | Gauge     | 14.1  | `url`                                                                                     | 在从站点同步失败的可同步上传数量 |
| `geo_uploads_registry`                                   | Gauge     | 14.1  | `url`                                                                                     | 注册表中的上传数量 |
| `geo_uploads_synced`                                     | Gauge     | 14.1  | `url`                                                                                     | 在从站点同步的上传数量 |
| `geo_uploads_verification_failed`                        | Gauge     | 14.6  | `url`                                                                                     | 在从站点验证失败的上传数量 |
| `geo_uploads_verification_total`                         | Gauge     | 14.6  | `url`                                                                                     | 需要在从站点尝试验证的上传数量 |
| `geo_uploads_verified`                                   | Gauge     | 14.6  | `url`                                                                                     | 在从站点成功验证的上传数量 |
| `geo_uploads`                                            | Gauge     | 14.1  | `url`                                                                                     | 主站点上的上传数量 |
| `gitlab_audit_event_streaming_worker_total`              | Counter   | 18.9  | `should_stream`, `should_persist`, `streamable`                                           | 由流式工作进程处理的审计事件 |
| `gitlab_ci_job_failure_reasons`                          | Counter   | 13.11 | `reason`, `runner_type`                                                                   | 作业失败原因计数器。也由 Rails 进程导出。有关 `reason` 标签值，请参见 [CI/CD 失败原因指标](#cicd-failure-reason-metrics) |
| `gitlab_ci_pipeline_failure_reasons`                     | Counter   | 13.11 | `reason`                                                                                  | 流水线失败原因计数器。也由 Rails 进程导出。有关 `reason` 标签值，请参见 [CI/CD 失败原因指标](#cicd-failure-reason-metrics) |
| `gitlab_ci_queue_active_runners_total`                   | Histogram | 16.3  |                                                                                           | 项目中可处理 CI/CD 队列的活动 Runner 数量 |
| `gitlab_maintenance_mode`                                | Gauge     | 15.11 |                                                                                           | 极狐GitLab 维护模式是否已启用？ |
| `gitlab_memwd_violations_handled_total`                  | Counter   | 15.9  |                                                                                           | Sidekiq 进程内存违规被处理的总次数 |
| `gitlab_memwd_violations_total`                          | Counter   | 15.9  |                                                                                           | Sidekiq 进程违反内存阈值的总次数 |
| `gitlab_optimistic_locking_retries`                      | Histogram | 13.10 |                                                                                           | 执行乐观重试锁的重试尝试次数 |
| `gitlab_pg_ash_consecutive_rotate_failures`              | Gauge     | 19.5  |                                                                                           | 连续失败的[活动会话历史](../performance/_index.md#active-session-history)分区轮换次数；成功轮换会将其重置 |
| `gitlab_pg_ash_insert_errors`                            | Gauge     | 19.4  |                                                                                           | `pg_ash` 在写入[活动会话历史](../performance/_index.md#active-session-history)样本时遇到的错误数量 |
| `gitlab_pg_ash_missed_samples`                           | Gauge     | 19.4  |                                                                                           | 在记录之前被中断的[活动会话历史](../performance/_index.md#active-session-history)样本数量 |
| `gitlab_pg_ash_sampler_errors_total`                     | Counter   | 19.4  |                                                                                           | 采集[活动会话历史](../performance/_index.md#active-session-history)样本时引发的错误数量 |
| `gitlab_pg_ash_skipped_samples`                          | Gauge     | 19.4  |                                                                                           | 因数据库中采样关闭而跳过的[活动会话历史](../performance/_index.md#active-session-history)样本数量 |
| `gitlab_transaction_event_receive_email_create_issue_total`                     | Counter   | 12.3  |                                                                                           | 用于创建议题的已接收邮件计数器 |
| `gitlab_transaction_event_receive_email_create_merge_request_total`             | Counter   | 12.3  |                                                                                           | 用于创建合并请求的已接收邮件计数器 |
| `gitlab_transaction_event_receive_email_create_note_issuable_total`             | Counter   | 12.3  |                                                                                           | 当邮件不是对通知的回复时，用于在议题上创建评论的已接收邮件计数器 |
| `gitlab_transaction_event_receive_email_create_note_total`                      | Counter   | 12.3  |                                                                                           | 当邮件是对通知的回复时，用于创建评论的已接收邮件计数器 |
| `gitlab_transaction_event_receive_email_service_desk_total`                     | Counter   | 12.3  |                                                                                           | 用于已接收服务台回复邮件的计数器 |
| `gitlab_transaction_event_receive_email_unsubscribe_total`                      | Counter   | 12.3  |                                                                                           | 用于退订邮件的计数器 |
| `gitlab_transaction_event_remote_mirrors_failed_total`   | Counter   | 10.8  |                                                                                           | 用于失败远程镜像的计数器 |
| `gitlab_transaction_event_remote_mirrors_finished_total` | Counter   | 10.8  |                                                                                           | 用于已完成远程镜像的计数器 |
| `gitlab_transaction_event_remote_mirrors_running_total`  | Counter   | 10.8  |                                                                                           | 用于运行中远程镜像的计数器 |
| `global_search_awaiting_indexing_queue_size`             | Gauge     | 13.2  |                                                                                           | 已在 18.7 中弃用并移除。由 `search_advanced_awaiting_indexing_queue_size` 替代。在索引暂停期间等待同步到 Elasticsearch 的数据库更新数量 |
| `global_search_bulk_cron_initial_queue_size`             | Gauge     | 13.1  |                                                                                           | 已在 18.7 中弃用并移除。由 `search_advanced_bulk_cron_initial_queue_size` 替代。等待同步到 Elasticsearch 的初始数据库更新数量 |
| `global_search_bulk_cron_queue_size`                     | Gauge     | 12.10 |                                                                                           | 已弃用，并在 18.7 中移除。由 `search_advanced_bulk_cron_queue_size` 取代。等待同步到 Elasticsearch 的增量数据库更新数量 |
| `limited_capacity_worker_max_running_jobs`               | Gauge     | 13.5  | `worker`                                                                                  | 正在运行的作业的最大数量 |
| `limited_capacity_worker_remaining_work_count`           | Gauge     | 13.5  | `worker`                                                                                  | 等待入队的作业数量 |
| `limited_capacity_worker_running_jobs`                   | Gauge     | 13.5  | `worker`                                                                                  | 正在运行的作业数量 |
| `search_advanced_awaiting_indexing_queue_size`           | Gauge     | 17.6  |                                                                                           | 索引暂停期间等待同步到 Elasticsearch 的数据库更新数量 |
| `search_advanced_bulk_cron_embedding_queue_size`         | Gauge     | 17.6  |                                                                                           | 等待同步到 Elasticsearch 的嵌入更新数量 |
| `search_advanced_bulk_cron_initial_queue_size`           | Gauge     | 17.6  |                                                                                           | 等待同步到 Elasticsearch 的初始数据库更新数量 |
| `search_advanced_bulk_cron_queue_size`                   | Gauge     | 17.6  |                                                                                           | 等待同步到 Elasticsearch 的增量数据库更新数量 |
| `sidekiq_concurrency_limit_current_concurrent_jobs`      | Gauge     | 17.6  | `worker`, `feature_category`                                                              | 当前并发运行的作业数量。 |
| `sidekiq_concurrency_limit_current_limit`                | Gauge     | 18.3  | `worker`, `feature_category`                                                              | 当前在节流限制下允许运行的并发作业数量 |
| `sidekiq_concurrency_limit_max_concurrent_jobs`          | Gauge     | 17.3  | `worker`, `feature_category`                                                              | 并发运行的 Sidekiq 作业的最大数量 |
| `sidekiq_concurrency_limit_queue_jobs`                   | Gauge     | 17.3  | `worker`, `feature_category`                                                              | 在并发限制队列中等待的 Sidekiq 作业数量 |
| `sidekiq_concurrency`                                    | Gauge     | 12.5  |                                                                                           | Sidekiq 作业的最大数量 |
| `sidekiq_elasticsearch_requests_duration_seconds`        | Histogram | 13.1  | `queue`, `boundary`, `external_dependencies`, `feature_category`, `job_status`, `urgency` | Sidekiq 作业在向 Elasticsearch 服务器发出的请求中所花费的时长（以秒为单位） |
| `sidekiq_elasticsearch_requests_total`                   | Counter   | 13.1  | `queue`, `boundary`, `external_dependencies`, `feature_category`, `job_status`, `urgency` | Sidekiq 作业执行期间的 Elasticsearch 请求 |
| `sidekiq_zoekt_requests_duration_seconds`                | Histogram | 19.2  | `queue`, `boundary`, `external_dependencies`, `feature_category`, `job_status`, `urgency`, `destination_shard_redis` | Sidekiq 作业在向 Zoekt 服务器发出的请求中所花费的时长（以秒为单位）。 |
| `sidekiq_zoekt_requests_total`                           | Counter   | 19.2  | `queue`, `boundary`, `external_dependencies`, `feature_category`, `job_status`, `urgency`, `destination_shard_redis` | Sidekiq 作业执行期间的 Zoekt 请求。 |
| `sidekiq_jobs_completion_seconds`                        | Histogram | 12.2  | `queue`, `boundary`, `external_dependencies`, `feature_category`, `job_status`, `urgency` | 完成 Sidekiq 作业所需的秒数 |
| `sidekiq_jobs_cpu_seconds`                               | Histogram | 12.4  | `queue`, `boundary`, `external_dependencies`, `feature_category`, `job_status`, `urgency` | 运行 Sidekiq 作业所需的 CPU 时间（以秒为单位） |
| `sidekiq_jobs_db_seconds`                                | Histogram | 12.9  | `queue`, `boundary`, `external_dependencies`, `feature_category`, `job_status`, `urgency` | 运行 Sidekiq 作业所需的数据库时间（以秒为单位） |
| `sidekiq_jobs_dead_total`                                | Counter   | 13.7  | `queue`, `boundary`, `external_dependencies`, `feature_category`, `urgency`               | Sidekiq 死信作业（已耗尽重试次数的作业） |
| `sidekiq_jobs_failed_total`                              | Counter   | 12.2  | `queue`, `boundary`, `external_dependencies`, `feature_category`, `urgency`               | 失败的 Sidekiq 作业 |
| `sidekiq_jobs_gitaly_seconds`                            | Histogram | 12.9  | `queue`, `boundary`, `external_dependencies`, `feature_category`, `job_status`, `urgency` | 运行 Sidekiq 作业所需的 Gitaly 时间（以秒为单位） |
| `sidekiq_jobs_interrupted_total`                         | Counter   | 15.2  | `queue`, `boundary`, `external_dependencies`, `feature_category`, `urgency`               | 被中断的 Sidekiq 作业 |
| `sidekiq_jobs_queue_duration_seconds`                    | Histogram | 12.5  | `queue`, `boundary`, `external_dependencies`, `feature_category`, `urgency`               | Sidekiq 作业在执行前排队等待的时长（以秒为单位） |
| `sidekiq_jobs_retried_total`                             | Counter   | 12.2  | `queue`, `boundary`, `external_dependencies`, `feature_category`, `urgency`               | 已重试的 Sidekiq 作业 |
| `sidekiq_jobs_skipped_total`                             | Counter   | 16.2  | `worker`, `action`, `feature_category`, `reason`                                          | 当 `drop_sidekiq_jobs` 功能标志启用或 `run_sidekiq_jobs` 功能标志禁用时，被跳过（丢弃或延迟）的作业数量 |
| `sidekiq_mem_total_bytes`                                | Gauge     | 15.3  |                                                                                           | 为占用对象槽位的对象以及需要 malloc 的对象所分配的字节数 |
| `sidekiq_redis_requests_duration_seconds`                | Histogram | 13.1  | `queue`, `boundary`, `external_dependencies`, `feature_category`, `job_status`, `urgency` | Sidekiq 作业在查询 Redis 服务器时所花费的时长（以秒为单位） |
| `sidekiq_redis_requests_total`                           | Counter   | 13.1  | `queue`, `boundary`, `external_dependencies`, `feature_category`, `job_status`, `urgency` | Sidekiq 作业执行期间的 Redis 请求 |
| `sidekiq_running_jobs`                                   | Gauge     | 12.2  | `queue`, `boundary`, `external_dependencies`, `feature_category`, `urgency`               | 正在运行的 Sidekiq 作业数量 |
| `sidekiq_throttling_events_total`                        | Counter   | 18.3  | `worker`, `strategy`                                                                      | Sidekiq 节流事件总数 |
| `sidekiq_watchdog_running_jobs_total`                    | Counter   | 15.9  | `worker_class`                                                                            | 达到 RSS 限制时正在运行的作业数量 |

<a id="database-load-balancing-metrics"></a>

## 数据库负载均衡指标

{{< details >}}

- Tier: 专业版，旗舰版
- Offering: 私有化部署

{{< /details >}}

以下指标可用：

| 指标 | 类型 | 引入版本 | 标签 | 描述 |
|:--------------------------------------------------------|:--------|:------------------------------------------------------------|:---------|:------------|
| `db_load_balancing_hosts`                               | Gauge   | [12.3](https://gitlab.com/gitlab-org/gitlab/-/issues/13630) |          | 当前负载均衡主机数 |
| `sidekiq_load_balancing_count`                          | Counter | 13.11                                                       | `queue`, `boundary`, `external_dependencies`, `feature_category`, `job_status`, `urgency`, `data_consistency`, `load_balancing_strategy` | 使用负载均衡且数据一致性设置为 `:sticky` 或 `:delayed`的 Sidekiq 作业数 |
| `gitlab_transaction_caught_up_replica_pick_count_total` | Counter | 14.1                                                        | `result` | 搜索已追平副本的尝试次数 |

<a id="database-partitioning-metrics"></a>

## 数据库分区指标

{{< details >}}

- Tier: 专业版，旗舰版
- Offering: 私有化部署

{{< /details >}}

以下指标可用：

| 指标 | 类型 | 引入版本 | 描述 |
|:------------------------|:------|:-------------------------------------------------------------|:------------|
| `db_partitions_present` | Gauge | [13.4](https://gitlab.com/gitlab-org/gitlab/-/issues/227353) | 当前存在的数据库分区数 |
| `db_partitions_missing` | Gauge | [13.4](https://gitlab.com/gitlab-org/gitlab/-/issues/227353) | 当前应有但缺失的数据库分区数 |

<a id="connection-pool-metrics"></a>

## 连接池指标

这些指标记录数据库[连接池](https://api.rubyonrails.org/classes/ActiveRecord/ConnectionAdapters/ConnectionPool.html)的状态，并且所有指标都具有以下标签：

- `class` - 被记录的 Ruby 类。
  - `ActiveRecord::Base` 是主数据库连接。
  - `Geo::TrackingBase` 是到 Geo 跟踪数据库的连接（如果已启用）。
- `host` - 用于连接数据库的主机名。
- `port` - 用于连接数据库的端口。

| 指标 | 类型 | 引入版本 | 描述 |
|:----------------------------------------------------|:------|:------|:------------|
| `gitlab_database_connection_pool_size`              | Gauge | 13.0  | 连接池总容量 |
| `gitlab_database_connection_pool_connections`       | Gauge | 13.0  | 池中已创建的连接数。[^idle-connection-count] |
| `gitlab_database_connection_pool_busy`              | Gauge | 13.0  | 使用中且所有者仍存活的连接数 |
| `gitlab_database_connection_pool_dead`              | Gauge | 13.0  | 使用中但所有者已不存活的连接数 |
| `gitlab_database_connection_pool_idle`              | Gauge | 13.0  | 已创建但当前未使用的连接数 |
| `gitlab_database_connection_pool_waiting`           | Gauge | 13.0  | 当前在此队列上等待的线程数 |
| `gitlab_database_extended_connection_pool_busy`     | Gauge | 18.11 | 使用中且所有者仍存活的连接数，按线程统计 |
| `gitlab_database_extended_connection_pool_dead`     | Gauge | 18.11 | 使用中但所有者已不存活的连接数，按线程统计 |

[^idle-connection-count]: 由于 `idle` 只统计已初始化但未使用的连接，因此 `busy`、`dead` 和 `idle` 连接的总数可能小于或等于连接总数。

在极狐GitLab 18.11 及更高版本中，默认连接池 Gauge 指标会跨 Puma 工作进程聚合，因此每个 Pod 只发出一个时间序列（而不是每个工作进程一个）。

聚合使用极狐GitLab 所使用的 [`prometheus-client-mmap`](https://gitlab.com/gitlab-org/ruby/gems/prometheus-client-mmap) 客户端支持的 [`multiprocess_mode`](https://github.com/prometheus/client_ruby#aggregation-settings-for-multi-process-stores) 设置：

- `gitlab_database_connection_pool_size` 使用 `min`。由于 Puma 工作进程在 fork 时使用相同配置，因此 Pod 中每个工作进程的此值都相同，所以 `min` 只是呈现该共享值。
- `gitlab_database_connection_pool_connections`、`gitlab_database_connection_pool_busy`、`gitlab_database_connection_pool_dead`、`gitlab_database_connection_pool_idle` 和 `gitlab_database_connection_pool_waiting` 使用 `max`（最坏情况的工作进程）。

由于这些值是每个 Pod 的最坏情况值，而不是跨工作进程的总和，因此在极狐GitLab 18.10 及更早版本中对每个工作进程序列求和的仪表板或告警（例如 `sum(gitlab_database_connection_pool_busy)`）现在会低估总数。

请勿尝试通过乘以 Puma 工作进程数来重建之前的总和。同一个 Pod 内的求和不能反映该 Pod 或整个集群的利用率，监控应针对最坏情况的工作进程。

如果单个工作进程的池达到饱和，那么无论同一 Pod 上的其他工作进程状态如何，该工作进程都无法处理请求。

对于连接池饱和监控，请使用 `busy` 加 `dead`，而不是 `connections` 减 `idle`。

`gitlab_database_extended_connection_pool_busy` 和 `gitlab_database_extended_connection_pool_dead` 指标包含一个 `thread_name` 标签，用于提供按线程的粒度。由于基数较高，这些指标默认处于禁用状态。要为一定百分比的 Pod 启用它们，请使用 `per_thread_db_connection_pool_metrics` [运维功能标志](../../../development/feature_flags/_index.md)。该标志的作用域为 `Feature.current_pod`，因此可以为一定百分比的 Pod 开启，而无需在整个集群范围内发出高基数序列。

<a id="ruby-metrics"></a>

## Ruby 指标

以下是一些基本的 Ruby 运行时指标：

| 指标 | 类型 | 引入版本 | 描述 |
|:------------------------------------------|:--------|:------|:------------|
| `ruby_gc_duration_seconds`                | Counter | 11.1  | Ruby 在 GC 中花费的时间 |
| `ruby_gc_stat_...`                        | Gauge   | 11.1  | 来自 [GC.stat](https://ruby-doc.org/core-2.6.5/GC.html#method-c-stat)的各种指标 |
| `ruby_gc_stat_ext_heap_fragmentation`     | Gauge   | 15.2  | Ruby 堆碎片程度，以存活对象与 eden 槽位之比表示（范围 0 到 1） |
| `ruby_gvl_wait_seconds_total`             | Gauge   | 19.4  | 此进程中所有线程等待全局 VM 锁所花费的秒数。[由功能标志控制](#metrics-controlled-by-a-feature-flag) |
| `ruby_file_descriptors`                   | Gauge   | 11.1  | 每个进程的文件描述符数 |
| `ruby_sampler_duration_seconds`           | Counter | 11.1  | 收集统计信息所花费的时间 |
| `ruby_process_cpu_seconds_total`          | Gauge   | 12.0  | 每个进程的 CPU 时间总量 |
| `ruby_process_max_fds`                    | Gauge   | 12.0  | 每个进程可打开的最大文件描述符数 |
| `ruby_process_resident_memory_bytes`      | Gauge   | 12.0  | 进程内存使用量（RSS/常驻集大小） |
| `ruby_process_resident_anon_memory_bytes` | Gauge   | 15.6  | 进程匿名内存使用量（RSS/常驻集大小） |
| `ruby_process_resident_file_memory_bytes` | Gauge   | 15.6  | 进程文件页内存使用量（RSS/常驻集大小） |
| `ruby_process_unique_memory_bytes`        | Gauge   | 13.0  | 进程内存使用量（USS/唯一集大小） |
| `ruby_process_proportional_memory_bytes`  | Gauge   | 13.0  | 进程内存使用量（PSS/比例集大小） |
| `ruby_process_start_time_seconds`         | Gauge   | 12.0  | 进程启动时间的 UNIX 时间戳 |

<a id="puma-metrics"></a>

## Puma 指标

| 指标 | 类型 | 引入版本 | 描述 |
|:--------------------------|:------|:------|:------------|
| `puma_workers`            | Gauge | 12.0  | 工作进程总数 |
| `puma_running_workers`    | Gauge | 12.0  | 已启动的工作进程数 |
| `puma_stale_workers`      | Gauge | 12.0  | 旧工作进程数 |
| `puma_running`            | Gauge | 12.0  | 运行中的线程数 |
| `puma_queued_connections` | Gauge | 12.0  | 该工作进程“待办”集合中等待工作线程的连接数 |
| `puma_active_connections` | Gauge | 12.0  | 正在处理请求的线程数 |
| `puma_pool_capacity`      | Gauge | 12.0  | 工作进程当前能够接受的请求数 |
| `puma_max_threads`        | Gauge | 12.0  | 工作线程最大数 |
| `puma_idle_threads`       | Gauge | 12.0  | 已生成但未在处理请求的线程数 |

<a id="redis-metrics"></a>

## Redis 指标

这些客户端指标旨在补充 Redis 服务器指标。这些指标按 [Redis 实例](../../redis/replication_and_failover.md#running-multiple-redis-clusters)细分。这些指标都有一个 `storage` 标签，用于指示 Redis 实例。例如 `cache` 或 `shared_state`。

| 指标 | 类型 | 引入版本 | 描述 |
|:--------------------------------------------------|:----------|:------|:------------|
| `gitlab_redis_client_exceptions_total`            | Counter   | 13.2  | Redis 客户端异常数，按异常类细分 |
| `gitlab_redis_client_requests_total`              | Counter   | 13.2  | Redis 客户端请求数 |
| `gitlab_redis_client_requests_duration_seconds`   | Histogram | 13.2  | Redis 请求延迟，不包括阻塞命令 |
| `gitlab_redis_client_redirections_total`          | Counter   | 15.10 | Redis Cluster MOVED/ASK 重定向次数，按重定向类型细分 |
| `gitlab_redis_client_requests_pipelined_commands` | Histogram | 16.4  | 发送到单个 Redis 服务器的每个流水线的命令数 |
| `gitlab_redis_client_pipeline_redirections_count` | Histogram | 17.0  | 一个流水线中的 Redis Cluster 重定向次数 |

<a id="git-lfs-metrics"></a>

## Git LFS 指标

用于跟踪各种 [Git LFS](https://git-lfs.com/) 功能的指标。

| 指标 | 类型 | 引入版本 | 描述 |
|:---------------------------------------------------|:--------|:------|:------------|
| `gitlab_sli_lfs_update_objects_total`              | Counter | 16.10 | 更新的 LFS 对象总数 |
| `gitlab_sli_lfs_update_objects_error_total`        | Counter | 16.10 | 更新的 LFS 对象错误总数 |
| `gitlab_sli_lfs_check_objects_total`               | Counter | 16.10 | 检查的 LFS 对象总数 |
| `gitlab_sli_lfs_check_objects_error_total`         | Counter | 16.10 | 检查的 LFS 对象错误总数 |
| `gitlab_sli_lfs_validate_link_objects_total`       | Counter | 16.10 | 已验证的 LFS 链接对象总数 |
| `gitlab_sli_lfs_validate_link_objects_error_total` | Counter | 16.10 | 已验证的 LFS 链接对象错误总数 |

<a id="secret-detection-partner-token-verification-metrics"></a>

## 密钥检测合作伙伴令牌验证指标

{{< details >}}

- Tier: 旗舰版
- Offering: JihuLab.com，私有化部署

{{< /details >}}

用于跟踪通过外部合作伙伴 API（AWS、GCP、Postman 等）进行密钥检测合作伙伴令牌验证的指标。

| 指标 | 类型 | 引入版本 | 标签 | 描述 |
|:--------------------------------------------------|:----------|:------|:----------------------------------------------|:------------|
| `validity_check_partner_api_duration_seconds`     | Histogram | 18.6  | `partner`                                     | 跟踪合作伙伴令牌验证请求的 API 响应时间。直方图桶：[0.1, 0.25, 0.5, 1, 2, 5, 10] 秒。 |
| `validity_check_partner_api_requests_total`       | Counter   | 18.6  | `partner`, `status`, `error_type`             | 合作伙伴 API 验证请求总数。`status` 可以是 `success` 或 `failure`。`error_type` 仅在失败时包含（例如 `network_error`、`rate_limit`、`response_error`）。 |
| `validity_check_network_errors_total`             | Counter   | 18.6  | `partner`, `error_class`                      | 合作伙伴 API 调用期间的网络错误总数。`error_class` 指示错误类型（例如 `Timeout`、`ConnectionRefused`、`HTTPError`）。 |
| `validity_check_rate_limit_hits_total`            | Counter   | 18.6  | `limit_type`                    | 令牌验证期间的速率限制命中总数。`limit_type` 对应合作伙伴速率限制键（例如 `partner_aws_api`、`partner_gcp_api`、`partner_postman_api`）。 |

<a id="partner-labels"></a>

### 合作伙伴标签

`partner` 标签可以具有以下值：

- `aws` - Amazon Web Services 令牌
- `gcp` - Google Cloud Platform 令牌
- `postman` - Postman API 令牌

<a id="metrics-shared-directory"></a>

## 指标共享目录

极狐GitLab Prometheus 客户端需要一个目录来存储多进程服务之间共享的指标数据。这些文件在 Puma 服务器下运行的所有实例之间共享。该目录必须可供所有正在运行的 Puma 进程访问，否则指标将无法正常工作。

此目录的位置通过环境变量 `prometheus_multiproc_dir` 配置。为获得最佳性能，请在 `tmpfs`中创建此目录。

如果极狐GitLab 使用 Linux 软件包安装，并且 `tmpfs` 可用，那么极狐GitLab 会为您配置指标目录。
