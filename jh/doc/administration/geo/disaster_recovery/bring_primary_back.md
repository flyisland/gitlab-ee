---
stage: Tenant Scale
group: Geo
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
title: 将降级的站点重新加入到 Geo 中
---

{{< details >}}

- Tier: 专业版，旗舰版
- Offering: 私有化部署

{{< /details >}}

在故障转移之后，你可以将降级的 **主站点** 恢复为一个新的 **辅助站点**，或者恢复原来的 **主站点**。这个过程分为两个步骤：

1. 让原来的 **主站点** 成为一个 **辅助站点**。
1. 将一个 **辅助站点** 提升为 **主站点**。

> [!warning]
>
> - 如果你对该站点上数据的一致性有任何疑虑，应当从头开始设置。
> - 降级后的主站点被视为一个独立的 GitLab 服务器，不再与 Geo 同步。
>
>   在将其重新添加为新的辅助站点之前，请务必移除它作为前主站点的所有残留配置。

<a id="configure-the-former-primary-site-to-be-a-secondary-site"></a>

## 将原有的 **主站点** 配置为 **辅助站点**

由于原有的 **主站点** 已经与当前的 **主站点** 不同步，第一步是让原有的 **主站点** 追上进度。注意：在让原有的 **主站点** 重新同步时，不会重放对磁盘上存储的数据（如代码仓库和上传文件）的删除操作，这可能导致磁盘使用量增加。
或者，你也可以[设置一个新的 **辅助** GitLab 实例](../setup/_index.md)来避免这种情况。

要让原有的 **主站点** 追上进度：

