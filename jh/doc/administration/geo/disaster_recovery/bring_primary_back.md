---
stage: GitLab Dedicated
group: Geo
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
title: 将已降级的站点重新引入 Geo
---

{{< details >}}

- Tier: 专业版，旗舰版
- Offering: 私有化部署

{{< /details >}}

故障转移后，可以将已降级的主站点重新作为新的从站点恢复，或恢复原来的主站点。此过程包含两个步骤：

1. 将旧主站点设为从站点。
1. 将从站点提升为主站点。

> [!warning]
>
> - 如果您对该站点数据的一致性有任何疑虑，应从头重新设置该站点。
> - 已降级的主站点被视为一个独立的极狐GitLab 服务器，不再与 Geo 同步。
>
>   在将其重新添加为新的从站点之前，请确保已移除其作为原主站点的所有残留配置。

<a id="configure-the-former-primary-site-to-be-a-secondary-site"></a>

## 将原主站点配置为从站点

由于原主站点与当前主站点不同步，第一步是使原主站点恢复同步。请注意，将原主站点重新纳入同步时，不会重放存储在磁盘上的数据（如代码仓库和上传文件）的删除操作，这可能导致磁盘使用量增加。或者，您可以[设置一个新的从站点极狐GitLab 实例](../setup/_index.md)来避免此问题。

要使原主站点恢复同步：

