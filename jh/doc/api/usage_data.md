---
stage: Analytics
group: Analytics Instrumentation
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
title: Service Ping API
---

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: 私有化部署

{{< /details >}}

使用此 API 与极狐GitLab Service Ping 过程交互。

<a id="export-service-ping-data"></a>

## 导出 Service Ping 数据

{{< history >}}

- 在极狐GitLab 16.9 中引入。

{{< /history >}}

导出 Service Ping 收集的 JSON 负载。如果应用缓存中没有负载数据，则返回空响应。
如果负载数据为空，请确保已启用 [Service Ping 功能](../administration/settings/usage_statistics.md#enable-or-disable-service-ping)，并等待 cron 作业执行，或手动生成负载数据。

先决条件：

- 你必须使用具有 `read_service_ping` 范围的个人访问令牌进行认证。

```plaintext
GET /usage_data/service_ping
```

示例请求：

```shell
curl --request GET \
  --header "PRIVATE-TOKEN: <your_access_token>" \
  --url "https://gitlab.example.com/api/v4/usage_data/service_ping"
```

示例响应：

```json
  "recorded_at": "2024-01-15T23:33:50.387Z",
  "license": {},
  "counts": {
    "assignee_lists": 0,
    "ci_builds": 463,
    "ci_external_pipelines": 0,
    "ci_pipeline_config_auto_devops": 0,
    "ci_pipeline_config_repository": 0,
    "ci_triggers": 0,
    "ci_pipeline_schedules": 0
...
```

<a id="interpreting-schema-inconsistencies-metric"></a>

### 解读 `schema_inconsistencies_metric`

Service Ping JSON 负载包含 `schema_inconsistencies_metric`。数据库模式不一致是预期行为，不太可能表示实例存在问题。

此指标仅用于排查持续性问题，不应作为常规运行状况检查。只能在极狐GitLab 支持团队的指导下解读此指标。该指标报告与
[数据库模式检查 Rake 任务](../administration/raketasks/maintenance.md#check-the-database-for-schema-inconsistencies)相同的数据库模式不一致。

<a id="export-metric-definitions"></a>

## 导出指标定义

将所有指标定义导出为单个 YAML 文件，类似于 [Metrics Dictionary](https://metrics.gitlab.com/)，以便于导入。

```plaintext
GET /usage_data/metric_definitions
```

示例请求：

```shell
curl --request GET \
  --url "https://gitlab.example.com/api/v4/usage_data/metric_definitions"
```

示例响应：

```yaml
---
- key_path: redis_hll_counters.search.i_search_paid_monthly
  description: Calculated unique users to perform a search with a paid license enabled
    by month
  product_group: global_search
  value_type: number
  status: active
  time_frame: 28d
  data_source: redis_hll
  tier:
  - premium
  - ultimate
...
```

<a id="list-all-service-ping-sql-queries"></a>

## 列出所有 Service Ping SQL 查询

{{< history >}}

- 在极狐GitLab 13.11 中引入。
- [部署在功能标志](../administration/feature_flags/_index.md)之后，名为 `usage_data_queries_api`，默认禁用。

{{< /history >}}

列出用于计算 Service Ping 的所有原始 SQL 查询。此操作隐藏在
`usage_data_queries_api` 功能标志后，仅适用于极狐GitLab 实例的
[管理员](../user/permissions.md)用户。

```plaintext
GET /usage_data/queries
```

示例请求：

```shell
curl --request GET \
  --header "PRIVATE-TOKEN: <your_access_token>" \
  --url "https://gitlab.example.com/api/v4/usage_data/queries"
```

示例响应：

```json
{
  "recorded_at": "2021-03-23T06:31:21.267Z",
  "uuid": null,
  "hostname": "localhost",
  "version": "13.11.0-pre",
  "installation_type": "gitlab-development-kit",
  "active_user_count": "SELECT COUNT(\"users\".\"id\") FROM \"users\" WHERE (\"users\".\"state\" IN ('active')) AND (\"users\".\"user_type\" IS NULL OR \"users\".\"user_type\" IN (NULL, 6, 4))",
  "edition": "EE",
  "license_md5": "c701acc03844c45366dd175ef7a4e19c",
  "license_sha256": "366dd175ef7a4e19cc701acc03844c45366dd175ef7a4e19cc701acc03844c45",
  "license_id": null,
  "historical_max_users": 0,
  "licensee": {
    "Name": "John Doe1"
  },
  "license_user_count": null,
  "license_starts_at": "1970-01-01",
  "license_expires_at": "2022-02-23",
  "license_plan": "starter",
  "license_add_ons": {
    "GitLab_FileLocks": 1,
    "GitLab_Auditor_User": 1
  },
  "license_trial": null,
  "license_subscription_id": "0000",
  "license": {},
  "settings": {
    "ldap_encrypted_secrets_enabled": false,
    "operating_system": "mac_os_x-11.2.2"
  },
  "counts": {
    "assignee_lists": "SELECT COUNT(\"lists\".\"id\") FROM \"lists\" WHERE \"lists\".\"list_type\" = 3",
    "boards": "SELECT COUNT(\"boards\".\"id\") FROM \"boards\"",
    "ci_builds": "SELECT COUNT(\"ci_builds\".\"id\") FROM \"ci_builds\" WHERE \"ci_builds\".\"type\" = 'Ci::Build'",
    "ci_internal_pipelines": "SELECT COUNT(\"ci_pipelines\".\"id\") FROM \"ci_pipelines\" WHERE (\"ci_pipelines\".\"source\" IN (1, 2, 3, 4, 5, 7, 8, 9, 10, 11, 12, 13) OR \"ci_pipelines\".\"source\" IS NULL)",
    "ci_external_pipelines": "SELECT COUNT(\"ci_pipelines\".\"id\") FROM \"ci_pipelines\" WHERE \"ci_pipelines\".\"source\" = 6",
    "ci_pipeline_config_auto_devops": "SELECT COUNT(\"ci_pipelines\".\"id\") FROM \"ci_pipelines\" WHERE \"ci_pipelines\".\"config_source\" = 2",
    "ci_pipeline_config_repository": "SELECT COUNT(\"ci_pipelines\".\"id\") FROM \"ci_pipelines\" WHERE \"ci_pipelines\".\"config_source\" = 1",
    "ci_runners": "SELECT COUNT(\"ci_runners\".\"id\") FROM \"ci_runners\"",
...
```

<a id="list-all-non-sql-metrics"></a>

## 列出所有非 SQL 指标

{{< history >}}

- 在极狐GitLab 13.11 中引入。
- [部署在功能标志](../administration/feature_flags/_index.md)之后，名为 `usage_data_non_sql_metrics`，默认禁用。

{{< /history >}}

列出 Service Ping 中使用的所有非 SQL 指标数据。此操作隐藏在
`usage_data_non_sql_metrics` 功能标志后，仅适用于极狐GitLab 实例的
[管理员](../user/permissions.md)用户。

```plaintext
GET /usage_data/non_sql_metrics
```

示例请求：

```shell
curl --request GET \
  --header "PRIVATE-TOKEN: <your_access_token>" \
  --url "https://gitlab.example.com/api/v4/usage_data/non_sql_metrics"
```

示例响应：

```json
{
  "recorded_at": "2021-03-26T07:04:03.724Z",
  "uuid": null,
  "hostname": "localhost",
  "version": "13.11.0-pre",
  "installation_type": "gitlab-development-kit",
  "active_user_count": -3,
  "edition": "EE",
  "license_md5": "bb8cd0d8a6d9569ff3f70b8927a1f949",
  "license_sha256": "366dd175ef7a4e19cc701acc03844c45366dd175ef7a4e19cc701acc03844c45",
  "license_id": null,
  "historical_max_users": 0,
  "licensee": {
    "Name": "John Doe1"
  },
  "license_user_count": null,
  "license_starts_at": "1970-01-01",
  "license_expires_at": "2022-02-26",
  "license_plan": "starter",
  "license_add_ons": {
    "GitLab_FileLocks": 1,
    "GitLab_Auditor_User": 1
  },
  "license_trial": null,
  "license_subscription_id": "0000",
  "license": {},
  "settings": {
    "ldap_encrypted_secrets_enabled": false,
    "operating_system": "mac_os_x-11.2.2"
  },
...
```

<a id="track-internal-events"></a>

## 跟踪内部事件

跟踪极狐GitLab 实例中的内部事件。

先决条件：

- 你必须使用具有 `api` 或 `ai_workflows` 范围的个人访问令牌进行认证。

```plaintext
POST /usage_data/track_event
```

要将事件跟踪到 Snowplow，请将 `send_to_snowplow` 参数设置为 `true`。

示例请求：

```shell
curl --header "PRIVATE-TOKEN: <your_access_token>" \
     --header "Content-Type: application/json" \
     --request POST \
     --data '{
       "event": "mr_name_changed",
       "send_to_snowplow": true,
       "namespace_id": 1,
       "project_id": 1,
       "additional_properties": {
         "lang": "eng"
       }
     }' \
     --url "https://gitlab.example.com/api/v4/usage_data/track_event"
```

如果需要跟踪多个事件，请将事件数组发送到 `/track_events` 端点：

```shell
curl --header "PRIVATE-TOKEN: <your_access_token>" \
     --header "Content-Type: application/json" \
     --request POST \
     --data '{
       "events": [
         {
           "event": "mr_name_changed",
           "namespace_id": 1,
           "project_id": 1,
           "additional_properties": {
             "lang": "eng"
           }
         },
         {
           "event": "mr_name_changed",
           "namespace_id": 2,
           "project_id": 2,
           "additional_properties": {
             "lang": "eng"
           }
         }
       ]
     }' \
     --url "https://gitlab.example.com/api/v4/usage_data/track_events"
```