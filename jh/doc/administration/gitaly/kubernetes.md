---
stage: Tenant Scale
group: Gitaly
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
title: 在 Kubernetes 上运行 Gitaly
---

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: JihuLab.com，私有化部署

{{< /details >}}

{{< history >}}

- 在极狐GitLab 17.3 中作为[实验阶段](../../policy/development_stages_support.md)引入。
- 在极狐GitLab 17.10 中从实验阶段更改为测试阶段。
- 在极狐GitLab 18.2 中从测试阶段更改为有限可用。
- 在极狐GitLab 18.11 中从有限可用更改为 GA。

{{< /history >}}

在 Kubernetes 上运行 Gitaly 会带来可用性方面的权衡，因此规划生产环境时请考虑这些权衡，并相应设定期望。
本文档介绍了这些内容，并提供了如何最大限度减少及规划现有限制的指南。

Gitaly 团队已经对在 Kubernetes 上运行 Gitaly 进行了评估，并确定这是一种安全
的 Gitaly 部署方式。本文档的其余部分详细说明了这样做的最佳实践。

<a id="timeline"></a>

## 时间线

[在 Kubernetes 上运行 Gitaly](kubernetes.md) 从极狐GitLab 18.11 开始已正式发布。极狐GitLab 不
保证与云提供商特定的托管 Kubernetes 服务（例如 Amazon EKS、Google GKE 或 Azure AKS）的兼容性。你应
在部署到生产环境之前验证你的特定环境。

<a id="context"></a>

## 背景

按照设计，Gitaly（非集群）是一个单点故障服务（SPoF）。数据从单个实例获取并提供服务。
对于 Kubernetes，当 StatefulSet Pod 发生轮换（例如，在升级、节点维护或驱逐期间）时，轮换会导致该 Pod 或实例所提供数据服务的中断。

