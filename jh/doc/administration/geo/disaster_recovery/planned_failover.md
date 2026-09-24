---
stage: Tenant Scale
group: Geo
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
description: Use Geo for planned failover to migrate GitLab with minimal downtime by following preflight checks and sync steps to promote a secondary site without data loss.
title: 计划性故障转移的灾难恢复
---

{{< details >}}

- Tier: 专业版，旗舰版
- Offering: 私有化部署

{{< /details >}}

The primary use case of Disaster Recovery is to ensure business continuity in
the event of unplanned outage, but it can be used in conjunction with a planned
failover to migrate your GitLab instance between regions without extended
downtime.

Replication between Geo sites is asynchronous, so a planned failover requires a maintenance window
in which updates to the primary site are blocked. The length of this window depends on how long
it takes to fully synchronize the secondary site with the primary site. When synchronization is
complete, the failover can occur without data loss.

This document assumes you already have a fully configured, working Geo setup.
Read this document and the [Disaster Recovery](_index.md) failover
documentation in full before proceeding. Planned failover is a major operation,
and if performed incorrectly, there is a high risk of data loss.
Rehearse the procedure until you are comfortable with the necessary steps, and
have a high degree of confidence you can perform them accurately.

<a id="recommendations-for-failover"></a>

## 故障转移建议

遵循这些建议有助于确保故障转移过程顺利进行，并降低数据丢失或延长停机时间的风险。

<a id="resolve-sync-and-verification-failures"></a>

### 解决同步和验证失败问题

