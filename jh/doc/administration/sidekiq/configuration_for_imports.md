---
stage: Create
group: Import
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.jihulab.com/handbook/product/ux/technical-writing/#assignments>
title: 用于导入的 Sidekiq 配置
description: 优化 Sidekiq 配置，以便导入或迁移至极狐GitLab。
---

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: 私有化部署

{{< /details >}}

导入器严重依赖 Sidekiq 作业来处理群组和项目的导入导出。这些作业中的一部分可能会消耗大量资源（CPU 和内存），并且需要很长时间才能完成，这可能会影响其他作业的执行。

要解决此问题，你应当将导入器作业路由到专用的 Sidekiq 队列，并分配一个专用的 Sidekiq 进程来处理该队列。

例如，你可以使用以下配置：

```conf
sidekiq['concurrency'] = 20

sidekiq['routing_rules'] = [
  # 将导入和导出作业路由到导入器队列
  ['feature_category=importers', 'importers'],

  # 使用通配符匹配将所有其他作业路由到默认队列
  ['*', 'default']
]

sidekiq['queue_groups'] = [
  # 为导入器队列运行一个专用进程
  'importers',

  # 为默认队列和邮件队列运行一个单独的进程
  'default,mailers'
]
```

在此设置中：

- 一个专用 Sidekiq 进程通过导入器队列处理导入和导出作业。
- 另一个 Sidekiq 进程处理所有其他作业（默认队列和邮件队列）。
- 两个 Sidekiq 进程默认配置为使用 20 个并发线程运行。对于内存受限的环境，你可能希望减少此数字。

<a id="configure-additional-processes"></a>

## 配置额外的进程

如果你的实例有足够的资源来支持更多并发作业，你可以配置额外的 Sidekiq 进程来加快迁移速度。

在确定最大 Sidekiq 进程数时，请牢记以下几点：

- 进程数不应超过可用的 CPU 核心数。
- 每个进程最多可使用 2 GB 内存，因此请确保实例有足够的内存来支持任何额外的进程。
- 每个进程会根据 `sidekiq['concurrency']` 中定义的每个线程添加一个数据库连接。

例如：

```conf
sidekiq['queue_groups'] = [
  # 运行三个进程处理导入器作业
  'importers',
  'importers',
  'importers',

  # 为默认队列和邮件队列运行一个单独的进程
  'default,mailers'
]
```

使用此设置，多个 Sidekiq 进程会并发处理导入和导出作业，只要实例具有足够的资源，就能加快迁移速度。