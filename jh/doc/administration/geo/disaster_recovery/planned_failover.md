---
stage: GitLab Dedicated
group: Geo
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
description: 使用 Geo 进行计划内故障转移，通过执行预检和同步步骤，以最短停机时间迁移极狐GitLab，将从站点提升为主站点且不丢失数据。
title: 计划内故障转移的灾难恢复
---

{{< details >}}

- Tier: 专业版，旗舰版
- Offering: 私有化部署

{{< /details >}}

灾难恢复的主要用例是确保在计划外停机时业务能够持续运行，但它也可以与计划内故障转移配合使用，在区域之间迁移极狐GitLab 实例而无需长时间停机。

Geo 站点之间的复制是异步的，因此计划内故障转移需要一个维护窗口，在此期间阻止对主站点的更新。该窗口的长度取决于从站点与主站点完全同步所需的时间。同步完成后，即可在不丢失数据的情况下执行故障转移。

本文档假设您已经拥有一个完全配置且可正常工作的 Geo 环境。在继续操作之前，请完整阅读本文档以及[灾难恢复](_index.md)故障转移文档。计划内故障转移是一项重大操作，如果执行不当，数据丢失的风险很高。请演练该流程，直到您熟悉必要的步骤，并有十足把握能够准确执行这些步骤。

<a id="recommendations-for-failover"></a>

## 故障转移建议

遵循这些建议有助于确保故障转移过程顺利进行，并降低数据丢失或长时间停机的风险。

<a id="resolve-sync-and-verification-failures"></a>

### 解决同步和验证失败

