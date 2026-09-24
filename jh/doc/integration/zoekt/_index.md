---
stage: AI-powered
group: Global Search
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
title: Zoekt
---

{{< details >}}

- Tier: 专业版，旗舰版
- Offering: JihuLab.com，私有化部署
- Status: 有限可用性

{{< /details >}}

{{< history >}}

- 在极狐GitLab 15.9 中作为[测试版](../../policy/development_stages_support.md#beta)引入，带有[功能标志](../../administration/feature_flags/_index.md) `index_code_with_zoekt` 和 `search_code_with_zoekt`，默认禁用。
- 在极狐GitLab 16.6 中[在 JihuLab.com 和私有化部署启用](https://gitlab.com/gitlab-org/gitlab/-/issues/388519)。
- 全局代码搜索在极狐GitLab 16.11 中引入，带有[功能标志](../../administration/feature_flags/_index.md) `zoekt_cross_namespace_search`，默认禁用。
- 功能标志 `index_code_with_zoekt` 和 `search_code_with_zoekt` 在极狐GitLab 17.1 中移除。
- 功能标志 `zoekt_rollout_worker` 在极狐GitLab 17.9 中添加，默认禁用。
- 在极狐GitLab 18.6 中从测试版更改为有限可用性。
- 功能标志 `zoekt_cross_namespace_search` 和 `zoekt_rollout_worker` 在极狐GitLab 18.7 中移除。

{{< /history >}}

> [!warning]
> 该功能处于[有限可用性](../../policy/development_stages_support.md#limited-availability)状态。
> 更多信息，请参见[史诗 9404](https://gitlab.com/groups/gitlab-org/-/epics/9404)。

Zoekt 是一个专为搜索代码设计的开源搜索引擎。

通过此集成，你可以在极狐GitLab 中使用[精确代码搜索](../../user/search/exact_code_search.md)而非[高级搜索](../../user/search/advanced_search.md)来搜索代码。
你可以在群组或代码仓中使用精确匹配和正则表达式模式搜索代码。

> [!note]
> Zoekt 仅处理代码搜索，不会替代
> [Elasticsearch 或 OpenSearch](../advanced_search/elasticsearch.md)。
> 对于其他所有搜索范围，包括评论、提交、史诗、
> 议题、合并请求、里程碑、项目、用户和 wiki，
> 仍需要 Elasticsearch 或 OpenSearch。

<a id="install-zoekt"></a>

## 安装 Zoekt

先决条件：

- 管理员访问权限。

要在极狐GitLab 中[启用精确代码搜索](#enable-exact-code-search)，你必须至少有一个 Zoekt 节点连接到实例。以下安装方法支持 Zoekt：

- [Zoekt chart](https://gitlab.cn/docs/charts/charts/gitlab/gitlab-zoekt/)
  （作为独立 chart 或极狐GitLab Helm chart 的子 chart）
- [GitLab Operator](https://gitlab.cn/docs/operator/)（使用 `gitlab-zoekt.install=true`）

以下安装方法可用于测试，不用于生产环境：

- [Docker Compose](https://jihulab.com/gitlab-cn/gitlab-zoekt-indexer/-/tree/main/example/docker-compose)
- [Ansible playbook](https://jihulab.com/gitlab-cn/search-team/code-search/ansible-gitlab-zoekt)

<a id="enable-exact-code-search"></a>

## 启用精确代码搜索

<a id="from-the-gitlab-ui"></a>

### 从极狐GitLab UI

先决条件：

- 管理员访问权限。
- [已安装 Zoekt](#install-zoekt)。

要从极狐GitLab UI 启用[精确代码搜索](../../user/search/exact_code_search.md)：

1. 在右上角，选择 **管理员**。
1. 在左侧边栏，选择 **设置** > **搜索**。
1. 展开 **精确代码搜索**。
1. 选中 **启用索引** 和 **启用搜索** 复选框。
1. 选择 **保存更改**。

<a id="with-rake-tasks"></a>

### 使用 Rake 任务

{{< history >}}

- 在极狐GitLab 18.10 中引入。

{{< /history >}}

先决条件：

- 管理员访问权限。
- [已安装 Zoekt](#install-zoekt)。

你可以使用 Rake 任务管理[精确代码搜索](../../user/search/exact_code_search.md)。

<a id="enable-indexing-and-search"></a>

#### 启用索引和搜索

要启用索引和搜索，运行这个 Rake 任务：

```shell
gitlab-rake gitlab:zoekt:index
```

该任务启用 `zoekt_indexing_enabled`、`zoekt_search_enabled` 和 `zoekt_auto_index_root_namespace`。
`RolloutWorker` 自动索引所有根命名空间，索引准备好后，搜索即可用。

<a id="disable-indexing-and-search"></a>

#### 禁用索引和搜索

要禁用索引和搜索，运行这个 Rake 任务：

```shell
gitlab-rake gitlab:zoekt:disable
```

该任务同时禁用 `zoekt_indexing_enabled` 和 `zoekt_search_enabled`。

<a id="pause-and-resume-indexing"></a>

#### 暂停和恢复索引

要暂停索引（例如在维护期间），运行这个 Rake 任务：

```shell
gitlab-rake gitlab:zoekt:pause_indexing
```

要恢复索引，运行这个 Rake 任务：

```shell
gitlab-rake gitlab:zoekt:resume_indexing
```

<a id="estimate-storage-requirements"></a>

#### 估算存储需求

要估算 Zoekt 节点所需的存储，运行这个 Rake 任务：

```shell
sudo gitlab-rake gitlab:zoekt:estimate_storage
```

更多信息，请参见[估算需求](#estimate-requirements)。

<a id="check-indexing-status"></a>

## 检查索引状态

{{< history >}}

- 在极狐GitLab 17.7 中引入当 Zoekt 节点存储超过临界水位时停止索引的功能，带有[功能标志](../../administration/feature_flags/_index.md) `zoekt_critical_watermark_stop_indexing`，默认禁用。
- 在极狐GitLab 18.0 中在 JihuLab.com 和私有化部署启用。
- 在极狐GitLab 18.1 中 GA。功能标志 `zoekt_critical_watermark_stop_indexing` 已移除。

{{< /history >}}

先决条件：

- 管理员访问权限。

索引性能取决于 Zoekt 索引节点上的 CPU 和内存限制。
要检查索引状态：

{{< tabs >}}

{{< tab title="极狐GitLab 17.10 及更高版本" >}}

运行这个 Rake 任务：

```shell
gitlab-rake gitlab:zoekt:info
```

要每 10 秒自动刷新数据，请运行以下 Rake 任务：

```shell
gitlab-rake "gitlab:zoekt:info[10]"
```

{{< /tab >}}

{{< tab title="极狐GitLab 17.9 及更低版本" >}}

在 [Rails 控制台](../../administration/operations/rails_console.md#starting-a-rails-console-session)中，运行这些命令：

```ruby
Search::Zoekt::Index.group(:state).count
Search::Zoekt::Repository.group(:state).count
Search::Zoekt::Task.group(:state).count
```

{{< /tab >}}

{{< /tabs >}}

<a id="sample-output"></a>

### 示例输出

`gitlab:zoekt:info` Rake 任务返回类似以下内容的输出：

```console
Exact Code Search
GitLab version:                                      19.0.0
Enable indexing:                                     yes
Enable searching:                                    yes
Pause indexing:                                      no
Index root namespaces automatically:                 yes
Cache search results for five minutes:               yes
Indexing CPU to tasks multiplier:                    1.0
Probability of random force reindexing (percentage): 0.25
Number of parallel processes per indexing task:      1
Number of namespaces per indexing rollout:           32
Offline nodes automatically deleted after:           20m
Indexing timeout per project:                        30m
Maximum number of files per project to be indexed:   500000
Maximum file size for indexing:                      1MB
Maximum trigrams per file:                           20000
Retry interval for failed namespaces:                1d
Number of replicas per namespace:                    1
Maximum projects for legacy search:                  1000

Nodes
# Number of Zoekt nodes and their status
Node count:                   2 (online: 2, offline: 0)
Last seen at:                 2026-04-16 22:58:09 UTC (less than a minute ago)
Max schema_version:           2601
Storage reserved / usable:    71.1 MiB / 124 GiB (0.06%)
Storage indexed / reserved:   42.7 MiB / 71.1 MiB (60.0%)
Storage used / total:         797 GiB / 921 GiB (86.54%)
Online node watermark levels: 2
  - low: 2

Indexing status
Group count:                      8
# Number of enabled namespaces and their status
EnabledNamespace count:           8 (without indices: 0, rollout blocked: 0, with search disabled: 0)
Replicas count:                   8
  - ready: 8
Indices count:                    8
  - ready: 8
Indices watermark levels:         8
  - healthy: 8
Repositories count:               10
  - ready: 10
Tasks count:                      10
  - done: 10
Tasks pending/processing by type: (none)
Storage buffer factor:            0.831× [dynamic (observed)]

Feature Flags (Non-Default Values)
- zoekt_offset_pagination:      disabled

Feature Flags (Default Values)
- zoekt_batch_update_index_storage_bytes:  disabled
- zoekt_cap_file_match_results:            disabled

Node Details
Node 1 - test-zoekt-hostname-1:
  Status:                       Online
  Last seen at:                 2026-04-16 22:58:09 UTC (less than a minute ago)
  Disk utilization:             86.54%
  Unclaimed storage:            62 GiB
  # Zoekt build version on the node. Must match GitLab version.
  Zoekt version:                2026.04.15-v1.4.0-1-g89a8871
  Schema version:               2601
Node 2 - test-zoekt-hostname-2:
  Status:                       Online
  Last seen at:                 2026-04-16 22:58:09 UTC (less than a minute ago)
  Disk utilization:             86.54%
  Unclaimed storage:            62 GiB
  Zoekt version:                2026.04.15-v1.4.0-1-g89a8871
  Schema version:               2601
```

<a id="run-a-health-check"></a>

## 运行健康检查

{{< history >}}

- 在极狐GitLab 18.4 中引入。

{{< /history >}}

先决条件：

- 管理员访问权限。

运行健康检查以了解你的 Zoekt 基础设施状态，包括：

- 在线和离线节点
- 索引和搜索设置
- 搜索 API 端点
- JSON Web Token 生成

要运行健康检查，执行以下任务：

```shell
gitlab-rake gitlab:zoekt:health
```

该任务提供：

- 总体状态：`HEALTHY`、`DEGRADED` 或 `UNHEALTHY`
- 针对检测到的问题的解决建议
- 用于自动化和监控集成的退出代码：`0=healthy`、`1=degraded` 或 `2=unhealthy`

<a id="run-checks-automatically"></a>

### 自动运行检查

要每 10 秒自动运行健康检查，执行以下任务：

```shell
gitlab-rake "gitlab:zoekt:health[10]"
```

输出包含彩色状态指示器，并显示：

- 在线和离线节点计数、存储使用警告以及连接问题
- 核心设置验证以及命名空间和仓库索引状态
- 总体状态，包括综合健康评估：`HEALTHY`、`DEGRADED` 或 `UNHEALTHY`
- 解决问题建议

<a id="force-reindex-projects"></a>

## 强制重新索引项目

{{< history >}}

- 在极狐GitLab 18.10 中引入。

{{< /history >}}

先决条件：

- 管理员访问权限。

要强制重新索引一系列项目，运行这个 Rake 任务：

```shell
gitlab-rake gitlab:zoekt:reindex_projects ID_FROM=10 ID_TO=20
```

`ID_FROM` 和 `ID_TO` 表示项目 ID 范围。

要仅强制重新索引一个项目，请为 `ID_FROM` 和 `ID_TO` 使用相同的值。
要强制重新索引所有项目，请勿使用这些环境变量。

<a id="pause-indexing"></a>

## 暂停索引

先决条件：

- 管理员访问权限。

要暂停[精确代码搜索](../../user/search/exact_code_search.md)的索引：

1. 在右上角，选择 **管理员**。
1. 在左侧边栏，选择 **设置** > **搜索**。
1. 展开 **精确代码搜索**。
1. 选中 **暂停索引** 复选框。
1. 选择 **保存更改**。

当你暂停精确代码搜索的索引时，仓库中的所有更改都会排队。
要恢复索引，请清除 **暂停精确代码搜索索引** 复选框。

<a id="index-root-namespaces-automatically"></a>

## 自动索引根命名空间

{{< history >}}

- 在极狐GitLab 17.1 中引入。

{{< /history >}}

先决条件：

- 管理员访问权限。

你可以自动索引现有的和新的根命名空间。
要自动索引所有根命名空间：

1. 在右上角，选择 **管理员**。
1. 在左侧边栏，选择 **设置** > **搜索**。
1. 展开 **精确代码搜索**。
1. 选中 **自动索引根命名空间** 复选框。
1. 选择 **保存更改**。

启用此设置后，极狐GitLab 会为以下所有项目创建索引任务：

- 所有群组和子群组
- 任何新的根命名空间

项目索引完成后，极狐GitLab 仅会在检测到仓库更改时进行增量索引。

禁用此设置后：

- 现有的根命名空间保持索引状态。
- 新的根命名空间不再被索引。

<a id="cache-search-results"></a>

## 缓存搜索结果

{{< history >}}

- 在极狐GitLab 18.0 中引入。

{{< /history >}}

先决条件：

- 管理员访问权限。

你可以缓存搜索结果以获得更好的性能。
该功能默认启用，并缓存结果五分钟。

要缓存搜索结果：

1. 在右上角，选择 **管理员**。
1. 在左侧边栏，选择 **设置** > **搜索**。
1. 展开 **精确代码搜索**。
1. 选中 **缓存搜索结果五分钟** 复选框。
1. 选择 **保存更改**。

<a id="set-concurrent-indexing-tasks"></a>

## 设置并发索引任务

{{< history >}}

- 在极狐GitLab 17.4 中引入。

{{< /history >}}

先决条件：

- 管理员访问权限。

你可以根据 Zoekt 节点的 CPU 容量设置并发索引任务数。

更高的乘数意味着可以同时运行更多任务，这将在提高索引吞吐量的同时增加 CPU 使用率。
默认值为 `1.0`（每个 CPU 核心一个任务）。

你可以根据节点的性能和工作负载调整此值。
要设置并发索引任务数：

1. 在右上角，选择 **管理员**。
1. 在左侧边栏，选择 **设置** > **搜索**。
1. 展开 **精确代码搜索**。
1. 在 **索引 CPU 与任务乘数** 文本框中，输入一个值。

   例如，如果一个 Zoekt 节点有 `4` 个 CPU 核心，乘数为 `1.5`，则该节点的并发任务数为 `6`。
1. 选择 **保存更改**。

<a id="define-the-probability-of-random-force-reindexing"></a>

## 定义随机强制重新索引的概率

{{< history >}}

- 在极狐GitLab 18.9 中引入。

{{< /history >}}

先决条件：

- 管理员访问权限。

你可以定义项目被强制重新索引而不是增量索引的概率。
默认值为 `0.25`（0.25%）。

强制重新索引通过定期从头重建索引来帮助防止内存映射（mmap）处理程序耗尽。
更高的百分比会增加索引负载，尤其是对于非常大的仓库。

要定义随机强制重新索引的概率：

1. 在右上角，选择 **管理员**。
1. 在左侧边栏，选择 **设置** > **搜索**。
1. 展开 **精确代码搜索**。
1. 在 **随机强制重新索引的概率（百分比）** 文本框中，输入一个介于 `0` 和 `100` 之间的数字。
1. 选择 **保存更改**。

<a id="set-the-number-of-parallel-processes-per-indexing-task"></a>

## 设置每个索引任务的并行进程数

{{< history >}}

- 在极狐GitLab 18.1 中引入。

{{< /history >}}

先决条件：

- 管理员访问权限。

你可以设置每个索引任务的并行进程数。

更高的数值将在提高索引速度的同时增加 CPU 和内存使用率。
默认值为 `1`（每个索引任务一个进程）。

你可以根据节点的性能和工作负载调整此值。
要设置每个索引任务的并行进程数：

1. 在右上角，选择 **管理员**。
1. 在左侧边栏，选择 **设置** > **搜索**。
1. 展开 **精确代码搜索**。
1. 在 **每个索引任务的并行进程数** 文本框中，输入一个值。
1. 选择 **保存更改**。

<a id="set-the-number-of-namespaces-per-indexing-rollout"></a>

## 设置每次索引推广的命名空间数

{{< history >}}

- 在极狐GitLab 18.0 中引入。

{{< /history >}}

先决条件：

- 管理员访问权限。

你可以为初始索引设置每个 `RolloutWorker` 作业的命名空间数。
默认值为 `32`。
你可以根据节点的性能和工作负载调整此值。

要设置每次索引推广的命名空间数：

1. 在右上角，选择 **管理员**。
1. 在左侧边栏，选择 **设置** > **搜索**。
1. 展开 **精确代码搜索**。
1. 在 **每次索引推广的命名空间数** 文本框中，输入一个大于零的数字。
1. 选择 **保存更改**。

<a id="define-when-offline-nodes-are-automatically-deleted"></a>

## 定义离线节点自动删除时间

{{< history >}}

- 在极狐GitLab 17.5 中引入。
- 在极狐GitLab 18.1 中，**12 小时后删除离线节点** 复选框更新为 **离线节点在以下时间后自动删除** 文本框。

{{< /history >}}

先决条件：

- 管理员访问权限。

你可以在特定时间段后自动删除离线 Zoekt 节点及其相关索引、仓库和任务。
默认值为 `12h`（12 小时）。

使用此设置来管理你的 Zoekt 基础设施并防止孤立资源。
要定义离线节点自动删除的时间：

1. 在右上角，选择 **管理员**。
1. 在左侧边栏，选择 **设置** > **搜索**。
1. 展开 **精确代码搜索**。
1. 在 **离线节点在以下时间后自动删除** 文本框中，输入一个值（例如 `30m`（30 分钟）、`2h`（两小时）或 `1d`（一天））。
   要禁用自动删除，请设置为 `0`。
1. 选择 **保存更改**。

<a id="define-the-indexing-timeout-for-a-project"></a>

## 定义项目索引超时

{{< history >}}

- 在极狐GitLab 18.2 中引入。

{{< /history >}}

先决条件：

- 管理员访问权限。

你可以定义项目的索引超时。
默认值为 `30m`（30 分钟）。

要定义项目的索引超时：

1. 在右上角，选择 **管理员**。
1. 在左侧边栏，选择 **设置** > **搜索**。
1. 展开 **精确代码搜索**。
1. 在 **每个项目的索引超时** 文本框中，输入一个值（例如 `30m`（30 分钟）、`2h`（两小时）或 `1d`（一天））。
1. 选择 **保存更改**。

<a id="set-the-maximum-number-of-files-in-a-project-to-be-indexed"></a>

## 设置项目中可索引的最大文件数

{{< history >}}

- 在极狐GitLab 18.2 中引入。

{{< /history >}}

先决条件：

- 管理员访问权限。

你可以设置项目中可索引的最大文件数。
默认分支上文件数超过此限制的项目不会被索引。
默认值为 `500,000`。

你可以根据节点的性能和工作负载调整此值。
要设置项目中可索引的最大文件数：

1. 在右上角，选择 **管理员**。
1. 在左侧边栏，选择 **设置** > **搜索**。
1. 展开 **精确代码搜索**。
1. 在 **每个项目可索引的最大文件数** 文本框中，输入一个大于零的数字。
1. 选择 **保存更改**。

<a id="set-maximum-file-size-for-indexing"></a>

## 设置索引的最大文件大小

{{< history >}}

- 在极狐GitLab 18.7 中引入。

{{< /history >}}

先决条件：

- 管理员访问权限。

你可以设置要索引的最大文件大小。
默认值为 `1MB`。

对于超过指定大小的文件，仅索引文件名。
你只能通过文件名搜索这些文件。

要设置索引的最大文件大小：

1. 在右上角，选择 **管理员**。
1. 在左侧边栏，选择 **设置** > **搜索**。
1. 展开 **精确代码搜索**。
1. 在 **索引的最大文件大小** 文本框中，输入一个值（例如 `512B`、`50KB`、`2MB` 或 `1GB`）。
   该值也可以是小写。
1. 选择 **保存更改**。

<a id="set-the-maximum-trigram-count-for-indexing"></a>

## 设置索引的最大三元组计数

{{< history >}}

- 在极狐GitLab 18.8 中引入。

{{< /history >}}

先决条件：

- 管理员访问权限。

你可以设置要索引的文件的最大三元组数量。
默认值为 `20,000`。

三元组是 Zoekt 用于高效代码搜索的三字符序列。
对于超过此三元组限制的文件，仅索引文件名。
更高的限制会影响索引和搜索性能。

要设置索引的最大三元组计数：

1. 在右上角，选择 **管理员**。
1. 在左侧边栏，选择 **设置** > **搜索**。
1. 展开 **精确代码搜索**。
1. 在 **每个文件的最大三元组数** 文本框中，输入一个大于零的数字。
1. 选择 **保存更改**。

<a id="define-the-retry-interval-for-failed-namespaces"></a>

## 定义失败命名空间的重试间隔

{{< history >}}

- 在极狐GitLab 17.10 中引入。

{{< /history >}}

先决条件：

- 管理员访问权限。

你可以为之前失败的命名空间定义重试间隔。
默认值为 `1d`（一天）。
值为 `0` 表示失败的命名空间永不重试。

要定义失败命名空间的重试间隔：

1. 在右上角，选择 **管理员**。
1. 在左侧边栏，选择 **设置** > **搜索**。
1. 展开 **精确代码搜索**。
1. 在 **失败命名空间的重试间隔** 文本框中，输入一个值（例如 `30m`（30 分钟）、`2h`（两小时）或 `1d`（一天））。
1. 选择 **保存更改**。

<a id="set-the-number-of-replicas-per-namespace"></a>

## 设置每个命名空间的副本数

{{< history >}}

- 在极狐GitLab 18.7 中引入。

{{< /history >}}

先决条件：

- 管理员访问权限。

你可以设置每个命名空间的副本数。
默认值为 `1`（每个命名空间一个副本）。

增加每个命名空间的副本数可以通过将负载分布到多个 Zoekt 节点来提高搜索可用性。
更多副本会增加存储需求。

要设置每个命名空间的副本数：

1. 在右上角，选择 **管理员**。
1. 在左侧边栏，选择 **设置** > **搜索**。
1. 展开 **精确代码搜索**。
1. 在 **每个命名空间的副本数** 文本框中，输入一个大于零的数字。
1. 选择 **保存更改**。

<a id="run-zoekt-on-a-separate-server"></a>

## 在独立服务器上运行 Zoekt

{{< history >}}

- 极狐GitLab 16.3 引入了 Zoekt 的身份验证。

{{< /history >}}

先决条件：

- 管理员访问权限。

要在与极狐GitLab 不同的服务器上运行 Zoekt：

1. [更改 Gitaly 监听接口](../../administration/gitaly/configure_gitaly.md#change-the-gitaly-listening-interface)。
1. [安装 Zoekt](#install-zoekt)。

<a id="sizing-recommendations"></a>

## 规模建议

以下建议对于某些部署可能过度配置。
你应该监控你的部署以确保：

- 不发生内存不足事件。
- CPU 节流不过度。
- 索引性能满足你的需求。

根据你的具体工作负载特征调整资源，包括：

- 仓库大小和复杂性
- 活跃开发者数量
- 代码更改频率
- 索引模式

<a id="memory-architecture"></a>

### 内存架构

Webserver 和 Indexer 有不同的内存使用模式。

Webserver 将磁盘上的索引分片内存映射到虚拟内存中。
操作系统在提供搜索服务时，将分片数据调入和调出物理内存。
常驻内存使用量随着活跃工作集的增长而增加。
具有更大索引或更高查询量的节点需要更多的 Webserver 内存，以避免页面抖动和内存不足情况。

当 Indexer 构建或重建索引时，Indexer 进程在内存中处理 Git 对象数据。
当索引大型仓库或多个任务并行运行时，内存使用量会激增。
你可以通过调整[每个索引任务的并行进程数](#set-the-number-of-parallel-processes-per-indexing-task)和[并发索引任务数](#set-concurrent-indexing-tasks)来控制峰值 Indexer 内存。

在 VM 和裸机部署中，Webserver 和 Indexer 共享相同的系统内存。

<a id="nodes"></a>

### 节点

为了获得最佳性能，正确调整 Zoekt 节点的大小至关重要。
由于资源分配和管理方式的差异，Kubernetes 和 VM 部署的规模建议有所不同。

<a id="kubernetes-deployments"></a>

#### Kubernetes 部署
下表展示了基于索引存储需求的 Kubernetes 部署中每节点（每 StatefulSet Pod）的推荐资源。
StatefulSet 中的每个 Pod 都运行自己的 Web 服务器和索引器容器，具有独立的资源分配和其自己的持久卷用于索引存储。
如果运行多个节点，请将这些资源乘以节点数以计算总集群资源。

| 磁盘   | Web 服务器 CPU | Web 服务器内存 | 索引器 CPU | 索引器内存 |
|--------|---------------|----------------|------------|------------|
| 128 GB | 1             | 16 GiB         | 1          | 6 GiB      |
| 256 GB | 1.5           | 32 GiB         | 1          | 8 GiB      |
| 512 GB | 2             | 64 GiB         | 1          | 12 GiB     |
| 1 TB   | 3             | 128 GiB        | 1.5        | 24 GiB     |
| 2 TB   | 4             | 256 GiB        | 2          | 32 GiB     |

为了更精细地管理资源，你可以分别向不同容器分配 CPU 和内存。

对于 Kubernetes 部署：

- 不要为 Zoekt 容器设置 CPU 限制。CPU 限制可能会在索引突发期间导致不必要的节流，从而显著影响性能。相反，依靠资源请求来保证最低 CPU 可用性，并确保容器在可用且需要时使用额外的 CPU。
- 设置适当的内存限制以防止资源争用和内存不足情况。
- 使用高性能存储类以获得更好的索引性能。JihuLab.com 使用 GCP 上的 `pd-balanced`，可平衡性能和成本。等效选项包括 AWS 上的 `gp3` 和 Azure 上的 `Premium_LRS`。

#### 虚拟机与裸机部署

下表展示了基于索引存储要求的虚拟机和裸机部署中每个节点的推荐资源。
如果运行多个节点，请将这些资源乘以节点数以计算总集群资源。

| 磁盘   | 虚拟机规格 | 总 CPU | 总内存 | AWS          | GCP             | Azure              |
|--------|-----------|--------|--------|--------------|-----------------|--------------------|
| 128 GB | 小型      | 2 核   | 16 GB  | `r5.large`   | `n1-highmem-2`  | `Standard_E2s_v3`  |
| 256 GB | 中型      | 4 核   | 32 GB  | `r5.xlarge`  | `n1-highmem-4`  | `Standard_E4s_v3`  |
| 512 GB | 大型      | 4 核   | 64 GB  | `r5.2xlarge` | `n1-highmem-8`  | `Standard_E8s_v3`  |
| 1 TB   | 超大型    | 8 核   | 128 GB | `r5.4xlarge` | `n1-highmem-16` | `Standard_E16s_v3` |
| 2 TB   | 2 倍超大型 | 16 核  | 256 GB | `r5.8xlarge` | `n1-highmem-32` | `Standard_E32s_v3` |

只能将这些资源分配给整个节点。

对于虚拟机和裸机部署：

- 监控 CPU、内存和磁盘使用情况以识别瓶颈。
- 考虑使用 SSD 存储以获得更好的索引性能。
- 确保极狐GitLab 与 Zoekt 节点之间有足够的网络带宽用于数据传输。

### 存储

Zoekt 存储要求取决于你的 Git 仓库大小和副本配置。
Zoekt 仅索引 Git 对象数据（源代码和提交历史）。
它不索引 LFS 文件、CI/CD 产物、软件包、Wiki 或其他存储组件。

#### 估算需求

要估算存储需求，请运行此 Rake 任务：

```shell
sudo gitlab-rake gitlab:zoekt:estimate_storage
```

此任务查询你的极狐GitLab 数据库，并根据你当前的仓库大小和副本配置输出存储估计。

要手动计算存储需求，请改用以下公式：

```plaintext
每副本存储 = 仓库 Git 大小总和 × 缓冲因子
总集群存储 = 每副本存储 × 副本数
```

`repository_git_size` 是每个仓库的 Git 对象大小。此值不包括 LFS 对象、wiki、产物或软件包。
`buffer_factor` 是初始索引期间的预留空间。你可以将此值计算为 `Search::Zoekt::Index.global_buffer_factor`，默认通常为 `3`。

要查看 `repository_git_size`：

1. 在右上角，选择 **管理员**。
1. 在左侧边栏，选择 **概览** > **项目**。
1. 在 **代码仓** 列中，查看 Git 对象大小。

对于初始配置目标，从你的总 `repository_git_size` 乘以副本数的三倍开始。

例如：

- 100 GB 的 Git 仓库数据和 1 个副本：300 GB 的 Zoekt 存储。
- 100 GB 的 Git 仓库数据和 2 个副本：600 GB 的 Zoekt 存储。

极狐GitLab 在内部保留此缓冲区，以确保 Zoekt 在索引期间有预留空间。
初始索引完成后，基于 JihuLab.com 上观察到的数据，实际磁盘使用量通常接近 `repository_git_size` 的一半。
仅在需要时进行垂直或水平扩展。

要查看当前缓冲因子，请运行此 Rake 任务：

```shell
sudo gitlab-rake gitlab:zoekt:info
```

输出包括 **存储缓冲因子**，它显示了计划器正在使用的动态值。

要监控 Zoekt 节点存储，请参见 [检查索引状态](#check-indexing-status)。
如果因磁盘空间不足而未能索引命名空间，请添加节点或增加磁盘容量。

## 安全与认证

Zoekt 实现了一个多层认证系统，以确保极狐GitLab、Zoekt 索引器和 Zoekt Web 服务器组件之间的通信安全。
所有通信通道都强制执行认证。
所有认证方法都使用极狐GitLab Shell 密钥。
认证失败会返回 `401 Unauthorized` 响应。

### Zoekt 索引器到极狐GitLab

Zoekt 索引器通过 JSON Web 令牌（JWT）向极狐GitLab 进行认证，以获取索引任务并发送完成回调。
该方法使用 `.gitlab_shell_secret` 进行签名和验证。
令牌在 `Gitlab-Shell-Api-Request` 头部中发送。
以下端点可用：

- `GET /internal/search/zoekt/:uuid/heartbeat` 用于任务检索
- `POST /internal/search/zoekt/:uuid/callback` 用于状态更新

该方法确保 Zoekt 索引器节点与极狐GitLab 之间的安全轮询，用于任务分发和状态报告。

### 极狐GitLab 到 Zoekt Web 服务器

#### JWT 认证

{{< history >}}

- JWT 认证在极狐GitLab Zoekt 1.0.0 中引入。

{{< /history >}}

极狐GitLab 通过 JSON Web 令牌（JWT）向 Zoekt Web 服务器认证以执行搜索查询。
JWT 令牌提供有时限的、加密签名的认证，与极狐GitLab的其他认证模式一致。
该方法使用 `Gitlab::Shell.secret_token` 和 HS256 算法（带有 SHA-256 的 HMAC）。
令牌在 `Authorization: Bearer <jwt_token>` 头部中发送，并在五分钟后过期以限制暴露。
端点包括 `/webserver/api/search` 和 `/webserver/api/v2/search`。
JWT 声明包括发行者（`gitlab`）和受众（`gitlab-zoekt`）。