如果在 [preflight checks](#preflight-checks)（手动验证或运行 `gitlab-ctl promotion-preflight-checks` 时）中出现 **Failed** 或 **Queued** 项目，则故障转移将被阻止，直到这些项目：

- 已解决：成功同步（如有必要可手动复制到辅助站点）并验证。
- 记录为可接受：有明确理由，例如：
  - 针对这些特定故障，手动校验和比较通过。
  - 仓库已弃用，可以排除。
  - 项目被识别为非关键，可以在故障转移后复制。

有关诊断同步和验证失败的帮助，请参见
[Troubleshooting Geo synchronization and verification errors](../replication/troubleshooting/synchronization_verification.md)。

<a id="plan-for-data-integrity-resolution"></a>

### 规划数据完整性解决方案

在故障转移完成前留出 4-6 周时间来解决首次设置 Geo 复制后通常会出现的数据完整性问题。这些问题可能包括孤立的数据库记录或不一致的文件引用。
有关指导，请参见 [Troubleshooting common Geo errors](../replication/troubleshooting/common.md)。

尽早开始解决同步问题，以避免在维护窗口期间做出艰难的决定：

1. 提前 4-6 周：识别并开始解决未完成的同步问题。
1. 提前 1 周：目标解决或记录所有剩余的同步问题。
1. 提前 1-2 天：解决任何新的故障。
1. 提前数小时：最后检查是否有新的故障。

为确保成功：为因未解决的同步错误而中止故障转移创建明确的标准。

<a id="test-backup-timing-in-geo-environments"></a>

### 在 Geo 环境中测试备份时机

> [!warning]
> 在活跃的数据库事务期间，来自 Geo 副本数据库的备份可能会被取消。

提前测试备份过程，并考虑以下策略：

- 直接从主站点进行备份。这可能会影响性能。
- 使用一个专门的只读副本，该副本在备份期间可以与复制隔离。
- 在低活动期安排备份。

<a id="prepare-comprehensive-fallback-procedures"></a>

### 准备全面的回退程序

> [!warning]
> 在提升完成之前规划回滚决策点，因为之后再进行回退可能会导致数据丢失。

记录恢复到原始主站点的具体步骤，包括：

- 何时中止故障转移的决策标准。
- DNS 恢复程序。
- 重新启用原始主站点的流程。请参见 [使降级的主站点重新上线](bring_primary_back.md)。
- 用户沟通计划。

<a id="develop-a-failover-runbook-in-a-staging-environment"></a>

### 在预发布环境中制定故障转移操作手册

为确保成功，请详细练习并记录这项高度手册化的任务：

1. 如果您还没有一个类似生产环境的环境，请进行配置。
1. 进行冒烟测试。例如，添加群组、添加项目、添加 Runner、使用 `git push`、向议题添加图片。
1. 故障转移到辅助站点。
1. 运行冒烟测试。发现问题。
1. 在这些步骤中，记录下所采取的每一项操作、操作者、预期结果以及相关资源链接。
1. 根据需要重复，以完善操作手册和脚本。

<a id="not-all-data-is-automatically-replicated"></a>

## 并非所有数据都会自动复制

如果您正在使用 Geo 不支持的极狐GitLab 功能，则必须单独进行配置，以确保辅助站点具有与该功能相关的所有数据的更新副本。这可能会显著延长维护时间。有关 Geo 支持的功能列表，请参见
[replicated data types table](../replication/datatypes.md#replicated-data-types)。

对于存储在文件中的数据，一种常见策略是使用 `rsync` 传输数据，以尽可能缩短这段时间。可以在维护窗口之前执行初始 `rsync`。后续的 `rsync` 过程，包括在维护窗口内进行的最终传输，将只传输主站点和辅助站点之间的更改。

有关使用 `rsync` 以 Git 仓库为中心的策略，请参见
[moving repositories](../../operations/moving_repositories.md)。这些策略可适用于任何其他基于文件的数据。

<a id="container-registry"></a>

### 容器镜像仓库

默认情况下，容器镜像仓库不会自动复制到辅助站点。需要手动配置。有关更多信息，请参见
[容器镜像仓库辅助站点](../replication/container_registry.md)。

如果您在当前主站点上为容器镜像仓库使用本地存储，则可以将容器镜像仓库对象通过 `rsync` 传输到您即将故障转移到的辅助站点：

```shell
# 从辅助站点运行
rsync --archive --perms --delete root@<geo-primary>:/var/opt/gitlab/gitlab-rails/shared/registry/. /var/opt/gitlab/gitlab-rails/shared/registry
```

或者，[备份](../../backup_restore/_index.md#back-up-gitlab)
主站点上的容器镜像仓库，并将其恢复到辅助站点上：

1. 在主站点上，仅备份镜像仓库，并
   [从备份中排除特定目录](../../backup_restore/backup_gitlab.md#excluding-specific-data-from-the-backup)：

   ```shell
   # 在 /var/opt/gitlab/backups 文件夹中创建备份
   sudo gitlab-backup create SKIP=db,uploads,builds,artifacts,lfs,terraform_state,pages,repositories,packages
   ```

1. 将主站点生成的备份 tarball 复制到辅助站点的 `/var/opt/gitlab/backups` 文件夹中。
1. 在辅助站点上，按照 [Restore GitLab](../../backup_restore/_index.md#restore-gitlab) 文档恢复镜像仓库。

<a id="recover-data-for-advanced-search"></a>

### 恢复高级搜索数据

高级搜索由 Elasticsearch 或 OpenSearch 提供支持。
高级搜索数据不会自动复制到辅助站点。

要在新提升的主站点上恢复高级搜索数据：

{{< tabs >}}

{{< tab title="极狐GitLab 17.2 及更高版本" >}}

1. 禁用 Elasticsearch 搜索：

   ```shell
   sudo gitlab-rake gitlab:elastic:disable_search_with_elasticsearch
   ```

1. [对整个实例重新索引](../../../integration/advanced_search/elasticsearch.md#index-the-instance)。
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

1. 暂停索引并等待五分钟以使正在进行的任务完成：

   ```shell
   sudo gitlab-rake gitlab:elastic:pause_indexing
   ```

1. 从头开始重新索引实例：

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

## 预检检查

在安排计划性故障转移之前，请通过验证这些预检检查来确保过程顺利进行。下面将更详细地描述每个步骤。

在实际故障转移过程中，当主站点宕机后，运行此命令，以在提升辅助站点之前执行最终验证检查：

```shell
gitlab-ctl promotion-preflight-checks
```

`gitlab-ctl promotion-preflight-checks` 命令是故障转移过程的一部分，要求主站点处于宕机状态。当主站点仍在运行时，您不能将其用作维护前验证工具。运行此命令时，系统会提示您询问主站点是否已宕机。如果回答 `No`，则会显示以下错误：`ERROR: primary node must be down`.

对于主站点仍在运行时的维护前验证，请使用下面的手动检查。

<a id="dns-ttl"></a>

### DNS TTL

如果您计划 [更新主域名 DNS 记录](_index.md#optional-updating-the-primary-domain-dns-record)，
请考虑设置较低的 TTL（生存时间），以确保 DNS 更改的快速传播。

<a id="object-storage"></a>

### 对象存储

如果您的极狐GitLab 安装规模很大或者无法容忍停机，请考虑在安排计划性故障转移之前
[迁移到对象存储](../replication/object_storage.md)。
这样做既可以缩短维护窗口的时间，也可以降低因计划性故障转移执行不当而导致数据丢失的风险。

如果您希望极狐GitLab 管理辅助站点的对象存储复制，
请参见 [对象存储复制](../replication/object_storage.md)。

<a id="review-the-configuration-of-each-secondary-site"></a>

### 检查每个辅助站点的配置

数据库设置会自动复制到辅助站点。但是，您必须手动设置 `/etc/gitlab/gitlab.rb` 文件，并且各个站点之间的文件有所不同。如果诸如 Mattermost、OAuth 或 LDAP 集成等功能在主站点上启用而在辅助站点上未启用，则在故障转移期间这些功能将会丢失。

检查两个站点的 `/etc/gitlab/gitlab.rb` 文件。确保在安排计划性故障转移之前，辅助站点支持主站点所支持的所有功能。
确保 [极狐GitLab Geo 角色](https://gitlab.cn/docs/omnibus/roles/#gitlab-geo-roles) 配置正确。

<a id="run-system-checks"></a>

### 运行系统检查

在主站点和辅助站点上运行以下命令：

```shell
gitlab-rake gitlab:check
gitlab-rake gitlab:geo:check
```

如果任一站点报告任何故障，请在安排计划性故障转移之前解决它们。

<a id="check-that-secrets-and-ssh-host-keys-match-between-nodes"></a>

### 检查节点之间的密钥和 SSH 主机密钥是否匹配

SSH 主机密钥和 `/etc/gitlab/gitlab-secrets.json` 文件应在所有节点上完全相同。通过在所有节点上运行以下命令并比较输出来检查这一点：

```shell
sudo sha256sum /etc/ssh/sshhost /etc/gitlab/gitlab-secrets.json
```

如果有任何文件存在差异，请根据需要对辅助站点
[手动复制极狐GitLab 密钥](../replication/configuration.md#step-1-manually-replicate-secret-gitlab-values) 和
[复制 SSH 主机密钥](../replication/configuration.md#step-2-manually-replicate-the-primary-sites-ssh-host-keys)。

<a id="check-that-the-correct-certificates-are-installed-for-https"></a>

### 检查是否为 HTTPS 安装了正确的证书

如果主站点以及主站点访问的所有外部站点都使用由公共 CA 颁发的证书，则可以安全地跳过此步骤。

如果出现以下任何一种情况，您应该在辅助站点上安装正确的证书：

- 主站点使用自定义或自签名 TLS 证书来保护入站连接。
- 主站点连接到使用自定义或自签名证书的外部服务。

有关更多信息，请参见
[在辅助站点上使用自定义证书](../replication/configuration.md#step-4-optional-using-custom-certificates)。

<a id="ensure-geo-replication-is-up-to-date"></a>

### 确保 Geo 复制是最新的

在 Geo 复制和验证完全完成之前，维护窗口不会结束。为了尽可能缩短窗口时间，您应该确保这些过程在活跃使用期间尽可能接近 100%。

在辅助站点上：

1. 在右上角，选择 **管理员**。
1. 在左侧边栏中，选择 **Geo** > **站点**。
   已复制的对象（以绿色显示）应接近 100%，并且不应有任何失败（以红色显示）。如果大部分对象尚未复制（以灰色显示），请考虑给站点更多时间来完成：

   ![Geo 管理仪表板，显示辅助站点的同步状态](img/geo_dashboard_v14_0.png)

如果对象复制失败，请在安排维护窗口之前进行调查。
在计划性故障转移之后，任何复制失败的对象都会丢失。

复制失败的常见原因是主站点上缺少数据。要解决这些故障，可以：

- 从备份中恢复数据。
- 删除对丢失数据的引用。

<a id="verify-the-integrity-of-replicated-data"></a>

### 验证复制数据的完整性

在进行故障转移之前，请确保验证完成。验证失败的损坏数据可能在故障转移过程中丢失。

有关更多信息，请参见 [自动后台验证](background_verification.md)。

<a id="notify-users-of-scheduled-maintenance"></a>

### 通知用户计划维护

在主站点上：

1. 在右上角，选择 **管理员**。
1. 在左侧边栏中，选择 **消息**。
1. 添加一条通知用户维护窗口的消息。要估计完成同步所需的时间，请转至 **Geo** > **站点**。
1. 选择 **添加广播消息**。

<a id="runner-connectivity-during-failover"></a>

### 故障转移期间的 Runner 连接性

根据实例 URL 的配置方式，在故障转移后可能需要进行额外的步骤来保持您的 runner 集群 100% 可用。

用于注册 runners 的令牌应在主站点或辅助站点上都能正常工作。如果您在故障转移后遇到连接问题，则可能是您在配置辅助站点时
[手动复制密钥](../setup/two_single_node_sites.md#manually-replicate-secret-gitlab-values) 的过程中未将密钥复制过来。
您可以 [重置 runner 令牌](../../backup_restore/troubleshooting_backup_gitlab.md#reset-runner-registration-tokens)，
但是，请注意，如果密钥不同步，您可能会遇到与 runners 无关的其他问题。

如果 runner 反复无法连接到极狐GitLab 实例，它会在一段时间内停止尝试连接。默认情况下，这段时间为 1 小时。为避免这种情况，请关闭 runners，直到极狐GitLab 实例可达。参见
[`check_interval` 文档](https://gitlab.cn/docs/runner/configuration/advanced-configuration/#how-check_interval-works)，
以及配置选项 `unhealthy_requests_limit` 和 `unhealthy_interval`。

- 如果您使用我们的 **位置感知 URL**：从 DNS 配置中删除旧的主站点后，runners 应自动连接到下一个最近的实例。
- 如果您使用单独的 URL：任何连接到当前主站点的 runner 都应更新为连接到新的主站点（一旦它被提升）。
- 如果您的任何 runners 连接到当前的辅助站点：请参见
  [如何在故障转移期间处理辅助 runners](../secondary_proxy/runners.md#handling-a-planned-failover-with-secondary-runners)。

<a id="openbao-prerequisites"></a>

### OpenBao 先决条件

如果您已使用极狐GitLab Helm chart 安装了 [OpenBao](https://gitlab.cn/docs/charts/charts/openbao/)，
请在 **主站点** 集群仍可访问时完成这些检查。

<a id="verify-the-unseal-secret-is-present-on-the-secondary"></a>

#### 验证辅助站点上存在解封秘密

`gitlab-openbao-unseal` Kubernetes secret 必须存在于辅助集群上。
验证其是否存在：

```shell
kubectl --namespace gitlab get secret gitlab-openbao-unseal
```

如果缺少此 secret，请在继续之前从主站点复制它。
有关更多信息，请参见
[备份秘密](https://gitlab.cn/docs/charts/backup-restore/backup/#back-up-the-secrets)。

<a id="validate-openbao-database-replication"></a>

#### 验证 OpenBao 数据库复制

辅助 OpenBao 数据库是主 PostgreSQL 的只读副本，包括 `openbao` 模式。在计划性故障转移之前，请验证复制是最新的，并且辅助数据与主数据一致。

如果主数据库已经不可用，则辅助数据库包含截至上次复制事务的数据。主站点在上次复制之后写入的任何密钥都将丢失。

<a id="prevent-updates-to-the-primary-site"></a>

## 阻止对主站点的更新

为了确保所有数据都能复制到辅助站点，请在主站点上禁用更新（写入请求），以便给辅助站点时间来跟上进度：

1. 在主站点上启用 [维护模式](../../maintenance_mode/_index.md)。
1. 在右上角，选择 **管理员**。
1. 在左侧边栏中，选择 **监控** > **后台作业**。
1. 在 Sidekiq 仪表板上，选择 **Cron**。
1. 选择 `全部禁用` 以禁用非 Geo 的周期性后台作业。
1. 为以下 cron 作业选择 `启用`：

   - `geo_metrics_update_worker`
   - `geo_prune_event_log_worker`
   - `geo_verification_cron_worker`
   - `repository_check_worker`

   重新启用这些 cron 作业对于计划性故障转移的成功完成至关重要。

<a id="finish-replicating-and-verifying-all-data"></a>

## 完成所有数据的复制和验证

1. 如果您正在手动复制任何不由 Geo 管理的数据，请现在触发最终复制过程。
1. 在主站点上：
   1. 在右上角，选择 **管理员**。
   1. 在左侧边栏中，选择 **监控** > **后台作业**。
   1. 在 Sidekiq 仪表板上，选择 **队列**。等待所有队列（名称中带有 `geo` 的队列除外）降至 0。
      这些队列包含用户提交的工作。在队列清空之前进行故障转移会导致工作丢失。
   1. 在左侧边栏中，选择 **Geo** > **站点**。等待以下条件对于您要故障转移到的辅助站点全部为真：

      - 所有复制计量器达到 100% 已复制，0% 失败。
      - 所有验证计量器达到 100% 已验证，0% 失败。
      - 数据库复制延迟为 0 毫秒。
      - Geo 日志游标是最新的（落后 0 个事件）。

1. 在辅助站点上：
   1. 在右上角，选择 **管理员**。
   1. 在左侧边栏中，选择 **监控** > **后台作业**。
   1. 在 Sidekiq 仪表板上，选择 **队列**。等待所有 `geo` 队列降至 0 个排队作业和 0 个运行中的作业。
   1. [运行完整性检查](../../raketasks/check.md)，以验证文件存储中的 CI 产物、LFS 对象和上传的完整性。

此时，您的辅助站点包含主站点所有内容的最新副本，确保在故障转移时不会丢失数据。

<a id="promote-the-secondary-site"></a>

## 提升辅助站点

复制完成后，[将辅助站点提升为主站点](_index.md)。
此过程会导致辅助站点出现短暂中断，用户可能需要重新登录。如果您正确执行了这些步骤，旧的 Geo 主站点将被禁用，用户流量将转而流向新提升的站点。

提升完成后，维护窗口结束，您的新主站点现在开始与旧主站点产生差异。

故障转移完成后，请不要忘记删除广播消息。

如果一切如预期正常工作，您可以
[将旧站点作为辅助站点重新启用](bring_primary_back.md#configure-the-former-primary-site-to-be-a-secondary-site)。

<a id="fall-back-to-the-old-primary"></a>

### 回退到旧主站点

如果新提升的主站点出现问题，[回退到旧主站点](bring_primary_back.md) 是可能的，
但是，在新主站点上所做的所有更改都会丢失。