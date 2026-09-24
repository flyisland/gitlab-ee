---
stage: Package
group: Container Registry
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
title: 容器镜像仓库元数据数据库故障排除
description: 排除容器镜像仓库元数据数据库的问题。
---

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: 私有化部署

{{< /details >}}

<a id="error-there-are-pending-database-migrations"></a>

## 错误：`存在待处理的数据库迁移`

如果镜像仓库已更新，但仍有待处理的架构迁移，镜像仓库将无法启动，并显示以下错误消息：

```shell
FATA[0000] 正在配置应用程序：存在待处理的数据库迁移，请使用 'registry database migrate' CLI 命令检查并应用它们
```

要解决此问题，请按照 [应用数据库迁移](container_registry_metadata_database.md#应用数据库迁移) 中的步骤进行操作。

在 18.3 版本之前，您必须在每次版本升级时手动应用数据库迁移。

<a id="error-offline-garbage-collection-is-no-longer-possible"></a>

### 错误：`不再支持离线垃圾回收`

如果镜像仓库使用元数据数据库，并且您尝试运行 [离线垃圾回收](container_registry.md#容器镜像仓库垃圾回收)，镜像仓库将失败并显示以下错误消息：

```shell
ERRO[0000] 此文件系统由元数据数据库管理，不再支持离线垃圾回收，如果您不再使用数据库，请删除此日志消息中 lock_path 处的文件 lock_path=/docker/registry/lockfiles/database-in-use
```

您必须选择以下任一操作：

- 停止使用离线垃圾回收。
- 如果您不再使用元数据数据库，请删除错误消息中显示的 `lock_path` 处指示的锁定文件。
  例如，删除 `/docker/registry/lockfiles/database-in-use` 文件。

<a id="error-cannot-execute-statement-in-a-read-only-transaction"></a>

### 错误：`无法在只读事务中执行 <STATEMENT>`

镜像仓库在 [应用数据库迁移](container_registry_metadata_database.md#应用数据库迁移) 时可能失败，并显示以下错误消息：

```shell
err="ERROR: 无法在只读事务中执行 CREATE TABLE (SQLSTATE 25006)"
```

此外，如果您尝试运行 [在线垃圾回收](container_registry.md#执行无停机的垃圾回收)，镜像仓库也可能失败并显示以下错误消息：

```shell
error="处理任务：获取下一个 GC blob 任务：扫描 GC blob 任务：ERROR: 无法在只读事务中执行 SELECT FOR UPDATE (SQLSTATE 25006)"
```

您必须通过在 PostgreSQL 控制台中检查 `default_transaction_read_only` 和 `transaction_read_only` 的值，来验证只读事务是否被禁用。
例如：

```sql
# SHOW default_transaction_read_only;
 default_transaction_read_only
 -------------------------------
 on
(1 row)

# SHOW transaction_read_only;
 transaction_read_only
 -----------------------
 on
(1 row)
```

如果其中任何一个值设置为 `on`，您必须禁用它：

1. 编辑您的 `postgresql.conf` 并设置以下值：

   ```shell
   default_transaction_read_only=off
   ```

1. 重启您的 Postgres 服务器以应用这些设置。
1. 如果适用，尝试再次 [应用数据库迁移](container_registry_metadata_database.md#应用数据库迁移)。
1. 重启镜像仓库 `sudo gitlab-ctl restart registry`。

<a id="error-cannot-import-all-repositories-while-the-tags-table-has-entries"></a>

### 错误：`当 tags 表中有条目时无法导入所有仓库`

如果您尝试 [导入现有镜像仓库元数据](container_registry_metadata_database.md#为现有镜像仓库启用数据库) 并遇到以下错误：

```shell
ERRO[0000] 无法在 tags 表中有条目的情况下导入所有仓库，您必须手动截断该表后重试，
请参阅 https://gitlab.cn/docs/administration/packages/container_registry_metadata_database/#故障排除
common_blobs=true dry_run=false error="tags 表不为空"
```

当镜像仓库数据库的 `tags` 表中存在现有条目时，会发生此错误，这可能发生在以下情况下：

- 尝试了 [一步导入](container_registry_metadata_database_one_step_import.md) 并遇到错误。
- 尝试了 [三步导入](container_registry_metadata_database_three_step_import.md) 流程并遇到错误。
- 有意停止了导入流程。
- 在执行任何上述操作后再次尝试运行导入。
- 针对错误的配置文件运行了导入。

要解决此问题，您必须删除 tags 表中的现有条目。
您必须在您的 PostgreSQL 实例上手动截断该表：

1. 编辑 `/etc/gitlab/gitlab.rb` 并确保元数据数据库已禁用：

   ```ruby
   registry['database'] = {
     'enabled' => false,
   }
   ```

1. 使用 PostgreSQL 客户端连接到您的镜像仓库数据库。
1. 截断 `tags` 表以删除所有现有条目：

   ```sql
   TRUNCATE TABLE tags RESTART IDENTITY CASCADE;
   ```

1. 截断 `tags` 表后，再次尝试运行导入流程。

<a id="error-database-in-use-lockfile-exists"></a>

### 错误：`存在 database-in-use 锁文件`

如果您尝试 [导入现有镜像仓库元数据](container_registry_metadata_database.md#为现有镜像仓库启用数据库) 并遇到以下错误：

```shell
|  [0s] 第二步：导入标签 导入元数据失败：导入所有仓库：发生 1 个错误：
    * 无法恢复锁文件：存在 database-in-use 锁文件
```

此错误意味着您之前已导入镜像仓库并完成了所有仓库数据的导入（第二步），并且镜像仓库文件系统中存在 `database-in-use` 锁文件。
如果遇到此问题，您不应再次运行导入程序。

如果必须继续，您必须手动从文件系统中删除 `database-in-use` 锁文件。
该文件位于 `/path/to/rootdirectory/docker/registry/lockfiles/database-in-use`。

<a id="error-pre-importing-all-repositories-accessdenied"></a>

### 错误：`导入所有仓库前：AccessDenied：`

在 [导入现有镜像仓库](container_registry_metadata_database.md#为现有镜像仓库启用数据库) 并将 AWS S3 作为您的存储后端时，您可能会收到 `AccessDenied` 错误：

```shell
/opt/gitlab/embedded/bin/registry database import --step-one /var/opt/gitlab/registry/config.yml
  [0s] 第一步：导入清单
  [0s] 第一步：导入清单 导入元数据失败：导入所有仓库前：AccessDenied：拒绝访问
```

请确保执行该命令的用户拥有正确的 [权限范围](https://docker-docs.uclv.cu/registry/storage-drivers/s3/#s3-permission-scopes)。

<a id="registry-fails-to-start-due-to-metadata-management-issues"></a>

### 镜像仓库因元数据管理问题而无法启动

镜像仓库可能因以下错误之一而无法启动：

<a id="error-registry-filesystem-metadata-in-use-please-import-data-before-enabling-the-database"></a>

#### 错误：`镜像仓库文件系统元数据正在使用，请在启用数据库前导入数据`

当您的配置中启用了数据库 `registry['database'] = { 'enabled' => true}`，但您尚未将 [现有镜像仓库元数据](container_registry_metadata_database.md#为现有镜像仓库启用数据库) 导入到元数据数据库时，会发生此错误。

<a id="error-registry-metadata-database-in-use-please-enable-the-database"></a>

#### 错误：`镜像仓库元数据数据库正在使用，请启用数据库`

当您已完成将 [现有镜像仓库元数据](container_registry_metadata_database.md#为现有镜像仓库启用数据库) 导入到元数据数据库，但尚未在配置中启用数据库时，会发生此错误。

<a id="problems-checking-or-creating-the-lock-files"></a>

#### 检查或创建锁定文件时出现问题

如果您遇到以下任何错误：

- `无法检查文件系统元数据是否已锁定`
- `无法检查数据库元数据是否已锁定`
- `无法将文件系统标记为仅限数据库使用`
- `无法将文件系统标记为仅限文件系统使用`

镜像仓库无法访问配置的 `rootdirectory`。如果您之前有一个正常工作的镜像仓库，此错误不太可能发生。请检查错误日志以查找任何配置错误问题。

<a id="storage-usage-not-decreasing-after-deleting-tags"></a>

### 删除标签后存储使用量未减少

默认情况下，在线垃圾回收器仅会在与所有标签关联的时间点起的 48 小时后开始删除未引用的层。此延迟可确保垃圾回收器不会干扰长时间运行或中断的镜像推送，因为层在关联到镜像和标签之前已被推送到镜像仓库。

<a id="error-permission-denied-for-schema-public-sqlstate-42501"></a>

### 错误：`对 schema public 的权限被拒绝 (SQLSTATE 42501)`

在镜像仓库迁移或 GitLab 升级期间，您可能会遇到以下错误之一：

- `ERROR: 对 schema public 的权限被拒绝 (SQLSTATE 42501)`
- `ERROR: 关系 "public.blobs" 不存在 (SQLSTATE 42P01)`

这些类型的错误是由于 PostgreSQL 15+ 中的一项变更，该变更出于安全原因移除了对 public schema 的默认 CREATE 权限。
默认情况下，只有数据库所有者才能在 PostgreSQL 15+ 中的 public schema 中创建对象。

要解决该错误，请运行以下命令，为镜像仓库用户授予镜像仓库数据库的所有者权限：

```sql
ALTER DATABASE <registry_database_name> OWNER TO <registry_user>;
```

这将为镜像仓库用户提供必要的权限，以便成功创建表并运行迁移。

<a id="error-database-in-use-and-filesystem-in-use-lockfiles-present"></a>

### 错误：`同时存在 database-in-use 和 filesystem-in-use 锁文件`

当配置的镜像仓库存储中同时存在 `filesystem-in-use` 和 `database-in-use` 锁文件时，会发生此错误，并表明镜像仓库状态不明确。

要解决此错误，您必须确定您的镜像仓库是应使用元数据数据库还是传统的元数据存储。

如果出现以下情况，您的镜像仓库很可能应使用元数据数据库：

- 您之前已执行了其中一个 [导入流程](container_registry_metadata_database.md#选择正确的导入方法)。
- 您的镜像仓库配置指示镜像仓库已启用。

检查 `/etc/gitlab/gitlab.rb` 中的文件，查看镜像仓库是否已启用：

```ruby
registry['database'] = {
  'enabled' => true,
}
```

确认镜像仓库应使用数据库后，删除配置的镜像仓库存储中存在的 `filesystem-in-use` 锁文件，该文件位于 `/docker/registry/lockfiles/filesystem-in-use`。

或者，如果上述情况不成立，并且您的镜像仓库应使用传统元数据存储，请删除 `/docker/registry/lockfiles/database-in-use` 处的 `database-in-use` 锁文件。

对于 GitLab 18.8 和 18.9，您可以通过将 `REGISTRY_FF_ENFORCE_LOCKFILES` 容器镜像仓库功能标志设置为 `false` 来禁用锁文件检查。
虽然这可以禁用检查，但此错误旨在确保您的镜像仓库数据的完整性，最好确认您正在使用哪种元数据存储。`REGISTRY_FF_ENFORCE_LOCKFILES` 功能标志已在 GitLab 18.10 中移除。有关更多信息，请参阅 [容器镜像仓库功能标志](container_registry.md#容器镜像仓库功能标志)。