1. 通过 SSH 登录到已经落后的原有 **主站点**。
1. 删除 `/etc/gitlab/gitlab-cluster.json`（如果存在）。（[什么是 `gitlab-cluster.json` 文件？](https://gitlab.cn/docs/omnibus/development/reconfigure_in_detail/#gitlab-clusterjson-file)）

   如果要重新添加为 **辅助站点** 的站点是使用 `gitlab-ctl geo promote` 命令提升的，那么它可能包含 `/etc/gitlab/gitlab-cluster.json` 文件。例如，在执行 `gitlab-ctl reconfigure` 时，你可能会看到类似这样的输出：

   ```plaintext
   'geo_primary_role' 在 /etc/gitlab/gitlab-cluster.json 中被定义为 'true'，并覆盖了 /etc/gitlab/gitlab.rb 中的设置。
   ```

   如果是这样，则必须从站点中的每个 Sidekiq、PostgreSQL、Gitaly 和 Rails 节点（如果使用多节点设置）删除 `/etc/gitlab/gitlab-cluster.json`，使 `/etc/gitlab/gitlab.rb` 重新成为唯一的配置来源。

1. 确保所有服务都正在运行：

   ```shell
   sudo gitlab-ctl start
   ```

   > [!note]
   > - 如果你之前[永久禁用了 **主站点**](_index.md#step-1-permanently-disable-the-primary-site)，现在需要撤销这些操作。对于使用 systemd 的发行版（例如 Debian/Ubuntu/CentOS7+），你必须运行
   >   `sudo systemctl enable gitlab-runsvdir`。对于不使用 systemd 的发行版（例如 CentOS 6），你需要从头安装 GitLab 实例，并按照[设置说明](../setup/_index.md)将其设置为 **辅助站点**。在这种情况下，你无需执行后续步骤。
   > - 如果你在灾难恢复过程中[更改了该站点的 DNS 记录](_index.md#optional-updating-the-primary-domain-dns-record)，可能需要在此过程中[阻止对该站点的所有写入](planned_failover.md#prevent-updates-to-the-primary-site)。

1. [设置 Geo](../setup/_index.md)。在这个场景中，**辅助站点** 指的就是原有的 **主站点**。
   1. 如果 [PgBouncer](../../postgresql/pgbouncer.md) 在**当前辅助站点**（即它还是主站点时）处于启用状态，请通过编辑 `/etc/gitlab/gitlab.rb` 并运行 `sudo gitlab-ctl reconfigure` 来禁用它。
   1. 然后，你可以在 **辅助站点** 上设置数据库复制。

   1. 为 OpenBao 配置 JWT audience。如果你已启用 GitLab Secrets Manager，并且主站点和辅助站点不共享相同的 JWT audience，请在重新添加的辅助站点的 Helm values 中将 `jwt_audience` 设置为新主站点的 OpenBao URL：

      ```yaml
      global:
        openbao:
          enabled: true
          url: https://openbao.old-primary.example.com:8200
          jwt_audience: https://openbao.promoted.example.com:8200
      ```

如果你丢失了原有的 **主站点**，请按照[设置说明](../setup/_index.md)设置一个新的 **辅助站点**。

<a id="promote-the-secondary-site-to-primary-site"></a>

## 将 **辅助站点** 提升为 **主站点**

当初始复制完成，并且 **主站点** 和 **辅助站点** 紧密同步后，你可以进行[计划内故障转移](planned_failover.md)。

<a id="restore-the-secondary-site"></a>

## 恢复 **辅助站点**

如果你的目标是重新拥有两个站点，那么你还需要通过为 **辅助站点** 重复第一步（[将原有的 **主站点** 配置为 **辅助站点**](#configure-the-former-primary-site-to-be-a-secondary-site)）来让其重新上线。

<a id="restoring-additional-secondary-sites"></a>

### 恢复其他 **辅助站点**

如果有多个 **辅助站点**，其余的站点现在可以上线。对于每个剩余的站点，[启动与 **主站点** 之间的复制过程](../setup/database.md#step-3-initiate-the-replication-process)。

<a id="skipping-re-transfer-of-data-on-a-secondary-site"></a>

## 跳过 **辅助站点** 上的数据重新传输

当添加一个辅助站点时，如果它包含原本会从主站点同步过来的数据，Geo 会避免重新传输这些数据。

- Git 仓库通过 `git fetch` 传输，这只会传输缺失的引用。
- Geo 的容器镜像仓库同步代码会比较 tag 和 digest 的元组，只拉取缺失的。
- 在第一次同步时，如果[Blob 数据](#skipping-re-transfer-of-blobs)已存在，则会跳过。

使用场景：

- 你进行计划内故障转移，通过将旧的主站点作为辅助站点附加，而不重新构建它，从而降级旧的主站点。
- 你有多个 Geo 辅助站点。你进行计划内故障转移，并重新附加其他 Geo 辅助站点，而不重新构建它们。
- 你通过提升和降级一个辅助站点来执行故障转移测试，然后在不重新构建的情况下重新附加它。
- 你恢复了一个备份，并将该站点作为辅助站点附加。
- 你手动复制数据到辅助站点以解决同步问题。
- 你删除或截断 Geo 追踪数据库中的 registry 表行以解决问题。
- 你重置了 Geo 追踪数据库以解决问题。

<a id="skipping-re-transfer-of-blobs"></a>

### 跳过 Blob 数据的重新传输

{{< history >}}

- 在 极狐GitLab 16.8 引入，带有名为 `geo_skip_download_if_exists` 的[功能标志](../../feature_flags/_index.md)。默认禁用。
- 在 极狐GitLab 16.9 GA。功能标志 `geo_skip_download_if_exists` 已移除。

{{< /history >}}

当你添加一个已存在 Blob 数据的辅助站点时，Geo 辅助站点将避免重新传输这些数据。这适用于：

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

如果辅助站点的副本实际已损坏，后台验证最终会失败，Blob 数据将被重新同步。

只有 Blob 数据在 Geo 追踪数据库中没有对应的 registry 记录时，才会以上述方式被跳过。这些条件很严格，因为重新同步通常都是有意的，我们不能冒险错误地跳过传输。