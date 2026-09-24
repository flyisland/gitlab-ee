---
stage: Tenant Scale
group: Geo
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
title: 升级 Geo 站点
---

{{< details >}}

- Tier: 专业版，旗舰版
- Offering: 私有化部署

{{< /details >}}

> [!warning]
> 在更新 Geo 站点之前，请仔细阅读这些部分。不遵循
> 特定版本的升级步骤可能会导致意外停机。如果您有
> 任何具体问题，请[联系支持](https://gitlab.cn/support/#contact-support)。
> 数据库主版本升级需要[重新初始化 PostgreSQL 复制](https://gitlab.cn/docs/omnibus/settings/database/#upgrading-a-geo-instance)
> 到 Geo 次要站点。这适用于 Linux 软件包和外部管理的数据库。
> 这可能导致比预期更长的停机时间。

升级 Geo 站点涉及以下步骤：

1. 版本特定的升级步骤，取决于升级的来源或目标版本：
   - [极狐GitLab 18 升级说明](../../../update/versions/gitlab_18_changes.md)
   - [极狐GitLab 17 升级说明](../../../update/versions/gitlab_17_changes.md)
   - [极狐GitLab 16 升级说明](../../../update/versions/gitlab_16_changes.md)
   - [极狐GitLab 15 升级说明](../../../update/versions/gitlab_15_changes.md)
1. [常规升级步骤](#general-upgrade-steps)，适用于所有升级。

<a id="general-upgrade-steps"></a>

## 常规升级步骤

> [!note]
> 这些常规升级步骤在多节点部署中需要停机。
> 如果您想避免停机，请考虑使用
> [零停机升级](../../../update/zero_downtime.md#upgrade-multi-node-geo-instances)。

当新版本的极狐GitLab发布时，升级 Geo 站点需要升级**主**站点以及所有**次要**站点：

1. 可选。[在每个**次要**站点暂停复制](pause_resume_replication.md)，以保护**次要**站点的灾难恢复（DR）能力。
   当您的优先事项是在高风险升级窗口期间保留干净的 DR 检查点时，请暂停复制。
   如果您的优先事项是保持次要站点处于最新状态并在升级期间正常提供读取流量，尤其是在采用零停机方法时，请不要暂停复制。
1. SSH 登录到**主**站点的每个节点。
1. [在**主**站点上升级极狐GitLab](../../../update/package/_index.md)。
1. 在**主**站点上执行测试，尤其是在步骤 1 中暂停复制以保护 DR 的情况下。
   有关升级后测试的更多信息，请参阅
   [运行升级健康检查](../../../update/plan_your_upgrade.md#run-upgrade-health-checks)。
1. 确保主站点和次要站点的 `/etc/gitlab/gitlab-secrets.json` 文件中的密钥相同。该文件在站点的所有节点上都必须相同。
1. SSH 登录到**次要**站点的每个节点。
1. [在每个**次要**站点上升级极狐GitLab](../../../update/package/_index.md)。
1. 如果您在步骤 1 中暂停了复制，请[在每个**次要**站点上恢复复制](../_index.md#pausing-and-resuming-replication)。
   然后，在每个**次要**站点上重启 Puma 和 Sidekiq。这是为了确保它们
   针对现在已经从先前升级的**主**站点复制过来的较新数据库模式进行初始化。

   ```shell
   sudo gitlab-ctl restart sidekiq
   sudo gitlab-ctl restart puma
   ```

1. [测试](#check-status-after-upgrading)**主**站点和**次要**站点，并检查每个站点的版本。

<a id="check-status-after-upgrading"></a>

### 升级后检查状态

升级过程完成后，您可能需要检查是否一切正常：

1. 在主站点和次要站点的应用节点上运行 Geo Rake 任务。一切应该显示为绿色：

   ```shell
   sudo gitlab-rake gitlab:geo:check
   ```

1. 检查**主**站点的 Geo 仪表板是否有任何错误。
1. 通过向**主**站点推送代码来测试数据复制，并查看**次要**站点是否接收到。

如果您遇到任何问题，请参阅 [Geo 故障排除指南](troubleshooting/_index.md)。