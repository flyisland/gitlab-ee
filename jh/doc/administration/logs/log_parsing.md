---
stage: GitLab Delivery
group: Operate
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
title: 使用 `jq` 解析极狐GitLab 日志
---

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: 私有化部署

{{< /details >}}

建议尽可能使用 Kibana 和 Splunk 等日志聚合与搜索工具，但如果这些工具不可用，您仍然可以使用 [`jq`](https://stedolan.github.io/jq/) 快速解析 JSON 格式的[极狐GitLab 日志](_index.md)。

> [!note]
> 具体而言，若要汇总错误事件和基本使用统计数据，极狐GitLab 支持团队提供了专门的 [`fast-stats` 工具](https://gitlab.com/gitlab-com/support/toolbox/fast-stats/#when-to-use-it)。它处理大型日志的速度通常比 `jq` 快得多，并且输出的统计信息范围也更广。

<a id="what-is-jq"></a>

## 什么是 JQ？

正如其[手册](https://stedolan.github.io/jq/manual/)所述，`jq` 是一个命令行 JSON 处理器。以下示例包含针对解析极狐GitLab 日志文件的用例。

<a id="parsing-logs"></a>

## 解析日志

下面列出的示例通过各自的 Linux 软件包安装相对路径和默认文件名来定位相应的日志文件。请在[极狐GitLab 日志章节](_index.md#production_jsonlog)中查找各自的完整路径。

<a id="compressed-logs"></a>

### 压缩日志

当[日志文件轮转](https://smarden.org/runit/svlogd.8)时，它们会以 Unix 时间戳格式重命名，并使用 `gzip` 压缩。生成的文件名类似于 `@40000000624492fa18da6f34.s`。与较新的日志文件相比，这些文件在解析前必须以不同的方式处理：

- 要解压文件，请使用 `gunzip -S .s @40000000624492fa18da6f34.s`，并将文件名替换为您的压缩日志文件名。
- 要直接读取或通过管道传递文件，请使用 `zcat` 或 `zless`。
- 要搜索文件内容，请使用 `zgrep`。

<a id="general-commands"></a>

### 通用命令

<a id="pipe-colorized-jq-output-into-less"></a>

#### 将带颜色的 `jq` 输出通过管道传递给 `less`

```shell
jq . <FILE> -C | less -R
```

<a id="search-for-a-term-and-pretty-print-all-matching-lines"></a>

#### 搜索某个词并美化打印所有匹配的行

```shell
grep <TERM> <FILE> | jq .
```

<a id="skip-invalid-lines-of-json"></a>

#### 跳过无效的 JSON 行

```shell
jq -cR 'fromjson?' file.json | jq <COMMAND>
```

默认情况下，当 `jq` 遇到不是有效 JSON 的行时会报错。此命令会跳过所有无效行并解析其余部分。

<a id="print-a-json-logs-time-range"></a>

#### 打印 JSON 日志的时间范围

```shell
cat log.json | (head -1; tail -1) | jq '.time'
```

如果文件已轮转并压缩，请使用 `zcat`：

```shell
zcat @400000006026b71d1a7af804.s | (head -1; tail -1) | jq '.time'

zcat some_json.log.25.gz | (head -1; tail -1) | jq '.time'
```

<a id="get-activity-for-correlation-id-across-multiple-json-logs-in-chronological-order"></a>

#### 按时间顺序获取多个 JSON 日志中某个关联 ID 的活动

```shell
grep -hR <correlationID> | jq -c -R 'fromjson?' | jq -C -s 'sort_by(.time)'  | less -R
```

<a id="parsing-gitlab-railsproduction_jsonlog-and-gitlab-railsapi_jsonlog"></a>

### 解析 `gitlab-rails/production_json.log` 和 `gitlab-rails/api_json.log`

<a id="find-all-requests-with-a-5xx-status-code"></a>

#### 查找所有状态码为 5XX 的请求

```shell
jq 'select(.status >= 500)' <FILE>
```

<a id="top-10-slowest-requests"></a>

#### 最慢的 10 个请求

```shell
jq -s 'sort_by(-.duration_s) | limit(10; .[])' <FILE>
```

<a id="find-and-pretty-print-all-requests-related-to-a-project"></a>

#### 查找并美化打印与某个项目相关的所有请求

```shell
grep <PROJECT_NAME> <FILE> | jq .
```

<a id="find-all-requests-with-a-total-duration--5-seconds"></a>

#### 查找总时长超过 5 秒的所有请求

```shell
jq 'select(.duration_s > 5000)' <FILE>
```

<a id="find-all-project-requests-with-more-than-5-gitaly-calls"></a>

#### 查找 Gitaly 调用次数超过 5 次的所有项目请求

```shell
grep <PROJECT_NAME> <FILE> | jq 'select(.gitaly_calls > 5)'
```

<a id="find-all-requests-with-a-gitaly-duration--10-seconds"></a>

#### 查找 Gitaly 时长超过 10 秒的所有请求

```shell
jq 'select(.gitaly_duration_s > 10000)' <FILE>
```

<a id="find-all-requests-with-a-queue-duration--10-seconds"></a>

#### 查找队列时长超过 10 秒的所有请求

```shell
jq 'select(.queue_duration_s > 10000)' <FILE>
```

<a id="top-10-requests-by--of-gitaly-calls"></a>

#### 按 Gitaly 调用次数排名的前 10 个请求

```shell
jq -s 'map(select(.gitaly_calls != null)) | sort_by(-.gitaly_calls) | limit(10; .[])' <FILE>
```

<a id="output-a-specific-time-range"></a>

#### 输出特定的时间范围

```shell
jq 'select(.time >= "2023-01-10T00:00:00Z" and .time <= "2023-01-10T12:00:00Z")' <FILE>
```

<a id="parsing-gitlab-railsproduction_jsonlog"></a>

### 解析 `gitlab-rails/production_json.log`

<a id="print-the-top-three-controller-methods-by-request-volume-and-their-three-longest-durations"></a>

#### 按请求量打印前三个控制器方法及其三个最长时长

```shell
jq -s -r 'group_by(.controller+.action) | sort_by(-length) | limit(3; .[]) | sort_by(-.duration_s) | "CT: \(length)\tMETHOD: \(.[0].controller)#\(.[0].action)\tDURS: \(.[0].duration_s),  \(.[1].duration_s),  \(.[2].duration_s)"' production_json.log
```

**示例输出**

```plaintext
CT: 2721   METHOD: SessionsController#new  DURS: 844.06,  713.81,  704.66
CT: 2435   METHOD: MetricsController#index DURS: 299.29,  284.01,  158.57
CT: 1328   METHOD: Projects::NotesController#index DURS: 403.99,  386.29,  384.39
```

或者，使用 [`fast-stats`](https://gitlab.com/gitlab-com/support/toolbox/fast-stats)：

```shell
fast-stats --verbose --limit=3 production_json.log
```

<a id="parsing-gitlab-railsapi_jsonlog"></a>

### 解析 `gitlab-rails/api_json.log`

<a id="print-top-three-routes-with-request-count-and-their-three-longest-durations"></a>

#### 打印请求数排名前三的路由及其三个最长时长

```shell
jq -s -r 'group_by(.route) | sort_by(-length) | limit(3; .[]) | sort_by(-.duration_s) | "CT: \(length)\tROUTE: \(.[0].route)\tDURS: \(.[0].duration_s),  \(.[1].duration_s),  \(.[2].duration_s)"' api_json.log
```

**示例输出**

```plaintext
CT: 2472 ROUTE: /api/:version/internal/allowed   DURS: 56402.65,  38411.43,  19500.41
CT: 297  ROUTE: /api/:version/projects/:id/repository/tags       DURS: 731.39,  685.57,  480.86
CT: 190  ROUTE: /api/:version/projects/:id/repository/commits    DURS: 1079.02,  979.68,  958.21
```

或者，使用 [`fast-stats`](https://gitlab.com/gitlab-com/support/toolbox/fast-stats)：

```shell
fast-stats --verbose --limit=3 api_json.log
```

<a id="print-top-api-user-agents"></a>

#### 打印排名靠前的 API 用户代理

```shell
jq --raw-output '
  select(.remote_ip != "127.0.0.1") | [
    (.time | split(".")[0] | strptime("%Y-%m-%dT%H:%M:%S") | strftime("…%m-%dT%H…")),
    ."meta.caller_id", .username, .ua
  ] | @tsv' api_json.log | sort | uniq -c \
  | grep --invert-match --extended-regexp '^\s+\d{1,3}\b'
```

**示例输出**：

```plaintext
 1234 …01-12T01…  GET /api/:version/projects/:id/pipelines  some_user  # plus browser details; OK
54321 …01-12T01…  POST /api/:version/projects/:id/repository/files/:file_path/raw  some_bot
 5678 …01-12T01…  PATCH /api/:version/jobs/:id/trace gitlab-runner     # plus version details; OK
```

此示例显示某个自定义工具或脚本导致了意外的高[请求速率（>15 RPS）](../reference_architectures/_index.md#available-reference-architectures)。在这种情况下，用户代理可能是专门的[第三方客户端](../../api/rest/third_party_clients.md)，也可能是 `curl` 之类的通用工具。

按小时聚合有助于：

- 将机器人或用户活动的峰值与 [Prometheus](../monitoring/prometheus/_index.md) 等监控工具的数据关联起来。
- 评估[速率限制设置](../settings/user_and_ip_rate_limits.md)。

配合 `jq`，使用 [`fast-stats top`](https://gitlab.com/gitlab-com/support/toolbox/fast-stats/-/blob/main/README.md#top) 来审查这些用户和机器人的性能影响：

```shell
fast-stats top --display=percentage --sort-by=cpu-s api_json.log
```

请求频率高本身并不一定有问题，但占用任何资源的比例过高则不然。

<a id="parsing-gitlab-railsimporterlog"></a>

### 解析 `gitlab-rails/importer.log`

要排查[项目导入](../raketasks/project_import_export.md)或[迁移](../../user/import/_index.md)问题，请运行以下命令：

```shell
jq 'select(.project_path == "<namespace>/<project>").error_messages' importer.log
```

有关常见问题，请参阅[故障排除](../raketasks/import_export_rake_tasks_troubleshooting.md)。

<a id="parsing-gitlab-workhorsecurrent"></a>

### 解析 `gitlab-workhorse/current`

<a id="print-top-workhorse-user-agents"></a>

#### 打印排名靠前的 Workhorse 用户代理

```shell
jq --raw-output '
  select(.remote_ip != "127.0.0.1") | [
    (.time | split(".")[0] | strptime("%Y-%m-%dT%H:%M:%S") | strftime("…%m-%dT%H…")),
    .remote_ip, .uri, .user_agent
  ] | @tsv' current |
  sort | uniq -c
```

与 [API `ua` 示例](#print-top-api-user-agents)类似，此输出中出现许多意外的用户代理表明存在未优化的脚本。预期的用户代理包括 `gitlab-runner`、`GitLab-Shell` 和浏览器。

例如，可以通过增大 [`check_interval` 设置](https://gitlab.cn/docs/runner/configuration/advanced-configuration/#the-global-section)来降低 Runner 检查新作业带来的性能影响。

<a id="parsing-gitlab-railsgeolog"></a>

### 解析 `gitlab-rails/geo.log`

<a id="find-most-common-geo-sync-errors"></a>

#### 查找最常见的 Geo 同步错误

如果 [`gitlab:geo:status` Rake 任务](../geo/replication/troubleshooting/common.md#sync-status-rake-task)反复报告某些条目始终无法达到 100%，以下命令有助于聚焦最常见的错误。

```shell
jq --raw-output 'select(.severity == "ERROR") | [
  (.time | split(".")[0] | strptime("%Y-%m-%dT%H:%M:%S") | strftime("…%m-%dT%H:%M…")),
  .class, .id, .message, .error
  ] | @tsv' geo.log \
  | sort | uniq -c
```

有关特定错误消息的建议，请参阅我们的 [Geo 故障排除页面](../geo/replication/troubleshooting/_index.md)。

<a id="parsing-gitalycurrent"></a>

### 解析 `gitaly/current`

使用以下示例来[排查 Gitaly 问题](../gitaly/troubleshooting.md)。

<a id="find-all-gitaly-requests-sent-from-web-ui"></a>

#### 查找从 Web UI 发送的所有 Gitaly 请求

```shell
jq 'select(."grpc.meta.client_name" == "gitlab-web")' current
```

<a id="find-all-failed-gitaly-requests"></a>

#### 查找所有失败的 Gitaly 请求

```shell
jq 'select(."grpc.code" != null and ."grpc.code" != "OK")' current
```

<a id="find-all-requests-that-took-longer-than-30-seconds"></a>

#### 查找所有耗时超过 30 秒的请求

```shell
jq 'select(."grpc.time_ms" > 30000)' current
```

<a id="print-top-ten-projects-by-request-volume-and-their-three-longest-durations"></a>

#### 按请求量打印前十个项目及其三个最长时长

```shell
jq --raw-output --slurp '
  map(
    select(
      ."grpc.request.glProjectPath" != null
      and ."grpc.request.glProjectPath" != ""
      and ."grpc.time_ms" != null
    )
  )
  | group_by(."grpc.request.glProjectPath")
  | sort_by(-length)
  | limit(10; .[])
  | sort_by(-."grpc.time_ms")
  | [
      length,
      .[0]."grpc.time_ms",
      .[1]."grpc.time_ms",
      .[2]."grpc.time_ms",
      .[0]."grpc.request.glProjectPath"
    ]
  | @sh' current |
  awk 'BEGIN { printf "%7s %10s %10s %10s\t%s\n", "CT", "MAX DURS", "", "", "PROJECT" }
  { printf "%7u %7u ms, %7u ms, %7u ms\t%s\n", $1, $2, $3, $4, $5 }'
```

**示例输出**

```plaintext
   CT    MAX DURS                              PROJECT
  206    4898 ms,    1101 ms,    1032 ms      'groupD/project4'
  109    1420 ms,     962 ms,     875 ms      'groupEF/project56'
  663     106 ms,      96 ms,      94 ms      'groupABC/project123'
  ...
```

或者，使用 [`fast-stats`](https://gitlab.com/gitlab-com/support/toolbox/fast-stats)：

```shell
fast-stats top --sort-by=duration current
```

<a id="types-of-user-and-project-activity-overview"></a>

#### 用户和项目活动类型概览

```shell
jq --raw-output '[
    (.time | split(".")[0] | strptime("%Y-%m-%dT%H:%M:%S") | strftime("…%m-%dT%H…")),
    .username, ."grpc.method", ."grpc.request.glProjectPath"
  ] | @tsv' current | sort | uniq -c \
  | grep --invert-match --extended-regexp '^\s+\d{1,3}\b'
```

**示例输出**：

```plaintext
 5678 …01-12T01…     ReferenceTransactionHook  # Praefect operation; OK
54321 …01-12T01…  some_bot   GetBlobs    namespace/subgroup/project
 1234 …01-12T01…  some_user  FindCommit  namespace/subgroup/project
```

此示例显示某个自定义工具或脚本在 Gitaly 上导致了意外的高[请求速率（>15 RPS）](../reference_architectures/_index.md#available-reference-architectures)。按小时聚合有助于：

- 将机器人或用户活动的峰值与 [Prometheus](../monitoring/prometheus/_index.md) 等监控工具的数据关联起来。
- 评估[速率限制设置](../settings/user_and_ip_rate_limits.md)。

配合 `jq`，使用 [`fast-stats top`](https://gitlab.com/gitlab-com/support/toolbox/fast-stats/-/blob/main/README.md#top) 来审查这些用户和机器人的性能影响：

```shell
fast-stats top --display=percentage --sort-by=cpu-s current
```

请求频率高本身并不一定有问题，但占用任何资源的比例过高则不然。

<a id="find-all-projects-affected-by-a-fatal-git-problem"></a>

#### 查找所有受致命 Git 问题影响的项目

```shell
grep "fatal: " current |
  jq '."grpc.request.glProjectPath"' |
  sort | uniq
```

<a id="parsing-gitlab-shellgitlab-shelllog"></a>

### 解析 `gitlab-shell/gitlab-shell.log`

用于调查通过 SSH 进行的 Git 调用。

按项目和用户查找调用次数最多的前 20 个调用：

```shell
jq --raw-output --slurp '
  map(
    select(
      .username != null and
      .gl_project_path !=null
    )
  )
  | group_by(.username+.gl_project_path)
  | sort_by(-length)
  | limit(20; .[])
  | "count: \(length)\tuser: \(.[0].username)\tproject: \(.[0].gl_project_path)" ' \
  gitlab-shell.log
```

按项目、用户和命令查找调用次数最多的前 20 个调用：

```shell
jq --raw-output --slurp '
  map(
    select(
      .command  != null and
      .username != null and
      .gl_project_path !=null
    )
  )
  | group_by(.username+.gl_project_path+.command)
  | sort_by(-length)
  | limit(20; .[])
  | "count: \(length)\tcommand: \(.[0].command)\tuser: \(.[0].username)\tproject: \(.[0].gl_project_path)" ' \
  gitlab-shell.log
```
