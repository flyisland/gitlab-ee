---
stage: Application Security Testing
group: Composition analysis
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
description: 扫描 Kubernetes 集群中的容器镜像以查找漏洞。
title: 运维容器扫描
---

{{< details >}}

- Tier: 旗舰版
- Offering: JihuLab.com，私有化部署

{{< /details >}}

<a id="supported-architectures"></a>

## 支持的架构

运维容器扫描（OCS）支持 `linux/arm64` 和 `linux/amd64`。

<a id="enable-operational-container-scanning"></a>

## 启用运维容器扫描

您可以使用 OCS 扫描集群中的容器镜像以查找安全漏洞。OCS 使用 [Trivy](https://github.com/aquasecurity/trivy)的[包装镜像](https://gitlab.com/gitlab-org/security-products/analyzers/trivy-k8s-wrapper)来扫描镜像中的漏洞。

您可以使用 `agent config` 或项目的扫描执行策略，将 OCS 配置为按周期运行。

> [!note]
> 如果同时配置了 `agent config` 和 `scan execution policies`，则以 `scan execution policy`中的配置为准。

<a id="enable-via-agent-configuration"></a>

### 通过 Agent 配置启用

要通过 Agent 配置启用对 Kubernetes 集群中镜像的扫描，请向 Agent 配置添加一个 `container_scanning` 配置块，其中包含一个 `cadence` 字段，该字段包含用于指定扫描运行时间的 [CRON 表达式](https://en.wikipedia.org/wiki/Cron)。

```yaml
container_scanning:
  cadence: '0 0 * * *' # Daily at 00:00 (Kubernetes cluster time)
```

`cadence` 字段为必填项。极狐GitLab 支持在 cadence 字段中使用以下类型的 CRON 语法：

- 每天在指定小时每小时运行一次的每日周期，例如：`0 18 * * *`
- 每周在指定日期和指定小时运行一次的每周周期，例如：`0 13 * * 0`

> [!note]
> 如果您的实现所使用的 [cron](https://github.com/robfig/cron) 支持，[CRON 语法](https://docs.oracle.com/cd/E12058_01/doc/doc.1014/e12030/cron_expressions.htm)的其他元素也可能在 cadence 字段中生效。但是，极狐GitLab 不会正式测试或支持它们。
>
> CRON 表达式使用 Kubernetes Agent Pod 的系统时间，以 [UTC](https://www.timeanddate.com/worldclock/timezone/utc) 计算。

默认情况下，运维容器扫描不会扫描任何工作负载以查找漏洞。您可以设置 `vulnerability_report` 块及其 `namespaces` 字段，用于选择要扫描的命名空间。例如，如果您只想扫描 `default`、`kube-system` 命名空间，可以使用以下配置：

```yaml
container_scanning:
  cadence: '0 0 * * *'
  vulnerability_report:
    namespaces:
      - default
      - kube-system
```

对于每个目标命名空间，默认会扫描以下工作负载资源中的所有镜像：

- Pod
- ReplicaSet
- ReplicationController
- StatefulSet
- DaemonSet
- CronJob
- Job

您可以通过[配置 Trivy Kubernetes 资源检测](#configure-trivy-kubernetes-resource-detection)来自定义此行为。

<a id="enable-via-scan-execution-policies"></a>

### 通过扫描执行策略启用

要通过扫描执行策略启用对 Kubernetes 集群中镜像的扫描，请使用[扫描执行策略编辑器](../../application_security/policies/scan_execution_policies.md#scan-execution-policy-editor)创建新的计划规则。

> [!note]
> 要扫描正在运行的容器镜像，Kubernetes Agent 必须在您的集群中运行

运维容器扫描独立于极狐GitLab 流水线运行。它完全自动化，由 Kubernetes Agent 管理，Agent 会在扫描执行策略中配置的计划时间发起新的扫描。Agent 会在您的集群中创建一个专用 Job 来执行扫描，并将发现结果报告回极狐GitLab。

以下是一个策略示例，用于在 Kubernetes Agent 所连接的集群中启用运维容器扫描：

```yaml
- name: Enforce container scanning in cluster connected through my-gitlab-agent for default and kube-system namespaces
  enabled: true
  rules:
  - type: schedule
    cadence: '0 10 * * *'
    agents:
      <agent-name>:
        namespaces:
        - 'default'
        - 'kube-system'
  actions:
  - scan: container_scanning
```

计划规则的键为：

- `cadence`（必填）：用于指定扫描运行时间的 [CRON 表达式](https://docs.oracle.com/cd/E12058_01/doc/doc.1014/e12030/cron_expressions.htm)
- `agents:<agent-name>`（必填）：用于扫描的 Agent 名称
- `agents:<agent-name>:namespaces`（必填）：要扫描的 Kubernetes 命名空间。

> [!note]
> 如果您的实现所使用的 [cron](https://github.com/robfig/cron) 支持，[CRON 语法](https://docs.oracle.com/cd/E12058_01/doc/doc.1014/e12030/cron_expressions.htm)的其他元素也可能在 cadence 字段中生效。但是，极狐GitLab 不会正式测试或支持它们。
>
> CRON 表达式使用 Kubernetes Agent Pod 的系统时间，以 [UTC](https://www.timeanddate.com/worldclock/timezone/utc) 计算。

您可以在[扫描执行策略文档](../../application_security/policies/scan_execution_policies.md#scan-execution-policies-schema)中查看完整架构。

<a id="ocs-vulnerability-resolution-for-multi-cluster-configuration"></a>

## 多集群配置下的 OCS 漏洞解决

为确保 OCS 准确跟踪漏洞，您应为每个集群创建一个启用了 OCS 的独立极狐GitLab 项目。如果您有多个集群，请务必为每个集群使用一个项目。

OCS 会在每次扫描后，通过将当前扫描的漏洞与之前检测到的漏洞进行比较，来解决集群中不再发现的漏洞。之前扫描中存在但当前扫描中不再出现的任何漏洞，都会在极狐GitLab 项目中标记为已解决。

如果在同一个项目中配置了多个集群，则一个集群（例如项目 A）中的 OCS 扫描会解决另一个集群（例如项目 B）中之前检测到的漏洞，从而导致漏洞报告不正确。

<a id="configure-scanner-resource-requirements"></a>

## 配置扫描器资源需求

默认情况下，扫描器 Pod 的默认资源需求为：

```yaml
requests:
  cpu: 100m
  memory: 100Mi
  ephemeral_storage: 1Gi
limits:
  cpu: 500m
  memory: 500Mi
  ephemeral_storage: 3Gi
```

您可以使用 `resource_requirements` 字段进行自定义。

```yaml
container_scanning:
  resource_requirements:
    requests:
      cpu: '0.2'
      memory: 200Mi
      ephemeral_storage: 2Gi
    limits:
      cpu: '0.7'
      memory: 700Mi
      ephemeral_storage: 4Gi
```

为 CPU 使用小数值时，请将该值格式化为字符串。

> [!note]
>
> - 即使通过扫描执行策略启用运维容器扫描，也必须使用 Agent 配置文件设置资源需求。
> - 使用 Google Kubernetes Engine（GKE）进行 Kubernetes 编排时，[临时存储限制会自动设置为与请求相等](https://cloud.google.com/kubernetes-engine/docs/concepts/autopilot-resource-requests#resource-limits)。

<a id="custom-repository-for-trivy-k8s-wrapper"></a>

## Trivy K8s Wrapper 的自定义仓库

在扫描期间，OCS 会使用来自 [Trivy K8s Wrapper 仓库](https://gitlab.com/security-products/trivy-k8s-wrapper/container_registry/5992609)的镜像部署 Pod，该仓库会将 [Trivy Kubernetes](https://aquasecurity.github.io/trivy/v0.54/docs/target/kubernetes) 生成的漏洞报告传输给 OCS。

如果您的集群防火墙限制了对 Trivy K8s Wrapper 仓库的访问，您可以将 OCS 配置为从自定义仓库拉取镜像。请确保自定义仓库镜像了 Trivy K8s Wrapper 仓库以保证兼容性。

```yaml
container_scanning:
  trivy_k8s_wrapper_image:
    repository: "your-custom-registry/your-image-path"
```

<a id="configure-scan-timeout"></a>

## 配置扫描超时

默认情况下，Trivy 扫描会在五分钟后超时。Agent 本身会额外提供 15 分钟来读取链式 ConfigMap 并传输漏洞信息。

要自定义 Trivy 超时时长：

- 使用 `scanner_timeout` 字段以秒为单位指定时长。

例如：

```yaml
container_scanning:
  scanner_timeout: "3600s" # 60 minutes
```

<a id="configure-trivy-report-size"></a>

## 配置 Trivy 报告大小

默认情况下，Trivy 报告限制为 100 MB，这对大多数扫描来说已经足够。但是，如果您有大量工作负载，可能需要提高该限制。

为此：

- 使用 `report_max_size` 字段以字节为单位指定限制。

例如：

```yaml
container_scanning:
  report_max_size: "300000000" # 300 MB
```

<a id="configure-trivy-kubernetes-resource-detection"></a>

## 配置 Trivy Kubernetes 资源检测

默认情况下，Trivy 会查找以下 Kubernetes 资源类型以发现可扫描的镜像：

- Pod
- ReplicaSet
- ReplicationController
- StatefulSet
- DaemonSet
- CronJob
- Job
- Deployment

您可以限制 Trivy 发现的 Kubernetes 资源类型，例如仅扫描“活动”镜像。

为此：

- 使用 `resource_types` 字段指定资源类型：

  ```yaml
  container_scanning:
    vulnerability_report:
      resource_types:
        - Deployment
        - Pod
        - Job
  ```

<a id="configure-trivy-report-artifact-deletion"></a>

## 配置 Trivy 报告产物删除

默认情况下，极狐GitLab Kubernetes Agent 会在扫描完成后删除 Trivy 报告产物。

您可以将 Agent 配置为保留报告产物，以便查看原始状态的报告。

为此：

- 将 `delete_report_artifact` 设置为 `false`：

  ```yaml
  container_scanning:
    delete_report_artifact: false
  ```

<a id="configure-trivy-severity-threshold-filter"></a>

## 配置 Trivy 严重性阈值过滤器

默认情况下，OCS 会扫描所有[严重性](../../application_security/vulnerabilities/severities.md)级别的漏洞。

要仅报告达到或高于特定严重性级别的漏洞，请将配置变量 `severity_threshold` 设置为该值。设置严重性阈值后，低于您所选严重性的漏洞将不再出现在漏洞报告、API 负载和其他报告机制中。

这使您可以专注于符合组织风险承受能力需求的漏洞。

支持的阈值包括 `UNKNOWN`、`LOW`、`MEDIUM`、`HIGH` 和 `CRITICAL`。

例如，要报告高和严重级别的漏洞：

```yaml
container_scanning:
  severity_threshold: "HIGH"
```

<a id="view-cluster-vulnerabilities"></a>

## 查看集群漏洞

要在极狐GitLab 中查看漏洞信息：

1. 在顶部栏中，选择**搜索或跳转到**，然后找到包含 Agent 配置文件的极狐GitLab 项目。
1. 选择**运维** > **Kubernetes 集群**。
1. 选择 **代理** 标签页。
1. 选择一个 Agent 以查看集群漏洞。

![集群代理安全标签页界面](img/cluster_agent_security_tab_v14_8.png)

此信息也可在[运维漏洞](../../application_security/vulnerability_report/_index.md#operational-vulnerabilities)下找到。

> [!note]
> 您必须具有开发者、维护者或所有者角色。

<a id="scanning-private-images"></a>

## 扫描私有镜像

要扫描私有镜像，扫描器会依赖镜像拉取密钥（直接引用以及来自服务账号的引用）来拉取镜像。

<a id="known-issues"></a>

## 已知问题

在极狐GitLab Kubernetes Agent 16.9 及更高版本中，运维容器扫描：

- 可处理最大 100 MB 的 Trivy 报告。在之前的版本中，该限制为 10 MB。
- 当极狐GitLab Kubernetes Agent 以 `fips` 模式运行时会被禁用。

<a id="troubleshooting"></a>

## 故障排除

<a id="error-running-trivy-scan-container-terminated-reason-oomkilled"></a>

### `Error running Trivy scan. Container terminated reason: OOMKilled`

如果要扫描的资源过多，或者要扫描的镜像过大，OCS 可能会因 OOM 错误而失败。

要解决此问题，请[配置资源需求](#configure-scanner-resource-requirements)以增加可用内存量。

<a id="pod-ephemeral-local-storage-usage-exceeds-the-total-limit-of-containers"></a>

### `Pod ephemeral local storage usage exceeds the total limit of containers`

对于默认临时存储较低的 Kubernetes 集群，OCS 扫描可能会失败。例如，[GKE autopilot](https://cloud.google.com/kubernetes-engine/docs/concepts/autopilot-resource-requests#defaults) 将默认临时存储设置为 1 GB。对于 OCS 来说，在扫描包含大镜像的命名空间时，这可能是个问题，因为可能没有足够的空间存储 OCS 所需的所有数据。

要解决此问题，请[配置资源需求](#configure-scanner-resource-requirements)以增加可用临时存储量。

指示此问题的另一条消息可能是：`OCS Scanning pod evicted due to low resources. Please configure higher resource limits.`

<a id="error-running-trivy-scan-due-to-context-timeout"></a>

### `Error running Trivy scan due to context timeout`

如果 Trivy 完成扫描耗时过长，OCS 可能无法完成扫描。默认扫描超时为 5 分钟，Agent 另有 15 分钟用于读取结果并传输漏洞信息。

要解决此问题，请[配置扫描器超时](#configure-scan-timeout)以延长扫描超时时间。

<a id="trivy-report-size-limit-exceeded"></a>

### `trivy report size limit exceeded`

如果生成的 Trivy 报告大小超过默认最大限制，OCS 可能会因此错误而失败。

要解决此问题，请[配置 Trivy 报告最大大小](#configure-trivy-report-size)以增加 Trivy 报告允许的最大大小。
