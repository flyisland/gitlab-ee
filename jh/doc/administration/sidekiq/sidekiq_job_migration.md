---
stage: Tenant Scale
group: Tenant Services
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
title: Sidekiq 作业迁移 Rake 任务
---

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: 私有化部署

{{< /details >}}

> [!warning]
> 此操作应该非常罕见。我们不建议绝大多数极狐GitLab 实例使用。

Sidekiq 路由规则允许管理员将某些后台作业从其常规队列重新路由到备用队列。默认情况下，极狐GitLab 为每种后台作业类型使用一个队列。极狐GitLab 有超过 400 种后台作业类型，因此相应的有超过 400 个队列。

大多数管理员不需要更改此设置。在某些情况下，由于后台作业处理工作负载特别大，Redis 性能可能会因为极狐GitLab 监听的队列数量而受到影响。

如果更改了 Sidekiq 路由规则，管理员应谨慎迁移以避免完全丢失作业。基本迁移步骤如下：

1. 同时监听旧队列和新队列。
1. 更新路由规则。
1. [重新配置极狐GitLab](../restart_gitlab.md#reconfigure-a-linux-package-installation) 以使更改生效。
1. 运行[用于迁移队列中和未来作业的 Rake 任务](#migrate-queued-and-future-jobs)。
1. 停止监听旧队列。

<a id="migrate-queued-and-future-jobs"></a>

## 迁移队列中和未来作业

步骤 4 涉及重写一些已经存储在 Redis 中但将在未来运行的作业的 Sidekiq 作业数据。将在未来运行的两组作业是：计划作业和要重试的作业。我们提供了单独的 Rake 任务来迁移每组：

- `gitlab:sidekiq:migrate_jobs:retry` 用于要重试的作业。
- `gitlab:sidekiq:migrate_jobs:schedule` 用于计划作业。

尚未运行的队列作业也可以使用 Rake 任务迁移（[在极狐GitLab 15.6 中可用](https://jihulab.com/gitlab-cn/gitlab/-/merge_requests/101348)及更高版本）：

- `gitlab:sidekiq:migrate_jobs:queued` 用于异步执行的队列作业。

大多数情况下，同时运行所有三个任务是正确的选择。三个独立的任务允许在需要时进行更精细的控制。要一次性运行所有三个任务（[在极狐GitLab 15.6 中可用](https://jihulab.com/gitlab-cn/gitlab/-/merge_requests/101348)及更高版本）：

```shell
# Omnibus 极狐GitLab
sudo gitlab-rake gitlab:sidekiq:migrate_jobs:retry gitlab:sidekiq:migrate_jobs:schedule gitlab:sidekiq:migrate_jobs:queued

# 源码安装
bundle exec rake gitlab:sidekiq:migrate_jobs:retry gitlab:sidekiq:migrate_jobs:schedule gitlab:sidekiq:migrate_jobs:queued RAILS_ENV=production
```