在[云原生混合](../reference_architectures/1k_users.md#cloud-native-hybrid-reference-architecture-with-helm-charts)设置（Gitaly VM）中，Linux 软件包（Omnibus）
通过以下方式掩盖了这个问题：

1. 原地升级 Gitaly 二进制文件。
1. 执行优雅重载。

相同方法不适用于基于容器生命周期的场景，因为容器或 Pod 需要完全关闭并作为新容器或 Pod 启动。

Gitaly 集群（Praefect）通过跨实例复制数据来解决数据和服务高可用性方面的问题。然而，由于在容器化平台上会加剧的[现有问题和设计限制](praefect/_index.md#known-issues)，Gitaly 集群（Praefect）不适合在 Kubernetes 中运行。

为了支持云原生部署，Gitaly（非集群）是唯一的选择。
通过利用正确的 Kubernetes 和 Gitaly 特性及配置，你可以最大限度地减少服务中断，并提供良好的用户体验。

<a id="requirements"></a>

## 要求

本页面信息基于以下前提：

- Kubernetes 版本等于或高于 `1.29`。
- Kubernetes 节点 `runc` 版本等于或高于 `1.1.9`。
- Kubernetes 节点 cgroup v2。不支持原生的混合 v1 模式。仅支持
  [`systemd` 风格的 cgroup 结构](https://kubernetes.io/docs/setup/production-environment/container-runtimes/#systemd-cgroup-driver)（Kubernetes 默认）。
- Pod 可访问节点挂载点 `/sys/fs/cgroup`。
- containerd 版本 2.1.0 或更高。
- Pod 初始化容器（`init-cgroups`）对 `/sys/fs/cgroup` 具有 `root` 用户文件系统权限。用于将 Pod cgroup 委托给 Gitaly 容器
  （用户 `git`，UID `1000`）。
- cgroups 文件系统未使用 `nsdelegate` 标志挂载。更多信息，请参见 Gitaly 议题 [6480](https://gitlab.com/gitlab-org/gitaly/-/issues/6480)。

<a id="guidance"></a>

## 指南

在 Kubernetes 中运行 Gitaly 时，你必须：

- [处理 Pod 中断](#address-pod-disruption)。
- [处理资源争用和饱和](#address-resource-contention-and-saturation)。
- [优化 Pod 轮换时间](#optimize-pod-rotation-time)。
- [监控磁盘使用情况](#monitor-disk-usage)

<a id="enable-cgroupwritable-field-in-containerd"></a>

### 在 containerd 中启用 `cgroup_writable` 字段

Gitaly 中的 cgroup 支持要求非特权容器对 cgroups 具有可写访问权限。containerd v2.1.0 引入了 `cgroup_writable` 配置选项。启用此选项后，可确保 cgroups 文件系统以读写权限挂载。

要启用此字段，请在将要部署 Gitaly 的节点上执行以下步骤。如果 Gitaly 已经部署，则必须在修改配置后重新创建 Pod。

1. 修改位于 `/etc/containerd/config.toml` 的 containerd 配置文件，以包含 `cgroup_writable` 字段：

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

   如果服务重启时间过长，这些命令可能会将节点标记为 NotReady。

<a id="address-pod-disruption"></a>

### 处理 Pod 中断

Pod 可能因多种原因发生轮换。理解并规划服务生命周期有助于最大限度减少中断。

例如，对于 Gitaly，Kubernetes `StatefulSet` 会在 `spec.template` 对象发生更改时进行轮换，这可能发生在 Helm Chart 升级（标签或镜像标签）或 Pod 资源请求或限制更新期间。

本节重点介绍常见的 Pod 中断情况以及如何处理它们。

<a id="schedule-maintenance-windows"></a>

#### 安排维护窗口

由于该服务并非高可用，某些操作可能会导致短暂的服务中断。安排维护窗口可以预示潜在的
服务中断，并有助于设定期望。你应在以下情况使用维护窗口：

- 极狐GitLab Helm Chart 升级和重新配置。
- Gitaly 配置更改。
- Kubernetes 节点维护窗口。例如，升级和打补丁。将 Gitaly 隔离到其专用的节点池可能会有所帮助。

<a id="use-priorityclass"></a>

#### 使用 `PriorityClass`

使用 [PriorityClass](https://kubernetes.io/docs/concepts/scheduling-eviction/pod-priority-preemption/#priorityclass) 为 Gitaly Pod 分配比其他 Pod 更高的优先级，以帮助缓解节点饱和压力、提高驱逐优先级和改善调度延迟：

1. 创建一个优先级：

   ```yaml
   apiVersion: scheduling.k8s.io/v1
   kind: PriorityClass
   metadata:
     name: gitlab-gitaly
   value: 1000000
   globalDefault: false
   description: "极狐GitLab Gitaly 优先级"
   ```

1. 将优先级分配给 Gitaly Pod：

   ```yaml
   gitlab:
     gitaly:
       priorityClassName: gitlab-gitaly
   ```

<a id="signal-node-autoscaling-to-prevent-eviction"></a>

#### 通过节点自动伸缩信号防止驱逐

节点自动伸缩工具会根据需要添加和移除 Kubernetes 节点，以调度 Pod 并优化成本。

在缩容事件期间，Gitaly Pod 可能会被驱逐，以优化资源使用。通常可以使用注解来控制此行为并
排除工作负载。例如，使用 Cluster Autoscaler：

```yaml
gitlab:
  gitaly:
    annotations:
      cluster-autoscaler.kubernetes.io/safe-to-evict: "false"
```

<a id="address-resource-contention-and-saturation"></a>

### 处理资源争用和饱和

由于 Git 操作的不可预测性，Gitaly 服务的资源使用情况可能难以预判。并非所有仓库都相同，其大小
会严重影响性能和资源使用，尤其是对于[单体仓库](../../user/project/repository/monorepos/_index.md)。

在 Kubernetes 中，不受控制的资源使用可能导致内存不足（OOM）事件，这会强制平台终止 Pod 并终止其所有进程。
Pod 终止会引发两个重要问题：

- 数据/仓库损坏
- 服务中断

本节重点介绍如何缩小影响范围并保护整个服务。

<a id="constrain-git-processes-resource-usage"></a>

#### 限制 Git 进程的资源使用

隔离 Git 进程可以安全地保证单个 Git 调用无法消耗所有服务和 Pod 资源。

Gitaly 可以使用 Linux [控制组（cgroups）](cgroups.md)对每个仓库的资源使用施加更小的配额。

你应保持 cgroup 配额低于 Pod 的总资源分配。
CPU 并非关键因素，因为它只会减慢服务速度。但是，内存饱和可能导致 Pod 终止。在 Pod 请求和 Git cgroup
分配之间保留 1 GiB 的内存缓冲区是一个安全的起点。缓冲区的大小取决于流量模式和仓库数据。

例如，如果 Pod 内存请求为 15 GiB，则 14 GiB 分配给 Git 调用：

```yaml
gitlab:
  gitaly:
    cgroups:
      enabled: true
      # 所有仓库 cgroup 的总限制，不包括 Gitaly 进程
      memoryBytes: 15032385536 # 14GiB
      cpuShares: 1024
      cpuQuotaUs: 400000 # 4 核心
      # 每个仓库的限制，50 个仓库 cgroup
      repositories:
        count: 50
        memoryBytes: 7516192768 # 7GiB
        cpuShares: 512
        cpuQuotaUs: 200000 # 2 核心
```

更多信息，请参见 [Gitaly 配置文档](configure_gitaly.md#control-groups)。

<a id="right-size-pod-resources"></a>

#### 合理配置 Pod 资源大小

Gitaly Pod 的大小调整至关重要，[参考架构](../reference_architectures/_index.md#cloud-native-hybrid)提供了一些入门指导。但是，不同的仓库和使用模式会消耗不同程度的资源。
你应监控资源使用情况，并随时间推移进行相应调整。

内存是 Kubernetes 中最敏感的资源，因为内存耗尽可能触发 Pod 终止。
[使用 cgroups 隔离 Git 调用](#constrain-git-processes-resource-usage)有助于限制仓库操作的资源使用，但这不包括 Gitaly 服务本身。
根据之前关于 cgroup 配额的建议，在总体 Git cgroup 内存分配和 Pod 内存请求之间添加一个缓冲区，以提高安全性。

首选 Pod `Guaranteed` [服务质量](https://kubernetes.io/docs/tasks/configure-pod-container/quality-service-pod/)等级
（资源请求与限制匹配）。使用此设置，Pod 不易受到资源争用的影响，并保证不会因其他 Pod 的消耗而被驱逐。

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

你可以使用并发限制来帮助保护服务免受异常流量模式的影响。更多信息，请参见
[并发限制配置文档](concurrency_limiting.md)和[如何监控限制](monitoring.md#monitor-gitaly-concurrency-limiting)。

<a id="isolate-gitaly-pods"></a>

#### 隔离 Gitaly Pod

运行多个 Gitaly Pod 时，应将它们调度到不同的节点，以分散故障域。这可以使用 Pod 反亲和性来强制执行。
例如：

```yaml
gitlab:
  gitaly:
    antiAffinity: hard
```

<a id="optimize-pod-rotation-time"></a>

### 优化 Pod 轮换时间

本节涵盖优化领域，通过减少 Pod 开始服务流量所需的时间，来减少维护事件或计划外基础设施事件期间的停机时间。

<a id="persistent-volume-permissions"></a>

#### 持久卷权限

随着数据大小（Git 历史记录和更多仓库）的增长，Pod 启动并变为就绪状态所需的时间会越来越长。

在 Pod 初始化期间，作为持久卷挂载的一部分，文件系统权限和所有权会显式设置为容器的 `uid` 和 `gid`。
此操作默认运行，并且由于存储的 Git 数据包含许多小文件，可能会显著减慢 Pod 启动时间。

此行为可以通过
[`fsGroupChangePolicy`](https://kubernetes.io/docs/tasks/configure-pod-container/security-context/#configure-volume-permission-and-ownership-change-policy-for-pods)
属性进行配置。使用此属性，仅在卷根目录的 `uid` 或 `gid` 与容器规范不匹配时才执行该操作：

```yaml
gitlab:
  gitaly:
    securityContext:
      fsGroupChangePolicy: OnRootMismatch
```

<a id="health-probes"></a>

#### 健康探测

Gitaly Pod 在就绪探测成功后开始服务流量。默认的探测时间较为保守，以覆盖大多数用例。
减少 `readinessProbe` 的 `initialDelaySeconds` 属性可以更早地触发探测，从而加快 Pod 就绪速度。例如：

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

默认情况下，在终止时，Gitaly 为正在处理的请求授予 1 分钟的超时时间以完成。
乍看之下这很有用，但此超时：

- 会减慢 Pod 轮换速度。
- 通过在关闭过程中拒绝请求来降低可用性。

在基于容器的部署中，更好的方法是依赖客户端重试逻辑。你可以使用 `gracefulRestartTimeout` 字段重新配置超时时间。
例如，授予 1 秒的优雅超时：

```yaml
gitlab:
  gitaly:
    gracefulRestartTimeout: 1
```

<a id="monitor-disk-usage"></a>

### 监控磁盘使用情况

对于长时间运行的 Gitaly 容器，请定期监控磁盘使用情况，因为如果
[未启用日志轮换](https://gitlab.cn/docs/charts/charts/globals/#log-rotation)，日志文件增长可能会导致存储问题。

<a id="migrate-to-gitaly-on-kubernetes"></a>

## 迁移到在 Kubernetes 上运行的 Gitaly

要将现有仓库从非 Kubernetes 的 Gitaly 节点迁移到在 Kubernetes 上运行的 Gitaly：

1. 部署在 Kubernetes 上运行的 Gitaly 节点，并在极狐GitLab 管理区域中[将其添加为新的仓库存储](../repository_storage_paths.md#configure-where-new-repositories-are-stored)。
   配置存储权重，使所有新仓库都创建在新的仓库存储上。
   这可以防止在迁移过程中，在旧的仓库存储上创建新项目。
1. 使用仓库移动 API 将现有仓库移动到新的存储上。
   极狐GitLab 仓库可以与项目、群组和片段关联，每种类型都有单独的 API。
   有关完整说明，请参见[移动极狐GitLab 管理的仓库](../operations/moving_repositories.md)。

在移动期间，每个仓库将被设为只读，并且在移动完成之前不可写入。