---
stage: GitLab Dedicated
group: Geo
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
title: 升级 Geo 站点
---

{{< details >}}

- Tier: 专业版，旗舰版
- Offering: 私有化部署

{{< /details >}}

> [!warning]
> 在更新 Geo 站点之前，请仔细阅读以下章节。不遵循
> 特定版本的升级步骤可能会导致意外停机。如果您有
> 任何具体问题，请[联系支持团队](https://gitlab.cn/support)。
> 数据库主版本升级需要[重新初始化 PostgreSQL 复制](https://gitlab.cn/docs/omnibus/settings/database/#upgrading-a-geo-instance)
> 到 Geo 从站点。这适用于 Linux 软件包和外部管理的数据库。
> 这可能会导致比预期更长的停机时间。

升级 Geo 站点涉及执行：

1. 特定版本的升级步骤，具体取决于升级的目标版本或来源版本：
   - [极狐GitLab 19 升级说明](../../../update/versions/gitlab_19_changes.md)
   - [极狐GitLab 18 升级说明](../../../update/versions/gitlab_18_changes.md)
   - [极狐GitLab 17 升级说明](../../../update/versions/gitlab_17_changes.md)
   - [极狐GitLab 16 升级说明](../../../update/versions/gitlab_16_changes.md)
   - [极狐GitLab 15 升级说明](../../../update/versions/gitlab_15_changes.md)
1. [通用升级步骤](#general-upgrade-steps)，适用于所有升级。

<a id="general-upgrade-steps"></a>

## 通用升级步骤

> [!note]
> 这些通用升级步骤在多节点设置中需要停机。
> 如果您想避免停机，请考虑使用
> [零停机升级](../../../update/zero_downtime.md#upgrade-multi-node-geo-instances)。

当新版本极狐GitLab 发布时，要升级 Geo 站点，请升级主站点和所有从站点：

1. 可选。[在每个从站点上暂停复制](pause_resume_replication.md)
   以保护从站点的灾难恢复（DR）能力。
   当您的优先事项是在高风险升级窗口期间保留干净的 DR 检查点时，请暂停复制。
   如果您的优先事项是让从站点保持最新并在升级期间正常提供读取流量，尤其是在零停机方案中，请不要暂停复制。
1. SSH 登录到主站点的每个节点。
1. [在主站点上升级极狐GitLab](../../../update/package/_index.md)。
1. 在主站点上执行测试，特别是如果您在步骤 1 中暂停了复制以保护 DR。
   有关升级后测试的更多信息，请参阅
   [运行升级健康检查](../../../update/plan_your_upgrade.md#run-upgrade-health-checks)。
1. 确保主站点和从站点的 `/etc/gitlab/gitlab-secrets.json` 文件中的密钥相同。该文件在站点的所有节点上必须相同。
1. SSH 登录到从站点的每个节点。
1. [在每个从站点上升级极狐GitLab](../../../update/package/_index.md)。
1. 如果您在步骤 1 中暂停了复制，请[在每个从站点上恢复复制](../_index.md#pausing-and-resuming-replication)。
   然后，在每个从站点上重启 Puma 和 Sidekiq。这是为了确保它们
   针对较新的数据库架构进行初始化，该架构现在从
   先前升级的主站点复制而来。

   ```shell
   sudo gitlab-ctl restart sidekiq
   sudo gitlab-ctl restart puma
   ```

1. [测试](#check-status-after-upgrading)主站点和从站点，并检查每个站点的版本。

<a id="check-status-after-upgrading"></a>

### 升级后检查状态

现在升级过程已完成，您可能想检查一切是否正常工作：

1. 在主站点和从站点的应用节点上运行 Geo Rake 任务。一切都应为绿色：

   ```shell
   sudo gitlab-rake gitlab:geo:check
   ```

1. 检查主站点的 Geo 仪表板是否有任何错误。
1. 通过将代码推送到主站点来测试数据复制，并查看
   从站点是否收到该代码。

如果您遇到任何问题，请参阅 [Geo 故障排除指南](troubleshooting/_index.md)。
