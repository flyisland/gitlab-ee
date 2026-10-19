---
stage: Async
group: Async
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
title: Sidekiq 作业迁移 Rake 任务
---

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: 私有化部署

{{< /details >}}

> [!warning]
> 此操作应极为罕见。对于绝大多数极狐GitLab 实例，我们不推荐这样做。

Sidekiq 路由规则允许管理员将某些后台作业从其常规队列重新路由到其他队列。默认情况下，极狐GitLab 为每种后台作业类型使用一个队列。极狐GitLab 有 400 多种后台作业类型，因此相应地有 400 多个队列。

大多数管理员无需更改此设置。在某些后台作业处理负载特别大的情况下，由于极狐GitLab 监听的队列数量过多，Redis 性能可能会受到影响。

如果更改了 Sidekiq 路由规则，管理员在迁移时应谨慎，以免完全丢失作业。基本的迁移步骤如下：

1. 同时监听旧队列和新队列。
1. 更新路由规则。
1. [重新配置极狐GitLab](../restart_gitlab.md#reconfigure-a-linux-package-installation) 以使更改生效。
1. 运行[用于迁移已排队作业和未来作业的 Rake 任务](#migrate-queued-and-future-jobs)。
1. 停止监听旧队列。

<a id="migrate-queued-and-future-jobs"></a>

## 迁移已排队作业和未来作业

第 4 步涉及为已存储在 Redis 中、但计划在未来运行的作业重写部分 Sidekiq 作业数据。计划在未来运行的两类作业分别是计划作业和待重试作业。我们为每一类作业提供了单独的 Rake 任务进行迁移：

- `gitlab:sidekiq:migrate_jobs:retry` 用于待重试作业。
- `gitlab:sidekiq:migrate_jobs:schedule` 用于计划作业。

尚未运行的已排队作业也可以通过 Rake 任务进行迁移：

- `gitlab:sidekiq:migrate_jobs:queued` 用于异步执行的已排队作业。

大多数情况下，同时运行这三个任务是正确的选择。三个独立任务可在需要时提供更细粒度的控制。要同时运行这三个任务：

```shell
# omnibus-gitlab
sudo gitlab-rake gitlab:sidekiq:migrate_jobs:retry gitlab:sidekiq:migrate_jobs:schedule gitlab:sidekiq:migrate_jobs:queued

# source installations
bundle exec rake gitlab:sidekiq:migrate_jobs:retry gitlab:sidekiq:migrate_jobs:schedule gitlab:sidekiq:migrate_jobs:queued RAILS_ENV=production
```
