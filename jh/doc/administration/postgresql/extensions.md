---
stage: Data Access
group: Database Operations
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
title: 管理 PostgreSQL 扩展
description: 为极狐GitLab 私有化部署安装必需和推荐的 PostgreSQL 扩展。
---

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: 私有化部署

{{< /details >}}

极狐GitLab 在每个数据库中都要求特定的 PostgreSQL 扩展。有关必需扩展及最低极狐GitLab 版本的列表，请参阅
[PostgreSQL 要求](../../install/requirements.md#extensions)。

要安装扩展，PostgreSQL 需要超级用户权限。极狐GitLab 数据库用户
通常不是超级用户，因此您必须在升级极狐GitLab 之前手动安装扩展。

<a id="install-required-extensions"></a>

## 安装必需的扩展

1. 使用超级用户连接到极狐GitLab PostgreSQL 数据库，例如：

   ```shell
   sudo gitlab-psql -d gitlabhq_production
   ```

1. 使用
   [`CREATE EXTENSION`](https://www.postgresql.org/docs/16/sql-createextension.html) 安装扩展（本例中为 `btree_gist`）：

   ```sql
   CREATE EXTENSION IF NOT EXISTS btree_gist
   ```

1. 验证已安装的扩展：

   ```shell
   gitlabhq_production=# \dx
   ```

在某些系统上，您可能需要安装额外的软件包（例如，
`postgresql-contrib`）才能使某些扩展可用。

<a id="enable-pg_stat_statements"></a>

## 启用 pg_stat_statements

`pg_stat_statements` 推荐用于排查慢数据库查询。
启用它需要超级用户权限并重启 PostgreSQL。

1. 将 `pg_stat_statements` 添加到 `postgresql.conf` 中的 `shared_preload_libraries`。
   对于 Linux 软件包安装，请将以下内容添加到 `/etc/gitlab/gitlab.rb`：

   ```ruby
   postgresql['shared_preload_libraries'] = 'pg_stat_statements'
   ```

1. 重启 PostgreSQL。
1. 以超级用户身份创建扩展：

   ```sql
   CREATE EXTENSION IF NOT EXISTS pg_stat_statements
   ```

有关更多信息，请参阅
[启用可选的查询统计数据](../raketasks/maintenance.md#enable-optional-query-statistics-data)。

<a id="troubleshooting"></a>

## 故障排查

在使用 PostgreSQL 扩展时，您可能会遇到以下问题。

<a id="migration-fails-because-an-extension-is-missing"></a>

### 迁移因缺少扩展而失败

如果数据库迁移因缺少扩展而失败，请以
超级用户身份手动安装它，然后重新运行迁移：

```shell
sudo gitlab-rake db:migrate
```
