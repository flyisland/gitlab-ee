---
stage: Tenant Scale
group: Gitaly
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
title: Kubernetes 上的 Gitaly
---

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: JihuLab.com，私有化部署

{{< /details >}}

在 Kubernetes 上运行 Gitaly 存在可用性方面的权衡，因此在规划生产环境时需要考虑这些权衡，并相应地设定预期。本文档介绍如何将这些限制降至最低并为其做好规划，同时提供相关指导。

Gitaly 团队已对 Kubernetes 上的 Gitaly 进行评估，并确定这是一种安全的
Gitaly 部署方式。本文档的其余部分详细介绍了相关最佳实践。

<a id="timeline"></a>

## 时间线

自极狐GitLab 18.11 起，Kubernetes 上的 Gitaly 已正式发布。极狐GitLab 不
保证与云提供商提供的特定托管 Kubernetes 服务（例如 Amazon EKS、Google GKE 或 Azure AKS）兼容。在部署到生产环境之前，您应验证
您的具体环境。

<a id="context"></a>

## 背景

按照设计，Gitaly（非集群）是单点故障服务（SPoF）。数据从单个实例获取并提供。对于 Kubernetes，当 StatefulSet pod 轮换时（例如在升级、节点维护或驱逐期间），轮换会导致该 pod 或实例所提供的数据出现服务中断。

