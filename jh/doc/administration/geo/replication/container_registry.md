---
stage: GitLab Dedicated
group: Geo
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
title: 从站点的容器镜像仓库
---

{{< details >}}

- Tier: 专业版，旗舰版
- Offering: 私有化部署

{{< /details >}}

您可以在 Geo 从站点上设置容器镜像仓库，用于从 Geo 主站点上的容器镜像仓库复制容器镜像。此容器镜像复制仅用于灾难恢复目的。

请勿推送到 Geo 从站点上的容器镜像仓库，因为数据不会传播到主站点。

不建议从从站点拉取容器镜像仓库数据，因为这些数据可能已过期。功能请求[议题 365864](https://gitlab.com/gitlab-org/gitlab/-/issues/365864) 将解决此问题。欢迎您为该议题点赞，以表达您的关注。

> [!warning]
> **重要：**容器镜像仓库元数据数据库与容器镜像复制是相互独立的。容器镜像会从主站点复制到从站点，但元数据数据库不会。在启用容器镜像仓库元数据数据库的情况下使用极狐GitLab Geo 时，您必须在每个 Geo 站点（主站点和从站点）为容器镜像仓库分别配置独立的外部 PostgreSQL 实例。容器镜像仓库元数据数据库不能使用极狐GitLab 默认管理的 PostgreSQL 数据库。每个站点的元数据数据库独立运行，彼此之间不进行复制。有关设置说明，请参阅[使用外部数据库](../../packages/container_registry_metadata_database.md#using-an-external-database)。

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
- [OCI（Open Container Initiative）](https://github.com/opencontainers/image-spec)

此外，Geo 还支持 [BuildKit 缓存镜像](https://github.com/moby/buildkit)。

<a id="supported-storage"></a>

## 支持的存储

<a id="docker"></a>

### Docker

有关支持的镜像仓库存储驱动程序的更多信息，请参阅 [Docker 镜像仓库存储驱动程序](https://distribution.github.io/distribution/storage-drivers/)

在部署镜像仓库时，请阅读[负载均衡注意事项](https://distribution.github.io/distribution/about/deploying/#load-balancing-considerations)，以及如何为极狐GitLab 集成的[容器镜像仓库](../../packages/container_registry.md#use-object-storage)设置存储驱动程序。

<a id="registries-that-support-oci-artifacts"></a>

### 支持 OCI 产物的镜像仓库

以下镜像仓库支持 OCI 产物：

- CNCF Distribution - 本地/离线验证
- Azure Container Registry (ACR)
- Amazon Elastic Container Registry (ECR)
- Google 制品仓库 (GAR)
- GitHub Packages container registry (GHCR)
- Bundle Bar

有关更多信息，请参阅 [OCI Distribution Specification](https://github.com/opencontainers/distribution-spec)。

<a id="configure-container-registry-replication"></a>

## 配置容器镜像仓库复制

您可以启用与存储无关的复制，使其可用于云存储或本地存储。每当有新镜像推送到主站点时，每个从站点都会将其拉取到自己的容器仓库。

要配置容器镜像仓库复制：

1. 配置[主站点](#configure-primary-site)。
1. 配置[从站点](#configure-secondary-site)。
1. 验证容器镜像仓库[复制](#verify-replication)。

<a id="configure-primary-site"></a>

### 配置主站点

在执行后续步骤之前，请确保主站点上的容器镜像仓库已设置并正常运行。

为了能够复制新容器镜像，容器镜像仓库必须在每次推送时向主站点发送通知事件。容器镜像仓库与主站点 Web 节点之间共享的令牌用于提高通信的安全性。

1. 通过 SSH 登录极狐GitLab 主服务器，并以 root 身份登录（对于极狐GitLab HA，您只需要一个镜像仓库节点）：

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
       'maxretries' => 5,
       'backoff' => '1s',
       'headers' => {
         'Authorization' => ['<replace_with_a_secret_token>']
       }
     }
   ]
   ```

   将 `<example.com>` 替换为主站点 `/etc/gitlab/gitlab.rb` 文件中定义的 `external_url`，
   并将 `<replace_with_a_secret_token>` 替换为区分大小写、以字母开头的字母数字字符串。
   您可以使用 `/dev/urandom tr -dc _A-Z-a-z-0-9 | head -c 32 | sed "s/^[0-9]*//"; echo` 生成一个。

   > [!note]
   > 除非您显式设置 `gitlab_rails['registry_notification_secret']`，否则请将此端点命名为 `geo_event`。在 `/etc/gitlab/gitlab.rb`中包含
   > `registry['notifications']` 块的节点上，Linux 软件包仅当端点名称匹配时，才会从该端点的
   > `Authorization` 请求头中派生该密钥。如果使用任何其他名称且未显式设置，极狐GitLab 就没有通知密钥，
   > 镜像仓库的通知会被拒绝，返回 `401 Unauthorized`。
   >
   > 如果您使用外部镜像仓库（不是与极狐GitLab 集成的那个），则没有
   > `registry['notifications']` 块可用于派生密钥，因此您必须在
   > `/etc/gitlab/gitlab.rb`中自行设置：
   >
   > ```ruby
   > gitlab_rails['registry_notification_secret'] = '<replace_with_a_secret_token>'
   > ```

1. 仅适用于极狐GitLab HA。在每个 Web 节点上编辑 `/etc/gitlab/gitlab.rb`：

   ```ruby
   gitlab_rails['registry_notification_secret'] = '<replace_with_a_secret_token_generated_above>'
   ```

   Web 节点没有 `registry['notifications']` 块，因此没有可用于派生密钥的内容，必须显式设置。
   如果由于将同一个 `/etc/gitlab/gitlab.rb` 复制到每个节点而使 Web 节点确实带有该块，
   则其派生密钥的方式与镜像仓库节点相同。

1. 重新配置您刚刚更新的每个节点：

   ```shell
   gitlab-ctl reconfigure
   ```

<a id="configure-secondary-site"></a>

### 配置从站点

在执行后续步骤之前，请确保从站点上的容器镜像仓库已设置并正常运行。

以下步骤应在您期望看到容器镜像复制的每个从站点上执行。

由于需要允许从站点与主站点容器镜像仓库进行安全通信，我们需要为所有站点使用单一密钥对。从站点使用此密钥生成短期 JWT，该 JWT 仅具有拉取权限，用于访问主站点容器镜像仓库。

对于从站点上的每个应用节点和 Sidekiq 节点：

1. 通过 SSH 登录该节点，并以 `root` 用户身份登录：

   ```shell
   sudo -i
   ```

1. 将 `/var/opt/gitlab/gitlab-rails/etc/gitlab-registry.key` 从主站点复制到该节点。
1. 编辑 `/etc/gitlab/gitlab.rb` 并添加：

   ```ruby
   gitlab_rails['geo_registry_replication_enabled'] = true

   # Primary registry's hostname and port, it will be used by
   # the secondary node to directly communicate to primary registry
   gitlab_rails['geo_registry_replication_primary_api_url'] = 'https://primary.example.com:5050/'
   ```

1. 重新配置该节点以使更改生效：

   ```shell
   gitlab-ctl reconfigure
   ```

<a id="disable-container-registry-replication"></a>

### 禁用容器镜像仓库复制

> [!note]
> 当容器镜像仓库服务被禁用时，Geo 会自动跳过容器仓库的验证尝试。容器镜像仓库指标
> 会从 Geo 仪表板中隐藏。现有验证状态仍保留在数据库中，但不会显示。

要停止将容器镜像复制到从站点并禁用本地容器镜像仓库：

1. 通过 SSH 登录主服务器节点，并以 `root` 用户身份登录：

   ```shell
   sudo -i
   ```

1. 编辑 `/etc/gitlab/gitlab.rb` 并添加：

   ```ruby
   # Disable Geo replication for the container registry
   gitlab_rails['geo_registry_replication_enabled'] = false
   # Disable the container registry service itself
   registry['enable'] = false
   ```

1. 重新配置该节点以使更改生效：

   ```shell
   sudo gitlab-ctl reconfigure
   ```

<a id="verify-replication"></a>

### 验证复制

要验证容器镜像仓库复制是否正常工作，请在从站点上执行以下操作：

1. 在右上角，选择**管理员**。
1. 在左侧边栏中，选择 **Geo** > **节点**。
   初始复制（即“回填”）可能仍在进行中。

您可以在浏览器中通过主站点的 **Geo 节点**仪表板监控每个 Geo 站点上的同步过程。

<a id="garbage-collection-on-geo-sites"></a>

## Geo 站点上的垃圾回收

主站点上的垃圾回收不会释放从站点上的存储空间。每个站点都必须清理自己的容器镜像仓库存储。当您在主站点上删除标签时，该删除操作会复制到从站点。但是，镜像层会保留在两个站点的存储中，直到垃圾回收将其移除。

如何运行垃圾回收取决于您的镜像仓库配置。

<a id="garbage-collection-with-the-container-registry-metadata-database"></a>

### 使用容器镜像仓库元数据数据库进行垃圾回收

每个站点都有自己的镜像仓库元数据数据库，镜像仓库会在每个站点上自动运行[在线垃圾回收](../../packages/container_registry_metadata_database.md#online-garbage-collection-monitoring)。您无需手动运行垃圾回收。

<a id="garbage-collection-without-the-metadata-database-with-separate-storage-for-each-site"></a>

### 不使用元数据数据库、且每个站点使用独立存储时的垃圾回收

在每个站点上运行[垃圾回收](../../packages/container_registry.md#container-registry-garbage-collection)。垃圾回收运行期间，从站点无法复制容器镜像，Geo 会在其完成后重试失败的同步。

<a id="garbage-collection-without-the-metadata-database-with-shared-storage"></a>

### 不使用元数据数据库、且使用共享存储时的垃圾回收

> [!warning]
> 不建议使用共享存储。配置错误可能导致数据丢失。

使用共享存储时，两个站点读写同一个存储桶，因此主站点拥有所有镜像仓库 blob。从站点不得触碰它们：请勿在从站点上运行垃圾回收，因为它可能会删除最近推送到主站点的镜像，而且复制会将 blob 复制到其自身。

简而言之：

1. 在从站点上，[禁用容器镜像仓库复制](#disable-container-registry-replication)。
1. 在主站点上，运行[垃圾回收](../../packages/container_registry.md#container-registry-garbage-collection)。

<a id="troubleshooting"></a>

## 故障排除

<a id="confirm-that-container-registry-replication-is-enabled"></a>

### 确认容器镜像仓库复制已启用

可以使用 [Rails 控制台](../../operations/rails_console.md#starting-a-rails-console-session)执行检查来确认：

```ruby
Geo::ContainerRepositoryRegistry.replication_enabled?
```

<a id="missing-container-registry-notification-event"></a>

### 缺少容器镜像仓库通知事件

1. 当镜像被推送到主站点的容器镜像仓库时，应触发[容器镜像仓库通知](../../packages/container_registry.md#configure-container-registry-notifications)
1. 主站点的容器镜像仓库会调用主站点位于 `https://<example.com>/api/v4/container_registry_event/events`的 API
1. 主站点会向 `geo_events` 表插入一条记录，内容为 `replicable_name: 'container_repository', model_record_id: <ID of the container repository>`。
1. 该记录会由 PostgreSQL 复制到从站点的数据库。
1. Geo Log Cursor 服务处理该新事件，并将 Sidekiq 作业 `Geo::EventWorker` 加入队列

要验证此过程是否正常工作，请将镜像推送到主站点上的镜像仓库，并在 Rails 控制台上运行以下命令，以验证通知已收到并已处理为事件：

```ruby
Geo::Event.where(replicable_name: 'container_repository')
```

您还可以通过检查 `geo.log`中来自 `Geo::ContainerRepositorySyncService`的条目来进一步验证。

<a id="registry-events-logs-response-status-401-unauthorized-unaccepted"></a>

### 镜像仓库事件日志响应状态 401 Unauthorized 未被接受

`401 Unauthorized` 错误表示主站点的容器镜像仓库通知未被 Rails 应用接受，导致其无法通知极狐GitLab 有内容被推送。

要解决此问题，请确保随镜像仓库通知发送的授权请求头与主站点上配置的一致，这应在[配置主站点](#configure-primary-site)步骤中完成。

如果它们看起来一致，请检查极狐GitLab 是否持有通知密钥。在运行 Rails 的每个节点上：

```shell
grep notification_secret /var/opt/gitlab/gitlab-rails/etc/gitlab.yml
```

值为空表示极狐GitLab 没有可用于比较传入请求头的内容，因此无论镜像仓库发送什么，每个通知都会被拒绝。有两种原因会导致值为空：

- 节点的 `/etc/gitlab/gitlab.rb`中没有 `registry['notifications']` 块，
  因此没有可用于派生密钥的内容。这是 Web 节点的常见状态，也是镜像仓库为外部镜像仓库时所有节点的状态。
  请按照[配置主站点](#configure-primary-site)中的说明，显式设置
  `gitlab_rails['registry_notification_secret']`。
- 该块存在，但其端点未命名为 `geo_event`。
  派生过程按端点名称进行匹配，因此任何其他名称都不会生成密钥。

Linux 软件包不会将派生出的密钥写入 `/etc/gitlab/gitlab-secrets.json`，因此每次执行 `gitlab-ctl reconfigure` 时都会重新派生。因此，端点命名错误不是一次性的失误，后续重新配置也无法修复。

被拒绝的通知会根据端点配置中的 `maxretries` 值进行重试，然后被丢弃，因此推送本身会成功，但永远不会为其创建 Geo 事件。只要密钥仍为空，后续的任何推送也不会启动复制。

在您更正密钥后，后续对容器仓库的推送会重新同步整个容器仓库，包括在中断期间遗漏的任何推送。如果某个容器仓库之后没有收到推送，则不会立即重新同步。它会在主站点的定期重新验证重新计算其校验和、且从站点检测到不匹配后重新同步，这可能需要长达[重新验证间隔](../disaster_recovery/background_verification.md#repository-re-verification)的时间。要更快地重新同步，可以按照[手动触发容器镜像仓库同步事件](#manually-trigger-a-container-registry-sync-event)中所述选择**全部重新同步**，或者[重新验证主站点上的所有容器仓库](resync_reverify.md#reverify-one-component-on-all-sites)。[停机后容器仓库未重新同步](#repository-not-resynced-after-downtime)中描述的定向 `gitlab:geo:reverify_container_repositories_since` 任务在此处不适用。它选择的是主站点最近验证过的容器仓库，而在通知被拒绝期间，主站点并未重新验证那些被推送到的容器仓库，因此该任务无法将它们与其他任何容器仓库区分开来。

要从极狐GitLab 一侧确认这些拒绝，请检查 `api_json.log` 而不是 `production_json.log`。通知端点是 REST API 的一部分，因此其请求（包括被拒绝的请求）会记录在 `api_json.log`中，而不会记录在 `production_json.log`中：

```shell
grep container_registry_event /var/log/gitlab/gitlab-rails/api_json.log
```

<a id="registry-error-token-from-untrusted-issuer-token"></a>

#### 镜像仓库错误：`token from untrusted issuer: "<token>"`

在 Geo 中复制容器镜像时，您可能会看到错误 `token from untrusted issuer: "<token>"`。

此问题在容器镜像仓库配置不正确、导致 Sidekiq 的 JWT 认证失败时发生。

要解决此问题：

1. 确保两个站点共享单一签名密钥对，如[配置从站点](#configure-secondary-site)中所述。
1. 验证两个容器镜像仓库以及主站点和从站点都配置为使用相同的令牌签发者。有关更多信息，请参阅
   [在独立节点上配置极狐GitLab 和镜像仓库](../../packages/container_registry.md#configure-gitlab-and-registry-on-separate-nodes-linux-package-installations)。
1. 对于多节点部署，请确认 Sidekiq 节点上配置的签发者与镜像仓库上配置的值一致。

<a id="manually-trigger-a-container-registry-sync-event"></a>

### 手动触发容器镜像仓库同步事件

为帮助排查问题，您可以手动触发容器镜像仓库复制过程：

1. 在右上角，选择**管理员**。
1. 在左侧边栏中，选择 **Geo** > **站点**。
1. 在**从站点**的**复制详情**中，选择**容器仓库**。
1. 为某一行选择**重新同步**，或选择**全部重新同步**。

您还可以通过在从站点的 Rails 控制台上运行以下命令来手动触发重新同步：

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

- `"0"`：等待同步（通常表示从未同步过）
- `"1"`：已开始同步（当前有同步作业正在运行）
- `"2"`：同步成功
- `"3"`：同步失败

<a id="repository-not-resynced-after-downtime"></a>

### 停机后容器仓库未重新同步

如果容器镜像仓库复制在一段时间内被禁用，无论是通过 `geo_container_repository_replication` 功能标志还是由于配置错误，在此期间推送的镜像可能不会自动同步到从站点。

在停机期间新建的容器仓库会在复制重新启用后由回填工作进程自动拾取。但是，对现有容器仓库的更新（例如，推送到现有仓库的新标签）不会自动重新同步。Geo 管理界面可能仍报告 100% 复制率，因为同步状态基于镜像仓库条目的状态，而不是基于内容验证。

更新过的容器仓库最终会在主站点重新验证周期检测到校验和不匹配后重新同步。有关重新验证间隔的更多信息，请参阅[容器仓库重新验证](../disaster_recovery/background_verification.md#repository-re-verification)。

如果复制是通过 `geo_container_repository_replication` 功能标志禁用的，但镜像仓库通知和强制主站点校验和计算仍保持启用，则主站点仍会重新计算在复制被禁用期间被推送到的每个容器仓库的校验和，即使没有向从站点发送任何复制事件。因此，这些容器仓库的验证时间戳（`verified_at`）可以标识出哪些容器仓库在停机期间发生了更改，仅重新验证这些容器仓库就足以触发它们的重新同步。要将主站点在过去 N 天内验证过的容器仓库标记为需要重新验证，请在主站点上运行以下命令：

```shell
sudo gitlab-rake "gitlab:geo:reverify_container_repositories_since[7]"
```

该参数是要回溯的天数，默认为 `7`。该任务会报告标记了多少个容器仓库，然后定期验证工作进程会重新计算它们的校验和。从站点会检测到由此产生的校验和不匹配，并重新同步受影响的容器仓库。如果任务被中断，可以安全地再次运行：已标记的容器仓库会被跳过。

要预览将标记多少个容器仓库而不做任何更改，请设置 `DRY_RUN=true`：

```shell
sudo DRY_RUN=true gitlab-rake "gitlab:geo:reverify_container_repositories_since[7]"
```

此定向恢复要求镜像仓库通知在中断期间已到达主站点，并且 `geo_container_repository_force_primary_checksumming` 一直保持启用。

如果镜像仓库通知在一段时间内配置错误，例如由于用户错误，则在此期间推送的标签不会被记录，因此 Geo 无法确定哪些容器仓库发生了更改。在这种情况下，建议的操作是[重新验证主站点上的所有容器仓库](resync_reverify.md#reverify-one-component-on-all-sites)。主站点会重新计算所有校验和，然后从站点仅重新同步内容发生更改的容器仓库。
