---
stage: Analytics
group: Global Search
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
title: 故障排除 Elasticsearch 索引和搜索
---

{{< details >}}

- Tier: 专业版，旗舰版
- Offering: 私有化部署

{{< /details >}}

在使用 Elasticsearch 索引或搜索时，您可能会遇到以下问题。

<a id="create-an-empty-index"></a>

## 创建空索引

对于索引问题，请先尝试创建一个空索引。
检查 Elasticsearch 实例，确认是否存在 `gitlab-production` 索引。
如果存在，请在 Elasticsearch 实例上手动删除该索引，然后尝试通过
[`recreate_index`](../../advanced_search/elasticsearch.md#gitlab-advanced-search-rake-tasks)
Rake 任务重新创建它。

如果仍然遇到问题，请尝试在 Elasticsearch 实例上手动创建索引。如果您：

- 无法创建索引，请联系您的 Elasticsearch 管理员。
- 可以创建索引，请联系极狐GitLab 支持。

<a id="check-the-status-of-indexed-projects"></a>

## 检查已索引项目的状态

您可以检查项目索引过程中出现的错误。错误可能出现在：

- 极狐GitLab 实例上：如果您无法自行修复，请联系极狐GitLab 支持寻求指导。
- Elasticsearch 实例上：[如果错误未列出](_index.md)，请联系您的 Elasticsearch 管理员。

如果索引未返回错误，请使用以下 Rake 任务检查已索引项目的状态：

- [`sudo gitlab-rake gitlab:elastic:index_projects_status`](../../advanced_search/elasticsearch.md#gitlab-advanced-search-rake-tasks)
  查看整体状态
- [`sudo gitlab-rake gitlab:elastic:projects_not_indexed`](../../advanced_search/elasticsearch.md#gitlab-advanced-search-rake-tasks)
  查看未索引的特定项目

如果索引：

- 已完成，请联系极狐GitLab 支持。
- 未完成，请尝试通过运行
  `sudo gitlab-rake gitlab:elastic:index_projects ID_FROM=<project ID> ID_TO=<project ID>` 重新索引该项目。

如果重新索引该项目时出现错误，且错误出现在：

- 极狐GitLab 实例上：请联系极狐GitLab 支持。
- Elasticsearch 实例上或完全没有错误：请联系您的 Elasticsearch 管理员检查该实例。

<a id="no-search-results-after-updating-gitlab"></a>

## 更新极狐GitLab 后没有搜索结果

我们会持续更新索引策略，并致力于支持更新版本的 Elasticsearch。当索引方式发生变化时，您可能需要在更新极狐GitLab 后[重新索引](../../advanced_search/elasticsearch.md#zero-downtime-reindexing)。

<a id="no-search-results-after-indexing-all-repositories"></a>

## 索引所有代码仓库后没有搜索结果

> [!note]
> 请勿将这些说明用于仅索引[部分命名空间](../../advanced_search/elasticsearch.md#limit-the-amount-of-namespace-and-project-data-to-index)的场景。

请确保您已[索引所有数据库数据](../../advanced_search/elasticsearch.md#enable-advanced-search)。

如果 UI 搜索中没有任何结果（命中），请通过 Rails 控制台（`sudo gitlab-rails console`）检查是否看到相同的结果：

```ruby
u = User.find_by_username('your-username')
s = SearchService.new(u, {:search => 'search_term', :scope => 'blobs'})
pp s.search_objects.to_a
```

此外，请通过 [Elasticsearch 搜索 API](https://www.elastic.co/docs/api/doc/elasticsearch/operation/operation-search) 检查数据是否出现在 Elasticsearch 端：

```shell
curl --request GET <elasticsearch_server_ip>:9200/gitlab-production/_search?q=<search_term>
```

也可以进行更[复杂的 Elasticsearch API 调用](https://www.elastic.co/docs/explore-analyze/query-filter/languages/querydsl)。

如果结果：

- 一致，请检查您是否使用了[支持的语法](../../../user/search/advanced_search.md#syntax)。高级搜索不支持[精确子字符串匹配](https://gitlab.com/gitlab-org/gitlab/-/issues/325234)。
- 不一致，这表明从项目生成的文档存在问题。最好[重新索引该项目](../../advanced_search/elasticsearch.md#indexing-a-range-of-projects-or-a-specific-project)。

有关搜索特定类型数据的更多信息，请参阅 [Elasticsearch 索引范围](../../advanced_search/elasticsearch.md#advanced-search-index-scopes)。

<a id="no-search-results-after-enabling-advanced-search-with-low-concurrency"></a>

## 在低并发下启用高级搜索后没有搜索结果

启用高级搜索后，您可能会发现文档未被索引，代码也无法搜索。您可能会在 Sidekiq 日志中看到类似以下内容的消息：

```json
"job_status":"concurrency_limit","message":"Search::Elastic::CommitIndexerWorker JID-352e0b9ee88af9f455c69b81: concurrency_limit: paused"
```

要解决此问题：

1. 使用 Rake 任务 `gitlab-rake gitlab:elastic:info` 检查 **索引队列**的状态。
1. 如果 **并发限制代码队列** 不为零，请检查 **代码索引并发**的值。
   值过低可能会阻止索引继续进行。
   请考虑增大该值，并使用 Rake 任务检查进度。

<a id="no-search-results-after-switching-elasticsearch-servers"></a>

## 切换 Elasticsearch 服务器后没有搜索结果

要重新索引数据库、代码仓库和 Wiki，请[索引该实例](../../advanced_search/elasticsearch.md#index-the-instance)。

<a id="indexing-fails-with-error-elastic-error-429-too-many-requests"></a>

## 索引失败并出现 `error: elastic: Error 429 (Too Many Requests)`

如果 `Search::Elastic::CommitIndexerWorker` Sidekiq 工作进程在索引期间因该错误而失败，通常意味着 Elasticsearch 无法跟上索引请求的并发量。要解决此问题，请更改以下设置：

- 要降低索引吞吐量，您可以减小 `Bulk request concurrency`（请参阅[高级搜索设置](../../advanced_search/elasticsearch.md#advanced-search-configuration)）。该值默认为 `10`，但您可以将其降低到 1，以减少并发索引操作的数量。
- 如果更改 `Bulk request concurrency` 没有帮助，您可以使用[路由规则](../../../administration/sidekiq/processing_specific_job_classes.md#routing-rules)选项来[将索引作业限制到特定的 Sidekiq 节点](../../advanced_search/elasticsearch.md#index-large-instances-with-dedicated-sidekiq-nodes-or-processes)，这应能减少索引请求的数量。

<a id="error-elasticsearchtransporttransporterrorsrequestentitytoolarge"></a>

## 错误：`Elasticsearch::Transport::Transport::Errors::RequestEntityTooLarge`

```plaintext
[413] {"Message":"Request size exceeded 10485760 bytes"}
```

当您的 Elasticsearch 集群配置为拒绝超过特定大小（此处为 10 MiB）的请求时，会出现此异常。这对应于 `elasticsearch.yml`中的 `http.max_content_length` 设置。请将其增大到更大的值，然后重启 Elasticsearch 集群。

AWS 根据底层实例的大小对 HTTP 请求负载的最大大小设有[网络限制](https://docs.aws.amazon.com/opensearch-service/latest/developerguide/limits.html#network-limits)。请将最大批量请求大小设置为低于 10 MiB 的值。

<a id="indexing-is-very-slow-or-fails-with-rejected-execution-of-coordinating-operation"></a>

## 索引非常慢或失败并出现 `rejected execution of coordinating operation`

批量请求被 Elasticsearch 节点拒绝，很可能是由于负载过高和可用内存不足。请确保您的 Elasticsearch 集群满足[系统要求](../../advanced_search/elasticsearch.md#system-requirements)并有足够的资源
来执行批量操作。另请参阅错误[“429 (Too Many Requests)”](#indexing-fails-with-error-elastic-error-429-too-many-requests)。

<a id="indexing-fails-with-strict_dynamic_mapping_exception"></a>

## 索引失败并出现 `strict_dynamic_mapping_exception`

如果在进行主要升级之前未完成所有[高级搜索迁移](../../advanced_search/elasticsearch.md#all-migrations-must-be-finished-before-doing-a-major-upgrade)，索引可能会失败。此错误可能伴随大量 Sidekiq 积压。要修复索引失败，您必须重新索引数据库、代码仓库和 Wiki。

1. 暂停索引，以便 Sidekiq 能够跟上进度：

   ```shell
   sudo gitlab-rake gitlab:elastic:pause_indexing
   ```

1. [从头重新创建索引](#last-resort-to-recreate-an-index)。
1. 恢复索引：

   ```shell
   sudo gitlab-rake gitlab:elastic:resume_indexing
   ```

<a id="indexing-keeps-pausing-with-elasticsearch_pause_indexing-setting-is-enabled"></a>

## 索引不断暂停并出现 `elasticsearch_pause_indexing setting is enabled`

您可能会注意到，运行搜索时无法检测到新数据。

当新数据未被正确索引时，会出现此错误。

要解决此错误，请[重新索引您的数据](../../advanced_search/elasticsearch.md#zero-downtime-reindexing)。

但是，在重新索引时，您可能会遇到索引过程不断暂停的错误，并且 Elasticsearch 日志显示以下内容：

```shell
"message":"elasticsearch_pause_indexing setting is enabled. Job was added to the waiting queue"
```

如果重新索引无法解决此问题，并且您没有手动暂停索引过程，则此错误可能是因为两个极狐GitLab 实例共享一个 Elasticsearch 集群。

要解决此错误，请断开其中一个极狐GitLab 实例与 Elasticsearch 集群的连接。

有关更多信息，请参阅[议题 3421](https://gitlab.com/gitlab-org/gitlab/-/issues/3421)。

<a id="search-fails-with-too_many_clauses-maxclausecount-is-set-to-1024"></a>

## 搜索失败并出现 `too_many_clauses: maxClauseCount is set to 1024`

当查询的子句数超过 `indices.query.bool.max_clause_count` 设置中定义的值时，会出现此错误：

- [在 Elasticsearch 7.17 及更早版本中](https://www.elastic.co/guide/en/elasticsearch/reference/7.17/search-settings.html)，默认值为 `1024`。
- [在 Elasticsearch 8.0 中](https://www.elastic.co/guide/en/elasticsearch/reference/8.0/search-settings.html)，默认值为 `4096`。
- [在 Elasticsearch 8.1 及更高版本中](https://www.elastic.co/guide/en/elasticsearch/reference/8.1/search-settings.html)，该设置已弃用，其值由系统动态确定。

要解决此问题，请增大该值或升级到 Elasticsearch 8.1 或更高版本。增大该值可能会导致性能下降。

<a id="search-results-contain-duplicates-across-multiple-pages"></a>

## 搜索结果在多个页面之间包含重复项

使用高级搜索时，跨多个页面的搜索结果可能包含重复项。出现重复项时，某些匹配结果不会被返回。

极狐GitLab 根据 Elasticsearch 返回的
唯一匹配结果数量对结果进行分页。
但是，由于 Elasticsearch 对结果排序的方式，
同一结果可能会出现在多个页面上。当您按相关性对结果排序时，更可能出现此问题。

作为变通方法，请考虑以下做法：

- 使用更具体的搜索查询来缩小结果范围。
- 在可能的情况下使用不同的排序选项。

有关更多信息，请参阅[议题 416286](https://gitlab.com/gitlab-org/gitlab/-/work_items/416286)。

<a id="error-disk-usage-exceeded-flood-stage-watermark-index-has-read-only-allow-delete-block"></a>

## 错误：`disk usage exceeded flood-stage watermark, index has read-only-allow-delete block`

当您的 Elasticsearch 集群中
至少有一个节点的磁盘空间严重不足时，会出现此错误。超过默认水位阈值 95% 的集群会强制执行只读块，从而阻止所有后续写入操作。此块可能导致新的索引操作失败，并导致搜索结果过时。

您可以使用以下 Rake 任务检查集群是否处于只读模式：

```shell
sudo gitlab-rake gitlab:elastic:info
```

请查找指示 `blocks.write` 或 `blocks.read_only_allow_delete` 为 `true`的输出。

要检查 Elasticsearch 集群的磁盘使用情况，请运行以下命令：

```shell
curl --request GET '<your_ES_cluster>:9200/_cat/allocation?v&pretty'
```

要解决此问题，请增大已满节点的磁盘容量。您可以使用以下 Rake 任务估算集群大小：

```shell
sudo gitlab-rake gitlab:elastic:estimate_cluster_size
```

<a id="last-resort-to-recreate-an-index"></a>

## 重新创建索引的最后手段

在某些情况下，数据可能从未被索引，也不在队列中，或者索引处于某种状态，导致迁移无法继续进行。最好始终通过[查看日志](access.md#view-logs)来排查问题的根本原因。

作为最后手段，您可以从头重新创建索引。对于小型极狐GitLab 安装，重新创建索引可能是快速解决某些问题的方法。但对于大型极狐GitLab 安装，此方法可能需要很长时间。在索引完成之前，您的索引不会显示正确的搜索结果。在索引运行期间，您可能
希望清除 **使用高级搜索** 复选框。

如果您确定已阅读上述注意事项并希望继续，那么您应运行以下 Rake 任务来从头重新创建整个索引。

{{< tabs >}}

{{< tab title="Linux 软件包（Omnibus）" >}}

```shell
# WARNING: DO NOT RUN THIS UNTIL YOU READ THE DESCRIPTION ABOVE
sudo gitlab-rake gitlab:elastic:index
```

{{< /tab >}}

{{< tab title="自行编译（源代码）" >}}

```shell
# WARNING: DO NOT RUN THIS UNTIL YOU READ THE DESCRIPTION ABOVE
cd /home/git/gitlab
sudo -u git -H bundle exec rake gitlab:elastic:index
```

{{< /tab >}}

{{< /tabs >}}

<a id="dead-queue"></a>

## 死信队列

条目在重试一次后仍然失败时，会进入死信队列。死信队列中的条目需要手动调查，不会自动重试。

<a id="check-the-status"></a>

### 检查状态

要检查死信队列的大小和详细信息：

1. 启动 Rails 控制台：

   ```shell
   sudo gitlab-rails console
   ```

1. 检查失败条目的数量：

   ```ruby
   Search::Elastic::DeadQueue.queue_size
   ```

1. 检查失败条目的详细信息：

   ```ruby
   Search::Elastic::DeadQueue.queued_items
   ```

   此命令返回一个哈希，其中每个键是分片编号，
   每个值是 `[spec, score]` 对的数组。
   spec 包含有关失败条目的信息。

<a id="retry-items"></a>

### 重试条目

将您想要重试的条目加入队列。如果这些条目再次失败，它们会被移回死信队列。

要重试死信队列中的条目：

1. 启动 Rails 控制台：

   ```shell
   sudo gitlab-rails console
   ```

1. 将条目从死信队列移动到重试队列：

   ```ruby
   specs = Search::Elastic::DeadQueue.queued_items.flat_map { |_, items| items.map { |spec, _| spec } }

   Search::Elastic::DeadQueue.clear_tracking!
   Search::Elastic::RetryQueue.track!(*specs)
   ```

1. 可选。[检查索引状态](../../advanced_search/elasticsearch.md#check-indexing-status)。

要丢弃死信队列中的条目而不重试它们，请运行以下命令：

```ruby
Search::Elastic::DeadQueue.clear_tracking!
```

<a id="contact-gitlab-support"></a>

### 联系极狐GitLab 支持

如果您需要有关死信队列条目的帮助，请向极狐GitLab 支持提供以下信息：

- `Search::Elastic::DeadQueue.queue_size`的输出
- 您的 Elasticsearch 和极狐GitLab 版本
- 索引失败开始的时间
- 相关的应用日志或错误消息

<a id="improve-elasticsearch-performance"></a>

## 提升 Elasticsearch 性能

要提升性能，请确保：

- Elasticsearch 服务器未与极狐GitLab 运行在同一节点上。
- Elasticsearch 服务器有足够的 RAM 和 CPU 核心。
- 使用了分片。

进一步详细说明，如果 Elasticsearch 与极狐GitLab 运行在同一台服务器上，很可能会发生资源争用。理想情况下，需要充足资源的 Elasticsearch 应运行在自己的服务器上（也许与 Logstash 和 Kibana 部署在一起）。

对于 Elasticsearch 而言，RAM 是关键资源。Elasticsearch 官方建议：

- 非生产实例至少 8 GB RAM。
- 生产实例至少 16 GB RAM。
- 理想情况下为 64 GB RAM。

对于 CPU，Elasticsearch 建议至少 2 个 CPU 核心，但 Elasticsearch 表示常见
配置最多使用 8 个核心。有关服务器规格的更多详细信息，请查看
[Elasticsearch 硬件指南](https://www.elastic.co/guide/en/elasticsearch/guide/current/hardware.html)。

除上述内容外，分片也很重要。分片是 Elasticsearch 的核心组成部分。它允许对索引进行水平扩展，这在处理大量数据时很有帮助。

按照极狐GitLab 的索引方式，会有大量文档被索引。通过使用分片，您可以加快 Elasticsearch 定位数据的速度，因为每个分片都是一个 Lucene 索引。

如果您不使用分片，在生产环境中开始使用
Elasticsearch 时很可能会遇到问题。

只有一个分片的索引没有扩展系数，在频繁调用时很可能会遇到问题。请参阅
[Elasticsearch 容量规划文档](https://www.elastic.co/guide/en/elasticsearch/guide/2.x/capacity-planning.html)。

确定是否使用分片的最简单方法是检查
[Elasticsearch 健康状态 API](https://www.elastic.co/docs/api/doc/elasticsearch/operation/operation-cluster-health)的输出：

- 红色表示集群已宕机。
- 黄色表示集群已启动，但没有分片/副本。
- 绿色表示集群健康（已启动、有分片、有副本）。

对于生产用途，它应始终为绿色。

除这些步骤外，您还可以检查一些更复杂的内容，例如合并和缓存。这些内容可能很复杂，需要一些时间学习，因此如果您需要进一步深入研究这些内容，最好升级或与 Elasticsearch 专家结对处理。

请联系极狐GitLab 支持，但这很可能是熟练的
Elasticsearch 管理员更有经验处理的事项。

<a id="slow-initial-indexing"></a>

## 初始索引缓慢

极狐GitLab 实例的数据越多，索引所需的时间就越长。您可以使用 Rake 任务 `sudo gitlab-rake gitlab:elastic:estimate_cluster_size` 估算集群大小。

<a id="for-code-documents"></a>

### 对于代码文档

请确保您有足够的 Sidekiq 节点和工作进程来高效地索引代码、提交和 Wiki。如果初始索引缓慢，请考虑使用[专用 Sidekiq 节点或工作进程](../../advanced_search/elasticsearch.md#index-large-instances-with-dedicated-sidekiq-nodes-or-processes)。

<a id="for-non-code-documents"></a>

### 对于非代码文档

如果初始索引缓慢，但 Sidekiq 有足够的节点和工作进程，您可以在极狐GitLab 中调整高级搜索工作进程设置。
对于 **重新排队索引 workers**，默认值为 `false`。
对于 **非代码索引的分片数量**，默认值为 `2`。
这些设置将索引限制为每分钟 2000 个文档。

先决条件：

- 管理员访问权限。

要调整工作进程设置：

1. 在右上角，选择**管理员**。
1. 在左侧边栏中，选择**设置** > **搜索**。
1. 展开**高级搜索**。
1. 选中 **重新排队索引 workers** 复选框。
1. 在 **非代码索引的分片数量** 文本框中，输入大于 `2`的值。
1. 选择**保存更改**。
