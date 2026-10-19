---
stage: GitLab Dedicated
group: Geo
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
ignore_in_report: true
title: 灾难恢复（Geo）提升 runbook
---

{{< details >}}

- Tier: 专业版，旗舰版
- Offering: 私有化部署
- Status: 实验

{{< /details >}}

灾难恢复（Geo）提升 runbook。

> [!warning]
> 本 runbook 属于[实验](../../../../policy/development_stages_support.md#experiment)。如需完整且可用于生产环境的文档，请参阅
> [灾难恢复文档](../_index.md)。

<a id="geo-planned-failover-for-a-single-node-configuration"></a>

## 单节点配置的 Geo 计划内故障转移

| 组件        | 配置                |
|:------------|:-----------------------------|
| PostgreSQL  | 由 Linux 软件包管理 |
| Geo 站点    | 单节点                  |
| 从站点 | 一个                          |

本 runbook 将指导您完成单节点 Geo 站点（带一个从站点）的计划内故障转移。假定采用以下总体架构：

主站点：

- 极狐GitLab 节点

从站点：

- 极狐GitLab 节点

本指南将实现以下结果：

1. 主站点离线。
1. 从站点已提升，成为新的主站点。

未涵盖的内容：

1. 将旧主站点重新添加为从站点。
1. 添加新的从站点。

<a id="preparation"></a>

### 准备工作

> [!note]
> 在执行上述任何步骤之前，请确保您拥有从站点的 `root` 访问权限以便提升它，因为目前没有自动化的方式来
> 提升 Geo 副本并执行故障转移。

在从站点上，前往**管理区域** > **Geo** 仪表板查看其状态。已复制的对象（以绿色显示）应接近 100%，且不应存在失败（以红色显示）。如果很大一部分对象尚未复制（以灰色显示），请考虑给该站点更多时间来完成。

![显示从站点同步状态的 Geo 管理仪表板。](img/geo_dashboard_v14_0.png)

如果有任何对象复制失败，应在安排维护窗口之前进行调查。计划内故障转移之后，任何未能复制的数据都会丢失。

复制失败的常见原因是主站点上缺少数据——您可以通过从备份恢复数据，或移除对缺失数据的引用来解决这些失败。

在 Geo 复制和验证完全完成之前，维护窗口不会结束。为尽可能缩短该窗口，您应确保这些进程在活跃使用期间尽可能接近 100%。

如果从站点仍在从主站点复制数据，请按照以下步骤操作，以避免不必要的数据丢失：

1. 在[只读模式](https://gitlab.com/gitlab-org/gitlab/-/issues/14609)
   实现之前，必须手动阻止对主站点的更新。
   在维护窗口期间，您的从站点仍需要对主站点的只读
   访问权限：

   1. 在计划的时间，使用您的云服务商或站点防火墙，阻止
      所有进出主站点的 HTTP、HTTPS 和 SSH 流量，但您的 IP 和
      从站点的 IP 除外。

      例如，您可以在主站点上运行以下命令：

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

      从此刻起，用户将无法查看其数据或在
      主站点上进行更改。他们也无法登录从站点。
      但是，现有会话需要在维护期的剩余时间内继续工作，
      因此公共数据在整个过程中均可访问。

   1. 通过使用另一个 IP 在浏览器中访问主站点，验证其 HTTP 流量已被阻止。服务器应拒绝连接。

   1. 通过尝试使用 SSH 远程 URL 拉取现有 Git 代码仓库，验证主站点的 Git over SSH 流量已被阻止。服务器应拒绝
      连接。

   1. 在主站点上：
      1. 在右上角，选择**管理员**。
      1. 在左侧边栏中，选择**监控** > **后台作业**。
      1. 在 Sidekiq 仪表板上，选择 **Cron**。
      1. 选择 `Disable All` 以禁用所有非 Geo 的周期性后台作业。
      1. 为 `geo_sidekiq_cron_config_worker` cron 作业选择 `Enable`。
         该作业会重新启用其他几个对计划内
         故障转移成功完成至关重要的 cron 作业。

1. 完成所有数据的复制和验证：

   > [!warning]
   > 并非所有数据都会自动复制。详细了解
   > [哪些内容被排除在外](../planned_failover.md#not-all-data-is-automatically-replicated)。

   1. 如果您正在手动复制任何
      [不受 Geo 管理的数据](../../replication/datatypes.md#data-types-not-replicated)，
      请立即触发最终复制过程。
   1. 在主站点上：
      1. 在右上角，选择**管理员**。
      1. 在左侧边栏中，选择**监控** > **后台作业**。
      1. 在 Sidekiq 仪表板上，选择 **Queues**，并等待除名称中包含 `geo`的队列外，
         所有队列降至 0。
         这些队列包含您的用户提交的工作；在完成之前进行故障转移，
         会导致这些工作丢失。
      1. 在左侧边栏中，选择 **Geo** > **站点**，并等待
         您要故障转移到的从站点满足以下条件：

         - 所有复制指标达到 100% 已复制，0% 失败。
         - 所有验证指标达到 100% 已验证，0% 失败。
         - 数据库复制延迟为 0 ms。
         - Geo 日志游标为最新（落后 0 个事件）。

   1. 在从站点上：
      1. 在右上角，选择**管理员**。
      1. 在左侧边栏中，选择**监控** > **后台作业**。
      1. 在 Sidekiq 仪表板上，选择 **Queues**，并等待所有 `geo`
         队列降至 0 个排队和 0 个运行中的作业。
      1. [运行完整性检查](../../../raketasks/check.md)，以验证文件存储中
         CI 产物、LFS 对象和上传内容的完整性。

   此时，您的从站点包含主站点所有内容的最新副本，
   这意味着故障转移时不会丢失任何内容。

1. 在最后一步中，您需要永久禁用主站点。

   > [!warning]
   > 当主站点离线时，主站点上可能保存有尚未复制到从站点的数据。
   > 如果您继续操作，这些数据应视为已丢失。

   如果您计划[更新主域名 DNS 记录](../_index.md#optional-updating-the-primary-domain-dns-record)，
   您可能希望现在降低 TTL 以加快传播。

   执行故障转移时，我们希望避免出现脑裂情况，即
   写入可能发生在两个不同的极狐GitLab 实例中。因此，为准备
   故障转移，您必须禁用主站点：

   - 如果您对主站点有 SSH 访问权限，请停止并禁用极狐GitLab：

     ```shell
     sudo gitlab-ctl stop
     ```

     防止极狐GitLab 在服务器意外重启时再次启动：

     ```shell
     sudo systemctl disable gitlab-runsvdir
     ```

     > [!note]
     >
     > - 在 CentOS 6 或更早版本中，如果机器重启，很难阻止极狐GitLab
     >   启动（参见[议题 3058](https://gitlab.com/gitlab-org/omnibus-gitlab/-/issues/3058)）。
     >   最安全的做法可能是使用 `sudo yum remove gitlab-ee` 完全卸载极狐GitLab 软件包。
     > - 如果您使用的是较旧版本的 Ubuntu（如 14.04 LTS）
     >   或任何其他基于 Upstart init 系统的发行版，您可以以 `root` 身份
     >   使用 `initctl stop gitlab-runsvdir && echo 'manual' > /etc/init/gitlab-runsvdir.override && initctl reload-configuration`
     >   来防止极狐GitLab 在机器重启时启动。

   - 如果您对主站点没有 SSH 访问权限，请将机器离线并
     防止其重启。由于您可能偏好多种方式来实现这一点，
     我们避免给出单一建议。您可能需要：

     - 重新配置负载均衡器。
     - 更改 DNS 记录（例如，将主 DNS 记录指向
       从站点，以停止使用主站点）。
     - 停止虚拟服务器。
     - 通过防火墙阻止流量。
     - 撤销主站点的对象存储权限。
     - 物理断开机器。

<a id="promoting-the-secondary-site"></a>

### 提升从站点

提升从站点时，请注意以下事项：

- 此时不应添加新的从站点。如果您想添加新的
  从站点，请在完成将从站点提升为主站点的整个流程之后
  再进行。
- 如果您在此过程中遇到 `ActiveRecord::RecordInvalid: Validation failed: Name has already been taken`
  错误，请阅读
  [故障排除建议](../failover_troubleshooting.md#fixing-errors-during-a-failover-or-when-promoting-a-secondary-to-a-primary-site)。

要提升从站点：

1. 通过 SSH 连接到您的从站点，并运行以下命令之一：

   - 要将从站点提升为主站点：

     ```shell
     sudo gitlab-ctl geo promote
     ```

   - 要在没有任何进一步确认的情况下将从站点提升为主站点：

     ```shell
     sudo gitlab-ctl geo promote --force
     ```

1. 验证您可以使用之前用于从站点的 URL 连接到新提升的主站点。

   如果成功，从站点现已提升为主站点。

<a id="next-steps"></a>

### 后续步骤

要尽快恢复地理冗余，您应[添加新的从站点](../../setup/_index.md)。为此，您可以将旧主站点重新添加为新的从站点，并使其重新上线。