在 [Cloud Native Hybrid](../reference_architectures/1k_users.md#cloud-native-hybrid-reference-architecture-with-helm-charts) 设置（Gitaly 虚拟机）中，Linux 软件包（Omnibus）
通过以下方式掩盖了该问题：

1. 就地升级 Gitaly 二进制文件。
1. 执行优雅重载。

同样的方法不适用于基于容器的生命周期，因为容器或 pod 需要完全关闭并作为新的容器或 pod 启动。

为支持 Cloud Native 部署，Gitaly（非集群）是唯一正式发布的选项。Kubernetes 上的 [Gitaly 集群（Praefect）](praefect/_index.md#gitaly-cluster-on-kubernetes)处于测试版。
通过利用合适的 Kubernetes 和 Gitaly 功能及配置，您可以最大限度地减少服务中断并提供良好的用户体验。

<a id="requirements"></a>

## 要求

本页信息假设：

- Kubernetes 版本等于或大于 `1.29`。
- Kubernetes 节点 `runc` 版本等于或大于 `1.1.9`。
- Kubernetes 节点使用 cgroup v2。不支持原生、混合 v1 模式。仅支持
  [`systemd` 风格的 cgroup 结构](https://kubernetes.io/docs/setup/production-environment/container-runtimes/#systemd-cgroup-driver)（Kubernetes 默认）。
- Pod 可访问节点挂载点 `/sys/fs/cgroup`。
- containerd 版本为 2.1.0 或更高。
- Pod 初始化容器（`init-cgroups`）对 `/sys/fs/cgroup` 具有 `root` 用户文件系统权限。用于将 pod cgroup 委托给 Gitaly 容器
  （用户 `git`，UID `1000`）。
- cgroups 文件系统未使用 `nsdelegate` 标志挂载。更多信息，请参见 Gitaly 议题 [6480](https://gitlab.com/gitlab-org/gitaly/-/issues/6480)。

<a id="guidance"></a>

## 指导

在 Kubernetes 中运行 Gitaly 时，您必须：

- [处理 pod 中断](#address-pod-disruption)。
- [处理资源争用和饱和](#address-resource-contention-and-saturation)。
- [优化 pod 轮换时间](#optimize-pod-rotation-time)。
- [监控磁盘使用情况](#monitor-disk-usage)

<a id="enable-cgroup_writable-field-in-containerd"></a>

### 在 containerd 中启用 `cgroup_writable` 字段

Gitaly 中的 cgroup 支持要求非特权容器对 cgroups 具有可写访问权限。containerd v2.1.0 引入了 `cgroup_writable` 配置选项。启用后，该选项可确保 cgroups 文件系统以读写权限挂载。

要启用此字段，请在将部署 Gitaly 的节点上执行以下步骤。如果 Gitaly 已部署，则必须在修改配置后重新创建 pod。

1. 修改位于 `/etc/containerd/config.toml`的 containerd 配置文件，以包含 `cgroup_writable` 字段：

   ```toml
   [plugins."io.containerd.grpc.v1.cri".containerd.runtimes.runc]
   runtime_type = "io.containerd.runc.v2"
   cgroup_writable = true
   ```

1. 重启 Kubelet 和 containerd 服务：

   ```shell
   sudo systemctl restart kubelet
   sudo systemctl restart containerd
   ```

   如果这些服务重启耗时较长，这些命令可能会将节点标记为 NotReady。

<a id="address-pod-disruption"></a>

### 处理 pod 中断

pod 可能因多种原因轮换。了解并规划服务生命周期有助于最大限度地减少中断。

例如，对于 Gitaly，Kubernetes `StatefulSet` 会在 `spec.template` 对象发生变化时轮换，这可能发生在 Helm Chart 升级（标签或镜像标签）或 pod 资源请求或限制更新期间。

本节重点介绍常见的 pod 中断情况以及如何处理它们。

<a id="schedule-maintenance-windows"></a>

#### 安排维护窗口

由于该服务不是高可用的，某些操作可能会导致短暂的服务中断。安排维护窗口可以表明可能发生服务中断，并有助于设定预期。您应在以下情况下使用维护窗口：

- GitLab Helm chart 升级和重新配置。
- Gitaly 配置变更。
- Kubernetes 节点维护窗口。例如升级和打补丁。将 Gitaly 隔离到其专用的节点池可能会有所帮助。

<a id="use-priorityclass"></a>

#### 使用 `PriorityClass`

使用 [PriorityClass](https://kubernetes.io/docs/concepts/scheduling-eviction/pod-priority-preemption/#priorityclass) 为 Gitaly pod 分配比其他 pod 更高的优先级，以帮助应对节点饱和压力、驱逐优先级和调度延迟：

1. 创建优先级类：

   ```yaml
   apiVersion: scheduling.k8s.io/v1
   kind: PriorityClass
   metadata:
     name: gitlab-gitaly
   value: 1000000
   globalDefault: false
   description: "GitLab Gitaly priority class"
   ```

1. 将优先级类分配给 Gitaly pod：

   ```yaml
   gitlab:
     gitaly:
       priorityClassName: gitlab-gitaly
   ```

<a id="signal-node-autoscaling-to-prevent-eviction"></a>

#### 向节点自动扩缩发出信号以防止驱逐

节点自动扩缩工具会根据需要添加和移除 Kubernetes 节点，以调度 pod 并优化成本。

在缩容事件期间，Gitaly pod 可能会被驱逐以优化资源使用。通常可以使用注解来控制此行为并
排除工作负载。例如，使用 Cluster Autoscaler 时：

```yaml
gitlab:
  gitaly:
    annotations:
      cluster-autoscaler.kubernetes.io/safe-to-evict: "false"
```

<a id="address-resource-contention-and-saturation"></a>

### 处理资源争用和饱和

由于 Git 操作的不确定性，Gitaly 服务的资源使用情况可能难以预测。并非所有代码仓库都相同，大小会严重影响性能和资源使用，尤其是对于[单一代码仓库](../../user/project/repository/monorepos/_index.md)。

在 Kubernetes 中，不受控制的资源使用可能导致内存不足（OOM）事件，这会迫使平台终止 pod 并终止其所有进程。Pod 终止会引发两个重要问题：

- 数据/代码仓库损坏
- 服务中断

本节重点介绍缩小影响范围并保护整个服务。

<a id="constrain-git-processes-resource-usage"></a>

#### 限制 Git 进程的资源使用

隔离 Git 进程可以确保单次 Git 调用不会消耗所有服务和 pod 资源，从而提供安全性。

Gitaly 可以使用 Linux [控制组（cgroups）](cgroups.md)对每个代码仓库施加更小的资源使用配额。

您应将 cgroup 配额保持在整体 pod 资源分配之下。CPU 并不关键，因为它只会减慢服务速度。但是，内存饱和可能导致 pod 终止。在 pod 请求与 Git cgroup 分配之间保留 1 GiB 内存缓冲区是一个安全的起点。缓冲区的大小取决于流量模式和代码仓库数据。

例如，当 pod 内存请求为 15 GiB 时，为 Git 调用分配 14 GiB：

```yaml
gitlab:
  gitaly:
    cgroups:
      enabled: true
      # Total limit across all repository cgroups, excludes Gitaly process
      memoryBytes: 15032385536 # 14GiB
      cpuShares: 1024
      cpuQuotaUs: 400000 # 4 cores
      # Per repository limits, 50 repository cgroups
      repositories:
        count: 50
        memoryBytes: 7516192768 # 7GiB
        cpuShares: 512
        cpuQuotaUs: 200000 # 2 cores
```

更多信息，请参见 [Gitaly 配置文档](configure_gitaly.md#control-groups)。

<a id="right-size-pod-resources"></a>

#### 合理设置 Pod 资源大小

设置 Gitaly pod 的大小至关重要，[参考架构](../reference_architectures/_index.md#cloud-native-hybrid)提供了一些指导作为起点。但是，不同的代码仓库和使用模式会消耗不同程度的资源。您应监控资源使用情况并随时间相应调整。

内存是 Kubernetes 中最敏感的资源，因为内存耗尽可能触发 pod 终止。[使用 cgroups 隔离 Git 调用](#constrain-git-processes-resource-usage)有助于限制代码仓库操作的资源使用，但这不包括 Gitaly 服务本身。根据之前关于 cgroup 配额的建议，在整体 Git cgroup 内存分配与 pod 内存请求之间添加缓冲区以提高安全性。

pod 的 `Guaranteed` [服务质量](https://kubernetes.io/docs/tasks/configure-pod-container/quality-service-pod/)类别是首选（资源请求与限制相匹配）。使用此设置，pod 更不易受到资源争用的影响，并保证绝不会因其他 pod 的消耗而被驱逐。

资源配置示例：

```yaml
gitlab:
  gitaly:
    resources:
      requests:
        cpu: 4000m
        memory: 15Gi
      limits:
        cpu: 4000m
        memory: 15Gi

    init:
      resources:
        requests:
          cpu: 50m
          memory: 32Mi
        limits:
          cpu: 50m
          memory: 32Mi
```

<a id="configure-concurrency-limiting"></a>

#### 配置并发限制

您可以使用并发限制来帮助保护服务免受异常流量模式的影响。更多信息，请参见[并发配置文档](concurrency_limiting.md)和[如何监控限制](monitoring.md#monitor-gitaly-concurrency-limiting)。

<a id="isolate-gitaly-pods"></a>

#### 隔离 Gitaly pod

当运行多个 Gitaly pod 时，您应将它们调度到不同的节点以分散故障域。可以使用 pod 反亲和性来强制执行此操作。例如：

```yaml
gitlab:
  gitaly:
    antiAffinity: hard
```

<a id="optimize-pod-rotation-time"></a>

### 优化 pod 轮换时间

本节介绍优化领域，通过缩短 pod 开始提供流量所需的时间，来减少维护事件或计划外基础设施事件期间的停机时间。

<a id="persistent-volume-permissions"></a>

#### 持久卷权限

随着数据量增长（Git 历史记录和更多代码仓库），pod 启动并准备就绪所需的时间越来越长。

在 pod 初始化期间，作为持久卷挂载的一部分，文件系统权限和所有权会显式设置为容器的 `uid` 和 `gid`。此操作默认运行，可能会显著减慢 pod 启动时间，因为存储的 Git 数据包含许多小文件。

此行为可通过
[`fsGroupChangePolicy`](https://kubernetes.io/docs/tasks/configure-pod-container/security-context/#configure-volume-permission-and-ownership-change-policy-for-pods)
属性进行配置。使用此属性仅在卷根目录的 `uid` 或 `gid` 与容器规范不匹配时执行该操作：

```yaml
gitlab:
  gitaly:
    securityContext:
      fsGroupChangePolicy: OnRootMismatch
```

<a id="health-probes"></a>

#### 健康探针

Gitaly pod 在就绪探针成功后开始提供流量。默认探针时间较为保守，以覆盖大多数用例。减小 `readinessProbe`的 `initialDelaySeconds` 属性可更早触发探针，从而加快 pod 就绪。例如：

```yaml
gitlab:
  gitaly:
    statefulset:
      readinessProbe:
        initialDelaySeconds: 2
        periodSeconds: 10
        timeoutSeconds: 3
        successThreshold: 1
        failureThreshold: 3
```

<a id="gitaly-graceful-shutdown-timeout"></a>

#### Gitaly 优雅关闭超时

默认情况下，终止时，Gitaly 为进行中的请求授予 1 分钟的超时时间以完成。虽然乍看之下这很有益，但此超时：

- 会减慢 pod 轮换。
- 会因在关闭过程中拒绝请求而降低可用性。

在基于容器的部署中，更好的方法是依赖客户端重试逻辑。您可以使用 `gracefulRestartTimeout` 字段重新配置超时。例如，要授予 1 秒的优雅超时：

```yaml
gitlab:
  gitaly:
    gracefulRestartTimeout: 1
```

<a id="monitor-disk-usage"></a>

### 监控磁盘使用情况

对于长时间运行的 Gitaly 容器，请定期监控磁盘使用情况，因为如果[未启用日志轮转](https://gitlab.cn/docs/charts/charts/globals/#log-rotation)，日志文件增长可能导致存储问题。

<a id="migrate-to-gitaly-on-kubernetes"></a>

## 迁移到 Kubernetes 上的 Gitaly

要将现有代码仓库从非 Kubernetes 的 Gitaly 节点迁移到 Kubernetes 上的 Gitaly：

1. 将 Gitaly 部署到 Kubernetes 节点上，并在极狐GitLab 管理区域中[将它们添加为新的代码仓库存储](../repository_storage_paths.md#configure-where-new-repositories-are-stored)。
   配置存储权重，使所有新代码仓库都创建在新的代码仓库存储上。
   这可防止在迁移进行期间在旧代码仓库存储上创建新项目。
1. 使用代码仓库移动 API 将现有代码仓库移动到新存储。
   极狐GitLab 代码仓库可以与项目、群组和代码片段关联，每种类型都有单独的 API。
   完整说明，请参见[移动由极狐GitLab 管理的代码仓库](../operations/moving_repositories.md)。

在移动期间，每个代码仓库都会变为只读，直到移动完成前都不可写入。
