---
stage: Tenant Scale
group: Tenant Services
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
title: Sidekiq 后台作业
---

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: 私有化部署

{{< /details >}}

配置 Sidekiq 作业大小限制，以及用于评估 cron 作业计划的时区。

先决条件：

- 管理员访问权限。

要访问这些设置：

1. 在右上角，选择 **管理员**。
1. 在左侧边栏中，选择 **设置** > **偏好设置**。
1. 展开 **Sidekiq 后台作业**。

<a id="job-size-limits"></a>

## 作业大小限制

[Sidekiq](../sidekiq/_index.md) 将作业存储在 Redis 中。为避免 Redis 内存使用过多，极狐GitLab：

- 在将作业参数存储到 Redis 之前对其进行压缩。
- 拒绝压缩后超过指定阈值限制的作业。

要调整压缩阈值或大小限制，请更新相应值。要禁用压缩，请选择 **跟踪** 模式。

<a id="available-settings"></a>

### 可用设置

| 设置                                   | 默认值          | 描述                                                                                                                                                                   |
|-------------------------------------------|------------------|-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| 限制模式                             | 压缩         | 此模式在达到指定阈值时压缩作业，并在压缩后超过指定限制时拒绝这些作业。                                               |
| Sidekiq 作业压缩阈值（字节） | 100 000 (100 KB) | 当参数大小超过此阈值时，参数会在存储到 Redis 之前被压缩。                                                                          |
| Sidekiq 作业大小限制（字节）            | 0                | 压缩后超过此大小的作业将被拒绝。这可以避免 Redis 内存使用过多导致不稳定。将其设置为 0 可防止拒绝作业。     |

更改这些值后，[重启 Sidekiq](../restart_gitlab.md)。

<a id="cron-jobs-time-zone"></a>

## Cron 作业时区

默认情况下，极狐GitLab 在实例时区（除非另行配置，否则为 UTC）中评估 cron 作业计划。要在其他时区运行 cron 作业，请设置时区覆盖。

要设置时区：

1. 从 **Cron 作业时区** 下拉列表中，选择一个时区，或选择 **系统默认** 以使用实例时区。

更改此值后，[重启 Sidekiq](../restart_gitlab.md)。
