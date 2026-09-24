---
stage: Application Security Testing
group: Composition analysis
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
description: Scans container images in a Kubernetes cluster for vulnerabilities.
title: 操作式容器扫描
---

{{< details >}}

- Tier: 旗舰版
- Offering: JihuLab.com，私有化部署

{{< /details >}}

{{< history >}}

- 在极狐GitLab 15.4 中已弃用 starboard 指令。starboard 指令计划在极狐GitLab 16.0 中移除。

{{< /history >}}

<a id="supported-architectures"></a>

## 支持的架构

在极狐GitLab Kubernetes Agent 16.10.0 及更高版本和极狐GitLab Agent Helm Chart 1.25.0 及更高版本中，操作式容器扫描 (OCS) 支持 `linux/arm64` 和 `linux/amd64`。对于早期版本，仅支持 `linux/amd64`。

<a id="enable-operational-container-scanning"></a>

## 启用操作式容器扫描

您可以使用 OCS 扫描集群中的容器镜像漏洞。在极狐GitLab Kubernetes Agent 16.9 及更高版本中，OCS 使用 [包装器镜像](https://jihulab.com/gitlab-cn/security-products/analyzers/trivy-k8s-wrapper) 封装 [Trivy](https://github.com/aquasecurity/trivy) 来扫描镜像漏洞。在极狐GitLab 16.9 之前，OCS 直接使用 [Trivy](https://github.com/aquasecurity/trivy) 镜像。

OCS 可以通过使用 `agent config` 或项目的扫描执行策略，按配置的周期运行。

> [!note]
> 如果同时配置了 `agent config` 和 `scan execution policies`，则以 `scan execution policy` 的配置为准。

<a id="enable-via-agent-configuration"></a>

### 通过 agent 配置启用

要通过 agent 配置在 Kubernetes 集群中启用镜像扫描，请在您的 agent 配置中添加一个 `container_scanning` 配置块，并在其中设置一个包含 [CRON 表达式](https://en.wikipedia.org/wiki/Cron) 的 `cadence` 字段，以指定扫描的运行时间。

```yaml
container_scanning:
  cadence: '0 0 * * *' # 每日 00:00（Kubernetes 集群时间）
```

`cadence` 字段是必需的。极狐GitLab 支持以下类型的 CRON 语法用于 cadence 字段：

- 每日在指定小时执行一次的计划，例如：`0 18 * * *`
- 每周在指定星期几的指定小时执行一次的计划，例如：`0 13 * * 0`

> [!note]
> 其它元素的 [CRON 语法](https://docs.oracle.com/cd/E12058_01/doc/doc.1014/e12030/cron_expressions.htm) 可能在 cadence 字段中工作，如果您的实施中使用的 [cron](https://github.com/robfig/cron) 支持这些元素。然而，极狐GitLab 未正式测试或支持它们。
>
> CRON 表达式使用 Kubernetes agent Pod 的系统时间，以 [UTC](https://www.timeanddate.com/worldclock/timezone/utc) 计算。

默认情况下，操作式容器扫描不会扫描任何工作负载的漏洞。您可以设置 `vulnerability_report` 块，并使用 `namespaces` 字段来选择要扫描的命名空间。例如，如果您只想扫描 `default`、`kube-system` 命名空间，可以使用以下配置：

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

这可以通过 [配置 Trivy Kubernetes 资源检测](#configure-trivy-kubernetes-resource-detection) 进行自定义。

<a id="enable-via-scan-execution-policies"></a>

### 通过扫描执行策略启用

要通过扫描执行策略启用 Kubernetes 集群中的镜像扫描，请使用 [扫描执行策略编辑器](../../application_security/policies/scan_execution_policies.md#scan-execution-policy-editor) 创建新的计划规则。

> [!note]
> 要扫描运行中的容器镜像，Kubernetes Agent 必须在您的集群中运行。

操作式容器扫描独立于极狐GitLab 流水线运行。它完全自动化，由 Kubernetes Agent 管理，该 Agent 会在扫描执行策略中配置的计划时间启动新的扫描。Agent 会在您的集群中创建一个专用 Job 来执行扫描，并将结果报告回极狐GitLab。

以下是启用操作式容器扫描的策略示例，该扫描在 Kubernetes Agent 所连接的集群中运行，覆盖 `default` 和 `kube-system` 命名空间：

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

计划规则的键包括：

- `cadence`（必需）：指定扫描运行时间的 CRON 表达式
- `agents:<agent-name>`（必需）：用于扫描的 Agent 名称
- `agents:<agent-name>:namespaces`（必需）：要扫描的 Kubernetes 命名空间

> [!note]
> 其它元素的 [CRON 语法](https://docs.oracle.com/cd/E12058_01/doc/doc.1014/e12030/cron_expressions.htm) 可能在 cadence 字段中工作，如果您的实施中使用的 [cron](https://github.com/robfig/cron) 支持这些元素。然而，极狐GitLab 未正式测试或支持它们。
>
> CRON 表达式使用 Kubernetes agent Pod 的系统时间，以 [UTC](https://www.timeanddate.com/worldclock/timezone/utc) 计算。

您可以在 [扫描执行策略文档](../../application_security/policies/scan_execution_policies.md#scan-execution-policies-schema) 中查看完整架构。

<a id="ocs-vulnerability-resolution-for-multi-cluster-configuration"></a>

## 多集群配置下的 OCS 漏洞解决

为确保 OCS 的漏洞跟踪准确，您应该为每个集群创建一个单独的极狐GitLab 项目，并在该项目中启用 OCS。如果您有多个集群，请确保每个集群都使用一个单独的项目。

OCS 通过在每次扫描后比较当前扫描与先前检测到的漏洞，来解决集群中不再存在的漏洞。对于该极狐GitLab 项目，所有之前扫描发现但在当前扫描中不再存在的漏洞都会被解决。

如果在同一个项目中配置了多个集群，那么在一个集群（例如，Project A）中进行的 OCS 扫描会解决来自另一个集群（例如，Project B）的先前检测到的漏洞，从而导致漏洞报告不正确。

<a id="configure-scanner-resource-requirements"></a>

## 配置扫描器资源需求

默认情况下，扫描器 Pod 的默认资源需求如下：

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

您可以使用 `resource_requirements` 字段对其进行自定义。

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

当使用分数值表示 CPU 时，请将值格式化为字符串。

> [!note]
>
> - 即使通过扫描执行策略启用了操作式容器扫描，也必须使用 agent 配置文件设置资源需求。
> - 在使用 Google Kubernetes Engine (GKE) 进行 Kubernetes 编排时，[临时存储限制会自动设置为等于请求值](https://cloud.google.com/kubernetes-engine/docs/concepts/autopilot-resource-requests#resource-limits)。

<a id="custom-repository-for-trivy-k8s-wrapper"></a>

## 自定义 Trivy K8s Wrapper 仓库

在扫描期间，OCS 会部署 Pod，使用来自 [Trivy K8s Wrapper 仓库](https://gitlab.com/security-products/trivy-k8s-wrapper/container_registry/5992609) 的镜像，该仓库将 [Trivy Kubernetes](https://aquasecurity.github.io/trivy/v0.54/docs/target/kubernetes) 生成的漏洞报告传输给 OCS。

如果您的集群防火墙限制了对 Trivy K8s Wrapper 仓库的访问，您可以配置 OCS 从自定义仓库拉取镜像。请确保自定义仓库镜像与 Trivy K8s Wrapper 仓库兼容。

```yaml
container_scanning:
  trivy_k8s_wrapper_image:
    repository: "your-custom-registry/your-image-path"
```

<a id="configure-scan-timeout"></a>

## 配置扫描超时

{{< history >}}

- 在极狐GitLab 17.7 中引入。

{{< /history >}}

默认情况下，Trivy 扫描在五分钟后超时。Agent 本身会额外提供 15 分钟来读取链式配置映射并传输漏洞。

要自定义 Trivy 超时时长：

- 使用 `scanner_timeout` 字段指定时长（以秒为单位）。

例如：

```yaml
container_scanning:
  scanner_timeout: "3600s" # 60 分钟
```

<a id="configure-trivy-report-size"></a>

## 配置 Trivy 报告大小

{{< history >}}

- 在极狐GitLab 17.7 中引入。

{{< /history >}}

默认情况下，Trivy 报告大小限制为 100 MB，这对大多数扫描来说已经足够。但是，如果您有大量工作负载，可能需要提高此限制。

为此：

- 使用 `report_max_size` 字段指定大小限制（以字节为单位）。

例如：

```yaml
container_scanning:
  report_max_size: "300000000" # 300 MB
```

<a id="configure-trivy-kubernetes-resource-detection"></a>

## 配置 Trivy Kubernetes 资源检测

{{< history >}}

- 在极狐GitLab 17.9 中引入。

{{< /history >}}

默认情况下，Trivy 会查找以下 Kubernetes 资源类型以发现可扫描的镜像：

- Pod
- ReplicaSet
- ReplicationController
- StatefulSet
- DaemonSet
- CronJob
- Job
- Deployment

您可以限制 Trivy 发现的 Kubernetes 资源类型，例如只扫描“活动”镜像。

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

## 配置 Trivy 报告制品删除

{{< history >}}

- 在极狐GitLab 17.9 中引入。

{{< /history >}}

默认情况下，极狐GitLab Kubernetes Agent 在扫描完成后会删除 Trivy 报告制品。

您可以配置 Agent 保留报告制品，以便查看报告的原始状态。

为此：

- 将 `delete_report_artifact` 设置为 `false`：

  ```yaml
  container_scanning:
    delete_report_artifact: false
  ```

<a id="configure-trivy-severity-threshold-filter"></a>

## 配置 Trivy 严重性阈值过滤器

{{< history >}}

- 在极狐GitLab 18.4 中引入。

{{< /history >}}

默认情况下，OCS 会扫描所有 [严重性级别](../../application_security/vulnerabilities/severities.md) 的漏洞。

要仅报告达到或高于特定严重性级别的漏洞，请将配置变量 `severity_threshold` 设置为该值。设置严重性阈值后，低于您所选择级别的漏洞将不再出现在漏洞报告、API 载荷和其他报告机制中。

这样可以让您专注于满足组织风险承受需求的漏洞。

支持的阈值包括 `UNKNOWN`、`LOW`、`MEDIUM`、`HIGH` 和 `CRITICAL`。

例如，要仅报告高危害和严重级别的漏洞：

```yaml
container_scanning:
  severity_threshold: "HIGH"
```

<a id="view-cluster-vulnerabilities"></a>

## 查看集群漏洞

要在极狐GitLab 中查看漏洞信息：

1. 在顶部栏，选择 **搜索或跳转到** 并找到包含 agent 配置文件的所在项目。
1. 选择 **运维** > **Kubernetes 集群**。
1. 选择 **代理** 选项卡。
1. 选择一个代理以查看集群漏洞。

![集群代理安全选项卡界面](img/cluster_agent_security_tab_v14_8.png)

这些信息也可以在 [操作式漏洞](../../application_security/vulnerability_report/_index.md#operational-vulnerabilities) 下找到。

> [!note]
> 您必须具有开发者、维护者或所有者角色。

<a id="scanning-private-images"></a>

## 扫描私有镜像

{{< history >}}

- 在极狐GitLab 16.4 中引入。

{{< /history >}}

要扫描私有镜像，扫描器依赖于镜像拉取密钥（直接引用以及来自服务账户的密钥）来拉取镜像。

<a id="known-issues"></a>

## 已知问题

在极狐GitLab Kubernetes Agent 16.9 及更高版本中，操作式容器扫描：

- 处理最多 100 MB 的 Trivy 报告。对于早期版本，此限制为 10 MB。
- 当极狐GitLab Kubernetes Agent 在 `fips` 模式下运行时，会被禁用。

<a id="troubleshooting"></a>

## 故障排除

### `Error running Trivy scan. Container terminated reason: OOMKilled`

如果要扫描的资源太多或镜像过大，OCS 可能会因 OOM 错误而失败。

要解决此问题，请 [配置资源需求](#configure-scanner-resource-requirements) 以增加可用内存量。

### `Pod ephemeral local storage usage exceeds the total limit of containers`

对于默认临时存储较低的 Kubernetes 集群，OCS 扫描可能会失败。例如，[GKE Autopilot](https://cloud.google.com/kubernetes-engine/docs/concepts/autopilot-resource-requests#defaults) 将默认临时存储设置为 1 GB。当 OCS 扫描包含大镜像的命名空间时，这会导致问题，因为可能没有足够的空间存储 OCS 所需的所有数据。

要解决此问题，请 [配置资源需求](#configure-scanner-resource-requirements) 以增加可用临时存储量。

指示此问题的另一条消息可能是：`OCS Scanning pod evicted due to low resources. Please configure higher resource limits.`

### `Error running Trivy scan due to context timeout`

如果 Trivy 完成扫描的时间过长，OCS 可能无法完成扫描。默认扫描超时为 5 分钟，Agent 会额外提供 15 分钟来读取结果和传输漏洞。

要解决此问题，请 [配置扫描超时](#configure-scan-timeout) 以增加可用内存量。

### `trivy report size limit exceeded`

如果生成的 Trivy 报告大小超过默认上限，OCS 可能会失败并报此错误。

要解决此问题，请 [配置最大 Trivy 报告大小](#configure-trivy-report-size) 以提高 Trivy 报告的允许上限。