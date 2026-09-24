---
stage: Tenant Scale
group: Geo
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
ignore_in_report: true
title: 灾难恢复（Geo）提升操作手册
---

{{< details >}}

- Tier: 专业版，旗舰版
- Offering: 私有化部署
- Status: 实验

{{< /details >}}

灾难恢复（Geo）提升操作手册。

> [!warning]
> 本操作手册为[实验性](../../../../policy/development_stages_support.md#experiment)内容。如需完整的、可用于生产环境的文档，请参阅
> [灾难恢复文档](../_index.md)。

<a id="geo-planned-failover-for-a-multi-node-configuration"></a>

## 多节点配置的 Geo 计划故障转移

| 组件   | 配置                |
|:------------|:-----------------------------|
| PostgreSQL  | 由 Linux 软件包管理 |
| Geo 站点    | 多节点                   |
| 辅助站点 | 一个                          |

本操作手册将引导你完成对拥有一个辅助站点的多节点 Geo 站点进行计划故障转移。假设采用以下 [40 RPS / 2,000 用户参考架构](../../../reference_architectures/2k_users.md)：

主站点（多节点）：

- Rails 节点 1
- Rails 节点 2
- PostgreSQL 节点
- Gitaly 节点
- Redis 节点
- 监控节点

辅助站点：

- Rails 节点 1
- Rails 节点 2
- PostgreSQL 节点
- Gitaly 节点
- Redis 节点
- 监控节点

本指南最终将达成以下结果：

1. 一个离线的主站点。
1. 一个已提升的辅助站点，现在成为新的主站点。

未涵盖的内容：

1. 将旧**主站点**重新添加为辅助站点。
1. 添加新的辅助站点。

<a id="preparation"></a>

### 准备

> [!note]
> 在执行以下任何步骤之前，请确保你拥有对**辅助站点**的 `root` 访问权限以进行提升，因为系统未提供自动化的方式
> 来提升 Geo 副本并执行故障转移。

在**辅助站点**上：

1. 在右上角，选择**管理员**。
1. 在左侧边栏中，选择 **Geo** > **站点**以查看其状态。
   已复制的对象（显示为绿色）应接近 100%，
   并且不应有任何失败项（显示为红色）。如果有大量对象
   尚未复制（显示为灰色），请考虑给站点更多时间来完成复制。

   ![复制状态](img/geo_dashboard_v14_0.png)

如果有任何对象复制失败，应在安排维护窗口之前进行调查。在计划故障转移之后，任何
未能复制的内容将**丢失**。

复制失败的常见原因是**主站点**上缺少数据 - 你可以通过从备份恢复数据
或删除对缺失数据的引用来解决这些失败。

在 Geo 复制和验证完全完成之前，维护窗口不会结束。为了尽可能缩短窗口时间，你应确保
这些流程在使用期间尽可能接近 100%。

如果**辅助站点**仍在从**主站点**复制数据，
请按照以下步骤操作，以避免不必要的数据丢失：

1. 在**主站点**上启用[维护模式](../../../maintenance_mode/_index.md)，
   并确保停止所有[后台作业](../../../maintenance_mode/_index.md#background-jobs)。
1. 完成所有数据的复制和验证：

   > [!warning]
   > 并非所有数据都会自动复制。阅读更多关于
   > [哪些数据不会被自动复制](../planned_failover.md#not-all-data-is-automatically-replicated)。

   1. 如果你正在手动复制任何
      [Geo 不管理的数据](../../replication/datatypes.md#replicated-data-types)，
      请立即触发最终的复制流程。
   1. 在**主站点**上：
      1. 在右上角，选择**管理员**。
      1. 在左侧边栏中，选择**监控** > **后台作业**。
      1. 在 Sidekiq 仪表板上，选择**队列**，并等待除了名称中包含 `geo` 的队列之外的所有队列降至 0。
         这些队列包含你的用户提交的工作；在这些工作完成之前进行故障转移，会导致工作丢失。
      1. 在左侧边栏中，选择 **Geo** > **站点**，并等待
         你要故障转移到的**辅助站点**满足以下条件：

         - 所有复制仪表达到 100% 已复制，0% 失败。
         - 所有验证仪表达到 100% 已验证，0% 失败。
         - 数据库复制延迟为 0 毫秒。
         - Geo 日志游标是最新的（落后 0 个事件）。

   1. 在**辅助站点**上：
      1. 在右上角，选择**管理员**。
      1. 在左侧边栏中，选择**监控** > **后台作业**。
      1. 在 Sidekiq 仪表板上，选择**队列**，并等待所有 `geo` 队列降至 0 个排队作业和 0 个正在运行的作业。
      1. [运行完整性检查](../../../raketasks/check.md)以验证文件存储中 CI 产物、LFS 对象和上传文件的完整性。

   此时，你的**辅助站点**包含了**主站点**所有内容的最新副本，这意味着在故障转移时不会丢失任何数据。

1. 在这最后的步骤中，你必须永久禁用**主站点**。

   > [!warning]
   > 当**主站点**下线时，可能存在保存在**主站点**上
   > 但尚未复制到**辅助站点**的数据。如果你继续操作，这些数据应视为
   > 已丢失。

   如果你计划[更新**主站点**域名的 DNS 记录](../_index.md#optional-updating-the-primary-domain-dns-record)，
   你可能希望现在降低 TTL 以加快传播速度。

   在执行故障转移时，我们希望避免出现脑裂情况，即写入可能发生在两个不同的极狐GitLab 实例中。因此，为了准备
   故障转移，你必须禁用**主站点**：

   - 如果你具有对**主站点**的 SSH 访问权限，请停止并禁用极狐GitLab：

     ```shell
     sudo gitlab-ctl stop
     ```

     防止服务器意外重启时极狐GitLab 再次启动：

     ```shell
     sudo systemctl disable gitlab-runsvdir
     ```

     > [!note]
     >
     > - 在 CentOS 6 或更早版本中，如果机器重启，很难阻止极狐GitLab 启动（参见 [issue 3058](https://jihulab.com/gitlab-cn/omnibus-gitlab/-/issues/3058)）。
     >   最安全的做法可能是使用 `sudo yum remove gitlab-ee` 完全卸载极狐GitLab 软件包。
     > - 如果你使用的是较旧版本的 Ubuntu（如 14.04 LTS）
     >   或任何其他基于 Upstart 初始化系统的发行版，你可以通过以下方式以 `root` 用户防止极狐GitLab
     >   在机器重启时启动：
     >   `initctl stop gitlab-runsvvdir && echo 'manual' > /etc/init/gitlab-runsvdir.override && initctl reload-configuration`。

   - 如果你不具有对**主站点**的 SSH 访问权限，请将机器离线并
     阻止其重启。由于有多种方法可以实现这一点，
     我们避免推荐单一方法。你可能需要：

     - 重新配置负载均衡器。
     - 更改 DNS 记录（例如，将**主站点**的 DNS 记录指向
       **辅助站点**，以停止使用**主站点**）。
     - 停止虚拟服务器。
     - 通过防火墙阻止流量。
     - 撤销**主站点**的对象存储权限。
     - 物理断开机器连接。

<a id="promoting-the-secondary-site"></a>

### 提升**辅助站点**

1. SSH 到**辅助站点**中的每个 Sidekiq、PostgreSQL 和 Gitaly 节点，并运行以下命令之一：

   - 将辅助站点提升为主站点：

     ```shell
     sudo gitlab-ctl geo promote
     ```

   - 将辅助站点提升为主站点，无需任何进一步确认：

     ```shell
     sudo gitlab-ctl geo promote --force
     ```

1. SSH 到**辅助站点**上的每个 Rails 节点，并运行以下命令之一：

   - 将辅助站点提升为主站点：

     ```shell
     sudo gitlab-ctl geo promote
     ```

   - 将辅助站点提升为主站点，无需任何进一步确认：

     ```shell
     sudo gitlab-ctl geo promote --force
     ```

1. 验证你可以使用先前用于**辅助站点**的 URL 连接到新提升的**主站点**。

1. 如果成功，**辅助站点**现在已提升为**主站点**。

<a id="next-steps"></a>

### 后续步骤

为了尽快恢复地理冗余，你应该
[添加一个新的**辅助站点**](../../setup/_index.md)。要做到这一点，
你可以将旧的**主站点**重新添加为新的辅助站点，并将其重新上线。