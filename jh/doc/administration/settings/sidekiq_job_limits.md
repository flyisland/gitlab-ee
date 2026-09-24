---
stage: Tenant Scale
group: Tenant Services
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
title: Sidekiq 作业大小限制
---

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: 私有化部署

{{< /details >}}

[Sidekiq](../sidekiq/_index.md) 作业存储在 Redis 中。为避免 Redis 占用过多内存，我们：

- 在将作业参数存储到 Redis 之前对其进行压缩。
- 拒绝压缩后超过指定阈值限制的作业。

前提条件：

- 管理员访问权限。

要访问 Sidekiq 作业大小限制：

1. 在右上角，选择 **管理员**。
1. 在左侧边栏中，选择 **设置** > **偏好设置**。
1. 展开 **Sidekiq 作业大小限制**。
1. 调整压缩阈值或大小限制。通过选择 **跟踪** 模式可以禁用压缩。

<a id="available-settings"></a>

## 可用设置

| 设置                                     | 默认值           | 描述                                                                                                                     |
|-------------------------------------------|------------------|---------------------------------------------------------------------------------------------------------------------------------|
| 限制模式                                 | 压缩             | 此模式在达到指定阈值时压缩作业，并在压缩后超过指定限制时拒绝作业。                                                       |
| Sidekiq 作业压缩阈值（字节）              | 100 000（100 KB）| 当参数大小超过此阈值时，会在存储到 Redis 之前对其进行压缩。                                                                  |
| Sidekiq 作业大小限制（字节）              | 0                | 压缩后超过此大小的作业将被拒绝。这可以避免 Redis 中过多的内存使用导致不稳定。将其设置为 0 可防止拒绝作业。                     |

更改这些值后，[重启 Sidekiq](../restart_gitlab.md)。