1. 通过 SSH 登录到已落后的原主站点。
1. 删除 `/etc/gitlab/gitlab-cluster.json`（如果存在）。（[什么是 `gitlab-cluster.json` 文件？](https://gitlab.cn/docs/omnibus/development/reconfigure_in_detail/#gitlab-clusterjson-file)）

   如果要重新添加为从站点的站点是通过 `gitlab-ctl geo promote` 命令提升的，那么它可能包含 `/etc/gitlab/gitlab-cluster.json`。例如，在运行 `gitlab-ctl reconfigure` 期间，您可能会看到类似如下输出：

   ```plaintext
   The 'geo_primary_role' is defined in /etc/gitlab/gitlab-cluster.json as 'true' and overrides the setting in the /etc/gitlab/gitlab.rb
   ```

   如果是这样，则必须从该站点的每个 Sidekiq、PostgreSQL、Gitaly 和 Rails 节点（如果使用多节点设置）中删除 `/etc/gitlab/gitlab-cluster.json`，以使 `/etc/gitlab/gitlab.rb` 重新成为唯一可信来源。

1. 确保所有服务均已启动：

   ```shell
   sudo gitlab-ctl start
   ```

   > [!note]
   > - 如果您[永久禁用了主站点](_index.md#step-1-permanently-disable-the-primary-site)，
   >   现在需要撤销这些步骤。对于使用 systemd 的发行版，例如 Debian/Ubuntu/CentOS7+，您必须运行
   >   `sudo systemctl enable gitlab-runsvdir`。对于不使用 systemd 的发行版，例如 CentOS 6，您需要从头安装
   >   极狐GitLab 实例，并按照[设置说明](../setup/_index.md)将其设置为从站点。
   >   在这种情况下，您无需执行下一步。
   > - 如果您在灾难恢复过程中[更改了该站点的 DNS 记录](_index.md#optional-updating-the-primary-domain-dns-record)，
   >   则在此过程中您可能需要
   >   [阻止对该站点的所有写入](planned_failover.md#prevent-updates-to-the-primary-site)。

1. [设置 Geo](../setup/_index.md)。在这种情况下，从站点
   指的是原主站点。
   1. 如果当前从站点（当其还是主站点时）启用了 [PgBouncer](../../postgresql/pgbouncer.md)，
      请通过编辑 `/etc/gitlab/gitlab.rb`
      并运行 `sudo gitlab-ctl reconfigure` 将其禁用。
   1. 然后您可以在从站点上设置数据库复制。
   1. 在重新引入的从站点上初始化 Geo 跟踪数据库架构。

      `gitlab-ctl replicate-geo-database` 仅复制主 `gitlabhq_production`
      数据库。Geo 跟踪数据库（`gitlabhq_geo_production`）位于从站点本地，通常由 `sudo gitlab-ctl reconfigure` 通过
      `geo_secondary['auto_migrate']` 进行迁移。如果 `auto_migrate` 被禁用、跟踪
      数据库为外部数据库，或者上次运行 reconfigure 时该数据库为空，则 Geo Log
      Cursor 会停滞，所有同步类型都会保持在 0%。

      在这些情况下，请在从站点的 Rails 或 Sidekiq 节点上：

      1. [手动运行跟踪数据库迁移](../setup/external_database.md#set-up-the-database-schema)。
      1. 重启 Geo Log Cursor，使其加载新架构：

         ```shell
         sudo gitlab-ctl restart geo-logcursor
         ```

      1. 在继续之前，验证跟踪数据库已正确设置：

         ```shell
         # Confirm the tracking database has tables
         sudo gitlab-geo-psql -d gitlabhq_geo_production -c "\dt"

         # Confirm all tracking database migrations are applied
         sudo gitlab-rake db:migrate:status:geo | grep -w down

         # Run the full Geo check
         sudo gitlab-rake gitlab:geo:check
         ```

      `db:migrate:status:geo` 命令应返回没有 `down` 状态的迁移，并且
      `gitlab:geo:check` 应在其输出中报告 `GitLab Geo tracking database is correctly configured ... yes`。

   1. 为 OpenBao 配置 JWT audience。如果您已启用极狐GitLab 密钥管理器，
      并且主站点和从站点不共享相同的 JWT audience，
      请在重新添加的从站点的 Helm values 中将 `jwt_audience` 设置为新主站点的 OpenBao URL：

      ```yaml
      global:
        openbao:
          enabled: true
          url: https://openbao.old-primary.example.com:8200
          jwt_audience: https://openbao.promoted.example.com:8200
      ```

如果您已丢失原主站点，请按照[设置说明](../setup/_index.md)设置一个新的从站点。

<a id="promote-the-secondary-site-to-primary-site"></a>

## 将从站点提升为主站点

当初始复制完成，且主站点和从站点已基本同步时，您可以执行[计划内故障转移](planned_failover.md)。

<a id="restore-the-secondary-site"></a>

## 恢复从站点

如果您的目标是再次拥有两个站点，您还需要通过为从站点重复第一步（[将原主站点配置为从站点](#configure-the-former-primary-site-to-be-a-secondary-site)）来使从站点重新上线。

<a id="restoring-additional-secondary-sites"></a>

### 恢复其他从站点

如果有多个从站点，其余站点现在可以上线。对于每个其余站点，请与主站点[启动复制过程](../setup/database.md#step-3-initiate-the-replication-process)。

<a id="skipping-re-transfer-of-data-on-a-secondary-site"></a>

## 跳过从站点上的数据重新传输

添加从站点时，如果该站点包含原本会从主站点同步的数据，则 Geo 会避免重新传输这些数据。

- Git 代码仓库通过 `git fetch` 传输，仅传输缺失的引用。
- Geo 的容器镜像仓库同步代码会比较标签和摘要的元组，仅拉取缺失的部分。
- 如果 [Blob](#skipping-re-transfer-of-blobs) 在首次同步时已存在，则会跳过。

使用场景：

- 您执行计划内故障转移，并通过将旧主站点作为从站点挂接（而不重建它）来将其降级。
- 您有多个从 Geo 站点。您执行计划内故障转移，并重新挂接其他从 Geo 站点而不重建它们。
- 您通过提升和降级从站点来执行故障转移测试，并重新挂接它而不重建它。
- 您恢复备份，并将该站点作为从站点挂接。
- 您手动将数据复制到从站点，以变通解决同步问题。
- 您删除或截断 Geo 跟踪数据库中的 registry 表行，以变通解决问题。
- 您重置 Geo 跟踪数据库，以变通解决问题。

<a id="skipping-re-transfer-of-blobs"></a>

### 跳过 Blob 的重新传输

当您添加一个已有 Blob 数据的从站点时，从 Geo 站点将避免重新传输这些数据。这适用于：

- CI 作业产物
- CI 流水线产物
- CI 安全文件
- LFS 对象
- 合并请求差异
- 软件包文件
- Pages 部署
- Terraform 状态版本
- 上传文件
- 依赖代理清单
- 依赖代理 Blob

如果从站点的副本实际上已损坏，则后台验证最终会失败，该 Blob 将被重新同步。

仅当这些 Blob 在 Geo 跟踪数据库中没有对应的 registry 记录时，才会以这种方式跳过。条件很严格，因为重新同步几乎总是有意为之，我们不能冒险错误地跳过传输。

<a id="troubleshooting"></a>

## 故障排除

<a id="error-too-many-replication-slots-active-before-shutdown"></a>

### 错误：`too many replication slots active before shutdown`

当您将原主站点配置为从站点时，`sudo gitlab-ctl reconfigure` 可能会失败，因为 PostgreSQL 无法启动。PostgreSQL 日志会显示类似如下错误：

```plaintext
FATAL:  too many replication slots active before shutdown
HINT:  Increase max_replication_slots and try again.
```

当原主站点仍保留其先前角色的复制槽，而从站点配置将 `max_replication_slots` 设置为 `0`（这在单节点从站点中很常见）时，就会出现此问题。只要残留的复制槽存在，PostgreSQL 就会拒绝启动。

为避免此问题，在将原主站点重新配置为从站点之前，请移除其残留的复制槽。有关更多信息，请参阅[移除不活跃的复制槽](../replication/troubleshooting/postgresql_replication.md#removing-an-inactive-replication-slot)。

如果 PostgreSQL 已经启动失败：

1. 在 `/etc/gitlab/gitlab.rb`中，临时将 `postgresql['max_replication_slots']` 设置为
   至少等于残留复制槽数量的值。
1. 重新配置极狐GitLab：

   ```shell
   sudo gitlab-ctl reconfigure
   ```

1. 启动 PostgreSQL 控制台会话：

   ```shell
   sudo gitlab-psql -d gitlabhq_production
   ```

1. 移除所有复制槽：

   ```sql
   SELECT pg_drop_replication_slot(slot_name) FROM pg_replication_slots;
   ```

1. 在 `/etc/gitlab/gitlab.rb`中，移除临时的 `postgresql['max_replication_slots']` 设置，
   并再次重新配置极狐GitLab。
