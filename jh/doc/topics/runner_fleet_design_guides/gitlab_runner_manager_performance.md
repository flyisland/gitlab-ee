---
stage: Verify
group: Runner Core
info: >-
  To determine the technical writer assigned to the Stage/Group associated with
  this page, see
  <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
description: 在 Kubernetes 环境中优化极狐GitLab Runner 管理器 pod 性能。
title: 优化极狐GitLab Runner 管理器 pod 性能
---

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: JihuLab.com，私有化部署

{{< /details >}}

要在 Kubernetes 环境中监控并优化极狐GitLab Runner 管理器 pod 性能，极狐GitLab 推荐以下最佳实践。请应用这些实践来识别性能瓶颈，并实施解决方案，以实现最优的 CI/CD 流水线执行。

<a id="prerequisites"></a>

## 先决条件

在实施这些建议之前：

- 使用 [Kubernetes 执行器](https://gitlab.cn/docs/runner/executors/kubernetes/)在 Kubernetes 中部署极狐GitLab Runner
- 拥有 Kubernetes 集群的管理员访问权限
- 为极狐GitLab Runner 配置 [Prometheus 监控](../../administration/monitoring/_index.md)
- 对 Kubernetes 资源管理有基本了解

<a id="gitlab-runner-manager-pod-responsibilities"></a>

## 极狐GitLab Runner 管理器 pod 的职责

极狐GitLab Runner 管理器 pod 负责协调 Kubernetes 中所有 CI/CD 作业的执行。
其性能直接影响您的流水线效率。

它负责处理：

- **日志处理**：从工作 pod 收集作业日志并将其转发到极狐GitLab
- **缓存管理**：协调本地和基于云的缓存操作
- **Kubernetes API 请求**：创建、监控和删除工作 pod
- **极狐GitLab API 通信**：轮询作业并报告状态更新
- **Pod 生命周期管理**：管理工作 pod 的预配和清理

```mermaid
%%{init: { "fontFamily": "GitLab Sans" }}%%
flowchart LR
    accTitle: GitLab Runner manager pod architecture
    accDescr: The manager pod polls GitLab for jobs, creates job pods through the Kubernetes API, manages the S3 cache, and forwards logs from job pods to GitLab.

    subgraph "External Services"
        GL[GitLab Instance]
        S3[S3 Cache Storage]
    end

    subgraph "Manager Pod"
        MP[Manager Process]
        LB[Log Buffer]
        CM[Cache Manager]
    end

    subgraph "Kubernetes API"
        K8S[API Server]
    end

    subgraph "Job Pods"
        JP1[Job Pod 1]
        JP2[Job Pod 2]
        JP3[Job Pod N]
    end

    GL <-->|Poll Jobs<br/>Update Status| MP
    MP <-->|Create/Delete<br/>Monitor Pods| K8S
    MP <-->|Cache Operations| S3
    JP1 -->|Stream Logs| LB
    JP2 -->|Stream Logs| LB
    JP3 -->|Stream Logs| LB
    LB -->|Forward Logs| GL
    CM <-->|Manage Cache| S3
```

每项职责对性能的影响各不相同：

- **CPU 密集型**：Kubernetes API 操作、日志处理
- **内存密集型**：日志缓冲、作业队列管理
- **网络密集型**：极狐GitLab API 通信、日志流式传输

<a id="deploy-gitlab-runner-in-kubernetes"></a>

## 在 Kubernetes 中部署极狐GitLab Runner

通过 [GitLab Runner Operator](https://gitlab.com/gitlab-org/gl-openshift/gitlab-runner-operator) 安装极狐GitLab Runner。
该 Operator 会持续获得新功能和改进。
GitLab Runner 团队通过以下框架安装 Operator：
[实验性 GRIT 框架](https://gitlab.com/gitlab-org/ci-cd/runner-tools/grit/-/tree/main/scenarios/google/gke/operator?ref_type=heads)。

在 Kubernetes 中安装极狐GitLab Runner 最简单的方法是应用
[最新版本中的 `operator.k8s.yaml` 清单](https://gitlab.com/gitlab-org/gl-openshift/gitlab-runner-operator/-/releases)，然后按照 [Operator 安装文档](https://gitlab.cn/docs/runner/install/operator/#install-on-kubernetes)中的说明操作。

<a id="configure-monitoring"></a>

## 配置监控

可观测性对于在 Kubernetes 中管理极狐GitLab Runner 至关重要，因为
pod 是临时的，而指标提供了主要的运维可见性。

要进行监控，请安装 [`kube-prometheus-stack`](https://github.com/prometheus-community/helm-charts/blob/main/charts/kube-prometheus-stack/README.md)。

要为 Operator 配置监控，请参阅[监控 GitLab Runner Operator](https://gitlab.cn/docs/runner/monitoring/#monitor-operator-managed-gitlab-runners)。

<a id="performance-monitoring"></a>

## 性能监控

有效的监控对于维持管理器 pod 的最佳性能至关重要。

```mermaid
%%{init: { "fontFamily": "GitLab Sans" }}%%
flowchart TD
    accTitle: Metrics collection and monitoring flow
    accDescr: The manager pod exposes metrics, Prometheus scrapes the metrics using PodMonitor configuration, Grafana visualizes the data, and Alertmanager notifies operators.

    subgraph "Metrics Collection Flow"
        MP[Manager Pod<br/>:9252/metrics]
        PM[PodMonitor]
        P[Prometheus]
        G[Grafana]
        A[Alertmanager]

        MP -->|Expose Metrics| PM
        PM -->|Scrape| P
        P -->|Query| G
        P -->|Alerts| A
        A -->|Notify| O[Operators]
    end
```

<a id="key-performance-metrics"></a>

### 关键性能指标

监控以下重要指标：

| 指标                                               | 描述                             | 性能指标              |
| -------------------------------------------------- | -------------------------------- | --------------------- |
| `gitlab_runner_jobs`                               | 当前运行的作业                   | 作业队列饱和度        |
| `gitlab_runner_limit`                              | 配置的作业并发限制               | 容量利用率            |
| `gitlab_runner_request_concurrency_exceeded_total` | 超出并发限制的请求               | API 限流              |
| `gitlab_runner_errors_total`                       | 捕获的错误总数                   | 系统稳定性            |
| `container_cpu_usage_seconds_total`                | 容器 CPU 使用量                  | 资源消耗              |
| `container_memory_working_set_bytes`               | 容器内存使用量                   | 内存压力              |

<a id="prometheus-queries"></a>

### Prometheus 查询

使用以下查询跟踪管理器 pod 性能：

```prometheus
# Manager pod memory usage in MB
container_memory_working_set_bytes{pod=~"gitlab-runner.*"} / 1024 / 1024

# Manager pod CPU utilization in Millicores
rate(container_cpu_usage_seconds_total{pod=~"gitlab-runner.*"}[5m]) * 1000

# Job queue saturation
gitlab_runner_jobs / gitlab_runner_limit

# Jobs per runner
gitlab_runner_jobs

# API request rate
sum(rate(apiserver_request_total[5m]))
```

<a id="example-dashboard"></a>

### 示例仪表板

以下仪表板使用前面介绍的 Prometheus 查询，展示所有 pod 的管理器 pod 利用率：

![极狐GitLab Runner 管理器 pod 指标仪表板，显示管理器 pod 的内存和 CPU 使用情况](img/metrics_v18_2.png)

此仪表板可帮助您直观了解：

- 各管理器 pod 的内存使用趋势
- 作业执行期间的 CPU 利用率模式
- 作业队列饱和度
- 各个 pod 的资源消耗

<a id="identify-overloaded-manager-pods"></a>

## 识别过载的管理器 pod

在性能下降影响您的流水线之前识别它。

<a id="resource-utilization-indicators"></a>

### 资源利用率指标

默认情况下，GitLab Runner Operator 不会对管理器 pod 应用 CPU 或内存限制。

要设置资源限制：

```shell
kubectl patch deployment gitlab-runner -p '{"spec":{"template":{"spec":{"containers":[{"name":"gitlab-runner","resources":{"requests":{"cpu":"500m","memory":"256Mi"},"limits":{"cpu":"1000m","memory":"512Mi"}}}]}}}}'
```

> [!note]
> 允许从 Operator 配置进行部署补丁的功能正在开发中。
> 更多信息，请参阅[合并请求 197](https://gitlab.com/gitlab-org/gl-openshift/gitlab-runner-operator/-/merge_requests/197)。

**高 CPU 使用模式：**

- 标准操作期间 CPU 持续高于 70%
- 创建作业期间 CPU 峰值超过 90%
- 在没有相应作业活动的情况下 CPU 持续高企

**内存消耗趋势：**

- 内存使用量超过分配限制的 80%
- 在负载未增加的情况下内存持续增长
- 管理器 pod 日志中出现内存不足（OOM）事件

<a id="performance-degradation-signs"></a>

### 性能下降迹象

留意以下运维症状：

- 作业保持待处理状态的时间比平时更长
- Pod 创建时间超过 30 秒
- 极狐GitLab 作业界面中的日志输出延迟
- 日志中出现 `etcdserver: request timed out` 错误

<a id="diagnostic-commands"></a>

### 诊断命令

```shell
# Current resource usage
kubectl top pods --containers

> POD                                                 NAME              CPU(cores)   MEMORY(bytes)
> gitlab-runner-runner-86cd68d899-m6qqm               runner            7m           32Mi

# Check for performance errors
kubectl logs gitlab-runner-runner-86cd68d899-m6qqm --since=2h | grep -E "(error|timeout|failed)"
```

<a id="resource-configuration"></a>

## 资源配置

正确的资源配置对于实现最佳性能至关重要。

<a id="performance-testing-methodology"></a>

### 性能测试方法

极狐GitLab Runner 管理器 pod 的性能通过一个最大化日志输出的作业进行测试：

<details>
<summary>性能测试作业定义</summary>

```yaml
performance_test:
  stage: build
  timeout: 30m
  tags:
    - kubernetes_runner
  image: alpine:latest
  parallel: 100
  variables:
    FILE_SIZE_MB: 4
    CHUNK_SIZE_BYTES: 1024
    FILE_NAME: "test_file_${CI_JOB_ID}_${FILE_SIZE_MB}MB.dat"
    KUBERNETES_CPU_REQUEST: "200m"
    KUBERNETES_CPU_LIMIT: "200m"
    KUBERNETES_MEMORY_REQUEST: "200Mi"
    KUBERNETES_MEMORY_LIMIT: "200Mi"
  script:
    - echo "Starting performance test job ${CI_PARALLEL_ID}/${CI_PARALLEL_TOTAL} with ${FILE_SIZE_MB}MB file size, ${CHUNK_SIZE_BYTES} bytes chunk size"
    - dd if=/dev/urandom of="${FILE_NAME}" bs=1M count=${FILE_SIZE_MB}
    - echo "File generated successfully. Size:"
    - ls -lh "${FILE_NAME}"
    - echo "Reading file in ${CHUNK_SIZE_BYTES} byte chunks"
    - |
      TOTAL_SIZE=$(stat -c%s "${FILE_NAME}")
      BLOCKS=$((TOTAL_SIZE / CHUNK_SIZE_BYTES))
      echo "Processing $BLOCKS blocks of $CHUNK_SIZE_BYTES bytes each"
      for i in $(seq 0 99 $BLOCKS); do
        echo "Processing blocks $i to $((i+99))"
        dd if="${FILE_NAME}" bs=${CHUNK_SIZE_BYTES} skip=$i count=100 2>/dev/null | xxd -l $((CHUNK_SIZE_BYTES * 100)) -c 16
        sleep 0.5
      done
```

</details>

此测试为每个作业生成 4 MB 的日志输出，达到默认的
[`output_limit`](https://gitlab.cn/docs/runner/configuration/advanced-configuration/#the-runners-section)，
以对管理器 pod 的日志处理能力进行压力测试。

**测试结果：**

| 并行作业数 | 峰值 CPU 使用量 | 峰值内存使用量 |
| ------------- | -------------- | ----------------- |
| 50            | 308m           | 261 MB            |
| 100           | 657m           | 369 MB            |

```mermaid
%%{init: { "fontFamily": "GitLab Sans" }}%%
xychart-beta
    accTitle: Manager pod resource usage compared to concurrent jobs
    accDescr: Chart showing CPU usage (10-610 millicores) and memory usage (50-300 MB) that scale with concurrent jobs (0-100).

    x-axis [0, 25, 50, 75, 100]
    y-axis "Resource Usage" 0 --> 700
    line "CPU (millicores)" [10, 160, 310, 460, 610]
    line "Memory (MB)" [50, 112, 175, 237, 300]
```

**主要发现：**

- CPU 使用量随并发作业数大致呈线性增长
- 内存使用量随作业数量增加而增加，但并非线性
- 所有作业并发运行，无需排队

<a id="cpu-requirements"></a>

### CPU 需求

根据极狐GitLab 性能测试，计算管理器 pod 的 CPU 需求：

管理器 pod CPU = 基础 CPU +（并发作业数 × 每作业 CPU 系数）

其中：

- 基础 CPU：10m（基线开销）
- 每作业 CPU 系数：每个并发作业约 6m（基于测试）

**基于测试结果的示例：**

对于 50 个并发作业：

```yaml
resources:
  requests:
    cpu: "310m" # 10m + (50 × 6m) = 310m
  limits:
    cpu: "465m" # 50% headroom for burst traffic
```

对于 100 个并发作业：

```yaml
resources:
  requests:
    cpu: "610m" # 10m + (100 × 6m) = 610m
  limits:
    cpu: "915m" # 50% headroom
```

<a id="memory-requirements"></a>

### 内存需求

根据极狐GitLab 测试，计算内存需求：

管理器 pod 内存 = 基础内存 +（并发作业数 × 每作业内存）

其中：

- 基础内存：50 MB（基线开销）
- 每作业内存：每个并发作业约 2.5 MB（日志输出为 4MB 时）

**基于测试结果的示例：**

对于 50 个并发作业：

```yaml
resources:
  requests:
    memory: "175Mi" # 50 + (50 × 2.5) = 175 MB
  limits:
    memory: "350Mi" # 100% headroom
```

对于 100 个并发作业：

```yaml
resources:
  requests:
    memory: "300Mi" # 50 + (100 × 2.5) = 300 MB
  limits:
    memory: "600Mi" # 100% headroom
```

> [!note]
> 内存使用量会因日志量不同而有显著差异。产生超过
> 4 MB 日志的作业需要按比例增加更多内存。

<a id="configuration-examples"></a>

### 配置示例

**小规模（1-20 个并发作业）：**

```yaml
resources:
  limits:
    cpu: 300m
    memory: 256Mi
  requests:
    cpu: 150m
    memory: 128Mi

runners:
  config: |
    concurrent = 20

    [[runners]]
      limit = 20
      request_concurrency = 5
```

**大规模（75 个以上并发作业）：**

```yaml
resources:
  limits:
    cpu: 1000m
    memory: 1Gi
  requests:
    cpu: 600m
    memory: 600Mi

runners:
  config: |
    concurrent = 150

    [[runners]]
      limit = 150
      request_concurrency = 20
```

<a id="horizontal-pod-autoscaler"></a>

### 水平 pod 自动扩缩器

配置自动扩缩：

```yaml
apiVersion: autoscaling/v2
kind: HorizontalPodAutoscaler
metadata:
  name: gitlab-runner-hpa
spec:
  scaleTargetRef:
    apiVersion: apps/v1
    kind: Deployment
    name: gitlab-runner
  minReplicas: 2
  maxReplicas: 5
  metrics:
    - type: Resource
      resource:
        name: cpu
        target:
          type: Utilization
          averageUtilization: 70
    - type: Resource
      resource:
        name: memory
        target:
          type: Utilization
          averageUtilization: 80
```

<a id="troubleshoot-performance-issues"></a>

## 排查性能问题

使用以下解决方案解决常见的管理器 pod 性能问题。

<a id="api-rate-limiting"></a>

### API 速率限制

**问题：**管理器 pod 超出 Kubernetes API 速率限制。

**解决方案：**优化 API 轮询：

```toml
[[runners]]
  [runners.kubernetes]
    poll_interval = "5s"  # Increase from default 3s
    poll_timeout = "180s"
```

<a id="performance-optimization"></a>

## 性能优化

针对具有挑战性的场景应用以下性能优化策略。

<a id="cache-optimization"></a>

### 缓存优化

配置分布式缓存以减轻管理器 pod 负载。此操作通过共享缓存文件，减少作业 pod 所需的计算量：

```toml
[runners.cache]
  Type = "s3"
  Shared = true

  [runners.cache.s3]
    ServerAddress = "cache.example.com"
    BucketName = "gitlab-runner-cache"
    PreSignedURLDisabled = false
```

<a id="node-segregation"></a>

## 节点隔离

使用专用节点将管理器 pod 与作业 pod 隔离，以确保稳定的性能并防止资源争用。这种隔离可防止作业 pod
干扰关键的管理器 pod 操作。

```mermaid
%%{init: { "fontFamily": "GitLab Sans" }}%%
graph TB
    accTitle: Kubernetes node segregation architecture
    accDescr: Node segregation with manager pods on dedicated manager nodes and job pods on worker nodes, separated by taints.

    subgraph "Kubernetes Cluster"
        subgraph "Manager Nodes"
            MN1[Manager Node 1<br/>Taint: runner.gitlab.com/manager]
            MN2[Manager Node 2<br/>Taint: runner.gitlab.com/manager]
            MP1[Manager Pod 1]
            MP2[Manager Pod 2]
            MN1 --> MP1
            MN2 --> MP2
        end

        subgraph "Worker Nodes"
            WN1[Worker Node 1<br/>Taint: runner.gitlab.com/job]
            WN2[Worker Node 2<br/>Taint: runner.gitlab.com/job]
            WN3[Worker Node 3<br/>Taint: runner.gitlab.com/job]
            JP1[Job Pod 1]
            JP2[Job Pod 2]
            JP3[Job Pod 3]
            JP4[Job Pod 4]
            WN1 --> JP1
            WN1 --> JP2
            WN2 --> JP3
            WN3 --> JP4
        end
    end

    MP1 -.->|Creates & Manages| JP1
    MP1 -.->|Creates & Manages| JP2
    MP2 -.->|Creates & Manages| JP3
    MP2 -.->|Creates & Manages| JP4
```

<a id="configure-node-taints"></a>

### 配置节点污点

**对于管理器节点：**

```shell
# Taint nodes dedicated to Manager Pods
kubectl taint nodes <manager-node-name> runner.gitlab.com/manager=:NoExecute

# Label nodes for easier selection
kubectl label nodes <manager-node-name> runner.gitlab.com/workload-type=manager
```

**对于工作节点：**

```shell
# Taint nodes dedicated to job pods
kubectl taint nodes <worker-node-name> runner.gitlab.com/job=:NoExecute

# Label nodes for job scheduling
kubectl label nodes <worker-node-name> runner.gitlab.com/workload-type=job
```

<a id="configure-manager-pod-scheduling"></a>

### 配置管理器 pod 调度

更新 GitLab Runner Operator 配置，使管理器 pod 仅在专用节点上调度：

```yaml
apiVersion: apps.gitlab.com/v1beta2
kind: Runner
metadata:
  name: gitlab-runner
spec:
  gitlabUrl: https://gitlab.example.com
  token: gitlab-runner-secret
  buildImage: alpine
  podSpec:
    name: "manager-node-affinity"
    patch: |
      {
        "spec": {
          "nodeSelector": {
            "runner.gitlab.com/workload-type": "manager"
          },
          "tolerations": [
            {
              "key": "runner.gitlab.com/manager",
              "operator": "Exists",
              "effect": "NoExecute"
            }
          ]
        }
      }
    patchType: "strategic"
```

<a id="configure-job-pod-scheduling"></a>

### 配置作业 pod 调度

通过更新 `config.toml`，确保作业 pod 仅在工作节点上运行。

```toml
[runners.kubernetes.node_selector]
"runner.gitlab.com/workload-type" = "job"

[runners.kubernetes.node_tolerations]
"runner.gitlab.com/job=" = "NoExecute"
```

**节点隔离的优势：**

- 为管理器 pod 提供专用资源，不受作业干扰
- 性能可预测，无资源争用
- 使用专用节点时可选择不设置资源限制
- 通过基于节点的扩缩简化容量规划

<a id="emergency-procedures"></a>

### 应急程序

**优雅重启：**

```shell
# Scale down to stop accepting new jobs
kubectl scale deployment gitlab-runner --replicas=0

# Wait for active jobs to complete (max 10 minutes)
timeout 600 bash -c 'while kubectl get pods -l job-type=user-job | grep Running; do sleep 10; done'

# Scale back up
kubectl scale deployment gitlab-runner --replicas=1
```

<a id="capacity-planning"></a>

## 容量规划

这些计算基于每个作业 4 MB 日志输出的测试。您的资源需求可能因以下因素而异：

- 每个作业的日志量
- 作业执行模式
- 缓存使用情况
- 到极狐GitLab 的网络延迟

使用以下 Python 函数计算最优资源：

```python
def calculate_manager_resources(concurrent_jobs, avg_log_mb_per_job=4):
    """Calculate Manager Pod resources based on performance testing."""
    # CPU: ~6m per concurrent job + 10m base
    base_cpu = 0.01  # 10m
    cpu_per_job = 0.006  # 6m per job
    total_cpu = base_cpu + (concurrent_jobs * cpu_per_job)

    # Memory: ~2.5MB per job + 50MB base (for 4MB log output)
    base_memory = 50
    memory_per_job = 2.5 * (avg_log_mb_per_job / 4)  # Scale with log size
    total_memory = base_memory + (concurrent_jobs * memory_per_job)

    return {
        'cpu_request': f"{int(total_cpu * 1000)}m",
        'cpu_limit': f"{int(total_cpu * 1.5 * 1000)}m",  # 50% headroom
        'memory_request': f"{int(total_memory)}Mi",
        'memory_limit': f"{int(total_memory * 2.0)}Mi"  # 100% headroom
    }
```

<a id="performance-thresholds"></a>

## 性能阈值

建立阈值以便主动干预：

| 指标           | 警告           | 严重           | 所需操作                |
| -------------- | -------------- | -------------- | ----------------------- |
| CPU 使用率     | 持续 70%       | 持续 85%       | 扩缩或优化              |
| 内存使用率     | 达到限制的 80% | 达到限制的 90% | 提高限制                |
| API 错误率     | 请求的 2%      | 请求的 5%      | 排查瓶颈                |
| 作业队列时间   | 30 秒          | 2 分钟         | 检查容量                |

<a id="summary"></a>

## 总结

优化极狐GitLab Runner 管理器 pod 性能需要系统化的监控、
合理的资源分配和主动的故障排除。

关键策略包括：

- **主动监控**：使用 Prometheus 指标和 Grafana 仪表板
- **资源规划**：基于并发作业容量和日志量
- **多管理器架构**：实现容错和负载分配
- **应急程序**：快速解决问题

实施这些策略，以确保可靠的 CI/CD 流水线执行，同时保持最优的资源利用率。
