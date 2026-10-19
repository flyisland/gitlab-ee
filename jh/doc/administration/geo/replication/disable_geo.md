---
stage: GitLab Dedicated
group: Geo
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
title: 禁用 Geo
---

{{< details >}}

- Tier: 专业版，旗舰版
- Offering: 私有化部署

{{< /details >}}

如果您想在测试后恢复为常规 Linux 软件包安装设置，或者您遇到了灾难恢复情况并希望暂时禁用 Geo，可以使用以下说明来禁用您的
Geo 设置。

如果您正确移除 Geo 从站点，禁用 Geo 与拥有一个没有 Geo 从站点的活动 Geo 设置之间不应有任何功能差异。

要禁用 Geo，请按照以下步骤操作：

1. [移除所有 Geo 从站点](#remove-all-secondary-geo-sites)。
1. [从 UI 中移除主站点](#remove-the-primary-site-from-the-ui)。
1. [移除从站点复制槽](#remove-secondary-replication-slots)。
1. [移除 Geo 相关配置](#remove-geo-related-configuration)。
1. [可选。还原 PostgreSQL 设置以使用密码并监听 IP](#optional-revert-postgresql-settings-to-use-a-password-and-listen-on-an-ip)。

<a id="remove-all-secondary-geo-sites"></a>

## 移除所有 Geo 从站点

要禁用 Geo，您需要先移除所有 Geo 从站点，这意味着这些站点上不再进行复制。您可以按照我们的文档[移除您的 Geo 从站点](remove_geo_site.md)。

如果您想继续使用的当前站点是从站点，您需要先将其提升为主站点。您可以使用我们关于[如何提升从站点](../disaster_recovery/_index.md#step-2-promoting-a-secondary-site)的步骤来完成此操作。

<a id="remove-the-primary-site-from-the-ui"></a>

## 从 UI 中移除主站点

要移除主站点：

1. [移除所有 Geo 从站点](remove_geo_site.md)
1. 在右上角，选择**管理员**。
1. 在左侧边栏中，选择 **Geo** > **节点**。
1. 为主节点选择**移除**。
1. 出现提示时，选择**移除**以确认。

<a id="remove-secondary-replication-slots"></a>

## 移除从站点复制槽

要移除从站点复制槽，请在主 Geo 节点的 PostgreSQL 控制台（`sudo gitlab-psql`）中运行以下查询之一：

- 如果您已有 PostgreSQL 集群，请按名称删除各个复制槽，以防止
  从同一集群中移除您的从站点数据库。您可以使用以下命令获取
  所有名称，然后删除各个槽：

  ```sql
  SELECT slot_name, slot_type, active FROM pg_replication_slots; -- view present replication slots
  SELECT pg_drop_replication_slot('slot_name'); -- where slot_name is the one expected from the previous command
  ```

- 要移除所有从站点复制槽：

  ```sql
  SELECT pg_drop_replication_slot(slot_name) FROM pg_replication_slots;
  ```

<a id="remove-geo-related-configuration"></a>

## 移除 Geo 相关配置

1. 对于 Geo 主站点上的每个节点，通过 SSH 登录该节点并以 root 身份登录：

   ```shell
   sudo -i
   ```

1. 编辑 `/etc/gitlab/gitlab.rb`，通过移除任何启用 `geo_primary_role`的行
   来移除 Geo 相关配置：

   ```ruby
   ## In pre-11.5 documentation, the role was enabled as follows. Remove this line.
   geo_primary_role['enable'] = true

   ## In 11.5+ documentation, the role was enabled as follows. Remove this line.
   roles ['geo_primary_role']
   ```

1. 进行这些更改后，[重新配置极狐GitLab](../../restart_gitlab.md#reconfigure-a-linux-package-installation)
   以使更改生效。

<a id="optional-revert-postgresql-settings-to-use-a-password-and-listen-on-an-ip"></a>

## （可选）还原 PostgreSQL 设置以使用密码并监听 IP

如果您想移除 PostgreSQL 特定的设置并还原为默认值（改用套接字），可以安全地从 `/etc/gitlab/gitlab.rb` 文件中移除以下行：

```ruby
postgresql['sql_user_password'] = '...'
gitlab_rails['db_password'] = '...'
postgresql['listen_address'] = '...'
postgresql['md5_auth_cidr_addresses'] =  ['...', '...']
```
