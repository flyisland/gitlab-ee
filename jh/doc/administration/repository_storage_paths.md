---
stage: Tenant Scale
group: Gitaly
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
gitlab_dedicated: no
title: 仓库存储
description: How 极狐GitLab stores repository data.
---

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: 私有化部署

{{< /details >}}

极狐GitLab 将[仓库](../user/project/repository/_index.md)存储在仓库存储上。仓库存储可以是：

- 物理存储，配置有 `gitaly_address` 指向 [Gitaly 节点](gitaly/_index.md)。
- [虚拟存储](gitaly/praefect/_index.md#virtual-storage)，在 Gitaly 集群 (Praefect) 上存储仓库。

> [!warning]
> 仓库存储可以配置为一个 `path`，直接指向存储仓库的目录。直接从包含仓库的目录访问的做法已被弃用。您应该将极狐GitLab 配置为通过物理或虚拟存储来访问仓库。

有关更多信息，请参阅：

- 配置 Gitaly，请参阅[配置 Gitaly](gitaly/configure_gitaly.md)。
- 配置 Gitaly 集群 (Praefect)，请参阅[配置 Gitaly 集群 (Praefect)](gitaly/praefect/configure.md)。

<a id="hashed-storage"></a>

## 哈希存储

哈希存储根据项目 ID 的哈希值将项目存储在磁盘上的某位置。这使文件夹结构不可变，无需将状态从 URL 同步到磁盘结构。这意味着重命名群组、用户或项目：

- 仅产生数据库事务开销。
- 立即生效。

哈希还有助于将仓库更均匀地分布在磁盘上。顶级目录包含的文件夹数量少于顶级命名空间的总数。

哈希格式基于 SHA256 的十六进制表示，使用 `SHA256(project.id)` 计算得出。顶级文件夹使用前两个字符，然后是下两个字符的文件夹。它们都存储在一个特殊的 `@hashed` 文件夹中，以便与现有的遗留存储项目共存。例如：

```ruby
# 项目的仓库：
"@hashed/#{hash[0..1]}/#{hash[2..3]}/#{hash}.git"

# 维基的仓库：
"@hashed/#{hash[0..1]}/#{hash[2..3]}/#{hash}.wiki.git"
```

<a id="translate-hashed-storage-paths"></a>

### 转换哈希存储路径

在排查 Git 仓库问题、添加钩子及其他任务时，您需要在可读的项目名称与哈希存储路径之间进行转换。您可以进行以下转换：

- [从项目名称到哈希路径](#from-project-name-to-hashed-path)
- [从哈希路径到项目名称](#from-hashed-path-to-project-name)

<a id="from-project-name-to-hashed-path"></a>

#### 从项目名称到哈希路径

{{< history >}}

- **相对路径** 字段在极狐GitLab 16.3 中从 **Gitaly 相对路径** 重命名。

{{< /history >}}

管理员可以使用以下方式根据项目名称或 ID 查找其哈希路径：

- [**管理员** 区域](admin_area.md#administering-projects)
- Rails 控制台

在**管理员**区域查找项目的哈希路径：

1. 在右上角，选择 **管理员**。
1. 在左侧边栏中，选择 **概览** > **项目**，然后选择该项目。
1. 找到 **相对路径** 字段。其值类似于：

   ```plaintext
   "@hashed/b1/7e/b17ef6d19c7a5b1ee83b907c595526dcb1eb06db8227d650d5dda0a9f4ce8cd9.git"
   ```

使用 Rails 控制台查找项目的哈希路径：

1. 启动 [Rails 控制台](operations/rails_console.md#starting-a-rails-console-session)。
1. 运行类似以下示例的命令（使用项目 ID 或其名称）：

   ```ruby
   Project.find(16).disk_path
   Project.find_by_full_path('group/project').disk_path
   ```

<a id="from-hashed-path-to-project-name"></a>

#### 从哈希路径到项目名称

管理员可以使用以下方式根据哈希相对路径查找项目名称：

- Rails 控制台
- `*.git` 目录中的 `config` 文件

使用 Rails 控制台查找项目名称：

1. 启动 [Rails 控制台](operations/rails_console.md#starting-a-rails-console-session)。
1. 运行类似以下示例的命令：

   ```ruby
   ProjectRepository.find_by(disk_path: '@hashed/b1/7e/b17ef6d19c7a5b1ee83b907c595526dcb1eb06db8227d650d5dda0a9f4ce8cd9').project
   ```

该命令中引用的字符串是您可以在极狐GitLab 服务器上找到的目录树。例如，在默认的 Linux 软件包安装中，这会是 `/var/opt/gitlab/git-data/repositories/@hashed/b1/7e/b17ef6d19c7a5b1ee83b907c595526dcb1eb06db8227d650d5dda0a9f4ce8cd9.git`，并移除了目录名称尾部的 `.git`。

输出包含项目 ID 和项目名称。例如：

```plaintext
=> #<Project id:16 it/supportteam/ticketsystem>
```

<a id="from-hashed-path-to-full-path-of-a-project"></a>

#### 从哈希路径到项目的完整路径

要使用 Rails 控制台查找项目的完整路径：

1. 启动 [Rails 控制台](operations/rails_console.md#starting-a-rails-console-session)。
1. 运行类似以下示例的命令：

   ```ruby
   ProjectRepository.find_by(disk_path: '@hashed/b1/7e/b17ef6d19c7a5b1ee83b907c595526dcb1eb06db8227d650d5dda0a9f4ce8cd9').project.full_path
   ```

   在此示例中，该命令中引用的字符串是您极狐GitLab 服务器上的目录树。例如，在默认的 Linux 软件包安装中，此字符串为
   `/var/opt/gitlab/git-data/repositories/@hashed/b1/7e/b17ef6d19c7a5b1ee83b907c595526dcb1eb06db8227d650d5dda0a9f4ce8cd9.git`，
   并移除了目录名称尾部的 `.git`。

输出包含项目的完整路径。例如：

```plaintext
=> "it/supportteam/ticketsystem"
```

<a id="hashed-object-pools"></a>

### 哈希对象池

对象池是用于去重[公开和内部项目的派生](../user/project/repository/forking_workflow.md)并包含源项目中对象的仓库。通过 `objects/info/alternates`，源项目和派生使用对象池获取共享对象。有关更多信息，请参阅极狐GitLab 开发文档中的 Git 对象去重信息。

在对源项目运行清理时，对象会从源项目移动到对象池。对象池仓库存储方式与常规仓库类似，但存放在 `@pools` 而非 `@hashed` 目录中。

```ruby
# 对象池路径
"@pools/#{hash[0..1]}/#{hash[2..3]}/#{hash}.git"
```

> [!warning]
> 不要对存储在 `@pools` 目录中的对象池仓库运行 `git prune` 或 `git gc`。
> 这会导致依赖对象池的常规仓库中的数据丢失。

<a id="translate-hashed-object-pool-storage-paths"></a>

### 转换哈希对象池存储路径

使用 Rails 控制台查找项目的对象池：

1. 启动 [Rails 控制台](operations/rails_console.md#starting-a-rails-console-session)。
1. 运行类似以下示例的命令：

   ```ruby
   project_id = 1
   pool_repository = Project.find(project_id).pool_repository
   pool_repository = Project.find_by_full_path('group/project').pool_repository

   # 获取对象池仓库的更多详细信息
   pool_repository.source_project
   pool_repository.member_projects
   pool_repository.shard
   pool_repository.disk_path
   ```

<a id="group-wiki-storage"></a>

### 群组维基存储

与存储在 `@hashed` 目录中的项目维基不同，群组维基存储在名为 `@groups` 的目录中。与项目维基类似，群组维基遵循哈希存储文件夹约定，但使用群组 ID 的哈希值，而非项目 ID。

例如：

```ruby
# 群组维基路径
"@groups/#{hash[0..1]}/#{hash[2..3]}/#{hash}.wiki.git"
```

<a id="gitaly-cluster-praefect-storage"></a>

### Gitaly 集群 (Praefect) 存储

如果使用了 Gitaly 集群 (Praefect)，则 Praefect 管理存储位置。Praefect 用于仓库的内部路径与哈希路径不同。有关更多信息，请参见 [Praefect 生成的副本路径](gitaly/praefect/_index.md#praefect-generated-replica-paths)。

<a id="repository-file-archive-cache"></a>

### 仓库文件归档缓存

用户可以通过以下方式下载仓库的 `.zip` 或 `.tar.gz` 等格式归档：

- 极狐GitLab UI。
- [仓库 API](../api/repositories.md#retrieve-file-archive-from-a-repository)。

极狐GitLab 将此归档缓存存储在极狐GitLab 服务器上的一个目录中。

缓存的位置取决于您的安装方式：

- 对于 Linux 软件包实例，文件归档缓存的默认目录是 `/var/opt/gitlab/gitlab-rails/shared/cache/archive`。您可以通过 `/etc/gitlab/gitlab.rb` 中的 `gitlab_rails['gitlab_repository_downloads_path']` 设置来配置此目录。
- 对于 Helm 图表实例，缓存存储在 `/srv/gitlab/shared/cache/archive` 中。该目录无法配置。

在 Sidekiq 上运行的后台作业会定期从此目录清理过期的归档。因此，所有 Sidekiq 和 GitLab Workhorse 节点必须能够访问此目录。如果 Sidekiq 无法访问 GitLab Workhorse 使用的同一目录，则包含该目录的磁盘会填满。

如果您不想为 Sidekiq 和 GitLab Workhorse 使用共享挂载，您可以改为配置单独的 `cron` 作业来删除该目录中的文件。

或者，您可以完全禁用缓存：

{{< tabs >}}

{{< tab title="Linux 软件包 (Omnibus)" >}}

要禁用缓存：

1. 在所有运行 Puma 的节点上设置 `WORKHORSE_ARCHIVE_CACHE_DISABLED` 环境变量：

   ```shell
   sudo -e /etc/gitlab/gitlab.rb
   ```

   ```ruby
   gitlab_rails['env'] = { 'WORKHORSE_ARCHIVE_CACHE_DISABLED' => '1' }
   ```

1. 重新配置更新的节点以使更改生效：

   ```shell
   sudo gitlab-ctl reconfigure
   ```

{{< /tab >}}

{{< tab title="Helm chart (Kubernetes)" >}}

要禁用缓存，您可以使用 `--set gitlab.webservice.extraEnv.WORKHORSE_ARCHIVE_CACHE_DISABLED="1"`，或在您的 values 文件中指定如下内容：

```yaml
gitlab:
  webservice:
    extraEnv:
      WORKHORSE_ARCHIVE_CACHE_DISABLED: "1"
```

{{< /tab >}}

{{< /tabs >}}

<a id="object-storage-support"></a>

### 对象存储支持

此表格显示每种存储类型中哪些可存储对象可以存储：

| 可存储对象      | 哈希存储 | 兼容 S3 |
|:-----------------|:---------------|:--------------|
| 仓库             | 是            | -             |
| 附件             | 是            | -             |
| 头像             | 否            | -             |
| Pages            | 否            | -             |
| Docker Registry  | 否            | -             |
| CI/CD 作业日志   | 否            | -             |
| CI/CD 产物       | 否            | 是           |
| CI/CD 缓存       | 否            | 是           |
| LFS 对象         | 类似          | 是           |
| 仓库池           | 是            | -             |

存储在 S3 兼容端点中的文件只要没有以 `#{namespace}/#{project_name}` 为前缀，就可以具有与[哈希存储](#hashed-storage)相同的优点。这对于 CI/CD 缓存和 LFS 对象来说确实如此。

<a id="avatars"></a>

#### 头像

每个文件都存储在与其在数据库中分配的 `id` 相匹配的目录中。用户头像的文件名始终为 `avatar.png`。替换头像时，`Upload` 模型会被销毁，并创建一个具有不同 `id` 的新模型。

<a id="cicd-artifacts"></a>

#### CI/CD 产物

CI/CD 产物兼容 S3。

<a id="lfs-objects"></a>

#### LFS 对象

[极狐GitLab 中的 LFS 对象](../topics/git/lfs/_index.md) 实现了类似的存储模式，使用两个字符和二级文件夹，遵循 Git 实现：

```ruby
"shared/lfs-objects/#{oid[0..1}/#{oid[2..3]}/#{oid[4..-1]}"

# 基于对象 `oid`: `8909029eb962194cfb326259411b22ae3f4a814b5be4f80651735aeef9f3229c`，路径将是：
"shared/lfs-objects/89/09/029eb962194cfb326259411b22ae3f4a814b5be4f80651735aeef9f3229c"
```

LFS 对象也[兼容 S3](lfs/_index.md#storing-lfs-objects-in-remote-object-storage)。

<a id="configure-where-new-repositories-are-stored"></a>

## 配置新仓库的存储位置

在[配置多个仓库存储](https://gitlab.cn/docs/omnibus/settings/configuration/#store-git-data-in-an-alternative-directory)后，您可以选择新仓库的存储位置：

1. 在右上角，选择 **管理员**。
1. 在左侧边栏中，选择 **设置** > **仓库**。
1. 展开 **仓库存储**。
1. 在 **新仓库的存储节点** 字段中输入值。
1. 选择 **保存更改**。

每个仓库存储路径可以被分配一个从 0 到 100 的权重。创建新项目时，这些权重用于确定仓库创建在哪个存储位置上。

给定仓库存储路径的权重相对于其他仓库存储路径越高，被选中的频率就越高（`(存储权重) / (所有权重之和) * 100 = 概率 %`）。

默认情况下，如果之前未配置仓库权重：

- `default` 的权重为 `100`。
- 所有其他存储的权重为 `0`。

> [!note]
> 如果所有存储权重均为 `0`（例如，当 `default` 不存在时），极狐GitLab 会尝试在 `default` 上创建新仓库，无论配置如何或 `default` 是否存在。

<a id="move-repositories"></a>

## 移动仓库

要将仓库移动到不同的仓库存储（例如，从 `default` 到 `storage2`），请使用与[迁移到 Gitaly 集群 (Praefect)](gitaly/praefect/_index.md#migrate-to-gitaly-cluster-praefect) 相同的过程。