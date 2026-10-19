---
stage: Tenant Scale
group: Gitaly
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
gitlab_dedicated: no
title: 代码仓库存储
description: 极狐GitLab 如何存储代码仓库数据。
---

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: 私有化部署

{{< /details >}}

极狐GitLab 将[代码仓库](../user/project/repository/_index.md)存储在代码仓库存储上。代码仓库存储可以是：

- 使用指向 [Gitaly 节点](gitaly/_index.md)的 `gitaly_address` 配置的物理存储。
- 将代码仓库存储在 Gitaly 集群 (Praefect)上的[虚拟存储](gitaly/praefect/_index.md#virtual-storage)。

> [!warning]
> 代码仓库存储也可以配置为直接指向代码仓库存储目录的 `path`。极狐GitLab 直接访问包含代码仓库的目录这一方式已弃用。您应该将极狐GitLab 配置为通过物理或虚拟存储访问代码仓库。

有关以下内容的更多信息：

- 配置 Gitaly，请参见[配置 Gitaly](gitaly/configure_gitaly.md)。
- 配置 Gitaly 集群 (Praefect)，请参见[配置 Gitaly 集群 (Praefect)](gitaly/praefect/configure.md)。

<a id="hashed-storage"></a>

## 哈希存储

哈希存储根据项目 ID 的哈希值将项目存储在磁盘上的某个位置。这使得文件夹结构不可变，并且无需将 URL 状态同步到磁盘结构。这意味着重命名群组、用户或项目：

- 仅消耗数据库事务成本。
- 立即生效。

哈希还有助于将代码仓库更均匀地分布在磁盘上。顶层目录包含的文件夹数量少于顶层命名空间的总数。

哈希格式基于 SHA256 的十六进制表示，使用 `SHA256(project.id)` 计算得出。顶层文件夹使用前两个字符，后跟另一个使用接下来两个字符的文件夹。它们都存储在一个特殊的 `@hashed` 文件夹中，以便与现有的旧式存储项目共存。例如：

```ruby
# Project's repository:
"@hashed/#{hash[0..1]}/#{hash[2..3]}/#{hash}.git"

# Wiki's repository:
"@hashed/#{hash[0..1]}/#{hash[2..3]}/#{hash}.wiki.git"
```

<a id="translate-hashed-storage-paths"></a>

### 转换哈希存储路径

故障排除 Git 代码仓库问题、添加钩子以及其他任务时，您需要在人类可读的项目名称和哈希存储路径之间进行转换。您可以进行以下转换：

- [从项目名称转换到其哈希路径](#from-project-name-to-hashed-path)。
- [从哈希路径转换到项目名称](#from-hashed-path-to-project-name)。

<a id="from-project-name-to-hashed-path"></a>

#### 从项目名称转换到哈希路径

管理员可以使用以下方式根据项目名称或 ID 查找项目的哈希路径：

- [**管理区域**](admin_area.md#administering-projects)。
- Rails 控制台。

要在**管理区域**中查找项目的哈希路径：

1. 在右上角，选择**管理员**。
1. 在左侧边栏中，选择**概览** > **项目**，然后选择该项目。
1. 找到**相对路径**字段。其值类似于：

   ```plaintext
   "@hashed/b1/7e/b17ef6d19c7a5b1ee83b907c595526dcb1eb06db8227d650d5dda0a9f4ce8cd9.git"
   ```

要使用 Rails 控制台查找项目的哈希路径：

1. 启动 [Rails 控制台](operations/rails_console.md#starting-a-rails-console-session)。
1. 运行类似于以下示例的命令（使用项目的 ID 或其名称）：

   ```ruby
   Project.find(16).disk_path
   Project.find_by_full_path('group/project').disk_path
   ```

<a id="from-hashed-path-to-project-name"></a>

#### 从哈希路径转换到项目名称

管理员可以使用以下方式根据项目的哈希相对路径查找项目名称：

- Rails 控制台。
- `*.git` 目录中的 `config` 文件。

要使用 Rails 控制台查找项目名称：

1. 启动 [Rails 控制台](operations/rails_console.md#starting-a-rails-console-session)。
1. 运行类似于以下示例的命令：

   ```ruby
   ProjectRepository.find_by(disk_path: '@hashed/b1/7e/b17ef6d19c7a5b1ee83b907c595526dcb1eb06db8227d650d5dda0a9f4ce8cd9').project
   ```

该命令中带引号的字符串是您可以在极狐GitLab 服务器上找到的目录树。例如，在默认的 Linux 软件包安装中，这将是 `/var/opt/gitlab/git-data/repositories/@hashed/b1/7e/b17ef6d19c7a5b1ee83b907c595526dcb1eb06db8227d650d5dda0a9f4ce8cd9.git`，并移除目录名称末尾的 `.git`。

输出包括项目 ID 和项目名称。例如：

```plaintext
=> #<Project id:16 it/supportteam/ticketsystem>
```

<a id="from-hashed-path-to-full-path-of-a-project"></a>

#### 从哈希路径转换到项目的完整路径

要使用 Rails 控制台查找项目的完整路径：

1. 启动 [Rails 控制台](operations/rails_console.md#starting-a-rails-console-session)。
1. 运行类似于以下示例的命令：

   ```ruby
   ProjectRepository.find_by(disk_path: '@hashed/b1/7e/b17ef6d19c7a5b1ee83b907c595526dcb1eb06db8227d650d5dda0a9f4ce8cd9').project.full_path
   ```

   在该示例中，命令中带引号的字符串是极狐GitLab 服务器上的目录树。例如，在默认的 Linux 软件包安装中，该字符串将是
   `/var/opt/gitlab/git-data/repositories/@hashed/b1/7e/b17ef6d19c7a5b1ee83b907c595526dcb1eb06db8227d650d5dda0a9f4ce8cd9.git`，
   并移除目录名称末尾的 `.git`。

输出包括项目的完整路径。例如：

```plaintext
=> "it/supportteam/ticketsystem"
```

<a id="hashed-object-pools"></a>

### 哈希对象池

对象池是用于对[公共和内部项目的 forks](../user/project/repository/forking_workflow.md) 进行去重的代码仓库，包含源项目中的对象。通过使用 `objects/info/alternates`，源项目和 forks 使用对象池来共享对象。有关更多信息，请参见极狐GitLab 开发文档中的 Git 对象去重信息。

当对源项目运行清理时，对象会从源项目移动到对象池。对象池代码仓库的存储方式与常规代码仓库类似，但存储在名为 `@pools`的目录中，而不是 `@hashed`中。

```ruby
# object pool paths
"@pools/#{hash[0..1]}/#{hash[2..3]}/#{hash}.git"
```

> [!warning]
> 请勿在对象池代码仓库中运行 `git prune` 或 `git gc`，这些代码仓库存储在 `@pools` 目录中。
> 这可能会导致依赖该对象池的常规代码仓库中的数据丢失。

<a id="translate-hashed-object-pool-storage-paths"></a>

### 转换哈希对象池存储路径

要使用 Rails 控制台查找项目的对象池：

1. 启动 [Rails 控制台](operations/rails_console.md#starting-a-rails-console-session)。
1. 运行类似于以下示例的命令：

   ```ruby
   project_id = 1
   pool_repository = Project.find(project_id).pool_repository
   pool_repository = Project.find_by_full_path('group/project').pool_repository

   # Get more details about the pool repository
   pool_repository.source_project
   pool_repository.member_projects
   pool_repository.shard
   pool_repository.disk_path
   ```

<a id="group-wiki-storage"></a>

### 群组 Wiki 存储

与存储在 `@hashed` 目录中的项目 Wiki 不同，群组 Wiki 存储在名为 `@groups`的目录中。与项目 Wiki 一样，群组 Wiki 遵循哈希存储文件夹约定，但使用群组 ID 的哈希值，而不是项目 ID 的哈希值。

例如：

```ruby
# group wiki paths
"@groups/#{hash[0..1]}/#{hash[2..3]}/#{hash}.wiki.git"
```

<a id="gitaly-cluster-praefect-storage"></a>

### Gitaly 集群 (Praefect)存储

如果使用 Gitaly 集群 (Praefect)，则由 Praefect 管理存储位置。Praefect 为代码仓库使用的内部路径与哈希路径不同。有关更多信息，请参见 [Praefect 生成的副本路径](gitaly/praefect/_index.md#praefect-generated-replica-paths)。

<a id="repository-file-archive-cache"></a>

### 代码仓库文件归档缓存

用户可以通过以下任一方式下载 `.zip` 或 `.tar.gz` 等格式的代码仓库归档：

- 极狐GitLab UI。
- [代码仓库 API](../api/repositories.md#retrieve-file-archive-from-a-repository)。

极狐GitLab 将此归档存储在极狐GitLab 服务器上某个目录的缓存中。

缓存的位置取决于您的安装方式：

- 对于 Linux 软件包实例，文件归档缓存的默认目录是 `/var/opt/gitlab/gitlab-rails/shared/cache/archive`。您可以在 `/etc/gitlab/gitlab.rb`中使用 `gitlab_rails['gitlab_repository_downloads_path']` 设置对此进行配置。
- 对于 Helm chart 实例，缓存存储在 `/srv/gitlab/shared/cache/archive`中。该目录无法配置。

在 Sidekiq 上运行的后台作业会定期清理此目录中的过期归档。因此，所有 Sidekiq 和 GitLab Workhorse 节点都必须能够访问此目录。如果 Sidekiq 无法访问 GitLab Workhorse 使用的同一目录，[包含该目录的磁盘会被写满](https://gitlab.com/gitlab-org/omnibus-gitlab/-/issues/6005)。

如果您不想为 Sidekiq 和 GitLab Workhorse 使用共享挂载，可以改为配置一个单独的 `cron` 作业来删除此目录中的文件。

或者，您可以完全禁用缓存：

{{< tabs >}}

{{< tab title="Linux 软件包（Omnibus）" >}}

要禁用缓存：

1. 在所有运行 Puma 的节点上设置 `WORKHORSE_ARCHIVE_CACHE_DISABLED` 环境变量：

   ```shell
   sudo -e /etc/gitlab/gitlab.rb
   ```

   ```ruby
   gitlab_rails['env'] = { 'WORKHORSE_ARCHIVE_CACHE_DISABLED' => '1' }
   ```

1. 重新配置更新后的节点以使更改生效：

   ```shell
   sudo gitlab-ctl reconfigure
   ```

{{< /tab >}}

{{< tab title="Helm chart（Kubernetes）" >}}

要禁用缓存，您可以使用 `--set gitlab.webservice.extraEnv.WORKHORSE_ARCHIVE_CACHE_DISABLED="1"`，或在您的 values 文件中指定以下内容：

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

此表显示了哪些可存储对象可以存储在每种存储类型中：

| 可存储对象  | 哈希存储 | S3 兼容 |
|:-----------------|:---------------|:--------------|
| 代码仓库       | 是            | -             |
| 附件      | 是            | -             |
| 头像          | 否             | -             |
| Pages            | 否             | -             |
| Docker Registry  | 否             | -             |
| CI/CD 作业日志   | 否             | -             |
| CI/CD 产物  | 否             | 是           |
| CI/CD 缓存      | 否             | 是           |
| LFS 对象      | 类似        | 是           |
| 代码仓库池 | 是            | -             |

存储在 S3 兼容端点中的文件可以具有与[哈希存储](#hashed-storage)相同的优势，只要它们不以 `#{namespace}/#{project_name}` 为前缀即可。CI/CD 缓存和 LFS 对象就是如此。

<a id="avatars"></a>

#### 头像

每个文件都存储在与数据库中分配给它的 `id` 匹配的目录中。对于用户头像，文件名始终是 `avatar.png`。当头像被替换时，`Upload` 模型会被销毁，并使用不同的 `id` 创建新模型。

<a id="cicd-artifacts"></a>

#### CI/CD 产物

CI/CD 产物是 S3 兼容的。

<a id="lfs-objects"></a>

#### LFS 对象

[极狐GitLab 中的 LFS 对象](../topics/git/lfs/_index.md)遵循 Git 实现，使用两个字符和两级文件夹实现了类似的存储模式：

```ruby
"shared/lfs-objects/#{oid[0..1}/#{oid[2..3]}/#{oid[4..-1]}"

# Based on object `oid`: `8909029eb962194cfb326259411b22ae3f4a814b5be4f80651735aeef9f3229c`, path will be:
"shared/lfs-objects/89/09/029eb962194cfb326259411b22ae3f4a814b5be4f80651735aeef9f3229c"
```

LFS 对象也是 [S3 兼容的](lfs/_index.md#storing-lfs-objects-in-remote-object-storage)。

<a id="configure-where-new-repositories-are-stored"></a>

## 配置新代码仓库的存储位置

在[配置多个代码仓库存储](https://gitlab.cn/docs/omnibus/settings/configuration/#store-git-data-in-an-alternative-directory)之后，您可以选择新代码仓库的存储位置：

1. 在右上角，选择**管理员**。
1. 在左侧边栏中，选择**设置** > **代码仓库**。
1. 展开**代码仓库存储**。
1. 在**新代码仓库的存储节点**字段中输入值。
1. 选择**保存更改**。

每个代码仓库存储路径都可以分配一个 0-100 的权重。创建新项目时，这些权重用于确定代码仓库的存储位置。

某个代码仓库存储路径相对于其他代码仓库存储路径的权重越高，它被选中的频率就越高（`(storage weight) / (sum of all weights) * 100 = chance %`）。

默认情况下，如果之前未配置代码仓库权重：

- `default`的权重为 `100`。
- 所有其他存储的权重为 `0`。

> [!note]
> 如果所有存储权重均为 `0`（例如，当 `default` 不存在时），极狐GitLab 会尝试在 `default` 上创建新代码仓库，而不管配置如何或 `default` 是否存在。
> 有关更多信息，请参见[跟踪议题](https://gitlab.com/gitlab-org/gitlab/-/issues/36175)。

<a id="move-repositories"></a>

## 移动代码仓库

要将代码仓库移动到不同的代码仓库存储（例如，从 `default` 移动到 `storage2`），请使用与[迁移到 Gitaly 集群 (Praefect)](gitaly/praefect/_index.md#migrate-to-gitaly-cluster-praefect) 相同的流程。
