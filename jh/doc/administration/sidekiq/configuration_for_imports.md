---
stage: GitLab Dedicated
group: Import
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
title: 用于导入的 Sidekiq 配置
description: 优化 Sidekiq 配置，以便导入或迁移到极狐GitLab。
---

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: 私有化部署

{{< /details >}}

导入器高度依赖 Sidekiq 作业来处理群组和项目的导入与导出。其中一些作业可能会消耗大量资源（CPU 和内存），并且需要很长时间才能完成，这可能会影响其他作业的执行。

要解决此问题，您应将导入器作业路由到专用的 Sidekiq 队列，并分配一个专用的 Sidekiq 进程来处理该队列。

例如，您可以使用以下配置：

```conf
sidekiq['concurrency'] = 20

sidekiq['routing_rules'] = [
  # Route import and export jobs to the importer queue
  ['feature_category=importers', 'importers'],

  # Route all other jobs to the default queue by using wildcard matching
  ['*', 'default']
]

sidekiq['queue_groups'] = [
  # Run a dedicated process for the importer queue
  'importers',

  # Run a separate process for the default and mailer queues
  'default,mailers'
]
```

在此设置中：

- 一个专用的 Sidekiq 进程通过导入器队列处理导入和导出作业。
- 另一个 Sidekiq 进程处理所有其他作业（默认队列和邮件队列）。
- 两个 Sidekiq 进程默认都配置为以 20 个并发线程运行。
  对于内存受限的环境，您可能需要减少此数量。

<a id="configure-additional-processes"></a>

## 配置其他进程

如果您的实例有足够的资源来支持更多并发作业，您可以配置其他 Sidekiq 进程来加速迁移。

关于 Sidekiq 进程的最大数量，请注意以下几点：

- 进程数不应超过可用的 CPU 核心数。
- 每个进程最多可使用 2 GB 内存，因此请确保实例
  有足够的内存来运行任何其他进程。
- 每个进程会按 `sidekiq['concurrency']` 中定义的
  每个线程增加一个数据库连接。

例如：

```conf
sidekiq['queue_groups'] = [
  # Run three processes for importer jobs
  'importers',
  'importers',
  'importers',

  # Run a separate process for the default and mailer queues
  'default,mailers'
]
```

在此设置中，多个 Sidekiq 进程会并发处理导入和导出作业，只要实例有足够的资源，就能加速迁移。
