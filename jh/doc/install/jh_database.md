---
stage: Enablement
group: Distribution
info: To determine the technical writer assigned to the Stage/Group associated with this page, see https://about.gitlab.com/handbook/engineering/ux/technical-writing/#assignments
---

# 配置使用极狐独立数据库 **(BASIC SELF)**

本指南记录了如何配置启用极狐独立数据库。

要使用极狐独立数据库，你需要将极狐GitLab 实例配置为使用多数据库支持。

### 注意事项

极狐独立数据库目前仅支持 Linux 安装包，暂不支持其他如 Docker 等方式的极狐GitLab。

### 基于 Linux 安装包的配置步骤

1. 如果是全新安装，请先按照[安装方法](./index.md)让极狐GitLab 实例启动运行起来。

2. 创建配置的备份：

   ```sh
   sudo cp /etc/gitlab/gitlab.rb /etc/gitlab/gitlab.rb.org
   ```

3. 编辑 `/etc/gitlab/gitlab.rb` 并保存更改。

   ```ruby
   ### Gitlab JH database settings
   gitlab_rails['databases']['jh']['enable'] = true
   gitlab_rails['databases']['jh']['db_database'] = "gitlabhq_production_jh"
   gitlab_rails['databases']['jh']['db_database_tasks'] = true
   gitlab_rails['databases']['jh']['db_migrations_paths'] = "jh/db/migrate"
   gitlab_rails['databases']['jh']['db_schema_migrations_path'] = "jh/db/schema_migrations"
   ```

4. 设置数据库权限：

   ```sh
   sudo su - gitlab-psql
   /bin/bash
   psql -h /var/opt/gitlab/postgresql -d template1

   # 在 psql 内执行
   ALTER USER gitlab CREATEDB;
   ```

5. 运行 `sudo gitlab-ctl reconfigure` 命令

6. 运行迁移脚本：

   ```sh
   # 步骤一
   sudo gitlab-rails db:create:jh

   # 步骤二
   sudo gitlab-rails db:migrate:jh
   ```

7. 检查数据库，确认极狐独立数据库（`gitlabhq_production_jh`）已经被正确创建好：

   ```sh
   sudo gitlab-psql -c 'select version()'
   -------------------------------------------------------
   PostgreSQL 13.11 on x86_64-pc-linux-gnu, compiled by gcc (Ubuntu 11.3.0-1ubuntu1~22.04.1) 11.3.0, 64-bit
   (1 row)

   sudo gitlab-psql -c 'SELECT pg_database.datname as "dbname", pg_database_size(pg_database.datname)/1024/1024 AS size_in_mb FROM pg_database ORDER by size_in_mb DESC'

   # 在输出列表中应该能看到 `gitlabhq_production_jh` 出现
            dbname         | size_in_mb
   ------------------------+------------
    gitlabhq_production    |         71
    gitlabhq_production_jh |          7
   ```

8. 运行`sudo gitlab-ctl restart`重启极狐GitLab 实例。

此时，极狐GitLab 实例应该启动并正常运行，且已同时支持主数据库和极狐独立数据库。

### 极狐独立数据库的备份和恢复

目前暂时不支持`gitlab-backup`的备份方式。可以使用 PostgreSQL 的工具来进行备份和恢复。

#### 备份极狐独立数据库

```sh
sudo su - gitlab-psql

$ pg_dump -h /var/opt/gitlab/postgresql -d gitlabhq_production_jh -f /path/to/backup/jhdb_bak.sql
```

#### 恢复极狐独立数据库

```sh
sudo su - gitlab-psql

$ psql -h /var/opt/gitlab/postgresql -d gitlabhq_production_jh < /path/to/backup/jhdb_bak.sql
```
