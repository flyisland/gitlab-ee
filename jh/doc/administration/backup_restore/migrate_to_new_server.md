---
stage: Tenant Scale
group: Geo
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
title: 迁移到新服务器
---

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: 私有化部署

{{< /details >}}

<!-- some details borrowed from GitLab.com move from Azure to GCP detailed at <https://gitlab.com/gitlab-com/migration/-/blob/master/.gitlab/issue_templates/failover.md> -->

你可以使用极狐GitLab 备份和恢复功能将实例迁移到新服务器。本节概述了在使用 Linux 安装包的单台服务器上运行的极狐GitLab 部署的典型流程。

如果你正在运行极狐GitLab Geo，另一种选择是[用于计划故障转移的 Geo 灾难恢复](../geo/disaster_recovery/planned_failover.md)。在选择使用 Geo 进行迁移之前，你必须确保所有站点都满足 [Geo 要求](../geo/_index.md#requirements-for-running-geo)。

> [!warning]
> 避免新旧服务器同时进行不协调的数据处理，在这种情况下，多台
> 服务器可能同时连接并处理相同的数据。例如，当使用
> [接收邮件](../incoming_email.md)时，如果两个极狐GitLab 实例同时
> 处理电子邮件，那么两个实例都会丢失部分数据。
> 此类问题也可能发生在其他服务上，例如
> [非安装包数据库](https://gitlab.cn/docs/omnibus/settings/database/#using-a-non-packaged-postgresql-database-management-server)、
> 非安装包 Redis 实例或非安装包 Sidekiq。

前提条件：

- 提前发布[广播消息横幅](../broadcast_messages.md)以通知用户即将进行的迁移。
- 完整且最新的备份。创建完整的系统级备份，或
  对所有参与迁移的服务器进行快照，以防错误地运行
  破坏性命令（如 `rm`）。
- 管理员权限。

<a id="prepare-the-new-server"></a>

## 准备新服务器

要准备新服务器：

1. 从旧服务器复制
   [SSH 主机密钥](https://superuser.com/questions/532040/copy-ssh-keys-from-one-server-to-another-server/532079#532079)
   以避免中间人攻击警告。
   请参阅[手动复制主站点的 SSH 主机密钥](../geo/replication/configuration.md#step-2-manually-replicate-the-primary-sites-ssh-host-keys)了解示例步骤。
1. [安装极狐GitLab](../../install/package/_index.md)。
1. 通过将 `/etc/gitlab` 文件从旧服务器复制到新服务器来进行配置，并根据需要进行更新。
   请阅读
   [Linux 安装包备份和恢复说明](https://gitlab.cn/docs/omnibus/settings/backups/)以获取更多详细信息。
1. 如果适用，禁用[接收邮件](../incoming_email.md)。
1. 在备份和恢复后首次启动时，阻止新的 CI/CD 作业启动。
   编辑 `/etc/gitlab/gitlab.rb` 并设置以下内容：

   ```ruby
   nginx['custom_gitlab_server_config'] = "location = /api/v4/jobs/request {\n    deny all;\n    return 503;\n  }\n"
   ```

1. 重新配置极狐GitLab：

   ```shell
   sudo gitlab-ctl reconfigure
   ```

1. 停止极狐GitLab 以避免任何不必要和意外的数据处理：

   ```shell
   sudo gitlab-ctl stop
   ```

1. 停止 Redis：

   ```shell
   sudo gitlab-ctl stop redis
   ```

1. 配置新服务器以允许接收 Redis 数据库和极狐GitLab 备份文件：

   ```shell
   sudo rm -f /var/opt/gitlab/redis/dump.rdb
   sudo chown <your-linux-username> /var/opt/gitlab/redis /var/opt/gitlab/backups
   ```

<a id="prepare-and-transfer-content-from-the-old-server"></a>

## 准备和传输旧服务器上的内容

1. 确保你拥有旧服务器的最新系统级备份或快照。
1. 如果你的极狐GitLab 版本支持，启用[维护模式](../maintenance_mode/_index.md)。
1. 阻止新的 CI/CD 作业启动：
   1. 编辑 `/etc/gitlab/gitlab.rb`，并设置以下内容：

      ```ruby
      nginx['custom_gitlab_server_config'] = "location = /api/v4/jobs/request {\n    deny all;\n    return 503;\n  }\n"
      ```

   1. 重新配置极狐GitLab：

      ```shell
      sudo gitlab-ctl reconfigure
      ```

1. 禁用周期性后台作业：
   1. 在右上角，选择 **管理员**。
   1. 在左侧边栏中，选择 **监控** > **后台作业** 以显示 Sidekiq 仪表板。
   1. 在 Sidekiq 仪表板上，在其顶部菜单中，选择 **Cron**。
   1. 在 Sidekiq 仪表板上，在其右上方，选择 **全部禁用**。
1. 等待正在运行的 CI/CD 作业完成，或者接受未完成的作业可能会丢失。
   要查看所有正在运行的作业：
   1. 在左侧边栏中，选择 **CI/CD** > **作业**。
   1. 在过滤栏中，选择 **状态** > **运行中**。
1. 等待 Sidekiq 作业完成：
   1. 在左侧边栏中，选择 **监控** > **后台作业**。
   1. 在 Sidekiq 仪表板上，在其顶部菜单中，选择 **队列**。
   1. 在 Sidekiq 仪表板上，在其右上方，选择 **实时轮询**。
      等待 **Busy** 和 **Enqueued** 降至 0。
      这些队列包含用户提交的工作；
      在这些作业完成之前关闭可能会导致工作丢失。
      记下 Sidekiq 仪表板中显示的数字，以便迁移后验证。
1. 将 Redis 数据库刷新到磁盘，并停止极狐GitLab，但迁移所需的服务除外：

   ```shell
   sudo /opt/gitlab/embedded/bin/redis-cli -s /var/opt/gitlab/redis/redis.socket save && \
   sudo gitlab-ctl stop && \
   sudo gitlab-ctl start postgresql && \
   sudo gitlab-ctl start gitaly
   ```

1. 创建极狐GitLab 备份：

   ```shell
   sudo gitlab-backup create
   ```

1. 备份完成后，禁用以下极狐GitLab 服务，并通过将以下内容添加到 `/etc/gitlab/gitlab.rb` 的底部来防止意外重启：

   ```ruby
   alertmanager['enable'] = false
   gitaly['enable'] = false
   gitlab_exporter['enable'] = false
   gitlab_pages['enable'] = false
   gitlab_workhorse['enable'] = false
   grafana['enable'] = false
   logrotate['enable'] = false
   gitlab_rails['incoming_email_enabled'] = false
   nginx['enable'] = false
   node_exporter['enable'] = false
   postgres_exporter['enable'] = false
   postgresql['enable'] = false
   prometheus['enable'] = false
   puma['enable'] = false
   redis['enable'] = false
   redis_exporter['enable'] = false
   registry['enable'] = false
   sidekiq['enable'] = false
   ```

1. 重新配置极狐GitLab：

   ```shell
   sudo gitlab-ctl reconfigure
   ```

1. 验证所有内容已停止，并确认没有服务正在运行：

   ```shell
   sudo gitlab-ctl status
   ```

1. 将 Redis 数据库和极狐GitLab 备份传输到新服务器：

   ```shell
   sudo scp /var/opt/gitlab/redis/dump.rdb <your-linux-username>@new-server:/var/opt/gitlab/redis
   sudo scp /var/opt/gitlab/backups/your-backup.tar <your-linux-username>@new-server:/var/opt/gitlab/backups
   ```

<a id="for-instances-with-a-large-volume-of-git-and-object-data"></a>

### 对于有大量 Git 和对象数据的实例

如果你的极狐GitLab 实例在本地卷上有大量数据，例如超过 1 TB，
备份可能需要很长时间。在这种情况下，你可能会发现将数据传输到新实例上的相应卷更容易。

你可能需要手动迁移的主要卷有：

- `/var/opt/gitlab/git-data` 目录，包含所有 Git 数据。请务必阅读
  [移动仓库文档部分](../operations/moving_repositories.md#migrate-to-another-gitlab-instance)
  以消除 Git 数据损坏的可能性。
- `/var/opt/gitlab/gitlab-rails/shared` 目录，包含对象数据，如产物。
- `/var/opt/gitlab/gitlab-rails/uploads` 目录，包含上传数据，如用户头像。
- 如果你正在使用 Linux 安装包自带的 PostgreSQL，
  你还需要迁移 `/var/opt/gitlab/postgresql/data` 下的
  [PostgreSQL 数据目录](https://gitlab.cn/docs/omnibus/settings/database/#store-postgresql-data-in-a-different-directory)。

在所有极狐GitLab 服务停止后，你可以使用诸如 `rsync` 或挂载卷快照之类的工具将数据
移动到新环境。

<a id="restore-data-on-the-new-server"></a>

## 在新服务器上恢复数据

1. 恢复适当的文件系统权限：

   ```shell
   sudo chown gitlab-redis /var/opt/gitlab/redis
   sudo chown gitlab-redis:gitlab-redis /var/opt/gitlab/redis/dump.rdb
   sudo chown git:root /var/opt/gitlab/backups
   sudo chown git:git /var/opt/gitlab/backups/your-backup.tar
   ```

1. 启动 Redis：

   ```shell
   sudo gitlab-ctl start redis
   ```

   Redis 会自动拾取并恢复 `dump.rdb`。

1. [恢复极狐GitLab 备份](restore_gitlab.md)。
1. 验证 Redis 数据库是否正确恢复：
   1. 在右上角，选择 **管理员**。
   1. 在左侧边栏中，选择 **监控** > **后台作业**。
   1. 在 Sidekiq 仪表板下，验证数字
      是否与旧服务器上显示的匹配。
   1. 仍在 Sidekiq 仪表板下，选择 **Cron**，然后选择 **全部启用**
      以重新启用周期性后台作业。
1. 测试极狐GitLab 实例上的只读操作是否按预期工作。例如，浏览项目仓库文件、合并请求和议题。
1. 如果之前启用，则禁用[维护模式](../maintenance_mode/_index.md)。
1. 测试极狐GitLab 实例是否按预期工作。
1. 如果适用，重新启用[接收邮件](../incoming_email.md)并测试其是否按预期工作。
1. 更新你的 DNS 或负载均衡器以指向新服务器。
1. 通过删除你之前添加的自定义 NGINX 配置来允许新的 CI/CD 作业
   启动：

   ```ruby
   # The following line must be removed
   nginx['custom_gitlab_server_config'] = "location = /api/v4/jobs/request {\n    deny all;\n    return 503;\n  }\n"
   ```

1. 重新配置极狐GitLab：

   ```shell
   sudo gitlab-ctl reconfigure
   ```

1. 删除预定的维护[广播消息横幅](../broadcast_messages.md)。