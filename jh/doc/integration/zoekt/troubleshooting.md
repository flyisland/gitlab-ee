---
stage: AI-powered
group: Global Search
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
title: 排查 Zoekt 问题
---

{{< details >}}

- Tier: 专业版，旗舰版
- Offering: JihuLab.com，私有化部署
- 状态: 有限可用

{{< /details >}}

在使用 Zoekt 时，您可能会遇到以下问题。初步调试：

- [运行健康检查](_index.md#run-a-health-check) 来了解 Zoekt 基础设施的状态。
- 使用 `gitlab-rake gitlab:zoekt:info` Rake 任务 [检查索引状态](_index.md#check-indexing-status)。

<a id="namespace-is-not-indexed"></a>

## 命名空间未被索引

当您 [启用该设置](_index.md#index-root-namespaces-automatically) 后，新的命名空间会自动被索引。如果某个命名空间没有被自动索引，请检查 Sidekiq 日志以查看作业是否正在被处理。`Search::Zoekt::SchedulingWorker` 负责命名空间的索引。

在 [Rails 控制台会话](../../administration/operations/rails_console.md#starting-a-rails-console-session) 中，您可以检查：

- 未启用 Zoekt 的命名空间：

  ```ruby
  Namespace.group_namespaces.root_namespaces_without_zoekt_enabled_namespace
  ```

- Zoekt 索引的状态：

  ```ruby
  Search::Zoekt::Index.all.pluck(:state, :namespace_id)
  ```

要手动索引命名空间，请参阅 [设置索引](https://gitlab.cn/docs/charts/charts/gitlab/gitlab-zoekt/#configure-zoekt-in-gitlab)。

<a id="error-silentmodeblockederror"></a>

## 错误：`SilentModeBlockedError`

当您尝试运行精确代码搜索时，可能会遇到 `SilentModeBlockedError`。此问题发生于当极狐GitLab 实例上启用了 [静默模式](../../administration/silent_mode) 时。要解决此问题，请确保静默模式已禁用。

<a id="error-connections-to-all-backends-failing"></a>

## 错误：`connections to all backends failing`

在 `application_json.log` 中，您可能会遇到以下错误：

```plaintext
连接到所有后端失败；最后的错误：UNKNOWN: ipv4:1.2.3.4:5678: 尝试连接 http1.x 服务器
```

要解决此问题，请检查您是否使用了任何代理。如果是，请将极狐GitLab 服务器的 IP 地址添加到 `no_proxy`：

```ruby
gitlab_rails['env'] = {
  "http_proxy" => "http://proxy.domain.com:1234",
  "https_proxy" => "http://proxy.domain.com:1234",
  "no_proxy" => ".domain.com,IP_OF_GITLAB_INSTANCE,127.0.0.1,localhost"
}
```

`proxy.domain.com:1234` 是代理实例的域名和端口。`IP_OF_GITLAB_INSTANCE` 指向极狐GitLab 实例的公网 IP 地址。

您可以通过运行 `ip a` 并检查以下任一信息获取这些信息：
- 相应网络接口的 IP 地址
- 您使用的任何负载均衡器的公网 IP 地址

<a id="out-of-memory-errors"></a>

## 内存不足错误

Zoekt 节点在搜索或索引过程中可能会耗尽内存。内存不足（OOM）错误在 webserver 中更可能发生。webserver 在提供搜索服务时将索引分片内存映射到物理内存中，因此常驻内存会随着索引大小和查询量增长。OOM 错误的症状和所需的恢复步骤在两个组件之间有所不同。有关更多信息，请参阅 [内存架构](_index.md#memory-architecture)。

<a id="detect-an-out-of-memory-event"></a>

### 检测内存不足事件

对于 Kubernetes 部署，请检查容器是否因 OOM 错误而被终止：

```shell
kubectl describe pod <your_pod_name> -n <your_namespace>
```

在 `Last State` 部分查找 `OOMKilled` 和非零的 `Exit Code`（通常是 `137`）：

```plaintext
上一次状态：已终止
原因：OOMKilled
退出代码：137
```

您还可以检查所有 Zoekt pod 的重启次数：

```shell
kubectl get pods -n <your_namespace> -l app=gitlab-zoekt
```

一个 pod 的高 `RESTARTS` 计数表明反复的 OOM 终止。标签选择器 `app=gitlab-zoekt` 可能因您的 chart 版本或 operator 配置而异。

如果安装了 [kube-state-metrics](https://github.com/kubernetes/kube-state-metrics)，您还可以在 Prometheus 或 Grafana 中监控以下指标：
- `kube_pod_container_status_last_terminated_reason{reason="OOMKilled"}`：因 OOM 终止的 pod。
- `kube_pod_container_status_waiting_reason{reason="CrashLoopBackOff"}`：处于崩溃循环的 pod。
- `kube_pod_container_status_restarts_total`：每个容器的累计重启次数。快速增加表明重复崩溃。

webserver 在端口 `6070` 的 `/metrics` 处公开了 `process_resident_memory_bytes`。如果您已将 Prometheus 配置为直接抓取 webserver pod，则可以使用该指标来监控 webserver 常驻内存随时间的使用情况。

对于 VM 和裸机部署，请检查系统日志以查找 OOM 事件：

```shell
sudo journalctl -k | grep -i "oom\|killed process"
```

<a id="recover-from-an-out-of-memory-event"></a>

### 从内存不足事件中恢复

恢复步骤因遇到 OOM 错误的组件而异。

<a id="indexer-out-of-memory-errors"></a>

#### 索引器内存不足错误

如果索引器因 OOM 错误而反复被终止，请全局暂停索引，以在您调查期间停止所有节点上的所有新索引工作：

```shell
gitlab-rake gitlab:zoekt:pause_indexing
```

或从 UI 暂停索引：

前提条件：
- 管理员访问权限。

1. 在右上角，选择 **管理员**。
1. 在左侧边栏中，选择 **设置** > **搜索**。
1. 展开 **精确代码搜索**。
1. 选中 **暂停索引** 复选框。
1. 选择 **保存更改**。

在节点稳定后，恢复索引：

```shell
gitlab-rake gitlab:zoekt:resume_indexing
```

<a id="webserver-out-of-memory-errors"></a>

#### Webserver 内存不足错误

如果 webserver 因 OOM 错误而反复被终止，请在调查时禁用 Zoekt 搜索。这将停止向崩溃节点发送搜索流量，而不影响索引。

> [!note]
> 当 Zoekt 搜索被禁用时，代码搜索将回退到基本搜索模式。
> 如果 Elasticsearch 不可用，在基本搜索模式下只能进行项目范围内的代码搜索，这会增加 Gitaly 的负载。

前提条件：
- 管理员访问权限。

1. 在右上角，选择 **管理员**。
1. 在左侧边栏中，选择 **设置** > **搜索**。
1. 展开 **精确代码搜索**。
1. 清除 **启用搜索** 复选框。
1. 选择 **保存更改**。

稳定节点后，重新启用搜索：

1. 在右上角，选择 **管理员**。
1. 在左侧边栏中，选择 **设置** > **搜索**。
1. 展开 **精确代码搜索**。
1. 选中 **启用搜索** 复选框。
1. 选择 **保存更改**。

<a id="reduce-memory-pressure"></a>

### 减少内存压力

如果您的节点规模适当但仍面临内存压力，请调整以下设置以减少内存使用。

<a id="reduce-parallel-indexing-processes"></a>

#### 减少并行索引进程数

前提条件：
- 管理员访问权限。

要减少峰值索引器内存，请降低每个索引任务的并行进程数：

1. 在右上角，选择 **管理员**。
1. 在左侧边栏中，选择 **设置** > **搜索**。
1. 展开 **精确代码搜索**。
1. 将 **每个索引任务的并行进程数** 设置为 `1`。
1. 选择 **保存更改**。

<a id="reduce-concurrent-indexing-tasks"></a>

#### 减少并发索引任务数

前提条件：
- 管理员访问权限。

要减少同时运行的索引任务数量，请降低 **索引 CPU 与任务乘数** 值：

1. 在右上角，选择 **管理员**。
1. 在左侧边栏中，选择 **设置** > **搜索**。
1. 展开 **精确代码搜索**。
1. 降低 **索引 CPU 与任务乘数** 值（例如，降至 `0.5`）。
1. 选择 **保存更改**。

<a id="increase-force-reindexing-probability"></a>

#### 提高强制重新索引概率

Zoekt webserver 将索引分片内存映射。随着时间的推移，增量索引会累积许多小分片，从而增加打开的 mmap 句柄数量。强制重新索引会完全重建索引，将分片合并为更少、更大的文件，从而减少内存开销。

前提条件：
- 管理员访问权限。

要减少分片累积，请提高强制重新索引概率：

1. 在右上角，选择 **管理员**。
1. 在左侧边栏中，选择 **设置** > **搜索**。
1. 展开 **精确代码搜索**。
1. 增加 **随机强制重索引的概率（百分比）** 值。
   默认值为 `0.25`（0.25%）。例如，将其设置为 `1`，以强制大约每 100 个增量索引任务中就有 1 个进行重新索引。
1. 选择 **保存更改**。

<a id="right-size-the-node"></a>

### 节点规模调整

如果调整设置不能解决反复出现的 OOM 事件，则该节点需要更多内存。有关根据索引大小分配内存的指导，请参阅 [规模建议](_index.md#sizing-recommendations)。

对于 Kubernetes 部署，请在您的 Helm chart 的 `values.yaml` 中增加内存请求和限制。确保内存限制等于或高于规模表中针对您磁盘层级的建议值。

对于 VM 和裸机部署，请根据规模表迁移到更大的实例类型，或添加更多节点以将索引分布在更多的机器上。

调整规模后，运行健康检查以确认节点已恢复：

```shell
gitlab-rake gitlab:zoekt:health
```

<a id="verify-zoekt-node-connections"></a>

## 验证 Zoekt 节点连接

要验证您的 Zoekt 节点是否已正确配置和连接，请在 [Rails 控制台会话](../../administration/operations/rails_console.md#starting-a-rails-console-session) 中：

- 检查已配置的 Zoekt 节点总数：

  ```ruby
  Search::Zoekt::Node.count
  ```

- 检查有多少节点在线：

  ```ruby
  Search::Zoekt::Node.online.count
  ```

或者，您也可以使用 `gitlab:zoekt:info` Rake 任务。

如果在线节点数低于已配置的节点数，或者在配置了节点时为零，则极狐GitLab 与 Zoekt 节点之间可能存在连接问题。

<a id="debug-zoekt-connection-errors"></a>

## 调试 Zoekt 连接错误

当您遇到 Zoekt 的连接问题时，了解请求流程并系统地验证架构中的每个组件非常重要。

<a id="zoekt-architecture"></a>

### Zoekt 架构

Zoekt 使用一个统一的二进制文件（`gitlab-zoekt`），它可以在两种模式下运行：
- 索引器模式，用于从 Gitaly 索引仓库
- Webserver 模式，用于处理搜索请求

基本搜索流程是：

```plaintext
GitLab Rails → Zoekt webserver
```

对于 Helm chart（Kubernetes）部署，架构包括用于负载均衡的额外网关组件：

```plaintext
GitLab Rails → 外部网关（NGINX） → 内部网关（NGINX） → Zoekt webserver
```

这些网关组件是 Helm chart 部署的一部分，而不是 Zoekt 的内部组件。它们是 NGINX 代理，用于将请求分发到多个 Zoekt webserver 实例，并处理路由、负载均衡和可选的 TLS 终结。

有关 Zoekt 架构设计的更多信息，请参阅 [使用 Zoekt 进行代码搜索](https://handbook.gitlab.com/handbook/engineering/architecture/design-documents/code_search_with_zoekt/)。

<a id="verify-network-reachability"></a>

### 验证网络可达性

要验证 Zoekt 网关可以从您的极狐GitLab Rails pod 访问，[运行健康检查](_index.md#run-a-health-check)：

```shell
gitlab-rake gitlab:zoekt:health
```

此任务验证从 Rails 到 Zoekt 的连通性，并报告总体状态为 `HEALTHY`、`DEGRADED` 或 `UNHEALTHY`。如果健康检查失败，则极狐GitLab 与您的 Zoekt 基础设施之间可能存在网络连接问题。

要检查节点状态和配置，请运行以下 Rake 任务：

```shell
gitlab-rake gitlab:zoekt:info
```

要查看包括 URL 在内的详细节点信息，请在 [Rails 控制台](../../administration/operations/rails_console.md#starting-a-rails-console-session) 中运行以下命令：

```ruby
# 查看所有节点属性，包括 URL
Search::Zoekt::Node.all.map(&:attributes)
```

- `search_base_url` 应指向 Zoekt webserver 或 Kubernetes 中的外部网关（例如 `http://gitlab-zoekt:8080/`）。
- `index_base_url` 应指向 Zoekt 索引器。

如果您在搜索时收到 `404` 响应，则请求可能未正确路由。此错误表明问题很可能出在网关配置而不是网络连接上。

<a id="monitor-zoekt-logs"></a>

### 监控 Zoekt 日志

对于 Helm chart（Kubernetes）部署，请监控 Zoekt 组件日志以识别连接问题。

`StatefulSet` 包含三个容器：

```shell
# 监控 webserver 日志（来自 Rails 的搜索请求）
kubectl logs -f statefulset/gitlab-zoekt -c zoekt-webserver -n <your_namespace>

# 监控索引器日志（仓库索引）
kubectl logs -f statefulset/gitlab-zoekt -c zoekt-indexer -n <your_namespace>

# 监控内部网关日志（外部网关和 webserver 之间的 NGINX 代理）
kubectl logs -f statefulset/gitlab-zoekt -c zoekt-internal-gateway -n <your_namespace>
```

如果您使用的是外部网关部署，您还可以监控外部网关日志：

```shell
# 监控外部网关日志（来自 Rails 的传入请求的 NGINX 代理）
kubectl logs -f deployment/gitlab-zoekt-gateway -c zoekt-external-gateway -n <your_namespace>
```

在监控这些日志的同时，从极狐GitLab UI 运行测试搜索。日志应显示请求正在被处理。如果日志中没有出现请求，则 Rails 和 Zoekt 之间可能存在网络路由问题。

<a id="run-test-searches-from-the-ui"></a>

### 从 UI 运行测试搜索

在监控 Zoekt 日志时，您可以从极狐GitLab UI 运行测试搜索：
- 在项目中搜索特定节点。
- 在群组中搜索以查询多个节点。
- 全局搜索以查询所有节点。

如果搜索失败，请检查 Rails 应用程序日志以获取详细错误信息：

```shell
# 对于使用 Linux 软件包的安装
tail -f /var/log/gitlab/gitlab-rails/application_json.log | grep -i zoekt

# 对于自编译安装
tail -f log/application_json.log | grep -i zoekt
```

查找连接错误、超时或身份验证失败，这些可能表明极狐GitLab 与您的 Zoekt 基础设施之间存在网络问题。

<a id="verify-pod-and-service-status"></a>

### 验证 pod 和服务状态

对于 Helm chart（Kubernetes）部署，请检查您的 Zoekt pod 和服务的状态：

```shell
# 检查 pod 状态
kubectl get pods -n <your_namespace> -l app=gitlab-zoekt

# 检查 `StatefulSet` 状态
kubectl get statefulset gitlab-zoekt -n <your_namespace>

# 检查服务端点
kubectl get endpoints gitlab-zoekt -n <your_namespace>

# 描述服务以查看配置
kubectl describe service gitlab-zoekt -n <your_namespace>
```

确保所有 pod 都处于运行状态，并且服务具有有效的端点。如果 pod 未运行或端点缺失，则您的 Zoekt 部署可能存在配置问题。

有关部署架构的更多信息，请参阅：
- [外部网关部署配置](https://jihulab.com/gitlab-cn/charts/gitlab-zoekt/-/blob/main/templates/deployment.yaml)
- [`StatefulSet` 配置（索引器、webserver 和内部网关）](https://jihulab.com/gitlab-cn/charts/gitlab-zoekt/-/blob/main/templates/stateful_sets.yaml)

<a id="error-taskrequest-responded-with-401"></a>

## 错误：`TaskRequest responded with [401]`

在您的 Zoekt 索引器日志中，您可能会看到 `TaskRequest responded with [401]`。此错误表明 Zoekt 索引器未能通过极狐GitLab 的身份验证。

要解决此问题，请验证 `gitlab-shell-secret` 是否正确配置，并在您的极狐GitLab 实例和 Zoekt 索引器之间保持一致。例如，以下命令的输出必须与您 `gitlab.rb` 中的 `gitlab-shell-secret` 匹配：

```shell
kubectl get secret gitlab-shell-secret -o jsonpath='{.data.secret}' -n your_zoekt_namespace | base64 -d
```

<a id="error-missing-selected-alpn-property"></a>

## 错误：`missing selected ALPN property`

当您在 Zoekt 网关前面使用外部负载均衡器时，您可能会在极狐GitLab 日志中看到以下错误：

```plaintext
rpc error: code = Unavailable desc = connection error: desc = "transport: authentication handshake failed: credentials: cannot check peer: missing selected ALPN property"
```

当负载均衡器不支持或不通过 ALPN（应用层协议协商）宣传 HTTP/2 时，会出现此错误。Zoekt 依赖 gRPC 进行节点间通信，这需要 HTTP/2 支持。

要解决此问题，请执行以下操作之一：

- 在负载均衡器上启用 HTTP/2 支持（推荐）：
  1. 配置您的负载均衡器以通过 ALPN 支持并宣传 HTTP/2：
     - 对于 HAProxy，在您的后端中，确保已配置 `alpn h2,http/1.1`。
     - 对于 NGINX，在您的 server 块中使用：
       - 在 NGINX 1.25.1 及更高版本中，使用 `http2 on;`。
       - 在 NGINX 1.25.0 及更早版本中，使用 `listen 443 ssl http2;`。
  1. 验证 HTTP/2 支持：

     ```shell
     curl --verbose --http2 "https://your-zoekt-gateway-url/health" 2>&1 | grep ALPN
     ```

     您应该看到类似以下的输出：

     ```plaintext
     * ALPN, server accepted to use h2
     ```

- 使用 TLS 透传：
  如果您的负载均衡器无法支持 HTTP/2，请将负载均衡器配置为 TLS 透传。这样，Zoekt 网关可以直接处理 TLS 终结，从而确保正确的 ALPN 协商。要使用 TLS 透传，请在 Zoekt 网关上配置有效的 TLS 证书：

  1. 对于 Helm chart 部署，在您的 `values.yaml` 中配置证书：

     ```yaml
     gateway:
       tls:
         certificate:
           enabled: true
           secretName: zoekt-gateway-cert
     ```

  1. 配置您的负载均衡器以透传加密流量而不终结 TLS。