---
stage: GitLab Delivery
group: Operate
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
title: 使用 Prometheus 监控 极狐GitLab
---

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: 私有化部署

{{< /details >}}

[Prometheus](https://prometheus.io) 是一款强大的时序监控服务，为监控 极狐GitLab 和其他软件产品提供了灵活的平台。

极狐GitLab 提供与 Prometheus 集成的开箱即用监控，可对 极狐GitLab 服务进行高质量的时序监控。

本页列出的 Prometheus 和各种导出器均捆绑在 Linux 软件包中。请查看各导出器的文档，了解其添加的时间线。对于自行编译的安装，您必须自行安装。在后续版本中，将捕获更多 极狐GitLab 指标。

Prometheus 服务默认开启。

Prometheus 及其导出器不对用户进行认证，任何可访问它们的人均可使用。

<a id="how-prometheus-works"></a>

## Prometheus 工作原理

Prometheus 通过定期连接数据源，并通过[各种导出器](#bundled-software-metrics)采集其性能指标。要查看和处理这些监控数据，您可以
[直接连接到 Prometheus](#viewing-performance-metrics)，或使用
[Grafana](https://grafana.com) 之类的仪表板工具。

<a id="configuring-prometheus"></a>

## 配置 Prometheus

对于自行编译的安装，您必须自行安装和配置。

Prometheus 及其导出器默认开启。
Prometheus 以 `gitlab-prometheus` 用户身份运行，并监听
`http://localhost:9090`。默认情况下，Prometheus 仅可从 极狐GitLab 服务器本身访问。
每个导出器都会自动设置为 Prometheus 的监控目标，除非单独禁用。

要禁用 Prometheus 及其所有导出器，以及将来添加的任何导出器：

1. 编辑 `/etc/gitlab/gitlab.rb`
1. 添加或查找并取消注释以下行，确保它们设置为 `false`：

   ```ruby
   prometheus_monitoring['enable'] = false
   sidekiq['metrics_enabled'] = false

   # 已默认设置为 `false`，但您可以显式禁用以确保万无一失
   puma['exporter_enabled'] = false
   ```

1. 保存文件并[重新配置 极狐GitLab](../../restart_gitlab.md#reconfigure-a-linux-package-installation) 以使更改生效。

<a id="changing-the-port-and-address-prometheus-listens-on"></a>

### 更改 Prometheus 监听的端口和地址

> [!warning]
> 您可以更改 Prometheus 监听的端口，但不建议这样做。
> 此更改可能会影响或与运行在 极狐GitLab 服务器上的其他服务发生冲突。风险自负。

要从 极狐GitLab 服务器外部访问 Prometheus，
请更改 Prometheus 监听的地址/端口：

1. 编辑 `/etc/gitlab/gitlab.rb`
1. 添加或查找并取消注释以下行：

   ```ruby
   prometheus['listen_address'] = 'localhost:9090'
   ```

   将 `localhost:9090` 替换为您希望 Prometheus 监听的地址或端口。如果您想允许非 `localhost` 的主机访问 Prometheus，可省略主机部分，或使用 `0.0.0.0` 允许公开访问：

   ```ruby
   prometheus['listen_address'] = ':9090'
   # or
   prometheus['listen_address'] = '0.0.0.0:9090'
   ```

1. 保存文件并[重新配置 极狐GitLab](../../restart_gitlab.md#reconfigure-a-linux-package-installation) 以使更改生效

<a id="adding-custom-scrape-configurations"></a>

### 添加自定义抓取配置

您可以通过在 `/etc/gitlab/gitlab.rb` 中编辑 `prometheus['scrape_configs']`，使用
[Prometheus 抓取目标配置](https://prometheus.io/docs/prometheus/latest/configuration/configuration/#%3Cscrape_config%3E) 语法，为 Linux 软件包绑定的
Prometheus 配置额外的抓取目标。

以下是一个抓取 `http://1.1.1.1:8060/probe?param_a=test&param_b=additional_test` 的配置示例：

```ruby
prometheus['scrape_configs'] = [
  {
    'job_name': 'custom-scrape',
    'metrics_path': '/probe',
    'params' => {
      'param_a' => ['test'],
      'param_b' => ['additional_test'],
    },
    'static_configs' => [
      'targets' => ['1.1.1.1:8060'],
    ],
  },
]
```

<a id="standalone-prometheus-using-the-linux-package"></a>

### 使用 Linux 软件包搭建独立 Prometheus

您可以使用 Linux 软件包配置一台独立的监控节点，运行 Prometheus。
可以配置外部 [Grafana](../performance/grafana_configuration.md) 连接到此监控节点以展示仪表板。

对于[多节点 极狐GitLab 部署](../../reference_architectures/_index.md)，建议使用独立的监控节点。

以下步骤是使用 Linux 软件包配置运行 Prometheus 的监控节点所需的最小配置：

1. SSH 进入监控节点。
1. 按照 极狐GitLab 下载页面上的**步骤 1 和 2** [安装](https://gitlab.cn/install/) 您所需的 Linux 软件包，但不要执行后续步骤。
1. 确保收集 Consul 服务器节点的 IP 地址或 DNS 记录，以供下一步使用。
1. 编辑 `/etc/gitlab/gitlab.rb` 并添加以下内容：

   ```ruby
   roles ['monitoring_role']

   external_url 'http://gitlab.example.com'

   # Prometheus
   prometheus['listen_address'] = '0.0.0.0:9090'
   prometheus['monitor_kubernetes'] = false

   # 启用 Prometheus 的服务发现
   consul['enable'] = true
   consul['monitoring_service_discovery'] = true
   consul['configuration'] = {
      retry_join: %w(10.0.0.1 10.0.0.2 10.0.0.3), # 地址可以是 IP 或 FQDN
   }

   # Nginx - 用于 Grafana 访问
   nginx['enable'] = true
   ```

1. 运行 `sudo gitlab-ctl reconfigure` 以编译配置。

下一步是告诉所有其他节点监控节点的位置：

1. 编辑 `/etc/gitlab/gitlab.rb`，并添加或查找并取消注释以下行：

   ```ruby
   # 可以是 FQDN 或 IP
   gitlab_rails['prometheus_address'] = '10.0.0.1:9090'
   ```

   其中 `10.0.0.1:9090` 是 Prometheus 节点的 IP 地址和端口。

1. 保存文件并[重新配置 极狐GitLab](../../restart_gitlab.md#reconfigure-a-linux-package-installation) 以使更改生效。

在通过 `consul['monitoring_service_discovery'] = true` 启用基于服务发现的监控后，
请确保未在 `/etc/gitlab/gitlab.rb` 中设置 `prometheus['scrape_configs']`。在 `/etc/gitlab/gitlab.rb` 中同时设置
`consul['monitoring_service_discovery'] = true` 和 `prometheus['scrape_configs']` 会导致错误。

<a id="using-an-external-prometheus-server"></a>

### 使用外部 Prometheus 服务器

> [!warning]
> Prometheus 和大多数导出器不支持身份认证。我们不建议将它们暴露在本地网络之外。

需要进行一些配置更改，以允许外部 Prometheus 服务器监控 极狐GitLab。

要使用外部 Prometheus 服务器：

1. 编辑 `/etc/gitlab/gitlab.rb`。
1. 禁用捆绑的 Prometheus：

   ```ruby
   prometheus['enable'] = false
   ```

1. 将每个捆绑服务的[导出器](#bundled-software-metrics)设置为监听网络地址，例如：

   ```ruby
   node_exporter['listen_address'] = '0.0.0.0:9100'
   gitlab_workhorse['prometheus_listen_addr'] = "0.0.0.0:9229"

   # Rails 节点
   gitlab_exporter['listen_address'] = '0.0.0.0'
   gitlab_exporter['listen_port'] = '9168'
   registry['debug_addr'] = '0.0.0.0:5001'

   # Sidekiq 节点
   sidekiq['listen_address'] = '0.0.0.0'

   # Redis 节点
   redis_exporter['listen_address'] = '0.0.0.0:9121'

   # PostgreSQL 节点
   postgres_exporter['listen_address'] = '0.0.0.0:9187'

   # Gitaly 节点
   gitaly['configuration'] = {
      # ...
      prometheus_listen_addr: '0.0.0.0:9236',
   }

   # Pgbouncer 节点
   pgbouncer_exporter['listen_address'] = '0.0.0.0:9188'
   ```

1. 如有必要，使用[官方安装说明](https://prometheus.io/docs/prometheus/latest/installation/) 安装和设置一个专用的 Prometheus 实例。
1. 在**所有** 极狐GitLab Rails（Puma、Sidekiq）服务器上，设置 Prometheus 服务器的 IP 地址和监听端口。例如：

   ```ruby
   gitlab_rails['prometheus_address'] = '192.168.0.1:9090'
   ```

1. 要抓取 NGINX 指标，您还必须配置 NGINX 以允许 Prometheus 服务器的
   IP。例如：

   ```ruby
   nginx['status']['options'] = {
         "server_tokens" => "off",
         "access_log" => "off",
         "allow" => "192.168.0.1",
         "deny" => "all",
   }
   ```

   如果有多个 Prometheus 服务器，您也可以指定多个 IP 地址：

   ```ruby
   nginx['status']['options'] = {
         "server_tokens" => "off",
         "access_log" => "off",
         "allow" => ["192.168.0.1", "192.168.0.2"],
         "deny" => "all",
   }
   ```

1. 要允许 Prometheus 服务器从[极狐GitLab 指标](#gitlab-metrics)端点拉取数据，请将 Prometheus
   服务器 IP 地址添加到[监控 IP 允许列表](../ip_allowlist.md)：

   ```ruby
   gitlab_rails['monitoring_whitelist'] = ['127.0.0.0/8', '192.168.0.1']
   ```

1. 由于我们将每个捆绑服务的[导出器](#bundled-software-metrics)设置为监听网络地址，
   请更新实例的防火墙，仅允许来自您的 Prometheus IP 的流量访问已启用的导出器。可用的导出器服务及其[相应端口](../../package_information/defaults.md#ports)的完整参考列表可供查阅。
1. [重新配置 极狐GitLab](../../restart_gitlab.md#reconfigure-a-linux-package-installation) 以应用更改。
1. 编辑 Prometheus 服务器的配置文件。
1. 将各节点的导出器添加到 Prometheus 服务器的
   [抓取目标配置](https://prometheus.io/docs/prometheus/latest/configuration/configuration/#%3Cscrape_config%3E) 中。
   例如，使用 `static_configs` 的示例片段：

   ```yaml
   scrape_configs:
     - job_name: nginx
       static_configs:
         - targets:
           - 1.1.1.1:8060
     - job_name: redis
       static_configs:
         - targets:
           - 1.1.1.1:9121
     - job_name: postgres
       static_configs:
         - targets:
           - 1.1.1.1:9187
     - job_name: node
       static_configs:
         - targets:
           - 1.1.1.1:9100
     - job_name: gitlab-workhorse
       static_configs:
         - targets:
           - 1.1.1.1:9229
     - job_name: gitlab-rails
       metrics_path: "/-/metrics"
       scheme: https
       static_configs:
         - targets:
           - 1.1.1.1
     - job_name: gitlab-sidekiq
       static_configs:
         - targets:
           - 1.1.1.1:8082
     - job_name: gitlab_exporter_database
       metrics_path: "/database"
       static_configs:
         - targets:
           - 1.1.1.1:9168
     - job_name: gitlab_exporter_sidekiq
       metrics_path: "/sidekiq"
       static_configs:
         - targets:
           - 1.1.1.1:9168
     - job_name: gitaly
       static_configs:
         - targets:
           - 1.1.1.1:9236
     - job_name: registry
       static_configs:
         - targets:
           - 1.1.1.1:5001
   ```

   > [!warning]
   > 该片段中的 `gitlab-rails` 任务假定 极狐GitLab 可通过 HTTPS 访问。如果您的
   > 部署未使用 HTTPS，则任务配置需调整为使用 `http` 方案和端口
   > 80。

1. 重新加载 Prometheus 服务器。

<a id="configure-the-storage-retention-size"></a>

### 配置存储保留大小

Prometheus 有几个用于配置本地存储的自定义标志：

- `storage.tsdb.retention.time`：何时删除旧数据。默认为 `15d`。如果此标志设置为非默认值，将覆盖
  `storage.tsdb.retention`。
- `storage.tsdb.retention.size`：（实验性）要保留的存储块的最大字节数。
  最旧的数据会先被删除。默认为 `0`（禁用）。此标志为实验性，未来版本可能会更改。支持的单位：`B`、`KB`、`MB`、`GB`、`TB`、`PB`、`EB`。例如，
  `512MB`。

要配置存储保留大小：

1. 编辑 `/etc/gitlab/gitlab.rb`：

   ```ruby
   prometheus['flags'] = {
     'storage.tsdb.path' => "/var/opt/gitlab/prometheus/data",
     'storage.tsdb.retention.time' => "7d",
     'storage.tsdb.retention.size' => "2GB",
     'config.file' => "/var/opt/gitlab/prometheus/prometheus.yml"
   }
   ```

1. 重新配置 极狐GitLab：

   ```shell
   sudo gitlab-ctl reconfigure
   ```

<a id="viewing-performance-metrics"></a>

## 查看性能指标

您可以访问 Prometheus 默认提供的仪表板 `http://localhost:9090`。

如果在您的 极狐GitLab 实例上启用了 SSL，由于 [HSTS](https://en.wikipedia.org/wiki/HTTP_Strict_Transport_Security)，您可能无法在使用相同 FQDN 的同一浏览器上同时访问
Prometheus 和 极狐GitLab。
[存在一个 极狐GitLab 测试项目](https://jihulab.com/gitlab-cn/multi-user-prometheus) 以提供访问，但在此期间有一些
变通方法：使用独立的 FQDN、使用服务器 IP、使用单独的浏览器访问 Prometheus、重置 HSTS，或
[使用 NGINX 代理](https://gitlab.cn/docs/omnibus/settings/nginx/#inserting-custom-nginx-settings-into-the-gitlab-server-block)。

Prometheus 收集的性能数据可以直接在
Prometheus 控制台中查看，或通过兼容的仪表板工具查看。
Prometheus 界面提供了一种[灵活的查询语言](https://prometheus.io/docs/prometheus/latest/querying/basics/)，用于处理收集到的数据，并可视化输出。
要使用功能更全面的仪表板，可以使用 Grafana，它
[官方支持 Prometheus](https://prometheus.io/docs/visualization/grafana/)。

<a id="sample-prometheus-queries"></a>

## Prometheus 查询示例

以下是一些可以使用的 Prometheus 查询示例。

> [!note]
> 这些示例可能不适用于所有设置。可能需要进一步调整。

- **% CPU 利用率**：`1 - avg without (mode,cpu) (rate(node_cpu_seconds_total{mode="idle"}[5m]))`
- **% 可用内存**：`((node_memory_MemAvailable_bytes / node_memory_MemTotal_bytes) or ((node_memory_MemFree_bytes + node_memory_Buffers_bytes + node_memory_Cached_bytes) / node_memory_MemTotal_bytes)) * 100`
- **传输数据量**：`rate(node_network_transmit_bytes_total{device!="lo"}[5m])`
- **接收数据量**：`rate(node_network_receive_bytes_total{device!="lo"}[5m])`
- **磁盘读取 IOPS**：`sum by (instance) (rate(node_disk_reads_completed_total[1m]))`
- **磁盘写入 IOPS**：`sum by (instance) (rate(node_disk_writes_completed_total[1m]))`
- **通过 极狐GitLab 事务计数的 RPS**：`sum(irate(gitlab_transaction_duration_seconds_count{controller!~'HealthController|MetricsController'}[1m])) by (controller, action)`

<a id="prometheus-as-a-grafana-data-source"></a>

## 将 Prometheus 作为 Grafana 数据源

Grafana 允许您将 Prometheus 性能指标导入为数据源，
并将这些指标渲染为图表和仪表板，这有助于可视化。

要为单服务器 极狐GitLab 设置添加 Prometheus 仪表板：

1. 在 Grafana 中创建一个新的数据源。
1. 对于**类型**，选择 `Prometheus`。
1. 命名您的数据源（例如 GitLab）。
1. 在**Prometheus 服务器 URL** 中，添加您的 Prometheus 监听地址。
1. 将**HTTP 方法** 设置为 `GET`。
1. 保存并测试您的配置，以验证其是否正常工作。

<a id="gitlab-metrics"></a>

## 极狐GitLab 指标

极狐GitLab 监控其自身内部服务指标，并在 `/-/metrics` 端点提供这些指标。与其他导出器不同，此端点需要进行认证，因为它与用户流量在同一 URL 和端口上提供。

了解更多关于[极狐GitLab 指标](gitlab_metrics.md) 的信息。

<a id="bundled-software-metrics"></a>

## 捆绑软件指标

Linux 软件包中捆绑的许多 极狐GitLab 依赖项都已预先配置为导出 Prometheus 指标。

<a id="node-exporter"></a>

### Node exporter

节点导出器允许您测量各种机器资源，例如
内存、磁盘和 CPU 利用率。

[了解更多关于节点导出器的信息](node_exporter.md)。

<a id="web-exporter"></a>

### Web exporter

Web 导出器是一个专用的指标服务器，允许将最终用户流量和 Prometheus 流量
分离到两个独立的应用程序中，以提高性能和可用性。

[了解更多关于 Web 导出器的信息](web_exporter.md)。

<a id="redis-exporter"></a>

### Redis exporter

Redis 导出器允许您测量各种 Redis 指标。

[了解更多关于 Redis 导出器的信息](redis_exporter.md)。

<a id="postgresql-exporter"></a>

### PostgreSQL exporter

PostgreSQL 导出器允许您测量各种 PostgreSQL 指标。

[了解更多关于 PostgreSQL 导出器的信息](postgres_exporter.md)。

<a id="pgbouncer-exporter"></a>

### PgBouncer exporter

PgBouncer 导出器允许您测量各种 PgBouncer 指标。

[了解更多关于 PgBouncer 导出器的信息](pgbouncer_exporter.md)。

<a id="registry-exporter"></a>

### Registry exporter

Registry 导出器允许您测量各种 Registry 指标。

[了解更多关于 Registry 导出器的信息](registry_exporter.md)。

<a id="gitlab-exporter"></a>

### 极狐GitLab exporter

极狐GitLab 导出器允许您测量从 Redis 和数据库中提取的各种 极狐GitLab 指标。

[了解更多关于 极狐GitLab 导出器的信息](gitlab_exporter.md)。

<a id="troubleshooting"></a>

## 故障排除

<a id="varoptgitlabprometheus-consumes-too-much-disk-space"></a>

### `/var/opt/gitlab/prometheus` 占用过多磁盘空间

如果您**未**使用 Prometheus 监控：

1. [禁用 Prometheus](_index.md#configuring-prometheus)。
1. 删除 `/var/opt/gitlab/prometheus` 下的数据。

如果您正在使用 Prometheus 监控：

1. 停止 Prometheus（在运行时删除数据可能导致数据损坏）：

   ```shell
   gitlab-ctl stop prometheus
   ```

1. 删除 `/var/opt/gitlab/prometheus/data` 下的数据。
1. 重新启动服务：

   ```shell
   gitlab-ctl start prometheus
   ```

1. 验证服务已启动并运行：

   ```shell
   gitlab-ctl status prometheus
   ```

1. 可选。[配置存储保留大小](_index.md#configure-the-storage-retention-size)。

<a id="monitoring-node-not-receiving-data"></a>

### 监控节点未收到数据

如果监控节点未收到任何数据，请检查导出器是否正在捕获数据：

```shell
curl "http[s]://localhost:<EXPORTER LISTENING PORT>/metrics"
```

或

```shell
curl "http[s]://localhost:<EXPORTER LISTENING PORT>/-/metrics"
```