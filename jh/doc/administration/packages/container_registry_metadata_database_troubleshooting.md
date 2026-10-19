---
stage: Package
group: Container Registry
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
title: 容器镜像仓库元数据数据库故障排除
description: 排查容器镜像仓库元数据数据库的问题。
---

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: 私有化部署

{{< /details >}}

<a id="error-there-are-pending-database-migrations"></a>

## 错误：`there are pending database migrations`

如果容器镜像仓库已更新且存在待处理的架构迁移，容器镜像仓库将无法启动，并显示以下错误消息：

```shell
FATA[0000] configuring application: there are pending database migrations, use the 'registry database migrate' CLI command to check and apply them
```

要解决此问题，请按照步骤[应用数据库迁移](container_registry_metadata_database.md#apply-database-migrations)。

在 18.3 版本之前，每次版本升级时都必须手动应用数据库迁移。

<a id="error-offline-garbage-collection-is-no-longer-possible"></a>

### 错误：`offline garbage collection is no longer possible`

如果容器镜像仓库使用元数据数据库，而您尝试运行[离线垃圾回收](container_registry.md#container-registry-garbage-collection)，容器镜像仓库将失败，并显示以下错误消息：

```shell
ERRO[0000] this filesystem is managed by the metadata database, and offline garbage collection is no longer possible, if you are not using the database anymore, remove the file at the lock_path in this log message lock_path=/docker/registry/lockfiles/database-in-use
```

您必须执行以下任一操作：

- 停止使用离线垃圾回收。
- 如果您不再使用元数据数据库，请删除错误消息中显示的 `lock_path` 所指示的锁文件。
  例如，删除 `/docker/registry/lockfiles/database-in-use` 文件。

<a id="error-cannot-execute-statement-in-a-read-only-transaction"></a>

### 错误：`cannot execute <STATEMENT> in a read-only transaction`

容器镜像仓库可能无法[应用数据库迁移](container_registry_metadata_database.md#apply-database-migrations)，并显示以下错误消息：

```shell
err="ERROR: cannot execute CREATE TABLE in a read-only transaction (SQLSTATE 25006)"
```

此外，如果您尝试运行[在线垃圾回收](container_registry.md#performing-garbage-collection-without-downtime)，容器镜像仓库也可能失败，并显示以下错误消息：

```shell
error="processing task: fetching next GC blob task: scanning GC blob task: ERROR: cannot execute SELECT FOR UPDATE in a read-only transaction (SQLSTATE 25006)"
```

您必须通过在 PostgreSQL 控制台中检查 `default_transaction_read_only` 和 `transaction_read_only`的值，确认只读事务已禁用。例如：

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

如果其中任一值被设置为 `on`，您必须将其禁用：

1. 编辑 `postgresql.conf` 并设置以下值：

   ```shell
   default_transaction_read_only=off
   ```

1. 重启 Postgres 服务器以应用这些设置。
1. 如果适用，请再次尝试[应用数据库迁移](container_registry_metadata_database.md#apply-database-migrations)。
1. 重启容器镜像仓库 `sudo gitlab-ctl restart registry`。

<a id="error-cannot-import-all-repositories-while-the-tags-table-has-entries"></a>

### 错误：`cannot import all repositories while the tags table has entries`

如果您尝试[导入现有容器镜像仓库元数据](container_registry_metadata_database.md#enable-the-database-for-existing-registries)并遇到以下错误：

```shell
ERRO[0000] cannot import all repositories while the tags table has entries, you must truncate the table manually before retrying,
see https://docs.gitlab.com/administration/packages/container_registry_metadata_database/#troubleshooting
common_blobs=true dry_run=false error="tags table is not empty"
```

当容器镜像仓库数据库的 `tags` 表中存在现有条目时，会发生此错误，以下情况可能导致该问题：

- 尝试了[一步导入](container_registry_metadata_database_one_step_import.md)并遇到错误。
- 尝试了[三步导入](container_registry_metadata_database_three_step_import.md)流程并遇到错误。
- 有意停止了导入流程。
- 在上述任一操作之后再次尝试运行导入。
- 针对错误的配置文件运行了导入。

> [!warning]
> 仅在重试未完成即失败的导入时，才截断 `tags` 表。
> 导入成功后，元数据数据库是容器镜像仓库元数据的唯一副本。
> 如果您在已迁移或生产环境的容器镜像仓库上截断该表，将永久删除标签元数据。
> 您无法通过从对象存储重新导入来重建该元数据。
> 切勿在已从元数据数据库提供流量的容器镜像仓库上运行此过程。

要解决此问题，您必须删除 tags 表中的现有条目。您必须在 PostgreSQL 实例上手动截断该表：

1. 编辑 `/etc/gitlab/gitlab.rb` 并确保元数据数据库已禁用：

   ```ruby
   registry['database'] = {
     'enabled' => false,
   }
   ```

1. 使用 PostgreSQL 客户端连接到您的容器镜像仓库数据库。
1. 截断 `tags` 表以删除所有现有条目：

   ```sql
   TRUNCATE TABLE tags RESTART IDENTITY CASCADE;
   ```

1. 截断 `tags` 表后，请再次尝试运行导入流程。

<a id="error-database-in-use-lockfile-exists"></a>

### 错误：`database-in-use lockfile exists`

如果您尝试[导入现有容器镜像仓库元数据](container_registry_metadata_database.md#enable-the-database-for-existing-registries)并遇到以下错误：

```shell
|  [0s] step two: import tags failed to import metadata: importing all repositories: 1 error occurred:
    * could not restore lockfiles: database-in-use lockfile exists
```

此错误表示您之前已导入容器镜像仓库，并完成了所有容器仓库数据（第二步）的导入，且容器镜像仓库文件系统中存在 `database-in-use`。如果遇到此问题，您不应再次运行导入程序。

如果必须继续，您必须从文件系统中手动删除 `database-in-use` 锁文件。该文件位于 `/path/to/rootdirectory/docker/registry/lockfiles/database-in-use`。

<a id="error-pre-importing-all-repositories-accessdenied"></a>

### 错误：`pre importing all repositories: AccessDenied:`

在使用 AWS S3 作为存储后端[导入现有容器镜像仓库](container_registry_metadata_database.md#enable-the-database-for-existing-registries)时，您可能会收到 `AccessDenied` 错误：

```shell
/opt/gitlab/embedded/bin/registry database import --step-one /var/opt/gitlab/registry/config.yml
  [0s] step one: import manifests
  [0s] step one: import manifests failed to import metadata: pre importing all repositories: AccessDenied: Access Denied
```

请确保执行该命令的用户具有正确的[权限范围](https://docker-docs.uclv.cu/registry/storage-drivers/s3/#s3-permission-scopes)。

<a id="error-convert-field-8-failed-invalid-hex-format"></a>

### 错误：`convert field 8 failed: invalid hex format`

当您将现有容器镜像仓库数据导入元数据数据库时，导入在读取清单时可能会失败：

```shell
ERRO[0000] pre importing tagged manifests common_blobs=false dry_run=false error="finding tagged manifests in database: scanning manifest: convert field 8 failed: invalid hex format"
```

当 PostgreSQL 服务器或容器镜像仓库的数据库角色配置了 `bytea_output = escape` 时，会发生此错误。容器镜像仓库将某些二进制列作为文本读取，并期望使用默认的十六进制格式。

请通过容器镜像仓库使用的同一连接路径检查该值，例如
如果您使用 PgBouncer，则通过 PgBouncer 检查：

```sql
SELECT current_setting('bytea_output');
```

要解决该错误，请将容器镜像仓库数据库的输出格式设置为 `hex`：

```sql
ALTER DATABASE <registry_database> SET bytea_output = 'hex';
```

然后通过重启容器镜像仓库或打开新连接来重新连接，并重试导入。角色级设置会覆盖数据库默认值，因此如果某个角色设置了 `bytea_output`，也请在该角色上设置：

```sql
ALTER ROLE <registry_user> SET bytea_output = 'hex';
```

<a id="registry-fails-to-start-due-to-metadata-management-issues"></a>

### 容器镜像仓库因元数据管理问题而无法启动

容器镜像仓库可能因以下错误之一而无法启动：

<a id="error-registry-filesystem-metadata-in-use-please-import-data-before-enabling-the-database"></a>

#### 错误：`registry filesystem metadata in use, please import data before enabling the database`

当您的配置中启用了数据库 `registry['database'] = { 'enabled' => true}`，但您尚未将[现有容器镜像仓库元数据](container_registry_metadata_database.md#enable-the-database-for-existing-registries)导入到元数据数据库时，会发生此错误。

<a id="error-registry-metadata-database-in-use-please-enable-the-database"></a>

#### 错误：`registry metadata database in use, please enable the database`

当您已完成将[现有容器镜像仓库元数据](container_registry_metadata_database.md#enable-the-database-for-existing-registries)导入到元数据数据库，但尚未在配置中启用数据库时，会发生此错误。

<a id="problems-checking-or-creating-the-lock-files"></a>

#### 检查或创建锁文件时出现问题

如果您遇到以下任一错误：

- `could not check if filesystem metadata is locked`
- `could not check if database metadata is locked`
- `failed to mark filesystem for database only usage`
- `failed to mark filesystem only usage`

容器镜像仓库无法访问配置的 `rootdirectory`。如果您之前有可正常工作的容器镜像仓库，则不太可能发生此错误。请查看错误日志以了解任何配置错误问题。

<a id="storage-usage-not-decreasing-after-deleting-tags"></a>

### 删除标记后存储用量未减少

默认情况下，在线垃圾回收器仅会在与其关联的所有标签被删除 48 小时后，才开始删除未引用的层。此延迟可确保垃圾回收器不会干扰长时间运行或中断的镜像推送，因为层在被关联到镜像和标签之前就已推送到容器镜像仓库。

> [!note]
> 在线垃圾回收会从存储中删除未引用的对象。
> 随后由您的对象存储提供商决定何时回收空间。
> 如果对象版本控制或保留策略无限期保留已删除的对象，提供商
> 将永远不会释放该空间。
> 请配置生命周期规则，使非当前版本过期以回收空间。

<a id="error-permission-denied-for-schema-public-sqlstate-42501"></a>

### 错误：`permission denied for schema public (SQLSTATE 42501)`

在容器镜像仓库迁移或极狐GitLab 升级期间，您可能会遇到以下错误之一：

- `ERROR: permission denied for schema public (SQLSTATE 42501)`
- `ERROR: relation "public.blobs" does not exist (SQLSTATE 42P01)`

这些类型的错误是由于 PostgreSQL 15+ 中的一项变更，出于安全原因，该变更移除了对 public 架构的默认 CREATE 权限。在 PostgreSQL 15+ 中，默认情况下只有数据库所有者才能在 public 架构中创建对象。

要解决该错误，请运行以下命令，为容器镜像仓库用户授予容器镜像仓库数据库的所有者权限：

```sql
ALTER DATABASE <registry_database_name> OWNER TO <registry_user>;
```

这将为容器镜像仓库用户授予创建表并成功运行迁移所需的权限。

<a id="error-database-in-use-and-filesystem-in-use-lockfiles-present"></a>

### 错误：`database-in-use and filesystem-in-use lockfiles present`

当配置的容器镜像仓库存储上同时存在 `filesystem-in-use` 和 `database-in-use` 锁文件时，会发生此错误，这表明容器镜像仓库状态不明确。

要解决此错误，您必须确定您的容器镜像仓库应使用元数据数据库还是旧版元数据存储。

如果符合以下情况，您的容器镜像仓库很可能应使用元数据数据库：

- 您之前执行过[导入流程](container_registry_metadata_database.md#choose-the-right-import-method)之一。
- 您的容器镜像仓库配置表明容器镜像仓库已启用。

检查 `/etc/gitlab/gitlab.rb` 文件，查看容器镜像仓库是否已启用：

```ruby
registry['database'] = {
  'enabled' => true,
}
```

确认容器镜像仓库应使用数据库后，请删除配置的容器镜像仓库存储中存在的 `filesystem-in-use` 锁文件，该文件位于 `/docker/registry/lockfiles/filesystem-in-use`。

或者，如果上述情况不成立，且您的容器镜像仓库应使用旧版元数据存储，请删除位于 `/docker/registry/lockfiles/database-in-use`的 `database-in-use` 锁文件。

对于极狐GitLab 18.8 和 18.9，您可以通过将 `REGISTRY_FF_ENFORCE_LOCKFILES` 容器镜像仓库功能标志设置为 `false` 来禁用锁文件检查。虽然这会禁用检查，但此错误旨在确保容器镜像仓库数据的完整性，最好确认您正在使用哪种元数据存储。`REGISTRY_FF_ENFORCE_LOCKFILES` 功能标志已在极狐GitLab 18.10 中移除。有关更多信息，请参阅[容器镜像仓库功能标志](container_registry.md#container-registry-feature-flags)。
