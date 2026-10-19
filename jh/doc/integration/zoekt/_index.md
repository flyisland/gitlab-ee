---
stage: Analytics
group: Global Search
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
title: Zoekt
---

{{< details >}}

- Tier: 专业版，旗舰版
- Offering: JihuLab.com，私有化部署

{{< /details >}}

Zoekt 是一款专为代码搜索而设计的开源搜索引擎。

通过此集成，您可以使用[精确代码搜索](../../user/search/exact_code_search.md)代替[高级搜索](../../user/search/advanced_search.md)来搜索极狐GitLab 中的代码。您可以使用精确匹配和正则表达式模式在群组或代码仓库中搜索代码。

> [!note]
> Zoekt 仅处理代码搜索，不能替代
> [Elasticsearch 或 OpenSearch](../advanced_search/elasticsearch.md)。
> 对于所有其他搜索范围，包括评论、提交、史诗、
> 议题、合并请求、里程碑、项目、用户和 Wiki，
> 仍然需要 Elasticsearch 或 OpenSearch。

<a id="version-compatibility"></a>

## 版本兼容性

每个极狐GitLab 版本都对应特定的 `gitlab-zoekt-indexer` 和 `gitlab-zoekt` chart 版本。

| 极狐GitLab 版本 | `gitlab-zoekt-indexer` 版本 | `gitlab-zoekt` chart 版本 |
|----------------|--------------------------------|------------------------------|
| 19.4           | 1.19.0                         | 4.1.0                        |
| 19.1 至 19.3   | 1.16.1                         | 4.1.0                        |
| 19.0           | 1.14.2                         | 4.0.0                        |
| 18.11          | 1.13.1                         | 3.11.0                       |
| 18.10          | 1.11.2                         | 3.10.0                       |
| 18.9           | 1.8.2                          | 3.9.0                        |
| 18.8           | 1.8.0                          | 3.8.0                        |
| 18.6 和 18.7  | 1.7.6                          | 3.7.1                        |

<a id="install-zoekt"></a>

## 安装 Zoekt

先决条件：

- 管理员访问权限。

