---
stage: Tenant Scale
group: Geo
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
title: 移除次要 Geo 站点
---

<a id="removing-secondary-geo-sites"></a>

# 移除次要 Geo 站点

{{< details >}}

- Tier: 专业版，旗舰版
- Offering: 私有化部署

{{< /details >}}

可以从 **主要** 站点的 Geo 管理页面将 **次要** 站点从 Geo 集群中移除。要移除 **次要** 站点：

1. 在右上角，选择 **管理员**。
1. 在左侧边栏，选择 **Geo** > **节点**。
1. 对于要移除的 **次要** 站点，选择 **移除**。
1. 当提示出现时，选择 **移除** 进行确认。

从 Geo 管理页面移除 **次要** 站点后，您必须停止并卸载该站点。对于次要 Geo 站点上的每个节点：

1. 停止极狐GitLab：

   ```shell
   sudo gitlab-ctl stop
   ```

1. 卸载极狐GitLab：

   > [!note]
   > 如果还需要从实例中清理极狐GitLab 数据，请参阅 [卸载 Linux 软件包及其所有数据](https://gitlab.cn/docs/omnibus/installation/#uninstall-the-linux-package-omnibus)。

   ```shell
   # 停止极狐GitLab 并移除其监督进程
   sudo gitlab-ctl uninstall

   # Debian/Ubuntu
   sudo dpkg --remove gitlab-ee

   # Redhat/Centos
   sudo rpm --erase gitlab-ee
   ```

当从 **次要** 站点上的每个节点卸载极狐GitLab 后，必须从 **主要** 站点的数据库中删除复制槽，操作如下：

1. 在 **主要** 站点的数据库节点上，启动 PostgreSQL 控制台会话：

   ```shell
   sudo gitlab-psql
   ```

   > [!note]
   > 使用 `gitlab-rails dbconsole` 无效，因为管理复制槽需要超级用户权限。

1. 找到相关复制槽的名称。这是运行复制命令 `gitlab-ctl replicate-geo-database` 时通过 `--slot-name` 指定的槽。

   ```sql
   SELECT * FROM pg_replication_slots;
   ```

1. 移除 **次要** 站点的复制槽：

   ```sql
   SELECT pg_drop_replication_slot('<name_of_slot>');
   ```

