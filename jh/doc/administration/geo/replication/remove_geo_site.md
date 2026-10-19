---
stage: GitLab Dedicated
group: Geo
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
title: 移除 Geo 从站点
---

{{< details >}}

- Tier: 专业版，旗舰版
- Offering: 私有化部署

{{< /details >}}

可以使用主站点的 Geo 管理页面从 Geo 集群中移除从站点。要移除从站点：

1. 在右上角，选择**管理员**。
1. 在左侧边栏中，选择 **Geo** > **节点**。
1. 对于要移除的从站点，选择**移除**。
1. 出现提示时，选择**移除**以确认。

从 Geo 管理页面移除从站点后，您必须停止并卸载该站点。对于 Geo 从站点上的每个节点：

1. 停止极狐GitLab：

   ```shell
   sudo gitlab-ctl stop
   ```

1. 卸载极狐GitLab：

   > [!note]
   > 如果还需要从实例中清理极狐GitLab 数据，请参阅如何[卸载 Linux 软件包及其所有数据](https://gitlab.cn/docs/omnibus/installation/#uninstall-the-linux-package-omnibus)。

   ```shell
   # Stop gitlab and remove its supervision process
   sudo gitlab-ctl uninstall

   # Debian/Ubuntu
   sudo dpkg --remove gitlab-ee

   # Redhat/Centos
   sudo rpm --erase gitlab-ee
   ```

在从站点的每个节点上卸载极狐GitLab 后，必须按如下方式从主站点的数据库中删除复制槽：

1. 在主站点的数据库节点上，启动 PostgreSQL 控制台会话：

   ```shell
   sudo gitlab-psql
   ```

   > [!note]
   > 使用 `gitlab-rails dbconsole` 不起作用，因为管理复制槽需要超级用户权限。

1. 查找相关复制槽的名称。该槽是在运行复制命令 `gitlab-ctl replicate-geo-database` 时通过 `--slot-name` 指定的槽。

   ```sql
   SELECT * FROM pg_replication_slots;
   ```

1. 移除从站点的复制槽：

   ```sql
   SELECT pg_drop_replication_slot('<name_of_slot>');
   ```
