---
stage: GitLab Dedicated
group: Geo
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
gitlab_dedicated: no
title: Geo 调优
---

{{< details >}}

- Tier: 专业版，旗舰版
- Offering: 私有化部署

{{< /details >}}

您可以限制站点可在后台运行的并发操作数量。

<a id="changing-the-syncverification-concurrency-values"></a>

## 更改同步/验证并发值

在主站点上：

1. 在右上角，选择**管理员**。
1. 在左侧边栏中，选择 **Geo** > **站点**。
1. 选择您要调优的从站点的**编辑**。
1. 在**调优设置**下，有多个变量可用于调优，以提升 Geo 的性能：

   - 代码仓库同步并发限制
   - 文件同步并发限制
   - 容器仓库同步并发限制
   - 验证并发限制

提高并发值会增加调度的作业数量。但是，除非同时增加可用的 Sidekiq 线程数，否则这未必会带来更多并行下载。例如，如果将代码仓库同步并发数从 25 提高到 50，您可能还需要将 Sidekiq 线程数从 25 增加到 50。有关更多详细信息，请参阅
[Sidekiq 并发文档](../../sidekiq/extra_sidekiq_processes.md#concurrency)。

> [!note]
> **验证并发限制**是站点上所有数据类型合计的并发验证作业总数的单一全局限制。有效并发数等于您配置的值。
>
> 在极狐GitLab 19.2 及更早版本中，极狐GitLab 会先将配置值除以数据类型数量再应用，因此有效并发数低于您设置的值。当您升级到极狐GitLab 19.3 时，极狐GitLab 会重新调整每个站点存储的值，使有效并发数大致与升级前保持一致。因此，升级后存储的值可能会更低。请根据需要检查并重新调优。

<a id="tuning-low-default-settings"></a>

## 调优较低的默认设置

为避免在设置新 Geo 站点时产生过高负载，从极狐GitLab 18.0 开始，Geo 的并发设置对大多数环境都设为较低的默认值。要提高这些设置：

1. 在右上角，选择**管理员**。
1. 在左侧边栏中，选择 **Geo** > **站点**。
1. 确定哪些数据类型进展过慢。
1. 观察主站点和从站点的负载指标。
1. 保守起见，将并发限制提高 10。
1. 观察进度变化和负载指标至少 3 分钟。
1. 重复提高限制，直到负载指标达到您期望的最大值，或者同步和验证的进展速度达到您期望的水平。

<a id="reduce-the-amount-of-replicated-data"></a>

## 减少复制的数据量

主站点上保留的每个文件都必须在每个从站点上存储、同步和验证，并由 Geo 指标收集进行统计。删除没有价值的数据通常比提高并发更有效，而且当您添加或重建从站点时，还能缩短初始同步时间。

CI/CD 作业产物通常是最大的贡献者。要减少其数量：

- 确保产物会过期。产物会在
  [默认产物过期时间](../../settings/continuous_integration.md#set-default-artifacts-expiration)
  （默认为 30 天）之后，或在通过
  [`artifacts:expire_in`](../../../ci/yaml/_index.md#artifactsexpire_in)
  为每个作业设置的时长之后自动删除。
  当产物过期时，极狐GitLab 会永久删除该文件及其数据库记录，并发布 Geo 删除事件，以便每个从站点移除其已同步的副本及其注册表条目。更小的表会直接减少同步、验证和
  [Geo 指标收集](troubleshooting/common.md#excessive-database-io-from-geo-metrics-collection)
  的负载。
- 检查
  [保留最近成功流水线的产物设置](../../settings/continuous_integration.md#keep-artifacts-from-latest-successful-pipelines)。
  启用后，每个 Git ref 最近一次成功流水线的产物将永不过期。在具有许多活跃分支和标签的实例上，此设置可能会无限期地保留大量产物。
- 清理没有过期时间的产物。在过期策略实施之前创建的产物没有过期日期，过期处理工作进程永远不会删除它们。要查找并移除它们，请参阅
  [列出具有特定过期时间（或无过期时间）的产物的项目和构建](../../cicd/job_artifacts_troubleshooting.md#list-projects-and-builds-with-artifacts-with-a-specific-expiration-or-no-expiration)
  和
  [删除旧的构建和产物](../../cicd/job_artifacts_troubleshooting.md#delete-old-builds-and-artifacts)。
  要移除磁盘上遗留的、没有数据库记录的产物文件，请使用
  [孤立产物文件清理 Rake 任务](../../raketasks/cleanup.md#remove-orphan-artifact-files)。

同样的原则也适用于其他复制的数据类型，例如 LFS 对象和软件包文件。对于容器镜像仓库中的镜像，请使用[清理策略](../../../user/packages/container_registry/reduce_container_registry_storage.md#cleanup-policy)。

<a id="repository-re-verification"></a>

## 代码仓库重新验证

请参阅[自动后台验证](../disaster_recovery/background_verification.md)。
