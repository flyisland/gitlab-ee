---
stage: Analytics
group: Global Search
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
title: 故障排除 Elasticsearch 迁移
---

{{< details >}}

- Tier: 专业版，旗舰版
- Offering: 私有化部署

{{< /details >}}

在使用 Elasticsearch 迁移时，您可能会遇到以下问题。

如果 [`elasticsearch.log`](../../../administration/logs/_index.md#elasticsearchlog)中包含错误，并且重试失败的迁移不起作用，请联系极狐GitLab 支持。更多信息，请参阅[高级搜索迁移](../../advanced_search/elasticsearch.md#advanced-search-migrations)。

<a id="error-elasticsearchtransporttransporterrorsbadrequest"></a>

## 错误：`Elasticsearch::Transport::Transport::Errors::BadRequest`

如果您遇到类似的异常，请确保您使用了正确的 Elasticsearch 版本，并且满足[系统要求](../../advanced_search/elasticsearch.md#system-requirements)。您也可以使用 `sudo gitlab-rake gitlab:check` 命令自动检查版本。

<a id="error-faradaytimeouterror-execution-expired"></a>

## 错误：`Faraday::TimeoutError (execution expired)`

当您使用代理时，请设置一个名为 [`no_proxy`](https://gitlab.cn/docs/omnibus/settings/environment-variables/)的自定义 `gitlab_rails['env']` 环境变量，
其值为您的 Elasticsearch 主机的 IP 地址。

<a id="single-node-elasticsearch-cluster-status-never-goes-from-yellow-to-green"></a>

## 单节点 Elasticsearch 集群状态始终无法从黄色变为绿色

对于单节点 Elasticsearch 集群，功能性集群健康状态为黄色（永远不会是绿色）。原因是主分片已分配，但副本无法分配，因为不存在 Elasticsearch 可以为其分配副本的其他节点。如果您使用 [Amazon OpenSearch](https://docs.aws.amazon.com/opensearch-service/latest/developerguide/aes-handling-errors.html#aes-handling-errors-yellow-cluster-status) 服务，也同样如此。

> [!warning]
> 不建议将副本数设置为 `0`（在极狐GitLab Elasticsearch 集成菜单中不允许这样做）。如果您计划添加更多 Elasticsearch 节点（使 Elasticsearch 节点总数超过 1 个），则需要将副本数设置为大于 `0`的整数值。否则会导致缺乏冗余（丢失一个节点就会损坏索引）。

如果您希望单节点 Elasticsearch 集群的状态为绿色，请了解相关风险，并运行以下查询将副本数设置为 `0`。此后集群将不再尝试创建任何分片副本。

```shell
curl --request PUT localhost:9200/gitlab-production/_settings --header 'Content-Type: application/json' \
     --data '{
       "index" : {
         "number_of_replicas" : 0
       }
     }'
```

<a id="error-health-check-timeout-no-elasticsearch-node-available"></a>

## 错误：`health check timeout: no Elasticsearch node available`

如果您在索引过程中于 Sidekiq 中遇到 `health check timeout: no Elasticsearch node available` 错误：

```plaintext
Gitlab::Elastic::Indexer::Error: time="2020-01-23T09:13:00Z" level=fatal msg="health check timeout: no Elasticsearch node available"
```

您可能没有在 Elasticsearch 集成菜单的 **"URL"** 字段值中使用 `http://` 或 `https://`。请确认该字段中的 URL 格式，因为 [Elasticsearch 的 Go 客户端](https://github.com/olivere/elastic)要求 URL 带有该前缀才会被[视为有效](https://github.com/olivere/elastic/commit/a80af35aa41856dc2c986204e2b64eab81ccac3a)。在您修正 URL 格式后，请[删除索引](../../advanced_search/elasticsearch.md#gitlab-advanced-search-rake-tasks)并[重新索引实例内容](../../advanced_search/elasticsearch.md#enable-advanced-search)。

<a id="elasticsearch-does-not-work-with-some-third-party-plugins"></a>

## Elasticsearch 无法与某些第三方插件配合使用

某些第三方插件可能会在您的集群中引入缺陷，或与该集成不兼容。

如果您的 Elasticsearch 集群安装了第三方插件且集成无法正常工作，请尝试禁用这些插件。

<a id="elasticsearch-workers-overload-sidekiq"></a>

## Elasticsearch 工作进程使 Sidekiq 过载

在某些情况下，Elasticsearch 无法再连接到极狐GitLab，原因包括：

- Elasticsearch 密码仅在一侧更新（`Unauthorized [401] ... unable to authenticate user` 错误）。
- 防火墙或网络问题影响连接（`Failed to open TCP connection to <ip>:9200` 错误）。

这些错误会记录在 [`gitlab-rails/elasticsearch.log`](../../../administration/logs/_index.md#elasticsearchlog)中。要获取这些错误，请使用 [`jq`](../../../administration/logs/log_parsing.md)：

```shell
$ jq --raw-output 'select(.severity == "ERROR") | [.error_class, .error_message] | @tsv' \
    gitlab-rails/elasticsearch.log |
  sort | uniq -c
```

`Elastic` 工作进程和 [Sidekiq 作业](../../../administration/admin_area.md#background-jobs)也可能出现得更加频繁，因为如果上一个作业失败，Elasticsearch 会频繁尝试重新索引。您可以使用 [`fast-stats`](https://gitlab.com/gitlab-com/support/toolbox/fast-stats#usage) 或 `jq` 来统计 [Sidekiq 日志](../../../administration/logs/_index.md#sidekiq-logs)中的工作进程：

```shell
$ fast-stats --print-fields=count,score sidekiq/current
WORKER                            COUNT   SCORE
Search::Elastic::IndexBulkCronWorker         234  123456
Search::Elastic::IndexInitialBulkCronWorker  345   12345
Some::OtherWorker                             12     123
...

$ jq '.class' sidekiq/current | sort | uniq -c | sort -nr
 234 "Search::Elastic::IndexInitialBulkCronWorker"
 345 "Search::Elastic::IndexBulkCronWorker"
  12 "Some::OtherWorker"
...
```

在这种情况下，在过载的极狐GitLab 节点上运行 `free -m` 也会显示异常高的 `buff/cache` 使用量。
