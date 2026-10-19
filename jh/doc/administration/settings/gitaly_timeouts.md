---
stage: Tenant Scale
group: Gitaly
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
title: Gitaly 超时和重试
---

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: 私有化部署

{{< /details >}}

[Gitaly](../gitaly/_index.md) 提供两种可配置的超时：

- 调用超时，通过极狐GitLab UI 配置。
- 协商超时，通过 Gitaly 配置文件配置。

<a id="configure-the-call-timeouts"></a>

## 配置调用超时

配置以下调用超时，以确保长时间运行的 Gitaly 调用不会无谓地占用资源。

先决条件：

- 管理员访问权限。

要配置调用超时：

1. 在右上角，选择**管理员**。
1. 在左侧边栏中，选择**设置** > **偏好设置**。
1. 展开 **Gitaly 超时**部分。
1. 根据需要设置每个超时。

<a id="available-call-timeouts"></a>

### 可用的调用超时

不同的 Gitaly 操作有不同的调用超时。

| 超时 | 默认值    | 描述 |
|:--------|:-----------|:------------|
| 默认 | 55 秒 | 大多数 Gitaly 调用的超时（对 `git` `fetch` 和 `push` 操作或 Sidekiq 作业不强制执行）。例如，检查代码仓库是否存在于磁盘上。确保在 Web 请求中发起的 Gitaly 调用不会超过整个请求超时。它应短于可为 [Puma](../../install/requirements.md#puma) 配置的[工作进程超时](../operations/puma.md#change-the-worker-timeout)。如果 Gitaly 调用超时超过工作进程超时，则使用工作进程超时的剩余时间，以避免必须终止工作进程。 |
| 快速    | 10 秒 | 请求中使用的快速 Gitaly 操作的超时，有时会多次使用。例如，检查代码仓库是否存在于磁盘上。如果快速操作超过此阈值，则存储分片可能存在问题。快速失败有助于保持极狐GitLab 实例的稳定性。 |
| 中等  | 30 秒 | 应快速完成（可能在请求中）但最好不要在请求中多次使用的 Gitaly 操作的超时。例如，加载 blob。应设置在默认和快速之间的超时。 |

默认情况下，**默认**超时不能设置为高于 `57` 秒。更多信息，请参见[无法将 Gitaly 默认超时提高到 57 秒以上](#unable-to-raise-gitaly-default-timeout-above-57-seconds)。

<a id="configure-the-negotiation-timeouts"></a>

## 配置协商超时

您可能需要增加协商超时：

- 对于特别大的代码仓库。
- 在并行执行这些命令时。

您可以为以下项配置协商超时：

- `git-upload-pack(1)`，当您执行 `git fetch` 时由 Gitaly 节点调用。
- `git-upload-archive(1)`，当您执行 `git archive --remote` 时由 Gitaly 节点调用。

要配置这些超时：

{{< tabs >}}

{{< tab title="Linux 软件包（Omnibus）" >}}

编辑 `/etc/gitlab/gitlab.rb`：

```ruby
gitaly['configuration'] = {
    timeout: {
        upload_pack_negotiation: '10m',      # 10 minutes
        upload_archive_negotiation: '20m',   # 20 minutes
    }
}
```

{{< /tab >}}

{{< tab title="自行编译（源代码）" >}}

编辑 `/home/git/gitaly/config.toml`：

```toml
[timeout]
upload_pack_negotiation = "10m"
upload_archive_negotiation = "20m"
```

{{< /tab >}}

{{< /tabs >}}

对于这些值，请使用 Go 中 [`ParseDuration`](https://pkg.go.dev/time#ParseDuration)的格式。

这些超时仅影响远程 Git 操作的[协商阶段](https://git-scm.com/docs/pack-protocol/2.2.3#_packfile_negotiation)，而不影响整个传输过程。

<a id="gitaly-client-retries"></a>

## Gitaly 客户端重试

Gitaly 有时可能会短暂不可用。例如，在极狐GitLab 升级期间。尤其是在 Kubernetes 上运行 Gitaly 时，
Pod 的启动和重启需要几秒钟。

为防止极狐GitLab 在短暂不可用时向客户端返回错误，请配置 Gitaly 客户端重试。当
配置了 Gitaly 客户端重试且 Gitaly 不可用时，Gitaly 客户端（如 Rails（极狐GitLab 应用）、
Workhorse 和 GitLab Shell）会以指数退避方式重试请求。

可以配置两个参数：

- `max_attempts`：最大重试次数，介于 2 和 5 之间。
- `max_backoff`：客户端停止重试前的最大时间量。值必须是时长字符串，例如
  `1.4s` 或 `10s`。

退避乘数设置为 `2`，初始退避由这两个参数推导得出。

<a id="configuration-guidelines"></a>

### 配置指南

正确的配置取决于您的极狐GitLab 实例设置，以及发生此类事件时 Gitaly 保持不可用的时长：

- 在 Kubernetes 上，Gitaly Pod 启动大约需要 10 到 12 秒，具体取决于云提供商。该
  时间包括将卷附加并挂载到 Pod 上所需的时间。
- 对于 Linux 软件包实例，Gitaly 可能重启得快得多，因为重启 Gitaly 只是进程重启。

另请注意，Gitaly 可以配置优雅关闭超时。当 Gitaly 正在关闭时，新请求会被拒绝，但 gRPC 服务器会继续处理进行中的请求，直到：

- 它们全部得到处理。
- 关闭超时到期。

此优雅关闭超时会影响 Gitaly 对新请求保持不可用的时长。

您应将客户端重试配置为 `max_backoff` 等于或大于优雅关闭时间 +（重）启动时间之和。

<a id="configure-client-retries"></a>

### 配置客户端重试

以下配置适用于 Rails（极狐GitLab 应用）、Workhorse 和 GitLab Shell，且相同的
配置适用于所有客户端。

提供的值仅为示例，不应视为指南。

{{< tabs >}}

{{< tab title="Linux 软件包（Omnibus）" >}}

使用这些配置更新您的 `gitlab.rb` 文件：

```ruby
gitlab_rails['gitaly_client_max_attempts'] = 5
gitlab_rails['gitaly_client_max_backoff'] = '1.4s'
```

{{< /tab >}}

{{< tab title="Helm chart（Kubernetes）" >}}

使用这些配置更新您的 `values.yml` 文件：

```yaml
global:
  gitaly:
    client:
      maxAttempts: 5
      maxBackoff: '1.4s'
```

{{< /tab >}}

{{< /tabs >}}

<a id="troubleshooting"></a>

## 故障排除

使用 Gitaly 超时时，您可能会遇到以下问题。

<a id="unable-to-raise-gitaly-default-timeout-above-57-seconds"></a>

### 无法将 Gitaly 默认超时提高到 57 秒以上

> [!warning]
> 仅在需要时提高这些值。更高的工作进程超时意味着缓慢或卡住的请求会占用 Puma 工作进程更长时间，
> 从而降低实例容量。提高 Gitaly **默认**超时的常见原因包括：位于
> 慢速存储上的超大代码仓库、开销高昂的差异或比较视图，或性能下降的 Gitaly 集群节点。对于导入、
> 镜像或内务处理等后台工作，优先卸载到 Sidekiq，它不受此上限约束。

默认情况下，[**默认**超时](#available-call-timeouts)不能提高到 `57` 秒以上。尝试将超时设置得更高会产生验证错误：

```plaintext
Gitaly timeout default must be less than or equal to 57
```

此限制由三个相互作用的超时施加：

- `puma['worker_timeout']`：每个工作进程的 Puma 超时。默认为 `60` 秒。更多信息，
  请参见[更改工作进程超时](../operations/puma.md#change-the-worker-timeout)。
- `gitlab_rails['max_request_duration_seconds']`#限制 Gitaly
  **默认**超时的极狐GitLab 应用设置。默认为 `(worker_timeout * 0.95).ceil` = `57` 秒。此设置必须
  严格小于 `puma['worker_timeout']`。
- `GITLAB_RAILS_RACK_TIMEOUT`：`Rack::Timeout`中间件 `service_timeout`。默认为 `60` 秒。
  此超时独立于其他两个，无论其他两个如何配置，它都会在此值处终止请求。

要将 Gitaly **默认**超时提高到 57 秒以上，必须同时提高这三个值。例如，
要允许 Gitaly **默认**超时为 `110` 秒：

1. 编辑 `/etc/gitlab/gitlab.rb`：

   ```ruby
   puma['worker_timeout'] = 120
   gitlab_rails['max_request_duration_seconds'] = 114
   gitlab_rails['env'] = {
     'GITLAB_RAILS_RACK_TIMEOUT' => 120
   }
   ```

1. 重新配置极狐GitLab：

   ```shell
   sudo gitlab-ctl reconfigure
   ```

1. 在右上角，选择**管理员**。
1. 在左侧边栏中，选择**设置** > **偏好设置**。
1. 展开 **Gitaly 超时**。
1. 将**默认超时**设置为新的所需值（最高为 `max_request_duration_seconds`）。

   建议留出少量余量。内置默认值使用 5% 的间隔
   （`max_request_duration_seconds = (worker_timeout * 0.95).ceil`），因此 Rails 请求截止时间会在 Puma
   达到其工作进程超时之前触发。

   `GITLAB_RAILS_RACK_TIMEOUT` 本身不会提高 Gitaly 上限。
   `Settings.gitlab.max_request_duration_seconds` 才是应用设置验证器所查询的值，它由
   `gitlab_rails['max_request_duration_seconds']` 设置。但是，将 `GITLAB_RAILS_RACK_TIMEOUT` 保留为其默认值
   `60` 会导致 Rack 中间件终止任何超过 60 秒的请求（包括长时间的 Gitaly 调用），使其无法完成。