要在极狐GitLab 中[启用精确代码搜索](#enable-exact-code-search)，您必须至少有一个 Zoekt 节点连接到该实例。Zoekt 支持以下安装方法：

- [Zoekt chart](https://gitlab.cn/docs/charts/charts/gitlab/gitlab-zoekt/)
  （作为独立 chart 或 GitLab Helm chart 的子 chart）
- [GitLab Operator](https://docs.gitlab.com/operator/)（使用 `gitlab-zoekt.install=true`）

以下安装方法可用于测试，不适用于生产环境：

- [Docker Compose](https://gitlab.com/gitlab-org/gitlab-zoekt-indexer/-/tree/main/example/docker-compose)
- [Ansible playbook](https://gitlab.com/gitlab-org/search-team/code-search/ansible-gitlab-zoekt)

<a id="enable-exact-code-search"></a>

## 启用精确代码搜索

<a id="from-the-gitlab-ui"></a>

### 通过极狐GitLab UI

先决条件：

- 管理员访问权限。
- [已安装 Zoekt](#install-zoekt)。

要通过极狐GitLab UI 启用[精确代码搜索](../../user/search/exact_code_search.md)：

1. 在右上角，选择**管理员**。
1. 在左侧边栏中，选择**设置** > **搜索**。
1. 展开**精确代码搜索**。
1. 选中**启用索引**和**启用搜索**复选框。
1. 选择**保存更改**。

<a id="with-rake-tasks"></a>

### 使用 Rake 任务

先决条件：

- 管理员访问权限。
- [已安装 Zoekt](#install-zoekt)。

您可以使用 Rake 任务管理[精确代码搜索](../../user/search/exact_code_search.md)。

<a id="enable-indexing-and-search"></a>

#### 启用索引和搜索

要启用索引和搜索，请运行此 Rake 任务：

```shell
gitlab-rake gitlab:zoekt:index
```

此任务会启用 `zoekt_indexing_enabled`、`zoekt_search_enabled` 和 `zoekt_auto_index_root_namespace`。`RolloutWorker` 会自动索引所有根命名空间，索引就绪后即可进行搜索。

<a id="disable-indexing-and-search"></a>

#### 禁用索引和搜索

要禁用索引和搜索，请运行此 Rake 任务：

```shell
gitlab-rake gitlab:zoekt:disable
```

此任务会同时禁用 `zoekt_indexing_enabled` 和 `zoekt_search_enabled`。

<a id="pause-and-resume-indexing"></a>

#### 暂停和恢复索引

要暂停索引（例如在维护期间），请运行此 Rake 任务：

```shell
gitlab-rake gitlab:zoekt:pause_indexing
```

要恢复索引，请运行此 Rake 任务：

```shell
gitlab-rake gitlab:zoekt:resume_indexing
```

<a id="estimate-storage-requirements"></a>

#### 估算存储需求

要估算 Zoekt 节点所需的存储空间，请运行此 Rake 任务：

```shell
sudo gitlab-rake gitlab:zoekt:estimate_storage
```

有关更多信息，请参阅[估算存储需求](#estimate-requirements)。

<a id="retry-indexing-of-failed-repositories"></a>

#### 重试失败代码仓库的索引

要重试所有 `failed` 状态的 Zoekt 代码仓库记录，请运行此 Rake 任务：

```shell
gitlab-rake gitlab:zoekt:reindex_failed_projects
```

此任务会将所有 `failed` 状态的 `zoekt_repository` 记录移至 `pending` 状态，并将 `retries_left` 设置为 `1`，以便它们在下一次索引周期中被处理。

要仅重试特定项目，请传入以逗号分隔的项目 ID 列表：

```shell
gitlab-rake "gitlab:zoekt:reindex_failed_projects[1,2,3]"
```

<a id="check-indexing-status"></a>

## 检查索引状态

先决条件：

- 管理员访问权限。

索引性能取决于 Zoekt 索引器节点上的 CPU 和内存限制。要检查索引状态：

{{< tabs >}}

{{< tab title="GitLab 17.10 and later" >}}

运行此 Rake 任务：

```shell
gitlab-rake gitlab:zoekt:info
```

要让数据每 10 秒自动刷新一次，请改为运行此 Rake 任务：

```shell
gitlab-rake "gitlab:zoekt:info[10]"
```

{{< /tab >}}

{{< tab title="GitLab 17.9 and earlier" >}}

在 [Rails 控制台](../../administration/operations/rails_console.md#starting-a-rails-console-session)中，运行以下命令：

```ruby
Search::Zoekt::Index.group(:state).count
Search::Zoekt::Repository.group(:state).count
Search::Zoekt::Task.group(:state).count
```

{{< /tab >}}

{{< /tabs >}}

<a id="sample-output"></a>

### 示例输出

`gitlab:zoekt:info` Rake 任务返回的输出类似于以下内容：

```console
Exact Code Search
GitLab version:                                                 19.1.0
Enable indexing:                                                yes
Enable searching:                                               yes
Pause indexing:                                                 no
Index root namespaces automatically:                            yes
Cache search results for five minutes:                          yes
Indexing CPU to tasks multiplier:                               1.0
Probability of random force reindexing (percentage):            0.25
Number of parallel processes per indexing task:                 1
Number of namespaces per indexing rollout:                      32
Offline nodes automatically deleted after:                      20m
Indexing timeout per project:                                   30m
Maximum number of files per project to be indexed:              500000
Maximum file size for indexing:                                 1MB
Maximum trigrams per file:                                      20000
Retry interval for failed namespaces:                           1d
Number of replicas per namespace:                               1
Maximum number of projects for legacy search:                   1000
Maximum number of process restarts within 15 minutes for nodes: 3
Number of pending indices to start indexing per node:           1

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
Feature flags:  none

Feature Flags (Default Values)
Feature flags:  none

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

先决条件：

- 管理员访问权限。

运行健康检查以了解 Zoekt 基础设施的状态，包括：

- 在线和离线节点
- 索引和搜索设置
- 搜索 API 端点
- JSON Web 令牌生成

要运行健康检查，请执行以下任务：

```shell
gitlab-rake gitlab:zoekt:health
```

此任务提供：

- 总体状态：`HEALTHY`、`DEGRADED` 或 `UNHEALTHY`
- 解决检测到的问题的建议
- 用于自动化和监控集成的退出码：`0=healthy`、`1=degraded` 或 `2=unhealthy`

<a id="run-checks-automatically"></a>

### 自动运行检查

要每 10 秒自动运行一次健康检查，请执行以下任务：

```shell
gitlab-rake "gitlab:zoekt:health[10]"
```

输出包含彩色状态指示器，并显示：

- 在线和离线节点数量、存储使用警告以及连接问题
- 核心设置验证以及命名空间和代码仓库索引状态
- 总体状态，包括综合健康评估：`HEALTHY`、`DEGRADED` 或 `UNHEALTHY`
- 解决问题的建议

<a id="force-reindex-projects"></a>

## 强制重新索引项目

先决条件：

- 管理员访问权限。

要强制重新索引一定范围内的项目，请运行此 Rake 任务：

```shell
gitlab-rake gitlab:zoekt:reindex_projects ID_FROM=10 ID_TO=20
```

`ID_FROM` 和 `ID_TO` 表示项目 ID 的范围。

要仅强制重新索引一个项目，请为 `ID_FROM` 和 `ID_TO` 使用相同的值。要强制重新索引所有项目，请不要使用这些环境变量。

<a id="pause-indexing"></a>

## 暂停索引

先决条件：

- 管理员访问权限。

要暂停[精确代码搜索](../../user/search/exact_code_search.md)的索引：

1. 在右上角，选择**管理员**。
1. 在左侧边栏中，选择**设置** > **搜索**。
1. 展开**精确代码搜索**。
1. 选中**暂停索引**复选框。
1. 选择**保存更改**。

当您暂停精确代码搜索的索引时，代码仓库中的所有更改都会排队。要恢复索引，请清除**暂停精确代码搜索的索引**复选框。

<a id="index-root-namespaces-automatically"></a>

## 自动索引根命名空间

先决条件：

- 管理员访问权限。

您可以自动索引现有和新的根命名空间。要自动索引所有根命名空间：

1. 在右上角，选择**管理员**。
1. 在左侧边栏中，选择**设置** > **搜索**。
1. 展开**精确代码搜索**。
1. 选中**自动索引根命名空间**复选框。
1. 选择**保存更改**。

当您启用此设置时，极狐GitLab 会为以下范围内的所有项目创建索引任务：

- 所有群组和子群组
- 任何新的根命名空间

项目完成索引后，极狐GitLab 仅在检测到代码仓库变更时创建增量索引。

当您禁用此设置时：

- 现有根命名空间保持已索引状态。
- 不再索引新的根命名空间。

<a id="cache-search-results"></a>

## 缓存搜索结果

先决条件：

- 管理员访问权限。

您可以缓存搜索结果以获得更好的性能。此功能默认启用，并缓存结果五分钟。

要缓存搜索结果：

1. 在右上角，选择**管理员**。
1. 在左侧边栏中，选择**设置** > **搜索**。
1. 展开**精确代码搜索**。
1. 选中**缓存搜索结果五分钟**复选框。
1. 选择**保存更改**。

<a id="set-concurrent-indexing-tasks"></a>

## 设置并发索引任务数

先决条件：

- 管理员访问权限。

您可以相对于 Zoekt 节点的 CPU 容量设置其并发索引任务数。

乘数越高，可并发运行的任务就越多，这会提高索引吞吐量，但代价是 CPU 使用率增加。默认值为 `1.0`（每个 CPU 核心一个任务）。

您可以根据节点的性能和工作负载调整此值。要设置并发索引任务数：

1. 在右上角，选择**管理员**。
1. 在左侧边栏中，选择**设置** > **搜索**。
1. 展开**精确代码搜索**。
1. 在**索引 CPU 与任务数乘数**文本框中，输入一个值。

   例如，如果 Zoekt 节点有 `4` 个 CPU 核心，乘数为 `1.5`，
   则该节点的并发任务数为 `6`。
1. 选择**保存更改**。

<a id="define-the-probability-of-random-force-reindexing"></a>

## 定义随机强制重新索引的概率

先决条件：

- 管理员访问权限。

您可以定义项目被强制重新索引而非增量索引的概率。默认值为 `0.25`（0.25%）。

强制重新索引通过定期从头重建索引，有助于防止内存映射（mmap）处理程序耗尽。百分比越高，索引负载越大，对于非常大的代码仓库尤其如此。

要定义随机强制重新索引的概率：

1. 在右上角，选择**管理员**。
1. 在左侧边栏中，选择**设置** > **搜索**。
1. 展开**精确代码搜索**。
1. 在**随机强制重新索引的概率（百分比）**文本框中，
   输入一个介于 `0` 和 `100` 之间的数字。
1. 选择**保存更改**。

<a id="set-the-number-of-parallel-processes-per-indexing-task"></a>

## 设置每个索引任务的并行进程数

先决条件：

- 管理员访问权限。

您可以设置每个索引任务的并行进程数。

数值越高，索引时间越短，但代价是 CPU 和内存使用率增加。默认值为 `1`（每个索引任务一个进程）。

您可以根据节点的性能和工作负载调整此值。要设置每个索引任务的并行进程数：

1. 在右上角，选择**管理员**。
1. 在左侧边栏中，选择**设置** > **搜索**。
1. 展开**精确代码搜索**。
1. 在**每个索引任务的并行进程数**文本框中，输入一个值。
1. 选择**保存更改**。

<a id="set-the-number-of-namespaces-per-indexing-rollout"></a>

## 设置每次索引推广的命名空间数

先决条件：

- 管理员访问权限。

您可以设置初始索引时每个 `RolloutWorker` 作业的命名空间数。默认值为 `32`。您可以根据节点的性能和工作负载调整此值。

要设置每次索引推广的命名空间数：

1. 在右上角，选择**管理员**。
1. 在左侧边栏中，选择**设置** > **搜索**。
1. 展开**精确代码搜索**。
1. 在**每次索引推广的命名空间数**文本框中，
   输入一个大于零的数字。
1. 选择**保存更改**。

<a id="define-when-offline-nodes-are-automatically-deleted"></a>

## 定义离线节点自动删除的时间

先决条件：

- 管理员访问权限。

您可以在特定时间段后自动删除离线 Zoekt 节点及其相关的索引、代码仓库和任务。默认值为 `12h`（12 小时）。

使用此设置来管理您的 Zoekt 基础设施并防止出现孤立资源。要定义离线节点自动删除的时间：

1. 在右上角，选择**管理员**。
1. 在左侧边栏中，选择**设置** > **搜索**。
1. 展开**精确代码搜索**。
1. 在**离线节点自动删除时间**文本框中，输入一个值
   （例如 `30m`（30 分钟）、`2h`（两小时）或 `1d`（一天））。
   要禁用自动删除，请设置为 `0`。
1. 选择**保存更改**。

<a id="define-the-indexing-timeout-for-a-project"></a>

## 定义项目的索引超时时间

先决条件：

- 管理员访问权限。

您可以定义项目的索引超时时间。默认值为 `30m`（30 分钟）。

要定义项目的索引超时时间：

1. 在右上角，选择**管理员**。
1. 在左侧边栏中，选择**设置** > **搜索**。
1. 展开**精确代码搜索**。
1. 在**每个项目的索引超时时间**文本框中，输入一个值
   （例如 `30m`（30 分钟）、`2h`（两小时）或 `1d`（一天））。
1. 选择**保存更改**。

<a id="set-the-maximum-number-of-files-in-a-project-to-be-indexed"></a>

## 设置项目中可索引的最大文件数

先决条件：

- 管理员访问权限。

您可以设置项目中可索引的最大文件数。默认分支上文件数超过此限制的项目不会被索引。默认值为 `500,000`。

您可以根据节点的性能和工作负载调整此值。要设置项目中可索引的最大文件数：

1. 在右上角，选择**管理员**。
1. 在左侧边栏中，选择**设置** > **搜索**。
1. 展开**精确代码搜索**。
1. 在**每个项目中可索引的最大文件数**文本框中，输入一个大于零的数字。
1. 选择**保存更改**。

<a id="set-maximum-file-size-for-indexing"></a>

## 设置可索引的最大文件大小

先决条件：

- 管理员访问权限。

您可以设置可索引文件的最大大小。默认值为 `1MB`。

对于超过指定大小的文件，仅索引文件名。您只能按文件名搜索这些文件。

要设置可索引的最大文件大小：

1. 在右上角，选择**管理员**。
1. 在左侧边栏中，选择**设置** > **搜索**。
1. 展开**精确代码搜索**。
1. 在**可索引的最大文件大小**文本框中，输入一个值
   （例如 `512B`、`50KB`、`2MB` 或 `1GB`）。
   该值也可以使用小写形式。
1. 选择**保存更改**。

<a id="set-the-maximum-trigram-count-for-indexing"></a>

## 设置可索引的最大三元组数量

先决条件：

- 管理员访问权限。

您可以设置文件可索引的最大三元组数量。默认值为 `20,000`。

三元组是 Zoekt 用于高效代码搜索的三字符序列。对于超过此三元组限制的文件，仅索引文件名。限制越高，对索引和搜索性能的影响就越大。

要设置可索引的最大三元组数量：

1. 在右上角，选择**管理员**。
1. 在左侧边栏中，选择**设置** > **搜索**。
1. 展开**精确代码搜索**。
1. 在**每个文件的最大三元组数**文本框中，输入一个大于零的数字。
1. 选择**保存更改**。

<a id="define-the-retry-interval-for-failed-namespaces"></a>

## 定义失败命名空间的重试间隔

先决条件：

- 管理员访问权限。

您可以定义之前失败的命名空间的重试间隔。默认值为 `1d`（一天）。值为 `0` 表示失败的命名空间永不重试。

要定义失败命名空间的重试间隔：

1. 在右上角，选择**管理员**。
1. 在左侧边栏中，选择**设置** > **搜索**。
1. 展开**精确代码搜索**。
1. 在**失败命名空间的重试间隔**文本框中，输入一个值
   （例如 `30m`（30 分钟）、`2h`（两小时）或 `1d`（一天））。
1. 选择**保存更改**。

<a id="set-the-number-of-replicas-per-namespace"></a>

## 设置每个命名空间的副本数

先决条件：

- 管理员访问权限。

您可以设置每个命名空间的副本数。默认值为 `1`（每个命名空间一个副本）。

增加每个命名空间的副本数可通过将负载分散到多个 Zoekt 节点来提高搜索可用性。副本越多，存储需求越大。

要设置每个命名空间的副本数：

1. 在右上角，选择**管理员**。
1. 在左侧边栏中，选择**设置** > **搜索**。
1. 展开**精确代码搜索**。
1. 在**每个命名空间的副本数**文本框中，
   输入一个大于零的数字。
1. 选择**保存更改**。

<a id="set-the-maximum-number-of-projects-for-legacy-search"></a>

## 设置旧版搜索的最大项目数

先决条件：

- 管理员访问权限。

您可以设置当遍历 ID 索引仍在进行时，在群组中可搜索的最大项目数。默认值为 `1,000`。

当您在遍历 ID 索引完成之前在群组中搜索时，极狐GitLab 仅搜索（按项目 ID 排序的）前若干个不超过此限制的项目，并显示一条警告，提示某些项目未包含在结果中。遍历 ID 索引完成后，极狐GitLab 会搜索群组中的所有项目。

要设置旧版搜索的最大项目数：

1. 在右上角，选择**管理员**。
1. 在左侧边栏中，选择**设置** > **搜索**。
1. 展开**精确代码搜索**。
1. 在**旧版搜索的最大项目数**文本框中，输入一个大于零的数字。
1. 选择**保存更改**。

<a id="set-the-maximum-number-of-process-restarts-for-nodes"></a>

## 设置节点的最大进程重启次数

先决条件：

- 管理员访问权限。

您可以设置节点被排除在搜索路由之外前，15 分钟内的最大进程重启次数。默认值为 `2`。

极狐GitLab 使用此设置来检测陷入崩溃循环的索引器或 Web 服务器进程。当节点在 15 分钟内的进程重启次数超过此值时，该节点会被排除在搜索之外，直到重启次数恢复到正常范围。值为 `0` 表示节点在单次重启后即被排除。

如果所有在线节点都被排除，极狐GitLab 会回退到使用全部在线节点，以避免搜索中断。

要设置节点的最大进程重启次数：

1. 在右上角，选择**管理员**。
1. 在左侧边栏中，选择**设置** > **搜索**。
1. 展开**精确代码搜索**。
1. 在**节点在 15 分钟内的最大进程重启次数**
   文本框中，输入一个大于或等于零的数字。
1. 选择**保存更改**。

<a id="run-zoekt-on-a-separate-server"></a>

## 在单独的服务器上运行 Zoekt

先决条件：

- 管理员访问权限。

要在与极狐GitLab 不同的服务器上运行 Zoekt：

1. [配置 Gitaly 监听 TCP](#configure-gitaly-for-an-external-zoekt-server)。
1. [安装 Zoekt](#install-zoekt)。

<a id="configure-gitaly-for-an-external-zoekt-server"></a>

### 为外部 Zoekt 服务器配置 Gitaly

Zoekt 通过连接 Gitaly 来索引代码仓库，因此 Gitaly 必须监听
Zoekt 服务器可访问的 TCP 地址。默认情况下，Gitaly 监听 Unix
套接字，只有同一服务器上的进程才能访问。

[通用说明](../../administration/gitaly/configure_gitaly.md#change-the-gitaly-listening-interface)涵盖多服务器安装。当 Gitaly 与极狐GitLab 运行在同一台服务器上，且只有 Zoekt 从外部连接时，您需要的设置更少。

> [!warning]
> `gitaly['configuration']` 会替换整个 Gitaly 配置哈希，
> 而不是合并到其中。如果您已经设置了自定义 Gitaly 选项，例如
> 额外的存储或 TLS，请将此代码片段合并到您现有的
> 配置中，而不是原样粘贴，并确保 `name` 和 `path`
> 与您的存储匹配。出于同样的原因，即使您
> 不更改存储路径，也要保留 `storage` 数组。否则，Gitaly 将没有配置
> 存储，代码仓库访问会失败。

下面的配置还会更改 Gitaly 在网络上的可访问方式。

> [!warning]
> `listen_addr: '0.0.0.0:8075'` 会让 Gitaly 监听所有接口。请将
> 端口 `8075`的访问限制为仅 Zoekt 服务器。

要为外部 Zoekt 服务器配置 Gitaly：

1. 生成令牌：

   ```shell
   openssl rand -base64 24
   ```

1. 编辑 `/etc/gitlab/gitlab.rb` 并添加以下内容，将
   `<your_secure_token>` 替换为生成的令牌，将 `<ip_address>` 替换为
   Zoekt 服务器用于访问 Gitaly 的地址：

   ```ruby
   # Shared token for Gitaly authentication
   gitlab_rails['gitaly_token'] = '<your_secure_token>'

   # Gitaly configuration
   gitaly['configuration'] = {
     listen_addr: '0.0.0.0:8075',
     auth: {
       token: '<your_secure_token>',
     },
     storage: [
       {
         name: 'default',
         path: '/var/opt/gitlab/git-data/repositories',
       },
     ]
   }

   # Tell Rails where to find Gitaly
   gitlab_rails['repositories_storages'] = {
     'default' => { 'gitaly_address' => 'tcp://<ip_address>:8075' },
   }
   ```

1. 重新配置极狐GitLab：

   ```shell
   sudo gitlab-ctl reconfigure
   ```

重新配置后，Gitaly 会在端口 `8075` 上接受 TCP 连接，Zoekt 服务器可以通过您配置的地址访问它。

<a id="sizing-recommendations"></a>

## 规模建议

以下建议对于某些部署而言可能配置过高。您应监控您的部署，以确保：

- 不发生内存不足事件。
- CPU 节流不过度。
- 索引性能满足您的要求。

请根据您的具体工作负载特征调整资源，包括：

- 代码仓库大小和复杂度
- 活跃开发者数量
- 代码变更频率
- 索引模式

<a id="memory-architecture"></a>

### 内存架构

Web 服务器和索引器的内存使用模式不同。

Web 服务器将磁盘上的索引分片内存映射到虚拟内存中。操作系统在提供搜索服务时会将分片数据在物理内存中换入换出。常驻内存使用量会随活跃工作集增长。索引更大或查询量更高的节点需要更多 Web 服务器内存，以避免页面抖动和内存不足的情况。

当索引器构建或重建索引时，索引器进程会在内存中处理 Git 对象数据。在索引大型代码仓库或并行运行多个任务时，内存使用量会激增。您可以通过调整[每个索引任务的并行进程数](#set-the-number-of-parallel-processes-per-indexing-task)和[并发索引任务数](#set-concurrent-indexing-tasks)来控制索引器的内存峰值。

在虚拟机和裸金属部署中，Web 服务器和索引器共享同一系统内存。

<a id="nodes"></a>

### 节点

为获得最佳性能，合理确定 Zoekt 节点的规模至关重要。由于资源分配和管理方式不同，Kubernetes 和虚拟机部署的规模建议有所不同。

<a id="kubernetes-deployments"></a>

#### Kubernetes 部署

下表显示了基于索引存储需求，Kubernetes 部署中每个节点（每个 StatefulSet pod）
的建议资源。StatefulSet 中的每个 pod 都运行自己的 Web 服务器和索引器容器，具有独立的资源分配和自己的索引存储持久卷。如果您运行多个节点，请将这些资源乘以节点数以计算集群总资源。

| 磁盘   | Web 服务器 CPU | Web 服务器内存  | 索引器 CPU | 索引器内存 |
|--------|---------------|-------------------|-------------|----------------|
| 128 GB | 1             | 16 GiB            | 1           | 6 GiB  |
| 256 GB | 1.5           | 32 GiB            | 1           | 8 GiB  |
| 512 GB | 2             | 64 GiB            | 1           | 12 GiB |
| 1 TB   | 3             | 128 GiB           | 1.5         | 24 GiB |
| 2 TB   | 4             | 256 GiB           | 2           | 32 GiB |

要更精细地管理资源，您可以将 CPU 和内存分别分配给不同的容器。

对于 Kubernetes 部署：

- 不要为 Zoekt 容器设置 CPU 限制。
  CPU 限制可能会在索引突发期间导致不必要的节流，
  从而严重影响性能。
  相反，应依靠资源请求来保证最低 CPU 可用性，
  并确保容器在可用且需要时使用额外的 CPU。
- 设置适当的内存限制，以防止资源争用
  和内存不足的情况。
- 使用高性能存储类以获得更好的索引性能。
  JihuLab.com 在 GCP 上使用 `pd-balanced`，它在性能和成本之间取得了平衡。
  等效选项包括 AWS 上的 `gp3` 和 Azure 上的 `Premium_LRS`。

<a id="vm-and-bare-metal-deployments"></a>

#### 虚拟机和裸金属部署

下表显示了基于索引存储需求，虚拟机和裸金属部署中每个节点的建议资源。如果您运行多个节点，请将这些资源乘以节点数以计算集群总资源。

| 磁盘   | 虚拟机规格  | 总 CPU | 总内存 | AWS          | GCP             | Azure |
|--------|----------|-----------|--------------|--------------|-----------------|-------|
| 128 GB | 小型    | 2 核   | 16 GB        | `r5.large`   | `n1-highmem-2`  | `Standard_E2s_v3`  |
| 256 GB | 中型   | 4 核   | 32 GB        | `r5.xlarge`  | `n1-highmem-4`  | `Standard_E4s_v3`  |
| 512 GB | 大型    | 4 核   | 64 GB        | `r5.2xlarge` | `n1-highmem-8`  | `Standard_E8s_v3`  |
| 1 TB   | 超大型  | 8 核   | 128 GB       | `r5.4xlarge` | `n1-highmem-16` | `Standard_E16s_v3` |
| 2 TB   | 2 倍超大型 | 16 核  | 256 GB       | `r5.8xlarge` | `n1-highmem-32` | `Standard_E32s_v3` |

您只能将这些资源分配给整个节点。

对于虚拟机和裸金属部署：

- 监控 CPU、内存和磁盘使用情况，以识别瓶颈。
- 考虑使用 SSD 存储以获得更好的索引性能。
- 确保极狐GitLab 和 Zoekt 节点之间有足够的网络带宽用于数据传输。

<a id="storage"></a>

### 存储

Zoekt 的存储需求取决于您的 Git 代码仓库大小和副本配置。Zoekt 仅索引 Git 对象数据（源代码和提交历史）。它不索引 LFS 文件、CI/CD 产物、软件包、Wiki 或其他存储组件。

<a id="estimate-requirements"></a>

#### 估算需求

要估算存储需求，请运行此 Rake 任务：

```shell
sudo gitlab-rake gitlab:zoekt:estimate_storage
```

此任务会查询您的极狐GitLab 数据库，并根据您当前的代码仓库大小和副本配置输出存储估算值。

要手动计算存储需求，请改用以下公式：

```plaintext
storage_per_replica = sum(repository_git_size) × buffer_factor
total_cluster_storage = storage_per_replica × number_of_replicas
```

`repository_git_size` 是每个代码仓库的 Git 对象大小。此值不包括 LFS 对象、Wiki、产物或软件包。`buffer_factor` 是初始索引期间的余量。您可以将此值计算为 `Search::Zoekt::Index.global_buffer_factor`，它默认大多为 `3`。

要查看 `repository_git_size`：

1. 在右上角，选择**管理员**。
1. 在左侧边栏中，选择**概览** > **项目**。
1. 在**代码仓库**列中，查看 Git 对象大小。

对于初始预配目标，请从总 `repository_git_size`的三倍乘以副本数开始。例如：

- 100 GB 的 Git 代码仓库数据和一份副本：300 GB 的 Zoekt 存储。
- 100 GB 的 Git 代码仓库数据和两份副本：600 GB 的 Zoekt 存储。

极狐GitLab 会在内部保留此缓冲区，以确保 Zoekt 在索引期间有余量。初始索引完成后，根据 JihuLab.com 上的观测数据，实际磁盘使用量通常接近 `repository_git_size`的一半。仅在需要时进行纵向或横向扩展。

要查看当前的缓冲区系数，请运行此 Rake 任务：

```shell
sudo gitlab-rake gitlab:zoekt:info
```

输出包含**存储缓冲区系数**，它显示规划器正在使用的动态值。

要监控 Zoekt 节点存储，请参阅[检查索引状态](#check-indexing-status)。如果命名空间因磁盘空间不足而未被索引，请添加节点或增加磁盘容量。

<a id="security-and-authentication"></a>

## 安全和认证

Zoekt 实现了多层认证系统，以保护
极狐GitLab、Zoekt 索引器和 Zoekt Web 服务器组件之间的通信。
所有通信渠道都强制执行认证。

所有认证方法都使用 GitLab Shell 密钥。认证失败会返回 `401 Unauthorized` 响应。

<a id="zoekt-indexer-to-gitlab"></a>

### Zoekt 索引器到极狐GitLab

Zoekt 索引器使用 JSON Web 令牌（JWT）向极狐GitLab 进行认证，
以获取索引任务并发送完成回调。

此方法使用 `.gitlab_shell_secret` 进行签名和验证。令牌通过 `Gitlab-Shell-Api-Request` 请求头发送。以下端点可用：

- `GET /internal/search/zoekt/:uuid/heartbeat` 用于获取任务
- `POST /internal/search/zoekt/:uuid/callback` 用于状态更新

此方法可确保 Zoekt 索引器节点与极狐GitLab 之间安全地轮询任务分发和状态报告。

<a id="gitlab-to-the-zoekt-webserver"></a>

### 极狐GitLab 到 Zoekt Web 服务器

<a id="jwt-authentication"></a>

#### JWT 认证

极狐GitLab 使用 JSON Web 令牌（JWT）向 Zoekt Web 服务器进行认证，
以执行搜索查询。JWT 令牌提供有时间限制、经过加密签名的认证，与其他极狐GitLab 认证模式一致。

此方法使用 `Gitlab::Shell.secret_token` 和 HS256 算法（使用 SHA-256 的 HMAC）。
令牌通过 `Authorization: Bearer <jwt_token>` 请求头发送，并在五分钟后过期，以限制暴露风险。

端点包括 `/webserver/api/search` 和 `/webserver/api/v2/search`。JWT 声明为签发者（`gitlab`）和受众（`gitlab-zoekt`）。
