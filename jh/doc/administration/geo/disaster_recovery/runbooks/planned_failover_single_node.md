---
stage: Tenant Scale
group: Geo
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
ignore_in_report: true
title: 灾备（Geo）晋升 runbook
---

{{< details >}}

- Tier: 专业版，旗舰版
- Offering: 私有化部署
- Status: Experiment

{{< /details >}}

灾备（Geo）晋升 runbook。

> [!warning]
> 本 runbook 为 [实验性功能](../../../../policy/development_stages_support.md#experiment)。有关完整的、生产就绪的文档，请参阅
> [灾备文档](../_index.md)。

<a id="geo-planned-failover-for-a-single-node-configuration"></a>

## 单节点配置的 Geo 计划性故障转移

| 组件 | 配置 |
|:------------|:-----------------------------|
| PostgreSQL | 由 Linux 安装包管理 |
| Geo 站点 | 单节点 |
| 次要站点 | 一个 |

本 runbook 将指导你完成对具有一个次要站点的单节点 Geo 站点进行计划性故障转移。假定的一般架构如下：

主要站点：

- 极狐GitLab 节点

次要站点：

- 极狐GitLab 节点

本指南将达成以下结果：

1. 一个离线的主要站点。
1. 一个已晋升的次要站点，现在成为新的主要站点。

未涵盖的内容：

1. 将旧的主要站点重新添加为次要站点。
1. 添加新的次要站点。

<a id="preparation"></a>

### 准备

> [!note]
> 在执行任何这些步骤之前，请确保你拥有对次要站点的 `root` 访问权限以晋升它，因为没有自动化的方式来晋升 Geo 副本并执行故障转移。

在次要站点上，进入 **管理员** > **Geo** 仪表盘以查看其状态。已复制的对象（以绿色显示）应接近 100%，并且不应有失败项（以红色显示）。如果很大比例的对象尚未复制（以灰色显示），请考虑给站点更多时间来完成。

![显示次要站点同步状态的 Geo 管理员仪表盘。](img/geo_dashboard_v14_0.png)

如果有任何对象复制失败，应在安排维护窗口之前进行调查。计划性故障转移后，任何复制失败的内容都会**丢失**。

复制失败的常见原因是数据在主要站点上丢失——你可以通过从备份恢复数据或删除对丢失数据的引用来解决这些失败。

在 Geo 复制和验证完全完成之前，维护窗口不会结束。为了尽可能缩短窗口时间，你应该确保这些流程在活跃使用期间尽可能接近 100%。

如果次要站点仍在从主要站点复制数据，请按照以下步骤操作以避免不必要的数据丢失：

1. 在 [只读模式](https://gitlab.com/gitlab-org/gitlab/-/issues/14609) 实现之前，必须手动阻止对主要站点的更新。在维护窗口期间，你的次要站点仍需要对主要站点的只读访问权限：

   1. 在预定时间，使用你的云服务商或站点防火墙，阻止所有进出主要站点的 HTTP、HTTPS 和 SSH 流量，**除了**你的 IP 和次要站点的 IP。

      例如，你可以在主要站点上运行以下命令：

      ```shell
      sudo iptables -A INPUT -p tcp -s <secondary_site_ip> --destination-port 22 -j ACCEPT
      sudo iptables -A INPUT -p tcp -s <your_ip> --destination-port 22 -j ACCEPT
      sudo iptables -A INPUT --destination-port 22 -j REJECT

      sudo iptables -A INPUT -p tcp -s <secondary_site_ip> --destination-port 80 -j ACCEPT
      sudo iptables -A INPUT -p tcp -s <your_ip> --destination-port 80 -j ACCEPT
      sudo iptables -A INPUT --tcp-dport 80 -j REJECT

      sudo iptables -A INPUT -p tcp -s <secondary_site_ip> --destination-port 443 -j ACCEPT
      sudo iptables -A INPUT -p tcp -s <your_ip> --destination-port 443 -j ACCEPT
      sudo iptables -A INPUT --tcp-dport 443 -j REJECT
      ```

      从此时起，用户将无法在主要站点上查看数据或进行更改。他们也无法登录次要站点。但是，现有的会话需要在剩余的维护期间正常工作，因此公开数据始终可以访问。

   1. 通过使用另一个 IP 在浏览器中访问主要站点，验证其 HTTP 流量已被阻止。服务器应拒绝连接。

   1. 通过尝试使用 SSH 远程 URL 拉取现有的 Git 仓库，验证主要站点对通过 SSH 的 Git 流量已被阻止。服务器应拒绝连接。

   1. 在主要站点上：
      1. 在右上角，选择 **管理员**。
      1. 在左侧边栏中，选择 **监控** > **后台作业**。
      1. 在 Sidekiq 仪表盘上，选择 **Cron**。
      1. 选择 `Disable All` 以禁用所有非 Geo 的周期性后台作业。
      1. 为 `geo_sidekiq_cron_config_worker` cron 作业选择 `Enable`。
         此作业会重新启用其他几个对计划性故障转移成功完成至关重要的 cron 作业。

1. 完成所有数据的复制和验证：

   > [!warning]
   > 并非所有数据都会自动复制。详细了解
   > [哪些数据被排除在外](../planned_failover.md#not-all-data-is-automatically-replicated)。

   1. 如果你正在手动复制任何 [非 Geo 管理的数据](../../replication/datatypes.md#replicated-data-types)，请立即触发最终复制过程。
   1. 在主要站点上：
      1. 在右上角，选择 **管理员**。
      1. 在左侧边栏中，选择 **监控** > **后台作业**。
      1. 在 Sidekiq 仪表盘上，选择 **Queues**，并等待所有不包含 `geo` 的队列降至 0。
         这些队列包含你的用户提交的工作；在完成之前进行故障转移会导致工作丢失。
      1. 在左侧边栏中，选择 **Geo** > **站点**，并等待你要切换到的次要站点满足以下所有条件：

         - 所有复制仪表达到 100% 已复制，0% 失败。
         - 所有验证仪表达到 100% 已验证，0% 失败。
         - 数据库复制延迟为 0 毫秒。
         - Geo 日志游标是最新的（落后 0 个事件）。

   1. 在次要站点上：
      1. 在右上角，选择 **管理员**。
      1. 在左侧边栏中，选择 **监控** > **后台作业**。
      1. 在 Sidekiq 仪表盘上，选择 **Queues**，并等待所有 `geo` 队列的排队和运行中作业降至 0。
      1. [运行完整性检查](../../../raketasks/check.md) 以验证文件存储中 CI 产物、LFS 对象和上传文件的完整性。

   此时，你的次要站点包含了主要站点所有内容的最新副本，这意味着故障转移时不会有任何损失。

1. 在这最后一步中，你需要永久禁用主要站点。

   > [!warning]
   > 当主要站点下线时，可能有一些保存在主要站点上的数据尚未复制到次要站点。如果你继续操作，这些数据应被视为已丢失。

   如果你计划 [更新主要域名 DNS 记录](../_index.md#optional-updating-the-primary-domain-dns-record)，你可能希望现在降低 TTL 以加快传播速度。

   执行故障转移时，我们希望避免在两个不同的极狐GitLab 实例中出现写入操作的脑裂情况。因此，为准备故障转移，你必须禁用主要站点：

   - 如果你可以通过 SSH 访问主要站点，停止并禁用极狐GitLab：

     ```shell
     sudo gitlab-ctl stop
     ```

     如果服务器意外重启，阻止极狐GitLab 再次启动：

     ```shell
     sudo systemctl disable gitlab-runsvdir
     ```

     > [!note]
     >
     > - 在 CentOS 6 或更早版本中，要防止极狐GitLab 在机器重启时启动比较困难（请参阅 [issue 3058](https://gitlab.com/gitlab-org/omnibus-gitlab/-/issues/3058)）。
     >   最安全的方法可能是使用 `sudo yum remove gitlab-ee` 完全卸载极狐GitLab 软件包。
     > - 如果你使用的是较旧版本的 Ubuntu（如 14.04 LTS）或任何其他基于 Upstart 初始化系统的发行版，你可以以 `root` 用户身份通过
     >   `initctl stop gitlab-runsvvdir && echo 'manual' > /etc/init/gitlab-runsvdir.override && initctl reload-configuration` 来防止 GitLab 在机器重启时启动。

   - 如果你没有主要站点的 SSH 访问权限，请将机器脱机并防止其重启。由于有很多方法可以实现这一点，我们不提供单一建议。你可能需要：

     - 重新配置负载均衡器。
     - 更改 DNS 记录（例如，将主要 DNS 记录指向次要站点以停止使用主要站点）。
     - 停止虚拟服务器。
     - 通过防火墙阻止流量。
     - 撤销主要站点对对象存储的权限。
     - 物理断开机器。

<a id="promoting-the-secondary-site"></a>

### 晋升次要站点

晋升次要站点时，请注意以下几点：

- 此时不应添加新的次要站点。如果你想添加新的次要站点，请在完成将次要站点晋升为主要站点的整个过程之后再进行。
- 如果在此过程中遇到 `ActiveRecord::RecordInvalid: Validation failed: Name has already been taken` 错误，请阅读
  [故障排除建议](../failover_troubleshooting.md#fixing-errors-during-a-failover-or-when-promoting-a-secondary-to-a-primary-site)。

要晋升次要站点：

1. 通过 SSH 登录到你的次要站点并运行以下命令之一：

   - 将次要站点晋升为主要站点：

     ```shell
     sudo gitlab-ctl geo promote
     ```

   - **在没有任何进一步确认的情况下**将次要站点晋升为主要站点：

     ```shell
     sudo gitlab-ctl geo promote --force
     ```

1. 验证你是否可以使用之前用于次要站点的 URL 连接到新晋升的主要站点。

   如果成功，次要站点现在已晋升为主要站点。

<a id="next-steps"></a>

### 后续步骤

要尽快恢复地理冗余，你应该 [添加一个新的次要站点](../../setup/_index.md)。为此，你可以将旧的主要站点重新添加为新的次要站点，并使其重新上线。