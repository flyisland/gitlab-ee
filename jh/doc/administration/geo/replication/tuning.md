---
stage: Tenant Scale
group: Geo
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
gitlab_dedicated: no
title: 调整 Geo
---

{{< details >}}

- Tier: 专业版，旗舰版
- Offering: 私有化部署

{{< /details >}}

您可以限制站点在后台可运行的并发操作数量。

<a id="changing-the-sync-verification-concurrency-values"></a>

## 更改同步/验证并发值

在主站点上：

1. 在右上角，选择 **管理员**。
1. 在左侧边栏，选择 **Geo** > **站点**。
1. 选择您要调整的次要站点的 **编辑**。
1. 在 **调整设置** 下，有几个可以调整的变量，以提升 Geo 的性能：

   - 仓库同步并发限制
   - 文件同步并发限制
   - 容器镜像仓库同步并发限制
   - 验证并发限制

增加并发值会增加计划执行的作业数量。
但是，除非同时增加可用的 Sidekiq 线程数，否则这不一定能导致更多并行下载。例如，如果仓库同步并发数从 25 增加到 50，您可能还需要将 Sidekiq 线程数从 25 增加到 50。更多详情，请参见
[Sidekiq 并发文档](../../sidekiq/extra_sidekiq_processes.md#concurrency)。

<a id="tuning-low-default-settings"></a>

## 调整较低的默认设置

为避免在设置新的 Geo 站点时产生过多负载，从极狐GitLab 18.0 开始，Geo 的并发设置对于大多数环境都设置为较低的默认值。
要增加这些设置：

1. 在右上角，选择 **管理员**。
1. 在左侧边栏，选择 **Geo** > **站点**。
1. 确定哪些数据类型进展太慢。
1. 观察主站点和次要站点的负载指标。
1. 为保守起见，将并发限制增加 10。
1. 观察进度和负载指标的变化至少 3 分钟。
1. 重复增加限制，直到负载指标达到您期望的最大值，或同步和验证的进展速度符合预期。

<a id="repository-re-verification"></a>

## 仓库重新验证

请参阅
[自动后台验证](../disaster_recovery/background_verification.md)。