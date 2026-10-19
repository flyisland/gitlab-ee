---
stage: Systems
group: Cloud Connector
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
title: Web 导出器（专用指标服务器）
---

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: 私有化部署

{{< /details >}}

通过从主应用服务器单独收集指标，提升极狐GitLab 监控的可靠性和性能。专用指标服务器将监控流量与用户请求隔离，避免指标收集影响应用性能。

对于中大型安装实例，这种分离可以在使用高峰期提供更一致的数据收集，并降低高负载期间丢失关键指标的风险。

<a id="how-gitlab-metrics-collection-works"></a>

## 极狐GitLab 指标收集的工作原理

使用 Prometheus 监控极狐GitLab 时，极狐GitLab 会运行各种收集器，对应用进行采样以获取与使用情况、负载和性能相关的数据。随后，极狐GitLab 可以通过运行一个或多个 Prometheus 导出器，将这些数据提供给 Prometheus 抓取器。Prometheus 导出器是一个 HTTP 服务器，它将指标数据序列化为 Prometheus 抓取器能够理解的格式。

> [!note]
> 本页介绍 Web 应用指标。
> 要导出后台作业指标，请了解如何[配置 Sidekiq 指标服务器](../../sidekiq/_index.md#configure-the-sidekiq-metrics-server)。

我们提供两种导出 Web 应用指标的机制：

- 通过主 Rails 应用。这意味着我们使用的应用服务器 Puma 通过其自身的 `/-/metrics` 端点提供指标数据。这是默认方式，在极狐GitLab 指标中有所描述。对于收集指标量较小的极狐GitLab 小型安装实例，您应使用此默认方式。
- 通过专用指标服务器。启用该服务器会使 Puma 启动一个额外的进程，其唯一职责就是提供指标。这种方式可为超大型极狐GitLab 安装实例带来更好的故障隔离和性能，但会额外占用内存。对于追求高性能和高可用性的中大型极狐GitLab 安装实例，我们推荐使用这种方式。

专用服务器和 Rails `/-/metrics` 端点提供相同的数据，因此它们在功能上等效，仅在性能特征上有所不同。

要启用专用服务器：

1. [启用 Prometheus](_index.md#configuring-prometheus)。
1. 编辑 `/etc/gitlab/gitlab.rb`，添加（或找到并取消注释）以下行。确保 `puma['exporter_enabled']` 设置为 `true`：

   ```ruby
   puma['exporter_enabled'] = true
   puma['exporter_address'] = "127.0.0.1"
   puma['exporter_port'] = 8083
   ```

1. 配置 Prometheus 抓取器：
   - 如果您使用的是极狐GitLab 内置的 Prometheus，请确保其 [`scrape_config` 指向 `localhost:8083/metrics`](_index.md#adding-custom-scrape-configurations)。
   - 如果您使用的是外部 Prometheus 服务器，请配置该[外部服务器以抓取新端点](_index.md#using-an-external-prometheus-server)。
1. 保存文件并[重新配置极狐GitLab](../../restart_gitlab.md#reconfigure-a-linux-package-installation)，以使更改生效。

现在可以从 `localhost:8083/metrics` 提供并抓取指标。

<a id="enable-https"></a>

## 启用 HTTPS

要通过 HTTPS 而非 HTTP 提供指标，请在导出器设置中启用 TLS：

1. 编辑 `/etc/gitlab/gitlab.rb`，添加（或找到并取消注释）以下行：

   ```ruby
   puma['exporter_tls_enabled'] = true
   puma['exporter_tls_cert_path'] = "/path/to/certificate.pem"
   puma['exporter_tls_key_path'] = "/path/to/private-key.pem"
   ```

1. 保存文件并[重新配置极狐GitLab](../../restart_gitlab.md#reconfigure-a-linux-package-installation)，以使更改生效。

启用 TLS 后，仍使用与前述相同的 `port` 和 `address`。指标服务器无法同时提供 HTTP 和 HTTPS。

<a id="troubleshooting"></a>

## 故障排除

<a id="docker-container-runs-out-of-space"></a>

### Docker 容器空间不足

在 Docker 中运行极狐GitLab 时，您的容器可能会空间不足。如果您启用了某些会增加空间占用的功能（例如 Web 导出器），就可能发生这种情况。

要解决此问题，请[更新您的 `shm-size`](../../../install/docker/troubleshooting.md#devshm-mount-not-having-enough-space-in-docker-container)。
