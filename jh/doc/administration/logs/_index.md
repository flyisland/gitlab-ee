---
stage: Analytics
group: Platform Insights
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
title: 日志系统
description: 访问全面的日志记录和监控功能。
---

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: 私有化部署

{{< /details >}}

极狐GitLab 中的日志系统为分析您的极狐GitLab 实例提供了全面的日志记录和监控功能。
您可以使用日志来识别系统问题、调查安全事件和分析应用程序性能。
每个操作都有对应的日志条目，因此当问题发生时，这些日志提供了快速诊断和解决问题所需的数据。

日志系统：

- 在结构化的日志文件中跟踪极狐GitLab 各组件中的所有应用程序活动。
- 以标准化格式记录性能指标、错误和安全事件。
- 通过 JSON 日志记录与 Elasticsearch 和 Splunk 等日志分析工具集成。
- 为不同的极狐GitLab 服务和组件维护单独的日志文件。
- 包含关联 ID，用于在整个系统中跟踪请求。

系统日志文件通常是标准日志文件格式的纯文本。

日志系统类似于[审计事件](../compliance/audit_event_reports.md)。
更多信息，另请参阅：

- [自定义 Linux 软件包安装的日志记录](https://gitlab.cn/docs/omnibus/settings/logs/)
- [解析和分析 JSON 格式的极狐GitLab 日志](log_parsing.md)

<a id="log-levels"></a>

## 日志级别

每条日志消息都有一个指定的日志级别，表示其重要性和详细程度。
每个记录器都有一个指定的最低日志级别。
记录器仅在其日志级别等于或高于最低日志级别时才发出日志消息。

支持以下日志级别：

| 级别 | 名称      |
|:------|:----------|
| 0     | `DEBUG`   |
| 1     | `INFO`    |
| 2     | `WARN`    |
| 3     | `ERROR`   |
| 4     | `FATAL`   |
| 5     | `UNKNOWN` |

极狐GitLab 记录器会发出所有日志消息，因为它们默认设置为 `DEBUG`。

<a id="override-default-log-level"></a>

### 覆盖默认日志级别

您可以使用 `GITLAB_LOG_LEVEL` 环境变量覆盖极狐GitLab 记录器的最低日志级别。
有效值是 `0` 到 `5` 之间的值，或日志级别的名称。

示例：

```shell
GITLAB_LOG_LEVEL=info
```

对于某些服务，存在不受此设置影响的其他日志级别。
其中一些服务有自己的环境变量来覆盖日志级别。例如：

| 服务                   | 日志级别 | 环境变量 |
|:--------------------------|:----------|:---------------------|
| GitLab Cleanup            | `INFO`    | `DEBUG`              |
| GitLab Doctor             | `INFO`    | `VERBOSE`            |
| GitLab Export             | `INFO`    | `EXPORT_DEBUG`       |
| GitLab Import             | `INFO`    | `IMPORT_DEBUG`       |
| GitLab QA Runtime         | `INFO`    | `QA_LOG_LEVEL`       |
| GitLab Product Usage Data | `INFO`    |                      |
| Google APIs               | `INFO`    |                      |
| Rack Timeout              | `ERROR`   |                      |
| Snowplow Tracker          | `FATAL`   |                      |
| gRPC Client (Gitaly)      | `WARN`    | `GRPC_LOG_LEVEL`     |
| LLM                       | `INFO`    | `LLM_DEBUG`          |

<a id="log-rotation"></a>

## 日志轮转

给定服务的日志可能由以下方式管理和轮转：

- `logrotate`
- `svlogd` (`runit` 的服务日志守护进程)
- `logrotate` 和 `svlogd`
- 或者根本不轮转

下表包含有关哪个守护进程负责管理和轮转所包含服务的日志的信息：

- 由 `svlogd` [管理的日志](https://gitlab.cn/docs/omnibus/settings/logs/#runit-logs) 写入名为 `current` 的文件。
  其归档版本被压缩为 `@<hexadecimal-ID>.s` 文件。
- 极狐GitLab 内置的 `logrotate` 服务 [管理所有其他日志](https://gitlab.cn/docs/omnibus/settings/logs/#logrotate)。
  其归档版本被压缩为 `<original-name>.<number>.gz` 文件。

| 日志类型                                                                 | 由 logrotate 管理 | 由 svlogd/runit 管理 |
|:-------------------------------------------------------------------------|:---------------------|:------------------------|
| [Alertmanager 日志](#alertmanager-logs)                                  | {{< no >}}           | {{< yes >}} |
| [Consul 日志](#consul-logs)                                              | {{< no >}}           | {{< yes >}} |
| [crond 日志](#crond-logs)                                                | {{< no >}}           | {{< yes >}} |
| [Gitaly](#gitaly-logs)                                                   | {{< yes >}}          | {{< yes >}} |
| [Linux 软件包安装的 GitLab Exporter](#gitlab-exporter-logs) | {{< no >}}           | {{< yes >}} |
| [GitLab Pages 日志](#pages-logs)                                         | {{< yes >}}          | {{< yes >}} |
| GitLab Rails                                                             | {{< yes >}}          | {{< no >}}  |
| [GitLab Shell 日志](#gitlab-shelllog)                                    | {{< yes >}}          | {{< no >}}  |
| [Grafana 日志](#grafana-logs)                                            | {{< no >}}           | {{< yes >}} |
| [LogRotate 日志](#logrotate-logs)                                        | {{< no >}}           | {{< yes >}} |
| [Mailroom](#mail_room_jsonlog-default)                                   | {{< yes >}}          | {{< yes >}} |
| [NGINX](#nginx-logs)                                                     | {{< yes >}}          | {{< yes >}} |
| [Patroni 日志](#patroni-logs)                                            | {{< no >}}           | {{< yes >}} |
| [PgBouncer 日志](#pgbouncer-logs)                                        | {{< no >}}           | {{< yes >}} |
| [PostgreSQL 日志](#postgresql-logs)                                      | {{< no >}}           | {{< yes >}} |
| [Praefect 日志](#praefect-logs)                                          | {{< yes >}}          | {{< yes >}} |
| [Prometheus 日志](#prometheus-logs)                                      | {{< no >}}           | {{< yes >}} |
| [Puma](#puma-logs)                                                       | {{< yes >}}          | {{< yes >}} |
| [Redis 日志](#redis-logs)                                                | {{< no >}}           | {{< yes >}} |
| [Registry 日志](#registry-logs)                                          | {{< no >}}           | {{< yes >}} |
| [Sentinel 日志](#sentinel-logs)                                          | {{< no >}}           | {{< yes >}} |
| [Sidekiq 日志](#sidekiq-logs)                                            | {{< no >}}           | {{< yes >}} |
| [Workhorse 日志](#workhorse-logs)                                        | {{< yes >}}          | {{< yes >}} |

有关生成这些日志的服务的更多信息，请参阅 [极狐GitLab 架构概述](../../development/architecture.md)。

<a id="accessing-logs-on-helm-chart-installations"></a>

## 访问 Helm chart 安装的日志

在 Helm chart 安装中，极狐GitLab 组件将日志发送到 `stdout`，可以使用 `kubectl logs` 访问。
在 Pod 的生命周期内，日志也可在 Pod 的 `/var/log/gitlab` 路径下获取。

<a id="pods-with-structured-logs-subcomponent-filtering"></a>

### 具有结构化日志的 Pod（子组件过滤）

某些 Pod 包含一个 `subcomponent` 字段，用于标识特定的日志类型：

```shell
# Webservice pod logs (Rails application)
kubectl logs -l app=webservice -c webservice | jq 'select(."subcomponent"=="<subcomponent-key>")'

# Sidekiq pod logs (background jobs)
kubectl logs -l app=sidekiq | jq 'select(."subcomponent"=="<subcomponent-key>")'
```

以下日志部分在适用时指示适当的 Pod 和子组件键。

<a id="other-pods"></a>

### 其他 Pod

对于不使用带子组件的结构化日志的其他极狐GitLab 组件，您可以直接访问日志。

要查找可用的 Pod 选择器：

```shell
# List all unique app labels in use
kubectl get pods -o jsonpath='{range .items[*]}{.metadata.labels.app}{"\n"}{end}' | grep -v '^$' | sort | uniq

# For pods with app labels
kubectl logs -l app=<pod-selector>

# For specific pods (when app labels aren't available)
kubectl get pods
kubectl logs <pod-name>
```

有关更多 Kubernetes 故障排查命令，请参阅 [Kubernetes 速查表](https://gitlab.cn/docs/charts/troubleshooting/kubernetes_cheat_sheet/)。

<a id="production_jsonlog"></a>

## `production_json.log`

此日志位于：

- Linux 软件包安装的 `/var/log/gitlab/gitlab-rails/production_json.log` 文件中。
- 自编译安装的 `/home/git/gitlab/log/production_json.log` 文件中。
- Helm chart 安装的 Webservice Pod 上，位于 `subcomponent="production_json"` 键下。

它包含来自极狐GitLab 的 Rails 控制器请求的结构化日志，这得益于 [Lograge](https://github.com/roidrage/lograge/)。
来自 API 的请求记录在 `api_json.log` 的单独文件中。

每行包含可由 Elasticsearch 和 Splunk 等服务接收的 JSON。
为便于阅读，示例中添加了换行符：

```json
{
  "method":"GET",
  "path":"/gitlab/gitlab-foss/issues/1234",
  "format":"html",
  "controller":"Projects::IssuesController",
  "action":"show",
  "status":200,
  "time":"2017-08-08T20:15:54.821Z",
  "params":[{"key":"param_key","value":"param_value"}],
  "remote_ip":"18.245.0.1",
  "user_id":1,
  "username":"admin",
  "queue_duration_s":0.0,
  "gitaly_calls":16,
  "gitaly_duration_s":0.16,
  "redis_calls":115,
  "redis_duration_s":0.13,
  "redis_read_bytes":1507378,
  "redis_write_bytes":2920,
  "correlation_id":"O1SdybnnIq7",
  "cpu_s":17.50,
  "db_duration_s":0.08,
  "view_duration_s":2.39,
  "duration_s":20.54,
  "pid": 81836,
  "worker_id":"puma_0"
}
```

此示例是针对特定议题的 GET 请求。
每行还包含性能数据，时间以秒为单位：

- `duration_s`：检索请求的总时间
- `queue_duration_s`：请求在 GitLab Workhorse 内部排队的总时间
- `view_duration_s`：在 Rails 视图中花费的总时间
- `db_duration_s`：从 PostgreSQL 检索数据的总时间
- `cpu_s`：在 CPU 上花费的总时间
- `gitaly_duration_s`：Gitaly 调用的总时间
- `gitaly_calls`：对 Gitaly 发出的调用总数
- `redis_calls`：对 Redis 发出的调用总数
- `redis_cross_slot_calls`：对 Redis 发出的跨槽调用总数
- `redis_allowed_cross_slot_calls`：对 Redis 发出的允许的跨槽调用总数
- `redis_duration_s`：从 Redis 检索数据的总时间
- `redis_read_bytes`：从 Redis 读取的总字节数
- `redis_write_bytes`：写入 Redis 的总字节数
- `redis_<instance>_calls`：对 Redis 实例发出的调用总数
- `redis_<instance>_cross_slot_calls`：对 Redis 实例发出的跨槽调用总数
- `redis_<instance>_allowed_cross_slot_calls`：对 Redis 实例发出的允许的跨槽调用总数
- `redis_<instance>_duration_s`：从 Redis 实例检索数据的总时间
- `redis_<instance>_read_bytes`：从 Redis 实例读取的总字节数
- `redis_<instance>_write_bytes`：写入 Redis 实例的总字节数
- `pid`：工作进程的 Linux 进程 ID（工作进程重启时更改）
- `worker_id`：工作进程的逻辑 ID（工作进程重启时不更改）

使用 HTTP 传输的用户克隆和获取活动在日志中显示为 `action: git_upload_pack`。

此外，日志包含发起请求的 IP 地址 (`remote_ip`)、用户 ID (`user_id`) 和用户名 (`username`)。

某些端点（例如 `/search`）如果使用[高级搜索](../../user/search/advanced_search.md)，可能会向 Elasticsearch 发出请求。这些请求还会记录 `elasticsearch_calls` 和 `elasticsearch_duration_s`，分别对应：

- `elasticsearch_calls`：对 Elasticsearch 的调用总数
- `elasticsearch_duration_s`：Elasticsearch 调用花费的总时间
- `elasticsearch_timed_out_count`：超时并因此返回部分结果的 Elasticsearch 调用总数

使用 [极狐GitLab Secrets Manager](../../ci/secrets/secrets_manager/_index.md) 读取或写入密钥的请求还会记录 `openbao_calls` 和 `openbao_duration_s`，分别对应：

- `openbao_calls`：对 OpenBao 的调用总数
- `openbao_duration_s`：OpenBao 调用花费的总时间

ActionCable 连接和订阅事件也会记录到此文件中，并遵循之前的格式。`method`、`path` 和 `format` 字段不适用，并且始终为空。ActionCable 连接或频道类用作 `controller`。

```json
{
  "method":null,
  "path":null,
  "format":null,
  "controller":"IssuesChannel",
  "action":"subscribe",
  "status":200,
  "time":"2020-05-14T19:46:22.008Z",
  "params":[{"key":"project_path","value":"gitlab/gitlab-foss"},{"key":"iid","value":"1"}],
  "remote_ip":"127.0.0.1",
  "user_id":1,
  "username":"admin",
  "ua":"Mozilla/5.0 (Macintosh; Intel Mac OS X 10.15; rv:76.0) Gecko/20100101 Firefox/76.0",
  "correlation_id":"jSOIEynHCUa",
  "duration_s":0.32566
}
```

> [!note]
> 如果发生错误，会包含一个
> `exception` 字段，其中包含 `class`、`message` 和
> `backtrace`。以前的版本包含一个 `error` 字段，而不是
> `exception.class` 和 `exception.message`。例如：

```json
{
  "method": "GET",
  "path": "/admin",
  "format": "html",
  "controller": "Admin::DashboardController",
  "action": "index",
  "status": 500,
  "time": "2019-11-14T13:12:46.156Z",
  "params": [],
  "remote_ip": "127.0.0.1",
  "user_id": 1,
  "username": "root",
  "ua": "Mozilla/5.0 (Macintosh; Intel Mac OS X 10.14; rv:70.0) Gecko/20100101 Firefox/70.0",
  "queue_duration": 274.35,
  "correlation_id": "KjDVUhNvvV3",
  "queue_duration_s":0.0,
  "gitaly_calls":16,
  "gitaly_duration_s":0.16,
  "redis_calls":115,
  "redis_duration_s":0.13,
  "correlation_id":"O1SdybnnIq7",
  "cpu_s":17.50,
  "db_duration_s":0.08,
  "view_duration_s":2.39,
  "duration_s":20.54,
  "pid": 81836,
  "worker_id": "puma_0",
  "exception.class": "NameError",
  "exception.message": "undefined local variable or method `adsf' for #<Admin::DashboardController:0x00007ff3c9648588>",
  "exception.backtrace": [
    "app/controllers/admin/dashboard_controller.rb:11:in `index'",
    "ee/app/controllers/ee/admin/dashboard_controller.rb:14:in `index'",
    "ee/lib/gitlab/ip_address_state.rb:10:in `with'",
    "ee/app/controllers/ee/application_controller.rb:43:in `set_current_ip_address'",
    "lib/gitlab/session.rb:11:in `with_session'",
    "app/controllers/application_controller.rb:450:in `set_session_storage'",
    "app/controllers/application_controller.rb:444:in `set_locale'",
    "ee/lib/gitlab/jira/middleware.rb:19:in `call'"
  ]
}
```

<a id="productionlog"></a>

## `production.log`

此日志位于：

- Linux 软件包安装的 `/var/log/gitlab/gitlab-rails/production.log` 文件中。
- 自编译安装的 `/home/git/gitlab/log/production.log` 文件中。

它包含有关所有已执行请求的信息。您可以查看请求的 URL 和类型、IP 地址以及处理此特定请求所涉及的代码部分。此外，您还可以查看所有已执行的 SQL 请求以及每个请求花费的时间。此任务对极狐GitLab 贡献者和开发者更有用。报告错误时，请使用此日志文件的一部分。例如：

```plaintext
Started GET "/gitlabhq/yaml_db/tree/master" for 168.111.56.1 at 2015-02-12 19:34:53 +0200
Processing by Projects::TreeController#show as HTML
  Parameters: {"project_id"=>"gitlabhq/yaml_db", "id"=>"master"}

  ... [CUT OUT]

  Namespaces"."created_at" DESC, "namespaces"."id" DESC LIMIT 1 [["id", 26]]
  CACHE (0.0ms) SELECT  "members".* FROM "members"  WHERE "members"."source_type" = 'Project' AND "members"."type" IN ('ProjectMember') AND "members"."source_id" = $1 AND "members"."source_type" = $2 AND "members"."user_id" = 1  ORDER BY "members"."created_at" DESC, "members"."id" DESC LIMIT 1  [["source_id", 18], ["source_type", "Project"]]
  CACHE (0.0ms) SELECT  "members".* FROM "members"  WHERE "members"."source_type" = 'Project' AND "members".
  (1.4ms) SELECT COUNT(*) FROM "merge_requests"  WHERE "merge_requests"."target_project_id" = $1 AND ("merge_requests"."state" IN ('opened','reopened')) [["target_project_id", 18]]
  Rendered layouts/nav/_project.html.haml (28.0ms)
  Rendered layouts/_collapse_button.html.haml (0.2ms)
  Rendered layouts/_flash.html.haml (0.1ms)
  Rendered layouts/_page.html.haml (32.9ms)
Completed 200 OK in 166ms (Views: 117.4ms | ActiveRecord: 27.2ms)
```

在此示例中，服务器处理了一个 URL 为 `/gitlabhq/yaml_db/tree/master`、来自 IP `168.111.56.1`、时间为 `2015-02-12 19:34:53 +0200` 的 HTTP 请求。该请求由 `Projects::TreeController` 处理。

<a id="api_jsonlog"></a>

## `api_json.log`

此日志位于：

- Linux 软件包安装的 `/var/log/gitlab/gitlab-rails/api_json.log` 文件中。
- 自编译安装的 `/home/git/gitlab/log/api_json.log` 文件中。
- Helm chart 安装的 Webservice Pod 上，位于 `subcomponent="api_json"` 键下。

它帮助您查看直接对 API 发出的请求。例如：

```json
{
  "time":"2018-10-29T12:49:42.123Z",
  "severity":"INFO",
  "duration":709.08,
  "db":14.59,
  "view":694.49,
  "status":200,
  "method":"GET",
  "path":"/api/v4/projects",
  "params":[{"key":"action","value":"git-upload-pack"},{"key":"changes","value":"_any"},{"key":"key_id","value":"secret"},{"key":"secret_token","value":"[FILTERED]"}],
  "host":"localhost",
  "remote_ip":"::1",
  "ua":"Ruby",
  "route":"/api/:version/projects",
  "user_id":1,
  "username":"root",
  "queue_duration":100.31,
  "gitaly_calls":30,
  "gitaly_duration":5.36,
  "pid": 81836,
  "worker_id": "puma_0",
  ...
}
```

此条目显示了一个内部端点，用于检查关联的 SSH 密钥是否可以通过使用 `git fetch` 或 `git clone` 下载相关项目。在此示例中，我们看到：

- `duration`：检索请求的总时间（毫秒）
- `queue_duration`：请求在 GitLab Workhorse 内部排队的总时间（毫秒）
- `method`：发出请求所使用的 HTTP 方法
- `path`：查询的相对路径
- `params`：在查询字符串或 HTTP 正文中传递的键值对（敏感参数，如密码和令牌，会被过滤掉）
- `ua`：请求方的 User-Agent

> [!note]
> 自 [`Grape Logging`](https://github.com/aserafin/grape_logging) v1.8.4 起，
> `view_duration_s` 由 [`duration_s - db_duration_s`](https://github.com/aserafin/grape_logging/blob/v1.8.4/lib/grape_logging/middleware/request_logger.rb#L117-L119) 计算。
> 因此，`view_duration_s` 可能受到多种不同因素的影响，例如 Redis 上的读写进程或外部 HTTP，而不仅仅是序列化过程。

<a id="applicationlog-deprecated"></a>

## `application.log`（已弃用）

此日志位于：

- Linux 软件包安装的 `/var/log/gitlab/gitlab-rails/application.log` 文件中。
- 自编译安装的 `/home/git/gitlab/log/application.log` 文件中。

它包含 [`application_json.log`](#application_jsonlog) 中日志的结构化程度较低的版本，如下例所示：

```plaintext
October 06, 2014 11:56: User "Administrator" (admin@example.com) was created
October 06, 2014 11:56: Documentcloud created a new project "Documentcloud / Underscore"
October 06, 2014 11:56: Gitlab Org created a new project "Gitlab Org / Gitlab Ce"
October 07, 2014 11:25: User "Claudie Hodkiewicz" (nasir_stehr@olson.co.uk)  was removed
October 07, 2014 11:25: Project "project133" was removed
```

<a id="application_jsonlog"></a>

## `application_json.log`

此日志位于：

- Linux 软件包安装的 `/var/log/gitlab/gitlab-rails/application_json.log` 文件中。
- 自编译安装的 `/home/git/gitlab/log/application_json.log` 文件中。
- Helm chart 安装的 Sidekiq 和 Webservice Pod 上，位于 `subcomponent="application_json"` 键下。

它帮助您发现实例中发生的事件，例如用户创建和项目删除。例如：

```json
{
  "severity":"INFO",
  "time":"2020-01-14T13:35:15.466Z",
  "correlation_id":"3823a1550b64417f9c9ed8ee0f48087e",
  "message":"User \"Administrator\" (admin@example.com) was created"
}
{
  "severity":"INFO",
  "time":"2020-01-14T13:35:15.466Z",
  "correlation_id":"78e3df10c9a18745243d524540bd5be4",
  "message":"Project \"project133\" was removed"
}
```

<a id="integrations_jsonlog"></a>

## `integrations_json.log`

此日志位于：

- Linux 软件包安装的 `/var/log/gitlab/gitlab-rails/integrations_json.log` 文件中。
- 自编译安装的 `/home/git/gitlab/log/integrations_json.log` 文件中。
- Helm chart 安装的 Sidekiq 和 Webservice Pod 上，位于 `subcomponent="integrations_json"` 键下。

它包含有关[集成](../../user/project/integrations/_index.md)活动的信息，例如 Jira、Asana 和 irker 服务。它使用 JSON 格式，如下例所示：

```json
{
  "severity":"ERROR",
  "time":"2018-09-06T14:56:20.439Z",
  "service_class":"Integrations::Jira",
  "project_id":8,
  "project_path":"h5bp/html5-boilerplate",
  "message":"Error sending message",
  "client_url":"http://jira.gitlab.com:8080",
  "error":"execution expired"
}
{
  "severity":"INFO",
  "time":"2018-09-06T17:15:16.365Z",
  "service_class":"Integrations::Jira",
  "project_id":3,
  "project_path":"namespace2/project2",
  "message":"Successfully posted",
  "client_url":"http://jira.example.com"
}
```

<a id="kuberneteslog-deprecated"></a>

## `kubernetes.log`（已弃用）

此日志位于：

- Linux 软件包安装的 `/var/log/gitlab/gitlab-rails/kubernetes.log` 文件中。
- 自编译安装的 `/home/git/gitlab/log/kubernetes.log` 文件中。
- Helm chart 安装的 Sidekiq Pod 上，位于 `subcomponent="kubernetes"` 键下。

它记录与[基于证书的集群](../../user/project/clusters/_index.md)相关的信息，例如连接错误。每行包含可由 Elasticsearch 和 Splunk 等服务接收的 JSON。

<a id="git_jsonlog"></a>

## `git_json.log`

此日志位于：

- Linux 软件包安装的 `/var/log/gitlab/gitlab-rails/git_json.log` 文件中。
- 自编译安装的 `/home/git/gitlab/log/git_json.log` 文件中。
- Helm chart 安装的 Sidekiq Pod 上，位于 `subcomponent="git_json"` 键下。

极狐GitLab 必须与 Git 代码仓库交互，但在极少数情况下可能会出错。如果发生这种情况，您需要确切知道发生了什么。此日志文件包含从极狐GitLab 到 Git 代码仓库的所有失败请求。在大多数情况下，此文件仅对开发者有用。例如：

```json
{
   "severity":"ERROR",
   "time":"2019-07-19T22:16:12.528Z",
   "correlation_id":"FeGxww5Hj64",
   "message":"Command failed [1]: /usr/bin/git --git-dir=/Users/vsizov/gitlab-development-kit/gitlab/tmp/tests/gitlab-satellites/group184/gitlabhq/.git --work-tree=/Users/vsizov/gitlab-development-kit/gitlab/tmp/tests/gitlab-satellites/group184/gitlabhq merge --no-ff -mMerge branch 'feature_conflict' into 'feature' source/feature_conflict\n\nerror: failed to push some refs to '/Users/vsizov/gitlab-development-kit/repositories/gitlabhq/gitlab_git.git'"
}
```

<a id="audit_jsonlog"></a>

## `audit_json.log`

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: 私有化部署

{{< /details >}}

> [!note]
> 极狐GitLab 基础版跟踪少量不同的审计事件。
> 极狐GitLab 专业版跟踪更多。

此日志位于：

- Linux 软件包安装的 `/var/log/gitlab/gitlab-rails/audit_json.log` 文件中。
- 自编译安装的 `/home/git/gitlab/log/audit_json.log` 文件中。
- Helm chart 安装的 Sidekiq 和 Webservice Pod 上，位于 `subcomponent="audit_json"` 键下。

对群组或项目设置和成员资格 (`target_details`) 的更改会记录到此文件中。例如：

```json
{
  "severity":"INFO",
  "time":"2018-10-17T17:38:22.523Z",
  "author_id":3,
  "entity_id":2,
  "entity_type":"Project",
  "change":"visibility",
  "from":"Private",
  "to":"Public",
  "author_name":"John Doe4",
  "target_id":2,
  "target_type":"Project",
  "target_details":"namespace2/project2"
}
```

<a id="sidekiq-logs"></a>

## Sidekiq 日志

对于 Linux 软件包安装，某些 Sidekiq 日志位于 `/var/log/gitlab/sidekiq/current`，如下所述。

<a id="sidekiqlog"></a>

### `sidekiq.log`

此日志位于：

- Linux 软件包安装的 `/var/log/gitlab/sidekiq/current` 文件中。
- 自编译安装的 `/home/git/gitlab/log/sidekiq.log` 文件中。

GitLab Helm chart 安装的默认日志格式是 `json`。

极狐GitLab 使用后台作业来处理可能需要长时间的任务。有关处理这些作业的所有信息都会写入此文件。例如：

```json
{
  "severity":"INFO",
  "time":"2018-04-03T22:57:22.071Z",
  "queue":"cronjob:update_all_mirrors",
  "args":[],
  "class":"UpdateAllMirrorsWorker",
  "retry":false,
  "queue_namespace":"cronjob",
  "jid":"06aeaa3b0aadacf9981f368e",
  "created_at":"2018-04-03T22:57:21.930Z",
  "enqueued_at":"2018-04-03T22:57:21.931Z",
  "pid":10077,
  "worker_id":"sidekiq_0",
  "message":"UpdateAllMirrorsWorker JID-06aeaa3b0aadacf9981f368e: done: 0.139 sec",
  "job_status":"done",
  "duration":0.139,
  "completed_at":"2018-04-03T22:57:22.071Z",
  "db_duration":0.05,
  "db_duration_s":0.0005,
  "gitaly_duration":0,
  "gitaly_calls":0
}
```

除了 JSON 日志，您也可以选择为 Sidekiq 生成文本日志。例如：

```plaintext
2023-05-16T16:08:55.272Z pid=82525 tid=23rl INFO: Initializing websocket
2023-05-16T16:08:55.279Z pid=82525 tid=23rl INFO: Booted Rails 6.1.7.2 application in production environment
2023-05-16T16:08:55.279Z pid=82525 tid=23rl INFO: Running in ruby 3.0.5p211 (2022-11-24 revision ba5cf0f7c5) [arm64-darwin22]
2023-05-16T16:08:55.279Z pid=82525 tid=23rl INFO: See LICENSE and the LGPL-3.0 for licensing details.
2023-05-16T16:08:55.279Z pid=82525 tid=23rl INFO: Upgrade to Sidekiq Pro for more features and support: https://sidekiq.org
2023-05-16T16:08:55.286Z pid=82525 tid=7p4t INFO: Cleaning working queues
2023-05-16T16:09:06.043Z pid=82525 tid=7p7d class=ScheduleMergeRequestCleanupRefsWorker jid=efcc73f169c09a514b06da3f INFO: start
2023-05-16T16:09:06.050Z pid=82525 tid=7p7d class=ScheduleMergeRequestCleanupRefsWorker jid=efcc73f169c09a514b06da3f INFO: arguments: []
2023-05-16T16:09:06.065Z pid=82525 tid=7p81 class=UserStatusCleanup::BatchWorker jid=e279aa6409ac33031a314822 INFO: start
2023-05-16T16:09:06.066Z pid=82525 tid=7p81 class=UserStatusCleanup::BatchWorker jid=e279aa6409ac33031a314822 INFO: arguments: []
```

对于 Linux 软件包安装，添加配置选项：

```ruby
sidekiq['log_format'] = 'text'
```

对于自编译安装，编辑 `gitlab.yml` 并设置 Sidekiq 的 `log_format` 配置选项：

```yaml
  ## Sidekiq
  sidekiq:
    log_format: text
```

<a id="sidekiq_clientlog"></a>

### `sidekiq_client.log`

此日志位于：

- Linux 软件包安装的 `/var/log/gitlab/gitlab-rails/sidekiq_client.log` 文件中。
- 自编译安装的 `/home/git/gitlab/log/sidekiq_client.log` 文件中。
- Helm chart 安装的 Webservice Pod 上，位于 `subcomponent="sidekiq_client"` 键下。

此文件包含 Sidekiq 开始处理作业之前（例如入队之前）的作业日志信息。

此日志文件遵循与 [`sidekiq.log`](#sidekiqlog) 相同的结构，因此如果您如前所述为 Sidekiq 配置了 JSON 格式，它将是 JSON 结构。

<a id="gitlab-shelllog"></a>

## `gitlab-shell.log`

GitLab Shell 被极狐GitLab 用于执行 Git 命令并为 Git 代码仓库提供 SSH 访问。

包含 `git-{upload-pack,receive-pack}` 请求的信息位于 `/var/log/gitlab/gitlab-shell/gitlab-shell.log`。来自 Gitaly 的 GitLab Shell 钩子信息位于 `/var/log/gitlab/gitaly/current`。

`/var/log/gitlab/gitlab-shell/gitlab-shell.log` 的示例日志条目：

```json
{
  "duration_ms": 74.104,
  "level": "info",
  "method": "POST",
  "msg": "Finished HTTP request",
  "time": "2020-04-17T20:28:46Z",
  "url": "http://127.0.0.1:8080/api/v4/internal/allowed"
}
{
  "command": "git-upload-pack",
  "git_protocol": "",
  "gl_project_path": "root/example",
  "gl_repository": "project-1",
  "level": "info",
  "msg": "executing git command",
  "time": "2020-04-17T20:28:46Z",
  "user_id": "user-1",
  "username": "root"
}
```

`/var/log/gitlab/gitaly/current` 的示例日志条目：

```json
{
  "method": "POST",
  "url": "http://127.0.0.1:8080/api/v4/internal/allowed",
  "duration": 0.058012959,
  "gitaly_embedded": true,
  "pid": 16636,
  "level": "info",
  "msg": "finished HTTP request",
  "time": "2020-04-17T20:29:08+00:00"
}
{
  "method": "POST",
  "url": "http://127.0.0.1:8080/api/v4/internal/pre_receive",
  "duration": 0.031022552,
  "gitaly_embedded": true,
  "pid": 16636,
  "level": "info",
  "msg": "finished HTTP request",
  "time": "2020-04-17T20:29:08+00:00"
}
```

<a id="gitaly-logs"></a>

## Gitaly 日志

此文件位于 `/var/log/gitlab/gitaly/current`，由 [runit](https://smarden.org/runit/) 生成。`runit` 随 Linux 软件包一起打包，其用途的简要说明可在 [Linux 软件包文档](https://gitlab.cn/docs/omnibus/architecture/#runit) 中找到。

<a id="grpclog"></a>

### `grpc.log`

对于 Linux 软件包安装，此文件位于 `/var/log/gitlab/gitlab-rails/grpc.log`。Gitaly 使用的原生 [gRPC](https://grpc.io/) 日志记录。

<a id="gitaly_hookslog"></a>

### `gitaly_hooks.log`

此文件位于 `/var/log/gitlab/gitaly/gitaly_hooks.log`，由 `gitaly-hooks` 命令生成。它还包含处理极狐GitLab API 响应期间收到的失败记录。

<a id="puma-logs"></a>

## Puma 日志

<a id="puma_stdoutlog"></a>

### `puma_stdout.log`

此日志位于：

- Linux 软件包安装的 `/var/log/gitlab/puma/puma_stdout.log` 文件中。
- 自编译安装的 `/home/git/gitlab/log/puma_stdout.log` 文件中。

<a id="puma_stderrlog"></a>

### `puma_stderr.log`

此日志位于：

- Linux 软件包安装的 `/var/log/gitlab/puma/puma_stderr.log` 文件中。
- 自编译安装的 `/home/git/gitlab/log/puma_stderr.log` 文件中。

<a id="repochecklog"></a>

## `repocheck.log`

此日志位于：

- Linux 软件包安装的 `/var/log/gitlab/gitlab-rails/repocheck.log` 文件中。
- 自编译安装的 `/home/git/gitlab/log/repocheck.log` 文件中。
- Helm chart 安装的 Sidekiq Pod 上，位于 `subcomponent="repocheck"` 键下。

每当对项目执行[代码仓库检查](../repository_checks.md)时，它都会记录信息。

<a id="importerlog"></a>

## `importer.log`

此日志位于：

- Linux 软件包安装的 `/var/log/gitlab/gitlab-rails/importer.log` 文件中。
- 自编译安装的 `/home/git/gitlab/log/importer.log` 文件中。
- Helm chart 安装的 Sidekiq Pod 上，位于 `subcomponent="importer"` 键下。

此文件记录[项目导入和迁移](../../user/import/_index.md)的进度。

<a id="exporterlog"></a>

## `exporter.log`

此日志位于：

- Linux 软件包安装的 `/var/log/gitlab/gitlab-rails/exporter.log` 文件中。
- 自编译安装的 `/home/git/gitlab/log/exporter.log` 文件中。
- Helm chart 安装的 Sidekiq 和 Webservice Pod 上，位于 `subcomponent="exporter"` 键下。

它记录导出过程的进度。

<a id="features_jsonlog"></a>

## `features_json.log`

此日志位于：

- Linux 软件包安装的 `/var/log/gitlab/gitlab-rails/features_json.log` 文件中。
- 自编译安装的 `/home/git/gitlab/log/features_json.log` 文件中。
- Helm chart 安装的 Sidekiq 和 Webservice Pod 上，位于 `subcomponent="features_json"` 键下。

极狐GitLab 开发中功能标志的修改事件记录在此文件中。例如：

```json
{"severity":"INFO","time":"2020-11-24T02:30:59.860Z","correlation_id":null,"key":"cd_auto_rollback","action":"enable","extra.thing":"true"}
{"severity":"INFO","time":"2020-11-24T02:31:29.108Z","correlation_id":null,"key":"cd_auto_rollback","action":"enable","extra.thing":"true"}
{"severity":"INFO","time":"2020-11-24T02:31:29.129Z","correlation_id":null,"key":"cd_auto_rollback","action":"disable","extra.thing":"false"}
{"severity":"INFO","time":"2020-11-24T02:31:29.177Z","correlation_id":null,"key":"cd_auto_rollback","action":"enable","extra.thing":"Project:1"}
{"severity":"INFO","time":"2020-11-24T02:31:29.183Z","correlation_id":null,"key":"cd_auto_rollback","action":"disable","extra.thing":"Project:1"}
{"severity":"INFO","time":"2020-11-24T02:31:29.188Z","correlation_id":null,"key":"cd_auto_rollback","action":"enable_percentage_of_time","extra.percentage":"50"}
{"severity":"INFO","time":"2020-11-24T02:31:29.193Z","correlation_id":null,"key":"cd_auto_rollback","action":"disable_percentage_of_time"}
{"severity":"INFO","time":"2020-11-24T02:31:29.198Z","correlation_id":null,"key":"cd_auto_rollback","action":"enable_percentage_of_actors","extra.percentage":"50"}
{"severity":"INFO","time":"2020-11-24T02:31:29.203Z","correlation_id":null,"key":"cd_auto_rollback","action":"disable_percentage_of_actors"}
{"severity":"INFO","time":"2020-11-24T02:31:29.329Z","correlation_id":null,"key":"cd_auto_rollback","action":"remove"}
```

<a id="ci_resource_groups_jsonlog"></a>

## `ci_resource_groups_json.log`

此日志位于：

- Linux 软件包安装的 `/var/log/gitlab/gitlab-rails/ci_resource_groups_json.log` 文件中。
- 自编译安装的 `/home/git/gitlab/log/ci_resource_group_json.log` 文件中。
- Helm chart 安装的 Sidekiq 和 Webservice Pod 上，位于 `subcomponent="ci_resource_groups_json"` 键下。

它包含有关[资源组](../../ci/resource_groups/_index.md)获取的信息。例如：

```json
{"severity":"INFO","time":"2023-02-10T23:02:06.095Z","correlation_id":"01GRYS10C2DZQ9J1G12ZVAD4YD","resource_group_id":1,"processable_id":288,"message":"attempted to assign resource to processable","success":true}
{"severity":"INFO","time":"2023-02-10T23:02:08.945Z","correlation_id":"01GRYS138MYEG32C0QEWMC4BDM","resource_group_id":1,"processable_id":288,"message":"attempted to release resource from processable","success":true}
```

示例显示了每个条目的 `resource_group_id`、`processable_id`、`message` 和 `success` 字段。

<a id="authlog"></a>

## `auth.log`

此日志位于：

- Linux 软件包安装的 `/var/log/gitlab/gitlab-rails/auth.log` 文件中。
- 自编译安装的 `/home/git/gitlab/log/auth.log` 文件中。

此日志记录：

- 对原始端点的[速率限制](../settings/rate_limits_on_raw_endpoints.md)请求。
- [受保护路径](../settings/protected_paths.md)的滥用请求。
- 用户 ID 和用户名（如果可用）。

<a id="auth_jsonlog"></a>

## `auth_json.log`

此日志位于：

- Linux 软件包安装的 `/var/log/gitlab/gitlab-rails/auth_json.log` 文件中。
- 自编译安装的 `/home/git/gitlab/log/auth_json.log` 文件中。
- Helm chart 安装的 Sidekiq 和 Webservice Pod 上，位于 `subcomponent="auth_json"` 键下。

此文件包含 `auth.log` 中日志的 JSON 版本，例如：

```json
{
    "severity":"ERROR",
    "time":"2023-04-19T22:14:25.893Z",
    "correlation_id":"01GYDSAKAN2SPZPAMJNRWW5H8S",
    "message":"Rack_Attack",
    "env":"blocklist",
    "remote_ip":"x.x.x.x",
    "request_method":"GET",
    "path":"/group/project.git/info/refs?service=git-upload-pack"
}
```

<a id="graphql_jsonlog"></a>

## `graphql_json.log`

此日志位于：

- Linux 软件包安装的 `/var/log/gitlab/gitlab-rails/graphql_json.log` 文件中。
- 自编译安装的 `/home/git/gitlab/log/graphql_json.log` 文件中。
- Helm chart 安装的 Sidekiq 和 Webservice Pod 上，位于 `subcomponent="graphql_json"` 键下。

GraphQL 查询记录在此文件中。例如：

```json
{"query_string":"query IntrospectionQuery{__schema {queryType { name },mutationType { name }}}...(etc)","variables":{"a":1,"b":2},"complexity":181,"depth":1,"duration_s":7}
```

<a id="clickhouselog"></a>

## `clickhouse.log`

此日志位于：

- Linux 软件包安装的 `/var/log/gitlab/gitlab-rails/clickhouse.log` 文件中。
- 自编译安装的 `/home/git/gitlab/log/clickhouse.log` 文件中。
- Sidekiq 和 Webservice Pod 上，位于 `subcomponent="clickhouse"` 键下。

`clickhouse.log` 文件记录与极狐GitLab 中 [ClickHouse 数据库客户端](../../integration/clickhouse.md) 相关的信息。

<a id="migrationslog"></a>

## `migrations.log`

此日志位于：

- Linux 软件包安装的 `/var/log/gitlab/gitlab-rails/migrations.log` 文件中。
- 自编译安装的 `/home/git/gitlab/log/migrations.log` 文件中。

此文件记录[数据库迁移](../raketasks/maintenance.md#display-status-of-database-migrations)的进度。

<a id="mail_room_jsonlog-default"></a>

## `mail_room_json.log`（默认）

此日志位于：

- Linux 软件包安装的 `/var/log/gitlab/mailroom/current` 文件中。
- 自编译安装的 `/home/git/gitlab/log/mail_room_json.log` 文件中。

此结构化日志文件记录 `mail_room` gem 中的内部活动。其名称和路径是可配置的，因此名称和路径可能与前面记录的此名称和路径不匹配。

<a id="web_hookslog"></a>

## `web_hooks.log`

此日志位于：

- Linux 软件包安装的 `/var/log/gitlab/gitlab-rails/web_hooks.log` 文件中。
- 自编译安装的 `/home/git/gitlab/log/web_hooks.log` 文件中。
- Helm chart 安装的 Sidekiq Pod 上，位于 `subcomponent="web_hooks"` 键下。

Webhook 的退避、禁用和重新启用事件记录在此文件中。例如：

```json
{"severity":"INFO","time":"2020-11-24T02:30:59.860Z","hook_id":12,"action":"backoff","disabled_until":"2020-11-24T04:30:59.860Z","recent_failures":2}
{"severity":"INFO","time":"2020-11-24T02:30:59.860Z","hook_id":12,"action":"disable","disabled_until":null,"recent_failures":100}
{"severity":"INFO","time":"2020-11-24T02:30:59.860Z","hook_id":12,"action":"enable","disabled_until":null,"recent_failures":0}
```

<a id="reconfigure-logs"></a>

## 重新配置日志

对于 Linux 软件包安装，重新配置日志文件位于 `/var/log/gitlab/reconfigure`。自编译安装没有重新配置日志。每当手动运行 `gitlab-ctl reconfigure` 或作为升级的一部分运行时，都会生成重新配置日志。

重新配置日志文件根据重新配置启动时的 UNIX 时间戳命名，例如 `1509705644.log`

<a id="sidekiq_exporterlog-and-web_exporterlog"></a>

## `sidekiq_exporter.log` 和 `web_exporter.log`

如果同时启用 Prometheus 指标和 Sidekiq Exporter，Sidekiq 会启动一个 Web 服务器并监听定义的端口（默认：`8082`）。默认情况下，Sidekiq Exporter 访问日志是禁用的，但可以启用：

- 在 Linux 软件包安装的 `/etc/gitlab/gitlab.rb` 中使用 `sidekiq['exporter_log_enabled'] = true` 选项。
- 在自编译安装的 `gitlab.yml` 中使用 `sidekiq_exporter.log_enabled` 选项。

启用后，根据您的安装方法，此文件位于：

- Linux 软件包安装的 `/var/log/gitlab/gitlab-rails/sidekiq_exporter.log`。
- 自编译安装的 `/home/git/gitlab/log/sidekiq_exporter.log`。

如果同时启用 Prometheus 指标和 Web Exporter，Puma 会启动一个 Web 服务器并监听定义的端口（默认：`8083`），并根据您的安装方法在某个位置生成访问日志：

- Linux 软件包安装的 `/var/log/gitlab/gitlab-rails/web_exporter.log`。
- 自编译安装的 `/home/git/gitlab/log/web_exporter.log`。

<a id="database_load_balancinglog"></a>

## `database_load_balancing.log`

{{< details >}}

- Tier: 专业版，旗舰版
- Offering: 私有化部署

{{< /details >}}

包含极狐GitLab [数据库负载均衡](../postgresql/database_load_balancing.md)的详细信息。

此日志位于：

- Linux 软件包安装的 `/var/log/gitlab/gitlab-rails/database_load_balancing.log` 文件中。
- 自编译安装的 `/home/git/gitlab/log/database_load_balancing.log` 文件中。
- Helm chart 安装的 Sidekiq 和 Webservice Pod 上，位于 `subcomponent="database_load_balancing"` 键下。

<a id="zoektlog"></a>

## `zoekt.log`

{{< details >}}

- Tier: 专业版，旗舰版
- Offering: 私有化部署

{{< /details >}}

此文件记录与[精确代码搜索](../../user/search/exact_code_search.md)相关的信息。

此日志位于：

- Linux 软件包安装的 `/var/log/gitlab/gitlab-rails/zoekt.log` 文件中。
- 自编译安装的 `/home/git/gitlab/log/zoekt.log` 文件中。
- Helm chart 安装的 Sidekiq 和 Webservice Pod 上，位于 `subcomponent="zoekt"` 键下。

<a id="zoektlog-fields"></a>

### `zoekt.log` 字段

来自周期性指标 cron 作业的条目通过 `metric` 字段（`node_metrics` 或 `indices_metrics`）进行区分。每个请求的日志条目不携带 `metric` 字段，而是将下面记录的 Zoekt 字段附加到捕获它们的任何 Rails 请求或 Sidekiq 作业日志行中。

<a id="node-metrics-entries-metric-node_metrics"></a>

#### 节点指标条目 (`metric: node_metrics`)

这些条目由周期性指标 cron 作业为每个在线的 Zoekt 节点发出一次。

| 字段 | 类型 | 描述 |
|:------|:-----|:------------|
| `enabled_namespaces_count` | 整数 | 在此节点上启用精确代码搜索的命名空间数量 |
| `indices_count` | 整数 | 此节点上的代码仓库索引数量 |
| `task_count_pending` | 整数 | 处于 `pending` 状态的索引任务数量 |
| `task_count_failed` | 整数 | 处于 `failed` 状态的索引任务数量 |
| `task_count_processing_queue` | 整数 | 准备好处理的索引任务数量（状态为 `pending` 或 `processing` 且 `perform_at <= now`） |
| `task_count_orphaned` | 整数 | 处于 `orphaned` 状态的索引任务数量 |
| `task_count_done` | 整数 | 处于 `done` 状态的索引任务数量 |
| `meta` | 对象 | 节点元数据，包括节点 ID 和 URL |

<a id="indices-metrics-entries-metric-indices_metrics"></a>

#### 索引指标条目 (`metric: indices_metrics`)

这些条目在每个指标收集周期发出一次。

键 `meta.zoekt.with_stale_used_storage_bytes_updated_at` 是一个带点的字面量扁平键名，不是嵌套对象路径。

| 字段 | 类型 | 描述 |
|:------|:-----|:------------|
| `meta.zoekt.with_stale_used_storage_bytes_updated_at` | 整数 | `used_storage_bytes` 值最近未更新的 Zoekt 索引数量 |

<a id="per-request-fields"></a>

#### 每个请求的字段

这些字段出现在从 GitLab Rails 到 Zoekt 节点的每个 HTTP 请求发出的日志条目中。

| 字段 | 类型 | 描述 |
|:------|:-----|:------------|
| `zoekt_calls` | 整数 | 在此 Rails 请求期间发出的 Zoekt HTTP 请求数量 |
| `zoekt_duration_s` | 浮点数 | 在此 Rails 请求期间等待 Zoekt 响应所花费的总时间（秒） |

<a id="elasticsearchlog"></a>

## `elasticsearch.log`

{{< details >}}

- Tier: 专业版，旗舰版
- Offering: 私有化部署

{{< /details >}}

此文件记录与 Elasticsearch 集成相关的信息，包括索引或搜索 Elasticsearch 期间的错误。

此日志位于：

- Linux 软件包安装的 `/var/log/gitlab/gitlab-rails/elasticsearch.log` 文件中。
- 自编译安装的 `/home/git/gitlab/log/elasticsearch.log` 文件中。
- Helm chart 安装的 Sidekiq 和 Webservice Pod 上，位于 `subcomponent="elasticsearch"` 键下。

每行包含可由 Elasticsearch 和 Splunk 等服务接收的 JSON。为清晰起见，以下示例行中添加了换行符：

```json
{
  "severity":"DEBUG",
  "time":"2019-10-17T06:23:13.227Z",
  "correlation_id":null,
  "message":"redacted_search_result",
  "class_name":"Milestone",
  "id":2,
  "ability":"read_milestone",
  "current_user_id":2,
  "query":"project"
}
```

<a id="exceptions_jsonlog"></a>

## `exceptions_json.log`

此文件记录由 `Gitlab::ErrorTracking` 跟踪的异常信息，它提供了一种标准且一致的方式来处理被捕获的异常。

此日志位于：

- Linux 软件包安装的 `/var/log/gitlab/gitlab-rails/exceptions_json.log` 文件中。
- 自编译安装的 `/home/git/gitlab/log/exceptions_json.log` 文件中。
- Helm chart 安装的 Sidekiq 和 Webservice Pod 上，位于 `subcomponent="exceptions_json"` 键下。

每行包含可由 Elasticsearch 接收的 JSON。例如：

```json
{
  "severity": "ERROR",
  "time": "2019-12-17T11:49:29.485Z",
  "correlation_id": "AbDVUrrTvM1",
  "extra.project_id": 55,
  "extra.relation_key": "milestones",
  "extra.relation_index": 1,
  "exception.class": "NoMethodError",
  "exception.message": "undefined method `strong_memoize' for #<Gitlab::ImportExport::RelationFactory:0x00007fb5d917c4b0>",
  "exception.backtrace": [
    "lib/gitlab/import_export/relation_factory.rb:329:in `unique_relation?'",
    "lib/gitlab/import_export/relation_factory.rb:345:in `find_or_create_object!'"
  ]
}
```

<a id="service_measurementlog"></a>

## `service_measurement.log`

此日志位于：

- Linux 软件包安装的 `/var/log/gitlab/gitlab-rails/service_measurement.log` 文件中。
- 自编译安装的 `/home/git/gitlab/log/service_measurement.log` 文件中。
- Helm chart 安装的 Sidekiq 和 Webservice Pod 上，位于 `subcomponent="service_measurement"` 键下。

它仅包含一个带有每次服务执行测量的结构化日志。它包含诸如 SQL 调用次数、`execution_time`、`gc_stats` 和 `memory usage` 等测量值。

例如：

```json
{ "severity":"INFO", "time":"2020-04-22T16:04:50.691Z","correlation_id":"04f1366e-57a1-45b8-88c1-b00b23dc3616","class":"Projects::ImportExport::ExportService","current_user":"John Doe","project_full_path":"group1/test-export","file_path":"/path/to/archive","gc_stats":{"count":{"before":127,"after":127,"diff":0},"heap_allocated_pages":{"before":10369,"after":10369,"diff":0},"heap_sorted_length":{"before":10369,"after":10369,"diff":0},"heap_allocatable_pages":{"before":0,"after":0,"diff":0},"heap_available_slots":{"before":4226409,"after":4226409,"diff":0},"heap_live_slots":{"before":2542709,"after":2641420,"diff":98711},"heap_free_slots":{"before":1683700,"after":1584989,"diff":-98711},"heap_final_slots":{"before":0,"after":0,"diff":0},"heap_marked_slots":{"before":2542704,"after":2542704,"diff":0},"heap_eden_pages":{"before":10369,"after":10369,"diff":0},"heap_tomb_pages":{"before":0,"after":0,"diff":0},"total_allocated_pages":{"before":10369,"after":10369,"diff":0},"total_freed_pages":{"before":0,"after":0,"diff":0},"total_allocated_objects":{"before":24896308,"after":24995019,"diff":98711},"total_freed_objects":{"before":22353599,"after":22353599,"diff":0},"malloc_increase_bytes":{"before":140032,"after":6650240,"diff":6510208},"malloc_increase_bytes_limit":{"before":25804104,"after":25804104,"diff":0},"minor_gc_count":{"before":94,"after":94,"diff":0},"major_gc_count":{"before":33,"after":33,"diff":0},"remembered_wb_unprotected_objects":{"before":34284,"after":34284,"diff":0},"remembered_wb_unprotected_objects_limit":{"before":68568,"after":68568,"diff":0},"old_objects":{"before":2404725,"after":2404725,"diff":0},"old_objects_limit":{"before":4809450,"after":4809450,"diff":0},"oldmalloc_increase_bytes":{"before":140032,"after":6650240,"diff":6510208},"oldmalloc_increase_bytes_limit":{"before":68537556,"after":68537556,"diff":0}},"time_to_finish":0.12298400001600385,"number_of_sql_calls":70,"memory_usage":"0.0 MiB","label":"process_48616"}
```

<a id="geolog"></a>

## `geo.log`

{{< details >}}

- Tier: 专业版，旗舰版
- Offering: 私有化部署

{{< /details >}}

此日志位于：

- Linux 软件包安装的 `/var/log/gitlab/gitlab-rails/geo.log` 文件中。
- 自编译安装的 `/home/git/gitlab/log/geo.log` 文件中。
- Helm chart 安装的 Sidekiq 和 Webservice Pod 上，位于 `subcomponent="geo"` 键下。

此文件包含有关 Geo 何时尝试同步代码仓库和文件的信息。文件中的每一行都包含一个单独的 JSON 条目，可以被（例如，Elasticsearch 或 Splunk）接收。

例如：

```json
{"severity":"INFO","time":"2017-08-06T05:40:16.104Z","message":"Repository update","project_id":1,"source":"repository","resync_repository":true,"resync_wiki":true,"class":"Gitlab::Geo::LogCursor::Daemon","cursor_delay_s":0.038}
```

此消息显示 Geo 检测到项目 `1` 需要更新代码仓库。

<a id="update_mirror_service_jsonlog"></a>

## `update_mirror_service_json.log`

此日志位于：

- Linux 软件包安装的 `/var/log/gitlab/gitlab-rails/update_mirror_service_json.log` 文件中。
- 自编译安装的 `/home/git/gitlab/log/update_mirror_service_json.log` 文件中。
- Helm chart 安装的 Sidekiq Pod 上，位于 `subcomponent="update_mirror_service_json"` 键下。

此文件包含项目镜像期间发生的 LFS 错误信息。在其他项目镜像错误迁移到此日志之前，可以使用[通用日志](#productionlog)。

```json
{
   "severity":"ERROR",
   "time":"2020-07-28T23:29:29.473Z",
   "correlation_id":"5HgIkCJsO53",
   "user_id":"x",
   "project_id":"x",
   "import_url":"https://mirror-source/group/project.git",
   "error_message":"The LFS objects download list couldn't be imported. Error: Unauthorized"
}
```

<a id="llmlog"></a>

## `llm.log`

{{< details >}}

- Tier: 专业版，旗舰版
- Offering: JihuLab.com，私有化部署

{{< /details >}}

`llm.log` 文件记录与 [AI 功能](../../user/gitlab_duo/_index.md) 相关的信息。日志记录包括有关 AI 事件的信息。

<a id="llm-input-and-output-logging"></a>

### LLM 输入和输出日志记录

> [!flag]
> 此功能的可用性由功能标志控制。
> 此功能可用于测试，但尚未准备好用于生产环境。

要记录 LLM 提示输入和响应输出，请启用 `expanded_ai_logging` 功能标志。此标志仅用于 JihuLab.com，不用于极狐GitLab 私有化部署实例。

此标志默认禁用，并且只能通过以下方式启用：

- 对于 JihuLab.com，当您通过 GitLab [支持工单](https://about.gitlab.com/support/portal/) 提供同意时。

默认情况下，日志不包含 LLM 提示输入和响应输出，以支持 AI 功能数据的[数据保留策略](../../user/gitlab_duo/data_usage.md#data-retention)。

日志文件位于：

- Linux 软件包安装的 `/var/log/gitlab/gitlab-rails/llm.log` 文件中。
- 自编译安装的 `/home/git/gitlab/log/llm.log` 文件中。
- Helm chart 安装的 Webservice Pod 上，位于 `subcomponent="llm"` 键下。

<a id="mcplog"></a>

## `mcp.log`

{{< details >}}

- Tier: 专业版，旗舰版
- Offering: JihuLab.com，私有化部署

{{< /details >}}

`mcp.log` 文件记录与 [极狐GitLab MCP 服务器](../../user/gitlab_duo/model_context_protocol/mcp_server.md) 相关的信息。日志记录包括 MCP 服务器可用性拒绝，并带有 `denial_reason` 字段，说明请求被拒绝的原因。

日志文件位于：

- Linux 软件包安装的 `/var/log/gitlab/gitlab-rails/mcp.log` 文件中。
- 自编译安装的 `/home/git/gitlab/log/mcp.log` 文件中。
- Helm chart 安装的 Webservice Pod 上，位于 `subcomponent="mcp"` 键下。

<a id="epic_work_item_synclog"></a>

## `epic_work_item_sync.log`

{{< details >}}

- Tier: 专业版，旗舰版
- Offering: JihuLab.com，私有化部署

{{< /details >}}

`epic_work_item_sync.log` 文件记录与将史诗作为工作项同步和迁移相关的信息。

此日志位于：

- Linux 软件包安装的 `/var/log/gitlab/gitlab-rails/epic_work_item_sync.log` 文件中。
- 自编译安装的 `/home/git/gitlab/log/epic_work_item_sync.log` 文件中。
- Helm chart 安装的 Sidekiq 和 Webservice Pod 上，位于 `subcomponent="epic_work_item_sync"` 键下。

<a id="secret_push_protectionlog"></a>

## `secret_push_protection.log`

{{< details >}}

- Tier: 旗舰版
- Offering: JihuLab.com

{{< /details >}}

`secret_push_protection.log` 文件记录与[密钥推送保护](../../user/application_security/secret_detection/secret_push_protection/_index.md)功能相关的信息。

此日志位于：

- Linux 软件包安装的 `/var/log/gitlab/gitlab-rails/secret_push_protection.log` 文件中。
- 自编译安装的 `/home/git/gitlab/log/secret_push_protection.log` 文件中。
- Helm chart 安装的 Webservice Pod 上，位于 `subcomponent="secret_push_protection"` 键下。

<a id="active_contextlog"></a>

## `active_context.log`

{{< details >}}

- Tier: 专业版，旗舰版
- Offering: JihuLab.com，私有化部署

{{< /details >}}

`active_context.log` 文件记录通过 [`ActiveContext` 层](https://handbook.gitlab.com/handbook/engineering/architecture/design-documents/ai_context_abstraction_layer/) 嵌入流水线的相关信息。

极狐GitLab 支持 `ActiveContext` 代码嵌入。此流水线处理项目代码文件的嵌入生成。更多信息，请参阅[架构设计](https://handbook.gitlab.com/handbook/engineering/architecture/design-documents/codebase_as_chat_context/code_embeddings/)。

此日志位于：

- Linux 软件包安装的 `/var/log/gitlab/gitlab-rails/active_context.log` 文件中。
- 自编译安装的 `/home/git/gitlab/log/active_context.log` 文件中。
- Helm chart 安装的 Sidekiq Pod 上，位于 `subcomponent="activecontext"` 键下。

<a id="ai_cataloglog"></a>

## `ai_catalog.log`

{{< details >}}

- Tier: 专业版，旗舰版
- Offering: JihuLab.com，私有化部署

{{< /details >}}

`ai_catalog.log` 文件记录与 [AI 目录](../../user/duo_agent_platform/ai_catalog.md) 相关的信息，包括何时执行 AI 目录任务流和 Agent。

此日志位于：

- Linux 软件包安装的 `/var/log/gitlab/gitlab-rails/ai_catalog.log` 文件中。
- 自编译安装的 `/home/git/gitlab/log/ai_catalog.log` 文件中。
- Helm chart 安装的 Sidekiq Pod 上，位于 `subcomponent="ai_catalog"` 键下。

<a id="user_experience_slislog"></a>

## `user_experience_slis.log`

此日志位于：

- Linux 软件包安装的 `/var/log/gitlab/gitlab-rails/user_experience_slis.log` 文件中。
- 自编译安装的 `/home/git/gitlab/log/user_experience_slis.log` 文件中。
- Helm chart 安装的 Webservice Pod 上，位于 `subcomponent="user_experience_slis"` 键下。

它包含与指标匹配的用户体验 SLI 的 JSON 结构化日志。

每行包含可由 Elasticsearch 等服务接收的 JSON。

示例：

```json
{
  "checkpoint": "start",
  "component": "gitlab",
  "correlation_id": "3823a1550b64417f9c9ed8ee0f48087e",
  "covered_experience": "create_merge_request",
  "elapsed_time_s": 0,
  "environment": "gprd",
  "feature_category": "code_review_workflow",
  "logtag": "F",
  "meta": {
    "caller_id": "Projects::MergeRequests::CreationsController#create",
    "client_id": "user/123",
    "feature_category": "code_review_workflow",
    "gl_user_id": 123,
    "organization_id": 456,
    "project": "project/path/here",
    "remote_ip": "x.x.x.x",
    "root_namespace": "project",
    "subscription_plan": "ultimate",
    "user": "a_username"
  },
  "severity": "INFO",
  "shard": "default",
  "stage": "cny",
  "start_time": "2025-10-31 15:21:40 UTC",
  "subcomponent": "user_experience_slis",
  "tag": "web-cny-rails.var.log.containers.gitlab-cny-webservice-web-123-abc_gitlab-cny_webservice-4567890.log",
  "tier": "sv",
  "time": "2025-10-31T15:21:40.333Z",
  "type": "web",
  "urgency": "async_fast",
  "urgency_threshold_s": 15
}
```

可用字段记录在[用户体验 SLI 设计文档](https://handbook.gitlab.com/handbook/engineering/architecture/design-documents/user_experience_slis/#sdk-requirements)中。

<a id="registry-logs"></a>

## Registry 日志

对于 Linux 软件包安装，容器镜像仓库日志位于 `/var/log/gitlab/registry/current`。

<a id="nginx-logs"></a>

## NGINX 日志

对于 Linux 软件包安装，NGINX 日志位于：

- `/var/log/gitlab/nginx/gitlab_access.log`：对极狐GitLab 发出的请求日志
- `/var/log/gitlab/nginx/gitlab_error.log`：极狐GitLab 的 NGINX 错误日志
- `/var/log/gitlab/nginx/gitlab_pages_access.log`：对 Pages 静态站点发出的请求日志
- `/var/log/gitlab/nginx/gitlab_pages_error.log`：Pages 静态站点的 NGINX 错误日志
- `/var/log/gitlab/nginx/gitlab_registry_access.log`：对容器镜像仓库发出的请求日志
- `/var/log/gitlab/nginx/gitlab_registry_error.log`：容器镜像仓库的 NGINX 错误日志
- `/var/log/gitlab/nginx/gitlab_mattermost_access.log`：对 Mattermost 发出的请求日志
- `/var/log/gitlab/nginx/gitlab_mattermost_error.log`：Mattermost 的 NGINX 错误日志

以下是默认的极狐GitLab NGINX 访问日志格式：

```plaintext
'$remote_addr - $remote_user [$time_local] "$request" $status $body_bytes_sent "$http_referer" "$http_user_agent"'
```

`$request` 和 `$http_referer` 会[过滤](https://gitlab.com/gitlab-org/gitlab/-/blob/master/lib/support/nginx/gitlab)敏感的查询字符串参数，例如密钥令牌。

<a id="pages-logs"></a>

## Pages 日志

对于 Linux 软件包安装，Pages 日志位于 `/var/log/gitlab/gitlab-pages/current`。

例如：

```json
{
  "level": "info",
  "msg": "GitLab Pages Daemon",
  "revision": "52b2899",
  "time": "2020-04-22T17:53:12Z",
  "version": "1.17.0"
}
{
  "level": "info",
  "msg": "URL: https://gitlab.com/gitlab-org/gitlab-pages",
  "time": "2020-04-22T17:53:12Z"
}
{
  "gid": 998,
  "in-place": false,
  "level": "info",
  "msg": "running the daemon as unprivileged user",
  "time": "2020-04-22T17:53:12Z",
  "uid": 998
}
```

<a id="product-usage-data-log"></a>

## 产品使用数据日志

> [!note]
> 不建议使用原始日志分析功能使用情况，因为数据质量尚未经过准确性认证。
>
> 事件列表可能因新功能或现有功能的更改而在每个版本中发生变化。经过认证的产品内采用报告将在数据准备好分析后提供。

此日志位于：

- Linux 软件包安装的 `/var/log/gitlab/gitlab-rails/product_usage_data.log` 文件中。
- 自编译安装的 `/home/git/gitlab/log/product_usage_data.log` 文件中。
- Helm chart 安装的 Webservice Pod 上，位于 `subcomponent="product_usage_data"` 键下。

它包含通过 Snowplow 跟踪的产品使用事件的 JSON 格式日志。文件中的每一行都包含一个单独的 JSON 条目，可以被 Elasticsearch 或 Splunk 等服务接收。为便于阅读，示例中添加了换行符：

```json
{
  "severity":"INFO",
  "time":"2025-04-09T13:43:40.254Z",
  "message":"sending event",
  "payload":"{
  \"e\":\"se\",
  \"se_ca\":\"projects:merge_requests:diffs\",
  \"se_ac\":\"i_code_review_user_searches_diff\",
  \"cx\":\"eyJzY2hlbWEiOiJpZ2x1OmNvbS5zbm93cGxvd2FuYWx5dGljcy5zbm93cGxvdy9jb250ZXh0cy9qc29uc2NoZW1hLzEtMC0xIiwiZGF0YSI6W3sic2NoZW1hIjoiaWdsdTpjb20uZ2l0bGFiL2dpdGxhYl9zdGFuZGFyZC9qc29uc2NoZW1hLzEtMS0xIiwiZGF0YSI6eyJlbnZpcm9ubWVudCI6ImRldmVsb3BtZW50Iiwic291cmNlIjoiZ2l0bGFiLXJhaWxzIiwiY29ycmVsYXRpb25faWQiOiJlNDk2NzNjNWI2MGQ5ODc0M2U4YWI0MjZiMTZmMTkxMiIsInBsYW4iOiJkZWZhdWx0IiwiZXh0cmEiOnt9LCJ1c2VyX2lkIjpudWxsLCJnbG9iYWxfdXNlcl9pZCI6bnVsbCwiaXNfZ2l0bGFiX3RlYW1fbWVtYmVyIjpudWxsLCJuYW1lc3BhY2VfaWQiOjMxLCJwcm9qZWN0X2lkIjo2LCJmZWF0dXJlX2VuYWJsZWRfYnlfbmFtZXNwYWNlX2lkcyI6bnVsbCwicmVhbG0iOiJzZWxmLW1hbmFnZWQiLCJpbnN0YW5jZV9pZCI6IjJkMDg1NzBkLWNmZGItNDFmMy1iODllLWM3MTM5YmFjZTI3NSIsImhvc3RfbmFtZSI6ImpsYXJzZW4tLTIwMjIxMjE0LVBWWTY5IiwiaW5zdGFuY2VfdmVyc2lvbiI6IjE3LjExLjAiLCJjb250ZXh0X2dlbmVyYXRlZF9hdCI6IjIwMjUtMDQtMDkgMTM6NDM6NDAgVVRDIn19LHsic2NoZW1hIjoiaWdsdTpjb20uZ2l0bGFiL2dpdGxhYl9zZXJ2aWNlX3BpbmcvanNvbnNjaGVtYS8xLTAtMSIsImRhdGEiOnsiZGF0YV9zb3VyY2UiOiJyZWRpc19obGwiLCJldmVudF9uYW1lIjoiaV9jb2RlX3Jldmlld191c2VyX3NlYXJjaGVzX2RpZmYifX1dfQ==\",
  \"p\":\"srv\",
  \"dtm\":\"1744206220253\",
  \"tna\":\"gl\",
  \"tv\":\"rb-0.8.0\",
  \"eid\":\"4f067989-d10d-40b0-9312-ad9d7355be7f\"
}
```

要检查这些日志，您可以使用 [Rake 任务](../raketasks/_index.md) `product_usage_data:format`，它会格式化 JSON 输出并解码 base64 编码的上下文数据，以提高可读性：

```shell
gitlab-rake "product_usage_data:format[log/product_usage_data.log]"
# or pipe the logs directly
cat log/product_usage_data.log | gitlab-rake product_usage_data:format
# or tail the logs in real-time
tail -f log/product_usage_data.log | gitlab-rake product_usage_data:format
```

您可以通过将 `GITLAB_DISABLE_PRODUCT_USAGE_EVENT_LOGGING` 环境变量设置为任意值来禁用此日志。

<a id="lets-encrypt-logs"></a>

## Let's Encrypt 日志

对于 Linux 软件包安装，Let's Encrypt [自动续期](https://gitlab.cn/docs/omnibus/settings/ssl/#renew-the-certificates-automatically) 日志位于 `/var/log/gitlab/lets-encrypt/`。

<a id="mattermost-logs"></a>

## Mattermost 日志

对于 Linux 软件包安装，Mattermost 日志位于以下位置：

- `/var/log/gitlab/mattermost/mattermost.log`
- `/var/log/gitlab/mattermost/current`

<a id="workhorse-logs"></a>

## Workhorse 日志

对于 Linux 软件包安装，Workhorse 日志位于 `/var/log/gitlab/gitlab-workhorse/current`。

<a id="patroni-logs"></a>

## Patroni 日志

对于 Linux 软件包安装，Patroni 日志位于 `/var/log/gitlab/patroni/current`。

<a id="pgbouncer-logs"></a>

## PgBouncer 日志

对于 Linux 软件包安装，PgBouncer 日志位于 `/var/log/gitlab/pgbouncer/current`。

<a id="postgresql-logs"></a>

## PostgreSQL 日志

对于 Linux 软件包安装，PostgreSQL 日志位于 `/var/log/gitlab/postgresql/current`。

如果使用 Patroni，PostgreSQL 日志将存储在 [Patroni 日志](#patroni-logs) 中。

<a id="prometheus-logs"></a>

## Prometheus 日志

对于 Linux 软件包安装，Prometheus 日志位于 `/var/log/gitlab/prometheus/current`。

<a id="redis-logs"></a>

## Redis 日志

对于 Linux 软件包安装，Redis 日志位于 `/var/log/gitlab/redis/current`。

<a id="sentinel-logs"></a>

## Sentinel 日志

对于 Linux 软件包安装，Sentinel 日志位于 `/var/log/gitlab/sentinel/current`。

<a id="alertmanager-logs"></a>

## Alertmanager 日志

对于 Linux 软件包安装，Alertmanager 日志位于 `/var/log/gitlab/alertmanager/current`。

<a id="consul-logs"></a>

## Consul 日志

对于 Linux 软件包安装，Consul 日志位于 `/var/log/gitlab/consul/current`。

<!-- vale gitlab_base.Spelling = NO -->

<a id="crond-logs"></a>

## crond 日志

对于 Linux 软件包安装，crond 日志位于 `/var/log/gitlab/crond/`。

<!-- vale gitlab_base.Spelling = YES -->

<a id="grafana-logs"></a>

## Grafana 日志

对于 Linux 软件包安装，Grafana 日志位于 `/var/log/gitlab/grafana/current`。

<a id="logrotate-logs"></a>

## LogRotate 日志

对于 Linux 软件包安装，`logrotate` 日志位于 `/var/log/gitlab/logrotate/current`。

<a id="gitlab-monitor-logs"></a>

## GitLab Monitor 日志

对于 Linux 软件包安装，GitLab Monitor 日志位于 `/var/log/gitlab/gitlab-monitor/`。

<a id="gitlab-exporter-logs"></a>

## GitLab Exporter 日志

对于 Linux 软件包安装，GitLab Exporter 日志位于 `/var/log/gitlab/gitlab-exporter/current`。

<a id="gitlab-agent-server-for-kubernetes-logs"></a>

## 用于 Kubernetes 的 GitLab agent server 日志

对于 Linux 软件包安装，用于 Kubernetes 的 GitLab agent server 日志位于 `/var/log/gitlab/gitlab-kas/current`。

<a id="praefect-logs"></a>

## Praefect 日志

对于 Linux 软件包安装，Praefect 日志位于 `/var/log/gitlab/praefect/`。

极狐GitLab 还跟踪 [Gitaly 集群 (Praefect)的 Prometheus 指标](../gitaly/praefect/monitoring.md)。

<a id="backup-log"></a>

## 备份日志

对于 Linux 软件包安装，备份日志位于 `/var/log/gitlab/gitlab-rails/backup_json.log`。

在 Helm chart 安装中，备份日志存储在 Toolbox Pod 中，位于 `/var/log/gitlab/backup_json.log`。

当创建[极狐GitLab 备份](../backup_restore/_index.md)时，会生成此日志。您可以使用此日志来了解备份过程的执行情况。

<a id="performance-bar-stats"></a>

## 性能栏统计信息

此日志位于：

- Linux 软件包安装的 `/var/log/gitlab/gitlab-rails/performance_bar_json.log` 文件中。
- 自编译安装的 `/home/git/gitlab/log/performance_bar_json.log` 文件中。
- Helm chart 安装的 Sidekiq Pod 上，位于 `subcomponent="performance_bar_json"` 键下。

性能栏统计信息（目前仅限 SQL 查询的持续时间）记录在该文件中。例如：

```json
{"severity":"INFO","time":"2020-12-04T09:29:44.592Z","correlation_id":"33680b1490ccd35981b03639c406a697","filename":"app/models/ci/pipeline.rb","method_path":"app/models/ci/pipeline.rb:each_with_object","request_id":"rYHomD0VJS4","duration_ms":26.889,"count":2,"query_type": "active-record"}
```

这些统计信息仅在 JihuLab.com 上记录，在私有化部署环境中禁用。

<a id="gathering-logs"></a>

## 收集日志

在[排查](../troubleshooting/_index.md)并非局限于前面所列组件之一的问题时，同时从极狐GitLab 实例收集多个日志和统计数据会很有帮助。

> [!note]
> GitLab Support 通常会要求提供其中一种，并维护所需工具。

<a id="briefly-tail-the-main-logs"></a>

### 简要跟踪主要日志

如果错误或缺陷易于复现，请在多次复现问题的同时，将主要极狐GitLab 日志保存[到文件](../troubleshooting/linux_cheat_sheet.md#files-and-directories)：

```shell
sudo gitlab-ctl tail | tee /tmp/<case-ID-and-keywords>.log
```

日志收集结束时，按 <kbd>Control</kbd> + <kbd>C</kbd> 结束。

<a id="gathering-sos-logs"></a>

### 收集 SOS 日志

如果出现性能下降或级联错误，且无法轻易归因于前面所列的某个极狐GitLab 组件，请[使用我们的 SOS 脚本](../troubleshooting/diagnostics_tools.md#sos-scripts)。

<a id="fast-stats"></a>

### Fast-stats

[Fast-stats](https://gitlab.com/gitlab-com/support/toolbox/fast-stats) 是一个用于从极狐GitLab 日志创建和比较性能统计数据的工具。
有关更多详情和运行说明，请阅读 [fast-stats 文档](https://gitlab.com/gitlab-com/support/toolbox/fast-stats#usage)。

<a id="find-relevant-log-entries-with-a-correlation-id"></a>

## 使用关联 ID 查找相关日志条目

大多数请求都有一个日志 ID，可用于[查找相关日志条目](tracing_correlation_id.md)。
