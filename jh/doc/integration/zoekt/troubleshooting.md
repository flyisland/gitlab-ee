---
stage: Analytics
group: Global Search
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
title: Zoekt 故障排除
---

{{< details >}}

- Tier: 专业版，旗舰版
- Offering: JihuLab.com，私有化部署

{{< /details >}}

使用 Zoekt 时，您可能会遇到以下问题。

要了解在诊断错误时 Zoekt 各组件如何交互，请参阅[使用 Zoekt 进行代码搜索](https://handbook.gitlab.com/handbook/engineering/architecture/design-documents/code_search_with_zoekt/)。该设计文档描述了完整的架构，包括哪个组件调用哪个组件，以及每个组件保存哪些内容。

初步调试：

- [运行健康检查](_index.md#run-a-health-check)，以了解
  Zoekt 基础设施的状态。
- 使用 `gitlab-rake gitlab:zoekt:info` Rake 任务
  [检查索引状态](_index.md#check-indexing-status)。

<a id="namespace-is-not-indexed"></a>

## 命名空间未被索引

当您[启用该设置](_index.md#index-root-namespaces-automatically)后，新的命名空间会自动建立索引。如果某个命名空间未自动建立索引，请检查 Sidekiq 日志，确认作业是否正在处理。`Search::Zoekt::SchedulingWorker` 负责为命名空间建立索引。

在 [Rails 控制台会话](../../administration/operations/rails_console.md#starting-a-rails-console-session)中，您可以检查：

- 未启用 Zoekt 的命名空间：

  ```ruby
  Namespace.group_namespaces.root_namespaces_without_zoekt_enabled_namespace
  ```

- Zoekt 索引的状态：

  ```ruby
  Search::Zoekt::Index.all.pluck(:state, :namespace_id)
  ```

要手动为命名空间建立索引，请参阅[设置索引](https://gitlab.cn/docs/charts/charts/gitlab/gitlab-zoekt/#configure-zoekt-in-gitlab)。

<a id="error-silentmodeblockederror"></a>

## 错误：`SilentModeBlockedError`

当您尝试运行精确代码搜索时，可能会遇到 `SilentModeBlockedError`。当极狐GitLab 实例上启用了[静默模式](../../administration/silent_mode)时，会出现此问题。

要解决此问题，请确保已禁用静默模式。

<a id="error-connections-to-all-backends-failing"></a>

## 错误：`connections to all backends failing`

在 `application_json.log`中，您可能会遇到以下错误：

```plaintext
connections to all backends failing; last error: UNKNOWN: ipv4:1.2.3.4:5678: Trying to connect an http1.x server
```

要解决此问题，请检查您是否使用了任何代理。如果使用了，请将极狐GitLab 服务器的 IP 地址设置为 `no_proxy`：

```ruby
gitlab_rails['env'] = {
  "http_proxy" => "http://proxy.domain.com:1234",
  "https_proxy" => "http://proxy.domain.com:1234",
  "no_proxy" => ".domain.com,IP_OF_GITLAB_INSTANCE,127.0.0.1,localhost"
}
```

`proxy.domain.com:1234` 是代理实例的域名和端口。`IP_OF_GITLAB_INSTANCE` 指向极狐GitLab 实例的公共 IP 地址。

您可以通过运行 `ip a` 并检查以下内容之一来获取此信息：

- 相应网络接口的 IP 地址
- 您所使用的任何负载均衡器的公共 IP 地址

<a id="out-of-memory-errors"></a>

## 内存不足错误

Zoekt 节点在搜索或建立索引期间可能会耗尽内存。内存不足（OOM）错误更可能出现在 webserver 中。webserver 在提供搜索服务时会将索引分片内存映射到物理内存，因此常驻内存会随索引大小和查询量增长。OOM 错误的症状以及所需的恢复步骤因这两个组件而异。有关更多信息，请参阅[内存架构](_index.md#memory-architecture)。

<a id="detect-an-out-of-memory-event"></a>

### 检测内存不足事件

对于 Kubernetes 部署，请检查容器是否因 OOM 错误而被终止：

```shell
kubectl describe pod <your_pod_name> -n <your_namespace>
```

在 `Last State` 部分中查找 `OOMKilled` 以及非零的 `Exit Code`（通常为 `137`）：

```plaintext
Last State: Terminated
  Reason: OOMKilled
  Exit Code: 137
```

您还可以检查所有 Zoekt pod 的重启次数：

```shell
kubectl get pods -n <your_namespace> -l app=gitlab-zoekt
```

某个 pod 上较高的 `RESTARTS` 次数表明发生了反复的 OOM 终止。标签选择器
`app=gitlab-zoekt` 可能因您的 chart 版本或 operator 配置而异。

如果您安装了 [kube-state-metrics](https://github.com/kubernetes/kube-state-metrics)，
还可以在 Prometheus 或 Grafana 中监控以下指标：

- `kube_pod_container_status_last_terminated_reason{reason="OOMKilled"}`：因 OOM 而终止的 pod。
- `kube_pod_container_status_waiting_reason{reason="CrashLoopBackOff"}`：处于崩溃循环中的 pod。
- `kube_pod_container_status_restarts_total`：每个容器的累计重启次数。快速增加表明发生了反复崩溃。

webserver 在端口 `6070`的 `/metrics` 上公开 `process_resident_memory_bytes`。
如果您已将 Prometheus 配置为直接抓取 webserver pod，可以使用此
指标来监控 webserver 常驻内存随时间的用量。

对于虚拟机和裸机部署，请检查系统日志中的 OOM 事件：

```shell
sudo journalctl -k | grep -i "oom\|killed process"
```

<a id="recover-from-an-out-of-memory-event"></a>

### 从内存不足事件中恢复

恢复步骤因遇到 OOM 错误的组件而异。

<a id="indexer-out-of-memory-errors"></a>

#### 索引器内存不足错误

如果索引器因 OOM 错误而被反复终止，请在调查期间全局暂停索引，以停止所有节点上的所有新索引工作：

```shell
gitlab-rake gitlab:zoekt:pause_indexing
```

或者从 UI 暂停索引：

先决条件：

- 管理员访问权限。

1. 在右上角，选择**管理员**。
1. 在左侧边栏中，选择**设置** > **搜索**。
1. 展开**精确代码搜索**。
1. 选中**暂停索引**复选框。
1. 选择**保存更改**。

在节点稳定后，恢复索引：

```shell
gitlab-rake gitlab:zoekt:resume_indexing
```

<a id="webserver-out-of-memory-errors"></a>

#### Webserver 内存不足错误

如果 webserver 因 OOM 错误而被反复终止，请在调查期间禁用 Zoekt 搜索。这样可以在不影响索引的情况下停止发往崩溃节点的搜索流量。

> [!note]
> 禁用 Zoekt 搜索后，代码搜索会回退到基本搜索模式。
> 如果 Elasticsearch 不可用，则基本搜索模式只能进行项目范围的代码搜索，
> 这会增加 Gitaly 的负载。

先决条件：

- 管理员访问权限。

1. 在右上角，选择**管理员**。
1. 在左侧边栏中，选择**设置** > **搜索**。
1. 展开**精确代码搜索**。
1. 清除**启用搜索**复选框。
1. 选择**保存更改**。

在节点稳定后，重新启用搜索：

1. 在右上角，选择**管理员**。
1. 在左侧边栏中，选择**设置** > **搜索**。
1. 展开**精确代码搜索**。
1. 选中**启用搜索**复选框。
1. 选择**保存更改**。

<a id="reduce-memory-pressure"></a>

### 减轻内存压力

如果您的节点规格合适但仍遇到内存压力，请调整以下设置以减少内存使用。

<a id="reduce-parallel-indexing-processes"></a>

#### 减少并行索引进程数

先决条件：

- 管理员访问权限。

要降低索引器的峰值内存，请减少每个索引任务的并行进程数：

1. 在右上角，选择**管理员**。
1. 在左侧边栏中，选择**设置** > **搜索**。
1. 展开**精确代码搜索**。
1. 将**每个索引任务的并行进程数**设置为 `1`。
1. 选择**保存更改**。

<a id="reduce-concurrent-indexing-tasks"></a>

#### 减少并发索引任务数

先决条件：

- 管理员访问权限。

要减少同时运行的索引任务数量，请降低**索引 CPU 与任务数乘数**的值：

1. 在右上角，选择**管理员**。
1. 在左侧边栏中，选择**设置** > **搜索**。
1. 展开**精确代码搜索**。
1. 降低**索引 CPU 与任务数乘数**的值（例如，降低到 `0.5`）。
1. 选择**保存更改**。

<a id="increase-force-reindexing-probability"></a>

#### 提高强制重新索引的概率

Zoekt webserver 会对索引分片进行内存映射。随着时间推移，增量索引会累积许多小分片，从而增加打开的 mmap 句柄数量。强制重新索引会完全重建索引，将分片合并为更少、更大的文件，从而减少内存开销。

先决条件：

- 管理员访问权限。

要减少分片累积，请提高强制重新索引的概率：

1. 在右上角，选择**管理员**。
1. 在左侧边栏中，选择**设置** > **搜索**。
1. 展开**精确代码搜索**。
1. 提高**随机强制重新索引的概率（百分比）**的值。
   默认值为 `0.25`（0.25%）。例如，将其设置为 `1`，以便大约每 100 个
   增量索引任务中有 1 个触发强制重新索引。
1. 选择**保存更改**。

<a id="right-size-the-node"></a>

### 调整节点规格

如果调整设置后仍无法解决反复出现的 OOM 事件，则该节点需要更多内存。有关根据索引大小分配内存的指导，请参阅[规格建议](_index.md#sizing-recommendations)。

对于 Kubernetes 部署，请在 Helm chart 的 `values.yaml`中增加内存请求和限制。
确保内存限制等于或高于您的磁盘层级在规格表中的值。

对于虚拟机和裸机部署，请迁移到规格表中更大的实例类型，或添加更多节点，将索引分布到更多机器上。

调整规格后，运行健康检查以确认节点已恢复：

```shell
gitlab-rake gitlab:zoekt:health
```

<a id="verify-zoekt-node-connections"></a>

## 验证 Zoekt 节点连接

要验证您的 Zoekt 节点已正确配置并连接，请在 [Rails 控制台会话](../../administration/operations/rails_console.md#starting-a-rails-console-session)中：

- 检查已配置的 Zoekt 节点总数：

  ```ruby
  Search::Zoekt::Node.count
  ```

- 检查有多少节点在线：

  ```ruby
  Search::Zoekt::Node.online.count
  ```

或者，您可以使用 `gitlab:zoekt:info` Rake 任务。

如果在线节点数少于已配置的节点数，或者在已配置节点的情况下为零，则极狐GitLab 与您的 Zoekt 节点之间可能存在连接问题。

<a id="debug-zoekt-connection-errors"></a>

## 调试 Zoekt 连接错误

当您遇到 Zoekt 连接问题时，了解请求流程并系统地验证架构中的每个组件非常重要。

<a id="zoekt-architecture"></a>

### Zoekt 架构

Zoekt 使用一个统一的二进制文件（`gitlab-zoekt`），它可以以两种模式运行：

- 索引器模式，用于为 Gitaly 中的代码仓库建立索引
- Webserver 模式，用于处理搜索请求

基本搜索流程为：

```plaintext
GitLab Rails → Zoekt webserver
```

对于 Helm chart（Kubernetes）部署，架构
还包含用于负载均衡的额外网关组件：

```plaintext
GitLab Rails → external gateway (NGINX) → internal gateway (NGINX) → Zoekt webserver
```

这些网关组件是 Helm chart 部署的一部分，而不是 Zoekt 的内部组件。
它们是 NGINX 代理，用于将请求分发到多个 Zoekt webserver 实例，
并处理路由、负载均衡和可选的 TLS 终止。

有关 Zoekt 架构设计的更多信息，请参阅[使用 Zoekt 进行代码搜索](https://handbook.gitlab.com/handbook/engineering/architecture/design-documents/code_search_with_zoekt/)。

<a id="verify-network-reachability"></a>

### 验证网络可达性

要验证从您的 GitLab Rails pod 可以访问 Zoekt 网关，
请[运行健康检查](_index.md#run-a-health-check)：

```shell
gitlab-rake gitlab:zoekt:health
```

此任务会验证从 Rails 到 Zoekt 的连接，并报告总体状态为 `HEALTHY`、`DEGRADED` 或 `UNHEALTHY`。如果健康检查失败，则极狐GitLab 与您的 Zoekt 基础设施之间可能存在网络连接问题。

要检查节点状态和配置，请运行以下 Rake 任务：

```shell
gitlab-rake gitlab:zoekt:info
```

要查看包括 URL 在内的详细节点信息，请在 [Rails 控制台](../../administration/operations/rails_console.md#starting-a-rails-console-session)中运行以下命令：

```ruby
# View all node attributes including URLs
Search::Zoekt::Node.all.map(&:attributes)
```

- `search_base_url` 应指向 Zoekt webserver 或 Kubernetes 中的外部网关
  （例如 `http://gitlab-zoekt:8080/`）。
- `index_base_url` 应指向 Zoekt 索引器。

如果您在搜索时收到 `404` 响应，则请求可能未正确路由。此错误表明问题很可能出在网关配置，而不是网络连接。

<a id="monitor-zoekt-logs"></a>

### 监控 Zoekt 日志

对于 Helm chart（Kubernetes）部署，请监控 Zoekt 组件日志
以识别连接问题。

`StatefulSet` 包含三个容器：

```shell
# Monitor webserver logs (search requests from Rails)
kubectl logs -f statefulset/gitlab-zoekt -c zoekt-webserver -n <your_namespace>

# Monitor indexer logs (repository indexing)
kubectl logs -f statefulset/gitlab-zoekt -c zoekt-indexer -n <your_namespace>

# Monitor internal gateway logs (NGINX proxy between the external gateway and webserver)
kubectl logs -f statefulset/gitlab-zoekt -c zoekt-internal-gateway -n <your_namespace>
```

如果您使用的是外部网关部署，还可以监控外部网关日志：

```shell
# Monitor external gateway logs (NGINX proxy for incoming requests from Rails)
kubectl logs -f deployment/gitlab-zoekt-gateway -c zoekt-external-gateway -n <your_namespace>
```

在监控这些日志时，请从极狐GitLab UI 运行测试搜索。日志应显示请求正在被处理。如果请求未出现在日志中，则 Rails 与 Zoekt 之间可能存在网络路由问题。

<a id="run-test-searches-from-the-ui"></a>

### 从 UI 运行测试搜索

在监控 `zoekt.log` 文件时，您可以从极狐GitLab UI 运行测试搜索：

- 在项目中搜索特定节点。
- 在群组中搜索以查询多个节点。
- 全局搜索以查询所有节点。

如果搜索失败，请检查 `zoekt.log` 文件中的详细错误消息：

```shell
# For installations that use the Linux package
tail -f /var/log/gitlab/gitlab-rails/zoekt.log

# For self-compiled installations
tail -f /home/git/gitlab/log/zoekt.log
```

对于搜索失败，`application_json.log` 文件仅记录一条 `Global Search Error Rate SLI` 条目。此条目是服务等级指标（SLI），而不是详细的错误消息。

请查找可能表明极狐GitLab 与您的 Zoekt 基础设施之间存在网络问题的连接错误、超时或认证失败。

<a id="verify-pod-and-service-status"></a>

### 验证 pod 和服务状态

对于 Helm chart（Kubernetes）部署，请检查 Zoekt pod 和服务的状态：

```shell
# Check pod status
kubectl get pods -n <your_namespace> -l app=gitlab-zoekt

# Check `StatefulSet` status
kubectl get statefulset gitlab-zoekt -n <your_namespace>

# Check service endpoints
kubectl get endpoints gitlab-zoekt -n <your_namespace>

# Describe the service to see the configuration
kubectl describe service gitlab-zoekt -n <your_namespace>
```

确保所有 pod 都处于运行状态，并且服务具有有效的端点。如果 pod 未运行或端点缺失，则您的 Zoekt 部署可能存在配置问题。

有关部署架构的更多信息，请参阅：

- [外部网关部署配置](https://gitlab.com/gitlab-org/cloud-native/charts/gitlab-zoekt/-/blob/main/templates/deployment.yaml)
- [`StatefulSet` 配置（索引器、webserver 和内部网关）](https://gitlab.com/gitlab-org/cloud-native/charts/gitlab-zoekt/-/blob/main/templates/stateful_sets.yaml)

<a id="error-taskrequest-responded-with-401"></a>

## 错误：`TaskRequest responded with [401]`

在 Zoekt 索引器日志中，您可能会看到 `TaskRequest responded with [401]`。此错误表明 Zoekt 索引器无法通过极狐GitLab 的认证。

要解决此问题，请验证 `gitlab-shell-secret` 已正确配置，并且在您的极狐GitLab 实例与 Zoekt 索引器之间保持一致。例如，以下命令的输出必须与您 `gitlab.rb`中的 `gitlab-shell-secret` 匹配：

```shell
kubectl get secret gitlab-shell-secret -o jsonpath='{.data.secret}' -n your_zoekt_namespace | base64 -d
```

<a id="error-missing-selected-alpn-property"></a>

## 错误：`missing selected ALPN property`

当您在 Zoekt 网关前面使用外部负载均衡器时，可能会在极狐GitLab 日志中看到以下错误：

```plaintext
rpc error: code = Unavailable desc = connection error: desc = "transport: authentication handshake failed: credentials: cannot check peer: missing selected ALPN property"
```

当负载均衡器不支持或未通告带 HTTP/2 的 ALPN（应用层协议协商）时，会出现此错误。
Zoekt 依赖 gRPC 进行节点间通信，而 gRPC 需要 HTTP/2 支持。

要解决此问题，请执行以下操作之一：

- 在负载均衡器上启用 HTTP/2 支持（推荐）：

  1. 将负载均衡器配置为通过 ALPN 支持和通告 HTTP/2：
     - 对于 HAProxy，在后端中确保已配置 `alpn h2,http/1.1`。
     - 对于 NGINX，在 server 块中使用：
       - 在 NGINX 1.25.1 及更高版本中，使用 `http2 on;`。
       - 在 NGINX 1.25.0 及更早版本中，使用 `listen 443 ssl http2;`。
  1. 验证 HTTP/2 支持：

     ```shell
     curl --verbose --http2 "https://your-zoekt-gateway-url/health" 2>&1 | grep ALPN
     ```

     您应看到类似以下的输出：

     ```plaintext
     * ALPN, server accepted to use h2
     ```

- 使用 TLS 透传：

  如果您的负载均衡器无法支持 HTTP/2，请将负载均衡器配置为 TLS 透传。
  这样 Zoekt 网关就可以直接处理 TLS 终止，从而确保正确的 ALPN 协商。
  要使用 TLS 透传，请在 Zoekt 网关上配置有效的 TLS 证书：

  1. 对于 Helm chart 部署，请在 `values.yaml`中配置证书：

     ```yaml
     gateway:
       tls:
         certificate:
           enabled: true
           secretName: zoekt-gateway-cert
     ```

  1. 将负载均衡器配置为透传加密流量而不终止 TLS。
