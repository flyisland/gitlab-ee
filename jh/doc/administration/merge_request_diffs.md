---
stage: Create
group: Code Review
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
description: Configure external storage for merge request diffs on your GitLab instance.
title: 合并请求差异存储
---

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: 私有化部署

{{< /details >}}

合并请求差异（diffs）是与合并请求相关联的差异的有大小限制的副本。在查看合并请求时，会尽可能从这些副本获取差异，以优化性能。

默认情况下，极狐GitLab 将合并请求差异存储在数据库中，表名为 `merge_request_diff_files`。较大规模的安装可能会发现该表变得过大，此时应切换到外部存储。

合并请求差异可以存储于：

- 完全[在磁盘上](#using-external-storage)。
- 完全[在对象存储上](#using-object-storage)。
- 当前差异在数据库中，[过时差异在对象存储中](#alternative-in-database-storage)。

<a id="using-external-storage"></a>

## 使用外部存储

{{< tabs >}}

{{< tab title="Linux 安装包 (Omnibus)" >}}

1. 编辑 `/etc/gitlab/gitlab.rb` 并添加以下行：

   ```ruby
   gitlab_rails['external_diffs_enabled'] = true
   ```

2. 外部差异默认存储在 `/var/opt/gitlab/gitlab-rails/shared/external-diffs`。要更改路径，例如改为 `/mnt/storage/external-diffs`，请编辑 `/etc/gitlab/gitlab.rb` 并添加以下行：

   ```ruby
   gitlab_rails['external_diffs_storage_path'] = "/mnt/storage/external-diffs"
   ```

3. 保存文件并[重新配置极狐GitLab](restart_gitlab.md#reconfigure-a-linux-package-installation) 以使更改生效。然后极狐GitLab 会将现有合并请求差异迁移至外部存储。

{{< /tab >}}

{{< tab title="自行编译（源码）" >}}

1. 编辑 `/home/git/gitlab/config/gitlab.yml` 并添加或修改以下行：

   ```yaml
   external_diffs:
     enabled: true
   ```

2. 外部差异默认存储在 `/home/git/gitlab/shared/external-diffs`。要更改路径，例如改为 `/mnt/storage/external-diffs`，请编辑 `/home/git/gitlab/config/gitlab.yml` 并添加或修改以下行：

   ```yaml
   external_diffs:
     enabled: true
     storage_path: /mnt/storage/external-diffs
   ```

3. 保存文件并[重启极狐GitLab](restart_gitlab.md#self-compiled-installations) 以使更改生效。然后极狐GitLab 会将现有合并请求差异迁移至外部存储。

{{< /tab >}}

{{< /tabs >}}

<a id="using-object-storage"></a>

## 使用对象存储

> [!warning]
> 迁移到对象存储是不可逆的。

不应将外部差异存储在磁盘上，而应使用类似 AWS S3 的对象存储。此配置依赖于有效且已预配置的 AWS 凭证。

> [!note]
> 在统一对象存储设置中为外部差异配置对象存储不会自动启用合并请求差异的外部存储。你必须显式将 `external_diffs_enabled` 设置为 `true`。

要配置外部差异的对象存储：

{{< tabs >}}

{{< tab title="Linux 安装包 (Omnibus)" >}}

1. 编辑 `/etc/gitlab/gitlab.rb` 并添加以下行：

   ```ruby
   gitlab_rails['external_diffs_enabled'] = true
   ```

2. 配置[统一对象存储设置](object_storage.md#configure-a-single-storage-connection-for-all-object-types-consolidated-form)。
3. 保存文件并[重新配置极狐GitLab](restart_gitlab.md#reconfigure-a-linux-package-installation) 以使更改生效。

{{< /tab >}}

{{< tab title="自行编译（源码）" >}}

1. 编辑 `/home/git/gitlab/config/gitlab.yml` 并添加或修改以下行：

   ```yaml
   external_diffs:
     enabled: true
   ```

2. 配置[统一对象存储设置](object_storage.md#configure-a-single-storage-connection-for-all-object-types-consolidated-form)。
3. 保存文件并[重启极狐GitLab](restart_gitlab.md#self-compiled-installations) 以使更改生效。

{{< /tab >}}

{{< /tabs >}}

重新配置或重启极狐GitLab 后，现有合并请求差异即迁移至外部存储。

有关更多信息，请参阅[对象存储](object_storage.md)。

<a id="alternative-in-database-storage"></a>

## 替代的数据库内存储

启用外部差异可能会降低合并请求的性能，因为必须通过单独的操作来检索它们与其他数据。一个折衷方案是仅将过时的差异存储在外部，而将当前差异保留在数据库中。

要启用此功能，请执行以下步骤：

{{< tabs >}}

{{< tab title="Linux 安装包 (Omnibus)" >}}

1. 编辑 `/etc/gitlab/gitlab.rb` 并添加以下行：

   ```ruby
   gitlab_rails['external_diffs_when'] = 'outdated'
   ```

2. 保存文件并[重新配置极狐GitLab](restart_gitlab.md#reconfigure-a-linux-package-installation) 以使更改生效。

{{< /tab >}}

{{< tab title="自行编译（源码）" >}}

1. 编辑 `/home/git/gitlab/config/gitlab.yml` 并添加或修改以下行：

   ```yaml
   external_diffs:
     enabled: true
     when: outdated
   ```

2. 保存文件并[重启极狐GitLab](restart_gitlab.md#self-compiled-installations) 以使更改生效。

{{< /tab >}}

{{< /tabs >}}

启用此功能后，差异最初会存储在数据库中，而非外部。当满足以下任一条件时，它们会被移至外部存储：

- 存在更新版本的合并请求差异
- 合并请求在七天前被合并
- 合并请求在七天前被关闭

这些规则通过在数据库中仅存储经常访问的差异来平衡空间和性能。不太可能被访问的差异将被移至外部存储。

<a id="switching-from-external-storage-to-object-storage"></a>

## 从外部存储切换到对象存储

自动迁移会移动数据库中存储的差异，但不会在存储类型之间移动差异。要从外部存储切换到对象存储：

1. 手动将本地或 NFS 存储上的文件移动到对象存储。
2. 运行此 Rake 任务以更改其在数据库中的位置。

   对于 Linux 安装包：

   ```shell
   sudo gitlab-rake gitlab:external_diffs:force_object_storage
   ```

   对于自行编译安装：

   ```shell
   sudo -u git -H bundle exec rake gitlab:external_diffs:force_object_storage RAILS_ENV=production
   ```

   默认情况下，`sudo` 不会保留现有环境变量。你应该将它们追加，而不是前置，像这样：

   ```shell
   sudo gitlab-rake gitlab:external_diffs:force_object_storage START_ID=59946109 END_ID=59946109 UPDATE_DELAY=5
   ```

这些环境变量会修改 Rake 任务的行为：

| 名称 | 默认值 | 用途 |
| --- | --- | --- |
| `ANSI` | `true` | 使用 ANSI 转义码使输出更易理解。 |
| `BATCH_SIZE` | `1000` | 按此大小的批次遍历表。 |
| `START_ID` | `nil` | 如果设置，从此 ID 开始扫描。 |
| `END_ID` | `nil` | 如果设置，在此 ID 停止扫描。 |
| `UPDATE_DELAY` | `1` | 更新之间的睡眠秒数。 |

- `START_ID` 和 `END_ID` 可用于并行运行更新，通过将不同进程分配给表的不同部分来实现。
- `BATCH` 和 `UPDATE_DELAY` 允许在迁移速度与并发访问表之间进行权衡。
- 如果您的终端不支持 ANSI 转义码，应将 `ANSI` 设置为 `false`。

要检查外部差异在对象存储和本地存储之间的分布，请使用以下 SQL 查询：

```shell
gitlabhq_production=# SELECT count(*) AS total,
  SUM(CASE
    WHEN external_diff_store = '1' THEN 1
    ELSE 0
  END) AS filesystem,
  SUM(CASE
    WHEN external_diff_store = '2' THEN 1
    ELSE 0
  END) AS objectstg
FROM merge_request_diffs;
```