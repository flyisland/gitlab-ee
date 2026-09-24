---
stage: Tenant Scale
group: Geo
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
title: 辅助站点的容器镜像仓库
---

{{< details >}}

- Tier: 专业版，旗舰版
- Offering: 私有化部署

{{< /details >}}

你可以在 **辅助** Geo 站点上设置一个容器镜像仓库，用于从 **主** Geo 站点的容器镜像仓库复制镜像。此容器镜像复制仅用于灾难恢复目的。

不要向 **辅助** Geo 站点的容器镜像仓库推送镜像，因为数据不会传播到 **主** 站点。

我们不建议从 **辅助** 站点拉取容器镜像仓库数据，因为数据可能过期。

> [!warning]
> **重要：** 容器镜像仓库元数据数据库与容器镜像复制是分开的。虽然容器镜像从主站点复制到辅助站点，但元数据数据库不会复制。在启用容器镜像仓库元数据数据库的情况下使用极狐GitLab Geo 时，必须为每个 Geo 站点（主站点和辅助站点）配置独立的外部 PostgreSQL 实例。容器镜像仓库元数据数据库不能使用极狐GitLab 管理的默认 PostgreSQL 数据库。每个站点的元数据数据库独立运行，它们之间不进行复制。有关设置说明，请参阅 [使用外部数据库](../../packages/container_registry_metadata_database.md#using-an-external-database)。

<a id="supported-container-registries"></a>

## 支持的容器镜像仓库

Geo 支持以下类型的容器镜像仓库：

- [Docker](https://distribution.github.io/distribution/)
- [OCI](https://github.com/opencontainers/distribution-spec/blob/main/spec.md)

<a id="supported-image-formats"></a>

## 支持的镜像格式

Geo 支持以下容器镜像格式：

- [Docker V2, schema 1](https://distribution.github.io/distribution/spec/deprecated-schema-v1/)
- [Docker V2, schema 2](https://distribution.github.io/distribution/spec/manifest-v2-2/)
- [OCI (Open Container Initiative)](https://github.com/opencontainers/image-spec)

此外，Geo 还支持 [BuildKit 缓存镜像](https://github.com/moby/buildkit)。

<a id="supported-storage"></a>

## 支持的存储

<a id="docker"></a>

### Docker

有关支持的镜像仓库存储驱动，请参阅
[Docker 镜像仓库存储驱动](https://distribution.github.io/distribution/storage-drivers/)

在部署镜像仓库时，请阅读 [负载均衡注意事项](https://distribution.github.io/distribution/about/deploying/#load-balancing-considerations)
，以及如何为极狐GitLab 集成的
[容器镜像仓库](../../packages/container_registry.md#use-object-storage) 配置存储驱动。

<a id="registries-that-support-oci-artifacts"></a>

### 支持 OCI 制品的镜像仓库

以下镜像仓库支持 OCI 制品：

- CNCF Distribution - 本地/离线验证
- Azure Container Registry (ACR)
- Amazon Elastic Container Registry (ECR)
- Google Artifact Registry (GAR)
- GitHub Packages container registry (GHCR)
- Bundle Bar

更多信息，请参阅 [OCI 分发规范](https://github.com/opencontainers/distribution-spec)。

<a id="configure-container-registry-replication"></a>

## 配置容器镜像仓库复制

你可以启用与存储无关的复制，以便可用于云或本地存储。每当新镜像推送到
**主** 站点时，每个 **辅助** 站点都会将其拉取到自己的容器
仓库。

要配置容器镜像仓库复制：

1. 配置 [**主** 站点](#configure-primary-site)。
1. 配置 [**辅助** 站点](#configure-secondary-site)。
1. 验证容器镜像仓库 [复制](#verify-replication)。

<a id="configure-primary-site"></a>

### 配置主站点

在继续执行以下步骤之前，请确保你已在
**主** 站点上设置容器镜像仓库并使其正常工作。

为了能够复制新的容器镜像，容器镜像仓库必须在每次推送时向
**主** 站点发送通知事件。容器镜像仓库与
**主** 站点上的 Web 节点之间共享的令牌用于使通信更加安全。

1. SSH 到你的极狐GitLab **主** 服务器并以 root 身份登录（对于极狐GitLab HA，你只需要一个 Registry 节点）：

   ```shell
   sudo -i
   ```

1. 编辑 `/etc/gitlab/gitlab.rb`：

   ```ruby
   # Configure the registry to listen on the public/internal interface
   # Replace with the appropriate interface (for example, '0.0.0.0' for all interfaces)
   registry['registry_http_addr'] = '0.0.0.0:5000'
   registry['notifications'] = [
     {
       'name' => 'geo_event',
       'url' => 'https://<example.com>/api/v4/container_registry_event/events',
       'timeout' => '500ms',
       'threshold' => 5,
       'backoff' => '1s',
       'headers' => {
         'Authorization' => ['<replace_with_a_secret_token>']
       }
     }
   ]
   ```

   将 `<example.com>` 替换为主站点 `/etc/gitlab/gitlab.rb` 文件中定义的 `external_url`，并将
   `<replace_with_a_secret_token>` 替换为一个区分大小写的字母数字字符串，
   该字符串以字母开头。你可以使用 `/dev/urandom tr -dc _A-Z-a-z-0-9 | head -c 32 | sed "s/^[0-9]*//"; echo` 生成一个。

   > [!note]
   > 如果你使用外部镜像仓库（非极狐GitLab 集成的），则只需在
   > `/etc/gitlab/gitlab.rb` 文件中指定通知密钥（`registry['notification_secret']`）。

1. 仅限极狐GitLab HA。在每个 Web 节点上编辑 `/etc/gitlab/gitlab.rb`：

   ```ruby
   registry['notification_secret'] = '<replace_with_a_secret_token_generated_above>'
   ```

1. 重新配置你刚刚更新的每个节点：

   ```shell
   gitlab-ctl reconfigure
   ```

<a id="configure-secondary-site"></a>

### 配置辅助站点

在继续执行以下步骤之前，请确保你已在
**辅助** 站点上设置容器镜像仓库并使其正常工作。

以下步骤应在你希望看到容器镜像被复制的每个 **辅助** 站点上执行。

因为我们需要允许 **辅助** 站点与
**主** 站点容器镜像仓库安全通信，所以我们需要为所有站点提供一个单一密钥
对。**辅助** 站点使用此密钥
生成一个短期的、仅有拉取权限的 JWT，以访问
**主** 站点容器镜像仓库。

对于 **辅助** 站点上的每个应用程序和 Sidekiq 节点：

1. SSH 到节点并以 `root` 用户身份登录：

   ```shell
   sudo -i
   ```

1. 将 `/var/opt/gitlab/gitlab-rails/etc/gitlab-registry.key` 从 **主** 站点复制到节点。
1. 编辑 `/etc/gitlab/gitlab.rb` 并添加：

   ```ruby
   gitlab_rails['geo_registry_replication_enabled'] = true

   # Primary registry's hostname and port, it will be used by
   # the secondary node to directly communicate to primary registry
   gitlab_rails['geo_registry_replication_primary_api_url'] = 'https://primary.example.com:5050/'
   ```

1. 重新配置节点以使更改生效：

   ```shell
   gitlab-ctl reconfigure
   ```

<a id="verify-replication"></a>

### 验证复制

要验证容器镜像仓库复制是否正常工作，在 **辅助** 站点上：

1. 在右上角，选择 **管理员**。
1. 在左侧边栏中，选择 **Geo** > **节点**。
   初始复制（或称为“回填”）可能仍在进行中。

你可以在浏览器中从 **主** 站点的 **Geo 节点** 仪表板监控每个 Geo 站点的同步过程。

<a id="troubleshooting"></a>

## 故障排查

<a id="confirm-that-container-registry-replication-is-enabled"></a>

### 确认容器镜像仓库复制已启用

可以在 [Rails 控制台](../../operations/rails_console.md#starting-a-rails-console-session) 中使用以下命令进行检查：

```ruby
Geo::ContainerRepositoryRegistry.replication_enabled?
```

<a id="missing-container-registry-notification-event"></a>

### 缺少容器镜像仓库通知事件

1. 当镜像被推送到主站点的容器镜像仓库时，应该触发一个 [容器镜像仓库通知](../../packages/container_registry.md#configure-container-registry-notifications)
1. 主站点的容器镜像仓库调用主站点的 API，地址为 `https://<example.com>/api/v4/container_registry_event/events`
1. 主站点向 `geo_events` 表插入一条记录，其中包含 `replicable_name: 'container_repository', model_record_id: <容器镜像仓库的 ID>`。
1. 该记录通过 PostgreSQL 复制到辅助站点的数据库。
1. Geo 日志游标服务处理该新事件，并将一个 Sidekiq 作业 `Geo::EventWorker` 加入队列。

要验证此操作是否正确，请将镜像推送到主站点上的镜像仓库，并在 Rails 控制台中运行以下命令以验证通知已被接收并处理为事件：

```ruby
Geo::Event.where(replicable_name: 'container_repository')
```

你还可以通过检查 `geo.log` 中来自 `Geo::ContainerRepositorySyncService` 的条目来进一步验证。

<a id="registry-events-logs-response-status-401-unauthorized-unaccepted"></a>

### 镜像仓库事件日志响应状态 401 未授权不可接受

`401 Unauthorized` 错误表示主站点的容器镜像仓库通知未被 Rails 应用程序接受，从而无法通知极狐GitLab 有镜像被推送。

要解决此问题，请确保随镜像仓库通知发送的授权标头与主站点上配置的内容匹配，就像在 [配置主站点](#configure-primary-site) 步骤中所做的那样。

<a id="registry-error-token-from-untrusted-issuer-token"></a>

#### 镜像仓库错误：`token from untrusted issuer: "<token>"`

在 Geo 中复制容器镜像时，你可能会看到错误 `token from untrusted issuer: "<token>"`。

当容器镜像仓库配置不正确，导致 Sidekiq 的 JWT 认证失败时，会出现此问题。

要解决此问题：

1. 确保两个站点共享一个签名密钥对，如 [配置辅助站点](#configure-secondary-site) 中所述。
1. 验证两个容器镜像仓库以及主站点和辅助站点都配置为使用相同的令牌颁发者。更多信息，请参阅 [在单独的节点上配置极狐GitLab 和容器镜像仓库](../../packages/container_registry.md#configure-gitlab-and-registry-on-separate-nodes-linux-package-installations)。
1. 对于多节点部署，请确认 Sidekiq 节点上配置的颁发者与镜像仓库上配置的值匹配。

<a id="manually-trigger-a-container-registry-sync-event"></a>

### 手动触发容器镜像仓库同步事件

为帮助排查故障，你可以手动触发容器镜像仓库复制过程：

1. 在右上角，选择 **管理员**。
1. 在左侧边栏中，选择 **Geo** > **站点**。
1. 在 **辅助站点** 的 **复制详情** 中，选择 **容器镜像仓库**。
1. 对某一行选择 **重新同步**，或选择 **全部重新同步**。

你还可以在辅助站点的 Rails 控制台中运行以下命令来手动触发重新同步：

```ruby
registry = Geo::ContainerRepositoryRegistry.first # Choose a Geo registry entry
registry.replicator.sync # Resync the container repository
pp registry.reload # Look at replication state fields

#<Geo::ContainerRepositoryRegistry:0x00007f54c2a36060
 id: 1,
 container_repository_id: 1,
 state: "2",
 retry_count: 0,
 last_sync_failure: nil,
 retry_at: nil,
 last_synced_at: Thu, 28 Sep 2023 19:38:05.823680000 UTC +00:00,
 created_at: Mon, 11 Sep 2023 15:38:06.262490000 UTC +00:00>
```

`state` 字段表示同步状态：

- `"0"`：等待同步（通常表示从未同步）
- `"1"`：同步已启动（当前正在运行同步作业）
- `"2"`：已成功同步
- `"3"`：同步失败

<a id="repository-not-resynced-after-downtime"></a>

### 停机后仓库未重新同步

如果容器镜像仓库复制因 `geo_container_repository_replication` 功能标志或错误配置而被禁用了一段时间，那么在此期间推送的镜像可能不会自动同步到 **辅助** 站点。

在复制重新启用后，停机期间创建的新容器镜像仓库会自动被回填工作进程捕获。但是，对现有容器镜像仓库的更新（例如，向现有仓库推送新标签）不会自动重新同步。Geo 管理界面可能仍会报告 100% 复制，因为同步状态是基于仓库条目状态，而不是内容验证。

在 **主** 站点的重新验证周期检测到校验和不匹配后，更新的容器镜像仓库最终会重新同步。有关重新验证间隔的更多信息，请参阅 [仓库重新验证](../disaster_recovery/background_verification.md#repository-re-verification)。

要强制立即重新同步而不等待重新验证，请参阅 [手动重试复制或验证](troubleshooting/synchronization_verification.md#manually-retry-replication-or-verification)。