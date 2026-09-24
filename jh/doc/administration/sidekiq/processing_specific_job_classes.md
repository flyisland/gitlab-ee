---
stage: Tenant Scale
group: Tenant Services
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
title: 处理特定任务类
---

> [!warning]
> 这些是高级设置。尽管它们在 JihuLab.com 上使用，但大多数极狐GitLab
> 实例应该只添加监听所有队列的进程。这与
> [参考架构](../reference_architectures/_index.md) 中描述的方法相同。

大多数极狐GitLab 实例应该让 [所有进程监听所有队列](extra_sidekiq_processes.md#start-multiple-processes)。

另一种方法是使用 [路由规则](#routing-rules)，将应用程序内的特定任务类
定向到你配置的队列名称。然后，Sidekiq
进程只需要监听少数几个已配置的队列。这样做
可以降低 Redis 的负载，这对于超大规模部署非常重要。

<a id="routing-rules"></a>

## 路由规则

{{< history >}}

- 默认路由规则值在极狐GitLab 15.4 中引入。
- 在极狐GitLab 17.0 中，队列选择器被路由规则所取代。

{{< /history >}}

> [!note]
> 邮件任务无法通过路由规则进行路由，并且始终进入
> `mailers` 队列。使用路由规则时，请确保至少有一个进程
> 监听 `mailers` 队列。通常可以将其与
> `default` 队列放在一起。

我们建议大多数极狐GitLab 实例使用路由规则来管理其 Sidekiq
队列。这允许管理员根据任务类的属性为任务类组选择单一的队列名称。
语法是一个有序的 `[查询, 队列]` 对数组：

1. 查询是一个 [Worker 匹配查询](#worker-matching-query)。
1. 队列名称必须是一个有效的 Sidekiq 队列名称。如果队列名称
   为 `nil` 或空字符串，则该 Worker 会被路由到由 Worker 名称生成的队列。
   (有关更多信息，请参阅 [可用任务类列表](#list-of-available-job-classes))。
   队列名称不必与可用任务类列表中的任何现有队列名称匹配。
1. 第一个匹配 Worker 的查询会被选中用于该 Worker；后续规则将被忽略。

<a id="routing-rules-migration"></a>

### 路由规则迁移

在更改 Sidekiq 路由规则后，你必须谨慎进行
迁移，以避免完全丢失任务，尤其是在具有长任务队列的系统中。
可以按照 [Sidekiq 任务迁移](sidekiq_job_migration.md) 中提到的迁移步骤进行迁移。

<a id="routing-rules-in-a-scaled-architecture"></a>

### 规模化架构中的路由规则

路由规则在所有极狐GitLab 节点（尤其是极狐GitLab Rails
和 Sidekiq 节点）上必须相同，因为它们是应用程序配置的一部分。

<a id="detailed-example"></a>

### 详细示例

这是一个旨在展示不同可能性的综合示例。
[Helm Chart 示例也可供参考](https://gitlab.cn/docs/charts/charts/gitlab/sidekiq/#queues)。
这些不是建议。

1. 编辑 `/etc/gitlab/gitlab.rb`：

   ```ruby
   sidekiq['routing_rules'] = [
     # 将所有非 CPU 密集型且紧急程度为高的 Worker 路由到 `high-urgency` 队列
     ['resource_boundary!=cpu&urgency=high', 'high-urgency'],
     # 将所有数据库、gitaly 和全局搜索类目且紧急程度为限流的 Worker 路由到 `throttled` 队列
     ['feature_category=database,gitaly,global_search&urgency=throttled', 'throttled'],
     # 将所有与外部有联系的 Worker 路由到 `network-intensive` 队列
     ['has_external_dependencies=true|feature_category=hooks|tags=network', 'network-intensive'],
     # 通配符匹配，将其余部分路由到 `default` 队列
     ['*', 'default']
   ]
   ```

   然后可以设置 `queue_groups` 来匹配这些生成的队列名称。例如：

   ```ruby
   sidekiq['queue_groups'] = [
     # 运行两个高紧急度进程
     'high-urgency',
     'high-urgency',
     # 为限流和网络密集型任务运行一个进程
     'throttled,network-intensive',
     # 在默认队列和邮件队列上运行一个“捕获所有”进程
     'default,mailers'
   ]
   ```

1. 保存文件并重新配置极狐GitLab：

   ```shell
   sudo gitlab-ctl reconfigure
   ```

<a id="worker-matching-query"></a>

## Worker 匹配查询

极狐GitLab 提供了一种查询语法，用于根据路由规则所使用的 Worker 属性来匹配 Worker。
一个查询包含两个组件：

- 可以选择的属性。
- 用于构造查询的操作符。

<a id="available-attributes"></a>

### 可用属性

队列匹配查询基于 Worker 属性工作，这些属性在极狐GitLab 开发文档的 Sidekiq 风格指南中有所描述。
我们支持基于一部分 Worker 属性进行查询：

- `feature_category` - 该队列所属的
  极狐GitLab 功能类目。例如，`merge` 队列属于
  `source_code_management` 类目。
- `has_external_dependencies` - 该队列是否连接到外部
  服务。例如，所有导入器的此属性都设置为 `true`。
- `urgency` - 该队列的任务运行速度的重要性。
  可以是 `high`、`low` 或 `throttled`。例如，
  `authorized_projects` 队列用于刷新用户权限，其紧急程度为
  `high`。
- `worker_name` - Worker 名称。使用此属性选择特定的 Worker。在下面的 [任务类列表](#list-of-available-job-classes) 中查找所有可用的名称。
- `name` - 从 Worker 名称生成的队列名称。使用此属性选择一个特定的队列。因为它是由
  Worker 名称生成的，所以它不会因其他路由
  规则的结果而改变。
- `resource_boundary` - 如果队列的边界是 `cpu`、`memory` 或
  `unknown`。例如，`ProjectExportWorker` 是内存密集型的，因为它必须
  在保存导出数据之前将数据加载到内存中。
- `tags` - 队列的短期注解。这些预计会频繁地
  在版本之间变更，并且可能会被完全移除。
- `queue_namespace` - 一些 Worker 按命名空间分组，
  `name` 前缀为 `<queue_namespace>:`。例如，对于一个 `name` 为 `cronjob:admin_email` 的队列，
  其 `queue_namespace` 是 `cronjob`。使用此属性选择一组 Worker。

`has_external_dependencies` 是一个布尔属性：只有确切的
字符串 `true` 被认为是真，其他所有情况都被认为是
假。

`tags` 是一个集合，这意味着 `=` 检查交集，而
`!=` 检查不相交集。例如，`tags=a,b` 选择具有
标签 `a`、`b` 或同时具有这两个标签的队列。`tags!=a,b` 选择
两个标签都没有的队列。

<a id="available-operators"></a>

### 可用操作符

路由规则支持以下操作符，按从高到低的
优先级列出：

- `|` - 逻辑 `OR` 操作符。例如，`query_a|query_b`（其中 `query_a`
  和 `query_b` 是由其他操作符构成的查询）包括
  匹配任一查询的队列。
- `&` - 逻辑 `AND` 操作符。例如，`query_a&query_b`（其中
  `query_a` 和 `query_b` 是由其他操作符构成的查询）
  仅包括同时匹配两个查询的队列。
- `!=` - `NOT IN` 操作符。例如，`feature_category!=issue_tracking`
  排除 `issue_tracking` 功能类目中的所有队列。
- `=` - `IN` 操作符。例如，`resource_boundary=cpu` 包括所有
  受 CPU 限制的队列。
- `,` - 连接集合操作符。例如，
  `feature_category=continuous_integration,pages` 包括
  来自 `continuous_integration` 类目或 `pages` 类目的所有队列。这个
  例子也可以使用 OR 操作符，但允许更简洁，同时
  具有更低的优先级。

此语法的操作符优先级是固定的：无法让 `AND`
具有比 `OR` 更高的优先级。

与前面记录的标准队列组语法一样，一个单一的 `*` 作为
整个队列组会选择所有队列。

<a id="test-routing-rules-in-the-rails-console"></a>

### 在 Rails 控制台中测试路由规则

你可以通过 [Rails 控制台](../operations/rails_console.md) 运行以下命令来验证哪些 Worker 匹配给定的查询：

```ruby
matcher = Gitlab::SidekiqConfig::WorkerMatcher.new("feature_category=global_search")
Gitlab::SidekiqConfig.workers
  .select { |w| matcher.match?(w.to_yaml) }
  .map(&:klass)
```

将查询字符串替换为任何有效的 Worker 匹配查询以测试不同的路由规则。

请参阅 [可用任务类列表](#list-of-available-job-classes) 以查找适合你的查询参数。

<a id="list-of-available-job-classes"></a>

### 可用任务类列表

有关现有 Sidekiq 任务类和队列的列表，请检查以下
文件：

- [所有极狐GitLab 版本的队列](https://jihulab.com/gitlab-cn/gitlab/-/blob/master/app/workers/all_queues.yml)
- [仅限极狐GitLab 企业版的队列](https://jihulab.com/gitlab-cn/gitlab/-/blob/master/ee/app/workers/all_queues.yml)