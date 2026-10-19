---
stage: Async
group: Async
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
title: 处理特定作业类
---

> [!warning]
> 这些是高级设置。虽然 JihuLab.com 上使用了这些设置，但大多数极狐GitLab
> 实例只应添加更多监听所有队列的进程。这与
> [参考架构](../reference_architectures/_index.md)中描述的方法相同。

大多数极狐GitLab 实例应让[所有进程监听所有队列](extra_sidekiq_processes.md#start-multiple-processes)。

另一种替代方案是使用[路由规则](#routing-rules)，将应用程序内的特定作业类定向到您配置的队列名称。这样，Sidekiq 进程只需监听少数已配置的队列。这样做可以降低 Redis 的负载，这在超大规模部署中非常重要。

<a id="routing-rules"></a>

## 路由规则

> [!note]
> 邮件发送器作业无法通过路由规则进行路由，它们始终进入
> `mailers` 队列。使用路由规则时，请确保至少有一个进程
> 监听 `mailers` 队列。通常可以将其与
> `default` 队列放在一起。

建议大多数极狐GitLab 实例使用路由规则来管理其 Sidekiq 队列。这允许管理员根据作业类的属性，为一组作业类选择单个队列名称。其语法是一个有序的 `[query, queue]` 对数组：

1. 查询是一个 [worker 匹配查询](#worker-matching-query)。
1. 队列名称必须是有效的 Sidekiq 队列名称。如果队列名称为
   `nil` 或空字符串，则 worker 会被路由到由
   worker 名称生成的队列。（有关更多信息，请参阅[可用作业类列表](#list-of-available-job-classes)）。
   队列名称不必与可用作业类列表中
   的任何现有队列名称匹配。
1. 为 worker 选择第一个匹配的查询；后续规则
   会被忽略。

<a id="routing-rules-migration"></a>

### 路由规则迁移

更改 Sidekiq 路由规则后，您必须谨慎进行迁移，以避免完全丢失作业，尤其是在作业队列很长的系统中。可以按照 [Sidekiq 作业迁移](sidekiq_job_migration.md)中提到的迁移步骤来完成迁移。

<a id="routing-rules-in-a-scaled-architecture"></a>

### 规模化架构中的路由规则

路由规则在所有极狐GitLab 节点（尤其是 GitLab Rails
和 Sidekiq 节点）上必须相同，因为它们是应用程序配置的一部分。

<a id="detailed-example"></a>

### 详细示例

这是一个综合性示例，旨在展示各种可能性。
[还提供了 Helm chart 示例](https://gitlab.cn/docs/charts/charts/gitlab/sidekiq/#queues)。
这些并非建议。

1. 编辑 `/etc/gitlab/gitlab.rb`：

   ```ruby
   sidekiq['routing_rules'] = [
     # Route all non-CPU-bound workers that are high urgency to `high-urgency` queue
     ['resource_boundary!=cpu&urgency=high', 'high-urgency'],
     # Route all database, gitaly and global search workers that are throttled to `throttled` queue
     ['feature_category=database,gitaly,global_search&urgency=throttled', 'throttled'],
     # Route all workers having contact with outside world to a `network-intensive` queue
     ['has_external_dependencies=true|feature_category=hooks|tags=network', 'network-intensive'],
     # Wildcard matching, route the rest to `default` queue
     ['*', 'default']
   ]
   ```

   然后可以将 `queue_groups` 设置为匹配这些生成的队列名称。例如：

   ```ruby
   sidekiq['queue_groups'] = [
     # Run two high-urgency processes
     'high-urgency',
     'high-urgency',
     # Run one process for throttled, network-intensive
     'throttled,network-intensive',
     # Run one 'catchall' process on the default and mailers queues
     'default,mailers'
   ]
   ```

1. 保存文件并重新配置极狐GitLab：

   ```shell
   sudo gitlab-ctl reconfigure
   ```

<a id="worker-matching-query"></a>

## Worker 匹配查询

极狐GitLab 提供了一种查询语法，供路由规则使用，以根据 worker 的属性匹配 worker。查询包含两个组成部分：

- 可选择的属性。
- 用于构造查询的运算符。

<a id="available-attributes"></a>

### 可用属性

队列匹配查询基于 worker 属性工作，这些属性在极狐GitLab 开发文档的 Sidekiq 风格指南中有所描述。支持基于 worker 属性子集的查询：

- `feature_category` - 队列所属的
  极狐GitLab 功能类别。例如，`merge` 队列属于
  `source_code_management` 类别。
- `has_external_dependencies` - 队列是否连接到外部
  服务。例如，所有导入器都将此项设置为 `true`。
- `urgency` - 该队列的作业需要多快
  运行。可以是 `high`、`low` 或 `throttled`。例如，
  `authorized_projects` 队列用于刷新用户权限，
  其紧急程度为 `high`。
- `worker_name` - worker 名称。使用此属性选择特定的 worker。可在下方的[作业类列表](#list-of-available-job-classes)中找到所有可用名称。
- `name` - 由 worker 名称生成的队列名称。使用此属性选择特定的队列。由于它是由
  worker 名称生成的，因此不会根据其他路由
  规则的结果而变化。
- `resource_boundary` - 队列是否受 `cpu`、`memory` 或
  `unknown` 限制。例如，`ProjectExportWorker` 受内存限制，因为它
  必须在保存数据以供导出之前在内存中加载数据。
- `tags` - 队列的短期注解。这些注解预计会随着
  版本发布而频繁变化，并且可能会被完全移除。
- `queue_namespace` - 一些 worker 按命名空间分组，
  `name` 会带有 `<queue_namespace>:` 前缀。例如，对于 `name` 为 `cronjob:admin_email`的队列，
  `queue_namespace` 为 `cronjob`。使用此属性选择一组 worker。

`has_external_dependencies` 是布尔属性：只有确切的字符串 `true` 才被视为 true，其他所有内容都被视为
false。

`tags` 是一个集合，这意味着 `=` 检查相交集合，而 `!=` 检查不相交集合。例如，`tags=a,b` 选择具有标记 `a`、`b` 或两者兼有的队列。`tags!=a,b` 选择不具有这些标记中任何一个的队列。

<a id="available-operators"></a>

### 可用运算符

路由规则支持以下运算符，按优先级从高到低列出：

- `|` - 逻辑 `OR` 运算符。例如，`query_a|query_b`（其中 `query_a`
  和 `query_b` 是此处其他运算符构成的查询）包括
  匹配任一查询的队列。
- `&` - 逻辑 `AND` 运算符。例如，`query_a&query_b`（其中
  `query_a` 和 `query_b` 是此处其他运算符构成的查询）
  仅包括同时匹配两个查询的队列。
- `!=` - `NOT IN` 运算符。例如，`feature_category!=issue_tracking`
  排除 `issue_tracking` 功能类别中的所有队列。
- `=` - `IN` 运算符。例如，`resource_boundary=cpu` 包括所有
  受 CPU 限制的队列。
- `,` - 连接集合运算符。例如，
  `feature_category=continuous_integration,pages` 包括来自
  `continuous_integration` 类别或 `pages` 类别的所有队列。此
  示例也可以使用 OR 运算符实现，但这样更简洁，
  而且优先级更低。

此语法的运算符优先级是固定的：无法让 `AND`的优先级高于 `OR`。

与前面记录的标准队列组语法一样，将整个队列组设为单个 `*` 会选择所有队列。

<a id="test-routing-rules-in-the-rails-console"></a>

### 在 Rails 控制台中测试路由规则

您可以通过在 [Rails 控制台](../operations/rails_console.md)中运行以下命令，来验证哪些 worker 匹配给定的查询：

```ruby
matcher = Gitlab::SidekiqConfig::WorkerMatcher.new("feature_category=global_search")
Gitlab::SidekiqConfig.workers
  .select { |w| matcher.match?(w.to_yaml) }
  .map(&:klass)
```

将查询字符串替换为任何有效的 worker 匹配查询，以测试不同的路由规则。

请参阅[可用作业类列表](#list-of-available-job-classes)，找到适合您的查询参数。

<a id="list-of-available-job-classes"></a>

### 可用作业类列表

有关现有 Sidekiq 作业类和队列的列表，请查看以下文件：

- [所有极狐GitLab 版本的队列](https://jihulab.com/gitlab-cn/gitlab/-/blob/master/app/workers/all_queues.yml)
- [仅极狐GitLab 企业版的队列](https://jihulab.com/gitlab-cn/gitlab/-/blob/master/ee/app/workers/all_queues.yml)
