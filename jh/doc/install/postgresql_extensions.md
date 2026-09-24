---
stage: Data Access
group: Database Operations
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
description: Install and manage PostgreSQL extensions in GitLab Self-Managed, with guidance on handling failures and recovering from failed migrations.
title: 管理 PostgreSQL 扩展
---

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: 私有化部署

{{< /details >}}

本指南介绍了如何为具有外部 PostgreSQL 数据库的极狐GitLab 安装管理 PostgreSQL 扩展。

你必须将以下扩展加载到主 极狐GitLab 数据库（默认为 `gitlabhq_production`）中：

| 扩展    | 最低极狐GitLab 版本 |
|--------------|------------------------|
| `pg_trgm`    | 8.6                    |
| `btree_gist` | 13.1                   |
| `plpgsql`    | 11.7                   |
| `amcheck`    | 18.4                   |

如果你正在使用 极狐GitLab Geo，你必须将以下扩展加载到所有辅助跟踪数据库（默认为 `gitlabhq_geo_production`）中：

| 扩展    | 最低极狐GitLab 版本 |
|--------------|------------------------|
| `plpgsql`    | 9.0                    |

要安装扩展，PostgreSQL 要求用户具有超级用户权限。通常，极狐GitLab 数据库用户不是超级用户。因此，常规数据库迁移无法用于安装扩展，而必须在将极狐GitLab 升级到新版本之前手动安装扩展。

<a id="installing-postgresql-extensions-manually"></a>

## 手动安装 PostgreSQL 扩展

要安装 PostgreSQL 扩展，应遵循以下步骤：

1. 使用超级用户连接到极狐GitLab PostgreSQL 数据库，例如：

   ```shell
   sudo gitlab-psql -d gitlabhq_production
   ```

1. 使用 `CREATE EXTENSION` 安装扩展（本例中为 `btree_gist`）：

   ```sql
   CREATE EXTENSION IF NOT EXISTS btree_gist
   ```

1. 验证已安装的扩展：

   ```shell
    gitlabhq_production=# \dx
                                        List of installed extensions
        Name    | Version |   Schema   |                            Description
    ------------+---------+------------+-------------------------------------------------------------------
    amcheck    | 1.3     | public     | functions for verifying relation integrity
    btree_gist | 1.5     | public     | support for indexing common datatypes in GiST
    pg_trgm    | 1.4     | public     | text similarity measurement and index searching based on trigrams
    plpgsql    | 1.0     | pg_catalog | PL/pgSQL procedural language
    (3 rows)
   ```

在某些系统上，你可能需要安装额外的软件包（例如 `postgresql-contrib`）才能使某些扩展可用。

<a id="typical-failure-scenarios"></a>

## 典型失败场景

以下是一个新的极狐GitLab 安装失败的示例，原因是没有提前安装扩展。

```shell
---- Begin output of "bash"  "/tmp/chef-script20210513-52940-d9b1gs" ----
STDOUT: psql:/opt/gitlab/embedded/service/gitlab-rails/db/structure.sql:9: ERROR:  permission denied to create extension "btree_gist"
HINT:  Must be superuser to create this extension.
rake aborted!
failed to execute:
psql -v ON_ERROR_STOP=1 -q -X -f /opt/gitlab/embedded/service/gitlab-rails/db/structure.sql --single-transaction gitlabhq_production
```

以下是在运行迁移之前未安装扩展的情况示例。在这种情况下，数据库迁移因权限不足无法创建扩展 `btree_gist`。

```shell
== 20200515152649 EnableBtreeGistExtension: migrating =========================
-- execute("CREATE EXTENSION IF NOT EXISTS btree_gist")

GitLab requires the PostgreSQL extension 'btree_gist' installed in database 'gitlabhq_production', but
the database user is not allowed to install the extension.

You can either install the extension manually using a database superuser:

  CREATE EXTENSION IF NOT EXISTS btree_gist

Or, you can solve this by logging in to the GitLab database (gitlabhq_production) using a superuser and running:

    ALTER regular WITH SUPERUSER

This query will grant the user superuser permissions, ensuring any database extensions
can be installed through migrations.
```

要从失败的迁移中恢复，必须由超级用户手动安装该扩展，并通过重新运行数据库迁移来完成极狐GitLab 升级：

```shell
sudo gitlab-rake db:migrate
```