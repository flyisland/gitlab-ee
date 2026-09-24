---
stage: Tenant Scale
group: Geo
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
title: 禁用 Geo
---

{{< details >}}

- Tier: 专业版，旗舰版
- Offering: 私有化部署

{{< /details >}}

如果在测试后想要恢复为标准 Linux 软件包安装设置，或者遇到灾难恢复情况需要临时禁用 Geo，你可以按照这些说明来禁用 Geo 设置。

如果正确移除，禁用 Geo 与拥有没有次要 Geo 站点的活动 Geo 设置之间应该没有功能上的区别。

要禁用 Geo，请按照以下步骤操作：

1. [移除所有次要 Geo 站点](#remove-all-secondary-geo-sites)
1. [从 UI 中移除主站点](#remove-the-primary-site-from-the-ui)
1. [移除次要复制槽](#remove-secondary-replication-slots)
1. [移除 Geo 相关配置](#remove-geo-related-configuration)
1. [可选。恢复 PostgreSQL 设置以使用密码并在 IP 上监听](#optional-revert-postgresql-settings-to-use-a-password-and-listen-on-an-ip)

<a id="remove-all-secondary-geo-sites"></a>

## 移除所有次要 Geo 站点

要禁用 Geo，你需要首先移除所有次要 Geo 站点，这意味着这些站点上将不再进行复制。你可以按照文档[移除次要 Geo 站点](remove_geo_site.md)来执行。

如果希望继续使用的当前站点是次要站点，则需要先将其提升为主站点。你可以使用我们关于[如何提升次要站点](../disaster_recovery/_index.md#step-2-promoting-a-secondary-site)的步骤来实现。

<a id="remove-the-primary-site-from-the-ui"></a>

## 从 UI 中移除主站点

要移除**主**站点：

1. [移除所有次要 Geo 站点](remove_geo_site.md)
1. 在右上角，选择**管理员**。
1. 在左侧边栏，选择 **Geo** > **节点**。
1. 针对**主**节点，选择**移除**。
1. 当提示出现时，选择**移除**以确认。

<a id="remove-secondary-replication-slots"></a>

## 移除次要复制槽

要移除次要复制槽，请在主 Geo 节点上的 PostgreSQL 控制台（`sudo gitlab-psql`）中运行以下任一查询：

- 如果已有 PostgreSQL 集群，通过名称删除单个复制槽，以避免从同一集群中移除你的次要数据库。你可以使用以下命令获取所有名称，然后删除每个单独槽：

  ```sql
  SELECT slot_name, slot_type, active FROM pg_replication_slots; -- 查看当前复制槽
  SELECT pg_drop_replication_slot('slot_name'); -- 其中 slot_name 是前一条命令中预期的名称
  ```

- 移除所有次要复制槽：

  ```sql
  SELECT pg_drop_replication_slot(slot_name) FROM pg_replication_slots;
  ```

<a id="remove-geo-related-configuration"></a>

## 移除 Geo 相关配置

1. 对于主 Geo 站点上的每个节点，通过 SSH 登录节点并以 root 用户身份登录：

   ```shell
   sudo -i
   ```

1. 编辑 `/etc/gitlab/gitlab.rb`，移除与 Geo 相关的配置，即删除所有启用 `geo_primary_role` 的行：

   ```ruby
   ## 在 11.5 之前的文档中，角色的启用方式如下。请删除此行。
   geo_primary_role['enable'] = true

   ## 在 11.5 及之后的文档中，角色的启用方式如下。请删除此行。
   roles ['geo_primary_role']
   ```

1. 做出这些更改后，[重新配置极狐GitLab](../../restart_gitlab.md#reconfigure-a-linux-package-installation) 以使更改生效。

<a id="optional-revert-postgresql-settings-to-use-a-password-and-listen-on-an-ip"></a>

## （可选）恢复 PostgreSQL 设置以使用密码并在 IP 上监听

如果你希望移除 PostgreSQL 特定设置并恢复默认值（使用套接字），你可以安全地从 `/etc/gitlab/gitlab.rb` 文件中删除以下行：

```ruby
postgresql['sql_user_password'] = '...'
gitlab_rails['db_password'] = '...'
postgresql['listen_address'] = '...'
postgresql['md5_auth_cidr_addresses'] =  ['...', '...']
```