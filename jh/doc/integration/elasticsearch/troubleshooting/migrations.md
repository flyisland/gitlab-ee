---
stage: AI-powered
group: Global Search
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
title: 排查 Elasticsearch 迁移问题
---

{{< details >}}

- Tier: 专业版，旗舰版
- Offering: 私有化部署

{{< /details >}}

在使用 Elasticsearch 迁移时，您可能会遇到以下问题。

如果 [`elasticsearch.log`](../../../administration/logs/_index.md#elasticsearchlog) 包含错误并且重试失败的迁移不起作用，请联系极狐GitLab 支持。更多信息，请参见[高级搜索迁移](../../advanced_search/elasticsearch.md#advanced-search-migrations)。

<a id="error-elasticsearch-transport-transport-errors-badrequest"></a>

## 错误：`Elasticsearch::Transport::Transport::Errors::BadRequest`

如果您遇到类似的异常，请确保您拥有正确的 Elasticsearch 版本并满足[系统要求](../../advanced_search/elasticsearch.md#system-requirements)。您也可以使用 `sudo gitlab-rake gitlab:check` 命令自动检查版本。

<a id="error-faradaytimeouterror-execution-expired"></a>

## 错误：`Faraday::TimeoutError (执行超时)`

当您使用代理时，请设置一个名为 [`no_proxy`](https://gitlab.cn/docs/omnibus/settings/environment-variables/) 的自定义 `gitlab_rails['env']` 环境变量，其值为您的 Elasticsearch 主机的 IP 地址。

<a id="single-node-elasticsearch-cluster-status-never-goes-from-yellow-to-green"></a>

## 单节点 Elasticsearch 集群状态永远不会从黄色变为绿色

对于单节点 Elasticsearch 集群，功能集群健康状态为黄色（永远不会变为绿色）。原因是主分片已分配，但副本无法分配，因为没有其他节点可供 Elasticsearch 分配副本。如果您使用的是 [Amazon OpenSearch](https://docs.aws.amazon.com/opensearch-service/latest/developerguide/aes-handling-errors.html#aes-handling-errors-yellow-cluster-status) 服务，这也适用。

> [!warning]
> 不建议将副本数设置为 `0`（极狐GitLab Elasticsearch 集成菜单中不允许这样做）。如果您计划添加更多 Elasticsearch 节点（总共超过 1 个 Elasticsearch），则需要将副本数设置为大于 `0` 的整数值。否则会导致缺乏冗余（丢失一个节点会损坏索引）。

如果您希望单节点 Elasticsearch 集群状态为绿色，请了解风险并运行以下查询将副本数设置为 `0`。集群将不再尝试创建任何分片副本。

```shell
curl --request PUT localhost:9200/gitlab-production/_settings --header 'Content-Type: application/json' \
     --data '{
       "index" : {
         "number_of_replicas" : 0
       }
     }'
```

<a id="error-health-check-timeout-no-elasticsearch-node-available"></a>

## 错误：`健康检查超时：没有可用的 Elasticsearch 节点`

如果您在索引过程中在 Sidekiq 中遇到 `health check timeout: no Elasticsearch node available` 错误：

```plaintext
Gitlab::Elastic::Indexer::Error: time="2020-01-23T09:13:00Z" level=fatal msg="健康检查超时：没有可用的 Elasticsearch 节点"
```

您可能没有在 Elasticsearch 集成菜单的 **"URL"** 字段中使用 `http://` 或 `https://` 作为值的一部分。请确认该字段中的 URL 格式，因为 [Elasticsearch 的 Go 客户端](https://github.com/olivere/elastic) 要求 URL 前缀[被接受为有效](https://github.com/olivere/elastic/commit/a80af35aa41856dc2c986204e2b64eab81ccac3a)。纠正 URL 格式后，[删除索引](../../advanced_search/elasticsearch.md#gitlab-advanced-search-rake-tasks)并[重新索引实例内容](../../advanced_search/elasticsearch.md#enable-advanced-search)。

<a id="elasticsearch-does-not-work-with-some-third-party-plugins"></a>

## Elasticsearch 与某些第三方插件不兼容

某些第三方插件可能会在您的集群中引入错误或与集成不兼容。如果您的 Elasticsearch 集群安装了第三方插件且集成无法正常工作，请尝试禁用这些插件。

<a id="elasticsearch-workers-overload-sidekiq"></a>

## Elasticsearch 工作进程使 Sidekiq 过载

在某些情况下，Elasticsearch 无法再连接到极狐GitLab，原因如下：

- Elasticsearch 密码仅在一侧更新（`Unauthorized [401] ... unable to authenticate user` 错误）。
- 防火墙或网络问题影响连接（`Failed to open TCP connection to <ip>:9200` 错误）。

这些错误记录在 [`gitlab-rails/elasticsearch.log`](../../../administration/logs/_index.md#elasticsearchlog) 中。要检索错误，请使用 [`jq`](../../../administration/logs/log_parsing.md)：

```shell
$ jq --raw-output 'select(.severity == "ERROR") | [.error_class, .error_message] | @tsv' \
    gitlab-rails/elasticsearch.log |
  sort | uniq -c
```

`Elastic` 工作进程和 [Sidekiq 作业](../../../administration/admin_area.md#background-jobs) 也可能出现得更频繁，因为如果之前的作业失败，Elasticsearch 会频繁尝试重新索引。您可以使用 [`fast-stats`](https://gitlab.com/gitlab-com/support/toolbox/fast-stats#usage) 或 `jq` 在 [Sidekiq 日志](../../../administration/logs/_index.md#sidekiq-logs) 中统计工作进程：

```shell
$ fast-stats --print-fields=count,score sidekiq/current
WORKER                            COUNT   SCORE
ElasticIndexBulkCronWorker          234  123456
ElasticIndexInitialBulkCronWorker   345   12345
Some::OtherWorker                    12     123
...

$ jq '.class' sidekiq/current | sort | uniq -c | sort -nr
 234 "ElasticIndexInitialBulkCronWorker"
 345 "ElasticIndexBulkCronWorker"
  12 "Some::OtherWorker"
...
```

在这种情况下，在过载的极狐GitLab 节点上运行 `free -m` 也会显示异常高的 `buff/cache` 使用率。

<a id="error-couldnt-load-task-status"></a>

## 错误：`无法加载任务状态`

重新索引时，您可能会遇到 `无法加载任务状态` 错误。Elasticsearch 主机上也可能出现 `sliceId must be greater than 0 but was [-1]` 错误。作为一种变通方法，请考虑[从头重新索引](indexing.md#last-resort-to-recreate-an-index)或升级到极狐GitLab 16.3。

<a id="error-migration-has-failed-with-nomethoderrorundefined-method"></a>

## 错误：`迁移失败，出现 NoMethodError:undefined method`

在极狐GitLab 15.11 中，`BackfillProjectPermissionsInBlobs` 迁移可能会失败，并在 `elasticsearch.log` 中记录以下错误消息：

```shell
migration has failed with NoMethodError:undefined method `<<' for nil:NilClass, no retries left
```

如果 `BackfillProjectPermissionsInBlobs` 是唯一失败的迁移，您可以升级到极狐GitLab 16.0 的最新补丁版本，该版本包含[修复](https://jihulab.com/gitlab-cn/gitlab/-/merge_requests/118494)。否则，您可以忽略该错误，因为它不影响高级搜索的功能。

<a id="elasticindexinitialbulkcronworker-and-elasticindexbulkcronworker-jobs-stuck-in-deduplication"></a>

## `ElasticIndexInitialBulkCronWorker` 和 `ElasticIndexBulkCronWorker` 作业卡在去重中

在极狐GitLab 16.5 及更早版本中，`ElasticIndexInitialBulkCronWorker` 和 `ElasticIndexBulkCronWorker` 作业可能会卡在去重中。此问题可能会阻止高级搜索即使在创建新索引后也能正确索引文档。在极狐GitLab 16.6 中，为执行索引的批量 cron 工作进程[移除了](https://jihulab.com/gitlab-cn/gitlab/-/merge_requests/135817) `idempotent!`。

Sidekiq 日志可能包含以下条目：

```plaintext
{"severity":"INFO","time":"2023-10-31T10:33:06.998Z","retry":0,"queue":"default","version":0,"queue_namespace":"cronjob","args":[],"class":"ElasticIndexInitialBulkCronWorker",
...
"idempotency_key":"resque:gitlab:duplicate:default:<value>","duplicate-of":"91e8673347d4dc84fbad5319","job_size_bytes":2,"pid":12047,"job_status":"deduplicated","message":"ElasticIndexInitialBulkCronWorker JID-5e1af9180d6e8f991fc773c6: 去重：直到执行","deduplication.type":"直到执行"}
```

要解决此问题：

1. 在 [Rails 控制台会话](../../../administration/operations/rails_console.md#starting-a-rails-console-session) 中，运行以下命令：

   ```shell
   idempotency_key = "<idempotency_key_from_log_entry>"
   duplicate_key = "resque:gitlab:#{idempotency_key}:cookie:v2"
   Gitlab::Redis::Queues.with { |c| c.del(duplicate_key) }
   ```

1. 将 `<idempotency_key_from_log_entry>` 替换为日志中的实际条目。