如果在[预检](#preflight-checks)期间（无论是手动验证还是运行 `gitlab-ctl promotion-preflight-checks` 时）存在 **Failed** 或 **Queued** 项，则故障转移会被阻止，直到这些项满足以下条件之一：

- 已解决：成功同步（如有必要，可手动复制到从站点）并验证。
- 记录为可接受：并附有明确的理由，例如：
  - 针对这些特定失败项，手动校验和比较通过。
  - 代码仓库已弃用，可以排除。
  - 项被认定为非关键项，可以在故障转移后复制。

如需帮助诊断同步和验证失败，请参阅[故障排除 Geo 同步和验证错误](../replication/troubleshooting/synchronization_verification.md)。

<a id="plan-for-data-integrity-resolution"></a>

### 规划数据完整性问题的解决

在故障转移完成前预留 4-6 周时间，以解决首次为 Geo 复制进行设置后通常会出现的数据完整性问题。这些问题可能包括孤立的数据库记录或不一致的文件引用。如需指导，请参阅[故障排除常见 Geo 错误](../replication/troubleshooting/common.md)。

尽早开始处理同步问题，以避免在维护窗口期间做出艰难的决定：

1. 4-6 周前：识别并开始解决尚未解决的同步问题。
1. 1 周前：争取解决或记录所有剩余的同步问题。
1. 1-2 天前：解决任何新的失败。
1. 数小时前：最后检查是否有任何新的失败。

为确保成功：制定明确的标准，以确定何时因未解决的同步错误而中止故障转移。

<a id="test-backup-timing-in-geo-environments"></a>

### 在 Geo 环境中测试备份时机

> [!warning]
> 来自 Geo 副本数据库的备份可能会在数据库事务处于活动状态时被取消。

提前测试备份流程，并考虑以下策略：

- 直接从主站点进行备份。这可能会影响性能。
- 使用专用的只读副本，在备份期间将其与复制隔离。
- 在活动较少的时段安排备份。

<a id="prepare-comprehensive-fallback-procedures"></a>

### 准备全面的回退流程

> [!warning]
> 在提升完成之前规划好回滚决策点，因为之后回退可能会导致数据丢失。

记录恢复到原始主站点的具体步骤，包括：

- 中止故障转移的决策标准。
- DNS 还原流程。
- 重新启用原始主站点的流程。请参阅[使已降级的主站点重新上线](bring_primary_back.md)。
- 用户沟通计划。

<a id="develop-a-failover-runbook-in-a-staging-environment"></a>

### 在预发布环境中制定故障转移 runbook

为确保成功，请完整详细地演练并记录这项高度依赖人工的任务：

1. 如果还没有类生产环境，请预配一个。
1. 冒烟测试。例如，添加群组、添加项目、添加 Runner、使用 `git push`、向议题添加图片。
1. 故障转移到从站点。
1. 运行冒烟测试。查找问题。
1. 在这些步骤中，记录所采取的每一项操作、执行者、预期结果以及资源链接。
1. 根据需要重复，以完善 runbook 和脚本。

<a id="not-all-data-is-automatically-replicated"></a>

## 并非所有数据都会自动复制

如果您使用了 Geo 不支持的任何极狐GitLab 功能，则必须另行采取措施，确保从站点拥有与该功能相关的任何数据的最新副本。这可能会显著延长维护期。有关 Geo 支持的功能列表，请参阅[复制数据类型表](../replication/datatypes.md#replicated-data-types)。

对于存储在文件中的数据，尽可能缩短此期限的一种常见策略是使用 `rsync` 传输数据。可以在维护窗口之前执行初始 `rsync`。之后的 `rsync` 流程（包括维护窗口内的最终传输）则只传输主站点与从站点之间的变更。

有关以 Git 代码仓库为中心、有效使用 `rsync`的策略，请参阅[移动代码仓库](../../operations/moving_repositories.md)。这些策略可以调整后用于任何其他基于文件的数据。

<a id="container-registry"></a>

### 容器镜像仓库

默认情况下，容器镜像仓库不会自动复制到从站点。这需要手动配置。有关更多信息，请参阅[从站点的容器镜像仓库](../replication/container_registry.md)。

故障转移对镜像仓库的要求取决于两个独立的因素：镜像仓库使用哪种元数据后端，以及镜像存储在何处。还有两项设置取决于站点所扮演的角色，无论使用哪种后端和存储，都必须在提升后更改。

<a id="configuration-that-does-not-carry-across-a-promotion"></a>

#### 不会随提升而保留的配置

- 被提升的站点必须开始向其自身的 API 发送镜像仓库通知。一个一直仅作为从站点的站点没有 `registry['notifications']` 配置块，因此提升后没有任何机制告知极狐GitLab 镜像已被推送，向任何剩余从站点的复制也不会启动。请按照[配置主站点](../replication/container_registry.md#configure-primary-site)中的说明进行配置。

  这种情况不会报告任何错误。由于未配置端点，镜像仓库没有任何可通知的对象，因此镜像仓库日志和 `api_json.log` 都不会记录任何内容，而从站点上的容器仓库会继续被报告为已同步，并带有其上次成功同步的时间戳。要确认提升后通知是否正常流动，请在提升后的站点上运行以下检查，记下它报告的时间戳，推送一个镜像，然后立即再次运行该检查：

  ```shell
  sudo gitlab-rake gitlab:geo:check
  ```

  在极狐GitLab 18.9 及更高版本中，`Container Registry replication enabled` 检查还会报告 `Container Registry Geo events ... last event at <timestamp>`。时间戳晚于推送时间即确认被提升的站点正在发送通知。时间戳没有推进本身并不能证明存在问题：当不再有从站点存在时不会创建任何事件，而 `Geo::PruneEventLogWorker` 每五分钟运行一次，会移除所有剩余从站点都已处理的事件，因此该检查在健康的站点上可能会报告 `none found` 或较早的时间戳。在这种情况下，请在提升后的站点上检查 `api_json.log`，查找推送后对 `/api/v4/container_registry_event/events`的请求。`200` 表示通知已被接受。`401` 表示通知密钥不匹配，请参阅[镜像仓库事件日志响应状态 401 Unauthorized unaccepted](../replication/container_registry.md#registry-events-logs-response-status-401-unauthorized-unaccepted)。
  当未设置 `gitlab_rails['geo_registry_replication_enabled']` 时，该检查会被完全跳过，因此请先确认该设置。从从站点提升而来的站点仍然保留该设置，以及 `gitlab_rails['geo_registry_replication_primary_api_url']`，并且可以保留这两项设置。这两项设置都不会影响主站点上的复制，提升也不会更改它们。
- 任何仍为从站点的站点都必须将 `gitlab_rails['geo_registry_replication_primary_api_url']` 指向被提升的站点，如[配置从站点](../replication/container_registry.md#configure-secondary-site)中所述。

<a id="metadata-database"></a>

#### 元数据数据库

如果镜像仓库使用[容器镜像仓库元数据数据库](../../packages/container_registry_metadata_database.md)，其标签和清单元数据存放在一个 PostgreSQL 数据库中，Geo 不会复制该数据库，也不需要提升它。仅复制镜像存储会使另一站点上的镜像仓库缺少该元数据。这适用于[对象存储中的镜像](#images-in-object-storage)和[本地文件系统存储中的镜像](#images-in-local-file-system-storage)中的每个流程。Geo 容器镜像仓库复制会填充从站点自身的镜像仓库数据库及其存储，因此复制镜像仓库的从站点同时拥有镜像和元数据。

每个站点运行自己的镜像仓库数据库和自己的存储，因此提升后镜像仓库会继续从它原本使用的资源提供服务。提升会重新配置站点，但不会更改镜像仓库的数据库配置及其存储。

<a id="images-replicated-by-geo"></a>

#### 由 Geo 复制的镜像

如果 Geo 复制容器镜像仓库，则从站点已在其自身存储中拥有这些镜像。[对象存储中的镜像](#images-in-object-storage)和[本地文件系统存储中的镜像](#images-in-local-file-system-storage)中的流程不需要执行。请在维护窗口之前确认从站点拥有这些镜像，如[验证容器镜像仓库](#verify-the-container-registry)中所述。

<a id="images-in-object-storage"></a>

#### 对象存储中的镜像

在维护窗口之前，使用对象存储提供商自带的工具复制存储桶。

> [!warning]
> 当镜像仓库存储为远程存储时，请勿运行[本地文件系统存储中的镜像](#images-in-local-file-system-storage)中的 `rsync` 或备份流程。
> 它们仅作用于本地文件系统，并且 `rsync` 命令使用了 `--delete`。
> 当主站点的本地镜像仓库目录存在但为空时（通常在迁移到对象存储后就是如此），`rsync` 会清空从站点的本地镜像仓库目录。

复制存储桶只会复制镜像。使用元数据数据库的镜像仓库还需要其元数据，而此流程不会复制元数据。请参阅[元数据数据库](#metadata-database)。

<a id="images-in-local-file-system-storage"></a>

#### 本地文件系统存储中的镜像

如果您在当前主站点上为容器镜像仓库使用本地存储，可以将容器镜像仓库对象 `rsync` 到您即将故障转移到的从站点。`rsync` 只会复制镜像：使用元数据数据库的镜像仓库还需要其元数据，请参阅[元数据数据库](#metadata-database)。

```shell
# Run from the secondary site
rsync --archive --perms --delete root@<geo-primary>:/var/opt/gitlab/gitlab-rails/shared/registry/. /var/opt/gitlab/gitlab-rails/shared/registry
```

或者，[备份](../../backup_restore/_index.md#back-up-gitlab)主站点上的容器镜像仓库，并将其恢复到从站点：

1. 在主站点上，仅备份镜像仓库，并[从备份中排除特定目录](../../backup_restore/backup_gitlab.md#excluding-specific-data-from-the-backup)：

   ```shell
   # Create a backup in the /var/opt/gitlab/backups folder
   sudo gitlab-backup create SKIP=db,uploads,builds,artifacts,lfs,terraform_state,pages,repositories,packages
   ```

1. 将从主站点生成的备份 tar 包复制到从站点上的 `/var/opt/gitlab/backups` 文件夹。
1. 在从站点上，按照[恢复极狐GitLab](../../backup_restore/_index.md#restore-gitlab) 文档恢复镜像仓库。

<a id="recover-data-for-advanced-search"></a>

### 恢复高级搜索的数据

高级搜索由 Elasticsearch 或 OpenSearch 提供支持。
高级搜索的数据不会自动复制到从站点。

要在新提升的主站点上恢复高级搜索的数据：

{{< tabs >}}

{{< tab title="极狐GitLab 17.2 及更高版本" >}}

1. 禁用 Elasticsearch 搜索：

   ```shell
   sudo gitlab-rake gitlab:elastic:disable_search_with_elasticsearch
   ```

1. [为整个实例重建索引](../../../integration/advanced_search/elasticsearch.md#index-the-instance)。
1. [检查索引状态](../../../integration/advanced_search/elasticsearch.md#check-indexing-status)。
1. [监控后台作业的状态](../../../integration/advanced_search/elasticsearch.md#monitor-the-status-of-background-jobs)。
1. 启用 Elasticsearch 搜索：

   ```shell
   sudo gitlab-rake gitlab:elastic:enable_search_with_elasticsearch
   ```

{{< /tab >}}

{{< tab title="极狐GitLab 17.1 及更早版本" >}}

1. 禁用 Elasticsearch 搜索：

   ```shell
   sudo gitlab-rake gitlab:elastic:disable_search_with_elasticsearch
   ```

1. 暂停索引，并等待五分钟让正在进行的任务完成：

   ```shell
   sudo gitlab-rake gitlab:elastic:pause_indexing
   ```

1. 从头为实例重建索引：

   ```shell
   sudo gitlab-rake gitlab:elastic:index
   ```

1. 恢复索引：

   ```shell
   sudo gitlab-rake gitlab:elastic:resume_indexing
   ```

1. [检查索引状态](../../../integration/advanced_search/elasticsearch.md#check-indexing-status)。
1. [监控后台作业的状态](../../../integration/advanced_search/elasticsearch.md#monitor-the-status-of-background-jobs)。
1. 启用 Elasticsearch 搜索：

   ```shell
   sudo gitlab-rake gitlab:elastic:enable_search_with_elasticsearch
   ```

{{< /tab >}}

{{< /tabs >}}

<a id="preflight-checks"></a>

## 预检

在安排计划内故障转移之前，请通过验证以下预检来确保流程顺利进行。每个步骤将在后续章节中更详细地说明。

在实际故障转移过程中，主站点关闭后，运行以下命令以在提升从站点之前执行最终验证检查：

```shell
gitlab-ctl promotion-preflight-checks
```

`gitlab-ctl promotion-preflight-checks` 命令是故障转移流程的一部分，要求主站点处于关闭状态。您不能在主站点仍在运行时将其用作维护前验证工具。运行此命令时，会出现提示询问您主站点是否已关闭。如果您回答 `No`，则会显示以下错误：`ERROR: primary node must be down`。

如需在主站点仍在运行时进行维护前验证，请使用以下章节中的手动检查。

<a id="dns-ttl"></a>

### DNS TTL

如果您计划[更新主域名 DNS 记录](_index.md#optional-updating-the-primary-domain-dns-record)，请考虑设置较低的 TTL（生存时间），以确保 DNS 更改快速传播。

<a id="object-storage"></a>

### 对象存储

如果您的极狐GitLab 安装规模较大，或者无法容忍停机，请考虑在安排计划内故障转移之前[迁移到对象存储](../replication/object_storage.md)。这样做既能缩短维护窗口的长度，也能降低因计划内故障转移执行不当而导致数据丢失的风险。

如果您希望极狐GitLab 管理从站点的对象存储复制，请参阅[对象存储复制](../replication/object_storage.md)。

<a id="review-the-configuration-of-each-secondary-site"></a>

### 检查每个从站点的配置

数据库设置会自动复制到从站点。但是，您必须手动设置 `/etc/gitlab/gitlab.rb` 文件，并且该文件因站点而异。如果在主站点上启用了 Mattermost、OAuth 或 LDAP 集成等功能，而从站点未启用，则这些功能会在故障转移期间丢失。

请检查两个站点的 `/etc/gitlab/gitlab.rb` 文件。在安排计划内故障转移之前，确保从站点支持主站点所支持的一切。确保[极狐GitLab Geo 角色](https://gitlab.cn/docs/omnibus/roles/#gitlab-geo-roles)配置正确。

<a id="run-system-checks"></a>

### 运行系统检查

在主站点和从站点上分别运行以下命令：

```shell
gitlab-rake gitlab:check
gitlab-rake gitlab:geo:check
```

如果任一站点报告任何失败，请在安排计划内故障转移之前解决它们。

<a id="check-that-secrets-and-ssh-host-keys-match-between-nodes"></a>

### 检查节点之间的密钥和 SSH 主机密钥是否匹配

所有节点上的 SSH 主机密钥和 `/etc/gitlab/gitlab-secrets.json` 文件应完全相同。请在所有节点上运行以下命令并比较输出，以进行检查：

```shell
sudo sha256sum /etc/ssh/sshhost /etc/gitlab/gitlab-secrets.json
```

如果任何文件不同，请根据需要[手动复制极狐GitLab 密钥](../replication/configuration.md#step-1-manually-replicate-secret-gitlab-values)并[复制 SSH 主机密钥](../replication/configuration.md#step-2-manually-replicate-the-primary-sites-ssh-host-keys)到从站点。

<a id="check-that-the-correct-certificates-are-installed-for-https"></a>

### 检查是否为 HTTPS 安装了正确的证书

如果主站点以及主站点访问的所有外部站点都使用公共 CA 签发的证书，则可以安全地跳过此步骤。

如果出现以下任一情况，您应在从站点上安装正确的证书：

- 主站点使用自定义或自签名 TLS 证书来保护入站连接。
- 主站点连接到使用自定义或自签名证书的外部服务。

有关更多信息，请参阅在从站点上[使用自定义证书](../replication/configuration.md#step-4-optional-using-custom-certificates)。

<a id="ensure-geo-replication-is-up-to-date"></a>

### 确保 Geo 复制是最新的

在 Geo 复制和验证完全完成之前，维护窗口不会结束。为尽可能缩短窗口，您应确保在活跃使用期间这些进程尽可能接近 100%。

在从站点上：

1. 在右上角，选择**管理员**。
1. 在左侧边栏中，选择 **Geo** > **站点**。
   已复制的对象（以绿色显示）应接近 100%，
   并且不应有失败（以红色显示）。如果很大一部分对象尚未复制（以灰色显示），请考虑给站点更多时间来完成：

   ![显示从站点同步状态的 Geo 管理仪表板](img/geo_dashboard_v14_0.png)

如果对象复制失败，请在安排维护窗口之前进行调查。任何复制失败的对象都会在计划内故障转移后丢失。

复制失败的常见原因是主站点上缺少数据。要解决这些失败，可以：

- 从备份恢复数据。
- 移除对缺失数据的引用。

<a id="verify-the-integrity-of-replicated-data"></a>

### 验证已复制数据的完整性

在继续故障转移之前，确保验证已完成。任何未通过验证的损坏数据都可能在故障转移期间丢失。

有关更多信息，请参阅[自动后台验证](background_verification.md)。

<a id="verify-the-container-registry"></a>

### 验证容器镜像仓库

如果从站点复制容器镜像仓库，请在维护窗口之前确认从站点拥有这些镜像，并且两个站点都从您预期的元数据后端提供服务。

1. 比较目录。读取目录需要具有 `registry:catalog:*` 作用域的令牌，该令牌仅颁发给管理员。个人访问令牌必须至少具有 `read_registry` 作用域。在每个站点上，生成一个令牌并列出目录：

   ```shell
   token=$(curl --silent --user "<administrator-username>:<personal-access-token>" \
     "https://<gitlab-host>/jwt/auth?service=container_registry&scope=registry:catalog:*" \
     | grep --only-matching '"token":"[^"]*"' | cut --delimiter='"' --fields=4)

   curl --silent --header "Authorization: Bearer ${token}" \
     "https://<registry-host>/v2/_catalog?n=1000"
   ```

   目录请求返回 `401` 通常意味着该账号不是管理员。
   令牌请求对任何已认证用户都会成功，但对于非管理员，它返回的令牌不携带任何访问权限。

   目录是分页的。默认返回 100 个容器仓库，`n` 设置每页数量且不能超过 1000，请求数量超过该上限时会返回错误，而不是分页结果。如果还有更多容器仓库，响应会携带包含下一页 URL 的 `Link` 头。持续跟进，直到不再返回 `Link` 头，并比较完整列表，而不是第一页。

   不要仅依赖 Geo 的容器仓库同步状态。即使个别标签传输失败，容器仓库也可能被标记为已同步，因为标签失败只写入日志，不会记录到容器镜像仓库的同步状态中。在从站点上检查 `geo.log`中是否有 `Error while syncing tag` 条目。

1. 确认每个站点正在使用哪种元数据后端，如[验证哪个元数据后端处于活动状态](../../packages/container_registry_metadata_database.md#verify-which-metadata-backend-is-active)中所述。
   已回退到旧版元数据的站点仍会报告为健康，因此从 Geo 仪表板中看不到这一点。

<a id="notify-users-of-scheduled-maintenance"></a>

### 通知用户计划内维护

在主站点上：

1. 在右上角，选择**管理员**。
1. 在左侧边栏中，选择**消息**。
1. 添加一条消息，通知用户维护窗口。要估算完成同步所需的时间，请转到 **Geo** > **站点**。
1. 选择**添加广播消息**。

<a id="runner-connectivity-during-failover"></a>

### 故障转移期间的 Runner 连接

根据您的实例 URL 配置方式，可能需要额外的步骤才能在故障转移后使您的 runner 集群保持 100%。

用于注册 runner 的令牌应能在主实例或从实例上使用。如果您在故障转移后遇到连接问题，可能是密钥在[从站点配置](../setup/two_single_node_sites.md#manually-replicate-secret-gitlab-values)期间未被复制过来。您可以[重置 runner 令牌](../../backup_restore/troubleshooting_backup_gitlab.md#reset-runner-registration-tokens)。但是请注意，如果密钥未同步，您可能会遇到与 runner 无关的其他问题。

如果 runner 反复无法连接到极狐GitLab 实例，它会在一段时间内停止尝试连接。默认情况下，该时间段为 1 小时。为避免这种情况，请关闭 runner，直到极狐GitLab 实例可访问。请参阅 [`check_interval` 文档](https://gitlab.cn/docs/runner/configuration/advanced-configuration/#how-check_interval-works)，以及配置选项 `unhealthy_requests_limit` 和 `unhealthy_interval`。

- 如果您使用我们的**位置感知 URL**：从 DNS 配置中移除旧主站点后，runner 应会自动连接到下一个最近的实例。
- 如果您使用单独的 URL：任何连接到当前主站点的 runner 都应在新的主站点被提升后更新为连接到新的主站点。
- 如果您有任何 runner 连接到当前的从站点：请参阅故障转移期间[如何处理从站点 runner](../secondary_proxy/runners.md#handling-a-planned-failover-with-secondary-runners)。

<a id="openbao-prerequisites"></a>

### OpenBao 先决条件

如果您使用 GitLab Helm chart 安装了 [OpenBao](https://gitlab.cn/docs/charts/charts/openbao/)，
请在主集群仍可访问时完成这些检查。

<a id="verify-the-unseal-secret-is-present-on-the-secondary"></a>

#### 验证从站点上存在解封凭据

从集群上必须存在 `gitlab-openbao-unseal` Kubernetes 密钥。验证其是否存在：

```shell
kubectl --namespace gitlab get secret gitlab-openbao-unseal
```

如果该密钥缺失，请在继续之前从主站点复制它。有关更多信息，请参阅[备份密钥](https://gitlab.cn/docs/charts/backup-restore/backup/#back-up-the-secrets)。

<a id="validate-openbao-database-replication"></a>

#### 验证 OpenBao 数据库复制

从站点的 OpenBao 数据库是主站点 PostgreSQL 的只读副本，包括 `openbao` schema。在计划内故障转移之前，请验证复制是最新的，并且从站点数据与主站点一致。

如果主数据库已经不可用，则从站点包含截至最后一次复制事务的数据。在最后一次复制之后写入主站点的任何密钥都会丢失。

<a id="prevent-updates-to-the-primary-site"></a>

## 阻止对主站点的更新

为确保所有数据都复制到从站点，请禁用主站点上的更新（写入请求），以便给从站点时间追赶：

1. 在主站点上启用[维护模式](../../maintenance_mode/_index.md)。
1. 在右上角，选择**管理员**。
1. 在左侧边栏中，选择**监控** > **后台作业**。
1. 在 Sidekiq 仪表板上，选择 **Cron**。
1. 选择 `Disable All` 以禁用非 Geo 的周期性后台作业。
1. 为以下 cron 作业选择 `Enable`：

   - `geo_metrics_update_worker`
   - `geo_prune_event_log_worker`
   - `geo_verification_cron_worker`
   - `repository_check_worker`

   重新启用这些 cron 作业对于计划内故障转移成功完成至关重要。

<a id="finish-replicating-and-verifying-all-data"></a>

## 完成所有数据的复制和验证

1. 如果您正在手动复制任何不受 Geo 管理的数据，请立即触发最终复制流程。
1. 在主站点上：
   1. 在右上角，选择**管理员**。
   1. 在左侧边栏中，选择**监控** > **后台作业**。
   1. 在 Sidekiq 仪表板上，选择**队列**。等待所有队列（名称中包含 `geo`的队列除外）降至 0。
      这些队列包含您的用户提交的工作。在队列清空之前进行故障转移会导致这些工作丢失。
   1. 在左侧边栏中，选择 **Geo** > **站点**。等待您要故障转移到的从站点满足以下条件：

      - 所有复制指标达到 100% 已复制，且 0% 失败。
      - 所有验证指标达到 100% 已验证，且 0% 失败。
      - 数据库复制延迟为 0 ms。
      - Geo 日志游标是最新的（落后 0 个事件）。

1. 在从站点上：
   1. 在右上角，选择**管理员**。
   1. 在左侧边栏中，选择**监控** > **后台作业**。
   1. 在 Sidekiq 仪表板上，选择**队列**。等待所有 `geo` 队列降至 0 个排队和 0 个运行中的作业。
   1. [运行完整性检查](../../raketasks/check.md)，以验证文件存储中 CI 产物、LFS 对象和上传内容的完整性。

此时，您的从站点包含主站点所有内容的最新副本，确保在故障转移时不会丢失数据。

<a id="promote-the-secondary-site"></a>

## 提升从站点

复制完成后，[将从站点提升为主站点](_index.md)。此过程会导致从站点短暂中断，用户可能需要重新登录。如果您正确遵循这些步骤，旧的 Geo 主站点将被禁用，用户流量将改为流向新提升的站点。

提升完成后，维护窗口即结束，您的新主站点现在开始与旧主站点产生差异。

故障转移完成后，别忘了移除广播消息。

如果一切按预期工作，您可以[将旧站点作为从站点恢复](bring_primary_back.md#configure-the-former-primary-site-to-be-a-secondary-site)。

<a id="fall-back-to-the-old-primary"></a>

### 回退到旧主站点

如果新提升的主站点出现问题，可以[回退到旧主站点](bring_primary_back.md)，但是，在新主站点上所做的所有更改都会丢失。
