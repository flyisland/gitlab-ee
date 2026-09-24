---
stage: Tenant Scale
group: Gitaly
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
title: Gitaly 超时与重试
---

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: 私有化部署

{{< /details >}}

[Gitaly](../gitaly/_index.md) 提供两种可配置的超时类型：

- 调用超时，通过极狐GitLab 界面进行配置。
- 协商超时，通过 Gitaly 配置文件进行配置。

<a id="configure-the-call-timeouts"></a>

## 配置调用超时

配置以下调用超时，以确保长时间运行的 Gitaly 调用不会不必要地占用资源。

前提条件：

- 管理员访问权限。

要配置调用超时：

1. 在右上角，选择 **管理员**。
1. 在左侧边栏中，选择 **设置** > **偏好设置**。
1. 展开 **Gitaly 超时** 部分。
1. 根据需要设置各项超时。

<a id="available-call-timeouts"></a>

### 可用的调用超时

不同的 Gitaly 操作有不同的调用超时。

| 超时 | 默认值 | 描述 |
|:--------|:-----------|:------------|
| 默认 | 55 秒 | 大多数 Gitaly 调用的超时时间（不强制用于 `git` `fetch` 和 `push` 操作，或 Sidekiq 作业）。例如，检查仓库是否存在于磁盘上。确保在 Web 请求中进行的 Gitaly 调用不会超过整个请求超时。它应短于可为 [Puma](../../install/requirements.md#puma) 配置的 [worker 超时](../operations/puma.md#change-the-worker-timeout)。如果 Gitaly 调用超时超过了 worker 超时，则会使用 worker 超时的剩余时间，以避免不得不终止 worker。 |
| 快速 | 10 秒 | 用于请求中的快速 Gitaly 操作（有时会多次使用）的超时时间。例如，检查仓库是否存在于磁盘上。如果快速操作超过此阈值，则可能是存储分片存在问题。快速失败有助于维护极狐GitLab 实例的稳定性。 |
| 中等 | 30 秒 | 用于应快速（可能在请求中）但最好不要在单个请求中多次使用的 Gitaly 操作的超时时间。例如，加载 blob。应设置在默认和快速之间的超时。 |

<a id="configure-the-negotiation-timeouts"></a>

## 配置协商超时

{{< history >}}

- 在极狐GitLab 16.5 引入。

{{< /history >}}

您可能需要增加协商超时时间：

- 对于特别大的仓库。
- 当并行执行这些命令时。

您可以为以下内容配置协商超时：

- `git-upload-pack(1)`，当您执行 `git fetch` 时由 Gitaly 节点调用。
- `git-upload-archive(1)`，当您执行 `git archive --remote` 时由 Gitaly 节点调用。

要配置这些超时：

{{< tabs >}}

{{< tab title="Linux 软件包 (Omnibus)" >}}

编辑 `/etc/gitlab/gitlab.rb`：

```ruby
gitaly['configuration'] = {
    timeout: {
        upload_pack_negotiation: '10m',      # 10 分钟
        upload_archive_negotiation: '20m',   # 20 分钟
    }
}
```

{{< /tab >}}

{{< tab title="自编译 (源代码)" >}}

编辑 `/home/git/gitaly/config.toml`：

```toml
[timeout]
upload_pack_negotiation = "10m"
upload_archive_negotiation = "20m"
```

{{< /tab >}}

{{< /tabs >}}

对于这些值，请使用 Go 中 [`ParseDuration`](https://pkg.go.dev/time#ParseDuration) 的格式。

这些超时仅影响远程 Git 操作的[协商阶段](https://git-scm.com/docs/pack-protocol/2.2.3#_packfile_negotiation)，而不是整个传输过程。

<a id="gitaly-client-retries"></a>

## Gitaly 客户端重试

{{< history >}}

- 在极狐GitLab 18.10 引入。

{{< /history >}}

Gitaly 有时会短暂不可用。例如，在极狐GitLab 升级期间。尤其是在 Kubernetes 上运行 Gitaly 时，Pod 的启动和重启需要几秒钟。

为了防止极狐GitLab 在 Gitaly 短暂不可用时向客户端返回错误，可以配置 Gitaly 客户端重试。当配置了 Gitaly 客户端重试且 Gitaly 不可用时，Gitaly 客户端（例如 Rails（极狐GitLab 应用）、Workhorse 和极狐GitLab Shell）会以指数退避的方式重试请求。

可以配置两个参数：

- `max_attempts`：最大重试次数，介于 1 到 5 之间。
- `max_backoff`：客户端停止重试前的最长时间。值必须是一个持续时间字符串，例如 `1.4s` 或 `10s`。

退避乘数设置为 `2`，初始退避由这两个参数派生。

<a id="configuration-guidelines"></a>

### 配置指南

正确的配置取决于您的极狐GitLab 实例设置以及在此类事件发生时 Gitaly 保持不可用的时长：

- 在 Kubernetes 上，一个 Gitaly Pod 可能需要大约 10 到 12 秒才能启动，具体取决于云提供商。这个时间包括卷被挂载并附加到 Pod 上所需的时间。
- 对于 Linux 软件包实例，Gitaly 的重启可能要快得多，因为重启 Gitaly 只是一个进程重启。

还要记住，Gitaly 可以配置一个优雅关闭超时。当 Gitaly 正在关闭时，新请求会被拒绝，但 gRPC 服务器会继续处理正在进行的请求，直到：

- 所有请求都被处理完毕。
- 关闭超时到期。

这个优雅关闭超时会影响 Gitaly 对于新请求保持不可用的时长。

您应该将客户端重试的 `max_backoff` 配置为等于或大于优雅关闭时间加（重新）启动时间的总和。

<a id="configure-client-retries"></a>

### 配置客户端重试

以下配置适用于 Rails（极狐GitLab 应用）、Workhorse 和极狐GitLab Shell，并且相同的配置适用于所有客户端。

提供的值是示例，不应被视为指导值。

{{< tabs >}}

{{< tab title="Linux 软件包 (Omnibus)" >}}

使用以下配置更新您的 `gitlab.rb` 文件：

```ruby
gitlab_rails['gitaly_client_max_attempts'] = 5
gitlab_rails['gitaly_client_max_backoff'] = '1.4s'
```

{{< /tab >}}

{{< tab title="Helm Chart (Kubernetes)" >}}

使用以下配置更新您的 `values.yml` 文件：

```yaml
global:
  gitaly:
    client:
      maxAttempts: 5
      maxBackoff: '1.4s'
```

{{< /tab >}}

{{< /tabs >}}